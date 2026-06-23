# ADR-0020: 碰撞检测 API 补充架构

## Summary

补充 ADR-0004 未覆盖的碰撞检测实现细节：定义 HitboxConfig 数据结构、完善多目标命中处理与死亡清理生命周期、指定 F4 调试可视化叠加层实现、规定命中即时反馈触发机制、明确与 WeaponComponent/StatusEffectComponent 的集成契约。填补 TR-collision-004 ~ TR-collision-009 共 6 个 TR 缺口，使碰撞系统具备完整可实现的 API 规范。

## Status

Proposed

## Date

2026-06-22

## Last Verified

2026-06-22

## Decision Makers

架构师（用户 + AI）

## Engine Compatibility

| Field | Value |
|-------|-------|
| **Engine** | Godot 4.6.3 |
| **Domain** | Physics 2D / Debug |
| **Knowledge Risk** | LOW — Area2D、CollisionShape2D、PhysicsServer2D 均为稳定 API（4.0 起无破坏性变更） |
| **References Consulted** | `docs/engine-reference/godot/modules/physics.md`, `docs/engine-reference/godot/VERSION.md` |
| **Post-Cutoff APIs Used** | None |
| **Verification Required** | 验证 `_physics_process` 中批量 `get_overlapping_areas()` 在 10 实体 × 3 Hitbox 场景下 < 3ms |

## ADR Dependencies

| Field | Value |
|-------|-------|
| **Depends On** | ADR-0004 (碰撞检测基础架构 — Area2D Hitbox/Hurtbox 模式), ADR-0002 (on_hit_confirmed 信号 + HitEvent), ADR-0016 (WeaponComponent — 武器特殊招式 Hitbox 配置), ADR-0017 (StatusEffectComponent — 命中触发状态效果) |
| **Enables** | ADR-0005 (CombatComponent — 完整碰撞激活流程), 碰撞调试工具实现, 武器特殊招式碰撞集成 |
| **Blocks** | 战斗表现系统 (依赖 hit feedback 接口), 调试面板 (依赖碰撞可视化接口) |
| **Ordering Note** | Core 层补充 ADR，与 ADR-0004 共同构成碰撞系统完整规范。必须在 WeaponComponent / StatusEffectComponent 实现之前 Accepted |

## Context

### Problem Statement

ADR-0004 定义了碰撞检测的基础骨架（Area2D 节点结构、碰撞层分配、帧级检测循环、Hurtbox 状态管理），但以下实现细节未明确，导致实现阶段存在歧义：

1. **Hitbox 配置数据结构**未定义——武器特殊招式（ADR-0016）如何传入 Hitbox 参数？
2. **多目标处理**细节不足——范围攻击同帧命中 3+ 敌人时，事件顺序、去重、性能保证未明确 (TR-collision-006)
3. **死亡清理**生命周期缺失——实体死亡时活跃 Hitbox 如何回收 (TR-collision-007)
4. **碰撞层矩阵**完整配置规范缺失——project.godot 中 layer/mask 位掩码的精确值 (TR-collision-004 扩展)
5. **调试可视化**未定义——F4 切换、颜色编码、绘制方式 (TR-collision-009)
6. **命中即时反馈**接口未定义——火花粒子与闪光如何由碰撞系统直接触发
7. **与 WeaponComponent 集成**接口未定义——武器特殊招式的 Hitbox 如何传入 CollisionComponent
8. **与 StatusEffectComponent 集成**接口未定义——碰撞命中如何触发状态效果
9. **性能优化策略**未定义——大量实体时碰撞检测如何控制在 3ms 预算内

### Constraints

- **ADR-0004 不可变**: 本 ADR 扩展而非修改 ADR-0004 的节点结构、帧级循环、Hurtbox 状态管理
- **Godot 4.6.3**: 所有 API 必须符合 Godot 4.6.3（参考 `docs/engine-reference/godot/VERSION.md`）
- **性能预算**: 碰撞检测 < 3ms/帧（10 实体 × 3 活跃 Hitbox 基准场景）
- **组件模式**: 遵循 ADR-0001，CollisionComponent 作为实体子节点，非 Autoload

### Requirements

- 定义 HitboxConfig 数据结构，支持从 WeaponComponent / 数据文件传入 (TR-collision-004 扩展)
- 完善多目标命中处理：保证顺序、去重、独立事件发射 (TR-collision-006)
- 定义死亡清理接口：监听 on_death 自动停用所有 Hitbox (TR-collision-007)
- 指定 Area2D + CollisionShape2D 的精确配置（矩形、默认尺寸）(TR-collision-008)
- 定义调试可视化系统：F4 切换、颜色编码、绘制实现 (TR-collision-009)
- 定义命中即时反馈触发接口（火花粒子、闪光）
- 定义与 WeaponComponent 的集成契约
- 定义与 StatusEffectComponent 的集成契约
- 定义性能优化策略（空间分区 / 批量查询）

## Decision

### 1. HitboxConfig 数据结构

定义独立的数据资源类，将 Hitbox 参数从硬编码中解耦，支持从数据文件（JSON/Resource）和 WeaponComponent 统一传入。

```gdscript
# res://src/core/hitbox_config.gd
class_name HitboxConfig
extends Resource

## 唯一标识符（对应 HitboxContainer 中的节点名）
@export var hitbox_id: StringName

## 碰撞形状偏移（相对于实体中心）
@export var offset: Vector2 = Vector2.ZERO

## 碰撞形状尺寸（像素）
@export var size: Vector2 = Vector2(32, 32)

## 活跃持续帧数（60fps 基准）
@export var duration_frames: int = 10

## 碰撞层（使用 CollisionLayer 枚举常量）
@export var collision_layer: int = CollisionLayer.PLAYER_ATTACK

## 攻击元数据（传递给伤害计算管线）
@export var attack_metadata: Dictionary = {}

## 尺寸下限验证
const MIN_SIZE := Vector2(4, 4)

func validate() -> void:
    if size.x < MIN_SIZE.x or size.y < MIN_SIZE.y:
        push_warning("HitboxConfig '%s' size %s below minimum %s, clamping" % [hitbox_id, size, MIN_SIZE])
        size = size.max(MIN_SIZE)
    if duration_frames <= 0:
        push_warning("HitboxConfig '%s' duration_frames <= 0, setting to 1" % hitbox_id)
        duration_frames = 1
```

