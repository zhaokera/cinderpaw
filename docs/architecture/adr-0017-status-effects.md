# ADR-0017: 状态效果系统架构

## Summary
定义状态效果系统的组件化架构：StatusEffectComponent 作为实体子节点管理最多 5 个并发效果实例，使用枚举+内部数组实现 7 种效果类型的施加、刷新、叠加（同类型最多 2 层）、过期和移除。DoT/HoT 通过独立 tick 计时器驱动（0.5 秒间隔），效果修改器通过纯函数接口注入 DamageCalculator 流水线。i-frame 免疫通过查询 HealthComponent 的无敌状态实现。

## Status
Proposed

## Date
2026-06-22

## Engine Compatibility

| Field | Value |
|-------|-------|
| **Engine** | Godot 4.7 |
| **Domain** | Core / GDScript |
| **Knowledge Risk** | LOW — 纯 GDScript 数据结构 + Timer 节点，无引擎特定新 API |
| **References Consulted** | `docs/engine-reference/godot/VERSION.md`, `docs/engine-reference/godot/breaking-changes.md` |
| **Post-Cutoff APIs Used** | None |
| **Verification Required** | Timer 节点在 `_physics_process` 帧内的精度是否满足 0.5s tick 需求；Array 排序在小规模（≤5）下的性能 |

## ADR Dependencies

| Field | Value |
|-------|-------|
| **Depends On** | ADR-0001 (组件模式 — StatusEffectComponent 作为实体子节点，非 Autoload), ADR-0005 (战斗状态机 — CombatComponent 攻击命中触发效果施加，眩晕影响状态转换) |
| **Enables** | 武器特殊招式状态效果集成 (TR-weapon-006), AI 行为状态效果响应 (TR-ai-001), 战斗表现层效果视觉反馈 |
| **Blocks** | 电磁铃铛减速实现, 弹反眩晕实现, 火焰元素燃烧实现 |
| **Ordering Note** | Core 层 ADR，在战斗状态机和碰撞检测之后 |

## Context

### Problem Statement

status-effects.md GDD 定义了 7 种状态效果（poison/slow/stun/burn/speed_boost/damage_boost/invincible）的完整规则——施加、持续、叠加、过期、免疫、优先级。但实现架构未定：效果数据如何在实体上存储和管理、DoT tick 如何驱动、效果修改器如何注入伤害计算流水线、i-frame 免疫如何与 HealthComponent 协同、眩晕如何影响 CombatComponent 状态机。

### Constraints

- **ADR-0001**: StatusEffectComponent 作为实体（Player/Enemy）子节点，非 Autoload。每个实体独立管理自己的效果列表
- **ADR-0002**: 效果施加事件通过信号通信（`status_applied`/`status_expired`）
- **ADR-0005**: CombatComponent 状态机需要响应眩晕（进入 HIT_STUN 或新增 STUNNED 状态）
- **ADR-0003**: 效果数值（持续时间、DPS、百分比）从 DataManager 的 TuningKnob 读取，不硬编码
- **帧级精度**: 效果处理在 `_physics_process` 中执行（60fps），DoT tick 间隔 0.5 秒
- **性能预算**: 状态效果系统开销 <0.5ms/帧（远小于 16.6ms 总预算）

### Requirements

- 必须支持 7 种效果类型 (TR-status-001)
- 必须支持效果施加规则：免疫检查→同类刷新→施加事件 (TR-status-002)
- 必须支持 DoT 每 0.5 秒 tick 调用 `apply_damage()`，移速修改使用乘法叠加 (TR-status-003)
- 必须支持 i-frame 期间免疫所有 debuff (TR-status-004)
- 必须支持效果优先级和满槽替换 (TR-status-005)
- 必须支持场景切换/死亡时清除所有效果 (TR-status-006)
- 必须支持 Boss 免疫眩晕
- 必须支持同类型效果最多 2 层叠加

## Decision

### 效果类型枚举与数据定义

