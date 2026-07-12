# Story 140: Central Tower Threshold Guard Handoff

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Core / Gameplay Runtime / Scene Management / Combat / Visual
> **Type**: Integration
> **Estimate**: L
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-12

## Context

**GDD**: `design/gdd/game-concept.md`,
`design/gdd/exploration-ability-gating.md`, `design/gdd/scene-management.md`,
`design/gdd/health-death.md`, `design/gdd/death-respawn.md`,
`design/gdd/combat-presentation.md`, `design/gdd/audio-system.md`,
`design/art/art-bible.md`

**Quick Design**:
`design/quick-specs/central-tower-threshold-guard-2026-07-12.md`

**Requirements**: `TR-explore-001`, `TR-explore-002`, `TR-scene-001`,
`TR-scene-002`, `TR-scene-004`, `TR-respawn-001`, `TR-respawn-002`,
`TR-respawn-005`, `TR-respawn-006`, `TR-respawn-007`

**ADR Governing Implementation**: ADR-0001 Autoload architecture; ADR-0002
typed signals; ADR-0003 data configuration; ADR-0004 collision detection;
ADR-0005 combat state machine; ADR-0006 AI behavior; ADR-0007 scene
persistence. This Story reuses, but does not ratify or expand, the existing
interfaces described by Proposed ADR-0018/0019/0021.

Story139 proves the GDD's `parry + all prerequisite areas` gate and persists
the outer threshold as secured. It deliberately stops before a scene handoff
because no Central Tower interior contract existed. The linked Quick Design now
defines only a first threshold vestibule: explicit entry, one non-Boss guard,
durable inner-seal clear, a local death checkpoint, and a return route.

## Design Decision

- **Selected**: register the existing stable target id
  `area_05_central_tower`; Story019 and Story139 already use that id, so this
  story does not silently migrate it to `area_06_central_tower`.
- **Selected**: one generated `1280x720` vestibule with a unique frame-animated
  Threshold Guard. This makes the destination playable instead of an empty
  scene while remaining an ordinary encounter.
- **Selected**: defeating the guard opens the inner seal. No resource reward is
  attached because the GDD defines no Tower reward at this point.
- **Selected**: a real `SavepointRuntime` Threshold Roost at the arrival marker
  becomes the local no-loss checkpoint; existing GameFlow and PlayerController
  revive contracts are reused.
- **Rejected**: an empty handoff-only room. It proves plumbing but does not add
  a player-visible ACT beat.
- **Rejected**: Boss4, a Boss arena, a second room, NPC/dialogue, ability reward,
  minimap, fast travel, or ending content. None has an approved contract.

## Stable Contract

| Contract | Value |
|----------|-------|
| Scene id | `area_05_central_tower` |
| Scene path | `res://scenes/areas/central_tower_threshold.tscn` |
| Default / entry spawn | `neon_rooftops_threshold_arrival` |
| Rooftops return spawn | `central_tower_threshold_return` |
| Guard entity / family | `2701` / `central_tower_threshold_guard` |
| Guard config | `central_tower_threshold_guard` |
| Guard clear state | `central_tower_threshold_guard_defeated` |
| Encounter activation state | `central_tower_threshold_guard_activated` |
| Savepoint id | `central_tower_threshold_roost` |
| Savepoint state | `central_tower_threshold_roost_activated` |

## Acceptance Criteria

- [x] `data/scene_registry.json` and its schema register
  `area_05_central_tower` with exact path, `type=area`, `preload=false`, and
  `default_spawn=neon_rooftops_threshold_arrival`.
- [x] After Story139 threshold security, a second explicit interaction near the
  authored Tower route requests exactly
  `area_05_central_tower / neon_rooftops_threshold_arrival` once. Unsecured,
  distant, loading, locked, unknown-scene, or repeated requests do not mutate
  progression or the transition latch.
- [x] Rooftops persists its complete Story136-139 state before the request and
  accepts `central_tower_threshold_return` as a safe spawn beside the open outer
  gate without replaying the parry trial or threshold feedback.
