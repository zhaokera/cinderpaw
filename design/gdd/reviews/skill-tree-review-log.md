# Skill-Tree GDD Review Log

## Review #1 — 2026-06-19 — Verdict: MAJOR REVISION NEEDED → Revised

**Scope signal**: XL
**Specialists**: game-designer, systems-designer, economy-designer, qa-lead, creative-director
**Blocking items**: 14 | **Recommended**: 12

### Summary

Full adversarial review identified 14 blocking issues across three failure categories:
1. **Economy broken** — 52 SP budget at 33.8% coverage cannot deliver build-diversity fantasy; GDD's own worked example contained arithmetic error ("通用区全部(9)" should be 42)
2. **Cross-GDD conflicts** — Boss SP (3 vs 4), weapon_base (24 vs 40), and stacking formula (additive vs multiplicative) disagreed across 3+ GDDs
3. **Specification gaps** — T5 ultimate undefined, MULTIPLY modifier undefined, Cat Soul overpromises fantasy, 6 missing ACs

### Revisions Applied

All 14 blockers resolved in revision pass:
- SP economy increased to 65 (Boss=5×4, Elite=2×8, Explore=3×7, Quest=2×4)
- T5 defined as gateway (unlocks ultimate move)
- Cat Soul made mutually exclusive (choose 1 of 3)
- F7+F9 tracks separated (skill_weapon_bonus = base modifier, not stat bonus)
- Ultimate cat-energy cost defined (80 for all weapons)
- MULTIPLY and OVERRIDE modifier semantics fully specified
- F10 cooldown_floor values added, CDR clamped before formula
- F3 respec_count → prior_respec_count (unambiguous semantics)
- Node type classification table added (29/57 = 50.9% active/modifier)
- 7 new ACs added, 3 existing ACs rewritten with correct values
- Exploration node effects fully specified (damage, radius, duration)
- Cross-GDD sync table created for 6 value conflicts requiring propagation

### Outstanding (Cross-GDD — not yet fixed in source docs)

- boss-config.md: needs skill_point field in defeat_rewards
- damage-calculation.md: weapon_base example needs 40→24, F1 needs F9 override note
- charm-equipment.md: F4 needs multiplicative formula
- entities.yaml: F8 formula needs additive→multiplicative

### Status: Pending re-review in new session

## Review #3 — 2026-06-19 — Verdict: MAJOR REVISION NEEDED → Revised

**Scope signal**: XL
**Specialists**: game-designer, systems-designer, economy-designer, qa-lead, creative-director
**Blocking items**: 9 | **Recommended**: 5

### Summary

第三轮完整审查发现9项阻塞问题，集中在三个失败类别：
1. **SP经济数学全篇错误** — F1变量表残留旧值(52 vs 65)，F6示例使用错误的weapon_base(24 vs 40)，AC-17算术错误(89 vs 90)，满解费用(151 vs 144/116)不一致
2. **F8公式违背自身设计意图** — 乘法递减+硬上限0.50导致charm达到cap时skill贡献被完全抹零，恰好是它声称要避免的问题
3. **武器分支缺乏选择** — T5要求全部T4使分支变成线性走廊，与"铸爪成道"幻想矛盾

### 修订内容

全部9项阻塞已解决：
- **T3分叉结构**：每个武器分支T3层添加1对互斥节点(2选1)，创造分支内选择(每分支12节点/路径购9/费用21)
- **F8软上限0.75**：统一上限从0.50提升到0.75，设计cap范围内(skill≤0.25, charm≤0.50)不再触发截断
- **T1重分类**：通用T1"废土韧体"从被动改为修改型(+10HP+受击无敌帧+0.1秒)
- **数学全面修正**：F1变量表对齐Rule 3，F6示例weapon_base=40/伤害=133，满解费用116，覆盖率56%
- **Build示例重写**：4个Build示例全部重新计算（武器专精65/猫魂战士61/通用大师61/广猎多武64）
- **新增4条AC**：T3分叉选择/锁定、废土韧体修改效果、洗点后T3重置
- **Cross-GDD sync更新**：weapon_base标记已对齐，F8条目更新cap值，新增F9→F6覆盖声明

### 设计决策记录

