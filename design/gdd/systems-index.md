# Systems Index: 废土喵影 (Cat Shadow Wasteland)

> **Status**: Approved
> **Created**: 2026-06-18
> **Last Updated**: 2026-06-18
> **Source Concept**: design/gdd/game-concept.md
> **Technical Director Review (TD-SYSTEM-BOUNDARY)**: CONCERNS (accepted — boundaries revised) [2026-06-18]
> **Producer Review (PR-SCOPE)**: OPTIMISTIC (accepted — MVP split into Core/Extension) [2026-06-18]

---

## Overview

《废土喵影》是一款2D横版像素ACT + 银河城探索游戏，核心循环为：探索→战斗→发现→升级→Boss→据点。需要26个系统支撑完整体验，分为Foundation/Core/Feature/Presentation四层。MVP（20-30分钟Demo）分两步交付：核心16系统（3-4个月）+ 扩展5系统（第4-5个月），另有5系统推迟到垂直切片阶段。

**设计原则**：先验证手感（第1个月6个系统+1个房间+1个敌人），再铺系统。美术产能是Solo开发者最大瓶颈，系统数量不是KPI——16系统打磨到位 > 26系统能跑但手感平庸。

---

## Systems Enumeration

| # | System Name | Category | Priority | Layer | Status | Depends On |
|---|-------------|----------|----------|-------|--------|------------|
| 1 | 输入系统 | Core | MVP核心 | Foundation | Needs Revision | design/gdd/input.md | — |
| 2 | 数据/平衡基础设施 | Core | MVP核心 | Foundation | Designed | design/gdd/data-balance.md | — |
| 3 | 伤害计算系统 | Core | MVP核心 | Foundation | Needs Revision | design/gdd/damage-calculation.md | — |
| 4 | 生命与死亡检测系统 | Core | MVP核心 | Core | Needs Revision | design/gdd/health-death.md | 伤害计算 |
| 5 | 猫科战斗系统 | Gameplay | MVP核心 | Core | Needs Revision | design/gdd/feline-combat.md | 输入, 碰撞判定, 伤害计算 |
| 6 | 碰撞与判定系统 | Core | MVP核心 | Core | Designed | design/gdd/collision-detection.md | 输入 |
| 7 | AI框架 | Gameplay | MVP核心 | Core | Designed | design/gdd/ai-framework.md | 伤害计算, 生命检测, 碰撞 |
| 8 | 武器流派系统 | Gameplay | MVP核心 | Core | Needs Revision | design/gdd/weapon-styles.md | 猫科战斗, 伤害计算 |
| 9 | Boss配置层 | Gameplay | MVP核心 | Core | Needs Revision | design/gdd/boss-config.md | AI框架, 生命检测 |
| 10 | 存档系统 | Persistence | MVP核心 | Feature | Designed | design/gdd/save-system.md | ISerializable接口 |
| 11 | 场景管理系统 | Core | MVP核心 | Feature | Designed | design/gdd/scene-management.md | — |
| 12 | 死亡与重生系统 | Gameplay | MVP核心 | Feature | Designed | design/gdd/death-respawn.md | 生命检测(on_death信号) |
| 13 | HUD/UI系统 | UI | MVP核心 | Presentation | Needs Revision | design/gdd/hud-ui.md | 生命, 战斗, 技能 |
| 14 | 战斗表现系统 | UI | MVP核心 | Presentation | Designed | design/gdd/combat-presentation.md | 猫科战斗(on_hit信号) |
| 15 | 音效系统 | Audio | MVP核心 | Presentation | Designed | design/gdd/audio-system.md | 战斗, 场景 |
| 16 | 探索与能力门控系统 | Gameplay | MVP核心 | Feature | Needs Revision | design/gdd/exploration-ability-gating.md | 玩家能力, 世界状态 |
| 17 | 状态效果系统 | Gameplay | MVP扩展 | Core | Designed | design/gdd/status-effects.md | 生命检测, 伤害计算 |
| 18 | 玩家能力系统 | Core | **MVP核心** | Core | Needs Revision | design/gdd/player-abilities.md | — |
| 19 | 护符/装备系统 | Progression | MVP扩展 | Feature | Needs Revision | design/gdd/charm-equipment.md | 状态效果, 数值平衡 |
| 20 | NPC对话系统 | Narrative | MVP扩展 | Feature | Designed | design/gdd/npc-dialogue.md | 世界状态 |
| 21 | 地图系统 | UI | MVP扩展 | Feature | Needs Revision | design/gdd/map-system.md | 场景管理, 世界状态 |
| 22 | 技能树系统 | Progression | 垂直切片 | Feature | **Approved** | design/gdd/skill-tree.md | 武器流派, 数值平衡 |
| 23 | 商店系统 | Economy | 垂直切片 | Feature | Not Started | 数值平衡 |
| 24 | 快速旅行系统 | Core | 垂直切片 | Feature | Not Started | 场景管理, 世界状态 |
| 25 | 任务系统 | Narrative | 垂直切片 | Feature | Not Started | NPC对话, 世界状态 |
| 26 | 世界状态系统 | Persistence | 垂直切片 | Feature | Not Started | 存档, 场景管理 |
| 27 | 玩家移动系统 | Core | MVP核心 | Foundation | Not Started | 输入 |
| 28 | 场景叙事物件 | Narrative | MVP扩展 | Feature | Not Started | 场景管理 |

