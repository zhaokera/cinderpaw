# QA Evidence: Old Factory Runoff Exit Production Combat Reward Cache Handoff

**Story**: Player Abilities Story221

**Date**: 2026-07-22

**Status**: Accepted

**Engine / MCP**: Godot 4.7 / Godot AI MCP 3.0.4

## Scope

Verify Story108 production movement, combat and live death, then Story109's
stale-input-safe cache reveal and fresh reward claim. Stop with the runoff exit
gate available, blocking and unopened.

## TDD Evidence

- `reports/report_2341/results.xml`: canonical RED, `0/1`, exactly three
  expected failures for no-input activation, Coil Rat z-order and fresh cache
  interaction routing.
- `reports/report_2342/results.xml`: focused GREEN, `1/1`.
- `reports/report_2343/results.xml`: final five-suite related GREEN, `7/7`,
  zero failure/error/flaky/skip/orphan.
- Full suite was intentionally not run.

Direct damage is limited to deterministic `24 -> 12` nonlethal setup. The
lethal transition uses real `Input.attack`, `cat_claw_light`, Combat and
Collision routing; MCP separately proves engine-scheduled physical overlap.

## Smoke Evidence

`reports/old_factory_aftershock_condenser_overflow_pump_runoff_exit_production_combat_reward_handoff_smoke.log`
completed `180` fixed-FPS Factory frames and exited `0`. Its targeted scan found
no parse/script, invalid-call/access, missing-resource, ObjectDB leak or
resource-in-use error.

## MCP Runtime Evidence

Accepted session/run: `cinderpaw@198e` / `r163369359-6`.

- Scene was reloaded from disk under Godot `4.7-stable`, plugin/server `3.0.4`.
- No-input x `7804` remained available/inactive. Actual `move_right` advanced x
  `7792 -> 7818.67`, activating entity `2140` at `24 HP` with visible/targeted,
  processing/physical state, six three-frame animations and `10` opening-grace
  frames.
- After `24 -> 12` setup, actual MCP attack and physical Area2D overlap
  produced target `2140`, `attack_type=light`, `hitbox_id=cat_claw_light`,
  `damage_applied=12` and HP `0`.
- The death frame remained visible/process with animation `death`; physics,
  target, body layer/mask and hurtbox were disabled. The cache became visible,
  claimable and `+20 Gears` while held `interact` left reward/feedback empty.
- After release and no-input placement inside the `96px` reward range, the
  cache remained unclaimed. Fresh `interact` produced exact id/source,
  `gears=20`, feedback `Runoff Exit Cache Claimed +20 Gears`, and a visible,
  available, blocking gate with `opened=false` and prompt
  `Open Runoff Exit Gate`.
- Final input state reported move-left/right, attack and interact all false.
  Current-run game log contained only helper registration; editor log after
  cursor `2` was empty; playback stopped at editor readiness `ready`.
- Preliminary diagnostic runs were discarded after generated MCP eval probes
  called a nonexistent helper and later inspected an expired corpse. Both
  errors resolved only to temporary `gdscript://` eval code; the accepted run
  was restarted clean and contains no project-code error.

## Visual Evidence

- Death/cache reveal, non-empty RGB `1278x718`:
  `reports/visual/cinderpaw-mcp-overflow-pump-runoff-exit-production-combat-reward-handoff-20260722.png`,
  SHA-256 `45acaf5545580089cd1e0fdc8cdf69fd9d844daa661bf29b2402c453c47dde15`.
- Claimed/gate available, non-empty RGB `1278x718`:
  `reports/visual/cinderpaw-mcp-overflow-pump-runoff-exit-production-combat-reward-handoff-claimed-20260722.png`,
  SHA-256 `a78c21eee60ba2cb941e87135a320481427fe19c8cdbef91c4e47801817a70f1`.

Both captures show authored Factory art and the existing frame-animated
Cinderpaw/Coil Rat rather than rectangle placeholders. The second capture
intentionally shows the closed gate; opening readability belongs to the next
Story109 production-input slice.

## Asset Review

No image generation was needed. Existing registered/imported image-generated
Cinderpaw, Factory Coil Rat, cache, closed gate and Factory environment assets
cover this slice. Final effective ordering is floor `11`, cache/duct `22`, Coil
Rat `24`, Cinderpaw `26`.
