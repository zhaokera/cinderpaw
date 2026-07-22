# Story 221: Old Factory Runoff Exit Production Combat Reward Cache Handoff

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Combat and Reward Handoff
> **Type**: Integration + Production Movement + Production Combat + Live Death + Reward
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-22

## Context

Story220 crosses the overflow-pump runoff duct and leaves Story108 available
but inactive. Story221 closes the next playable ACT loop: real movement starts
the runoff-exit Coil Rat, a real light attack preserves its visible death,
stale interaction cannot consume the newly revealed Story109 cache, and a
later fresh interaction claims the reward while leaving the exit gate closed.

**GDD**: `design/gdd/input.md`, `design/gdd/feline-combat.md`,
`design/gdd/health-death.md`, `design/gdd/collision-detection.md`,
`design/gdd/scene-management.md`,
`design/gdd/exploration-ability-gating.md`

**Requirements**: `TR-input-001`, `TR-collision-004`, `TR-combat-001`,
`TR-scene-004`, `TR-explore-005`

**Governing ADRs**: ADR-0002 Signal Communication; ADR-0004 Collision
Detection; ADR-0005 Combat State Machine; ADR-0007 Scene Management. No
persistence schema or ability architecture changes are introduced.

## Acceptance Criteria

- [x] With Story107 crossed, restoring state, teleporting, stationary frames
  or no-input displacement to x `7804` cannot activate Story108.
- [x] Frame-start availability, held `move_right`, fresh positive x movement
  and crossing x `7800` activate entity `2140` through Factory production
  `_process(delta)` without calling Story108's direct activation API.
- [x] Activation restores the image-generated, frame-animated Coil Rat at
  `24 HP`, visible, targeted, processing/physical, normal hurtbox and a
  `10`-frame opening grace.
- [x] The Coil Rat renders at z `24`, above the runoff duct/cache z `22` and
  below Cinderpaw z `26`, keeping combat and death readable.
- [x] Direct damage is limited to deterministic nonlethal setup `24 -> 12`;
  real `Input.attack` and physical `cat_claw_light` overlap deliver the lethal
  `12 -> 0` hit to entity `2140` with complete hit metadata.
- [x] Defeat persists Story108 cleared and preserves visible/process
  three-frame `death`; physics, body collision, targeting, hurtbox and bite
  damage stop immediately.
- [x] Story109's cache becomes visible/available/claimable with prompt
  `+20 Gears`, while pre-clear held `interact` and no-input positioning into
  its `96px` range leave it unclaimed.
- [x] Releasing input rearms the trigger; fresh `Input.interact` uses the
  production nearest-cache router to claim exactly one `20`-gear reward.
- [x] Claim feedback is exactly `Runoff Exit Cache Claimed +20 Gears` and the
  exact cache id/source is persisted.
- [x] Claiming reveals `Open Runoff Exit Gate`; the gate is visible,
  available and collision-blocking but remains unopened in this slice.
- [x] Existing imported image-generated Cinderpaw, Factory Coil Rat, cache,
  gate and Factory environment remain in use; no placeholder or new image is
  introduced.
- [x] Thin RED/GREEN, five-suite bounded regression, Factory smoke and Godot
  4.7 / Godot AI MCP 3.0.4 runtime/log/two-screenshot acceptance pass.

## Out of Scope

Opening or visually retracting the Story109 gate, Story110 runoff-outlet
traversal, new art/audio/VFX, global wallet crediting beyond the established
reward payload, enemy/player balance, shared RatMinion timing, SaveSystem
schema, service lift, Boss2, Rat King Phase III and full-suite testing.

## Implementation Notes

- Story108 now owns a resettable previous-x snapshot and requires
  `move_right + current_x > previous_x + x >= 7800` for production activation.
- Story109's existing cache and claim API participate in the shared nearest
  progression-cache arbitration; rising-edge semantics remain centralized.
- The canonical test uses direct damage only for nonlethal setup. Its lethal
  transition uses production attack input and focused collision routing; MCP
  independently proves an engine-scheduled physical Area2D overlap.
- Fresh claim intentionally leaves the closed gate as the next player decision
  and the next bounded production-input slice.

## Asset Use

No image generation was required. The Story reuses registered/imported
image-generated Cinderpaw, Factory Coil Rat `AnimatedSprite2D + SpriteFrames`,
reward cache, closed gate and Old Factory environment assets.

## Verification Evidence

- Canonical RED `reports/report_2341/results.xml` failed `0/1` with exactly
  three expected gaps: no-input activation, Coil Rat z-order and missing
  Story109 production cache routing.
- Focused GREEN `reports/report_2342/results.xml` passed `1/1`.
- Final related `reports/report_2343/results.xml` passed five suites and `7/7`
  tests with zero failure, error, flaky, skip or orphan. It covers Story220,
  Story108, Story109, Story219 and Story221. No full suite was run.
- Factory `180`-frame smoke exited `0` with no matching project error or
  shutdown leak:
  `reports/old_factory_aftershock_condenser_overflow_pump_runoff_exit_production_combat_reward_handoff_smoke.log`.
- Godot MCP 3.0.4 session `cinderpaw@198e`, accepted run `r163369359-6`,
  rejected no-input x `7804`, then used actual `move_right` to advance x
  `7792 -> 7818.67` and activate entity `2140`.
- After deterministic nonlethal setup, actual MCP `Input.attack` and physical
  Area2D overlap delivered `cat_claw_light` damage `12`, target `2140` and HP
  `0`. The Coil Rat remained visible/process on `death` with physics, target,
  collision and hurtbox disabled.
- Held `interact` left the revealed cache unclaimed. After release and
  no-input range placement, fresh `interact` produced the exact `20`-gear
  reward/feedback and exposed a blocking, unopened gate. Final game log was
  helper-only, editor log after cursor `2` was empty, all inputs were released,
  and playback stopped at readiness `ready`.
- Non-empty RGB `1278x718` captures:
  - `reports/visual/cinderpaw-mcp-overflow-pump-runoff-exit-production-combat-reward-handoff-20260722.png`, SHA-256 `45acaf5545580089cd1e0fdc8cdf69fd9d844daa661bf29b2402c453c47dde15`.
  - `reports/visual/cinderpaw-mcp-overflow-pump-runoff-exit-production-combat-reward-handoff-claimed-20260722.png`, SHA-256 `a78c21eee60ba2cb941e87135a320481427fe19c8cdbef91c4e47801817a70f1`.

## Dependencies

- Depends on: Story220 production hatch/duct handoff; Story108 combat and
  Story109 reward-cache baselines.
- Unlocks: Story109 gate production input and Story110 runoff-outlet hazard
  traversal handoff.

## Verification Summary

One integrated RED isolated three production gaps. The minimal movement guard,
z-order correction and cache-router entry produced focused `1/1`, related
`7/7`, clean smoke and a clean MCP run covering real movement, real lethal
attack, live death, stale-input safety, fresh reward claim and the unopened
gate handoff without new assets.
