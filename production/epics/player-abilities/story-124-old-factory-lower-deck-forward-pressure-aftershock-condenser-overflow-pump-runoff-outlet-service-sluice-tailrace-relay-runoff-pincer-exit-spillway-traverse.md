# Story 124: Old Factory Lower Deck Forward Pressure Aftershock Condenser Overflow Pump Runoff Outlet Service Sluice Tailrace Relay Runoff Pincer Exit Spillway Traverse

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Route Traversal
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

**ADR Governing Implementation**: ADR-0004 Collision detection; ADR-0005
Combat state machine; ADR-0007 Scene management; ADR-0018 Player abilities;
ADR-0021 Save system.

Story123 opens the post-pincer exit hatch. Story124 turns that continuation
point into a compact playable spillway traversal: after the hatch is opened, a
short duct/steam-vent section appears to the right, uses the existing
deterministic active-only contact window, and persists crossed state without
adding new enemies, rewards, savepoints, generated art, or systems.

## Acceptance Criteria

- [x] The spillway duct and vent are hidden, unavailable, non-contacting, and
  cannot activate until Story123's pincer exit hatch has opened.
- [x] Once the hatch is opened, the spillway becomes visible and available;
  real positive-x production movement crossing activation x `16560` starts route feedback
  `Cross Tailrace Exit Spillway`.
- [x] The spillway uses hazard id
  `old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_spillway`,
  the existing service-sluice landing texture, steam vent hazard texture,
  damage `8`, and cooldown `1.0`.
- [x] Steam contact/collision is enabled only during the deterministic `active`
  phase and remains disabled during idle, grace, warning, safe, and crossed
  phases.
- [x] Crossing exit x `17040` completes the traversal, disables contact,
  persists
  `factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_spillway_crossed=true`,
  and advances route feedback to `Tailrace Exit Spillway Crossed`.
- [x] Restoring only the Story124 crossed key backfills Story106-123, keeps the
  Story123 hatch opened, keeps pincer enemies/cache/hatch from replaying, and
  preserves the Story119 Tailrace Relay savepoint payload.
- [x] Route bounds are extended for the new pocket: right wall x `17280`,
  camera/background right `17300`, ground right edge `17400`, and at least
  69 route floor visuals.
- [x] Focused/related GdUnit, headless smoke, and Godot MCP runtime checks pass
  under Godot 4.7 / Godot AI MCP 2.9.1.

## Out of Scope

New enemies, reward caches, savepoints, SceneManager transitions, SaveSystem
schema changes, minimap/fast-travel UI, economy tuning, new audio,
particles/shaders, generated art, Boss2, and broader lower-deck biome art
replacement.

## Implementation Notes

- The spillway deliberately reuses the Story120 traversal/hazard pattern so this
  remains a compact route beat, not a new gameplay system.
- Ready state keeps the Story123 route label `Tailrace Runoff Exit Opened`;
  the new objective takes priority only while the spillway is active or crossed.
- Production automatic activation requires the spillway to be available at
  frame start, held `move_right`, initialized prior-x tracking and real positive
  x displacement. Direct unit-level activation APIs retain their authored
  Story124 contract.
- Restored Story124 crossed state backfills the full runoff/service-sluice /
  tailrace / pincer reward / exit hatch chain so old saves do not replay stale
  combat, cache, or hatch beats.

## Asset Pipeline

No new visual or audio assets were generated. Story124 reuses existing
image-generated/imported assets already present in the Godot import pipeline:

- `assets/environment/old_factory_runoff_service_hatch_landing/env_old_factory_runoff_service_hatch_landing_768.png`
- `assets/environment/old_factory_steam_vent/factory_steam_vent_hazard.png`
- `assets/environment/old_factory_route_floor/env_old_factory_route_floor_tile_256x96.png`

## Test Evidence

- Focused RED: `reports/report_1379/` failed before Story124 diagnostics,
  activation, and completion methods existed.
- Focused GREEN: `reports/report_1380/` passed Story124 `2/2`.
- Related GREEN: `reports/report_1381/` passed Story124 plus Story123,
  Story122, Story121, Story120, and Story119 suites `12/12`.
- Headless smoke:
  `reports/old_factory_service_sluice_tailrace_relay_runoff_pincer_exit_spillway_smoke.log`
  exited `0` and printed
  `service_sluice_tailrace_relay_runoff_pincer_exit_spillway_smoke=passed`.
  The log contains only known Godot cleanup-time ObjectDB/resource messages
  after shutdown.
- Godot AI MCP `2.9.1` on Godot `4.7-stable` force-reloaded and ran the
  factory scene, confirmed the edited-scene spillway nodes/hazard id/textures,
  bounds, runtime ready/active/contact/crossed states, local-state persistence,
  game log containing only helper registration, empty editor log, and a
  non-empty `640x359` game screenshot.
- Full evidence is recorded in
  `production/qa/evidence/old-factory-service-sluice-tailrace-relay-runoff-pincer-exit-spillway-2026-07-10.md`.
- Story234 incoming production handoff opens Story123 through one fresh input
  edge and leaves this spillway visible/available but inactive, idle,
  non-contacting and uncrossed. Held input and no-input placement beyond both
  thresholds remain waiting in MCP run `r198694429-38`.
- Story235 production closure requires frame-start state, held `move_right` and
  real positive-x displacement at both thresholds; runs the four-phase steam,
  applies exact physical HP `100 -> 92`, persists crossed state and leaves
  Story126 waiting. Final related `reports/report_2410/results.xml` passed
  `7/7`; MCP run `r200395661-39` completed with clean accepted-run logs.
