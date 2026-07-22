# Story 207: Old Factory Aftershock Exhaust Pursuer Production Combat Reward Handoff

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Combat and Reward Handoff
> **Type**: Integration + Gameplay Runtime + Production Combat + Production Input + Reward
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-21

## Context

Story206 finishes the timed exhaust traversal and leaves Story087 available.
This Story closes the next player-visible ACT loop: fresh forward movement
activates the Coil Rat pursuer, a real player attack defeats it, the live death
animation exposes Story088's reward cache, and real interaction claims the
once-only reward without prematurely starting Story089.

**GDD**: `design/gdd/player-abilities.md`,
`design/gdd/exploration-ability-gating.md`, `design/gdd/feline-combat.md`,
`design/gdd/collision-detection.md`, `design/gdd/scene-management.md`

**Requirements**: `TR-scene-004`, `TR-explore-005`, `TR-combat-001`,
`TR-respawn-002`

**Governing ADRs**: ADR-0002 Signal Communication; ADR-0004 Collision
Detection; ADR-0005 Combat State Machine; ADR-0006 Enemy AI; ADR-0007 Scene
Management. ADR-0018 and ADR-0021 remain no-change dependencies.

## Acceptance Criteria

- [x] Completing Story086 makes Story087 available but cannot activate it in
  the same `_process` frame, even when the player is already beyond x `2552`.
- [x] After availability is established, only fresh positive player movement
  across x `2552` activates entity `2131`; it becomes visible, processing,
  physical, targeted, `24 HP`, and hurtbox `normal` with HUD
  `Purge Aftershock Exhaust Pursuer`.
- [x] Entity `2131` uses `AnimatedSprite2D + SpriteFrames`; `idle`, `run`,
  `attack_tell`, `attack`, `hurt`, and `death` each provide three frames.
- [x] A real `Input.attack` through `cat_claw_light` can finish entity `2131`
  and records target `2131`, attack type `light`, and applied damage.
- [x] Live defeat keeps the Coil Rat visible/processing on its three-frame
  `death` animation while disabling physics, target and hurtbox. Story088's
  cache becomes visible and claimable with prompt `+20 Gears`.
- [x] Production `Input.interact` routes to the Story088 cache, grants one
  `20`-gear payload with the expected source and feedback, and duplicate input
  cannot claim it again.
- [x] After the claim, Story089 becomes available only. Entity `2132` remains
  hidden/inactive, `24 HP`, and hurtbox `gone` until its own x `2768` movement
  boundary is crossed.
- [x] Thin RED/GREEN, eight-suite bounded regression, Factory smoke, and Godot
  4.7 / Godot AI MCP 3.0.4 runtime/log/screenshot acceptance pass.

## Out Of Scope

Story089 production activation/combat, new enemy families, new visual/audio
assets, global wallet integration for Factory cache payloads, SaveSystem schema
changes, service-lift routing, room expansion and Rat King Phase III.

## Implementation Notes

- The Factory progression-cache router now includes Story088, so regular
  `interact` input can select the nearest available pursuer cache.
- Story087 activation snapshots availability at the start of `_process` and
  requires current player x to exceed the previous processed x. This prevents
  Story086 completion and Story087 activation from collapsing into one frame.
- Story089 synchronization maps its inactive Spark Rat hurtbox to `gone`,
  preventing the next encounter from stealing attacks during the reward beat.
- The canonical acceptance test uses direct damage only for deterministic
  nonlethal setup; the lethal hit and reward claim both use production input.

## Asset Use

No image generation was required. The Story reuses the registered
image-generated Cinderpaw, Factory Coil Rat, reward cache and Factory
environment. No PNG, SpriteFrames, source/import, manifest or entity inventory
file changed.

## Verification Evidence

- Canonical RED `reports/report_2245/results.xml` failed `0/1` because
  production `interact` could not claim Story088. Focused GREEN
  `reports/report_2246/results.xml` passed `1/1` after cache routing.
- The first bounded run `reports/report_2247/results.xml` exposed three stale
  Story089 assertions that expected immediate live-death hiding. Focused
  Story089 `reports/report_2248/results.xml` passed `3/3` after
  separating visible live death from hidden restored completion.
- A refined boundary RED `reports/report_2249/results.xml` failed only
  because Story086 completion could activate Story087 in the same process
  frame. Focused GREEN `reports/report_2250/results.xml` passed `1/1`.
- Final bounded related `reports/report_2251/results.xml` passed eight suites
  and `14/14` tests with zero failure, error, flaky, skip or orphan. No full
  suite was run.
- Godot 4.7 Factory `180`-frame headless smoke exited `0`; log:
  `reports/old_factory_aftershock_exhaust_pursuer_production_combat_reward_handoff_smoke.log`.
  It retained only the established `4 ObjectDB / 2 resources` shutdown
  baseline and no project script/parse/resource error.
- Godot MCP 3.0.4 accepted run `r135689461-59` used real `move_right`, real
  `attack`, and real `interact`. It verified entity `2131` activation and six
  three-frame animations, lethal hit metadata, visible noncombat death,
  once-only `+20 Gears`, and Story089 available/inactive safety.
- Non-empty RGB `1278x718` captures:
  `reports/visual/cinderpaw-mcp-old-factory-aftershock-exhaust-pursuer-production-combat-reward-handoff-death-20260721.png`
  and
  `reports/visual/cinderpaw-mcp-old-factory-aftershock-exhaust-pursuer-production-combat-reward-handoff-claimed-20260721.png`.
  The accepted game log contained only helper registration, editor log was
  empty, inputs/time scale were restored, and the editor returned to ready.
- Full evidence:
  `production/qa/evidence/old-factory-aftershock-exhaust-pursuer-production-combat-reward-handoff-2026-07-21.md`.

**Status**: [x] Complete.

## Dependencies

- Depends on: Stories 086, 087, 088 and 206.
- Unlocks: Story089 production movement, combat and deeper-route handoff.
