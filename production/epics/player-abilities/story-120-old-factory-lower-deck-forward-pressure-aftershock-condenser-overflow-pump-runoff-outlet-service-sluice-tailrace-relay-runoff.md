# Story 120: Old Factory Lower Deck Forward Pressure Aftershock Condenser Overflow Pump Runoff Outlet Service Sluice Tailrace Relay Runoff

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Traversal
> **Type**: Integration + Gameplay Runtime + Visual/Feel
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-22

## Context

**GDD**: `design/gdd/player-abilities.md`,
`design/gdd/exploration-ability-gating.md`,
`design/gdd/scene-management.md`, `design/gdd/death-respawn.md`

**Requirements**: `TR-scene-004`, `TR-explore-005`, `TR-respawn-002`,
`TR-respawn-004`

**ADR Governing Implementation**: ADR-0004 Collision detection; ADR-0007
Scene management; ADR-0018 Player abilities; ADR-0021 Save system.

Story119 creates the Tailrace Relay savepoint after the service-sluice
Tailrace Coil Rat. Story120 extends the route immediately after that relay with
a compact, readable runoff vent traversal so the savepoint has a nearby
gameplay payoff without stacking another enemy encounter directly on top of
Story118.

## Acceptance Criteria

- [x] The tailrace relay runoff duct and vent are present in
  `factory_route_transition_shell.tscn`, hidden, unavailable, non-monitoring,
  and non-contacting until the Story119 tailrace relay is activated.
- [x] Once the relay is activated, the runoff pocket is visible but idle,
  route feedback remains `Tailrace Relay Secured`, and contact damage remains
  disabled until activation.
- [x] Crossing activation x `13760.0` starts the runoff traversal, persists
  `factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_activated=true`,
  and updates route feedback to `Cross Tailrace Relay Runoff`.
- [x] The runoff uses the deterministic steam window
  `grace -> warning -> active -> safe`; only the `active` phase enables
  collision layer/mask, monitoring, and contact damage.
- [x] Crossing exit x `14320.0` persists
  `factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_crossed=true`,
  disables contact, and updates route feedback to
  `Tailrace Relay Runoff Crossed`.
- [x] Restoring only the Story120 crossed flag backfills the Story106-119
  runoff/service-sluice/tailrace/relay chain without replaying prior beats or
  relay VFX.
- [x] Story120 does not change the Story119 savepoint payload; the last
  savepoint remains the Tailrace Relay with scene `area_03_factory` and spawn
  point
  `lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay`.
- [x] Scene bounds support the new pocket: right wall x `14500`, camera and
  background right `14520`, ground right edge x `14600`, and at least 61 route
  floor visuals.
- [x] Focused/related GdUnit, headless smoke, and Godot MCP runtime checks pass
  under Godot 4.7 / Godot AI MCP 2.9.1.

## Out of Scope

New enemies, new character frame animations, new generated art, reward cache,
new savepoint, SaveSystem schema changes, minimap/fast-travel UI, authored
audio, particles, shaders, Boss2, broader lower-deck biome art replacement, and
post-runoff combat encounter tuning.

## Implementation Notes

- The Story120 slice deliberately follows Story118 combat and Story119
  savepoint with a short traversal beat to avoid dense back-to-back enemy
  encounters.
- The next practical ACT slice after this can be a post-runoff Spark Rat/Coil
  Rat skirmish using existing `AnimatedSprite2D + SpriteFrames` enemies.
- The route objective now prioritizes the active/crossed runoff states before
  the Story119 `Tailrace Relay Secured` handoff.

## Asset Pipeline

No new visual or audio assets were generated. Story120 reuses existing
image-generated/imported assets:

- Service-sluice landing/duct:
  `assets/environment/old_factory_runoff_service_hatch_landing/env_old_factory_runoff_service_hatch_landing_768.png`
- Steam vent hazard:
  `assets/environment/old_factory_steam_vent/factory_steam_vent_hazard.png`
- Route floor:
  `assets/environment/old_factory_route_floor/env_old_factory_route_floor_tile_256x96.png`

The AGENTS frame-animation rule is not triggered because Story120 adds an
environment traversal hazard, not a new player-visible character.

## Test Evidence

- Focused RED: `reports/report_1362/` failed before Story120 diagnostics,
  activation/completion APIs, scene nodes, state, and bounds existed.
- Focused GREEN: `reports/report_1364/` passed Story120 `2/2`, including
  active-only contact, route bounds, local-state persistence, and restore
  backfill.
- Related GREEN: `reports/report_1365/` passed Story120 plus adjacent
  service-sluice/tailrace suites `10/10`.
- Headless smoke:
  `reports/old_factory_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_smoke.log`
  exited `0` and printed `service_sluice_tailrace_relay_runoff_smoke=passed`.
- Godot AI MCP `2.9.1` on Godot `4.7-stable` opened and ran the factory scene
  with helper live, `current_run_errors=[]`, clean current-run game/editor logs,
  Story120 duct/vent edited-scene nodes present, runtime vent node in
  `factory_hazard`, script/hazard id/damage/cooldown correct, and a non-empty
  `640x359` game screenshot response.
- Full evidence is recorded in
  `production/qa/evidence/old-factory-service-sluice-tailrace-relay-runoff-2026-07-10.md`.
- Story230 incoming guard: `reports/report_2382/report_1/results.xml` passed its
  focused case and `reports/report_2383/report_1/results.xml` passed the final
  bounded related set `8/8`. The upgraded Story119 smoke and Godot AI MCP
  3.0.4 run `r190526212-29` confirmed the runoff becomes visible/available but
  stays idle after relay activation, respawn and a no-input placement beyond
  activation x.
