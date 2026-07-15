# ADR-0019: HealthComponent 深度架构

## Summary

定义 HealthComponent 的内部深度架构：HP 数据结构（current_hp/max_hp/shield）、apply_damage 完整流水线（含 4 层防护）、护盾优先吸收机制、无敌帧管理（max-take 不叠加）、专注模式（迟滞缓冲 + 战斗状态门控）、HP 里程碑事件（4 阈值一次性触发）、3 状态死亡状态机（ALIVE→DYING→DEAD）、死亡元数据、max_hp 聚合公式（HD-F0）、受伤音效音调偏移（HD-F4）、ISerializable 存档集成，以及与 CombatComponent/DamageCalculator/AI 框架的系统集成。覆盖 TR-health-001~015 全部 15 个技术需求。

## Status

Proposed

## Date

2026-06-22

## Engine Compatibility

| Field | Value |
|-------|-------|
| **Engine** | Godot 4.7 |
| **Domain** | Core / GDScript |
| **Knowledge Risk** | LOW — Node component pattern, signal API, and state machine pattern all stable since 4.0 |
| **References Consulted** | `docs/engine-reference/godot/VERSION.md`, `docs/engine-reference/godot/breaking-changes.md` |
| **Post-Cutoff APIs Used** | None — `@abstract` annotation (4.5+) considered but not required for this ADR's patterns |
| **Verification Required** | `ISerializable` 接口在 Godot 4.6+ required types 下 `deserialize(data: Dictionary, version: int)` 是否正常工作（参考 ADR-0001 已确认的 ISerializable 接口） |

## ADR Dependencies

| Field | Value |
|-------|-------|
| **Depends On** | ADR-0001 (Autoload架构 — HealthComponent 作为实体子节点组件), ADR-0002 (事件/信号通信模式 — 信号命名约定 + payload 数据类 + 发射顺序), ADR-0005 (战斗状态机 — CombatComponent 专注模式集成 + battle_stats 查询) |
| **Enables** | ADR-0006 (AI行为 — AI 查询 get_hp_percentage + 监听 on_focus_mode_changed), 死亡重生系统实现 (on_death 信号消费方) |
| **Blocks** | HealthComponent 实现, HUD HP条实现, AI框架低HP行为, Boss阶段转换 |
| **Ordering Note** | Core 层 ADR，在战斗状态机和信号规范之后，AI行为之前 |

## Context

### Problem Statement

ADR-0001 定义了 HealthComponent 作为 Player/Enemy 实体的子节点组件（非 Autoload），ADR-0005 定义了 CombatComponent 监听 `on_focus_mode_changed` 信号。GDD `health-death.md` 定义了完整的 HP 系统需求（10 条核心规则、5 个公式、31 条验收标准、31 个 AC）。TR 注册表有 15 个 TR-health 条目（TR-health-001~015）。但 HealthComponent 的内部架构——数据结构、apply_damage 完整流水线、护盾优先级、i-frame 管理、专注模式迟滞逻辑、里程碑事件机制、死亡状态机、存档集成——尚未详细定义。LP 审查将此标为 HIGH concern。

### Constraints

- **ADR-0001**: HealthComponent 挂载在 Player/Enemy 场景节点下，非 Autoload；每个实体独立实例
- **ADR-0002**: 信号使用 `class_name` payload 数据类；apply_damage 中 5 个信号有严格发射顺序
- **ADR-0005**: CombatComponent 通过 `health.on_focus_mode_changed.connect()` 监听专注模式变化；`get_battle_stats()` 供死亡元数据使用
- **帧级精度**: i-frame 计数、专注模式判定在 `_physics_process` 中处理
- **Godot 4.6+ Required Types**: 所有公开接口必须强类型，nullable 参数不再隐式允许
- **可测试性**: GdUnit4 单元测试必须能独立实例化 HealthComponent，不依赖完整场景树（coding-standards.md）
- **数据驱动**: 所有可调参数（阈值、帧数等）通过 DataManager.get_tuning() 获取，不硬编码

### Requirements

- 必须实现 HP 状态管理 (TR-health-001)：current_hp / max_hp / shield（休眠）
- 必须实现 apply_damage 完整流水线 (TR-health-002)：4 层防护（state guard / is_invincible / 零伤害 / 护盾吸收）
- 必须实现护盾优先吸收 (TR-health-003)：shield_absorbed = min(shield, incoming)
- 必须实现 Boss 阶段跨跳 (TR-health-004)：while 循环触发所有经过的阈值
- 必须实现 HP 里程碑 (TR-health-005)：4 阈值一次性触发，复活后重置
- 必须实现专注模式 (TR-health-006)：25% 激活 / 28% 退出（3% 迟滞），战斗状态门控
- 必须实现专注模式激活信号 (TR-health-007)：猫眼金色闪光 + 猫科提示音（一次性）
- 必须实现专注模式感知变化接口 (TR-health-008)：windup_extension / 预兆放大 / 粒子降低 / 低频混响
- 必须实现 i-frame 管理 (TR-health-009)：grant_iframes max-take 不叠加
- 必须实现死亡元数据 (TR-health-010)：last_hit / battle_stats / context
- 必须保证信号发射顺序 (TR-health-011)：on_hp_changed → on_hp_milestone → on_boss_phase_change → on_focus_mode_changed → on_death
- 必须实现 max_hp 聚合 (TR-health-012)：HD-F0 公式
- 必须实现 revive 重置专注模式 (TR-health-013)
- 必须提供受伤音效音调偏移查询 (TR-health-014)：HD-F4 公式
- 必须提供探索/叙事接口钩子 (TR-health-015)：on_hp_milestone + on_death_in_zone

