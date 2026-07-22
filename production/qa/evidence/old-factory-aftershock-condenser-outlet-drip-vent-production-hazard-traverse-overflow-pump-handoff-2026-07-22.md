# QA Evidence: Old Factory Aftershock Condenser Outlet Drip Vent Production Hazard Traverse Overflow Pump Handoff

**Story**: Player Abilities Story218

**Date**: 2026-07-22

**Status**: Accepted

**Engine / MCP**: Godot 4.7 / Godot AI MCP 3.0.4

## Scope

Verify Story098 production movement, hazard timing and real physics overlap;
isolate Story099 from crossing-frame/stationary activation; and verify that a
later fresh movement activates a visually unobscured Coil Rat. Story099 combat
and reward progression remain out of scope.

## TDD Evidence

- `reports/report_2320/report_1/results.xml`: canonical behavior RED, `1`
  expected failure at the no-input Story099 activation assertion.
- `reports/report_2324/report_1/results.xml`: visual-layer RED, `1` expected
  failure because Coil Rat z `20` was behind pump z `22`.
- `reports/report_2327/report_1/results.xml`: final focused GREEN, `1/1`, using
  real movement into the vent and physics-triggered `Area2D` damage.
- `reports/report_2329/report_1/results.xml`: bounded related GREEN, `6/6`
  across Story217, Story098, Story099 and Story218; zero
  failure/error/flaky/skip/orphan.
- `reports/report_2328/report_1/results.xml`: AudioSystem regression `24/24`.
- Full suite was intentionally not run.

## Smoke Evidence

`reports/old_factory_aftershock_condenser_outlet_drip_vent_production_hazard_traverse_overflow_pump_handoff_smoke.log`
completed `180` fixed-FPS frames and exited `0` with no parse/script,
invalid-call/access, missing-resource, ObjectDB leak or resource-in-use error.

The initial smoke reproduced Godot 4.7 Dummy-driver music/ambient playback
leaks. Headless requests now preserve logical cue success but skip physical
playback; editor and runtime builds still play normally. The final smoke is
clean.

## MCP Runtime Evidence

Accepted run: `cinderpaw@1b14` / `r156727664-15`.

- Runtime state restored Story098 crossed and Story099 available. With input
  released, x `6536 -> 6544` left Story099 inactive, pump visible, Coil Rat
  hidden/untargeted and route feedback `Outlet Drip Vent Crossed`.
- MCP `input_action(move_right)` plus fresh positive movement activated
  Story099. Diagnostics reported entity `2139`, visible Coil Rat, player target,
  process/physics enabled, `idle` animation with `3` frames and route feedback
  `Clear Overflow Pump Skirmish`.
- Runtime z diagnostics reported overflow pump `22` and Coil Rat `24`.
- Game log contained only helper registration; editor log was empty. Input was
  released and the project stopped at editor readiness `ready`.

## Visual Evidence

Non-empty RGB PNG, `1278x718`, SHA-256
`d35824772c2d1c016f7b0421624016a7104b2ca87033a3cb09a80482c86b5ff8`:

`reports/visual/cinderpaw-mcp-aftershock-condenser-drip-vent-overflow-pump-handoff-20260722.png`

The gameplay framebuffer shows the authored Factory pocket, Cinderpaw,
overflow-pump region, activated Coil Rat in front of environment machinery and
`Clear Overflow Pump Skirmish` feedback.

## Asset Review

No image generation was needed. Existing generated/imported assets satisfy the
slice. Read-only art review identified the Coil Rat/pump z conflict; setting the
enemy to z `24` resolves the structural occlusion while retaining hazard/VFX
and player foreground ownership.
