# ADR-0016: 武器流派系统架构

## Summary

定义武器流派系统的内部架构：4 种武器（猫爪/长尾刃/鱼骨大剑/电磁铃铛）的数据驱动配置、WeaponComponent 的武器切换状态机（SWAP_COOLDOWN 子状态）、特殊招式调度器（冷却 + 猫气双重门控）、武器升级持久化、与 CombatComponent 的集成接口（weapon_base 查询 + 特殊机制回调），以及与 SkillTree Modifier 的注入点（F9 weapon_base 修正 + 武器特化 condition）。

## Status

Proposed

## Date

2026-06-22

## Engine Compatibility

| Field | Value |
|-------|-------|
| **Engine** | Godot 4.7 |
| **Domain** | Core / GDScript / Data |
| **Knowledge Risk** | LOW — 纯 GDScript 设计 + Resource 数据层，无引擎特定新 API |
| **References Consulted** | `docs/engine-reference/godot/VERSION.md`, `docs/engine-reference/godot/breaking-changes.md` |
| **Post-Cutoff APIs Used** | None |
| **Verification Required** | Resource 子类在 Godot 4.6+ 中 `@export` 数组序列化兼容性；AnimationPlayer 切换动画取消时 `animation_finished` 信号行为（同 ADR-0005 已识别风险） |

## ADR Dependencies

| Field | Value |
|-------|-------|
| **Depends On** | ADR-0001 (Component 模式 — WeaponComponent 作为 Player 子节点), ADR-0005 (战斗状态机 — WeaponComponent 与 CombatComponent 协作), ADR-0009 (技能树 Modifier — F9 weapon_base 修正 + condition 机制) |
| **Extends** | ADR-0005 (扩展 DamageCalculator 接口签名，新增 weapon_base_override 和 crit_window_bonus 参数) |
| **Enables** | 武器 HUD 显示, 武器升级 NPC 界面, 特殊招式表现层 |
| **Blocks** | 武器升级存档, 武器 HUD 实现 |
| **Ordering Note** | Core 层 ADR，在战斗状态机之后、表现层 ADR 之前。**注意**: 本 ADR 扩展了 ADR-0001/ADR-0005 定义的 DamageCalculator.calculate_damage() 接口，需同步更新 ADR-0005 的 CombatComponent 调用代码 |

## Context

### Problem Statement

weapon-styles.md GDD 定义了 4 种武器的完整参数（伤害、攻速、范围、特殊机制）、武器切换规则、特殊招式和升级系统。但以下架构问题未解决：

1. **数据层**：武器配置如何存储和加载？Resource 子类还是纯 JSON？
2. **武器切换**：0.5 秒切换动画期间 CombatComponent 状态机处于什么状态？切换时 combo_index 如何清空？
3. **特殊招式**：4 种武器各有独特的特殊招式效果（多段攻击/范围攻击/破盾/减速），如何统一调度又不丧失个性？
4. **特殊机制**：猫爪的暴击窗口扩展、长尾刃的多目标命中、鱼骨大剑的破盾、电磁铃铛的减速——这些机制分别在哪个层次实现？
5. **升级系统**：5 级升级数据如何与 base_damage 联动？存档如何持久化？
6. **Modifier 集成**：技能树的 F9 weapon_base 修正和武器特化 condition 如何注入武器系统？

LP 审查将此标为 HIGH concern（C6：武器系统架构未定义）。

### Constraints

- **ADR-0001**: WeaponComponent 挂载在 Player 节点下，非 Autoload
- **ADR-0005**: 战斗状态由 CombatComponent 管理（6 状态），WeaponComponent 作为其属性消费者
- **ADR-0009**: 技能树 Modifier 通过 Provider 模式注入，DamageCalculator 是纯函数
- **数据驱动**: 所有武器参数必须从 DataManager 加载（ADR-0003），不可硬编码
- **帧级精度**: 切换冷却和特殊招式冷却在 `_physics_process` 中更新
- **存档集成**: 武器等级必须通过 ISerializable 持久化（ADR-0010）

### Requirements

- 必须定义 4 种武器的完整配置数据结构 (TR-weapon-001)
- 必须支持战斗中 0.5 秒切换动画，循环切换，清空 combo_index (TR-weapon-002)
- 必须支持 4 种特殊招式，冷却和猫气双重门控 (TR-weapon-003)
- 必须支持武器 5 级升级，每级提升 base_damage (TR-weapon-004)
- 必须实现猫爪暴击窗口+3帧机制 (TR-weapon-005)
- 必须实现电磁铃铛减速效果调用 (TR-weapon-006)
- 必须实现鱼骨大剑破盾机制 (TR-weapon-007)
- 必须支持长尾刃多目标命中（复用 CollisionComponent ADR-0004 范围碰撞）