## Decision

### 1. HP 数据结构

```gdscript
# HealthComponent.gd — 核心数据

## 实体HP状态机（3状态）
enum EntityState {
    ALIVE,    # 正常接收伤害，HP可变
    DYING,    # 播放死亡动画，不接收伤害
    DEAD      # 从场景移除或保留尸体
}

# --- HP 核心数据 ---
var _current_hp: int = 100
var _max_hp: int = 100
var _shield: int = 0           # 休眠特性 — max_shield 默认 0，护盾机制不激活
var _max_shield: int = 0       # 直到上游系统（状态效果）提供护盾来源

# --- 状态 ---
var _state: EntityState = EntityState.ALIVE
var _is_player: bool = false   # 由 _ready() 根据父节点类型设置
var _focus_mode_active: bool = false

# --- 里程碑追踪 ---
var _triggered_milestones: Array[float] = []  # 已触发的阈值（0.75/0.50/0.25/0.01）

# --- i-frame 管理 ---
var _i_frame_remaining: int = 0  # 剩余无敌帧数

# --- 死亡元数据追踪 ---
var _battle_start_time: float = 0.0
var _total_damage_received: int = 0
var _total_damage_dealt: int = 0    # 由 CombatComponent 通过 observe_damage_dealt() 更新
var _current_zone_id: StringName = &""
```

**设计决策**：
- 使用 `int` 而非 `float` 表示 HP 值——GDD 明确定义 HP 为整数（规则1）
- `_shield` 休眠设计——接口和公式保留，但 `max_shield` 默认 0，护盾机制不激活直到上游提供来源（GDD 规则1 注释）
- `_triggered_milestones` 使用 `Array[float]` 而非 `Set`（GDScript 无 Set 类型，使用 `has()` 查询，4 个元素性能无影响）
- `_is_player` 在 `_ready()` 中通过 `get_parent().is_in_group("player")` 判断，避免每帧类型检查

### 2. max_hp 聚合公式（HD-F0）

```gdscript
## 重新计算 max_hp（HD-F0）
## 执行时机：_ready() / 技能解锁 / 护符装备变更 / 存档加载
func recalculate_max_hp() -> void:
    var base_hp: int = _get_base_hp()  # 从 DataManager 读取 player_stats/enemy_stats
    var skill_hp_flat: int = _get_skill_hp_bonus()  # 查询技能树 F4 被动节点累计
    var charm_hp_flat: int = _get_charm_hp_bonus()  # 查询护符系统 charm_life
    
    var new_max_hp: int = base_hp + skill_hp_flat + charm_hp_flat
    # 数据验证防护（AC-19）
    if new_max_hp <= 0:
        new_max_hp = 100  # 默认值
        push_warning("HealthComponent: max_hp=%d <= 0, using default 100" % new_max_hp)
    
    # 如果 max_hp 增大，current_hp 等比例扩展（保持 HP 百分比不变）
    if _max_hp > 0 and new_max_hp != _max_hp:
        var hp_ratio: float = float(_current_hp) / float(_max_hp)
        _max_hp = new_max_hp
        _current_hp = clampi(int(round(hp_ratio * _max_hp)), 0, _max_hp)
    else:
        _max_hp = new_max_hp
    
    # shield 上限同步
    _max_shield = _get_max_shield_from_effects()  # 休眠：当前返回 0
    _shield = clampi(_shield, 0, _max_shield)
```

**TR 映射**：TR-health-012

### 3. apply_damage 完整流水线

