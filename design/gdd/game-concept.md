# Game Concept: 废土喵影 (Cat Shadow Wasteland)

*Created: 2026-06-18*
*Status: Approved*

> **Creative Director Review (CD-PILLARS)**: APPROVED (after revision) [2026-06-18]
> **Art Director Review (AD-CONCEPT-VISUAL)**: APPROVED [2026-06-18]
> **Technical Director Review (TD-FEASIBILITY)**: CONCERNS (accepted) [2026-06-18]
> **Producer Review (PR-SCOPE)**: OPTIMISTIC (accepted with adjustments) [2026-06-18]

---

## Elevator Pitch

> 一款横版2D像素ACT，玩家扮演末世猫武士探索机械废土、击败变异生物、解锁能力、揭开人类消失的真相。像《空洞骑士》的银河城探索遇上猫科战斗美学，在可爱与危险的视觉反差中体验技巧优先的硬核动作。

---

## Core Identity

| Aspect | Detail |
| ---- | ---- |
| **Genre** | 2D横版ACT + 银河城探索 (Metroidvania) |
| **Platform** | 多平台（PC首发 → 移动端第二批 → 主机第三批） |
| **Target Audience** | 硬核2D动作游戏爱好者，喜欢挑战性Boss战和非线性探索 |
| **Player Count** | 单人 |
| **Session Length** | 30-120分钟（自然停止点：击败Boss后、回到据点后、解锁新能力后） |
| **Monetization** | Premium（买断制） |
| **Estimated Scope** | Large (14-20个月，solo developer) |
| **Comparable Titles** | 《空洞骑士》《死亡细胞》《洛克人》 |

---

## Core Fantasy

**成为一只技艺精湛的猫武士，在危险世界中通过技巧取胜。**

玩家体验猫科动物的敏捷、好奇和致命——快速出击、灵活闪避、精准时机。每一次胜利都来自对敌人模式的理解和操作技巧的掌握，而非数值碾压。探索未知区域、发现隐藏秘密、逐步揭开人类消失后的真相，用猫的眼睛看这个机械废土世界。

---

## Unique Hook

**像《空洞骑士》，而且你扮演一只猫，有多种武器流派，设定在末世机械废土。**

"并且"测试通过：
- 像《空洞骑士》的银河城探索和硬核Boss战
- **而且** 你是猫武士，多种武器流派各有特色（猫爪反击流、长尾刃范围流、鱼骨大剑暴击流、电磁铃铛控制流）
- **而且** 设定在人类消失后的机械废土，猫族对抗机械鼠军团
- **而且** 50%可爱+50%危险的视觉反差——猫的温暖柔软与机械废土的冰冷锈蚀形成对比

这个钩子影响玩法（多种武器流派改变战斗策略），不只是美学。

---

## Player Experience Analysis (MDA Framework)

### Target Aesthetics (What the player FEELS)

| Aesthetic | Priority | How We Deliver It |
| ---- | ---- | ---- |
| **Challenge** (mastery) | 1 (Primary) | 技巧优先的Boss战、敌人模式学习、弹反/闪避时机 |
| **Discovery** (exploration) | 2 | 隐藏房间、秘密通道、环境叙事、能力解锁打开新路线 |
| **Fantasy** (role-playing) | 3 | 扮演猫武士、猫科动作美学、末世世界观 |
| **Sensation** (sensory) | 4 | 像素艺术、打击感（帧停、震屏、音效）、流畅动画 |
| **Narrative** (story) | 5 | 环境叙事、物品描述、NPC碎片对话、主动发现故事 |
| **Expression** (creativity) | 6 | 多种武器Build、护符组合、玩法风格选择 |
| **Fellowship** (social) | N/A | 单人游戏 |
| **Submission** (relaxation) | N/A | 硬核挑战，非放松向 |

### Key Dynamics (Emergent player behaviors)

- **玩家会实验不同武器组合**，找到适合自己的Build
- **玩家会主动探索每个角落**，因为隐藏回报改变后续选择空间
- **玩家会在Boss战后分享成就**，因为胜利来自技巧掌握
- **玩家会讨论环境叙事细节**，拼凑出完整故事

### Core Mechanics (Systems we build)

1. **快速流畅战斗系统** — 猫科动作基因（扑击、翻滚、反击），4种武器流派，命中停顿、帧级动画控制
2. **非线性探索系统** — 银河城式能力门控、隐藏房间、捷径、地图迷雾
3. **技巧优先成长系统** — 击败挑战获得能力、护符/遗物Build构建、技巧优于数值
4. **环境叙事系统** — 场景布置、物品描述、NPC碎片对话、可解读的信号/痕迹
5. **多阶段Boss战** — 每个Boss 3阶段、攻击模式学习、弹反/闪避窗口

