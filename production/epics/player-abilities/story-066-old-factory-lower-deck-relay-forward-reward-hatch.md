# Story 066: Old Factory Lower Deck Relay Forward Reward Hatch

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Route Reward Gate
> **Type**: Integration + Gameplay Runtime + UI/Visual
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-02

## Context

**GDD**: `design/gdd/player-abilities.md`,
`design/gdd/exploration-ability-gating.md`,
`design/gdd/feline-combat.md`, `design/gdd/scene-management.md`,
`design/gdd/death-respawn.md`

**Requirements**: `TR-ability-005`, `TR-scene-004`

**ADR Governing Implementation**: ADR-0004 Collision architecture; ADR-0007
Scene management; ADR-0018 Player abilities; ADR-0021 Save system.

Story065 adds a short relay-forward combat trial after the lower-deck breach
relay is repaired. This story adds the immediate playable payoff after that
trial: a one-time reward cache and a local forward hatch that gives the player a
clear reward and next-route boundary without expanding service-lift routing or
global save schema.

## Acceptance Criteria

- [x] `FactoryLowerDeckRelayForwardRewardCache` and
  `FactoryLowerDeckForwardHatch` are authored in
  `factory_route_transition_shell.tscn`.
- [x] Both nodes are locked/hidden until
  `factory_lower_deck_post_relay_trial_defeated=true`.
- [x] The relay-forward cache becomes visible and claimable after the trial is
  cleared with cache/source `old_factory_lower_deck_relay_forward_cache`,
  prompt `+20 Gears`, and deterministic reward `20` gears.
- [x] Claiming the cache succeeds once, records
  `factory_lower_deck_relay_forward_reward_cache_claimed=true`, writes
  `Relay Forward Cache Claimed +20 Gears` route feedback, and rejects duplicate
  claims without mutating adjacent cache flags.
- [x] The forward hatch is visible after the trial clear, prompts
  `Claim relay cache` until the cache is claimed, then becomes available with
  `Open forward hatch`.
- [x] Opening the forward hatch succeeds once, persists
  `factory_lower_deck_forward_hatch_opened=true`, disables local collision, and
  updates route feedback to `Lower Deck Forward Hatch Opened`.
- [x] Restored state keeps the cache claimed, hatch opened, post-relay trial
  defeated, and breach relay activated without replaying relay VFX/audio or
  Story061-065 combat prerequisites.
- [x] `FactoryServiceLift` remains optional with prompt `Call lift`; Story066
  does not change service-lift destinations or SceneManager contracts.
- [x] No new visual or audio assets are generated; the story reuses existing
  image-generated lower-deck cache and deep bulkhead art and records the new
  usage in the asset manifest and entity inventory.
- [x] Focused/related GdUnit, headless smoke, and Godot MCP runtime checks pass
  under Godot 4.7 / Godot AI MCP 2.8.3.

## Out of Scope

New lower-deck room art, new enemy family art, authored SFX, minimap markers,
fast travel, SaveSystem schema expansion, global quest state, service-lift route
changes, broader lower-deck rooms, and boss content.

## Implementation Notes

- `OldFactoryEntranceScene` owns scene-local flags, claim/open APIs,
  diagnostics, local-state persistence, route feedback, and collision toggling.
- The reward cache reuses `FactoryCombatCache` and remains independent from the
  Story053 lower-deck cache, Story056 shortcut cache, and Story051 overdrive
  cache state.
- The forward hatch reuses `FactoryDeepRouteEndpoint` so interaction radius,
  prompt state, endpoint signal, unlock VFX, and one-shot activation behavior
  match earlier Old Factory gates.

## Asset Pipeline

No new visual or audio asset was generated. Story066 intentionally reuses
already imported image-generated assets:

- `assets/environment/old_factory_lower_deck_skirmish_cache/env_old_factory_lower_deck_skirmish_cache_claimable_256.png`
- `assets/environment/old_factory_lower_deck_deep_bulkhead/env_old_factory_lower_deck_deep_bulkhead_closed_256.png`
- `assets/environment/old_factory_deep_route/vfx/factory_deep_route_unlock_spark.png`

The new usage is recorded in `design/assets/asset-manifest.md`,
`design/assets/entity-inventory.md`, and QA evidence.

## Test Evidence

- RED focused:
  - `reports/report_1089/` failed as expected before Story066 diagnostics,
    claim/open APIs, and scene nodes existed.
- Focused GREEN:
  - `reports/report_1090/` passed Story066 `2/2` with `0` errors, failures,
    skipped, flaky, and orphans.
- Related regression:
  - `reports/report_1091/` passed Story066, Story065 post-relay combat,
    breach relay/reward route, lower-deck cache regressions, deep bulkhead, and
    service-lift SceneManager exit suites `18/18` with `0` errors, failures,
    skipped, flaky, and orphans.
- Headless smoke:
  - `reports/old_factory_lower_deck_relay_forward_reward_hatch_smoke.log`
    exited `0`; keyword scan found no project script, parse, invalid-call,
    invalid-access, missing-resource, or resource-load errors. Godot retained
    only exit-time resource cleanup noise.
- MCP runtime:
  - Godot AI MCP `2.8.3` confirmed helper live in
    `res://scenes/factory_route_transition_shell.tscn`.
  - Runtime probe confirmed cache/hatch node presence, cache id/source/gears,
    hatch endpoint id and prompt contract, real claim/open path ending at
    `Lower Deck Forward Hatch Opened`, service lift still `Call lift`, no relay
    VFX/audio replay, clean game log, and non-empty game framebuffer capture.
  - Full evidence:
    `production/qa/evidence/old-factory-lower-deck-relay-forward-reward-hatch-2026-07-02.md`.

**Status**: [x] Complete.
