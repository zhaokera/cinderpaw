# 玩家能力系统 (Player Abilities System)

> **Status**: Designed (awaiting review)
> **Author**: 用户 + AI
> **Last Updated**: 2026-06-18
> **Implements Pillar**: 技巧优先成长, 机制探索回报
> **Systems Index**: #18 | **MVP核心** | Core

## Overview

**玩家能力系统**管理猫武士的可解锁能力——冲刺、二段跳、下劈攻击、墙壁攀爬、弹反。它负责能力的注册、解锁、查询和激活。能力是银河城式探索的核心驱动力：击败Boss获得新能力→新能力打开之前无法到达的区域→新区域有新Boss→新Boss给新能力。能力也是战斗深度的基础：弹反让你反弹伤害，冲刺让你穿越危险，下劈让你从空中打击。

## Player Fantasy

**「九命猫技」— 每次解锁都是新世界的钥匙**

能力的终极使命是让玩家永远觉得"我还能变得更强"。游戏开始时你只有基本的爪击和跳跃；击败第一个Boss后获得冲刺——突然之间，之前无法通过的电栅栏变得可达；获得二段跳后，之前够不到的高台现在可以轻松到达。每一次能力解锁都重新定义了"你能做什么"，让整个废土世界变得更加开放。

## Detailed Design

### Core Rules

#### 规则1：能力注册表

| 能力ID | 名称 | 解锁条件 | 类型 |
|--------|------|---------|------|
| basic_attack | 爪击 | 游戏开始 | 主动 |
| jump | 跳跃 | 游戏开始 | 主动 |
| dodge | 闪避 | 游戏开始 | 主动 |
| dash | 冲刺 | 击败垃圾桶鼠王 | 主动 |
| double_jump | 二段跳 | 击败第2个Boss | 主动 |
| aerial_attack | 下劈 | 击败第3个Boss | 主动 |
| wall_climb | 墙壁攀爬 | 击败第4个Boss | 主动 |
| parry | 弹反 | 教学关卡 | 主动 |

#### 规则2：能力解锁流程
1. 触发解锁条件
2. `unlock_ability(ability_id)`
3. 播放解锁动画（1.5秒）
4. `ability_unlocked(ability_id)`事件
5. 探索门控系统更新门状态
6. HUD通知
7. 存档记录

#### 规则3：能力查询接口
```
has_ability(ability_id) → bool
get_unlocked_abilities() → Array[String]
unlock_ability(ability_id) → bool
is_ability_on_cooldown(ability_id) → bool
get_ability_cooldown_remaining(ability_id) → float
```

#### 规则4：能力冷却管理

| 能力 | 冷却 | 类型 |
|------|:---:|------|
| basic_attack | 0秒 | 无 |
| jump | 0秒 | 无 |
| dodge | 0.5秒 | 短冷却 |
| dash | 1.0秒 | 中冷却 |
| double_jump | 0秒（落地重置） | 使用限制 |
| aerial_attack | 0秒 | 无 |
| wall_climb | 0秒 | 无 |
| parry | 0.3秒 | 短冷却 |

#### 规则5：能力激活流程
1. 玩家输入 → 2. has_ability检查 → 3. 冷却检查 → 4. 前置条件检查 → 5. 激活+事件 → 6. 开始冷却 → 7. 动画+特效 → 8. 效果执行

### States and Transitions

**能力实例状态**：LOCKED → AVAILABLE（解锁）→ ACTIVE（激活）→ ON_COOLDOWN（冷却）→ AVAILABLE

### Interactions with Other Systems

**上游依赖**：Boss配置层（解锁触发）、生命检测（死亡重置）
**下游被依赖**：探索与能力门控（has_ability查询）、猫科战斗（动作触发）、战斗表现（特效）、HUD/UI（图标显示）

**接口签名**：
```
has_ability(ability_id) → bool
get_unlocked_abilities() → Array[String]
is_ability_on_cooldown(ability_id) → bool
unlock_ability(ability_id) → bool
reset_air_abilities() → void
signal ability_unlocked(ability_id)
signal ability_activated(ability_id)
```

