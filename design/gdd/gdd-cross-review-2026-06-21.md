# Cross-GDD Review Report

> **Date**: 2026-06-21
> **GDDs Reviewed**: 22 系统 GDD + game-concept + systems-index = 24
> **Systems Covered**: 输入, 数据/平衡, 伤害计算, 生命/死亡检测, 猫科战斗, 碰撞判定, AI框架, 武器流派, Boss配置, 存档, 场景管理, 死亡重生, HUD/UI, 战斗表现, 音效, 探索门控, 状态效果, 玩家能力, 护符/装备, NPC对话, 地图, 技能树
> **Engine**: Godot 4.6.3
> **Entity Registry**: 3 formulas + 8 constants (部分填充)
> **Pillars**: 猫科战斗美学, 机制探索回报, 技巧优先的Earned成长, 可爱与危险的视觉反差, 叙事融入世界
> **Anti-Pillars**: NOT 人类主角, NOT 纯线性关卡, NOT 数值碾压, NOT 显式教学UI

---

## Consistency Issues

### Blocking (must resolve before architecture begins)

#### 🔴 B-1: Boss弹反倍率三方矛盾

**涉及GDD**: boss-config.md × damage-calculation.md

- `boss-config.md` Edge Cases: "Boss被弹反：受到**4.0×**伤害但不进入STUN（Boss免疫眩晕）"
- `boss-config.md` AC: "GIVEN Boss被弹反, WHEN 弹反成功, THEN 受到**4.0×**伤害但不进入STUN"
- `damage-calculation.md` DC-F7: PERFECT弹反 = **5.0×**（全局统一，无Boss例外）
- `damage-calculation.md` Rule 4: PERFECT弹反 = **5.0×**

**问题**: Boss弹反到底是4.0×还是5.0×？如果Boss有特殊减免，damage-calculation需要声明；如果已统一为5.0×，boss-config需要修正。

**建议**: 确定权威值后统一两处。如果Boss确实使用4.0×（设计意图是Boss弹反回报略低于小怪），则在 damage-calculation DC-F7 添加 Boss 例外条款。

---

#### 🔴 B-2: 疾风连爪伤害倍率矛盾

**涉及GDD**: weapon-styles.md × damage-calculation.md

- `weapon-styles.md` Rule 3 特殊招式表: "疾风连爪：0.5秒内连续5次快速攻击（每次**50%**伤害）"
- `damage-calculation.md` DC-F9: special_multiplier = **0.8**（每次**80%**伤害, 总倍率4.0×）

**问题**: 每击是50%还是80%？总倍率是2.5×还是4.0×？两个GDD必须统一。

**建议**: damage-calculation.md 经过4轮Design Review，DC-F9 数值（0.8×5=4.0×）已被充分验证。建议更新 weapon-styles.md Rule 3 以匹配 DC-F9。

---

#### 🔴 B-3: 暴击护符(charm_crit)与确定性暴击系统不兼容

**涉及GDD**: charm-equipment.md × damage-calculation.md

- `charm-equipment.md` 规则1: charm_crit = "**暴击率+5%**"
- `charm-equipment.md` Rule 4: `final_crit_rate = base + charm_crit_bonus`（概率模型）
- `damage-calculation.md` Rule 2: 暴击是**确定性时机窗口**（PERFECT/GOOD/NORMAL），无随机概率
- `damage-calculation.md` Dependencies Open Question: 已明确标注"charm_crit 必须从'+N% 暴击率'改为'暴击窗口+N帧'。在 charm-equipment 完成修复前，charm_crit 护符不可实现"

**问题**: charm-equipment.md 的 charm_crit 定义和 Rule 4 公式仍使用概率模型，与伤害计算系统的确定性暴击机制根本矛盾。charm_crit 护符在当前设计下**不可实现**。

**建议**: 将 charm_crit 效果改为"暴击窗口+1帧"或类似，删除 Rule 4 中的 `final_crit_rate` 公式，改为声明 charm_bonus 通过 skill-tree F8 统一上限公式进入伤害流水线。

---

#### 🔴 B-4: 专注模式反杀工具缺失——猫科战斗未实现on_focus_mode_changed

**涉及GDD**: health-death.md × feline-combat.md × skill-tree.md

