# Story 020: Cat Claw Combo Finisher Impact Feedback

> **Epic**: Combat Presentation
> **Status**: Complete
> **Layer**: Presentation / Gameplay Integration
> **Type**: Visual/Feel
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-15

## Context

**GDD**: `design/gdd/combat-presentation.md`,
`design/gdd/feline-combat.md`

**Requirements**: `TR-combatfx-001`, `TR-combatfx-002`,
`TR-combatfx-003`, `TR-combatfx-005`, `TR-combatfx-007`

**ADR Governing Implementation**: ADR-0001 scene ownership; ADR-0002 signal
communication; ADR-0016 weapon-style metadata.

Player Abilities Story167 completed the authored `4/4/4`, `6/6/6`, and
`10/10/10` light-attack hitbox windows and already carries `weapon_id`,
`attack_type`, `combo_index`, and `combo_stage` through the real Main hit event.
`CombatPresentation` still treats the confirmed third hit as a normal hit, so
the GDD finisher anchor lacks its dedicated impact profile.

## Acceptance Criteria

- [x] Only a confirmed Cat Claw light hit with `combo_index=2` or
  `combo_stage=2` triggers the finisher profile; earlier hits, other weapons,
  heavy attacks, and whiffs keep their existing behavior.
- [x] The baseline third hit preserves `18` final damage, `+12` cat energy,
  one-target duplicate suppression, `attack_3` contact frame, and the authored
  `10/10/10` timing window.
- [x] A non-critical finisher requests `5` hitstop frames and `4px` shake for
  `5` frames. Existing same-frame maximum rules remain intact.
- [x] The confirmed finisher keeps exactly one damage number but overrides its
  presentation to gold `#F59E0B` at `28px`, without raising gameplay damage.
- [x] Existing hit-spark texture and count are reused at `1.5x` scale, and one
  gold `终结` label appears above the contact point. No new bitmap asset is
  generated for this runtime-label/VFX specialization.
- [x] A simultaneous critical finisher retains the stronger critical profile:
  at least `6` hitstop frames, `5px` shake, cat-eye gold `#ECC94B`, and the
  existing critical particle count.
- [x] Focused RED/GREEN, the smallest related combat regressions, and one Godot
  MCP Main run verify the real third-hit path, visible contact feedback,
  non-empty screenshot, and clean game/editor logs.

## Out of Scope

- Changing damage formulas, cat-energy values, combo timing, hitbox timing,
  animation frames, input windows, or audio pitch.
- Implementing real gameplay-wide time freezing. The current hitstop counter
  becoming an actual pause with buffered input is the next dedicated Story.
- Renaming or regenerating existing combat VFX textures.

## Required Evidence

- `tests/unit/gameplay/main_scene_cat_claw_combo_finisher_feedback_test.gd`
- Existing `tests/unit/presentation/combat_presentation_test.gd`
- Existing Story167 authored timing and Main attack-chain regressions
- Godot MCP evidence under `production/qa/evidence/`

## Test Evidence

- Expected RED: `reports/report_1732/results.xml`, `1` case with `6` expected
  feedback failures while the real third-hit damage and energy path passed.
- Focused GREEN: `reports/report_1733/results.xml`, `1/1` passing.
- Presentation and critical-priority GREEN: `reports/report_1734/results.xml`,
  `35/35` passing across the new Main acceptance and CombatPresentation suite.
- Bounded combo/Main regression: `reports/report_1735/results.xml`, `9/9`
  passing across Story167 timing, real-input chaining, and Main attack routing.
- Godot MCP `3.0.2` run `r62054889-14` verified the live Main third-hit event,
  exact feedback values, visible runtime nodes, non-empty screenshot, three
  info-only game rows, zero editor errors, and clean stop to `ready`.
- Full suite was not run and no equivalent test was repeated after documentation.

## Completion Notes

**Completed**: 2026-07-15

**Criteria**: 7/7 passing

**Assets**: No new bitmap or audio asset. Existing hit-spark and Cat Claw
animation resources are reused through runtime Presentation specialization.

**QA Evidence**:
`production/qa/evidence/cat-claw-combo-finisher-impact-feedback-2026-07-15.md`