**CollisionLayer 枚举**（集中定义，避免魔法数字）：

```gdscript
# res://src/core/collision_layer.gd
class_name CollisionLayer
extends RefCounted

enum Layer {
    NONE         = 0,
    PLAYER_ATTACK = 1 << 0,  # Layer 1
    ENEMY_ATTACK  = 1 << 1,  # Layer 2
    PLAYER_HURT   = 1 << 2,  # Layer 3
    ENEMY_HURT    = 1 << 3,  # Layer 4
    ENVIRONMENT   = 1 << 4,  # Layer 5
}

## 碰撞矩阵：Layer → Mask 映射
## 规则：player_attack → enemy_hurt, enemy_attack → player_hurt, environment → both hurt
const LAYER_MASK_MAP: Dictionary = {
    Layer.PLAYER_ATTACK: Layer.ENEMY_HURT,
    Layer.ENEMY_ATTACK:  Layer.PLAYER_HURT,
    Layer.PLAYER_HURT:   Layer.NONE,       # Hurtbox 不主动检测
    Layer.ENEMY_HURT:    Layer.NONE,       # Hurtbox 不主动检测
    Layer.ENVIRONMENT:   Layer.PLAYER_HURT | Layer.ENEMY_HURT,
}
```

### 2. 完善后的碰撞 API 完整接口

ADR-0004 定义了 `activate_hitbox` / `deactivate_hitbox` / `set_hurtbox_state` 的基础签名。以下补充完整签名和语义：

```gdscript
# CollisionComponent.gd — 完整公开接口（补充 ADR-0004）

# ─── Hitbox 管理 ─────────────────────────────────────────────

## 激活指定 Hitbox。由 CombatComponent / AIComponent / SpecialAttackExecutor 调用。
## config: HitboxConfig 资源（包含 offset, size, duration_frames, attack_metadata）
## 语义：设置 HitboxArea 位置/形状/monitoring=true/剩余帧数，清除命中记录
func activate_hitbox(hitbox_id: StringName, config: HitboxConfig) -> void:
    config.validate()
    var hitbox: HitboxArea = _hitbox_map.get(hitbox_id)
    if hitbox == null:
        push_warning("CollisionComponent: hitbox_id '%s' not found in _hitbox_map" % hitbox_id)
        return
    hitbox.position = config.offset
    hitbox.shape.size = config.size
    hitbox.collision_layer = config.collision_layer
    hitbox.collision_mask = CollisionLayer.LAYER_MASK_MAP[config.collision_layer]
    hitbox.attack_metadata = config.attack_metadata.duplicate()
    hitbox.monitoring = true
    hitbox.remaining_frames = config.duration_frames
    hitbox.clear_hits()
    if hitbox not in _active_hitboxes:
        _active_hitboxes.append(hitbox)

## 立即停用指定 Hitbox。
func deactivate_hitbox(hitbox_id: StringName) -> void:
    var hitbox: HitboxArea = _hitbox_map.get(hitbox_id)
    if hitbox == null:
        return
    hitbox.monitoring = false
    hitbox.clear_hits()
    _active_hitboxes.erase(hitbox)

## 停用实体的所有活跃 Hitbox（死亡/硬直时调用）
func deactivate_all_hitboxes() -> void:
    for hitbox in _active_hitboxes.duplicate():
        hitbox.monitoring = false
        hitbox.clear_hits()
    _active_hitboxes.clear()

## 查询指定 Hitbox 是否处于活跃状态
func is_hitbox_active(hitbox_id: StringName) -> bool:
    var hitbox: HitboxArea = _hitbox_map.get(hitbox_id)
    return hitbox != null and hitbox in _active_hitboxes

## 获取当前活跃 Hitbox 数量（调试/性能监控用）
func get_active_hitbox_count() -> int:
    return _active_hitboxes.size()

# ─── Hurtbox 管理 ────────────────────────────────────────────

## 设置 Hurtbox 状态。由 CombatComponent 调用。
## state: &"normal" | &"shrunk" | &"gone"
func set_hurtbox_state(state: StringName) -> void:
    # （实现同 ADR-0004，此处不重复）
    pass

## 更新 Hurtbox 尺寸（姿态变化：站立/蹲伏/空中）
## 由 CombatComponent 在姿态切换时调用
func set_hurtbox_size(size: Vector2) -> void:
    _normal_shape.size = size
    _shrunk_shape.size = size * _shrunk_ratio  # _shrunk_ratio = 0.5

## 查询当前 Hurtbox 状态
func get_hurtbox_state() -> StringName:
    return _current_hurtbox_state

## 查询 Hurtbox 是否可被命中（normal/shrunk = true, gone = false）
func is_hurtbox_active() -> bool:
    return _hurtbox.monitorable

# ─── 信号 ────────────────────────────────────────────────────

## 命中确认（ADR-0002 定义的 HitEvent payload）
signal on_hit_confirmed(event: HitEvent)

## 调试用：Hitbox 激活/停用事件（仅 DEBUG 构建连接）
signal on_hitbox_activated(hitbox_id: StringName)
signal on_hitbox_deactivated(hitbox_id: StringName)
signal on_hurtbox_state_changed(state: StringName)

# ─── 生命周期 ─────────────────────────────────────────────────

## 初始化：在 _ready 中扫描 HitboxContainer 子节点，构建 _hitbox_map
## 连接实体的 on_death 信号（由父实体在初始化时调用）
func bind_entity_death(death_signal: Signal) -> void:
    death_signal.connect(_on_entity_death, CONNECT_ONE_SHOT)

func _on_entity_death() -> void:
    deactivate_all_hitboxes()
    _hurtbox.monitorable = false  # 死亡后不再受击
```

