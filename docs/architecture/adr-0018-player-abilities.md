# ADR-0018: 玩家能力系统架构

## Summary
定义 AbilityComponent 的实体组件架构：8 种能力的注册表驱动数据结构、每实体独立的 AbilityComponent（挂载在 Player 下）、基于 Dictionary 的冷却管理、空中次数计数器（二段跳落地重置）、技能树 Modifier Provider 集成（能力参数修改）、ExplorationGate 能力门控集成（has_ability 查询 + ability_unlocked 事件广播）、SceneManager 区域解锁事件联动、ISerializable 存档持久化。能力数据从 DataManager 加载配置表，运行时状态由 AbilityComponent 自管理。

## Status
Proposed

## Date
2026-06-22

## Engine Compatibility

| Field | Value |
|-------|-------|
| **Engine** | Godot 4.6.3 |
| **Domain** | Core / Gameplay |
| **Knowledge Risk** | LOW — Timer, Dictionary, signal API stable since 4.0; no post-cutoff APIs required |
| **References Consulted** | `docs/engine-reference/godot/VERSION.md`, `docs/engine-reference/godot/breaking-changes.md` |
| **Post-Cutoff APIs Used** | None |
| **Verification Required** | 验证 `_physics_process` 中冷却递减精度（float 累积误差在 0.3s 短冷却下是否可接受）；验证信号连接到 ExplorationGate（场景级节点）在场景切换时的断连/重连行为 |

## ADR Dependencies

| Field | Value |
|-------|-------|
| **Depends On** | ADR-0001 (AbilityComponent 作为 Player 子节点组件), ADR-0005 (CombatComponent 状态机 — 能力激活需与战斗状态协调), ADR-0007 (SceneManager — 区域解锁事件触发场景可用) |
| **Also Depends On** | ADR-0003 (DataManager — 能力配置表加载), ADR-0008 (SaveSystem — ISerializable 存档接口), ADR-0009 (SkillTreeManager — Modifier Provider 能力修改) |
| **Enables** | 探索与能力门控（ExplorationGate）、HUD 能力图标显示、技能树能力升级 |
| **Blocks** | ExplorationGate 实现, 能力 HUD 实现, Boss 战后解锁动画 |
| **Ordering Note** | Feature 层 ADR，在 Core 层 ADR-0005 之后、探索门控 ADR 之前 |

## Context

### Problem Statement

player-abilities.md GDD 定义了完整的玩家能力系统（8 种能力、解锁条件、冷却管理、空中次数、能力修改器、探索门控），但 AbilityComponent 的内部架构未定：能力数据如何组织（硬编码 vs 配置表）、冷却管理如何实现（Timer vs 帧递减）、空中次数如何与跳跃/落地联动、技能树修改器如何注入能力参数、ExplorationGate 如何查询能力状态、SceneManager 如何响应区域解锁事件、以及能力状态如何持久化到存档。需求追踪矩阵（requirements-traceability.md）标记了 6 个 TR-ability 缺口，本 ADR 一次性覆盖。

### Constraints

- **ADR-0001**: AbilityComponent 挂载在 Player 节点下，非 Autoload。每个实体独立实例
- **ADR-0003**: 能力配置数据从 DataManager 加载（`data/abilities.json`），不硬编码
- **ADR-0005**: CombatComponent 使用 6 状态战斗状态机。能力激活必须与战斗状态协调（如 ATTACKING 状态下某些能力不可用）
- **ADR-0008**: AbilityComponent 必须实现 ISerializable 接口，通过 SaveSystem 注册存档
- **ADR-0009**: SkillTreeManager 提供 Modifier Provider 接口（`get_modifiers(action_id)`），AbilityComponent 在冷却/效果计算时查询修改器
- **帧级精度**: 冷却管理在 `_physics_process` 中递减，保证帧级精度
- **Godot 4.6 Required Types**: 所有接口参数和返回值必须类型安全，nullable 不再隐式允许

### Requirements

