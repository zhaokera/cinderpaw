# Story 025: Boss2 Run Frame Animation Runtime

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Core / Feature / AI Runtime / Visual Integration
> **Type**: Integration + Gameplay Runtime + Visual/Feel
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-30

## Context

**GDD**: `design/gdd/ai-framework.md`, `design/gdd/feline-combat.md`,
`design/gdd/boss-config.md`, `design/gdd/player-abilities.md`

**Requirements**: `TR-ai-001`, `TR-ai-007`, `TR-ai-008`,
`TR-ability-005`

**ADR Governing Implementation**: ADR-0002 Signal communication; ADR-0004
Collision detection; ADR-0005 Combat state machine; ADR-0006 AI behavior
system architecture; ADR-0007 Scene management; ADR-0018 Player abilities;
ADR-0021 Save system architecture.

Story024 made Boss2 actively chase the player, but the chase state still uses
the existing `idle` animation as a temporary visual. This makes the encounter
read as a sliding placeholder instead of a horizontal ACT boss that is charging
the player.

This story adds the smallest player-visible animation polish for that behavior:
generated Boss2 `run` frames, a looped `run` SpriteFrames animation, and runtime
logic that plays `run` while `behavior_phase="chase"` and returns to `attack`
when startup begins.

## Acceptance Criteria

- [x] Add image-generated transparent PNG frames under
  `assets/characters/boss2_echo_guardian/run/` with continuous naming,
  consistent `160x128` frame size, transparent background, and no single-frame
  placeholder.
- [x] Preserve the image-generation source strip and alpha-matted source under
  `assets/characters/boss2_echo_guardian/source/`.
- [x] Extend
  `assets/characters/boss2_echo_guardian/boss2_echo_guardian_sprite_frames.tres`
  with a looped `run` animation containing at least 3 frames without regressing
  `idle`, `attack`, `hurt`, or `death`.
- [x] From the current `res://scenes/main.tscn` placement, Boss2's chase
  behavior keeps `behavior_phase="chase"` and plays the `run` animation while it
  closes distance.
- [x] Once Boss2 reaches startup, the sprite switches back to the existing
  `attack` animation and `boss2_echo_swipe` remains inactive until active
  frames.
- [x] Defeated, restored-defeated, and stale-target paths do not leave Boss2
  stuck in `run`.
- [x] Update asset manifest, entity inventory, QA evidence, and Story/Epic
  tracking with the generated prompt, source paths, runtime frame paths, and
  verification evidence.
- [x] Focused RED/GREEN tests, related Boss2 regression, Godot import/headless
  smoke, and Godot MCP runtime screenshot/log evidence are recorded.

## Out of Scope

- Boss2 arena bounds, multi-phase AI, new attack patterns, navigation/pathing,
  wall avoidance, or final balancing.
- Boss portrait, HP-bar art polish, cutscene/camera polish, authored music/SFX,
  shaders, or new UI.
- Replacing existing Boss2 `idle`, `attack`, `hurt`, or `death` frames.

## Implementation Notes

- Keep the gameplay behavior scene-local to `Boss2EchoGuardian`.
- Use `run` as the animation resource name. The AI diagnostic phase remains
  `chase` because that is the behavior state, not the art asset name.
- Do not restart `run` every frame; `_play_animation()` should let the loop
  advance while the current animation is already `run`.
- Follow AGENTS.md frame-animation rules: `AnimatedSprite2D + SpriteFrames`,
  transparent PNGs, same size and anchor, continuous naming, image-generation
  source retained, and MCP runtime validation.

## Test Evidence

**Required evidence**:

- `tests/unit/gameplay/boss2_autonomous_pressure_runtime_test.gd`
- `tests/unit/gameplay/boss2_double_jump_payoff_runtime_test.gd`
- `tests/unit/gameplay/boss2_echo_guardian_telegraph_strike_test.gd`
- `tests/unit/gameplay/boss2_hud_focus_runtime_test.gd`
- Godot MCP runtime evidence under
  `production/qa/evidence/boss2-run-frame-animation-runtime-2026-06-30.md`