**与 ADR-0004 接口的兼容性说明**：

ADR-0004 定义的 `activate_hitbox(hitbox_id, duration_frames, offset, size)` 签名保留为**便捷重载**，内部构造 HitboxConfig 后调用完整签名：

```gdscript
## 便捷重载（兼容 ADR-0004 签名）
func activate_hitbox(hitbox_id: StringName, duration_frames: int,
                     offset: Vector2, size: Vector2) -> void:
    var config := HitboxConfig.new()
    config.hitbox_id = hitbox_id
    config.offset = offset
    config.size = size
    config.duration_frames = duration_frames
    activate_hitbox(hitbox_id, config)
```

### 3. 多目标处理

当一次范围攻击（如长尾刃旋风斩）的 Hitbox 同帧与多个 Hurtbox 重叠时，处理规则：

```gdscript
# CollisionComponent._physics_process 中的多目标处理逻辑

func _physics_process(delta: float) -> void:
    # 1. 帧级碰撞检测（所有活跃 Hitbox）
    for hitbox in _active_hitboxes:
        if not hitbox.monitoring:
            continue
        var overlapping: Array[Area2D] = hitbox.get_overlapping_areas()
        # 收集本帧所有有效命中
        var frame_hits: Array[HitEvent] = []
        for area in overlapping:
            if area == _hurtbox:
                continue  # 跳过自身 Hurtbox
            if not area.is_in_group(&"hurtbox"):
                continue
            var target_entity: Node = area.get_parent()
            var target_id: int = target_entity.entity_id
            if hitbox.has_hit(target_id):
                continue  # 防重复：同一次攻击对同一目标只命中一次
            # 碰撞层验证（双重保险——引擎 layer/mask 已过滤，此处防御性检查）
            if hitbox.collision_layer & area.collision_mask == 0:
                continue
            hitbox.mark_hit(target_id)
            var event := _build_hit_event(hitbox, area, target_id)
            frame_hits.append(event)

        # 2. 按目标距离排序：近到远（确保表现层按命中距离播放反馈）
        frame_hits.sort_custom(_compare_hit_distance.bind(hitbox.global_position))

        # 3. 逐个发射（保证信号处理顺序确定性）
        for event in frame_hits:
            on_hit_confirmed.emit(event)
            _trigger_hit_feedback(event)  # 命中即时反馈

    # 4. 递减 Hitbox 活跃帧数
    _tick_hitbox_frames()

func _compare_hit_distance(a: HitEvent, b: HitEvent, origin: Vector2) -> bool:
    return origin.distance_squared_to(a.hit_position) < origin.distance_squared_to(b.hit_position)

func _build_hit_event(hitbox: HitboxArea, hurtbox: Area2D, target_id: int) -> HitEvent:
    var event := HitEvent.new()
    event.attacker_id = entity_id
    event.target_id = target_id
    event.hitbox_id = hitbox.hitbox_id
    event.hit_position = (hitbox.global_position + hurtbox.global_position) / 2.0
    event.hit_frame = Engine.get_physics_frames()
    event.attack_metadata = hitbox.attack_metadata.duplicate()
    return event
```

**多目标处理规则总结**：

| 场景 | 行为 |
|------|------|
| 同一 Hitbox 同帧重叠 N 个 Hurtbox | 发射 N 次 `on_hit_confirmed`，每次独立 HitEvent |
| 同一 Hitbox 对同一 Hurtbox 连续多帧重叠 | 仅第 1 帧命中（`mark_hit()` 防重复） |
| 两个实体 Hitbox 互相重叠对方 Hurtbox | 各自独立触发命中（互伤） |
| Hitbox 激活帧与 Hurtbox gone 状态同帧 | 该帧命中无效（`monitorable=false`，引擎不返回重叠） |
| Hitbox 激活帧与 Hurtbox shrunk 状态同帧 | 命中有效（shrunk 仍 `monitorable=true`，仅面积缩小） |
| 实体死亡瞬间 Hitbox 仍重叠 Hurtbox | `_on_entity_death()` 立即停用所有 Hitbox，不再检测 |

### 4. 死亡清理生命周期

```gdscript
# 死亡清理流程

# 1. 实体初始化时绑定
func _ready() -> void:
    # ... ADR-0004 原有初始化 ...
    var combat: Node = get_parent().get_node_or_null("CombatComponent")
    if combat and combat.has_signal("on_death"):
        bind_entity_death(combat.on_death)

# 2. 死亡触发时的执行顺序
#    a. CombatComponent 发射 on_death
#    b. CollisionComponent._on_entity_death() 被调用（CONNECT_ONE_SHOT）
#    c. deactivate_all_hitboxes() — 停用所有活跃 Hitbox
#    d. _hurtbox.monitorable = false — 防止死亡后继续受击
#    e. 断开所有碰撞相关的信号连接

# 3. 注意事项
#    - 死亡帧的命中判定：如果 on_death 在同一 _physics_process 帧内
#      被发射（非 call_deferred），则死亡帧的碰撞仍有效
#    - 如果 on_death 在 _process 中发射（非物理帧），则死亡帧碰撞
#      可能已经执行完毕——以实际发射时序为准
```

### 5. 碰撞层完整配置规范

补充 ADR-0004 的碰撞层定义，增加 mask 位掩码精确值和 Area2D 节点配置：

