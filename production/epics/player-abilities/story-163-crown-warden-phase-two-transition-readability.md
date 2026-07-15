# Story 163: Crown Warden Phase II Transition Readability

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Feature / Boss Combat / Presentation / Audio
> **Type**: Integration + Gameplay Runtime + Combat Readability
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-14

## Context

**GDD**: `design/gdd/boss-config.md`,
`design/gdd/combat-presentation.md`, `design/gdd/hud-ui.md`,
`design/gdd/audio-system.md`

**Quick Design**:
`design/quick-specs/crown-warden-phase-two-transition-readability-2026-07-14.md`

**Requirements**: `TR-boss-002`, `TR-combatfx-001`, `TR-hud-001`

**ADR Governing Implementation**: ADR-0002, ADR-0004, ADR-0005, ADR-0006,
ADR-0010, ADR-0019, ADR-0020.

Story146 已实现 Crown Warden 的 Phase II 阈值、攻击链安全等待、HUD 与阶段
数值，但旧路径会在收招后立即恢复行动。Story163 补齐 GDD 规定的 2.5 秒
无敌转换，把动画、碰撞、VFX、HUD 与音频绑定到同一个只触发一次的运行时
窗口。

## Acceptance Criteria

- [x] 80 点阈值伤害发生在 `wing_sweep` active 时只设置 pending；Boss 继续
  Phase I，直到当前 attack recovery 完整结束。
- [x] 收招后只启动一次 2.5 秒 Phase II 转换，攻击状态为
  `phase_transition`，移动与新攻击暂停，Hurtbox 为 `gone`。
- [x] 转换期间 Arena 伤害入口返回 `false`，Boss HP 保持 `80/160`；推进
  2.49 秒仍在转换，2.50 秒边界准确结束。
- [x] 转换播放现有三帧 `hurt` 动画，并发出一次带持续时间、动画、位置、
  阶段和冷却数据的阶段信号。
- [x] Arena 将信号转发到现有 CombatPresentation、AudioSystem 与 Boss HUD；
  运行时显示 Phase II，存在一层 phase overlay、32 个金属碎片，并播放
  `sfx_boss_phase`。
- [x] 转换结束后恢复 `idle`、正常 Hurtbox 与 Phase II 冷却，新
  `talon_dive` 可以启动，转换计数仍为 1。
- [x] Intentional RED、focused GREEN、最小 Boss4 related regression、目标
  smoke 与 Godot MCP 3.0.2 真实场景截图/日志均有证据。

## Out Of Scope

- 重做现有全屏 phase overlay 的构图、层级或 1.5 秒淡出；该问题保留为独立
  Combat Presentation 可读性 Story。
- 新视觉/音频素材、第三阶段、召唤、竞技场突变、相机编舞或 Boss1-3 改造。
- 修改攻击伤害、Phase II 速度、奖励、回程、存档格式或共享 Boss 架构。

## Implementation

- `CrownWardenBoss` 新增明确的 `PHASE_TRANSITION` 状态、2.5 秒计时、
  deterministic advance/diagnostics API、攻击/伤害拒绝、Hurtbox 无敌与边界
  恢复。
- 阈值仍在当前攻击完成后消费；进入阶段时清理攻击碰撞、停止移动并播放配置
  中的 `hurt`，结束时恢复 Phase II 的 30 帧冷却和正常碰撞。
- `CrownWardenArena.apply_damage()` 返回 Boss 的真实接受结果，并把阶段元数据
  转发给现有表现、音频和 HUD 接口。
- 本 Story 复用现有生成资产与音频，不新增 image-generation 产物或 Godot
  import 项。

## Test Evidence

- Intentional RED: `reports/report_1687/results.xml`，`1` case / `1` 个预期
  failure，锁定缺失 deterministic phase-transition API。
- Focused GREEN: `reports/report_1688/results.xml`，`1/1` 通过，0 error、
  failure、flaky、skip、orphan。
- Bounded related GREEN: `reports/report_1689/results.xml`，`15/15` 通过，
  覆盖 Story163、Boss4 core、parry counter、reward payoff 与 victory recall。
- Target smoke:
  `tests/smoke/crown_warden_phase_two_transition_feedback_smoke.gd`，exit `0`，
  marker `crown_warden_phase_two_transition_feedback_smoke=passed`。
- Godot MCP evidence:
  `production/qa/evidence/crown-warden-phase-two-transition-readability-2026-07-14.md`
  与
  `production/qa/evidence/crown-warden-phase-two-transition-readability-mcp-run1.json`。
- 未运行 full suite；文档更新后没有重复等价 focused 测试。

**Status**: [x] Complete.