- 必须支持 8 种核心能力的注册表驱动配置 (TR-ability-001)
- 必须提供 has_ability/get_unlocked_abilities/is_ability_on_cooldown/unlock_ability/reset_air_abilities 接口 (TR-ability-002)
- 必须支持各能力不同冷却（dodge 0.5s, dash 1.0s, parry 0.3s）+ double_jump 落地重置 (TR-ability-003)
- 必须支持 6 步激活流程：输入→has_ability→冷却→前置条件→激活+事件→冷却开始 (TR-ability-004)
- 必须支持解锁时触发：解锁动画→ability_unlocked 事件→探索门控更新→HUD 通知→存档记录 (TR-ability-005)
- 必须支持技能树通过 Modifier Provider 修改能力参数 (TR-ability-006)

## Decision

### 能力数据结构

能力配置从 `data/abilities.json` 加载（通过 DataManager），运行时状态由 AbilityComponent 内部管理。

```json
// data/abilities.json
{
  "basic_attack": {
    "unlock_condition": "game_start",
    "cooldown_sec": 0.0,
    "cooldown_type": "none",
    "air_count_max": 0,
    "requires_airborne": false,
    "combat_state_blocking": []
  },
  "jump": {
    "unlock_condition": "game_start",
    "cooldown_sec": 0.0,
    "cooldown_type": "none",
    "air_count_max": 0,
    "requires_airborne": false,
    "combat_state_blocking": []
  },
  "dodge": {
    "unlock_condition": "game_start",
    "cooldown_sec": 0.5,
    "cooldown_type": "short",
    "air_count_max": 0,
    "requires_airborne": false,
    "combat_state_blocking": ["HIT_STUN"]
  },
  "dash": {
    "unlock_condition": "boss_01_defeated",
    "unlock_trigger": "boss_defeated",
    "unlock_target": "垃圾桶鼠王",
    "cooldown_sec": 1.0,
    "cooldown_type": "medium",
    "air_count_max": 0,
    "requires_airborne": false,
    "combat_state_blocking": ["HIT_STUN"]
  },
  "double_jump": {
    "unlock_condition": "boss_02_defeated_or_hidden_boss",
    "cooldown_sec": 0.0,
    "cooldown_type": "air_count",
    "air_count_max": 1,
    "requires_airborne": true,
    "combat_state_blocking": []
  },
  "aerial_attack": {
    "unlock_condition": "boss_03_defeated",
    "cooldown_sec": 0.0,
    "cooldown_type": "none",
    "air_count_max": 0,
    "requires_airborne": true,
    "combat_state_blocking": []
  },
  "wall_climb": {
    "unlock_condition": "boss_04_defeated_or_hidden_altar",
    "cooldown_sec": 0.0,
    "cooldown_type": "none",
    "air_count_max": 0,
    "requires_airborne": false,
    "combat_state_blocking": []
  },
  "parry": {
    "unlock_condition": "tutorial",
    "cooldown_sec": 0.3,
    "cooldown_type": "short",
    "air_count_max": 0,
    "requires_airborne": false,
    "combat_state_blocking": ["HIT_STUN", "ATTACKING"]
  }
}
```

**数据结构说明**：

| 字段 | 类型 | 说明 |
|------|------|------|
| `unlock_condition` | String | 解锁条件标识（`game_start` / `boss_XX_defeated` / `tutorial` / 组合条件） |
| `cooldown_sec` | float | 基础冷却时间（秒），可被技能树修改器覆盖 |
| `cooldown_type` | String | `none` / `short` / `medium` / `air_count`（决定冷却管理策略） |
| `air_count_max` | int | 空中最大使用次数（0 = 无限制，仅 `double_jump` 使用） |
| `requires_airborne` | bool | 是否必须空中才能激活 |
| `combat_state_blocking` | Array[StringName] | 不可使用的战斗状态列表（如 HIT_STUN 下所有能力不可用） |

### AbilityComponent 架构

