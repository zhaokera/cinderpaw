# Story 011: Old Factory Deep Guard Activation Pacing

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Core / Feature / Gameplay Runtime / Presentation Integration
> **Type**: Integration + Gameplay Runtime + Combat Pacing
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-26

## Context

**GDD**: `design/gdd/player-abilities.md`,
`design/gdd/exploration-ability-gating.md`,
`design/gdd/scene-management.md`

**Requirements**: `TR-ability-005`, `TR-explore-001`,
`TR-explore-002`, `TR-explore-006`, `TR-scene-001`

**ADR Governing Implementation**: ADR-0018 Player abilities; ADR-0007 Scene
management; ADR-0021 Save system architecture; ADR-0004 Collision architecture.

Story010 added a second Rat Minion and a generated deep-route endpoint inside
the Old Factory entrance room. The first implementation made the second guard
start chasing immediately, turning the route into an instant two-enemy brawl.
This story turns that into a readable second encounter: the deep guard is
visible, inert, and non-colliding until the entrance guard is defeated and the
player crosses the deeper route pressure point.

This remains a single-room Old Factory micro-slice and does not add a new enemy
family or new visual asset.

## Acceptance Criteria

- [x] `FactoryDeepGuardRatMinion` remains visible at scene start but has no
  attack target, no physics/process ticking, and no blocking collision until
  activated.
- [x] Calling `try_activate_factory_deep_guard()` before the entrance encounter
  is cleared returns `false`, even if the player is already past the trigger x.
- [x] Calling `try_activate_factory_deep_guard()` after the entrance encounter
  is cleared but before the player crosses `deep_guard_activation_x` returns
  `false`.
- [x] After the entrance guard is defeated and the player crosses the deeper
  pressure point, deep guard activation succeeds exactly once, restores target,
  process/physics, and Rat Minion collision layer/mask.
- [x] Deep guard activation state persists through `get_local_state()` /
  `set_local_state()` without unlocking or activating the endpoint by itself.
- [x] Defeating the activated deep guard still unlocks the existing
  `FactoryDeepRouteEndpoint`, and endpoint activation remains once-only.
- [x] Diagnostics expose `deep_guard_activated`,
  `deep_guard_activation_x`, `deep_guard_has_target`,
  `deep_guard_physics_enabled`, and `deep_guard_process_enabled` for tests and
  MCP probes.
- [x] Story007-010 Old Factory contracts remain valid: entrance combat, room
  cache, steam vent hazard, generated endpoint, Rat Minion frame animation, and
  endpoint unlock flow do not regress.
- [x] RED/GREEN focused test, related regression, headless smoke, and Godot MCP
  runtime screenshot/log evidence are recorded.

## Out of Scope

- New enemy family, new Rat Minion animation pack, new generated prop, Boss2,
  hidden-boss combat, savepoints, minimap, multi-room Old Factory layout,
  shortcuts, or new player abilities.
- Skill-tree UI, currency economy balancing, inventory screens, quest journal,
  or cross-process SaveSystem schema changes.
- Camera redesign, shader work, audio-system changes, final authored art
  replacement, or SceneManager architecture rewrite.

## Implementation Notes

- Keep `FactoryDeepGuardRatMinion` in the existing registered factory scene so
  the player can see the future threat without fighting it during the entrance
  encounter.
- Add scene-local activation state instead of a new Autoload or SaveSystem
  schema field. The existing ADR-0007 local state handoff now includes
  `factory_deep_guard_activated`.
- Initial inactive deep guard state clears attack target, disables process and
  physics, and temporarily sets collision layer/mask to `0`.
- Activation restores the current Rat Minion runtime contract by setting the
  player target, enabling process and physics, and restoring layer `2` / mask
  `17`.
- No new visual asset was required. The story reuses the Story010 generated
  endpoint prop and existing Rat Minion `AnimatedSprite2D + SpriteFrames`
  frames.

## Test Evidence

**Required evidence**:

- `tests/unit/gameplay/old_factory_deep_guard_activation_pacing_test.gd`
- `tests/unit/gameplay/old_factory_deep_route_micro_slice_runtime_test.gd`
- `tests/unit/gameplay/old_factory_entrance_combat_slice_runtime_test.gd`
- `tests/unit/gameplay/old_factory_entrance_room_clear_runtime_test.gd`
- `tests/unit/gameplay/old_factory_steam_vent_hazard_runtime_test.gd`
- `tests/unit/gameplay/rat_king_live_summon_runtime_test.gd`
- Godot MCP runtime evidence under
  `production/qa/evidence/old-factory-deep-guard-activation-pacing-2026-06-26.md`

**Status**: [x] Related regression, headless smoke, and MCP runtime evidence
recorded.

- RED: `reports/report_662/` failed as expected because the factory scene did
  not expose the deep guard activation APIs or diagnostics, and the deep guard
  still started with active target/process state.
- GREEN focused: `reports/report_663/` passed `4/4` for inactive initial deep
  guard state, entrance-clear plus threshold activation, local state restore,
  and endpoint unlock after activated guard defeat.
- Related regression: `reports/report_665/` passed `26/26` across Story011,
  Story010 deep route, Story007 entrance combat, Story008 room cache, Story009
  steam vent hazard, and Rat King summon runtime reuse of Rat Minion APIs.
- Headless smoke:
  `reports/old_factory_deep_guard_activation_pacing_factory_scene_smoke.log`
  and
  `reports/old_factory_deep_guard_activation_pacing_main_scene_smoke.log`
  exited `0`; keyword scans found no script parse, invalid call, missing
  resource, or resource-load errors.
- MCP runtime: Godot MCP ran
  `res://scenes/factory_route_transition_shell.tscn` with `autosave=false`,
  verified initial inactive deep guard diagnostics, rejected activation before
  entrance clear and before threshold, activated once after the player crossed
  the threshold, kept the endpoint locked until deep guard defeat, then opened
  the endpoint once. MCP also verified Player and deep guard SpriteFrames frame
  counts, clean runtime logs, and screenshot
  `reports/visual/cinderpaw-mcp-old-factory-deep-guard-activation-pacing-20260626.png`.

## Test-Criterion Traceability

| Criterion | Test / Evidence | Status |
|-----------|-----------------|--------|
| Deep guard starts visible but inactive | `old_factory_deep_guard_activation_pacing_test`; MCP probe | COVERED |
| Activation fails before entrance clear | `old_factory_deep_guard_activation_pacing_test`; MCP probe | COVERED |
| Activation fails before threshold | `old_factory_deep_guard_activation_pacing_test`; MCP probe | COVERED |
| Activation succeeds once after clear + threshold | `old_factory_deep_guard_activation_pacing_test`; MCP probe | COVERED |
| Activated state restores without endpoint unlock | `old_factory_deep_guard_activation_pacing_test` | COVERED |
| Guard defeat still unlocks endpoint once | `old_factory_deep_guard_activation_pacing_test`; MCP probe | COVERED |
| Diagnostics expose pacing state | `old_factory_deep_guard_activation_pacing_test`; MCP probe | COVERED |
| Story007-010 Old Factory content remains valid | Related regression `reports/report_665/` | COVERED |
| Runtime logs and screenshot verified through MCP | QA evidence; MCP runtime probe | COVERED |

## Completion Notes

**Completed**: 2026-06-26
**Criteria**: 9/9 passing
**Deviations**: No new image-generated asset was added because the pacing fix
reuses existing generated endpoint art and existing animated Rat Minion frames.
**QA Evidence**:
`production/qa/evidence/old-factory-deep-guard-activation-pacing-2026-06-26.md`
