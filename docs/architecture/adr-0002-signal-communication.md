# ADR-0002: 事件/信号通信模式

## Summary
定义全项目的信号通信规范：命名约定、负载数据类型、连接模式和信号发射顺序。采用 Godot 原生信号 + `class_name` 数据类作为 payload，禁止集中事件总线。

## Status
Accepted

## Date
2026-06-21

## Engine Compatibility

| Field | Value |
|-------|-------|
| **Engine** | Godot 4.7 |
| **Domain** | Core / GDScript |
| **Knowledge Risk** | LOW — Signal API stable since 4.0 (typed signals with Callable) |
| **References Consulted** | `docs/engine-reference/godot/VERSION.md`, `docs/engine-reference/godot/current-best-practices.md` |
| **Post-Cutoff APIs Used** | None |
| **Verification Required** | None — signal pattern fully within training data |

## ADR Dependencies

| Field | Value |
|-------|-------|
| **Depends On** | ADR-0001 (Autoload架构 — 定义了 Autoload↔Component 通信规则) |
| **Enables** | ADR-0004 (碰撞检测), ADR-0005 (战斗状态机), ADR-0006 (AI行为), ADR-0008 (存档) |
| **Blocks** | 所有 Core 层实现（信号是 Core 系统间的主要通信方式） |
| **Ordering Note** | 必须在 Core 层 ADR 之前完成，因为它们定义各自的信号签名 |

## Context

### Problem Statement

架构文档和 ADR-0001 确定了"信号用于异步通知、直接调用用于同步查询"的原则。但 22 个 GDD 定义了 30+ 个信号（`on_hp_changed`, `on_death`, `on_hit_confirmed` 等），每个信号携带不同的数据。尚未统一：信号命名约定、负载数据格式（裸 Dictionary vs 类型化数据类）、连接模式、以及多信号同帧发射时的顺序保证。LP 审查指出裸 Dictionary 缺乏编译期类型检查（C9 concern）。

### Constraints

- **ADR-0001 约束**: Autoload→Component 仅信号，Component→Autoload 直接调用，Foundation 不引用 Core
- **类型安全**: Godot 4.6+ required types — nullable 参数不再隐式允许，信号 payload 也应类型化
- **性能**: 信号连接/断开不应产生每帧开销；payload 对象不应造成 GC 压力
- **GDD 一致性**: 信号名称和参数必须与 22 个 GDD 中已定义的信号保持一致

### Requirements

- 必须定义统一的信号命名约定（前缀、时态、分隔符）
- 必须为每个高频信号定义 `class_name` payload 数据类
- 必须定义信号连接的生命周期管理（何时连接、何时断开）
- 必须定义 apply_damage 中 5 个信号的发射顺序
- 必须兼容 ADR-0001 的通信规则（6 条规则）

## Decision

### 信号命名约定

```
命名模式: signal on_[noun]_[past_participle](payload: [PayloadClass])

规则:
  1. 前缀: on_ （所有信号统一）
  2. 名词: 信号主体（hp, death, hit, boss_phase, focus_mode）
  3. 动词: 过去分词（changed, confirmed, unlocked, triggered）
  4. 无参信号: 仅当 payload 为空时使用（如 on_game_loaded）

示例:
  signal on_hp_changed(event: HpChangedEvent)
  signal on_death(event: DeathEvent)
  signal on_hit_confirmed(event: HitEvent)
  signal on_boss_phase_change(event: BossPhaseEvent)  # 注: change 非过去分词，此处与 GDD 保持一致
  signal on_focus_mode_changed(active: bool)    # 简单bool不需类
  signal on_hp_milestone(entity_id: int, threshold: float)  # 2参数直接传
```

**简化规则**: payload 包含 ≤3 个字段 → 直接参数传递；payload 包含 >3 个字段 → `class_name` 数据类。

> **`on_` 前缀说明**: Godot 内置信号不使用 `on_` 前缀（如 `body_entered`, `pressed`），`on_` 在社区中通常是回调方法前缀（`_on_hp_changed`）。本项目选择信号使用 `on_` 前缀以保持与 22 个 GDD 的一致性（所有 GDD 已使用此命名），并明确区分"信号名"和"回调函数名"。回调使用 `_handle_[signal]` 而非 `_on_[signal]` 避免冗余。

### Payload 数据类