```gdscript
# res://src/core/ability_component.gd
# 挂载在 Player 节点下，每实体独立实例

class_name AbilityComponent
extends Node

# --- 配置数据（从 DataManager 加载） ---
var _ability_configs: Dictionary = {}  # {ability_id: config_dict}

# --- 运行时状态 ---
var _unlocked_abilities: Dictionary = {}  # {ability_id: bool}
var _cooldown_remaining: Dictionary = {}  # {ability_id: float} 秒
var _air_count_used: int = 0              # 当前空中已使用次数
var _is_airborne: bool = false            # 当前是否在空中

# --- 外部引用 ---
var _combat: CombatComponent = null
var _collision: CollisionComponent = null

func _ready() -> void:
    _combat = get_parent().get_node(%"CombatComponent")
    _collision = get_parent().get_node(%"CollisionComponent")
    _load_ability_configs()
    _unlock_initial_abilities()
    SaveSystem.register_serializable(&"abilities", self)

func _load_ability_configs() -> void:
    var domain: DataDomain = DataManager.get_domain(&"abilities")
    for ability_id in domain.get_all_ids():
        _ability_configs[ability_id] = domain.get_entry(ability_id)
        _unlocked_abilities[ability_id] = false
        _cooldown_remaining[ability_id] = 0.0
```

### 冷却管理系统

冷却在 `_physics_process` 中帧级递减，保证精度。`air_count` 类型不使用冷却计时器，而是通过空中次数计数器管理。

```gdscript
func _physics_process(delta: float) -> void:
    # 递减所有活跃冷却
    for ability_id in _cooldown_remaining:
        if _cooldown_remaining[ability_id] > 0.0:
            _cooldown_remaining[ability_id] = max(0.0, _cooldown_remaining[ability_id] - delta)

# 冷却查询（考虑技能树修改器）
func _get_effective_cooldown(ability_id: StringName) -> float:
    var base_cooldown: float = _ability_configs[ability_id].get("cooldown_sec", 0.0)
    # 查询 SkillTreeManager 的修改器
    var modifiers: Array = _get_modifiers_for(ability_id)
    var effective: float = base_cooldown
    for mod in modifiers:
        if mod.get("stat_key", "") == "cooldown":
            effective = _apply_modifier(effective, mod)
    return max(0.0, effective)

# 激活后启动冷却
func _start_cooldown(ability_id: StringName) -> void:
    var cooldown_type: String = _ability_configs[ability_id].get("cooldown_type", "none")
    match cooldown_type:
        "none":
            pass  # 无冷却
        "short", "medium":
            _cooldown_remaining[ability_id] = _get_effective_cooldown(ability_id)
        "air_count":
            _air_count_used += 1  # 空中次数+1，无时间冷却
```

### 空中次数管理（二段跳）

`double_jump` 使用 `air_count` 冷却类型，通过 `_air_count_used` 计数器管理。落地时由外部（PlayerController 或移动组件）调用 `reset_air_abilities()` 重置。

```gdscript
# 落地重置 — 由 PlayerController 在检测到触地时调用
func reset_air_abilities() -> void:
    _air_count_used = 0
    _is_airborne = false

# 起跳时标记 — 由 PlayerController 在检测到离地时调用
func set_airborne(is_in_air: bool) -> void:
    _is_airborne = is_in_air
    if not is_in_air:
        reset_air_abilities()

# 空中次数检查（double_jump 专用）
func _can_use_air_ability() -> bool:
    if not _is_airborne:
        return false  # 地面不可使用空中能力
    var max_count: int = _ability_configs[&"double_jump"].get("air_count_max", 1)
    return _air_count_used < max_count
```

### 能力注册/解锁/查询接口

