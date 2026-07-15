# Story 019: Boss Phase Overlay Readability

> **Epic**: Combat Presentation
> **Status**: Complete
> **Layer**: Presentation
> **Type**: Visual/Feel + Runtime Integration
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-14

## Context

**GDD**: `design/gdd/combat-presentation.md`, `design/gdd/hud-ui.md`

**Requirements**: `TR-combatfx-001`, `TR-combatfx-002`,
`TR-combatfx-003`, `TR-combatfx-007`

**ADR Governing Implementation**: ADR-0001 autoload architecture; ADR-0002
signal communication.

Story010 established the textured Boss phase overlay and the required 32 metal
debris pieces, but the original full-screen image kept an opaque focal mass over
the combat center for the entire `1.5s` debris lifetime. Player Abilities
Story163 verified the Crown Warden Phase II state transition and explicitly
deferred overlay composition and lifetime to this Presentation Story.

## Acceptance Criteria

- [x] Runtime uses a dedicated image-generated edge overlay at
  `res://assets/generated/combat_boss_phase_overlay_readable.png`; the middle
  `50% x 50%` rectangle is fully transparent at pixel level.
- [x] One `TextureRect` named `BossPhaseOverlay` is mounted under one
  `CanvasLayer` named `BossPhaseOverlayLayer`, ignores mouse input, and remains
  below the arena HUD. Its runtime rect starts at `(0, 0)`, exactly matches the
  `1280x720` viewport/texture, and uses full-rect anchors with zero offsets.
- [x] The overlay performs one deterministic linear fade and is removed at
  `0.40s`; the existing 32 metal debris pieces remain active for `1.50s`.
- [x] Boss phase logic, hitstop, shake, invulnerability, HUD state, audio routing,
  particle budget, and debris behavior are not reopened by this Story.
- [x] Focused RED/GREEN, bounded Presentation/Boss regressions, target smoke,
  and Godot MCP 3.0.2 verify import, timing, node contract, visible gameplay,
  non-empty screenshot, and clean logs.

## Out Of Scope

- Changing Crown Warden Phase II state logic, Boss damage, attacks, balance,
  animation state, audio, arena layout, or reward flow.
- Replacing the existing debris texture or changing the `30+ / 1.5s` GDD
  debris contract.
- Adding another overlay layer, shader pass, cutscene framework, or persistent
  runtime resource.

## Implementation Notes

- Keep the original Story010 overlay and retained source for historical audit;
  only the runtime texture path moves to the readable replacement.
- Put authored fragments in the outer border and hard-clear
  `Rect2i(320, 180, 640, 360)` after normalizing the image to `1280x720`.
- Advance opacity through `CombatPresentation.advance_time()` rather than a
  Tween so focused tests and MCP can inspect exact `0.39s` and `0.41s`
  boundaries.
- Use CanvasLayer `0`; Crown Warden arena HUD remains CanvasLayer `1`, so health,
  Phase II text, player status, currency, and weapon state stay readable.
- With `PRESET_FULL_RECT`, keep all four offsets at `0`. Positive right/bottom
  offsets add to the parent size and crop this cover-stretched texture.

## Test Evidence

- `tests/unit/presentation/boss_phase_overlay_readability_test.gd`
- `tests/unit/presentation/combat_presentation_test.gd`
- `tests/unit/gameplay/rat_king_boss_runtime_contract_test.gd`
- `tests/unit/gameplay/crown_warden_phase_two_transition_feedback_test.gd`
- `tests/smoke/crown_warden_phase_two_transition_feedback_smoke.gd`

**Status**: [x] Complete.

- Expected RED: `reports/report_1690/results.xml`, `1` case with `2` expected
  missing-asset/API failures.
- Rejected pass: `reports/report_1691/results.xml` reported `1/1`, but emitted a
  ResourceLoader error before the new PNG had completed Godot import; it is not
  completion evidence.
- Focused GREEN after import: `reports/report_1692/results.xml`, `1/1` passing.
- Bounded related GREEN: `reports/report_1693/results.xml`, `40/40` passing.
- Target smoke exited `0` and printed
  `crown_warden_phase_two_transition_feedback_smoke=passed`.
- Godot MCP `3.0.2` run `r22854-1` remains valid for the real Crown Warden Phase
  II transition, HUD ordering, three-frame player/Boss animations and exact
  fade/debris boundaries. Its screenshot is rejected for layout acceptance:
  full-rect anchors plus positive `1280x720` offsets produced a `2560x1440`
  runtime rect and cropped the right/bottom frame.
- Layout repair RED `reports/report_1698/results.xml` reproduced that exact
  `2560x1440` defect. Focused GREEN `reports/report_1699/results.xml` passed
  `1/1`; bounded related GREEN `reports/report_1700/results.xml` passed `39/39`.
- Final Godot MCP `3.0.2` run `r7097860-5` used the real Main Rat King Phase II
  signal path and verified position `(0, 0)`, rect/texture/viewport `1280x720`,
  full-rect anchors, four zero offsets, overlay/debris `1/32`, player/Boss/HUD
  visibility, a non-empty four-edge screenshot, three info-only game logs, zero
  editor logs, and clean stop to `ready`.

## Completion Notes

**Completed**: 2026-07-14
**Criteria**: 5/5 passing
**Assets**: One image-generated keyed source, one alpha intermediate, and one
Godot-imported `1280x720` runtime PNG.
**Asset Spec**: `design/assets/specs/boss-phase-overlay-readability.md`
**QA Evidence**:
`production/qa/evidence/boss-phase-overlay-readability-2026-07-14.md`