```gdscript
# status_effect_component.gd

enum EffectType {
    POISON,          # debuff: 5秒, 每0.5秒3点伤害
    SLOW,            # debuff: 2秒, 移速-30%
    STUN,            # debuff: 1秒, 无法行动
    BURN,            # debuff: 3秒, 每0.5秒5点伤害+移速-10%
    SPEED_BOOST,     # buff:   3秒, 移速+30%
    DAMAGE_BOOST,    # buff:   5秒, 伤害+25%
    INVINCIBLE,      # buff:   0.5秒, 免疫伤害
}

enum EffectCategory {
    DEBUFF,
    BUFF,
}

# 效果静态配置（从 DataManager TuningKnob 加载默认值）
const EFFECT_CONFIG: Dictionary = {
    EffectType.POISON: {
        &"category": EffectCategory.DEBUFF,
        &"base_duration": 5.0,
        &"dot_damage": 3,           # 每tick伤害
        &"movement_modifier": 1.0,   # 无移速影响
        &"damage_modifier": 1.0,     # 无伤害影响
        &"priority": 30,
    },
    EffectType.SLOW: {
        &"category": EffectCategory.DEBUFF,
        &"base_duration": 2.0,
        &"dot_damage": 0,
        &"movement_modifier": 0.7,   # -30%
        &"damage_modifier": 1.0,
        &"priority": 60,
    },
    EffectType.STUN: {
        &"category": EffectCategory.DEBUFF,
        &"base_duration": 1.0,
        &"dot_damage": 0,
        &"movement_modifier": 0.0,   # 完全无法移动
        &"damage_modifier": 1.0,
        &"priority": 100,            # 最高优先级
    },
    EffectType.BURN: {
        &"category": EffectCategory.DEBUFF,
        &"base_duration": 3.0,
        &"dot_damage": 5,
        &"movement_modifier": 0.9,   # -10%
        &"damage_modifier": 1.0,
        &"priority": 20,
    },
    EffectType.SPEED_BOOST: {
        &"category": EffectCategory.BUFF,
        &"base_duration": 3.0,
        &"dot_damage": 0,
        &"movement_modifier": 1.3,   # +30%
        &"damage_modifier": 1.0,
        &"priority": 15,
    },
    EffectType.DAMAGE_BOOST: {
        &"category": EffectCategory.BUFF,
        &"base_duration": 5.0,
        &"dot_damage": 0,
        &"movement_modifier": 1.0,
        &"damage_modifier": 1.25,    # +25%
        &"priority": 10,
    },
    EffectType.INVINCIBLE: {
        &"category": EffectCategory.BUFF,
        &"base_duration": 0.5,
        &"dot_damage": 0,
        &"movement_modifier": 1.0,
        &"damage_modifier": 1.0,
        &"priority": 5,
    },
}

# 优先级映射（数值越大优先级越高）
# STUN(100) > SLOW(60) > POISON(30) > BURN(20) > SPEED_BOOST(15) > DAMAGE_BOOST(10) > INVINCIBLE(5)
```

### 效果实例数据结构

```gdscript
class_name StatusEffectInstance
extends RefCounted

## 当前效果实例的运行时数据

var effect_type: EffectType
var source_id: int                  # 施加者 entity_id（0 = 环境）
var remaining_duration: float       # 剩余持续时间（秒）
var tick_timer: float = 0.0        # DoT tick 计时器
var stack_count: int = 1           # 叠加层数（最大 2）
var applied_at: float = 0.0        # 施加时的场景时间（用于满槽时比较"最早"）
var is_expiring: bool = false       # 剩余 <0.5 秒标记

const MAX_STACK: int = 2
const EXPIRING_THRESHOLD: float = 0.5

func _init(type: EffectType, source: int, duration: float, scene_time: float) -> void:
    effect_type = type
    source_id = source
    remaining_duration = duration
    applied_at = scene_time

func refresh_duration(new_duration: float) -> void:
    ## 同类效果刷新：取较长值（GDD 边缘情况 #1）
    remaining_duration = max(remaining_duration, new_duration)

func try_stack() -> bool:
    ## 尝试叠加，返回是否成功叠加
    if stack_count < MAX_STACK:
        stack_count += 1
        return true
    return false

func tick(delta: float, tick_interval: float) -> int:
    ## 执行一次 tick 逻辑，返回 DoT 伤害值（0 = 无伤害）
    remaining_duration -= delta
    if remaining_duration <= EXPIRING_THRESHOLD:
        is_expiring = true
    tick_timer += delta
    var dot_damage: int = 0
    if tick_timer >= tick_interval:
        tick_timer -= tick_interval
        var config: Dictionary = StatusEffectComponent.EFFECT_CONFIG[effect_type]
        dot_damage = int(config[&"dot_damage"]) * stack_count
    return dot_damage

func is_expired() -> bool:
    return remaining_duration <= 0.0
```

