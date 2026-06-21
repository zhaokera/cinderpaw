# Damage-Calculation GDD Review Log

## Review #1 — 2026-06-19 — Verdict: NEEDS REVISION → Revised

**Scope signal**: M
**Specialists**: None (lean mode — issues identified by /review-all-gdds cross-GDD review)
**Blocking items**: 3 | **Recommended**: 3

### Summary

首次单独审查发现伤害计算GDD存在严重的内部数值矛盾：Rules部分和Formulas部分对暴击和弹反倍率给出了不同的数值（Rules: 2.0x/3.0x vs Formulas: 2.5/4.0），ACs使用了错误的Rules值。验证表使用正确的Formulas值。此外，F1缺少skill-tree F9覆盖注释，Dependencies未列出skill-tree，猫爪"暴击率+50%"机制在timing window系统中无法实现。

### 修订内容

全部6项已解决：
- **Rule 2**: PERFECT暴击 2.0x→2.5x, GOOD暴击 1.5x→1.8x（对齐F5）
- **Rule 4**: PERFECT弹反 3.0x→4.0x, GOOD弹反 2.0x→2.5x（对齐F7）
- **AC#2**: crit_multiplier 2.0→2.5
- **AC#3**: parry_multiplier 3.0→4.0
- **AC#4**: attack_damage 52→58.5（13×2.5×1.8）
- **F1**: 添加skill-tree F9覆盖注释
- **Dependencies**: 添加技能树系统为上游依赖
- **Visual/Audio**: 暴击弹反倍率值更新
- **F2示例**: 52→58.5
- **weapon-styles.md**: 猫爪"暴击率+50%"→"暴击窗口+3帧"

### 设计决策记录

- 猫爪机制选择"方案A: 暴击窗口扩大+3帧"（用户决策），使用已有timing系统，无需新机制
- 倍率统一选择Formulas值（2.5/4.0），因验证表和boss-config已使用这些值

### 遗留问题（来自/review-all-gdds，非本GDD职责）

- health-death.md: 心跳音效矛盾（Rule 7 vs 3处引用）
- charm-equipment.md: Rule 4公式需引用skill-tree F8
- boss-config.md: 阶段转换缓冲机制未定义
- 齿轮币经济完全未定义（需新GDD）

### Status: Pending re-review in new session (/clear before re-review recommended)

## Review #2 — 2026-06-20 — Verdict: NEEDS REVISION → Revised

**Scope signal**: M
**Specialists**: game-designer, systems-designer, qa-lead, creative-director (full mode)
**Blocking items**: 3 | **Recommended**: 6 | **Nice-to-have**: 7

### Summary

Full review 发现三个 blocking 问题：(1) F2 变量表仍保留 Review #1 修订前的旧值（crit 1.0/1.5/2.0 vs F5 实际 1.0/1.8/2.5），是上次修订的遗漏；(2) 接口签名缺少 attack_power、enemy_defense、skill_modifiers 三个必需参数，导致多条 AC 不可测试；(3) F2 输出范围声明 10-300 但弹反路径最大值达 560。此外发现 damage_multiplier 旋钮悬浮（三处引用却无公式）、MVP 内特殊招式无伤害公式、AC9 为不可测试的设计意图伪装。

### 修订内容