## Formulas

冷却管理：`cooldown_remaining = max(0, cooldown_duration - elapsed_time)`

| Variable | Type | Range |
|----------|------|-------|
| cooldown_duration | float | 0-2.0秒 |
| elapsed_time | float | 0-∞ |
| **输出** | float | 0-cooldown_duration |

## Edge Cases

- **已拥有能力再次解锁**：忽略
- **冷却中输入**：忽略
- **double_jump地面使用**：忽略
- **空中死亡**：重置空中能力使用次数
- **场景切换时冷却中**：冷却继续
- **Boss战中解锁**：Boss战后播放动画
- **同时多个解锁**：按ID字母顺序

## Dependencies

**上游依赖**：Boss配置层、生命检测
**下游被依赖**：探索与能力门控、猫科战斗、战斗表现、HUD/UI

## Tuning Knobs

| 旋钮 | 默认值 | 安全范围 | 过高影响 | 过低影响 |
|------|--------|---------|---------|---------|
| dodge_cooldown_sec | 0.5 | 0.2-1.0 | 太慢 | 太强 | *(权威定义在 feline-combat.md，此处为引用)* |
| dash_cooldown_sec | 1.0 | 0.5-2.0 | 太慢 | 太强 |
| dash_distance_px | 96 | 48-192 | 太短 | 太远 |
| parry_cooldown_sec | 0.3 | 0.1-0.5 | 太慢 | 太强 |
| double_jump_height_ratio | 0.8 | 0.5-1.0 | 太低 | 太高 |

## Visual/Audio Requirements

### 能力解锁视觉
- 学习动作动画（1.5秒）
- 能力图标从Boss飘向玩家
- 金色光芒爆发+粒子
- HUD通知

### 能力激活视觉
| 能力 | 视觉 | 音效 |
|------|------|------|
| dash | 残影+速度线 | 风声 |
| double_jump | 脚下气旋 | 弹跳音 |
| aerial_attack | 下劈轨迹+冲击 | 重击音 |
| wall_climb | 接触点发光 | 摩擦音 |
| parry | 架势+金色闪光 | 金属准备音 |

## UI Requirements

> 📌 **UX Flag — 玩家能力系统**: 运行 `/ux-design` 创建 `design/ux/abilities-hud.md`。

### 能力栏HUD
- 位置：屏幕底部中央
- 已解锁：24×24px图标
- 冷却：灰色遮罩+倒计时
- 未解锁：灰色锁图标
- 最大8个图标

## Acceptance Criteria

- **GIVEN** 游戏开始，**WHEN** 初始化，**THEN** 拥有basic_attack, jump, dodge, parry
- **GIVEN** 击败鼠王，**WHEN** Boss死亡，**THEN** 解锁dash+解锁动画
- **GIVEN** 有dash，**WHEN** 按冲刺键，**THEN** 冲刺+1秒冷却
- **GIVEN** dash冷却中，**WHEN** 再按，**THEN** 忽略
- **GIVEN** 有double_jump，**WHEN** 空中按跳跃，**THEN** 二段跳
- **GIVEN** double_jump已用，**WHEN** 空中再按，**THEN** 忽略
- **GIVEN** 落地，**WHEN** 触地，**THEN** 重置double_jump
- **GIVEN** 门控查询has_ability("dash")，**WHEN** 已解锁，**THEN** true

## Open Questions

| # | 问题 | 负责人 | 目标解决时间 | 状态 |
|---|------|--------|-------------|------|
| 1 | 是否需要能力升级系统？ | game-designer | 技能树系统GDD | **已解决** — 能力升级通过技能树通用中心区实现（冲刺距离+25%、弹反窗口+3帧等），与武器分支共享技能点（见 skill-tree.md 规则6） |
| 2 | 是否需要能力组合？ | game-designer | 垂直切片阶段 | |
| 3 | 墙壁攀爬是否需要体力条？ | game-designer | 垂直切片阶段 | |
