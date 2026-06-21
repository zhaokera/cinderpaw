# 伤害计算系统 (Damage Calculation System)

> **Status**: Approved
> **Author**: 用户 + AI
> **Last Updated**: 2026-06-20
> **Implements Pillar**: 猫科战斗美学, 技巧优先成长
> **Systems Index**: #3 | MVP核心 | Foundation
> **Creative Director Review (CD-GDD-ALIGN)**: CONCERNS (accepted — multipliers increased, verification table corrected) [2026-06-18]
> **Design Review #1**: NEEDS REVISION → 3 blocking + 3 warnings [2026-06-19]
> **Design Review #1 Revision**: All items resolved — Rules/ACs unified to Formulas, F9 override note, skill-tree dependency, cat claw mechanic redesigned [2026-06-19]
> **Design Review #2**: NEEDS REVISION → 3 blocking + 6 recommended [2026-06-20]
> **Design Review #2 Revision**: All items resolved — F2 variable table unified, interface signature completed, F4 damage_multiplier added, F-special formula defined, ACs rewritten with full inputs [2026-06-20]
> **Design Review #3**: NEEDS REVISION → 5 blocking + 6 recommended [2026-06-20]
> **Design Review #3 Revision**: All items resolved — parry_perfect 4.0→5.0, ACs全量重写, DC-前缀编号, 弹反回报结构声明, 多段伤害文档化, F1范围修正, Tuning Knobs补全 [2026-06-20]
> **Design Review #4**: NEEDS REVISION → 4A设计决策 + 4B机械修复 + 7C测试覆盖 [2026-06-20]
> **Design Review #4 Revision**: All items resolved — 疾风连爪0.5→0.8, 伤害分级阈值下调, Boss GOOD窗口文档化, attack_type_multiplier占位表, weapon_base范围8-40, DC-F2范围8-788, DC-F7半开区间统一, AC全量重构(12→20条+默认参数表) [2026-06-20]

## Overview

**伤害计算系统**是《废土喵影》的核心数学引擎，负责将攻击动作转化为具体的伤害数值。它接收攻击类型、武器属性、暴击判定、防御减免等输入，输出最终伤害值及伤害元数据（暴击与否、元素类型、是否破盾等）。

**玩家直接感受它**：对于ACT游戏，伤害数字是战斗反馈的核心组成部分。当暴击打出"999"时的爽快感、当弹反成功触发全额伤害时的成就感、当刮痧打不动Boss时的挫败感——这些都源于伤害计算公式的设计。公式不合理 = 战斗"感觉不对"。

**技术职责**：
- 伤害公式引擎：根据攻击类型、武器基础伤害、攻击力缩放、暴击倍率计算最终伤害
- 防御减免系统：根据目标防御力、护盾值、元素抗性计算实际受到的伤害
- 特殊伤害处理：弹反伤害加成、下劈弹跳伤害、连招递增伤害、环境伤害
- 伤害元数据输出：暴击标志、元素类型、是否破盾、伤害来源（用于视觉/音频反馈系统）

**为什么存在**：没有它，攻击只是动画——没有数字反馈、没有"打中了"的确认感、没有技巧回报。伤害计算是"攻击动作"变成"战斗体验"的桥梁。

## Player Fantasy

**「猫狩直觉」+「蓄势倾泻」— 猎手本能的速度碾压**

伤害计算系统的终极使命是让每一次精准操作都获得**猫科猎手的本能满足**。当玩家读懂敌人前摇、在0.3秒窗口内弹反——伤害数字弹出的瞬间，感受到的不是"我算对了"，而是**"我看穿了"**。

**锚定时刻（直觉层）**：Boss第三阶段，敌人举起巨爪蓄力攻击。玩家不退反进，在最后一帧弹反——敌人攻击被截断，全额伤害反击。那一刻的感受是"我看穿了你的节奏"。暴击数字伴随帧停、震屏、刃白闪光弹出——所有蓄势的能量在那一刻倾泻而出。

**锚定时刻（倾泻层）**：对精英敌人打出完整连招，伤害数字逐级攀升（轻→轻→重→暴击），每一击都在加速，势能不断积累。终结暴击的金色大字弹出时，帧停0.3秒、全屏震屏——玩家觉得自己刚完成了一次完美的猫科猎杀。

**核心承诺**：
- **精准有回报**：暴击窗口、弹反窗口、下劈时机——每一个精准操作都在伤害数字中得到放大
- **节奏有重量**：连招递增不是数字堆叠，而是势能积累——最后一击的释放感来自前几击的铺垫
- **技巧放大器**：相同装备，高手执行最高风险操作（弹反暴击）的伤害是菜鸟普通攻击的**13-14倍**；跨装备极端差距下（基础猫爪 vs 满级鱼骨），高手巅峰伤害仍为菜鸟普通的**2.5倍**——技巧让你**稳定**输出高伤害，装备让你**偶尔**打出更高数字

