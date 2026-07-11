# Story 136: Neon Rooftops Magnetic Wall Gate Handoff

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Feature / Gameplay Runtime / Scene Management / Presentation
> **Type**: Integration + Ability Gate + Scene Handoff + Traversal + Visual
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-11

## Context

**GDD**: `design/gdd/exploration-ability-gating.md`,
`design/gdd/player-abilities.md`, `design/gdd/scene-management.md`,
`design/gdd/audio-system.md`

**Requirements**: `TR-explore-001`, `TR-explore-002`, `TR-explore-005`,
`TR-explore-006`, `TR-ability-001`, `TR-ability-004`, `TR-scene-001`,
`TR-scene-003`, `TR-scene-004`

**ADR Governing Implementation**: ADR-0001 component ownership; ADR-0002 typed
signals; ADR-0003 data management; ADR-0004 presentation; ADR-0007 scene
persistence; ADR-0018 player abilities; ADR-0021 save system.

Story135 ends on a physical high perch with `wall_climb` unlocked and the route
proven, but deliberately stops before creating Neon Rooftops. The exploration
GDD defines Neon Rooftops as the area unlocked by the magnetic-wall gate. This
story closes that loop with a registered, bidirectional scene handoff and one
bounded rooftop entry screen where the same wall-climb mechanic is required in
real collision to reach the high route endpoint.

The first screen is an ACT traversal slice, not an empty destination: Cinderpaw
arrives on a lower roof, crosses to an image-generated magnetic tower, climbs
through a one-way upper-roof lip, and records the entry route as explored. It
also requests the existing `mus_rooftop` and `amb_rooftop` cues through the
shared scene-audio contract.

## Acceptance Criteria

- [x] `data/scene_registry.json` and its schema register
  `area_05_neon_rooftops` at
  `res://scenes/areas/neon_rooftops_entry.tscn`, type `area`, default spawn
  `factory_rooftop_arrival`, display name `Neon Rooftops`.
- [x] Factory Upper Altar contains a generated rooftop bridge/beacon route at
  the Story135 proof perch. It is unavailable before `wall_climb` plus
  `factory_upper_wall_climb_route_proven`, then shows a proximity prompt and
  permits one transition request per visit.
- [x] Entering Neon Rooftops permanently records
  `factory_upper_neon_rooftops_route_opened=true`, persists Factory state,
  merges unlocked abilities into destination state, and requests
  `area_05_neon_rooftops / factory_rooftop_arrival` through SceneManager.
- [x] Returning from Neon Rooftops requests
  `area_03_factory_upper_altar / neon_rooftops_return`; the Factory scene aligns
  Cinderpaw to an authored high-perch return marker instead of the cistern
  arrival marker, including after local-state restore.
- [x] The destination is a bounded `1280x720` scene with image-generated opaque
  rooftop background, generated transparent magnetic tower and Factory bridge,
  Cinderpaw `AnimatedSprite2D + SpriteFrames`, Camera2D limits, HUD/objective,
  invisible collision-backed lower roof, one-way upper roof, side/top bounds,
  proof Area2D, and no player-visible primitive placeholders.
- [x] `neon_rooftops_entry_scene.gd` restores unlocked abilities and only records
  `neon_rooftops_entry_traversed=true` when a provider with `wall_climb` reaches
  the high proof area. Duplicate proof is rejected and restored state does not
  replay feedback.
- [x] Valid magnetic-tower contact uses the shared Story135 wall-climb movement,
  three-frame `wall_climb` animation, and generated contact glow. The authored
  geometry permits climb-through plus landing and prevents leaving the scene.
- [x] The entry objective progresses from `Climb the Neon Magnetic Tower` to
  `Neon Rooftops Reached`; the return route remains usable and preserves the
  full unlocked-ability list in both scene states.
- [x] AudioSystem maps `area_05_neon_rooftops` to existing `mus_rooftop` and
  `amb_rooftop` streams without generating duplicate baseline audio.
