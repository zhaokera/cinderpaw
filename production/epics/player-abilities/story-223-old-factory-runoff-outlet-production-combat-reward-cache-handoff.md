# Story 223: Old Factory Runoff Outlet Production Combat Reward Cache Handoff

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Production Combat + Reward Handoff
> **Type**: Integration + Production Movement + Production Combat + Live Death + Reward
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-22

## Context

Story222 leaves Story111 available but inactive after the live runoff-outlet
hazard is crossed. Story223 closes the next playable ACT loop: real movement
wakes entity `2141`, a real Cinderpaw light attack finishes the Spark Rat,
the live death presentation reveals Story112 without consuming held input,
and a later fresh interaction claims the cache before handing control to the
closed service hatch.

**GDD**: `design/gdd/input.md`, `design/gdd/collision-detection.md`,
`design/gdd/feline-combat.md`, `design/gdd/scene-management.md`,
`design/gdd/exploration-ability-gating.md`

**Requirements**: `TR-input-001`, `TR-collision-004`, `TR-combat-001`,
`TR-scene-004`, `TR-explore-005`

**Governing ADRs**: ADR-0002 Event Bus; ADR-0004 Collision Detection;
ADR-0005 Combat State Machine; ADR-0007 Scene Management.

## Acceptance Criteria

- [x] Story111 remains inactive after no-input placement beyond x `9280` and
  requires a later real positive-x `move_right` frame to activate.
- [x] Activation reveals and targets Factory Spark Rat entity `2141` at
  `24 HP`, with process/physics enabled and the existing `12`-frame opening
  grace.
- [x] The Spark Rat renders at z `24`, in front of the outlet duct/cache z
  `22` and behind Cinderpaw z `26`.
- [x] Its `AnimatedSprite2D + SpriteFrames` contract retains `idle`, `run`,
  `attack_tell`, `attack`, `hurt`, and `death` at three frames each.
- [x] Direct damage is limited to deterministic nonlethal setup `24 -> 12`;
  the lethal transition uses real `Input.attack`, `cat_claw_light`, entity
  `2141` collision routing and HP `12 -> 0`.
- [x] Live death remains visible and processing in `death` while target,
  physics, body collision and hurtbox participation stop.
- [x] Story112 becomes visible/claimable with prompt `+20 Gears`, while a held
  pre-clear `interact` and no-input displacement into its `96px` range both
  leave it unclaimed.
- [x] A fresh production `interact` grants exactly `20` gears with the Story112
  cache id as source and emits `Runoff Outlet Cache Claimed +20 Gears`.
- [x] The final service hatch is present, visible, available, blocking and
  unopened with prompt `Open Runoff Outlet Service Hatch`.
- [x] Story113's service sluice remains present but unavailable, inactive,
  uncrossed and hidden until the service hatch is opened by a later slice.
- [x] Focused/related GdUnit, `180`-frame Factory smoke, and Godot 4.7 /
  Godot AI MCP 3.0.4 runtime/log/two-screenshot acceptance pass.

## Out of Scope

Opening the Story112 service hatch, activating Story113's service-sluice
hazard, new art/audio/VFX, enemy/player balance, SaveSystem schema changes,
Boss2, Rat King Phase III and full-suite testing.

## Implementation Notes

- Story112's runoff-outlet cache now participates in the shared nearest
  production reward-cache interaction route. Existing rising-edge arbitration
  remains the single stale/fresh input authority.
- The Story111 Spark Rat z-order is raised from `20` to `24`; no gameplay,
  collision or persistence contract changes were required.
- The integrated acceptance test establishes boundaries directly but drives
  encounter activation, lethal combat and cache claim through production
  input paths.

## Asset Use

No image generation was required. Existing imported image-generated Cinderpaw,
Factory Spark Rat, cache, service hatch and Factory environment assets cover
the slice. The Spark Rat's six existing transparent frame-animation folders
remain bound through `AnimatedSprite2D + SpriteFrames`.

## Verification Evidence

- Canonical RED `reports/report_2351/results.xml` ran `1` test and exposed
  exactly two expected failures: Spark Rat z-order and missing fresh Story112
  cache interaction routing.
- Focused GREEN `reports/report_2352/results.xml` passed `1/1` with zero
  failure/error/flaky/skip/orphan.
- Final six-suite related GREEN `reports/report_2353/results.xml` passed `9/9`
  with zero failure/error/flaky/skip/orphan. It covers Story223, Story222,
  analogous Story221, Stories111/112 and shared progression interaction.
- Factory `180`-frame smoke exited `0` with no targeted project error:
  `reports/old_factory_runoff_outlet_production_combat_reward_cache_handoff_smoke.log`.
- Godot MCP 3.0.4 session `cinderpaw@198e`, accepted run token/id `13` /
  `r167485675-13`, proved no-input rejection, real movement activation, real
  attack death, stale/no-input reward protection, fresh exact reward claim and
  the locked Story113 boundary.
- All four driven actions were released. The game log contained only helper
  registration, editor delta after cursor `2` was empty, and playback stopped
  at readiness `ready`.
- Non-empty RGB `1280x720` captures:
  - `reports/visual/cinderpaw-mcp-runoff-outlet-spark-death-cache-20260722.png`,
    SHA-256 `046cceb86f3222293a9ec7fe2ab5fcbbcd933ac4a8412950d45b71b017b06bf2`.
  - `reports/visual/cinderpaw-mcp-runoff-outlet-cache-claimed-service-hatch-20260722.png`,
    SHA-256 `4ebb3d29c69d1308bcb7de92cd3fb27d6b06013d9bb4b892f38de2e45b2c6279`.

## Dependencies

- Depends on: Story222 production gate/outlet handoff and Stories111/112
  baseline content.
- Unlocks: Story112 production service-hatch input/readability and Story113
  service-sluice hazard traversal.

## Verification Summary

One integrated thin-TDD test and one clean MCP run close real movement, real
combat, live death, exact reward and unopened-hatch handoff. Focused `1/1`,
related `9/9`, smoke and runtime/log/visual acceptance pass without new assets
or persistence-schema changes.