**猎手的本能，从数字开始。** 当暴击让"我读准了时机"变得可见，当弹反让"你的力量成了我的"变得可感，当连招让"这套真漂亮"变得可数——伤害计算系统就在背后支撑着猫科战斗的全部爽感。

## Detailed Rules

### Core Rules

#### 规则1：伤害流水线
```
base_damage → attack_damage（含暴击/连招/弹反倍率）→ final_damage（减伤后）
```

#### 规则2：暴击系统 — 时机窗口，非随机
**破绽窗口**：敌人攻击动画的特定帧段暴露弱点，玩家需读懂前摇并在窗口内命中。
- PERFECT（2.5x）：窗口前3帧
- GOOD（1.8x）：窗口后3帧
- NORMAL（1.0x）：其他

窗口宽度按难度递减：小怪8-10帧，精英5-6帧，Boss 3-5帧。上述 PERFECT/GOOD 倍率固定不变，窗口帧数由 AI 系统按敌人难度配置（详见 DC-F5 注释）。

#### 规则3：连招递增

| combo_index | 猫爪 | 长尾刃 | 鱼骨大剑 | 电磁铃铛 |
|:---:|:---:|:---:|:---:|:---:|
| 0（起手） | 1.0× | 1.0× | 1.0× | 1.0× |
| 1（积累） | 1.2× | 1.15× | 1.3× | 1.1× |
| 2（终结） | 1.8× | 1.7× | 2.2× | 1.5× |

完整连招奖励约+20%~+50%总伤害（视武器而定：猫爪+33%、长尾刃+28%、鱼骨大剑+50%、电磁铃铛+20%，vs 散打）。超时300ms或被击中则重置。

#### 规则4：弹反伤害 — 最高风险最高回报

| 弹反类型 | 窗口 | 倍率 | 视觉反馈 |
|----------|------|------|----------|
| PERFECT | 6帧（100ms） | 5.0× | 全屏闪白+8帧帧停+强震 |
| GOOD | 7-12帧 | 2.5× | 小火花+4帧帧停 |
| LATE | 13-18帧 | 1.5× | 微弱火花+减伤 |
| NO | 超时 | 1.0× | 正常受击 |

弹反使用玩家自身base_damage（非敌人伤害反弹）。

**回报结构设计意图**：PERFECT弹反（最高风险操作，100ms窗口）作为独立操作即应为最优伤害路径。设计目标：`PERFECT弹反(无暴击) > 连招终结 + PERFECT暴击`。当前数值验证（猫爪 base=10, defense=30）：PERFECT弹反(无暴击) = floor(10×5.0×1.0×0.667) = **33** > 连招终结+PERFECT暴击 = floor(10×2.5×1.8×0.667) = **30** ✅。如果 playtest 中弹反使用率低于预期，优先调高此倍率而非降低连招倍率。

#### 规则5：防御减免 — 比率递减曲线
`reduction_factor = 60 / (defense + 60)`

| defense | 减伤% | 敌人类型 |
|:---:|:---:|------|
| 0 | 0% | 无防御目标 |
| 10 | 14% | 第一区域精英 |
| 30 | 33% | 第二区域Boss |
| 50 | 45% | 最终Boss |

#### 规则6：最终伤害
`final_damage = clamp(floor(attack_damage × reduction_factor × damage_multiplier), 1, 999)`
- damage_multiplier：全局伤害倍率旋钮（默认1.0），用于运营期难度/平衡调节
- 下限1：保证任何攻击都有反馈
- 上限999：ACT经典三位数上限

#### 规则7：特殊招式伤害
特殊招式使用独立倍率，不与 combo_multiplier 叠加。每击独立走完整伤害流水线。
- 猫爪「疾风连爪」：5次攻击，每次 base_damage × 0.8，各击独立判定暴击
- 长尾刃「旋风斩」：单次攻击，base_damage × 1.5，单次暴击判定
- 鱼骨大剑「地裂斩」：单次攻击，base_damage × 2.0（MVP外，公式占位）
- 电磁铃铛「电磁脉冲」：DoT独立定义（MVP外）

公式详见 DC-F9。冷却/猫气消耗由 weapon-styles.md 和 feline-combat.md 定义。

#### 规则8：伤害数字体感

| 伤害范围 | 体感 | 视觉表现 |
|:---:|------|------|
| 1-5 | 刮痧 | 白色小字 |
| 6-15 | 正常 | 白色标准字 |
| 16-30 | 有力 | 黄色中字+轻微震屏 |
| 31-60 | 强力 | 金色大字+帧停+震屏 |
| 61-150 | 极限 | 猫眼金色超大字+全特效 |
| 151-999 | 传说 | 特殊动画 |

### States and Transitions

伤害计算系统是无状态纯函数引擎——每次调用独立计算，无内部状态。状态由上游系统管理：
- 输入系统管理combo_index
- 战斗系统管理攻击动作和命中帧
- AI系统管理敌人破绽窗口

### Interactions with Other Systems

