# ADR-0007: 场景管理架构

## Summary
定义 SceneManager Autoload 的内部架构：场景注册表、异步加载策略（ResourceLoader + 过渡动画掩盖）、延迟卸载（3秒）、场景状态持久化、快速传送机制。

## Status
Accepted

## Date
2026-06-21

## Engine Compatibility

| Field | Value |
|-------|-------|
| **Engine** | Godot 4.6.3 |
| **Domain** | Core / Scene Management |
| **Knowledge Risk** | LOW — ResourceLoader, SceneTree, PackedScene API stable since 4.0 |
| **References Consulted** | `docs/engine-reference/godot/VERSION.md` |
| **Post-Cutoff APIs Used** | None |
| **Verification Required** | ResourceLoader.load_threaded_request/get_request 在目标平台的异步行为 |

## ADR Dependencies

| Field | Value |
|-------|-------|
| **Depends On** | ADR-0001 (SceneManager 作为 Autoload #5) |
| **Enables** | 所有场景切换逻辑（快速传送、Boss 战场、死亡重生） |
| **Blocks** | SceneManager 实现, 快速传送系统, 死亡重生系统 |
| **Ordering Note** | Foundation/Feature 层最后一个 ADR，完成 P0-P1 全部 7 个 ADR |

## Context

### Problem Statement

scene-management.md GDD 定义了场景管理的需求（异步加载、过渡动画、延迟卸载、状态持久化），但 SceneManager Autoload 的内部架构未定：场景注册表结构、异步加载如何与过渡动画配合、卸载延迟如何实现、场景本地状态如何持久化。

### Constraints

- **ADR-0001**: SceneManager 作为 Autoload #5（最后初始化），负责加载首个场景（hub）
- **内存预算**: 同时驻留场景不超过 2 个（technical-preferences.md: 2GB PC, 1GB mobile）
- **加载时间目标**: <2秒（过渡动画掩盖）
- **Boss 战场锁定**: Boss 战期间禁止场景切换

### Requirements

- 必须支持异步场景加载 + 过渡动画 (TR-scene-001)
- 必须支持延迟卸载（3秒）+ 最多 2 个驻留场景 (TR-scene-002)
- 必须支持场景本地状态持久化（已开启门、已破坏障碍物）
- 必须支持快速传送（已发现存档点之间）
- 必须支持 Boss 战场场景锁定

## Decision

### 场景注册表

```gdscript
# SceneManager.gd (Autoload)

# 从 DataManager 加载场景配置
# data/scene_registry.json:
# {
#   "hub": {"path": "res://scenes/hub/hub.tscn", "type": "hub", "preload": true},
#   "area_01_street": {"path": "res://scenes/areas/street.tscn", "type": "area"},
#   "boss_01_arena": {"path": "res://scenes/bosses/rat_king.tscn", "type": "boss_arena"}
# }

var _scene_registry: Dictionary = {}
var _current_scene_id: StringName = &""
var _current_scene: Node = null
var _cached_scene: Node = null           # 延迟卸载的旧场景
var _cached_scene_id: StringName = &""
var _unload_timer: float = 0.0
var _is_loading: bool = false
var _boss_lock: bool = false            # Boss战锁定场景切换
```

### 异步加载流程

```gdscript
func change_scene(scene_id: StringName, spawn_point: StringName = &"default") -> void:
    if _boss_lock or _is_loading:
        return

    var config: Dictionary = _scene_registry[scene_id]
    _is_loading = true

    # 1. 开始过渡动画（猫武士穿过隧道/门洞，1.5秒）
    _play_transition_animation()

    # 2. 异步加载目标场景
    ResourceLoader.load_threaded_request(config.path)

    # 3. 等待加载完成（在过渡动画期间）
    await _wait_for_load(config.path)

    # 4. 实例化新场景
    var packed: PackedScene = ResourceLoader.load_threaded_get(config.path)
    var new_scene: Node = packed.instantiate()

    # 5. 保存旧场景状态 + 卸载
    _save_scene_state(_current_scene_id)
    _queue_unload(_current_scene, _current_scene_id)

    # 6. 添加新场景
    get_tree().root.add_child(new_scene)
    _current_scene = new_scene
    _current_scene_id = scene_id

    # 7. 恢复场景本地状态
    _restore_scene_state(scene_id)

    # 8. 定位玩家到 spawn_point
    _position_player(spawn_point)

    # 9. 结束过渡动画
    _end_transition_animation()
    _is_loading = false
```

### 延迟卸载

```gdscript
func _queue_unload(scene: Node, scene_id: StringName) -> void:
    # 如果已有缓存场景，立即卸载
    if _cached_scene != null:
        _unload_scene(_cached_scene)
    # 从场景树中摘除（停止 _process/信号），保留引用以便快速返回
    get_tree().root.remove_child(scene)
    _cached_scene = scene
    _cached_scene_id = scene_id
    _unload_timer = 3.0  # 3秒延迟

func _process(delta: float) -> void:
    if _cached_scene != null:
        _unload_timer -= delta
        if _unload_timer <= 0:
            _unload_scene(_cached_scene)
            _cached_scene = null

func _unload_scene(scene: Node) -> void:
    scene.queue_free()
```

### 场景状态持久化

```gdscript
# 每个场景维护本地状态 Dictionary
var _scene_states: Dictionary = {}  # {scene_id: {doors_opened, obstacles_destroyed, ...}}

func _save_scene_state(scene_id: StringName) -> void:
    if _current_scene and _current_scene.has_method(&"get_local_state"):
        _scene_states[scene_id] = _current_scene.get_local_state()

func _restore_scene_state(scene_id: StringName) -> void:
    if _scene_states.has(scene_id) and _current_scene.has_method(&"set_local_state"):
        _current_scene.set_local_state(_scene_states[scene_id])

# ISerializable 接口（SaveSystem 调用）
func serialize() -> Dictionary:
    return {"scene_states": _scene_states, "current_scene_id": _current_scene_id}

func deserialize(data: Dictionary) -> void:
    _scene_states = data.get(&"scene_states", {})
    var saved_scene: StringName = data.get(&"current_scene_id", &"hub")
    await change_scene(saved_scene)  # await 确保场景切换完成后才返回
```

### Boss 战场锁定

```gdscript
func lock_scene() -> void: _boss_lock = true    # Boss战开始时调用
func unlock_scene() -> void: _boss_lock = false  # Boss战结束时调用
```

### Key Interfaces

```gdscript
# SceneManager Autoload 公开接口

func change_scene(scene_id: StringName, spawn_point: StringName = &"default") -> void
func preload_scene(scene_id: StringName) -> void
func get_current_scene() -> StringName
func get_scene_state(scene_id: StringName) -> Dictionary
func set_scene_state(scene_id: StringName, state: Dictionary) -> void
func lock_scene() -> void      # Boss战锁定
func unlock_scene() -> void    # Boss战解锁

# ISerializable
func serialize() -> Dictionary
func deserialize(data: Dictionary) -> void

# 信号
signal on_scene_changed(old_scene: StringName, new_scene: StringName)
signal on_scene_loaded(scene_id: StringName)
```

## Alternatives Considered

### Alternative A: 同步加载 + 黑屏
- **Description**: `get_tree().change_scene_to_file()` 同步加载，黑屏等待
- **Pros**: 实现简单
- **Cons**: 加载期间游戏冻结；黑屏打断沉浸感；大场景加载可能超过 2 秒
- **Rejection Reason**: GDD 要求过渡动画掩盖加载，同步加载无法满足

### Alternative B: 预加载所有场景
- **Description**: 启动时预加载所有场景到内存，切换时直接实例化
- **Pros**: 零加载时间
- **Cons**: 内存占用过高（超出 1GB mobile 预算）；启动时间过长
- **Rejection Reason**: 内存预算限制，不适合多场景银河城

## Consequences

### Positive
- **无感知加载**: 过渡动画掩盖异步加载，玩家感受不到等待
- **快速返回**: 延迟卸载允许 3 秒内返回旧场景无需重新加载
- **状态保持**: 场景本地状态（门、障碍物）在切换后保持
- **Boss 安全**: 锁定机制防止 Boss 战中意外场景切换

### Negative
- **过渡动画时间**: 每次场景切换至少 1.5 秒（过渡动画），频繁切换可能烦躁
- **内存峰值**: 过渡期间同时驻留 2 个场景，内存翻倍
- **异步加载复杂性**: 需要处理加载失败、超时、取消等边缘情况

### Risks
- **ResourceLoader 异步在某些平台不支持**: 部分平台（如 Web）的 `load_threaded_request` 行为可能不同。**缓解**: 回退到同步加载 + 短过渡动画
- **过渡动画期间输入**: 玩家可能在过渡期间按键。**缓解**: 过渡期间禁用所有输入

## GDD Requirements Addressed

| GDD System | Requirement | How This ADR Addresses It |
|------------|-------------|--------------------------|
| scene-management.md | 异步加载 + 过渡动画 (TR-scene-001) | ResourceLoader.load_threaded_request + 过渡动画 |
| scene-management.md | 延迟卸载 + 驻留限制 (TR-scene-002) | _cached_scene + 3秒计时器 |
| death-respawn.md | Boss战重生在战场入口 | lock_scene/unlock_scene + spawn_point |
| exploration-ability-gating.md | 区域解锁触发场景可用 | 场景注册表 type 字段 |

## Performance Implications

- **CPU**: 异步加载在后台线程，主线程开销 <0.1ms/帧。过渡动画 <0.5ms/帧
- **Memory**: 2 场景驻留峰值 ≈ 200MB（PC）/ 100MB（mobile）。延迟卸载期间短暂超出
- **Load Time**: 首次场景加载 <2秒（异步+过渡掩盖）。快速返回（<3秒）零加载
- **Network**: N/A

## Migration Plan

无需迁移。实现步骤：
1. 创建 `res://src/feature/scene_manager.gd`
2. 实现场景注册表（从 DataManager 加载配置）
3. 实现 change_scene() 异步加载流程
4. 创建过渡动画场景（猫武士穿过隧道）
5. 实现延迟卸载机制
6. 实现场景状态持久化（ISerializable）
7. 实现 Boss 锁定机制

## Validation Criteria

- [ ] change_scene() 在过渡动画期间完成异步加载
- [ ] 延迟卸载 3 秒后正确释放旧场景
- [ ] 场景本地状态在切换后正确恢复
- [ ] Boss 锁定期间 change_scene() 被拒绝
- [ ] ISerializable serialize/deserialize 正确保存/恢复场景状态

## Related Decisions

- ADR-0001: SceneManager 作为 Autoload #5
- ADR-0003: DataManager 提供场景配置数据
- `design/gdd/scene-management.md`: 完整 GDD 需求