## Decision

### 1. 武器数据结构定义

#### 1.1 WeaponConfig Resource

武器配置使用 Resource 子类，由 JSON 数据文件生成（通过 DataManager 加载链）：

```gdscript
# res://src/core/weapon_config.gd
class_name WeaponConfig
extends Resource

@export var weapon_id: StringName           # &"cat_claw" | &"tail_blade" | &"fishbone_greatsword" | &"em_bell"
@export var display_name: String            # 显示名（支持本地化 key）
@export var style: StringName               # &"counter" | &"aoe" | &"burst" | &"control"

# 基础战斗参数
@export var base_damage_range: Vector2i     # x=min, y=max (升级前后)
@export var attack_speed: float             # 攻速系数（影响动画播放速度）
@export var attack_range: float             # 攻击范围（格）

# 连招倍率表 (combo_index 0/1/2)
@export var combo_multipliers: Array[float] # [1.0, 1.2, 1.8] 等

# 升级数据 (5 级)
@export var upgrade_damage_table: Array[int] # [10,12,14,16,18] 猫爪

# 特殊招式
@export var special_attack_id: StringName   # &"gale_claw" | &"whirlwind_slash" | &"earth_splitter" | &"em_pulse"
@export var special_cooldown_sec: float     # 8/10/12/15
@export var special_damage_multiplier: float # 0.8(每击)/1.5/2.0/特殊

# 特殊机制参数
@export var special_mechanism: Dictionary   # 武器独特机制参数（见下文）

# Hitbox 配置 (每武器的攻击 hitbox 尺寸)
@export var hitbox_offset: Vector2
@export var hitbox_size: Vector2
```

#### 1.2 四种武器特殊机制参数

```gdscript
# 猫爪 special_mechanism
{
    "type": &"counter_crit_extension",
    "crit_window_bonus_frames": 3,      # 闪避后下一击暴击窗口扩展
    "window_duration_sec": 0.5          # 闪避后 0.5 秒内有效
}

# 长尾刃 special_mechanism
{
    "type": &"multi_target",
    "aoe_range": 2.0,                   # 2格范围
    "max_targets": 5                    # 最大命中目标数
}

# 鱼骨大剑 special_mechanism
{
    "type": &"shield_break",
    "charge_time_sec": 1.5,             # 满蓄力时间
    "shield_break_damage_multiplier": 2.0,
    "knockback_force": 300.0
}

# 电磁铃铛 special_mechanism
{
    "type": &"slow_on_hit",
    "slow_duration_sec": 2.0,
    "slow_percentage": 0.3,             # 30% 减速
    "status_effect_id": &"slow"
}
```

#### 1.3 数据文件结构

```json
// res://assets/data/weapons/cat_claw.json
{
    "weapon_id": "cat_claw",
    "display_name": "猫爪",
    "style": "counter",
    "base_damage_range": {"x": 10, "y": 18},
    "attack_speed": 1.5,
    "attack_range": 1.0,
    "combo_multipliers": [1.0, 1.2, 1.8],
    "upgrade_damage_table": [10, 12, 14, 16, 18],
    "special_attack_id": "gale_claw",
    "special_cooldown_sec": 8.0,
    "special_damage_multiplier": 0.8,
    "special_mechanism": {
        "type": "counter_crit_extension",
        "crit_window_bonus_frames": 3,
        "window_duration_sec": 0.5
    },
    "hitbox_offset": {"x": 16, "y": 0},
    "hitbox_size": {"x": 32, "y": 32}
}
```

### 2. 武器切换状态机

WeaponComponent 维护一个 3 状态子状态机，管理武器切换的生命周期：

