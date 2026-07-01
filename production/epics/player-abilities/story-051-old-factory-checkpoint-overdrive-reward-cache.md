# Story 051: Old Factory Checkpoint Overdrive Reward Cache

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Scene Management / Visual
> **Type**: Integration + Gameplay Runtime + UI/Visual
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-01

## Context

**GDD**: `design/gdd/player-abilities.md`,
`design/gdd/exploration-ability-gating.md`,
`design/gdd/scene-management.md`

**Requirements**: `TR-ability-005`, `TR-scene-001`, `TR-scene-003`,
`TR-scene-005`

**ADR Governing Implementation**: ADR-0007 Scene management; ADR-0018 Player
abilities; ADR-0021 Save system.

Stories049-050 make the Old Factory checkpoint overdrive duo a readable final
service-lift combat gate. This story adds the immediate payoff for clearing that
fight: a generated reward cache appears in the same route scene, can be claimed
once for a deterministic gear payload, and gives a clear RouteLabel success read.

## Acceptance Criteria

- [x] `res://scenes/factory_route_transition_shell.tscn` contains
  `FactoryCheckpointOverdriveRewardCache`, a visible cache prop using an
  image-generated transparent 256x256 runtime PNG.
- [x] The cache uses independent state:
  `cache_id/source="old_factory_checkpoint_overdrive_cache"` and does not reuse
  the entrance or return-patrol cache state.
- [x] While the overdrive duo is not fully cleared, the cache remains locked,
  not claimable, and shows `Clear overdrive duo`; service-lift lock/unlock
  behavior from Story049 remains intact.
- [x] After both overdrive Spark Rats are defeated, the cache becomes available
  and claimable with prompt `+25 Gears`.
- [x] Claiming the cache returns a deterministic reward payload with
  `cache_id="old_factory_checkpoint_overdrive_cache"`, `gears=25`, and
  `source="old_factory_checkpoint_overdrive_cache"`; duplicate claims return
  false.
- [x] Claiming the cache updates `RouteLabel` to
  `Overdrive Cache Claimed +25 Gears`; duplicate claims do not overwrite or
  replay the last successful claim feedback.
- [x] `get_local_state()` / `set_local_state()` persist
  `factory_checkpoint_overdrive_reward_cache_claimed`,
  `last_checkpoint_overdrive_reward_cache_reward`, and
  `last_checkpoint_overdrive_reward_cache_claim_feedback` without adding
  SaveSystem schema fields or global currency state.
- [x] Focused and related GdUnit regressions, Godot import, and Godot MCP
  runtime evidence pass with no new project script or resource errors.

## Out of Scope

New enemies, new rooms, service-lift behavior changes, minimap/savepoint
expansion, global economy totals, inventory/HUD currency screens, SaveSystem
schema changes, Spark Rat tuning, overdrive pacing changes, new SFX, or service
lift animation.

## Implementation Notes

- Reuse `FactoryCombatCache` for the claim radius, prompt, visual dimming, and
  once-only claim behavior.
- Keep reward cache state scene-local inside `OldFactoryEntranceScene`.
- Do not block the service lift behind reward collection; the cache is optional
  payoff after the duo is cleared.
- Do not call `_refresh_factory_route_objective()` immediately after a
  successful cache claim, so the player can read the reward feedback.

## Asset Pipeline

- New generated source:
  `assets/generated/source/old_factory_checkpoint_overdrive_reward_cache_imagegen_20260701.png`.
- Alpha source:
  `assets/generated/source/old_factory_checkpoint_overdrive_reward_cache_alpha_20260701.png`.
- Metadata:
  `assets/generated/source/old_factory_checkpoint_overdrive_reward_cache_imagegen_20260701.json`.
- Runtime PNG:
  `assets/environment/old_factory_checkpoint_overdrive_reward_cache/env_old_factory_checkpoint_overdrive_reward_cache_claimable_256.png`.
- Manifest row:
  `design/assets/asset-manifest.md`.

## Test Evidence

- Focused RED:
  - `reports/report_1022/` failed because
    `get_factory_checkpoint_overdrive_reward_cache_diagnostics()` and
    `try_claim_factory_checkpoint_overdrive_reward_cache()` did not exist.
- Import correction:
  - `reports/report_1023/` failed because the new PNG had not yet been imported
    as a Godot `Texture2D`.
- Focused GREEN:
  - `reports/report_1024/` passed Story051 `2/2` with `0` errors, failures, or
    orphans on Godot `4.7.stable.official.5b4e0cb0f`.
- Related regression, headless smoke, and MCP runtime evidence:
  - `reports/report_1025/` passed `16/16` across Story051, overdrive duo,
    cache feedback, return-patrol reward cache, service-lift handoff/exit, and
    Factory route roundtrip.
  - `reports/old_factory_checkpoint_overdrive_reward_cache_smoke.log` exited
    `0`; keyword scan found no project script, parse, invalid-call,
    invalid-access, missing-resource, or resource-load errors in the log file.
    Godot still printed known cleanup-time ObjectDB/resource-at-exit noise to
    terminal.
  - `production/qa/evidence/old-factory-checkpoint-overdrive-reward-cache-2026-07-01.md`.

**Status**: [x] Complete.
