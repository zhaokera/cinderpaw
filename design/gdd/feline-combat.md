# 猫科战斗系统 (Feline Combat System)

> **Status**: Designed (awaiting review)
> **Author**: 用户 + AI
> **Last Updated**: 2026-06-18
> **Implements Pillar**: 猫科战斗美学, 技巧优先成长
> **Systems Index**: #5 | MVP核心 | Core

## Overview

**猫科战斗系统**是《废土喵影》的核心玩法引擎，负责将玩家的输入转化为猫武士的战斗行为。它管理攻击状态机（轻攻击、重攻击、连招链）、防御动作（闪避、弹反）、以及与伤害计算和碰撞系统的协调。

**玩家直接感受它**：这是游戏中玩家交互最频繁的系统——每一次挥爪、每一次闪避、每一次弹反都由它驱动。它决定了战斗是否"爽"、是否"流畅"、是否"有猫的感觉"。

**技术职责**：
- 攻击状态机：管理轻攻击3段连招、重攻击蓄力、空中攻击
- 防御动作：闪避（i-frame无敌帧）、弹反（时机窗口判定）
- 动作取消规则：哪些动作可以取消哪些动作（如闪避可取消攻击后摇）
- 与输入系统协调：消费`action_triggered`信号，管理动画锁定
- 与伤害计算协调：传递攻击参数（武器类型、combo_index、弹反时机）
- 与碰撞系统协调：管理Hitbox/Hurtbox的激活和停用（provisional接口）

**为什么存在**：没有它，输入只是按键——没有"猫武士在战斗"的体验。战斗系统是"按键"变成"猎杀"的桥梁。

## Player Fantasy

**「猫狩直觉」+「蓄势倾泻」— 猎手本能的战斗节奏**

猫科战斗系统的终极使命是让每一次战斗都像**猫科猎手的本能释放**。不是机械地按键，而是读懂猎物、选择时机、一击致命。

**锚定时刻（进攻节奏）**：面对精英敌人，轻攻击起手→第二击积累→终结一击释放。每一击的伤害数字递增，最后一击伴随帧停和震屏弹出金色大字——玩家感受到"这套连招真漂亮"。

**锚定时刻（防御反击）**：敌人巨爪挥来，玩家在最后一帧弹反——全屏闪白、火花四溅、清脆金属碰撞。猫武士不退反进，全额反弹伤害。那一刻的感受是"我看穿了你的节奏，你的力量成了我的"。

**锚定时刻（闪避流动）**：连续三次闪避穿过敌人的连击，每次闪避都有精准的i-frame窗口。闪避后立刻反击，动作流畅如行云流水——玩家感受到"我比它快"。

**核心承诺**：
- **进攻有节奏**：连招不是乱按，是有韵律的攻击序列
- **防御有回报**：闪避和弹反不是被动挨打，是反击的开始
- **猫科有本能**：战斗流畅到像猫的本能——不需要思考，只需要感受

## Detailed Design

### Core Rules

#### 规则1：攻击状态机

**轻攻击（3段连招）**：
- 第1击：快速起手（前摇4帧），低伤害，短后摇（8帧）
- 第2击：中速（前摇6帧），中伤害，中后摇（12帧）
- 第3击（终结）：慢速（前摇10帧），高伤害，长后摇（20帧）
- 连招链由输入系统管理（combo_index），战斗系统根据combo_index选择动画和伤害参数

**重攻击（蓄力）**：
- 按住heavy_attack键蓄力（0.5-1.5秒），松开释放
- 蓄力时间影响伤害倍率（F1公式由伤害计算系统定义）
- 蓄力期间可被打断（受击=蓄力中断，闪避=取消蓄力）

**空中攻击**：
- 空中按attack=下劈攻击，命中敌人可弹跳（恢复一次跳跃）
- 空中按heavy_attack=俯冲攻击，落地产生冲击波

#### 规则2：防御动作