- [x] `central_tower_threshold.tscn` is a bounded `1280x720` area with generated
  background/props, Player, Camera2D, HUD/objective, real floor/walls, exact
  arrival marker, `SavepointRuntime` Threshold Roost, return route, rear/inner
  seals, guard, and encounter controller. It has no visible primitive/debug
  placeholder.
- [x] `central_tower_threshold_guard` is data-driven and uses
  `AnimatedSprite2D + SpriteFrames`; `idle`, `run`, `attack_tell`, `attack`,
  `hurt`, and `death` each use exactly three transparent `96x96` frames with
  common bottom-center registration and continuous names. Runtime frames live
  under `assets/characters/central_tower_threshold_guard/<animation>/`, with
  `scenes/characters/central_tower_threshold_guard.tscn`,
  `src/characters/central_tower_threshold_guard.gd`, and the matching gameplay
  wrapper all present.
- [x] Crossing x `420` activates entity `2701`, closes both seals, assigns the
  real player as attack target, and changes the objective to break the guard.
  Its telegraphed attack can deal configured damage through the shared Core
  Collision/Combat/Health chain.
- [x] Real player attack routing can damage and defeat the guard. Defeat opens
  both seals, records the durable clear state, updates the objective, and does
  not create a reward, Boss, or new ability.
- [x] First entry activates `central_tower_threshold_roost` before combat.
  Lethal damage uses the existing `1.5s -> 50% HP` no-loss revive at the valid
  standing position for `neon_rooftops_threshold_arrival`; control returns on
  revive with `2.0s / 120` frames of invincibility. An uncleared attempt resets
  activation to false, opens both seals, restores full guard HP and authored
  position, and can be reactivated by a new threshold crossing. A guard defeated
  during the death window, or an already cleared room, remains durably clear.
- [x] Tower return requests exactly
  `area_05_neon_rooftops / central_tower_threshold_return`, preserving Tower
  clear state and all unlocked abilities across fresh restore and runtime scene
  reuse.
- [x] One focused RED/GREEN suite, one bounded Story139 regression, one real
  bidirectional SceneManager smoke, and one final Godot MCP run verify the
  registry, bidirectional swaps, exact spawns, state, combat, death/revive,
  generated assets, six animations, key node visibility, non-empty screenshots,
  and no new current-run errors.

## Implementation Notes

- Add no Autoload. Both scenes receive SceneManager through the established
  runtime configuration seam and persist JSON-safe local state.
- Keep the Rooftops laser trial controller unchanged. The parent scene owns the
  post-secure transition latch and route prompt.
- Reuse `RatMinion`-family Core components for the guard, but give the new
  character its own scene, script, SpriteFrames, data id, metadata source, and
  generated art.
- The guard controller owns activation, seals, enemy reset, and durable combat
  state. The area scene owns SceneManager, Player combat adapters, GameFlow,
  HUD/objective, return route, audio, and state aggregation.
- Use `mus_rooftop` / `amb_rooftop` at the exterior threshold. Do not invent
  Central Tower music before audio content exists.
- Generated assets are specified in
  `design/assets/specs/central-tower-threshold-guard-handoff.md`, recorded in
  `design/assets/asset-manifest.md`, and evidenced in
  `production/qa/evidence/central-tower-threshold-guard-handoff-2026-07-12.md`.

## Out of Scope

- Boss4 identity, data, phases, arena, art, music, reward, and story payoff.
- Deeper Tower interior, second encounter wave, puzzle, additional savepoints,
  ability reward, cache, NPC, dialogue, quest, ending, minimap, or fast travel.
- Rebalancing Story139 parry timing/damage or renaming existing scene ids.
- Shared SceneManager, PlayerController, CombatComponent, or save-schema
  refactors unrelated to the bounded handoff.

## QA Plan

1. Run the new three-test suite once in RED before production implementation.
2. Run it once in GREEN after implementation and asset import.
3. Run only Story139 as the adjacent regression; Story140 remains isolated in
   its focused suite instead of being executed twice.
