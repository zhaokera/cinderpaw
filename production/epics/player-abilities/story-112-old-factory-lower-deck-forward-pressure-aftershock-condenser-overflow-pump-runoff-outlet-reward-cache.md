# Story 112: Old Factory Lower Deck Forward Pressure Aftershock Condenser Overflow Pump Runoff Outlet Reward Cache

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Route Reward
> **Type**: Integration + Gameplay Runtime + UI/Visual
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-22

## Context

**GDD**: `design/gdd/player-abilities.md`,
`design/gdd/exploration-ability-gating.md`,
`design/gdd/feline-combat.md`, `design/gdd/scene-management.md`,
`design/gdd/death-respawn.md`

**Requirements**: `TR-scene-004`, `TR-explore-005`, `TR-respawn-002`

**ADR Governing Implementation**: ADR-0004 Collision detection; ADR-0005 Combat
state machine; ADR-0007 Scene management; ADR-0018 Player abilities; ADR-0021
Save system.

Story111 leaves the player after clearing the runoff outlet Spark Rat.
Story112 adds a small reward beat and handoff: a reused factory cache appears,
pays `20` gears once, then reveals a reused service hatch that opens the next
forward route pocket.

## Acceptance Criteria

- [x] `FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffOutletRewardCache`
  exists in `factory_route_transition_shell.tscn`, starts hidden, is placed at
  x `9520`, and uses cache id
  `old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_reward_cache`.
- [x] The cache stays locked until
  `factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_spark_rat_defeated=true`;
  locked diagnostics report unavailable/hidden and claim attempts return
  `false`.
- [x] Once Story111 is cleared, the cache becomes visible, exposes prompt
  `+20 Gears`, and route feedback remains `Runoff Outlet Spark Rat Cleared`.
- [x] Claiming the cache succeeds once, records `20` gears with the cache id as
  the reward source, emits `Runoff Outlet Cache Claimed +20 Gears`, and then
  blocks repeat claims.
- [x] `FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffOutletServiceHatch`
  appears only after the cache is claimed, uses endpoint id
  `old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_hatch`,
  and exposes prompt `Open Runoff Outlet Service Hatch`.
- [x] Opening the service hatch succeeds once, advances route feedback to
  `Runoff Outlet Service Hatch Open`, and disables the hatch blocking
  collision.
- [x] Route bounds extend to right wall x `10220` and camera limit right
  `10240`; floor coverage remains at least `42` tiles / `12800` px wide.
- [x] Restoring the service hatch opened state backfills the Story106-111
  overflow pump runoff chain so prior cache, duct, exit, outlet, and skirmish
  states do not replay.
- [x] Focused/related GdUnit, headless smoke, and Godot MCP runtime checks pass
  under Godot 4.7 / Godot AI MCP 3.0.4.

## Out of Scope

New enemy, new savepoint, minimap, fast travel, authored audio, particles,
shaders, new generated art, broader lower-deck visual replacement, and new
player or enemy frame animations.

## Implementation Notes

- Story112 adds no new combatant; it is a payoff and route handoff slice after
  the Story111 Spark Rat clears.
- `set_local_state` restores cache-claimed and service-hatch-opened flags and
  backfills the Story106-111 route chain when a deeper state is restored.
- Route objective priority now checks active forward-pressure states at a flat
  function level, then prefers Story112 service hatch opened/cache claimed
  states before the Story111 cleared and Story110 crossed handoff states.
- The implementation reuses `factory_combat_cache.gd` for the cache and
  `factory_deep_route_endpoint.gd` for the service hatch.

## Asset Pipeline

No new visual asset was generated for Story112.

Reused imported visual assets:

- Reward cache:
  `assets/environment/old_factory_lower_deck_skirmish_cache/env_old_factory_lower_deck_skirmish_cache_claimable_256.png`
- Service hatch:
  `assets/environment/old_factory_lower_deck_deep_bulkhead/env_old_factory_lower_deck_deep_bulkhead_closed_256.png`
- Unlock VFX:
  `assets/environment/old_factory_deep_route/vfx/factory_deep_route_unlock_spark.png`
- Floor tiles:
  existing factory route floor tile texture already used by the shell scene.

The reused assets were previously imported through the Godot asset pipeline.
Story112 does not introduce a new player-visible character, so the
`AnimatedSprite2D + SpriteFrames` character rule is not newly exercised here.

## Test Evidence

- Focused RED: `reports/report_1311/` failed because Story112 diagnostics,
  cache claim, and service hatch APIs did not exist yet.
- Focused GREEN: `reports/report_1319/` passed `2/2`.
- Related GREEN: `reports/report_1320/` passed `8/8` across Story112,
  Story111, Story110, and Story109.
- Final post-format focused rerun: `reports/report_1321/` passed `2/2`.
- Final post-format related rerun: `reports/report_1322/` passed `8/8`.
- Headless smoke:
  `reports/old_factory_overflow_pump_runoff_outlet_reward_cache_smoke.log`
  exited `0`. The log had no Story112 script, parse, invalid-call/access,
  missing-resource, or resource-load errors; it only reported standard Godot
  process-exit resource cleanup noise.
- Godot MCP:
  Godot AI MCP `2.9.1` on Godot `4.7-stable` confirmed disk scene reload,
  edited scene cache and hatch nodes, cache/hatch scripts, IDs, prompts, reward
  amount, right wall x `10220`, camera limit right `10240`, runtime helper
  live, `current_run_errors=[]`, successful runtime cache claim and hatch open
  eval, current-run game log without errors, no new editor log rows after
  cursor `9`, and a non-empty `960x539` game screenshot showing the claimed
  cache and opened hatch.
- Story223 production handoff: canonical RED `report_2351` exposed the missing
  nearest-cache interaction route; focused `report_2352` passed `1/1`, related
  `report_2353` passed `9/9`, and Factory smoke exited `0`. MCP 3.0.4 accepted
  run `r167485675-13` proved held pre-clear input and no-input in-range
  placement remain non-consuming, while fresh `interact` grants exact
  `20`-gear id/source/feedback and leaves the service hatch visible, blocking
  and unopened. Story113 remained unavailable/inactive/hidden.
- Story224 production hatch handoff: final focused `report_2357` passed `1/1`,
  related `report_2360` passed `10/10`, and marker-backed Factory smoke exited
  `0`. MCP 3.0.4 accepted run `r169905919-15` proved held approach input stays
  stale, fresh `interact` opens the hatch once, collision/prompt disable, unlock
  VFX remains single-shot, and the lifted visual reads at `(48,-136)`, `6deg`,
  effective z `23` before Story113 starts.

## Dependencies

- Depends on: Story111 Old Factory Lower Deck Forward Pressure Aftershock
  Condenser Overflow Pump Runoff Outlet Skirmish
- Unlocks: deeper Old Factory route content beyond the runoff outlet service
  hatch

## Verification Summary

Story112 followed thin TDD: focused RED `reports/report_1311/` failed before
runtime support existed, focused GREEN `reports/report_1319/` passed `2/2`, and
related GREEN `reports/report_1320/` passed `8/8`. After a formatting-only
indentation cleanup, focused `reports/report_1321/` passed `2/2` and related
`reports/report_1322/` passed `8/8`. Headless smoke exited `0`. Godot MCP
runtime validation passed under Godot 4.7. Story223 adds current Godot AI MCP
3.0.4 evidence for stale/fresh production reward input and the unopened service
hatch boundary. Story224 adds current production hatch opening/readability and
one-shot VFX evidence without changing Story112 persistence or reward behavior.
