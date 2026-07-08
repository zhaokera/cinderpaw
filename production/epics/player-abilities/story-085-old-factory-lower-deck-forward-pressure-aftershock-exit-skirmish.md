# Story 085: Old Factory Lower Deck Forward Pressure Aftershock Exit Skirmish

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Route Progression
> **Type**: Integration + Gameplay Runtime + Visual/Feel
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-09

## Context

**GDD**: `design/gdd/player-abilities.md`,
`design/gdd/exploration-ability-gating.md`,
`design/gdd/feline-combat.md`, `design/gdd/scene-management.md`,
`design/gdd/death-respawn.md`

**Requirements**: `TR-scene-004`, `TR-explore-005`, `TR-combat-001`,
`TR-respawn-002`

**ADR Governing Implementation**: ADR-0004 Collision detection; ADR-0007 Scene
management; ADR-0018 Player abilities; ADR-0021 Save system.

Story084 pays off the Coil Aftershock with a once-only reward cache. Story085
keeps the route playable immediately after that reward: once Cinderpaw has
claimed the aftershock cache, pushing forward triggers a compact Spark Rat +
Coil Rat exit skirmish. The slice reinforces the ACT loop of claim, advance,
read enemy tells, fight, and clear the route without introducing a new enemy
family, new generated art, a new savepoint, service-lift routing, or a new room
scene.

## Acceptance Criteria

- [x] `factory_route_transition_shell.tscn` contains
  `FactoryLowerDeckForwardPressureAftershockExitSkirmishSparkRat` using
  `src/gameplay/factory_spark_rat.tscn` and
  `FactoryLowerDeckForwardPressureAftershockExitSkirmishCoilRat` using
  `src/gameplay/factory_coil_rat.tscn`.
- [x] The exit skirmish is unavailable while
  `factory_lower_deck_forward_pressure_aftershock_reward_cache_claimed=false`;
  both enemies remain hidden/inactive, and manual activation returns `false`.
- [x] Once Story084's cache is claimed, crossing activation x `2288.0`
  activates entity `2129` as the Spark Rat side and entity `2130` as the Coil
  Rat side, assigns the player as target for both, enables process/physics for
  both, starts opening grace frame pacing `12/24`, and updates route feedback to
  `Break Aftershock Exit Skirmish`.
- [x] Both enemies use `AnimatedSprite2D + SpriteFrames` with `idle`, `run`,
  `attack_tell`, `attack`, `hurt`, and `death` animations, each with at least
  3 transparent PNG frames. No placeholder rectangle or single-frame character
  art is accepted for this Story.
- [x] Defeating both enemies persists
  `factory_lower_deck_forward_pressure_aftershock_exit_skirmish_activated=true`,
  `factory_lower_deck_forward_pressure_aftershock_exit_skirmish_spark_rat_defeated=true`,
  `factory_lower_deck_forward_pressure_aftershock_exit_skirmish_coil_rat_defeated=true`,
  and `factory_lower_deck_forward_pressure_aftershock_exit_skirmish_cleared=true`,
  disables both enemies, marks the route objective complete, and updates route
  feedback to `Forward Pressure Aftershock Exit Skirmish Cleared`.
- [x] Restoring completed state keeps Story085 inactive/cleared, keeps Story084
  cache claimed, keeps Story083/082/081 completed, preserves the Story074 exit
  relay savepoint contract, does not replay Story068 clear burst or Story071
  reward-cache audio, and preserves `FactoryServiceLift` prompt `Call lift`.
- [x] Focused/related GdUnit, headless smoke, and Godot MCP runtime checks pass
  under Godot 4.7 / Godot AI MCP 2.9.1, including scene load, both enemy nodes,
  SpriteFrames frame counts, clean logs, and a non-empty screenshot showing the
  active exit skirmish state.

## Out of Scope

New generated character art, new enemy family, new AI behavior tree, new
hazard, new reward economy, new savepoint, SaveSystem schema changes,
service-lift route changes, minimap/fast travel UI, authored audio,
particles/shaders, Boss2, and broader lower-deck layout work.

## Implementation Notes

- Reuse existing `FactorySparkRat` and `FactoryCoilRat` gameplay scenes and
  imported frame animation assets.
- Keep Story085 state scene-local through
  `OldFactoryEntranceScene.get_local_state()` / `set_local_state()`.
- Use encounter id
  `old_factory_lower_deck_forward_pressure_aftershock_exit_skirmish`.
- Keep the Story074 relay as the active non-boss respawn anchor; Story085 does
  not write a new savepoint contract.
- Do not lock `FactoryServiceLift`; the exit skirmish is a forward-route
  pressure beat, not a lift gate.

## Asset Pipeline

No new visual assets are required for this Story. It reuses imported,
image-generated animated enemy assets:

- Factory Spark Rat SpriteFrames:
  `assets/characters/factory_spark_rat/factory_spark_rat_sprite_frames.tres`
- Factory Coil Rat SpriteFrames:
  `assets/characters/factory_coil_rat/factory_coil_rat_sprite_frames.tres`

Usage must be recorded in `design/assets/asset-manifest.md`,
`design/assets/entity-inventory.md`, this story, and QA evidence.

## Test Evidence

- Focused GdUnit:
  `tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_exit_skirmish_test.gd`;
  RED `reports/report_1181/`, focused GREEN `reports/report_1183/` (`3/3`),
  and final pre-commit focused rerun `reports/report_1186/` (`3/3`).
- Related regression:
  Story085 focused + Story084, Story083, Story082, Story081, Story080,
  Story079, Story078, Story077, Story076, Story075, Story074, service-lift,
  and no-loss respawn suites. Related GREEN `reports/report_1184/` (`20/20`)
  and expanded related GREEN `reports/report_1185/` (`36/36`).
- Runtime evidence:
  Headless smoke
  `reports/old_factory_forward_pressure_aftershock_exit_skirmish_smoke.log`
  exited `0` and its project error keyword scan was empty. Godot MCP runtime
  on Godot `4.7-stable` / Godot AI MCP `2.9.1` confirmed scene load, both
  skirmish enemies present, Story084-cache-claimed gating, enemy SpriteFrames
  frame counts, active route label, partial/full defeat semantics, restored
  state, unchanged relay savepoint contract, service lift prompt `Call lift`,
  game log containing only helper registration, empty editor log after clearing
  an eval-probe warning, and a non-empty `960x539` screenshot with both enemies
  visible.

## Verification Summary

- RED focused `reports/report_1181/` failed as expected before Story085 scene
  APIs existed. A transient implementation parse failure in `reports/report_1182/`
  was fixed before acceptance.
- Focused GREEN `reports/report_1183/` passed Story085 `3/3`.
- Final pre-commit focused rerun `reports/report_1186/` passed Story085 `3/3`.
- Related GREEN `reports/report_1184/` passed Story085 through Story080 plus
  Story074/service-lift/no-loss coverage `20/20`.
- Expanded related GREEN `reports/report_1185/` passed Story085, Story084,
  Story083 through Story074, Story071 audio no-replay, service-lift, and
  no-loss respawn suites `36/36`.
- Godot MCP runtime confirmed active state entities `2129/2130`, families
  `factory_spark_rat` / `factory_coil_rat`, SpriteFrames paths, required
  animation frame counts, opening grace frames `12/24`, route label
  `Break Aftershock Exit Skirmish`, completed-state persistence, and clean
  game/editor logs for the final run.

## Dependencies

- Depends on: Story084 Old Factory Lower Deck Forward Pressure Aftershock Reward Cache
- Unlocks: Deeper Old Factory route content after the aftershock exit skirmish
