# Story 082: Old Factory Lower Deck Forward Pressure Coil Pincer

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

Story081 introduces the Factory Coil Rat as a distinct animated threat after
the pressure relief ambush. Story082 turns that new enemy into a small ACT
pressure test: the player pushes beyond the breakthrough and triggers a pincer
using one Coil Rat and one Spark Rat. The slice adds visible combat density
without adding new AI families, save schema, service-lift routing, or a new
room scene.

## Acceptance Criteria

- [x] `factory_route_transition_shell.tscn` contains
  `FactoryLowerDeckForwardPressureCoilPincerSparkRat` using
  `src/gameplay/factory_spark_rat.tscn` and
  `FactoryLowerDeckForwardPressureCoilPincerCoilRat` using
  `src/gameplay/factory_coil_rat.tscn`.
- [x] The Coil Pincer is unavailable while
  `factory_lower_deck_forward_pressure_coil_rat_breakthrough_defeated=false`;
  both enemies remain hidden/inactive, and manual activation returns `false`.
- [x] Once Story081 is defeated, crossing activation x `2016.0` activates
  entity `2126` as the Spark Rat side and entity `2127` as the Coil Rat side,
  assigns the player as target for both, enables process/physics for both, and
  updates route feedback to `Break Coil Pincer`.
- [x] The encounter uses `AnimatedSprite2D + SpriteFrames` enemies with
  `idle`, `run`, `attack_tell`, `attack`, `hurt`, and `death` animations, each
  with at least 3 transparent PNG frames. No new placeholder rectangle or
  single-frame character art is accepted for this Story.
- [x] The two enemies use staggered opening grace frames so the Spark Rat
  starts pressure first and the Coil Rat follows; diagnostics expose both
  pacing states for tests and MCP probes.
- [x] Defeating only one enemy keeps the encounter incomplete. Defeating both
  persists
  `factory_lower_deck_forward_pressure_coil_pincer_activated=true`,
  `factory_lower_deck_forward_pressure_coil_pincer_spark_rat_defeated=true`,
  `factory_lower_deck_forward_pressure_coil_pincer_coil_rat_defeated=true`,
  and
  `factory_lower_deck_forward_pressure_coil_pincer_cleared=true`, disables both
  enemies, marks the route objective complete, and updates route feedback to
  `Forward Pressure Coil Pincer Cleared`.
- [x] Restoring completed state keeps Story082 inactive/cleared, keeps Story081
  Coil Rat breakthrough defeated, keeps Story080 relief ambush defeated, keeps
  Story079 breaker cut, preserves the Story074 exit relay savepoint contract,
  does not replay Story068 clear burst or Story071 cache audio, and preserves
  `FactoryServiceLift` prompt `Call lift`.
- [x] Focused/related GdUnit, headless smoke, and Godot MCP runtime checks pass
  under Godot 4.7 / Godot AI MCP 2.9.1, including scene load, both enemy nodes,
  SpriteFrames frame counts, clean logs, and a non-empty screenshot showing the
  active pincer state.

## Out of Scope

New generated character art, new enemy family, new AI behavior tree, new
steam/electric hazard, reward cache/economy changes, new savepoint, SaveSystem
schema changes, service-lift route changes, minimap/fast travel UI, authored
audio, Boss2, particles/shaders, and broader lower-deck layout work.

## Implementation Notes

- Reuse existing `FactorySparkRat` and `FactoryCoilRat` gameplay scenes and
  their imported frame animation assets.
- Keep Story082 state scene-local through
  `OldFactoryEntranceScene.get_local_state()` / `set_local_state()`.
- Use a single activation threshold and one shared encounter id:
  `old_factory_lower_deck_forward_pressure_coil_pincer`.
- Keep the Story074 relay as the active non-boss respawn anchor; Story082 does
  not write a new savepoint contract.
- Do not lock `FactoryServiceLift`; the pincer is a forward-route pressure beat,
  not a lift gate.

## Asset Pipeline

No new visual assets are required for this Story. It reuses imported,
image-generated animated characters:

- Factory Coil Rat SpriteFrames:
  `assets/characters/factory_coil_rat/factory_coil_rat_sprite_frames.tres`
- Factory Spark Rat SpriteFrames:
  `assets/characters/factory_spark_rat/factory_spark_rat_sprite_frames.tres`

Usage must be recorded in `design/assets/asset-manifest.md`,
`design/assets/entity-inventory.md`, this story, and QA evidence.

## Test Evidence

- Focused GdUnit:
  `tests/unit/gameplay/old_factory_lower_deck_forward_pressure_coil_pincer_test.gd`
- Related regression:
  Story082 focused + Story081, Story080, Story079, Story078, Story077,
  Story076, Story075, Story074, service-lift, and no-loss respawn suites.
- Runtime evidence:
  Headless smoke and Godot MCP runtime checks must confirm scene load, both
  pincer enemies present, Story081-clear gating, enemy SpriteFrames frame
  counts, active route label, partial defeat vs full clear semantics, restored
  state, unchanged relay savepoint contract, service lift prompt, clean logs,
  and a non-empty screenshot with both enemies visible.

## Verification Summary

- RED: `reports/report_1162/` failed as expected before the Story082
  diagnostics and activation APIs existed.
- Focused GREEN: `reports/report_1166/` passed Story082 `2/2` with `0`
  errors, failures, skipped tests, flaky tests, or orphans.
- Related GREEN: `reports/report_1167/` passed Story082 plus Story081, Story080,
  Story079, Story078, Story077, Story076, Story075, Story074, service-lift, and
  no-loss respawn suites `24/24` with `0` errors, failures, skipped tests,
  flaky tests, or orphans.
- Headless smoke: `reports/old_factory_forward_pressure_coil_pincer_smoke.log`
  exited `0`; keyword scan found no project script, parse, invalid-call,
  invalid-access, missing-resource, or resource-load errors.
- Godot MCP: Godot AI MCP `2.9.1` on Godot `4.7-stable` launched
  `res://scenes/factory_route_transition_shell.tscn` with `autosave=false`,
  confirmed helper live, active pincer diagnostics, entities `2126` and `2127`,
  `factory_spark_rat` and `factory_coil_rat` SpriteFrames paths, six animation
  frame counts of `3`, opening grace frames `10/26`, partial vs full defeat,
  restored completed-state continuity, Story074 exit-relay savepoint contract,
  Story068/071 no-replay checks, `FactoryServiceLift` prompt `Call lift`, a game
  log containing only the MCP helper registration line, and an empty editor log
  after clearing eval-probe noise.
- MCP screenshot: `reports/visual/cinderpaw-mcp-old-factory-forward-pressure-coil-pincer-20260709.png`
  is a non-empty `1278x718` PNG captured from the active pincer runtime state.

## Dependencies

- Depends on: Story081 Old Factory Lower Deck Forward Pressure Coil Rat
  Breakthrough
- Unlocks: Deeper Old Factory route content after the Coil Pincer
