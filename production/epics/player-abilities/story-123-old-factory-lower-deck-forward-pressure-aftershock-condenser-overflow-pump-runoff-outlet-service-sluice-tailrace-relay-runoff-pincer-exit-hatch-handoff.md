# Story 123: Old Factory Lower Deck Forward Pressure Aftershock Condenser Overflow Pump Runoff Outlet Service Sluice Tailrace Relay Runoff Pincer Exit Hatch Handoff

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Route Handoff
> **Type**: Integration + Gameplay Runtime + UI/Visual
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

Story122 claims the post-pincer reward cache. Story123 converts that payoff
into forward route intent: after the cache is claimed, a short exit hatch
appears to the right, opens once, clears collision, and leaves the player with
a visible continuation point without adding new enemies, hazards, rewards, or
savepoints.

## Acceptance Criteria

- [x] The hatch is hidden, unavailable, non-blocking, and cannot be opened until
  Story122's pincer reward cache has been claimed.
- [x] Once the cache is claimed, the hatch at `Vector2(16080, 392)` becomes
  visible, available, interaction-enabled, and collision-blocking.
- [x] The hatch uses `factory_deep_route_endpoint.gd`, endpoint id
  `old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_hatch`,
  the existing deep-bulkhead texture, unlock spark VFX, activation radius `96`,
  and prompts `Claim pincer cache` -> `Open Tailrace Exit` ->
  `Tailrace Exit Open`.
- [x] Opening succeeds once in range, rejects duplicate opens, plays one unlock
  VFX, clears collision blocking, disables availability, and updates route
  feedback to `Tailrace Runoff Exit Opened`.
- [x] Restoring only
  `factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_hatch_opened=true`
  backfills Story106-122, keeps the Story122 cache claimed, keeps the Story121
  pincer cleared and enemies hidden, and preserves the Story119 Tailrace Relay
  savepoint payload.
- [x] Route bounds are extended for the new short handoff: right wall x
  `16480`, camera/background right `16500`, ground right edge `16600`, and at
  least 66 route floor visuals.
- [x] Focused/related GdUnit, headless smoke, and Godot MCP runtime checks pass
  under Godot 4.7 / Godot AI MCP 2.9.1.

## Out of Scope

New enemies, hazards, reward caches, savepoints, SceneManager transitions,
SaveSystem schema changes, minimap/fast-travel UI, economy tuning, new audio,
particles/shaders, generated art, Boss2, and broader lower-deck biome art
replacement.

## Implementation Notes

- The hatch deliberately reuses the existing endpoint script and imported
  deep-bulkhead hatch art so the slice remains a route handoff, not a new
  gameplay system.
- Route objective priority now advances from Story122 cache claimed to
  `Open Tailrace Runoff Exit`, while the immediate claim interaction still
  shows `Tailrace Runoff Pincer Cache Claimed +20 Gears`.
- Restored Story123 opened state backfills the full runoff/service-sluice /
  tailrace / pincer reward chain so old saves do not replay stale combat or
  cache beats.

## Asset Pipeline

No new visual or audio assets were generated. Story123 reuses existing
image-generated/imported assets already present in the Godot import pipeline:

- `assets/environment/old_factory_lower_deck_deep_bulkhead/env_old_factory_lower_deck_deep_bulkhead_closed_256.png`
- `assets/environment/old_factory_deep_route/vfx/factory_deep_route_unlock_spark.png`
- `assets/environment/old_factory_route_floor/env_old_factory_route_floor_tile_256x96.png`

## Test Evidence

- Focused RED: `reports/report_1373/` failed before Story123 diagnostics and
  open APIs existed.
- Focused GREEN: `reports/report_1377/` passed Story123 `2/2` after the final
  clean scene patch.
- Related GREEN: `reports/report_1378/` passed Story123 plus Story122,
  Story121, Story120, Story119, and Story116 suites `12/12`.
- Headless smoke:
  `reports/old_factory_service_sluice_tailrace_relay_runoff_pincer_exit_hatch_smoke.log`
  exited `0` and printed
  `service_sluice_tailrace_relay_runoff_pincer_exit_hatch_smoke=passed`.
  The log contains only known Godot cleanup-time ObjectDB/resource messages
  after shutdown.
- Godot AI MCP `2.9.1` on Godot `4.7-stable` force-reloaded and ran the
  factory scene, confirmed the edited-scene hatch node/script/id/prompts,
  right-wall/camera bounds, runtime visible/available/blocking state after the
  pincer cache claim, once-only open, collision clear, route feedback
  `Tailrace Runoff Exit Opened`, local-state persistence, game log containing
  only helper registration, empty editor log, and a non-empty `960x539` game
  screenshot.
- Full evidence is recorded in
  `production/qa/evidence/old-factory-service-sluice-tailrace-relay-runoff-pincer-exit-hatch-2026-07-10.md`.
- Story233 incoming production handoff: a fresh cache-claim edge makes this
  hatch visible, available, monitoring, monitorable and collision-blocking at
  `(16080,392)`, but held input leaves it unopened with zero unlock VFX in MCP
  run `r196920539-37`.
- Story234 production closure: stale held and released no-input states remain
  closed. One fresh production edge opens the hatch once, clears collision,
  hides the world prompt, plays one unlock spark and applies the authored child
  pose `(48,-136)`, `6deg`, effective z `23` in MCP run `r198694429-38`.
