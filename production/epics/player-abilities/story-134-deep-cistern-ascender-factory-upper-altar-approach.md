# Story 134: Deep Cistern Ascender Factory Upper Altar Approach

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Feature / Gameplay Runtime / Scene Management / Presentation
> **Type**: Integration + Traversal + Scene Handoff + Visual
> **Estimate**: M
> **Manifest Version**: 2026-07-11
> **Last Updated**: 2026-07-11

## Context

**GDD**: `design/gdd/player-abilities.md`,
`design/gdd/exploration-ability-gating.md`,
`design/gdd/scene-management.md`

**Requirements**: `TR-ability-001`, `TR-ability-003`, `TR-explore-001`,
`TR-explore-002`, `TR-scene-001`, `TR-scene-002`, `TR-scene-003`

**ADR Governing Implementation**: ADR-0002 Data schemas; ADR-0004 Feature
ownership; ADR-0007 Scene management; ADR-0018 Player abilities; ADR-0021
Save system.

Story133 leaves Cinderpaw in a secured deep-cistern arena. The ability GDD
defines an alternate `wall_climb` source at a hidden altar on the Old Factory's
upper platform, but neither Boss4 nor that reward has an implementable story
contract. This story creates the deliberate route between those facts: a
restored cistern ascender becomes available only after the Stalker is defeated,
delivers Cinderpaw to a new playable Factory upper-works approach, and lets the
player traverse to and discover the dormant altar without granting its reward.

## Acceptance Criteria

- [x] `data/scene_registry.json` and its schema register
  `area_03_factory_upper_altar` at
  `res://scenes/areas/factory_upper_altar_approach.tscn`, default spawn
  `cistern_ascender_arrival`.
- [x] Underground Passage contains `DeepCisternAscenderRoute` and
  `DeepCisternAscenderReturnSpawn`. The route targets
  `area_03_factory_upper_altar / cistern_ascender_arrival` and remains
  unavailable until `underground_deep_cistern_stalker_defeated=true`.
- [x] A nearby player can request the ascender exactly once per visit through
  SceneManager. The Underground snapshot is persisted before the transition,
  including Story131-133 state and unlocked abilities.
- [x] The Factory upper-altar approach is a bounded `1280x720` playable scene
  with Cinderpaw, Camera2D, collision-backed floor/platforms, HUD/objective, a
  return ascender, and a reachable dormant hidden altar.
- [x] The new opaque background, transparent ascender, and transparent dormant
  altar are generated through image generation, imported by Godot 4.7, and
  recorded in the asset pipeline.
- [x] Reaching the altar records
  `factory_upper_hidden_altar_discovered=true`, changes the objective to
  `Dormant Altar Found`, and does not unlock `wall_climb`.
- [x] Discovery is idempotent and survives local-state restore without replaying
  discovery feedback.
- [x] The return ascender requests
  `area_04_underground_passage / deep_cistern_ascender_return`; the Underground
  scene aligns Cinderpaw to that marker without reactivating the Stalker.
- [x] Focused tests, one bounded adjacent regression, one targeted headless
  smoke, and Godot MCP verify scene load, scripts, registry, imported textures,
  transition state, collision-backed traversal, logs, key nodes, and a non-empty
  screenshot.

## Out of Scope

- Boss4 design, boss configuration, boss combat, boss reward flow, or Boss4 art.
- Unlocking or implementing `wall_climb`; Story135 may own the altar reward and
  runtime movement once its acceptance contract exists.
- Neon Rooftops or Central Tower scene implementation.
- Expanding the existing 5120 px Underground route or adding another enemy wave.
- New save schema, minimap, fast travel, dialogue, or bespoke audio.

## Implementation Notes

- Keep scene changes behind the existing SceneManager request boundary and
  persist scene-local state before requesting a swap.
- Keep upper-approach behavior in
  `src/gameplay/factory_upper_altar_approach_scene.gd`; do not widen the very
  large Factory route controller.
- Reuse `RouteTransitionShell` for both ascenders. The scene controllers own
  availability, proximity, idempotence, state merge, and objective priority.
- Generated props are real `Sprite2D` visuals paired with authored collision or
  interaction nodes; no ColorRect or primitive placeholder is accepted.
- The dormant altar is a discovery payoff and foreshadowing object. It must not
  call `unlock_ability(&"wall_climb")` in this story.

## Test Evidence

**Required evidence**:

- `tests/unit/gameplay/deep_cistern_ascender_factory_upper_altar_approach_test.gd`
- `tests/smoke/deep_cistern_ascender_factory_upper_altar_approach_smoke.gd`
- `production/qa/evidence/deep-cistern-ascender-factory-upper-altar-approach-2026-07-11.md`

**Status**: [x] Complete.

- Initial contract RED: `reports/report_1457/results.xml`.
- Runtime objective regression RED: `reports/report_1461/results.xml`.
- Final focused GREEN: `reports/report_1463/results.xml` passed `3/3`.
- Bounded adjacent GREEN: `reports/report_1459/results.xml` passed `15/15`.
- Targeted smoke exited `0` with
  `deep_cistern_ascender_factory_upper_altar_approach_smoke=passed`.
- Godot MCP runs `39` and `41` verified the real SceneManager handoff, generated
  visuals, movement, discovery state, node visibility, clean current-run logs,
  and non-empty gameplay screenshots.

## Dependencies

- Depends on: Story133 Underground Deep Cistern Stalker Ambush. Complete.
- Unlocks: Story135 Hidden Altar Wall Climb Reward and runtime movement design.

## Completion Notes

- All `9/9` acceptance criteria are complete.
- Story134 registers and implements the post-Stalker ascender route, the bounded
  Factory upper-altar approach, bidirectional SceneManager state handoff, and
  idempotent dormant-altar discovery.
- The three player-visible environment assets were generated through built-in
  image generation, normalized to runtime formats, and imported by Godot 4.7.
- `wall_climb` is intentionally not granted or implemented here. Story135 owns
  the reward and movement contract; Boss4 remains undesigned and out of scope.
