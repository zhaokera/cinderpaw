# QA Evidence: Old Factory Service Sluice Production Combat Reward Cache Handoff

**Story**: Player Abilities Story225

**Date**: 2026-07-22

**Status**: Accepted

**Engine / MCP**: Godot 4.7 / Godot AI MCP 3.0.4

## Scope

Verify real movement activation, entity `2142` physical combat and live death,
then stop at Story115 visible/claimable/unclaimed. Reward claiming and Story116
input are intentionally excluded.

## TDD Evidence

- `reports/report_2361/results.xml`: canonical RED, `1` test, zero errors and
  one expected z-order failure (`20` was not greater than `22`).
- `reports/report_2362/results.xml`: focused GREEN `1/1`, zero
  failure/error/flaky/skip/orphan.
- `reports/report_2363/results.xml`: five related suites, `7/7`, zero
  failure/error/flaky/skip/orphan.
- Full suite was intentionally not run.

The integrated test uses production `move_right`, production `attack`, the
player's real `cat_claw_light` Hitbox and the Spark Rat's real Hurtbox. Direct
damage is limited to the nonlethal `24 -> 12` setup.

## Smoke Evidence

`reports/old_factory_service_sluice_production_combat_reward_cache_handoff_smoke.log`
completed `180` fixed-FPS Factory frames, exited `0`, and ends with
`story225_smoke=passed frames=180`.

## MCP Runtime Evidence

Session `cinderpaw@198e`; final clean run `r177921577-21`.

- Editor and server reported Godot `4.7-stable` and MCP/plugin `3.0.4`.
- No-input Story114 remained available/inactive; real `move_right` crossed
  x `10920` and activated visible, targeted, processing/physical entity `2142`.
- All six Factory Spark Rat actions reported `3` frames.
- z order was duct/cache `22`, Spark Rat `24`, Cinderpaw `26`.
- Nonlethal setup produced `24 -> 12`; real `attack` produced metadata target
  `2142`, `light`, `cat_claw_light`, applied damage `12`, and cleared Story114.
- A clean supplemental probe captured the transient visible `death` state with
  process enabled, physics and target disabled before despawn.
- Story115 reported visible, available, claimable, unclaimed, exact cache id,
  position `(11360,410)`, prompt `+20 Gears`, and empty reward/feedback.
- Story116 remained unavailable, hidden and unopened.
- Final input state had `move_right/move_left/attack/interact=false`.
- Current-run game log contained only helper registration; editor log after
  cursor `2` was empty; playback stopped with readiness `ready`.

## Visual Evidence

Two non-empty MCP game framebuffer responses were RGB `1278x718`:

- Active combat: Cinderpaw and the frame-animated Spark Rat are both readable
  with objective `Clear Service Sluice Spark Rat`.
- Reward handoff: authored Factory cache art and `+20 Gears` are visible with
  objective `Service Sluice Spark Rat Cleared`.

No rectangle placeholder or single-frame substitute was introduced.

## Asset Review

Existing imported image-generated Factory, Cinderpaw, Spark Rat, service-sluice
and cache assets fully cover this slice. No new asset or image generation was
needed.

## QA Result

Accepted. Story114 is playable through real movement and combat, its enemy is
readable at z `24`, and Story115 is handed off without accidental claim or
Story116 activation.