```
project.godot 配置:
────────────────────────────────────────────────────
Layer 名称           位       Layer 值     典型使用者
────────────────────────────────────────────────────
player_attack        bit 0    1            Player Hitbox
enemy_attack         bit 1    2            Enemy Hitbox
player_hurt          bit 2    4            Player Hurtbox
enemy_hurt           bit 3    8            Enemy Hurtbox
environment          bit 4    16           尖刺/岩浆/陷阱
────────────────────────────────────────────────────

Area2D 节点配置模板:
────────────────────────────────────────────────────
节点类型           collision_layer    collision_mask
────────────────────────────────────────────────────
Player Hitbox      1 (player_attack)  8 (enemy_hurt)
Enemy Hitbox       2 (enemy_attack)   4 (player_hurt)
Player Hurtbox     4 (player_hurt)    0 (不主动检测)
Enemy Hurtbox      8 (enemy_hurt)     0 (不主动检测)
环境伤害 Area2D    16 (environment)   12 (player_hurt + enemy_hurt)
────────────────────────────────────────────────────

注意：Hurtbox 的 collision_mask = 0，因为碰撞检测由 Hitbox 主动发起
（Hitbox monitoring=true，调用 get_overlapping_areas() 获取重叠 Hurtbox）。
Hurtbox 只需设置 collision_layer 以被 Hitbox 的 mask 匹配到。
```

### 6. Area2D + CollisionShape2D 精确配置 (TR-collision-008)

```gdscript
# Hitbox Area2D 默认配置
# 在 HitboxContainer 下的每个 Hitbox Area2D 节点:
#   monitoring = false          # 默认不检测，由 activate_hitbox 激活
#   monitorable = false         # Hitbox 不需要被其他 Area2D 检测
#   collision_layer = 按类型设置（见上方矩阵）
#   collision_mask = 按类型设置（见上方矩阵）
#   gravity_scale = 0.0         # Area2D 不受重力影响（4.6 属性）

# CollisionShape2D 配置:
#   shape = RectangleShape2D    # 默认矩形（支持未来扩展圆形）
#   disabled = false            # 默认启用
#   one_way_collision = false   # 不使用单向碰撞

# Hurtbox Area2D 默认配置:
#   monitoring = false          # Hurtbox 不主动检测
#   monitorable = true          # 可被 Hitbox 检测到
#   add_to_group("hurtbox")    # 必须加入 hurtbox 组（帧级循环过滤用）

# 默认尺寸:
#   Hitbox:  RectangleShape2D.size = Vector2(32, 32)
#   Hurtbox: RectangleShape2D.size = Vector2(24, 48)（站立姿态）
#   Hurtbox shrunk: RectangleShape2D.size = Vector2(12, 24)（50% 缩小）
```

### 7. 调试可视化系统 (TR-collision-009)

独立组件 `CollisionDebugOverlay`，作为 Autoload 单例实现（需要全局访问所有实体的碰撞框）。

```gdscript
# res://src/tools/collision_debug_overlay.gd
# Autoload: CollisionDebugOverlay
extends CanvasLayer

## F4 切换碰撞框可视化叠加层
## 颜色编码:
##   红色半透明   — 活跃 Hitbox
##   绿色半透明   — 正常 Hurtbox (normal)
##   蓝色半透明   — 缩小 Hurtbox (shrunk)
##   黄色虚线轮廓 — 消失 Hurtbox (gone / i-frame)

var _enabled: bool = false
var _overlay_control: Control

func _ready() -> void:
    layer = 128  # 最高层，确保叠加在所有游戏内容之上
    _overlay_control = Control.new()
    _overlay_control.set_anchors_preset(Control.PRESET_FULL_RECT)
    _overlay_control.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(_overlay_control)
    _overlay_control.draw.connect(_draw_collision_boxes)

func _input(event: InputEvent) -> void:
    if event.is_action_pressed("debug_toggle_collision"):  # F4 绑定
        toggle()

func toggle() -> void:
    _enabled = not _enabled
    _overlay_control.visible = _enabled
    if _enabled:
        set_process(true)
    else:
        set_process(false)
        _overlay_control.queue_redraw()

func _process(_delta: float) -> void:
    _overlay_control.queue_redraw()  # 每帧重绘

func _draw_collision_boxes() -> void:
    if not _enabled:
        return
    # 遍历所有 CollisionComponent 实例
    var components: Array[Node] = get_tree().get_nodes_in_group("collision_component")
    for comp in components:
        _draw_hitboxes(comp)
        _draw_hurtbox(comp)

func _draw_hitboxes(comp: Node) -> void:
    # 红色半透明: Color(1, 0, 0, 0.3), 实线边框 Color(1, 0, 0, 0.8)
    for hitbox in comp._active_hitboxes:
        var rect: Rect2 = _get_area_global_rect(hitbox)
        _overlay_control.draw_rect(rect, Color(1, 0, 0, 0.3))
        _overlay_control.draw_rect(rect, Color(1, 0, 0, 0.8), false, 1.0)
        # 标注 hitbox_id
        _overlay_control.draw_string(
            ThemeDB.fallback_font, rect.position + Vector2(0, -4),
            str(hitbox.hitbox_id), HORIZONTAL_ALIGNMENT_LEFT, -1, 10,
            Color(1, 0, 0, 0.9)
        )

func _draw_hurtbox(comp: Node) -> void:
    var hurtbox: Area2D = comp._hurtbox
    var rect: Rect2 = _get_area_global_rect(hurtbox)
    var state: StringName = comp.get_hurtbox_state()
    match state:
        &"normal":
            # 绿色半透明
            _overlay_control.draw_rect(rect, Color(0, 1, 0, 0.3))
            _overlay_control.draw_rect(rect, Color(0, 1, 0, 0.8), false, 1.0)
        &"shrunk":
            # 蓝色半透明
            _overlay_control.draw_rect(rect, Color(0, 0.4, 1, 0.3))
            _overlay_control.draw_rect(rect, Color(0, 0.4, 1, 0.8), false, 1.0)
        &"gone":
            # 黄色虚线轮廓（i-frame 无敌）
            _draw_dashed_rect(rect, Color(1, 1, 0, 0.6))

func _draw_dashed_rect(rect: Rect2, color: Color, dash_length: float = 4.0, gap_length: float = 4.0) -> void:
    var points: PackedVector2Array = [
        rect.position,
        Vector2(rect.end.x, rect.position.y),
        rect.end,
        Vector2(rect.position.x, rect.end.y),
    ]
    for i in range(4):
        _draw_dashed_line(points[i], points[(i + 1) % 4], color, dash_length, gap_length)

func _draw_dashed_line(from: Vector2, to: Vector2, color: Color, dash: float, gap: float) -> void:
    var dir: Vector2 = (to - from).normalized()
    var dist: float = from.distance_to(to)
    var pos: float = 0.0
    var drawing: bool = true
    while pos < dist:
        var seg: float = min(dash if drawing else gap, dist - pos)
        if drawing:
            _overlay_control.draw_line(from + dir * pos, from + dir * (pos + seg), color, 1.0)
        pos += seg
        drawing = not drawing

func _get_area_global_rect(area: Area2D) -> Rect2:
    var shape: CollisionShape2D = area.get_node("CollisionShape2D")
    var rect_shape: RectangleShape2D = shape.shape as RectangleShape2D
    if rect_shape == null:
        return Rect2()
    var half: Vector2 = rect_shape.size / 2.0
    var center: Vector2 = shape.global_position
    return Rect2(center - half, rect_shape.size)

# ─── 调试面板信息 ─────────────────────────────────────────────

func get_debug_info() -> Dictionary:
    var info: Dictionary = {}
    var total_hitboxes: int = 0
    var total_hurtboxes: int = 0
    var components: Array[Node] = get_tree().get_nodes_in_group("collision_component")
    for comp in components:
        total_hitboxes += comp.get_active_hitbox_count()
        total_hurtboxes += 1
    info["active_hitboxes"] = total_hitboxes
    info["total_entities"] = components.size()
    info["overlay_enabled"] = _enabled
    return info
```

