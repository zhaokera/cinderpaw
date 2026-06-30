# ADR-0008: 存档序列化模式 (ISerializable)

## Summary
定义存档系统的序列化架构：采用 ISerializable 接口模式，每个系统自实现 serialize()/deserialize()，SaveSystem 只负责协调调用和文件I/O。使用 JSON 格式存储，支持 3 个手动槽位 + 1 个自动存档槽位。

## Status
Proposed

## Date
2026-06-22

## Engine Compatibility

| Field | Value |
|-------|-------|
| **Engine** | Godot 4.7 |
| **Domain** | Persistence / GDScript |
| **Knowledge Risk** | MEDIUM — duplicate_deep() is 4.5+ (post-cutoff) |
| **References Consulted** | `docs/engine-reference/godot/current-best-practices.md`, `docs/engine-reference/godot/breaking-changes.md` |
| **Post-Cutoff APIs Used** | `Resource.duplicate_deep()` (4.5+) — for deep copying nested resources during save |
| **Verification Required** | 验证 duplicate_deep() 行为与 duplicate() 的区别；确认 JSON 序列化支持所有 Godot Variant 类型 |

## ADR Dependencies

| Field | Value |
|-------|-------|
| **Depends On** | ADR-0001 (Autoload架构), ADR-0003 (数据管理架构) |
| **Enables** | 所有需要持久化的系统（Health, Combat, Weapon, Ability, SkillTree, Charm, Exploration, NPC, Scene） |
| **Blocks** | 存档功能实现 |
| **Ordering Note** | 必须在所有 ISerializable 系统实现前确定接口契约 |

## Context

### Problem Statement

架构文档定义 SaveSystem 为 Autoload，负责协调存档操作。但尚未决定：
1. 序列化格式（JSON vs Resource vs 二进制）
2. 接口契约（每个系统如何暴露序列化能力）
3. 槽位结构（多少槽位，自动存档如何处理）
4. 版本迁移策略（存档格式变更时如何向后兼容）
5. 数据完整性保障（损坏存档如何恢复）

### Constraints

- **可测试性**: 序列化逻辑必须可单元测试，不依赖文件系统（coding-standards.md）
- **数据驱动**: 存档数据来自各系统的运行时状态，非硬编码
- **安全性**: 防止存档损坏导致进度丢失
- **性能**: 存档操作不应造成明显卡顿（异步写入考虑）

### Decision Drivers

- **灵活性**: 不同系统的数据结构差异大（Dictionary vs Array vs 自定义对象）
- **可维护性**: 新增系统时不应修改 SaveSystem 代码
- **向后兼容**: 游戏更新后旧存档仍能加载

## Decision

### 序列化格式：JSON

**选择**: JSON 文本格式  
**理由**:
- 人类可读，便于调试和模组支持
- Godot 内置 `JSON` 类，无需外部依赖
- 跨平台兼容性好
- 支持所有基础 Variant 类型（int, float, String, bool, Array, Dictionary）

**权衡**:
- 文件大小比二进制大（可接受，存档数据量小）
- 序列化速度比二进制慢（可接受，存档操作低频）
- 不支持 Resource 引用（需要转为路径字符串）

### 接口契约：ISerializable

```gdscript
class_name ISerializable
extends RefCounted

## 序列化当前状态为 Dictionary
## Returns: 可 JSON 序列化的 Dictionary
func serialize() -> Dictionary:
    return {}

## 从 Dictionary 恢复状态
## data: 从 JSON 解析的 Dictionary
## version: 存档版本号（用于迁移）
func deserialize(data: Dictionary, version: int) -> void:
    pass
```

**实现规则**:
1. 所有需要存档的系统继承或实现 ISerializable
2. `serialize()` 返回的 Dictionary 必须只包含可 JSON 序列化的类型
3. `deserialize()` 必须处理缺失字段（向后兼容）
4. Resource 引用序列化为 `res://` 路径字符串，反序列化时 `load()` 恢复

### 槽位结构

```
user://saves/
├── slot_0.json      # 自动存档（不可手动覆盖）
├── slot_1.json      # 手动槽位 1
├── slot_2.json      # 手动槽位 2
├── slot_3.json      # 手动槽位 3
└── slot_0.json.bak  # 自动存档备份（写入前复制旧文件）
```

**规则**:
- 槽位 0 为自动存档，每次存档点触发时自动写入
- 槽位 1-3 为手动存档，玩家主动触发
- 写入前先复制旧文件为 `.bak`，防止写入中断导致损坏
- 加载时如果主文件损坏，尝试加载 `.bak`

### 版本迁移

```gdscript
const CURRENT_SAVE_VERSION: int = 1

func deserialize(data: Dictionary, version: int) -> void:
    if version < CURRENT_SAVE_VERSION:
        data = _migrate_save_data(data, version)
    # 正常反序列化
```

**迁移策略**:
- 每个存档文件包含 `"_meta": {"version": N}` 字段
- SaveSystem 加载时检查版本，如果低于 CURRENT_SAVE_VERSION，调用各系统的迁移方法
- 迁移方法只处理增量变更，不重写整个数据结构

### 注册机制

```gdscript
# SaveSystem (Autoload)
var _serializables: Array[ISerializable] = []

func register_serializable(system: ISerializable) -> void:
    _serializables.append(system)

func save_game(slot: int) -> void:
    var save_data: Dictionary = {"_meta": {"version": CURRENT_SAVE_VERSION}}
    for sys in _serializables:
        save_data[sys.get_save_key()] = sys.serialize()
    _write_json(save_data, slot)
```

**规则**:
- 各系统在 `_ready()` 时调用 `SaveSystem.register_serializable(self)`
- 每个系统提供唯一的 `get_save_key() -> StringName`（如 "health", "combat"）
- SaveSystem 按注册顺序序列化/反序列化

## Consequences

### Positive
- **解耦**: 新增存档系统不需要修改 SaveSystem
- **可测试**: serialize/deserialize 可独立测试
- **灵活**: 各系统控制自己的数据格式
- **安全**: .bak 备份防止数据丢失

### Negative
- **注册顺序依赖**: 反序列化时依赖注册顺序（如果有跨系统引用）
- **手动注册**: 每个系统需要记得调用 register_serializable
- **JSON 限制**: 不支持 Resource 引用，需要转为路径

### Neutral
- **性能**: JSON 序列化/反序列化比二进制慢（但存档低频，可接受）
- **文件大小**: JSON 比二进制大（但存档数据量小，可接受）

## GDD Requirements Addressed

- `design/gdd/save-system.md` — Rule 1 (槽位结构), Rule 2 (自动存档), Rule 3 (备份机制)
- `design/gdd/systems-index.md` — System #10 (存档系统)

## Verification

- [ ] 单元测试：serialize/deserialize 往返一致性
- [ ] 集成测试：完整存档/加载流程
- [ ] 压力测试：大量数据的序列化性能
- [ ] 损坏测试：.bak 恢复机制