---

## Player Motivation Profile

### Primary Psychological Needs Served (SDT)

| Need | How This Game Satisfies It | Strength |
| ---- | ---- | ---- |
| **Autonomy** (freedom, meaningful choice) | 选择探索路线、选择武器Build、选择战斗方式 | Core |
| **Competence** (mastery, skill growth) | Boss战技巧掌握、能力解锁后的操作精度提升 | Core |
| **Relatedness** (connection, belonging) | 与猫族NPC的情感联系、对猫武士身份的代入 | Supporting |

### Player Type Appeal (Bartle Taxonomy + Quantic Foundry)

- [x] **Achievers** (goal completion, collection, progression) — 收集护符、解锁全地图、击败所有Boss
- [x] **Explorers** (discovery, understanding systems, finding secrets) — 隐藏房间、秘密通道、环境叙事
- [ ] **Socializers** (relationships, cooperation, community) — 单人游戏，社交元素弱
- [x] **Killers/Competitors** (domination, mastery) — 挑战高难度Boss、追求无伤通关

**Quantic Foundry 动机集群**:
- 主要：Challenge (竞争/挑战) + Discovery (探索/发现)
- 次要：Mastery (精通/技巧) + Completion (完成/收集)

### Flow State Design

- **Onboarding curve**: 前10分钟通过环境引导学习基础操作（跑、跳、攻击），不需要显式UI教程。第一个房间是安全的练习场，第二个房间引入第一个敌人，第三个房间要求闪避。
- **Difficulty scaling**: 敌人模式从简单（单一攻击）到复杂（多段组合），Boss战有明确的3阶段递进。每个新区域引入新敌人类型，但之前区域的敌人仍会出现（让玩家感受自己的成长）。
- **Feedback clarity**: 打击感反馈（帧停、震屏、音效）让玩家知道命中了；敌人攻击前摇让玩家知道该闪避了；死亡后快速重试让玩家立即应用学到的教训。
- **Recovery from failure**: 死亡后在最近存档点复活，无惩罚（无经验值损失、无装备耐久）。失败是教育性的——玩家每次死亡都学到敌人模式的一部分。

---

## Core Loop

### Moment-to-Moment (30 seconds)

**战斗节奏**：发现敌人 → 接近 → 快速连击（爪击三段）→ 闪避反击 → 击杀 → 获得资源/掉落。高级玩家：观察敌人前摇 → 完美闪避 → 弹反 → 暴击 → 连招终结。

**探索节奏**：进入新区域 → 观察环境 → 发现隐藏通道/房间 → 解开小谜题或击败守卫 → 获得奖励。

**满足感来源**：命中停顿、震屏、打击音效、粒子效果、发现秘密。

### Short-Term (5-15 minutes)

```
探索区域 → 遇敌战斗 → 获得资源 → 发现捷径/存档点 → 挑战小Boss → 进入新区域
```

"再来一次"心理钩子：
- "这个房间看起来有隐藏通道"
- "击败这组敌人后宝箱会掉什么？"
- "前面有个存档点，再往前探索一点"
- "这个小Boss打赢后能解锁什么？"

### Session-Level (30-120 minutes)

完整Session：从据点出发 → 探索1-2个区域 → 击败1个Boss → 回到据点升级 → 解锁新路线 → （可选）继续探索或退出。

自然停止点：击败Boss后（成就感高点）、回到据点后（升级完成）、解锁新能力后（想测试新能力）。

离开游戏时的想法：
- "我知道那里有个隐藏房间打不开，等我有二段跳再来"
- "我想试试新武器打下一关"
- "下一个区域会发生什么？"

### Long-Term Progression

**玩家成长维度**：
- **力量成长**：新能力（冲刺、二段跳、下劈）、武器升级、技能树解锁
- **知识成长**：学习敌人模式、发现地图秘密、理解剧情
- **选项成长**：更多武器选择、更多Build组合、更多探索路线
- **故事成长**：揭开人类消失真相、找到猫王、理解旧世界AI

**长期目标**：主线通关（击败最终Boss）、100%地图探索、收集所有护符/遗物、解锁所有武器和技能。

**游戏"完成"时机**：主线故事结束 + （可选）新游戏+或100%完成度。

### Retention Hooks

- **Curiosity**: 未打开的区域（能力门控）、未发现的隐藏房间、未拼凑的故事碎片
- **Investment**: 已解锁的能力、已探索的地图、已收集的护符Build
- **Social**: N/A（单人游戏，但玩家会分享Boss战成就和发现）
- **Mastery**: 未击败的Boss、未完成的无伤挑战、未尝试的武器Build