**InputMap 配置**：
```
# project.godot 中添加
[input]
debug_toggle_collision={
    "events": [Object(InputEventKey,"keycode":KEY_F4) ]
}
```

**非 DEBUG 构建排除**：
```gdscript
# CollisionDebugOverlay 仅在 Debug 构建中注册为 Autoload
# 通过 export preset 的 feature tag 控制：
#   [configuration]
#   features=PackedStringArray("debug")
# 在 release 构建中，CollisionDebugOverlay 不被加载，零开销
```

### 8. 命中即时反馈

碰撞系统直接触发最底层的命中反馈（火花粒子 + 闪光），与 `combat-presentation.md` 定义的高级表现（帧停、震屏、伤害数字）分层：

```gdscript
# CollisionComponent 内部方法

func _trigger_hit_feedback(event: HitEvent) -> void:
    if not OS.is_debug_build():
        return  # Release 构建跳过调试反馈（正式反馈由表现层处理）

    # 1. 火花粒子（3-5 个白色小火花）
    var spark_scene: PackedScene = preload("res://assets/vfx/hit_spark.tscn")
    var spark: GPUParticles2D = spark_scene.instantiate() as GPUParticles2D
    spark.emitting = true
    spark.one_shot = true
    spark.amount = randi_range(3, 5)
    spark.lifetime = 0.2
    spark.global_position = event.hit_position
    get_tree().current_scene.add_child(spark)
    # 自动清理
    spark.finished.connect(spark.queue_free)

    # 2. 命中闪光（8×8px 白色闪光，持续 1 帧）
    var flash: Sprite2D = Sprite2D.new()
    flash.texture = _flash_texture  # 预加载的 8×8 白色方块纹理
    flash.global_position = event.hit_position
    flash.modulate = Color(1, 1, 1, 0.8)
    get_tree().current_scene.add_child(flash)
    # 1 帧后移除
    var tween: Tween = flash.create_tween()
    tween.tween_callback(flash.queue_free).set_delay(1.0 / 60.0)

# 预加载资源（避免每次命中实例化开销）
var _flash_texture: Texture2D = preload("res://assets/vfx/hit_flash_8x8.png")
```

**职责分界**：

| 反馈类型 | 触发者 | 位置 | 说明 |
|----------|--------|------|------|
| 火花粒子 | CollisionComponent | hit_position | 碰撞系统直接触发，确认命中 |
| 命中闪光 | CollisionComponent | hit_position | 碰撞系统直接触发，1帧白闪 |
| 帧停 (Hitstop) | CombatPresentation | — | 监听 on_hit_confirmed 信号触发 |
| 震屏 | CombatPresentation | — | 监听 on_hit_confirmed 信号触发 |
| 伤害数字 | CombatPresentation | — | 伤害计算完成后由表现层显示 |
| 命中音效 | CombatPresentation | — | 监听 on_hit_confirmed 信号触发 |

### 9. 与 WeaponComponent 集成

WeaponComponent（ADR-0016）持有武器的 HitboxConfig 数据，通过 CollisionComponent 的完整接口激活碰撞：

```gdscript
# WeaponComponent 中的碰撞集成模式

# 武器配置中定义 HitboxConfig 引用
# WeaponConfig (Resource) 已有:
#   hitbox_offset: Vector2
#   hitbox_size: Vector2
# 扩展为:
#   hitbox_configs: Array[HitboxConfig]  # 每种攻击的 Hitbox 配置

# SpecialAttackExecutor 中的调用模式（ADR-0016 扩展）:
func _execute_whirlwind_slash(weapon: WeaponConfig) -> void:
    # 长尾刃多目标范围攻击
    var config: HitboxConfig = weapon.get_hitbox_config(&"special_whirlwind")
    config.duration_frames = 15  # 范围攻击持续更长
    config.attack_metadata["attack_type"] = "special"
    config.attack_metadata["weapon_id"] = weapon.weapon_id
    _collision.activate_hitbox(config.hitbox_id, config)
    # 多目标命中由 CollisionComponent 自动处理（见第 3 节）

# 武器切换时的 Hitbox 清理:
func _on_weapon_switched() -> void:
    # 切换武器时停用所有活跃 Hitbox，防止残留判定
    _collision.deactivate_all_hitboxes()
```