```gdscript
# WeaponComponent.gd (挂在 Player 节点下)

enum WeaponSwapState {
    READY,          # 可切换/可攻击
    SWAPPING,       # 切换动画播放中（0.5秒不可取消）
    COOLDOWN        # 切换后短暂冷却（可选，防连续按键）
}

var _swap_state: WeaponSwapState = WeaponSwapState.READY
var _swap_timer: float = 0.0
var _current_weapon_index: int = 0   # 0=猫爪, 1=长尾刃, 2=鱼骨, 3=铃铛
var _weapons: Array[WeaponConfig] = []
var _weapon_levels: Dictionary = {}   # {weapon_id: level} (0-4, 对应1-5级)

const WEAPON_SWAP_DURATION: float = 0.5
const WEAPON_SWAP_ORDER: Array[StringName] = [
    &"cat_claw", &"tail_blade", &"fishbone_greatsword", &"em_bell"
]

func _physics_process(delta: float) -> void:
    match _swap_state:
        WeaponSwapState.READY:
            pass  # 等待输入
        WeaponSwapState.SWAPPING:
            _swap_timer -= delta
            if _swap_timer <= 0.0:
                _complete_swap()
        WeaponSwapState.COOLDOWN:
            _swap_timer -= delta
            if _swap_timer <= 0.0:
                _swap_state = WeaponSwapState.READY

func request_swap() -> void:
    if _swap_state != WeaponSwapState.READY:
        return
    # 检查 CombatComponent 状态：攻击动画中不允许切换
    var combat: CombatComponent = _get_combat_component()
    if combat.get_current_state() == CombatComponent.CombatState.ATTACKING:
        return  # GDD: 攻击动画完成后再切换
    _swap_state = WeaponSwapState.SWAPPING
    _swap_timer = WEAPON_SWAP_DURATION
    # 通知 CombatComponent 进入切换状态（可选：添加 SWAPPING 到 CombatState）
    combat.notify_weapon_swapping()

func _complete_swap() -> void:
    # 循环切换
    _current_weapon_index = (_current_weapon_index + 1) % 4
    # 清空 combo_index（通知 CombatComponent）
    var combat: CombatComponent = _get_combat_component()
    combat.reset_combo()
    # 重置闪避冷却（通知 AbilitySystem）
    # 发射信号
    on_weapon_changed.emit(get_current_weapon())
    _swap_state = WeaponSwapState.READY

func get_current_weapon() -> WeaponConfig:
    var weapon_id: StringName = WEAPON_SWAP_ORDER[_current_weapon_index]
    return _weapons[_current_weapon_index]

func get_weapon_level(weapon_id: StringName) -> int:
    return _weapon_levels.get(weapon_id, 0)

func get_effective_base_damage() -> int:
    var weapon: WeaponConfig = get_current_weapon()
    var level: int = get_weapon_level(weapon.weapon_id)
    return weapon.upgrade_damage_table[level]

# 信号
signal on_weapon_changed(weapon: WeaponConfig)
signal on_special_attack_started(attack_id: StringName)
signal on_special_attack_finished(attack_id: StringName)
```

#### 2.1 与 CombatComponent 的切换协调

```gdscript
# CombatComponent 新增接口（ADR-0005 扩展）

func notify_weapon_swapping() -> void:
    # 武器切换期间禁止攻击输入
    _accepting_attack_input = false

func reset_combo() -> void:
    _combo_index = 0
    _combo_timer = 0.0

# 武器切换完成后恢复
func _on_weapon_swap_complete() -> void:
    _accepting_attack_input = true
```

#### 2.2 切换时序图

```
玩家按 weapon_swap
    │
    ├─ 检查 _swap_state == READY? ──── 否 → 忽略
    │
    ├─ 检查 CombatState ≠ ATTACKING? ─ 否 → 忽略（等待攻击完成）
    │
    ├─ _swap_state = SWAPPING
    ├─ 通知 CombatComponent.notify_weapon_swapping()
    ├─ 播放切换动画（AnimationPlayer, 0.5秒）
    │
    ├─ 0.5秒后...
    ├─ _current_weapon_index = (index + 1) % 4
    ├─ CombatComponent.reset_combo()
    ├─ on_weapon_changed.emit()
    └─ _swap_state = READY
```

### 3. 特殊招式架构

#### 3.1 SpecialAttackDispatcher

特殊招式使用策略模式：一个统一的调度器 + 4 种效果执行器。

