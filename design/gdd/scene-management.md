# 场景管理系统 (Scene Management System)

> **Status**: Designed (awaiting review)
> **Author**: 用户 + AI
> **Last Updated**: 2026-06-18
> **Implements Pillar**: 机制探索回报
> **Systems Index**: #11 | MVP核心 | Feature

## Overview

**场景管理系统**负责游戏场景的加载、卸载、过渡和内存管理。它管理场景之间的切换（区域切换、Boss战场进入/退出、据点往返），确保场景加载流畅且不超出内存预算。采用异步加载+过渡动画的方式，避免加载卡顿。

## Player Fantasy

**「无缝废土」— 世界连绵不断的沉浸感**

场景管理的终极使命是让玩家**感受不到场景切换**。从一个区域走到另一个区域时，世界是连续的——没有突兀的加载画面打断探索节奏。即使需要加载新场景，过渡也是短暂的、有视觉包装的（如猫武士穿过门洞/隧道），而非黑屏等待。

## Detailed Design

### Core Rules

#### 规则1：场景结构
```
scene_registry = {
    "hub": { path: "res://scenes/hub/hub.tscn", type: "hub", preload: true },
    "area_01_street": { path: "res://scenes/areas/street.tscn", type: "area" },
    "area_02_sewer": { path: "res://scenes/areas/sewer.tscn", type: "area" },
    "boss_01_arena": { path: "res://scenes/bosses/rat_king_arena.tscn", type: "boss_arena" },
    "transition_tunnel": { path: "res://scenes/transitions/tunnel.tscn", type: "transition" }
}
```

#### 规则2：场景加载策略
- **预加载**：hub场景在游戏启动时预加载（常驻内存）
- **异步加载**：区域/Boss场景在进入时异步加载（后台线程）
- **卸载策略**：离开场景后延迟3秒卸载（快速返回时无需重新加载）
- **内存预算**：同时驻留场景不超过2个（当前+预加载下一个）

#### 规则3：场景过渡流程
1. 玩家触发场景切换（进入门洞/区域边界）
2. 播放过渡动画（猫武士穿过隧道/门洞，1-2秒）
3. 过渡动画期间：异步加载目标场景
4. 加载完成：卸载旧场景，实例化新场景
5. 过渡动画结束：恢复玩家控制

#### 规则4：场景状态持久化
- 每个场景维护本地状态（已开启的门、已破坏的障碍物、NPC位置）
- 场景卸载时序列化本地状态到世界状态系统
- 场景加载时从世界状态系统恢复本地状态
- Boss战场特殊处理：进入时保存当前HP，退出时恢复

#### 规则5：快速传送
- 已发现的存档点之间可快速传送
- 快速传送使用特殊过渡动画（猫武士跳入传送管道，2秒）
- 传送目标场景预先加载（利用传送动画时间）

### States and Transitions

| 状态 | 行为 | 转换条件 |
|------|------|---------|
| IDLE | 当前场景运行中 | 触发场景切换→LOADING |
| LOADING | 过渡动画+异步加载 | 加载完成→SWAPPING |
| SWAPPING | 卸载旧场景+实例化新场景 | 完成→IDLE |
| ERROR | 加载失败 | 重试→LOADING |

### Interactions with Other Systems

**上游依赖**：无

**下游被依赖**：
- 存档系统 — 加载存档时恢复场景
- Boss配置层 — 阶段转换时修改竞技场
- 探索与能力门控 — 区域解锁触发场景可用
- 世界状态系统 — 场景状态持久化

**接口签名**：
```
change_scene(scene_id: String, spawn_point: String = "default") → void
preload_scene(scene_id: String) → void
get_current_scene() → String
is_scene_loaded(scene_id: String) → bool
get_scene_state(scene_id: String) → Dictionary
set_scene_state(scene_id: String, state: Dictionary) → void
```

## Formulas

本系统不定义游戏平衡公式。性能预算：
- 场景加载时间目标：< 2秒（异步加载+过渡动画掩盖）
- 内存峰值：< 1GB（移动端）/ 2GB（PC）

## Edge Cases

- **加载失败**：重试1次，仍失败则显示错误提示+返回hub
- **加载中玩家死亡**：取消加载，在存档点重生
- **快速连续切换场景**：队列机制，只执行最后一次
- **Boss战中场景卸载**：不可能（Boss战场锁定场景切换）
- **传送目标场景未解锁**：传送按钮灰色，提示"区域未解锁"
- **内存不足**：强制卸载所有非当前场景，提示"内存不足"

## Dependencies

**上游依赖**：无
**下游被依赖**：存档系统、Boss配置层、探索与能力门控、世界状态系统

## Tuning Knobs

| 旋钮 | 默认值 | 安全范围 | 过高影响 | 过低影响 |
|------|--------|---------|---------|---------|
| scene_unload_delay_sec | 3.0 | 1.0-10.0 | 内存占用太久 | 快速返回需重新加载 |
| transition_duration_sec | 1.5 | 0.5-3.0 | 过渡太长 | 加载未完成 |
| max_concurrent_scenes | 2 | 1-3 | 内存超限 | 无法预加载 |
| async_load_timeout_sec | 10.0 | 5.0-30.0 | 等待太久 | 过早超时 |

## Visual/Audio Requirements

### 过渡动画
- **区域切换**：猫武士穿过隧道/门洞（1.5秒），画面渐暗→渐亮
- **快速传送**：猫武士跳入发光管道（2秒），粒子旋涡特效
- **Boss战场进入**：大门缓缓打开，镜头推进（2秒）

### 音效设计
- **区域切换**：脚步声+环境音渐变（旧区域淡出，新区域淡入）
- **快速传送**：传送管道共鸣音+风声
- **Boss战场**：沉重门开启音+Boss主题音乐渐入

## UI Requirements

### 加载指示器
- 位置：屏幕中央偏下
- 样式：猫爪印旋转动画（非进度条，掩盖加载时间）
- 文字：当前区域名称

### 快速传送菜单
- 位置：猫族据点传送点NPC交互
- 显示：已解锁的存档点列表（名称+缩略图）
- 未解锁：灰色+锁定图标

## Acceptance Criteria

- **GIVEN** 玩家进入区域边界，**WHEN** 触发场景切换，**THEN** 过渡动画播放+异步加载目标场景
- **GIVEN** 场景加载中，**WHEN** 加载时间超过10秒，**THEN** 超时处理+错误提示
- **GIVEN** 场景卸载后3秒内，**WHEN** 玩家返回，**THEN** 无需重新加载
- **GIVEN** 快速传送，**WHEN** 目标场景已解锁，**THEN** 传送动画+预加载+场景切换
- **GIVEN** Boss战中，**WHEN** 尝试切换场景，**THEN** 操作被阻止
- **GIVEN** 存档加载，**WHEN** 调用场景恢复，**THEN** 场景状态从世界状态系统恢复

## Open Questions

| # | 问题 | 负责人 | 目标解决时间 |
|---|------|--------|-------------|
| 1 | 是否支持场景内子场景流式加载（大型区域分块加载）？ | technical-director | 垂直切片阶段 |
| 2 | 场景过渡是否需要支持中断（加载中返回）？ | game-designer | 垂直切片阶段 |
