# Story 013: Old Factory Spark Rat Patrol Encounter

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Core / Feature / Gameplay Runtime / Visual Integration
> **Type**: Integration + Gameplay Runtime + Visual/Feel
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-26

## Context

**GDD**: `design/gdd/player-abilities.md`,
`design/gdd/exploration-ability-gating.md`,
`design/gdd/scene-management.md`, `design/gdd/feline-combat.md`

**Requirements**: `TR-combat-001`, `TR-ai-001`, `TR-ai-007`,
`TR-explore-003`, `TR-scene-004`

**ADR Governing Implementation**: ADR-0004 Collision architecture; ADR-0007
Scene management; ADR-0018 Player abilities; ADR-0021 Save system
architecture.

Stories007-012 made the Old Factory route playable but still leans on reused
Rat Minion instances. This story adds a distinct image-generated enemy family
to make the deep route feel like authored ACT content instead of placeholder
boxes or repeated guards.

## Acceptance Criteria

- [x] Add a new `FactorySparkRat` visible enemy family using
  `AnimatedSprite2D` + `SpriteFrames`, with generated transparent PNG frame
  assets under `assets/characters/factory_spark_rat/<animation>/`.
- [x] Create `scenes/characters/factory_spark_rat.tscn` and
  `src/characters/factory_spark_rat.gd`, and mount that character scene through
  a gameplay enemy scene in the Old Factory route.
- [x] The spark rat exposes at least `idle`, `run`, `attack`, `hurt`, and
  `death` gameplay-state animations with at least 3 frames each.
- [x] The Old Factory scene keeps the spark rat visible but inactive until the
  deep route endpoint has been opened; activation restores target, process,
  physics, and enemy collision.
- [x] Player attack routing can damage and defeat the spark rat by deterministic
  entity id, and defeating it records `factory_spark_rat_defeated=true` in
  scene-local state.
- [x] Restoring local state with `factory_spark_rat_defeated=true` hides and
  disables the spark rat without replaying endpoint unlock feedback.
- [x] Diagnostics expose spark-rat presence, entity id, active/defeated state,
  frame counts, sprite frames path, and runtime position for GdUnit and MCP.
- [x] Focused RED/GREEN tests, related Old Factory regression, Godot import,
  headless smoke, and Godot MCP runtime screenshot/log evidence are recorded.

## Out of Scope

- Boss2, hidden-boss combat, full multi-room Old Factory layout, savepoints,
  minimap, skill-tree UI, new player abilities, or SceneManager architecture
  rewrites.
- Complex pathfinding, patrol spline tooling, NavigationAgent2D, loot tables,
  economy balancing, authored final-art replacement, shaders, or SFX expansion.
- Cross-process SaveSystem schema changes; this story uses ADR-0007 scene-local
  state only.

## Implementation Notes

- Reuse the existing Rat Minion gameplay contract where practical, but the
  visible character resource must be a new `factory_spark_rat` character scene
  and SpriteFrames pack.
- Keep collision/hit routing compatible with ADR-0004 and the existing
  `OldFactoryEntranceScene.apply_damage(...)` adapter.
- Do not activate the spark rat before the deep route endpoint opens; this keeps
  encounter pacing readable and avoids turning the single room into a three-enemy
  pileup.
- Preserve image-generation source, alpha/intermediate files, runtime PNGs,
  prompts, and import status in the asset manifest and QA evidence.

## Test Evidence

**Required evidence**:

- `tests/unit/gameplay/old_factory_spark_rat_patrol_encounter_test.gd`
- `tests/unit/gameplay/old_factory_deep_route_unlock_feedback_test.gd`
- `tests/unit/gameplay/old_factory_deep_guard_activation_pacing_test.gd`
- `tests/unit/gameplay/old_factory_deep_route_micro_slice_runtime_test.gd`
- Godot MCP runtime evidence under
  `production/qa/evidence/old-factory-spark-rat-patrol-encounter-2026-06-26.md`

**Status**: [x] Recorded in
`production/qa/evidence/old-factory-spark-rat-patrol-encounter-2026-06-26.md`.

## Completion Notes

**Completed**: 2026-06-26
**Criteria**: 8/8 passing
**Deviations**: Factory Spark Rat uses 96x96 runtime frames to match the current
implemented Cinderpaw/Rat Minion small-character pipeline. The Art Bible's
older 64x64 base-frame note remains a future normalization item, not a blocker
for this Story.
**QA Evidence**:
`production/qa/evidence/old-factory-spark-rat-patrol-encounter-2026-06-26.md`