```gdscript
## 伤害应用完整流水线
## 调用方：DamageCalculator 输出 final_damage 后，由碰撞系统转发调用
## 信号发射顺序（TR-health-011）：
##   on_hp_changed → on_hp_milestone → on_boss_phase_change → on_focus_mode_changed → on_death
func apply_damage(final_damage: int, metadata: Dictionary) -> void:
    # === 防护层 1: 状态守卫 ===
    if _state != EntityState.ALIVE:
        return  # DYING/DEAD 不接收伤害（AC-4, AC-18）
    
    # === 防护层 2: i-frame 免疫 ===
    if _i_frame_remaining > 0:
        return  # 无敌帧期间忽略伤害，不触发 on_hp_changed（HP未变）(AC-10)
    
    # === 防护层 3: 零/负伤害防护 ===
    if final_damage <= 0:
        return  # 零伤害不处理，不触发任何信号（AC-27）
    
    # === 阶段 4: 护盾吸收 ===
    var effective_damage: int = final_damage
    if _shield > 0:
        var shield_absorbed: int = mini(_shield, final_damage)  # HD-F2
        _shield -= shield_absorbed
        effective_damage = final_damage - shield_absorbed
    
    # === 阶段 5: HP 扣减 ===
    var old_hp: int = _current_hp
    _current_hp = maxi(0, _current_hp - effective_damage)
    _total_damage_received += (old_hp - _current_hp)
    
    # === 信号序列开始（严格顺序，TR-health-011） ===
    
    # ① on_hp_changed
    on_hp_changed.emit(_current_hp, _max_hp)
    
    # ② on_hp_milestone — 检查 4 个阈值
    var hp_pct: float = get_hp_percentage()
    for threshold: float in [0.75, 0.50, 0.25, 0.01]:
        if hp_pct <= threshold and threshold not in _triggered_milestones:
            _triggered_milestones.append(threshold)
            on_hp_milestone.emit(threshold)
    
    # ③ on_boss_phase_change — 仅 Boss 实体
    if _phase_thresholds.size() > 0:
        _check_boss_phase_transition(hp_pct)
    
    # ④ on_focus_mode_changed — 仅玩家实体
    if _is_player:
        _check_focus_mode_transition(hp_pct)
    
    # ⑤ on_death — 终结事件，最后发射
    if _current_hp == 0:
        _state = EntityState.DYING
        var death_meta: Dictionary = _build_death_metadata(metadata)
        on_death.emit(death_meta)
        # 区域死亡信号（TR-health-015）
        on_death_in_zone.emit(_current_zone_id)
```

**关键设计决策**：

1. **4 层防护顺序**：state → i-frame → zero-damage → shield → HP。先检查轻量条件（整数比较），再处理复杂逻辑（护盾计算），避免无效计算
2. **信号严格顺序**：按 GDD AC-22 定义的顺序发射——on_hp_changed → on_hp_milestone → on_boss_phase_change → on_focus_mode_changed → on_death。这保证了下游监听器接收到信号时，前置状态已更新完毕
3. **护盾优先**：shield_absorbed 在 HP 扣减之前计算（GDD HD-F2），护盾清零后剩余伤害才扣 HP
4. **metadata 参数**：来自 DamageCalculator 的 DamageResult.metadata（is_crit/crit_type/combo_stage 等），透传给 on_death

**TR 映射**：TR-health-002, TR-health-003, TR-health-011

### 4. 护盾系统

```gdscript
# 护盾当前为休眠特性（max_shield 默认 0）
# 接口完整保留，待上游系统（状态效果 GDD）提供护盾来源后激活

func get_shield_percentage() -> float:
    if _max_shield <= 0:
        return 0.0
    return float(_shield) / float(_max_shield)

# 外部设置护盾值（由状态效果系统调用）
func set_shield(value: int) -> void:
    _shield = clampi(value, 0, _max_shield)
```

**设计决策**：护盾系统接口完整但休眠。`max_shield=0` 时护盾逻辑不激活（`_shield > 0` 永远为 false），`apply_damage` 中的护盾分支不会被执行，零开销。上游系统（状态效果）通过 `set_shield()` 和修改 `_max_shield` 来激活。

**TR 映射**：TR-health-003

### 5. 无敌帧（i-frames）管理

```gdscript
## 授予无敌帧（max-take，不叠加）
## 调用方：猫科战斗系统（闪避/弹反）、死亡重生系统（复活）、状态效果系统（invincible）
func grant_iframes(frames: int) -> void:
    _i_frame_remaining = maxi(_i_frame_remaining, frames)  # 取最长，不叠加（AC-24）

## _physics_process 中递减 i-frame 计数
func _physics_process(delta: float) -> void:
    if _i_frame_remaining > 0:
        _i_frame_remaining -= 1
```

**i-frame 来源与帧数**（由上游系统提供）：

| 来源 | 帧数 | 管理系统 |
|------|------|---------|
| 闪避翻滚 | 8 帧（帧 3-10） | CombatComponent 设置 |
| PERFECT 弹反 | 6 帧 | CombatComponent 设置 |
| 复活 | 120 帧（2秒） | 死亡重生系统设置 |
| invincible 状态效果 | 效果持续期间 | StatusEffectComponent 设置 |

**关键约束**：
- **不叠加**：多个来源同帧授予时取 `max(current, new)`（AC-24）
- **DoT 免疫**：i-frame 期间 DoT tick 也被免疫（AC-25）——因为 DoT 也走 `apply_damage` 路径
- **统计排除**：i-frame 期间受击不更新 `_total_damage_received`（AC-10：不更新伤害统计）

**TR 映射**：TR-health-009

### 6. 专注模式（Focus Mode）

```gdscript
## 专注模式检查与转换
## 在 apply_damage 信号序列的 ④ 阶段调用
func _check_focus_mode_transition(hp_pct: float) -> void:
    var active_enemies: int = _get_active_enemy_count()  # 查询 AI 框架
    
    if not _focus_mode_active:
        # 激活条件：HP ≤ 25% 且处于战斗状态
        if active_enemies > 0 and hp_pct <= _low_hp_threshold:
            _focus_mode_active = true
            on_focus_mode_changed.emit(true)
    else:
        # 退出条件 A：HP > 28%（迟滞缓冲）
        if hp_pct > _low_hp_threshold + _focus_hysteresis:
            _focus_mode_active = false
            on_focus_mode_changed.emit(false)
        # 退出条件 B：脱战（无活跃敌人）
        elif active_enemies == 0:
            _focus_mode_active = false
            on_focus_mode_changed.emit(false)
```