```gdscript
# res://src/core/special_attack_executor.gd
class_name SpecialAttackExecutor
extends RefCounted

var _weapon_component: WeaponComponent
var _combat_component: CombatComponent
var _collision: CollisionComponent

func execute(weapon: WeaponConfig) -> void:
    match weapon.special_mechanism.get("type", &""):
        &"counter_crit_extension":
            _execute_gale_claw(weapon)
        &"multi_target":
            _execute_whirlwind_slash(weapon)
        &"shield_break":
            _execute_earth_splitter(weapon)
        &"slow_on_hit":
            _execute_em_pulse(weapon)

# 疾风连爪：0.5秒内5次快速攻击（每次80%伤害，独立暴击判定）
func _execute_gale_claw(weapon: WeaponConfig) -> void:
    var hits: int = 5
    var interval: float = 0.1  # 0.5秒 / 5次
    for i in range(hits):
        await _combat_component.wait_frames(int(interval * 60))
        var base_dmg: int = int(weapon.upgrade_damage_table[
            _weapon_component.get_weapon_level(weapon.weapon_id)
        ] * weapon.special_damage_multiplier)  # 80% 伤害
        _collision.activate_hitbox(
            &"special_gale_claw", 3, 
            weapon.hitbox_offset, weapon.hitbox_size
        )
        # 每次命中独立走伤害流水线（含暴击判定）
        # metadata 标记 attack_type = "special"

# 旋风斩：360°范围攻击（150%伤害）
func _execute_whirlwind_slash(weapon: WeaponConfig) -> void:
    var aoe_range: float = weapon.special_mechanism.get("aoe_range", 2.0)
    # 激活大范围 Hitbox（圆形，半径=aoe_range * tile_size）
    _collision.activate_hitbox(
        &"special_whirlwind", 6,
        Vector2.ZERO, Vector2(aoe_range * 32, aoe_range * 32)
    )
    # 伤害在 on_hit_confirmed 中按 150% 计算

# 地裂斩：向前跳跃重击（200%伤害 + 击飞 + 破盾）
func _execute_earth_splitter(weapon: WeaponConfig) -> void:
    # 跳跃 + 落地重击
    _combat_component.play_heavy_animation()
    # 落地瞬间激活 Hitbox
    await _combat_component.on_animation_event(&"hitbox_activate")
    _collision.activate_hitbox(
        &"special_earth_splitter", 8,
        weapon.hitbox_offset, weapon.hitbox_size * 1.5
    )
    # 命中后检查目标护盾 → 破盾（调用 HealthComponent.break_shield()）

# 电磁脉冲：范围眩晕(2秒) + 持续伤害(3秒5次) + Boss过载
func _execute_em_pulse(weapon: WeaponConfig) -> void:
    var aoe_range: float = 3.0  # 远程范围
    _collision.activate_hitbox(
        &"special_em_pulse", 4,
        Vector2.ZERO, Vector2(aoe_range * 32, aoe_range * 32)
    )
    # 命中后：
    # 1. 施加眩晕状态效果（2秒）→ StatusEffectSystem.apply(&"stun", 2.0)
    # 2. 施加 DoT（3秒5次）→ StatusEffectSystem.apply(&"burn", ...)
    # 3. Boss特殊：打断 + 过载(+20%受伤) → 查询 target.is_boss
```

#### 3.2 特殊招式调度器

```gdscript
# WeaponComponent 内部

var _special_cooldown_timer: float = 0.0
var _special_cooldown_max: float = 0.0

func request_special_attack() -> void:
    var weapon: WeaponConfig = get_current_weapon()
    # 门控1: 冷却检查
    if _special_cooldown_timer > 0.0:
        on_special_cooldown.emit(_special_cooldown_timer)
        return
    # 门控2: 猫气检查（从 CombatComponent 查询）
    var combat: CombatComponent = _get_combat_component()
    var required_energy: int = _get_special_energy_cost(weapon.special_attack_id)
    if combat.get_cat_energy() < required_energy:
        on_insufficient_energy.emit(required_energy)
        return
    # 门控3: 战斗状态检查（必须 IDLE 或 ATTACKING）
    var state: CombatComponent.CombatState = combat.get_current_state()
    if state != CombatComponent.CombatState.IDLE and \
       state != CombatComponent.CombatState.ATTACKING:
        return
    
    # 消耗猫气
    combat.consume_cat_energy(required_energy)
    # 开始冷却
    _special_cooldown_max = _get_effective_cooldown(weapon)
    _special_cooldown_timer = _special_cooldown_max
    # 执行特殊招式
    on_special_attack_started.emit(weapon.special_attack_id)
    
    # 鱼骨大剑特殊招式：两阶段流程
    # 阶段1: 门控通过后，进入CHARGING状态（由CombatComponent内部控制）
    if weapon.special_attack_id == &"earth_splitter":
        combat.enter_charging_state()  # ADR-0005 扩展接口
    # 阶段2: 落地命中后，由 _on_hit_confirmed 处理破盾逻辑
    
    _executor.execute(weapon)

func _get_effective_cooldown(weapon: WeaponConfig) -> float:
    var base_cd: float = weapon.special_cooldown_sec
    # 应用技能树冷却修正（F10）
    var skill_tree: SkillTreeManager = get_tree().get_first_node_in_group(&"skill_tree_manager")
    if skill_tree:
        var cd_reduction: float = skill_tree.get_stat_bonus(&"cooldown_reduction")
        var floor_val: float = 5.0  # 冷却下限
        base_cd = maxf(floor_val, base_cd * (1.0 - minf(cd_reduction, 0.30)))
    return base_cd

func _get_special_energy_cost(attack_id: StringName) -> int:
    # 猫气消耗由 feline-combat.md 规则7定义
    match attack_id:
        &"gale_claw": return 30
        &"whirlwind_slash": return 40
        &"earth_splitter": return 50
        &"em_pulse": return 60
        _: return 999

func _physics_process(delta: float) -> void:
    # ... (swap logic above)
    if _special_cooldown_timer > 0.0:
        _special_cooldown_timer = maxf(0.0, _special_cooldown_timer - delta)

# 信号
signal on_special_cooldown(remaining_sec: float)
signal on_insufficient_energy(required: int)
```

