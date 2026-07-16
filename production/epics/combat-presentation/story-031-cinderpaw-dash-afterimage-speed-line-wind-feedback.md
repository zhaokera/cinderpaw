# Story 031: Cinderpaw Dash Afterimage, Speed-Line, and Wind Feedback

> **Epic**: Combat Presentation
> **Status**: Complete
> **Layer**: Presentation
> **Type**: Visual / Feel / Audio / Integration
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-16

## Context

**GDD**: `design/gdd/combat-presentation.md`, `design/gdd/player-abilities.md`

**Requirement**: `TR-combatfx-004`

Story030 已让 Dash 三帧动作与 Dodge 可辨认，但 Main 仍把 `dash_started`
路由到 Dodge 的残影与音效。本 Story 保持 Dash 的移动、冷却、门控和三帧动画
不变，只补齐玩家可直接感知的两道高速残影、定向速度线和独立风声。

## Acceptance Criteria

- [x] 成功 Dash 生成恰好两道当前帧残影，位于移动反方向 `20px/40px`，
  alpha 为 `0.45/0.25`，生命周期为 `10/60s`。
- [x] 同次 Dash 生成一组 image-generated 冷白/月光蓝速度线，位于角色身后，
  可随朝向镜像并在 `6/60s` 后清理。
- [x] Main 将 `dash_started` 独立路由到 `CombatPresentation.on_dash_event` 和
  `AudioSystem.on_dash_event`，不再复用 Dodge handler。
- [x] Dash 请求独立 `dash / sfx_dash` cue；音频文件已导入且路径与
  `sfx_dodge` 不同。
- [x] Dash 速度仍为 `620 px/s`，现有三帧 `dash` 动画、能力门控和冷却回归
  通过；Dodge 仍为三残影和 `sfx_dodge`，不生成速度线。
- [x] Dash VFX 纳入既有 200-particle cap，速度线和残影按各自生命周期清理；
  已释放速度线的诊断读取不会访问 freed instance。
- [x] Godot 4.7 / MCP 3.0.2 使用真实 Dash action 验证动画、速度、视觉、
  独立音效、生命周期、Dodge 隔离、非空截图和 clean logs。

## Out of Scope

- Dash 解锁、速度、持续时间、距离、冷却、碰撞或无敌帧规则。
- Dash 三帧角色素材、Dodge、Perfect Parry、Double Jump、camera 或 hitstop。
- 非 Main 场景集成、关卡门、Boss 奖励、存档、HUD 或平衡调整。
- 真人主观混音签收、商业母带或平台响度认证。

## Required Evidence

- `tests/unit/gameplay/main_scene_player_dash_presentation_test.gd`
- `tests/unit/gameplay/player_dash_ability_runtime_test.gd`
- `tests/unit/gameplay/main_scene_player_dodge_afterimage_test.gd`
- `tests/unit/presentation/audio_system_test.gd`
- `tests/unit/gameplay/main_scene_audio_event_adapter_test.gd`
- `design/assets/specs/cinderpaw-dedicated-dash-presentation.md`
- `production/qa/evidence/cinderpaw-dash-afterimage-speed-line-wind-feedback-2026-07-16.md`

## Test Evidence

- Initial RED: `reports/report_1836/results.xml`，`1` 个验收测试产生预期的
  `7` 项失败，证明旧实现仍为三道 Dodge 残影、`dodge/sfx_dodge` 且无速度线。
- Initial GREEN: `reports/report_1837/results.xml`，新验收 `1/1`。
- Adapter correction: `reports/report_1841/results.xml`，Main audio adapter
  `12/12`，并按 authored attack startup 修正旧测试时序及清理音频 stream。
- MCP-found lifecycle RED/GREEN: `report_1843` 稳定复现 freed-instance 错误；
  `report_1844` 在过期后安全读取诊断并通过 `1/1`。
- Final focused + related: `reports/report_1845/results.xml`，五套件
  `41/41`，`0 errors / 0 failures / 0 orphans`，exit `0`。
- Full suite 未运行，符合 Main 可见表现小 Story 的验证预算。

## Completion Notes

**Completed**: 2026-07-16

**Criteria**: 7/7 passing

速度线源图、透明处理结果、提示词、确定性音频生成脚本和参数均已留档并进入
Godot import 管线。自动化与 MCP 证明 cue 独立、资源可加载并收到播放请求，
不声明已完成真人主观听感评审。