全部 16 项已解决：
- **B1**: F2 变量表 crit_multiplier → 1.0/1.8/2.5, parry_multiplier → 1.0/1.5/2.5/4.0, 输出范围 → 10-560
- **B2**: 接口签名补全 attack_power, enemy_defense, skill_modifiers
- **B3**: F2 输出范围 10-300 → 10-560
- **R1**: damage_multiplier 接入 F4 公式（`× damage_multiplier`），规则6 同步更新
- **R2**: 新增 F9: special_move_damage 公式，含 special_multiplier 表（疾风连爪 0.5×5、旋风斩 1.5×1 等）
- **R3**: AC9 重写为具体数值场景（猫爪 100 > 鱼骨 50）
- **R4**: F2 弹反路径添加设计意图注释（弹反不计连招）
- **R5**: Dependencies 添加 charm_crit 兼容性注释和 skill-tree F8 跨系统接口注释
- **R6**: AC1/AC4/AC7/AC8 全部重写，含完整输入参数和具体触发值
- **NT1**: 连招奖励 "+31%" → "+20%~+50%（视武器）"
- **NT2**: 验证表添加同装备对比行（11.0x/10.1x）
- **NT3**: F1 输出范围 10-50 → 10-56（反映 F9）
- **NT4**: F5 添加窗口参数化注释 + window_start 参考系定义
- **NT5**: F3 添加 max(0, defense) 下界保护
- **NT6**: F7 显式处理 frame_diff < 0
- **NT7**: Player Fantasy "3-5x" → "同装备10-11x, 跨装备2x"

### 设计决策记录

- damage_multiplier 接入 F4（最终伤害层），作为全局难度/平衡调节旋钮（用户决策）
- MVP 武器特殊招式现在定义公式，鱼骨/铃铛 defer 到垂直切片（用户决策）
- 弹反不计连招确认为有意设计——弹反是防御反击动作，重置攻击节奏（用户决策）

### 遗留问题（跨系统）

- charm-equipment.md: charm_crit 需从"+N% crit rate"改为"+N帧 暴击窗口"（与确定性暴击系统兼容）
- skill-tree F8: attack_power 是否受 combined_bonus 影响需在实现时确认
- feline-combat.md: 特殊招式的猫气消耗和冷却需与 F9 公式对齐

### Status: Pending re-review in new session (/clear before re-review recommended)

## Review #3 — 2026-06-20 — Verdict: NEEDS REVISION → Revised

**Scope signal**: M
**Specialists**: game-designer, systems-designer, qa-lead, creative-director (full mode)
**Blocking items**: 5 | **Recommended**: 6 | **Nice-to-have**: 5

### Summary

Full review（第3轮）发现5个 blocking 问题：(1) AC 中6/11条 FAIL——只断言中间变量而非 final_damage，输入参数不完整，AC9 用 defense=0 无法验证技巧优先；(2) F1 输出范围"10-56"未计 F8 combined_bonus，实际可达 63；(3) 弹反回报结构缺失——PERFECT弹反(无暴击)伤害低于连招终结+暴击，最高风险操作非最优选择；(4) 多段伤害每击独立 floor+reduction 导致的实际倍率偏低未文档化；(5) F9 编号冲突——damage-calc F9(special_move) 与 skill-tree F9(skill_weapon_base) 互相引用造成混淆。

### 修订内容

全部 5+6 项已解决：
- **B1**: AC2-5/AC9-10 全量重写，每条包含完整8参数输入→final_damage具体数值。AC9改用defense=30验证技巧优先
- **B2**: F1 Range改为"10-56（基础）"，注释增加"含DC-F8 combined_bonus后上限约63"
- **B3**: parry_perfect_multiplier 4.0→5.0（规则4/DC-F7/旋钮/验证表/视觉反馈全链路）。规则4新增回报结构声明段落
- **B4**: Edge Cases新增多段伤害floor截断累积偏差说明，标注"DPS型vs爆发型"差异化设计意图
- **B5**: 全部9个公式加DC-前缀（DC-F1~DC-F9），所有内部交叉引用同步，skill-tree F9引用保持原样
- **R1**: F2/F4输出范围更新（560→700）反映parry=5.0
- **R2**: Tuning Knobs新增combo_timeout(300ms)、parry_late_multiplier(1.5)、crit_perfect_window(3帧)
- **R3**: DC-F2新增空中/蓄力攻击注释（第三种计算路径，由feline-combat定义）
- **R4**: charm_crit依赖标注为"⚠️前置修复依赖"
- **R5**: Section标题"Detailed Design"→"Detailed Rules"
- **R6**: Player Fantasy技巧倍率更新（同装备13-14x，跨装备2.5x）

