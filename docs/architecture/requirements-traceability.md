# Architecture Traceability Index

> Last Updated: 2026-07-15
> Engine: Godot 4.7
> Source: /architecture-review 2026-06-21

## Coverage Summary

- Total requirements: 185
- Covered: 65 (35%)
- Partial: 43 (23%)
- Gaps: 77 (42%)

**Foundation layer**: 40 TRs — 28 covered, 10 partial, 2 gaps (0 blocking)
**Core layer**: 78 TRs — 35 covered, 20 partial, 23 gaps
**Feature layer**: 52 TRs — 2 covered, 8 partial, 42 gaps
**Presentation layer**: 30 TRs — 0 covered, 5 partial, 25 gaps

---

## Full Matrix

### Foundation Layer

#### Data/Balance Infrastructure (data-balance.md)

| TR-ID | Requirement | ADR Coverage | Status |
|-------|-------------|-------------|--------|
| TR-data-001 | DataManager Autoload 单例，4状态机 | ADR-0001, ADR-0003 | ✅ |
| TR-data-002 | JSON为源格式，Resource桥接，标准目录 | ADR-0003 | ✅ |
| TR-data-003 | 热重载（1秒轮询，Debug构建） | ADR-0003 | ✅ |
| TR-data-004 | Schema验证，三级失败处理 | ADR-0003 | ✅ |
| TR-data-005 | TuningKnobRegistry 集中管理 | ADR-0003 | ✅ |
| TR-data-006 | 数据版本 MAJOR.MINOR + 链式迁移 | ADR-0003 | ✅ |
| TR-data-007 | 标准接口契约（_ready/get_entry/changed） | ADR-0003 | ✅ |
| TR-data-008 | 调试面板（F12 旋钮编辑/域状态/验证错误） | ADR-0003 | ✅ |

#### Input System (input.md)

| TR-ID | Requirement | ADR Coverage | Status |
|-------|-------------|-------------|--------|
| TR-input-001 | 统一输入抽象层，12核心动作 | ADR-0001 | ✅ |
| TR-input-002 | 输入缓冲 150ms/3深度/50ms预输入 | ADR-0001 | ✅ Queue + Main/Crown runtime |
| TR-input-003 | 连招链管理 combo_counter | ADR-0001 | ⚠️ |
| TR-input-004 | Coyote Time 5-8帧 + Jump Buffer | — | ❌ |
| TR-input-005 | 平台检测 500ms防抖 | ADR-0001 | ⚠️ |
| TR-input-006 | 输入冲突解决（优先级互斥） | ADR-0001 | ⚠️ |
| TR-input-007 | 三状态 FSM (DIRECT/BUFFERING/TRANSITIONING) | — | ✅ |
| TR-input-008 | action_triggered 信号 + metadata | ADR-0001, ADR-0002 | ✅ |
| TR-input-009 | device_changed 信号 | ADR-0001, ADR-0002 | ✅ |
| TR-input-010 | 键位映射存储 user://input_bindings.cfg | ADR-0001 | ⚠️ |
| TR-input-011 | 8个旋钮注册 TuningKnobRegistry | ADR-0003 | ✅ |
| TR-input-012 | 查询接口（is_action_pressed/strength/duration） | ADR-0001 | ✅ |

#### Damage Calculation (damage-calculation.md)

| TR-ID | Requirement | ADR Coverage | Status |
|-------|-------------|-------------|--------|
| TR-damage-001 | 三步伤害流水线，纯函数无状态 | ADR-0001 | ✅ |
| TR-damage-002 | 确定性暴击窗口（PERFECT/GOOD/NORMAL） | ADR-0001 | ⚠️ |
| TR-damage-003 | 连招倍率查表（4武器×3段） | ADR-0001 | ⚠️ |
| TR-damage-004 | 弹反4档倍率（5.0×/2.5×/1.5×/1.0×） | ADR-0001 | ⚠️ |
| TR-damage-005 | 防御减伤递减曲线 60/(defense+60) | ADR-0001 | ⚠️ |
| TR-damage-006 | final_damage clamp(1,999) + damage_multiplier | ADR-0001 | ✅ |
| TR-damage-007 | 特殊招式独立倍率 DC-F9 | ADR-0001 | ⚠️ |
| TR-damage-008 | calculate_damage 输出 metadata | ADR-0002 | ✅ |
| TR-damage-009 | F9 weapon_base 覆盖（技能树） | — | ❌ Gap: needs Skill Tree ADR |
| TR-damage-010 | DC-F5 暴击窗口扩展（护符+专注模式） | ADR-0005 | ⚠️ |
| TR-damage-011 | 空中/蓄力攻击第三路径 | ADR-0001 | ⚠️ |

