# Quick Design Spec: Crown Warden Phase II Transition Readability

## 问题

Story146 已让 Crown Warden 在 50% HP 后进入 Phase II，但旧运行时只在当前
攻击收招后立即切换阶段与数值，没有实现 `boss-config.md` 规定的 2-3 秒
无敌转换，也没有把阶段动画、战斗表现、HUD 与音频收束为一个可验收窗口。
玩家因此难以区分普通受击、攻击收招和二阶段正式开始。

## 有界结果

1. HP 首次降到 50% 或更低时，若 Boss 正在攻击，阶段转换继续等待当前攻击
   完整收招，不中断 active/recovery。
2. 收招后只启动一次 2.5 秒 Phase II 转换；Boss 停止移动和出招，Hurtbox
   进入 `gone`，直接伤害入口返回 `false` 且 HP 不变。
3. 转换播放现有三帧 `hurt` 动画，并通过同一个阶段信号驱动 Boss HUD、现有
   phase overlay、32 个金属碎片与 `sfx_boss_phase`。
4. 2.5 秒边界结束时恢复 `idle`、正常 Hurtbox 和 Phase II 的 30 帧攻击
   冷却配置；后续攻击可以正常启动。

## 所有权

- `CrownWardenBoss`：拥有转换状态、计时、无敌窗口、动画与恢复边界。
- `CrownWardenArena`：保留实体路由，转发阶段元数据到 CombatPresentation、
  AudioSystem 与 Boss HUD，并让伤害入口返回 Boss 的接受结果。
- `CombatPresentation`、`AudioSystem`：复用现有阶段反馈 API，不新增第二套
  Boss 专用表现系统。

## 验收探针

在真实 Crown Warden Arena 中启动 `wing_sweep`，active 阶段造成 80 伤害。
Phase I 必须保持到完整收招；随后 Phase II 以 80/160 HP 进入 2.5 秒转换，
Hurtbox 为 `gone`，再次伤害和新攻击均被拒绝。诊断显示一层 overlay、32 个
碎片、HUD `Phase II` 与 `sfx_boss_phase`。推进 2.49 秒仍处于转换，推进到
2.50 秒后恢复正常 Hurtbox 且 `talon_dive` 可启动。

## 素材

不新增素材。复用 `combat_boss_phase_overlay.png`、`combat_enemy_debris.png`、
Crown Warden 三帧 `hurt` 动画及现有 `sfx_boss_phase`。现有全屏 overlay 的
中心遮挡和淡出时长属于独立 Combat Presentation 可读性修正，不在本切片中
重做资产或表现生命周期。

## 范围外

- 新阶段贴图、音效、角色帧、第三阶段或竞技场地形变化。
- 重写通用 BossConfigComponent、HealthComponent 或 CombatPresentation。
- 改动 Crown Warden 攻击伤害、Phase II 速度、奖励、场景回程或存档格式。