**迟滞缓冲设计**：

```
激活阈值:  HP ≤ 25%  →  focus_mode = true
退出阈值:  HP > 28%  →  focus_mode = false  (25% + 3% hysteresis)
缓冲带:    25% < HP ≤ 28%  →  保持当前状态不变
```

- `_low_hp_threshold`：默认 0.25，从 TuningKnobRegistry 读取（安全范围 0.1-0.4）
- `_focus_hysteresis`：默认 0.03，从 TuningKnobRegistry 读取（安全范围 0.01-0.05）
- **严格大于**：退出条件是 `hp_pct > threshold + hysteresis`（>28%），不是 `>=`（AC-14b：恰好 28% 不退出）

**战斗状态门控**：
- 激活需要 `active_enemies_count > 0`（AI 框架提供 `get_active_enemy_count()` 查询，返回 CHASE/ATTACK 状态的敌人数量）
- 脱战自动退出——防止"安全区低血白嫖专注"退化策略（AC-30）

**查询接口**：
```gdscript
func is_focus_mode_active() -> bool:
    return _focus_mode_active
```

**TR 映射**：TR-health-006, TR-health-007, TR-health-008

### 7. HP 里程碑事件

```gdscript
# 在 apply_damage 信号序列的 ② 阶段处理（见上方流水线）
# 4 个阈值: 0.75(轻伤) / 0.50(中伤) / 0.25(重伤) / 0.01(濒死)
# 每阈值每生命周期仅触发一次
# revive() 调用 _triggered_milestones.clear() 重置（AC-20）

signal on_hp_milestone(threshold: float)
```

**设计决策**：
- 阈值检查在 `on_hp_changed` 之后、`on_boss_phase_change` 之前发射
- 使用 `Array[float].has()` 查询已触发阈值——4 个元素的线性查找远快于 HashSet 开销
- 里程碑信号供探索奖励系统（"首次低血量存活"成就）和叙事系统监听

**TR 映射**：TR-health-005, TR-health-015

### 8. Boss 阶段转换

```gdscript
var _phase_thresholds: Array[float] = []  # Boss 专用，从 BossConfig 加载
var _next_phase: int = 0

## Boss 阶段跨跳检测（while 循环，TR-health-004）
func _check_boss_phase_transition(hp_pct: float) -> void:
    if _phase_thresholds.is_empty() or _next_phase >= _phase_thresholds.size():
        return  # 无更多阶段，安全返回
    
    while _next_phase < _phase_thresholds.size() and hp_pct <= _phase_thresholds[_next_phase]:
        on_boss_phase_change.emit(_next_phase)
        _next_phase += 1
```

**设计决策**：
- **while 循环**而非 if 语句——确保跨跳场景（如从 70% 直接到 20%）触发所有经过的阈值（AC-6）
- 阶段转换在 `on_hp_milestone` 之后发射——先通知通用里程碑监听器，再触发 Boss 专有逻辑
- 致死伤害也触发阶段转换——Boss 从 33% HP 被击杀时，先发射 `on_boss_phase_change` 再发射 `on_death`（AC-26）
- `_phase_thresholds` 非空时才执行——普通实体无阶段概念，零开销

**TR 映射**：TR-health-004

### 9. 死亡检测与元数据

```gdscript
## 构建死亡元数据（GDD 规则9）
func _build_death_metadata(last_hit_metadata: Dictionary) -> Dictionary:
    var battle_stats: Dictionary = {}
    # 从 CombatComponent 获取战斗统计（ADR-0005 定义）
    var combat: Node = get_parent().get_node_or_null(&"CombatComponent")
    if combat and combat.has_method(&"get_battle_stats"):
        battle_stats = combat.get_battle_stats()
    
    return {
        "last_hit": {
            "damage": last_hit_metadata.get("final_damage", 0),
            "type": last_hit_metadata.get("damage_category", &"normal"),
            "source": last_hit_metadata.get("source_entity", &""),
            "is_crit": last_hit_metadata.get("is_crit", false),
        },
        "battle_stats": {
            "duration_sec": (Time.get_ticks_msec() / 1000.0) - _battle_start_time,
            "damage_received": _total_damage_received,
            "damage_dealt": _total_damage_dealt,
            "dodge_success_rate": battle_stats.get("dodge_success_rate", 0.0),
            "parry_success_rate": battle_stats.get("parry_success_rate", 0.0),
            "hits_received_by_pattern": battle_stats.get("hits_received_by_pattern", {}),
        },
        "context": {
            "zone_id": _current_zone_id,
            "enemy_type": last_hit_metadata.get("source_type", &""),
            "boss_phase": _next_phase if _phase_thresholds.size() > 0 else -1,
        }
    }
```

**信号定义**：
```gdscript
signal on_death(metadata: Dictionary)
signal on_death_in_zone(zone_id: StringName)
```

**死亡状态机**：

```
ALIVE ──[HP=0]──► DYING ──[动画完成]──► DEAD
  ▲                                       │
  └───────── revive() ◄──────────────────┘
```

