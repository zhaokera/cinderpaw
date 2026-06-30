# ADR-0006: AI行为系统架构

## Summary
定义 AIComponent 的内部架构：6 状态行为状态机（IDLE/PATROL/CHASE/ATTACK/FLEE/STUN）、感知锥检测、数据驱动攻击模式、Boss 阶段转换集成、专注模式前摇延长。

## Status
Accepted

## Date
2026-06-21

## Engine Compatibility

| Field | Value |
|-------|-------|
| **Engine** | Godot 4.7 |
| **Domain** | Core / Physics 2D |
| **Knowledge Risk** | LOW — RayCast2D, Area2D API stable. NavigationServer2D (4.5+) not needed for hand-designed levels |
| **References Consulted** | `docs/engine-reference/godot/modules/physics.md`, `docs/engine-reference/godot/modules/navigation.md` |
| **Post-Cutoff APIs Used** | None (2D Nav Server 4.5 not used — levels are hand-designed) |
| **Verification Required** | RayCast2D 视线检测在 TileMapLayer 障碍物上的准确性 |

## ADR Dependencies

| Field | Value |
|-------|-------|
| **Depends On** | ADR-0001 (AIComponent 组件模式), ADR-0002 (信号), ADR-0004 (碰撞), ADR-0005 (状态机模式参考) |
| **Enables** | Boss配置层实现 |
| **Blocks** | AIComponent 实现, Boss行为实现 |
| **Ordering Note** | Core 层最后一个 ADR |

## Context

### Problem Statement

ai-framework.md GDD 定义了敌人行为需求（6 状态、感知系统、攻击模式、Boss 阶段、低HP 适应），但 AIComponent 的内部架构未定：状态机如何实现、感知系统用什么引擎 API、攻击模式如何从数据加载、Boss 阶段转换如何集成。

### Constraints

- **ADR-0001**: AIComponent 挂载在每个 Enemy 节点下
- **ADR-0002**: 信号遵循 `on_` 前缀
- **ADR-0004**: 通过 CollisionComponent 激活 Hitbox
- **数据驱动**: 攻击模式从 DataManager 的 `enemy_stats` 域加载
- **无 NavigationServer2D**: 银河城关卡手动设计，不需要自动寻路

### Requirements

- 必须支持 6 状态行为状态机 (TR-ai-001)
- 必须支持感知锥检测（角度+距离+视线射线）(TR-ai-002)
- 必须支持数据驱动攻击模式（startup/active/recovery 帧配置）(TR-ai-003)
- 必须支持 Boss 阶段转换（监听 on_boss_phase_change）
- 必须支持专注模式前摇延长（windup_extension_frames）
- 必须提供 `get_active_enemy_count()` 查询（供 HealthComponent 专注模式使用）

## Decision

### 行为状态机

```gdscript
# AIComponent.gd

enum AIState {
    IDLE,
    PATROL,
    CHASE,
    ATTACK,
    FLEE,
    STUN
}

var _current_state: AIState = AIState.IDLE
var _attack_patterns: Array[Dictionary] = []  # 从 DataManager 加载
var _current_pattern_index: int = -1
var _windup_extension: int = 0  # 专注模式前摇延长帧数

func _physics_process(delta: float) -> void:
    match _current_state:
        AIState.IDLE:
            _process_idle()
        AIState.PATROL:
            _process_patrol()
        AIState.CHASE:
            _process_chase()
        AIState.ATTACK:
            _process_attack()
        AIState.FLEE:
            _process_flee()
        AIState.STUN:
            _process_stun()
```

### 感知系统

```gdscript
# 使用 RayCast2D 检测视线 + Area2D 检测距离

var _perception_radius: float = 200.0
var _perception_angle: float = 120.0  # 度

func _can_see_player() -> bool:
    var to_player: Vector2 = _player.global_position - global_position
    var distance: float = to_player.length()
    if distance > _perception_radius:
        return false
    var angle: float = rad_to_deg(global_transform.x.angle_to(to_player.normalized()))
    if abs(angle) > _perception_angle / 2.0:
        return false
    # 视线射线检测
    var space_state := get_world_2d().direct_space_state
    var query := PhysicsRayQueryParameters2D.create(global_position, _player.global_position)
    query.collision_mask = 0b10000  # environment layer
    var result: Dictionary = space_state.intersect_ray(query)
    return result.is_empty()  # 无遮挡 = 可见
```

### 攻击模式执行

```gdscript
func _process_attack() -> void:
    if _attack_phase == AttackPhase.STARTUP:
        _startup_frame += 1
        var effective_startup: int = _current_pattern.startup_frames + _windup_extension
        if _startup_frame >= effective_startup:
            _attack_phase = AttackPhase.ACTIVE
            _collision.activate_hitbox(
                _current_pattern.hitbox_id,
                _current_pattern.active_frames,
                _current_pattern.hitbox_offset,
                _current_pattern.hitbox_size
            )
    elif _attack_phase == AttackPhase.ACTIVE:
        _active_frame += 1
        if _active_frame >= _current_pattern.active_frames:
            _attack_phase = AttackPhase.RECOVERY
    elif _attack_phase == AttackPhase.RECOVERY:
        _recovery_frame += 1
        if _recovery_frame >= _current_pattern.recovery_frames:
            _change_state(AIState.IDLE)
```

### 专注模式集成

