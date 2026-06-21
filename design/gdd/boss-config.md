# Boss配置层 (Boss Configuration Layer)

> **Status**: Designed (awaiting review)
> **Author**: 用户 + AI
> **Last Updated**: 2026-06-18
> **Implements Pillar**: 猫科战斗美学, 技巧优先成长
> **Systems Index**: #9 | MVP核心 | Core

## Overview

**Boss配置层**为Boss战斗提供数据驱动的配置管理。它扩展AI框架，定义每个Boss的独特参数：HP、阶段数量、每阶段攻击模式、阶段转换动画、击败奖励。MVP包含1个Boss——**垃圾桶鼠王**。

## Player Fantasy

**「巨兽面前的猫」— 以小博大的猎手荣光**

Boss战的终极使命是让玩家感受到"我不该赢，但我赢了"。Boss体型是猫的5-10倍，力量碾压性地强——但猫更快、更灵活、更聪明。三阶段递进的情绪弧线：威压（"它太强了"）→ 焦灼（"我找到规律了"）→ 殊死（"最后一搏"）。当Boss最终倒下时，玩家感受到的是**猎杀巨兽的荣光**。

## Detailed Design

### Core Rules

#### 规则1：Boss配置数据结构
```
boss_config = {
    boss_id: String,
    display_name: String,
    max_hp: int,
    phases: [
        {
            phase_id: int,
            hp_threshold: float,      # 0.66, 0.33
            attack_patterns: Array,   # 引用AI框架攻击模式
            attack_speed_modifier: float,  # 1.0/1.2/1.5
            special_attacks: Array,   # 阶段独有特殊攻击
            transition_animation: String,
            arena_changes: Array      # 阶段转换时竞技场变化
        }
    ],
    defeat_rewards: { ability_unlock: String, currency: int, skill_points: int },
    arena_bounds: Rect2
}
```

#### 规则2：阶段转换流程
1. 生命系统检测到HP≤阈值 → 发射`on_boss_phase_change(boss_id, new_phase)`
2. Boss配置层接收信号 → 暂停Boss当前攻击
3. 播放阶段转换动画（2-3秒，Boss无敌）
4. 应用竞技场变化（如：地面漏电区域出现）
5. 加载新阶段攻击模式 → 恢复Boss行动
6. 攻击速度应用`attack_speed_modifier`

#### 规则3：MVP Boss — 垃圾桶鼠王

| 属性 | 值 |
|------|-----|
| max_hp | 300 |
| 体型 | 猫武士的8倍 |

**阶段1（HP 100-66%）：威压**
- 攻击速度：1.0x
- 攻击模式：冲撞（startup 20帧）、挥爪（startup 15帧）
- 特殊攻击：无
- 破绽窗口：冲撞后摇8帧、挥爪后摇6帧

**阶段2（HP 66-33%）：焦灼**
- 攻击速度：1.2x
- 新增攻击：召唤小老鼠（每15秒1只，最多2只同时存在）
- 新增攻击：跳跃砸地（startup 25帧，范围攻击）
- 竞技场变化：地面出现垃圾堆（障碍物）
- 破绽窗口：跳跃砸地后摇12帧

**阶段3（HP 33-0%）：殊死**
- 攻击速度：1.5x
- 新增攻击：狂暴连击（连续3次挥爪，每次startup 10帧）
- 竞技场变化：垃圾桶翻倒（新增障碍物+伤害区域）
- 新增机制：HP<10%时防御力-30%（最后冲刺）
- 破绽窗口：狂暴连击第3击后摇15帧

#### 规则4：击败奖励
- **能力解锁**：短距离冲刺（dash）
- **货币**：50 齿轮币
- **技能点**：5 SP（由技能树系统消费，见 skill-tree.md 规则3）
- **叙事**：Boss倒下动画（3秒）→ 场景过渡 → 能力获得过场

### States and Transitions

Boss状态由AI框架管理，Boss配置层提供配置数据。阶段转换时Boss短暂进入INVULNERABLE状态（转换动画期间2-3秒）。

### Interactions with Other Systems

**上游依赖**：
- AI框架 — 提供行为状态机和攻击模式执行
- 生命系统 — 提供`on_boss_phase_change`信号和HP查询

**下游被依赖**：
- 战斗表现系统 — 监听阶段转换触发特殊视觉
- 场景管理系统 — 阶段转换时修改竞技场布局