**闪避（Dodge）**：
- 触发：按下dodge键
- i-frame无敌帧：第3-10帧（共8帧≈133ms）
- 位移距离：3个角色宽度
- 冷却：0.5秒（防止无限闪避）
- 可取消：攻击后摇、重攻击蓄力

**闪避设计意图说明**：闪避提供低风险防御选项，i-frame覆盖率约19%（8帧/42帧循环）。设计允许"无限闪避"策略作为新手友好路径，但技巧差距在以下方面体现：
1. **DPS差距**：闪避流DPS低于弹反流约30%（弹反5.0×倍率 vs 闪避后攻击1.8×暴击）
2. **进攻机会成本**：闪避时无法攻击，弹反后获得1秒眩晕窗口可打完整连招
3. **Boss战压力**：多阶段Boss攻击模式密集时，闪避冷却0.5秒成为限制，需要弹反填补
4. **猫气管理**：闪避不消耗猫气但也不获取，弹反成功获取+15猫气，长期战斗中弹反流猫气更充裕

如playtest显示闪避使用率过高（>70%防御动作），优先调整：(1)降低i-frame帧数至6帧，(2)增加闪避冷却至0.7秒，(3)提高弹反倍率至6.0×。

**闪避后反击窗口（猫爪专属）**：
闪避结束后，猫爪武器进入**反击窗口**状态，持续30帧（0.5秒）。此窗口内：
- 攻击的PERFECT暴击窗口+3帧（从3帧扩展为6帧）
- 与charm_crit（+1帧）和focus_mode（+1帧）叠加，最大可达8帧
- 窗口状态变量：`dodge_counter_window: int`（闪避结束时设为30，每帧递减）

**实现接口**：
```
on_dodge_end() → void:
    if current_weapon == "cat_claw":
        dodge_counter_window = 30
        emit_signal("on_dodge_counter_active", true)

_physics_process(delta):
    if dodge_counter_window > 0:
        dodge_counter_window -= 1
        if dodge_counter_window == 0:
            emit_signal("on_dodge_counter_active", false)
```

**伤害计算集成**（damage-calculation.md DC-F5）：
```
perfect_window_base = 3
if dodge_counter_active: perfect_window_base += 3  # 猫爪闪避后反击
if charm_crit_equipped: perfect_window_base += 1
if focus_mode_active: perfect_window_base += 1
# 最大: 3+3+1+1 = 8帧
```

**弹反（Parry）**：
- 触发：按下parry键（优先级100，最高）
- 弹反窗口：第1-18帧（PERFECT=0-6帧，GOOD=7-12帧，LATE=13-18帧）
- 成功弹反：敌人眩晕1秒，猫武士自动反击（伤害由伤害计算F7定义）
- 失败弹反：正常受击（无额外惩罚）
- 不可取消：弹反一旦触发必须播放完整动画

#### 规则3：动作取消规则

| 当前动作 | 可取消的动作 |
|----------|-------------|
| 轻攻击第1/2击后摇 | 闪避、下一击轻攻击 |
| 轻攻击第3击后摇 | 闪避（不可接下一击） |
| 重攻击蓄力 | 闪避（取消蓄力） |
| 闪避 | 无（必须播放完整） |
| 弹反 | 无（必须播放完整） |
| 受击硬直 | 无（必须播放完整） |

#### 规则4：与输入系统协调

- 消费`action_triggered(action_id, metadata)`信号
- 根据action_id选择动作（attack→轻攻击，heavy_attack→重攻击，dodge→闪避，parry→弹反）
- metadata中的combo_index决定连招阶段
- 动作开始时调用`notify_animation_lock(duration_ms)`通知输入系统进入缓冲模式
- 动作结束时调用`notify_animation_unlock()`通知输入系统恢复直通模式

#### 规则5：与伤害计算协调

攻击命中时（由碰撞系统检测）：
```
calculate_damage(
    attack_type: "light" | "heavy" | "aerial",
    weapon_id: current_weapon,
    hit_frame: current_frame,
    combo_index: from input metadata,
    parry_timing: from parry window check
) → final_damage + metadata
```
将结果传递给生命系统`apply_damage(target, final_damage, metadata)`

