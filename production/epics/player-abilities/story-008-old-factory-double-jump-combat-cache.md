# Story 008: Old Factory Double Jump Combat Cache

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
management; ADR-0021 Save system architecture.

Stories003-007 made Double Jump playable, routed it into the Old Factory, and
turned the factory destination into a first combat room with Cinderpaw and a Rat
Minion. This story adds the first small in-room objective: an upper cache that
reads as a Double Jump reachable reward, stays locked until the room combat is
cleared, and persists its one-time claim state through the existing scene-local
state protocol.

This is a micro combat/traversal reward loop inside the entrance room, not a
full deeper Old Factory layout.

## Acceptance Criteria

- [x] `res://scenes/factory_route_transition_shell.tscn` keeps loading as
  `area_03_factory` with `FactoryGateEntrySpawn` / `factory_gate_entry`.
- [x] The entrance room contains an upper cache platform reachable with Double
  Jump spacing and not represented by visible `ColorRect` or `Polygon2D`
  placeholder art.
- [x] The room contains a visible `FactoryCombatCache` reward prop using an
  image-generated transparent PNG imported through the Godot asset pipeline.
- [x] The cache starts locked while `FactoryRatMinion` is alive, becomes
  available after the enemy defeat signal, and can be claimed once by a nearby
  player.
- [x] Claiming the cache returns a deterministic reward payload, dims/hides
  the prompt, and refuses duplicate claims.
- [x] `OldFactoryEntranceScene` exposes deterministic diagnostics plus
  `get_local_state()` / `set_local_state()` so room clear and cache claim state
  survive SceneManager runtime swaps.
- [x] Existing visible characters remain `AnimatedSprite2D + SpriteFrames`, and
  no new player-visible character uses static blocks or single-frame fake
  animation.
- [x] RED/GREEN focused test, related regression, Godot import, headless smoke,
  and Godot MCP runtime screenshot/log evidence are recorded.

## Out of Scope

- New enemy family, Boss2, hidden-boss combat, savepoints, minimap, deeper
  multi-room Old Factory layout, shortcuts, or new player abilities.
- Skill-tree UI, currency economy balancing, inventory screens, or full reward
  presentation polish beyond the room-local deterministic payload and prompt.
- SceneManager architecture rewrite, SaveSystem storage schema changes, camera
  polish, shader work, or authored final art replacement.

## Implementation Notes

- Reuse `res://scenes/factory_route_transition_shell.tscn` as the registered
  `area_03_factory` destination and extend its entrance room layout.
- Add a small `FactoryCombatCache` scene-local component instead of expanding
  `AbilityRewardSource`, because this reward is gated by room clear state and
  grants a deterministic cache payload rather than unlocking an ability.
- Keep persistence scene-local via ADR-0007's `get_local_state()` /
  `set_local_state()` protocol; do not add a new Autoload or SaveSystem schema.
- The new cache prop must be generated through image generation, alpha processed,
  imported, and recorded in the asset manifest and QA evidence.
- Existing Cinderpaw and Rat Minion frame animation resources are reused; no
  new character frame pack is needed for this story.

## Test Evidence

**Required evidence**:

- `tests/unit/gameplay/old_factory_entrance_room_clear_runtime_test.gd`
- `tests/unit/gameplay/old_factory_entrance_combat_slice_runtime_test.gd`
- `tests/unit/gameplay/factory_route_transition_shell_runtime_test.gd`
- `tests/unit/scene/story_005_runtime_scene_tree_swap_test.gd`
- Godot MCP runtime evidence under
  `production/qa/evidence/old-factory-double-jump-combat-cache-2026-06-26.md`

**Status**: [x] Related regression, headless smoke, and MCP runtime evidence
recorded.

- RED: `reports/report_648/` failed as expected because the registered factory
  destination lacked the generated cache texture, `FactoryCachePlatform`,
  `FactoryCombatCache`, room-clear API, and local scene state API.
- GREEN focused: `reports/report_650/` passed `3/3` for the generated cache
  prop, upper cache platform, clear-to-claim state transition, once-only reward
  claim, and `get_local_state()` / `set_local_state()` restoration.
- Related regression: `reports/report_651/` passed `23/23` across Old Factory
  room clear cache, Old Factory entrance combat, Factory route shell,
  SceneManager runtime scene-tree swap, Double Jump gate, hidden Double Jump
  reward source, and MainScene player attack core chain.
- Godot import/headless smoke: `godot --headless --path . --import --quit`
  registered `FactoryCombatCache` and refreshed the generated cache PNG imports.
  `reports/old_factory_double_jump_combat_cache_factory_scene_smoke.log` and
  `reports/old_factory_double_jump_combat_cache_main_scene_smoke.log` exited
  `0`; keyword scans found no script parse, invalid call, missing resource, or
  resource-load errors. Known cleanup-time ObjectDB/resource messages remain
  limited to process exit.
- MCP runtime: Godot MCP ran `res://scenes/factory_route_transition_shell.tscn`,
  verified `area_03_factory`, `Player/Sprite` and `FactoryRatMinion/Sprite`
  as `AnimatedSprite2D`, Rat Minion `idle/run/attack` frame counts of `3`,
  cache texture path
  `res://assets/environment/old_factory_combat_cache/factory_combat_cache.png`,
  initial cache locked state, enemy-defeat unlock, `claim_ok=true`,
  `duplicate_claim=false`, local state persistence, clean logs, and screenshot
  `reports/visual/cinderpaw-mcp-old-factory-double-jump-combat-cache-20260626.png`.

## Test-Criterion Traceability

| Criterion | Test / Evidence | Status |
|-----------|-----------------|--------|
| Factory destination still loads as `area_03_factory` | `old_factory_entrance_room_clear_runtime_test` | COVERED |
| Double Jump cache platform is present without visible placeholder art | `old_factory_entrance_room_clear_runtime_test`; MCP screenshot | COVERED |
| Generated cache prop imported through Godot | `old_factory_entrance_room_clear_runtime_test`; asset manifest | COVERED |
| Enemy defeat unlocks the cache | `old_factory_entrance_room_clear_runtime_test`; MCP probe | COVERED |
| Cache claim is once-only and returns payload | `old_factory_entrance_room_clear_runtime_test`; MCP probe | COVERED |
| Room clear/cache state persists via local scene state | `old_factory_entrance_room_clear_runtime_test`; SceneManager related regression | COVERED |
| Character frame-animation rules remain satisfied | Story007 regression; MCP runtime probe | COVERED |
| Runtime logs and screenshot verified through MCP | QA evidence; MCP runtime probe | COVERED |

## Completion Notes

**Completed**: 2026-06-26
**Criteria**: 8/8 passing
**Deviations**: This story implements one entrance-room Double Jump combat cache
only; full deeper Old Factory content remains out of scope.
**QA Evidence**:
`production/qa/evidence/old-factory-double-jump-combat-cache-2026-06-26.md`
