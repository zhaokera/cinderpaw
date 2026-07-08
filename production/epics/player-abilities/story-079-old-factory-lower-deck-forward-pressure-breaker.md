# Story 079: Old Factory Lower Deck Forward Pressure Breaker

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

**Requirements**: `TR-scene-004`, `TR-explore-005`, `TR-respawn-002`

**ADR Governing Implementation**: ADR-0007 Scene management; ADR-0018 Player
abilities; ADR-0021 Save system.

Story078 clears the forward-pressure overrun. This story adds a compact
post-combat breaker stand: after the overrun is defeated, crossing deeper into
the lower deck activates one animated Factory Spark Rat and one pressure vent.
Defeating the guard makes a visible pressure breaker console interactable so
Cinderpaw can cut the pressure line. The slice must be visible and playable at
runtime, use a new generated transparent PNG prop, persist its one-shot state,
and preserve the Story074 exit relay savepoint plus optional service lift.

## Acceptance Criteria

- [x] `factory_route_transition_shell.tscn` contains
  `FactoryLowerDeckForwardPressureBreakerSparkRat`,
  `FactoryLowerDeckForwardPressureBreakerVent`, and
  `FactoryLowerDeckForwardPressureBreaker`.
- [x] The breaker is unavailable while
  `factory_lower_deck_forward_pressure_overrun_defeated=false`; enemy, hazard,
  and breaker remain hidden/inactive, and manual activation returns `false`.
- [x] Once the overrun is defeated, crossing activation x `1668.0` activates
  entity `2123`, assigns the player as target, enables Spark Rat process and
  physics, enables pressure vent hazard
  `old_factory_lower_deck_forward_pressure_breaker`, and updates route feedback
  to `Secure Forward Pressure Breaker`.
- [x] The enemy uses `AnimatedSprite2D + SpriteFrames` with `idle`, `run`,
  `attack_tell`, `attack`, `hurt`, and `death` animations, each with at least
  3 frames.
- [x] Defeating entity `2123` disables the enemy and hazard, persists
  `factory_lower_deck_forward_pressure_breaker_activated=true` and
  `factory_lower_deck_forward_pressure_breaker_secured=true`, reveals the
  breaker console with prompt `Cut Pressure`, endpoint id
  `old_factory_lower_deck_forward_pressure_breaker`, and the generated breaker
  texture.
- [x] Activating the breaker console from player range succeeds once, persists
  `factory_lower_deck_forward_pressure_breaker_cut=true`, plays the existing
  unlock VFX, changes the prompt to `Pressure Cut`, and updates route feedback
  to `Forward Pressure Breaker Cut`.
- [x] Restoring completed state keeps the breaker visible/cut, keeps Story079
  guard and Story078 overrun inactive/defeated, preserves the Story074 exit
  relay savepoint contract, does not replay Story068 clear burst or Story071
  cache audio, and preserves `FactoryServiceLift` prompt `Call lift`.
- [x] A new transparent PNG breaker prop is generated through image generation,
  imported through the Godot asset pipeline, and recorded in asset docs and QA
  evidence with its prompt/source.
- [x] Focused/related GdUnit, headless smoke, and Godot MCP runtime checks pass
  under Godot 4.7 / Godot AI MCP 2.9.1.

## Out of Scope

New enemy family art, additional combat encounters, new room scene, minimap/full
map UI, fast travel UI, SaveSystem schema changes, service-lift route changes,
new player ability, reward cache/economy changes, authored audio, boss content,
particles/shaders, and broader lower-deck layout work.

## Implementation Notes

- Reuse `FactorySparkRat` through
  `scenes/characters/factory_spark_rat.tscn` and bind it to entity id `2123`.
- Reuse `FactorySteamVentHazard` semantics for the local pressure vent, keeping
  it hidden/non-monitoring until the breaker stand is active.
- Reuse `FactoryDeepRouteEndpoint` for the breaker console range checks, prompt
  state, and existing unlock VFX.
- Keep the breaker state scene-local through
  `OldFactoryEntranceScene.get_local_state()` / `set_local_state()`.
- Keep the Story074 relay as the active non-boss respawn anchor; Story079 does
  not write a new savepoint contract.
- Do not alter Story078's cleared label before the player crosses the breaker
  stand activation boundary; the combat activation carries the next route label.

## Asset Pipeline

Generate one new transparent PNG prop:

- Runtime asset:
  `assets/environment/old_factory_forward_pressure_breaker/env_old_factory_forward_pressure_breaker_console_256.png`
- Source prompt and image-generation metadata:
  `assets/generated/source/old_factory_forward_pressure_breaker_console_imagegen_20260708.md`

The asset should be a compact 2D side-view scrap pressure breaker console with
steel casing, warning stripes, cyan pressure gauge, and cut cable details. It
must have a transparent background, consistent 256x256 framing, no text, no
watermark, and readable silhouette at gameplay scale.

## Test Evidence

- Focused GdUnit:
  `tests/unit/gameplay/old_factory_lower_deck_forward_pressure_breaker_test.gd`
- Related regression:
  Story079 focused + Story078, Story077, Story076, Story075, Story074, Story073,
  service-lift, and no-loss respawn suites.
- Runtime evidence:
  Headless smoke and Godot MCP runtime checks must confirm scene load, breaker
  guard enemy, hazard, and console node presence, generated texture path,
  overrun-clear gating, enemy SpriteFrames frame counts, active hazard
  semantics, one-shot breaker activation, persisted restored state, unchanged
  relay savepoint contract, service lift prompt, clean logs, and a non-empty
  screenshot with the active breaker stand visible.

## Verification Summary

- RED focused: `reports/report_1144/` failed as expected because Story079
  diagnostics and activation APIs did not exist.
- Focused GREEN: `reports/report_1147/` passed Story079 `2/2` with no errors,
  failures, skips, flaky cases, or orphans.
- Related GREEN: `reports/report_1148/` passed Story079, Story078, Story077,
  Story076, Story075, Story074, Story073, service-lift, and no-loss respawn
  suites `18/18`.
- Headless smoke: `reports/old_factory_forward_pressure_breaker_smoke.log`
  exited `0`; keyword scan found no project script/parse/invalid-call/access/
  missing-resource/resource-load errors. Godot still emitted the known
  cleanup-time ObjectDB/resource messages to terminal output.
- Godot MCP runtime evidence: Godot AI MCP `2.9.1` on Godot `4.7-stable`
  launched the scene with `autosave=false`, confirmed helper live, and verified
  locked/ready/active/secured/cut/restored diagnostics. MCP confirmed entity
  `2123`, Spark Rat `AnimatedSprite2D + SpriteFrames`
  `idle/run/attack_tell/attack/hurt/death=3`, hazard id
  `old_factory_lower_deck_forward_pressure_breaker`, damage `8`, cooldown
  `1.0`, generated breaker texture path, one-shot cut activation, duplicate
  cut rejection, persisted local flags, restored no-replay
  `unlock_feedback_spawn_count=0`, service lift prompt `Call lift`, game log
  containing only helper registration, empty editor log, and non-empty
  `960x539` MCP game screenshots for active and secured breaker states.