#### 上游依赖（输入）
- **数据基础设施**：读取damage_params域（weapon_base, defense等）+ damage_multiplier旋钮
- **输入系统**：接收攻击动作类型（attack, heavy_attack, parry等）
- **战斗系统**：提供命中帧、combo_index、弹反时机

#### 下游被依赖（输出）
- **生命与死亡检测**：接收final_damage进行HP扣减
- **视觉反馈系统**：接收伤害元数据（暴击标志、弹反类型）触发帧停/震屏/粒子
- **音效系统**：接收伤害类型触发对应音效
- **AI框架**：接收受到的伤害用于行为调整

#### 接口签名
```
calculate_damage(attack_type, weapon_id, hit_frame, combo_index, parry_timing,
    attack_power, enemy_defense, skill_modifiers) → {
    final_damage: int,
    metadata: {
        is_crit: bool,
        crit_type: "perfect" | "good" | "none",
        is_parry: bool,
        parry_type: "perfect" | "good" | "late" | "none",
        combo_stage: int,
        damage_category: "scratch" | "normal" | "strong" | "powerful" | "extreme" | "legendary"
    }
}
```

## Formulas

### DC-F1: base_damage（武器基础伤害）
`base_damage = weapon_base + floor(attack_power × 0.2)`

> **跨系统覆盖**：当技能树系统 F9 生效时（`skill_weapon_bonus > 0`），`weapon_base` 被 `skill_weapon_base = weapon_base × (1 + skill_weapon_bonus)` 替换后再进入本公式。无技能树加成时，`skill_weapon_base = weapon_base`，公式不变。参见 skill-tree.md F9。

| Variable | Type | Range | Description |
|----------|------|-------|-------------|
| weapon_base | int | 8-40 | 武器固有基础伤害 |
| attack_power | int | 0-50 | 角色攻击力（护符/升级） |
| **输出** | int | 8-56（基础）| 进入倍率计算的基础伤害（skill-tree F9介入后可达56；含DC-F8 combined_bonus后上限约63） |

**装备差距**：最低8 vs 最高50 = 6.25x（极端），典型2.6x

**Example**：基础猫爪(weapon_base=10) + 攻击力15 → base_damage = 10 + 3 = 13

### DC-F2: attack_damage（进攻伤害）
**普通攻击**：`attack_damage = base_damage × crit_multiplier × combo_multiplier`
**弹反**：`attack_damage = base_damage × parry_multiplier × crit_multiplier`

| Variable | Type | Range | Description |
|----------|------|-------|-------------|
| crit_multiplier | float | 1.0/1.8/2.5 | 暴击倍率（DC-F5） |
| combo_multiplier | float | 1.0-2.2 | 连招倍率（DC-F6） |
| parry_multiplier | float | 1.0/1.5/2.5/5.0 | 弹反倍率（DC-F7） |
| **输出** | float | 8-788 | 倍率叠加后的伤害（DC-F4 clamp 前） |

**Example**：连招终结+暴击，猫爪(base=13) → 13 × 2.5 × 1.8 = **58.5**

> **设计意图**：弹反路径不使用 combo_multiplier。弹反是独立的防御反击动作，重置攻击节奏而非延续连招序列。弹反后的下一次普通攻击从 combo_index=0 重新开始。

> **空中/蓄力攻击**：空中攻击和蓄力攻击（重攻击）使用独立的 `attack_type_multiplier`，由 feline-combat.md 定义倍率值。这些 attack_type 不使用 combo_multiplier 或 parry_multiplier 路径，而是作为 DC-F2 的第三种计算路径：`attack_damage = base_damage × attack_type_multiplier × crit_multiplier`。
>
> **占位倍率表**（MVP阶段使用，垂直切片时由 feline-combat.md 细化）：
>
> | attack_type | attack_type_multiplier | 状态 |
> |-------------|:---:|------|
> | light | 1.0 | 默认（通过 combo 递增） |
> | heavy_min | 1.2 | 占位（0.5s 蓄力） |
> | heavy_max | 2.0 | 占位（1.5s 满蓄力） |
> | aerial_dive | 1.5 | 占位（下劈） |

### DC-F3: reduction_factor（防御减伤系数）
`reduction_factor = 60 / (max(0, defense) + 60)`

| Variable | Type | Range | Description |
|----------|------|-------|-------------|
| defense | int | 0-50 | 目标防御力（负值由 max(0,...) 钳位到 0） |
| **输出** | float | 0.545-1.0 | 伤害保留比例 |

**Example**：defense=20 → reduction = 60/(20+60) = 0.75（25%减伤）

### DC-F4: final_damage（最终伤害）
`final_damage = clamp(floor(attack_damage × reduction_factor × damage_multiplier), 1, 999)`

| Variable | Type | Range | Description |
|----------|------|-------|-------------|
| attack_damage | float | 10-700 | DC-F2输出 |
| reduction_factor | float | 0.545-1.0 | DC-F3输出 |
| damage_multiplier | float | 0.5-2.0 | 全局伤害倍率（旋钮，默认1.0） |
| **输出** | int | 1-999 | 目标实际受到的伤害 |

