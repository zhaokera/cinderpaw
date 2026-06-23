# 探索与能力门控系统 (Exploration & Ability Gating System)

> **Status**: Designed (awaiting review)
> **Author**: 用户 + AI
> **Last Updated**: 2026-06-18
> **Implements Pillar**: 机制探索回报
> **Systems Index**: #16 | MVP核心 | Feature

## Overview

**探索与能力门控系统**管理银河城式的探索进度——哪些区域已解锁、哪些路径需要特定能力才能通过、哪些隐藏房间已被发现。它是"探索回报"支柱的核心执行者：玩家获得新能力（如冲刺、二段跳、墙壁攀爬）后，之前无法到达的区域变得可达，形成"能力→探索→奖励→更强能力"的正循环。

## Player Fantasy

**「废土探险家」— 每一扇门后都有新世界**

探索的终极使命是让玩家永远觉得"再往前走走看"。看到一扇需要冲刺才能通过的电栅栏时，玩家记住它的位置；获得冲刺后再回来，穿过栅栏发现隐藏房间——那一刻的感受是"我记得这里，我终于进来了"。能力门控让探索不是线性的 walkthrough，而是不断回溯、不断发现新事物的循环。

## Detailed Design

### Core Rules

#### 规则1：能力门（Ability Gate）

| 门类型 | 所需能力 | 视觉表现 | 区域示例 |
|--------|---------|---------|---------|
| 电栅栏 | 冲刺(dash) | 闪烁电弧+信号红 | 商业街→下水道 |
| 高台 | 二段跳(double_jump) | 过高平台+猫爪痕 | 下水道→工厂 |
| 窄缝 | 下劈(aerial_attack) | 可破坏地板+裂缝 | 工厂→地下通道 |
| 磁力墙 | 墙壁攀爬(wall_climb) | 磁性表面+蓝色光纹 | 霓虹屋顶 |
| 激光网 | 弹反(parry) | 激光束+可弹反节点 | 中央高塔 |

**门交互规则**：
- 靠近时显示"需要[能力]"（未拥有）或"按[键]通过"（已拥有）
- 通过时播放对应动画
- 通过后永久开放

#### 规则2：区域解锁追踪

| 区域 | 解锁条件 |
|------|---------|
| 猫族据点 | 游戏开始 |
| 废弃商业街 | 从hub出发 |
| 下水道 | 需要冲刺 |
| 旧工厂 | 需要二段跳 |
| 霓虹屋顶 | 需要墙壁攀爬 |
| 中央高塔 | 需要弹反+所有前置区域 |

#### 规则3：隐藏房间检测
- **可破坏墙壁**：攻击3次后破坏（微弱裂缝提示）
- **隐藏通道**：特定位置按下+跳跃（无明显提示）
- **能力门后隐藏房**：门后额外房间

发现触发`secret_room_discovered(room_id)`事件，小地图更新+通知弹出。

#### 规则4：捷径解锁
- **单向平台**：高处跳下到低处（不可返回）
- **可破坏地板**：下劈破坏后永久通道
- **传送管道**：快速传送点

解锁触发`shortcut_unlocked(shortcut_id)`事件，永久开放。

### States and Transitions

**能力门状态**：LOCKED → UNLOCKABLE（拥有能力）→ UNLOCKED（通过后）
**区域状态**：HIDDEN → DISCOVERED（发现入口）→ UNLOCKED（通过门）→ EXPLORED

### Interactions with Other Systems

**上游依赖**：
- 玩家能力系统（provisional）— `has_ability(ability_id)`
- 世界状态系统（provisional）— 区域状态
- 场景管理系统 — 场景切换

**下游被依赖**：
- HUD/UI系统 — 地图/提示
- 存档系统 — 状态持久化

**接口签名**：
```
check_ability_gate(gate_id) → GateStatus
unlock_area(area_id) → void
discover_secret_room(room_id) → void
unlock_shortcut(shortcut_id) → void
get_area_completion(area_id) → float  # 0.0-1.0
get_total_completion() → float
```

## Formulas

**区域完成度**：
`area_completion = (discovered_secrets + unlocked_shortcuts + defeated_enemies) / (total_secrets + total_shortcuts + total_enemies)`