### 4. 武器升级系统

#### 4.1 升级接口

```gdscript
# WeaponComponent

const MAX_WEAPON_LEVEL: int = 4  # 0-indexed, 实际等级 1-5

func upgrade_weapon(weapon_id: StringName) -> bool:
    var current_level: int = _weapon_levels.get(weapon_id, 0)
    if current_level >= MAX_WEAPON_LEVEL:
        return false
    # 费用检查（由 NPC UI 传入，这里只执行升级）
    _weapon_levels[weapon_id] = current_level + 1
    on_weapon_upgraded.emit(weapon_id, current_level + 1)
    return true

func get_upgrade_cost(weapon_id: StringName) -> int:
    var next_level: int = _weapon_levels.get(weapon_id, 0) + 1
    # 费用公式：100 * next_level（可调）
    return 100 * next_level

func get_next_level_damage(weapon_id: StringName) -> int:
    var weapon: WeaponConfig = _get_config_by_id(weapon_id)
    var next_level: int = _weapon_levels.get(weapon_id, 0) + 1
    if next_level > MAX_WEAPON_LEVEL:
        return -1  # 已满级
    return weapon.upgrade_damage_table[next_level]

signal on_weapon_upgraded(weapon_id: StringName, new_level: int)
```

#### 4.2 存档持久化

```gdscript
# WeaponComponent implements ISerializable

func serialize() -> Dictionary:
    return {
        "version": 1,
        "current_weapon_index": _current_weapon_index,
        "weapon_levels": _weapon_levels.duplicate()
    }

func deserialize(data: Dictionary) -> void:
    _current_weapon_index = data.get("current_weapon_index", 0)
    _weapon_levels = data.get("weapon_levels", {})
    on_weapon_changed.emit(get_current_weapon())
```

### 5. 与 CombatComponent 的集成接口

#### 5.1 WeaponComponent → CombatComponent 调用

```gdscript
# WeaponComponent 在攻击时向 CombatComponent 提供武器数据

func get_attack_parameters() -> Dictionary:
    var weapon: WeaponConfig = get_current_weapon()
    var level: int = get_weapon_level(weapon.weapon_id)
    var base_dmg: int = weapon.upgrade_damage_table[level]
    
    # F9 技能树修正
    var skill_tree: SkillTreeManager = get_tree().get_first_node_in_group(&"skill_tree_manager")
    if skill_tree:
        var weapon_bonus: float = skill_tree.get_stat_bonus(
            &"weapon_base_bonus_%s" % weapon.weapon_id
        )
        base_dmg = int(base_dmg * (1.0 + weapon_bonus))
    
    return {
        "weapon_id": weapon.weapon_id,
        "base_damage": base_dmg,
        "combo_multiplier": weapon.combo_multipliers[
            _get_combat_component().get_combo_index()
        ],
        "attack_range": weapon.attack_range,
        "attack_speed": weapon.attack_speed,
        "special_mechanism": weapon.special_mechanism
    }
```

#### 5.2 武器特殊机制回调

```gdscript
# WeaponComponent 监听 on_hit_confirmed，执行武器特化逻辑

func _on_hit_confirmed(event: HitEvent) -> void:
    var weapon: WeaponConfig = get_current_weapon()
    match weapon.special_mechanism.get("type", &""):
        &"counter_crit_extension":
            _handle_counter_crit(event)
        &"slow_on_hit":
            _handle_slow_on_hit(event)
        &"shield_break":
            _handle_shield_break(event)
        &"multi_target":
            pass  # 由 CollisionComponent 自动处理多目标（TR-collision-006）

func _handle_counter_crit(event: HitEvent) -> void:
    # 猫爪：闪避后暴击窗口扩展
    if _dodge_counter_timer > 0.0:
        # 通知 DamageCalculator 扩展暴击窗口 +3帧
        _combat_component.set_crit_window_bonus(3)

func _handle_slow_on_hit(event: HitEvent) -> void:
    # 电磁铃铛：命中施加减速
    # 通过 StatusEffectComponent 施加（ADR-0017 统一接口）
    var target: Node = event.get_target_node()
    if target and target.has_node("StatusEffectComponent"):
        var status_comp = target.get_node("StatusEffectComponent")
        status_comp.apply_status(
            StatusEffectComponent.EffectType.SLOW,
            _entity_id,  # 施加者 entity_id
            weapon.special_mechanism.slow_duration_sec
        )

func _handle_shield_break(event: HitEvent) -> void:
    # 鱼骨大剑：满蓄力攻击破盾
    if _combat_component.get_current_state() == CombatComponent.CombatState.CHARGING:
        var charge_ratio: float = _combat_component.get_charge_ratio()
        if charge_ratio >= 1.0:  # 满蓄力
            var target: Node = event.get_target_node()
            if target and target.has_node("HealthComponent"):
                target.get_node("HealthComponent").break_shield()
```

