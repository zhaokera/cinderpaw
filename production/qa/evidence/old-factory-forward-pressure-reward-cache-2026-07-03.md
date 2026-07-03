# QA Evidence: Old Factory Forward Pressure Reward Cache

Date: 2026-07-03
Engine: Godot 4.7
MCP: Godot AI 2.8.3
Story: `production/epics/player-abilities/story-071-old-factory-lower-deck-forward-pressure-reward-cache.md`

## Scope

Story071 adds a once-only reward cache after Story070's forward pressure
counter-ambush is cleared. The slice mounts
`FactoryLowerDeckForwardPressureRewardCache`, grants deterministic `+20 Gears`,
and persists scene-local claim state without SaveSystem schema changes,
service-lift route changes, or global quest state.

## Asset Pipeline

No new visual or audio assets were generated for this story.

- Reward cache reuse:
  `res://assets/environment/old_factory_lower_deck_skirmish_cache/env_old_factory_lower_deck_skirmish_cache_claimable_256.png`
  via `FactoryLowerDeckForwardPressureRewardCache`.
- Runtime script reuse:
  `res://src/feature/factory_combat_cache.gd`.

The reused cache prop was originally created through image generation and is
recorded in `design/assets/asset-manifest.md` and
`design/assets/entity-inventory.md`.

## Automated Verification

- RED focused: `reports/report_1110/` failed as expected before Story071 cache
  APIs and diagnostics existed.
- Focused GREEN: `reports/report_1111/` passed Story071 `2/2` with no errors,
  failures, skips, flaky cases, or orphans.
- Related regression: `reports/report_1112/` passed Story071, Story070,
  Story069, Story068, Story066, and service-lift SceneManager exit suites
  `12/12` with no errors, failures, skips, flaky cases, or orphans.
- Headless scene smoke:
  `reports/old_factory_forward_pressure_reward_cache_smoke.log` exited `0`.
  Keyword scan found no project script, parse, invalid-call, invalid-access,
  missing-resource, or resource-load errors. The log retains only the known
  Godot cleanup-time `resources still in use` exit message.

## MCP Runtime Verification

Godot AI MCP `2.8.3` on Godot `4.7-stable` launched
`res://scenes/factory_route_transition_shell.tscn` with `autosave=false` and
confirmed helper live.

- Runtime scene tree contains `FactoryLowerDeckForwardPressureRewardCache`.
- Before Story070 is defeated, the cache is present but hidden, unavailable, and
  non-claimable.
- After restoring Story070 defeated state, the cache becomes visible and
  claimable with cache id
  `old_factory_lower_deck_forward_pressure_reward_cache`, prompt `+20 Gears`,
  and texture
  `res://assets/environment/old_factory_lower_deck_skirmish_cache/env_old_factory_lower_deck_skirmish_cache_claimable_256.png`.
- Claiming once returned `true`, recorded reward payload
  `gears=20` / `source=old_factory_lower_deck_forward_pressure_reward_cache`,
  route feedback `Forward Pressure Cache Claimed +20 Gears`, and local flag
  `factory_lower_deck_forward_pressure_reward_cache_claimed=true`.
- A second claim attempt returned `false`.
- Restored claimed state kept Story070 defeated, Story069 crossed/inactive,
  Story068 clear burst `spawn_count=0`, and `FactoryServiceLift` prompt
  `Call lift`.
- Game log contained only the MCP helper registration line; editor log was
  empty.
- MCP game screenshot metadata was non-empty (`960x539`) and visibly showed the
  reward cache after the counter-ambush clear state.