---

## Game Pillars

### Pillar 1: 猫科战斗美学 (Feline Combat Aesthetics)
战斗像猫一样——快速出击、灵活闪避、精准时机。利用速度和体型取胜，而非蛮力。4种武器流派各有特色，但共享猫科动作基因。每种武器流派是一种猫科捕猎策略的延伸——爪=反击流、尾=范围流、牙=暴击流、铃铛=控制流。

*Design test*: 如果我们在"蛮力硬抗"和"猫式灵活闪避+精准反击"之间选择，这个支柱说我们选择**猫式灵活**。

### Pillar 2: 机制探索回报 (Mechanical Exploration Rewards)
像猫一样好奇地探索——每个角落都值得嗅探。好奇心在机制层面得到回报——隐藏房间通往新区域、秘密宝箱提供能力升级、捷径解锁后永久改变路线选择。探索回报必须改变玩家的后续选择空间。

*Design test*: 如果我们在"直线推进"和"需要偏离主路才能发现的机制回报"之间选择，这个支柱说我们**包含机制回报**。

### Pillar 3: 技巧优先的Earned成长 (Skill-First Earned Progression)
能力通过击败关键挑战获得（进度earned），但真正的力量来自玩家技巧提升而非数值碾压。不存在"grind就能过"的设计——每个障碍都需要理解和操作。

*Design test*: 如果我们在"数值提升通关"和"技巧掌握通关"之间选择，这个支柱说我们选择**技巧掌握**。

### Pillar 4: 可爱与危险的视觉反差 (Visual Contrast of Cute and Dangerous)
猫的温暖柔软与机械废土的冰冷锈蚀形成对比。50%可爱+50%危险——最大反差。像素画保证清晰可读，但细节丰富（16-32bit区间）。角色轮廓夸张可辨认，环境叙事丰富。

*Design test*: 如果我们在"单一色调统一风格"和"可爱vs危险的视觉反差"之间选择，这个支柱说我们选择**反差**。

### Pillar 5: 叙事融入世界 (Narrative Through World)
故事通过环境叙事（场景布置）、物品描述、NPC碎片对话、可解读的信号/痕迹展开。玩家是主动发现者，不是被动观众。这是叙事层面的探索回报——与支柱2（机制回报）分离。

*Design test*: 如果我们在"被动接收剧情（长过场动画）"和"主动发现故事（环境叙事）"之间选择，这个支柱说我们选择**主动发现**。

### Anti-Pillars (What This Game Is NOT)

- **NOT 人类主角**: 猫是核心身份，不是装饰。所有机制围绕猫的特性设计——敏捷、夜视、九命、多重武器。
- **NOT 纯线性关卡**: 银河城/探索是核心体验，不是可选元素。地图必须有分支、捷径、隐藏区域。
- **NOT 数值碾压**: 技巧优先，不是等级优先。玩家可以升级，但技术不好照样过不了Boss。
- **NOT 显式教学UI**: 所有机制通过环境引导和玩家实验习得。教学融入第一个挑战，不中断心流。

---

## Visual Identity Anchor

### 主方向：「刃光残响」

> 视觉规则：「每一帧都是攻击预告」——所有视觉元素都在暗示即将发生的动作。

**战斗场景模式（高对比度）**：
- 极度锐利的三角形主导，猫武士的耳朵、尾巴、武器轮廓全部走锐角三角几何
- 色彩服务于0.3秒信息读取：

| 色彩 | 色值 | 语义 |
|------|------|------|
| 钢青灰 | `#4A5568` | 世界基底（废土金属、建筑结构） |
| 刃白 | `#F7FAFC` | 攻击/危险（武器轨迹、弹反闪光） |
| 猫眼金 | `#ECC94B` | 玩家/安全（轮廓光、存档点、回复） |
| 信号红 | `#E53E3E` | 敌人攻击预警（蓄力闪烁） |
| 毒绿 | `#48BB78` | 变异/腐蚀（下水道生物污染标识） |

### 补充层：「锈霓共生」

> 视觉规则：「新与旧在同一像素上共存」——每个场景必须同时展示毁灭前的繁华与毁灭后的荒凉。

**探索场景模式（丰富叙事）**：
- 有机曲线（旧世界建筑）与机械直角（机械鼠改造）碰撞
- 每个区域有"旧世界色"和"现在色"双层色彩叙事：

