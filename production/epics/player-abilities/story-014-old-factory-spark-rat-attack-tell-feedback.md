# Story 014: Old Factory Spark Rat Attack Tell Feedback

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Core / Feature / Gameplay Runtime / Visual Integration
> **Type**: Integration + Gameplay Runtime + Visual/Feel
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-26

## Context

**GDD**: `design/gdd/player-abilities.md`,
`design/gdd/exploration-ability-gating.md`,
`design/gdd/feline-combat.md`

**Requirements**: `TR-combat-001`, `TR-ai-007`, `TR-scene-004`

**ADR Governing Implementation**: ADR-0004 Collision architecture; ADR-0005
Combat state machine; ADR-0007 Scene management; ADR-0018 Player abilities.

Story013 added a visible image-generated `FactorySparkRat`, but its attack
startup still shares the same `attack` animation as the active bite. This story
adds a distinct generated `attack_tell` frame animation so the Old Factory
patrol encounter has a readable ACT windup instead of an abrupt bite.

## Acceptance Criteria

- [x] Add generated transparent PNG frames under
  `assets/characters/factory_spark_rat/attack_tell/` with continuous naming and
  consistent `96x96` frame size.
- [x] Preserve image-generation source, alpha source, and preview files under
  `assets/characters/factory_spark_rat/source/`.
- [x] Extend
  `assets/characters/factory_spark_rat/factory_spark_rat_sprite_frames.tres`
  with a non-looping `attack_tell` animation containing at least 3 frames.
- [x] `FactorySparkRat.request_attack()` plays `attack_tell` during startup,
  then switches to the existing `attack` animation once active frames begin.
- [x] The attack metadata and damage contract from Story013 remain unchanged:
  `factory_spark_rat_bite`, source `factory_spark_rat`, and 9 base damage.
- [x] No visible `ColorRect`, `Polygon2D`, or single-frame placeholder is used
  for the attack tell state.
- [x] Focused RED/GREEN tests, related Old Factory regression, Godot import,
  headless smoke, and Godot MCP runtime screenshot/log evidence are recorded.

## Out of Scope

- Boss2, hidden boss, new rooms, savepoints, minimap, skill-tree UI, patrol
  spline tooling, NavigationAgent2D, dodge-counter windows, new enemy families,
  loot/economy changes, or full Spark Rat AI redesign.
- Replacing existing `idle`, `run`, `attack`, `hurt`, or `death` frames.
- Required SFX, shaders, camera cuts, or final authored art.

## Implementation Notes

- Follow AGENTS.md frame-animation rules: `AnimatedSprite2D + SpriteFrames`,
  transparent PNGs, same size and anchor, continuous naming.
- Keep the shared Rat Minion attack phases. Add an overridable startup animation
  hook rather than duplicating the whole enemy FSM.
- This is a player-readability slice: the important runtime proof is that
  startup uses `attack_tell` and active bite uses `attack`.

## Test Evidence

**Required evidence**:

- `tests/unit/gameplay/old_factory_spark_rat_attack_tell_feedback_test.gd`
- `tests/unit/gameplay/old_factory_spark_rat_patrol_encounter_test.gd`
- `tests/unit/gameplay/old_factory_deep_route_unlock_feedback_test.gd`
- Godot MCP runtime evidence under
  `production/qa/evidence/old-factory-spark-rat-attack-tell-feedback-2026-06-26.md`

**Status**: [x] Complete.