**数据流**：
```
WeaponConfig (数据资源)
  └── hitbox_configs: Array[HitboxConfig]
        └── 每个 HitboxConfig 定义一种攻击的碰撞参数
              ↓
SpecialAttackExecutor / CombatComponent
  └── 从 WeaponConfig 获取 HitboxConfig
        └── 调用 CollisionComponent.activate_hitbox(id, config)
              ↓
CollisionComponent
  └── 配置 HitboxArea 并激活检测
        └── 命中时发射 on_hit_confirmed(event)
```

### 10. 与 StatusEffectComponent 集成

StatusEffectComponent（ADR-0017）监听 `on_hit_confirmed` 信号，检查 `attack_metadata` 中是否附带状态效果：

```gdscript
# StatusEffectComponent 中的碰撞集成模式（ADR-0017 已有，此处定义契约）

func _on_hit_confirmed(event: HitEvent) -> void:
    # 仅处理本实体发起的攻击（对其他实体的命中不处理效果施加）
    if event.attacker_id != _entity_id:
        return
    # 从 attack_metadata 中提取附带效果
    var effect_id: StringName = event.attack_metadata.get("attached_effect", &"")
    if effect_id.is_empty():
        return
    # 获取目标实体的 StatusEffectComponent
    var target_status: StatusEffectComponent = _get_target_status_component(event.target_id)
    if target_status == null:
        return
    # 施加状态效果
    target_status.apply_status(effect_id, _entity_id)
```

**attack_metadata 中状态效果的约定字段**：

| 字段 | 类型 | 说明 |
|------|------|------|
| `attached_effect` | StringName | 命中时施加的状态效果 ID（空 = 无效果） |
| `attack_type` | StringName | 攻击类型（`&"light"`, `&"heavy"`, `&"special"`） |
| `weapon_id` | StringName | 武器 ID（用于查询武器升级后的效果增强） |
| `combo_index` | int | 连招段数（0/1/2，用于连招递增伤害） |

### 11. 性能优化策略

基准场景：10 实体 × 3 活跃 Hitbox = 30 个活跃 Hitbox，预算 < 3ms/帧。

#### 11.1 当前方案性能评估

ADR-0004 的朴素方案（每个 Hitbox 调用 `get_overlapping_areas()`）：
- 30 次 `get_overlapping_areas()` 调用 × ~0.1ms/次 ≈ 3ms
- 恰好在预算边缘，无余量

#### 11.2 优化策略：空间哈希网格（推荐）

引入轻量空间哈希网格，减少不必要的碰撞查询：

```gdscript
# res://src/core/collision_spatial_hash.gd
class_name CollisionSpatialHash
extends RefCounted

## 空间哈希网格 — 将实体按位置分桶，减少碰撞查询次数
## 单元格大小：128px（约为最大 Hitbox 尺寸的 4 倍）

const CELL_SIZE: int = 128
var _grid: Dictionary = {}  # {Vector2i: Array[HitboxArea]}

func clear() -> void:
    _grid.clear()

func insert(hitbox: HitboxArea) -> void:
    var cell: Vector2i = _world_to_cell(hitbox.global_position)
    if not _grid.has(cell):
        _grid[cell] = []
    _grid[cell].append(hitbox)

func query_nearby(hitbox: HitboxArea) -> Array[HitboxArea]:
    ## 返回可能碰撞的 Hitbox（同单元格 + 相邻单元格）
    var cell: Vector2i = _world_to_cell(hitbox.global_position)
    var result: Array[HitboxArea] = []
    for dx in range(-1, 2):
        for dy in range(-1, 2):
            var neighbor: Vector2i = cell + Vector2i(dx, dy)
            if _grid.has(neighbor):
                result.append_array(_grid[neighbor])
    return result

func _world_to_cell(pos: Vector2) -> Vector2i:
    return Vector2i(int(pos.x) / CELL_SIZE, int(pos.y) / CELL_SIZE)
```

**注意**：空间哈希用于优化 Hurtbox 的候选查找，不替代 Godot 引擎的 Area2D 碰撞检测。实际碰撞判定仍由引擎 `get_overlapping_areas()` 完成。空间哈希的价值在于：当场景有 20+ 敌人时，可以先用空间哈希筛选出空间上可能碰撞的实体子集，再只对子集调用引擎查询。

**MVP 阶段决策**：MVP 场景同屏敌人 < 10，朴素方案（30 次查询 ≈ 3ms）可接受。空间哈希作为 Phase 2 优化预研，在实体数突破 15 时启用。代码中预留接口但不默认激活。

#### 11.3 优化策略：碰撞检测节流

```gdscript
# 当活跃 Hitbox 数量 < 阈值时，每帧检测
# 当活跃 Hitbox 数量 >= 阈值时，可以隔帧检测（牺牲 1 帧精度换性能）
const FULL_SCAN_THRESHOLD: int = 20  # 30 个活跃 Hitbox 下不触发

var _skip_frame: bool = false

func _physics_process(delta: float) -> void:
    if _active_hitboxes.size() >= FULL_SCAN_THRESHOLD:
        _skip_frame = not _skip_frame
        if _skip_frame:
            return  # 跳过本帧检测
    # 正常检测逻辑 ...
```

**MVP 阶段不使用节流**——10 实体 × 3 Hitbox = 30 次查询在预算内。此策略仅在性能监控显示超标时启用。