| 色彩 | 色值 | 语义 |
|------|------|------|
| 锈蚀橙 | `#C05621` | 旧世界的余温（废弃建筑、生锈金属、黄昏光线） |
| 霓虹粉紫 | `#D53F8C` / `#805AD5` | 残存的生命力（猫族聚落装饰灯光、屋顶区主色调） |
| 月光蓝 | `#63B3ED` | 希望/真相（叙事关键物品、旧世界AI安全信号） |

### 统一原则

- **猫眼金 `#ECC94B`** 是连接两个方向的统一色——无论战斗还是探索，金色永远代表"玩家/安全/猫的归属"
- 战斗场景：环境饱和度再降20%，攻击特效和敌人预警色占主导
- 探索场景：环境细节密度提升，旧世界色彩层可见

---

## Inspiration and References

| Reference | What We Take From It | What We Do Differently | Why It Matters |
| ---- | ---- | ---- | ---- |
| **空洞骑士** | 银河城探索、环境叙事、硬核Boss战、精致像素艺术 | 猫科战斗美学（更快更灵活）、多种武器流派、末世废土主题 | 验证了"银河城+硬核ACT"的市场吸引力 |
| **恶魔城** | 探索氛围、成长感、Boss战的成就感 | 更快的战斗节奏、更清晰的信息反馈（色彩编码） | 验证了"探索+成长"的长期吸引力 |
| **洛克人** | 精准操作、Boss设计、武器获取系统 | 非纯线性关卡、探索回报、环境叙事 | 验证了"Boss战+武器获取"的核心循环 |
| **死亡细胞** | 极速流畅战斗、打击感、Roguelite重玩性 | 非Roguelite（永久进度）、银河城探索、叙事深度 | 验证了"快速流畅战斗"是ACT的命脉 |

**Non-game inspirations**:
- **《铳梦》(Battle Angel Alita)**: 废土机械美学、小个子战士的反差感
- **《风之旅人》**: 孤独美感、环境叙事的力量
- **猫的行为学**: 猫的捕猎策略（伏击、追击、玩弄猎物）直接映射到战斗设计
- **底特律/匹兹堡后工业景观**: 锈蚀金属、废弃工厂、霓虹灯残骸的视觉参考

---

## Target Player Profile

| Attribute | Detail |
| ---- | ---- |
| **Age range** | 18-35 |
| **Gaming experience** | Mid-core to Hardcore |
| **Time availability** | 30-60分钟session（工作日晚间），2-3小时（周末） |
| **Platform preference** | PC（Steam）为主，移动端为辅 |
| **Current games they play** | 《空洞骑士》《死亡细胞》《黑帝斯》 |
| **What they're looking for** | 手感扎实的2D ACT、有深度的探索、有挑战但不公平的Boss |
| **What would turn them away** | 手感飘、数值碾压代替技巧、过长的教程、纯线性关卡 |

---

## Technical Considerations

| Consideration | Assessment |
| ---- | ---- |
| **Recommended Engine** | **Godot 4.7** — 2D管线最原生、像素艺术支持完善、TileMapLayer成熟。当前项目基线已升级到 4.7；主机支持需要第三方方案（W4 Games / Pineapple Works） |
| **Key Technical Challenges** | (1) 快速流畅战斗手感——需要低延迟输入、帧级动画控制 (2) 多平台适配——PC/移动端/主机各需不同输入映射和UI适配 (3) 动画产出量——4种武器×完整动画集是最大瓶颈 |
| **Art Style** | 16-32bit像素艺术，风格化，50%可爱+50%危险反差 |
| **Art Pipeline Complexity** | High — 自定义像素动画，非asset store。预估1000-2000帧（角色+敌人+Boss+特效） |
| **Audio Needs** | Moderate — 打击音效（关键！）、环境音、背景音乐（区域主题） |
| **Networking** | None — 纯单人游戏 |
| **Content Volume** | 完整版：1据点+5区域、4武器、5Boss、8-12小时。首发版（Tier 3）：1据点+2区域、2武器、2Boss+3Mini-Boss、2小时 |
| **Procedural Systems** | None — 全手工关卡设计（银河城品类需要精心设计的路线和能力门控） |

---

## Risks and Open Questions

### Design Risks
- **战斗手感不"爽"**：ACT的命脉，如果30秒循环不好玩，一切都不成立。**缓解**：Tier 1原型专门验证手感
- **武器流派同质化**：4种武器如果玩起来感觉一样，unique hook就失败了。**缓解**：每种武器有独特的猫科捕猎策略映射
- **中期难度曲线失衡**：玩家获得太多能力后，战斗变得太简单。**缓解**：能力是"选项"不是"力量"，技巧优先设计