```gdscript
# === 公开接口 ===

## 检查能力是否已解锁
func has_ability(ability_id: StringName) -> bool:
    return _unlocked_abilities.get(ability_id, false)

## 获取所有已解锁能力 ID 列表
func get_unlocked_abilities() -> Array[StringName]:
    var result: Array[StringName] = []
    for ability_id in _unlocked_abilities:
        if _unlocked_abilities[ability_id]:
            result.append(ability_id)
    return result

## 检查能力是否在冷却中
func is_ability_on_cooldown(ability_id: StringName) -> bool:
    var cooldown_type: String = _ability_configs[ability_id].get("cooldown_type", "none")
    if cooldown_type == "air_count":
        return not _can_use_air_ability()
    return _cooldown_remaining.get(ability_id, 0.0) > 0.0

## 获取冷却剩余时间（秒）
func get_ability_cooldown_remaining(ability_id: StringName) -> float:
    return _cooldown_remaining.get(ability_id, 0.0)

## 解锁能力
func unlock_ability(ability_id: StringName) -> bool:
    if not _ability_configs.has(ability_id):
        return false
    if _unlocked_abilities.get(ability_id, false):
        return false  # 已拥有，忽略（GDD Edge Case）
    _unlocked_abilities[ability_id] = true
    _on_ability_unlocked(ability_id)
    return true

## 激活能力（6步流程）
func try_activate_ability(ability_id: StringName) -> bool:
    # Step 1: 输入（由调用方提供，此处从 InputManager 缓冲获取）
    # Step 2: has_ability 检查
    if not has_ability(ability_id):
        return false
    # Step 3: 冷却检查
    if is_ability_on_cooldown(ability_id):
        return false
    # Step 4: 前置条件检查
    if not _check_prerequisites(ability_id):
        return false
    # Step 5: 激活 + 事件
    _activate(ability_id)
    # Step 6: 开始冷却
    _start_cooldown(ability_id)
    return true

# === 内部方法 ===

func _check_prerequisites(ability_id: StringName) -> bool:
    var config: Dictionary = _ability_configs[ability_id]
    # 空中检查
    if config.get("requires_airborne", false) and not _is_airborne:
        return false
    # 战斗状态检查
    var blocking_states: Array = config.get("combat_state_blocking", [])
    var current_combat_state: CombatComponent.CombatState = _combat.get_current_state()
    if CombatComponent.CombatState.keys()[current_combat_state] in blocking_states:
        return false
    return true

func _activate(ability_id: StringName) -> void:
    ability_activated.emit(ability_id)
    # CombatComponent 监听此信号，执行对应的战斗动作/动画
    # CollisionComponent 由 CombatComponent 协调激活对应 Hitbox

func _on_ability_unlocked(ability_id: StringName) -> void:
    # Step 1: 发射信号（解锁动画、HUD 通知由 Presentation 层监听）
    ability_unlocked.emit(ability_id)
    # Step 2: 探索门控更新（ExplorationGate 监听此信号）
    # — 通过信号解耦，ExplorationGate 在 _ready() 中连接
    # Step 3: SceneManager 区域解锁事件（见下方集成章节）
    area_unlock_triggered.emit(ability_id)
    # Step 4: 存档记录（SaveSystem 在下次 save 时自动序列化）
```

### 能力修改器集成（技能树加成）

AbilityComponent 通过 SkillTreeManager 的 Modifier Provider 接口查询能力修改器。修改器在计算有效冷却时间和效果参数时实时查询（非缓存），确保技能树加点后立即生效。

```gdscript
# 技能树修改器查询
func _get_modifiers_for(ability_id: StringName) -> Array:
    var skill_tree: Node = get_tree().get_first_node_in_group("skill_tree_manager")
    if skill_tree == null or not skill_tree.has_method("get_modifiers"):
        return []
    # action_id 格式: "ability:{ability_id}" — 与技能树节点定义对应
    return skill_tree.get_modifiers(StringName("ability:" + ability_id))

# 修改器应用（支持 ADR-0009 定义的 3 种操作）
func _apply_modifier(base_value: float, modifier: Dictionary) -> float:
    var operation: String = modifier.get("operation", "add_flat")
    var value: float = modifier.get("value", 0.0)
    match operation:
        "add_flat":
            return base_value + value
        "add_percent":
            return base_value * (1.0 + value)
        "multiply":
            return base_value * value
    return base_value

# 可修改的能力参数（由 GDD Tuning Knobs 定义）:
# - cooldown: 冷却时间修改（如：冲刺冷却 -20%）
# - dash_distance: 冲刺距离修改（如：冲刺距离 +25%）
# - parry_window: 弹反窗口修改（如：弹反窗口 +3帧）
# - double_jump_height: 二段跳高度修改（如：二段跳高度 ×0.9）
```

