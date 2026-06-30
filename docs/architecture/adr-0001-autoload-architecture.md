# ADR-0001: Autoload架构与初始化顺序

## Summary
定义项目中哪些系统作为 Autoload 全局单例、哪些作为场景组件，以及它们的初始化顺序和通信规则。选定 5 个 Autoload（DataManager, InputManager, AudioSystem, SaveSystem, SceneManager）+ 组件化 Core 层 + 静态工具类 DamageCalculator。

## Status
Accepted

## Date
2026-06-21

## Engine Compatibility

| Field | Value |
|-------|-------|
| **Engine** | Godot 4.7 |
| **Domain** | Core / GDScript |
| **Knowledge Risk** | LOW — Autoload API stable since 4.0 |
| **References Consulted** | `docs/engine-reference/godot/VERSION.md`, `docs/engine-reference/godot/current-best-practices.md` |
| **Post-Cutoff APIs Used** | None — Autoload pattern unchanged in 4.4–4.6 |
| **Verification Required** | 验证 Autoload 初始化顺序在 `project.godot` 中的声明与实际 `_ready()` 调用顺序一致 |

## ADR Dependencies

| Field | Value |
|-------|-------|
| **Depends On** | None |
| **Enables** | ADR-0002 (事件/信号通信模式), ADR-0003 (数据管理架构), ADR-0007 (场景管理架构) |
| **Blocks** | 所有 Foundation 和 Core 层实现 |
| **Ordering Note** | 这是第一个 ADR。所有后续 ADR 依赖此决策确定的 Autoload 清单和初始化顺序 |

## Context

### Problem Statement

架构文档 (`docs/architecture/architecture.md`) 定义了 5 层架构（Foundation/Core/Feature/Presentation/Platform），映射 28 个系统。但尚未决定哪些系统成为 Autoload（全局单例），哪些作为场景节点组件，以及它们的初始化顺序。这个决策是所有后续实现的基础——错误的 Autoload 选择会导致紧耦合、不可测试或跨场景状态丢失。

### Constraints

- **可测试性**: GdUnit4 单元测试必须能独立测试每个系统，不依赖完整场景树（coding-standards.md）
- **跨场景持久性**: DataManager 缓存、AudioManager 音乐状态、SaveSystem 必须在场景切换时存活
- **60fps 性能**: Autoload 的 `_process()`/`_physics_process()` 开销必须最小化（technical-preferences.md: 16.6ms 帧预算）
- **多实体支持**: HealthSystem、CombatSystem 等 Core 系统必须支持 Player + N 个 Enemy 同时存在
- **Godot 4.6+ Required Types**: nullable 参数不再隐式允许，所有 Autoload 接口必须类型安全

### Requirements

- 必须支持 DataManager 在场景切换时保持 JSON 域缓存
- 必须支持 InputManager 跨场景持续监听输入
- 必须支持 AudioManager 音乐在场景切换时交叉淡入淡出
- 必须支持 SaveSystem 协调所有 ISerializable 系统
- 必须支持 SceneManager 管理异步场景加载
- Core 层系统（Health, Combat, Collision 等）必须支持每个实体独立实例
- DamageCalculator 是无状态纯函数——不需要全局状态

## Decision

### Autoload 清单（5 个系统）

按 `project.godot` 初始化顺序排列：

| # | Autoload Name | Script | Layer | 职责 |
|---|--------------|--------|-------|------|
| 1 | `DataManager` | `res://src/foundation/data_manager.gd` | Foundation | JSON 域加载/缓存、热重载、TuningKnobRegistry、Schema 验证 |
| 2 | `InputManager` | `res://src/foundation/input_manager.gd` | Foundation | 动作映射、输入缓冲(3条目/150ms)、平台检测、combo_counter |
| 3 | `AudioSystem` | `res://src/presentation/audio_system.gd` | Presentation | 5 总线、音效池(max16)、空间音频、音乐状态机 |
| 4 | `SaveSystem` | `res://src/feature/save_system.gd` | Feature | ISerializable 协调、JSON 文件 I/O、3+1 槽位、版本迁移 |
| 5 | `SceneManager` | `res://src/feature/scene_manager.gd` | Feature | 异步加载、过渡动画、延迟卸载(3s)、场景状态缓存 |

### 非 Autoload 系统分类

**静态工具类**（`class_name`，无 Autoload 开销）：
- `DamageCalculator` — 纯数学函数，`calculate_damage()` 返回 `DamageResult`。调用方直接 `DamageCalculator.calculate_damage(...)` 使用