#### 规则6：与碰撞系统协调

- 攻击动作激活Hitbox（攻击判定框）：前摇结束后调用`activate_hitbox(entity, hitbox_id, duration_frames, offset, size)`
- 防御动作激活Hurtbox缩小：调用`set_hurtbox_state(entity, "shrunk")`
- 闪避i-frame期间：调用`set_hurtbox_state(entity, "gone")`
- 监听`on_hit_confirmed(attacker, target, hit_data)`信号，传递attack_metadata给伤害计算

#### 规则7：猫气系统

特殊招式同时受**冷却**和**猫气**双重约束。猫气是战斗资源，由战斗行为产生，由战斗技能消耗。

| 属性 | 值 |
|------|:---:|
| 最大容量 | 100 |
| 初始值 | 0 |
| 衰减 | 无 |

**脱战清零**：脱战后猫气归零。脱战定义：无敌人伤害交互（施受均算）持续**10秒**，或发生场景切换。

**猫气获取**：

| 行为 | 获取 |
|------|:---:|
| 普通攻击（轻攻击第1击） | +5 |
| 连招第2击命中 | +8 |
| 连招第3击（终结）命中 | +12 |
| 重攻击（蓄力）命中 | +10 |
| 空中攻击命中 | +8 |
| 特殊招式每段命中 | +3 |
| 弹反后自动反击命中 | +15 |
| PERFECT闪避（i-frame命中） | +15 |
| PERFECT弹反 | +20 |
| GOOD弹反 | +10 |
| 受到敌人伤害 | +3 |

**连招中断规则**：连招被中断时已获取的猫气保留（已命中的攻击已生效）。

**特殊招式消耗**：

| 武器 | 特殊招式 | 猫气消耗 | 冷却 |
|------|---------|:---:|:---:|
| 猫爪 | 疾风连爪 | 30 | 8秒 |
| 长尾刃 | 旋风斩 | 40 | 10秒 |
| 鱼骨大剑 | 地裂斩 | 50 | 12秒 |
| 电磁铃铛 | 电磁脉冲 | 60 | 15秒 |

**极意技消耗**（需技能树T5解锁）：

| 武器 | 极意技 | 猫气消耗 | 冷却 |
|------|--------|:---:|:---:|
| 猫爪 | 九命乱舞 | 80 | 60秒 |
| 长尾刃 | 银弧断空 | 80 | 75秒 |
| 鱼骨大剑 | 鱼骨天崩 | 80 | 90秒 |
| 电磁铃铛 | 电磁风暴 | 80 | 120秒 |

**猫气状态**：

| 状态 | 条件 |
|------|------|
| 空（0） | 战斗开始/脱战后 |
| 充能中 | 攻击/闪避/弹反积累 |
| 满（100） | 可释放任意特殊招式 |

**跨系统接口**：
- 技能树系统查询 `has_unlocked_ultimate(weapon_id) → bool`（T5门控）
- 技能树modifier可修改猫气获取率（当前无此类节点，预留接口）

### States and Transitions

**战斗状态机（6状态）**：

| 状态 | 触发 | 行为 |
|------|------|------|
| IDLE | 初始化/动作结束 | 待机，等待输入 |
| ATTACKING | attack/heavy_attack输入 | 播放攻击动画，激活Hitbox |
| DODGING | dodge输入 | 播放闪避动画，i-frame激活 |
| PARRYING | parry输入 | 播放弹反动画，检测弹反窗口 |
| HIT_STUN | 受击 | 播放受击动画，不可操作 |
| CHARGING | heavy_attack按住 | 蓄力状态，可被打断 |