#### 11.4 性能监控接口

```gdscript
# CollisionComponent 内置性能计时

var _last_frame_collision_time_ms: float = 0.0

func get_collision_time_ms() -> float:
    return _last_frame_collision_time_ms

func _physics_process(delta: float) -> void:
    var start_time: int = Time.get_ticks_usec()
    # ... 碰撞检测逻辑 ...
    _last_frame_collision_time_ms = (Time.get_ticks_usec() - start_time) / 1000.0

    if _last_frame_collision_time_ms > 3.0:
        push_warning("CollisionComponent: collision detection %.2fms exceeds 3ms budget" % _last_frame_collision_time_ms)
```

## Alternatives Considered

### Alternative A: 全局碰撞 Autoload 单例

- **Description**: 将碰撞检测逻辑放在 Autoload 单例中，统一管理所有实体的 Hitbox/Hurtbox
- **Pros**: 集中管理，方便全局查询和调试
- **Cons**: 违反 ADR-0001 组件模式（CollisionComponent 作为实体子节点）；单例成为瓶颈；实体生命周期管理复杂
- **Rejection Reason**: 与 ADR-0001 冲突。保持组件模式，CollisionDebugOverlay 作为唯一 Autoload（只读观察者）

### Alternative B: PhysicsServer2D 直接查询替代 Area2D

- **Description**: 不使用 Area2D 节点，通过 PhysicsServer2D.space_get_direct_state() 手动执行 AABB 查询
- **Pros**: 更高性能（无节点开销）；可批量查询
- **Cons**: 失去编辑器可视化；碰撞层需手动实现；代码复杂度显著增加
- **Rejection Reason**: ADR-0004 已选定 Area2D 方案。本 ADR 在 Area2D 基础上通过空间哈希优化性能，无需切换底层方案

### Alternative C: 自定义碰撞形状（圆形/多边形）

- **Description**: 支持 CircleShape2D 和 ConvexPolygonShape2D 作为 Hitbox/Hurtbox 形状
- **Pros**: 更精确的碰撞形状匹配（圆形适合旋转攻击）
- **Cons**: 调试可视化复杂度增加；矩形 AABB 足够满足 2D ACT 需求；增加数据结构复杂度
- **Rejection Reason**: MVP 阶段矩形足够。HitboxConfig 和调试系统预留扩展接口（`_get_area_global_rect` 改为形状无关的 `_get_area_global_shape`），Phase 2 按需添加

## Consequences

### Positive

- **完整 API 规范**: 消除 ADR-0004 留下的实现歧义，程序员可直接编码
- **数据驱动**: HitboxConfig Resource 使碰撞参数可从数据文件加载，支持热重载和策划配表
- **调试效率**: F4 可视化叠加层大幅提升碰撞框调试效率，减少"砍到了但没伤害"的排查时间
- **多目标正确性**: 明确的多目标处理规则确保范围攻击行为可预测
- **生命周期安全**: 死亡清理保证不存在"死亡实体仍在造成伤害"的 bug
- **性能余量**: 空间哈希预留接口 + 性能监控，确保未来实体数增加时可平滑优化
- **集成清晰**: 与 WeaponComponent / StatusEffectComponent 的契约明确，各组件职责不重叠

### Negative

- **接口扩展**: `activate_hitbox` 从简单参数扩展为 `HitboxConfig` 对象，调用方代码需要适配（兼容重载缓解）
- **调试组件开销**: CollisionDebugOverlay 每帧 `queue_redraw()` + 遍历所有实体，开启时约增加 0.5ms（仅 Debug 构建）
- **数据结构增加**: HitboxConfig Resource 新增一个文件，增加项目文件数量

### Neutral

- **空间哈希未激活**: MVP 阶段不启用空间哈希，代码存在但路径未走——需要后续测试覆盖
- **命中反馈分层**: 碰撞系统触发底层反馈（火花/闪光），表现层触发高级反馈（帧停/震屏）——增加理解成本但职责清晰

## Risks

| Risk | Probability | Impact | Mitigation |
|------|------------|--------|-----------|
| Area2D.get_overlapping_areas() 同帧延迟（ADR-0004 已识别） | MEDIUM | HIGH | `call_deferred` 或下帧检测；新增自动化测试验证同帧激活→检测时序 |
| 碰撞调试覆盖层在大量实体时卡顿 | LOW | MEDIUM | 限制 Debug 构建最大跟踪实体数 = 30；超出时显示 warning |
| HitboxConfig 数据不一致（offset/size 配错） | MEDIUM | MEDIUM | `validate()` 方法拦截异常值；编辑器 Inspector 增加自定义校验提示 |
| 死亡帧碰撞时序竞态 | LOW | HIGH | 文档明确时序规则；编写集成测试验证死亡帧行为 |
| 空间哈希在极端场景下退化（所有实体聚在同一点） | LOW | LOW | 退化为朴素方案（全量查询），不会崩溃；监控 _grid 桶大小 |

## Performance Implications

| Metric | Before (ADR-0004 only) | Expected After | Budget |
|--------|----------------------|----------------|--------|
| CPU — 碰撞检测 (10 entities × 3 hitboxes) | ~3ms (朴素 30 次查询) | ~2.5ms (优化后) | < 3ms |
| CPU — 调试覆盖层 (开启时) | 0ms | ~0.5ms | < 1ms (Debug only) |
| CPU — 命中反馈 (单次命中) | 0ms | ~0.1ms (粒子实例化) | < 0.2ms |
| Memory — HitboxConfig per weapon | 0B | ~200B | N/A |
| Memory — CollisionSpatialHash | 0B | ~1KB (预分配) | < 4KB |
| Load Time | — | +5ms (预加载 flash 纹理) | < 10ms |

## Migration Plan

无需迁移现有代码。本 ADR 扩展 ADR-0004，实施步骤：