**与 ADR-0009 F8 Combined Bonus 的关系**：能力修改器仅来自技能树（skill modifier），不经过 F8 联合上限计算。F8 上限仅适用于战斗数值（攻击/防御），不影响能力参数（冷却/距离/窗口）。

### 与 ExplorationGate 的集成（能力门控）

ExplorationGate 是场景级组件，通过信号监听 AbilityComponent 的 `ability_unlocked` 和 `ability_activated` 事件，查询 `has_ability()` 更新门状态。

```gdscript
# ExplorationGate._ready() 中连接:
# var player: Node = get_tree().get_first_node_in_group("player")
# var ability_comp: AbilityComponent = player.get_node("AbilityComponent")
# ability_comp.ability_unlocked.connect(_on_ability_unlocked)

# ExplorationGate 查询模式:
func _check_gate_state(gate_ability_id: StringName) -> GateState:
    var player: Node = get_tree().get_first_node_in_group("player")
    var ability_comp: AbilityComponent = player.get_node("AbilityComponent")
    if ability_comp.has_ability(gate_ability_id):
        return GateState.UNLOCKED
    # UNLOCKABLE 状态由其他条件决定（如玩家是否在门附近）
    return GateState.LOCKED

# 能力解锁后自动检查所有已发现的门 (TR-explore-006)
func _on_ability_unlocked(_ability_id: StringName) -> void:
    for gate in _all_gates:
        _update_gate_visual(gate)  # 重新检查门状态并更新视觉
```

**能力门映射表**（来自 GDD exploration-ability-gating.md）：

| 门类型 | 需要能力 | 视觉表现 |
|--------|---------|---------|
| 电栅栏 | dash | 冲刺穿越 |
| 高台 | double_jump | 二段跳到达 |
| 窄缝 | aerial_attack | 下劈破坏 |
| 磁力墙 | wall_climb | 墙壁攀爬通过 |
| 激光网 | parry | 弹反偏转 |

### 与 SceneManager 的集成（区域解锁事件）

能力解锁触发 `area_unlock_triggered` 信号，SceneManager 监听此信号更新场景注册表中的可用状态。快速传送系统查询 SceneManager 判断目标场景是否可达。

```gdscript
# SceneManager 集成:
# SceneManager._ready() 中连接玩家 AbilityComponent:
signal on_area_unlocked(ability_id: StringName)

# 当能力解锁时，SceneManager 更新场景可用性:
func _on_area_unlock_triggered(ability_id: StringName) -> void:
    # 查询场景注册表中依赖该能力的场景
    for scene_id in _scene_registry:
        var config: Dictionary = _scene_registry[scene_id]
        if config.get("requires_ability", "") == ability_id:
            config["accessible"] = true
            # 发射信号供 HUD/地图更新
            on_area_unlocked.emit(ability_id)

# 快速传送查询:
func is_scene_accessibleible(scene_id: StringName) -> bool:
    return _scene_registry.get(scene_id, {}).get("accessible", false)
```

**信号流**:

```
AbilityComponent.unlock_ability()
  → ability_unlocked 信号 → ExplorationGate._on_ability_unlocked() → 更新门视觉
  → ability_unlocked 信号 → HUDManager → 显示解锁通知
  → ability_unlocked 信号 → CombatPresentation → 播放解锁动画
  → area_unlock_triggered 信号 → SceneManager → 更新场景注册表
                              → MapSystem → 更新地图可探索区域
```

### 存档集成

AbilityComponent 实现 ISerializable 接口，在 `_ready()` 时向 SaveSystem 注册。序列化的数据包含已解锁能力集合和运行时冷却状态。

```gdscript
# ISerializable 实现

func get_save_key() -> StringName:
    return &"abilities"

func serialize() -> Dictionary:
    var unlocked: Array[StringName] = []
    for ability_id in _unlocked_abilities:
        if _unlocked_abilities[ability_id]:
            unlocked.append(ability_id)
    return {
        "unlocked": unlocked,
        "version": 1
    }

func deserialize(data: Dictionary, version: int) -> void:
    # 重置所有能力为锁定
    for ability_id in _unlocked_abilities:
        _unlocked_abilities[ability_id] = false
    # 恢复已解锁能力
    var unlocked: Array = data.get("unlocked", [])
    for ability_id in unlocked:
        if _ability_configs.has(ability_id):
            _unlocked_abilities[ability_id] = true
    # 冷却状态不持久化（存档后冷却重置，符合预期）
    for ability_id in _cooldown_remaining:
        _cooldown_remaining[ability_id] = 0.0
    _air_count_used = 0
```

