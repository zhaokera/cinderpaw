# Story 089: Old Factory Lower Deck Forward Pressure Aftershock Exhaust Flank Ambush

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Route Progression
> **Type**: Integration + Gameplay Runtime + Visual/Feel
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-21

## Context

**GDD**: `design/gdd/player-abilities.md`,
`design/gdd/exploration-ability-gating.md`,
`design/gdd/feline-combat.md`, `design/gdd/scene-management.md`,
`design/gdd/death-respawn.md`

**Requirements**: `TR-scene-004`, `TR-explore-005`, `TR-combat-001`,
`TR-respawn-002`

**ADR Governing Implementation**: ADR-0004 Collision detection; ADR-0007 Scene
management; ADR-0018 Player abilities; ADR-0021 Save system.

Story088 closes the aftershock exhaust pursuer with a once-only reward cache.
Story089 immediately pushes Cinderpaw forward again: after claiming that cache,
crossing x `2768.0` triggers a reused animated Factory Spark Rat and a reused
steam vent flank hazard. The slice keeps the lower-deck ACT route moving with
visible frame animation and contact pressure, without adding a new enemy
family, generated art, savepoint, service-lift route, or reward economy rule.

## Acceptance Criteria

- [x] `factory_route_transition_shell.tscn` contains
  `FactoryLowerDeckForwardPressureAftershockExhaustFlankAmbushSparkRat` using
  `src/gameplay/factory_spark_rat.tscn` and
  `FactoryLowerDeckForwardPressureAftershockExhaustFlankAmbushVent` using the
  existing Old Factory steam vent hazard script/texture.
- [x] The flank ambush is unavailable while
  `factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache_claimed=false`;
  the Spark Rat and vent remain hidden/inactive, and manual activation returns
  `false`.
- [x] Once Story088 is claimed, crossing activation x `2768.0` activates entity
  `2132`, assigns Cinderpaw as target, enables process/physics, starts opening
  grace frame pacing `14`, enables the vent contact hazard, and updates route
  feedback to `Break Aftershock Exhaust Flank`.
- [x] The enemy uses `AnimatedSprite2D + SpriteFrames` with `idle`, `run`,
  `attack_tell`, `attack`, `hurt`, and `death` animations, each with at least
  3 transparent PNG frames. No placeholder rectangle or single-frame character
  art is accepted for this Story.
- [x] The vent uses hazard id
  `old_factory_lower_deck_forward_pressure_aftershock_exhaust_flank_ambush`,
  applies `8` steam damage to the player only, respects `1.0s` cooldown, and
  disables contact after the flank is cleared.
- [x] Defeating entity `2132` persists
  `factory_lower_deck_forward_pressure_aftershock_exhaust_flank_ambush_activated=true`,
  `factory_lower_deck_forward_pressure_aftershock_exhaust_flank_ambush_spark_rat_defeated=true`,
  and `factory_lower_deck_forward_pressure_aftershock_exhaust_flank_ambush_cleared=true`,
  disables the Spark Rat/vent, marks the route objective complete, and updates
  route feedback to `Forward Pressure Exhaust Flank Cleared`. Live defeat
  preserves visible/process three-frame `death` while physics, target and
  hurtbox are disabled; restored completed state remains hidden.
- [x] Death-tween cleanup cannot break diagnostics: after the Spark Rat queues
  free and the scene waits additional frames, Story089 diagnostics must still
  return cleared state without a stale freed-node runtime error.
- [x] Restoring completed state keeps Story089 inactive/cleared, keeps the
  Story088 cache claimed, keeps Story087 cleared, keeps Story086 crossed, keeps
  Story085 cleared, keeps Story084 claimed, preserves the Story074 exit relay
  savepoint contract, does not replay Story068 clear burst or Story071
  reward-cache audio, and preserves `FactoryServiceLift` prompt `Call lift`.
- [x] Focused/related GdUnit, headless smoke, and Godot MCP runtime checks pass
  under Godot 4.7 / Godot AI MCP 3.0.4, including scene load, target nodes,
  SpriteFrames frame counts, live Story088 cache-claim-to-flank activation,
  hazard damage, freed-node-safe cleared diagnostics, clean logs, and a
  non-empty screenshot showing the active flank.

## Out of Scope

New generated character art, new enemy family, new AI behavior tree, new reward
cache, new reward economy, new savepoint, SaveSystem schema changes,
service-lift route changes, minimap/fast travel UI, authored audio,
particles/shaders, Boss2, and broader lower-deck layout work.

## Implementation Notes

- Reuse existing `FactorySparkRat` gameplay scene and imported frame animation
  assets for entity `2132`.
- Reuse `FactorySteamVentHazard` and
  `assets/environment/old_factory_steam_vent/factory_steam_vent_hazard.png`.
- Keep Story089 state scene-local through
  `OldFactoryEntranceScene.get_local_state()` / `set_local_state()`.
- Use encounter/hazard id
  `old_factory_lower_deck_forward_pressure_aftershock_exhaust_flank_ambush`.
- Guard diagnostics and enemy lookup against stale freed enemy references after
  `RatMinion` death tweens queue the Spark Rat free.
- Keep the Story074 relay as the active non-boss respawn anchor; Story089 does
  not write a new savepoint contract.
- Do not lock `FactoryServiceLift`; the flank is a forward-route ACT pressure
  beat, not a lift gate.