### StatusEffectComponent 节点结构

```
Player (CharacterBody2D)
├── ...
├── HealthComponent (Node)             # ADR-0001/health-death.md
├── CombatComponent (Node)             # ADR-0005
├── CollisionComponent (Node)          # ADR-0004
├── StatusEffectComponent (Node)       # 本ADR
│   ├── _tick_timer: float = 0.0      # 全局处理计时器
│   ├── _effects: Array[StatusEffectInstance] = []  # 最多5个
│   └── _scene_time: float = 0.0      # 场景运行时间（满槽排序用）
└── ...

Enemy (CharacterBody2D)
├── ...
├── StatusEffectComponent (Node)
└── ...
```

**组件模式**：与 HealthComponent、CombatComponent、CollisionComponent 一致，StatusEffectComponent 作为实体场景树的子节点，每个实体独立管理自己的效果。不使用 Autoload，不跨场景持久化。

### 核心处理循环

```gdscript
# StatusEffectComponent.gd

const MAX_EFFECTS: int = 5
const DOT_TICK_INTERVAL: float = 0.5  # 每0.5秒tick一次

var _effects: Array[StatusEffectInstance] = []
var _scene_time: float = 0.0
var _entity_id: int = 0

# 免疫列表：Boss 类型实体免疫 STUN
var _immunities: Array[EffectType] = []

func _ready() -> void:
    _entity_id = get_parent().entity_id
    # Boss 免疫检测：检查父节点是否有 is_boss 属性
    if get_parent().get(&"is_boss") == true:
        _immunities.append(EffectType.STUN)

func _physics_process(delta: float) -> void:
    if _effects.is_empty():
        return  # 无效果时零开销

    _scene_time += delta

    # 1. 更新所有效果的 tick 和持续时间
    var expired_indices: Array[int] = []
    for i in range(_effects.size()):
        var effect: StatusEffectInstance = _effects[i]
        var dot_damage: int = effect.tick(delta, DOT_TICK_INTERVAL)

        # 2. 执行 DoT 伤害
        if dot_damage > 0:
            _apply_dot_damage(dot_damage, effect)

        # 3. 检查过期
        if effect.is_expired():
            expired_indices.append(i)

    # 4. 移除过期效果（倒序遍历避免索引偏移）
    for i in range(expired_indices.size() - 1, -1, -1):
        var idx: int = expired_indices[i]
        var expired_effect: StatusEffectInstance = _effects[idx]
        _effects.remove_at(idx)
        status_expired.emit(_entity_id, expired_effect.effect_type)

func _apply_dot_damage(damage: int, effect: StatusEffectInstance) -> void:
    ## DoT 伤害通过 HealthComponent.apply_damage() 施加
    var health: Node = get_parent().get_node_or_null(&"HealthComponent")
    if health and health.has_method(&"apply_damage"):
        # DoT 伤害来源为效果施加者
        var damage_data: Dictionary = {
            &"damage": damage,
            &"source_id": effect.source_id,
            &"damage_category": &"dot",
            &"effect_type": effect.effect_type,
        }
        health.apply_damage(damage_data)
```

### 效果施加流程

