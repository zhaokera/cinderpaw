# Story 154: Main Scene Low-HP Focus Activation Feedback

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Core Signal / Presentation / Audio Integration
> **Type**: Integration + Visual/Feel + Audio
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-14

## Context

**GDD**: `design/gdd/health-death.md`, `design/gdd/combat-presentation.md`,
`design/gdd/audio-system.md`

**Requirements**: `TR-health-007`, `TR-health-008`, `TR-combatfx-009`,
`TR-audio-006`

**ADR Governing Implementation**: ADR-0002 signal communication; ADR-0010
audio system; ADR-0013 pixel-art rendering; ADR-0015 accessibility; ADR-0019
HealthComponent.

HealthComponent already owns the approved `25%` combat-gated entry and `28%`
exit hysteresis, and Main already forwards its transition to CombatPresentation
and AudioSystem. AI windup extension, focus crit-window bonus, reduced shake,
low-HP damage audio and the imported activation cue are implemented. The
remaining player-visible gap is `TR-health-007`: entering focus mode does not
show the required one-shot cat-eye-gold screen-edge flash, so the player lacks
the visual anchor that explains the subsequent perception changes.

## Acceptance Criteria

- [x] A fresh `on_focus_mode_changed(true)` creates exactly one stable-named
  `FocusModeActivationOverlay` `TextureRect` under CombatPresentation.
- [x] The overlay uses the new image-generated transparent
  `combat_focus_mode_edge_flash_overlay.png`, fills the authored `1280x720`
  viewport, leaves the center readable, ignores mouse input and renders above
  gameplay without changing HUD layout.
- [x] The transition reads `edge_flash_color` and `edge_flash_duration_sec`
  from Health metadata, defaults to cat-eye gold `#ECC94B` and `0.3s`, starts
  at full alpha, fades deterministically and is absent at exactly `0.3s`.
- [x] `on_focus_mode_changed(false)` updates focus/shake state but creates no
  activation overlay. A later genuine false-to-true transition may show one
  new overlay; duplicate calls do not accumulate stale overlays.
- [x] Main's real Player Health transition at `25/100 HP` with an active enemy
  reaches the overlay and routes one existing `sfx_focus_mode_activate` cue;
  Health thresholds, AI windup, crit window, damage audio and save schema stay
  unchanged.
- [x] Focused GdUnit, bounded Health/Presentation/Main/audio regression, target
  smoke and Godot MCP verify the real Main transition, texture/node/lifecycle,
  audible cue diagnostics, non-empty screenshot and clean logs.

## Out of Scope

- Changing focus thresholds, hysteresis, active-enemy ownership, AI windup,
  crit windows, screen-shake scaling or low-HP damage reverb.
- Implementing the longer-lived background-particle reduction, dark vignette
  or attack-tell area expansion; those are separate `TR-health-008` consumers.
- Replacing the existing activation WAV, changing HP-bar colors, adding text,
  pausing gameplay or introducing a second focus-mode state owner.

## Implementation Notes

- CombatPresentation remains the visual owner and consumes signal metadata;
  HealthComponent and Main do not reference the generated texture.
- Use `advance_time()` for deterministic lifetime/alpha rather than a second
  process owner or an untestable Tween-only lifecycle.
- Retain the image-generation source and alpha intermediate, import the exact
  transparent runtime PNG through Godot and record all paths in the manifest.

## Test Evidence

**Required evidence**:

- `tests/unit/gameplay/main_scene_focus_mode_activation_feedback_test.gd`
- Existing focus-mode Health, CombatPresentation, Main audio and AudioSystem tests
- `tests/smoke/main_scene_focus_mode_activation_feedback_smoke.gd`
- Godot MCP evidence under
  `production/qa/evidence/main-scene-low-hp-focus-activation-feedback-2026-07-14.md`

**Status**: [x] Complete.

- RED `reports/report_1604/results.xml`: the single acceptance case produced
  two expected failures before the overlay diagnostics APIs existed.
- Focused GREEN `reports/report_1607/results.xml`: `1/1`, zero errors or
  failures.
- Bounded related GREEN `reports/report_1610/results.xml`: `75/75` across the
  new Main acceptance, CombatPresentation, Health focus, AudioSystem and Main
  audio adapter suites. Target smoke exited `0` with
  `main_scene_focus_mode_activation_feedback_smoke=passed`.
- Godot `4.7-stable` / MCP `2.9.2` final run `r15524895-16` verified the real
  Main transition, generated `TextureRect`, existing activation cue, exact
  `1.0 -> 0.5 -> 0.0` alpha lifecycle and clean game/editor logs. Screenshot:
  `reports/visual/cinderpaw-mcp-main-scene-low-hp-focus-activation-feedback-20260714.png`.
