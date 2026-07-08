# Story 087: Old Factory Lower Deck Forward Pressure Aftershock Exhaust Pursuer

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

Story086 turns the aftershock exit into a timing traversal. Story087 follows
that movement beat with a compact ACT combat beat: once Cinderpaw crosses the
aftershock exhaust, pushing deeper triggers a single Coil Rat pursuer. The
slice keeps the route playable and visible without adding a new enemy family,
new generated art, a new hazard, a new reward cache, a new savepoint, or a new
room scene.

## Acceptance Criteria

- [x] `factory_route_transition_shell.tscn` contains
  `FactoryLowerDeckForwardPressureAftershockExhaustPursuerCoilRat` using
  `src/gameplay/factory_coil_rat.tscn`.
- [x] The exhaust pursuer is unavailable while
  `factory_lower_deck_forward_pressure_aftershock_exhaust_crossed=false`; the
  enemy remains hidden/inactive, and manual activation returns `false`.
- [x] Once Story086 is crossed, crossing activation x `2552.0` activates entity
  `2131`, assigns the player as target, enables process/physics, starts opening
  grace frame pacing `10`, and updates route feedback to
  `Purge Aftershock Exhaust Pursuer`.
- [x] The enemy uses `AnimatedSprite2D + SpriteFrames` with `idle`, `run`,
  `attack_tell`, `attack`, `hurt`, and `death` animations, each with at least
  3 transparent PNG frames. No placeholder rectangle or single-frame character
  art is accepted for this Story.
- [x] Defeating entity `2131` persists
  `factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_activated=true`,
  `factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_coil_rat_defeated=true`,
  and `factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_cleared=true`,
  disables the enemy, marks the route objective complete, and updates route
  feedback to `Forward Pressure Exhaust Pursuer Cleared`.
- [x] Restoring completed state keeps Story087 inactive/cleared, keeps Story086
  exhaust crossed, keeps Story085 cleared, keeps Story084 cache claimed,
  preserves the Story074 exit relay savepoint contract, does not replay Story068
  clear burst or Story071 reward-cache audio, and preserves
  `FactoryServiceLift` prompt `Call lift`.
- [x] Focused/related GdUnit, headless smoke, and Godot MCP runtime checks pass
  under Godot 4.7 / Godot AI MCP 2.9.1, including scene load, the pursuer node,
  SpriteFrames frame counts, clean logs, and a non-empty screenshot showing the
  active pursuer state.

## Out of Scope

New generated character art, new enemy family, new AI behavior tree, new
hazard, new reward economy, new reward cache, new savepoint, SaveSystem schema
changes, service-lift route changes, minimap/fast travel UI, authored audio,
particles/shaders, Boss2, and broader lower-deck layout work.

## Implementation Notes

- Reuse existing `FactoryCoilRat` gameplay scene and imported frame animation
  assets.
- Keep Story087 state scene-local through
  `OldFactoryEntranceScene.get_local_state()` / `set_local_state()`.
- Use encounter id
  `old_factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer`.
- Keep the Story074 relay as the active non-boss respawn anchor; Story087 does
  not write a new savepoint contract.
- Do not lock `FactoryServiceLift`; the pursuer is a forward-route pressure
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
  `tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_test.gd`
  - RED: `reports/report_1191/`
  - GREEN: `reports/report_1192/` (`2/2`)
- Related regression:
  Story087 focused + Story086, Story085, Story084, Story083, Story074,
  service-lift, and no-loss respawn suites.
  - GREEN: `reports/report_1193/` (`23/23`)
- Runtime evidence:
  Headless smoke and Godot MCP runtime checks must confirm scene load, the
  pursuer enemy present, Story086-crossed gating, enemy SpriteFrames frame
  counts, active route label, defeat semantics, restored state, unchanged relay
  savepoint contract, service lift prompt, clean logs, and a non-empty
  screenshot with the Coil Rat visible.
  - Headless smoke:
    `reports/old_factory_forward_pressure_aftershock_exhaust_pursuer_smoke.log`
  - QA evidence:
    `production/qa/evidence/old-factory-forward-pressure-aftershock-exhaust-pursuer-2026-07-09.md`

## Dependencies

- Depends on: Story086 Old Factory Lower Deck Forward Pressure Aftershock Exhaust Traverse
- Unlocks: Deeper Old Factory route content after the aftershock exhaust pursuer
