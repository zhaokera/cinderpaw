# Story 029: Boss2 Arena Camera Lock Runtime

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Core / Feature / Gameplay Runtime / Presentation Integration
> **Type**: Integration + Gameplay Runtime + Visual/Feel
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-30

## Context

**GDD**: `design/gdd/player-abilities.md`,
`design/gdd/exploration-ability-gating.md`, `design/gdd/boss-config.md`,
`design/gdd/scene-management.md`, `design/gdd/combat-presentation.md`

**Requirements**: `TR-ability-005`, `TR-scene-005`, `TR-boss-004`,
`TR-combatfx-001`

**ADR Governing Implementation**: ADR-0002 Signal communication; ADR-0005
Combat state machine; ADR-0007 Scene management; ADR-0018 Player abilities;
ADR-0021 Save system architecture.

Stories021-028 made Boss2 playable as the mainline Double Jump payoff, added
HUD focus, autonomous pressure, frame animation, arena bounds/reset semantics,
and arena/HUD readability. The remaining room-level feel issue is that the
camera still uses the full-scene framing even while Boss2 is active, so the
encounter reads like another object in the sandbox instead of a contained boss
fight.

This story adds the smallest runtime camera lock needed for the Boss2 room:
while undefeated Boss2 is active in `scenes/main.tscn`, the player's `Camera2D`
uses Boss2-room framing; when Boss2 is defeated or restored as defeated, the
camera returns to the default main-scene framing.

## Acceptance Criteria

- [x] `MainScene` exposes deterministic Boss2 camera diagnostics for tests and
  MCP probes, including whether the lock is enabled, the reason, camera path,
  limits, zoom, smoothing, and focus position.
- [x] While Boss2 is active and undefeated, `Player/Camera2D` applies Boss2 room
  framing: a tighter horizontal limit than the default full scene, camera
  smoothing enabled, and a modest zoom-in that makes Boss2/HUD action easier to
  read.
- [x] Boss2 camera framing does not alter Boss2 AI, arena bounds/reset,
  collision, HUD focus, Double Jump reward, or CombatPresentation screen-shake
  offset behavior.
- [x] When Boss2 is defeated or restored from defeated progress, the camera
  returns to the default main-scene limits and zoom so post-boss exploration and
  rewards are not trapped in the boss framing.
- [x] Focused RED/GREEN tests, related Boss2 regression, headless smoke, and
  Godot MCP runtime evidence are recorded.

## Out of Scope

- Boss2 room doors, new room art, minimap markers, cutscenes, camera rails,
  dynamic zoom curves, or full level-layout rebuild.
- Boss2 reset semantics, multi-phase AI, new attacks, final balance,
  boss portrait/HP-bar redesign, music/phase mix, or authored SFX changes.
- Generic camera manager, new Autoload, save schema migration, or non-Boss2
  camera behavior changes.

## Implementation Notes

- Keep the implementation scene-local to `MainScene` and the existing
  `Player/Camera2D`.
- Do not touch `Camera2D.offset`; CombatPresentation owns offset for screen
  shake and should remain compatible.
- Use explicit diagnostics instead of screenshot-only assertions.
- MCP evidence must prove scene load, camera diagnostics, active Boss2 camera
  framing, defeated release behavior, clean logs, and a nonblank screenshot.

## Test Evidence

**Required evidence**:

- `tests/unit/gameplay/boss2_arena_camera_lock_runtime_test.gd`
- Related Boss2 regressions for HUD focus, arena reset, autonomous pressure, and
  Double Jump payoff
- Headless main-scene smoke
- Godot MCP runtime evidence under
  `production/qa/evidence/boss2-arena-camera-lock-runtime-2026-06-30.md`

**Status**: [x] Complete. RED/GREEN focused evidence, related regression,
headless smoke, and Godot MCP runtime evidence are recorded.

- RED focused: `reports/report_839/` failed as expected because `MainScene`
  did not yet expose Boss2 camera lock APIs.
- Initial GREEN focused: `reports/report_840/` passed Story029 `2/2`.
- Review RED: `reports/report_844/` failed as expected before save-restore
  release and camera offset ownership regressions were fixed.
- Final GREEN focused: `reports/report_845/` passed Story029 `4/4`, including
  defeated save-restore release and CombatPresentation offset ownership.
- Final related regression: `reports/report_846/` passed Story029, Boss2 HUD focus,
  Boss2 arena bounds/reset, Boss2 telegraph strike, and Boss2 Double Jump payoff
  `20/20`. Boss2 autonomous pressure passed independently in
  `reports/report_847/` `6/6`.
- Combined related command `reports/report_841/` reproduced the known
  order-sensitive Boss2 autonomous run-frame assertion after other suites, so it
  is not acceptance evidence.
- Headless smoke:
  `reports/boss2_arena_camera_lock_runtime_main_scene_smoke.log`.
- Godot MCP evidence:
  `production/qa/evidence/boss2-arena-camera-lock-runtime-2026-06-30.md`.
- MCP runtime screenshot:
  `reports/visual/cinderpaw-mcp-boss2-arena-camera-lock-runtime-20260630.png`.

## Test-Criterion Traceability

| Criterion | Test / Evidence | Status |
|-----------|-----------------|--------|
| Boss2 camera diagnostics exposed | `report_839`, `report_845`, MCP probe | COVERED |
| Active Boss2 applies tighter camera framing | `report_845`, `report_846`, MCP camera properties | COVERED |
| Boss2 AI/HUD/reset/reward behavior preserved | `report_846`, `report_847` | COVERED |
| Defeated/restored Boss2 releases camera | `report_845`, `report_846`, MCP defeated-flag probe | COVERED |
| Runtime scene, logs, and screenshot verified | Headless smoke; QA evidence | COVERED |

## Completion Notes

**Completed**: 2026-06-30
**Criteria**: 5/5 passing
**Deviations**: No new visual assets were generated; this story reuses the
Story028 arena frame and existing Boss2/Cinderpaw frame-animation assets.
**QA Evidence**:
`production/qa/evidence/boss2-arena-camera-lock-runtime-2026-06-30.md`
