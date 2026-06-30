# ADR-0015: 无障碍实现方案 (AccessKit, 色盲模式)

## Summary
定义无障碍实现方案：利用 Godot 4.5+ 的 AccessKit 集成实现屏幕阅读器支持，提供色盲模式（3种滤镜），支持按键重映射和辅助模式（降低难度）。可推迟到 P3 阶段实现。

## Status
Proposed

## Date
2026-06-22

## Engine Compatibility

| Field | Value |
|-------|-------|
| **Engine** | Godot 4.7 |
| **Domain** | UI / Accessibility |
| **Knowledge Risk** | HIGH — AccessKit 是 4.5+ 新增 (post-cutoff) |
| **References Consulted** | `docs/engine-reference/godot/current-best-practices.md`, `docs/engine-reference/godot/breaking-changes.md` |
| **Post-Cutoff APIs Used** | `Control.accessibility_*` (4.5+ AccessKit integration) |
| **Verification Required** | 验证 AccessKit 在主流屏幕阅读器（NVDA, VoiceOver）上的兼容性 |

## ADR Dependencies

| Field | Value |
|-------|-------|
| **Depends On** | ADR-0011 (UI焦点管理) |
| **Enables** | 无障碍功能 |
| **Blocks** | 无（可推迟到 P3 阶段） |

## Context

### Problem Statement

游戏计划发布到多个平台（PC/移动端/主机），需要考虑无障碍支持：
1. 视觉障碍（色盲、低视力）
2. 听觉障碍（音效依赖）
3. 运动障碍（操作精度要求高）
4. 认知障碍（复杂 UI）

### Constraints

- **优先级**: 无障碍功能优先级低于核心玩法，可推迟
- **平台要求**: 主机平台（PlayStation/Xbox/Switch）有无障碍认证要求
- **成本**: 无障碍功能开发成本需要控制

## Decision

### 视觉障碍支持

#### 色盲模式

**提供 3 种色盲滤镜**:

| 类型 | 滤镜 | 用途 |
|------|------|------|
| 红色盲 (Protanopia) | 红→黄绿 | 区分红/绿信号（敌人攻击预警） |
| 绿色盲 (Deuteranopia) | 绿→蓝紫 | 区分红/绿信号 |
| 蓝色盲 (Tritanopia) | 蓝→黄 | 区分蓝/黄信号（较少见） |

**实现**:
```gdscript
# CanvasLayer (Post-processing)
var _color_blind_filter: ColorRect

func set_color_blind_mode(mode: StringName):  # "none" | "protanopia" | "deuteranopia" | "tritanopia"
    match mode:
        &"protanopia":
            _color_blind_filter.material.set_shader_param("mode", 1)
        &"deuteranopia":
            _color_blind_filter.material.set_shader_param("mode", 2)
        &"tritanopia":
            _color_blind_filter.material.set_shader_param("mode", 3)
        _:
            _color_blind_filter.visible = false
```

**关键信号替代**:
- 敌人攻击预警：红色闪烁 → 形状变化（三角形变大）+ 音效
- HP 低：红色脉动 → 屏幕边缘白色闪烁 + 心跳音效

#### 高对比度模式

**提供高对比度主题**:
- 角色轮廓加粗（2px 黑色描边）
- UI 元素对比度增强
- 文字大小可调（100% / 125% / 150%）

#### 屏幕阅读器支持 (AccessKit)

**利用 Godot 4.5+ AccessKit 集成**:

```gdscript
# 所有 UI Control 节点设置 accessibility 属性
func _ready():
    accessibility_label = "玩家 HP 条"
    accessibility_hint = "当前 HP: 80/100"
    accessibility_role = AccessKit.ROLE_PROGRESS_BAR
```

**关键 UI 元素**:
- 菜单按钮：`accessibility_label` + `accessibility_hint`
- HP 条：`ROLE_PROGRESS_BAR` + 实时数值更新
- 对话框：`ROLE_DIALOG` + 文本朗读

### 听觉障碍支持

#### 视觉替代

| 音效 | 视觉替代 |
|------|---------|
| 弹反成功 | 屏幕闪白 + "PARRY!" 文字 |
| 敌人攻击 | 攻击前摇动画 + 红色预警标记 |
| HP 低 | 屏幕边缘红色脉动 |
| 技能冷却完成 | 按钮图标高亮 |

#### 字幕系统

**所有 NPC 对话提供字幕**:
```gdscript
# DialogueSystem
func show_dialogue(npc_name: String, text: String):
    _dialogue_label.text = text
    _subtitle_container.visible = true
    # 字幕显示时间 = 文字长度 × 0.05秒 + 1秒
    _auto_hide_timer = text.length() * 0.05 + 1.0
```

### 运动障碍支持

#### 按键重映射

**支持完全按键重映射**:
```gdscript
# InputManager
func remap_action(action: StringName, new_event: InputEvent):
    InputMap.action_erase_events(action)
    InputMap.action_add_event(action, new_event)
    _save_remapping_to_config()
```

**预设方案**:
- 默认布局
- 左手布局（镜像）
- 单手布局（简化操作）

#### 辅助模式

**提供难度降低选项**:
- 弹反窗口延长（+2帧 / +4帧 / +6帧）
- 闪避 i-frame 延长（+2帧 / +4帧）
- 敌人攻击速度减慢（-20% / -40%）
- HP 自动回复（每10秒 +5HP）

**实现**:
```gdscript
# DataManager (Tuning Knobs)
var parry_window_bonus: int = 0  # 辅助模式加成
var dodge_iframe_bonus: int = 0
var enemy_speed_multiplier: float = 1.0
var auto_regen_enabled: bool = false
```

### 认知障碍支持

#### UI 简化模式

**可选简化 UI**:
- 隐藏连招指示器
- 隐藏猫气条
- 只显示核心信息（HP、武器）

#### 教程强化

**渐进式教程**:
- 每个机制单独教学（分步骤）
- 可重复查看教程（菜单中）
- 提供"安全房间"练习（不会死亡）

## Consequences

### Positive
- **市场扩大**: 无障碍支持扩大潜在玩家群体
- **平台要求**: 满足主机平台认证要求
- **用户体验**: 辅助模式帮助新手适应高难度

### Negative
- **开发成本**: 无障碍功能需要额外开发和测试
- **性能**: 后处理滤镜可能影响低端设备性能
- **平衡**: 辅助模式可能影响游戏平衡（但单人游戏可接受）

### Risk Mitigation
- **分阶段**: 无障碍功能分阶段实现（色盲 → 重映射 → 辅助模式 → 屏幕阅读器）
- **原型验证**: 每个无障碍功能先做原型验证效果
- **玩家测试**: 邀请无障碍玩家参与测试

## GDD Requirements Addressed

- `design/gdd/game-concept.md` — 多平台发布需求
- `design/gdd/hud-ui.md` — UI 可访问性

## Verification

- [ ] 色盲滤镜正确区分红/绿信号
- [ ] 屏幕阅读器正确朗读菜单按钮
- [ ] 按键重映射持久化到配置文件
- [ ] 辅助模式不影响成就系统
- [ ] 字幕显示时间与语音同步
- [ ] 高对比度模式在像素艺术下仍然美观

## Implementation Priority

**P3 (可推迟)**: 此 ADR 定义的功能可以推迟到 PC 版本完成后实现。优先级：
1. 色盲模式（最简单，影响最大）
2. 按键重映射（中等复杂度）
3. 辅助模式（需要调整游戏参数）
4. 屏幕阅读器（最复杂，需要 AccessKit 深入集成）
