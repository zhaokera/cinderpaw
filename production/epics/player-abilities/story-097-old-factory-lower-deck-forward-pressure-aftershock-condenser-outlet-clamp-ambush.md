# Story 097: Old Factory Lower Deck Forward Pressure Aftershock Condenser Outlet Clamp Ambush

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Combat
> **Type**: Integration + Gameplay Runtime + Visual/Feel
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-22

## Context

**GDD**: `design/gdd/player-abilities.md`,
`design/gdd/exploration-ability-gating.md`,
`design/gdd/feline-combat.md`, `design/gdd/scene-management.md`,
`design/gdd/death-respawn.md`

**Requirements**: `TR-scene-004`, `TR-explore-005`, `TR-respawn-002`

**ADR Governing Implementation**: ADR-0004 Collision detection; ADR-0007 Scene
management; ADR-0018 Player abilities; ADR-0021 Save system.

Story096 crosses the aftershock condenser outlet. Story097 turns the next
right-side pocket into a visible ACT combat beat: a newly generated outlet
clamp prop anchors the space, and a reused image-generated Factory Spark Rat
ambush forces a real attack/defeat loop before the route is considered clear.

## Acceptance Criteria

- [x] `FactoryLowerDeckForwardPressureAftershockCondenserOutletClamp` exists in
  `factory_route_transition_shell.tscn`, starts hidden, uses a newly generated
  transparent `256x256` PNG, and extends the right-side route to x `5760.0`.
- [x] `FactoryLowerDeckForwardPressureAftershockCondenserOutletClampSparkRat`
  reuses the existing Factory Spark Rat `AnimatedSprite2D + SpriteFrames`
  scene, starts hidden/inactive, and is registered as entity id `2138`.
- [x] The clamp ambush stays locked until
  `factory_lower_deck_forward_pressure_aftershock_condenser_outlet_crossed=true`;
  locked activation returns `false`, the prop is hidden, and the Spark Rat has
  no target/process/physics.
- [x] Once Story096 is crossed, diagnostics expose availability, visibility,
  generated texture path, route width, right wall, camera limit, activation x
  `5220.0`, Spark Rat node/entity/family, SpriteFrames path, six animation
  frame counts, and route label `Aftershock Condenser Outlet Crossed`.
- [x] Crossing the activation point starts the ambush, assigns the player as
  target, enables process/physics/collision for the Spark Rat, starts pacing,
  and advances route feedback to `Clear Outlet Clamp Ambush`.
- [x] Defeating entity `2138` persists
  `factory_lower_deck_forward_pressure_aftershock_condenser_outlet_clamp_ambush_activated=true`,
  `..._spark_rat_defeated=true`, and `..._cleared=true`, disables its gameplay
  collision/target/physics while preserving the live death animation, rejects
  repeat activation, and advances route feedback to
  `Outlet Clamp Ambush Cleared`.
- [x] Restoring local state from the cleared flags keeps Story094, Story095,
  and Story096 intact without replaying them; the Story096 outlet vent remains
  non-contacting and the service lift prompt remains `Call lift`.
- [x] Focused/related GdUnit, headless smoke, and Godot MCP runtime checks pass
  under Godot 4.7 / Godot AI MCP 2.9.1, including scene reload, runtime helper,
  generated prop, active `AnimatedSprite2D` Spark Rat, entity `2138` damage,
  clean current-run logs, and a non-empty screenshot showing the clamp ambush.

## Out of Scope

New enemy family, new enemy animation art, new AI behavior, Coil Rat or multiwave
ambush, reward cache, savepoint, minimap, fast travel, new hazard, new player
ability, authored audio, particles/shaders, Boss2, SaveSystem schema changes,
and broader lower-deck art replacement.

## Implementation Notes

- Activation is gated by
  `factory_lower_deck_forward_pressure_aftershock_condenser_outlet_crossed`.
- Route geometry extends the factory shell from x `5120.0` to x `5760.0`.
- The combat pocket uses x `5220.0` as the activation point, clamp prop at
  x `5320.0`, and Spark Rat spawn at x `5460.0`.