- F8选择"软上限0.75"方案（用户决策），而非"硬上限0.65"或"加法+0.60"
- 分支结构选择"T3单分叉"方案（用户决策），T5仍需全部T4
- T1重分类选择"改通用T1"方案（用户决策），仅改废土韧体1个节点

### 遗留问题（Cross-GDD — 尚未在源文档中修复）

- boss-config.md: 需在defeat_rewards中添加skill_point字段
- damage-calculation.md: 内部暴击/弹反倍率不一致(Rules vs Formulas)，F1需注明F9覆盖
- charm-equipment.md: F4需更新为乘法递减公式+0.75软上限
- entities.yaml: F8公式需更新为乘法递减+0.75 cap
- feline-combat.md: 缺少enemy_killed/parry_success/dodge_perfect信号定义
- player-abilities.md: 缺少modifier provider接口声明
- weapon-styles.md: Dependencies缺少skill-tree声明
- status-effects.md: 缺少skill-tree作为效果源声明

### QA覆盖率备注

审查发现AC覆盖率偏低：
- 猫气获取方式仅1/11有AC覆盖
- modifier API(get_modifiers/get_stat_bonus)无AC覆盖
- F9武器交互无AC覆盖
- 8/18边case无AC覆盖
- 无性能AC(60fps目标)
- 仅1条存档AC(错误场景，无正常round-trip)

建议在下次审查前补充关键AC。

### Status: Pending re-review #4 in new session (/clear before re-review recommended)

## Review #4 — 2026-06-19 — Verdict: NEEDS REVISION → Revised

**Scope signal**: XL
**Specialists**: game-designer, systems-designer, economy-designer, qa-lead, ux-designer, godot-specialist, creative-director (senior synthesis)
**Blocking items**: 8 (6 blocking + 2 structural) | **Recommended**: 8 | **Nice-to-have**: 7

### Summary

第四轮完整审查（7个专家代理对抗性评审）发现8项阻塞/结构性问题，集中在三个类别：
1. **跨GDD数据腐烂** — entities.yaml残留3个旧值+1个错误公式，boss-config缺少SP奖励字段，charm-equipment F4 cap冲突（0.50 vs 0.75）
2. **公式边界健壮性** — F6 reduction_factor在defense=-60时除零崩溃，F8乘法公式在charm_bonus>1.0时反转
3. **设计支柱违反** — 武器T1层100%被动节点违反"技巧优先"支柱，猫气系统归属错误（战斗资源定义在技能树GDD）

creative-director综合评审将多项godot-specialist和ux-designer的"阻塞"降级为"延迟"（属于架构/UX阶段，非GDD层设计问题），将game-designer的"48种Build不足"降级为"推荐"。

### 修订内容

全部8项阻塞/结构性问题已解决：
- **entities.yaml同步**：total_sp=65, cap=0.75, nodes=65, F8=multiplicative
- **boss-config.md**：defeat_rewards添加skill_points字段，Rule 4添加5SP奖励
- **charm-equipment.md**：F4 cap更新为0.75，公式更新为乘法递减
- **F6防御性clamp**：reduction_factor = clamp(60/(defense+60), 0.0, 1.0)
- **F8输入防御**：charm_bonus先clamp到[0, charm_cap]再进入公式
- **F6/F9命名统一**：weapon_base→effective_weapon_base + F9交互说明
- **武器T1重设计**：每武器添加T1-A修改型节点（猫爪:前冲位移, 长尾刃:范围+0.3格, 鱼骨:微击退, 铃铛:短暂减速）
- **猫气迁移**：完整猫气系统移至feline-combat.md规则7，skill-tree.md改为引用
- **节点类型比例**：从49.0%升至59.2%（T1-A修改型+猫魂重分类为修改型）
- **跨GDD同步表**：9/11项已标记解决

### 设计决策记录

- T1-A节点采用"方案A：轻微行为修改"（用户决策），而非"战斗机制奖励"或"新招式变体"
- F6/F8采用防御性clamp方案，不依赖外部系统保证输入范围
- 猫气系统完整迁移至feline-combat.md（三个专家共识），skill-tree仅保留极意技门控引用

### 遗留问题（非本GDD职责，需其他GDD处理）