**实体组件**（挂载在 Player/Enemy 场景节点下）：

```
Player (CharacterBody2D)
├── HealthComponent        # HP/shield/i-frames/focus_mode/milestones
├── CombatComponent        # 战斗状态机(6状态)/combo/cat_energy
├── CollisionComponent     # Hitbox/Hurtbox Area2D 管理
├── WeaponStyleComponent   # 当前武器/武器切换
├── StatusEffectComponent  # buff/debuff(max 5)/tick
├── AbilityComponent       # 已解锁能力/冷却/空中次数
└── Sprite2D / AnimationPlayer

Enemy (CharacterBody2D)
├── HealthComponent        # 同 Player（共享脚本，不同数据）
├── AIComponent            # 行为状态机(6状态)/感知/攻击模式
├── CollisionComponent     # 同 Player
├── StatusEffectComponent  # 同 Player
└── Sprite2D / AnimationPlayer

Boss (extends Enemy)
├── BossConfigComponent    # phases/hp_thresholds/arena_changes
└── (继承 Enemy 的所有组件)
```

**场景级组件**（挂载在各场景根节点或 CanvasLayer 下）：

```
World (场景根节点)
├── HUD (CanvasLayer)
│   └── HUDManager         # HP条/菜单/Boss HP/无障碍
├── CombatPresentation     # 帧停/震屏/粒子/残影
├── MapSystem              # 迷雾/标记/小地图
├── SkillTreeManager       # 技能节点/SP/modifier/F8 cap
├── CharmEquipment         # 3 槽位/加成计算
├── ExplorationGate        # 能力门/区域解锁
├── NPCDialogue            # 对话树/条件分支
└── Player / Enemies
```

### 初始化顺序

```
project.godot Autoload 顺序:
  1. DataManager      ← 最先：其他 Autoload _ready() 可能需要数据
  2. InputManager     ← 第二：InputMap 需要在任何输入监听前就绪
  3. AudioSystem      ← 第三：总线初始化，为加载音乐准备
  4. SaveSystem       ← 第四：注册 ISerializable 系统的接口
  5. SceneManager     ← 最后：加载首个场景（hub）

Scene Tree _ready() 顺序（自上而下）:
  World._ready()
  → 子节点按 scene tree 顺序初始化
  → Player._ready() → 各 Component._ready()
  → Enemy._ready() → 各 Component._ready()
  → HUD._ready() → HUDManager._ready()
  → CombatPresentation._ready()
```

### 通信规则

```
┌──────────────────────────────────────────────────────────────┐
│  规则                                                         │
├──────────────────────────────────────────────────────────────┤
│  1. Component → Autoload: 直接方法调用（Autoload 是全局可访问）│
│  2. Autoload → Component: 仅通过信号（Autoload 不知道具体组件）│
│  3. Component → Component (同实体): 直接方法调用              │
│  4. Component → Component (跨实体): 通过信号                  │
│  5. Presentation → 任何: 仅监听信号，不调用方法               │
│  6. Foundation Autoload → 任何 Core/Feature: 禁止            │
└──────────────────────────────────────────────────────────────┘
```

### Key Interfaces

```gdscript
# Autoload 公开接口（所有 Component 可直接调用）

# DataManager
func get_domain(domain_name: StringName) -> DataDomain
func get_entry(domain: StringName, entry_id: StringName) -> Variant
func get_tuning(knob_id: StringName, default: Variant) -> Variant

# InputManager
func is_action_pressed(action: StringName) -> bool
func is_action_just_pressed(action: StringName) -> bool
func clear_buffer() -> void
signal action_triggered(action_id: StringName, metadata: Dictionary)
signal device_changed(old: StringName, new: StringName)

# AudioSystem
func play_sfx(sfx_id: StringName, position: Vector2 = Vector2.ZERO, volume_db: float = 0.0) -> void
func play_music(music_id: StringName, fade_in_sec: float = 1.0) -> void
func set_bus_volume(bus_name: StringName, volume_percent: int) -> void

# SaveSystem
func register_serializable(system_name: StringName, system: ISerializable) -> void
func save_game(slot: int = 0) -> bool
func load_game(slot: int) -> bool

# SceneManager
func change_scene(scene_id: StringName, spawn_point: StringName = &"default") -> void
func get_current_scene() -> StringName

# DamageCalculator（静态工具类，非 Autoload）
class_name DamageCalculator
static func calculate_damage(
    attack_type: StringName, weapon_id: StringName,
    hit_frame: int, combo_index: int, parry_timing: int,
    attack_power: int, enemy_defense: int,
    skill_modifiers: Dictionary
) -> DamageResult

# ISerializable 接口（所有需要存档的系统必须实现）
# 参考 ADR-0008 获取完整接口定义
@abstract
class_name ISerializable
extends RefCounted

func serialize() -> Dictionary:
    return {}

func deserialize(data: Dictionary, version: int) -> void:
    pass
```