#### 5.3 猫爪闪避后暴击窗口计时器

```gdscript
# WeaponComponent 内部

var _dodge_counter_timer: float = 0.0
const DODGE_COUNTER_WINDOW: float = 0.5  # 闪避后0.5秒内有效

func _physics_process(delta: float) -> void:
    # ... (其他逻辑)
    if _dodge_counter_timer > 0.0:
        _dodge_counter_timer = maxf(0.0, _dodge_counter_timer - delta)

func _on_dodge_completed() -> void:
    # 监听 CombatComponent 的闪避完成信号
    var weapon: WeaponConfig = get_current_weapon()
    if weapon.special_mechanism.get("type", &"") == &"counter_crit_extension":
        _dodge_counter_timer = DODGE_COUNTER_WINDOW
```

### 6. 与 SkillTree Modifier 的集成

#### 6.1 F9 武器基础修正注入

```gdscript
# SkillTreeManager 注册武器特化 modifier

# 当技能树解锁武器加成节点时：
func _on_skill_unlocked(skill_id: StringName) -> void:
    var skill_data: Dictionary = _get_skill_data(skill_id)
    if skill_data.has("weapon_base_bonus"):
        var modifier := SkillModifier.new()
        modifier.skill_id = skill_id
        modifier.type = &"weapon_base_bonus"
        modifier.target_action = skill_data.weapon_id  # &"cat_claw" 等
        modifier.stat_key = &"weapon_base"
        modifier.operation = &"add_percent"
        modifier.value = skill_data.weapon_base_bonus  # 如 0.1 = +10%
        register_modifier(modifier)
```

#### 6.2 武器特化 Condition Modifier

```gdscript
# 猫爪暴击窗口扩展的技能树加成

# 技能树节点：「利爪精通」— 猫爪暴击伤害+15%
var modifier := SkillModifier.new()
modifier.skill_id = &"claw_mastery"
modifier.type = &"damage_bonus"
modifier.target_action = &"light_attack"
modifier.stat_key = &"crit_damage"
modifier.operation = &"add_percent"
modifier.value = 0.15
modifier.condition = {"weapon": &"cat_claw"}  # 条件：当前武器为猫爪
register_modifier(modifier)

# CombatComponent 查询时检查 condition
func _get_applicable_modifiers() -> Array[SkillModifier]:
    var skill_tree: SkillTreeManager = get_tree().get_first_node_in_group(&"skill_tree_manager")
    if not skill_tree:
        return []
    var all_modifiers: Array[SkillModifier] = skill_tree.get_modifiers(&"light_attack")
    var weapon_id: StringName = _weapon_component.get_current_weapon().weapon_id
    # 过滤 condition
    return all_modifiers.filter(func(m: SkillModifier) -> bool:
        if m.condition.is_empty():
            return true
        if m.condition.has("weapon") and m.condition.weapon != weapon_id:
            return false
        return true
    )
```

#### 6.3 DamageCalculator 集成（纯函数入口扩展）

```gdscript
# DamageCalculator.calculate_damage() 扩展签名（ADR-0005 引用）

static func calculate_damage(
    attack_type: StringName,
    weapon_id: StringName,
    hit_frame: int,
    combo_index: int,
    parry_timing: StringName,
    attack_power: int,
    enemy_defense: int,
    modifiers: Array[SkillModifier] = [],
    # 新增：武器特化参数
    weapon_base_override: int = -1,
    crit_window_bonus: int = 0,
) -> Dictionary:
    # F1: base_damage
    var weapon_base: int = weapon_base_override if weapon_base_override >= 0 else _get_weapon_base(weapon_id)
    var base_damage: int = weapon_base + int(attack_power * 0.2)
    
    # F9: 技能树修正
    var skill_weapon_bonus: float = _sum_modifier(modifiers, &"weapon_base", weapon_id)
    base_damage = int(base_damage * (1.0 + skill_weapon_bonus))
    
    # DC-F2: attack_damage
    var combo_mult: float = _get_combo_multiplier(weapon_id, combo_index)
    var crit_mult: float = _get_crit_multiplier(hit_frame, crit_window_bonus)
    var parry_mult: float = _get_parry_multiplier(parry_timing)
    var attack_damage: int = int(base_damage * crit_mult * combo_mult * parry_mult)
    
    # DC-F5: final_damage
    var reduction: float = 60.0 / (enemy_defense + 60.0)
    var final_damage: int = clampi(int(attack_damage * reduction), 1, 999)
    
    return {
        "final_damage": final_damage,
        "is_crit": crit_mult > 1.0,
        "crit_type": _get_crit_type(hit_frame, crit_window_bonus),
        "metadata": {}
    }
```

