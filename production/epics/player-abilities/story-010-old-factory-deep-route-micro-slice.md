# Story 010: Old Factory Deep Route Micro-Slice

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Core / Feature / Gameplay Runtime / Presentation Integration
> **Type**: Integration + Gameplay Runtime + Visual/Feel
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

Stories003-009 made Double Jump playable, routed it into the Old Factory,
created the first entrance combat room, added a room-clear cache, and placed a
steam vent hazard in the route. This story adds a small deeper route objective
inside the same registered factory destination: a second Rat Minion guard and a
visible generated endpoint switch that marks the route as cleared after the
guard is defeated.

This is still a single-room micro-slice inside `area_03_factory`, not the full
Old Factory area.

## Acceptance Criteria

- [x] `res://scenes/factory_route_transition_shell.tscn` keeps loading as
  `area_03_factory` with `FactoryGateEntrySpawn` / `factory_gate_entry`.
- [x] The room contains a visible `FactoryDeepRouteEndpoint` using an
  image-generated transparent PNG imported through the Godot asset pipeline,
  not visible `ColorRect` or `Polygon2D` placeholder art.
- [x] The endpoint exposes deterministic endpoint id, texture diagnostics,
  available state, activated state, range checks, and once-only activation.
- [x] The room contains a second visible guard named `FactoryDeepGuardRatMinion`
  that reuses the existing Rat Minion `AnimatedSprite2D + SpriteFrames`
  runtime contract with a unique entity id.
- [x] The endpoint is locked while the second guard is alive, becomes activable
  after that guard's defeat signal, activates once for a nearby player, and
  rejects duplicate activation.
- [x] `OldFactoryEntranceScene` exposes deterministic deep-route diagnostics
  plus `get_local_state()` / `set_local_state()` keys for
  `factory_deep_guard_defeated` and `factory_deep_route_cleared`.
- [x] Story007-009 content does not regress: entrance Rat Minion, combat cache,
  steam vent hazard, player animation, and Rat Minion frame rules remain valid.
- [x] RED/GREEN focused test, related regression, Godot import, headless smoke,
  and Godot MCP runtime screenshot/log evidence are recorded.

## Out of Scope

- New enemy family, new Rat Minion animation pack, Boss2, hidden-boss combat,
  savepoints, minimap, full deeper multi-room Old Factory layout, shortcuts, or
  new player abilities.
- Skill-tree UI, currency economy balancing, inventory screens, full quest
  completion flow, or cross-process SaveSystem schema changes.
- SceneManager architecture rewrite, camera polish, shader work, final authored
  art replacement, or audio-system changes.

## Implementation Notes

- Reuse `res://scenes/factory_route_transition_shell.tscn` as the registered
  `area_03_factory` destination and extend the existing room rather than adding
  a new factory scene.
- Add `FactoryDeepRouteEndpoint` as a scene-local Node2D component. It owns the
  endpoint visual, prompt label, interaction area, range gate, and once-only
  activation state.
- Reuse the existing Rat Minion scene for `FactoryDeepGuardRatMinion`; configure
  it with entity id `2101` so the entrance guard (`2100`) and deep guard cannot
  share combat state.
- Keep persistence scene-local via ADR-0007's `get_local_state()` /
  `set_local_state()` protocol; do not add a new Autoload or SaveSystem schema.
- The endpoint prop must be generated through image generation, alpha processed,
  imported, and recorded in the asset manifest and QA evidence.

## Test Evidence

**Required evidence**:

- `tests/unit/gameplay/old_factory_deep_route_micro_slice_runtime_test.gd`
- `tests/unit/gameplay/old_factory_entrance_combat_slice_runtime_test.gd`
- `tests/unit/gameplay/old_factory_entrance_room_clear_runtime_test.gd`
- `tests/unit/gameplay/old_factory_steam_vent_hazard_runtime_test.gd`
- Godot MCP runtime evidence under
  `production/qa/evidence/old-factory-deep-route-micro-slice-2026-06-26.md`

**Status**: [x] Related regression, headless smoke, and MCP runtime evidence
recorded.

- RED: `reports/report_655/` failed as expected because the registered factory
  scene had no generated endpoint PNG, no `FactoryDeepRouteEndpoint`, and no
  deep-route runtime APIs.
- RED refinement: `reports/report_656/` failed on missing Godot import metadata
  for the new endpoint PNG before the import pass.
- GREEN focused: `reports/report_657/` passed `4/4` for generated endpoint art,
  second animated Rat guard, endpoint unlock/once-only activation, diagnostics,
  and local state restoration.
- Related regression: `reports/report_658/`, `reports/report_659/`, and
  `reports/report_660/` passed `11/11` across Old Factory entrance combat,
  room-clear cache, and steam vent hazard contracts.
- Godot import/headless smoke: `godot --headless --path . --import --quit`
  registered `FactoryDeepRouteEndpoint` and refreshed the new PNG imports.
  `reports/old_factory_deep_route_micro_slice_factory_scene_smoke.log` and
  `reports/old_factory_deep_route_micro_slice_main_scene_smoke.log` exited
  `0`; keyword scans found no script parse, invalid call, missing resource, or
  resource-load errors.
- MCP runtime: Godot MCP ran
  `res://scenes/factory_route_transition_shell.tscn` with `autosave=false`,
  verified runtime nodes for `Player`, `FactoryRatMinion`,
  `FactoryDeepGuardRatMinion`, `FactoryCombatCache`,
  `FactorySteamVentHazard`, and `FactoryDeepRouteEndpoint`; confirmed clean
  initial state `before=false`, guard defeat unlock `after=true`, duplicate
  activation `false`, endpoint texture path, local state keys, Player
  `idle/run/jump` frames `3`, deep guard `idle/run/attack/hurt/death` frames
  `3`, clean game/editor logs, and screenshot
  `reports/visual/cinderpaw-mcp-old-factory-deep-route-micro-slice-20260626.png`.

## Test-Criterion Traceability

| Criterion | Test / Evidence | Status |
|-----------|-----------------|--------|
| Factory destination still loads as `area_03_factory` | `old_factory_deep_route_micro_slice_runtime_test`; MCP runtime tree | COVERED |
| Deep endpoint generated prop imported through Godot | `old_factory_deep_route_micro_slice_runtime_test`; asset manifest | COVERED |
| Endpoint diagnostics and activation API exist | `old_factory_deep_route_micro_slice_runtime_test`; MCP probe | COVERED |
| Second Rat guard is unique and animated | `old_factory_deep_route_micro_slice_runtime_test`; MCP probe | COVERED |
| Guard defeat unlocks endpoint and duplicate activation fails | `old_factory_deep_route_micro_slice_runtime_test`; MCP probe | COVERED |
| Deep-route state persists through local scene state | `old_factory_deep_route_micro_slice_runtime_test` | COVERED |
| Story007-009 content remains valid | Related regression `reports/report_658/`-`660/` | COVERED |
| Runtime logs and screenshot verified through MCP | QA evidence; MCP runtime probe | COVERED |

## Completion Notes

**Completed**: 2026-06-26
**Criteria**: 8/8 passing
**Deviations**: This story adds one deeper route objective inside the existing
factory room only; full Old Factory multi-room content remains out of scope.
**QA Evidence**:
`production/qa/evidence/old-factory-deep-route-micro-slice-2026-06-26.md`
