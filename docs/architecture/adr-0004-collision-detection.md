# ADR-0004: 碰撞检测架构

## Summary
定义碰撞检测的 Area2D Hitbox/Hurtbox 模式、碰撞层分配、帧级检测循环、Hurtbox 状态管理和防重复命中机制。采用 Godot 标准 Area2D + CollisionShape2D 方案。

## Status
Accepted

## Date
2026-06-21

## Engine Compatibility

| Field | Value |
|-------|-------|
| **Engine** | Godot 4.6.3 |
| **Domain** | Physics 2D |
| **Knowledge Risk** | LOW — 2D physics unchanged in 4.4–4.6 (still Godot Physics 2D) |
| **References Consulted** | `docs/engine-reference/godot/modules/physics.md`, `docs/engine-reference/godot/VERSION.md` |
| **Post-Cutoff APIs Used** | None |
| **Verification Required** | 验证 Area2D.get_overlapping_areas() 在 _physics_process 中的每帧一致性 |

## ADR Dependencies

| Field | Value |
|-------|-------|
| **Depends On** | ADR-0001 (CollisionComponent 作为实体子节点), ADR-0002 (on_hit_confirmed 信号 + HitEvent) |
| **Enables** | ADR-0005 (战斗状态机 — 攻击命中依赖碰撞检测) |
| **Blocks** | CombatComponent, AIComponent 实现 |
| **Ordering Note** | Core 层 ADR，在 Foundation ADR 之后、战斗/AI ADR 之前 |

## Context

### Problem Statement

collision-detection.md GDD 定义了帧级 Hitbox/Hurtbox 碰撞检测的需求。但实现架构未定：Area2D 节点如何组织在实体场景树中、碰撞层如何分配、帧级检测循环如何实现、Hurtbox 的 3 种状态如何切换、以及如何防止同一次攻击对同一目标多次命中。

### Constraints

- **ADR-0001**: CollisionComponent 作为实体（Player/Enemy）子节点，非 Autoload
- **ADR-0002**: 命中事件使用 `on_hit_confirmed` 信号 + `HitEvent` payload 类
- **帧级精度**: 碰撞检测在 `_physics_process` 中执行（60fps）
- **性能预算**: 碰撞检测 <3ms/帧（technical-preferences.md: 16.6ms 总预算）

### Requirements

- 必须支持每实体多个 Hitbox（不同攻击动作激活不同 Hitbox）(TR-collision-001)
- 必须支持 Hurtbox 三状态（normal/shrunk/gone）(TR-collision-002)
- 必须支持 5 碰撞层（player_attack, enemy_attack, player_hurt, enemy_hurt, environment）(TR-collision-003)
- 必须防止同一次攻击对同一目标多次命中
- 必须支持攻击命中后自动停用 Hitbox（duration_frames 超时）

## Decision

### 节点结构

```
Player (CharacterBody2D)
├── ...
├── HitboxContainer (Node2D)         # 所有 Hitbox 的父节点
│   ├── Hitbox_light_1 (Area2D)      # 轻攻击第1击
│   │   └── CollisionShape2D         # 攻击判定框
│   ├── Hitbox_light_2 (Area2D)      # 轻攻击第2击
│   │   └── CollisionShape2D
│   ├── Hitbox_heavy (Area2D)        # 重攻击
│   │   └── CollisionShape2D
│   └── Hitbox_special (Area2D)      # 特殊招式
│       └── CollisionShape2D
├── Hurtbox (Area2D)                 # 受击判定框（唯一）
│   └── CollisionShape2D
└── ...

Enemy (CharacterBody2D)
├── HitboxContainer (Node2D)
│   ├── Hitbox_attack_1 (Area2D)
│   │   └── CollisionShape2D
│   └── Hitbox_attack_2 (Area2D)
│       └── CollisionShape2D
└── Hurtbox (Area2D)
    └── CollisionShape2D
```

**规则**:
- Hitbox 默认 `monitoring = false`（不检测），攻击动作激活时设为 `true`
- Hurtbox 默认 `monitorable = true`（可被检测）
- Hurtbox `gone` 状态：`monitorable = false`（闪避 i-frame）
- Hurtbox `shrunk` 状态：替换为更小的 CollisionShape2D

### 碰撞层分配

