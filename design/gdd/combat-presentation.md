# 战斗表现系统 (Combat Presentation System)

> **Status**: Designed (awaiting review)
> **Author**: 用户 + AI
> **Last Updated**: 2026-06-18
> **Implements Pillar**: 猫科战斗美学
> **Systems Index**: #14 | MVP核心 | Presentation

## Overview

**战斗表现系统**是战斗"手感"的视觉和音频执行层。它监听战斗事件（命中、暴击、弹反、闪避、击杀等），触发对应的视觉特效（帧停、震屏、粒子、残影）和音效反馈。没有它，战斗只是动画——有了它，每一刀都有"份量"，每一次弹反都有"成就感"。战斗表现 = 50%的战斗手感。

## Player Fantasy

**「每一击都有份量」— 打击感的极致反馈**

战斗表现的终极使命是让玩家的每一次操作都得到**超越预期的感官回报**。命中敌人时不只是数字弹出——而是帧停让世界为你停顿一瞬，震屏让力量传导到你的手指，火花粒子让冲击可视化。弹反成功时不只是伤害翻倍——而是全屏闪白宣告"你做到了"。好的战斗表现让玩家**闭上眼睛都能感受到自己变强了**。

## Detailed Design

### Core Rules

#### 规则1：帧停（Hitstop）系统

| 命中类型 | 帧停帧数 | 时间(ms@60fps) | 触发条件 |
|----------|:---:|:---:|------|
| 普通命中 | 3帧 | 50ms | 任何攻击命中 |
| 暴击命中 | 6帧 | 100ms | 暴击 |
| 弹反成功 | 8帧 | 133ms | PERFECT弹反 |
| 连招终结 | 5帧 | 83ms | combo_index=2 |
| Boss阶段转换 | 4帧 | 67ms | 阶段切换 |
| 击杀 | 6帧 | 100ms | 敌人HP≤0 |

帧停叠加规则：同帧多个事件取最大值（不叠加）。

#### 规则2：震屏（Screen Shake）系统

| 事件 | 强度 | 持续 | 方向 |
|------|:---:|:---:|------|
| 普通命中 | 2px | 3帧 | 随机 |
| 暴击命中 | 5px | 5帧 | 攻击方向 |
| 弹反成功 | 8px | 8帧 | 径向 |
| Boss砸地 | 10px | 10帧 | 垂直 |
| 击杀 | 5px | 5帧 | 随机 |

震屏叠加规则：同帧多个事件取最大值。

#### 规则3：粒子特效系统

| 事件 | 粒子类型 | 颜色 | 数量 | 生命周期 |
|------|---------|------|:---:|:---:|
| 普通命中 | 火花 | 白色 | 5-8 | 0.3秒 |
| 暴击命中 | 火花+闪光 | 猫眼金 | 10-15 | 0.5秒 |
| 弹反成功 | 火花爆发 | 刃白+金 | 20-25 | 0.8秒 |
| 猫爪攻击 | 爪痕轨迹 | 琥珀色 | 3条 | 0.4秒 |
| 长尾刃攻击 | 弧线轨迹 | 银色 | 1条 | 0.5秒 |
| 鱼骨大剑攻击 | 冲击波 | 白色 | 1圈 | 0.3秒 |
| 电磁铃铛攻击 | 电弧 | 蓝色 | 5-8 | 0.4秒 |
| 敌人死亡 | 碎裂 | 敌人主色 | 15-20 | 1.0秒 |
| Boss阶段转换 | 金属碎片 | 钢青灰 | 30+ | 1.5秒 |

#### 规则4：残影（Afterimage）系统
- **闪避残影**：3帧半透明残影（50%/30%/10%）
- **高速移动残影**：冲刺时2帧残影
- **弹反姿态残影**：PERFECT弹反时1帧金色残影

#### 规则5：伤害数字表现

| 伤害范围 | 字号 | 颜色 | 特效 |
|----------|:---:|------|------|
| 1-5 | 12px | 白色 | 无 |
| 6-15 | 16px | 白色 | 无 |
| 16-30 | 20px | 黄色 | 轻微震屏 |
| 31-60 | 28px | 金色 | 帧停+震屏 |
| 61-150 | 36px | 猫眼金 | 帧停+震屏+闪光 |
| 151-999 | 48px | 猫眼金+白边 | 全特效+慢动作0.3秒 |

数字动画：从命中点弹出→上浮30px→淡出（1.5秒）。

#### 规则6：闪白（Flash）效果
- **全屏闪白**：PERFECT弹反，全屏白色80%→0%，8帧
- **角色闪白**：受击闪白3帧
- **敌人闪白**：被暴击命中闪白5帧

#### 规则7：玩家角色帧动画
- 玩家角色运行时视觉统一使用 `AnimatedSprite2D + SpriteFrames`。
- 角色帧素材放在 `assets/characters/<角色名>/<动画名>/`，PNG帧必须透明背景、尺寸一致、锚点一致、连续命名。
- 玩家垂直切片至少提供 `idle`、`run`、`attack` 三组多帧动画；完整角色集后续扩展 `jump`、`fall`、`dodge`、`hurt`、`death`、`revive`。
- 表现层动画只负责视觉状态；CombatComponent、CollisionComponent 和 PlayerController 的帧计数仍是战斗规则权威。

### States and Transitions

战斗表现系统无状态机——事件驱动的纯表现层。每个特效独立、自管理、播放完自动销毁。

### Interactions with Other Systems

**上游依赖（信号监听）**：
- 猫科战斗 — `on_hit`信号
- 伤害计算 — 伤害元数据
- 碰撞系统 — `on_hit_confirmed`
- Boss配置 — `on_boss_phase_change`
- 生命系统 — HP变化

