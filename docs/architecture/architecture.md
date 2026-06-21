# 废土喵影 (Cat Shadow Wasteland) — Master Architecture

## Document Status
- Version: 1.0
- Last Updated: 2026-06-21
- Engine: Godot 4.6.3 (GDScript)
- GDDs Covered: 22 system GDDs (input, data-balance, damage-calculation, health-death, feline-combat, collision-detection, ai-framework, weapon-styles, boss-config, save-system, scene-management, death-respawn, hud-ui, combat-presentation, audio-system, exploration-ability-gating, status-effects, player-abilities, charm-equipment, npc-dialogue, map-system, skill-tree)
- ADRs Referenced: None yet (15 required, see Required ADRs section)
- Review Mode: full
- Technical Director Sign-Off: 2026-06-21 — APPROVED WITH CONCERNS (15 ADRs需逐个生成；无障碍延迟到P3)
- Lead Programmer Feasibility: CONCERNS ACCEPTED (11项concerns, 0 blockers; HIGH: C5状态机→ADR#5引用GDD; MEDIUM: C1所有权→ADR#1, C3帧停→ADR#5, C6结构→ADR#3)

## Engine Knowledge Gap Summary

**Engine**: Godot 4.6.3 | **LLM Training Covers**: ~4.3 | **Post-Cutoff**: 4.4, 4.5, 4.6

**HIGH RISK**: UI 双焦点系统 (4.6) — mouse/touch 与 keyboard/gamepad 焦点分离，影响所有菜单和 HUD 交互。

**MEDIUM RISK**: Input SDL3 驱动 (4.5), Resources duplicate_deep (4.5), 2D Navigation Server (4.5), Rendering Shader Baker/SMAA (4.5)。

**关键决策**: 2D 物理仍为 Godot Physics 2D（Jolt 仅 3D），TileMapLayer 在 4.3（训练数据内），Audio API 稳定。

---

## System Layer Map

```
┌─────────────────────────────────────────────────────────────────┐
│  PRESENTATION LAYER (表现层)                                     │
│  #13 HUD/UI ⚠️, #14 战斗表现, #15 音效                           │
├─────────────────────────────────────────────────────────────────┤
│  FEATURE LAYER (功能层)                                          │
│  #10 存档, #11 场景管理, #12 死亡重生, #16 探索门控,              │
│  #19 护符/装备, #20 NPC对话, #21 地图, #22 技能树,               │
│  #23 商店(未), #24 快速旅行(未), #25 任务(未), #26 世界状态(未),  │
│  #28 场景叙事物件(未)                                             │
├─────────────────────────────────────────────────────────────────┤
│  CORE LAYER (核心层)                                             │
│  #4 生命/死亡, #5 猫科战斗, #6 碰撞判定, #7 AI框架,              │
│  #8 武器流派, #9 Boss配置, #17 状态效果, #18 玩家能力,           │
│  #27 玩家移动(未)                                                │
├─────────────────────────────────────────────────────────────────┤
│  FOUNDATION LAYER (基础层)                                       │
│  #1 输入 ⚠️, #2 数据/平衡, #3 伤害计算                           │
├─────────────────────────────────────────────────────────────────┤
│  PLATFORM LAYER (平台层)                                         │
│  Godot 4.6.3 Engine API, SDL3 Input, 2D Physics,                │
│  Audio Server, Rendering Pipeline                                │
└─────────────────────────────────────────────────────────────────┘
```

### Layer Rules

1. **上层可调用下层**：Presentation → Feature → Core → Foundation → Platform
2. **下层不可调用上层**：Foundation 不知道 Core 的存在
3. **同层可互相调用**：Core 层系统之间可通过信号通信
4. **跨层通信仅通过信号或接口**：避免直接方法调用跨越2层以上

---

## Module Ownership Map

### Communication Pattern

- **Foundation → Core**: 信号（`action_triggered`, `domain.changed`）+ 直接方法调用
- **Core ↔ Core**: 信号为主（`on_hit_confirmed`, `on_hp_changed`, `on_focus_mode_changed`），少数直接方法调用（`calculate_damage()`, `apply_damage()`）
- **Core → Feature**: 信号（`on_death`, `boss_defeated`）
- **Feature ↔ Feature**: 查询接口（`has_ability()`, `get_scene_state()`）
- **Core/Feature → Presentation**: 纯信号消费（`on_hit`, `on_hp_changed`, `on_boss_phase_change`）
- **Presentation → 任何层**: 禁止（Presentation 不向上调用）

### Foundation Modules

**InputManager**: Owns 动作映射/缓冲队列/设备状态/ combo_counter. Exposes `action_triggered`信号/查询接口/clear_buffer. Engine: `Input`, `InputMap`, `InputEvent`, `InputEventJoypadButton` ⚠️SDL3.

**DataManager**: Owns JSON域缓存/TuningKnobRegistry/热重载. Exposes `get_domain()`/`get_entry()`/`get_tuning()`/`changed`信号. Engine: `FileAccess`(4.4: store_*返回bool), `JSON`, `Timer`.

**DamageCalculator**: Owns DC-F1~F9公式/连招倍率表/弹反倍率表. Exposes `calculate_damage()→{final_damage, metadata}`. 纯数学，无引擎依赖.

### Core Modules

**HealthSystem**: Owns HP/shield/EntityState/i-frames/milestones/focus_mode/Boss phases. Exposes `apply_damage()`/`get_hp_percentage()`/`revive()`/`grant_iframes()` + 5个信号. Engine: `Timer`.

**CombatSystem**: Owns 战斗状态机(6状态)/current_weapon/combo_index/cat_energy/animation_lock. Exposes `on_attack_hit`信号/`get_battle_stats()`. Consumes Input/DamageCalc/Collision/WeaponStyles/SkillTree/Health(focus). Engine: `AnimationPlayer`, `Timer`.

**CollisionSystem**: Owns Hitbox列表/Hurtbox状态/hit跟踪. Exposes `activate_hitbox()`/`set_hurtbox_state()`/`on_hit_confirmed`信号. Engine: `Area2D`, `CollisionShape2D`.

**AISystem**: Owns 行为状态机(6状态)/感知参数/攻击模式/windup_extension. Exposes `get_active_enemy_count()`. Consumes DamageCalc/Health(focus+phase)/Collision/DataManager. Engine: `RayCast2D`, `NavigationAgent2D`(可选) ⚠️2D Nav 4.5.

**WeaponStyleManager**: Owns 4武器配置/升级等级. Exposes `get_weapon_config()`/`weapon_swap()`.

**StatusEffectManager**: Owns 效果列表(max5)/tick计时. Exposes `apply_status()`/`get_movement_modifier()`/`get_damage_modifier()`. Engine: `Timer`.

**PlayerAbilityManager**: Owns 能力列表/冷却/空中次数. Exposes `has_ability()`/`unlock_ability()`. Engine: `Timer`.

### Feature Modules

**SaveSystem**: Owns 槽位(3+1)/.bak/版本号. Exposes `save_game()`/`load_game()`/`register_serializable()`. Engine: `FileAccess`, `JSON`.

**SceneManager**: Owns 场景注册表/异步加载/过渡动画/驻留限制(2). Exposes `change_scene()`/`preload_scene()`. Engine: `ResourceLoader`(async), `SceneTree`.

**SkillTreeManager**: Owns 节点状态(3态)/SP余额/modifier注册/T3-T5互斥/F8统一cap. Exposes `get_modifiers()`/`get_stat_bonus()`/`has_skill()`/F8 combined_bonus.

### Presentation Modules

**HUDManager** ⚠️HIGH: Owns HUD布局/菜单状态(6态)/无障碍. Exposes `show_hud()`/`show_menu()`/`update_hp()`. Engine: `Control`, `CanvasLayer`, `Theme` ⚠️4.6双焦点.

**CombatPresentation**: Owns 帧停/震屏/粒子/残影/闪白生命周期. 纯消费层. Engine: `Camera2D`, `GPUParticles2D`, `Tween`, `CanvasModulate`.

**AudioSystem**: Owns 5总线/音效池(max16)/音乐状态机/空间衰减. Exposes `play_sfx()`/`play_music()`/`set_bus_volume()`. Engine: `AudioStreamPlayer`, `AudioStreamPlayer2D`, `AudioServer`.

---

## Data Flow

### Frame Update Path (每帧 _physics_process)

1. **InputManager**: 读取原始输入 → 缓冲检查 → 发射 `action_triggered`
2. **CombatSystem**: 消费动作 → 更新状态机 → 调用 Collision 管理 Hitbox
3. **CollisionSystem**: 检测 Hitbox-Hurtbox 重叠 → 发射 `on_hit_confirmed`
4. **CombatSystem**: 监听命中 → 调用 `DamageCalculator.calculate_damage()`
5. **HealthSystem**: `apply_damage()` → HP更新 → 信号链: `on_hp_changed` → `on_hp_milestone` → `on_boss_phase_change` → `on_focus_mode_changed` → `on_death`
6. **Presentation**: 各系统监听信号 → 触发视觉/音频效果

### Signal Architecture

**信号 (异步, 一对多通知)**:
- `on_hit_confirmed` (Collision → Combat)
- `on_hp_changed`, `on_death`, `on_boss_phase_change`, `on_hp_milestone`, `on_focus_mode_changed` (Health → multiple)
- `on_attack_hit` (Combat → Presentation)
- `device_changed` (Input → HUD)
- `ability_unlocked` (Ability → HUD)
- `domain.changed` (DataManager → consumers)

**直接调用 (同步, 需要返回值)**:
- `calculate_damage()` (Combat → DamageCalc)
- `apply_damage()` (Combat → Health)
- `has_ability()` (Exploration → Ability)
- `get_modifiers()` (Combat → SkillTree)
- `get_active_enemy_count()` (Health → AI)
- `get_weapon_config()` (Combat → WeaponStyles)

**禁止**: Presentation → Core/Feature/Foundation (上层不调下层)

### Save/Load Path

**Save**: SaveSystem → 遍历 ISerializable 系统 → 各系统 `serialize()→Dictionary` → JSON写入 `user://saves/slot_N.json` (先备份.bak)

**Load**: SaveSystem → 读取JSON → 版本验证+迁移 → 各系统 `deserialize(data)` → SceneManager.change_scene → emit `game_loaded`

**ISerializable 系统**: Health, Combat, WeaponStyles, Abilities, SkillTree, Charms, SceneManager, ExplorationGate, NPCDialogue

### Initialization Order

**Autoload (project.godot)**: DataManager → InputManager → DamageCalculator → AudioManager → SceneManager

**Scene Tree (_ready, top-down)**: World → Player(Combat/Health/Collision/Weapon/Ability/Status) → Enemies(AI) → HUD(CanvasLayer) → CombatFX → Audio

## API Boundaries

### ISerializable (存档接口)
所有存档系统实现 `serialize()→Dictionary` 和 `deserialize(data: Dictionary)→void`。SaveSystem保证data已验证，实现方保证返回值可JSON序列化。建议使用 `@abstract` (4.5+) 强制继承。

### DamageCalculator (伤害计算)
`calculate_damage(attack_type, weapon_id, hit_frame, combo_index, parry_timing, attack_power, enemy_defense, skill_modifiers) → DamageResult`
纯函数，无状态。DamageResult包含: final_damage(int,1-999), is_crit, crit_type, is_parry, parry_type, combo_stage, damage_category。

### HealthSystem (生命系统)
写入: `apply_damage(entity_id, final_damage, metadata)`, `revive(entity_id)`, `grant_iframes(entity_id, frames)`
查询: `get_hp_percentage(entity_id)→float`, `is_alive(entity_id)→bool`
信号: `on_hp_changed`, `on_death`, `on_boss_phase_change`, `on_hp_milestone`, `on_focus_mode_changed`

### SkillTree Modifier (技能树加成)
`register_modifier(skill_id, type, target_action, stat_key, operation, value, condition)`
`get_modifiers(action_id)→Array[Modifier]`, `get_stat_bonus(stat_key)→float`
F8: `get_combined_bonus(stat_key, charm_bonus)→float` — 乘法递减, cap 0.75

### Signal Data Contracts
- `on_hit_confirmed`: {hitbox_id, hit_position, hit_frame, attack_metadata}
- `on_death`: {last_hit{...}, battle_stats{...}, context{zone_id, enemy_type, boss_phase}}
- `on_hp_changed`: (entity_id, current_hp, max_hp)

### Engine Type Versions
- `signal`, `StringName`, `@export`, `class_name`, `Area2D`, `GPUParticles2D`: 4.0+ ✅
- `@abstract`: 4.5+ ⚠️ (推荐用于ISerializable)
- Required return types: 4.6+ ⚠️ HIGH (nullable不再隐式允许)

## ADR Audit

**现有 ADR**: 无 | **TR覆盖率**: 0/55 → 全部需新建

## Required ADRs

### Must Have Before Coding (P0-P1)

| # | ADR Title | Layer | Key TRs |
|---|-----------|-------|---------|
| 1 | Autoload架构与初始化顺序 | Foundation | TR-input-001, TR-data-001 |
| 2 | 事件/信号通信模式 | Foundation | 全局信号架构 |
| 3 | 数据管理架构 (DataManager, JSON, 热重载) | Foundation | TR-data-001~005 |
| 4 | 碰撞检测架构 (Area2D Hitbox/Hurtbox) | Core | TR-collision-001~003 |
| 5 | 战斗状态机架构 | Core | TR-combat-001~004 |
| 6 | AI行为系统架构 | Core | TR-ai-001~003 |
| 7 | 场景管理架构 (异步加载, 过渡, 内存) | Feature | TR-scene-001~002 |

### Should Have Before System Built (P2)

| # | ADR Title | Layer | Key TRs |
|---|-----------|-------|---------|
| 8 | 存档序列化模式 (ISerializable) | Feature | TR-save-001~003 |
| 9 | 技能树Modifier系统架构 | Feature | TR-skill-001~004 |
| 10 | 音频系统架构 (总线, 池化, 空间) | Presentation | TR-audio-001~003 |
| 11 | UI焦点管理策略 (4.6双焦点) ⚠️HIGH | Presentation | TR-hud-001~003 |
| 12 | 2D物理引擎选择 | Platform | 确认Godot Physics 2D |

### Can Defer (P3)

| # | ADR Title |
|---|-----------|
| 13 | 像素艺术渲染管线 (SMAA, Shader Baker) |
| 14 | 移动端输入适配策略 |
| 15 | 无障碍实现方案 (AccessKit, 色盲模式) |

## Architecture Principles

1. **信号解耦，方法同步** — 一对多通知用信号，需要返回值用直接方法调用。Presentation层永远不向上调用。
2. **Foundation零游戏逻辑** — DataManager/InputManager/DamageCalculator不知道任何Core层系统的存在。它们提供能力，不消费游戏状态。
3. **数据驱动优先** — 所有游戏数值来自DataManager的JSON域。不调硬编码。旋钮通过TuningKnobRegistry集中管理。
4. **ISerializable自管理** — 每个系统自己知道怎么序列化/反序列化。SaveSystem只负责协调调用和文件I/O。
5. **引擎抽象边界** — 直接引擎API调用限制在模块内部。模块间通信使用游戏级类型（int, float, Dictionary），不传递Node引用。

## Open Questions

| ID | Summary | Priority | Resolution Path |
|----|---------|----------|-----------------|
| QQ-01 | UI双焦点(4.6)对菜单导航的具体影响需验证 | High | ADR #11 + 原型测试 |
| QQ-02 | ~~NavigationAgent2D是否为AI寻路所需~~ | ~~Medium~~ | ✅ Resolved by ADR-0006 (不使用 NavigationAgent2D，手动关卡设计) |
| QQ-03 | SDL3手柄驱动对自定义震动模式的支持程度 | Medium | ADR #2 + 原型测试 |
| QQ-04 | 移动端触控输入与PC/手柄的架构统一程度 | Medium | ADR #14 |
| QQ-05 | Shader Baker是否对像素艺术渲染有启动时间收益 | Low | ADR #13 |
