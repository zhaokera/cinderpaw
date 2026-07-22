# Story 218: Old Factory Aftershock Condenser Outlet Drip Vent Production Hazard Traverse Overflow Pump Handoff

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Contact Hazard
> **Type**: Integration + Production Movement + Hazard Timing + Route Handoff
> **Estimate**: XS
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-22

## Context

Story217 reveals Story098 without consuming it. Story218 closes the next ACT
traversal beat through production movement and collision: Cinderpaw enters the
outlet drip vent, takes one real active-window steam hit, crosses the far edge,
and reaches Story099 without stale movement or coordinate correction starting
the combat automatically.

**GDD**: `design/gdd/input.md`, `design/gdd/collision-detection.md`,
`design/gdd/exploration-ability-gating.md`, `design/gdd/scene-management.md`

**Requirements**: `TR-input-001`, `TR-collision-004`, `TR-scene-004`,
`TR-explore-005`

**ADR Governing Implementation**: ADR-0004 Collision detection; ADR-0006
Damage calculation; ADR-0007 Scene management.

## Acceptance Criteria

- [x] A no-input x `5844.0` probe leaves Story098 available and visible but
  idle, with hazard contact disabled.
- [x] Real `move_right` and positive x movement across x `5840.0` activates
  Story098 once in `grace` without changing its public Story API.
- [x] Production `_process(delta)` preserves the authored
  `0.25 / 0.35 / 0.40 / 0.45s` grace, warning, active and safe phases.
- [x] Real movement places Cinderpaw inside the drip-vent `Area2D`; enabling
  the active phase and waiting physics frames triggers the connected overlap
  callback, changes HP `100 -> 92`, and records the Story098 hazard id. Safe
  phase physics frames do not apply another hit.
- [x] Real movement across x `6260.0` persists Story098 activated/crossed,
  disables contact, shows the overflow pump and advances feedback to
  `Outlet Drip Vent Crossed`.
- [x] The crossing frame and stationary/no-input probes beyond Story099 x
  `6540.0` keep entity `2139` hidden, untargeted and without process/physics,
  while the overflow pump remains visible.
- [x] A later fresh positive-x `move_right` frame activates Story099, shows
  entity `2139`, assigns the player target, enables process/physics, starts
  `10` opening-grace frames and updates feedback to
  `Clear Overflow Pump Skirmish`.
- [x] The activated Coil Rat renders at z `24`, in front of the overlapping
  overflow pump at z `22` and behind the player at z `26`.
- [x] Canonical GdUnit RED/GREEN, bounded Story217/098/099 regression,
  180-frame Factory smoke and Godot MCP runtime/visual acceptance pass under
  Godot 4.7 / Godot AI MCP 3.0.4.

## Out of Scope

Story099 combat/kill, Story106 reward handoff, enemy or player balance, new
moves, new visual assets, SaveSystem schema changes and full-suite testing.

## Implementation Notes

- Story099 production auto-activation now consumes frame-start availability,
  held `move_right` and a fresh positive-x movement snapshot.
- Story098 completion seeds a one-frame Story099 handoff barrier so a state
  transition cannot consume stale input in the same process frame.
- Story099's direct activation API remains unchanged for existing callers.
- Headless music and ambience requests retain logical success/metadata but do
  not start Dummy-driver playback, preventing Godot 4.7 shutdown leaks while
  leaving editor and runtime builds unchanged.

## Asset Pipeline

No image generation was needed. The Story reuses the registered
image-generated Factory environment, drain gantry, overflow pump, Cinderpaw,
steam-vent `SpriteFrames` and Factory Coil Rat
`AnimatedSprite2D + SpriteFrames` assets.

## Test Evidence

- Canonical GdUnit:
  `tests/unit/gameplay/old_factory_aftershock_condenser_outlet_drip_vent_production_hazard_traverse_overflow_pump_handoff_test.gd`
  - Behavior RED: `reports/report_2320/report_1/results.xml` (`1` expected
    failure proving no-input displacement started Story099).
  - Visual-layer RED: `reports/report_2324/report_1/results.xml` (`1` expected
    failure proving Coil Rat z `20` was behind pump z `22`).
  - Final focused GREEN with real `Area2D` overlap:
    `reports/report_2327/report_1/results.xml` (`1/1`).
- Final related regression: `reports/report_2329/report_1/results.xml` passed
  `6/6` across Story217, Story098, Story099 and Story218 with zero
  failure/error/flaky/skip/orphan.
- Audio regression: `reports/report_2328/report_1/results.xml` passed `24/24`.
- Factory smoke:
  `reports/old_factory_aftershock_condenser_outlet_drip_vent_production_hazard_traverse_overflow_pump_handoff_smoke.log`
  completed `180` fixed-FPS frames and exited `0` without project errors or
  shutdown resource leaks.
- Godot MCP 3.0.4 / Godot 4.7 session `cinderpaw@1b14`, run
  `r156727664-15`:
  - no-input x `6536 -> 6544` kept Story099 available but inactive;
  - MCP `move_right` plus fresh x movement activated entity `2139` with target,
    process/physics, `idle` `3` frames and the expected route objective;
  - diagnostics confirmed pump z `22` and Coil Rat z `24`;
  - game log was helper-only, editor log empty, inputs released and project
    stopped at editor readiness `ready`.
- Visual evidence: non-empty RGB `1278x718` PNG at
  `reports/visual/cinderpaw-mcp-aftershock-condenser-drip-vent-overflow-pump-handoff-20260722.png`,
  SHA-256 `d35824772c2d1c016f7b0421624016a7104b2ca87033a3cb09a80482c86b5ff8`.

## Dependencies

- Depends on: Story217 production clamp combat handoff; Story098/099 baseline.
- Unlocks: Story099 production combat and Story106 reward-cache handoff.

## Verification Summary

Two thin REDs isolated the stale/no-input activation and z-order defects. The
production gate, one-frame handoff barrier and Coil Rat z correction made the
final canonical `1/1` and related set `6/6`. The canonical test additionally
proved real movement and `Area2D` steam damage. Audio regression, clean
180-frame smoke and MCP runtime/visual acceptance passed without generating new
assets or running the full suite.
