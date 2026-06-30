# ADR-0003: 数据管理架构

## Summary
定义 DataManager Autoload 的内部架构：JSON域结构、文件加载管道、热重载机制、Schema验证策略、TuningKnobRegistry 集中旋钮管理。采用 JSON 为源数据格式，Resource 为引擎桥接层。

## Status
Accepted

## Date
2026-06-21

## Engine Compatibility

| Field | Value |
|-------|-------|
| **Engine** | Godot 4.7 |
| **Domain** | Core / Foundation |
| **Knowledge Risk** | LOW — FileAccess/JSON/DirAccess API stable since 4.0; 4.4 change: `FileAccess.store_*` returns bool |
| **References Consulted** | `docs/engine-reference/godot/VERSION.md`, `docs/engine-reference/godot/breaking-changes.md` |
| **Post-Cutoff APIs Used** | None (4.4 FileAccess change noted but does not affect read path) |
| **Verification Required** | 验证 `FileAccess.get_modified_time()` 在所有目标平台上正确返回文件修改时间戳 |

## ADR Dependencies

| Field | Value |
|-------|-------|
| **Depends On** | ADR-0001 (DataManager 作为 Autoload #1 注册) |
| **Enables** | ADR-0005 (战斗状态机 — 需要 weapon_stats 域), ADR-0006 (AI — 需要 enemy_stats 域), ADR-0009 (技能树 — 需要 skill_tree 域) |
| **Blocks** | 所有需要游戏数据的系统实现 |
| **Ordering Note** | Foundation 层 ADR，必须在所有 Core/Feature ADR 之前完成 |

## Context

### Problem Statement

data-balance.md GDD 定义了 DataManager 的高层需求（JSON 加载、热重载、验证、旋钮注册），但内部实现架构未定：域如何组织、JSON schema 格式、热重载的文件监听策略、验证失败的降级方式、TuningKnobRegistry 的注册和查询机制。这是所有数值驱动系统的基础——伤害计算、AI、技能树等都从 DataManager 读取配置。

### Constraints

- **ADR-0001**: DataManager 是 Foundation 层 Autoload，不引用 Core/Feature 系统
- **ADR-0002**: DataManager 的信号使用 `on_` 前缀命名约定
- **热重载仅 Debug 构建**: `OS.is_debug_build()` 时启用
- **不崩溃原则**: 数据错误永远不导致游戏崩溃——优雅降级
- **60fps**: 热重载轮询不能影响帧时间（<0.1ms/帧）

### Requirements

- 必须支持域(Domain)级别的数据组织和缓存 (TR-data-001)
- 必须支持 JSON 为源数据格式 (TR-data-002)
- 必须支持 Debug 构建热重载（1秒轮询 + 信号传播）(TR-data-003)
- 必须支持 Schema 驱动的数据验证（3级失败处理）(TR-data-004)
- 必须支持 TuningKnobRegistry 集中旋钮管理（运行时修改 + 安全范围）(TR-data-005)
- 必须支持数据版本迁移（MAJOR.MINOR + 链式迁移）

## Decision

### 目录结构

```
data/
├── manifest.json              # 域注册 + 加载顺序 + preload 标记
├── combat/
│   ├── damage_params.json     # DC-F1~F9 公式参数
│   ├── weapon_stats.json      # 4 武器基础数据
│   └── enemy_stats.json       # 敌人属性 + 攻击模式
├── progression/
│   ├── charm_definitions.json # 8 种护符定义
│   └── skill_tree.json        # 65 节点定义 + 费用
├── input/
│   └── input_config.json      # 12 动作 + 8 旋钮
├── tuning_knobs.json          # 全局旋钮注册表（聚合所有域旋钮）
└── schemas/                   # 验证 schema（不导出到 release）
    ├── damage_params.schema.json
    ├── weapon_stats.schema.json
    └── ...
```

### JSON 格式标准

```json
{
  "_meta": {
    "version": "1.0",
    "domain": "damage_params",
    "description": "伤害公式参数"
  },
  "entries": {
    "cat_claw": {
      "weapon_base": 10,
      "scaling_factor": 1.2,
      "crit_perfect_multiplier": 2.5,
      "crit_good_multiplier": 1.8
    },
    "long_tail": {
      "weapon_base": 14,
      "scaling_factor": 1.0,
      "crit_perfect_multiplier": 2.5,
      "crit_good_multiplier": 1.8
    }
  }
}
```

**规则**:
- `_meta` 必须存在，包含 `version`（MAJOR.MINOR）和 `domain`
- `entries` 是顶层数据对象，key 为 entry_id
- 每个 entry 的字段名和类型由对应 schema 定义
- 值类型：int, float, String, bool, Array, Dictionary

### manifest.json

```json
{
  "_meta": {"version": "1.0", "domain": "manifest"},
  "domains": [
    {"name": "damage_params", "path": "combat/damage_params.json", "preload": true},
    {"name": "weapon_stats", "path": "combat/weapon_stats.json", "preload": true},
    {"name": "enemy_stats", "path": "combat/enemy_stats.json", "preload": false},
    {"name": "charm_definitions", "path": "progression/charm_definitions.json", "preload": true},
    {"name": "skill_tree", "path": "progression/skill_tree.json", "preload": true},
    {"name": "input_config", "path": "input/input_config.json", "preload": true}
  ]
}
```

### DataManager 加载管道

```
Boot → _ready():
  1. 加载 manifest.json
  2. 验证 manifest schema
  3. 对每个 preload=true 域:
     a. 读取 JSON 文件 (FileAccess)
     b. 解析 (JSON.parse)
     c. 验证 (SchemaValidator)
     d. 验证通过 → 存入 _cache[domain_name] = Dictionary
     e. 验证失败 → 使用硬编码默认值 + 输出 ERROR
  4. 状态 → READY

Runtime → get_entry(domain, entry_id):
  1. 检查 _cache 是否有该域
  2. 有 → 返回 entries[entry_id]（或 null）
  3. 无 → preload=false 域首次请求时加载（懒加载）
  4. 返回 null 时调用方必须优雅降级

Hot Reload → _process(delta) [仅 Debug]:
  1. 每 1 秒检查所有域的 FileAccess.get_modified_time()
  2. 时间戳变化 → 重新读取 + 解析 + 验证
  3. 验证通过 → 原子替换 _cache[domain_name] + 发射 on_domain_changed 信号
  4. 验证失败 → 保留旧缓存 + 输出 ERROR（不替换）
```

### Schema 验证

```gdscript
class_name SchemaValidator

static func validate(data: Dictionary, schema: Dictionary) -> ValidationResult:
    # 检查项:
    # 1. 必填字段存在
    # 2. 类型匹配 (int/float/String/bool/Array/Dictionary)
    # 3. 数值范围 (min/max)
    # 4. 枚举值合法
    # 5. 跨字段约束 (如 max > min)
    pass

class_name ValidationResult:
    var is_valid: bool
    var errors: Array[String]  # ["damage_params.cat_claw.weapon_base: expected int, got String"]
```

**三级失败处理**:

| 场景 | 处理 |
|------|------|
| 首次加载 + 验证失败 | 使用硬编码默认值，ERROR 日志，游戏继续 |
| 热重载 + 验证失败 | 保留旧缓存，ERROR 日志，不替换 |
| manifest 加载失败 | DataManager 进入 ERROR 状态，所有请求返回 null |

### TuningKnobRegistry

```gdscript
# TuningKnobRegistry 是 DataManager 的内部组件

class_name TuningKnobEntry
var id: StringName           # "input.buffer_window_ms"
var type: StringName         # "int" | "float" | "bool" | "String"
var default_value: Variant   # 150
var min_value: Variant       # 80
var max_value: Variant       # 250
var domain: StringName       # "input"
var current_value: Variant   # 运行时值

# 值来源优先级:
# 1. 调试面板运行时修改 (最高)
# 2. JSON 文件值 (热重载更新)
# 3. 注册时的 default_value (最低)

# 注册 (由各系统在 _ready() 中调用):
func register(id: StringName, type: StringName, default: Variant,
              min_val: Variant, max_val: Variant, domain: StringName) -> void

# 查询:
func get_value(id: StringName, fallback: Variant) -> Variant
# 返回: clamp(current_value, min_value, max_value)
# 未注册 → 返回 fallback + WARNING 日志

# 运行时修改 (调试面板):
func set_value(id: StringName, value: Variant) -> void
# 自动 clamp 到 [min, max]
# 发射 knob_changed 信号

signal knob_changed(id: StringName, new_value: Variant)
```

### 数据版本迁移

```
version_compatible = (file_major == expected_major AND file_minor >= expected_minor)

迁移链: 1.0 → 1.1 → 1.2 → ... → current
每个迁移步骤是一个函数: func migrate_1_0_to_1_1(data: Dictionary) -> Dictionary
DataManager 自动检测版本并执行链式迁移
```

### Architecture Diagram

```
DataManager Autoload
├── ManifestLoader
│   └── manifest.json → 域注册表
├── DomainCache
│   ├── damage_params: Dictionary (entries)
│   ├── weapon_stats: Dictionary
│   ├── charm_definitions: Dictionary
│   └── ...
├── SchemaValidator (static)
│   └── schemas/*.schema.json
├── HotReloader (仅 Debug)
│   └── Timer (1s) → 检查 modified_time → 验证 → 替换
├── TuningKnobRegistry
│   └── registered_knobs: Dictionary
└── VersionMigrator
    └── migration_chain: Dictionary[version] → Callable
```

### Key Interfaces

```gdscript
# DataManager Autoload 公开接口

func get_domain(domain_name: StringName) -> Dictionary
# 返回域的全部 entries，域不存在返回空 Dictionary

func get_entry(domain: StringName, entry_id: StringName) -> Variant
# 返回单条数据，不存在返回 null

func get_tuning(knob_id: StringName, default: Variant) -> Variant
# 返回旋钮值（已 clamp），未注册返回 default

func reload_domain(domain_name: StringName) -> bool
# 手动触发重载（Debug 构建），成功返回 true

signal on_domain_changed(domain_name: StringName)
# 域数据热重载后发射

signal on_knob_changed(knob_id: StringName, new_value: Variant)
# 旋钮值变更后发射
```

## Alternatives Considered

### Alternative A: 纯 Resource (.tres) 格式
- **Description**: 所有数据使用 Godot Resource 文件（.tres），通过 Inspector 编辑
- **Pros**: Inspector 原生可视化编辑；强类型（Resource 类定义字段类型）；编辑器自动验证
- **Cons**: 不支持运行时热重载（Resource 文件需要编辑器重新导入）；不适合设计师在编辑器外编辑；版本控制 diff 不友好（二进制格式或长文本）
- **Rejection Reason**: 热重载是 GDD 核心需求（TR-data-003），Resource 无法在运行时热重载

### Alternative B: 纯 JSON + 自定义编辑器插件
- **Description**: JSON 为唯一格式，开发 Godot 编辑器插件提供可视化编辑面板
- **Pros**: JSON 热重载友好；插件可提供定制 UI
- **Cons**: 编辑器插件开发工作量大（solo 开发者）；维护成本高；JSON 在 Inspector 中无法直接可视化
- **Rejection Reason**: Solo 开发者 scope 限制，不值得开发专用编辑器插件。Resource 桥接提供足够可视化

## Consequences

### Positive
- **热重载**: JSON 文件修改后 1 秒内生效，无需重启游戏
- **优雅降级**: 数据错误不崩溃——首次加载用默认值，热重载保留旧缓存
- **集中管理**: 所有旋钮在 TuningKnobRegistry 注册，调试面板一处调整
- **版本迁移**: 链式迁移确保旧数据自动升级
- **域隔离**: 每个域独立加载/重载，不影响其他域

### Negative
- **JSON 无类型**: 加载时需要 Schema 验证，增加首次加载时间
- **Schema 维护**: 每个数据域需要对应的 schema 文件
- **Resource 桥接延迟**: 如需 Inspector 可视化，需要额外的 JSON→Resource 转换步骤

### Risks
- **FileAccess.get_modified_time() 跨平台**: 某些平台（如移动端）可能不支持或精度不够。**缓解**: 移动端不启用热重载（`OS.is_debug_build()` 为 false）
- **大 JSON 文件性能**: 单个 JSON 文件 >1000 条目时解析可能卡顿。**缓解**: 域拆分，单域文件控制在 100 条目以内
- **Schema 文件遗漏**: 开发者忘记为新域创建 schema。**缓解**: DataManager 在加载时检查 schema 存在性，缺失则输出 WARNING 并跳过验证

## GDD Requirements Addressed

| GDD System | Requirement | How This ADR Addresses It |
|------------|-------------|--------------------------|
| data-balance.md | DataManager Autoload 单例 (TR-data-001) | 完整的 Autoload 内部架构定义 |
| data-balance.md | JSON 为源 + Resource 桥接 (TR-data-002) | JSON 格式标准 + 目录结构 |
| data-balance.md | 热重载 Debug 构建 (TR-data-003) | HotReloader Timer 1秒轮询 + domain_changed 信号 |
| data-balance.md | Schema 验证 + 3级失败 (TR-data-004) | SchemaValidator + 三级处理策略 |
| data-balance.md | TuningKnobRegistry (TR-data-005) | 完整的注册/查询/修改接口 |
| damage-calculation.md | 读取 damage_params 域 | DataManager.get_domain("damage_params") |
| input.md | 8 个旋钮注册 | TuningKnobRegistry.register() |
| skill-tree.md | 加载 skill_tree.json | DataManager.get_domain("skill_tree") |

## Performance Implications

- **CPU**: 热重载轮询每 1 秒一次（非每帧），检查 FileAccess.get_modified_time() 开销 <0.01ms/域。首次加载所有 preload 域 <500ms
- **Memory**: 域缓存常驻内存。预计 6 个域 × 50 条目 × 10 字段 ≈ 30KB 数据
- **Load Time**: manifest + 5 个 preload 域 ≈ 500ms（首次启动）
- **Network**: N/A

## Migration Plan

无需迁移——第一个数据架构 ADR。实现步骤：
1. 创建 `data/` 目录结构
2. 实现 `SchemaValidator` (class_name 静态类)
3. 实现 `TuningKnobRegistry` (DataManager 内部组件)
4. 实现 `DataManager._ready()` 加载管道
5. 实现 `HotReloader._process()` 轮询逻辑
6. 创建示例 JSON 文件 (damage_params.json)
7. 创建示例 schema (damage_params.schema.json)

## Validation Criteria

- [ ] manifest.json 正确注册所有域
- [ ] preload=true 域在 `_ready()` 中加载完成
- [ ] get_entry() 对不存在的 entry 返回 null
- [ ] 热重载：修改 JSON 文件 → 1 秒内 domain_changed 信号发射
- [ ] Schema 验证失败 → 首次加载使用默认值 / 热重载保留旧缓存
- [ ] TuningKnobRegistry.set_value() 自动 clamp 到安全范围
- [ ] 数据版本不匹配 → 自动执行迁移链

## Related Decisions

- ADR-0001: Autoload架构 — DataManager 作为 Autoload #1
- ADR-0002: 信号通信 — domain_changed/knob_changed 信号遵循 on_ 前缀
- `design/gdd/data-balance.md`: 完整 GDD 需求
- ADR-0005 (待写): 战斗状态机 — 消费 weapon_stats 域
- ADR-0009 (待写): 技能树 — 消费 skill_tree 域