**下游被依赖**：无（纯表现层）

**接口签名**：
```
on_hit_event(hit_data: Dictionary) → void
on_boss_phase_change(boss_id, phase) → void
on_kill_event(target_id, position) → void
play_screen_shake(intensity, duration_frames, direction) → void
play_hitstop(frames) → void
play_flash(duration_frames, color, alpha) → void
spawn_particles(type, position, config) → void
```

## Formulas

本系统不定义游戏平衡公式。性能预算：
- 粒子系统：< 2ms帧时间
- 震屏/帧停：< 0.1ms
- 总战斗表现开销：< 3ms帧时间

## Edge Cases

- **同帧多个帧停事件**：取最大值
- **同帧多个震屏事件**：取最大值
- **帧停期间玩家输入**：输入缓冲正常，帧停后立即执行
- **粒子超过上限（200）**：最旧粒子优先销毁
- **Boss阶段转换+击杀同帧**：播放击杀特效（优先级更高）
- **低HP专注模式下震屏**：强度降低30%
- **色盲模式粒子颜色**：调整为色盲友好色板

## Dependencies

**上游依赖**：猫科战斗、伤害计算、碰撞系统、Boss配置、生命系统
**下游被依赖**：无

## Tuning Knobs

| 旋钮 | 默认值 | 安全范围 | 过高影响 | 过低影响 |
|------|--------|---------|---------|---------|
| hitstop_normal_frames | 3 | 1-6 | 战斗卡顿 | 打击感弱 |
| hitstop_crit_frames | 6 | 3-10 | 太卡 | 暴击无感 |
| hitstop_parry_frames | 8 | 4-12 | 太卡 | 弹反无感 |
| shake_normal_intensity | 2px | 1-5px | 太晃 | 无感 |
| shake_crit_intensity | 5px | 3-10px | 太晃 | 暴击无感 |
| particle_max_count | 200 | 50-500 | 性能问题 | 特效稀疏 |
| damage_number_duration | 1.5 | 0.5-3.0 | 数字太多 | 消失太快 |
| flash_parry_alpha | 0.8 | 0.5-1.0 | 太刺眼 | 无感 |
| afterimage_count | 3 | 1-5 | 太多 | 无感 |

## Visual/Audio Requirements

> 📌 **Asset Spec** — Visual/Audio requirements defined. After art bible approved, run `/asset-spec system:combat-presentation`.

### 视觉风格原则
- **艺术圣经对齐**：遵循「万物蓄势」总纲
- **色彩即语法**：白色=普通，金色=暴击/弹反，信号红=敌人
- **形态即命运**：锐利三角=攻击性，圆弧=防御性

### 粒子资产清单
| 粒子名称 | 颜色 | 形状 | 数量 |
|----------|------|------|:---:|
| spark_hit | 白色 | 点状 | 5-8 |
| spark_crit | 猫眼金 | 星状 | 10-15 |
| spark_parry | 刃白+金 | 放射状 | 20-25 |
| trail_claw | 琥珀色 | 线状 | 3条 |
| trail_blade | 银色 | 弧线 | 1条 |
| wave_bone | 白色 | 圆环 | 1圈 |
| arc_bell | 蓝色 | 闪电 | 5-8 |
| debris_enemy | 敌人主色 | 块状 | 15-20 |
| debris_boss | 钢青灰 | 块状 | 30+ |
| afterimage_dodge | 角色色 | 剪影 | 3帧 |

### 音效设计
- 命中音效：与伤害类别匹配，音调随伤害递增
- 暴击音效：强化金属碰撞+低频共鸣
- 弹反音效：清脆金属碰撞（PERFECT=高频+共鸣）
- 闪避音效：短促风声+布料音
- 击杀音效：沉重碎裂音+胜利短音

## UI Requirements

本系统无独立UI——所有反馈为游戏世界内特效（非HUD层）。伤害数字由HUD/UI系统渲染，本系统提供位置和数值数据。

## Acceptance Criteria

- **GIVEN** 普通攻击命中，**WHEN** `on_hit`触发，**THEN** 3帧帧停+轻微震屏+5-8个白色火花
- **GIVEN** 暴击命中，**WHEN** is_crit=true，**THEN** 6帧帧停+中等震屏+金色粒子+金色大字
- **GIVEN** PERFECT弹反，**WHEN** parry_type="perfect"，**THEN** 8帧帧停+全屏闪白+强烈震屏+放射粒子
- **GIVEN** 闪避执行，**WHEN** dodge动画播放，**THEN** 3帧半透明残影
- **GIVEN** 同帧多个帧停，**WHEN** 处理，**THEN** 取最大值
- **GIVEN** Boss阶段转换，**WHEN** 触发，**THEN** 震屏+金属碎片+暗角
- **GIVEN** 敌人被击杀，**WHEN** HP≤0，**THEN** 6帧帧停+碎裂粒子+击杀音效
- **GIVEN** 玩家移动或攻击，**WHEN** PlayerController状态变化，**THEN** 玩家视觉通过 `AnimatedSprite2D + SpriteFrames` 播放对应多帧动画，而不是静态 `Sprite2D` 单图

## Open Questions

| # | 问题 | 负责人 | 目标解决时间 |
|---|------|--------|-------------|
| 1 | 是否需要"慢动作"效果（传说伤害时）？ | game-designer | Tier 1原型验证 |
| 2 | 粒子是否需要GPUParticles2D？ | technical-artist | 技术验证阶段 |
| 3 | 移动端粒子数量自动降级？ | technical-artist | 移动端开发阶段 |