- damage-calculation.md: 内部暴击/弹反倍率不一致（Rules vs Formulas），F1需注明F9覆盖
- feline-combat.md: Dependencies已更新，但接口签名需补充has_unlocked_ultimate查询
- weapon-styles.md: Dependencies仍缺少skill-tree声明
- player-abilities.md: 缺少modifier provider接口声明
- status-effects.md: 缺少skill-tree作为效果源声明

### QA覆盖率备注

AC审计结果：29条AC中23条PASS，6条NEEDS-REWRITE。整体覆盖率约55%。
关键缺失AC（建议在重审前补充）：
- Modifier API (get_modifiers, get_stat_bonus, has_skill): 0条AC
- F9 weapon_base replacement: 0条AC
- 猫气获取方式: 仅1/11有AC
- Save/load happy path: 0条AC
- 性能(60fps): 0条AC

### Deferred Items（属于架构/UX阶段，不阻塞GDD审批）

- Modifier API应使用SkillModifier Resource类（godot-specialist建议）
- get_modifiers()需预计算缓存（godot-specialist建议）
- 信号归属/ autoload所有权（godot-specialist建议）
- F8 cap应使用共享工具类（godot-specialist建议）
- 猫魂确认对话框、战斗中只读查看、溢出预警、触屏导航（ux-designer建议）

### Status: Pending re-review #5 in new session (/clear before re-review recommended)

## Review #5 — 2026-06-19 — Verdict: NEEDS REVISION → Revised

**Scope signal**: XL
**Specialists**: game-designer, systems-designer, economy-designer, qa-lead, godot-specialist, creative-director (senior synthesis)
**Blocking items**: 3 | **Recommended**: 6 | **Nice-to-have**: 6

### Summary

第五轮完整审查（6个专家代理对抗性评审）发现3项阻塞问题，均为前几轮修订引入的数学/文档一致性问题：
1. **T3分叉数学矛盾** — F2公式(2×1+3×2+1×3+2×3+1×5)实际求和为22而非21，且与fork描述("各2个节点")和AC-26矛盾。级联影响满解费用、覆盖率、所有Build示例
2. **Modifier API + F9零AC覆盖** — get_modifiers/get_stat_bonus/has_skill三个核心接口和F9 weapon_base替换无任何验收标准
3. **AC-16通知时长矛盾** — UI Requirements说2秒，AC-16说3秒；SP授予时机模糊("回到据点" vs boss_defeated信号)

creative-director综合评审将多项game-designer和godot-specialist的"阻塞"降级：
- B2(52节点未定义) → WARNING — 内容创作任务，非系统设计
- B3(通用区强制税) → DESIGN DECISION — 基础能力层设计选择
- B4(T1-A数值不可感知) → WARNING — 平衡调整任务
- godot-specialist B-1/B-2/B-3 → WARNING — 架构阶段职责

### 修订内容

全部3项阻塞已解决：
- **T3分叉数学修正**：选择"2 T3节点/路径"方案（用户决策）。F2=25/分支，购10节点，满解132，覆盖率49.2%，可购54个
- **Build示例重写**：武器专精Build替换为均衡双武Build(25+18+16+5=64)，猫魂战士(25+27+5+8=65)，通用大师(32+25+8=65)
- **节点类型表更新**：T2-T3从12可购升至20可购，总计54可购/33主动修改/22被动=61.1%
- **新增3条AC**：get_modifiers查询、get_stat_bonus+has_skill查询、F9 skill_weapon_base替换验证
- **AC-16修正**：通知时长统一为3秒，SP授予时机改为"Boss击败时立即"(非回到据点)
- **UI Requirements修正**：通知持续从2秒改为3秒

### 设计决策记录

- T3分叉选择"2节点/路径"方案（用户决策），接受49.2%覆盖率
- 通知时长选择3秒（用户决策）
- SP授予时机选择"Boss击败时立即"（用户决策）

### 遗留问题（非本GDD职责）

- damage-calculation.md: 内部暴击/弹反倍率不一致
- weapon-styles.md: Dependencies缺少skill-tree声明
- player-abilities.md: 缺少modifier provider接口声明
- status-effects.md: 缺少skill-tree作为效果源声明
- charm-equipment.md: F4基础公式仍为加法叠加（虽有F8交叉引用注释）

