# Story 091: Old Factory Lower Deck Forward Pressure Aftershock Exhaust Escape Skirmish

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Route Progression
> **Type**: Integration + Gameplay Runtime + Visual/Feel
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-22

## Context

**GDD**: `design/gdd/player-abilities.md`,
`design/gdd/exploration-ability-gating.md`,
`design/gdd/feline-combat.md`, `design/gdd/scene-management.md`,
`design/gdd/death-respawn.md`

**Requirements**: `TR-scene-004`, `TR-explore-005`, `TR-combat-001`,
`TR-respawn-002`

**ADR Governing Implementation**: ADR-0004 Collision detection; ADR-0007 Scene
management; ADR-0018 Player abilities; ADR-0021 Save system.

Story090 cuts the aftershock exhaust breaker and leaves the lower-deck route
pressurized but passable. Story091 adds a short player-visible escape skirmish
past that breaker: after the breaker is cut, crossing x `3112.0` activates a
reused animated Factory Spark Rat and Factory Coil Rat pair. Both enemies use
`AnimatedSprite2D + SpriteFrames`, target Cinderpaw, stagger their opening
grace frames, and persist partial/full defeat through scene-local state.

## Acceptance Criteria

- [x] `FactoryLowerDeckForwardPressureAftershockExhaustEscapeSkirmishSparkRat`
  and `FactoryLowerDeckForwardPressureAftershockExhaustEscapeSkirmishCoilRat`
  exist in `factory_route_transition_shell.tscn` and start hidden/inactive.
- [x] The escape skirmish is unavailable until
  `factory_lower_deck_forward_pressure_aftershock_exhaust_breaker_cut=true`;
  manual activation returns `false` while locked and does not reveal either
  enemy.
- [x] Once Story090 is cut, crossing activation x `3112.0` activates Spark Rat
  entity `2134` and Coil Rat entity `2135`, assigns Cinderpaw as target,
  enables process/physics for both, starts opening grace frames `10/22`, and
  updates route feedback to `Break Aftershock Exhaust Escape`. Production
  staging anchors Coil/Cinderpaw/Spark at x `2952/3112/3256`, providing
  `160/144px` flanks and a `304px` enemy center gap.
- [x] Story090 cut can only make Story091 available in that process frame.
  Activation requires availability at frame start plus a later fresh positive
  player-x sample; restore/teleport and a stationary player at x `3116` keep
  entities `2134/2135` hidden, non-processing, non-physical, `24 HP`, with
  hurtboxes `gone`.
- [x] Both enemies use `AnimatedSprite2D + SpriteFrames` with `idle`, `run`,
  `attack_tell`, `attack`, `hurt`, and `death` animations, each with at least
  3 transparent PNG frames from their existing character asset folders.
- [x] Defeating only one enemy persists its partial defeat flag, keeps its
  three-frame live death visible/processing with combat collision disabled,
  and does not complete the route or hide the remaining active enemy.
- [x] Defeating both enemies persists
  `factory_lower_deck_forward_pressure_aftershock_exhaust_escape_skirmish_activated=true`,
  `factory_lower_deck_forward_pressure_aftershock_exhaust_escape_skirmish_spark_rat_defeated=true`,
  `factory_lower_deck_forward_pressure_aftershock_exhaust_escape_skirmish_coil_rat_defeated=true`,
  and `factory_lower_deck_forward_pressure_aftershock_exhaust_escape_skirmish_cleared=true`,
  keeps both fresh live deaths visible/processing with physics, targets,
  hurtboxes, bite hitboxes and body collision disabled, and originally updated
  route feedback to
  `Aftershock Exhaust Escape Secured`; Story092 now advances the live route
  objective to `Open Aftershock Exhaust Hatch` after this clear state.
- [x] Restoring completed state keeps Story091 inactive/cleared, keeps Story090
  cut and Story089 cleared, keeps Story074 exit relay contract stable, does not
  replay Story068 clear burst or Story071 reward-cache audio, and preserves
  `FactoryServiceLift` prompt `Call lift`.
- [x] Focused/related GdUnit, headless smoke, and Godot MCP runtime checks pass
  under Godot 4.7 / Godot AI MCP 3.0.4, including scene load, target nodes,
  SpriteFrames frame counts, active runtime diagnostics, persisted clear state,
  clean logs, and a non-empty screenshot showing the active skirmish.

## Out of Scope

New generated character art, new enemy family, new AI behavior tree, new hazard,
new reward cache, new reward economy, new savepoint, SaveSystem schema changes,
service-lift route changes, minimap/fast travel UI, authored audio,
particles/shaders, Boss2, and broader lower-deck biome art replacement.

## Implementation Notes

