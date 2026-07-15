# Story 016: Perfect Parry Gold Afterimage Feedback

> **Epic**: Combat Presentation
> **Status**: Complete
> **Layer**: Presentation / Gameplay Integration
> **Type**: Visual/Feel
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-14

## Context

**GDD**: `design/gdd/combat-presentation.md`

**Art Direction**: `design/art/art-bible.md`

**Requirements**: `TR-combatfx-004`, `TR-combatfx-006`, `TR-combatfx-010`

**ADR Governing Implementation**: ADR-0001 scene ownership; ADR-0002 signal
communication; ADR-0005 combat state machine ownership.

Main 已经把真实 Player PERFECT 弹反路由到 `CombatPresentation`，并产生帧停、
震屏、闪白和放射火花，但 GDD 规定的“一帧金色弹反姿态残影”仍缺失。该缺口让
PERFECT 与普通成功弹反在玩家轮廓层面缺少直接区分。

## Acceptance Criteria

- [x] 真实 Main Player PERFECT 弹反继续由现有 `CombatComponent` 判定，并在
  `CombatPresentation` 中额外生成且只生成一个稳定命名的玩家残影。
- [x] 残影复用 Player 当前 `AnimatedSprite2D` 帧纹理、世界位置和朝向，使用
  猫眼金 `#ECC94B`，不新增静态角色图或改变 gameplay timing。
- [x] `good`、`miss` 和缺少纹理的事件不生成金色残影，且不影响既有弹反帧停、
  震屏、闪白、火花和音频路径。
- [x] 残影加入现有 200 粒子预算，使用确定的短生命周期并自动清理，无重复残留。
- [x] Focused GdUnit、最小相关回归、目标 smoke 和 Godot MCP 运行态验证真实
  PERFECT 弹反、纹理/颜色/节点/生命周期、非空截图和 clean logs。

## Out of Scope

- 新增“完美闪避”判定、改动 dodge i-frame、反击窗口、弹反伤害或 Cat Energy。
- 新增位图素材；本 Story 的视觉是实时玩家帧的表现层派生效果，因此不需要
  image generation、manifest 或 import 变更。
- Boss 专属弹反反应、慢动作、手柄震动、音频替换和色盲模式重设计。

## Test Evidence

**Required evidence**:

- `tests/unit/gameplay/main_scene_perfect_parry_gold_afterimage_test.gd`
- `tests/smoke/main_scene_perfect_parry_gold_afterimage_smoke.gd`
- Existing `tests/unit/presentation/combat_presentation_test.gd`
- Existing `tests/unit/gameplay/main_scene_audio_event_adapter_test.gd`
- Godot MCP evidence under
  `production/qa/evidence/main-scene-perfect-parry-gold-afterimage-2026-07-14.md`

**Status**: [x] RED captured in `reports/report_1621/results.xml`: the focused
Main acceptance failed on the two missing gold-afterimage APIs before production
code was added. MCP visual review then exposed the weak tinted overlap;
`reports/report_1624/results.xml` failed on the missing solid silhouette shader
and 12px directional offset. Focused GREEN is `reports/report_1625/results.xml`
(`1/1`); final bounded related GREEN is `reports/report_1626/results.xml`
(`51/51`). Target smoke prints
`main_scene_perfect_parry_gold_afterimage_smoke=passed`. Final Godot MCP run
`r18602105-22` verified the real Main event, exact material/color/position,
three-frame parry animation, lifecycle, non-empty screenshot and clean logs.

## Dependencies

- Depends on: Combat Presentation Story002, Story004, Story007 and existing
  Main Player parry signal integration.
- Unlocks: later perfect-dodge feedback only after an approved perfect-dodge
  gameplay event contract exists.