### 7. Key Interfaces（完整公开接口）

```gdscript
# WeaponComponent 完整公开接口

# 查询
func get_current_weapon() -> WeaponConfig
func get_weapon_config(weapon_id: StringName) -> WeaponConfig
func get_weapon_level(weapon_id: StringName) -> int
func get_effective_base_damage() -> int
func get_attack_parameters() -> Dictionary
func get_next_weapon() -> WeaponConfig            # 循环切换预览

# 操作
func request_swap() -> void                       # 请求武器切换
func request_special_attack() -> void             # 请求特殊招式
func upgrade_weapon(weapon_id: StringName) -> bool

# 存档
func serialize() -> Dictionary
func deserialize(data: Dictionary) -> void

# 信号
signal on_weapon_changed(weapon: WeaponConfig)
signal on_special_attack_started(attack_id: StringName)
signal on_special_attack_finished(attack_id: StringName)
signal on_weapon_upgraded(weapon_id: StringName, new_level: int)
signal on_special_cooldown(remaining_sec: float)
signal on_insufficient_energy(required: int)
```

## Alternatives Considered

### Alternative A: 武器系统作为 CombatComponent 内部模块
- **Description**: 不创建独立的 WeaponComponent，将武器逻辑直接嵌入 CombatComponent
- **Pros**: 减少组件数量；数据共享更简单
- **Cons**: CombatComponent 职责膨胀（已有 6 状态机 + 猫气 + 连招）；武器升级/存档逻辑与战斗逻辑耦合；违反单一职责
- **Rejection Reason**: WeaponComponent 有独立的升级持久化、切换动画、特殊招式调度，足以成为独立组件

### Alternative B: 特殊招式使用独立场景/AnimationPlayer
- **Description**: 每种武器的特殊招式定义为独立场景，通过 PackedScene 实例化
- **Pros**: 视觉和逻辑完全隔离；可独立迭代
- **Cons**: 场景管理复杂度高；Hitbox 配置需要跨场景通信；4 种武器 = 4 个额外场景
- **Rejection Reason**: 特殊招式本质是动画+Hitbox 激活+效果触发，在 WeaponComponent 内用策略模式更简洁

### Alternative C: 武器数据使用纯 Dictionary（无 Resource 子类）
- **Description**: 直接使用 Dictionary 存储武器配置，不创建 WeaponConfig Resource
- **Pros**: 更灵活；无需 Resource 序列化
- **Cons**: 无类型安全；编辑器无自动补全；需要手动验证字段
- **Rejection Reason**: Resource 子类提供类型安全和编辑器支持，DataManager 的 Resource 加载链已有基础设施（ADR-0003）

## Consequences

### Positive
- **数据驱动**: 武器参数从 JSON 加载，平衡调整无需改代码
- **职责清晰**: WeaponComponent 专管武器，CombatComponent 专管战斗状态
- **扩展性好**: 新增武器只需添加 JSON + 特殊机制分支（策略模式）
- **Modifier 兼容**: 复用 ADR-0009 的 Provider 模式，技能树加成自然注入
- **存档简单**: serialize/deserialize 仅 2 个字段（当前武器+等级字典）

### Negative
- **组件通信**: WeaponComponent 和 CombatComponent 需要频繁交互（切换协调、参数查询）
- **特殊招式分支**: 策略模式的 match 分支会随武器增加而增长（但 MVP 仅 4 种）
- **猫气消耗硬编码**: `_get_special_energy_cost()` 中猫气消耗值硬编码（由 feline-combat.md 定义，但理想情况应从数据加载）

### Risks
- **切换动画与状态机竞争**: 武器切换 0.5 秒期间，CombatComponent 如果收到攻击输入可能导致状态不一致。**缓解**: `request_swap()` 中检查 CombatState，切换期间 `_accepting_attack_input = false`
- **特殊招式帧同步**: 疾风连爪（5 次 0.1 秒间隔）需要精确的帧级计时，`await wait_frames()` 可能因帧率波动导致时序偏差。**缓解**: 使用 `_physics_process` 帧计数器而非 `await get_tree().create_timer()`
- **Modifier condition 过滤性能**: 每次攻击都过滤 modifier 列表。**缓解**: modifier 数量 <20，过滤操作 <0.01ms；可在武器切换时缓存
- **鱼骨大剑破盾与 HealthComponent 耦合**: `break_shield()` 接口需要 HealthComponent 支持（ADR-0007）。**缓解**: 通过 `has_method` 检查，不存在时降级为普通伤害