---

## Categories

| Category | Systems |
|----------|---------|
| **Core** | 输入, 碰撞判定, 场景管理, 数据基础设施, 玩家能力, 快速旅行 |
| **Gameplay** | 猫科战斗, AI框架, 武器流派, Boss配置, 死亡重生, 探索门控, 状态效果 |
| **Progression** | 技能树, 护符/装备 |
| **Economy** | 商店 |
| **Persistence** | 存档, 世界状态 |
| **UI** | HUD/UI, 战斗表现, 地图 |
| **Audio** | 音效 |
| **Narrative** | NPC对话, 任务 |

---

## Dependency Map

### Foundation Layer (no dependencies)
1. **输入系统** — 所有交互的基础，多平台映射
2. **数据/平衡基础设施** — JSON/Resource加载+热重载，所有数值系统的基座
3. **伤害计算系统** — 纯公式引擎，输出final_damage+metadata

### Core Layer (depends on Foundation)
1. **生命与死亡检测** — 拥有is_dead标志，发出on_death信号
2. **碰撞与判定** — Hitbox/Hurtbox帧级控制
3. **猫科战斗** — 状态机+动作执行+输入消费，含弹反/闪避子系统。发出on_hit_confirmed信号
4. **玩家能力** — 能力注册/解锁/查询接口
5. **状态效果** — 眩晕/中毒/增益，含护盾子系统
6. **AI框架** — 统一行为树引擎（小怪+Boss共用）
7. **武器流派** — 武器战斗机制（技能树归Feature层）
8. **Boss配置层** — AI框架的配置层，非独立系统

### Feature Layer (depends on Core)
1. **技能树** — 统一负责所有武器技能解锁/升级
2. **护符/装备** — Build构建，装备效果
3. **探索与能力门控** — 查询玩家能力系统决定开门
4. **商店** — 买卖逻辑，库存
5. **快速旅行** — 传送点解锁，传送逻辑
6. **NPC对话** — 碎片对话，NPC状态
7. **任务** — 任务追踪，完成条件（查询世界状态只读接口）
8. **地图** — 迷雾，标记
9. **世界状态** — 严格范围：只拥有世界几何变更的持久化（捷径/Boss/区域解锁）
10. **存档** — ISerializable接口，各系统自实现序列化
11. **场景管理** — 区域加载/卸载/过渡
12. **死亡与重生** — 消费on_death信号，执行影化消散+据点复活

### Presentation Layer (depends on Core/Feature)
1. **战斗表现** — 消费on_hit_confirmed信号，执行帧停/震屏/残影/粒子
2. **音效** — 打击音效、环境音、Boss主题
3. **HUD/UI** — 血条、技能CD、小地图、菜单

---

## Recommended Design Order

