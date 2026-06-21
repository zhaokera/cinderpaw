# HUD/UI系统 (HUD/UI System)

> **Status**: Designed (awaiting review)
> **Author**: 用户 + AI
> **Last Updated**: 2026-06-18
> **Implements Pillar**: 猫科战斗美学, 机制探索回报
> **Systems Index**: #13 | MVP核心 | Presentation

## Overview

**HUD/UI系统**是游戏的视觉信息聚合层，负责将各系统的状态数据转化为玩家可读的界面元素。它管理战斗HUD（HP条、武器图标、连招指示器）、菜单系统（暂停、存档、设置）、以及过渡界面（加载、死亡、阶段转换）。设计原则：**UI不遮挡战斗视野**——战斗中HUD元素最小化，菜单中信息最大化。

## Player Fantasy

**「猫的视界」— 信息清晰但不干扰**

HUD的终极使命是让玩家**随时知道关键状态，但从不分散注意力**。战斗中，HP条在视野边缘默默告诉你"还有多少"，武器图标让你一眼知道当前装备——但你的眼睛始终聚焦在敌人身上。菜单打开时，信息丰富且层次清晰。好的UI是隐形的——你只在需要时注意到它。

## Detailed Design

### Core Rules

#### 规则1：战斗HUD布局

| 元素 | 位置 | 尺寸 | 来源GDD |
|------|------|------|---------|
| 玩家HP条 | 左下角 | 200×20px | 生命系统 |
| 武器图标+名称 | 右下角 | 48×48px图标 | 武器流派 |
| 特殊招式冷却 | 武器图标下方 | 圆弧进度 | 武器流派 |
| 连招指示器 | 角色头顶 | 数字1/2/3 | 猫科战斗 |
| Boss HP条 | 顶部中央 | 400×15px | Boss配置 |
| 齿轮币计数 | 右上角 | 图标+数字 | — |
| 小地图 | 右上角（HP条下方） | 120×120px | 场景管理 |

#### 规则2：HUD可见性规则
- **战斗中**：全部HUD元素可见
- **探索中**：HP条+齿轮币+小地图可见，武器图标半透明
- **对话中**：仅对话框可见，其他HUD隐藏
- **过场动画**：全部HUD隐藏
- **Boss战**：额外显示Boss HP条+阶段指示

#### 规则3：菜单系统

**暂停菜单**（Esc/Start键触发）：
- 继续游戏、保存游戏（仅存档点附近可用）、加载游戏、设置、返回主菜单

**设置菜单**：
- 音频：主音量、音乐、音效、环境音（各自0-100%）
- 显示：亮度、色盲模式（红绿/蓝黄）、HUD缩放
- 控制：键位重映射（PC键盘+手柄）
- 游戏：战斗总结开关、伤害数字显示开关

**主菜单**：新游戏、继续游戏、加载游戏、设置、退出

#### 规则4：HUD动画规则
- HP变化：平滑过渡（0.3秒插值）
- 低HP脉动：HP<25%时HP条颜色稳定为信号红，**不脉动**（CD-GDD-ALIGN决定：低HP专注模式下保持视觉清晰）
- 武器切换：旧图标淡出+新图标淡入（0.3秒）
- 连招数字：弹出放大效果（1.0→1.3→1.0，0.2秒）
- 伤害数字：从命中点弹出上浮+淡出（1.5秒）

#### 规则5：无障碍支持
- **色盲模式**：红绿色盲→HP条蓝→黄渐变；蓝黄色盲→HP条红→白渐变
- **HUD缩放**：50%-150%缩放（默认100%）
- **字幕**：所有NPC对话和Boss阶段文字显示字幕（可关闭）
- **伤害数字**：可关闭

### States and Transitions

| UI状态 | 可见HUD | 触发条件 |
|--------|---------|---------|
| COMBAT | 全部战斗HUD | 进入战斗 |
| EXPLORING | HP+齿轮币+小地图 | 脱离战斗5秒 |
| DIALOGUE | 仅对话框 | NPC交互 |
| CUTSCENE | 无 | 过场动画 |
| BOSS_FIGHT | 全部+Boss HP条 | Boss战开始 |
| MENU | 无HUD+菜单覆盖 | 暂停/菜单打开 |

### Interactions with Other Systems

**上游依赖**：
- 生命系统 — `on_hp_changed`信号
- 猫科战斗 — combo_index
- 武器流派 — 当前武器
- Boss配置 — Boss HP和阶段
- 存档系统 — 存档槽位
- 场景管理 — 区域/小地图

**下游被依赖**：无（纯展示层）

