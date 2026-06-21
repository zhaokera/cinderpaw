# 状态效果系统 (Status Effects System)

> **Status**: Designed (awaiting review)
> **Author**: 用户 + AI
> **Last Updated**: 2026-06-18
> **Implements Pillar**: 猫科战斗美学, 技巧优先成长
> **Systems Index**: #17 | MVP扩展 | Core

## Overview

**状态效果系统**管理实体（玩家/敌人）身上的持续效果——增益（buff）和减益（debuff）。它负责效果的施加、持续、叠加、过期和移除。状态效果为战斗增加策略深度：电磁铃铛的减速让敌人更容易命中，毒素持续伤害让战斗更有压力，眩晕让危险敌人暂时失去威胁。

## Player Fantasy

**「状态大师」— 掌控战场的节奏**

状态效果的终极使命是让战斗**不只是砍砍砍**。给敌人上减速后从容闪避它的攻击，用毒素慢慢消耗高血量敌人，在Boss狂暴前用眩晕打断它的致命招式——这些都是状态效果带来的策略深度。好的状态系统让玩家觉得"我在用脑子打这场仗"。

## Detailed Design

### Core Rules

#### 规则1：效果类型定义

| 效果ID | 名称 | 类型 | 持续 | 效果 | 来源 |
|--------|------|------|:---:|------|------|
| poison | 毒素 | debuff | 5秒 | 每秒3点伤害 | 敌人/环境 |
| slow | 减速 | debuff | 2秒 | 移速-30% | 电磁铃铛 |
| stun | 眩晕 | debuff | 1秒 | 无法行动 | 弹反/特殊攻击 |
| burn | 燃烧 | debuff | 3秒 | 每秒5点+移速-10% | 火焰元素 |
| speed_boost | 疾速 | buff | 3秒 | 移速+30% | 能力/道具 |
| damage_boost | 强化 | buff | 5秒 | 伤害+25% | 能力/道具 |
| invincible | 无敌 | buff | 0.5秒 | 免疫伤害 | 闪避/能力 |

#### 规则2：效果施加规则
1. 攻击命中 → 检查附带效果
2. 检查目标免疫（Boss免疫眩晕）
3. 检查同类效果（刷新持续时间，不叠加）
4. 施加 → `status_applied(target_id, effect_id)`

**叠加规则**：同效果刷新持续时间；不同效果可共存；每实体最多5个同时效果。

#### 规则3：效果持续与过期
每帧处理：减少剩余时间，执行tick（DoT每1秒），过期时移除并触发`status_expired`。

#### 规则4：效果免疫与清除
- Boss免疫眩晕
- 无敌期间免疫debuff
- 闪避i-frame期间免疫所有效果
- 死亡/场景切换清除所有效果

#### 规则5：效果优先级
施加优先级：stun > slow > poison > burn > speed_boost > damage_boost > invincible

### States and Transitions

**效果实例**：ACTIVE → EXPIRING（<0.5秒）→ EXPIRED → 移除
**实体效果管理**：NO_EFFECTS → HAS_EFFECTS（1-5个）→ EFFECTS_FULL（5个满）

### Interactions with Other Systems

**上游依赖**：
- 伤害计算 — 攻击附带效果数据
- 生命检测 — DoT伤害调用`apply_damage()`
- 武器流派 — 电磁铃铛附带减速

**下游被依赖**：
- 猫科战斗 — 查询效果状态
- AI框架 — 眩晕时AI进入STUN
- 战斗表现 — 效果视觉反馈
- HUD/UI — 效果图标显示

**接口签名**：
```
apply_status(target_id, effect_id, source_id) → bool
remove_status(target_id, effect_id) → void
has_status(target_id, effect_id) → bool
get_active_effects(target_id) → Array[StatusEffect]
get_movement_modifier(target_id) → float
get_damage_modifier(target_id) → float
clear_all_effects(target_id) → void
```

## Formulas

**DoT伤害**：
`dot_damage_per_tick = base_dot_damage × (1 + damage_boost_modifier)`

| Variable | Type | Range |
|----------|------|-------|
| base_dot_damage | int | 1-10 |
| damage_boost_modifier | float | 0.0-1.0 |
| **输出** | int | 1-20 |