```
Layer 1: player_attack   — 玩家 Hitbox
Layer 2: enemy_attack    — 敌人 Hitbox
Layer 3: player_hurt     — 玩家 Hurtbox
Layer 4: enemy_hurt      — 敌人 Hurtbox
Layer 5: environment     — 环境伤害（尖刺/岩浆）

碰撞矩阵:
  player_attack (L1) → mask: enemy_hurt (L4)   # 玩家攻击可命中敌人
  enemy_attack  (L2) → mask: player_hurt (L3)   # 敌人攻击可命中玩家
  environment   (L5) → mask: player_hurt + enemy_hurt (L3+L4)  # 环境伤害命中所有
```

**project.godot 配置**:
```
[layer_names]
2d_physics/layer_1="player_attack"
2d_physics/layer_2="enemy_attack"
2d_physics/layer_3="player_hurt"
2d_physics/layer_4="enemy_hurt"
2d_physics/layer_5="environment"
```

### 帧级检测循环

```gdscript
# CollisionComponent._physics_process(delta)

func _physics_process(delta: float) -> void:
    # 1. 检查所有活跃 Hitbox 的碰撞
    for hitbox in _active_hitboxes:
        if not hitbox.monitoring:
            continue
        var overlapping: Array[Area2D] = hitbox.get_overlapping_areas()
        for area in overlapping:
            if area == _hurtbox:
                continue  # 跳过自己的 Hurtbox
            if not area.is_in_group(&"hurtbox"):
                continue  # 只处理 Hurtbox
            var target_id: int = area.get_parent().entity_id
            if hitbox.has_hit(target_id):
                continue  # 防重复
            hitbox.mark_hit(target_id)
            _emit_hit_confirmed(hitbox, area, target_id)

    # 2. 递减 Hitbox 活跃帧数
    for hitbox in _active_hitboxes:
        hitbox.remaining_frames -= 1
        if hitbox.remaining_frames <= 0:
            deactivate_hitbox(hitbox)
```

### Hitbox 活跃管理

```gdscript
# 由 CombatComponent 或 AIComponent 调用

func activate_hitbox(hitbox_id: StringName, duration_frames: int,
                     offset: Vector2, size: Vector2) -> void:
    var hitbox: HitboxArea = _hitbox_map[hitbox_id]
    hitbox.position = offset
    hitbox.shape.size = size
    hitbox.monitoring = true
    hitbox.remaining_frames = duration_frames
    hitbox.clear_hits()  # 重置命中记录
    if hitbox not in _active_hitboxes:
        _active_hitboxes.append(hitbox)

func deactivate_hitbox(hitbox: HitboxArea) -> void:
    hitbox.monitoring = false
    _active_hitboxes.erase(hitbox)

# HitboxArea 类 (extends Area2D)
class_name HitboxArea
var remaining_frames: int = 0
var _hit_targets: Dictionary = {}  # {entity_id: true}
func mark_hit(target_id: int) -> void: _hit_targets[target_id] = true
func has_hit(target_id: int) -> bool: return _hit_targets.has(target_id)
func clear_hits() -> void: _hit_targets.clear()
```

### Hurtbox 状态管理

```gdscript
func set_hurtbox_state(state: StringName) -> void:
    match state:
        &"normal":
            _hurtbox.monitorable = true
            _hurtbox_shape.shape = _normal_shape  # _hurtbox_shape: CollisionShape2D 引用
        &"shrunk":
            _hurtbox.monitorable = true
            _hurtbox_shape.shape = _shrunk_shape  # 50% 尺寸
        &"gone":
            _hurtbox.monitorable = false    # i-frame 无敌
```

### Signal Emission

```gdscript
func _emit_hit_confirmed(hitbox: HitboxArea, hurtbox: Area2D, target_id: int) -> void:
    var event := HitEvent.new()
    event.attacker_id = entity_id
    event.target_id = target_id
    event.hitbox_id = hitbox.hitbox_id
    event.hit_position = (hitbox.global_position + hurtbox.global_position) / 2.0
    event.hit_frame = hitbox.remaining_frames  # 剩余帧作为命中帧参考
    event.attack_metadata = hitbox.attack_metadata
    on_hit_confirmed.emit(event)
```

### Key Interfaces

```gdscript
# CollisionComponent (挂在 Player/Enemy 下)

# 公开接口（CombatComponent / AIComponent 调用）
func activate_hitbox(hitbox_id: StringName, duration_frames: int,
                     offset: Vector2, size: Vector2) -> void
func deactivate_hitbox(hitbox_id: StringName) -> void
    # 内部通过 _hitbox_map[hitbox_id] 查找 HitboxArea 引用
func set_hurtbox_state(state: StringName) -> void  # "normal" | "shrunk" | "gone"

# 信号
signal on_hit_confirmed(event: HitEvent)  # ADR-0002 定义的 payload 类
```

