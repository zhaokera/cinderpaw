# Story 042: Old Factory Cache Claim Feedback

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / UI Feedback
> **Type**: Integration + UI/Visual
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

Stories040-041 make the Old Factory return route playable and rewardable, but
the cache claim moment still needed a direct player-facing success read. This
story adds scene-local claim feedback for both Old Factory caches without
expanding into a global economy, HUD toast, inventory UI, or SaveSystem schema.

## Acceptance Criteria

- [x] Claiming `FactoryCombatCache` after the entrance room is cleared updates
  `RouteLabel` to `Cache Claimed +10 Gears`.
- [x] Claiming `FactoryReturnPatrolRewardCache` after the return patrol is
  defeated updates `RouteLabel` to `Return Cache Claimed +15 Gears`.
- [x] Diagnostics expose deterministic claim feedback payloads with cache id,
  reward gears, source, and text for both entrance and return caches.
- [x] Duplicate claims return false and do not overwrite or replay the last
  successful claim feedback.
- [x] The entrance cache keeps
  `cache_id="old_factory_entrance_cache"` and `source="old_factory_combat_cache"`;
  the return cache keeps `cache_id/source="old_factory_return_patrol_cache"`.
- [x] Existing Old Factory route objective, return patrol, service-lift handoff,
  roundtrip, return prompt, and Scrap Roost hub regressions remain green.
- [x] Godot MCP runtime confirms the target scene opens, cache nodes exist,
  RouteLabel feedback is visible after both claim paths, duplicate claims are
  rejected, and game/editor logs have no new errors.

## Out of Scope

- Global currency totals, HUD notifications, inventory screens, SaveSystem
  schema fields, global quest state, new visual assets, new audio, new rooms,
  new enemies, or character frame-animation changes.

## Implementation Notes

- Keep reward claim feedback inside `OldFactoryEntranceScene`, alongside the
  existing scene-local cache reward and route objective diagnostics.
- Persist the last claim feedback in scene-local state for diagnostics and
  scene swap continuity, but do not add project-wide save schema fields.
- Do not call `_refresh_factory_route_objective()` immediately after a
  successful cache claim; that would erase the claim success text before the
  player can read it.

## Test Evidence

- Focused RED:
  - `reports/report_934/` failed the new Story042 test because the entrance
    cache claim still refreshed `RouteLabel` to `Reach Deep Guard` and no
    claim feedback diagnostics existed yet.
- Focused GREEN:
  - `reports/report_935/` passed Story042 `2/2` with `0` errors, failures, or
    orphans on Godot `4.7.stable.official.5b4e0cb0f`.
- Related regression:
  - `reports/report_936/` through `reports/report_945/` passed the targeted
    Old Factory related suite, `22/22` total, covering cache feedback, entrance
    room cache, return patrol reward cache, return patrol ambush, route
    objective, service lift handoff/SceneManager exit, factory roundtrip,
    factory return prompt, and Scrap Roost return hub.
  - `factory_route_return_prompt_test.gd` and
    `scrap_roost_return_hub_runtime_test.gd` still emit known Godot shutdown
    ObjectDB/resource-at-exit warnings after passing; no test failures or
    project script/resource errors were introduced.
- Post-refactor verification:
  - `reports/report_946/` through `reports/report_950/` passed Story042
    focused plus the highest-risk entrance cache, return reward cache, return
    ambush, and service-lift handoff regressions after duplicate-recording was
    tightened.
- Godot MCP runtime evidence:
  - `production/qa/evidence/old-factory-cache-claim-feedback-2026-06-30.md`.

**Status**: [x] Complete.