4. Run one targeted headless SceneManager smoke from secured Rooftops into the
   Tower and back, with frame-resource checks, a real guard hit, dual-seal
   activation, durable combat clear, exact spawns, and state preservation.
5. Run one Godot MCP acceptance pass against the final target scene; inspect
   hierarchy, guard animation/frame counts, runtime attack state, screenshot,
   game logs, and editor logs.

## Test Evidence Contract

- Focused suite:
  `tests/unit/gameplay/central_tower_threshold_guard_handoff_test.gd`
  - **Given** registry/data and generated assets, **when** the authored scene is
    instantiated, **then** exact scene/spawn/entity ids, required nodes, asset
    dimensions, six animation names, and three frames each are asserted.
  - **Given** incomplete or completed Story139 state, **when** the Tower route is
    requested, **then** rejection paths, one-shot request, state persistence,
    target ability handoff, and Rooftops return spawn are asserted.
  - **Given** an activated Threshold Roost and live guard, **when** enemy/player
  hitboxes resolve, death/revive occurs, the guard is defeated, state is
  restored, and return is requested, **then** HP, seals, reset semantics,
  120-frame i-frame grant/expiry, no added abilities, durable clear, feedback
  counts, and exact return ids are asserted.
- Headless smoke:
  `tests/smoke/central_tower_threshold_guard_handoff_smoke.gd`; it owns target
  Rooftops -> Tower -> Rooftops SceneManager loading, exact spawn checks,
  six-animation resource checks, one real guard hit, dual-seal state, durable
  guard clear, exact full-ability-set preservation at every boundary, return
  restoration, and a second cache-window round trip that reuses the same Tower
  runtime instance.
- Runtime evidence:
  `production/qa/evidence/central-tower-threshold-guard-handoff-2026-07-12.md`.

## Completion Evidence

- Expected RED: `reports/report_1493/results.xml` loaded all three cases and
  recorded the missing Story140 contracts before implementation.
- Asset-import prerequisite: `reports/report_1494/report_1/results.xml` failed
  because the newly generated PNGs had not yet entered Godot's import cache;
  Godot 4.7 editor import then completed with exit `0` and registered all four
  new global classes.
- Focused GREEN: `reports/report_1495/report_1/results.xml` passed `3/3` with
  zero errors, failures, flaky cases, skipped cases, or orphan nodes.
- Post-review focused GREEN: `reports/report_1497/report_1/results.xml` passed
  `3/3` after failed-attempt hitbox cleanup and first-entry Roost replay guards;
  it explicitly asserts no guard hitbox survives respawn reset.
- Story139 adjacent regression: `reports/report_1496/report_1/results.xml`
  passed `3/3` with zero errors or failures.
- Final consolidated regression: `reports/report_1500/results.xml` passed both
  Story140 and Story139 suites `6/6` with zero errors or failures.
- Final review-closure focused run: `reports/report_1501/results.xml` passed
  Story140 `3/3`, including exact ability equality and 120-frame i-frame expiry.
- Real bidirectional headless smoke exited `0` with marker
  `central_tower_threshold_guard_handoff_smoke=passed`; full output is retained
  at `reports/central_tower_threshold_guard_handoff_smoke.log`. A second entry
  before deferred unload reused the same Tower instance and retained its clear.
- Godot MCP session `cinderpaw@e40d` on Godot `4.7-stable` and MCP `2.9.1`
  opened the disk scene, inspected `44` authored and `78` runtime nodes, drove
  real right-movement input to activate the encounter, and captured a non-empty
  `1278x718` frame showing Cinderpaw, the generated room, both closed seals, and
  the visible frame-animated guard. Current run `62` reported no game-log errors
  and no editor rows after cursor `3`; the PNG is retained at
  `reports/visual/cinderpaw-mcp-central-tower-threshold-guard-run62-20260712.png`.

## Dependencies

- Depends on: Story139 Central Tower Parry-Laser Trial. Complete.
- Unlocks: a future authored Central Tower interior or Boss contract; neither is
  implied by this Story.
