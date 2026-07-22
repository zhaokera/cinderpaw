# QA Evidence: Old Factory Runoff Outlet Production Combat Reward Cache Handoff

**Story**: Player Abilities Story223

**Date**: 2026-07-22

**Status**: Accepted

**Engine / MCP**: Godot 4.7 / Godot AI MCP 3.0.4

## Scope

Verify Story111 real-movement activation, physical light-attack death and
Story112's stale-input-safe reward handoff. Stop with the service hatch visible,
blocking and unopened while Story113 remains locked.

## TDD Evidence

- `reports/report_2351/results.xml`: canonical RED, `1` test with exactly two
  expected failures for Spark Rat z-order and missing Story112 interaction
  routing.
- `reports/report_2352/results.xml`: focused GREEN, `1/1`.
- `reports/report_2353/results.xml`: final six-suite related GREEN, `9/9`, zero
  failure/error/flaky/skip/orphan.
- Full suite was intentionally not run.

Direct damage is limited to deterministic `24 -> 12` nonlethal setup. The
lethal transition uses real `Input.attack`, `cat_claw_light`, Combat and
Collision routing. Reward consumption uses production `Input.interact`.

## Smoke Evidence

`reports/old_factory_runoff_outlet_production_combat_reward_cache_handoff_smoke.log`
completed `180` fixed-FPS Factory frames and exited `0`. Its targeted scan found
no parse/script, invalid-call/access, missing-resource, ObjectDB leak or
resource-in-use error.

## MCP Runtime Evidence

Accepted session: `cinderpaw@198e`; accepted run token/id:
`13` / `r167485675-13`.

- No-input x `9284` remained inactive. Actual `move_right` advanced x
  `9274.223 -> 9280`, activating entity `2141` at `24 HP`, visible/targeted and
  processing/physical with six three-frame animations.
- Effective ordering was duct/cache `22`, Spark Rat `24`, Cinderpaw `26`.
- After deterministic `24 -> 12` setup, actual `attack` delivered
  `attack_type=light`, `hitbox_id=cat_claw_light`, hit frame `6`, target `2141`
  and HP `0` through physical overlap.
- The live death state reported animation `death`, visible/process true,
  physics/target false, body layer/mask `0`, and hurtbox state `gone`.
- Held pre-clear `interact` left Story112 reward/feedback empty. After release,
  no-input placement at the cache reported in-range but still unclaimed.
- Fresh `interact` granted `20` gears with the exact cache id/source and
  feedback `Runoff Outlet Cache Claimed +20 Gears`.
- The service hatch finished present/visible/available/blocking and unopened
  with prompt `Open Runoff Outlet Service Hatch`. Story113 remained
  present but unavailable/inactive/uncrossed with its duct and hazard hidden.
- Final input state reported move-left/right, attack and interact all false.
  Current-run game log contained only helper registration; editor log after
  cursor `2` was empty; playback stopped at readiness `ready`.
- Runs `10` through `12` were discarded after temporary MCP eval probes used
  an untyped dynamic assignment, an incorrect player node path, and then read a
  corpse after its lifetime expired. The errors resolved only to generated
  `gdscript://` probes; accepted run `13` restarted clean and contains no
  project-code error.

## Visual Evidence

- Death/cache reveal, non-empty RGB `1280x720`:
  `reports/visual/cinderpaw-mcp-runoff-outlet-spark-death-cache-20260722.png`,
  SHA-256 `046cceb86f3222293a9ec7fe2ab5fcbbcd933ac4a8412950d45b71b017b06bf2`.
- Claimed/service hatch available, non-empty RGB `1280x720`:
  `reports/visual/cinderpaw-mcp-runoff-outlet-cache-claimed-service-hatch-20260722.png`,
  SHA-256 `4ebb3d29c69d1308bcb7de92cd3fb27d6b06013d9bb4b892f38de2e45b2c6279`.

Both captures show authored Factory art, frame-animated characters and the
expected objective/prompt text without player-visible rectangle placeholders.
The second intentionally stops before opening the service hatch.

## Asset Review

No image generation was needed. Existing registered/imported image-generated
Cinderpaw, Factory Spark Rat, cache, hatch and Factory environment assets cover
the slice; all six Spark Rat gameplay animations remain three-frame
`AnimatedSprite2D + SpriteFrames` clips.
