# Story 010: Boss Phase Visual Feedback

> **Epic**: Combat Presentation
> **Status**: Complete
> **Layer**: Presentation
> **Type**: Visual/Feel
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-24

## Context

**GDD**: `design/gdd/combat-presentation.md`
**Requirements**: `TR-combatfx-006`, `TR-combatfx-010`
**ADR Governing Implementation**: ADR-0002: Signal communication

Story 009 added the presentation-facing boss transition-start signal from
BossConfigComponent. Combat Presentation still needs to consume that signal and
turn phase changes into readable visual feedback instead of leaving the boss as
another static block-state transition.

## Acceptance Criteria

- [x] `CombatPresentation.on_boss_phase_transition_started(entity_id, phase, metadata)` plays 4 frames of hitstop and phase-specific screen shake without changing the BossConfig signal signature.
- [x] The transition spawns a textured full-screen overlay using image-generated art, not a `ColorRect` or the PERFECT parry flash asset.
- [x] The transition spawns at least 30 textured steel-blue metal debris sprites and keeps them alive for 1.5 seconds before cleanup.
- [x] CombatPresentation records the last boss phase entity id, phase id, and duplicated metadata for HUD/audio/debug consumers.
- [x] MainScene exposes a safe registration method for a BossConfig-style source signal and forwards `on_boss_phase_transition_started(entity_id, phase, metadata)` to CombatPresentation.
- [x] Godot MCP runs `res://scenes/main.tscn`, triggers a phase transition probe, checks clean logs, and captures a nonblank screenshot showing the phase overlay/debris.

## Visual Direction

Use the "mechanical rat king rebuild shockwave" direction: steel-blue-gray metal
shards, dark charcoal vignette pressure, signal-red overload cracks, and sparse
cat-eye gold highlights. The effect should read as boss danger and phase
rebuild, not a victory flash or PERFECT parry white flash.

## Out of Scope

- Full BossConfig node instantiation inside `scenes/main.tscn`.
- Boss audio, HUD phase banner animation, or new boss AI pattern scheduling.
- New character frame animations.

## Test Evidence

**Required evidence**:
- `tests/unit/presentation/combat_presentation_test.gd`
- `tests/unit/gameplay/main_scene_visual_contract_test.gd`

**Status**: [x] RED/GREEN + MCP runtime evidence complete

**Evidence**:

- RED: `reports/report_361/` failed because CombatPresentation lacked the Boss
  phase transition presentation API and MainScene lacked the BossConfig-style
  signal source registration method.
- GREEN: `reports/report_368/` passed focused CombatPresentation/MainScene
  visual contract tests `22/22`.
- Regression: `reports/report_369/` passed presentation, Boss Story009 signal
  contract, MainScene attack/dodge, and Player/Enemy frame-animation suites
  `52/52`.
- Headless smoke: `reports/boss_phase_visual_feedback_main_scene_smoke.log`
  exited `0`; log scan found no error or warning matches.
- Godot MCP: ran `res://scenes/main.tscn`, registered a temporary real
  BossConfigComponent as the phase transition source, emitted phase `2`, and
  observed `1` textured overlay, `32` textured debris sprites, `0`
  presentation `ColorRect` nodes, Player/Enemy `AnimatedSprite2D` instances,
  clean game/editor logs, and screenshot
  `reports/visual/cinderpaw-mcp-boss-phase-visual-feedback-20260624.png`.
- QA evidence:
  `production/qa/evidence/boss-phase-visual-feedback-2026-06-24.md`.

## Dependencies

- Depends on: Story 009 boss phase transition signal contract.
- Unlocks: boss phase audio/HUD feedback and later real BossConfig scene wiring.

## Completion Notes

**Completed**: 2026-06-24
**Criteria**: 6/6 passing
**Deviations**: This story uses a MainScene registration API and runtime MCP
probe instead of adding a persistent BossConfig node to `scenes/main.tscn`.
The persistent BossConfig/Health/AI scene integration remains a follow-up
because the current Shadow Beast runtime enemy does not yet own BossConfig
phase thresholds.
