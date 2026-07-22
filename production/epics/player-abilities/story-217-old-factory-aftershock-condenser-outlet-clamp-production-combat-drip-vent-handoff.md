# Story 217: Old Factory Aftershock Condenser Outlet Clamp Production Combat Drip Vent Handoff

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Combat
> **Type**: Integration + Production Movement + Production Combat + Live Death + Route Handoff
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-22

## Context

Story216 reveals Story097 without consuming it. Story217 closes the next ACT
beat through production input: Cinderpaw crosses the clamp threshold, defeats
Spark Rat entity `2138` through the real light-attack collision path, sees its
authored death presentation, and hands control to Story098 without allowing the
killing frame's held movement to start the hazard.

**GDD**: `design/gdd/feline-combat.md`,
`design/gdd/exploration-ability-gating.md`, `design/gdd/scene-management.md`

**Requirements**: `TR-input-001`, `TR-collision-001`, `TR-collision-002`,
`TR-collision-003`, `TR-collision-004`, `TR-combat-001`, `TR-health-001`,
`TR-health-002`, `TR-scene-004`

**ADR Governing Implementation**: ADR-0002 Data-driven gameplay; ADR-0004
Collision detection; ADR-0005 Combat state machine; ADR-0006 Damage
calculation; ADR-0007 Scene management.

## Acceptance Criteria

- [x] A no-input x `5224.0` probe leaves Story097 available/visible but idle,
  with entity `2138` hidden, untargeted and without process/physics.
- [x] Real `move_right` with positive x movement across x `5220.0` activates
  Story097 once, enables entity `2138` at `24 HP`, assigns the player target,
  enables its hurtbox/process/physics and starts `18` opening-grace frames.
- [x] The lethal hit uses `Input.attack -> cat_claw_light -> entity 2138` and
  records target, attack type and applied `12` damage metadata.
- [x] Defeat persists Story097 clear state while the Spark Rat remains visible
  and processing in its 3-frame `death` animation; target, physics, body
  collision, hurtbox and bite hitbox are disabled immediately.
- [x] Story098 becomes available/visible with phase `idle` and contact disabled,
  but the killing frame cannot activate it even when `move_right` remains held
  and the player has crossed x `5840.0`.
- [x] A stationary follow-up frame remains idle. A later fresh positive-x
  `move_right` frame starts Story098 in `grace` without changing its authored
  timings or hazard values.
- [x] Canonical GdUnit RED/GREEN, bounded Story216/097/098 regression, 180-frame
  Factory smoke and Godot MCP runtime/visual acceptance pass under Godot 4.7 /
  Godot AI MCP 3.0.4.

## Out of Scope

Completing Story098, Story099 combat, enemy/player balance changes, new moves,
new visual/audio assets, attack-tell art timing, z-order redesign, SaveSystem
schema changes and full-suite testing.

## Asset Pipeline

No image generation was needed. The Story reuses the registered image-generated
Factory environment, clamp, drain gantry and Factory Spark Rat
`AnimatedSprite2D + SpriteFrames` assets.

## Test Evidence

- Canonical GdUnit:
  `tests/unit/gameplay/old_factory_aftershock_condenser_outlet_clamp_production_combat_drip_vent_handoff_test.gd`
  - Strengthened RED: `reports/report_2317/results.xml` (`1` case, `1` expected
    failure proving held movement on the killing frame chained Story098).
  - Focused GREEN: `reports/report_2318/results.xml` (`1/1`).
- Related regression: `reports/report_2319/results.xml` passed `6/6` across
  Story216, Story097, Story098 and Story217 with zero
  failure/error/flaky/skip/orphan.
- Factory smoke:
  `reports/old_factory_aftershock_condenser_outlet_clamp_production_combat_drip_vent_handoff_smoke.log`
  completed `180` fixed-FPS frames and exited `0` without project
  parse/script, invalid-call/access or missing-resource errors.
- Godot MCP 3.0.4 / Godot 4.7 session `cinderpaw@1b14`:
  - Accepted input/combat run `r155047659-13` proved no-input isolation, real
    x `5208.0 -> 5220.2222` activation, entity `2138` live state, real
    `cat_claw_light` lethal metadata, live death, held-input killing-frame and
    stationary-frame isolation, then fresh x `5848.0 -> 5852.0` activation of
    Story098 in `grace`.
  - Visual run `r155315013-14` captured the natural death animation at frame 2
    with Cinderpaw, the fallen Spark Rat, drain gantry and idle vent visible.
  - Both accepted runs had helper-only game logs, empty editor logs, released
    inputs and stopped with editor readiness `ready`.
- Visual evidence: non-empty RGB `1278x718` PNG at
  `reports/visual/cinderpaw-mcp-aftershock-condenser-outlet-clamp-death-handoff-20260722.png`,
  SHA-256 `bf2dad7de8b612b74b1a5e91d3d351cb864310f2f8f7373a55fd789d10613530`.

## Dependencies

- Depends on: Story216 production outlet handoff; Story097/098 baseline;
  Story037 Rat Minion death readability.
- Unlocks: Story098 production hazard traversal and Story099 handoff.

## Verification Summary

The strengthened RED isolated a real same-frame chaining bug. A one-frame
handoff barrier plus fresh movement snapshot made the canonical `1/1` and the
bounded related set `6/6`. Headless smoke exited `0`; MCP then proved the full
movement, combat, live-death and later-movement handoff with clean logs and a
valid gameplay screenshot. No new asset or full suite was required.
