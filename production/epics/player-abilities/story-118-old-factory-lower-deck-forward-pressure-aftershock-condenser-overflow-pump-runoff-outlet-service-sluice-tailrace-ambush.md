# Story 118: Old Factory Lower Deck Forward Pressure Aftershock Condenser Overflow Pump Runoff Outlet Service Sluice Tailrace Ambush

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Combat Encounter
> **Type**: Integration + Gameplay Runtime + Frame Animation Contract
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-22

## Context

**GDD**: `design/gdd/player-abilities.md`,
`design/gdd/exploration-ability-gating.md`,
`design/gdd/feline-combat.md`, `design/gdd/scene-management.md`,
`design/gdd/death-respawn.md`

**Requirements**: `TR-scene-004`, `TR-explore-005`, `TR-combat-001`,
`TR-combat-003`, `TR-respawn-002`

**ADR Governing Implementation**: ADR-0004 Collision detection; ADR-0005
Feline combat; ADR-0007 Scene management; ADR-0018 Player abilities; ADR-0021
Save system.

Story117 ended with Cinderpaw crossing the service-sluice tailrace. Story118
turns that handoff into a playable ACT beat by extending the right-side combat
pocket and activating a frame-animated Factory Coil Rat after the tailrace is
crossed. The encounter persists its cleared state so the Story106-117
runoff/service-sluice chain does not replay after restore.

## Acceptance Criteria

- [x] The tailrace ambush stays unavailable, inactive, and hidden until
  `factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_crossed=true`.
- [x] `FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffOutletServiceSluiceTailraceCoilRat`
  exists in `factory_route_transition_shell.tscn` after the tailrace exit and
  defaults hidden.
- [x] The encounter activates only when the player reaches x `12620.0`, assigns
  Cinderpaw as target, enables process/physics/collision, starts opening grace
  `10`, and updates route feedback to `Clear Tailrace Coil Rat`.
- [x] The enemy uses `AnimatedSprite2D + SpriteFrames` from
  `res://assets/characters/factory_coil_rat/factory_coil_rat_sprite_frames.tres`
  with `idle`, `run`, `attack_tell`, `attack`, `hurt`, and `death` each at
  least 3 frames.
- [x] Defeating entity `2143` disables target, physics, hurtbox and collision,
  preserves the visible/processing three-frame `death` animation through its
  fade/despawn window, persists activated/defeated/cleared local-state flags,
  marks the route objective complete, and updates feedback to
  `Repair Tailrace Relay`.
- [x] Scene bounds support the combat pocket: right wall x `13200`, camera and
  background right `13220`, ground right edge x `13300`, and at least 55 route
  floor tiles.
- [x] Restoring only the Story118 cleared flag backfills the Story106-117
  runoff/service-sluice chain, including tailrace crossed and exit hatch opened
  state, without replaying prior traversal, skirmish, cache, or hatch beats.
- [x] Focused/related GdUnit, headless smoke, and Godot MCP runtime checks pass
  under Godot 4.7 / Godot AI MCP 3.0.4.

## Out of Scope

New enemy families, new generated art, reward caches, gear economy changes,
savepoints, SaveSystem schema changes, minimap, fast travel, authored audio,
particles, shaders, Boss2, and broader lower-deck biome art replacement.

## Implementation Notes

- Story118 reuses the existing Factory Coil Rat frame-animation implementation
  and the established lower-deck enemy activation/pacing helpers.
- The route objective intentionally keeps `Service Sluice Tailrace Crossed`
  before activation, switches to `Clear Tailrace Coil Rat` while active, and
  hands the cleared encounter directly to `Repair Tailrace Relay`.
- The right wall, camera limit, background width, ground collision, and route
  floor visuals were extended so the enemy has room to fight instead of being
  squeezed into the tailrace hazard segment.

## Asset Pipeline

No new visual or audio assets were generated. Story118 reuses existing
image-generated/imported assets:

- Factory Coil Rat SpriteFrames:
  `assets/characters/factory_coil_rat/factory_coil_rat_sprite_frames.tres`
- Factory Coil Rat source frames:
  `assets/characters/factory_coil_rat/<animation>/`
- Route floor:
  `assets/environment/old_factory_route_floor/env_old_factory_route_floor_tile_256x96.png`

## Test Evidence

- Focused RED: `reports/report_1347/` failed before Story118 diagnostics and
  activation API existed.
- Focused GREEN: `reports/report_1348/` passed `2/2`.
- Related GREEN: `reports/report_1349/` passed `12/12` across Story118 and the
  adjacent service-sluice traverse, skirmish, reward cache, exit hatch, and
  tailrace suites.
- Headless smoke:
  `reports/old_factory_overflow_pump_runoff_outlet_service_sluice_tailrace_ambush_smoke.log`
  exited `0` and printed `service_sluice_tailrace_ambush_smoke=passed`.
- Godot MCP 2.9.1 / Godot 4.7 runtime validation opened
  `res://scenes/factory_route_transition_shell.tscn`, confirmed the Coil Rat
  node and `AnimatedSprite2D` SpriteFrames, activated entity `2143`, verified
  target/process/physics/frame-count/bounds contracts, captured a non-empty
  game screenshot with Cinderpaw and the Coil Rat visible, defeated the enemy,
  verified local-state persistence, and read clean current-run game/editor logs.
- Story228 handoff evidence: `reports/report_2376/report_1/results.xml` corrected
  the stale immediate-hide expectation and passed `2/2`; final related
  `reports/report_2377/report_1/results.xml` passed `7/7`. Godot AI MCP 3.0.4
  run `r184730101-26` crossed Story117 with real movement, then confirmed
  Story118 stayed available/inactive/hidden through no-input x `12624` and
  three stationary frames.
- Story229 production closure: initial characterization
  `reports/report_2378/report_1/results.xml` passed `1/1`; final five-suite
  related `reports/report_2379/report_1/results.xml` passed `7/7`. The updated
  `180`-frame smoke printed `story118_production_smoke=passed frames=180`.
  MCP 3.0.4 run `r187717447-28` used real `move_right` and `Input.attack`,
  recorded `cat_claw_light` damage `12`, retained the live death presentation,
  and exposed the visible, unactivated Story119 relay.

## Dependencies

- Depends on: Story117 tailrace crossing
- Unlocks: Story119 tailrace relay handoff

## Verification Summary

Story118 is complete through its production boundary. Story228 hardened its
entry guard; Story229 proves real movement activation, a real shared-hitbox
lethal attack, visible/processing death presentation with combat collision and
targeting disabled, and the unactivated Story119 relay handoff. Current related
GdUnit passed `7/7` under Godot 4.7 / Godot AI MCP 3.0.4.