#### Collision Detection (collision-detection.md)

| TR-ID | Requirement | ADR Coverage | Status |
|-------|-------------|-------------|--------|
| TR-collision-001 | 帧级 Hitbox/Hurtbox 碰撞检测 | ADR-0004 | ✅ |
| TR-collision-002 | Hitbox 帧级精度控制 | ADR-0004 | ✅ |
| TR-collision-003 | Hurtbox 三状态 (normal/shrunk/gone) | ADR-0004 | ✅ |
| TR-collision-004 | 5层碰撞分层 | ADR-0004 | ✅ |
| TR-collision-005 | on_hit_confirmed + mark_hit 防重复 | ADR-0004, ADR-0002 | ✅ |
| TR-collision-006 | 同帧多 Hurtbox 独立触发 | ADR-0004 | ✅ |
| TR-collision-007 | 死亡时自动停用 Hitbox | ADR-0004 | ✅ |
| TR-collision-008 | Area2D + CollisionShape2D 实现 | ADR-0004 | ✅ |
| TR-collision-009 | 调试可视化 F4 切换 | ADR-0004 | ✅ |

---

### Core Layer

#### Health & Death Detection (health-death.md)

| TR-ID | Requirement | ADR Coverage | Status |
|-------|-------------|-------------|--------|
| TR-health-001 | HP状态管理 current_hp/max_hp/shield | ADR-0001 | ⚠️ |
| TR-health-002 | apply_damage 伪代码防护 | ADR-0001 | ⚠️ |
| TR-health-003 | 护盾优先吸收 | — | ❌ |
| TR-health-004 | Boss阶段转换 while 循环 | — | ❌ |
| TR-health-005 | HP里程碑阈值 4档 | ADR-0002 | ⚠️ |
| TR-health-006 | 专注模式（HP≤25%+active_enemies） | ADR-0006 | ⚠️ |
| TR-health-007 | 专注模式激活视觉/音效 | ADR-0002, ADR-0010, ADR-0019 | ✅ |
| TR-health-008 | 专注模式4项感知变化 | ADR-0006, ADR-0010, ADR-0019 | ✅ Complete implementation: Story154/157/158/159 cover activation, Boss windup, attack-tell amplification and environment-particle reduction; Audio Story010 adds the traced low-frequency damped hurt mix. Subjective listening sign-off remains manual review. |
| TR-health-009 | i-frame管理 max不叠加 | — | ❌ |
| TR-health-010 | on_death 扩展元数据 | ADR-0002 | ✅ |
| TR-health-011 | 信号发射顺序 5级 | ADR-0002 | ✅ |
| TR-health-012 | max_hp 最终计算 HD-F0 | — | ❌ |
| TR-health-013 | revive() 重置 focus_mode | — | ❌ |
| TR-health-014 | 受伤音效音调偏移 HD-F4 | — | ❌ |
| TR-health-015 | 探索叙事接口钩子 | — | ❌ |

#### Feline Combat (feline-combat.md)

| TR-ID | Requirement | ADR Coverage | Status |
|-------|-------------|-------------|--------|
| TR-combat-001 | 6状态战斗状态机 | ADR-0005 | ✅ |
| TR-combat-002 | 3段连招帧参数 | ADR-0005 | ✅ |
| TR-combat-003 | 闪避i-frame 帧3-10 | ADR-0005 | ✅ |
| TR-combat-004 | 弹反18帧窗口4档 | ADR-0005 | ✅ |
| TR-combat-005 | 动作取消规则表 | ADR-0005 | ✅ |
| TR-combat-006 | 输入协调 animation_lock/unlock | ADR-0005, ADR-0002 | ✅ |
| TR-combat-007 | 猫气系统 max100 | ADR-0005 | ✅ |
| TR-combat-008 | 特殊招式双重约束 | ADR-0005 | ✅ |
| TR-combat-009 | 极意技T5门控 | — | ❌ Needs Skill Tree ADR |
| TR-combat-010 | 专注模式暴击窗口+1帧 | ADR-0005 | ✅ |
| TR-combat-011 | 受击硬直叠加 | ADR-0005 | ⚠️ |
| TR-combat-012 | 蓄力攻击 0.5-1.5秒 | ADR-0005 | ⚠️ |

