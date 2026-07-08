# Story 080: Old Factory Lower Deck Forward Pressure Relief Ambush

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Route Progression
> **Type**: Integration + Gameplay Runtime + Visual/Feel
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-08

## Context

**GDD**: `design/gdd/player-abilities.md`,
`design/gdd/exploration-ability-gating.md`,
`design/gdd/feline-combat.md`, `design/gdd/scene-management.md`,
`design/gdd/death-respawn.md`

**Requirements**: `TR-scene-004`, `TR-explore-005`, `TR-combat-001`,
`TR-respawn-002`

**ADR Governing Implementation**: ADR-0004 Collision detection; ADR-0007 Scene
management; ADR-0018 Player abilities; ADR-0021 Save system.

Story079 cuts the forward-pressure breaker. This story adds the smallest
post-breaker ACT beat: after the pressure line is cut, crossing deeper into the
lower deck trips a residual relief ambush with one animated Factory Spark
Rat and one pressure vent hazard. Defeating the sentry clears the relief,
persists the route state, and preserves the Story074 forward-pressure exit
relay savepoint plus optional service lift.

## Acceptance Criteria

- [x] `factory_route_transition_shell.tscn` contains
  `FactoryLowerDeckForwardPressureReliefSparkRat` and
  `FactoryLowerDeckForwardPressureReliefVent`.
- [x] The relief ambush is unavailable while
  `factory_lower_deck_forward_pressure_breaker_cut=false`; enemy and hazard
  remain hidden/inactive, and manual activation returns `false`.
- [x] Once the breaker is cut, crossing activation x `1804.0` activates entity
  `2124`, assigns the player as target, enables Spark Rat process and physics,
  enables pressure vent hazard
  `old_factory_lower_deck_forward_pressure_relief_ambush`, and updates route
  feedback to `Survive Forward Pressure Relief Ambush`.
- [x] The enemy uses `AnimatedSprite2D + SpriteFrames` with `idle`, `run`,
  `attack_tell`, `attack`, `hurt`, and `death` animations, each with at least
  3 frames.
- [x] Defeating entity `2124` disables the enemy and hazard, persists
  `factory_lower_deck_forward_pressure_relief_ambush_activated=true` and
  `factory_lower_deck_forward_pressure_relief_ambush_defeated=true`, marks the
  route objective complete, and updates route feedback to
  `Forward Pressure Relief Ambush Cleared`.
- [x] Restoring completed state keeps Story080 inactive/defeated, keeps Story079
  breaker cut, preserves the Story074 exit relay savepoint contract, does not
  replay Story068 clear burst or Story071 cache audio, and preserves
  `FactoryServiceLift` prompt `Call lift`.
- [x] No new visual asset is required; Story080 reuses the image-generated
  Factory Spark Rat `AnimatedSprite2D + SpriteFrames`, the Old Factory steam
  vent hazard prop, and the post-bulkhead backdrop, with reuse recorded in
  asset docs and QA evidence.
- [x] Focused/related GdUnit, headless smoke, and Godot MCP runtime checks pass
  under Godot 4.7 / Godot AI MCP 2.9.1.

## Out of Scope

New enemy family art, new room scene, minimap/full map UI, fast travel UI,
SaveSystem schema changes, service-lift route changes, new player ability,
reward cache/economy changes, authored audio, boss content, particles/shaders,
and broader lower-deck layout work.

## Implementation Notes

- Reuse `FactorySparkRat` through
  `scenes/characters/factory_spark_rat.tscn` and bind it to entity id `2124`.
- Reuse `FactorySteamVentHazard` semantics for the local relief vent,
  keeping it hidden/non-monitoring until the ambush is active.
- Keep the relief state scene-local through
  `OldFactoryEntranceScene.get_local_state()` / `set_local_state()`.
- Keep the Story074 relay as the active non-boss respawn anchor; Story080 does
  not write a new savepoint contract.
- Do not alter Story079's cleared label before the player crosses the
  relief activation boundary; the combat activation carries the next route
  label.

## Asset Pipeline

No new visual asset is generated. This story reuses already imported
image-generated assets:

- Factory Spark Rat SpriteFrames:
  `assets/characters/factory_spark_rat/factory_spark_rat_sprite_frames.tres`
- Old Factory steam vent hazard:
  `assets/environment/old_factory_steam_vent/factory_steam_vent_hazard.png`
- Post-bulkhead backdrop:
  `assets/environment/old_factory_lower_deck_post_bulkhead/env_old_factory_lower_deck_post_bulkhead_backdrop_1280x720.png`

Reuse must be recorded in `design/assets/asset-manifest.md`,
`design/assets/entity-inventory.md`, and QA evidence.

## Test Evidence

- Focused GdUnit:
  `tests/unit/gameplay/old_factory_lower_deck_forward_pressure_relief_ambush_test.gd`
- Related regression:
  Story080 focused + Story079, Story078, Story077, Story076, Story075, Story074,
  service-lift, and no-loss respawn suites.
- Runtime evidence:
  Headless smoke and Godot MCP runtime checks must confirm scene load,
  relief enemy and hazard node presence, breaker-cut gating, enemy
  SpriteFrames frame counts, active hazard semantics, defeat persistence,
  restored state, unchanged relay savepoint contract, service lift prompt,
  clean logs, and a non-empty screenshot with the active relief ambush
  visible.

## Verification Summary

- RED focused: `reports/report_1150/` failed as expected because Story080
  diagnostics and activation APIs did not exist.
- Focused GREEN: `reports/report_1151/` passed Story080 `2/2` with no errors,
  failures, skips, flaky cases, or orphans.
- Related GREEN: `reports/report_1152/` passed Story080, Story079, Story078,
  Story077, Story076, Story075, Story074, service-lift, and no-loss respawn
  suites `20/20`.
- Headless smoke:
  `reports/old_factory_forward_pressure_relief_ambush_smoke.log` exited `0`;
  keyword scan found no project script/parse/invalid-call/access/
  missing-resource/resource-load errors. Godot still emitted the known
  cleanup-time ObjectDB/resource messages to terminal output.
- Godot MCP runtime evidence: Godot AI MCP `2.9.1` on Godot `4.7-stable`
  launched the scene with `autosave=false`, confirmed helper live, found
  `FactoryLowerDeckForwardPressureReliefSparkRat` and
  `FactoryLowerDeckForwardPressureReliefVent`, and verified locked/ready/
  active/defeated/restored diagnostics. MCP confirmed entity `2124`, Spark Rat
  `AnimatedSprite2D + SpriteFrames`
  `idle/run/attack_tell/attack/hurt/death=3`, hazard id
  `old_factory_lower_deck_forward_pressure_relief_ambush`, damage `8`,
  cooldown `1.0`, steam vent texture path, failed pre-cut activation, failed
  pre-threshold activation, active route label `Survive Forward Pressure Relief
  Ambush`, defeated route label `Forward Pressure Relief Ambush Cleared`,
  persisted local flags, Story079 breaker cut, Story074 relay savepoint
  `old_factory_lower_deck_forward_pressure_exit_relay`, no-replay counts for
  Story068 clear feedback and Story071 cache audio, service lift prompt
  `Call lift`, game log containing only helper registration, empty editor log,
  and a non-empty `960x539` MCP game screenshot for the active relief ambush.

## Dependencies

- Depends on: Story079 Old Factory Lower Deck Forward Pressure Breaker
- Unlocks: Deeper Old Factory route content after the relief clear