**状态转换**：
- IDLE → ATTACKING/DODGING/PARRYING/CHARGING：接收对应输入
- ATTACKING → IDLE：动画播放完成
- ATTACKING → DODGING：闪避取消攻击后摇
- CHARGING → ATTACKING：松开heavy_attack键
- CHARGING → DODGING：闪避取消蓄力
- CHARGING → HIT_STUN：受击打断蓄力
- DODGING → IDLE：闪避动画完成
- PARRYING → IDLE：弹反动画完成（成功或失败）
- PARRYING → ATTACKING：弹反成功自动反击
- HIT_STUN → IDLE：硬直动画完成
- 任意 → HIT_STUN：受到致命伤害（HP>0时）
- 任意 → DEAD：HP≤0（由生命系统触发）

### Interactions with Other Systems

#### 上游依赖（输入）
- **输入系统**：消费`action_triggered`信号，获取combo_index、弹反时机
- **伤害计算系统**：调用`calculate_damage()`获取伤害结果
- **碰撞系统**（provisional）：Hitbox/Hurtbox检测命中
- **技能树系统**：查询`has_unlocked_ultimate(weapon_id)`（极意技T5门控），接收modifier对猫气获取率的修改

#### 下游被依赖（输出）
- **生命系统**：调用`apply_damage(target, final_damage, metadata)`
- **视觉反馈系统**：发射`on_attack_hit`信号（伤害元数据）
- **武器流派系统**：查询当前武器类型，决定攻击参数

#### 接口签名
```
# 输入
on_action_triggered(action_id: StringName, metadata: Dictionary) → void
on_hitbox_collision(attacker_hitbox, target_hurtbox) → void  # provisional

# 专注模式输入（来自 health-death.md）
on_focus_mode_changed(active: bool) → void
  # active=true 时：PERFECT暴击窗口 +1帧（3帧→4帧），使低血量玩家更容易打出暴击
  # active=false 时：恢复默认窗口
  # 仅影响暴击窗口，不影响弹反窗口（弹反窗口由玩家操作精度决定，不应随HP变化）

# 输出
apply_damage(target_id, final_damage: int, metadata: Dictionary) → void
on_attack_hit(metadata: Dictionary) → void  # 视觉反馈系统监听
```

## Formulas

本系统不定义新公式——伤害计算由伤害计算系统（F1-F8）负责。战斗系统传递参数：
- `combo_index` → 伤害计算F6查表
- `parry_timing` → 伤害计算F7判定
- `attack_type` → 伤害计算F2选择公式

## Edge Cases

- **弹反和闪避同帧输入**：弹反优先（优先级100 > 闪避90）
- **连招超时（>300ms）**：combo_index重置为0，下一击为第1击
- **闪避冷却中再次按闪避**：忽略输入，无反馈
- **空中闪避**：不允许（空中只能跳跃和下劈）
- **弹反成功但敌人已死亡**：不触发反击动画，直接回到IDLE
- **蓄力超过最大时间（1.5秒）**：自动释放，视为满蓄力攻击
- **受击硬直中再次受击**：叠加硬直时间（最多3次叠加）

## Dependencies

**上游依赖**：
- 输入系统 — 提供动作信号和combo_index
- 伤害计算系统 — 计算伤害结果
- 碰撞系统（provisional） — 检测Hitbox/Hurtbox命中
- 生命与死亡检测系统 — 监听`on_focus_mode_changed`信号，激活时PERFECT暴击窗口+1帧（3→4帧）

**下游被依赖**：
- 生命系统 — 接收apply_damage调用
- 视觉反馈系统 — 监听on_attack_hit信号
- 武器流派系统 — 查询武器类型
- 音效系统 — 监听on_hit, on_parry, on_dodge事件触发音效
- 战斗表现系统 — 监听on_hit_confirmed信号触发帧停/震屏
- 玩家能力系统 — 查询能力状态（如闪避增强）
- 状态效果系统 — 监听攻击命中应用效果
- HUD/UI系统 — 监听战斗事件更新UI

## Tuning Knobs