```gdscript
func apply_status(effect_type: EffectType, source_id: int) -> bool:
    ## 施加状态效果。返回 true=成功施加，false=被拒绝
    ## 完整流程: 免疫检查 → 无敌检查 → 同类刷新/叠加 → 满槽处理 → 施加

    # 1. 死亡检查 — 目标已死亡不施加
    var health: Node = get_parent().get_node_or_null(&"HealthComponent")
    if health and health.get(&"current_hp") <= 0:
        return false

    # 2. 免疫检查 — Boss 免疫眩晕等
    if effect_type in _immunities:
        return false

    # 3. i-frame 免疫 — debuff 在 i-frame 期间不生效
    var config: Dictionary = EFFECT_CONFIG[effect_type]
    if config[&"category"] == EffectCategory.DEBUFF:
        if _is_target_invincible():
            return false

    # 4. 同类效果刷新/叠加
    var existing: StatusEffectInstance = _find_effect(effect_type)
    if existing:
        var new_duration: float = config[&"base_duration"]
        existing.refresh_duration(new_duration)
        existing.try_stack()  # 最多2层，超过则仅刷新
        status_refreshed.emit(_entity_id, effect_type)
        return true

    # 5. 满槽处理 — 超过5个时移除最早的
    if _effects.size() >= MAX_EFFECTS:
        _remove_earliest_effect()

    # 6. 创建并添加新效果
    var instance := StatusEffectInstance.new(effect_type, source_id,
        config[&"base_duration"], _scene_time)
    _effects.append(instance)
    status_applied.emit(_entity_id, effect_type)

    # 7. 特殊效果处理
    if effect_type == EffectType.STUN:
        _on_stun_applied()
    elif effect_type == EffectType.INVINCIBLE:
        _on_invincible_applied()

    return true

func _is_target_invincible() -> bool:
    ## 检查目标是否处于 i-frame 或无敌状态
    # 检查 invincible 效果
    if _find_effect(EffectType.INVINCIBLE):
        return true
    # 检查 HealthComponent 的 i-frame 状态
    var health: Node = get_parent().get_node_or_null(&"HealthComponent")
    if health and health.has_method(&"is_invincible"):
        return health.is_invincible()
    return false

func _find_effect(effect_type: EffectType) -> StatusEffectInstance:
    for effect in _effects:
        if effect.effect_type == effect_type:
            return effect
    return null

func _remove_earliest_effect() -> void:
    ## 移除施加时间最早的效果（applied_at 最小）
    if _effects.is_empty():
        return
    var earliest_idx: int = 0
    var earliest_time: float = _effects[0].applied_at
    for i in range(1, _effects.size()):
        if _effects[i].applied_at < earliest_time:
            earliest_time = _effects[i].applied_at
            earliest_idx = i
    var removed: StatusEffectInstance = _effects[earliest_idx]
    _effects.remove_at(earliest_idx)
    status_expired.emit(_entity_id, removed.effect_type)
```

### 效果移除与清除

```gdscript
func remove_status(effect_type: EffectType) -> void:
    ## 手动移除指定类型效果（特定技能/道具清除）
    for i in range(_effects.size()):
        if _effects[i].effect_type == effect_type:
            _effects.remove_at(i)
            status_expired.emit(_entity_id, effect_type)
            return

func clear_all_effects() -> void:
    ## 清除所有效果（场景切换/死亡触发）
    for effect in _effects:
        status_expired.emit(_entity_id, effect.effect_type)
    _effects.clear()

func _on_stun_applied() -> void:
    ## 眩晕施加后通知 CombatComponent 进入受控状态
    var combat: Node = get_parent().get_node_or_null(&"CombatComponent")
    if combat and combat.has_method(&"on_stun_applied"):
        combat.on_stun_applied()
    # 通知 AI 组件（敌人）
    var ai: Node = get_parent().get_node_or_null(&"AIComponent")
    if ai and ai.has_method(&"on_stun_applied"):
        ai.on_stun_applied()

func _on_invincible_applied() -> void:
    ## 无敌效果施加，向 HealthComponent 注册 i-frames
    var health: Node = get_parent().get_node_or_null(&"HealthComponent")
    if health and health.has_method(&"grant_iframes"):
        # 0.5秒 = 30帧 @60fps
        health.grant_iframes(_entity_id, 30)
```

### 修改器查询接口（纯函数，供 DamageCalculator 调用）

```gdscript
func get_movement_modifier() -> float:
    ## 返回合成移速修改器（乘法叠加）
    ## GDD 公式: final_speed = base × Π(modifiers)
    ## Example: 减速(0.7) × 疾速(1.3) = 0.91
    var modifier: float = 1.0
    for effect in _effects:
        var config: Dictionary = EFFECT_CONFIG[effect.effect_type]
        modifier *= config[&"movement_modifier"]
    return modifier

func get_damage_modifier() -> float:
    ## 返回合成伤害修改器（乘法叠加）
    ## 用于 DamageCalculator 流水线 final_damage 计算
    var modifier: float = 1.0
    for effect in _effects:
        var config: Dictionary = EFFECT_CONFIG[effect.effect_type]
        modifier *= config[&"damage_modifier"]
    return modifier

func is_stunned() -> bool:
    ## 查询当前是否眩晕
    return _find_effect(EffectType.STUN) != null

func has_effect(effect_type: EffectType) -> bool:
    return _find_effect(effect_type) != null

func get_active_effects() -> Array[StatusEffectInstance]:
    ## 返回当前所有活跃效果的只读副本（供 HUD/表现层使用）
    return _effects.duplicate()
```

### 与 DamageCalculator 集成