| Variable | Type | Range |
|----------|------|-------|
| discovered_secrets | int | 0-total |
| unlocked_shortcuts | int | 0-total |
| defeated_enemies | int | 0-total |
| **输出** | float | 0.0-1.0 |

**全局完成度**：`global_completion = Σ(area_completion × area_weight) / Σ(area_weight)`
- hub权重=0.5, 普通区域=1.0, Boss区域=1.5

## Edge Cases

- **拥有能力但门仍LOCKED**：不可能（能力获取时自动检查）
- **区域解锁时场景加载中**：事件队列，加载完成后处理
- **隐藏房间重复进入**：不重复触发发现事件
- **捷径解锁后场景切换**：永久保持
- **Boss战中区域解锁**：Boss战结束后处理
- **多门同时满足**：各自独立解锁

## Dependencies

**上游依赖**：玩家能力系统(provisional)、世界状态系统(provisional)、场景管理、NPC对话系统(provisional，任务触发区域解锁)
**下游被依赖**：HUD/UI系统、存档系统

## Tuning Knobs

| 旋钮 | 默认值 | 安全范围 | 过高影响 | 过低影响 |
|------|--------|---------|---------|---------|
| gate_prompt_distance | 64px | 32-128px | 提示太早 | 提示太晚 |
| secret_wall_hit_count | 3 | 1-5 | 太容易 | 太难 |
| area_unlock_delay_sec | 0.5 | 0.2-1.0 | 太快 | 太慢 |
| completion_weight_hub | 0.5 | 0.3-0.7 | — | — |
| completion_weight_normal | 1.0 | 0.8-1.2 | — | — |
| completion_weight_boss | 1.5 | 1.2-2.0 | — | — |

## Visual/Audio Requirements

### 能力门视觉
- **电栅栏**：闪烁电弧（信号红），通过时消散+冲刺残影
- **高台**：过高平台+猫爪痕标记
- **可破坏墙壁**：微弱裂缝，攻击时裂缝扩大+碎片粒子
- **磁力墙**：蓝色光纹，攀爬时接触点发光

### 区域解锁视觉
- 门消散粒子效果（0.5秒）
- 小地图灰色→彩色渐变（1秒）
- 通知弹出

### 音效
- 门解锁：对应能力音效
- 区域解锁：宏大发现音+区域主题前奏
- 隐藏房间：神秘发现音+猫叫
- 捷径：平台/破碎/管道激活音

## UI Requirements

> 📌 **UX Flag** — 在Phase 4运行 `/ux-design` 创建 `design/ux/ability-gate-prompt.md`。

### 门提示UI
- 未拥有能力：锁图标+"需要[能力名]"
- 已拥有能力：能力图标+"按[键]通过"
- 已通过：无提示

### 小地图更新
- 新区域：灰色→彩色
- 隐藏房间：房间图标
- 捷径：连接线

## Acceptance Criteria

- **GIVEN** 无冲刺能力，**WHEN** 靠近电栅栏，**THEN** 显示"需要冲刺"
- **GIVEN** 有冲刺能力，**WHEN** 靠近电栅栏，**THEN** 显示"按[键]冲刺"
- **GIVEN** 冲刺通过电栅栏，**WHEN** 通过完成，**THEN** 门永久解锁+区域解锁事件
- **GIVEN** 进入新区域，**WHEN** 解锁事件触发，**THEN** 小地图更新+通知
- **GIVEN** 攻击可破坏墙壁3次，**WHEN** 第3次命中，**THEN** 破坏+隐藏房间发现
- **GIVEN** 通过捷径，**WHEN** 解锁事件触发，**THEN** 永久开放+小地图更新
- **GIVEN** 查询区域完成度，**WHEN** 调用，**THEN** 返回0.0-1.0

## Open Questions

| # | 问题 | 负责人 | 目标解决时间 |
|---|------|--------|-------------|
| 1 | 玩家能力系统完整接口？ | game-designer | 玩家能力系统GDD |
| 2 | 世界状态系统持久化方案？ | game-designer | 世界状态系统GDD |
| 3 | 是否需要"提示系统"（长时间未发现时给暗示）？ | game-designer | 垂直切片阶段 |