**Example**：attack=78, reduction=0.857, damage_multiplier=1.0 → final = floor(78 × 0.857 × 1.0) = 66

### DC-F5: crit_multiplier（暴击判定）
```
if hit_frame ∈ [window_start, window_start+3): → 2.5（PERFECT）
if hit_frame ∈ [window_start+3, window_start+6): → 1.8（GOOD）
else: → 1.0（NORMAL）
```

> **窗口参数化**：上述 3 帧为 PERFECT 子窗口的基础宽度。实际总窗口宽度（PERFECT + GOOD）按敌人难度递减（小怪 8-10 帧，精英 5-6 帧，Boss 3-5 帧），由 AI 系统配置 `window_start` 和窗口宽度。倍率值（2.5/1.8/1.0）固定不变。`window_start` 的参考系为敌人破绽暴露的起始帧（由 AI 框架定义）。
>
> **Boss 最小窗口退化**：当敌人总破绽窗口 ≤ 3 帧时，PERFECT 子窗口占据全部窗口（`min(3, total_window)` 帧），GOOD 子窗口宽度为 0——仅 PERFECT 或 NORMAL 可能，无中间地带。这是高难度 Boss 的有意设计：要么完美读招获得最高回报，要么时机不对全额惩罚。`hit_frame`: int ≥ 0，表示攻击命中的动画帧号（参考系由战斗系统定义）。

### DC-F6: combo_multiplier（连招倍率）
查表：`combo_multiplier = combo_table[weapon_type][combo_index]`

| combo_index | 猫爪 | 长尾刃 | 鱼骨大剑 | 电磁铃铛 |
|:---:|:---:|:---:|:---:|:---:|
| 0 | 1.0× | 1.0× | 1.0× | 1.0× |
| 1 | 1.2× | 1.15× | 1.3× | 1.1× |
| 2 | 1.8× | 1.7× | 2.2× | 1.5× |

### DC-F7: parry_multiplier（弹反倍率）
```
frame_diff = enemy_attack_frame - parry_frame
if frame_diff < 0: → 1.0（NO — 事后按键，不触发弹反）
if frame_diff ∈ [0,7): → 5.0（PERFECT）
if ∈ [7,13): → 2.5（GOOD）
if ∈ [13,19): → 1.5（LATE）
else: → 1.0（NO）
```

### DC-F8: elemental_modifier（属性克制）— MVP推迟
MVP阶段所有元素为none，modifier=1.0。垂直切片后加入：克制1.5x / 中性1.0x / 抗性0.5x。

### DC-F9: special_move_damage（特殊招式伤害）

特殊招式使用独立倍率，**不与 combo_multiplier 叠加**（特殊招式替代连招序列，而非叠加其上）。每击独立走完整伤害流水线（DC-F1→DC-F2→DC-F3→DC-F4）。

`special_attack_damage = base_damage × special_multiplier × crit_multiplier`
`special_final = clamp(floor(special_attack_damage × reduction_factor × damage_multiplier), 1, 999)`

| Variable | Type | Range | Description |
|----------|------|-------|-------------|
| base_damage | int | 10-56 | DC-F1输出（含skill-tree F9技能树修正） |
| special_multiplier | float | 0.8-2.0 | 招式固有倍率（见下表） |
| crit_multiplier | float | 1.0/1.8/2.5 | 每击独立判定暴击窗口（DC-F5） |
| reduction_factor | float | 0.545-1.0 | DC-F3输出 |
| damage_multiplier | float | 0.5-2.0 | DC-F4全局倍率 |

| 武器 | 特殊招式 | special_multiplier | 命中次数 | 总倍率 | 冷却 |
|------|---------|:---:|:---:|:---:|:---:|
| 猫爪 | 疾风连爪 | 0.8 | 5 | 4.0× | 8秒 |
| 长尾刃 | 旋风斩 | 1.5 | 1 | 1.5× | 10秒 |
| 鱼骨大剑 | 地裂斩 | 2.0 | 1 | 2.0× | 12秒 |
| 电磁铃铛 | 电磁脉冲 | — | — | DoT独立定义 | 15秒 |

**暴击判定**：疾风连爪每击独立判定 crit 窗口（基于各击的 hit_frame vs 敌人破绽窗口）。旋风斩/地裂斩为单次攻击，单次 crit 判定。

**非伤害约束**：冷却时间、猫气消耗、眩晕时长等非伤害参数由 weapon-styles.md 和 feline-combat.md 定义。

**MVP状态**：鱼骨大剑和电磁铃铛为 MVP 外武器，其特殊招式伤害公式在垂直切片阶段补完。当前占位供参考。

**Example**：疾风连爪(base=13, 全 NORMAL crit, def=20) → 5 × floor(13 × 0.8 × 1.0 × 0.75 × 1.0) = 5 × 7 = **35**
**Example**：旋风斩(base=20, PERFECT crit, def=0) → floor(20 × 1.5 × 2.5 × 1.0 × 1.0) = **75**