| Order | System | Priority | Layer | Est. Effort |
|-------|--------|----------|-------|-------------|
| 1 | 输入系统 | MVP核心 | Foundation | S |
| 2 | 数据/平衡基础设施 | MVP核心 | Foundation | S |
| 3 | 伤害计算系统 | MVP核心 | Foundation | S |
| 4 | 碰撞与判定系统 | MVP核心 | Core | M |
| 5 | 生命与死亡检测系统 | MVP核心 | Core | S |
| 6 | 猫科战斗系统 | MVP核心 | Core | **L** |
| 7 | 战斗表现系统 | MVP核心 | Presentation | M |
| 8 | 音效系统 | MVP核心 | Presentation | M |
| 9 | AI框架 | MVP核心 | Core | **L** |
| 10 | 武器流派系统 | MVP核心 | Core | M |
| 11 | Boss配置层 | MVP核心 | Core | M |
| 12 | 场景管理系统 | MVP核心 | Feature | S |
| 13 | 死亡与重生系统 | MVP核心 | Feature | S |
| 14 | 存档系统 | MVP核心 | Feature | M |
| 15 | 探索与能力门控系统 | MVP核心 | Feature | M |
| 16 | HUD/UI系统 | MVP核心 | Presentation | **L** |
| 17 | 玩家能力系统 | MVP扩展 | Core | M |
| 18 | 状态效果系统 | MVP扩展 | Core | S |
| 19 | 护符/装备系统 | MVP扩展 | Feature | M |
| 20 | NPC对话系统 | MVP扩展 | Feature | S |
| 21 | 地图系统 | MVP扩展 | Feature | M |
| 22 | 技能树系统 | 垂直切片 | Feature | **L** |
| 23 | 商店系统 | 垂直切片 | Feature | S |
| 24 | 快速旅行系统 | 垂直切片 | Feature | S |
| 25 | 任务系统 | 垂直切片 | Feature | M |
| 26 | 世界状态系统 | 垂直切片 | Feature | M |

**Effort**: S=1会话, M=2-3会话, L=4+会话

---

## Circular Dependencies

- **无循环依赖** ✅ 所有依赖关系单向流动

## Architectural Contracts (per TD review)

- **ISerializable接口**：所有系统自实现serialize()/deserialize()，Save System只负责调用+写文件
- **信号数据流**：Health→on_death→Death & Respawn→World State（单向）
- **信号数据流**：Combat→on_hit_confirmed→Combat Presentation（单向）
- **查询接口**：Exploration查询Player Ability的has_ability()；Quest查询World State的只读接口
- **modifier provider**：Skill Tree向Combat注册modifier provider，Combat通过接口获取技能加成

---

## High-Risk Systems

| System | Risk Type | Risk Description | Mitigation |
|--------|-----------|-----------------|------------|
| 猫科战斗 | Design | 手感不"爽"=全盘失败 | Tier 1原型：第1个月1房间+1敌人验证30秒循环 |
| 战斗表现 | Design | 帧停/震屏时机不对=打击感消失 | 与战斗系统同步迭代，尽早集成测试 |
| AI框架 | Technical | 行为树复杂度超出预期 | 精简版MVP只支持巡逻/追击/攻击3种行为 |
| 美术产能 | Scope | 动画工作量≈9个月全职 | 4方向→2方向、白盒测试、程序化动画 |

---

## Progress Tracker

| Metric | Count |
|--------|-------|
| Total systems identified | 28 |
| Design docs started | 22 |
| Design docs reviewed | 0 |
| Design docs approved | 0 |
| MVP核心 systems designed | **17/17** ✅ |
| MVP扩展 systems designed | 4/6 |
| MVP扩展 systems designed | 0/6 |
| 垂直切片 systems designed | 1/5 |

---

## Next Steps

- [x] Review and approve this systems enumeration ✅
- [ ] Design MVP核心 systems first: `/design-system input` → `/design-system feline-combat` → ...
- [ ] Run `/design-review` on each completed GDD
- [ ] Run `/gate-check systems-design` when MVP systems are designed
- [ ] Validate highest-risk systems with `/prototype combat` before committing to Production