- **ALIVE → DYING**：`_current_hp == 0` 时自动转换，发射 `on_death`
- **DYING → DEAD**：由死亡重生系统监听 `on_death` 后管理动画完成时转换
- **DEAD → ALIVE**：`revive()` 调用，由死亡重生系统触发

**TR 映射**：TR-health-010, TR-health-015

### 10. 复活流程

```gdscript
## 复活 — 由死亡重生系统调用
func revive() -> void:
    var revive_hp_pct: float = DataManager.get_tuning(&"revive_hp_percentage", 0.5)
    _current_hp = maxi(1, int(floor(_max_hp * revive_hp_pct)))  # AC-17 下限保护
    _state = EntityState.ALIVE
    
    # 重置里程碑（AC-20）
    _triggered_milestones.clear()
    
    # 重置专注模式（AC-28, TR-health-013）
    if _focus_mode_active:
        _focus_mode_active = false
        on_focus_mode_changed.emit(false)
    
    # 重置 Boss 阶段（Boss 复活场景）
    _next_phase = 0
    
    # 重置战斗统计
    _total_damage_received = 0
    _total_damage_dealt = 0
    _battle_start_time = Time.get_ticks_msec() / 1000.0
    
    # 重置护盾
    _shield = _max_shield
```

**TR 映射**：TR-health-013

### 11. HP 查询接口

```gdscript
## HP 百分比（HD-F1）
func get_hp_percentage() -> float:
    return float(_current_hp) / float(maxi(1, _max_hp))  # max(1, ...) 防除零

func is_alive() -> bool:
    return _state == EntityState.ALIVE

func is_dead() -> bool:
    return _state == EntityState.DEAD

func get_current_hp() -> int:
    return _current_hp

func get_max_hp() -> int:
    return _max_hp

func get_shield_percentage() -> float:
    if _max_shield <= 0:
        return 0.0
    return float(_shield) / float(_max_shield)

## 受伤音效音调偏移（HD-F4, TR-health-014）
func get_injury_pitch_offset() -> float:
    var max_semitones: int = DataManager.get_tuning(&"injury_pitch_max_semitones", 10)
    return (1.0 - get_hp_percentage()) * float(max_semitones)
```

**TR 映射**：TR-health-014

### 12. 治疗接口

```gdscript
## 治疗 — 由道具/存档点调用
func heal(amount: int) -> void:
    if _state != EntityState.ALIVE:
        return
    if amount <= 0:
        return
    _current_hp = mini(_max_hp, _current_hp + amount)  # clamp 到 max_hp（AC-11）
    on_hp_changed.emit(_current_hp, _max_hp)

## 存档点完全回复（GDD 规则6）
func restore_to_checkpoint() -> void:
    _current_hp = _max_hp
    _shield = _max_shield
    on_hp_changed.emit(_current_hp, _max_hp)
```

### 13. 完整信号清单

```gdscript
# --- HealthComponent 信号定义 ---
# 遵循 ADR-0002 信号命名约定

## HP 变更（每次 apply_damage/heal 后发射）
signal on_hp_changed(current_hp: int, max_hp: int)

## HP 里程碑（4 阈值一次性触发）
signal on_hp_milestone(threshold: float)

## 专注模式变化
signal on_focus_mode_changed(active: bool)

## Boss 阶段转换（仅 Boss 实体）
signal on_boss_phase_change(new_phase: int)

## 死亡（终结事件）
signal on_death(metadata: Dictionary)

## 区域死亡（叙事/探索钩子）
signal on_death_in_zone(zone_id: StringName)
```

### 14. 存档集成（ISerializable）

```gdscript
# HealthComponent 实现 ISerializable 接口（ADR-0001, ADR-0008）
# SaveSystem 在 save_game/load_game 时调用

func serialize() -> Dictionary:
    return {
        "version": 1,
        "current_hp": _current_hp,
        "max_hp": _max_hp,
        "shield": _shield,
        "state": _state,  # EntityState 枚举值
        "focus_mode_active": _focus_mode_active,
        "triggered_milestones": _triggered_milestones.duplicate(),
        "next_phase": _next_phase,
    }

func deserialize(data: Dictionary, version: int) -> void:
    _current_hp = data.get("current_hp", _max_hp)
    _max_hp = data.get("max_hp", 100)
    _shield = data.get("shield", 0)
    _state = data.get("state", EntityState.ALIVE) as EntityState
    _focus_mode_active = data.get("focus_mode_active", false)
    _triggered_milestones = data.get("triggered_milestones", []) as Array[float]
    _next_phase = data.get("next_phase", 0)
    
    # 存档加载后重新计算 max_hp（确保技能/护符变更同步）
    recalculate_max_hp()
```

**设计决策**：
- `_i_frame_remaining` 不存档——复活 i-frame 由死亡重生系统在 revive 后重新授予
- `_battle_start_time` 不存档——战斗统计在存档/读档间不连续
- `_total_damage_received/dealt` 不存档——战斗统计仅用于当次死亡的元数据
- 存档后调用 `recalculate_max_hp()`——确保技能解锁/护符变更后 max_hp 同步

### 15. 与 CombatComponent 集成