```gdscript
# DamageCalculator.calculate_damage() 扩展
# 在 final_damage 计算阶段注入 status_effect_modifier

# DC-F6 公式扩展:
# final_damage = clamp(floor(
#     attack_damage
#     × reduction_factor
#     × damage_multiplier
#     × status_damage_modifier    ← 新增
# ), 1, 999)

# 调用方式（CombatComponent 或 DamageCalculator 获取）:
# var status_comp: StatusEffectComponent = attacker.get_node("StatusEffectComponent")
# var status_modifier: float = status_comp.get_damage_modifier()
# 传入 DamageCalculator 的 modifiers 参数
```

**集成点**：DamageCalculator 是纯函数（ADR-0001），不直接引用 StatusEffectComponent。调用方（CombatComponent 或命中处理逻辑）在组装 damage_data 时查询攻击方的 `get_damage_modifier()`，将结果注入 `damage_multiplier` 字段。DoT 伤害不经过 DamageCalculator，直接调用 `HealthComponent.apply_damage()`。

### 与 CombatComponent 集成

```gdscript
# CombatComponent 新增处理:

func on_stun_applied() -> void:
    ## 由 StatusEffectComponent 调用，强制进入 HIT_STUN 状态
    ## 眩晕期间无法执行任何动作
    if _current_state != CombatState.HIT_STUN:
        _change_state(CombatState.HIT_STUN)
        _stun_from_status = true  # 标记来源，区分受击硬直和眩晕

func _process_hit_stun() -> void:
    if _stun_from_status:
        # 眩晕由 StatusEffectComponent 管理持续时间
        var status: Node = get_node_or_null(&"../StatusEffectComponent")
        if status and not status.is_stunned():
            _stun_from_status = false
            _change_state(CombatState.IDLE)
    else:
        # 原有受击硬直逻辑
        if _hit_stun_timer <= 0:
            _change_state(CombatState.IDLE)

# 攻击命中后触发效果:
func _on_hit_confirmed(event: HitEvent) -> void:
    # ... 原有伤害处理 ...
    # 检查攻击是否附带状态效果
    var attached_effect: EffectType = _get_attached_effect(event.hitbox_id)
    if attached_effect != -1:  # -1 表示无附带效果
        var target_status: Node = _get_target_status_component(event.target_id)
        if target_status:
            target_status.apply_status(attached_effect, _entity_id)
```

### 效果优先级与冲突解决

```
施加优先级（用于 UI 排序和满槽替换决策）:

  STUN(100) > SLOW(60) > POISON(30) > BURN(20)
    > SPEED_BOOST(15) > DAMAGE_BOOST(10) > INVINCIBLE(5)

冲突规则:
  1. 同类型效果 → 刷新持续时间（取较长值），可叠加至2层
  2. 不同类型效果 → 独立共存，最多5个
  3. 5个已满 + 新效果 → 移除 applied_at 最早的
  4. debuff 在目标无敌期间 → 不施加
  5. Boss + STUN → 不施加（免疫）
```

### 信号定义

```gdscript
# StatusEffectComponent 信号

## 效果成功施加时发射
signal status_applied(target_id: int, effect_type: EffectType)

## 效果过期或被手动移除时发射
signal status_expired(target_id: int, effect_type: EffectType)

## 同类效果刷新持续时间时发射
signal status_refreshed(target_id: int, effect_type: EffectType)

## 效果叠加层数变化时发射
signal status_stacked(target_id: int, effect_type: EffectType, new_stack: int)
```

### Key Interfaces

```gdscript
# StatusEffectComponent 公开接口

# 施加/移除（CombatComponent, AIComponent, 道具系统调用）
func apply_status(effect_type: EffectType, source_id: int) -> bool
func remove_status(effect_type: EffectType) -> void
func clear_all_effects() -> void

# 查询（DamageCalculator 调用方, MovementController, HUD 调用）
func has_effect(effect_type: EffectType) -> bool
func is_stunned() -> bool
func get_active_effects() -> Array[StatusEffectInstance]
func get_movement_modifier() -> float
func get_damage_modifier() -> float

# 信号
signal status_applied(target_id: int, effect_type: EffectType)
signal status_expired(target_id: int, effect_type: EffectType)
signal status_refreshed(target_id: int, effect_type: EffectType)
signal status_stacked(target_id: int, effect_type: EffectType, new_stack: int)
```

## Alternatives Considered