- [x] One focused RED/GREEN suite, one bounded adjacent regression, one targeted
  headless SceneManager/physics smoke, and Godot MCP verify registry/schema,
  generated imports, one-shot handoff, spawn alignment, real wall climb,
  persistence, audio cue, objective, logs, key nodes, and a non-empty screenshot.

## Implementation Notes

- Reuse `RouteTransitionShell` and SceneManager; keep Factory and rooftop local
  state ownership in their respective scene controllers.
- `factory_upper_neon_rooftops_route_opened` is the permanent gate-open flag.
  Once true, the return trip must not depend on re-performing Story135.
- The rooftop scene may reuse Story135's generated wall-contact glow and player
  animation, but its background, magnetic tower, and bridge/beacon must be new
  image-generation outputs with retained source and import records.
- Keep collision invisible over the generated art. Do not use ColorRect,
  Polygon2D, debug rectangles, or labels as environment substitutes.
- Preserve SceneManager's configure-then-restore order by applying the active
  spawn point after state restore as well as after manager binding.

## Out of Scope

- Boss4 configuration, encounter, reward, arena, enemy art, or combat balance.
- Additional Neon Rooftops rooms, streaming chunks, NPCs, merchants, secrets,
  savepoints, minimap completion, or Central Tower handoff.
- New player abilities, wall combat, ledge grab, stamina, moving magnetic walls,
  mobile controls, or input remapping.
- New music/ambient production; existing imported rooftop baseline cues are used.

## QA Test Cases

- **AC-1/5/9**: Registry, assets, scene, audio
  - Given: Story136 files are present.
  - When: registry/schema, generated PNGs, scene hierarchy, collision, camera,
    player SpriteFrames, and AudioSystem cue are inspected.
  - Then: the registered scene and exact asset/audio contracts resolve.
- **AC-2/3/4**: Factory one-shot handoff and return spawn
  - Given: Factory state before and after Story135 route proof.
  - When: Cinderpaw attempts the high route twice and later returns from rooftops.
  - Then: locked entry rejects, unlocked entry requests once and persists, and
    the return spawn remains on the high perch after restore.
- **AC-6/7/8/10**: Rooftop traversal and roundtrip
  - Given: the destination with and without `wall_climb`.
  - When: the real magnetic wall route and return bridge are exercised.
  - Then: only the able player completes the proof, state/objective persist,
    abilities survive, real animation/contact feedback are visible, and the
    SceneManager roundtrip remains clean.

## Test Evidence

**Required evidence**:

- `tests/unit/gameplay/neon_rooftops_magnetic_wall_handoff_test.gd`
- `tests/smoke/neon_rooftops_magnetic_wall_handoff_smoke.gd`
- `production/qa/evidence/neon-rooftops-magnetic-wall-handoff-2026-07-11.md`

**Status**: [x] Complete. Initial RED `report_1472`; focused GREEN
`report_1475` passed `3/3`; final bounded adjacent GREEN `report_1477` passed
`9/9`; targeted SceneManager/physics smoke passed; Godot MCP runs `46/48`
verified real entry input, generated assets, frame animation, audio state,
collision, screenshot, and clean final logs.

## Completion Notes

- Acceptance: `10/10` complete.
- Generated and imported one opaque rooftop environment plus two transparent
  route props; reused the completed Cinderpaw wall-climb frame contract.
- Factory→Rooftops→Factory roundtrip preserves route and abilities, including
  exact `neon_rooftops_return` high-perch alignment after restore.
- Boss4, additional rooftop rooms, enemies, secrets, savepoints, and Central
  Tower remain intentionally out of scope.

## Dependencies

- Depends on: Story135 Factory Hidden Altar Wall Climb Reward Traversal.
  Complete.
- Unlocks: a future first Neon Rooftops combat/traversal expansion story.