```gdscript
# CombatComponent 侧（ADR-0005 已定义）：
#   health.on_focus_mode_changed.connect(_handle_focus_mode_changed)
#   combat.get_battle_stats() 供死亡元数据查询

# HealthComponent 侧新增观察接口（用于 _total_damage_dealt 追踪）：
func observe_damage_dealt(amount: int) -> void:
    _total_damage_dealt += amount

# 战斗开始通知（由 CombatComponent 在首次攻击/受击时调用）
func notify_combat_started() -> void:
    if _battle_start_time == 0.0:
        _battle_start_time = Time.get_ticks_msec() / 1000.0
```

**active_enemies_count 查询路径**：
```
HealthComponent._check_focus_mode_transition()
  → AI框架.get_active_enemy_count()  # AI框架提供，返回 CHASE/ATTACK 状态敌人数量
```

HealthComponent 不直接查询 AIComponent——通过 AI 框架的集中查询接口，符合 ADR-0001 的通信规则（Component → Component 跨实体通过信号/查询接口）。

### 16. 与 DamageCalculator 集成

```
调用链：
  CollisionComponent.on_hit_confirmed(hit_data)
    → DamageCalculator.calculate_damage(...) → DamageResult { final_damage, metadata }
    → target_health.apply_damage(result.final_damage, result.metadata)
```

HealthComponent 不直接调用 DamageCalculator——由碰撞系统作为中间人，接收 DamageResult 后转发给目标的 HealthComponent。这保持了 ADR-0001 的分层原则（Core 组件之间通过信号/直接调用交互，不越层）。

### 17. 场景生命周期管理

```gdscript
func _ready() -> void:
    # 判断是否为玩家实体
    _is_player = get_parent().is_in_group(&"player")
    
    # 初始化 max_hp
    recalculate_max_hp()
    _current_hp = _max_hp  # 初始满血
    
    # 初始化战斗统计
    _battle_start_time = Time.get_ticks_msec() / 1000.0
    
    # 从 DataManager 读取调优参数
    _low_hp_threshold = DataManager.get_tuning(&"low_hp_warning_threshold", 0.25)
    _focus_hysteresis = DataManager.get_tuning(&"focus_hysteresis", 0.03)
    
    # Boss 实体从配置加载阶段阈值
    if get_parent().is_in_group(&"boss"):
        _load_boss_config()

func _physics_process(delta: float) -> void:
    # i-frame 递减
    if _i_frame_remaining > 0:
        _i_frame_remaining -= 1
```

## Alternatives Considered

### Alternative A: HealthSystem 作为 Autoload（集中式管理）
- **Description**: 所有实体的 HP 由一个全局 HealthSystem Autoload 管理，通过 entity_id 查表
- **Pros**: 统一入口，方便全局查询（如"所有敌人 HP 总和"）
- **Cons**: 无法利用 Godot 场景树的生命周期管理（`_ready`/`_exit_tree` 自动清理）；每个实体需要手动注册/注销；可测试性差（测试需 mock 整个 Autoload）；违反 ADR-0001 的组件化决策
- **Rejection Reason**: ADR-0001 已明确 HealthComponent 为实体子节点组件。多实体（Player + N Enemies）场景下组件模式更自然

### Alternative B: 使用 Godot Resource 存储 HP 数据
- **Description**: HP 数据封装为 `HealthData extends Resource`，通过 `@export` 在编辑器中配置
- **Pros**: 编辑器可视化配置；Resource 天然支持序列化
- **Cons**: HP 是运行时频繁变化的状态，不适合 Resource（Resource 适合静态配置）；`@export` 暴露内部状态给编辑器，增加误操作风险
- **Rejection Reason**: HP 是动态状态而非静态配置，直接用变量更高效

### Alternative C: 独立专注模式组件（FocusModeComponent）
- **Description**: 将专注模式逻辑抽离为独立组件，HealthComponent 仅发射 HP 变更信号
- **Pros**: 更好的关注点分离；专注模式可独立测试
- **Cons**: 增加组件间通信开销（多一层信号转发）；专注模式强依赖 HP 百分比，拆开后需要频繁查询 HP
- **Rejection Reason**: 专注模式是 HP 变化的直接下游逻辑（在 apply_damage 流水线中），内聚在 HealthComponent 中更自然。如未来专注模式复杂度增加（如多种专注等级），可再抽离

## Consequences

### Positive
- **完整防护**：4 层 apply_damage 防护确保不可能出现重复死亡、负 HP、i-frame 穿透等 bug
- **信号顺序保证**：严格定义 5 信号发射顺序，下游监听器可信赖前置状态已更新
- **迟滞缓冲**：3% 迟滞带防止 25% 阈值附近专注模式反复切换（AC-14b）
- **护盾休眠设计**：接口完整但零开销，不阻塞其他系统开发
- **存档安全**：serialize/deserialize 覆盖关键状态，revive 重置所有运行时追踪
- **Boss 跨跳**：while 循环确保即使一击跨越多个阈值也全部触发（AC-6）
- **数据驱动**：所有阈值/帧数从 TuningKnobRegistry 读取，支持运行时调优

