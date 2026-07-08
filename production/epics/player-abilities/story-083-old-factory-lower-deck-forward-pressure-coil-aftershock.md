# Story 083: Old Factory Lower Deck Forward Pressure Coil Aftershock

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

Story082 establishes a Spark Rat + Coil Rat pincer after the Coil Rat
breakthrough. Story083 keeps the route moving with a smaller post-pincer
aftershock: the player pushes past the pincer and contains one more Coil Rat
pressure beat. This is intentionally a compact ACT slice that reinforces the
new animated Coil Rat enemy without adding a new enemy family, hazard, reward
economy, savepoint, service-lift route, or room scene.

## Acceptance Criteria

- [x] `factory_route_transition_shell.tscn` contains
  `FactoryLowerDeckForwardPressureCoilAftershockCoilRat` using
  `src/gameplay/factory_coil_rat.tscn`.
- [x] The Coil Aftershock is unavailable while
  `factory_lower_deck_forward_pressure_coil_pincer_cleared=false`; the enemy
  remains hidden/inactive, and manual activation returns `false`.
- [x] Once Story082 is cleared, crossing activation x `2144.0` activates entity
  `2128`, assigns the player as target, enables process/physics, starts opening
  grace frame pacing `8`, and updates route feedback to
  `Contain Coil Aftershock`.
- [x] The enemy uses `AnimatedSprite2D + SpriteFrames` with `idle`, `run`,
  `attack_tell`, `attack`, `hurt`, and `death` animations, each with at least
  3 transparent PNG frames. No placeholder rectangle or single-frame character
  art is accepted for this Story.
- [x] Defeating entity `2128` persists
  `factory_lower_deck_forward_pressure_coil_aftershock_activated=true`,
  `factory_lower_deck_forward_pressure_coil_aftershock_coil_rat_defeated=true`,
  and `factory_lower_deck_forward_pressure_coil_aftershock_cleared=true`,
  disables the enemy, marks the route objective complete, and updates route
  feedback to `Forward Pressure Coil Aftershock Cleared`.
- [x] Restoring completed state keeps Story083 inactive/cleared, keeps Story082
  Coil Pincer cleared, keeps Story081 Coil Rat breakthrough defeated, preserves
  the Story074 exit relay savepoint contract, does not replay Story068 clear
  burst or Story071 cache audio, and preserves `FactoryServiceLift` prompt
  `Call lift`.
- [x] Focused/related GdUnit, headless smoke, and Godot MCP runtime checks pass
  under Godot 4.7 / Godot AI MCP 2.9.1, including scene load, the enemy node,
  SpriteFrames frame counts, clean logs, and a non-empty screenshot showing the
  active aftershock state.

## Out of Scope

New generated character art, new enemy family, new AI behavior tree, new
steam/electric hazard, pincer escalation, reward cache/economy changes, new
savepoint, SaveSystem schema changes, service-lift route changes, minimap/fast
travel UI, authored audio, Boss2, particles/shaders, and broader lower-deck
layout work.

## Implementation Notes

- Reuse existing `FactoryCoilRat` gameplay scene and imported frame animation
  assets.
- Keep Story083 state scene-local through
  `OldFactoryEntranceScene.get_local_state()` / `set_local_state()`.
- Use encounter id `old_factory_lower_deck_forward_pressure_coil_aftershock`.
- Keep the Story074 relay as the active non-boss respawn anchor; Story083 does
  not write a new savepoint contract.
- Do not lock `FactoryServiceLift`; the aftershock is a forward-route pressure
  beat, not a lift gate.

## Asset Pipeline

No new visual assets are required for this Story. It reuses the imported,
image-generated animated Factory Coil Rat:

- Factory Coil Rat SpriteFrames:
  `assets/characters/factory_coil_rat/factory_coil_rat_sprite_frames.tres`

Usage must be recorded in `design/assets/asset-manifest.md`,
`design/assets/entity-inventory.md`, this story, and QA evidence.

## Test Evidence

- Focused GdUnit:
  `tests/unit/gameplay/old_factory_lower_deck_forward_pressure_coil_aftershock_test.gd`
- Related regression:
  Story083 focused + Story082, Story081, Story080, Story079, Story078,
  Story077, Story076, Story075, Story074, service-lift, and no-loss respawn
  suites.
- Runtime evidence:
  Headless smoke and Godot MCP runtime checks must confirm scene load, the Coil
  Aftershock enemy present, Story082-clear gating, enemy SpriteFrames frame
  counts, active route label, defeat semantics, restored state, unchanged relay
  savepoint contract, service lift prompt, clean logs, and a non-empty
  screenshot with the Coil Rat visible.

## Verification Summary

- RED: `reports/report_1169/` failed as expected before Story083 diagnostics
  and activation APIs existed.
- Focused GREEN: `reports/report_1170/` passed Story083 `2/2` with `0`
  errors, failures, skipped tests, flaky tests, or orphans.
- Related GREEN: `reports/report_1171/` passed Story083 plus Story082, Story081,
  Story080, Story079, Story078, Story077, Story076, Story075, Story074,
  service-lift, and no-loss respawn suites `24/24` with `0` errors, failures,
  skipped tests, flaky tests, or orphans.
- Headless smoke:
  `reports/old_factory_forward_pressure_coil_aftershock_smoke.log` exited `0`;
  keyword scan found no project script, parse, invalid-call, invalid-access,
  missing-resource, or resource-load errors.
- Godot MCP: Godot AI MCP `2.9.1` on Godot `4.7-stable` launched
  `res://scenes/factory_route_transition_shell.tscn` with `autosave=false`,
  confirmed helper live, locked/ready/active/defeated/restored diagnostics,
  entity `2128`, `factory_coil_rat` SpriteFrames path, six animation frame
  counts of `3`, opening grace frames `8`, restored completed-state continuity,
  Story074 exit-relay savepoint contract, Story068/071 no-replay checks,
  `FactoryServiceLift` prompt `Call lift`, a game log containing only the MCP
  helper registration line, and an empty editor log after clearing eval-probe
  noise.
- MCP screenshot: `editor_screenshot(source="game")` returned a non-empty
  `960x539` game framebuffer showing the active aftershock Coil Rat.

## Dependencies

- Depends on: Story082 Old Factory Lower Deck Forward Pressure Coil Pincer
- Unlocks: Deeper Old Factory route content after the Coil Aftershock
