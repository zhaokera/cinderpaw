# Story 028: Boss2 HUD Hit Feedback + Arena Visual Runtime

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Core / Feature / Gameplay Runtime / Presentation Integration
> **Type**: Integration + Gameplay Runtime + HUD/Visual
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-30

## Context

**GDD**: `design/gdd/player-abilities.md`,
`design/gdd/exploration-ability-gating.md`, `design/gdd/boss-config.md`,
`design/gdd/hud-ui.md`, `design/gdd/combat-presentation.md`

**Requirements**: `TR-ability-005`, `TR-explore-001`, `TR-explore-002`,
`TR-boss-001`, `TR-hud-001`, `TR-combatfx-001`

**ADR Governing Implementation**: ADR-0002 Combat presentation; ADR-0004
Collision detection; ADR-0005 Combat state machine; ADR-0007 Scene management;
ADR-0018 Player abilities; ADR-0021 Save system.

Stories021-026 made Boss2 playable as the mainline Double Jump payoff, added
HUD focus, autonomous pressure, run animation, and arena bounds/reset semantics.
This story makes the encounter more readable at runtime by adding a dedicated
image-generated Boss2 arena frame and a short HUD hit flash when Boss2 takes
damage, without changing Boss2 collision, AI, reward, or reset contracts.

## Acceptance Criteria

- [x] `scenes/main.tscn` contains a visible `Boss2ArenaFrame` `Sprite2D` using
  `res://assets/environment/boss2_arena/boss2_echo_guardian_arena_frame.png`.
- [x] The Boss2 arena frame is a transparent imported 640x256 PNG with source,
  alpha source, prompt metadata, `.import` sidecar, and asset manifest record.
- [x] The arena frame is a non-collision visual layer behind Boss2 and does not
  change Boss2 arena bounds, reset, defeat, or Double Jump reward behavior.
- [x] Boss2 HP decreases trigger a short white HUD hit flash while keeping the
  existing Boss2 HUD focus label and phase marker intact.
- [x] The HUD hit flash exposes deterministic diagnostics for runtime tests and
  MCP probes: visibility, remaining time, and color.
- [x] Godot MCP verifies `res://scenes/main.tscn` runs, `Boss2ArenaFrame` is
  visible with the expected texture, Boss2 still uses `AnimatedSprite2D +
  SpriteFrames`, Boss2 damage triggers and expires the HUD flash, logs are
  clean, and a nonblank screenshot shows Boss2, HUD, and arena frame.

## Out of Scope

- Boss2 camera lock, room doors, final boss-room layout, minimap markers,
  cutscenes, and full Old Factory route content.
- Boss2 multi-phase AI, final combat balancing, new hitboxes, or changes to
  arena bounds/reset behavior.
- Boss portrait UI, full HP bar redesign, subtitles, accessibility
  visualization, or final music/mix pass.

## Implementation Notes

- Keep `Boss2ArenaFrame` as `Sprite2D` only. It must not add collision bodies,
  areas, or reward-state logic.
- HUD flash should be driven by Boss HP deltas inside `HUDManager` so the
  existing `MainScene` Boss2 focus bridge remains the only scene-level update
  path.
- The runtime texture path is
  `res://assets/environment/boss2_arena/boss2_echo_guardian_arena_frame.png`.
- Source prompt metadata is stored at
  `assets/generated/source/boss2_echo_guardian_arena_frame_imagegen_20260630.json`.

## Test Evidence

**Required evidence**:

- `tests/unit/gameplay/boss2_hud_hit_feedback_arena_visual_runtime_test.gd`
- Related Boss2 regressions for HUD focus, arena reset, autonomous pressure,
  telegraph strike, and Double Jump payoff
- Headless main-scene smoke
- Godot MCP runtime evidence under
  `production/qa/evidence/boss2-hud-hit-feedback-arena-visual-runtime-2026-06-30.md`

**Status**: [x] RED/GREEN focused evidence, related regression, import,
headless smoke, and MCP runtime evidence complete.

- RED focused: `reports/report_831/` failed as expected because
  `Boss2ArenaFrame` did not exist.
- Godot import: `/opt/homebrew/bin/godot --headless --path . --import --quit`
  exited `0` and imported the runtime/source PNG files.
- GREEN focused: `reports/report_832/` passed Story028 `2/2`.
- Final focused after MCP warning cleanup: `reports/report_838/` passed
  Story028 `2/2`.
- Related regressions: Boss2 HUD focus `reports/report_833/` `4/4`, Boss2
  arena bounds/reset `reports/report_834/` `5/5`, Boss2 autonomous pressure
  `reports/report_835/` `6/6`, Boss2 telegraph strike `reports/report_836/`
  `4/4`, and Boss2 Double Jump payoff `reports/report_837/` `3/3`.
- Headless smoke:
  `reports/boss2_hud_hit_feedback_arena_visual_runtime_main_scene_smoke.log`.
- Godot MCP evidence:
  `production/qa/evidence/boss2-hud-hit-feedback-arena-visual-runtime-2026-06-30.md`.
- MCP runtime screenshot:
  `reports/visual/cinderpaw-mcp-boss2-hud-hit-feedback-arena-visual-20260630.png`.

## Test-Criterion Traceability

| Criterion | Test / Evidence | Status |
|-----------|-----------------|--------|
| `Boss2ArenaFrame` uses dedicated runtime texture | `report_831`, `report_832`, `report_838`, MCP probe | COVERED |
| Runtime PNG/import/source metadata documented | Import, asset manifest, QA evidence | COVERED |
| Arena frame does not affect collision/reward/reset behavior | `report_834`, `report_837`, MCP probe | COVERED |
| Boss2 damage triggers HUD hit flash without losing focus | `report_832`, `report_838`, `report_833`, MCP probe | COVERED |
| Deterministic HUD flash diagnostics exist | `report_832`, `report_838`, MCP probe | COVERED |
| Runtime scene, logs, and screenshot verified through MCP | Headless smoke; QA evidence | COVERED |

## Completion Notes

**Completed**: 2026-06-30
**Criteria**: 6/6 passing
**Deviations**: None.
**QA Evidence**:
`production/qa/evidence/boss2-hud-hit-feedback-arena-visual-runtime-2026-06-30.md`