#### AI Framework (ai-framework.md)

| TR-ID | Requirement | ADR Coverage | Status |
|-------|-------------|-------------|--------|
| TR-ai-001 | 6状态行为状态机 | ADR-0006 | ✅ |
| TR-ai-002 | 感知锥 RayCast2D | ADR-0006 | ✅ |
| TR-ai-003 | 数据驱动攻击模式 | ADR-0006, ADR-0003 | ✅ |
| TR-ai-004 | on_boss_phase_change 监听 | ADR-0006, ADR-0002 | ✅ |
| TR-ai-005 | on_focus_mode_changed 前摇延长 | ADR-0006, ADR-0002 | ✅ |
| TR-ai-006 | get_active_enemy_count() | ADR-0006 | ✅ |
| TR-ai-007 | activate_hitbox() 调用 | ADR-0006, ADR-0004 | ✅ |
| TR-ai-008 | startup→Hitbox 帧级同步 | ADR-0006 | ⚠️ |
| TR-ai-009 | 低HP行为适应 | ADR-0006 | ⚠️ |
| TR-ai-010 | 加权随机攻击选择 | ADR-0006 | ⚠️ |

#### Weapon Styles (weapon-styles.md) — ❌ No ADR

| TR-ID | Requirement | ADR Coverage | Status |
|-------|-------------|-------------|--------|
| TR-weapon-001~007 | 4武器定义/切换/特殊/升级 | — | ❌ 7 gaps |

#### Status Effects (status-effects.md) — ❌ No ADR

| TR-ID | Requirement | ADR Coverage | Status |
|-------|-------------|-------------|--------|
| TR-status-001~006 | 7种效果/施加/DoT/i-frame/优先级 | — | ❌ 6 gaps |

#### Player Abilities (player-abilities.md) — ❌ No ADR

| TR-ID | Requirement | ADR Coverage | Status |
|-------|-------------|-------------|--------|
| TR-ability-001~006 | 能力注册/查询/冷却/解锁 | — | ❌ 6 gaps |

#### Boss Config (boss-config.md) — ❌ No ADR

| TR-ID | Requirement | ADR Coverage | Status |
|-------|-------------|-------------|--------|
| TR-boss-001~007 | 阶段/转换/召唤/竞技场/免疫/动态防御/奖励 | ADR-0006(部分) | ⚠️ 部分覆盖 |

---

### Feature Layer

#### Scene Management (scene-management.md)

| TR-ID | Requirement | ADR Coverage | Status |
|-------|-------------|-------------|--------|
| TR-scene-001~008 | 注册表/异步加载/延迟卸载/状态持久化/Boss锁定/快速传送/超时 | ADR-0007 | ✅ |

#### Save System (save-system.md) — ❌ No ADR (P2-#8 planned)

| TR-ID | Requirement | ADR Coverage | Status |
|-------|-------------|-------------|--------|
| TR-save-001 | ISerializable 接口模式 | ADR-0001 | ⚠️ Interface defined |
| TR-save-002~007 | 数据结构/槽位/备份/迁移/触发/异步 | — | ❌ 6 gaps |

#### Death & Respawn (death-respawn.md) — ✅ Implemented

| TR-ID | Requirement | ADR Coverage | Status |
|-------|-------------|-------------|--------|
| TR-respawn-001 | 死亡延迟、重生、复活与控制恢复流程 | ADR-0001, ADR-0002, ADR-0019 | ✅ Story001/002/008 |
| TR-respawn-002 | 存档点、聚落、Boss入口重生优先级 | ADR-0007 | ✅ Story003/004/007 |
| TR-respawn-003 | Boss死亡重置竞技场状态与Boss HP | ADR-0007 | ✅ Story003 |
| TR-respawn-004 | 可选猎人教学战斗总结 | ADR-0002, ADR-0019 | ✅ Story005 |
| TR-respawn-005 | 金钱、物品与进度无损失 | ADR-0007 | ✅ Story006 |
| TR-respawn-006 | 死亡到恢复控制总预算小于5.5秒 | ADR-0001 | ✅ Story001/008 |
| TR-respawn-007 | 复活后2秒无敌与可见反馈 | ADR-0019 | ✅ Story002/008 |