### Technical Risks
- **多平台适配工作量**：PC+移动端+主机 = 3倍测试矩阵。**缓解**：分阶段发布，PC首发
- **动画产能瓶颈**：Solo开发者1000-2000帧动画 ≈ 9个月全职工作。**缓解**：首发缩减至2种武器，Tier 2后评估产能
- **主机支持**：Godot无官方主机导出模板。**缓解**：主机作为第三批，需要第三方移植服务

### Market Risks
- **2D ACT市场饱和**：空洞骑士、死亡细胞、黑帝斯等强竞品。**缓解**：猫+机械废土主题有辨识度，多种武器流派是差异化
- **Solo开发者倦怠**：14-20个月长周期，第8-10个月倦怠风险显著。**缓解**：Tier 3（6-9个月）是最佳止损点，2小时垂直切片已是完整可交付物

### Scope Risks
- **内容量超出产能**：5区域+4武器+5Boss对Solo来说过多。**缓解**：优雅降级方案——3区域+3武器+4Boss仍是完整5-6小时游戏
- **Boss设计迭代成本**：每个Boss 3阶段，AI状态机复杂。**缓解**：Tier 2只1个Boss，充分迭代设计模式

### Open Questions
- **猫科动作基因的具体定义是什么？** — 需要通过Tier 1原型验证。所有武器共享的核心动作词：扑击=突进攻击、翻滚=无敌帧闪避、反击=精准时机窗口？
- **武器流派之间是互补（鼓励切换）还是独立（玩家选一个专精）？** — 需要通过玩家测试验证
- **环境叙事的"可读性"如何保证？** — 玩家能否在不看文字的情况下理解世界发生了什么？

---

## MVP Definition

**Core hypothesis**: 玩家觉得猫科战斗手感"爽"，并且有动力通过探索发现新区域和能力。

**Required for MVP (Tier 2 — 精简版)**:
1. 1个中心据点（猫族地铁站）+ 1个完整区域（废弃商业街）
2. 2种武器（猫爪 + 长尾刃）
3. 5种小怪
4. 1个Boss（垃圾桶鼠王，3阶段）
5. 4-5个技能（够展示系统深度）
6. 5个护符（展示装备机制）
7. 1个NPC + 1条任务
8. 存档系统
9. 基础地图（迷雾+标记）
10. **游戏时长：20-30分钟**

**Explicitly NOT in MVP**:
- 第3/4/5区域（扩展到2小时是Tier 3）
- 第3/4种武器（动画产能瓶颈）
- 完整技能树（4-5个技能足够验证）
- 多结局/分支叙事（单一主线即可）

### Scope Tiers (adjusted per producer review)

| Tier | Content | Features | Timeline |
| ---- | ---- | ---- | ---- |
| **Tier 1 (手感原型)** | 单武器、单敌人、单房间 | 核心战斗、基础手感（帧停、震屏） | 2-4周 |
| **Tier 2 (MVP/Demo)** | 1据点+1区域、2武器、5怪、1Boss | 核心循环完整、存档、地图、4-5技能、5护符、1NPC+1任务 | 3-4个月 |
| **Tier 3 (垂直切片)** | 1据点+2区域、2武器+完整技能树、2Boss+3Mini-Boss | 完整升级系统、完整地图、完整NPC对话和任务 | 6-9个月 |
| **Tier 4 (完整游戏)** | 1据点+3区域(缩减)、3武器(缩减)、4Boss(缩减) | 所有系统完整、5-6小时游戏时长 | 14-20个月 |

**Graceful degradation**: 如果时间不够完成Tier 4，砍至3区域+3武器+4Boss仍是完整的5-6小时游戏。最佳止损点是Tier 3（2小时垂直切片，足够参展/众筹/发行商演示）。

---

## Next Steps

- [x] ~~Get concept approval from creative-director~~ (APPROVED after revision)
- [ ] Run `/setup-engine` to configure Godot engine and populate version-aware reference docs
- [ ] Run `/art-bible` to create the visual identity specification — **required before Technical Setup gate**
- [ ] Run `/design-review design/gdd/game-concept.md` to validate concept completeness
- [ ] Run `/prototype combat` — validate core combat feel is fun before writing GDDs (Tier 1, 2-4 weeks)
- [ ] If prototype PROCEEDS: Run `/map-systems` to decompose concept into individual systems
- [ ] Run `/design-system [system-name]` for each MVP system — guided GDD writing
- [ ] Run `/create-architecture` to produce master architecture blueprint
- [ ] Run `/architecture-review` to bootstrap TR registry
- [ ] Run `/gate-check pre-production` to validate readiness
- [ ] Run `/vertical-slice` to validate full game loop (Tier 3)