**接口签名**：
```
show_hud(state: String) → void
hide_hud() → void
show_menu(menu_type: String) → void
hide_menu() → void
update_hp(current: int, max: int) → void
update_boss_hp(current: int, max: int, phase: int) → void
show_damage_number(position: Vector2, damage: int, metadata: Dictionary) → void
show_notification(text: String, duration: float) → void
```

## Formulas

本系统不定义游戏平衡公式。UI性能预算：
- HUD渲染：< 1ms帧时间
- 菜单打开/关闭：< 100ms

## Edge Cases

- **HP满值时受击**：HP条闪白0.1秒
- **同时多个伤害数字**：各自独立弹出，随机偏移±10px防重叠
- **菜单打开时Boss攻击**：游戏暂停
- **色盲模式下Boss阶段**：改用形状标记（I/II/III + 图标）
- **HUD缩放150%元素重叠**：自动调整布局间距
- **快速传送菜单存档点很多**：滚动列表，每页5个

## Dependencies

**上游依赖**：生命、猫科战斗、武器流派、Boss配置、存档、场景管理
**下游被依赖**：无

## Tuning Knobs

| 旋钮 | 默认值 | 安全范围 | 过高影响 | 过低影响 |
|------|--------|---------|---------|---------|
| hud_scale | 1.0 | 0.5-1.5 | UI太大 | UI太小 |
| hp_bar_width | 200px | 100-300px | — | — |
| hp_transition_sec | 0.3 | 0.1-0.5 | 太快 | 太慢 |
| damage_number_duration | 1.5 | 0.5-3.0 | 太久 | 太快 |
| combat_hud_timeout | 5.0 | 3.0-10.0 | 太快消失 | 太久 |

## Visual/Audio Requirements

### HUD视觉风格
- **整体风格**：废土工业风——金属质感边框、铆钉装饰、微妙锈迹
- **字体**：像素字体，数字等宽
- **颜色**：背景深灰半透明(#1A1A2E80)，边框钢青灰(#6B8A9E)，文字米白(#E8E4DC)，高亮猫眼金(#ECC94B)，警告信号红(#E53E3E)
- **HP条渐变**：猫眼金(100-75%) → 黄(74-50%) → 橙(49-25%) → 信号红(24-1%)

### 菜单视觉风格
- **背景**：全屏模糊（场景模糊50%+深灰叠加）
- **面板**：金属质感+铆钉边框
- **按钮**：猫爪形状选中指示器
- **动画**：面板从顶部滑入（0.3秒）

### 音效设计
- 菜单打开/关闭：金属门开启/关闭音
- 菜单导航：猫爪轻触音
- 菜单确认：印章盖下音
- HP低提示：环境音降低50%，战斗音效保持清晰，**不添加心跳音**（与health-death.md规则8专注模式一致）
- 通知弹出：轻柔叮音

## UI Requirements

> 📌 **UX Flag — HUD/UI系统**: 在Phase 4运行 `/ux-design` 创建每个屏幕的UX规范（`design/ux/hud.md`, `design/ux/pause-menu.md`, `design/ux/settings.md`, `design/ux/main-menu.md`）。

### 屏幕清单
1. 战斗HUD
2. 暂停菜单
3. 设置菜单
4. 主菜单
5. 存档/加载界面
6. 快速传送菜单
7. 对话框
8. 战斗总结（可选）
9. Boss阶段转换
10. 加载界面
11. 武器升级界面

## Acceptance Criteria

- **GIVEN** 战斗中，**WHEN** HP从100降到50，**THEN** HP条平滑过渡（0.3秒）从猫眼金变黄
- **GIVEN** 连招第2击命中，**WHEN** 更新连招指示器，**THEN** 显示"2"并弹出放大
- **GIVEN** 脱离战斗5秒，**WHEN** 无敌人附近，**THEN** HUD切换到EXPLORING状态
- **GIVEN** 暂停菜单打开，**WHEN** Boss正在攻击，**THEN** 游戏暂停
- **GIVEN** 色盲模式（红绿），**WHEN** HP变化，**THEN** HP条使用蓝→黄渐变
- **GIVEN** HUD缩放150%，**WHEN** 战斗HUD显示，**THEN** 所有元素按比例放大且无重叠
- **GIVEN** Boss战阶段2开始，**WHEN** 阶段转换，**THEN** Boss HP条显示阶段II标记

## Open Questions

| # | 问题 | 负责人 | 目标解决时间 |
|---|------|--------|-------------|
| 1 | 技能树UI设计（依赖技能树系统GDD #22）？ | game-designer | 技能树系统GDD |
| 2 | 是否需要"伤害统计面板"（实时DPS显示）？ | game-designer | 垂直切片阶段 |
| 3 | 移动端触控UI布局方案？ | ux-designer | 移动端开发阶段 |