#### Skill Tree (skill-tree.md) — ❌ No ADR (P2-#9 planned)

| TR-ID | Requirement | ADR Coverage | Status |
|-------|-------------|-------------|--------|
| TR-skill-001~012 | 结构/T3互斥/SP经济/洗点/Modifier/F7-F10/猫魂/极意/探索 | — | ❌ 12 gaps |

#### Exploration Gating — ❌ No ADR

| TR-ID | Requirement | ADR Coverage | Status |
|-------|-------------|-------------|--------|
| TR-explore-001~006 | 能力门/5类型/完成度/隐藏房/捷径/自动检查 | — | ❌ 6 gaps |

#### Charm/Equipment — ❌ No ADR

| TR-ID | Requirement | ADR Coverage | Status |
|-------|-------------|-------------|--------|
| TR-charm-001~006 | 3槽/伤害注入/crit窗口/持久化/安全区/上限 | — | ❌ 6 gaps |

#### NPC Dialogue — ❌ No ADR

| TR-ID | Requirement | ADR Coverage | Status |
|-------|-------------|-------------|--------|
| TR-npc-001~005 | 对话树/状态/事件/6状态/UI | — | ❌ 5 gaps |

#### Map System — ❌ No ADR

| TR-ID | Requirement | ADR Coverage | Status |
|-------|-------------|-------------|--------|
| TR-map-001~005 | 小地图/全地图/迷雾/标记/完成度 | — | ❌ 5 gaps |

---

### Presentation Layer

#### Combat Presentation (combat-presentation.md) — ⚠️ Runtime integration in progress

| TR-ID | Requirement | ADR Coverage | Status |
|-------|-------------|-------------|--------|
| TR-combatfx-001~009 | 帧停/震屏/粒子/残影/伤害数字/闪白/性能/色盲/专注模式 | ADR-0001, ADR-0002, ADR-0004, ADR-0005, ADR-0016 | ⚠️ Stories 001-023 implement the tracked presentation slices. Story021 Main, Story022 Crown Warden, and [Story023 Sluice Matriarch](../../production/epics/combat-presentation/story-023-sluice-matriarch-real-hitstop-input-buffer.md) verify real hitstop/input integration; [Story023 evidence](../../production/qa/evidence/sluice-matriarch-real-hitstop-input-buffer-2026-07-15.md). Remaining independent combat scenes keep the Epic open. |

#### Audio System (audio-system.md) — ❌ No ADR (P2-#10 planned)

| TR-ID | Requirement | ADR Coverage | Status |
|-------|-------------|-------------|--------|
| TR-audio-001~009 | 5总线/16音效池/2D空间/音乐切换/合并/监听/状态机/淡出/pitch | ADR-0001(接口) | ⚠️ |

#### HUD/UI (hud-ui.md) — ❌ No ADR (P2-#11 planned)

| TR-ID | Requirement | ADR Coverage | Status |
|-------|-------------|-------------|--------|
| TR-hud-001~008 | 7元素/6可见性/菜单/动画/色盲/缩放/性能/11屏幕 | — | ❌ 8 gaps |

---

## Known Gaps

### Foundation Layer (0 blocking)
- TR-input-004: Coyote Time + Jump Buffer — implement in InputManager, no ADR needed
- TR-input-007: Input FSM states — implementation detail

### Core Layer (non-blocking, evaluate per system)
- Weapon Styles: 7 TRs — extend ADR-0005 or write standalone ADR
- Status Effects: 6 TRs — write P2 ADR (independent component)
- Player Abilities: 6 TRs — write P2 ADR (independent component)
- Boss Config: 7 TRs — extend ADR-0006
- Health system details: 8 TRs — extend ADR-0001 or write dedicated ADR

### Feature Layer (P2 ADRs planned)
- Save System: P2-#8 planned
- Skill Tree: P2-#9 planned
- Charm/Equipment, Death/Respawn, Exploration, NPC, Map: add to planned ADRs

### Presentation Layer (P2 ADRs planned)
- Audio: P2-#10 planned
- HUD/UI: P2-#11 planned (HIGH priority — 4.6 dual focus)
- Combat Presentation: consolidate implemented Story coverage into a dedicated
  Presentation ADR before closing the Epic