- The enemy reuses `src/gameplay/factory_spark_rat.tscn` and
  `assets/characters/factory_spark_rat/factory_spark_rat_sprite_frames.tres`.

## Asset Pipeline

New image-generated runtime prop:

- Source:
  `assets/generated/source/old_factory_aftershock_condenser_outlet_clamp_imagegen_20260709.png`
- Alpha source:
  `assets/generated/source/old_factory_aftershock_condenser_outlet_clamp_alpha_20260709.png`
- Metadata:
  `assets/generated/source/old_factory_aftershock_condenser_outlet_clamp_imagegen_20260709.json`
- Runtime:
  `assets/environment/old_factory_aftershock_condenser_outlet_clamp/env_old_factory_aftershock_condenser_outlet_clamp_256.png`

The ambush enemy reuses the imported image-generated Factory Spark Rat frame
animation assets; no new character art was generated for Story097.

## Test Evidence

- Focused GdUnit:
  `tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_outlet_clamp_ambush_test.gd`
  - Initial RED: `reports/report_1240/` (missing Story097 asset/API)
  - Final RED after runtime size adjustment: `reports/report_1241/`
  - Focused GREEN: `reports/report_1242/` (`2/2`)
- Related regression:
  - Minimal related GREEN: `reports/report_1243/` (`18/18`) covering
    Story097, Story096, Story095, Story094, Story093, Story092, savepoint
    respawn selection, and no-loss respawn state.
- Runtime evidence:
  Headless factory smoke
  `reports/old_factory_aftershock_condenser_outlet_clamp_ambush_smoke.log`
  exited `0`. The log contains no project script/parse/invalid-call/access or
  missing-resource/resource-load errors; Godot still reports exit-time
  ObjectDB/resource cleanup warnings.
- Godot MCP:
  Godot AI MCP `2.9.1` on Godot `4.7-stable` confirmed scene reload from disk,
  runtime helper live, clamp and Spark Rat nodes present, generated clamp
  texture path mounted on `Sprite2D`, active ambush diagnostics with entity
  `2138`, Factory Spark Rat SpriteFrames path and 3-frame counts for
  `idle/run/attack_tell/attack/hurt/death`, `apply_damage(2138, 999)=true`,
  cleared and restored local-state persistence, duplicate activation `false`,
  Story096 outlet crossed/contact disabled, Story095 savepoint active,
  Story094 landing cleared, service lift prompt `Call lift`, current-run game
  log containing only helper registration, no editor entries after cursor `9`,
  and a non-empty `960x539` screenshot showing the generated clamp prop, player,
  and active Spark Rat.
- Story216 production handoff isolation:
  `reports/report_2312/results.xml` passed the final bounded `4/4`; MCP 3.0.4
  run `r153467824-10` crossed Story096 through real movement, then confirmed
  the clamp is available/visible while entity `2138` remains inactive, hidden,
  untargeted and without process/physics after a no-input x `5224.0` probe.
- Story217 production combat/death handoff:
  `reports/report_2319/results.xml` passed `6/6`; MCP 3.0.4 run
  `r155047659-13` activated Story097 through real movement, defeated entity
  `2138` through `Input.attack -> cat_claw_light`, preserved the visible death
  frames while disabling combat, and isolated Story098 from the killing frame.

## Dependencies

- Depends on: Story096 Old Factory Lower Deck Forward Pressure Aftershock Condenser Outlet Traverse
- Unlocks: Story098 outlet drip vent traverse

## Verification Summary

Story097 followed thin TDD: RED `reports/report_1240/` and `reports/report_1241/`
failed before asset/API support existed, focused GREEN `reports/report_1242/`
passed `2/2`, and related GREEN `reports/report_1243/` passed `18/18`.
Headless smoke exited `0`. Godot MCP runtime validation passed under Godot 4.7
and Godot AI MCP 2.9.1 after relaunching from an eval-snippet syntax break.
Story216 adds a clean Godot 4.7 / MCP 3.0.4 proof that production outlet
crossing does not silently consume the clamp ambush before its own movement
and combat Story. Story217 adds the real movement/attack/live-death proof and
reconciles the old immediate-hide assertion with the shared Rat Minion death
presentation contract.