**接口签名**：
```
get_boss_config(boss_id: String) → BossConfig
on_boss_defeated(boss_id: String) → void
```

## Formulas

本系统不定义新公式。引用：
- 伤害计算F1-F4：伤害流水线
- 生命系统F3：Boss阶段检测

## Edge Cases

- **阶段转换时正在攻击**：当前攻击完成后转换（不中断）
- **HP同时跨越两个阈值**：依次触发两个阶段转换
- **转换动画中玩家攻击**：Boss无敌，伤害为0
- **召唤的小老鼠在Boss死亡后**：小老鼠立即死亡
- **Boss被弹反**：受到5.0×伤害但不进入STUN（Boss免疫眩晕）

## Dependencies

**上游依赖**：
- AI框架 — 提供行为状态机和攻击模式执行
- 生命与死亡检测 — 提供`on_boss_phase_change`信号

**下游被依赖**：
- 战斗表现系统 — 阶段转换视觉
- 场景管理系统 — 竞技场变化

## Tuning Knobs

| 旋钮 | 默认值 | 安全范围 | 过高影响 | 过低影响 |
|------|--------|---------|---------|---------|
| boss_max_hp | 300 | 100-1000 | Boss太肉 | Boss太脆 |
| phase_transition_duration_sec | 2.5 | 1.5-4.0 | 转换太长 | 转换太短 |
| phase2_speed_modifier | 1.2 | 1.1-1.5 | 阶段2太快 | 无感 |
| phase3_speed_modifier | 1.5 | 1.3-2.0 | 阶段3太快 | 无感 |
| phase3_desperation_defense_reduction | 0.3 | 0.1-0.5 | 最后太脆 | 最后太肉 |
| summon_interval_sec | 15 | 10-30 | 召唤太频繁 | 召唤太少 |
| summon_max_count | 2 | 1-4 | 小怪太多 | 小怪太少 |
| defeat_currency_reward | 50 | 20-100 | 奖励太多 | 奖励太少 |

## Visual/Audio Requirements

### Boss视觉身份
- **垃圾桶鼠王**：巨大的机械鼠，身体由废弃金属和垃圾组成，眼睛发出红色光芒
- **阶段转换**：身体部件脱落/重组，眼睛颜色变化（红→橙→白热）
- **阶段3殊死**：身体开始漏电/冒烟，动作更狂暴

### 阶段转换视觉
- 全屏轻微震屏（4帧）
- Boss身上粒子爆发（金属碎片飞散）
- 短暂暗角效果聚焦Boss

### 音效设计
- **阶段1**：沉重金属撞击音
- **阶段2**：新增机械运转音+小老鼠吱吱声
- **阶段3**：过载电子音+金属扭曲音
- **击败**：巨大的金属崩塌音→沉默→胜利音乐渐入

## UI Requirements

### Boss HP条
- 位置：屏幕顶部中央（宽400px × 高15px）
- 阶段标记：66%和33%处显示垂直分割线
- Boss名称：HP条上方显示"垃圾桶鼠王"
- 阶段指示：当前阶段高亮（I/II/III）

### 阶段转换UI
- 全屏闪烁（0.5秒）
- 阶段文字弹出："阶段 II — 焦灼"（1.5秒后淡出）

## Acceptance Criteria

- **GIVEN** 垃圾桶鼠王HP=200（66%），**WHEN** HP降到198，**THEN** 触发阶段2转换
- **GIVEN** 阶段转换中，**WHEN** 玩家攻击Boss，**THEN** 伤害为0（无敌）
- **GIVEN** 阶段2，**WHEN** 15秒计时器到，**THEN** 召唤1只小老鼠（如果当前<2只）
- **GIVEN** 阶段3，**WHEN** Boss HP<10%，**THEN** 防御力-30%
- **GIVEN** Boss HP=0，**WHEN** 死亡触发，**THEN** 播放死亡动画+解锁冲刺能力+给予50齿轮币
- **GIVEN** Boss被弹反，**WHEN** 弹反成功，**THEN** 受到5.0×伤害但不进入STUN

## Open Questions

| # | 问题 | 负责人 | 目标解决时间 |
|---|------|--------|-------------|
| 1 | 后续Boss（垂直切片）的攻击模式设计？ | game-designer | 垂直切片阶段 |
| 2 | Boss是否需要"怜悯机制"（连续死亡多次后降低难度）？ | game-designer | 垂直切片阶段 |
