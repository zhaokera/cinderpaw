# 地图系统 (Map System)

> **Status**: Designed (awaiting review)
> **Author**: 用户 + AI
> **Last Updated**: 2026-06-18
> **Implements Pillar**: 机制探索回报
> **Systems Index**: #21 | MVP扩展 | Feature

## Overview

**地图系统**管理游戏中的地图显示——小地图（HUD常驻）和全地图（按键打开）。它负责迷雾探索（未探索区域不可见）、地图标记（存档点、Boss、隐藏房间、捷径）、以及区域解锁的视觉反馈。地图是探索进度的可视化——每解锁一个新区域，地图就多一块拼图；每发现一个隐藏房间，地图就多一个标记。好的地图让玩家永远知道"我去过哪里"和"还有哪里没去"。

## Player Fantasy

**「废土制图师」— 每一步都在绘制世界**

地图的终极使命是让探索**有可见的回报**。进入一个新区域时，地图从灰色迷雾变为彩色——你"绘制"了这块区域。发现一个隐藏房间时，地图上多出一个标记——你的探索被记录了。打开全地图查看整体进度时，你看到的不只是地图，而是你的探索历程。好的地图让你觉得"我在一步步揭开这个世界的秘密"。

## Detailed Design

### Core Rules

#### 规则1：地图类型定义

| 地图类型 | 显示方式 | 尺寸 | 触发方式 |
|----------|---------|------|---------|
| 小地图 | HUD常驻 | 120×120px | 自动显示 |
| 全地图 | 全屏覆盖 | 全屏 | 按M键 |

#### 规则2：迷雾探索机制
- 未探索区域：灰色迷雾覆盖
- 已探索区域：正常显示（彩色）
- 当前区域：高亮显示（边框发光）
- 玩家位置：猫爪图标（实时移动）

#### 规则3：地图标记类型

| 标记类型 | 图标 | 颜色 | 触发条件 |
|----------|------|------|---------|
| 玩家位置 | 猫爪图标 | 猫眼金 | 实时显示 |
| 存档点 | 猫窝图标 | 琥珀色 | 发现存档点 |
| Boss | 骷髅图标 | 信号红 | 发现Boss区域 |
| 隐藏房间 | 问号图标 | 幽紫色 | 发现隐藏房间 |
| 捷径 | 箭头图标 | 荧翠绿 | 解锁捷径 |
| NPC | 对话气泡 | 白色 | 遇到NPC |
| 商人 | 齿轮图标 | 琥珀色 | 遇到商人 |

#### 规则4：地图显示控制
- **小地图**：HP条右下方（120×120px），当前区域+相邻已探索区域，实时更新，自动旋转
- **全地图**：按M键打开，所有已解锁区域，可平移/缩放/点击标记，再按M/Esc关闭

#### 规则5：区域完成度显示
`area_completion = (discovered_secrets + unlocked_shortcuts + defeated_enemies) / (total_secrets + total_shortcuts + total_enemies)`
- 100%：金色边框+星标
- 0%：灰色（未探索）
- 1-99%：彩色（部分探索）

### States and Transitions

**地图系统状态**：MINIMAP_ONLY（默认）→ FULL_MAP_OPEN（按M）→ MINIMAP_ONLY（再按M/Esc）
区域切换时：任意 → MAP_TRANSITION → MINIMAP_ONLY

### Interactions with Other Systems

**上游依赖**：场景管理、世界状态(provisional)、探索与能力门控
**下游被依赖**：HUD/UI、快速旅行(undesigned)

**接口签名**：
```
open_full_map() → void
close_full_map() → void
add_map_marker(marker_type, position: Vector2, area_id) → void
remove_map_marker(marker_id) → void
get_area_completion(area_id) → float
get_player_map_position() → Vector2
set_current_area(area_id) → void
```

## Formulas

**区域完成度**（引用 exploration-ability-gating.md 公式，本系统不拥有此公式）：
`area_completion = (discovered_secrets + unlocked_shortcuts + defeated_enemies) / (total_secrets + total_shortcuts + total_enemies)`

| Variable | Type | Range |
|----------|------|-------|
| discovered_secrets | int | 0-total |
| unlocked_shortcuts | int | 0-total |
| defeated_enemies | int | 0-total |
| **输出** | float | 0.0-1.0 |

