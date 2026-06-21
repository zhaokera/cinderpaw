# 数据/平衡基础设施 (Data/Balance Infrastructure)

> **Status**: Designed (awaiting review)
> **Author**: 用户 + AI
> **Last Updated**: 2026-06-18
> **Implements Pillar**: 间接支撑全部支柱（所有数值系统的基础）
> **Systems Index**: #2 | MVP核心 | Foundation
> **Creative Director Review (CD-GDD-ALIGN)**: APPROVED [2026-06-18]

## Overview

**数据/平衡基础设施**是《废土喵影》的基础设施层，为所有游戏系统提供统一的数值配置管理能力。它负责加载、存储、热重载游戏数据（JSON/Resource格式），并为下游系统（伤害计算、状态效果、护符/装备、技能树、商店等）提供标准化的数据访问接口。

**玩家直接感受它**：对于一个以"技巧优先"为核心支柱的ACT游戏，数值平衡是玩家体验的隐形命脉。当伤害公式让暴击"感觉对了"，当护符效果让Build"有意义"，当Boss血量让战斗"紧张但不绝望"——这些都是数据基础设施在背后支撑的。数值不合理 = 技巧优先的承诺被打破。

**技术职责**：
- 统一数据格式：定义JSON/Resource的标准结构，所有系统使用相同的数据协议
- 数据加载器：从文件系统加载配置，支持异步加载和缓存
- 热重载监听：开发期间修改数据文件后自动重载，无需重启游戏
- 数据验证：加载时校验数据完整性（必填字段、值范围、类型安全）
- 旋钮注册表：所有可调参数的集中注册，支持设计师在运行时调参

**为什么存在**：没有它，每个系统各自管理数据 = 格式混乱、重复代码、调参需要改代码重编译。数据基础设施让"数值调对了"成为可能，而"数值调对了"是玩家感受到公平挑战的前提。

## Player Fantasy

**「精确如猫的信任感」+「每一刀都有分量的掌控感」— 隐形平衡幻想**

数据/平衡基础设施的终极使命是**让玩家忘记它的存在**。当它完美运作时，玩家从未想过"这个数值是不是有问题"——他们的全部注意力都放在自己与敌人的博弈上，而非与游戏设计的博弈上。

**锚定时刻（信任层）**：第三次挑战精英敌人，前两次失败了但不觉得不公平。第三次读懂了攻击前摇，完美闪避+格挡反击，敌人倒下。玩家感受到的不是"运气好"，而是"我变强了"。每一次伤害数字都合乎直觉，每一个敌人血量都恰好"认真但不绝望"。

**锚定时刻（掌控层）**：换了新武器，第一刀砍出去就感受到了差异——不是"+15攻击"的面板差异，而是"这一刀更重、更有决断力"的体感差异。选轻甲就更灵巧，选重击就更有冲击。数据不是贴在墙上的数字，而是融进了每一次按键反馈里的"份量"。

**核心承诺**：
- **公平透明**：相同操作产生相同结果，数值公式可预测、可学习
- **选择有重量**：每个Build决策都在战斗中有可感知的差异，不存在"无意义升级"
- **技巧放大器**：数值成长放大技巧差异而非替代技巧——高手用低级装备也能通关

**技巧优先的承诺，从数据层开始。** 当伤害公式让暴击"感觉对了"，当护符效果让Build"有意义"，当Boss血量让战斗"紧张但不绝望"——这就是数据基础设施在背后支撑的体验。

## Detailed Design

### Core Rules

#### 规则1：数据格式标准 — JSON为源，Resource为桥接

| 格式 | 用途 | 何时使用 |
|------|------|----------|
| **JSON** | 源数据，设计师直接编辑 | 所有平衡数值、配置定义、旋钮参数 |
| **Resource** | 引擎桥接层 | 需要编辑器Inspector可视化或引用Texture/Audio |

**目录结构**：
```
data/
├── manifest.json              # 数据清单（域注册+加载顺序）
├── combat/                    # 战斗数值
│   ├── damage_params.json
│   ├── weapon_stats.json
│   └── enemy_stats.json
├── progression/               # 成长系统
│   ├── charm_definitions.json
│   └── skill_tree.json
├── input/
│   └── input_config.json
├── tuning_knobs.json          # 全局旋钮注册表
└── schemas/                   # 验证schema（不导出）
```

**JSON标准格式**：
```json
{
  "_meta": { "version": "1.0", "domain": "damage_params" },
  "entries": {
    "basic_slash": { "base_damage": 10, "scaling_factor": 1.2, "crit_multiplier": 1.5 }
  }
}
```

#### 规则2：数据加载管道 — DataManager Autoload

`DataManager` 是Autoload单例，所有数据请求的唯一入口。

**核心接口**：
- `get_domain(domain_name) → DataDomain` — 获取数据域
- `get_entry(domain, entry_id) → Variant` — 按ID获取单条数据
- `get_tuning(knob_id, default) → Variant` — 获取旋钮值
- `reload_domain(domain_name) → bool` — 手动触发重载