```gdscript
func _ready() -> void:
    # 通过场景查找 Player 的 HealthComponent
    var player := get_tree().get_first_node_in_group(&"player")
    if player:
        var health: HealthComponent = player.get_node(&"HealthComponent")
        health.on_focus_mode_changed.connect(_handle_focus_mode_changed)

func _handle_focus_mode_changed(active: bool) -> void:
    _windup_extension = _attack_pattern_data.windup_extension_frames if active else 0
    # 仅影响新发起的攻击，已在执行中的攻击不受影响
```

### get_active_enemy_count()

```gdscript
# 静态全局计数器（所有 AIComponent 实例共享）
static var _active_enemy_count: int = 0

func _on_enter_combat_state() -> void:
    _active_enemy_count += 1  # CHASE 或 ATTACK 状态

func _on_exit_combat_state() -> void:
    _active_enemy_count -= 1  # 回到 IDLE/PATROL

static func get_active_enemy_count() -> int:
    return _active_enemy_count
```

### Key Interfaces

```gdscript
# AIComponent 公开接口

static func get_active_enemy_count() -> int  # HealthComponent 查询

# 信号
signal on_state_changed(old: AIState, new: AIState)
signal on_attack_started(pattern_id: StringName)
signal on_attack_ended()
```

## Alternatives Considered

### Alternative A: 行为树 (Behavior Tree)
- **Description**: 使用行为树框架（如 LimboHSM）替代状态机
- **Pros**: 更灵活的组合能力；适合复杂 AI
- **Cons**: 引入外部依赖；MVP 敌人行为简单（巡逻/追击/攻击），状态机足够
- **Rejection Reason**: MVP 范围内 3 种行为类型，状态机完全够用。垂直切片时可评估行为树

### Alternative B: NavigationAgent2D 自动寻路
- **Description**: 使用 Godot 4.5 的 2D 导航服务器做敌人寻路
- **Pros**: 自动避障；复杂地形路径规划
- **Cons**: 银河城关卡手动设计，不需要自动寻路；增加导出包大小；敌人路径应可预测（玩家学习模式）
- **Rejection Reason**: 手动关卡 + 可预测模式 = 不需要 NavigationAgent2D

## Consequences

### Positive
- **数据驱动**: 攻击模式从 JSON 加载，新增敌人类型无需写代码
- **状态机简单**: 6 状态足够覆盖 MVP 敌人行为
- **专注模式集成**: 通过信号自动延长前摇，无需 AI 代码修改
- **静态计数器**: get_active_enemy_count() 零开销查询

### Negative
- **无自动寻路**: 敌人追击路径固定（直线），复杂地形可能卡住
- **静态计数器线程安全**: 如果未来引入多线程，static var 需要保护

### Risks
- **RayCast2D 性能**: 每个敌人每帧发射视线射线。20 敌人 × 1 射线 ≈ 0.2ms（可接受）。**缓解**: 仅在 IDLE/CHASE 状态发射射线，ATTACK 状态跳过
- **感知锥计算误差**: `angle_to()` 在边缘角度可能不精确。**缓解**: 使用 `abs(angle) <= perception_angle / 2.0 + 1.0` 加宽容度

## GDD Requirements Addressed

| GDD System | Requirement | How This ADR Addresses It |
|------------|-------------|--------------------------|
| ai-framework.md | 6状态行为状态机 (TR-ai-001) | AIState 枚举 + match 实现 |
| ai-framework.md | 感知锥检测 (TR-ai-002) | RayCast2D + 角度/距离计算 |
| ai-framework.md | 数据驱动攻击模式 (TR-ai-003) | DataManager.get_domain("enemy_stats") |
| health-death.md | get_active_enemy_count() | 静态计数器 + 状态进入/退出更新 |
| health-death.md | on_focus_mode_changed 前摇延长 | _handle_focus_mode_changed + windup_extension |
| boss-config.md | Boss阶段转换 | on_boss_phase_change 监听（BossConfigComponent） |

## Performance Implications

- **CPU**: 状态机 <0.01ms/实体/帧。感知射线 0.01ms/实体/帧。20 实体 ≈ 0.4ms/帧
- **Memory**: AIComponent 实例 ~2KB/实体（状态+攻击模式数据）
- **Load Time**: 无影响
- **Network**: N/A

## Migration Plan

无需迁移。实现步骤：
1. 创建 `res://src/core/ai_component.gd`
2. 定义 AIState 枚举和状态转换逻辑
3. 实现感知系统（RayCast2D + 角度检测）
4. 实现攻击模式执行（3 阶段：startup/active/recovery）
5. 集成 CollisionComponent（Hitbox 激活）
6. 实现静态 active_enemy_count 计数器
7. 连接专注模式信号

## Validation Criteria

- [ ] 6 状态按感知条件和HP阈值正确转换
- [ ] 感知锥检测在半径/角度/遮挡三条件同时满足时返回 true
- [ ] 攻击模式 3 阶段按配置的帧数执行
- [ ] 专注模式下 startup_frames 正确延长 windup_extension_frames
- [ ] get_active_enemy_count() 返回 CHASE+ATTACK 状态的敌人总数

## Related Decisions

- ADR-0001: AIComponent 作为 Enemy 子节点
- ADR-0002: 信号约定
- ADR-0004: CollisionComponent 接口
- ADR-0005: 状态机模式参考
- `design/gdd/ai-framework.md`: 完整 GDD 需求
