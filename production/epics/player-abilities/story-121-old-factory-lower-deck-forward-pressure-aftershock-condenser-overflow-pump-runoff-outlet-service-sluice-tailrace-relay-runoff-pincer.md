# Story 121: Old Factory Lower Deck Forward Pressure Aftershock Condenser Overflow Pump Runoff Outlet Service Sluice Tailrace Relay Runoff Pincer

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Combat
> **Type**: Integration + Gameplay Runtime + Frame Animation Contract
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-22

## Context

**GDD**: `design/gdd/player-abilities.md`,
`design/gdd/exploration-ability-gating.md`,
`design/gdd/scene-management.md`, `design/gdd/death-respawn.md`

**Requirements**: `TR-scene-004`, `TR-explore-005`, `TR-respawn-002`,
`TR-respawn-004`

**ADR Governing Implementation**: ADR-0004 Collision detection; ADR-0005
Combat state machine; ADR-0007 Scene management; ADR-0018 Player abilities;
ADR-0021 Save system.

Story120 crosses the runoff pocket after the Tailrace Relay. Story121 adds a
compact post-runoff ACT combat beat using existing frame-animated Factory Spark
Rat and Factory Coil Rat enemies so the route does not remain a sequence of
environment-only traversal beats.

## Acceptance Criteria

- [x] The pincer is unavailable until Story120 has persisted
  `factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_crossed=true`.
- [x] Crossing activation x `14640.0` or explicitly activating with an in-range
  provider starts the encounter, persists the pincer activation flag, shows
  `Break Tailrace Runoff Pincer`, and reveals both enemies.
- [x] The encounter contains exactly one Factory Spark Rat entity `2144` at
  `Vector2(14760, 482)` and one Factory Coil Rat entity `2145` at
  `Vector2(15280, 482)`.
- [x] Both enemies use `AnimatedSprite2D + SpriteFrames`; `idle`, `run`,
  `attack_tell`, `attack`, `hurt`, and `death` each contain at least three
  frames.
- [x] Activation assigns Cinderpaw as the target for both enemies, enables
  process/physics, and starts staggered opening grace frames: Spark Rat `10`,
  Coil Rat `24`.
- [x] Defeating only one enemy keeps the route objective active and does not
  mark the pincer cleared.
- [x] Defeating both enemies hides/disables them, persists both defeated flags
  and the pincer cleared flag, and advances route feedback to
  `Tailrace Runoff Pincer Cleared`.
- [x] Restoring only the pincer-cleared state backfills the Story106-120 chain
  without replaying earlier beats.
- [x] Story121 preserves the Story119 Tailrace Relay savepoint payload; the
  last savepoint remains the Tailrace Relay.
- [x] Scene bounds support the encounter: right wall x `15580`, camera and
  background right `15600`, ground right edge x `15700`, and at least 63 route
  floor visuals.
- [x] Focused/related GdUnit, headless smoke, and Godot MCP runtime checks pass
  under Godot 4.7 / Godot AI MCP 2.9.1.

## Out of Scope

New enemy families, new generated character art, new AI behavior trees, reward
cache, new savepoint, SaveSystem schema changes, minimap/fast-travel UI,
authored audio, particles, shaders, Boss2, broader lower-deck biome art
replacement, and route economy tuning.

## Implementation Notes

- The slice deliberately reuses the existing Factory Spark Rat and Factory Coil
  Rat because the immediate goal is ACT density with frame animation, not a new
  art-production branch.
- The route objective prioritizes active pincer combat before the Story120
  `Tailrace Relay Runoff Crossed` handoff.
- Restored pincer completion backfills the prior runoff/service-sluice/tailrace
  chain so saves do not strand the player behind older gates.

## Asset Pipeline

No new visual or audio assets were generated. Story121 reuses existing
image-generated/imported character animation assets that already satisfy the
Godot frame-animation rule:

- Factory Spark Rat frames under
  `assets/characters/factory_spark_rat/<animation>/`
- Factory Spark Rat SpriteFrames:
  `assets/characters/factory_spark_rat/factory_spark_rat_sprite_frames.tres`
- Factory Coil Rat frames under
  `assets/characters/factory_coil_rat/<animation>/`
- Factory Coil Rat SpriteFrames:
  `assets/characters/factory_coil_rat/factory_coil_rat_sprite_frames.tres`
- Route floor:
  `assets/environment/old_factory_route_floor/env_old_factory_route_floor_tile_256x96.png`

## Test Evidence

- Focused RED: `reports/report_1366/` failed before Story121 pincer
  diagnostics, activation API, state, and scene nodes existed.
- Intermediate RED: `reports/report_1367/` exposed the missing entity lookup
  path for `apply_damage(2144/2145)`.
- Focused GREEN: `reports/report_1368/` passed Story121 `2/2`.
- Related GREEN: `reports/report_1369/` passed Story121 plus adjacent Story120,
  Story118, and Story114 suites `8/8`.
- Headless smoke:
  `reports/old_factory_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_smoke.log`
  exited `0` and printed
  `service_sluice_tailrace_relay_runoff_pincer_smoke=passed`.
- Godot AI MCP `2.9.1` on Godot `4.7-stable` opened and ran the factory scene
  with helper live, found both pincer enemies and their `AnimatedSprite2D`
  children, confirmed SpriteFrames paths and 3-frame counts for all required
  animations, activated the pincer in the running game through typed
  `game_eval`, confirmed visible/targeted enemies, route label
  `Break Tailrace Runoff Pincer`, clean current-run editor/game logs, and a
  non-empty `640x359` game screenshot showing the active pincer.
- Full evidence is recorded in
  `production/qa/evidence/old-factory-service-sluice-tailrace-relay-runoff-pincer-2026-07-10.md`.
- Story231 incoming handoff: `reports/report_2388/report_1/results.xml` passed
  the Story121 regression inside a five-suite `7/7` related set. The updated
  Story120 180-frame smoke and MCP 3.0.4 run `r192090587-32` confirmed Story121
  becomes available after the crossing but remains inactive, hidden,
  untargeted and non-processing after stationary/no-input threshold placement.
- The Story121 regression now follows the established live death contract:
  the most recently defeated enemy remains visible/processing during its
  three-frame death hold while targeting, collision and physics are disabled.