**缓存策略**：preload=true域启动时全量加载，之后只读缓存。热重载验证通过后原子替换缓存。

#### 规则3：热重载系统 — 文件时间戳轮询 + 信号传播

| 参数 | 值 | 说明 |
|------|----|------|
| 启用条件 | `OS.is_debug_build()` | 仅Debug构建 |
| 轮询间隔 | 1秒 | 对开发体验影响极小 |
| 传播机制 | 信号系统 | `domain.changed()` → 下游系统刷新 |

**重载流程**：检测文件变更 → 读取新数据 → 验证 → 验证通过：替换缓存+发信号 / 验证失败：保留旧缓存+报错

#### 规则4：数据验证 — Schema驱动 + 三级失败处理

**验证检查项**：必填字段存在、类型匹配、数值范围、枚举值合法、跨字段约束

**三级失败处理**：
| 场景 | 处理 |
|------|------|
| 首次加载+验证失败 | 使用硬编码默认值，输出ERROR，游戏继续运行 |
| 热重载+验证失败 | 保留旧缓存不变，输出ERROR，设计师修正文件 |
| manifest加载失败 | DataManager进入ERROR状态，所有请求返回null |

**设计哲学**：开发期间数据错误永远不导致游戏崩溃。设计师需要看到"哪里不对"而非被踢出游戏。

#### 规则5：旋钮注册表 — TuningKnobRegistry

集中管理所有可调参数，支持运行时修改。

**旋钮值来源优先级**：
1. 调试面板运行时修改（最高优先，临时生效）
2. JSON文件中的值（通过热重载更新）
3. 注册时的default_value（最低优先，兜底）

**注册示例**（输入系统在`_ready()`中注册）：
```
register("input.buffer_window_ms", int, 150, {min:80, max:250, domain:"input"})
register("input.coyote_frames", int, 6, {min:4, max:10, domain:"input"})
```

#### 规则6：数据版本控制 — _meta.version + 链式迁移

每个JSON文件头部必须包含版本号。版本格式：`MAJOR.MINOR`。
- MAJOR递增：删除字段、改变语义（破坏性变更）
- MINOR递增：新增可选字段（向后兼容）

**迁移机制**：链式迁移（1.0→1.1→1.2），自动执行中间步骤。

### States and Transitions

**DataManager全局状态机（4状态）**：

| 状态 | 触发 | get_entry()返回 |
|------|------|----------------|
| BOOTING | 启动，加载manifest | 阻塞或null |
| READY | manifest加载成功 | 缓存数据 |
| RELOADING | 检测到文件变更 | 旧缓存（原子替换） |
| ERROR | manifest加载失败 | null |

**状态转换**：
- BOOTING → READY（加载成功）/ ERROR（失败）
- READY → RELOADING（变更检测）→ READY（验证通过/失败均回READY）
- ERROR → BOOTING（手动重试）

### Interactions with Other Systems

#### 标准接口契约

所有数据消费系统遵循：
1. `_ready()`中获取域 + 连接`changed()`信号
2. `get_entry()`返回null时优雅降级
3. 信号回调中刷新本地数据

#### 输入系统的接口

输入GDD要求的`load_input_config(path) → Dictionary`：
```
func load_input_config(path: String) -> Dictionary:
    var domain := DataManager.get_domain("input_config")
    return domain.get_all_entries() if domain else _get_default_input_config()
```

输入系统的8个旋钮在`_ready()`中注册到TuningKnobRegistry，监听`knob_changed`信号实时更新。

#### 接口汇总

| 下游系统 | 域名 | 热重载响应 |
|----------|------|------------|
| 伤害计算 | `damage_params` | 重新读取参数，下次计算使用新值 |
| 护符/装备 | `charm_definitions` | 已装备效果立即更新 |
| 输入系统 | `input_config` + 旋钮 | 旋钮值立即生效 |
| 状态效果 | `status_effects` | 新施加的效果使用新参数 |
| AI框架 | `enemy_stats` | 新生成的敌人使用新属性 |
| Boss配置 | `boss_configs` | 新Boss战使用新配置 |
| 商店 | `shop_items` | 刷新商店UI |

## Formulas

数据基础设施本身不包含游戏平衡公式（属于下游系统），但定义以下系统级参数：

**1. 轮询间隔**
`poll_interval_sec = 1.0`（秒）— 热重载文件检查频率，仅Debug构建

**2. 验证结果判定**
`is_valid = (error_count == 0)` — 有任何ERROR则验证失败

**3. 版本号解析**
`version_compatible = (file_major == expected_major AND file_minor >= expected_minor)`

**4. 旋钮值clamp**
`clamped_value = clamp(requested_value, min_value, max_value)` — 自动限制在安全范围内

## Edge Cases