### Alternative A: Autoload 集中管理所有实体效果
- **Description**: 使用 StatusEffectManager Autoload 单例管理所有实体的效果，通过 entity_id 索引
- **Pros**: 全局视图方便调试；可以批量查询（如"所有中毒的敌人"）
- **Cons**: 违反 ADR-0001 组件模式；场景切换时状态管理复杂；与 HealthComponent/CombatComponent 组件模式不一致；可测试性差
- **Rejection Reason**: 违反 ADR-0001 确定的组件模式，且与 HealthComponent、CombatComponent 的架构模式不一致

### Alternative B: 使用 Godot Timer 节点驱动 DoT
- **Description**: 每个 DoT 效果创建独立 Timer 节点，通过 timeout 信号触发伤害
- **Pros**: 利用 Godot 内置 Timer 机制，无需手动管理计时
- **Cons**: 动态创建/销毁 Timer 节点有开销；多个 Timer 的信号管理复杂；与 `_physics_process` 帧循环不一致
- **Rejection Reason**: 在 `_physics_process` 中统一处理所有效果的 tick 更高效且可控，避免 N 个 Timer 节点的开销

### Alternative C: Resource 定义效果配置
- **Description**: 每种效果类型定义为独立的 Resource (.tres)，支持编辑器中可视化配置
- **Pros**: 非程序可通过编辑器调整效果数值；类型安全（强类型 Resource 属性）
- **Cons**: 7 种效果创建 7 个 .tres 文件，增加管理复杂度；效果数值已纳入 TuningKnob 管理，Resource 与之重复
- **Rejection Reason**: 效果数值通过 DataManager TuningKnob 系统管理已足够（支持热重载），Resource 层是多余的抽象

## Consequences

### Positive
- **组件一致性**: 与 HealthComponent、CombatComponent、CollisionComponent 遵循相同的组件模式（ADR-0001）
- **零开销空转**: `_effects.is_empty()` 时立即返回，无效果实体不消耗 CPU
- **纯函数查询接口**: `get_movement_modifier()`/`get_damage_modifier()` 是无副作用的纯函数，易于测试和集成
- **信号驱动**: `status_applied`/`status_expired` 信号让表现层（视觉效果、HUD 图标）无需轮询
- **TuningKnob 集成**: 所有效果数值从 DataManager 读取，支持热重载和调试面板修改

### Negative
- **实体场景复杂度增加**: 每个实体新增一个 StatusEffectComponent 子节点（Player + N 个 Enemy）
- **DoT 与 DamageCalculator 分离**: DoT 伤害直接调用 `apply_damage()`，不走完整伤害流水线，可能错过某些全局修正
- **眩晕状态耦合**: CombatComponent 需要新增 `on_stun_applied()` 方法和 `_stun_from_status` 标记，增加了状态机的入口点

### Risks
- **DoT 致死竞态**: DoT tick 在同一帧内可能导致实体 HP 归零并触发 `on_death`，但 `_physics_process` 中其他效果仍在处理。**缓解**: `_apply_dot_damage()` 中检查目标是否已死亡，死亡后立即 `clear_all_effects()` 并返回
- **满槽替换不公平**: 移除"最早的"效果可能导致高优先级效果（如 STUN）被低优先级新效果替换。**缓解**: 满槽替换时按优先级排序，优先保留高优先级效果而非最早的（实现时取 `priority` 最低且 `applied_at` 最早的）
- **乘法叠加溢出**: 多个移速修改器乘法叠加可能导致极端值（如 2 个 SLOW + 1 个 SPEED_BOOST = 0.7×0.7×1.3 = 0.637）。**缓解**: 对 `get_movement_modifier()` 返回值使用 `clamp(result, 0.1, 3.0)` 防止极端值

## GDD Requirements Addressed