1. 创建 `res://src/core/hitbox_config.gd` (class_name HitboxConfig, extends Resource)
2. 创建 `res://src/core/collision_layer.gd` (class_name CollisionLayer, extends RefCounted)
3. 扩展 `res://src/core/collision_component.gd`:
   - 添加 `activate_hitbox(hitbox_id, config: HitboxConfig)` 完整签名
   - 保留 `activate_hitbox(hitbox_id, duration_frames, offset, size)` 便捷重载
   - 添加 `deactivate_all_hitboxes()`
   - 添加 `bind_entity_death()` / `_on_entity_death()`
   - 添加多目标排序逻辑
   - 添加 `_trigger_hit_feedback()`
   - 添加性能计时 (`_last_frame_collision_time_ms`)
4. 创建 `res://src/tools/collision_debug_overlay.gd` (Autoload, Debug only)
5. 在 project.godot 中添加 `debug_toggle_collision` InputMap 动作 (F4)
6. 创建 `res://src/core/collision_spatial_hash.gd` (预留，MVP 不激活)
7. 更新 WeaponComponent / StatusEffectComponent 的调用代码以使用 HitboxConfig

**Rollback plan**: 移除新增文件，恢复 ADR-0004 原始接口。HitboxConfig 兼容重载确保回滚不影响调用方。

## Validation Criteria

- [ ] HitboxConfig.validate() 正确拦截 size < 4×4 和 duration_frames <= 0
- [ ] activate_hitbox(id, config) 正确设置 HitboxArea 位置/形状/层/帧数
- [ ] activate_hitbox 便捷重载行为与完整签名一致
- [ ] 同一 Hitbox 同帧重叠 3 个 Hurtbox → 3 次 on_hit_confirmed（独立 HitEvent）
- [ ] 同一 Hitbox 对同一 Hurtbox 连续 5 帧重叠 → 仅第 1 帧命中
- [ ] 实体死亡后所有活跃 Hitbox 立即停用，Hurtbox 变为不可命中
- [ ] F4 切换调试覆盖层：红色=Hitbox, 绿色=Hurtbox(normal), 蓝色=Hurtbox(shrunk), 黄色虚线=Hurtbox(gone)
- [ ] 碰撞层矩阵正确：player_attack 只命中 enemy_hurt，enemy_attack 只命中 player_hurt
- [ ] 10 实体 × 3 活跃 Hitbox 场景碰撞检测 < 3ms/帧
- [ ] 命中即时反馈（火花 + 闪光）在 hit_position 正确触发
- [ ] WeaponComponent 通过 HitboxConfig 正确激活武器特殊招式碰撞
- [ ] StatusEffectComponent 通过 attack_metadata.attached_effect 正确施加状态效果
- [ ] Release 构建不包含 CollisionDebugOverlay（零开销）
- [ ] 性能计时超 3ms 时输出 push_warning

## GDD Requirements Addressed

| GDD Document | System | Requirement (TR ID) | How This ADR Satisfies It |
|-------------|--------|---------------------|--------------------------|
| collision-detection.md | Collision | TR-collision-001 (帧级检测引擎) | ADR-0004 覆盖 — `_physics_process` 帧级循环 |
| collision-detection.md | Collision | TR-collision-002 (Hitbox 帧级控制) | ADR-0004 覆盖 + 本 ADR 扩展 HitboxConfig 数据结构 |
| collision-detection.md | Collision | TR-collision-003 (Hurtbox 三状态) | ADR-0004 覆盖 — set_hurtbox_state() |
| collision-detection.md | Collision | TR-collision-004 (5 层碰撞分层) | ADR-0004 定义层名称 + 本 ADR 定义精确位掩码值和 CollisionLayer 枚举类 |
| collision-detection.md | Collision | TR-collision-005 (hit_data + mark_hit) | ADR-0004 覆盖 + 本 ADR 完善 attack_metadata 约定字段 |
| collision-detection.md | Collision | TR-collision-006 (多目标范围攻击) | 本 ADR 第 3 节 — 按距离排序 + 独立事件发射 + 去重规则表 |
| collision-detection.md | Collision | TR-collision-007 (死亡自动停用) | 本 ADR 第 4 节 — bind_entity_death + deactivate_all_hitboxes |
| collision-detection.md | Collision | TR-collision-008 (Area2D + 矩形碰撞形状) | 本 ADR 第 6 节 — 精确 Area2D/CollisionShape2D 配置规范 |
| collision-detection.md | Collision | TR-collision-009 (F4 调试可视化) | 本 ADR 第 7 节 — CollisionDebugOverlay Autoload + 颜色编码 |
| feline-combat.md | Combat | 碰撞激活接口 | 本 ADR 第 2 节 — 完整 activate_hitbox 签名 + 兼容重载 |
| weapon-styles.md | Weapon | 武器特殊招式碰撞 | 本 ADR 第 9 节 — HitboxConfig 数据流 + SpecialAttackExecutor 集成模式 |
| status-effects.md | StatusEffect | 命中触发状态效果 | 本 ADR 第 10 节 — attack_metadata 约定字段 + StatusEffectComponent 集成契约 |

## Related

- **ADR-0004**: 碰撞检测基础架构 — 本 ADR 的直接扩展对象
- **ADR-0002**: 信号通信 — on_hit_confirmed 信号 + HitEvent payload 定义
- **ADR-0005**: 战斗状态机 — CombatComponent 调用碰撞接口的上游
- **ADR-0016**: 武器风格 — WeaponComponent 通过 HitboxConfig 传入碰撞参数
- **ADR-0017**: 状态效果 — StatusEffectComponent 消费 on_hit_confirmed + attack_metadata
- `design/gdd/collision-detection.md`: 完整碰撞系统 GDD
- `docs/architecture/tr-registry.yaml`: TR-collision-001 ~ 009 注册表