> ⚠️ **Variant 返回值注意**: `DataManager.get_entry()` 返回 `Variant`，在 Godot 4.6+ required types 下需实现时验证 `Variant` 返回 null 是否仍被允许。如不允许，改为返回 `Dictionary` + `has_entry()` 前置检查。

### Architecture Diagram

```
project.godot Autoload Chain:
  DataManager → InputManager → AudioSystem → SaveSystem → SceneManager
       │              │             │             │             │
       │              │             │             │             │
       ▼              ▼             ▼             ▼             ▼
  ┌─ Scene Tree ──────────────────────────────────────────────────┐
  │  World                                                         │
  │  ├── Player/                                                   │
  │  │   ├── HealthComponent ──calls──→ DataManager.get_tuning()   │
  │  │   ├── CombatComponent ──calls──→ InputManager.is_action_*() │
  │  │   │                   ──calls──→ DamageCalculator.calc()    │
  │  │   │                   ──signal──→ AudioSystem.play_sfx()    │
  │  │   ├── CollisionComponent                                    │
  │  │   └── ...                                                   │
  │  ├── Enemies/                                                  │
  │  │   ├── AIComponent ──calls──→ DataManager.get_entry()        │
  │  │   └── ...                                                   │
  │  ├── HUD/                                                      │
  │  │   └── HUDManager ──listens──→ Health.on_hp_changed          │
  │  └── CombatPresentation ──listens──→ Combat.on_attack_hit      │
  └────────────────────────────────────────────────────────────────┘
```

## Alternatives Considered

### Alternative A: 最小 Autoloads（仅 DataManager + InputManager）
- **Description**: 仅 Foundation 层系统作为 Autoload。SaveSystem、SceneManager、AudioSystem 作为场景组件，每次场景切换时重建
- **Pros**: 最少的全局状态，最高可测试性
- **Cons**: AudioManager 音乐在场景切换时中断（需要跨场景持久）；SaveSystem 需要全局注册表但作为组件无法在场景外存活；SceneManager 本身负责场景切换，不能是被切换的场景的一部分
- **Rejection Reason**: SaveSystem、AudioSystem、SceneManager 的跨场景持久性需求使它们不适合做场景组件

### Alternative B: 重量级 Autoloads（大部分系统 Autoload 化）
- **Description**: Foundation + Core + 部分 Feature 系统全部作为 Autoload
- **Pros**: 全局可访问，无需信号连接
- **Cons**: HealthSystem/CombatSystem 作为 Autoload 无法支持多实体（需要实体 ID 查表）；可测试性极差（测试必须 mock 全部 Autoload）；违反 Godot 组件化最佳实践
- **Rejection Reason**: 多实体需求（Player + N Enemies）使 Core 层系统必须是组件而非单例

### Alternative C: DamageCalculator 作为 Autoload
- **Description**: DamageCalculator 与 DataManager 等并列作为第 6 个 Autoload
- **Pros**: 统一访问模式
- **Cons**: 纯函数无状态不需要全局生命周期；增加 Autoload 初始化链长度；LP 审查指出这是 overkill
- **Rejection Reason**: 无状态纯函数更适合 `class_name` 静态工具类

## Consequences

### Positive
- **Foundation 层全局可用**: DataManager/InputManager 在任何场景、任何组件中可直接访问
- **跨场景持久**: 音乐不中断、存档系统不丢失状态、场景管理器可执行异步预加载
- **Core 层可测试**: HealthComponent/CombatComponent 可独立实例化，无需完整场景树
- **多实体支持**: 每个 Entity 拥有独立的 Component 实例，共享脚本但数据隔离
- **DamageCalculator 零开销**: 纯静态函数，无节点开销，无初始化顺序依赖

### Negative
- **Autoload 间隐式依赖**: 5 个 Autoload 的初始化顺序在 `project.godot` 中硬编码，修改顺序可能导致启动崩溃
- **Component 注册成本**: SaveSystem 需要在启动时注册所有 ISerializable 组件，需要额外的注册机制
- **调试路径更长**: Component → Autoload → Component 的调用链比全 Autoload 模式更难追踪