**移速修改**：
`final_move_speed = base_move_speed × Π(movement_modifiers)`

Example：基础200，减速+疾速 → 200 × 0.7 × 1.3 = 182

## Edge Cases

- **同效果刷新时剩余>新持续**：保留较长的
- **目标已死亡时施加**：不施加，返回false
- **目标无敌时施加debuff**：不施加
- **5个效果已满**：移除最早的，施加新的
- **DoT导致死亡**：正常触发死亡
- **眩晕期间再受眩晕**：刷新持续时间
- **场景切换**：清除所有效果

## Dependencies

**上游依赖**：伤害计算、生命检测、武器流派
**下游被依赖**：猫科战斗、AI框架、战斗表现、HUD/UI

## Tuning Knobs

| 旋钮 | 默认值 | 安全范围 | 过高影响 | 过低影响 |
|------|--------|---------|---------|---------|
| poison_duration_sec | 5.0 | 2.0-10.0 | 太强 | 无感 |
| poison_dps | 3 | 1-10 | 太强 | 无感 |
| slow_duration_sec | 2.0 | 1.0-5.0 | 太强 | 无感 |
| slow_percentage | 0.3 | 0.1-0.5 | 太强 | 无感 |
| stun_duration_sec | 1.0 | 0.5-2.0 | 太强 | 无感 |
| burn_duration_sec | 3.0 | 1.0-5.0 | 太强 | 无感 |
| burn_dps | 5 | 2-10 | 太强 | 无感 |
| max_effects_per_entity | 5 | 3-8 | 混乱 | 限制 |
| speed_boost_percentage | 0.3 | 0.1-0.5 | 太快 | 无感 |
| damage_boost_percentage | 0.25 | 0.1-0.5 | 太强 | 无感 |

## Visual/Audio Requirements

### 效果视觉
| 效果 | 视觉 | 颜色 | 粒子 |
|------|------|------|------|
| 毒素 | 绿色脉动 | 毒绿 | 气泡 |
| 减速 | 蓝色光晕 | 电弧蓝 | 无 |
| 眩晕 | 头部星星旋转 | 黄色 | 星星 |
| 燃烧 | 火焰覆盖 | 橙红 | 火焰 |
| 疾速 | 白色残影 | 白色 | 速度线 |
| 强化 | 金色光晕 | 猫眼金 | 火花 |
| 无敌 | 闪烁透明 | 白色 | 无 |

### 音效
- 施加debuff：低沉负面音
- 施加buff：明亮正面音
- DoT tick：轻微伤害音
- 效果过期：消散音

## UI Requirements

> 📌 **UX Flag — 状态效果系统**: 运行 `/ux-design` 创建 `design/ux/status-effects-hud.md`。

### 效果图标HUD
- 玩家效果：HP条右侧，24×24px图标+倒计时圆弧
- 敌人效果：敌人头顶
- 最大显示5个图标

## Acceptance Criteria

- **GIVEN** 电磁铃铛命中，**WHEN** 命中触发，**THEN** 施加减速（2秒，-30%）
- **GIVEN** 已有毒素3秒，**WHEN** 再次施加，**THEN** 刷新为5秒
- **GIVEN** Boss被弹反，**WHEN** 尝试眩晕，**THEN** 免疫
- **GIVEN** 5个效果已满，**WHEN** 施加第6个，**THEN** 移除最早的
- **GIVEN** 毒素3DPS，**WHEN** 1秒tick，**THEN** 造成3点伤害
- **GIVEN** 减速+疾速，**WHEN** 查询移速，**THEN** base×0.7×1.3
- **GIVEN** 敌人死亡，**WHEN** on_death，**THEN** 清除所有效果

## Open Questions

| # | 问题 | 负责人 | 目标解决时间 |
|---|------|--------|-------------|
| 1 | 是否需要"净化"道具？ | game-designer | 护符/装备系统GDD |
| 2 | 玩家是否也受毒素/燃烧？ | game-designer | 垂直切片阶段 |
| 3 | 是否需要元素反应？ | game-designer | 垂直切片阶段 |