### 技巧差距验证（MVP阶段，无元素克制）

**场景设定**：
- 敌人：defense=30，reduction_factor=0.667
- 高手：基础猫爪（weapon_base=10, attack_power=0）→ base_damage=10
- 菜鸟：满级鱼骨大剑（weapon_base=40, attack_power=50）→ base_damage=50

**完整对比表**：

| 操作 | 高手（基础猫爪） | 菜鸟（满级鱼骨） | 比值 |
|------|:---:|:---:|:---:|
| **普通攻击** | floor(10×1.0×1.0×0.667)=**6** | floor(50×1.0×1.0×0.667)=**33** | 菜鸟5.5x |
| **PERFECT暴击**（无连招） | floor(10×2.5×1.0×0.667)=**16** | floor(50×2.5×1.0×0.667)=**83** | 菜鸟5.2x |
| **连招终结**（无暴击） | floor(10×1.0×1.8×0.667)=**12** | floor(50×1.0×2.2×0.667)=**73** | 菜鸟6.1x |
| **连招终结+PERFECT暴击** | floor(10×2.5×1.8×0.667)=**30** | floor(50×2.5×2.2×0.667)=**183** | 菜鸟6.1x |
| **PERFECT弹反**（无暴击） | floor(10×5.0×1.0×0.667)=**33** | floor(50×5.0×1.0×0.667)=**166** | 菜鸟5.0x |
| **PERFECT弹反+PERFECT暴击** | floor(10×5.0×2.5×0.667)=**83** | floor(50×5.0×2.5×0.667)=**416** | 菜鸟5.0x |

**关键验证点**：

| 对比场景 | 高手伤害 | 菜鸟伤害 | 比值 | 结论 |
|----------|:---:|:---:|:---:|------|
| 高手巅峰（弹反暴击）vs 菜鸟普通 | 83 | 33 | **高手2.5x** ✅ | 跨装备技巧优先成立 |
| 高手连招暴击 vs 菜鸟普通 | 30 | 33 | 0.91x | 接近持平 |
| 高手普通 vs 菜鸟普通 | 6 | 33 | 0.18x | 装备差距显著 |
| 高手弹反暴击 vs 菜鸟连招暴击 | 83 | 183 | 0.45x | 菜鸟也精准时装备优势显现 |
| **同装备（基础猫爪）弹反暴击 vs 普通** | 83 | 6 | **高手13.8x** | 同装备技巧倍率远超装备差距 |
| **同装备（满级鱼骨）弹反暴击 vs 普通** | 416 | 33 | **高手12.6x** | 同装备下技巧放大一致 |

**设计解读**：
- **技巧优先成立条件**：高手执行最高风险操作（PERFECT弹反+暴击）时，伤害是菜鸟普通攻击的**2.5倍**
- **弹反回报验证**：PERFECT弹反（无暴击，33）> 连招终结+PERFECT暴击（30）✅ 最高风险操作作为独立操作即为最优
- **装备差距仍然存在**：如果菜鸟也偶尔打出暴击（即使是GOOD 1.8x），伤害=75，仍高于高手的连招暴击30
- **设计意图**：技巧让你**稳定**打出好伤害（弹反暴击83），装备让你**偶尔**打出更高伤害（暴击416）。高手的优势在于**一致性**——每次操作都可预测，而菜鸟依赖运气

**MVP技巧优先承诺**：✅ 成立（2.5x巅峰优势），但需配合视觉反馈（弹反暴击的特殊特效）让玩家感知到技巧回报

## Edge Cases

- **attack_power=0**：base_damage = weapon_base + 0，仍然有效
- **defense=0**：reduction_factor = 1.0，无减伤
- **弹反超时（>18帧）**：parry_multiplier = 1.0，正常受击
- **连招超时（>300ms）**：combo_index重置，combo_multiplier = 1.0
- **crit窗口与parry窗口重叠**：两者可叠加（弹反暴击 = 最高伤害）
- **final_damage计算结果<1**：clamp到1，保证最低伤害反馈
- **final_damage计算结果>999**：clamp到999，三位数上限
- **defense为负值**：DC-F3入口执行 `defense = max(0, defense)` 下界保护，防止除零或减伤反转
- **weapon_base超出范围**：数据验证层在加载时拦截
- **多段伤害 floor 截断累积偏差**：DC-F9 的多段招式（如疾风连爪 5 击）每击独立执行 DC-F4 的 floor 操作，导致累积截断损失高于同等总倍率的单次攻击。示例：base=13, special=0.8×5, defense=50(reduction=0.545) → 每击 floor(13×0.8×1.0×0.545)=floor(5.67)=5, 5击总计25；同等单次(special=4.0) → floor(13×4.0×1.0×0.545)=floor(28.34)=28。**这是有意设计**：多段招式风险低（每击独立暴击判定）、连击感强，以总伤害略低换取操作容错；单次爆发招式风险高（一锤定音）、容错低，以更高单次伤害补偿。设计意图为"DPS 型 vs 爆发型"的差异化。

