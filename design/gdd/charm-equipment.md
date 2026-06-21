# 护符/装备系统 (Charm/Equipment System)

> **Status**: Designed (awaiting review)
> **Author**: 用户 + AI
> **Last Updated**: 2026-06-18
> **Implements Pillar**: 技巧优先成长, 机制探索回报
> **Systems Index**: #19 | MVP扩展 | Feature

## Overview

**护符/装备系统**管理玩家的被动装备——护符和遗物。护符提供永久被动增益（攻击力+10%、暴击率+5%、移速+15%等），让玩家根据自己的玩法风格自定义角色构建（Build）。护符是探索的核心奖励：隐藏房间藏着稀有护符，Boss击败掉落独特遗物，商人出售基础护符。好的护符系统让玩家觉得"我的Build是我自己的"。

## Player Fantasy

**「遗物收藏家」— 每个护符都是一段故事**

护符的终极使命是让探索**有具体的回报**。发现一个隐藏房间，里面藏着一个古老护符——装备后你的攻击力提升了10%。这个护符不只是一个数值加成，它是你探索的纪念品，是你"到过那里"的证明。当你装备满3个护符时，你的Build反映了你的探索历程和玩法偏好。

## Detailed Design

### Core Rules

#### 规则1：护符类型定义

| 护符ID | 名称 | 效果 | 稀有度 | 来源 |
|--------|------|------|:---:|------|
| charm_power | 力量护符 | 攻击力+10% | 普通 | 商人/探索 |
| charm_crit | 暴击护符 | 暴击窗口+1帧（PERFECT窗口从3帧扩大为4帧） | 普通 | 商人/探索 |
| charm_speed | 疾速护符 | 移速+15% | 普通 | 商人/探索 |
| charm_life | 生命护符 | 最大HP+20 | 稀有 | 隐藏房间 |
| charm_combo | 连招护符 | 连招倍率+10% | 稀有 | 隐藏房间 |
| charm_dash | 冲刺护符 | 冲刺冷却-30% | 稀有 | Boss掉落 |
| charm_parry | 弹反护符 | 弹反窗口+3帧 | 史诗 | Boss掉落 |
| charm_regen | 再生遗物 | 每10秒恢复5HP | 史诗 | 隐藏房间 |

#### 规则2：装备槽位管理
- 最大装备数：3个护符同时装备
- 同类效果不叠加（2个力量护符只生效1个）
- 仅在安全区域（据点/存档点）可操作
- 装备后立即生效

#### 规则3：护符获取途径
- 商人购买：普通护符
- 隐藏房间：稀有/史诗护符
- Boss掉落：稀有/史诗护符
- 探索发现：普通/稀有护符

#### 规则4：护符效果应用
```
final_attack_power = base × (1 + charm_power_bonus + status_damage_boost)
final_move_speed = base × (1 + charm_speed_bonus + status_speed_boost)
```

> **暴击窗口护符(charm_crit)特殊处理**：charm_crit 的"暴击窗口+1帧"效果不通过 F8 统一上限公式，而是直接修改 damage-calculation DC-F5 的 PERFECT 子窗口宽度（从3帧扩大为4帧）。此效果不与技能树的暴击窗口加成叠加（两者取最大值），由消费方在 DC-F5 判定时合并处理。

#### 规则5：护符持久化
- 已拥有护符列表+装备槽位状态持久化到存档

### States and Transitions

**护符实例**：OWNED（未装备）→ EQUIPPED（装备生效）→ OWNED（卸下）
**重复获取**：OWNED → DUPLICATE（不添加）

### Interactions with Other Systems

**上游依赖**：状态效果（apply_status）、数值平衡（变量修改）
**下游被依赖**：伤害计算（查询加成）、生命系统（查询HP加成）、玩家能力（查询冷却加成）、HUD/UI（图标显示）

**接口签名**：
```
equip_charm(charm_id, slot: int) → bool
unequip_charm(slot: int) → void
get_equipped_charms() → Array[String]
get_owned_charms() → Array[String]
get_charm_bonus(stat: String) → float
has_charm(charm_id) → bool
add_charm(charm_id) → bool
```

## Formulas

