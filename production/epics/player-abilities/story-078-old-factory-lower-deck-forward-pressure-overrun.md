# Story 078: Old Factory Lower Deck Forward Pressure Overrun

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Combat Pacing
> **Type**: Integration + Gameplay Runtime + Visual/Feel
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-08

## Context

**GDD**: `design/gdd/player-abilities.md`,
`design/gdd/exploration-ability-gating.md`,
`design/gdd/feline-combat.md`, `design/gdd/scene-management.md`,
`design/gdd/death-respawn.md`

**Requirements**: `TR-scene-004`, `TR-explore-005`, `TR-combat-002`,
`TR-respawn-002`

**ADR Governing Implementation**: ADR-0004 Combat tuning; ADR-0007 Scene
management; ADR-0018 Player abilities; ADR-0021 Save system.

Story077 clears the forward-pressure beacon ambush and leaves the route ready
for a deeper combat beat. This story adds a compact follow-up overrun: after
the beacon ambush is defeated, crossing deeper into the lower deck activates one
animated Factory Spark Rat and one pressure vent. The slice must be visible and
playable at runtime, persist its clear state, and preserve the Story074 exit
relay savepoint and optional service lift.

## Acceptance Criteria

- [x] `factory_route_transition_shell.tscn` contains
  `FactoryLowerDeckForwardPressureOverrunSparkRat` and
  `FactoryLowerDeckForwardPressureOverrunVent`.
- [x] The overrun is unavailable while
  `factory_lower_deck_forward_pressure_beacon_ambush_defeated=false`; enemy and
  hazard remain hidden/inactive, and manual activation returns `false`.
- [x] Once the beacon ambush is defeated, crossing activation x `1620.0`
  activates entity `2122`, assigns the player as target, enables Spark Rat
  process and physics, enables the pressure vent hazard, and updates route
  feedback to `Survive Forward Pressure Overrun`.
- [x] The enemy uses `AnimatedSprite2D + SpriteFrames` with `idle`, `run`,
  `attack_tell`, `attack`, `hurt`, and `death` animations, each with at least
  3 frames.
- [x] The pressure vent uses hazard id
  `old_factory_lower_deck_forward_pressure_overrun`, damage `8`, cooldown
  `1.0`, and the existing image-generated steam vent texture.
- [x] Defeating entity `2122` disables the enemy and hazard, persists
  `factory_lower_deck_forward_pressure_overrun_activated=true` and
  `factory_lower_deck_forward_pressure_overrun_defeated=true`, and advances
  route feedback to `Forward Pressure Overrun Cleared`.
- [x] Restoring completed state keeps the route marker lit, keeps Story077
  inactive/defeated, preserves the Story074 exit relay savepoint contract,
  keeps the Story073 guard defeated/inactive, does not replay Story068 clear
  burst or Story071 cache audio, and preserves `FactoryServiceLift` prompt
  `Call lift`.
- [x] No new visual or audio assets are generated; this story reuses existing
  image-generated Factory Spark Rat frame animation, Old Factory steam vent, and
  post-bulkhead backdrop assets, with reuse recorded in asset docs and QA
  evidence.
- [x] Focused/related GdUnit, headless smoke, and Godot MCP runtime checks pass
  under Godot 4.7 / Godot AI MCP 2.9.1.

## Out of Scope

New enemy family art, new generated visual assets, new room scene, minimap/full
map UI, fast travel UI, SaveSystem schema changes, service-lift route changes,
new player ability, reward cache/economy changes, authored combat or hazard
SFX, boss content, particles/shaders, and broader lower-deck layout work.

## Implementation Notes

- Reuse `FactorySparkRat` through
  `scenes/characters/factory_spark_rat.tscn` and bind it to entity id `2122`.
- Reuse `FactorySteamVentHazard` semantics for the local pressure vent, keeping
  it hidden/non-monitoring until the overrun is active.
- Keep the new overrun state scene-local through
  `OldFactoryEntranceScene.get_local_state()` / `set_local_state()`.
- Keep the Story074 relay as the active non-boss respawn anchor; Story078 does
  not write a new savepoint contract.
- Do not mark the route complete by text only: the cleared objective must return
  `complete=true` from `get_factory_route_objective_diagnostics()`.

## Asset Pipeline

No new asset generation is required. Reuse:

- Enemy SpriteFrames:
  `assets/characters/factory_spark_rat/factory_spark_rat_sprite_frames.tres`
- Enemy frame source:
  `assets/characters/factory_spark_rat/source/factory_spark_rat_sprite_sheet_imagegen_20260626.png`
  and
  `assets/characters/factory_spark_rat/source/factory_spark_rat_attack_tell_sheet_imagegen_20260626.png`
- Hazard prop:
  `assets/environment/old_factory_steam_vent/factory_steam_vent_hazard.png`
- Backdrop:
  `assets/environment/old_factory_lower_deck_post_bulkhead/env_old_factory_lower_deck_post_bulkhead_backdrop_1280x720.png`

Record the Story078 reuse in `design/assets/asset-manifest.md`,
`design/assets/entity-inventory.md`, and QA evidence.

## Test Evidence

- Focused GdUnit:
  `tests/unit/gameplay/old_factory_lower_deck_forward_pressure_overrun_test.gd`
- Related regression:
  Story078 focused + Story077, Story076, Story075, Story074, Story073, Story070,
  service-lift, and no-loss respawn suites.
- Runtime evidence:
  Headless smoke and Godot MCP runtime checks must confirm scene load, enemy and
  hazard node presence, `AnimatedSprite2D + SpriteFrames` animation frame
  counts, beacon-ambush-clear gating, active hazard semantics, defeat
  persistence, restored completed-state no-replay, unchanged relay savepoint
  contract, service lift prompt, clean logs, and a non-empty screenshot with the
  active overrun visible.

## Verification Summary

- RED focused: `reports/report_1139/` failed as expected because Story078
  diagnostics and activation API did not exist.
- Focused GREEN: `reports/report_1142/` passed Story078 `2/2` with no errors,
  failures, skips, flaky cases, or orphans.
- Related GREEN: `reports/report_1143/` passed Story078, Story077, Story076,
  Story075, Story074, Story073, Story070, service-lift, and no-loss respawn
  suites `18/18`.
- Headless smoke: `reports/old_factory_forward_pressure_overrun_smoke.log`
  exited `0`; keyword scan found no project script/parse/invalid-call/access/
  missing-resource/resource-load errors. Godot still emitted the known
  cleanup-time ObjectDB/resource messages to terminal output.
- Godot MCP runtime evidence: Godot AI MCP `2.9.1` on Godot `4.7-stable`
  launched the scene with `autosave=false`, helper live, and no recent run
  errors. MCP confirmed locked/ready/active/defeated/restored diagnostics,
  runtime nodes, Spark Rat `AnimatedSprite2D` using
  `factory_spark_rat_sprite_frames.tres`, `idle/run/attack_tell/attack/hurt/death`
  frame counts of `3`, entity `2122`, hazard id
  `old_factory_lower_deck_forward_pressure_overrun`, hazard damage `8`,
  cooldown `1.0`, route labels, persisted local flags, stable Story074
  savepoint contract, Story068/071/073/077 no-replay checks, service lift
  prompt `Call lift`, game log containing only helper registration, empty editor
  log, and a non-empty MCP game screenshot response at `960x539`.

**Status**: [x] Complete.
