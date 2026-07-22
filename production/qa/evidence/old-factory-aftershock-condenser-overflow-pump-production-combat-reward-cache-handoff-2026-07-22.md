# QA Evidence: Old Factory Aftershock Condenser Overflow Pump Production Combat Reward Cache Handoff

**Story**: Player Abilities Story219

**Date**: 2026-07-22

**Status**: Accepted

**Engine / MCP**: Godot 4.7 / Godot AI MCP 3.0.4

## Scope

Verify Story099 production activation/combat/live death, Story106's
non-consuming cache reveal and fresh production interaction, then stop with the
runoff hatch available but unopened.

## TDD Evidence

- `reports/report_2330/results.xml`: discovery baseline, `1/1`; combat, live
  death and unclaimed cache reveal already worked.
- `reports/report_2331/results.xml`: refined canonical RED, `0/1`; the only
  failure was fresh `Input.interact` not reaching Story106's cache.
- `reports/report_2332/results.xml`: focused GREEN, `1/1`.
- `reports/report_2334/results.xml`: final five-suite related GREEN, `7/7`,
  zero failure/error/flaky/skip/orphan.
- Full suite was intentionally not run.

The test permits direct `24 -> 12` nonlethal setup, matching Stories204/207.
The lethal transition uses `Input.attack`, `cat_claw_light`, Combat and
Collision routing. MCP separately proves the engine-scheduled physical hit.

## Smoke Evidence

`reports/old_factory_aftershock_condenser_overflow_pump_production_combat_reward_cache_handoff_smoke.log`
completed `180` fixed-FPS Factory frames and exited `0`. It contains no
parse/script, invalid-call/access, missing-resource, ObjectDB leak or
resource-in-use error.

## MCP Runtime Evidence

Accepted session/run: `cinderpaw@1b14` / `r158132331-16`.

- Scene reloaded from disk with plugin/server `3.0.4` and Godot `4.7-stable`.
- Actual MCP `move_right` advanced player x `6532.67 -> 6601.34`; entity `2139`
  became visible, targeted, processing/physical, and reported six three-frame
  animations plus the `10`-frame opening grace contract.
- After deterministic HP `24 -> 12` setup and stable collision framing, actual
  MCP `attack` produced `target_id=2139`, `attack_type=light`,
  `hitbox_id=cat_claw_light`, `damage_applied=12`, HP `0`, visible/process
  `death`, disabled physics/target, and `Overflow Pump Cleared`.
- The unlocked cache reported visible/available/claimable, `+20 Gears`, and
  `claimed=false`. With input released, no-input positioning into reward range
  kept it unclaimed.
- Fresh MCP `interact` produced the exact once-only cache id/source,
  `gears=20`, feedback `Overflow Pump Cache Claimed +20 Gears`, and an
  available/visible/collision-blocking runoff hatch with `opened=false` and
  prompt `Open Runoff Hatch`.
- Current game log contained only helper registration; editor log was empty.
  All inputs were released and playback stopped at editor readiness `ready`.

## Visual Evidence

- Death/cache reveal: non-empty RGB `1278x718`
  `reports/visual/cinderpaw-mcp-overflow-pump-production-combat-reward-cache-handoff-20260722.png`,
  SHA-256 `c566cdacfe14d6e799b2cfc3dde494fb9508315fa3dc8d88c281ea0fd85105b5`.
- Claimed/hatch available: non-empty RGB `1278x718`
  `reports/visual/cinderpaw-mcp-overflow-pump-production-combat-reward-cache-handoff-claimed-20260722.png`,
  SHA-256 `a06913aa5935d88625dd4a5a350b8a0ea271b012cb6c30ffbf16e6c9a010f4e1`.

Both frames show the authored image-generated Factory environment and props,
the frame-animated Cinderpaw/Coil Rat combat handoff, readable reward feedback
and no player-visible rectangle placeholder.

## Asset Review

No image generation was needed. Existing generated/imported Cinderpaw, Factory
Coil Rat, overflow pump, cache, hatch and Factory environment assets cover the
slice. A distinct visually open hatch state remains a scoped readability item
for the next Story106 hatch-open/Story107 handoff, not for this unopened state.