### Negative
- **apply_damage 复杂度**：单函数包含 4 层防护 + 5 个信号发射 + 专注模式 + Boss 阶段，代码较长。**缓解**：各阶段用注释块分隔，子逻辑抽取为私有方法
- **AI 框架反向依赖**：专注模式查询 `get_active_enemy_count()` 引入 HealthComponent → AI 框架的依赖。**缓解**：AI 框架作为场景级组件，查询接口稳定；如 AI 框架未就绪，HealthComponent 降级为不检查战斗状态
- **死亡元数据耦合**：`_build_death_metadata()` 查询 CombatComponent 的 `get_battle_stats()`，增加组件间耦合。**缓解**：使用 `get_node_or_null` + `has_method` 防御性查询，CombatComponent 不存在时返回空统计

### Risks
- **同帧多伤害序列**：AC-18 定义第 1 次→hp=5, 第 2 次→hp=0+on_death, 第 3 次被忽略。这依赖 `_state == DYING` 的 state guard 生效——如果死亡动画回调延迟（`_state` 仍为 ALIVE），第 3 次伤害可能被处理。**缓解**：`apply_damage` 在 `_current_hp == 0` 时立即设置 `_state = EntityState.DYING`（在 `on_death` 发射之前），同帧后续调用被 state guard 拦截
- ** DataManager 不可用时降级**：`_ready()` 中 `get_tuning()` 如果 DataManager 未就绪（BOOTING 状态），使用硬编码默认值。**缓解**：所有调优参数在 `get_tuning()` 调用中传入默认值参数
- **里程碑阈值浮点精度**：`hp_pct <= threshold` 使用 float 比较。边界场景（如 current_hp=75, max_hp=100, hp_pct=0.75）可能因浮点误差导致 75% 恰好不被触发。**缓解**：阈值检查使用 `<=`（含等号），75/100=0.75 可被 float 精确表示（0.75 = 3/4 = 0.11 in binary，有限位）

## GDD Requirements Addressed

| TR-ID | Requirement | How This ADR Addresses It |
|-------|-------------|--------------------------|
| TR-health-001 | HP状态管理：current_hp/max_hp/shield，每个实体独立 | §1 HP 数据结构：`_current_hp`/`_max_hp`/`_shield` 变量 + EntityState 枚举 |
| TR-health-002 | apply_damage 完整伪代码防护：state guard/is_invincible/零伤害 | §3 apply_damage 流水线：4 层防护（state → i-frame → zero-damage → shield） |
| TR-health-003 | 护盾优先吸收：shield_absorbed = min(shield, incoming) | §3 阶段 4 + §4 护盾系统：HD-F2 公式实现 |
| TR-health-004 | Boss 阶段 while 循环跨跳检测 | §8 Boss 阶段转换：`while` 循环触发所有经过阈值 |
| TR-health-005 | HP 里程碑 4 阈值一次性触发，复活重置 | §7 HP 里程碑：`_triggered_milestones` + `revive()` 中 `clear()` |
| TR-health-006 | 专注模式：≤25% 激活 / >28% 退出，战斗状态门控 | §6 专注模式：`_check_focus_mode_transition()` + 迟滞缓冲 + `active_enemies` 查询 |
| TR-health-007 | 专注模式激活闪光 + 提示音（一次性） | §6 + §17：`on_focus_mode_changed(true)` 信号发射后，Presentation 层监听并播放视觉/音效 |
| TR-health-008 | 专注模式 4 项感知变化接口 | §6 + ADR-0005：`on_focus_mode_changed` 信号供 AI 框架追加 windup_extension；其余感知变化由 Presentation 层监听 |
| TR-health-009 | i-frame grant_iframes max-take 不叠加 | §5 无敌帧管理：`_i_frame_remaining = maxi(current, frames)` |
| TR-health-010 | on_death 扩展元数据（last_hit/battle_stats/context） | §9 死亡元数据：`_build_death_metadata()` 构建完整 Dictionary |
| TR-health-011 | 信号发射顺序：changed→milestone→phase→focus→death | §3 apply_damage 流水线：①→②→③→④→⑤ 严格按序发射 |
| TR-health-012 | max_hp 聚合（HD-F0）：base + skill + charm | §2 max_hp 聚合：`recalculate_max_hp()` 三源汇总 + 零值防护 |
| TR-health-013 | revive() 重置 focus_mode + 发射信号 | §10 复活流程：`_focus_mode_active = false` + `on_focus_mode_changed.emit(false)` |
| TR-health-014 | 受伤音效音调偏移（HD-F4） | §11 查询接口：`get_injury_pitch_offset()` 实现 `(1.0 - hp_pct) × max_semitones` |
| TR-health-015 | 探索/叙事钩子：on_hp_milestone + on_death_in_zone | §7 + §9：两个信号定义 + 发射逻辑 |

## Performance Implications

- **CPU**: `apply_damage()` 主路径（无 Boss/无专注模式切换）：~0.02ms。4 层防护均为整数比较；里程碑检查 4 次 float 比较 + Array.has()（4 元素）；信号发射 ~0.01ms/信号。总 HealthComponent `_physics_process` 开销 <0.05ms/帧（仅 i-frame 递减）
- **Memory**: HealthComponent 实例 ~200 bytes（12 个变量 + 信号连接）。4 个 milestone 阈值数组 ~64 bytes。死亡元数据 Dictionary 在 on_death 时临时分配 ~512 bytes，信号发射后可 GC
- **Load Time**: 无影响——HealthComponent 在 `_ready()` 中初始化，不阻塞加载
- **Network**: N/A（单人游戏）

