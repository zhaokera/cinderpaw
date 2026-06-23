# ADR-0021: 存档系统完整架构

## Summary

定义 SaveSystem Autoload 的完整内部架构：完整的 JSON 存档数据格式、4 槽位管理（槽位 0 自动存档 + 槽位 1–3 手动存档）、写入前 .bak 备份机制、基于 CURRENT_SAVE_VERSION 的链式版本迁移、Thread 异步写入避免帧率卡顿、JSON 解析失败时自动回退 .bak 的数据完整性保障、ISerializable 注册表的有序序列化/反序列化、存档触发点与加载流程的完整管道、以及与 DataManager 的集成方式。补全 TR-save-002～007 的全部 6 个架构缺口。

## Status

Proposed

## Date

2026-06-22

## Engine Compatibility

| Field | Value |
|-------|-------|
| **Engine** | Godot 4.6.3 |
| **Domain** | Feature / Persistence / GDScript |
| **Knowledge Risk** | MEDIUM — `Thread` 用于异步写入（稳定 API），`WorkerThreadPool` 为备选方案（4.4+ 优化） |
| **References Consulted** | `docs/engine-reference/godot/VERSION.md`, `docs/engine-reference/godot/breaking-changes.md`, `docs/engine-reference/godot/current-best-practices.md` |
| **Post-Cutoff APIs Used** | 无 — Thread/FileAccess/JSON API 自 4.0 稳定；4.4 FileAccess.store_string() 返回 bool（已纳入） |
| **Verification Required** | 验证 Thread 异步写入在 Web 导出时的兼容性（Web 不支持 Thread，需 fallback 到 call_deferred）；验证 `FileAccess.get_length()` 在目标平台上正确报告文件大小 |

## ADR Dependencies

