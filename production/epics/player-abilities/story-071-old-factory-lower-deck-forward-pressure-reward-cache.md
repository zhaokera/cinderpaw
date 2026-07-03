# Story 071: Old Factory Lower Deck Forward Pressure Reward Cache

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Reward Route
> **Type**: Integration + Gameplay Runtime + UI/Visual
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-03

## Context

**GDD**: `design/gdd/player-abilities.md`,
`design/gdd/exploration-ability-gating.md`,
`design/gdd/feline-combat.md`, `design/gdd/scene-management.md`,
`design/gdd/death-respawn.md`

**Requirements**: `TR-ability-005`, `TR-scene-004`

**ADR Governing Implementation**: ADR-0004 Collision architecture; ADR-0007
Scene management; ADR-0018 Player abilities; ADR-0021 Save system.

Story070 clears the forward pressure counter-ambush. This story adds the payoff:
a visible, once-only reward cache appears after the ambush is defeated, grants a
small deterministic gears reward, and persists scene-locally. The slice improves
the ACT combat/reward rhythm without adding another enemy or extending the
service-lift route.

## Acceptance Criteria

- [x] `factory_route_transition_shell.tscn` contains
  `FactoryLowerDeckForwardPressureRewardCache`, hidden and non-claimable before
  `factory_lower_deck_forward_pressure_counter_ambush_defeated=true`.
- [x] After Story070 is defeated, the cache becomes visible and claimable with
  cache id `old_factory_lower_deck_forward_pressure_reward_cache`, prompt
  `+20 Gears`, and the existing image-generated lower-deck cache texture.
- [x] Claiming succeeds once, returns reward payload
  `gears=20` / `source=old_factory_lower_deck_forward_pressure_reward_cache`,
  records feedback `Forward Pressure Cache Claimed +20 Gears`, and a second
  claim attempt returns `false`.
- [x] Claimed state persists through `OldFactoryEntranceScene.get_local_state()`
  / `set_local_state()` as
  `factory_lower_deck_forward_pressure_reward_cache_claimed=true`.
- [x] Restored completed state keeps the Story070 counter-ambush defeated,
  Story069 pressure traversal inactive/crossed, Story068 clear burst
  `spawn_count=0`, and `FactoryServiceLift` optional with prompt `Call lift`.
- [x] No new visual or audio assets are generated; the reused image-generated
  lower-deck reward cache asset is recorded in asset documentation and QA
  evidence.
- [x] Focused/related GdUnit, headless smoke, and Godot MCP runtime checks pass
  under Godot 4.7 / Godot AI MCP 2.8.3.

## Out of Scope

New enemy families, new room art, SaveSystem schema changes, minimap markers,
global quest state, service-lift route changes, new audio, new particles/shaders,
new generated visual assets, and broader reward economy balancing.

## Implementation Notes

- `OldFactoryEntranceScene` owns Story071 cache availability, claim handling,
  diagnostics, scene-local persistence, and claim feedback.
- The cache reuses `FactoryCombatCache` and the existing lower-deck reward cache
  visual instead of adding another placeholder or single-use custom node.
- The route label remains compatible with Story070 until the cache is claimed;
  the claim feedback becomes the current scene-local reward message.

## Asset Pipeline

No new asset generation is required. Reuse:

- `res://assets/environment/old_factory_lower_deck_skirmish_cache/env_old_factory_lower_deck_skirmish_cache_claimable_256.png`
- `res://src/feature/factory_combat_cache.gd`

Record the new usage in `design/assets/asset-manifest.md`,
`design/assets/entity-inventory.md`, and QA evidence.

## Test Evidence

- Focused GdUnit:
  `tests/unit/gameplay/old_factory_lower_deck_forward_pressure_reward_cache_test.gd`
- Related regression:
  Story071 focused + Story070, Story069, Story068, Story066, and service-lift
  suites.
- Runtime evidence:
  Headless smoke and Godot MCP runtime checks must confirm scene load, cache node
  presence, texture path, visible/claimable state, once-only claim persistence,
  service-lift prompt, clean logs, and a non-empty screenshot with the reward
  cache visible.

## Verification Summary

- RED focused: `reports/report_1110/` failed as expected before the Story071
  cache APIs and diagnostics existed.
- Focused GREEN: `reports/report_1111/` passed Story071 `2/2`.
- Related GREEN: `reports/report_1112/` passed Story071, Story070, Story069,
  Story068, Story066, and service-lift SceneManager exit suites `12/12`.
- Headless Factory smoke:
  `reports/old_factory_forward_pressure_reward_cache_smoke.log` exited `0`
  with no project script/parse/invalid-call/access/missing-resource/resource-load
  errors by keyword scan; only the known Godot cleanup-time resource message
  remained.
- Godot AI MCP `2.8.3` runtime evidence confirmed helper live, reward cache
  presence, image-generated texture path, visible/claimable state after Story070
  defeated, once-only `+20 Gears` claim, persisted local flag, no prerequisite
  replay, service lift `Call lift`, clean logs, and non-empty screenshot
  metadata `960x539`.
- Full evidence:
  `production/qa/evidence/old-factory-forward-pressure-reward-cache-2026-07-03.md`.

**Status**: [x] Complete.