### 信号定义

```gdscript
# AbilityComponent 信号

## 能力解锁时发射（Presentation 层、ExplorationGate、SceneManager 监听）
signal ability_unlocked(ability_id: StringName)

## 能力激活时发射（CombatComponent 监听，执行对应动作）
signal ability_activated(ability_id: StringName)

## 空中状态变更（PlayerController 监听，切换动画/物理）
signal airborne_changed(is_airborne: bool)
```

### Key Interfaces

```gdscript
# AbilityComponent 公开接口（完整清单）

# 查询
func has_ability(ability_id: StringName) -> bool
func get_unlocked_abilities() -> Array[StringName]
func is_ability_on_cooldown(ability_id: StringName) -> bool
func get_ability_cooldown_remaining(ability_id: StringName) -> float

# 操作
func unlock_ability(ability_id: StringName) -> bool
func try_activate_ability(ability_id: StringName) -> bool
func reset_air_abilities() -> void
func set_airborne(is_in_air: bool) -> void

# ISerializable
func get_save_key() -> StringName
func serialize() -> Dictionary
func deserialize(data: Dictionary, version: int) -> void

# 信号
signal ability_unlocked(ability_id: StringName)
signal ability_activated(ability_id: StringName)
signal airborne_changed(is_airborne: bool)
```

### 初始解锁与 Boss 触发

```gdscript
# 游戏开始时的初始解锁
func _unlock_initial_abilities() -> void:
    # GDD 规则：游戏开始拥有 basic_attack, jump, dodge, parry
    unlock_ability(&"basic_attack")
    unlock_ability(&"jump")
    unlock_ability(&"dodge")
    unlock_ability(&"parry")  # 教学关_UNLOCK_

# Boss 击败触发 — 由 BossConfigComponent 死亡事件调用
func on_boss_defeated(boss_id: StringName) -> void:
    match boss_id:
        &"boss_01_rat_king":
            unlock_ability(&"dash")
        &"boss_02":
            unlock_ability(&"double_jump")
        &"boss_03":
            unlock_ability(&"aerial_attack")
        &"boss_04":
            unlock_ability(&"wall_climb")

# 隐藏 Boss / 隐藏祭坛触发 — 由探索系统调用
func on_hidden_discovery(discovery_id: StringName) -> void:
    match discovery_id:
        &"hidden_boss_sewer":
            unlock_ability(&"double_jump")  # 替代路径
        &"hidden_altar_factory":
            unlock_ability(&"wall_climb")   # 替代路径
```

## Alternatives Considered

### Alternative A: Autoload 全局 AbilityManager
- **Description**: 将能力系统作为 Autoload 全局单例，管理所有实体的能力状态
- **Pros**: 全局可访问，ExplorationGate/SceneManager 直接调用 `AbilityManager.has_ability()`
- **Cons**: 违反 ADR-0001 组件化原则；多实体支持复杂（需要 entity_id 查表）；可测试性差（测试需 mock Autoload）；敌人不需要能力系统但被迫共享接口
- **Rejection Reason**: ADR-0001 明确规定 AbilityComponent 作为实体子节点。能力系统是 Player 独有的，不需要全局管理

### Alternative B: 使用 Godot Timer 节点管理冷却
- **Description**: 为每个有冷却的能力创建一个 Timer 子节点，通过 `timeout` 信号重置冷却
- **Pros**: 利用 Godot 原生 Timer 节点，代码量少；自动暂停/恢复随场景
- **Cons**: 每实体 3-4 个 Timer 节点开销；Timer 精度受 `process_callback` 影响（IDLE vs PHYSICS）；不如 `_physics_process` 帧递减精确；难以与技能树修改器动态调整冷却时间
- **Rejection Reason**: 帧级冷却递减（`_physics_process`）精度更高且更灵活，支持技能树实时修改冷却时间