## Alternatives Considered

### Alternative A: PhysicsServer2D 直接查询
- **Description**: 不使用 Area2D 节点，直接通过 PhysicsServer2D 的 `space_get_direct_state()` 查询碰撞
- **Pros**: 更高性能（无节点开销）；更细粒度控制
- **Cons**: 实现复杂度高；无法利用 Godot 编辑器的碰撞形状可视化；碰撞层管理需手动实现
- **Rejection Reason**: 2D ACT 碰撞检测复杂度不高，Area2D 方案足够且开发效率更高

### Alternative B: 自定义 AABB 检测
- **Description**: 完全不使用物理引擎，手动计算矩形重叠
- **Pros**: 最轻量；完全控制
- **Cons**: 失去碰撞层/遮罩；失去编辑器可视化；无法复用 Godot 调试工具
- **Rejection Reason**: Area2D 方案的调试可视化（F4 切换碰撞框显示）对开发效率至关重要

## Consequences

### Positive
- **Godot 原生**: Area2D 是 Godot 2D 碰撞检测的标准方案，社区资源丰富
- **编辑器可视化**: 碰撞形状在编辑器中直接可见，调试时 F4 切换显示
- **碰撞层管理**: Godot 的 layer/mask 系统提供声明式碰撞过滤
- **帧级精度**: `_physics_process` 保证每帧检测一次

### Negative
- **节点开销**: 每实体 1 Hurtbox + N Hitbox Area2D 节点（预计 Player 5个, Enemy 3个）
- **Hitbox 管理复杂度**: 需要为每种攻击创建预定义的 Hitbox 节点，新增攻击需修改场景

### Risks
- **Area2D.get_overlapping_areas() 同帧延迟**: 某些情况下 Area2D 状态变更（如 `monitoring = true`）可能在同一 `_physics_process` 帧内不被 `get_overlapping_areas()` 反映。**缓解**: 使用 `call_deferred` 或在下一个 `_physics_process` 帧开始检测
- **大量敌人时的性能**: 场景中有 20+ 敌人时，Area2D 重叠检测可能成为瓶颈。**缓解**: MVP 场景设计控制同屏敌人数量 <10

## GDD Requirements Addressed

| GDD System | Requirement | How This ADR Addresses It |
|------------|-------------|--------------------------|
| collision-detection.md | Hitbox 管理 (TR-collision-001) | HitboxArea 类 + activate/deactivate 接口 |
| collision-detection.md | Hurtbox 三状态 (TR-collision-002) | set_hurtbox_state() 实现 normal/shrunk/gone |
| collision-detection.md | 碰撞分层 (TR-collision-003) | 5 碰撞层 + layer/mask 配置 |
| feline-combat.md | activate_hitbox() 调用 | CollisionComponent.activate_hitbox() |
| feline-combat.md | set_hurtbox_state() 调用 | CollisionComponent.set_hurtbox_state() |
| ai-framework.md | 敌人攻击判定 | AIComponent 调用 activate_hitbox() |

## Performance Implications

- **CPU**: Area2D.get_overlapping_areas() 每次调用 <0.1ms。10 个实体 × 3 个活跃 Hitbox = 30 次调用/帧 ≈ 3ms（预算内）
- **Memory**: 每实体 ~5 个 Area2D 节点 ≈ 2KB/实体。20 实体 ≈ 40KB
- **Load Time**: 无影响
- **Network**: N/A

## Migration Plan

无需迁移。实现步骤：
1. 创建 `res://src/core/collision_component.gd`
2. 创建 `res://src/core/hitbox_area.gd` (class_name HitboxArea)
3. 在 project.godot 中配置 5 碰撞层
4. 在 Player/Enemy 场景中添加 HitboxContainer + Hurtbox 节点
5. 实现 `_physics_process` 检测循环

## Validation Criteria

- [ ] Hitbox 激活后在 duration_frames 帧内检测碰撞，超时自动停用
- [ ] Hurtbox `gone` 状态下不受任何 Hitbox 命中
- [ ] mark_hit() 防止同一次攻击对同一目标多次命中
- [ ] on_hit_confirmed 信号携带正确的 HitEvent 数据
- [ ] 碰撞层正确过滤（player_attack 只命中 enemy_hurt）

## Related Decisions

- ADR-0001: CollisionComponent 作为实体子节点
- ADR-0002: on_hit_confirmed 信号 + HitEvent payload
- ADR-0005 (待写): CombatComponent 调用 activate_hitbox/deactivate_hitbox
- `design/gdd/collision-detection.md`: 完整 GDD 需求
