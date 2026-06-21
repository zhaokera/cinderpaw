# ADR-0005: 战斗状态机架构

## Summary
定义 CombatComponent 的内部架构：6 状态战斗状态机（枚举+match 实现）、AnimationPlayer 动画驱动、3 段连招链、闪避/弹反子系统、猫气资源管理、动作取消规则表。

## Status
Accepted

## Date
2026-06-21

## Engine Compatibility

| Field | Value |
|-------|-------|
| **Engine** | Godot 4.6.3 |
| **Domain** | Animation / Core |
| **Knowledge Risk** | LOW — AnimationPlayer API stable since 4.0; AnimationMixer base class since 4.3 (in training data) |
| **References Consulted** | `docs/engine-reference/godot/modules/animation.md`, `docs/engine-reference/godot/breaking-changes.md` |
| **Post-Cutoff APIs Used** | None |
| **Verification Required** | AnimationPlayer.animation_finished 信号在动画取消时是否发射（用于状态转换） |

## ADR Dependencies

| Field | Value |
|-------|-------|
| **Depends On** | ADR-0001 (CombatComponent 组件模式), ADR-0002 (on_attack_hit 信号), ADR-0004 (碰撞激活接口) |
| **Enables** | ADR-0006 (AI行为 — 敌人也使用类似状态机模式) |
| **Blocks** | CombatComponent 实现, 武器特殊招式实现 |
| **Ordering Note** | Core 层 ADR，在碰撞检测之后 |

## Context

### Problem Statement

feline-combat.md GDD 定义了完整的战斗机制（连招、闪避、弹反、蓄力、猫气），但 CombatComponent 的内部实现架构未定：状态机用什么模式实现、动画如何与状态同步、连招链如何管理、动作取消规则如何编码、猫气如何与技能树交互。LP 审查将此标为 HIGH concern（C5：状态机未定义）。

### Constraints

- **ADR-0001**: CombatComponent 挂载在 Player 节点下，非 Autoload
- **ADR-0002**: 攻击命中使用 `on_attack_hit` 信号 + metadata
- **ADR-0004**: 通过 CollisionComponent 激活/停用 Hitbox
- **帧级精度**: 状态转换在 `_physics_process` 中处理
- **AnimationPlayer**: 动画由 AnimationPlayer 节点驱动（Player 场景子节点）

### Requirements

- 必须支持 6 状态战斗状态机 (TR-combat-001)
- 必须支持 3 段连招链（combo_index 0→1→2, 300ms 超时）(TR-combat-002)
- 必须支持动作取消规则（闪避取消攻击后摇等）(TR-combat-003)
- 必须支持猫气系统（max 100, 战斗积累, 特殊消耗, 脱战清零）(TR-combat-004)
- 必须支持蓄力攻击（0.5-1.5秒, 可被打断）
- 必须监听 `on_focus_mode_changed` 信号（专注模式下暴击窗口+1帧）

## Decision

### 状态机实现

```gdscript
# CombatComponent.gd

enum CombatState {
    IDLE,
    ATTACKING,
    DODGING,
    PARRYING,
    HIT_STUN,
    CHARGING
}

var _current_state: CombatState = CombatState.IDLE
var _previous_state: CombatState = CombatState.IDLE

func _physics_process(delta: float) -> void:
    match _current_state:
        CombatState.IDLE:
            _process_idle()
        CombatState.ATTACKING:
            _process_attacking()
        CombatState.DODGING:
            _process_dodging()
        CombatState.PARRYING:
            _process_parrying()
        CombatState.HIT_STUN:
            _process_hit_stun()
        CombatState.CHARGING:
            _process_charging()

func _change_state(new_state: CombatState) -> void:
    _previous_state = _current_state
    _current_state = new_state
    _on_state_enter(new_state)
```

### 状态定义与转换

```
              ┌─────────────────────────────────────────┐
              │                                         │
              ▼         attack              ┌───────────┘
    ┌──── IDLE ────┐                       │
    │    │    │    │                       │
    │    │    │    └──heavy_attack──► CHARGING
    │    │    │                            │ (松键)
    │    │    └──dodge──► DODGING          │
    │    │              (动画完)→IDLE       ▼
    │    └──parry──► PARRYING          ATTACKING
    │               (动画完)→IDLE          │
    │                                     │ (动画完)→IDLE
    └───── 受击 ────► HIT_STUN ◄──────────┘
                     (硬直完)→IDLE

    取消规则 (从当前状态可进入):
    ATTACKING → DODGING (闪避取消后摇)
    CHARGING → DODGING (闪避取消蓄力)
    CHARGING → HIT_STUN (受击打断蓄力)
```