```gdscript
# 定义在 res://src/core/events/ 目录下

class_name HpChangedEvent
var entity_id: int
var current_hp: int
var max_hp: int
func _init(p_entity_id: int, p_current: int, p_max: int) -> void:
    entity_id = p_entity_id; current_hp = p_current; max_hp = p_max

class_name DeathEvent
var entity_id: int
var last_hit_damage: int
var last_hit_type: StringName
var last_hit_source: StringName
var last_hit_is_crit: bool
var battle_duration_sec: float
var damage_received: int
var damage_dealt: int
var dodge_success_rate: float
var parry_success_rate: float
var zone_id: StringName
var enemy_type: StringName
var boss_phase: int
# 构造时从 HealthComponent.battle_stats 聚合

class_name HitEvent
var attacker_id: int
var target_id: int
var hitbox_id: StringName
var hit_position: Vector2
var hit_frame: int
var attack_metadata: Dictionary  # {weapon_id, attack_type, combo_index, parry_timing}

class_name BossPhaseEvent
var boss_id: int
var phase: int
var hp_percentage: float

class_name DamageResult
var final_damage: int
var is_crit: bool
var crit_type: StringName      # "perfect" | "good" | "none"
var is_parry: bool
var parry_type: StringName     # "perfect" | "good" | "late" | "none"
var combo_stage: int
var damage_category: StringName # "scratch"|"normal"|"strong"|"powerful"|"extreme"|"legendary"
```

### 信号连接模式

```
┌─ 连接规则 ─────────────────────────────────────────────────────────┐
│                                                                     │
│  1. 同实体 Component→Component:                                     │
│     在拥有者节点的 _ready() 中直接连接                               │
│     例: Player._ready() → combat.on_attack_hit.connect(health._on_damage)│
│                                                                     │
│  2. Component→Autoload:                                             │
│     在 Component._ready() 中调用 Autoload 方法（非信号）             │
│     例: combat._ready() → InputManager.action_triggered.connect(...) │
│                                                                     │
│  3. Component→Presentation (跨层级):                                │
│     Presentation._ready() 中查找 Component 并连接信号               │
│     例: HUD._ready() → player.health.on_hp_changed.connect(...)     │
│                                                                     │
│  4. 断开时机:                                                       │
│     实体死亡时 disconnect 所有信号                                   │
│     场景切换时由 SceneTree 自动清理                                  │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### 信号发射顺序

当一个事件触发多个信号时，按以下顺序发射（同步执行）：

```gdscript
# HealthComponent.apply_damage() 中的信号发射顺序：
# 1. 状态变更信号（最具体）
on_hp_changed.emit(HpChangedEvent.new(entity_id, current_hp, max_hp))

# 2. 里程碑信号（条件触发）
if hp_pct <= threshold and threshold not in triggered_milestones:
    on_hp_milestone.emit(entity_id, threshold)

# 3. Boss阶段信号（条件触发）
if is_boss:
    while next_phase < phase_thresholds.size() and hp_pct <= phase_thresholds[next_phase]:
        on_boss_phase_change.emit(BossPhaseEvent.new(boss_id, next_phase, hp_pct))
        next_phase += 1

# 4. 专注模式信号（条件触发）
if is_player and hp_changed_focus_relevant:
    on_focus_mode_changed.emit(focus_mode_active)

# 5. 终结信号（最后发射，确保其他信号先到达监听者）
if current_hp == 0:
    on_death.emit(DeathEvent.new(...))