- `health-death.md` Rule 8: "反杀工具（如暴击窗口加成）由猫科战斗系统和技能树通过 `on_focus_mode_changed` 信号接口提供，不在本系统职责内"
- `feline-combat.md`: **未声明监听** `on_focus_mode_changed` 信号，**未定义**任何专注模式下的反杀机制
- `skill-tree.md`: 也**未声明**专注模式相关加成

**问题**: 专注模式目前只提供防御端/感知端优势（前摇延长、预兆放大）。设计意图声明的"反杀工具"被推给两个系统，但两个系统均未实现。低血量时策略空间窄——只能保守等待，不能积极反杀。

**建议**: 在 feline-combat.md 中添加 `on_focus_mode_changed` 信号监听声明，定义至少1个轻量进攻回报（如专注模式下暴击窗口+1-2帧）。skill-tree.md 中可预留接口但无需当前实现节点。

---

### Warnings (should resolve, but won't block)

#### ⚠️ W-1: damage-calculation ↔ skill-tree 双向依赖不对称

- `damage-calculation.md` Dependencies 上游: 列出 "技能树系统 — F9 提供 skill_weapon_base"
- `skill-tree.md` Dependencies 下游: 列出 "伤害计算系统 — 被动加成注入流水线"
- 但 `skill-tree.md` Dependencies **上游**未列出 damage-calculation
- skill-tree F6 引用 DC-F3 reduction_factor，F9 替换 DC-F1 的 weapon_base

→ skill-tree.md 应声明 damage-calculation 为上游引用依赖。

---

#### ⚠️ W-2: active_enemies_count 来源系统未定义

- `health-death.md` Rule 2/8 引用 `active_enemies_count` 判断战斗状态
- `health-death.md` Open Question #7 已标记此问题
- Dependencies 中写"战斗/遭遇管理系统（待定义）"
- 无任何已设计GDD负责维护此值

→ 需要指定负责系统（建议由 AI框架 或 场景管理 系统维护）或在现有系统中添加此职责。

---

#### ⚠️ W-3: 猫气消耗三方不一致

- `weapon-styles.md` Rule 3 特殊招式表: **未提及猫气消耗**，只列冷却时间
- `feline-combat.md` Rule 7: 疾风连爪=30猫气, 旋风斩=40, 地裂斩=50, 电磁脉冲=60; 极意技全部=80
- `skill-tree.md` Rule 4: 极意技消耗80猫气（引用feline-combat）

→ weapon-styles.md 是"武器参数权威"但完全缺失猫气消耗列。应补充猫气消耗列或明确声明"猫气消耗由 feline-combat.md 规则7定义"。

---

#### ⚠️ W-4: 区域完成度公式双重所有权

- `exploration-ability-gating.md`: `area_completion = (secrets + shortcuts + enemies) / totals`，权重 hub=0.5/normal=1.0/boss=1.5
- `map-system.md`: **完全相同的公式和权重**

→ 建议指定 exploration-ability-gating 为权威来源，map-system 声明为引用。

---

#### ⚠️ W-5: dodge_cooldown_sec 双重Tuning Knob

- `feline-combat.md` Tuning Knobs: dodge_cooldown_sec = 0.5
- `player-abilities.md` Tuning Knobs: dodge_cooldown_sec = 0.5

→ 建议指定 feline-combat 为权威（它管理闪避执行），player-abilities 删除此旋钮或声明为引用。

---

#### ⚠️ W-6: HP加成所有权冲突

- `skill-tree.md` F7: HP加成 cap = +25
- `health-death.md` Tuning Knobs: player_max_hp = 100 (50-500)
- `charm-equipment.md`: charm_life = +20 HP (flat)

→ health-death.md 应声明为 max_hp 的最终计算者，明确公式: `max_hp = base_hp + skill_hp_bonus + charm_hp_bonus`。

---

#### ⚠️ W-7: 输入系统Space键上下文映射歧义

- `input.md` Rule 2 默认键位表: Space = **jump**
- `input.md` Rule 2 情境分离: "Space键：地面=**dodge**，空中=jump"
- 银河城游戏中跳跃是最频繁操作，地面Space=dodge可能严重影响键盘玩家体验