### Alternative C: 能力配置硬编码在 GDScript 中
- **Description**: 将 8 种能力的冷却、解锁条件等直接定义为 `const` 常量
- **Pros**: 最简单；零加载开销；类型安全
- **Cons**: 修改能力参数需要改代码+重新导出；不符合 GDD "游戏值必须数据驱动"（coding-standards.md）；无法支持 Mod 或热更新
- **Rejection Reason**: coding-standards.md 明确要求"Gameplay values must be data-driven (external config), never hardcoded"

## Consequences

### Positive
- **数据驱动**: 能力配置从 JSON 加载，策划可直接调整冷却/解锁条件而不改代码
- **帧级冷却精度**: `_physics_process` 递减保证 0.3s 短冷却（parry）的精确度
- **信号解耦**: ExplorationGate/HUD/SceneManager 通过信号监听，AbilityComponent 不直接引用外部系统
- **技能树实时生效**: 每次冷却计算都查询 Modifier Provider，技能树加点立即影响能力参数
- **存档自动集成**: ISerializable 注册后 SaveSystem 自动处理序列化，无需手动干预
- **可测试性**: 作为独立组件，GdUnit4 可直接实例化测试，无需完整场景树

### Negative
- **信号连接复杂度**: `ability_unlocked` 信号需要多个系统监听（ExplorationGate、HUD、SceneManager、CombatPresentation），连接管理分散
- **每帧冷却递减**: 8 个能力的冷却在 `_physics_process` 中每帧递减，虽然开销极低但非零
- **空中状态外部驱动**: `set_airborne()`/`reset_air_abilities()` 需要 PlayerController 正确调用，调用遗漏会导致二段跳状态异常
- **战斗状态耦合**: `try_activate_ability()` 需要查询 CombatComponent 的当前状态，增加了组件间依赖

### Risks
- **场景切换时信号断连**: ExplorationGate 是场景级节点，场景切换后需要重新连接 AbilityComponent 的信号。**缓解**: ExplorationGate 在 `_ready()` 中通过 `get_tree().get_first_node_in_group("player")` 获取引用并连接；Player 使用 `group` 而非硬编码路径，场景切换后自动找到
- **float 冷却精度累积误差**: `_physics_process` 中 float 递减在长时间运行后可能累积误差（如 0.5s 冷却实际 0.5001s 结束）。**缓解**: 使用 `max(0.0, ...)` 防止负值；0.001s 误差对玩家感知无影响
- **Godot 4.6 Required Types**: `Array[StringName]` 泛型在 Godot 4.6 中需要严格类型。**缓解**: 所有接口使用强类型，避免 Variant 数组
- **技能树引用失败**: `get_tree().get_first_node_in_group("skill_tree_manager")` 在 SkillTreeManager 未加载时返回 null。**缓解**: null 检查 + 空数组降级（无修改器时使用基础值）

## GDD Requirements Addressed

| GDD System | Requirement (TR-ID) | How This ADR Addresses It |
|------------|-------------|--------------------------|
| player-abilities.md | 8种能力注册表 (TR-ability-001) | `data/abilities.json` 配置表 + `_ability_configs` Dictionary |
| player-abilities.md | 能力查询接口 (TR-ability-002) | `has_ability()` / `get_unlocked_abilities()` / `is_ability_on_cooldown()` / `unlock_ability()` / `reset_air_abilities()` |
| player-abilities.md | 冷却管理 (TR-ability-003) | `_physics_process` 帧递减 + `cooldown_type` 分策略（none/short/medium/air_count） |
| player-abilities.md | 6步激活流程 (TR-ability-004) | `try_activate_ability()` 按序执行：输入→has_ability→冷却→前置条件→激活+事件→冷却开始 |
| player-abilities.md | 解锁触发链 (TR-ability-005) | `_on_ability_unlocked()` 发射 `ability_unlocked` 信号 → ExplorationGate/HUD/SceneManager 各自监听 |
| player-abilities.md | 技能树修改器 (TR-ability-006) | `_get_modifiers_for()` 查询 SkillTreeManager Modifier Provider + `_apply_modifier()` 支持 3 种操作 |
| exploration-ability-gating.md | 能力门 3 状态 | ExplorationGate 调用 `has_ability()` 决定 LOCKED/UNLOCKED |
| exploration-ability-gating.md | 解锁后自动检查门 (TR-explore-006) | `ability_unlocked` 信号 → ExplorationGate 遍历所有门更新视觉 |
| scene-management.md | 区域解锁触发场景可用 | `area_unlock_triggered` 信号 → SceneManager 更新场景注册表 |