## Dependencies

**上游依赖**：
- 数据/平衡基础设施 — 读取damage_params域、damage_multiplier旋钮
- 输入系统 — 接收攻击动作类型、combo_index
- 战斗系统 — 提供命中帧、弹反时机
- 技能树系统 — skill-tree.md F9 提供 skill_weapon_base（替换 weapon_base），modifier provider 提供被动加成
- 护符/装备系统 — charm_bonus 通过技能树 F8 统一上限公式间接影响 attack_power（跨系统接口；charm-equipment 计算 charm_bonus → skill-tree F8 执行 combined_bonus → 消费方使用 final_stat）

**跨系统依赖注释**：
- **charm_crit 兼容性**（✅ 2026-06-21 已修复）：charm-equipment.md 的 `charm_crit` 已改为"暴击窗口+1帧"（PERFECT窗口3→4帧），与本系统的确定性时机窗口暴击机制兼容。实现时在 DC-F5 PERFECT 判定中检查 charm_crit 装备状态并扩展窗口
- **技能树 DC-F8 统一上限**：attack_power 可能受技能树+护符的 combined_bonus 影响（`final_stat = base_stat × (1 + combined_bonus)`），此计算由消费方执行，本系统接收最终 attack_power 值

**下游被依赖**：
- 生命与死亡检测 — 接收final_damage扣减HP
- 视觉反馈 — 接收元数据触发帧停/震屏/粒子
- 音效系统 — 接收伤害类型触发音效
- AI框架 — 接收受到的伤害调整行为

## Tuning Knobs

| 旋钮 | 默认值 | 安全范围 | 过高影响 | 过低影响 |
|------|--------|---------|---------|---------|
| damage_multiplier | 1.0 | 0.5-2.0 | 伤害过高，Boss瞬杀 | 伤害过低，刮痧 |
| crit_perfect_multiplier | **2.5** | 2.0-3.5 | 暴击过强 | 暴击无感 |
| crit_good_multiplier | **1.8** | 1.5-2.5 | — | — |
| parry_perfect_multiplier | **5.0** | 3.0-6.0 | 弹反过强，唯一策略 | 弹反无吸引力 |
| parry_good_multiplier | **2.5** | 2.0-4.0 | — | — |
| combo_finisher_multiplier | 1.8 | 1.5-2.5 | 连招过强 | 连招无意义 |
| defense_curve_constant | 60 | 30-100 | 防御几乎无效 | 防御过高，刮痧 |
| damage_cap | 999 | 100-9999 | 数字过大 | 数字过小 |
| damage_floor | 1 | 1-10 | — | 可能完全无效 |
| combo_timeout | 300ms | 300-800ms | 连招无节奏感，变成乱按 | 连招过易，无操作门槛 |
| parry_late_multiplier | 1.5 | 1.0-2.0 | LATE弹反过强，降低精准动机 | LATE弹反无感，玩家放弃弹反 |
| crit_perfect_window | 3帧 | 2-5帧 | PERFECT暴击太容易 | PERFECT暴击不可能 |

## Acceptance Criteria

> **默认测试参数**：除非 AC 另有指定，所有测试使用以下默认值。
>
> | 参数 | 默认值 | 说明 |
> |------|--------|------|
> | weapon_id | "cat_claw" | 猫爪（weapon_base=10） |
> | skill_modifiers | 1.0 | 无技能树加成 |
> | hit_frame | OUTSIDE_WINDOW | 暴击窗口外（crit_multiplier=1.0） |
> | parry_timing | none | 不触发弹反（parry_multiplier=1.0） |
> | combo_index | 0 | 起手（combo_multiplier=1.0） |
> | attack_type | normal | 普通攻击 |
> | damage_multiplier | 1.0 | 全局默认 |
> | defense_curve_constant | 60 | 防御曲线常量 |

