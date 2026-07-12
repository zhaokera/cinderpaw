# Story 142: Central Tower Cooling Shaft Roost Traverse

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Traversal / Save and Respawn / Visual
> **Type**: Integration + Gameplay Runtime + Traversal + Save/Respawn + Visual
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-12

## Context

**GDD**: `design/gdd/game-concept.md`,
`design/gdd/exploration-ability-gating.md`, `design/gdd/player-abilities.md`,
`design/gdd/health-death.md`, `design/gdd/death-respawn.md`,
`design/gdd/save-system.md`, `design/gdd/scene-management.md`,
`design/art/art-bible.md`

**Quick Design**:
`design/quick-specs/central-tower-cooling-shaft-roost-traverse-2026-07-12.md`

**Requirements**: `TR-respawn-001`, `TR-respawn-002`, `TR-respawn-005`,
`TR-respawn-006`, `TR-save-006`, `TR-save-007`, `TR-scene-004`

**ADR Governing Implementation**: ADR-0001, ADR-0002, ADR-0004, ADR-0005,
ADR-0007, ADR-0018, ADR-0019, ADR-0021.

Story140-141 create two consecutive Tower combat viewports. Story142 supplies
the missing post-combat recovery and movement rhythm without inferring Boss4:
one generated third viewport, one new Roost, one cyclic electrical hazard over
a lethal suspension gap, existing movement ability traversal, and one bounded
durable endpoint.

## Acceptance Criteria

- [x] `central_tower_threshold.tscn` expands to a bounded `3840x720` scene while
  preserving Story140/141 nodes, coordinates, state keys, combat, cache, entry,
  and return. Camera/right/top bounds match the new width; the existing first
  two viewports keep their collision.
- [x] A dedicated `CentralTowerCoolingShaftController` owns the third viewport's
  route gate, Roost, hazard timing/contact cooldown, lethal fall, endpoint,
  objective, autosave/audio/VFX diagnostics, and durable state. The parent adds
  only narrow adapters, state merge, save snapshot, objective priority, and
  latest-savepoint selection.
- [x] Relay Mantis defeat unlocks the route. Cache claim is accepted as an
  optional stronger restored state but is never required for progression.
  Locked, distant, or duplicate Roost/endpoint activation is rejected.
- [x] The generated Cooling Shaft Roost uses `SavepointRuntime` with id
  `central_tower_cooling_shaft_roost`, scene `area_05_central_tower`, and spawn
  `cooling_shaft_roost`. First nearby activation restores full HP, records the
  exact spawn marker, requests established audio/VFX and one slot-zero autosave,
  persists once, and becomes the Tower GameFlow's latest respawn anchor.
- [x] The authored conduit gap uses real approach/exit ledges, two magnetic
  StaticBody2D spines, one-way perches, and a lethal fall Area2D. Existing
  Cinderpaw jump/double-jump/dash/wall-climb and `AnimatedSprite2D +
  SpriteFrames` states are the only traversal mechanics and character art.
- [x] Hazard `central_tower_cooling_shaft_arc` cycles deterministic
  `0.75/0.50/0.35/0.70s` grace/warning/active/safe timing. Only active overlap
  deals exactly `10` electric damage through the public player health path;
  the same target cannot be damaged again before `1.0s`.
- [x] Lethal fall after Roost activation uses the existing Tower `1.5s` death
  delay, then revives at `(2740,552)` with 50% HP and 120 i-frame protection.
  Hazard phase/cooldowns reset while Story140/141 clear, optional cache claim,
  Roost state, and exact abilities remain unchanged.
- [x] Reaching endpoint `central_tower_cooling_shaft_endpoint` after route
  activation persists `central_tower_cooling_shaft_traversed=true`, disables
  hazard/repeat feedback, and shows `Cooling Shaft Secured`. Fresh restore
  backfills prerequisites and does not replay Roost, autosave, audio, VFX, or
  endpoint feedback.
- [x] The generated background and six separate transparent assets meet exact
  dimensions, import through Godot 4.7, retain source/prompt/alpha records, and
  contain no visible primitive/debug placeholder, baked actor/text, magenta
  spill, or Boss-arena composition.
- [x] One focused RED/GREEN suite, one Story141 adjacent regression, one
  savepoint-selection regression, one target smoke, and one final Godot MCP run
  verify geometry, real movement, hazard/damage, death/revive, save/restore,
  screenshot, and current-run logs. No full suite is required.

## Stable Contract

| Contract | Value |
|----------|-------|
| Scene | `area_05_central_tower` / `central_tower_threshold.tscn` |
| Scene size | `3840x720` |
| Route prerequisite | `central_tower_relay_mantis_defeated` |
| Roost | `central_tower_cooling_shaft_roost` / `cooling_shaft_roost` |
| Hazard | `central_tower_cooling_shaft_arc` / `10` / `1.0s` |
| Endpoint | `central_tower_cooling_shaft_endpoint` |
| Durable completion | `central_tower_cooling_shaft_traversed` |

## Test Evidence Contract

- Focused suite:
  `tests/unit/gameplay/central_tower_cooling_shaft_roost_traverse_test.gd`
  - Authored assets, third-viewport geometry, controller and existing player
    animation contract.
  - Story141 gate, one-shot Roost/autosave/audio/VFX, cyclic arc damage and
    cooldown contract.
  - Lethal fall, Cooling Roost revive, endpoint, exact abilities, and fresh
    restore without replay.
- Headless smoke:
  `tests/smoke/central_tower_cooling_shaft_roost_traverse_smoke.gd`; starts from
  Story141 clear and runs only the new Roost/hazard/fall/endpoint/restore loop.
- MCP evidence:
  `production/qa/evidence/central-tower-cooling-shaft-roost-traverse-2026-07-12.md`.

## Completion Evidence

- Expected RED: `reports/report_1510/results.xml`; final focused GREEN:
  `reports/report_1513/results.xml` (`3/3`).
- Adjacent Story140/141 and savepoint-selection regression:
  `reports/report_1514/results.xml` (`10/10`).
- Target smoke emitted
  `central_tower_cooling_shaft_roost_traverse_smoke=passed` and exited `0`.
- Godot AI MCP `2.9.1` run `68` on Godot `4.7-stable` returned
  `current_run_errors=[]`, exercised real `jump` and `dash` actions, inspected
  generated runtime textures and Cinderpaw's live `AnimatedSprite2D`, and
  captured a non-empty `1278x718` gameplay screenshot.

## Out Of Scope

- Boss4 identity, data, arena, phases, music, reward, narrative, or ending.
- Fourth viewport, new scene id/handoff, enemy, ability, reward cache, NPC,
  dialogue, minimap, fast travel, secret room, or generalized hazard framework.
- Shared PlayerController, GameFlow, SaveSystem, SceneManager, Combat, Ability,
  or animation-resource refactors.
- Rebalancing or replaying Story139-141 gameplay during target verification.

## Dependencies

- Depends on: Story141 Central Tower Inner Relay Skirmish. Complete.
- Unlocks: a future authored deeper-Tower route or Boss approach contract;
  neither a Boss identity nor encounter is implied.
