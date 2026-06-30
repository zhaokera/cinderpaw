# Story 041: Old Factory Return Patrol Reward Cache

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Scene Management / Visual
> **Type**: Integration + Gameplay Runtime + Visual/Feel
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-30

## Context

**GDD**: `design/gdd/player-abilities.md`,
`design/gdd/exploration-ability-gating.md`,
`design/gdd/scene-management.md`

**Requirements**: `TR-ability-005`, `TR-scene-001`, `TR-scene-003`,
`TR-scene-005`

**ADR Governing Implementation**: ADR-0007 Scene management; ADR-0018 Player
abilities; ADR-0021 Save system.

Story040 makes the Old Factory return visit playable by spawning a one-time
return patrol ambush that locks the service lift until cleared. This story adds
the reward tail for that combat beat: after the return patrol is cleared, a
visible generated reward cache becomes claimable once in the existing Old
Factory route scene.

## Acceptance Criteria

- [x] `res://scenes/factory_route_transition_shell.tscn` contains a visible
  `FactoryReturnPatrolRewardCache` prop using an image-generated transparent
  runtime PNG.
- [x] The return reward cache uses an independent
  `cache_id="old_factory_return_patrol_cache"` and does not reuse the entrance
  room cache's `old_factory_entrance_cache` state.
- [x] While `FactoryReturnSparkRat` is active, the cache remains locked, not
  claimable, and shows `Clear patrol`; Story040 service-lift lockout semantics
  remain intact.
- [x] After `factory_return_patrol_defeated=true`, the cache becomes available
  and claimable with prompt `+15 Gears`.
- [x] Claiming the cache returns a deterministic reward payload with
  `cache_id="old_factory_return_patrol_cache"`, `gears=15`, and
  `source="old_factory_return_patrol_cache"`; duplicate claims return false.
- [x] `get_local_state()` / `set_local_state()` persist
  `factory_return_patrol_reward_cache_claimed` and
  `last_return_patrol_reward_cache_reward` without adding SaveSystem schema
  fields or global quest state.
- [x] Focused and related GdUnit regressions, Godot import, headless smoke, and
  Godot MCP runtime evidence pass with no new project script or resource errors.

## Out of Scope

- New rooms, minimap/savepoint gameplay, fast travel UI, new enemy family,
  Spark Rat tuning, global loot/economy systems, inventory UI, SaveSystem schema
  changes, global quest/objective manager, new service-lift animation, or new
  audio.

## Implementation Notes

- Reuse `FactoryCombatCache` for the claim radius, prompt, visual dimming, and
  once-only claim behavior. Story041 only adds a configurable `reward_source`
  export so the existing entrance cache keeps its legacy payload while the
  return cache has an independent source id.
- Keep return reward state scene-local inside `OldFactoryEntranceScene`.
- Generate the visual prop through image generation on green chroma key, retain
  source/alpha/metadata under `assets/generated/source/`, and import the
  transparent 256x256 runtime PNG through Godot's asset pipeline.

## Test Evidence

- Focused RED:
  - `reports/report_931/` failed `1/1` because the new return cache texture and
    diagnostics API were not present yet.
- Focused GREEN:
  - `reports/report_932/` passed Story041 `3/3` with `0` errors, failures, or
    orphans on Godot `4.7.stable.official.5b4e0cb0f`.
- Related regression:
  - `reports/report_933/` passed `18/18` across Story041, Story040 return
    patrol ambush, service-lift handoff/exit, factory roundtrip, return prompt,
    Scrap Roost hub, and the original entrance room cache.
- Godot import:
  - Godot `4.7.stable.official.5b4e0cb0f` imported
    `env_old_factory_return_patrol_reward_cache_claimable_256.png`,
    the image-generation source, and the alpha source.
- Headless Factory scene smoke:
  - `reports/old_factory_return_patrol_reward_cache_factory_scene_smoke.log`
    exited `0`; keyword scan found no script, parse, invalid-call,
    invalid-access, missing-resource, or resource-load errors. Godot reported
    known headless shutdown ObjectDB/resource-at-exit noise to terminal only.
- Godot MCP runtime evidence:
  - `production/qa/evidence/old-factory-return-patrol-reward-cache-2026-06-30.md`.

**Status**: [x] Complete.