- **JSON文件语法错误**：输出ERROR到开发控制台，保留旧缓存（热重载）或使用默认值（首次加载）
- **manifest.json不存在**：DataManager进入ERROR状态，所有`get_entry()`返回null
- **域文件被删除**：该域进入FALLBACK状态，使用硬编码默认值
- **验证失败但文件存在**：热重载时保留旧缓存；首次加载时使用默认值
- **多文件同周期变更**：合并为一次重载，避免级联
- **下游系统在BOOTING状态请求数据**：返回null，系统必须优雅降级
- **旋钮ID未注册就被查询**：返回传入的default参数值，输出WARNING
- **热重载导致下游状态不一致**：通过信号传播确保所有监听者在同一帧内收到通知

## Dependencies

**上游依赖**：
- 无（Foundation层，零依赖）
- Godot Engine: `FileAccess`, `JSON`, `DirAccess`, `ResourceLoader`, `Timer`

**下游被依赖**：
- 伤害计算系统 — 读取伤害公式参数
- 状态效果系统 — 读取效果定义
- 护符/装备系统 — 读取护符定义
- 技能树系统 — 读取技能树节点
- 商店系统 — 读取商店库存
- 输入系统 — 读取键位配置 + 注册旋钮
- AI框架 — 读取敌人属性
- Boss配置层 — 读取Boss配置

## Tuning Knobs

本系统自身的旋钮（基础设施级）：

| 旋钮 | 默认值 | 安全范围 | 过高影响 | 过低影响 |
|------|--------|---------|---------|---------|
| poll_interval_sec | 1.0 | 0.5-5.0 | 文件变更检测迟钝 | CPU轮询开销增加 |
| max_validation_errors | 10 | 1-100 | 验证报告过长 | 错误被截断 |
| default_fallback_enabled | true | true/false | — | 数据错误直接崩溃 |

**下游系统的旋钮**（由各自系统注册到TuningKnobRegistry）：
- 输入系统：8个旋钮（buffer_window_ms, coyote_frames等）— 见input.md
- 伤害计算：待设计（damage_multiplier, crit_rate等）
- 其他系统：待设计

## Visual/Audio Requirements

数据基础设施本身不产生视觉/音频输出。但以下调试反馈需要视觉支持：

### 开发控制台输出
- 数据加载成功：`[DataManager] 域 'combat' 加载完成 (12条目)`
- 热重载触发：`[DataManager] 检测到变更，重载域 'combat'`
- 验证失败：`[DataManager] 验证错误: combat/damage_params.json - 缺少必填字段 'base_damage'`
- 旋钮修改：`[DataManager] 旋钮 'input.buffer_window_ms' 改为 180`

### 调试面板（F12）
- 显示所有旋钮（按域分组），可实时调整
- 显示每个域的加载状态（READY/ERROR/FALLBACK）
- 显示最后重载时间

## UI Requirements

本系统无玩家可见UI。仅有开发调试面板（F12触发）：
- 旋钮编辑器：滑块+输入框，实时生效
- 域状态查看器：每个域的当前状态和数据量
- 验证错误查看器：当前所有验证失败的详细列表

## Acceptance Criteria

- **GIVEN** 游戏启动时，**WHEN** manifest.json存在且格式正确，**THEN** DataManager在READY状态，所有preload域可用
- **GIVEN** manifest.json缺失，**WHEN** 游戏启动，**THEN** DataManager进入ERROR状态，所有`get_entry()`返回null
- **GIVEN** JSON文件有语法错误，**WHEN** 加载该文件，**THEN** 输出ERROR到控制台，保留旧缓存或使用默认值
- **GIVEN** 数据文件在运行时被修改，**WHEN** 1秒内轮询检测到变更，**THEN** 触发重载，`changed()`信号发射，下游系统刷新数据
- **GIVEN** 热重载时验证失败，**WHEN** 新数据有错误字段，**THEN** 保留旧缓存不变，输出ERROR，游戏继续运行
- **GIVEN** 旋钮注册到TuningKnobRegistry，**WHEN** 运行时修改旋钮值，**THEN** `knob_changed`信号发射，下游系统立即使用新值
- **GIVEN** 旋钮值超出安全范围，**WHEN** 设置超过max的值，**THEN** 自动clamp到max，不报错
- **GIVEN** 下游系统调用`get_entry()`，**WHEN** 条目不存在，**THEN** 返回null，不崩溃
- **GIVEN** 数据文件版本号低于期望，**WHEN** 加载该文件，**THEN** 自动执行迁移链升级到目标版本
- **GIVEN** Debug构建，**WHEN** 热重载启用，**THEN** 每秒轮询一次文件修改时间
- **GIVEN** Release构建，**WHEN** 游戏运行，**THEN** 热重载完全禁用，零开销
- **GIVEN** 输入系统调用`load_input_config(path)`，**WHEN** 配置域存在，**THEN** 返回完整配置字典

## Open Questions

| # | 问题 | 负责人 | 目标解决时间 |
|---|------|--------|-------------|
| 1 | 是否需要支持Excel→JSON的自动导出工具链？ | tools-programmer | 首次内容填充前 |
| 2 | 数据加密/混淆是否需要？（防止玩家修改JSON调参） | technical-director | 发布前评估 |
| 3 | 是否需要支持远程数据下发（热更新）？ | technical-director | 发布后评估 |
