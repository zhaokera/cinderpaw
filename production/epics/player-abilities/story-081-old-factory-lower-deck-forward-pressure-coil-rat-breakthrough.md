# Story 081: Old Factory Lower Deck Forward Pressure Coil Rat Breakthrough

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Route Progression
> **Type**: Integration + Gameplay Runtime + Visual/Feel
> **Estimate**: M
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

Story080 clears the post-breaker relief ambush. Story081 adds a more visible
follow-up ACT beat instead of another Spark Rat + steam vent reuse: the player
pushes deeper into the forward-pressure lane and triggers a newly animated
Factory Coil Rat variant. The new enemy keeps the existing RatMinion combat
loop for scope control, but introduces a distinct silhouette and frame
animation set generated through the asset pipeline.

## Acceptance Criteria

- [x] `factory_route_transition_shell.tscn` contains
  `FactoryLowerDeckForwardPressureCoilRat` using
  `src/gameplay/factory_coil_rat.tscn`.
- [x] The Coil Rat breakthrough is unavailable while
  `factory_lower_deck_forward_pressure_relief_ambush_defeated=false`; the enemy
  remains hidden/inactive, and manual activation returns `false`.
- [x] Once Story080 is defeated, crossing activation x `1888.0` activates
  entity `2125`, assigns the player as target, enables Coil Rat process and
  physics, and updates route feedback to `Face Coil Rat Breakthrough`.
- [x] The enemy uses `AnimatedSprite2D + SpriteFrames` with `idle`, `run`,
  `attack_tell`, `attack`, `hurt`, and `death` animations, each with at least
  3 transparent PNG frames under `assets/characters/factory_coil_rat/`.
- [x] New Factory Coil Rat source image, alpha-matted source, runtime frames,
  prompt/usage metadata, character scene, gameplay scene, and scripts are
  recorded in the asset manifest, entity inventory, story, and QA evidence.
- [x] Defeating entity `2125` disables the enemy, persists
  `factory_lower_deck_forward_pressure_coil_rat_breakthrough_activated=true`
  and
  `factory_lower_deck_forward_pressure_coil_rat_breakthrough_defeated=true`,
  marks the route objective complete, and updates route feedback to
  `Forward Pressure Coil Rat Breakthrough Cleared`.
- [x] Restoring completed state keeps Story081 inactive/defeated, keeps Story080
  relief ambush defeated, keeps Story079 breaker cut, preserves the Story074
  exit relay savepoint contract, does not replay Story068 clear burst or
  Story071 cache audio, and preserves `FactoryServiceLift` prompt `Call lift`.
- [x] Focused/related GdUnit, headless smoke, and Godot MCP runtime checks pass
  under Godot 4.7 / Godot AI MCP 2.9.1, including scene load, `AnimatedSprite2D`
  node presence, SpriteFrames frame counts, clean logs, and a non-empty
  screenshot showing the Coil Rat state.

## Out of Scope

New AI behavior tree, new discharge attack mode, steam vent/hazard, reward
cache/economy changes, new savepoint, SaveSystem schema changes, service-lift
route changes, minimap/fast travel UI, authored audio, Boss2, particles/shaders,
and broader lower-deck layout work.

## Implementation Notes

- Reuse the existing `RatMinion` combat loop and derive `FactoryCoilRat` as the
  Factory Spark Rat did, changing enemy family id, damage metadata, pacing, and
  animation names only where needed.
- Add the AGENTS-required pure character surface at
  `scenes/characters/factory_coil_rat.tscn` with
  `src/characters/factory_coil_rat.gd`.
- Add the gameplay wrapper at `src/gameplay/factory_coil_rat.tscn` with root
  `CharacterBody2D`, a `CollisionShape2D`, and child `Sprite` instancing the
  character scene.
- Keep Story081 state scene-local through
  `OldFactoryEntranceScene.get_local_state()` / `set_local_state()`.
- Do not alter Story080's cleared label before the player crosses the
  Coil Rat activation boundary.
- Keep the Story074 relay as the active non-boss respawn anchor; Story081 does
  not write a new savepoint contract.

## Asset Pipeline

New visual assets must be generated through image generation and imported into
Godot:

- Factory Coil Rat SpriteFrames:
  `assets/characters/factory_coil_rat/factory_coil_rat_sprite_frames.tres`
- Runtime frames:
  `assets/characters/factory_coil_rat/<animation>/factory_coil_rat_<animation>_000.png`
  through `_002.png` for `idle`, `run`, `attack_tell`, `attack`, `hurt`, and
  `death`.
- Source image and alpha source:
  `assets/characters/factory_coil_rat/source/factory_coil_rat_sprite_sheet_imagegen_20260708.png`
  and
  `assets/characters/factory_coil_rat/source/factory_coil_rat_sprite_sheet_alpha_20260708.png`.
- Prompt/usage metadata:
  `assets/characters/factory_coil_rat/source/factory_coil_rat_sprite_sheet_imagegen_20260708.md`.

## Test Evidence

- Focused GdUnit:
  `tests/unit/gameplay/old_factory_lower_deck_forward_pressure_coil_rat_breakthrough_test.gd`
- Related regression:
  Story081 focused + Story080, Story079, Story078, Story077, Story076, Story075,
  Story074, service-lift, and no-loss respawn suites.
- Runtime evidence:
  Headless smoke and Godot MCP runtime checks must confirm scene load,
  Coil Rat node presence, relief-clear gating, enemy SpriteFrames frame counts,
  active route label, defeat persistence, restored state, unchanged relay
  savepoint contract, service lift prompt, clean logs, and a non-empty screenshot
  with the Coil Rat visible.

## Verification Summary

- RED focused: `reports/report_1154/` failed as expected before the Story081
  diagnostics and activation APIs existed.
- Focused + related GREEN: `reports/report_1161/` passed Story081 plus
  Story080, Story079, Story078, Story077, Story076, Story075, Story074,
  service-lift, and no-loss respawn suites `22/22` with no errors, failures,
  skips, flaky cases, or orphans.
- Headless smoke:
  `reports/old_factory_forward_pressure_coil_rat_breakthrough_smoke.log`
  exited `0`; keyword scan found no project script, parse, invalid-call,
  invalid-access, missing-resource, or resource-load errors. The terminal still
  emitted the known Godot cleanup-time ObjectDB/resource messages.
- Godot AI MCP `2.9.1` on Godot `4.7-stable` launched
  `res://scenes/factory_route_transition_shell.tscn`, confirmed helper live,
  activated entity `2125` at x `1888.0`, verified
  `FactoryLowerDeckForwardPressureCoilRat` as a visible `CharacterBody2D`,
  verified its child `Sprite` as `AnimatedSprite2D`, confirmed
  `factory_coil_rat_sprite_frames.tres`, confirmed `idle`, `run`,
  `attack_tell`, `attack`, `hurt`, and `death` each have 3 frames, confirmed
  route feedback `Face Coil Rat Breakthrough`, then confirmed defeat and
  restored-completed contracts including Story080/079/074 preservation,
  Story068/071 no-replay, and `FactoryServiceLift` prompt `Call lift`.
- MCP game screenshot returned a non-empty `960x539` framebuffer with the Coil
  Rat visible; the current game viewport was saved to
  `reports/visual/cinderpaw-mcp-old-factory-forward-pressure-coil-rat-breakthrough-20260708.png`.
- Formal MCP logs after clearing eval-probe noise: game log contained only the
  helper registration line and editor log was empty.

## Dependencies

- Depends on: Story080 Old Factory Lower Deck Forward Pressure Relief Ambush
- Unlocks: Deeper Old Factory route content after the Coil Rat breakthrough