### 连招链管理

```gdscript
var _combo_index: int = 0           # 0=起手, 1=中段, 2=终结
var _combo_timer: float = 0.0       # 连招超时计时
const COMBO_TIMEOUT: float = 0.3    # 300ms

func _process_attacking() -> void:
    if _anim_player.is_playing():
        return  # 动画播放中，等待
    # 动画播放完毕
    if _combo_index < 2 and _combo_timer > 0:
        # 等待下一击输入（由 InputManager 缓冲提供）
        pass
    else:
        _combo_index = 0
        _change_state(CombatState.IDLE)

func _on_attack_input() -> void:
    if _current_state == CombatState.ATTACKING and _combo_index < 2:
        _combo_index += 1
        _play_combo_animation(_combo_index)
        _combo_timer = COMBO_TIMEOUT
    elif _current_state == CombatState.IDLE:
        _combo_index = 0
        _change_state(CombatState.ATTACKING)
        _play_combo_animation(0)
        _combo_timer = COMBO_TIMEOUT
```

### 闪避子系统

```gdscript
const DODGE_IFRAME_START: int = 3
const DODGE_IFRAME_END: int = 10
const DODGE_TOTAL_FRAMES: int = 12

func _process_dodging() -> void:
    _dodge_frame += 1
    if _dodge_frame >= DODGE_IFRAME_START and _dodge_frame <= DODGE_IFRAME_END:
        _collision.set_hurtbox_state(&"gone")  # i-frame
    if _dodge_frame >= DODGE_TOTAL_FRAMES:
        _collision.set_hurtbox_state(&"normal")
        _change_state(CombatState.IDLE)
```

### 弹反子系统

```gdscript
const PARRY_WINDOW_FRAMES: int = 18

func _process_parrying() -> void:
    _parry_frame += 1
    if _parry_frame >= PARRY_WINDOW_FRAMES:
        _change_state(CombatState.IDLE)
    # 弹反判定由 CollisionComponent.on_hit_confirmed 回调处理
    # 根据 _parry_frame 判定 PERFECT(0-6)/GOOD(7-12)/LATE(13-18)
```

### 猫气管理

```gdscript
var _cat_energy: int = 0
const CAT_ENERGY_MAX: int = 100

# 获取规则 (GDD feline-combat.md 规则7)
func _on_hit_confirmed(event: HitEvent) -> void:
    match event.attack_metadata.get(&"attack_type", &""):
        &"light_0": _add_energy(5)
        &"light_1": _add_energy(8)
        &"light_2": _add_energy(12)
        &"heavy": _add_energy(10)
        &"aerial": _add_energy(8)
        &"special": _add_energy(3)
        &"parry_counter": _add_energy(15)

func _on_dodge_perfect() -> void: _add_energy(15)
func _on_parry_perfect() -> void: _add_energy(20)
func _on_parry_good() -> void: _add_energy(10)
func _on_damage_taken() -> void: _add_energy(3)

func _add_energy(amount: int) -> void:
    _cat_energy = min(CAT_ENERGY_MAX, _cat_energy + amount)

# 脱战清零 (10秒无伤害交互)
var _combat_timer: float = 0.0
func _process(delta: float) -> void:
    if _cat_energy > 0:
        _combat_timer += delta
        if _combat_timer > 10.0:
            _cat_energy = 0
```

### 专注模式集成

```gdscript
var _focus_mode_active: bool = false

func _ready() -> void:
    # 连接 HealthComponent 信号
    var health: HealthComponent = get_parent().get_node(&"HealthComponent")
    health.on_focus_mode_changed.connect(_handle_focus_mode_changed)

func _handle_focus_mode_changed(active: bool) -> void:
    _focus_mode_active = active
    # 专注模式下暴击窗口+1帧，传递给 DamageCalculator
    # 通过 skill_modifiers 参数注入
```

### Key Interfaces

```gdscript
# CombatComponent 公开接口

# 查询
func get_current_state() -> CombatState
func get_combo_index() -> int
func get_cat_energy() -> int
func is_focus_mode_active() -> bool

# 事件回调（由 CollisionComponent / InputManager 调用）
func on_hit_confirmed(event: HitEvent) -> void  # 攻击命中回调（HitEvent 定义见 ADR-0002）
func on_damage_taken(damage: int) -> void        # 受击回调
func get_battle_stats() -> Dictionary             # 战斗统计（供死亡元数据）

# 信号
signal on_attack_hit(metadata: Dictionary)  # CombatComponent 自有信号，攻击命中时发射（Presentation 层监听）
# 注: ADR-0002 定义了信号命名约定和 HitEvent payload 类，本信号遵循该约定
signal on_state_changed(old: CombatState, new: CombatState)  # 状态变更
```