## GDD Requirements Addressed

| GDD System | Requirement | How This ADR Addresses It |
|------------|-------------|--------------------------|
| weapon-styles.md | 4种武器定义 (TR-weapon-001) | WeaponConfig Resource + JSON 数据文件，4 种武器各有独立配置 |
| weapon-styles.md | 武器切换 (TR-weapon-002) | WeaponSwapState 状态机 + request_swap() + 0.5秒动画 + combo 清空 |
| weapon-styles.md | 特殊招式 (TR-weapon-003) | SpecialAttackExecutor 策略模式 + 冷却/猫气双重门控 |
| weapon-styles.md | 武器升级 (TR-weapon-004) | upgrade_weapon() + upgrade_damage_table + ISerializable 持久化 |
| weapon-styles.md | 猫爪暴击窗口 (TR-weapon-005) | _dodge_counter_timer + set_crit_window_bonus(3) + DODGE_COUNTER_WINDOW |
| weapon-styles.md | 电磁铃铛减速 (TR-weapon-006) | _handle_slow_on_hit() → target.apply_status_effect(&"slow") |
| weapon-styles.md | 鱼骨大剑破盾 (TR-weapon-007) | _handle_shield_break() + 满蓄力检查 + HealthComponent.break_shield() |

## Performance Implications

- **CPU**: WeaponComponent `_physics_process` 开销 <0.05ms/帧（计时器递减+状态检查）。特殊招式执行期间 <0.1ms/帧。Modifier 过滤 <0.01ms/帧
- **Memory**: 4 个 WeaponConfig Resource ≈ 4KB。_weapon_levels Dictionary ≈ 100B。总计 <5KB
- **Load Time**: 武器 JSON 在 DataManager BOOTING 阶段预加载，无运行时加载开销
- **Network**: N/A

## Migration Plan

无需迁移。实现步骤：

1. 创建 `res://src/core/weapon_config.gd`（Resource 子类）
2. 创建 `res://src/core/weapon_component.gd`（WeaponComponent 主体）
3. 创建 `res://src/core/special_attack_executor.gd`（特殊招式策略）
4. 编写 4 个武器 JSON 数据文件（`res://assets/data/weapons/`）
5. 扩展 CombatComponent（新增 `notify_weapon_swapping()` / `reset_combo()` / `set_crit_window_bonus()`）
6. 在 Player 场景中添加 WeaponComponent 节点
7. 连接信号（on_weapon_changed → HUD, on_hit_confirmed → 特殊机制回调）
8. 实现 ISerializable 接口（存档集成）
9. 与 SkillTreeManager 集成（F9 modifier 注册 + condition 过滤）

## Validation Criteria

- [ ] 4 种武器配置从 JSON 正确加载为 WeaponConfig Resource
- [ ] 战斗中按 weapon_swap 触发 0.5 秒切换动画，动画期间不可攻击
- [ ] 切换完成后 combo_index 重置为 0
- [ ] 循环切换顺序正确：猫爪→长尾刃→鱼骨→铃铛→猫爪
- [ ] 特殊招式同时检查冷却和猫气，任一不满足则拒绝执行
- [ ] 疾风连爪 0.5 秒内执行 5 次攻击，每次独立暴击判定
- [ ] 旋风斩命中 2 格范围内所有敌人
- [ ] 鱼骨大剑满蓄力命中破盾敌人时护盾被清除
- [ ] 电磁铃铛命中后目标移速 -30% 持续 2 秒
- [ ] 猫爪闪避后 0.5 秒内攻击，暴击窗口扩展 +3 帧
- [ ] 武器升级后 base_damage 按 upgrade_damage_table 正确提升
- [ ] 武器等级正确序列化和反序列化（存档/读档）
- [ ] 技能树 F9 weapon_base 修正正确注入伤害计算
- [ ] 武器特化 condition modifier 正确过滤（猫爪技能只影响猫爪）

## Related Decisions

- ADR-0001: WeaponComponent 作为 Player 子节点
- ADR-0003: DataManager 加载武器 JSON → WeaponConfig Resource
- ADR-0004: CollisionComponent activate_hitbox() 被特殊招式调用
- ADR-0005: CombatComponent 6 状态机与武器切换协调
- ADR-0009: SkillTree Modifier Provider + F9 修正 + condition 机制
- ADR-0010: ISerializable 武器等级持久化
- `design/gdd/weapon-styles.md`: 完整 GDD 需求
