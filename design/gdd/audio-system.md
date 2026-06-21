# 音效系统 (Audio System)

> **Status**: Designed (awaiting review)
> **Author**: 用户 + AI
> **Last Updated**: 2026-06-21
> **Implements Pillar**: 猫科战斗美学
> **Systems Index**: #15 | MVP核心 | Presentation
> **Cross-doc Sync (2026-06-21)**: 心跳音移除（与health-death.md CD裁定对齐）、on_low_hp→on_focus_mode_changed、LOW_HP状态重定义、sfx_low_hp→sfx_damage_taken_lowhp+sfx_focus_mode_activate

## Overview

**音效系统**管理游戏的所有音频资源——背景音乐、音效、环境音和UI音效。它负责音频总线管理（主音量/音乐/音效/环境音独立控制）、音频触发（监听游戏事件播放对应音效）、空间音频（2D位置音效）和音乐系统（区域主题+Boss战斗音乐切换）。音效是打击感的50%——没有正确的音效，再好的视觉反馈也缺少"份量"。

## Player Fantasy

**「废土之声」— 声音构建世界的真实感**

音效系统的终极使命是让玩家**闭上眼睛也能感受到这个世界**。废弃商业街的风声和低语让你感到孤独；Boss战前的低沉鼓点让你的心跳加速；弹反成功时清脆的金属碰撞让你知道"我做到了"。好的音效是隐形的——你只在它缺失时才会注意到。

## Detailed Design

### Core Rules

#### 规则1：音频总线架构

| 总线名称 | 用途 | 默认音量 | 独立控制 |
|----------|------|:---:|:---:|
| Master | 总输出 | 80% | ✅ |
| Music | 背景音乐 | 60% | ✅ |
| SFX | 战斗/动作音效 | 80% | ✅ |
| Ambient | 环境音 | 50% | ✅ |
| UI | 菜单/UI音效 | 70% | ✅ |

#### 规则2：音效触发系统

| 事件类型 | 总线 | 位置 |
|----------|------|------|
| 攻击命中 | SFX | 命中点2D位置 |
| 暴击命中 | SFX | 命中点 |
| 弹反成功 | SFX | 玩家位置 |
| 闪避 | SFX | 玩家位置 |
| 受伤 | SFX | 玩家位置 |
| 敌人死亡 | SFX | 敌人位置 |
| Boss阶段转换 | SFX+Music | Boss位置 |
| HP低于25% | SFX | 全局 |
| 环境音 | Ambient | 区域配置 |
| 背景音乐 | Music | 全局 |
| 菜单音效 | UI | 全局 |

#### 规则3：音乐系统

**区域音乐**：
| 区域 | 风格 | 节奏 |
|------|------|------|
| 猫族据点 | 温暖原声吉他+猫叫采样 | 60-80BPM |
| 废弃商业街 | 孤独钢琴+风声 | 80-100BPM |
| 下水道 | 低沉合成器+水滴 | 60BPM |
| 旧工厂 | 机械节奏+金属敲击 | 120BPM |
| 霓虹屋顶 | 合成波+电子节拍 | 130BPM |
| 中央高塔 | 管弦乐+电子混合 | 变化 |

**Boss战斗音乐**：
| Boss | 阶段1 | 阶段2 | 阶段3 |
|------|-------|-------|-------|
| 垃圾桶鼠王 | 紧张打击乐 | +低音铜管 | +全管弦乐+合唱 |

**音乐切换规则**：区域切换3秒交叉淡入淡出，进入Boss战1秒硬切，Boss阶段转换2秒过渡，Boss战结束3秒淡出。

#### 规则4：空间音频（2D）
- 音效位置与游戏世界坐标绑定
- 左右声道平衡基于声源水平位置
- 距离衰减：300px开始，600px外静音
- 全局音效（UI、音乐）无空间定位

#### 规则5：音频优先级与并发控制
- 最大同时音效数：16个
- 优先级：弹反/暴击 > 普通命中 > 环境音效
- 超过并发上限：最低优先级音效丢弃
- 同一音效重复触发（<100ms）：合并播放，音量+20%

### States and Transitions

| 音频状态 | 行为 | 触发条件 |
|----------|------|---------|
| NORMAL | 正常播放 | 默认 |
| BOSS_FIGHT | Boss音乐+战斗音效优先 | Boss战开始 |
| LOW_HP | 受伤音效叠加低频混响（跟随focus_mode激活/退出，含迟滞） | on_focus_mode_changed(true) |
| DEATH | 所有音效淡出→死亡音效 | 玩家死亡 |
| MENU | UI音效+音乐降低50% | 菜单打开 |
| CUTSCENE | 背景音乐+叙事音效 | 过场动画 |

### Interactions with Other Systems

**上游依赖**：
- 猫科战斗 — `on_hit`, `on_parry`, `on_dodge`
- 伤害计算 — 伤害元数据
- 生命系统 — `on_hp_changed`, `on_focus_mode_changed`, `on_death`
- Boss配置 — `on_boss_phase_change`
- 场景管理 — 场景切换事件
- HUD/UI — 菜单交互事件

**下游被依赖**：无