### Risks
- **Autoload 初始化失败传播**: 如果 DataManager._ready() 失败（如 manifest.json 缺失），后续 Autoload 的 _ready() 可能级联失败。**缓解**: DataManager 进入 ERROR 状态但不崩溃，其他 Autoload 检查 DataManager 状态后优雅降级
- **Component 注册遗漏**: 如果某个 Component 忘记向 SaveSystem 注册，其状态不会被存档。**缓解**: SaveSystem 在首次 save_game() 时输出注册表清单到控制台供调试
- **Godot 4.6+ Required Types**: Autoload 接口方法的参数和返回值必须类型安全。**缓解**: 所有 Autoload 接口使用强类型（StringName, int, Dictionary），不使用 nullable Variant

## GDD Requirements Addressed

| GDD System | Requirement | How This ADR Addresses It |
|------------|-------------|--------------------------|
| data-balance.md | DataManager Autoload 单例 (TR-data-001) | DataManager 作为 Autoload #1，全局唯一入口 |
| data-balance.md | 热重载系统 Debug 构建 (TR-data-003) | DataManager 内部管理 Timer 轮询 |
| input.md | 统一输入抽象层 (TR-input-001) | InputManager 作为 Autoload #2 |
| input.md | 输入缓冲队列 (TR-input-002) | InputManager 内部管理 buffer 数组 |
| damage-calculation.md | 无状态纯函数流水线 (TR-dmg-001) | DamageCalculator 作为 class_name 静态类 |
| health-death.md | HP 状态机 + i-frames (TR-hd-001) | HealthComponent 挂载在每个实体下 |
| health-death.md | Boss 阶段转换 (TR-hd-002) | HealthComponent 内部管理 phase_thresholds |
| feline-combat.md | 6 状态战斗状态机 (TR-combat-001) | CombatComponent 挂载在 Player 下 |
| save-system.md | ISerializable 接口 (TR-save-001) | SaveSystem Autoload 协调注册和调用 |
| scene-management.md | 异步加载 + 过渡动画 (TR-scene-001) | SceneManager Autoload 管理场景生命周期 |
| audio-system.md | 5 总线架构 (TR-audio-001) | AudioSystem Autoload 管理 AudioServer |
| architecture.md | Foundation 零游戏逻辑 (Principle #2) | DataManager/InputManager 不引用 Core 系统 |

## Performance Implications

- **CPU**: 5 个 Autoload 的 `_process()` 开销极小（DataManager 仅 Debug 构建轮询；InputManager 仅读取 Input 状态；AudioSystem 仅在播放时处理；SaveSystem/SceneManager 无 _process）
- **Memory**: 5 个 Autoload 节点 + 各自数据结构。DataManager 缓存所有 JSON 域（预计 <5MB）。AudioSystem 音效池 16 个 AudioStreamPlayer（<1MB）
- **Load Time**: Autoload 初始化链在首个场景加载前执行。DataManager 同步加载 manifest + preload 域（<500ms）。总 Autoload 初始化预计 <1 秒
- **Network**: N/A（单人游戏）

## Migration Plan

无需迁移——这是第一个 ADR，无现有代码。实现时按以下顺序创建脚本：
1. `res://src/foundation/data_manager.gd` + 注册到 project.godot
2. `res://src/foundation/input_manager.gd` + 注册
3. `res://src/foundation/damage_calculator.gd`（class_name，不注册）
4. `res://src/presentation/audio_system.gd` + 注册
5. `res://src/feature/save_system.gd` + 注册
6. `res://src/feature/scene_manager.gd` + 注册
7. `res://src/core/health_component.gd`（组件脚本，不注册）
8. 其他 Core 组件脚本

## Validation Criteria

- [ ] 5 个 Autoload 在 `project.godot` 中按正确顺序注册
- [ ] DataManager._ready() 在 InputManager._ready() 之前执行
- [ ] SceneManager._ready() 在所有其他 Autoload 之后执行
- [ ] DamageCalculator 可通过 `DamageCalculator.calculate_damage(...)` 静态调用
- [ ] HealthComponent 可在无 Autoload 的 GdUnit4 测试中独立实例化
- [ ] AudioSystem 音乐在场景切换时不中断
- [ ] SaveSystem 可协调 3+ 个 ISerializable 系统的序列化/反序列化

## Related Decisions

- `docs/architecture/architecture.md` — 5 层架构定义、Module Ownership Map
- ADR-0002 (待写): 事件/信号通信模式 — 定义 Autoload↔Component 的信号规范
- ADR-0003 (待写): 数据管理架构 — DataManager 内部实现细节
- ADR-0008 (待写): 存档序列化模式 — ISerializable 接口和注册机制细节