## Migration Plan

无需迁移。实现步骤：

1. 创建 `res://src/core/health_component.gd`
2. 定义 EntityState 枚举 + 核心变量
3. 实现 `recalculate_max_hp()`（HD-F0）
4. 实现 `apply_damage()` 完整流水线（4 层防护 + 5 信号序列）
5. 实现护盾系统（休眠接口）
6. 实现 i-frame 管理（`grant_iframes` + `_physics_process` 递减）
7. 实现专注模式（迟滞缓冲 + 战斗状态门控）
8. 实现 HP 里程碑（4 阈值 + 生命周期追踪）
9. 实现 Boss 阶段转换（while 循环）
10. 实现死亡元数据构建
11. 实现 revive()（含专注模式重置 + 里程碑清空）
12. 实现 ISerializable（serialize/deserialize）
13. 实现查询接口（get_hp_percentage/get_injury_pitch_offset 等）
14. 编写 GdUnit4 单元测试覆盖 AC-1~AC-31

## Verification

### 单元测试清单（GdUnit4，覆盖 GDD AC-1~AC-31）

- [ ] **AC-1** 基础扣血：100→70（30点伤害）
- [ ] **AC-2** 护盾吸收：shield=20+incoming=50 → shield=0, hp=50
- [ ] **AC-3** 过量伤害致死：hp=10, damage=15 → hp=0, on_death 发射
- [ ] **AC-4** 死后免疫：hp=0 后再受伤 → 忽略，不重复死亡
- [ ] **AC-5** Boss 阶段转换：200→190 (63%) → on_boss_phase_change(1)
- [ ] **AC-6** Boss 阶段跨跳：210→60 (20%) → phase_change(1) + phase_change(2)
- [ ] **AC-7** HP 百分比查询：50/100 → 0.5
- [ ] **AC-8** 复活公式：max_hp=100, revive_pct=0.5 → hp=50
- [ ] **AC-9** 专注模式激活：30%→25%（战斗状态）→ focus_mode=true
- [ ] **AC-10** i-frame 免疫：i_frame>0 → 伤害忽略，on_hp_changed 不发射
- [ ] **AC-11** 治疗溢出：hp=80, heal=30, max=100 → hp=100
- [ ] **AC-12** 里程碑首次触发：75% 触发后再次经过不重复
- [ ] **AC-14** 专注模式退出：25%→30%（>28%）→ focus_mode=false
- [ ] **AC-14b** 迟滞边界：恰好 28% 不退出（严格 >28%）
- [ ] **AC-15** 死亡元数据结构：验证 last_hit/battle_stats/context 字段完整
- [ ] **AC-16** 存档点回复：hp=30/shield=5 → hp=100/shield=20
- [ ] **AC-17** 复活下限：max_hp=1, pct=0.1 → hp=1（不返回 0）
- [ ] **AC-18** 多伤害同帧：hp=10, 三次5 → hp=5→hp=0(death)→忽略
- [ ] **AC-19** max_hp=0 防御：→ 使用默认值 100
- [ ] **AC-20** 里程碑复活重置：复活后再次降到 75% 重新触发
- [ ] **AC-21** 存亡+护盾查询：is_alive=true, shield_pct=0.5
- [ ] **AC-22** 信号发射顺序：验证 5 信号按序发射（计数器方案）
- [ ] **AC-24** i-frame 重叠取最长：5帧 + 30帧 → 30帧
- [ ] **AC-25** DoT 被 i-frame 免疫：i-frame 期间 apply_damage → HP 不变
- [ ] **AC-26** Boss 致死跨越阶段：phase_change 先于 on_death
- [ ] **AC-27** 零/负伤害防御：apply_damage(0) 和 apply_damage(-5) → HP 不变
- [ ] **AC-28** 复活退出专注模式：focus_mode=true → revive → focus_mode=false
- [ ] **AC-29** 区域死亡信号：zone_id="sewer_01" → on_death_in_zone 发射
- [ ] **AC-30** 脱战退出专注模式：active_enemies→0 → focus_mode=false

### 手动验证（非自动化）

- [ ] **AC-9b** 低 HP 视觉状态：HP 条颜色/攻击预兆闪烁（Presentation 层验证）
- [ ] **AC-23** 低 HP 受伤音效：Audio Story010 技术实现、客观频谱/衰减与 MCP 路由已通过；主观真人试听签收待完成
- [ ] **AC-31** 专注模式激活信号：猫眼金色闪光 + 提示音（Presentation 层验证）

## Related Decisions

- ADR-0001: HealthComponent 作为 Player/Enemy 子节点组件
- ADR-0002: 信号命名约定 + payload 数据类 + 发射顺序规范
- ADR-0005: CombatComponent 监听 `on_focus_mode_changed` + `get_battle_stats()` 接口
- `design/gdd/health-death.md`: 完整 GDD 需求（10 规则 + 5 公式 + 31 AC）
- `docs/architecture/tr-registry.yaml`: TR-health-001~015 技术需求定义