| 旋钮 | 默认值 | 安全范围 | 过高影响 | 过低影响 |
|------|--------|---------|---------|---------|
| light_attack_startup_frames | 4/6/10 | 3-15 | 攻击太慢 | 攻击太快无反应时间 |
| light_attack_recovery_frames | 8/12/20 | 5-30 | 连招太慢 | 连招太快无节奏 |
| dodge_iframe_start | 3 | 1-5 | i-frame太早 | i-frame太晚 |
| dodge_iframe_end | 10 | 6-15 | i-frame太长 | i-frame太短 |
| dodge_distance | 3.0 | 1.5-5.0 | 闪避太远 | 闪避太近 |
| dodge_cooldown_sec | 0.5 | 0.2-1.0 | 闪避太频繁 | 闪避太慢 |
| parry_window_frames | 18 | 12-24 | 弹反太容易 | 弹反太难 |
| heavy_charge_min_sec | 0.5 | 0.3-1.0 | 蓄力太快 | 蓄力太慢 |
| heavy_charge_max_sec | 1.5 | 1.0-3.0 | 蓄力太久 | 蓄力太短 |

## Acceptance Criteria

- **GIVEN** 玩家按attack，**WHEN** IDLE状态，**THEN** 进入ATTACKING状态，播放第1击动画
- **GIVEN** 玩家在第1击后摇期间按attack，**WHEN** combo超时未触发，**THEN** combo_index重置，播放第1击
- **GIVEN** 玩家按dodge，**WHEN** 攻击后摇期间，**THEN** 取消攻击，进入DODGING状态
- **GIVEN** 敌人攻击命中玩家，**WHEN** 玩家处于闪避i-frame（3-10帧），**THEN** 伤害为0
- **GIVEN** 玩家按parry，**WHEN** 敌人攻击在0-6帧窗口内命中，**THEN** PERFECT弹反，敌人眩晕1秒
- **GIVEN** 玩家按住heavy_attack 1.0秒后松开，**WHEN** IDLE状态，**THEN** 释放蓄力攻击
- **GIVEN** 玩家在空中按attack，**WHEN** 命中敌人，**THEN** 下劈攻击+弹跳恢复跳跃
- **GIVEN** 玩家连续闪避，**WHEN** 冷却时间未到，**THEN** 忽略闪避输入

## Visual/Audio Requirements

### 攻击视觉反馈
- **轻攻击**：爪痕轨迹（白色弧线，持续0.3秒），命中时火花粒子
- **重攻击蓄力**：猫武士身体发光（琥珀色），蓄力越久越亮
- **重攻击释放**：大范围斩击特效（猫眼金色），震屏4帧
- **下劈攻击**：垂直斩击轨迹，命中弹跳时地面裂纹粒子
- **连招终结**：最后一击特效放大50%，金色"终结"文字弹出

### 防御视觉反馈
- **闪避**：残影效果（3帧半透明残影），i-frame期间角色闪烁
- **弹反成功（PERFECT）**：全屏闪白8帧，火花粒子爆发，金属碰撞音效
- **弹反成功（GOOD）**：小火花，4帧帧停
- **弹反失败**：角色受击特效

### 音效设计
- **轻攻击**：快速爪击音（随combo递增音调）
- **重攻击蓄力**：持续嗡鸣音（音调随蓄力升高）
- **重攻击释放**：重击音+金属共鸣
- **闪避**：短促风声
- **弹反成功**：清脆金属碰撞（高频=PERFECT，低频=GOOD）
- **受击**：低沉撞击音

## UI Requirements

### 连招指示器
- 位置：角色头顶偏上
- 显示：当前combo_index（1/2/3），数字递增动画
- 超时提示：combo即将超时时数字闪烁

### 蓄力条
- 位置：角色下方
- 显示：蓄力进度（0-100%），颜色从白色渐变到猫眼金
- 满蓄力提示：条满时闪烁

## Open Questions

| # | 问题 | 负责人 | 目标解决时间 |
|---|------|--------|-------------|
| 1 | 碰撞系统的Hitbox/Hurtbox接口规格？ | game-designer | 碰撞系统GDD |
| 2 | 是否需要"无敌帧"（受伤后短暂无敌）？ | game-designer | 猫科战斗系统GDD |
| 3 | 空中攻击的弹跳高度和恢复机制？ | game-designer | 玩家移动系统GDD |