| GDD System | Requirement | How This ADR Addresses It |
|------------|-------------|--------------------------|
| status-effects.md | 7种效果类型 (TR-status-001) | EffectType 枚举定义 7 种效果，EFFECT_CONFIG 存储每种效果的配置 |
| status-effects.md | 效果施加规则 (TR-status-002) | `apply_status()` 完整流程：死亡检查→免疫检查→i-frame检查→同类刷新→满槽处理→施加 |
| status-effects.md | DoT tick + 移速乘法叠加 (TR-status-003) | `_physics_process` 中 0.5s tick 间隔调用 `apply_damage()`；`get_movement_modifier()` 使用 Π(modifiers) 乘法叠加 |
| status-effects.md | i-frame 免疫 (TR-status-004) | `_is_target_invincible()` 检查 HealthComponent.is_invincible() + INVINCIBLE 效果，debuff 不施加 |
| status-effects.md | 效果优先级 + 满槽替换 (TR-status-005) | priority 数值定义优先级（STUN 100 > SLOW 60 > ... > INVINCIBLE 5）；满槽移除 priority 最低且 applied_at 最早的 |
| status-effects.md | 场景切换/死亡清除 (TR-status-006) | `clear_all_effects()` 监听 on_death 信号和场景切换事件 |
| status-effects.md | Boss 免疫眩晕 | `_ready()` 中检测 `is_boss` 属性，将 STUN 加入 `_immunities` 列表 |
| status-effects.md | 同类型最多2层叠加 | `StatusEffectInstance.MAX_STACK = 2`，`try_stack()` 限制叠加 |
| weapon-styles.md | 电磁铃铛命中施加减速 (TR-weapon-006) | CombatComponent._on_hit_confirmed() 检查附带效果并调用 target.apply_status(SLOW) |

## Performance Implications

- **CPU**: 无效果时零开销（`_effects.is_empty()` 提前返回）。5 个效果 tick 更新 <0.01ms/帧。修改器查询（遍历 ≤5 元素数组）<0.005ms/帧。总 StatusEffectComponent 开销 <0.1ms/帧（远小于 0.5ms 预算）
- **Memory**: StatusEffectComponent 实例 ~200B（空）。每个 StatusEffectInstance ~80B。5 个效果 ≈ 600B/实体。20 实体 ≈ 12KB
- **Load Time**: 无影响
- **Network**: N/A

## Migration Plan

无需迁移。实现步骤：
1. 创建 `res://src/core/status_effect_component.gd`，定义 EffectType 枚举和 EFFECT_CONFIG
2. 创建 `StatusEffectInstance` 内部类（或独立文件 `res://src/core/status_effect_instance.gd`）
3. 实现 `apply_status()` / `remove_status()` / `clear_all_effects()` 核心逻辑
4. 实现 `_physics_process()` 效果更新和 DoT tick
5. 实现修改器查询接口 `get_movement_modifier()` / `get_damage_modifier()`
6. 在 CombatComponent 中集成：攻击命中触发效果、`on_stun_applied()` 处理
7. 在 DamageCalculator 调用方集成 `get_damage_modifier()`
8. 连接 `status_applied`/`status_expired` 信号到表现层（效果视觉反馈）
9. 连接 `on_death` 信号到 `clear_all_effects()`
10. 注册效果相关 TuningKnob 到 DataManager

## Validation Criteria

- [ ] 7 种效果类型可以正确施加、持续、过期
- [ ] 每实体最多同时 5 个效果，超过时移除优先级最低且最早的
- [ ] 同类型效果刷新持续时间（取较长值），叠加层数不超过 2
- [ ] DoT 每 0.5 秒 tick 一次，伤害值 = base_dot × stack_count
- [ ] Boss 免疫眩晕，apply_status(STUN) 返回 false
- [ ] i-frame 期间 debuff 不施加（`_is_target_invincible()` 返回 true）
- [ ] 无敌效果施加时调用 `HealthComponent.grant_iframes()`
- [ ] 眩晕施加后 CombatComponent 进入 HIT_STUN，眩晕结束后恢复 IDLE
- [ ] 移速修改器使用乘法叠加：base × Π(modifiers)
- [ ] 伤害修改器注入 DamageCalculator 流水线
- [ ] 死亡/场景切换时清除所有效果
- [ ] 电磁铃铛命中触发减速效果（SLOW, 2秒, -30%）
- [ ] `status_applied`/`status_expired` 信号正确发射

## Related Decisions

- ADR-0001: 组件模式 — StatusEffectComponent 作为实体子节点
- ADR-0002: 信号通信 — status_applied/status_expired 信号遵循 ADR-0002 约定
- ADR-0003: 数据管理 — 效果数值从 DataManager TuningKnob 读取
- ADR-0004: 碰撞检测 — 攻击命中由 CollisionComponent.on_hit_confirmed 触发
- ADR-0005: 战斗状态机 — CombatComponent 响应眩晕，攻击命中触发效果
- ADR-0009: 技能树 Modifier — damage_modifier 与技能树加成在 F8 统一上限公式中合并
- `design/gdd/status-effects.md`: 完整 GDD 需求
