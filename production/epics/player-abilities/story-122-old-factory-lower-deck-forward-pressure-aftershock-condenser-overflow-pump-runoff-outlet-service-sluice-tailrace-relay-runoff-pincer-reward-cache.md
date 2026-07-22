# Story 122: Old Factory Lower Deck Forward Pressure Aftershock Condenser Overflow Pump Runoff Outlet Service Sluice Tailrace Relay Runoff Pincer Reward Cache

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Reward
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

Story121 clears the post-runoff Spark Rat + Coil Rat pincer. Story122 adds a
short reward payoff immediately after that ACT beat so the player gets a clear
runtime confirmation that the pressure pocket is complete without adding
another enemy, hazard, gate, or savepoint.

## Acceptance Criteria

- [x] The reward cache is unavailable, hidden, and unclaimable until the
  Story121 pincer is fully cleared.
- [x] The cache remains hidden during an active pincer and while only one of
  the two pincer enemies is defeated.
- [x] Once both pincer enemies are defeated, the cache at `Vector2(15460, 410)`
  becomes visible and claimable while route feedback remains
  `Tailrace Runoff Pincer Cleared`.
- [x] The cache uses `factory_combat_cache.gd`, cache id/source
  `old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_reward_cache`,
  `20` gears, claim radius `96`, and available prompt `+20 Gears`.
- [x] Claiming the cache succeeds once, rejects duplicate claims, persists
  `factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_reward_cache_claimed=true`,
  records the reward/feedback payload, and updates route feedback to
  `Tailrace Runoff Pincer Cache Claimed +20 Gears`.
- [x] Restoring only the new claimed flag backfills the Story106-121 chain,
  hides both pincer enemies, keeps the pincer cleared, and preserves the
  Story119 Tailrace Relay savepoint payload.
- [x] The existing Story121 route bounds remain sufficient: right wall x
  `15580`, camera/background right `15600`, ground right edge x `15700`, and
  63 route floor visuals.
- [x] Focused/related GdUnit, headless smoke, and Godot MCP runtime checks pass
  under Godot 4.7 / Godot AI MCP 2.9.1.

## Out of Scope

New enemies, new frame animations, new hazards, new gates, new savepoint,
SaveSystem schema changes, new generated art, economy rebalance,
minimap/fast-travel UI, authored audio, particles/shaders, Boss2, and broader
lower-deck biome art replacement.

## Implementation Notes

- The slice deliberately uses the pre-authored reward cache node already placed
  after Story121. It completes the existing cache wiring instead of introducing
  a second reward system.
- Route objective priority is `pincer active` -> `pincer reward cache claimed`
  -> `pincer cleared`, so active combat remains visible while claim completion
  becomes the final route handoff.
- Restored claimed state backfills the pincer and previous service-sluice /
  tailrace chain to keep old runtime saves from landing behind stale gates.

## Asset Pipeline

No new visual or audio assets were generated. Story122 reuses the existing
image-generated/imported lower-deck reward cache texture:

- `assets/environment/old_factory_lower_deck_skirmish_cache/env_old_factory_lower_deck_skirmish_cache_claimable_256.png`

The cache texture was already imported through the Godot asset pipeline and is
referenced by the `factory_combat_cache.gd` node in
`scenes/factory_route_transition_shell.tscn`.

## Test Evidence

- Focused RED: `reports/report_1370/` failed before Story122 diagnostics,
  claim API, state persistence, and cache sync were complete.
- Focused GREEN: `reports/report_1371/` passed Story122 `2/2`.
- Related GREEN: `reports/report_1372/` passed Story122 plus adjacent
  Story121, Story120, and Story115 suites `8/8`.
- Headless smoke:
  `reports/old_factory_service_sluice_tailrace_relay_runoff_pincer_reward_cache_smoke.log`
  exited `0` and printed
  `service_sluice_tailrace_relay_runoff_pincer_reward_cache_smoke=passed`.
  The log contains only known Godot cleanup-time ObjectDB/resource messages
  after shutdown.
- Godot AI MCP `2.9.1` on Godot `4.7-stable` reloaded and ran the factory
  scene with helper live, confirmed the edited-scene reward cache node,
  `factory_combat_cache.gd`, cache id/source, reward `20`, prompt
  `+20 Gears`, runtime visible/claimable state after pincer clear, once-only
  claim, route feedback `Tailrace Runoff Pincer Cache Claimed +20 Gears`,
  local-state persistence, clean current-run game/editor logs, and a non-empty
  `960x539` game screenshot.
- Full evidence is recorded in
  `production/qa/evidence/old-factory-service-sluice-tailrace-relay-runoff-pincer-reward-cache-2026-07-10.md`.
- Story232 incoming production handoff: real shared attacks clear Story121 and
  reveal this cache as visible, available, in range and claimable with
  `+20 Gears`. Held pre-clear `interact` leaves claimed false and reward /
  feedback payloads empty in MCP run `r194847761-35`. Fresh production claim
  routing remains the next bounded Story.