- Reuse existing `FactorySparkRat` and `FactoryCoilRat` gameplay scenes and
  imported frame animation assets for entities `2134` and `2135`.
- Keep Story091 state scene-local through
  `OldFactoryEntranceScene.get_local_state()` / `set_local_state()`.
- Use encounter id
  `old_factory_lower_deck_forward_pressure_aftershock_exhaust_escape_skirmish`
  for diagnostics and asset tracking.
- Keep the Story074 relay as the active non-boss respawn anchor; Story091 does
  not write a new savepoint contract.

## Asset Pipeline

No new visual assets are required for this Story. It reuses imported,
image-generated assets already in the Godot pipeline:

- Factory Spark Rat SpriteFrames:
  `assets/characters/factory_spark_rat/factory_spark_rat_sprite_frames.tres`
- Factory Spark Rat attack-tell frames:
  `assets/characters/factory_spark_rat/attack_tell/`
- Factory Coil Rat SpriteFrames:
  `assets/characters/factory_coil_rat/factory_coil_rat_sprite_frames.tres`

Reuse is recorded in `design/assets/asset-manifest.md`,
`design/assets/entity-inventory.md`, this story, and QA evidence.

## Test Evidence

- Focused GdUnit:
  `tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_exhaust_escape_skirmish_test.gd`
  - Initial clean RED: `reports/report_1212/`
  - First focused GREEN: `reports/report_1213/` (`2/2`)
  - MCP-discovered stale-reference RED:
    `reports/report_1215/` (`errors=4`)
  - Final focused GREEN after valid-node diagnostics fix:
    `reports/report_1216/` (`2/2`)
- Related regression:
  `reports/report_1217/` (`39/39`)
- Runtime evidence:
  Headless factory smoke
  `reports/old_factory_forward_pressure_aftershock_exhaust_escape_skirmish_smoke.log`
  exited `0`; keyword scan found no project script/parse/invalid-call/access/
  missing-resource/resource-load/shadowed-variable errors.
- Godot MCP:
  Godot AI MCP `2.9.1` on Godot `4.7-stable` confirmed helper live, active
  Story091 diagnostics, entities `2134/2135`, Spark/Coil SpriteFrames paths and
  3-frame counts for `idle/run/attack_tell/attack/hurt/death`, opening grace
  frames `10/22`, visible active enemies, route label
  `Break Aftershock Exhaust Escape`, `apply_damage(2134/2135, 999)=true`,
  persisted and resynced cleared flags, route feedback
  `Aftershock Exhaust Escape Secured`, clean game/editor logs, and a non-empty
  `960x539` game screenshot showing the active skirmish.
- Story210 production acceptance:
  `reports/report_2272/results.xml` focused `1/1` and
  `reports/report_2275/results.xml` bounded related `6/6`; Godot 4.7 / MCP
  3.0.4 run `r142990853-69` confirmed the `2952/3112/3256` pincer, real
  `9/10` bites, four real player attacks, partial/full collision-safe live
  deaths, clean logs, and the unopened Story092 hatch handoff.

## Dependencies

- Depends on: Story090 Old Factory Lower Deck Forward Pressure Aftershock Exhaust Breaker Corridor
- Unlocks: deeper Old Factory route content after the aftershock exhaust escape

## Verification Summary

- Initial focused RED `reports/report_1212/` failed before the Story091
  diagnostics, activation API, scene nodes, route objective, and local-state
  fields existed.
- First focused GREEN `reports/report_1213/` passed `2/2`.
- MCP runtime probing exposed a stale freed-enemy-reference error after both
  enemies were defeated and local state was restored; regression RED
  `reports/report_1215/` captured `errors=4`.
- Final focused GREEN `reports/report_1216/` passed `2/2` after diagnostics and
  enemy-family/entity lookups were hardened with valid-node checks.
- Final related GREEN `reports/report_1217/` passed `39/39`.
- Headless smoke and Godot MCP runtime evidence passed under Godot 4.7 / Godot
  AI MCP 2.9.1.
- Story092 later extended the route chain after Story091, so current regression
  tests now expect Story091 clear state to unlock the aftershock exhaust exit
  hatch instead of ending the route objective chain.
- Story209 added the same-frame/fresh-movement guard at the Story090 cut
  boundary. `reports/report_2267/results.xml` passed the Story209/090/091/208
  and steam bounded set `10/10`; MCP run `r139679441-66` confirmed Story091
  remained available/inactive with both enemies hidden and collision-safe.
- Story210 replaced the old `44px` overlap with a `304px` pincer and promoted
  Story091 to production movement/bite/light-attack/live-death acceptance.
  Final bounded related `report_2275` passed `6/6`; accepted MCP run
  `r142990853-69` handed the route to Story092 without auto-opening it.