**接口签名**：
```
play_sfx(sfx_id, position: Vector2 = Vector2.ZERO, volume_db: float = 0.0) → void
play_music(music_id, fade_in_sec: float = 1.0) → void
stop_music(fade_out_sec: float = 1.0) → void
set_bus_volume(bus_name, volume_percent: int) → void
play_ambient(ambient_id) → void
stop_ambient(fade_out_sec: float = 2.0) → void
```

## Formulas

**距离衰减**：
`volume_db = base_volume_db - 20 * log10(distance / 300)`
- 距离 > 600px 时静音
- 最大衰减：-40dB

## Edge Cases

- **同帧多个音效**：按优先级排序，超过16个丢弃最低优先级
- **快速重复触发**（<100ms）：合并播放，音量+20%
- **Boss战+低HP专注模式同时**：Boss音乐优先，受伤音效低频混响保持（由focus_mode控制，含迟滞防抖动）
- **菜单打开时Boss战**：音乐降低50%，战斗音效继续
- **场景切换时音频未结束**：2秒强制淡出
- **音频资源加载失败**：静音，不影响游戏，输出警告
- **设备音频输出变化**：重新初始化音频总线

## Dependencies

**上游依赖**：猫科战斗、伤害计算、生命系统、Boss配置、场景管理、HUD/UI
**下游被依赖**：无

## Tuning Knobs

| 旋钮 | 默认值 | 安全范围 | 过高影响 | 过低影响 |
|------|--------|---------|---------|---------|
| master_volume | 80% | 0-100% | — | 无声 |
| music_volume | 60% | 0-100% | 音乐盖音效 | 音乐无感 |
| sfx_volume | 80% | 0-100% | 音效刺耳 | 打击感弱 |
| ambient_volume | 50% | 0-100% | 环境干扰 | 无氛围 |
| ui_volume | 70% | 0-100% | UI太响 | 无反馈感 |
| max_concurrent_sfx | 16 | 8-32 | 性能问题 | 音效丢失 |
| sfx_merge_threshold_ms | 100 | 50-200 | 合并不明显 | 音效堆积 |
| spatial_fade_start_px | 300 | 100-500 | 衰减太早 | 无空间感 |
| spatial_fade_end_px | 600 | 400-1000 | 远处还能听到 | 太突然 |
| music_crossfade_sec | 3.0 | 1.0-5.0 | 切换太慢 | 太突然 |

## Visual/Audio Requirements

> 📌 **Asset Spec** — Audio requirements defined. Run `/asset-spec system:audio-system` for per-asset specifications.

### 音效资产清单

**战斗音效（SFX）**：sfx_hit_normal, sfx_hit_crit, sfx_parry_perfect, sfx_parry_good, sfx_dodge, sfx_damage_taken, sfx_damage_taken_lowhp（低频混响版）, sfx_enemy_death, sfx_boss_phase, sfx_focus_mode_activate（专注模式激活提示音）

**武器音效（SFX）**：sfx_claw_attack（高频短促）, sfx_blade_attack（中频弧线）, sfx_bone_attack（低频沉重）, sfx_bell_attack（电子嗡鸣）

**环境音（Ambient）**：amb_hub（温暖+猫叫）, amb_street（风+碎玻璃）, amb_sewer（水滴+低频）, amb_factory（机械+金属）, amb_rooftop（合成波+风）, amb_tower（电子脉冲）

**音乐（Music）**：mus_hub, mus_street, mus_sewer, mus_factory, mus_rooftop, mus_tower, mus_boss_rat_p1/p2/p3

**UI音效（UI）**：ui_menu_open, ui_menu_close, ui_navigate, ui_confirm, ui_cancel, ui_save, ui_load

## UI Requirements

本系统无独立UI——音频设置通过HUD/UI系统的设置菜单控制（音量滑块）。

## Acceptance Criteria

- **GIVEN** 普通攻击命中，**WHEN** `on_hit`触发，**THEN** 播放sfx_hit_normal（命中点位置）
- **GIVEN** PERFECT弹反，**WHEN** 触发，**THEN** 播放sfx_parry_perfect
- **GIVEN** 进入废弃商业街，**WHEN** 场景加载完成，**THEN** 3秒交叉淡入mus_street+amb_street
- **GIVEN** Boss战开始，**WHEN** Boss出现，**THEN** 1秒硬切到mus_boss_rat_p1
- **GIVEN** 玩家进入专注模式（on_focus_mode_changed(true)），**WHEN** 受到伤害, **THEN** 播放sfx_damage_taken_lowhp（低频混响版受伤音效）替代sfx_damage_taken
- **GIVEN** 同帧17个音效，**WHEN** 并发上限16，**THEN** 丢弃最低优先级
- **GIVEN** 菜单打开，**WHEN** 暂停菜单激活，**THEN** Music总线降低50%

## Open Questions

| # | 问题 | 负责人 | 目标解决时间 |
|---|------|--------|-------------|
| 1 | 是否需要自适应音乐（根据战斗激烈程度动态调整）？ | audio-director | 垂直切片阶段 |
| 2 | 移动端音频性能限制方案？ | technical-artist | 移动端开发阶段 |
| 3 | 是否需要音频字幕（声音可视化提示）？ | ux-designer | 无障碍设计阶段 |