- **AC1** [全流水线基准] **GIVEN** weapon_base=10, attack_power=0, attack_type=normal, WHEN 普通攻击 defense=0 目标, THEN base_damage=10, reduction_factor=1.0, final_damage=**10**
- **AC2** [PERFECT暴击] **GIVEN** weapon_base=10, attack_power=0, attack_type=normal, combo_index=0, parry_timing=none, hit_frame=2(∈[window_start,window_start+3)=PERFECT), WHEN defense=0, THEN crit_multiplier=2.5, attack_damage=10×2.5×1.0=25, final_damage=clamp(floor(25×1.0×1.0),1,999)=**25**
- **AC3** [GOOD暴击] **GIVEN** weapon_base=10, attack_power=0, attack_type=normal, combo_index=0, parry_timing=none, hit_frame=4(∈[window_start+3,window_start+6)=GOOD), WHEN defense=0, THEN crit_multiplier=1.8, attack_damage=10×1.8×1.0=18, final_damage=clamp(floor(18×1.0×1.0),1,999)=**18**
- **AC4** [PERFECT弹反] **GIVEN** weapon_base=10, attack_power=0, attack_type=normal, combo_index=0, parry_timing=frame_diff=3(∈[0,7)=PERFECT), hit_frame=OUTSIDE_WINDOW, WHEN defense=0, THEN parry_multiplier=5.0, attack_damage=10×5.0×1.0=50, final_damage=clamp(floor(50×1.0×1.0),1,999)=**50**
- **AC5** [GOOD弹反] **GIVEN** weapon_base=10, attack_power=0, attack_type=normal, combo_index=0, parry_timing=frame_diff=10(∈[7,13)=GOOD), hit_frame=OUTSIDE_WINDOW, WHEN defense=0, THEN parry_multiplier=2.5, attack_damage=10×2.5×1.0=25, final_damage=clamp(floor(25×1.0×1.0),1,999)=**25**
- **AC6** [LATE弹反] **GIVEN** weapon_base=10, attack_power=0, attack_type=normal, combo_index=0, parry_timing=frame_diff=15(∈[13,19)=LATE), hit_frame=OUTSIDE_WINDOW, WHEN defense=0, THEN parry_multiplier=1.5, attack_damage=10×1.5×1.0=15, final_damage=clamp(floor(15×1.0×1.0),1,999)=**15**
- **AC7** [连招终结+PERFECT暴击] **GIVEN** weapon_base=13, attack_power=0, attack_type=normal, combo_index=2(连招终结段, combo_multiplier=1.8), hit_frame=2(PERFECT, crit_multiplier=2.5), parry_timing=none, WHEN defense=0, THEN attack_damage=13×2.5×1.8=58.5, reduction_factor=1.0, final_damage=clamp(floor(58.5×1.0×1.0),1,999)=**58**
- **AC8** [防御减伤] **GIVEN** weapon_base=10, attack_power=0, attack_type=normal, combo_index=0, hit_frame=OUTSIDE_WINDOW, parry_timing=none, WHEN defense=20, THEN reduction_factor=60/(20+60)=**0.75**, attack_damage=10, final_damage=clamp(floor(10×0.75×1.0),1,999)=**7**
- **AC9** [Boss级高防御] **GIVEN** weapon_base=10, attack_power=0, attack_type=normal, combo_index=0, hit_frame=OUTSIDE_WINDOW, parry_timing=none, WHEN defense=50, THEN reduction_factor=60/(50+60)≈**0.545**, attack_damage=10, final_damage=clamp(floor(10×0.545×1.0),1,999)=**5**
- **AC10** [damage_multiplier缩减] **GIVEN** weapon_base=10, attack_power=0, attack_type=normal, combo_index=0, hit_frame=OUTSIDE_WINDOW, parry_timing=none, damage_multiplier=0.5, WHEN defense=30, THEN reduction_factor=60/(30+60)≈0.667, attack_damage=10, final_damage=clamp(floor(10×0.667×0.5),1,999)=clamp(floor(3.335),1,999)=**3**
- **AC11** [连招超时重置] **GIVEN** weapon_base=10, attack_power=0, attack_type=normal, combo_index=1(中段, combo_multiplier=1.2), 超时300ms后, WHEN combo_index重置为0, THEN combo_multiplier=1.0, 下一击 attack_damage=10×1.0×1.0=10, final_damage=**10**（非连招中段的12）
- **AC12** [DC-F4单元测试：中间值] **GIVEN** attack_damage=100, reduction_factor=0.5, damage_multiplier=1.0, WHEN 计算最终伤害, THEN final_damage=clamp(floor(100×0.5×1.0),1,999)=**50**
- **AC13** [DC-F4单元测试：地板钳位] **GIVEN** attack_damage=1, defense=5940(reduction_factor=60/6000=0.01), WHEN floor(1×0.01×1.0)=0<1, THEN final_damage=**1**
- **AC14** [DC-F4单元测试：天花板钳位] **GIVEN** attack_damage=2000, defense=0(reduction_factor=1.0), WHEN floor(2000×1.0×1.0)=2000>999, THEN final_damage=**999**
- **AC15** [DC-F4单元测试：multiplier放大] **GIVEN** attack_damage=100, reduction_factor=0.75, damage_multiplier=1.5, WHEN 计算最终伤害, THEN final_damage=clamp(floor(100×0.75×1.5),1,999)=clamp(floor(112.5),1,999)=**112**
- **AC16** [DC-F4单元测试：multiplier+cap交互] **GIVEN** attack_damage=800, reduction_factor=1.0, damage_multiplier=2.0, WHEN floor(800×1.0×2.0)=1600>999, THEN final_damage=**999**（damage_multiplier放大后仍受damage_cap约束）
- **AC17a** [技巧优先验证：猫爪弹反暴击] **GIVEN** weapon_base=10, attack_power=0, attack_type=normal, combo_index=0, parry_timing=frame_diff=3(PERFECT, parry_multiplier=5.0), hit_frame=2(PERFECT, crit_multiplier=2.5), WHEN defense=30(reduction_factor=60/(30+60)≈0.667), THEN base_damage=DC-F1(10+0)=10, attack_damage=10×5.0×2.5=125, final_damage=clamp(floor(125×0.667×1.0),1,999)=**83**
- **AC17b** [技巧优先验证：鱼骨普通攻击] **GIVEN** weapon_id="fish_bone"(weapon_base=40), attack_power=50, attack_type=normal, combo_index=0, parry_timing=none, hit_frame=OUTSIDE_WINDOW, WHEN defense=30(reduction_factor≈0.667), THEN base_damage=DC-F1(40+floor(50×0.2))=40+10=50, attack_damage=50×1.0×1.0=50, final_damage=clamp(floor(50×0.667×1.0),1,999)=**33**
- **AC17c** [技巧优先断言] AC17a(final_damage=83) > AC17b(final_damage=33)，比值=2.5x ✅ 跨装备技巧优先成立
- **AC18** [DC-F9特殊招式：疾风连爪] **GIVEN** weapon_id="cat_claw"(weapon_base=10), attack_power=5, attack_type=special, combo_index=N/A(特殊招式不使用连招), parry_timing=none, hit_frame=OUTSIDE_WINDOW(NORMAL crit), WHEN 疾风连爪(special_multiplier=0.8, hits=5) vs defense=20(reduction_factor=0.75), THEN base_damage=DC-F1(10+floor(5×0.2))=10+1=11, 每击=floor(11×0.8×1.0×0.75×1.0)=floor(6.6)=6, 5击总计=**30**
- **AC19** [DC-F9特殊招式：旋风斩] **GIVEN** weapon_id="long_tail"(weapon_base=15), attack_power=10, attack_type=special, combo_index=N/A, parry_timing=none, hit_frame=2(PERFECT, crit_multiplier=2.5), WHEN 旋风斩(special_multiplier=1.5, hits=1) vs defense=0(reduction_factor=1.0), THEN base_damage=DC-F1(15+floor(10×0.2))=15+2=17, attack_damage=17×1.5×2.5=63.75, final_damage=clamp(floor(63.75×1.0×1.0),1,999)=**63**
- **AC20** [弹反+防御联合] **GIVEN** weapon_base=10, attack_power=0, attack_type=normal, combo_index=0, parry_timing=frame_diff=3(PERFECT, parry_multiplier=5.0), hit_frame=OUTSIDE_WINDOW(NORMAL crit), WHEN defense=20, THEN base_damage=10, attack_damage=10×5.0×1.0=50, reduction_factor=0.75, final_damage=clamp(floor(50×0.75×1.0),1,999)=**37**

