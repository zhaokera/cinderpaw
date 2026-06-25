# Story 009: Old Factory Steam Vent Hazard Route

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

Stories003-008 made Double Jump playable, routed it into the Old Factory,
created a first entrance combat room, and added a Double Jump-reachable cache.
The next useful ACT slice is a player-visible traversal hazard inside that same
factory scene: a generated steam vent that occupies the route, damages the
player on contact with a cooldown, and gives the room a timing/readability
challenge instead of only a static reward prop.

This is a micro traversal hazard route inside the existing registered factory
destination, not a full deeper Old Factory layout.

## Acceptance Criteria

- [x] `res://scenes/factory_route_transition_shell.tscn` keeps loading as
  `area_03_factory` with `FactoryGateEntrySpawn` / `factory_gate_entry`.
- [x] The room contains a visible `FactorySteamVentHazard` using an
  image-generated transparent PNG imported through the Godot asset pipeline,
  not visible `ColorRect` or `Polygon2D` placeholder art.
- [x] The steam vent is an `Area2D` contact hazard using the environment
  collision layer/mask contract, with a `CollisionShape2D`, active monitoring,
  and deterministic hazard id / texture diagnostics.
- [x] Contact with the player applies deterministic steam damage, records
  damage metadata, triggers hurt feedback through the existing player damage
  path, and refuses repeated damage until the contact cooldown elapses.
- [x] The hazard ignores the Factory Rat Minion and other non-player targets.
- [x] Existing visible characters remain `AnimatedSprite2D + SpriteFrames`, and
  no new player-visible character uses static blocks or single-frame fake
  animation.
- [x] RED/GREEN focused test, related regression, Godot import, headless smoke,
  and Godot MCP runtime screenshot/log evidence are recorded.

## Out of Scope

- New enemy family, Boss2, hidden-boss combat, savepoints, minimap, full deeper
  multi-room Old Factory layout, shortcuts, camera polish, or new player
  abilities.
- Skill-tree UI, currency economy balancing, inventory screens, or full hazard
  art replacement beyond the generated steam vent prop/VFX baseline.
- SceneManager architecture rewrite, SaveSystem storage schema changes, shader
  work, or authored final art replacement.

## Implementation Notes

- Reuse `res://scenes/factory_route_transition_shell.tscn` as the registered
  `area_03_factory` destination and extend the entrance room route.
- Add a small `FactorySteamVentHazard` scene-local component instead of a new
  Autoload. `OldFactoryEntranceScene` owns contact damage, cooldown state, and
  deterministic diagnostics.
- Use ADR-0004's `Area2D + CollisionShape2D` environment collision contract for
  the hazard. Keep the collision shape separate from the generated sprite art.
- The new vent prop/VFX must be generated through image generation, alpha
  processed, imported, and recorded in the asset manifest and QA evidence.
- Existing Cinderpaw and Rat Minion frame animation resources are reused; no
  new character frame pack is needed for this story.

## Test Evidence

**Required evidence**:

- `tests/unit/gameplay/old_factory_steam_vent_hazard_runtime_test.gd`
- `tests/unit/gameplay/old_factory_entrance_combat_slice_runtime_test.gd`
- `tests/unit/gameplay/old_factory_entrance_room_clear_runtime_test.gd`
- Godot MCP runtime evidence under
  `production/qa/evidence/old-factory-steam-vent-hazard-route-2026-06-26.md`

**Status**: [x] Related regression, headless smoke, and MCP runtime evidence
recorded.

- RED: `reports/report_652/` failed as expected because the registered factory
  destination lacked the generated steam vent PNG, `FactorySteamVentHazard`
  node, and contact hazard APIs.
- GREEN focused: `reports/report_653/` passed `4/4` for the generated vent
  prop, environment Area2D contract, deterministic steam damage, contact
  cooldown, enemy ignore behavior, sustained overlap tick, diagnostics, and
  character frame-animation contract.
- Related regression: `reports/report_654/` passed `19/19` across Old Factory
  steam vent hazard, Old Factory entrance combat, room-clear cache, Factory
  route shell, and Rat King electric leak contact damage.
- Godot import/headless smoke: `godot --headless --path . --import --quit`
  registered `FactorySteamVentHazard` and refreshed the new generated PNG
  imports. `reports/old_factory_steam_vent_hazard_factory_scene_smoke.log` and
  `reports/old_factory_steam_vent_hazard_main_scene_smoke.log` exited `0`;
  keyword scans found no script parse, invalid call, missing resource, or
  resource-load errors.
- MCP runtime: Godot MCP ran `res://scenes/factory_route_transition_shell.tscn`
  with `autosave=false`, verified the runtime tree contains
  `FactorySteamVentHazard`, `FactoryCombatCache`, `Player`, and
  `FactoryRatMinion`; confirmed steam vent layer/mask `16/12`, monitoring
  enabled, texture path
  `res://assets/environment/old_factory_steam_vent/factory_steam_vent_hazard.png`,
  HP sequence `100 -> 92 -> 92 -> 84`, contacts `[true,false,true]`,
  enemy contact ignored, Player/Rat Minion `AnimatedSprite2D`, Rat Minion
  `idle/run/attack` frame counts of `3`, clean game/editor logs, and screenshot
  `reports/visual/cinderpaw-mcp-old-factory-steam-vent-hazard-20260626.png`.

## Test-Criterion Traceability

| Criterion | Test / Evidence | Status |
|-----------|-----------------|--------|
| Factory destination still loads as `area_03_factory` | `old_factory_steam_vent_hazard_runtime_test`; MCP runtime tree | COVERED |
| Steam vent generated prop imported through Godot | `old_factory_steam_vent_hazard_runtime_test`; asset manifest | COVERED |
| Steam vent uses Area2D environment hazard contract | `old_factory_steam_vent_hazard_runtime_test`; MCP probe | COVERED |
| Player contact takes deterministic steam damage | `old_factory_steam_vent_hazard_runtime_test`; MCP probe | COVERED |
| Contact cooldown gates repeated damage | `old_factory_steam_vent_hazard_runtime_test`; MCP probe | COVERED |
| Non-player targets are ignored | `old_factory_steam_vent_hazard_runtime_test`; MCP probe | COVERED |
| Character frame-animation rules remain satisfied | Story007/009 regression; MCP runtime probe | COVERED |
| Runtime logs and screenshot verified through MCP | QA evidence; MCP runtime probe | COVERED |

## Completion Notes

**Completed**: 2026-06-26
**Criteria**: 7/7 passing
**Deviations**: This story implements one entrance-room steam vent contact
hazard only; full deeper Old Factory route/combat content remains out of scope.
**QA Evidence**:
`production/qa/evidence/old-factory-steam-vent-hazard-route-2026-06-26.md`