**全局完成度**：`global_completion = Σ(area_completion × area_weight) / Σ(area_weight)`
- hub=0.5, 普通区域=1.0, Boss区域=1.5

## Edge Cases

- **区域切换时全地图打开**：自动关闭全地图
- **未解锁区域尝试查看**：灰色迷雾，不可交互
- **标记超出显示范围**：小地图只显示当前区域，全地图显示所有
- **完成度除零**：total=0时返回0.0
- **快速连续区域切换**：队列机制，只显示最后一次
- **全地图打开时玩家死亡**：自动关闭
- **标记重叠**：偏移显示（±5px）

## Dependencies

**上游依赖**：场景管理、世界状态(provisional)、探索与能力门控
**下游被依赖**：HUD/UI、快速旅行(undesigned)

## Tuning Knobs

| 旋钮 | 默认值 | 安全范围 | 过高影响 | 过低影响 |
|------|--------|---------|---------|---------|
| minimap_size_px | 120 | 80-200 | 太大遮挡 | 太小难读 |
| minimap_zoom_level | 1.0 | 0.5-2.0 | 太近 | 太远 |
| minimap_rotation | true | true/false | — | — |
| full_map_open_key | M | 任意键 | — | — |
| fog_dissolve_duration | 1.0秒 | 0.5-2.0秒 | 太慢 | 太快 |
| marker_offset_px | 5 | 0-10 | 太分散 | 重叠 |
| completion_weight_hub | 0.5 | 0.3-0.7 | — | — |
| completion_weight_normal | 1.0 | 0.8-1.2 | — | — |
| completion_weight_boss | 1.5 | 1.2-2.0 | — | — |

## Visual/Audio Requirements

### 地图视觉
- 小地图：120×120px，半透明黑底，彩色区域
- 全地图：全屏，半透明黑底，彩色区域+标记
- 迷雾：灰色渐变，消散动画（1秒）
- 玩家图标：猫爪（猫眼金，实时移动）
- 标记图标：16×16px像素艺术

### 地图动画
- 迷雾消散：灰色→透明（1秒）
- 标记出现：从中心放大（0.5秒）
- 区域切换：旧区域淡出+新区域淡入（1秒）
- 玩家移动：猫爪图标平滑移动

### 音效
- 地图打开/关闭：轻微展开/关闭音
- 迷雾消散：轻微消散音
- 标记出现：轻微提示音

## UI Requirements

> 📌 **UX Flag — 地图系统**: 运行 `/ux-design` 创建 `design/ux/map-ui.md`。

### 小地图UI
- 位置：HP条右下方（120×120px）
- 显示：当前区域+相邻已探索区域
- 玩家图标：猫爪（实时移动）
- 自动旋转：以玩家朝向为上方

### 全地图UI
- 打开：按M键
- 显示：所有已解锁区域+标记+完成度百分比
- 交互：平移/缩放/标记详情
- 关闭：再按M键/Esc

## Acceptance Criteria

- **GIVEN** 游戏开始，**WHEN** 初始化，**THEN** 小地图显示（120×120px，HP条右下）
- **GIVEN** 进入新区域，**WHEN** `area_unlocked`事件，**THEN** 迷雾消散+区域显示
- **GIVEN** 发现隐藏房间，**WHEN** `secret_room_discovered`事件，**THEN** 问号标记出现
- **GIVEN** 按M键，**WHEN** 小地图状态，**THEN** 全地图打开
- **GIVEN** 全地图打开，**WHEN** 再按M键，**THEN** 全地图关闭
- **GIVEN** 全地图打开，**WHEN** 玩家死亡，**THEN** 自动关闭
- **GIVEN** 区域完成度100%，**WHEN** 查询，**THEN** 返回1.0+金色边框
- **GIVEN** 未探索区域，**WHEN** 全地图查看，**THEN** 灰色迷雾

## Open Questions

| # | 问题 | 负责人 | 目标解决时间 |
|---|------|--------|-------------|
| 1 | 是否需要地图图钉（玩家手动标记）？ | ux-designer | UX设计阶段 |
| 2 | 是否需要地图传说（标记图标说明）？ | ux-designer | UX设计阶段 |
| 3 | 全地图是否需要区域筛选？ | ux-designer | UX设计阶段 |