## Visual/Audio Requirements

### 伤害数字视觉反馈（由视觉反馈系统消费）

| 伤害范围 | 数字样式 | 特效 |
|----------|---------|------|
| 1-5（刮痧） | 白色小字 | 无 |
| 6-15（正常） | 白色标准字 | 无 |
| 16-30（有力） | 黄色中字 | 轻微震屏（2帧） |
| 31-60（强力） | 金色大字 | 帧停4帧 + 震屏 |
| 61-150（极限） | 猫眼金色超大字 | 帧停8帧 + 震屏 + 刃白粒子 |
| 151-999（传说） | 特殊动画（待设计） | 全屏特效 |

### 暴击视觉反馈
- PERFECT暴击（2.5x）：金色"暴击"数字 + 帧停8帧 + 全屏震屏 + 刃白闪光 + 手柄强震
- GOOD暴击（1.8x）：白色"精准"数字 + 帧停4帧 + 轻微震屏

### 弹反视觉反馈
- PERFECT弹反（5.0x）：全屏闪白 + 火花粒子 + 8帧帧停 + 清脆金属碰撞音 + 手柄强震
- GOOD弹反（2.5x）：小火花 + 4帧帧停 + 沉闷碰撞音
- LATE弹反（1.5x）：微弱火花 + 角色受击但减伤

### 音效设计
- 普通攻击命中：轻快打击音
- 暴击命中：强化打击音 + 金属共鸣
- 弹反成功：清脆金属碰撞（高频=PERFECT，低频=GOOD）
- 受击：低沉撞击音

## UI Requirements

### 伤害数字显示
- 位置：受击目标头顶
- 存在时间：1.5秒（淡出）
- 叠加规则：多次伤害数字独立显示，不合并
- 玩家伤害数字：始终显示
- 敌人伤害数字：可在设置中关闭（无障碍选项）

### 战斗统计（可选，设置中开启）
- 总伤害输出
- 暴击率
- 弹反成功率
- DPS（每秒伤害）

## Open Questions

| # | 问题 | 负责人 | 目标解决时间 |
|---|------|--------|-------------|
| 1 | 元素克制表的具体属性类型？ | game-designer | 垂直切片阶段 |
| 2 | 传说伤害（301-999）的特殊动画设计？ | art-director | 美术资源制作时 |
| 3 | 是否需要"伤害统计面板"供玩家查看DPS等数据？ | ux-designer | UI设计阶段 |