### Recommended Revisions（非阻塞，建议在下轮审查前处理）

- 添加skill_weapon_bonus_cap=0.15到Tuning Knobs表
- T1-A数值增大（+8px→+16px等）以感知到行为变化
- F8添加skill_bonus_total下界clamp
- 添加伤害流水线顺序图
- 添加skill_unlocked/modifiers_changed信号
- 添加skill_tree.json schema附录

### Status: Pending re-review #6 in new session (/clear before re-review recommended)

## Review #6 — 2026-06-19 — Verdict: APPROVED (Conditional → Revised → Approved)

**Scope signal**: XL
**Specialists**: game-designer, systems-designer, economy-designer, qa-lead, godot-specialist, creative-director (senior synthesis)
**Blocking items**: 1 (GDD-level) | **Recommended**: 4 | **Nice-to-have**: 6

### Summary

第六轮完整审查（6个专家代理对抗性评审），经creative-director综合裁定后判定为**有条件批准**。专家报告共15项BLOCKING，经creative-director分类裁定后：

- **GDD级阻塞**：仅1项 — F5比例型modifier负值clamp（systems-designer B1）
- **架构级（ADR）**：6项 — Modifier类型定义、信号归属、JSON/Resource格式、缓存策略、Autoload顺序、OVERRIDE优先级
- **内容创作**：3项 — T3 fork深度、决策密度、AC覆盖率
- **平衡调优**：4项 — T1-A感知度、探索SP占比、非探索者负面螺旋、猫魂互斥
- **已修复误报**：1项 — F6除零（已在Review #4中修复）

**creative-director核心判断**：经6轮迭代，系统设计（结构、公式、接口）已成熟完备。第6轮发现的问题主要是内容未填充（54个节点效果）、实现未规划（Godot架构）和数值未调优（T1-A感知度）——这些属于后续阶段（架构ADR、内容创作、垂直切片playtesting）的职责，不应阻塞GDD审批。

### 修订内容

全部阻塞项+推荐项已解决：
- **F5负值clamp**：`modifier_effect = max(0, base_value × (1 + modifier_value))`，防止负面modifier叠加产出负值
- **Tuning Knobs补充**：添加 `skill_weapon_bonus_cap=0.15` 和 `t1_modifier_min_ratio=0.10`（确保T1-A首次投资可感知）
- **Open Questions更新**：添加T2层第二fork远期考虑 + 猫魂效果设计指导（增强而非覆盖Build）
- **文档状态更新**：Status改为Approved，systems-index.md同步更新

### 设计决策记录

- 第3轮用户决策"T3单分叉"保持不变（creative-director裁定为scope-aware的合理决策）
- 探索SP占比32.3%保持不变（creative-director裁定非支柱违反，但需playtesting验证Boss vs 探索SP比值）
- 猫魂互斥设计保持不变（creative-director裁定为增强而非覆盖，需内容创作阶段确保效果差异化）

### 专家分歧裁定

| 分歧 | 专家立场 | creative-director裁定 |
|------|---------|---------------------|
| T1-A感知度 | game-designer: 不可感知，违反承诺 | 部分同意——数值需调大，但不阻塞GDD |
| T3 fork深度 | game-designer: 太浅，"技能楼梯" | 不同意——内容质量问题，非结构问题 |
| 探索SP占比 | economy-designer: 违反技巧优先 | 不同意——对支柱的误读 |
| 猫魂身份覆盖 | game-designer: 50SP被5SP覆盖 | 不同意——是叠加增强，非覆盖 |
| Godot实现3项 | godot-specialist: 实现阻断 | 降级为架构ADR，非GDD阻塞 |

### 后续阶段处理项

| 阶段 | 处理项 | 负责agent |
|------|--------|----------|
| 架构设计(ADR) | Modifier Resource类、信号归属、JSON/Resource格式、缓存策略、Autoload顺序 | godot-specialist + technical-director |
| 内容创作 | 54个节点具体效果设计 | game-designer + systems-designer |
| 垂直切片 | T1-A数值感知验证、Boss vs 探索SP比值验证 | qa-lead + economy-designer |
| 实现阶段 | AC补充（猫气获取全覆盖、save happy path、性能基准）| qa-lead |

### Status: **APPROVED** ✅
