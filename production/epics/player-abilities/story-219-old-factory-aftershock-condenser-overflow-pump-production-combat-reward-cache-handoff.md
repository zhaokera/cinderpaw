# Story 219: Old Factory Aftershock Condenser Overflow Pump Production Combat Reward Cache Handoff

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Combat and Reward Handoff
> **Type**: Integration + Production Combat + Production Input + Live Death + Reward
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-22

## Context

Story218 reaches and activates Story099 through production movement. Story219
closes the next playable ACT loop: Cinderpaw defeats entity `2139` with a real
light attack, the live Coil Rat death reveals Story106's cache without
consuming stale input, and a later fresh interaction claims the reward while
leaving the runoff hatch unopened.

**GDD**: `design/gdd/input.md`, `design/gdd/feline-combat.md`,
`design/gdd/health-death.md`, `design/gdd/collision-detection.md`,
`design/gdd/scene-management.md`,
`design/gdd/exploration-ability-gating.md`

**Requirements**: `TR-input-001`, `TR-collision-004`, `TR-combat-001`,
`TR-scene-004`, `TR-explore-005`, `TR-respawn-002`

**Governing ADRs**: ADR-0002 Signal Communication; ADR-0004 Collision
Detection; ADR-0005 Combat State Machine; ADR-0007 Scene Management. ADR-0006,
ADR-0018 and ADR-0021 are no-change dependencies.

## Acceptance Criteria

- [x] Real `move_right` and positive x movement across x `6540` activate
  entity `2139` without calling Story099's direct activation API.
- [x] Activation restores the frame-animated Coil Rat at `24 HP`, visible,
  targeted, processing/physical, normal hurtbox and `10` opening-grace frames.
- [x] The deterministic nonlethal setup may reduce HP `24 -> 12`; the lethal
  hit must use real `Input.attack` through `cat_claw_light`, records target
  `2139`, attack type `light`, applied damage `12`, and reaches HP `0`.
- [x] Defeat persists Story099 cleared while preserving visible/process
  three-frame `death`; physics, body collision, target, hurtbox and bite damage
  are disabled immediately.
- [x] Story106's cache becomes visible/available/claimable with prompt
  `+20 Gears`, but the lethal frame, a pre-clear held `interact`, and a later
  no-input displacement into its `96px` range leave it unclaimed.
- [x] After input release rearms the trigger, fresh `Input.interact` uses the
  production nearest-cache router to claim the cache exactly once.
- [x] Claim persistence and feedback contain the exact cache id, source,
  `gears=20`, and `Overflow Pump Cache Claimed +20 Gears`.
- [x] Claiming reveals an available, collision-blocking runoff hatch with
  prompt `Open Runoff Hatch`; the hatch remains unopened and Story107 does not
  start in this slice.
- [x] Existing image-generated Cinderpaw, Factory Coil Rat, overflow pump,
  cache, hatch and Factory environment remain in use; no placeholder or new
  asset is introduced.
- [x] Thin RED/GREEN, five-suite bounded regression, Factory smoke and Godot
  4.7 / Godot AI MCP 3.0.4 runtime/log/two-screenshot acceptance pass.

## Out of Scope

Opening the runoff hatch, Story107 traversal, new art/audio/VFX, global wallet
crediting beyond the established reward payload, enemy/player balance, shared
RatMinion timing, SaveSystem schema, service lift, Boss2, Rat King Phase III
and full-suite testing.

## Implementation Notes

- Story106's existing cache and claim API are now included in
  `_try_claim_nearest_factory_progression_reward_cache()`, preserving the
  shared nearest-distance and rising-edge interaction contracts.
- Story099 activation, combat, death and Story106 state APIs remain unchanged.
- The canonical test follows the established Story204/207 pattern: direct
  damage is limited to deterministic nonlethal setup; the lethal transition
  uses production attack input and collision routing.
- MCP independently proved an engine-scheduled real attack hit and fresh
  interaction without manual collision injection.

## Asset Use

No image generation was required. The Story reuses registered/imported
image-generated assets for Cinderpaw, Factory Coil Rat
`AnimatedSprite2D + SpriteFrames`, the overflow pump, reward cache, runoff
hatch and Factory environment.

## Verification Evidence

- Baseline discovery `reports/report_2330/results.xml` passed `1/1`, proving
  production combat, live death and non-consuming cache reveal already worked.
- Refined canonical RED `reports/report_2331/results.xml` failed `0/1` only
  because fresh production `Input.interact` could not route to Story106.
- Focused GREEN `reports/report_2332/results.xml` passed `1/1` after adding the
  existing cache to shared progression-cache arbitration.
- Final related `reports/report_2334/results.xml` passed five suites and `7/7`
  tests with zero failure, error, flaky, skip or orphan. It covers Story218,
  Story099, Story106, Story219 and shared reward-cache production input. No
  full suite was run.
- Factory `180`-frame smoke exited `0` with no project error or shutdown leak:
  `reports/old_factory_aftershock_condenser_overflow_pump_production_combat_reward_cache_handoff_smoke.log`.
- Godot MCP 3.0.4 session `cinderpaw@1b14`, run `r158132331-16`, used actual
  `move_right` to advance x `6532.67 -> 6601.34` and activate entity `2139`.
  After deterministic nonlethal setup, actual `Input.attack` delivered the
  `cat_claw_light` lethal `12 -> 0` hit with complete hit metadata. The Coil
  Rat remained visible/process on `death`, and the cache appeared unclaimed.
- With all input released, moving to the cache left it unclaimed. Fresh MCP
  `interact` then persisted one `20`-gear reward and revealed the available,
  blocking, unopened runoff hatch. Game log was helper-only, editor log empty,
  inputs were released and the project stopped at editor readiness `ready`.
- Non-empty RGB `1278x718` captures:
  - `reports/visual/cinderpaw-mcp-overflow-pump-production-combat-reward-cache-handoff-20260722.png`, SHA-256 `c566cdacfe14d6e799b2cfc3dde494fb9508315fa3dc8d88c281ea0fd85105b5`.
  - `reports/visual/cinderpaw-mcp-overflow-pump-production-combat-reward-cache-handoff-claimed-20260722.png`, SHA-256 `a06913aa5935d88625dd4a5a350b8a0ea271b012cb6c30ffbf16e6c9a010f4e1`.

## Dependencies

- Depends on: Story218 production hazard/combat handoff; Story099 combat and
  Story106 reward-cache baselines.
- Unlocks: Story106 runoff-hatch production input and Story107 production
  hazard traversal handoff.

## Verification Summary

The refined RED isolated the missing production interaction route. One bounded
router entry produced focused GREEN and final related `7/7`. Headless smoke and
MCP real movement, real lethal attack, non-consuming reward reveal, fresh
interaction, logs and two visual states all passed without new assets.
