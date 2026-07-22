# Story 186: Old Factory Deep Bulkhead Guard Production Movement Handoff

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Production Movement
> **Type**: Integration + Production Movement + Frame Animation + Visual Readability
> **Estimate**: S
> **Manifest Version**: 2026-07-20
> **Last Updated**: 2026-07-20

## Context

Story060 implemented the complete Lower Deck deep-bulkhead guard and gate, but
the Factory production `_process()` path never called its existing movement
activation API. Normal play could therefore clear the Steam Sluice and walk
past the intended encounter while tests and MCP probes started entity `2114`
directly. Runtime audit also found that the closed bulkhead blocked the
activation line before the guard appeared, the guard rendered below the gate
art, and the opened gate retained a stale interaction prompt.

**GDD**: `design/gdd/player-abilities.md`,
`design/gdd/exploration-ability-gating.md`, `design/gdd/feline-combat.md`,
`design/gdd/scene-management.md`

**Governing ADRs**: ADR-0004 Collision Detection; ADR-0005 Combat State
Machine; ADR-0006 AI Framework; ADR-0007 Scene Management; ADR-0018 Player
Abilities; ADR-0021 Save System.

## Acceptance Criteria

- [x] After the Steam Sluice is defeated, production `_process()` keeps the
  guard inactive below `x=1252` and activates it at the inclusive boundary
  without a direct activation call from the test.
- [x] Before activation the visible bulkhead does not block Cinderpaw from
  reaching the boundary. Activation enables the blocker; it remains closed
  after guard defeat until the gate is opened, then disables.
- [x] Activation reveals entity `2114`, assigns Cinderpaw as target, enables
  processing/physics, starts the existing 18-frame opening grace and updates
  the route objective to `Clear Deep Bulkhead Guard`.
- [x] The guard exposes `idle`, `run`, `attack_tell`, `attack`, `hurt` and
  `death` through `AnimatedSprite2D + SpriteFrames`, with at least three frames
  per animation.
- [x] The guard renders at `z=26`, above the `z=24` bulkhead and service lift,
  while endpoint prompts remain above the combat layer.
- [x] Opening the bulkhead hides its interaction prompt as required by
  Story060; the shared endpoint behavior remains unchanged for other instances.
- [x] The optional service lift remains available, unactivated, without an exit
  request and with prompt `Call lift`.
- [x] Thin RED/GREEN, bounded related regressions, a 180-frame Factory smoke
  and one Godot MCP 3.0.4 real-input pass complete under Godot 4.7 with clean
  project logs and a non-empty inspected screenshot.

## Out Of Scope

Guard damage or timing rebalance, new enemy families, service-lift routing,
save-schema changes, post-relay trial/reward-hatch handoffs, new visual assets
and Story181's authored pressure-valve animation.

## Implementation Notes

- Production `_process()` now preserves the order `Lower Deck skirmish -> deep
  bulkhead guard -> breach front -> breach rear -> forward content`.
- The existing guard API continues to own prerequisite checks, the inclusive
  boundary, target assignment, pacing, state synchronization and objective
  refresh.
- The bulkhead collision blocker now requires the guard to have activated and
  the gate to remain unopened. This makes `x=1252` reachable while preserving
  the combat gate after activation and defeat.
- `FactoryDeepRouteEndpoint` gained a default-off
  `hide_prompt_when_activated` option. Only the Lower Deck deep bulkhead enables
  it, so other authored endpoint labels retain their existing behavior.

## Asset Use

No new asset was required. The Story reuses the existing image-generated
Factory Spark Rat six-state SpriteFrames, deep-bulkhead gate, service lift and
Old Factory environment. No placeholder rectangle, static character or new
import was added.

## Verification Evidence

- Missing production call RED: `reports/report_2089/report_1/results.xml`.
- Visual layer RED: `reports/report_2090/report_1/results.xml`.
- Unreachable pre-activation blocker RED:
  `reports/report_2095/report_1/results.xml`.
- Opened prompt visibility RED: `reports/report_2097/report_1/results.xml`.
- Final Story186 focused GREEN: `reports/report_2096/report_1/results.xml`
  passed `1/1`; prompt GREEN `reports/report_2098/report_1/results.xml` passed
  `2/2`.
- Final related GREEN `reports/report_2099/report_1/results.xml` passed five
  suites at `9/9`, with zero failures, errors, flaky cases, skips or orphans.
- Godot 4.7 loaded the Factory scene for `180` fixed frames and exited `0` with
  no project parse, script, invalid-call/access or missing-resource error.
- Godot AI MCP 3.0.4 accepted run `r20325904-18`: after startup snap frames were
  consumed, real `move_right` input moved Cinderpaw from `x=1210` to
  `x=1253.33` and activated entity `2114` without calling its activation API.
- Accepted screenshot:
  `reports/visual/cinderpaw-mcp-old-factory-deep-bulkhead-guard-production-movement-handoff-20260720.png`.
- Full evidence:
  `production/qa/evidence/old-factory-deep-bulkhead-guard-production-movement-handoff-2026-07-20.md`.

**Status**: [x] Complete.