```

**原则**: 状态变更 → 条件信号 → 终结信号。终结信号（`on_death`）永远最后发射，确保所有"还活着"的监听者先收到状态更新。

### 禁止模式

- **禁止集中事件总线**: 不创建 EventBus Autoload。所有信号由状态变更的拥有者直接发射
- **禁止裸 Dictionary 高频 payload**: 高频信号（on_hp_changed, on_hit_confirmed）必须使用 class_name 数据类
- **禁止跨层方法调用**: Presentation 层不调用 Core 层方法，仅监听信号

## Alternatives Considered

### Alternative A: 集中事件总线 (EventBus Autoload)
- **Description**: 创建第 6 个 Autoload `EventBus`，所有信号通过它中转。系统不直接连接，而是 `EventBus.emit("on_death", data)`
- **Pros**: 完全解耦（系统互相不知道存在）；调试时可拦截所有事件
- **Cons**: 全局单点；字符串 key 易出错；性能开销（所有事件多一跳）；违反 ADR-0001 的 5 Autoload 上限
- **Rejection Reason**: 增加不必要的间接层，Godot 原生信号已提供足够的解耦

### Alternative B: 裸 Dictionary payload
- **Description**: 所有信号 payload 使用 Dictionary，如 `on_death.emit({"last_hit": {...}, "stats": {...}})`
- **Pros**: 灵活，无需定义额外类
- **Cons**: 无编译期类型检查（LP concern C9）；key 拼写错误不会报错；代码可读性差；Godot 4.6+ required types 下 Dictionary value 可能出问题
- **Rejection Reason**: class_name 数据类提供类型安全和代码补全，开发体验显著优于 Dictionary

### Alternative C: 全参数信号（无 payload 对象）
- **Description**: 所有信号使用直接参数，如 `signal on_hp_changed(entity_id: int, current_hp: int, max_hp: int)`
- **Pros**: 零对象分配；最简单的连接方式
- **Cons**: 参数 >3 个时签名过长；扩展字段需修改所有连接点；不一致（有些信号 2 参数有些 12 参数）
- **Rejection Reason**: 采用混合方案——≤3 参数直接传，>3 参数用 class_name 数据类

## Consequences

### Positive
- **类型安全**: class_name payload 在编译期检查字段名和类型
- **一致性**: 所有信号遵循 `on_[noun]_[past_participle]` 命名约定
- **性能**: 简单信号（≤3 参数）零对象分配；复杂信号仅创建一个轻量 Reference 对象
- **可扩展**: payload 类可添加新字段而不破坏已有连接（向后兼容）
- **调试友好**: 数据类在 debugger 中显示字段名，比 Dictionary 更直观

### Negative
- **代码量增加**: 需要为每个复杂信号定义 class_name 数据类（~10 个类）
- **对象分配**: 每次发射复杂信号创建一个 payload 对象（Reference，自动 GC）
- **Payload 类维护**: 修改 payload 字段需同步更新所有生产者和消费者

### Risks
- **Payload 对象 GC 压力**: 高频信号（如 on_hp_changed 每帧可能触发）创建大量短命对象。**缓解**: on_hp_changed 仅 3 个 int 参数，使用直接参数传递而非 payload 对象。其他高频信号同理
- **信号连接遗漏**: 如果 Presentation 层 _ready() 中忘记连接某个信号，该视觉反馈丢失。**缓解**: 信号连接清单作为 ADR 附件，/code-review 时检查

## GDD Requirements Addressed

| GDD System | Requirement | How This ADR Addresses It |
|------------|-------------|--------------------------|
| health-death.md | on_hp_changed, on_death, on_boss_phase_change, on_hp_milestone, on_focus_mode_changed 5 个信号 | 定义 payload 类和发射顺序 |
| feline-combat.md | on_attack_hit 信号 | 通过 HitEvent payload 传递 |
| collision-detection.md | on_hit_confirmed 信号 | 定义 HitEvent 类 + attack_metadata Dictionary |
| damage-calculation.md | calculate_damage 返回 metadata | DamageResult 类封装返回值 |
| input.md | action_triggered, device_changed 信号 | 直接参数传递（≤3 参数） |
| audio-system.md | 监听多个系统信号 | 连接模式规则 #3 |
| architecture.md | 信号 vs 直接调用规则 | 本 ADR 完整定义信号使用规范 |

## Performance Implications

- **CPU**: 信号发射本身开销极小（Godot 4 signal emit <0.01ms/次）。Payload 对象构造 <0.001ms/个。总信号开销预计 <0.1ms/帧
- **Memory**: ~10 个 class_name 数据类定义（<1KB 代码）。运行时 payload 对象为 Reference 类型，自动引用计数释放
- **Load Time**: 无影响（类定义在脚本加载时注册）
- **Network**: N/A

## Migration Plan

无需迁移——第一个信号规范 ADR。实现步骤：
1. 创建 `res://src/core/events/` 目录
2. 定义所有 payload 数据类
3. 在各 Component 中使用新信号签名
4. 在 Presentation 层 _ready() 中按规范连接信号

## Validation Criteria

- [ ] 所有信号遵循 `on_[noun]_[past_participle]` 命名
- [ ] 高频信号（>10次/秒）使用直接参数而非 payload 对象
- [ ] 复杂信号（>3 参数）使用 class_name 数据类
- [ ] apply_damage 中 5 个信号按定义顺序发射
- [ ] Presentation 层不调用 Core 层方法（仅信号）
- [ ] 无 EventBus Autoload
- [ ] GdUnit4 测试可 mock 信号 payload

## Related Decisions

- ADR-0001: Autoload架构 — 定义了 Autoload↔Component 通信规则
- `docs/architecture/architecture.md`: Signal Architecture 节
- ADR-0004 (待写): 碰撞检测 — on_hit_confirmed 的具体使用
- ADR-0005 (待写): 战斗状态机 — on_attack_hit 的具体使用