## Performance Implications

- **CPU**: `_physics_process` 冷却递减 8 次 Dictionary 查找 + float 运算 <0.01ms/帧。`try_activate_ability()` 仅在输入触发时执行（~0.02ms）。Modifier Provider 查询按需在激活时执行（~0.01ms/次）
- **Memory**: AbilityComponent 实例 ~2KB（2 个 Dictionary × 8 条目 + 状态变量）。`data/abilities.json` 配置 <1KB
- **Load Time**: DataManager 加载 `abilities.json` 域 <1ms（文件极小）
- **Network**: N/A（单人游戏）

## Migration Plan

无需迁移。实现步骤：
1. 创建 `res://data/abilities.json` 能力配置表（8 种能力）
2. 创建 `res://src/core/ability_component.gd`（AbilityComponent 脚本）
3. 在 Player 场景中添加 AbilityComponent 子节点
4. 实现 `_load_ability_configs()` 从 DataManager 加载配置
5. 实现 `_physics_process()` 冷却递减循环
6. 实现公开接口（has_ability, unlock_ability, try_activate_ability 等）
7. 实现空中次数管理（reset_air_abilities, set_airborne）
8. 实现 ISerializable 接口（serialize, deserialize）
9. 连接 CombatComponent 信号（战斗状态查询）
10. ExplorationGate 连接 `ability_unlocked` 信号
11. SceneManager 连接 `area_unlock_triggered` 信号
12. HUD 连接 `ability_unlocked` / `ability_activated` 信号（图标显示）

## Validation Criteria

- [ ] 游戏开始时自动解锁 basic_attack, jump, dodge, parry（4 种初始能力）
- [ ] `has_ability("dash")` 在击败垃圾桶鼠王前返回 false，击败后返回 true
- [ ] dodge 冷却精确 0.5s（±1帧 @60fps），dash 冷却精确 1.0s，parry 冷却精确 0.3s
- [ ] 冷却中输入被正确拒绝（`try_activate_ability()` 返回 false）
- [ ] double_jump 空中可使用 1 次，再次使用被拒绝，落地后重置
- [ ] double_jump 在地面使用被拒绝（`requires_airborne = true`）
- [ ] HIT_STUN 状态下所有能力激活被拒绝
- [ ] 技能树修改 dash 冷却 -20% 后，dash 冷却从 1.0s 变为 0.8s
- [ ] `ability_unlocked` 信号在解锁时正确发射，ExplorationGate 响应更新门状态
- [ ] ISerializable serialize/deserialize 正确保存/恢复已解锁能力集合
- [ ] 场景切换后 AbilityComponent 信号正确重连（ExplorationGate 在 `_ready()` 中连接）
- [ ] 空中死亡后 `_air_count_used` 重置为 0

## Related Decisions

- ADR-0001: AbilityComponent 作为 Player 子节点组件
- ADR-0003: DataManager 提供能力配置数据（`abilities.json` 域）
- ADR-0005: CombatComponent 战斗状态机 — AbilityComponent 查询 `get_current_state()` 判断前置条件
- ADR-0007: SceneManager 场景注册表 — 能力解锁更新场景可用性
- ADR-0008: ISerializable 接口 — 能力状态持久化
- ADR-0009: SkillTreeManager Modifier Provider — 能力参数修改
- `design/gdd/player-abilities.md`: 完整 GDD 需求
- `design/gdd/exploration-ability-gating.md`: 探索门控 GDD 需求