### 设计决策记录

- parry_perfect_multiplier选择5.0（用户决策），确保PERFECT弹反(无暴击)>连招终结+暴击
- 公式编号采用DC-前缀方案（用户决策），区别于skill-tree F9

### 遗留问题（跨系统）

- charm-equipment.md: charm_crit仍为"+5%暴击率"，需改为"+N帧暴击窗口"（damage-calc已标注为前置修复依赖）
- charm-equipment.md: 规则4加法叠加公式需与skill-tree F8乘法递减对齐
- skill-tree.md: effective_weapon_base vs skill_weapon_base命名需统一
- feline-combat.md: 特殊招式的猫气消耗和冷却需与DC-F9公式对齐

### Creative Director 综合评估

"结构完整、数学自洽的Foundation层GDD。5个blocking项均为低成本文档修复。game-designer的大部分'BLOCKING'发现（刮痧体感、连招窗口、伤害上限）实际是调参问题，属于垂直切片playtest范畴。弹反回报结构是唯一真正的设计系统问题，已修复。"

### Status: Pending re-review in new session (/clear before re-review recommended)

## Review #4 — 2026-06-20 — Verdict: NEEDS REVISION → Revised

**Scope signal**: M
**Specialists**: game-designer, systems-designer, qa-lead, creative-director (full mode)
**Blocking items**: 4A(设计决策) + 4B(机械修复) + 7C(测试覆盖) = 15 | **Recommended**: 6 | **Nice-to-have**: 5

### Summary

Full review（第4轮）发现核心数学引擎经过3轮修订已健壮。4个 Category A 问题集中在幻想-机制一致性和跨系统边界：(1) 疾风连爪(5×0.5)在所有场景下严格劣于普通连招——陷阱选项；(2) 伤害体感分级表让技巧型玩家"刮痧"——高手PERFECT暴击16=白色"正常"，菜鸟平A33=黄色"有力"；(3) Boss最小窗口(3帧)下GOOD暴击窗口退化为0帧——未文档化；(4) attack_type_multiplier被DC-F2引用但在feline-combat.md中未定义。Category B为4个范围声明/记号错误。Category C为7个测试覆盖缺口。

### 修订内容

全部 4A + 4B + 7C 项已解决：
- **A1**: 疾风连爪 special_multiplier 0.5→0.8（总2.5×→4.0×）
- **A2**: 伤害分级阈值下调（1-5/6-15/16-30/31-60/61-150/151-999）
- **A3**: DC-F5注释添加Boss最小窗口退化说明
- **A4**: DC-F2注释添加attack_type_multiplier占位表
- **B1**: weapon_base范围 10-40 → 8-40
- **B2**: DC-F2输出范围 10-700 → 8-788
- **B3**: DC-F7区间记号统一为半开区间
- **B4**: AC9拆分为AC17a/AC17b/AC17c
- **C1-C7**: 默认参数表, GOOD/LATE等级AC, defense=50, multiplier<1, 连招超时, DC-F9, 标注DC-F4单元测试
- **R1**: 弹反叙事文案 "你的力量成了我的" → "我看穿了你的节奏"
- AC总数: 12条 → 20条

### 设计决策记录

- 疾风连爪提升倍率至0.8（用户决策）
- 伤害分级降低阈值（用户决策）
- Boss GOOD窗口文档化为有意设计（用户决策）
- attack_type_multiplier定义占位值（用户决策）

### 遗留问题（跨系统 / Playtest验证项）

- charm-equipment.md: charm_crit需改为"+N帧暴击窗口"
- feline-combat.md: attack_type_multiplier占位值需垂直切片细化
- 100ms PERFECT弹反窗口在移动端可行性（Playtest）
- 999伤害上限在MVP中不触发（Playtest）
- 13-14x同装备技巧差距的心理影响（Playtest）

### Status: Approved — 4 reviews completed. Ready for implementation.