## Asset Pipeline

No new visual assets are required for this Story. It reuses imported,
image-generated assets already in the Godot pipeline:

- Factory Spark Rat SpriteFrames:
  `assets/characters/factory_spark_rat/factory_spark_rat_sprite_frames.tres`
- Factory Spark Rat attack tell frames:
  `assets/characters/factory_spark_rat/attack_tell/factory_spark_rat_attack_tell_000.png`
  through `_002.png`
- Old Factory steam vent runtime texture:
  `assets/environment/old_factory_steam_vent/factory_steam_vent_hazard.png`

Reuse is recorded in `design/assets/asset-manifest.md`,
`design/assets/entity-inventory.md`, this story, and QA evidence.

## Test Evidence

- Focused GdUnit:
  `tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_exhaust_flank_ambush_test.gd`
  - Initial RED: `reports/report_1198/`
  - Pre-MCP GREEN: `reports/report_1200/` (`3/3`)
  - MCP stale-reference RED: `reports/report_1202/`
  - Final GREEN: `reports/report_1205/` (`3/3`)
- Related regression:
  Story089 focused + Story088, Story087, Story086, Story085, Story084,
  Story083, Story074 exit relay, service-lift, no-loss respawn, Story068
  no-replay, Story071 reward-cache audio no-replay, and steam-vent hazard
  suites.
  - Final GREEN: `reports/report_1204/` (`33/33`)
- Runtime evidence:
  Headless smoke and Godot MCP runtime checks confirm scene load, live Story088
  cache claim, flank activation, Spark Rat `AnimatedSprite2D + SpriteFrames`
  frame counts, steam vent contact damage, freed-node-safe cleared diagnostics,
  unchanged relay savepoint contract, service lift prompt, clean final logs,
  and a non-empty screenshot with the active flank.
  - Headless smoke:
    `reports/old_factory_forward_pressure_aftershock_exhaust_flank_ambush_smoke.log`
  - QA evidence:
    `production/qa/evidence/old-factory-forward-pressure-aftershock-exhaust-flank-ambush-2026-07-09.md`

## Dependencies

- Depends on: Story088 Old Factory Lower Deck Forward Pressure Aftershock Exhaust Pursuer Reward Cache
- Unlocks: Deeper Old Factory route content after the aftershock exhaust flank

## Verification Summary

- Initial focused RED `reports/report_1198/` failed before Story089 diagnostics,
  activation APIs, scene nodes, and state fields existed.
- Focused GREEN `reports/report_1200/` passed the initial Story089 contract.
- MCP runtime then exposed a real stale-reference bug after the Spark Rat death
  tween queued the enemy free; the regression was captured as RED
  `reports/report_1202/`.
- Final focused GREEN `reports/report_1205/` passed `3/3`, including the
  death-tween settled diagnostics path.
- Related GREEN `reports/report_1204/` passed `33/33` across Story089,
  aftershock chain regressions, relay/service-lift/no-loss/no-replay, and steam
  hazard suites.
- Headless smoke exited `0`; the log file had no project script, parse,
  invalid-call, invalid-access, missing-resource, resource-load, or
  shadowed-variable errors by keyword scan. The Godot process still printed the
  existing cleanup-time ObjectDB/resource messages at exit.
- Godot MCP `2.9.1` / Godot `4.7-stable` confirmed helper live, live Story088
  cache claim `true`, active entity `2132`, Spark Rat `AnimatedSprite2D`,
  SpriteFrames path, `idle/run/attack_tell/attack/hurt/death` frame counts all
  `3`, opening-grace total `14`, hazard id/damage/cooldown/texture, player HP
  `100 -> 92`, cleared route label, Story074 relay savepoint, service lift
  `Call lift`, Story068/071 no-replay sentinels, final game log containing only
  the helper registration line, empty final editor log, and a non-empty
  `960x539` game screenshot.
- Story207's first bounded run `reports/report_2247/results.xml` exposed stale
  immediate-hide expectations for the shared live death behavior. Focused
  `reports/report_2248/report_1/results.xml` passed Story089 `3/3` after the
  test separated visible live death from hidden restored completion. Final
  `reports/report_2251/results.xml` passed the wider eight-suite `14/14`
  regression.
- Godot 4.7 / MCP 3.0.4 accepted run `r135689461-59` claimed Story088 through
  real input and verified Story089 as available but inactive: entity `2132`
  remained hidden, `24 HP`, and hurtbox `gone`, so it could not steal the
  Story207 attack or activate before its own x `2768` boundary.
- Story208 adds production-only fresh-movement tracking for Story089 and resets
  the runtime tracker on `set_local_state()`, so stationary threshold position
  and restored-state teleport cannot activate entity `2132`.
- Story208 final bounded regression `reports/report_2258/results.xml` passed
  five suites and `11/11`. Godot 4.7 / MCP 3.0.4 accepted run
  `r137556639-60` proved real `move_right`, real steam overlap `100 -> 92`,
  production Spark Rat bite metadata, two real light hits `24 -> 12 -> 0`,
  live death/vent shutdown and Story090 available/inactive safety.
- The active MCP capture shows valid authored art but tight player/enemy/steam
  silhouette overlap. Warning timing or encounter staging remains a focused
  visual follow-up; no new image asset is required.
