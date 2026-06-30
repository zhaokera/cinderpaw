# Interaction Pattern Library

> **Status**: Initial Framework
> **Author**: ux-designer
> **Last Updated**: 2026-06-21
> **Template**: Interaction Pattern Library
> **Input Methods**: Keyboard/Mouse (PC), Gamepad (全平台), Touch (移动端)
> **Primary Input**: Gamepad
> **Gamepad Support**: Full
> **Touch Support**: Full

---

## Overview

本模式库记录《废土喵影》中所有可复用的交互模式。每个模式定义了一种统一的交互方式，确保跨屏幕一致性。设计新屏幕时，优先引用已有模式而非创建新模式。

---

## Pattern Catalog

| # | Pattern Name | Category | Used In | Description |
|---|-------------|----------|---------|-------------|
| 1 | 确认对话框 | Modal | 全局 | 危险操作前的双选项确认 |
| 2 | 列表导航 | Navigation | 菜单、技能树 | 垂直/水平列表的焦点移动 |
| 3 | 通知弹出 | Feedback | 全局 | 短暂信息提示（3秒淡出） |
| 4 | 资源条 | Data Display | HUD | HP/猫气/冷却的实时数值可视化 |
| 5 | 按键提示 | Feedback | 全局 | 上下文相关的输入图标提示 |
| 6 | 分页标签 | Navigation | 设置菜单 | 多页面切换的标签导航 |

---

## Patterns

### 1. 确认对话框

**Category**: Modal
**Used In**: 洗点确认、覆盖存档、退出游戏

**Description**: 当玩家执行不可逆或高代价操作时，弹出双选项对话框要求确认。防止误操作。

**Specification**:
- **触发**: 危险操作按钮按下
- **布局**: 屏幕中央半透明叠加层，对话框宽60%屏宽
- **选项**: 确认（默认焦点） + 取消
- **输入映射**:
  - Gamepad: A=确认, B=取消
  - Keyboard: Enter=确认, Esc=取消
  - Touch: 点击按钮
- **反馈**: 确认音 + 操作执行；取消音 + 对话框关闭
- **无障碍**: 焦点默认在确认按钮；两个按钮均有清晰的焦点指示器

**When to Use**: 操作不可逆或代价较高（洗点、覆盖存档、退出）
**When NOT to Use**: 常规操作（装备切换、菜单导航）

---

### 2. 列表导航

**Category**: Navigation
**Used In**: 主菜单、设置菜单、技能树节点列表、护符列表

**Description**: 垂直或水平列表中的焦点移动。支持循环导航和快速跳转。

**Specification**:
- **导航**:
  - Gamepad: D-Pad/摇杆上下左右移动焦点
  - Keyboard: 方向键/WASD
  - Touch: 点击项目或滑动列表
- **焦点指示器**: 猫爪形状高亮框（猫眼金色 `#ECC94B`）
- **循环**: 列表末尾→首项（垂直）
- **快速跳转**: 长按方向键加速（初始5项/秒，2秒后15项/秒）
- **音效**: 导航音（猫爪轻触）+ 确认音（印章盖下）

**When to Use**: 任何需要选择列表中一项的场景
**When NOT to Use**: 自由空间导航（地图、技能树图谱）

---

### 3. 通知弹出

**Category**: Feedback
**Used In**: 技能点获取、区域解锁、成就、存档成功

**Description**: 屏幕边缘短暂显示信息条，3秒后自动淡出。不中断当前操作。

**Specification**:
- **位置**: 屏幕底部中央
- **样式**: 猫眼金底色 + 白色文字 + 图标
- **持续**: 3秒显示 → 0.5秒淡出
- **堆叠**: 多条通知垂直堆叠（最多3条同时显示）
- **输入**: 不可交互（纯信息展示）
- **音效**: 轻柔叮音

**When to Use**: 非紧急的系统通知
**When NOT to Use**: 需要玩家操作的信息（用确认对话框）；战斗中的实时反馈（用HUD元素）

---

### 4. 资源条

**Category**: Data Display
**Used In**: HP条、猫气条、Boss HP条、蓄力条、冷却进度

**Specification**:
- **形式**: 水平填充条（从左到右）
- **更新**: 平滑过渡（0.3秒插值）
- **颜色**: 根据数值变化（满=猫眼金 → 空=信号红）
- **低值警告**: ≤25% 时颜色稳定为信号红（不脉动，保持视觉清晰）
- **数值显示**: 条旁或条内显示数字（如 75/100）

**When to Use**: 实时变化的数值资源
**When NOT to Use**: 静态数值（用纯数字显示）

---

### 5. 按键提示

**Category**: Feedback
**Used In**: 门交互、NPC对话、拾取物品

**Specification**:
- **位置**: HUD边缘小图标（不在屏幕中央）
- **内容**: 当前设备对应的按键图标 + 动作名
- **切换**: 根据 `device_changed` 信号动态切换图标集（键盘/手柄/触控）
- **战斗中**: 不显示额外按键提示
- **风格**: 符合游戏视觉语言（废土工业风金属质感）

**When to Use**: 可交互对象附近
**When NOT to Use**: 战斗中或过场动画中

---

### 6. 分页标签

**Category**: Navigation
**Used In**: 设置菜单（音频/显示/控制/游戏）

**Specification**:
- **布局**: 顶部水平标签栏
- **导航**: 左右切换标签页
- **输入**:
  - Gamepad: LB/RB 切换标签
  - Keyboard: Tab/Shift+Tab
  - Touch: 点击标签
- **焦点指示器**: 当前标签底部金色下划线
- **切换动画**: 内容区域淡入淡出（0.2秒）

**When to Use**: 3个以上平级分类的设置页面
**When NOT to Use**: 线性流程（用步骤导航）

---

## Gaps & Patterns Needed

| Pattern | Needed For | Priority |
|---------|-----------|----------|
| 技能树图谱导航 | 技能树界面 | High |
| 地图平移/缩放 | 全地图界面 | High |
| 拖拽装备 | 护符菜单 | Medium |
| 对话选择 | NPC对话界面 | Medium |
| 加载指示器 | 场景过渡 | Low |

---

## Open Questions

- [ ] 技能树图谱是否需要专门的导航模式（自由平移+缩放）？
- [ ] 移动端触控的滑动灵敏度阈值需要 playtest 验证
- [ ] Godot 4.7 基线下的双焦点系统（mouse/touch focus ≠ keyboard/gamepad focus）对焦点指示器设计的影响需要原型验证
- [ ] 无障碍需求文档尚未创建，模式库中的无障碍规格为初步建议
- [ ] Player journey map 尚未创建，模式的上下文触发条件可能需要调整
