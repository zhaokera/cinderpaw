# Story 158: Main Scene Focus Mode Boss Attack Tell Amplification

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Presentation / Boss Runtime
> **Type**: Integration + Combat Readability + Generated Visual
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-14

## Context

**GDD**: `design/gdd/health-death.md`

**Requirements**: `TR-health-008`, Health & Death rule 8 item 2.

Story154 made focus activation visible and Story157 extended new Boss attack
startup by six frames. The GDD also requires the signal-red attack warning itself
to grow by `25%` and last `10%` longer during focus, which the Main Rat King and
Echo Guardian did not yet present.

## Acceptance Criteria

- [x] Rat King and Echo Guardian each own one stable-named `FocusAttackTell`
  `Sprite2D` behind their existing `AnimatedSprite2D` character.
- [x] Attacks started while focus is active freeze an exact `1.25` area
  multiplier and `1.10` duration multiplier: Rat King `15 -> 17` frames and
  Echo Guardian `8 -> 9` frames.
- [x] The warning stops after its own display duration even though Story157's
  extended startup remains in progress at `21` and `14` frames.
- [x] Character scale, attack hitbox, damage, active/recovery timing, attack
  selection and animation speed remain unchanged.
- [x] The shared warning asset is generated through built-in image generation,
  alpha-matted, imported through Godot 4.7 and recorded in the asset pipeline.
- [x] Focused RED/GREEN, bounded related regression, target smoke and one Godot
  MCP run verify node type, texture, multipliers, lifecycle, three-frame Boss
  attacks, non-empty screenshot and clean logs.

## Out Of Scope

- Applying the visual to every enemy scene or changing gameplay hitbox area.
- Rule 8 environment-particle reduction, edge treatment or low-frequency hurt
  audio.
- New Boss identity, attack pattern, damage tuning or animation frames.

## Implementation Notes

- `FocusAttackTell` owns only presentation state and deterministic frame
  countdown; each Boss remains the attack-state owner.
- Focus is sampled and frozen at attack start so an in-flight tell cannot resize
  or retime when focus later changes.
- Both Bosses share one generated open-center texture but retain authored base
  scales appropriate to their different character silhouettes.

## Test Evidence

- `tests/unit/gameplay/main_scene_focus_mode_boss_attack_tell_test.gd`
- `tests/smoke/main_scene_focus_mode_boss_attack_tell_smoke.gd`
- `production/qa/evidence/main-scene-focus-mode-boss-attack-tell-2026-07-14.md`
- `production/qa/evidence/main-scene-focus-mode-boss-attack-tell-mcp-run33.json`

**Status**: [x] Complete.

- Initial RED: `reports/report_1660/results.xml`, one case with three expected
  missing-contract failures.
- Refinement RED: `reports/report_1661/results.xml`, one case with three
  lifecycle failures that exposed Rat King's deterministic advance bypass.
- Focused GREEN: `reports/report_1662/results.xml`, `1/1` passed.
- Final bounded related GREEN: `reports/report_1663/results.xml`, `12/12`
  passed across Story158 and the directly related Boss/focus contracts.
- Target smoke exited `0` with
  `main_scene_focus_mode_boss_attack_tell_smoke=passed`.
- Godot `4.7-stable` / MCP plugin `2.9.2` run `r27682351-33` verified both
  visible warning nodes, exact timing/scale, lifecycle reset, three-frame
  attacks, a non-empty screenshot, three info-only game lines, zero editor
  lines and clean stop.
