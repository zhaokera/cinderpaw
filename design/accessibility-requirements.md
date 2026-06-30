# Accessibility Requirements

> **Status**: Initial Framework
> **Author**: ux-designer
> **Last Updated**: 2026-06-21
> **Target Tier**: WCAG-AA baseline (pending formal tier decision)

---

## Overview

本文档定义《废土喵影》的无障碍设计需求。所有 UI 系统和交互模式必须满足此处定义的最低标准。

**目标平台**: PC (Steam/Epic), Mobile (iOS/Android), Console (PlayStation/Xbox/Switch)
**输入方式**: Keyboard/Mouse, Gamepad, Touch — 全部完全支持

---

## Visual Accessibility

### 色盲模式

| 色盲类型 | 影响 | 适配方案 |
|----------|------|---------|
| 红绿色盲 (Deuteranopia/Protanopia) | HP条红绿渐变不可区分 | HP条改为蓝→黄渐变 |
| 蓝黄色盲 (Tritanopia) | 蓝色/黄色不可区分 | HP条改为红→白渐变 |
| 全色盲 (Achromatopsia) | 仅灰度 | 使用亮度差异 + 形状区分 |

**实现**: hud-ui.md 规则5 色盲模式 — 提供3种色板选项

### 最小可读字体

| 元素 | 最小字号 | 推荐字号 |
|------|---------|---------|
| HUD数字 | 14px | 16px |
| 菜单文字 | 16px | 20px |
| 对话框文字 | 18px | 22px |
| 通知弹出 | 14px | 16px |

### HUD缩放

- 支持 50%-150% 缩放（默认100%）
- 缩放后元素不重叠（自动调整布局间距）

### 高对比度模式

- 所有交互元素的焦点指示器使用高对比度颜色（猫眼金 `#ECC94B` on 深灰背景）
- 文字对比度 ≥ 4.5:1（WCAG-AA标准）

---

## Motor Accessibility

### 键盘/手柄完全导航

- 所有菜单可通过 D-Pad/方向键 完整导航
- 所有交互元素可通过 Tab/Shift+Tab 顺序到达
- 焦点顺序逻辑合理（从上到下，从左到右）
- 焦点指示器始终可见

### 按键重映射

- PC版支持完全自定义键位（input.md 规则2）
- 映射存储在 `user://input_bindings.cfg`
- 提供默认键位恢复选项

### 操作时间宽容度

- 连招超时窗口可调（默认300ms，范围200-500ms）
- Coyote Time 可调（默认6帧，范围4-10帧）
- Jump Buffer 可调（默认6帧，范围4-10帧）

### 单手操作

- 所有核心操作可通过单手完成（手柄单摇杆+肩键）
- 移动端触控布局支持单手持握

---

## Auditory Accessibility

### 字幕

- 所有NPC对话显示字幕（可关闭）
- Boss阶段转换文字显示
- 重要音效提供视觉替代（如敌人攻击预警=信号红闪烁）

### 音量独立控制

- 5总线独立音量控制（Master/Music/SFX/Ambient/UI）
- 支持完全静音各总线

### 音效视觉替代

- 敌人攻击预警：信号红闪烁（替代攻击音效）
- 低HP警告：HP条颜色变化（替代心跳音 — 游戏不添加心跳音）
- 专注模式激活：猫眼金边缘闪光（替代猫科提示音）

---

## Cognitive Accessibility

### 信息密度控制

- HUD元素可按类别隐藏/显示
- 伤害数字可关闭（设置选项）
- 战斗统计面板为可选（设置中开启）

### 难度辅助（非降低难度）

- 弹反窗口辅助选项（可扩展至12帧/自动弹反）— 待 playtest 验证
- 不降低敌人伤害或血量（技巧优先承诺）
- 无"怜悯机制"（同一Boss连续死亡不降低难度）

### 导航辅助

- 小地图始终可见
- 存档点/目标方向指示
- 探索提示系统（长时间未发现秘密时给暗示）— 待设计

---

## Godot 4.7 Specific Considerations

### 双焦点系统 ⚠️ HIGH RISK

Godot 4.6 引入了双焦点系统，当前项目基线为 Godot 4.7：mouse/touch focus 与 keyboard/gamepad focus 分离。

**影响**:
- `grab_focus()` 仅影响 keyboard/gamepad focus
- Mouse hover 产生独立的 mouse focus
- 两种焦点可同时活跃在不同控件上

**要求**:
- 所有自定义焦点绘制必须分别测试两种输入方式
- 菜单导航以 keyboard/gamepad focus 为主要路径
- Mouse/touch focus 提供视觉反馈但不要求键盘可达

### AccessKit 屏幕阅读器 (4.5+)

- Control 节点通过 AccessKit 与屏幕阅读器集成
- 所有非文本元素需要 `tooltip` 或 `accessible_name` 属性
- 焦点变更自动通知屏幕阅读器

---

## Open Questions

- [ ] 无障碍需求的正式 tier 等级尚未确定（建议 WCAG-AA 作为基线）
- [ ] 弹反窗口辅助选项是否纳入 MVP 还是推迟到垂直切片
- [ ] 移动端触控的最小触控区域尺寸（建议 44×44pt Apple HIG 标准）
- [ ] 屏幕阅读器支持的范围（完整游戏 vs 仅菜单）
- [ ] 色盲模式的 3 种色板是否需要在 art-bible 中定义精确色值