## Alternatives Considered

### Alternative A: AnimationTree 状态机
- **Description**: 使用 AnimationTree 的 AnimationNodeStateMachine 管理战斗状态
- **Pros**: 可视化状态编辑；动画混合过渡内置
- **Cons**: 2D 像素动画不需要混合；状态机逻辑与动画耦合；调试困难；不适合帧级精确控制
- **Rejection Reason**: 2D ACT 需要帧级状态控制，AnimationPlayer + 自定义状态机更灵活

### Alternative B: 独立状态机类（State Pattern）
- **Description**: 为每个状态创建独立的 State 类（State 基类 + 6 个子类），通过多态调用
- **Pros**: 更好的代码组织；每个状态独立文件
- **Cons**: 过度工程（6 个状态不需要 6 个文件）；状态间共享数据需通过上下文对象
- **Rejection Reason**: 对于 6 个状态，枚举+match 模式更简单且足够。状态增多后可重构为 State Pattern

## Consequences

### Positive
- **帧级控制**: `_physics_process` 中的状态机保证每帧精确更新
- **清晰可读**: 枚举+match 模式一目了然，调试时状态变量直接可见
- **AnimationPlayer 解耦**: 动画播放与状态逻辑分离，可独立迭代动画资源
- **猫气自管理**: 内部变量，无需外部系统干预，技能树仅查询不修改

### Negative
- **状态转换集中**: 所有转换逻辑在 `_change_state()` 中，状态增多后可能变长
- **硬编码数值**: i-frame 帧数、连招超时等硬编码在常量中（但通过 DataManager TuningKnob 可覆盖）

### Risks
- **AnimationPlayer 取消时信号**: `animation_finished` 在 `play()` 中断时可能不发射，导致状态机卡住。**缓解**: 使用 `call_deferred` 确保状态转换；或在 `play()` 前先检查当前动画
- **连招输入时序**: InputManager 缓冲的消费时机与 CombatComponent 的状态转换需要精确对齐。**缓解**: 在 `_process_attacking()` 动画最后一帧检查缓冲

## GDD Requirements Addressed

| GDD System | Requirement | How This ADR Addresses It |
|------------|-------------|--------------------------|
| feline-combat.md | 6状态战斗状态机 (TR-combat-001) | CombatState 枚举 + match 实现 |
| feline-combat.md | 3段连招链 (TR-combat-002) | _combo_index + COMBO_TIMEOUT |
| feline-combat.md | 动作取消规则 (TR-combat-003) | _change_state() 中允许的转换路径 |
| feline-combat.md | 猫气系统 (TR-combat-004) | _cat_energy 内部管理 + 获取表 |
| health-death.md | 专注模式暴击窗口+1帧 | _handle_focus_mode_changed 监听 |
| collision-detection.md | activate_hitbox 调用 | _on_state_enter() 中激活对应 Hitbox |

## Performance Implications

- **CPU**: 状态机 match 分支 <0.01ms/帧。连招/闪避计时 <0.01ms/帧。总 CombatComponent 开销 <0.1ms/帧
- **Memory**: CombatComponent 实例 ~1KB（状态变量+猫气+连招计时）
- **Load Time**: 无影响
- **Network**: N/A

## Migration Plan

无需迁移。实现步骤：
1. 创建 `res://src/core/combat_component.gd`
2. 定义 CombatState 枚举和状态转换表
3. 实现各状态的 `_process_*` 方法
4. 集成 CollisionComponent（Hitbox 激活）
5. 集成 AnimationPlayer（动画播放）
6. 实现猫气系统
7. 连接 HealthComponent 专注模式信号

## Validation Criteria

- [ ] 6 个状态之间按定义路径正确转换
- [ ] 连招链 300ms 超时正确重置 combo_index
- [ ] 闪避 i-frame 在帧 3-10 期间 Hurtbox 为 gone 状态
- [ ] 弹反判定按帧差分为 PERFECT/GOOD/LATE
- [ ] 猫气不超过 100，脱战 10 秒后清零
- [ ] 专注模式下暴击窗口+1帧生效

## Related Decisions

- ADR-0001: CombatComponent 作为 Player 子节点
- ADR-0002: on_attack_hit 信号定义
- ADR-0004: CollisionComponent activate_hitbox/set_hurtbox_state 接口
- ADR-0006 (待写): AI行为 — AIComponent 可使用类似状态机模式
- `design/gdd/feline-combat.md`: 完整 GDD 需求
