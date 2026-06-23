# ADR-0014: 移动端输入适配策略

## Summary
定义移动端输入适配：采用虚拟摇杆+按钮布局，与 PC/手柄共享 Input action 系统。移动端特有优化：触控缓冲窗口延长（200ms vs 150ms），按钮大小适配手指操作。

## Status
Proposed

## Date
2026-06-22

## Engine Compatibility

| Field | Value |
|-------|-------|
| **Engine** | Godot 4.6.3 |
| **Domain** | Input / Foundation |
| **Knowledge Risk** | MEDIUM — SDL3 驱动 (4.5+) 对手柄的支持需要验证 |
| **References Consulted** | `docs/engine-reference/godot/current-best-practices.md` |
| **Post-Cutoff APIs Used** | SDL3 gamepad driver (4.5+) — 影响手柄震动和自定义映射 |
| **Verification Required** | 验证 SDL3 驱动对自定义震动模式的支持；触控输入的延迟和精度 |

## ADR Dependencies

| Field | Value |
|-------|-------|
| **Depends On** | ADR-0001 (Autoload), ADR-0002 (信号通信) |
| **Enables** | 移动端发布 |
| **Blocks** | 移动端输入实现（可推迟到 PC 版本完成后） |

## Context

### Problem Statement

游戏计划发布移动端（iOS/Android）。需要决定：
1. 触控输入方案（虚拟摇杆 vs 手势 vs 混合）
2. 与 PC/手柄输入的架构统一程度
3. UI 布局适配（不同屏幕比例）
4. 性能优化（移动端帧率目标）

### Constraints

- **统一架构**: 尽量复用 Input action 系统，减少平台特定代码
- **操控性**: 移动端操作必须精准，不能影响战斗体验
- **性能**: 移动端目标 30fps（低端设备）或 60fps（高端设备）

## Decision

### 输入架构：统一 Input Action 系统

**选择**: 所有平台共享 Input action 映射

```gdscript
# InputManager (Autoload)
# 所有平台通过 Input action 消费输入
# PC: 键盘/手柄 → InputEventKey/InputEventJoypadButton
# 移动端: 虚拟按钮 → 模拟 InputEventScreenTouch
```

**优势**:
- 战斗系统、菜单系统等不需要知道输入来源
- 新增平台只需扩展输入映射，不需要修改游戏逻辑

### 移动端布局：虚拟摇杆+按钮

```
┌─────────────────────────────────┐
│                                 │
│                                 │
│                                 │
│                                 │
│  [摇杆]                    [B]  │
│                          [A][X] │
│                            [Y]  │
└─────────────────────────────────┘

摇杆: 移动 (左下角)
A: 攻击 (右下)
B: 闪避 (右中)
X: 弹反 (右左)
Y: 特殊招式 (右上)
```

**按钮大小**: 最小 80×80px（适配手指操作）  
**按钮间距**: 最小 20px（防止误触）  
**摇杆**: 浮动摇杆（触摸位置为圆心）

### 触控优化

| 参数 | PC/手柄 | 移动端 | 理由 |
|------|---------|--------|------|
| 输入缓冲窗口 | 150ms (9帧) | 200ms (12帧) | 触控精度较低，延长窗口 |
| 预输入窗口 | 50ms (3帧) | 80ms (5帧) | 触控延迟略高 |
| 弹反窗口 | 6帧 (100ms) | 8帧 (133ms) | 触控精度补偿 |

### UI 布局适配

**安全区域**: 考虑刘海屏、圆角
```gdscript
# HUDManager
func _ready():
    var safe_area = DisplayServer.get_display_safe_area()
    _apply_safe_area_margin(safe_area)
```

**屏幕比例**: 支持 16:9 到 21:9（超宽屏）
- HUD 元素锚定到角落，不随比例拉伸
- 战斗区域保持 16:9，两侧留黑边（如果比例不匹配）

### 性能目标

| 设备等级 | 帧率目标 | 渲染质量 |
|---------|---------|---------|
| 低端 (2020年前) | 30fps | 低画质，关闭后处理 |
| 中端 (2020-2023) | 60fps | 中画质，SMAA 关闭 |
| 高端 (2023年后) | 60fps | 高画质，SMAA 1x |

**动态分辨率**: 如果帧率低于目标，动态降低渲染分辨率（保持 UI 清晰）

## Consequences

### Positive
- **统一架构**: 所有平台共享 Input action，减少代码重复
- **操控优化**: 触控缓冲窗口延长，提升精准度
- **性能分级**: 动态分辨率确保不同设备都能流畅运行

### Negative
- **测试负担**: 需要在多种设备和屏幕比例上测试
- **触控精度**: 即使优化，触控仍不如手柄精准（弹反等操作可能受影响）
- **开发优先级**: 移动端开发推迟到 PC 版本完成后

### Risk Mitigation
- **原型验证**: 在 PC 版本完成后，用 1-2 周验证移动端操控
- **降级方案**: 如果弹反窗口在移动端太难，可以提供"辅助模式"（自动弹反或窗口延长）
- **市场策略**: 移动端作为第二批发布，PC 首发

## GDD Requirements Addressed

- `design/gdd/input.md` — 多平台输入支持
- `design/gdd/game-concept.md` — Platform: PC首发 → 移动端第二批

## Verification

- [ ] 虚拟摇杆在快速移动时响应灵敏
- [ ] 按钮布局在不同屏幕比例下不被遮挡
- [ ] 触控缓冲窗口延长后弹反成功率提升
- [ ] 低端设备帧率稳定 30fps
- [ ] 刘海屏安全区域正确处理
