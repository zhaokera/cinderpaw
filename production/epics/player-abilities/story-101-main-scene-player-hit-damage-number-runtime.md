# Story 101: Main Scene Player Hit Damage Number Runtime

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Core / Feature / Gameplay Runtime / Presentation Integration
> **Type**: Integration + Visual/Feel
> **Estimate**: XS
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-09

## Context

**GDD**: `design/gdd/feline-combat.md`,
`design/gdd/damage-calculation.md`, `design/gdd/combat-presentation.md`,
`design/gdd/hud-ui.md`

**Requirements**: `TR-combat-001`, `TR-damage-001`, `TR-presentation-001`,
`TR-hud-002`

**ADR Governing Implementation**: ADR-0002 Signal Communication; ADR-0004
Scene Tree Composition; ADR-0005 Combat State Machine; ADR-0018 Player
Abilities.

Combat Presentation Story008 already implemented damage-number styling,
tiers, float distance, lifetime, and the HUD opt-out path. Story101 closes the
runtime integration gap for the player-facing ACT loop by proving that a real
`Player.attack_landed -> MainScene._on_player_attack_landed ->
CombatPresentation.on_hit_event` hit produces a visible damage number whose
text matches the calculated `final_damage`.

## Acceptance Criteria

- [x] A valid player light attack hit in `scenes/main.tscn` creates exactly one
  active damage number in `CombatPresentation`.
- [x] The damage number text equals the hit metadata `final_damage`; it must not
  use base damage, a fixed placeholder, or an estimated value.
- [x] The first confirmed hit still reduces enemy HP, records the enemy
  `target_id`, records the equipped `weapon_id`, and increments
  `hits_landed` exactly once.
- [x] A duplicate detection pass for the same active hitbox does not apply extra
  damage and does not spawn an extra damage number.
- [x] Damage-number diagnostics expose text, visibility, z index, position,
  font size, outline size, 1px black shadow, 30px float distance, 1.5s
  lifetime, and active count for tests and Godot MCP runtime probes.
- [x] The active damage number expires through `CombatPresentation.advance_time`
  and leaves no stale active entry after its lifetime.
- [x] Existing combat-presentation behavior remains intact: hit sparks,
  hitstop, screen shake, weapon VFX, enemy attack damage numbers, and the HUD
  damage-number toggle continue to use the existing presentation path.
- [x] Godot MCP verifies `res://scenes/main.tscn` loads, `CombatPresentation`
  exists, a runtime player hit creates a visible damage number matching
  `final_damage`, logs have no new script/resource errors, and a non-empty
  screenshot shows the target area.

## Out of Scope

- New damage formulas, enemy HP tuning, hitbox behavior, AI, or weapon balance.
- New crit/parry legendary-number effects, audio, particles, shaders, HUD
  panels, or settings persistence.
- New image-generation assets. Story101 reuses the existing Label-based damage
  number presentation from Combat Presentation Story008.

## Implementation Notes

- The runtime path remains `MainScene._on_player_attack_landed()`, which enriches
  player hit metadata, applies the HUD `show_damage_number` setting, records
  `_last_player_hit_metadata`, and forwards the payload to
  `CombatPresentation.on_hit_event()`.
- `CombatPresentation.get_last_damage_number_snapshot()` is a diagnostics-only
  API for tests and MCP. It does not alter the damage-number animation or
  rendering path.
- No new visual assets were generated. Damage numbers are text Labels styled by
  GDD-tiered color, font size, outline, float distance, and lifetime.

## Test Evidence

**Required evidence**:

- `tests/unit/gameplay/main_scene_player_attack_core_chain_test.gd`
- `tests/unit/gameplay/main_scene_enemy_attack_core_chain_test.gd`
- `tests/unit/presentation/combat_presentation_test.gd`
- Headless main-scene smoke
- Godot MCP runtime evidence under
  `production/qa/evidence/main-scene-player-hit-damage-number-runtime-2026-07-09.md`

**Status**: [x] RED/GREEN focused evidence, related regression, headless smoke,
and MCP runtime evidence complete.

- RED focused: `reports/report_1257/` failed as expected because the new runtime
  contract required `CombatPresentation.get_last_damage_number_snapshot()`
  before that diagnostics API existed.
- Initial GREEN focused: `reports/report_1258/` passed `4/4` player attack
  core-chain tests after the diagnostics API landed.
- Final GREEN focused: `reports/report_1262/` passed `4/4` after the
  damage-number shadow readability enhancement.
- Related regression: `reports/report_1261/` passed player attack, enemy attack,
  and combat-presentation damage-number coverage `38/38`.
- Headless smoke: `reports/main_scene_damage_number_runtime_smoke.log` exited
  `0` with no project script/parse/invalid-call/access/missing-resource/resource
  load errors by keyword scan.
- Godot MCP evidence:
  `production/qa/evidence/main-scene-player-hit-damage-number-runtime-2026-07-09.md`.

## Test-Criterion Traceability

| Criterion | Test / Evidence | Status |
|-----------|-----------------|--------|
| Player hit creates one visible damage number | `report_1262`, MCP probe | COVERED |
| Damage-number text equals `final_damage` | `report_1262`, MCP probe | COVERED |
| Duplicate hitbox detection does not duplicate damage or numbers | `report_1262` | COVERED |
| Diagnostics expose visible Label contract, shadow, and lifetime | `report_1262`, MCP probe | COVERED |
| Existing presentation and enemy-hit paths remain intact | `report_1261` | COVERED |
| Runtime scene, logs, and screenshot verified through MCP | Headless smoke; QA evidence | COVERED |

## Completion Notes

**Completed**: 2026-07-09
**Criteria**: 8/8 passing
**Deviations**: No new bitmap assets were generated because Story101 closes a
runtime text-feedback integration gap and reuses the already implemented
Label-based damage-number renderer.
**QA Evidence**:
`production/qa/evidence/main-scene-player-hit-damage-number-runtime-2026-07-09.md`