→ 手柄不受影响（A=jump, B=dodge）。键盘端需要明确：地面跳跃的替代键位是什么？已在Open Questions中标注"Tier 1原型验证"。

---

#### ⚠️ W-8: damage-calculation 未声明 charm-equipment 为上游依赖

- `damage-calculation.md` Dependencies 上游: 列出 skill-tree (F8 combined_bonus), 但未列出 charm-equipment
- charm_bonus 通过 skill-tree F8 公式进入伤害流水线

→ 建议在 damage-calculation Dependencies 中添加 charm-equipment 为间接数据源说明。

---

#### ⚠️ W-9: hud-ui.md 保留已废弃的 low_hp_pulse_period 旋钮

- `hud-ui.md` Tuning Knobs: low_hp_pulse_period = 1.0 (0.5-2.0)
- 但 `hud-ui.md` Rule 4 和 `health-death.md` 均明确: 低HP时 "**不脉动**"（CD-GDD-ALIGN决定）

→ 应删除此旋钮或标注为 deprecated。

---

## Game Design Issues

### Blocking

（无设计理论级别的Blocking问题）

### Warnings

#### ⚠️ D-1: 齿轮币经济 Sink 不足

**资源**: 齿轮币 (gear_coins)
- **Sources**: Boss击败(50币), 探索发现, 敌人掉落, 任务奖励
- **Sinks**: 洗点(30-100币, 有上限), 武器升级(费用未定义), 护符购买(费用未定义)
- 商店系统(系统#23)状态: Not Started

→ 在MVP范围内，齿轮币几乎没有有效Sink。洗点费用封顶100。如果不在实现前定义足够的Sink，齿轮币将在中期变得毫无意义（无限积累，无消费出口）。

**建议**: 在 data-balance.md 或未来 shop-system GDD 中定义:
- 武器升级费用表
- 护符购买价格表
- 持续消耗型Sink（如消耗品、传送费用）

---

#### ⚠️ D-2: PERFECT弹反的支配策略风险

**分析**:
- PERFECT弹反(5.0×) 是游戏中最高倍率的独立操作
- 弹反后敌人眩晕1秒（免费输出窗口）
- 弹反后获得+15~20猫气（快速积攒特殊招式）
- 同装备下: 弹反暴击(83) vs 连招暴击(30) = **2.77×差距**

→ 弹反在伤害、资源获取、控制三个维度同时最优。如果玩家掌握了弹反时机，其他战斗策略可能变得无关紧要。

**缓解现状**: damage-calculation.md 已设计"PERFECT弹反(无暴击) > 连招终结+PERFECT暴击"的回报结构。这是有意设计，不是疏忽。

**建议**: 在垂直切片 playtest 中监测弹反使用率。如果弹反占据>60%的攻击选择，考虑:
- 降低弹反倍率至4.0-4.5×
- 增加连招持续DPS优势（连招攻速更快 = DPS更高）
- 设计"不可弹反"敌人类型增加多样性

---

#### ⚠️ D-3: Boss战认知负荷偏高

**Boss战期间同时活跃系统**:
1. 猫科战斗 — 连招节奏、攻击选择 (active)
2. 闪避/弹反 — 时机判断 (active)
3. 猫气 — 积攒与消耗决策 (semi-active)
4. 特殊招式 — 冷却管理 (semi-active)
5. HP管理 — 专注模式判断 (passive)
6. Boss阶段 — 阶段转换适应 (low-frequency)

→ 实际持续注意力集中在3-4个系统（攻击节奏、闪避/弹反时机、猫气消耗决策），处于可接受边界。

**建议**: 确保后续Boss设计不增加额外的同时活跃系统。Boss独特机制应替换（而非增加）基础系统——如"Boss战无弹反"而非"Boss战增加新资源条"。

---

#### ⚠️ D-4: 低HP专注模式——防御优势充足但进攻回报缺失

**现状**:
- 专注模式提供: 前摇延长(+6帧)、预兆放大、环境干扰减少、受伤音效变化
- 全部为防御端/感知端优势

**设计意图冲突**:
- game-concept "技巧优先" 支柱: "精准操作获得高回报"
- 低HP = 高风险 → 按设计理论应有高回报
- 但目前低HP只让猫武士"更难死"而非"更能杀"

→ 与B-4（blocking）联动。专注模式缺乏进攻端回报导致低血量时策略空间窄。

**建议**: 通过B-4修复引入轻量进攻回报（如暴击窗口+1-2帧），让低血量玩家有"拼命一搏"的战术选择。

---

## Cross-System Scenario Issues

**Scenarios walked**: 4

### Blockers

#### 🔴 Scenario 1: Boss被PERFECT弹反——伤害值不确定
- **Systems**: damage-calculation × boss-config
- **Step**: 弹反命中Boss时
- **Failure**: damage-calculation DC-F7 输出5.0×伤害，boss-config Edge Cases 声明4.0×。实现者不知道哪个GDD是权威。
- **必须解决**: 统一Boss弹反倍率（→ B-1）

#### 🔴 Scenario 2: 疾风连爪伤害计算——武器参数与伤害公式矛盾
- **Systems**: weapon-styles × damage-calculation
- **Step**: 玩家使用猫爪疾风连爪时
- **Failure**: weapon-styles 说每击50%伤害，damage-calculation DC-F9 说每击80%。实现者无法确定实际伤害值。
- **必须解决**: 统一疾风连爪特殊倍率（→ B-2）

### Warnings

#### ⚠️ Scenario 3: Boss战死亡→重生→Boss HP恢复——所有权分散
- **Systems**: health-death × death-respawn × scene-management × (世界状态#26)
- **Step**: Boss战中死亡 → 重生 → Boss HP需恢复到进入时状态
- **Issue**: death-respawn Rule 2 声明此行为，但依赖的世界状态系统(#26)为Not Started。scene-management Rule 4 也提及"Boss战场特殊处理"。
- **建议**: 明确 Boss HP 保存/恢复的所有权归属（建议 scene-management 或 death-respawn）。

#### ⚠️ Scenario 4: Boss致死伤害跨越阶段——视觉冲突
- **Systems**: health-death × boss-config × combat-presentation
- **Step**: Boss从35%受到致命伤害 → HD-F3 while循环触发phase_change(2) → 然后on_death
- **Issue**: 阶段转换动画(2-3秒)和死亡动画(2-3秒)的视觉优先级未定义。AC-26测试此场景但只验证信号顺序。
- **建议**: 定义"致死伤害跨越阶段阈值"时死亡优先，跳过阶段转换视觉。

### Info

#### ℹ️ Scenario 5: 专注模式激活→敌人连招中——帧数修正不连续
- **Systems**: health-death × ai-framework
- **Step**: 敌人正在执行三连击，第1击用旧startup_frames，玩家HP在第1击后降到25%→专注模式激活→第2击使用新startup_frames(+6帧)
- **Note**: ai-framework 已正确声明"已在执行中的攻击不受影响"。行为正确但玩家可能感知到"第2击突然变慢"。
- **Low risk**: +6帧(100ms)变化在连续攻击中可能不够明显。

---

## GDDs Flagged for Revision

| GDD | Reason | Type | Priority |
|-----|--------|------|----------|
| boss-config.md | Boss弹反倍率4.0×与damage-calc 5.0×矛盾 (B-1) | Consistency | Blocking |
| weapon-styles.md | 疾风连爪50%与damage-calc 80%矛盾 (B-2) + 猫气缺失 (W-3) | Consistency | Blocking |
| charm-equipment.md | charm_crit概率模型与确定性暴击不兼容 (B-3) | Consistency | Blocking |
| feline-combat.md | 缺少专注模式反杀工具接口 (B-4) | Consistency | Blocking |
| damage-calculation.md | 缺少skill-tree反向依赖 (W-1) + charm-equipment依赖 (W-8) | Consistency | Warning |
| health-death.md | active_enemies_count来源未定义 (W-2) | Consistency | Warning |
| hud-ui.md | low_hp_pulse_period旋钮已废弃但未标注 (W-9) | Consistency | Warning |
| input.md | Space键地面映射歧义 (W-7) | Consistency | Warning |
| exploration-ability-gating.md | 完成度公式双重所有权 (W-4) | Consistency | Warning |
| map-system.md | 完成度公式双重所有权 (W-4) | Consistency | Warning |
| player-abilities.md | dodge_cooldown双重Tuning Knob (W-5) | Consistency | Warning |

---

## Verdict: FAIL

**FAIL**: 4个Blocking问题必须在架构开始前解决。

### Required Actions Before Re-running

1. **统一Boss弹反倍率**: 在 boss-config.md 和 damage-calculation.md 之间确定权威值。如Boss有特殊减免，在 DC-F7 中添加例外条款
2. **统一疾风连爪倍率**: 在 weapon-styles.md 和 damage-calculation.md DC-F9 之间确定权威值（建议80%，与DC-F9对齐）
3. **修复charm_crit**: 将 charm-equipment.md 的 charm_crit 从"暴击率+5%"改为"暴击窗口+1帧"，更新 Rule 4 公式
4. **添加专注模式反杀接口**: 在 feline-combat.md 中声明监听 `on_focus_mode_changed` 信号，定义至少1个进攻端回报

### Warnings 建议处理顺序

- **30秒修复**: W-9 (删除 hud-ui low_hp_pulse_period 旋钮), W-8 (damage-calc 添加 charm-equipment 依赖说明)
- **简短修复**: W-3 (weapon-styles 补充猫气列), W-4 (完成度公式标注权威来源), W-5 (dodge_cooldown 标注所有权)
- **需要设计决策**: W-1 (依赖声明), W-2 (active_enemies_count 分配), W-6 (HP加成汇总公式), W-7 (Space键验证)
- **需要 playtest 数据**: D-2 (弹反支配策略)
- **需要后续GDD**: D-1 (齿轮币Sink定义)

---

## Appendix: Pillar Alignment Check

| System | Pillar(s) Served | Alignment |
|--------|-----------------|-----------|
| 输入系统 | 猫科战斗美学, 技巧优先 | ✅ |
| 数据/平衡 | 间接全部 | ✅ |
| 伤害计算 | 猫科战斗, 技巧优先 | ✅ |
| 生命/死亡 | 猫科战斗, 技巧优先 | ✅ |
| 猫科战斗 | 猫科战斗, 技巧优先 | ✅ |
| 碰撞判定 | 猫科战斗, 技巧优先 | ✅ |
| AI框架 | 猫科战斗, 技巧优先 | ✅ |
| 武器流派 | 猫科战斗, 技巧优先 | ✅ |
| Boss配置 | 猫科战斗, 技巧优先 | ✅ |
| 存档 | 间接全部 | ✅ |
| 场景管理 | 机制探索回报 | ✅ |
| 死亡重生 | 技巧优先 | ✅ |
| HUD/UI | 猫科战斗, 机制探索 | ✅ |
| 战斗表现 | 猫科战斗 | ✅ |
| 音效 | 猫科战斗 | ✅ |
| 探索门控 | 机制探索回报 | ✅ |
| 状态效果 | 猫科战斗, 技巧优先 | ✅ |
| 玩家能力 | 技巧优先, 机制探索 | ✅ |
| 护符/装备 | 技巧优先, 机制探索 | ✅ |
| NPC对话 | 叙事融入世界 | ✅ |
| 地图 | 机制探索回报 | ✅ |
| 技能树 | 技巧优先, 猫科战斗 | ✅ |

**Pillar Drift**: 无系统偏离设计支柱。所有22个系统均服务于至少一个核心支柱。

## Appendix: Player Fantasy Coherence

所有系统的Player Fantasy均围绕"技艺精湛的猫武士在危险世界中通过技巧取胜"的统一身份。无身份冲突。

## Appendix: Economic Loop Summary

| Resource | Sources | Sinks | Balance |
|----------|---------|-------|---------|
| 技能点 | Boss(20), 精英(16), 探索(21), 任务(8) = **65** | 技能树节点(132满解费) | ✅ 有限、有决策 |
| 猫气 | 战斗行为 | 特殊招式消耗, 脱战清零 | ✅ 闭环 |
| 齿轮币 | Boss, 探索, 掉落 | 洗点(有限), 升级/商店(未定义) | ⚠️ Sink不足 |
| HP | 存档点, 道具, 复活 | 敌人伤害 | ✅ |
| 护符 | 探索, Boss, 商人 | 装备槽位(3个) | ✅ |
