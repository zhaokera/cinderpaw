# ADR-0011: UI 焦点管理策略 (Godot 4.6 双焦点)

## Summary
定义 UI 焦点管理策略，应对 Godot 4.6 的双焦点系统（鼠标/触摸焦点与键盘/游戏手柄焦点分离）。采用 `FocusMode` 属性控制，HUD 使用 `FOCUS_NONE` 避免干扰战斗输入。

## Status
Proposed

## Date
2026-06-22

## Engine Compatibility

| Field | Value |
|-------|-------|
| **Engine** | Godot 4.6.3 |
| **Domain** | UI / Presentation |
| **Knowledge Risk** | HIGH — 双焦点系统是 4.6 新增 (post-cutoff) |
| **References Consulted** | `docs/engine-reference/godot/current-best-practices.md`, `docs/engine-reference/godot/breaking-changes.md` |
| **Post-Cutoff APIs Used** | `Control.focus_mode` (4.6 dual focus behavior change) |
| **Verification Required** | 验证菜单导航在键盘/手柄/鼠标三种输入下的行为一致性 |

## ADR Dependencies

| Field | Value |
|-------|-------|
| **Depends On** | ADR-0001 (Autoload), ADR-0007 (场景管理) |
| **Enables** | HUD/UI 系统实现 |
| **Blocks** | HUD/UI 实现 |

## Context

### Problem Statement

Godot 4.6 引入了双焦点系统：鼠标/触摸焦点与键盘/游戏手柄焦点分离。这意味着：
- 一个 Control 可以同时拥有"鼠标焦点"和"键盘焦点"
- 视觉反馈因输入方法不同而不同
- 需要决定如何处理 HUD 元素的焦点行为

### Constraints

- **战斗输入优先级**: HUD 元素不应拦截战斗中的输入
- **菜单导航**: 暂停/设置菜单需要完整的键盘/手柄导航支持
- **可访问性**: 需要支持键盘导航（无障碍要求）

## Decision

### 焦点策略分配

| UI 类型 | Focus Mode | 理由 |
|---------|------------|------|
| 战斗 HUD (HP条, 武器图标) | `FOCUS_NONE` | 不拦截战斗输入 |
| 小地图 | `FOCUS_NONE` | 纯展示，不需要交互 |
| 暂停菜单按钮 | `FOCUS_ALL` | 需要键盘/手柄导航 |
| 设置菜单滑块 | `FOCUS_ALL` | 需要键盘/手柄调整 |
| 对话框选项 | `FOCUS_ALL` | 需要键盘选择 |
| 存档槽位 | `FOCUS_ALL` | 需要键盘选择 |

### 菜单导航架构

```gdscript
# MenuManager (非 Autoload，由 SceneManager 管理)
class_name MenuManager
extends Control

func _ready():
    # 确保菜单打开时第一个按钮获得焦点
    get_tree().connect("tree_changed", _on_tree_changed)

func _on_tree_changed():
    if visible and get_focus_owner() == null:
        var first_button = find_first_focusable()
        if first_button:
            first_button.grab_focus()
```

### 输入模式检测

```gdscript
# InputManager
signal input_mode_changed(mode: StringName)  # "keyboard" | "gamepad" | "mouse"

var _current_mode: StringName = &"keyboard"

func _input(event: InputEvent):
    var new_mode: StringName
    if event is InputEventKey or event is InputEventJoypadButton:
        new_mode = &"keyboard" if event is InputEventKey else &"gamepad"
    elif event is InputEventMouse:
        new_mode = &"mouse"
    
    if new_mode != _current_mode:
        _current_mode = new_mode
        input_mode_changed.emit(new_mode)
```

### HUD 焦点屏蔽

```gdscript
# HUDManager
func _ready():
    # 所有战斗 HUD 子节点设置为 FOCUS_NONE
    for child in _combat_hud.get_children():
        if child is Control:
            child.focus_mode = Control.FOCUS_NONE
```

## Consequences

### Positive
- **战斗流畅**: HUD 不拦截输入，战斗体验不被打断
- **菜单友好**: 暂停/设置菜单完整支持键盘/手柄导航
- **可访问性**: 键盘导航满足无障碍要求

### Negative
- **测试负担**: 需要在三种输入模式下测试菜单行为
- **复杂度**: 输入模式检测需要额外逻辑

### Risk Mitigation
- **原型验证**: 在 Tier 1 原型中验证焦点行为
- **降级方案**: 如果焦点系统过于复杂，可以简化为单一焦点模式

## GDD Requirements Addressed

- `design/gdd/hud-ui.md` — Rule 3 (UI状态), Rule 5 (菜单系统)
- `design/gdd/input.md` — 多平台输入支持

## Verification

- [ ] 战斗中 HUD 不拦截键盘/手柄输入
- [ ] 暂停菜单支持键盘方向键导航
- [ ] 暂停菜单支持手柄 D-Pad 导航
- [ ] 鼠标点击菜单按钮正常工作
- [ ] 输入模式切换时焦点视觉反馈正确