| Field | Value |
|-------|-------|
| **Depends On** | ADR-0001 (Autoload架构 — SaveSystem 作为 Autoload #4), ADR-0008 (ISerializable 接口模式), ADR-0003 (数据管理架构 — DataManager 集成) |
| **Enables** | 所有需要持久化的系统（Health, Combat, Weapon, Ability, SkillTree, Charm, Exploration, NPC, Scene）, ADR-0007 (场景管理 — 加载时恢复场景) |
| **Blocks** | 存档功能完整实现 |
| **Ordering Note** | 本 ADR 是 ADR-0008 的深化补充。ADR-0008 定义了 ISerializable 接口契约和本 ADR 的高层槽位/备份/迁移策略；本 ADR 补全完整 JSON 格式、异步写入管道、数据完整性验证、DataManager 集成等实现级细节 |

## Context

### Problem Statement

ADR-0008 定义了存档序列化的高层模式（ISerializable 接口、JSON 格式、槽位结构、备份和迁移的概念）。但以下关键实现细节未定义：

1. **完整 JSON 数据结构** — 存档文件的完整 schema（`_meta`、`player_state`、`world_state`、`settings`、各 ISerializable 系统数据的嵌套结构）
2. **槽位管理细节** — 3 手动 + 1 自动的具体规则、槽位 0 不可手动覆盖的强制执行、槽位信息元数据的维护
3. **备份机制实现** — 写入前如何复制旧文件、.bak 文件的生命周期、多级备份策略
4. **版本迁移管道** — `CURRENT_SAVE_VERSION` 常量管理、`_migrate_save_data` 的链式调用流程、迁移失败处理
5. **异步写入** — 如何在主线程之外执行文件 I/O 以避免帧率卡顿（< 100ms 要求）
6. **数据完整性** — JSON 解析失败时的 .bak 回退策略、写入校验、损坏检测
7. **ISerializable 注册表** — 注册顺序的约束、`get_save_key()` 的命名规范、反序列化时的依赖排序
8. **存档触发点** — 自动存档、手动存档、场景切换存档的具体触发时机和调用链
9. **加载流程** — 从文件读取到场景恢复的完整管道
10. **DataManager 集成** — 存档相关配置（槽位数、自动存档间隔等）从 DataManager 读取

### Constraints

- **ADR-0001**: SaveSystem 是 Feature 层 Autoload #4，可访问 DataManager（Foundation 层）但不被 Core 层引用
- **ADR-0002**: SaveSystem 的信号使用 `on_` 前缀命名约定
- **ADR-0008**: ISerializable 接口契约已定（`serialize() → Dictionary`，`deserialize(data, version) → void`）
- **ADR-0003**: 存档相关配置（槽位数、自动存档间隔、最大存档大小等）作为 TuningKnob 注册在 DataManager
- **性能**: 存档操作 < 100ms，不阻塞游戏主线程（TR-save-007）
- **安全性**: 防止存档损坏导致进度丢失（TR-save-004）
- **可测试性**: 序列化/反序列化逻辑可独立单元测试（coding-standards.md）
- **Godot 4.6 Required Types**: 所有接口参数和返回值必须强类型
- **跨平台**: Thread 在 Web 导出不可用，需要 fallback 策略

### Requirements

- 必须定义完整的存档 JSON 数据结构 (TR-save-002)
- 必须实现 3 手动 + 1 自动槽位管理，槽位 0 不可手动覆盖 (TR-save-003)
- 必须实现写入前 .bak 备份机制 (TR-save-004)
- 必须实现存档版本迁移管道 (TR-save-005)
- 必须实现 4 种存档触发条件 (TR-save-006)
- 必须保证存档操作不阻塞游戏（< 100ms）(TR-save-007)
- 必须保证 ISerializable 接口的完整协调 (TR-save-001)

## Decision

### 1. 完整 JSON 数据结构

存档文件的完整 JSON schema 如下：

```json
{
  "_meta": {
    "version": 1,
    "timestamp": "2026-06-22T14:30:00Z",
    "play_time_sec": 3600.5,
    "slot": 0,
    "save_point_name": "猫族据点",
    "engine_version": "4.6.3"
  },
  "player_state": {
    "position": {"x": 128.0, "y": 256.0},
    "scene_id": "hub_village",
    "facing": 1,
    "current_hp": 80,
    "max_hp": 100,
    "current_weapon": "cat_claw",
    "weapon_levels": {
      "cat_claw": 3,
      "long_tail": 1
    },
    "unlocked_abilities": ["double_jump", "dash"],
    "currency": 1500
  },
  "world_state": {
    "defeated_bosses": ["forest_guardian"],
    "unlocked_areas": ["hub_village", "whisker_forest"],
    "discovered_save_points": ["sp_hub", "sp_forest_01"],
    "quest_progress": {
      "main_quest_01": {"stage": 2, "flags": {"talked_to_elder": true}}
    },
    "interactable_states": {
      "chest_001": {"opened": true},
      "breakable_042": {"destroyed": false}
    }
  },
  "settings": {
    "input_bindings": {},
    "audio_volumes": {"master": 80, "sfx": 100, "music": 70},
    "display_settings": {"fullscreen": false, "vsync": true}
  },
  "systems": {
    "health": {
      "current_hp": 80,
      "max_hp": 100,
      "shield_hp": 0
    },
    "combat": {
      "combo_count": 0,
      "cat_energy": 50,
      "focus_mode_active": false
    },
    "weapon": {
      "current_style": "cat_claw",
      "levels": {"cat_claw": 3, "long_tail": 1},
      "experience": {"cat_claw": 450}
    },
    "ability": {
      "unlocked": ["double_jump", "dash"],
      "cooldowns": {}
    },
    "skill_tree": {
      "spent_sp": 5,
      "unlocked_nodes": ["node_001", "node_003"]
    },
    "charm": {
      "equipped": ["charm_lucky", "charm_swift"],
      "inventory": ["charm_lucky", "charm_swift", "charm_power"]
    },
    "exploration": {
      "discovered_areas": ["hub_village", "whisker_forest"],
      "discovered_save_points": ["sp_hub", "sp_forest_01"],
      "map_revealed": {"whisker_forest": 0.6}
    },
    "npc": {
      "dialogue_states": {"npc_elder": {"met": true, "quest_stage": 2}},
      "merchant_inventory": {}
    },
    "scene": {
      "current_scene": "hub_village",
      "spawn_point": "save_point_01"
    }
  }
}
```

**结构规则**：

| 顶层字段 | 职责 | 来源 |
|---------|------|------|
| `_meta` | 存档元信息（版本、时间戳、游玩时间、槽位号、存档点名称、引擎版本） | SaveSystem 自身维护 |
| `player_state` | 玩家核心状态快照（位置、HP、武器、能力、货币） | SaveSystem 直接收集（非 ISerializable） |
| `world_state` | 世界状态快照（Boss 击败、区域解锁、存档点发现、任务进度、交互物状态） | WorldStateManager（非 ISerializable） |
| `settings` | 玩家设置（输入绑定、音量、显示设置） | SettingsManager（非 ISerializable，跨槽位共享） |
| `systems` | 各 ISerializable 系统的序列化数据，key 为 `get_save_key()` 返回值 | 各 ISerializable 系统 |

**大小约束**：
- 单存档不超过 `max_save_size_kb`（默认 100KB，DataManager TuningKnob）
- `systems` 子字典的 key 集合必须与 `_serializables` 注册表一一对应
- `settings` 字段在加载时覆盖当前设置，不影响其他槽位的设置

### 2. 槽位管理

#### 槽位结构

```
user://saves/
├── slot_0.json          # 自动存档（auto_save，不可手动覆盖）
├── slot_0.json.bak      # 自动存档备份
├── slot_1.json          # 手动存档槽位 1
├── slot_1.json.bak      # 手动存档备份
├── slot_2.json          # 手动存档槽位 2
├── slot_2.json.bak      # 手动存档备份
├── slot_3.json          # 手动存档槽位 3
└── slot_3.json.bak      # 手动存档备份
```

#### 槽位规则

| 规则 | 说明 |
|------|------|
| 槽位 0 = 自动存档 | 到达存档点、Boss 击败、关键事件后自动写入。**不可通过手动存档覆盖** |
| 槽位 1–3 = 手动存档 | 玩家在暂停菜单中手动触发。可被覆盖 |
| 槽位 0 保护 | `save_game(slot=0)` 仅由内部自动触发调用。外部调用 `save_game(slot=0)` 返回 `false` + ERROR 日志 |
| 槽位范围校验 | `save_game(slot)` / `load_game(slot)` 的 slot 参数必须 ∈ [0, 3]，越界返回 `false` |
| 手动存档覆盖 | 3 个手动槽位已满时，玩家选择覆盖某个槽位。SaveSystem 不自动选择最旧槽位 |
| 死亡重生 | 死亡后加载 slot_0（自动存档），不使用手动存档 |

#### 槽位信息 (SaveInfo)

```gdscript
class_name SaveInfo
extends RefCounted

## 槽位号（0-3）
var slot: int
## 是否为自动存档槽位
var is_auto: bool:
    get: return slot == 0
## 存档是否存在
var exists: bool
## 存档时间戳（ISO 8601）
var timestamp: String
## 游玩时间（秒）
var play_time_sec: float
## 存档点名称
var save_point_name: String
## 存档版本
var version: int
## 玩家等级/状态摘要（用于 UI 显示）
var summary: Dictionary
## 文件大小（字节）
var file_size_bytes: int

func _init(p_slot: int) -> void:
    slot = p_slot
    exists = false
```

`get_save_info(slot) → SaveInfo` 读取 `_meta` 字段填充 SaveInfo，文件不存在则返回 `exists = false` 的空对象。

### 3. 备份机制

#### 写入前备份流程

```
save_game(slot):
  1. 序列化所有数据 → save_data: Dictionary
  2. 检查 user://saves/slot_{N}.json 是否存在
  3. 如果存在:
     a. 读取旧文件内容 → old_content: String
     b. 写入 user://saves/slot_{N}.json.bak = old_content
     c. 验证 .bak 文件写入成功（读取并比较长度）
  4. 将 save_data 序列化为 JSON → json_string: String
  5. 验证 json_string.length() / 1024 < max_save_size_kb
  6. 写入 user://saves/slot_{N}.json = json_string
  7. 验证写入成功（读取 JSON 并解析，比较关键 hash）
```

#### 备份规则

| 规则 | 说明 |
|------|------|
| 单备份 | 每个槽位仅保留 1 个 .bak 文件（写入前复制旧主文件） |
| .bak 生命周期 | 每次写入新存档前，旧主文件 → .bak。旧 .bak 被覆盖 |
| .bak 创建时机 | 仅当主文件存在且非空时创建 .bak |
| 首次写入 | 槽位首次写入无旧文件，不创建 .bak |
| 备份大小校验 | .bak 写入后校验文件大小 ≥ 原文件大小的 90%（防止截断） |

#### 恢复流程

```
load_game(slot):
  1. 尝试读取 user://saves/slot_{N}.json
  2. JSON 解析:
     - 成功 → 继续正常加载流程
     - 失败 → 进入备份恢复
  3. 备份恢复:
     a. 读取 user://saves/slot_{N}.json.bak
     b. JSON 解析:
        - 成功 → 使用备份数据加载 + 发射 on_save_corrupted(slot) 信号
        - 失败 → 发射 on_save_load_failed(slot) 信号，返回 false
  4. 无 .bak 文件 → 直接发射 on_save_load_failed(slot)，返回 false
```

### 4. 版本迁移

#### 版本常量

```gdscript
## 当前存档格式版本号。
## 每次存档数据结构变更时递增。
## 版本号为 int（非 MAJOR.MINOR），简化迁移逻辑。
const CURRENT_SAVE_VERSION: int = 1
```

**版本递增规则**：
- 新增字段（有默认值）→ 递增版本号
- 删除字段 → 递增版本号
- 字段类型变更 → 递增版本号
- 仅修复 bug（不改数据结构）→ 不递增

#### 迁移管道

```gdscript
## 迁移注册表：version → 迁移函数
## key 是 "from_version"，value 是迁移 Callable
## 迁移函数签名: func(data: Dictionary) -> Dictionary
var _migrations: Dictionary = {
    # 示例：
    # 1: _migrate_v1_to_v2,
    # 2: _migrate_v2_to_v3,
}

func _migrate_save_data(data: Dictionary, from_version: int) -> Dictionary:
    var current: Dictionary = data.duplicate(true)
    var version: int = from_version

    while version < CURRENT_SAVE_VERSION:
        if version in _migrations:
            current = _migrations[version].call(current)
            version += 1
        else:
            push_error("SaveSystem: 缺失迁移函数 v%d → v%d" % [version, version + 1])
            return {}  # 迁移失败

    current["_meta"]["version"] = CURRENT_SAVE_VERSION
    return current
```

#### 迁移规则

| 规则 | 说明 |
|------|------|
| 链式迁移 | 从存档版本逐步迁移到 CURRENT_SAVE_VERSION，每步一个函数 |
| 迁移函数只处理增量 | 每个函数只修改版本间差异的字段，不重写整个结构 |
| 缺失迁移函数 = 加载失败 | 如果链中任何一步缺失，返回空 Dictionary → 加载失败 |
| 向下不兼容 | 存档版本 > CURRENT_SAVE_VERSION → 拒绝加载（未来版本存档不能在旧版本加载） |
| 各系统参与迁移 | SaveSystem 调用 `_migrate_save_data` 后，将迁移后的 `systems` 子字典传递给各 ISerializable 的 `deserialize()`，`version` 参数传原始版本号 |
| 迁移后写入 | 迁移成功后，立即触发一次 `save_game()` 将迁移后的数据写回磁盘 |

#### 迁移示例

```gdscript
# 假设 CURRENT_SAVE_VERSION 从 1 升级到 2，新增了 "focus_mode_active" 字段
func _migrate_v1_to_v2(data: Dictionary) -> Dictionary:
    # 为 combat 系统添加新字段（默认值 false）
    if "systems" in data and "combat" in data["systems"]:
        if not "focus_mode_active" in data["systems"]["combat"]:
            data["systems"]["combat"]["focus_mode_active"] = false
    return data
```

### 5. 异步写入

#### 架构选择：Thread + Mutex

```gdscript
var _write_thread: Thread
var _write_mutex: Mutex = Mutex.new()
var _write_pending: bool = false
var _write_result: Dictionary = {}  # {"success": bool, "error": String}

func _write_json_async(json_string: String, file_path: String) -> bool:
    if _write_pending:
        push_warning("SaveSystem: 上一次写入尚未完成，跳过本次写入")
        return false

    _write_mutex.lock()
    _write_pending = true
    _write_mutex.unlock()

    _write_thread = Thread.new()
    var error: int = _write_thread.start(
        _write_thread_func.bind(json_string, file_path)
    )
    if error != OK:
        push_error("SaveSystem: 无法启动写入线程，错误码: %d" % error)
        _write_pending = false
        return false

    return true

func _write_thread_func(json_string: String, file_path: String) -> void:
    var file: FileAccess = FileAccess.open(file_path, FileAccess.WRITE)
    if file == null:
        _write_mutex.lock()
        _write_result = {
            "success": false,
            "error": "FileAccess.open failed: %s" % file_path
        }
        _write_pending = false
        _write_mutex.unlock()
        return

    file.store_string(json_string)
    file.close()

    _write_mutex.lock()
    _write_result = {"success": true, "error": ""}
    _write_pending = false
    _write_mutex.unlock()
```

#### 写入完成回调

```gdscript
# 在主线程 _process() 中轮询写入状态
func _process(_delta: float) -> void:
    if _write_pending:
        _write_mutex.lock()
        var done: bool = not _write_pending
        _write_mutex.unlock()

        if done:
            if _write_result["success"]:
                _on_write_completed(true)
            else:
                _on_write_completed(false, _write_result["error"])
```

#### 异步写入规则

| 规则 | 说明 |
|------|------|
| 单写入锁 | 同一时间只允许一个异步写入操作。写入中触发新写入 → 跳过 + WARNING |
| 主线程回调 | Thread 完成后，主线程 `_process()` 检测并处理结果 |
| Web fallback | Web 导出不支持 Thread，使用 `call_deferred("_write_json_sync", ...)` 替代 |
| 加载不异步 | 加载操作在主线程同步执行（加载时显示过渡画面，不需要异步） |
| 线程安全 | Mutex 保护 `_write_pending` 和 `_write_result`，避免数据竞争 |

#### Web 导出 Fallback

```gdscript
func _is_web_export() -> bool:
    return OS.has_feature("web")

func _write_json_dispatch(json_string: String, file_path: String) -> bool:
    if _is_web_export():
        # Web 不支持 Thread，使用 call_deferred 避免单帧卡顿
        call_deferred("_write_json_sync", json_string, file_path)
        return true
    else:
        return _write_json_async(json_string, file_path)
```

### 6. 数据完整性

#### 完整性校验层次

```
Level 1: FileAccess 存在性检查
  └─ user://saves/slot_{N}.json 是否存在？

Level 2: JSON 解析验证
  └─ JSON.parse_string() 是否成功？
  └─ 解析结果是否为 Dictionary？

Level 3: 结构完整性检查
  └─ 是否包含 "_meta" 字段？
  └─ "_meta" 是否包含 "version"？
  └─ "version" 是否为合法 int？
  └─ "version" ≤ CURRENT_SAVE_VERSION？

Level 4: .bak 回退
  └─ Level 2 或 3 失败 → 尝试加载 .bak
  └─ .bak 同样失败 → 存档不可恢复

Level 5: 写入后验证
  └─ 写入后重新读取文件，验证 JSON 可解析
  └─ 写入后验证文件大小在合理范围内（> 100 bytes, < max_save_size_kb）
```

#### 完整性检查代码

```gdscript
func _validate_save_structure(data: Dictionary) -> bool:
    if not "_meta" in data:
        push_error("SaveSystem: 存档缺少 _meta 字段")
        return false
    var meta: Dictionary = data["_meta"]
    if not "version" in meta:
        push_error("SaveSystem: 存档 _meta 缺少 version 字段")
        return false
    if not meta["version"] is int:
        push_error("SaveSystem: 存档 version 不是 int 类型")
        return false
    if meta["version"] > CURRENT_SAVE_VERSION:
        push_error("SaveSystem: 存档版本 %d > 当前版本 %d，无法加载" % [
            meta["version"], CURRENT_SAVE_VERSION])
        return false
    return true
```

#### 损坏处理流程

```
load_game(slot) →
  main_data = _read_and_parse(slot)
  if main_data == null:
    backup_data = _read_and_parse_backup(slot)
    if backup_data != null:
      emit on_save_corrupted(slot, "主文件损坏，已使用备份恢复")
      return _deserialize_and_load(backup_data)
    else:
      emit on_save_load_failed(slot, "主文件和备份均损坏")
      return false
  else:
    if not _validate_save_structure(main_data):
      # 结构不完整，尝试备份
      backup_data = _read_and_parse_backup(slot)
      if backup_data != null and _validate_save_structure(backup_data):
        emit on_save_corrupted(slot, "主文件结构不完整，已使用备份恢复")
        return _deserialize_and_load(backup_data)
      else:
        emit on_save_load_failed(slot, "存档数据不可恢复")
        return false
    return _deserialize_and_load(main_data)
```

### 7. ISerializable 注册表

#### 注册机制

```gdscript
## 已注册的 ISerializable 系统列表。
## 注册顺序决定序列化/反序列化顺序。
var _serializables: Array[Dictionary] = []
# 每个元素: {"key": StringName, "system": ISerializable}

func register_serializable(system: ISerializable, save_key: StringName) -> void:
    # 去重检查
    for entry in _serializables:
        if entry["key"] == save_key:
            push_error("SaveSystem: save_key '%s' 重复注册" % save_key)
            return
    _serializables.append({"key": save_key, "system": system})

func unregister_serializable(save_key: StringName) -> void:
    for i in range(_serializables.size()):
        if _serializables[i]["key"] == save_key:
            _serializables.remove_at(i)
            return
```

#### 注册顺序约束

| 优先级 | 系统 | save_key | 原因 |
|--------|------|----------|------|
| 1 | HealthComponent (Player) | `"health"` | HP 状态影响其他系统渲染 |
| 2 | CombatComponent (Player) | `"combat"` | 战斗状态依赖 HP |
| 3 | WeaponStyleComponent | `"weapon"` | 武器等级影响战斗 |
| 4 | AbilityComponent | `"ability"` | 能力解锁影响探索 |
| 5 | SkillTreeManager | `"skill_tree"` | 技能点分配 |
| 6 | CharmEquipment | `"charm"` | 护符装备状态 |
| 7 | ExplorationGate | `"exploration"` | 区域解锁依赖能力 |
| 8 | NPCDialogue | `"npc"` | NPC 状态依赖任务进度 |
| 9 | SceneManager | `"scene"` | 场景状态最后恢复 |

**规则**：
- 各系统在其所在场景的 `_ready()` 中调用 `register_serializable`
- SaveSystem 按 `_serializables` 数组顺序执行 `serialize()` 和 `deserialize()`
- 如果系统 A 的 `deserialize()` 依赖系统 B 已恢复的状态，B 必须在 A 之前注册
- SceneManager 始终最后注册（场景恢复在所有系统状态恢复之后）

#### 序列化管道

```gdscript
func _serialize_all() -> Dictionary:
    var systems_data: Dictionary = {}
    for entry in _serializables:
        var key: StringName = entry["key"]
        var system: ISerializable = entry["system"]
        if is_instance_valid(system):
            systems_data[key] = system.serialize()
        else:
            push_warning("SaveSystem: ISerializable '%s' 实例无效，跳过" % key)
    return systems_data

func _deserialize_all(systems_data: Dictionary, version: int) -> void:
    for entry in _serializables:
        var key: StringName = entry["key"]
        var system: ISerializable = entry["system"]
        if is_instance_valid(system):
            if key in systems_data:
                system.deserialize(systems_data[key], version)
            else:
                push_warning("SaveSystem: 存档数据中缺少 '%s'，使用默认状态" % key)
        else:
            push_warning("SaveSystem: ISerializable '%s' 实例无效，跳过" % key)
```

### 8. 存档触发点

#### 触发类型

| 触发类型 | 触发时机 | 槽位 | 调用方 |
|---------|---------|------|--------|
| **存档点自动存档** | 玩家到达存档点（猫族据点/猫窝） | slot 0 | SavePointArea (Area2D body_entered) |
| **Boss 击败自动存档** | Boss HP 降至 0 | slot 0 | BossHealthComponent (signal on_boss_defeated) |
| **关键事件自动存档** | 获得新能力、完成重要任务 | slot 0 | AbilityComponent / QuestManager (signal) |
| **手动存档** | 暂停菜单 → "保存游戏" | slot 1-3 (玩家选择) | PauseMenu UI (button_pressed) |
| **场景切换自动存档** | 通过 SceneManager 切换场景前 | slot 0 | SceneManager.change_scene() 内部调用 |

#### 手动存档限制

```gdscript
func save_game(slot: int = 0) -> bool:
    if slot == 0:
        push_error("SaveSystem: 槽位 0 为自动存档，不可手动写入")
        return false
    if slot < 0 or slot > _get_max_slot():
        push_error("SaveSystem: 槽位 %d 超出范围 [0, %d]" % [slot, _get_max_slot()])
        return false
    return _execute_save(slot)
```

#### 自动存档内部调用

```gdscript
## 内部自动存档，绕过手动存档的槽位限制。
func _auto_save() -> bool:
    return _execute_save(0)

# 存档触发信号连接示例（在各系统初始化时）:
# SavePointArea.body_entered.connect(func(_body): SaveSystem._auto_save())
# BossHealthComponent.on_boss_defeated.connect(func(_boss): SaveSystem._auto_save())
```

#### 存档点视觉/音效反馈

```gdscript
# 存档完成后发射信号，HUD 监听并播放反馈
signal on_save_completed(slot: int, is_auto: bool)

# HUD 监听:
# - 自动存档: 右上角猫爪印章图标（1.5 秒淡出）+ 轻柔猫叫声
# - 手动存档: 暂停菜单更新槽位卡片 + 印章盖下音
```

### 9. 加载流程

#### 完整加载管道

```
load_game(slot: int) → bool
│
├─ Step 1: 参数校验
│   ├─ slot ∈ [0, 3]? 否 → return false
│   └─ _is_busy()? 是 → return false
│
├─ Step 2: 读取文件
│   ├─ 读取 user://saves/slot_{N}.json
│   ├─ 文件不存在 → return false
│   └─ JSON.parse_string() → 解析失败 → 进入备份恢复（§6）
│
├─ Step 3: 结构验证
│   ├─ _validate_save_structure(data)
│   └─ 验证失败 → 进入备份恢复（§6）
│
├─ Step 4: 版本检查
│   ├─ data._meta.version == CURRENT_SAVE_VERSION → 继续
│   ├─ data._meta.version < CURRENT_SAVE_VERSION → 执行迁移（§4）
│   │   └─ 迁移失败 → return false
│   └─ data._meta.version > CURRENT_SAVE_VERSION → return false（未来版本）
│
├─ Step 5: 反序列化
│   ├─ 恢复 player_state → Player 各 Component
│   ├─ 恢复 world_state → WorldStateManager
│   ├─ 恢复 settings → SettingsManager
│   └─ _deserialize_all(data["systems"], original_version)
│       └─ 按注册顺序调用各 ISerializable.deserialize()
│
├─ Step 6: 场景恢复
│   ├─ 读取 data["systems"]["scene"] 获取 target_scene + spawn_point
│   ├─ 如果当前场景 != target_scene:
│   │   └─ SceneManager.change_scene(target_scene, spawn_point)
│   └─ 如果当前场景 == target_scene:
│       └─ 将 Player 移动到 spawn_point 位置
│
├─ Step 7: 后处理
│   ├─ 更新 _current_play_time 从存档的 play_time_sec
│   ├─ 发射 on_game_loaded(slot) 信号
│   └─ return true
│
└─ 任何步骤失败 → return false
```

#### 加载时状态

```gdscript
enum LoadState { IDLE, READING, VALIDATING, MIGRATING, DESERIALIZING, SCENE_LOADING, DONE }
var _load_state: LoadState = LoadState.IDLE
```

#### 加载流程中的 DataManager 交互

```gdscript
# 加载时从 DataManager 获取配置
func _get_max_slot() -> int:
    return int(DataManager.get_tuning(&"save.max_slots", 3))

func _get_max_save_size_kb() -> int:
    return int(DataManager.get_tuning(&"save.max_save_size_kb", 100))
```

### 10. DataManager 集成

#### TuningKnob 注册

SaveSystem 在 `_ready()` 中向 DataManager 注册以下 TuningKnob：

| Knob ID | 类型 | 默认值 | 安全范围 | 说明 |
|---------|------|--------|---------|------|
| `save.max_slots` | int | 3 | 1–10 | 手动存档槽位数 |
| `save.auto_save_interval_sec` | int | 300 | 120–600 | 定时自动存档间隔（秒），0 = 禁用定时存档 |
| `save.max_save_size_kb` | int | 100 | 50–500 | 单存档最大文件大小 |
| `save.backup_count` | int | 1 | 1–3 | 每个槽位的备份数量 |
| `save.enable_async_write` | bool | true | — | 是否使用异步写入 |

```gdscript
func _ready() -> void:
    _register_tuning_knobs()
    # ... 其他初始化

func _register_tuning_knobs() -> void:
    DataManager.register_tuning(&"save.max_slots", "int", 3, 1, 10, &"save")
    DataManager.register_tuning(&"save.auto_save_interval_sec", "int", 300, 0, 600, &"save")
    DataManager.register_tuning(&"save.max_save_size_kb", "int", 100, 50, 500, &"save")
    DataManager.register_tuning(&"save.backup_count", "int", 1, 1, 3, &"save")
    DataManager.register_tuning(&"save.enable_async_write", "bool", true, null, null, &"save")
```

#### 配置读取

所有存档配置从 DataManager TuningKnobRegistry 读取，不在 SaveSystem 中硬编码：

```gdscript
func _get_config(knob_id: StringName, fallback: Variant) -> Variant:
    return DataManager.get_tuning(knob_id, fallback)
```

#### 存档配置热重载

如果 DataManager 热重载了 `save.*` 域的旋钮值，SaveSystem 监听 `on_knob_changed` 信号并更新内部状态：

```gdscript
func _ready() -> void:
    # ...
    DataManager.on_knob_changed.connect(_on_knob_changed)

func _on_knob_changed(id: StringName, new_value: Variant) -> void:
    if id == &"save.auto_save_interval_sec":
        _update_auto_save_timer(float(new_value))
    elif id == &"save.max_slots":
        # 槽位数变更在下次 save_game 时生效
        pass
```

### 完整存档流程

```
_execute_save(slot: int) → bool
│
├─ Step 1: 前置检查
│   ├─ _is_busy()? → return false
│   └─ 磁盘空间检查（DirAccess.get_space_left()）
│
├─ Step 2: 收集数据
│   ├─ _meta: 填充 version, timestamp, play_time_sec, slot, save_point_name
│   ├─ player_state: 从 Player 节点收集
│   ├─ world_state: 从 WorldStateManager 收集
│   ├─ settings: 从 SettingsManager 收集
│   └─ systems: _serialize_all() → 各 ISerializable 系统
│
├─ Step 3: 序列化
│   ├─ JSON.stringify(save_data, "\t") → json_string
│   └─ 大小检查: json_string.length() / 1024 < max_save_size_kb
│
├─ Step 4: 备份（§3）
│   ├─ 如果主文件存在 → 复制为 .bak
│   └─ 验证 .bak 写入
│
├─ Step 5: 写入（§5）
│   ├─ enable_async_write = true → _write_json_dispatch()
│   └─ enable_async_write = false → _write_json_sync()
│
├─ Step 6: 写入后验证（§6 Level 5）
│   └─ 异步: 在 _on_write_completed() 中执行
│
└─ Step 7: 后处理
    ├─ 发射 on_save_completed(slot, is_auto) 信号
    └─ return true
```

### 信号定义

```gdscript
## 存档成功完成
signal on_save_completed(slot: int, is_auto: bool)
## 存档失败
signal on_save_failed(slot: int, reason: String)
## 游戏加载完成
signal on_game_loaded(slot: int)
## 存档损坏，使用备份恢复
signal on_save_corrupted(slot: int, message: String)
## 存档不可恢复
signal on_save_load_failed(slot: int, message: String)
```

### 公开接口汇总

```gdscript
# SaveSystem (Autoload) 公开接口

## 注册 ISerializable 系统
func register_serializable(system: ISerializable, save_key: StringName) -> void

## 取消注册
func unregister_serializable(save_key: StringName) -> void

## 手动存档（slot 1-3，slot 0 不可手动写入）
func save_game(slot: int = 1) -> bool

## 加载存档
func load_game(slot: int) -> bool

## 获取槽位信息
func get_save_info(slot: int) -> SaveInfo

## 检查槽位是否有存档
func has_save(slot: int) -> bool

## 删除存档
func delete_save(slot: int) -> bool

## 当前是否在存档/加载中
func is_busy() -> bool
```

## Alternatives Considered

### Alternative A: WorkerThreadPool 替代 Thread

- **Description**: 使用 Godot 4.4+ 的 WorkerThreadPool 进行异步文件写入
- **Pros**: 更轻量（复用引擎线程池），无需管理 Thread 生命周期
- **Cons**: WorkerThreadPool 适用于 CPU 密集型任务而非 I/O；API 较新（4.4+），文档较少；错误处理不如 Thread 直观
- **Rejection Reason**: 文件写入是 I/O 密集型任务，Thread 方案更成熟、更可控。WorkerThreadPool 可作为未来优化方案

### Alternative B: 加密存档

- **Description**: 使用 AES 或 XOR 加密存档文件，防止玩家篡改
- **Pros**: 防止作弊；保护游戏经济平衡
- **Cons**: 增加复杂度；影响性能；单人游戏反作弊价值低；加密密钥硬编码在客户端不安全
- **Rejection Reason**: 单人 2D ACT 游戏，存档修改不影响多人体验。留作发布后评估（GDD Open Question #2）

### Alternative C: 二进制格式替代 JSON

- **Description**: 使用 `PackedByteArray` + `FileAccess.store_var()` 二进制序列化
- **Pros**: 文件更小（约为 JSON 的 1/3）；序列化/反序列化更快
- **Cons**: 不可读（无法调试和模组支持）；跨版本兼容性差（Variant 编码可能变化）；不支持跨平台迁移
- **Rejection Reason**: GDD 明确要求人类可读（便于调试和模组支持），存档数据量小（< 100KB），JSON 性能足够

## Consequences

### Positive

- **数据安全**: 三层防护（.bak 备份 + 写入后验证 + JSON 结构校验）最大程度防止存档丢失
- **零卡顿**: Thread 异步写入保证存档操作不阻塞游戏主线程，满足 < 100ms 要求
- **向后兼容**: 链式版本迁移确保旧存档在游戏更新后仍可加载
- **解耦设计**: ISerializable 注册表模式使新增存档系统无需修改 SaveSystem
- **可配置**: 所有存档参数通过 DataManager TuningKnob 管理，支持热重载和调试面板调整
- **可测试**: 序列化/反序列化逻辑与文件 I/O 分离，可独立单元测试
- **Web 兼容**: Thread 不可用时自动 fallback 到 call_deferred

### Negative

- **实现复杂度**: 异步写入 + 备份 + 迁移 + 完整性校验，代码量较大
- **调试难度**: Thread 异步执行的错误路径更难调试和复现
- **注册顺序依赖**: ISerializable 的反序列化依赖注册顺序，新增系统需要仔细考虑位置
- **JSON 限制**: 不支持 Resource 引用、Vector2 需要手动转换、大数值精度问题
- **手动注册**: 每个需要存档的系统必须记得调用 register_serializable，遗漏导致数据丢失

### Risks

- **Thread 生命周期管理**: 如果游戏在写入过程中退出，Thread 可能导致崩溃。**缓解**: SaveSystem._notification(NOTIFICATION_WM_CLOSE_REQUEST) 中等待写入完成或使用 Mutex.try_lock() 检测
- **Web 导出兼容性**: Web 平台不支持 Thread。**缓解**: 检测 web 特性，fallback 到 call_deferred 方案
- **注册遗漏**: 系统忘记注册 ISerializable。**缓解**: SaveSystem 在首次 save_game() 时输出注册表清单到控制台；添加单元测试检查所有预期系统已注册
- **迁移链断裂**: 开发者递增 CURRENT_SAVE_VERSION 但忘记添加迁移函数。**缓解**: 代码审查 checklist 包含迁移检查项；CI 中添加测试验证迁移链完整性
- **并发写入冲突**: 快速连续触发自动存档。**缓解**: _write_pending 锁保证同一时间只有一个写入操作
- **跨平台路径差异**: user:// 在不同平台的实际路径不同。**缓解**: 使用 Godot 的 user:// 抽象，不直接操作 OS 路径

## GDD Requirements Addressed

| TR-ID | Requirement | How This ADR Addresses It |
|-------|-------------|--------------------------|
| TR-save-001 | ISerializable 接口模式 | §7: 完整的注册表机制、有序序列化/反序列化管道、注册顺序约束、去重检查、unregister 支持。ADR-0008 定义了接口契约，本 ADR 补全注册表实现细节 |
| TR-save-002 | 存档数据结构 | §1: 完整的 JSON schema 定义，覆盖 `_meta`、`player_state`、`world_state`、`settings`、`systems` 全部字段及类型规范 |
| TR-save-003 | 3 手动 + 1 自动槽位 | §2: 完整的槽位管理规则，包括槽位 0 保护机制、范围校验、SaveInfo 结构、手动覆盖策略 |
| TR-save-004 | 备份机制 | §3: 完整的写入前备份流程、.bak 生命周期、备份大小校验、恢复流程（主文件 → .bak 两级回退） |
| TR-save-005 | 版本迁移 | §4: CURRENT_SAVE_VERSION 常量、链式迁移管道 `_migrate_save_data`、迁移注册表、迁移后写回、迁移失败处理 |
| TR-save-006 | 存档触发条件 | §8: 4 种触发类型（存档点自动、Boss 击败自动、关键事件自动、暂停菜单手动）的触发时机、调用方、槽位分配 |
| TR-save-007 | 异步写入 < 100ms | §5: Thread 异步写入 + Mutex 同步 + _process() 轮询回调 + Web fallback。写入操作不阻塞主线程 |

**附加覆盖**（超出 6 个 TR 缺口的补充）：

| 需求来源 | How This ADR Addresses It |
|---------|--------------------------|
| GDD Edge Case: 存档损坏 | §6: 5 层完整性校验 + .bak 回退 |
| GDD Edge Case: 磁盘空间不足 | 完整存档流程 Step 1: DirAccess.get_space_left() 检查 |
| GDD Edge Case: 多槽位同时操作 | §5: _write_pending 单写入锁 |
| GDD: 存档点视觉/音效反馈 | §8: on_save_completed 信号 |
| ADR-0003: DataManager 集成 | §10: TuningKnob 注册、配置读取、热重载监听 |
| ADR-0008: 加载流程 | §9: 完整的 7 步加载管道 |

## Verification

- [ ] **JSON 结构验证**: 创建存档文件，验证所有必需字段存在且类型正确
- [ ] **槽位保护验证**: 调用 `save_game(0)` 返回 `false` + ERROR 日志
- [ ] **槽位范围验证**: 调用 `save_game(4)` / `load_game(-1)` 返回 `false`
- [ ] **备份创建验证**: 存档两次后，验证 .bak 文件存在且内容为第一次存档的数据
- [ ] **备份恢复验证**: 手动损坏主 JSON 文件（写入无效内容），调用 load_game 成功从 .bak 恢复
- [ ] **完整性校验验证**: 缺少 `_meta` 字段的存档触发 .bak 回退
- [ ] **版本迁移验证**: 创建 version=1 存档，将 CURRENT_SAVE_VERSION 设为 2，加载时自动执行迁移
- [ ] **迁移链完整性**: 测试从 version=1 到 version=3 的跨版本迁移（经过中间步骤）
- [ ] **未来版本拒绝**: version=999 的存档拒绝加载
- [ ] **异步写入验证**: 存档操作不导致帧率下降（Profiler 验证）
- [ ] **并发写入保护**: 快速连续触发两次 save_game，第二次被跳过 + WARNING
- [ ] **Web fallback 验证**: Web 导出时使用 call_deferred 替代 Thread
- [ ] **ISerializable 注册验证**: 首次 save_game 时控制台输出所有已注册系统清单
- [ ] **注册去重验证**: 重复注册相同 save_key 返回 ERROR
- [ ] **反序列化缺失字段**: 存档数据缺少某个 system key 时，该系统使用默认状态 + WARNING
- [ ] **DataManager 集成验证**: 修改 `save.max_slots` 旋钮值，验证后续 save_game 使用新值
- [ ] **信号发射验证**: 存档成功发射 on_save_completed；损坏恢复发射 on_save_corrupted
- [ ] **大小限制验证**: 存档数据超过 max_save_size_kb 时拒绝写入
- [ ] **单元测试覆盖**: serialize/deserialize 往返一致性测试（每个 ISerializable 系统）
- [ ] **集成测试覆盖**: 完整 save → corrupt → load from .bak → verify state 流程
- [ ] **死亡重生验证**: 玩家死亡后加载 slot_0 自动存档

## Related Decisions

- ADR-0001: SaveSystem 作为 Autoload #4 的架构定位
- ADR-0002: 信号命名约定（`on_` 前缀）
- ADR-0003: DataManager TuningKnob 注册和查询接口
- ADR-0007: SceneManager 场景加载/切换接口（加载流程 Step 6 调用）
- ADR-0008: ISerializable 接口契约（serialize/deserialize 签名）
- `design/gdd/save-system.md`: 完整的存档系统 GDD 需求
- `docs/architecture/requirements-traceability.md`: TR-save 覆盖状态追踪