**Status**: [x] Complete.

## Test-Criterion Traceability

| Criterion | Test / Evidence | Status |
|-----------|-----------------|--------|
| Generated 160x128 transparent `run` frames | `boss2_double_jump_payoff_runtime_test`; PNG alpha/size check; asset manifest | PASS |
| Source and alpha source preserved | QA evidence; `assets/characters/boss2_echo_guardian/source/` | PASS |
| SpriteFrames looped `run` animation with old animations intact | `boss2_double_jump_payoff_runtime_test`; MCP probe | PASS |
| Main-scene chase plays `run` while closing distance | `boss2_autonomous_pressure_runtime_test`; MCP probe | PASS |
| Startup returns to `attack` with inactive hitbox | `boss2_autonomous_pressure_runtime_test`; Story022 regression; MCP probe | PASS |
| Defeated/stale-target paths do not remain in `run` | `boss2_autonomous_pressure_runtime_test`; MCP probe | PASS |
| Manifest, inventory, QA evidence, Story/Epic tracking updated | Documentation diff | PASS |
| Focused/related tests, import, smoke, MCP evidence recorded | QA evidence | PASS |

## Implementation Summary

Boss2 Echo Guardian now has an image-generated 3-frame `run` animation. The
source strip is preserved at
`assets/characters/boss2_echo_guardian/source/boss2_echo_guardian_run_sheet_imagegen_20260626.png`,
alpha-matted at
`assets/characters/boss2_echo_guardian/source/boss2_echo_guardian_run_sheet_alpha_20260626.png`,
and sliced into transparent 160x128 runtime frames under
`assets/characters/boss2_echo_guardian/run/`.

`boss2_echo_guardian_sprite_frames.tres` now includes a looped `run` animation
at speed `9.0` without changing the existing `idle`, `attack`, `hurt`, or
`death` frame sets. `Boss2EchoGuardian` plays `run` while
`behavior_phase="chase"` and keeps `attack` for startup/active/recovery. The
animation helper no longer restarts an already-playing animation every frame, so
the run loop can advance during sustained chase.

## Verification Summary

- RED focused: `reports/report_791/`
  - Expected failures: Boss2 chase still played `idle`, and SpriteFrames lacked
    the `run` animation.
- Godot import: `godot --headless --path . --import --quit` exited `0` and
  imported the new `run` frames plus source/alpha images.
- GREEN focused: `reports/report_796/`
  - Story024/025 Boss2 autonomous pressure and run animation: `6/6`,
    including sustained chase frame advancement.
- GREEN Boss2 asset/payoff regression: `reports/report_798/`
  - Story021 frame-animation and reward path: `3/3`.
- GREEN related regressions:
  - Story023 HUD focus: `reports/report_797/` `4/4`.
  - Story022 telegraph strike rerun: `reports/report_799/` `4/4`.
- Headless smoke:
  `reports/boss2_run_frame_animation_runtime_main_scene_smoke.log`
  exited `0`; keyword scan found no script, parse, invalid-call, missing
  resource, or resource-load errors.
- Godot MCP runtime with `autosave=false` confirmed
  `/Main/Boss2EchoGuardian/Sprite` is an `AnimatedSprite2D`, SpriteFrames path
  is `res://assets/characters/boss2_echo_guardian/boss2_echo_guardian_sprite_frames.tres`,
  `run` has 3 frames from `assets/characters/boss2_echo_guardian/run/` at
  `160x128`, chase changes distance by `-3px` and plays `run`, an already
  advanced run frame (`frame=1`, `frame_progress=0.25`) is preserved through 25
  deterministic chase frames instead of being reset to frame `0`, startup
  returns to `attack` with inactive `boss2_echo_swipe`, active hit damages
  Player `100 -> 86` once, defeated flag hides Boss2 and leaves `death` rather
  than `run`, game log has only helper/DataManager info, editor log is empty,
  and screenshot
  `reports/visual/cinderpaw-mcp-boss2-run-frame-animation-runtime-20260626.png`
  is nonblank.