**护符加成**：`charm_bonus = Σ(equipped_charms[stat].bonus)`（同类不叠加，最大0.5）

> **跨系统约束**：技能树系统定义了统一上限 `unified_bonus_cap = 0.75`（skill-tree F8）。技能加成与护符加成采用**乘法递减叠加**：`combined_bonus = min(0.75, 1 - (1 - skill_bonus) × (1 - charm_bonus))`。charm_bonus须先clamp到[0, 0.50]再进入公式。这确保两者永远互补，不会互相归零。由技能树系统负责执行统一cap。

Example：力量+疾速+生命 → attack+10%, speed+15%, HP+20

## Edge Cases

- **槽位已满装备新护符**：提示选择替换
- **重复获取**：提示"已拥有"
- **同类护符多个**：只生效1个
- **Boss战尝试装备**：不允许
- **数值溢出**：cap到系统最大值
- **存档护符ID不存在**：忽略+警告

## Dependencies

**上游依赖**：状态效果、数值平衡
**下游被依赖**：伤害计算、生命系统、玩家能力、HUD/UI

## Tuning Knobs

| 旋钮 | 默认值 | 安全范围 | 过高影响 | 过低影响 |
|------|--------|---------|---------|---------|
| max_equipped_charms | 3 | 1-5 | Build太强 | Build太弱 |
| charm_power_bonus | 0.10 | 0.05-0.20 | 太强 | 无感 |
| charm_crit_bonus | 0.05 | 0.02-0.10 | 太强 | 无感 |
| charm_speed_bonus | 0.15 | 0.05-0.30 | 太快 | 无感 |
| charm_life_bonus | 20 | 10-50 | 太肉 | 无感 |
| charm_combo_bonus | 0.10 | 0.05-0.20 | 太强 | 无感 |
| charm_dash_cooldown_reduction | 0.30 | 0.10-0.50 | 太强 | 无感 |
| charm_parry_window_bonus | 3帧 | 1-5帧 | 太强 | 无感 |
| charm_regen_amount | 5 | 2-10 | 太强 | 无感 |
| charm_regen_interval | 10秒 | 5-20秒 | 太强 | 无感 |

## Visual/Audio Requirements

### 护符视觉
- 图标：24×24px像素艺术
- 稀有度：普通=白色边框，稀有=蓝色，史诗=金色
- 装备光效：角色身上对应光效（力量=红光，疾速=白残影）

### 获取/装备视觉
- 获取：图标飘向玩家（1秒）+通知
- 装备：图标飞入槽位（0.5秒）

### 音效
- 获取：清脆发现音+稀有度音调
- 装备/卸下：轻微装备音

## UI Requirements

> 📌 **UX Flag — 护符/装备系统**: 运行 `/ux-design` 创建 `design/ux/charm-menu.md`。

### 护符菜单
- 打开条件：安全区域
- 布局：左侧已拥有列表，右侧3个槽位
- 操作：拖拽或点击装备/卸下

### HUD显示
- 位置：HP条下方
- 显示：3个装备护符小图标（16×16px）

## Acceptance Criteria

- **GIVEN** 拥有力量护符，**WHEN** 装备槽位1，**THEN** 攻击力+10%生效
- **GIVEN** 3槽位满，**WHEN** 装备新护符，**THEN** 提示替换
- **GIVEN** 已拥有力量护符，**WHEN** 再次获取，**THEN** 提示"已拥有"
- **GIVEN** 装备2个力量护符，**WHEN** 查询加成，**THEN** 10%（不叠加）
- **GIVEN** 装备力量+疾速+生命，**WHEN** 查询，**THEN** 攻击+10%/移速+15%/HP+20
- **GIVEN** Boss战中，**WHEN** 尝试打开菜单，**THEN** 不允许
- **GIVEN** 存档加载，**WHEN** 护符恢复，**THEN** 效果立即应用

## Open Questions

| # | 问题 | 负责人 | 目标解决时间 |
|---|------|--------|-------------|
| 1 | 是否需要护符合成系统？ | game-designer | 垂直切片阶段 |
| 2 | 是否需要护符套装（预设Build）？ | ux-designer | UX设计阶段 |
| 3 | 护符掉落是否需要随机性？ | game-designer | 垂直切片阶段 |
