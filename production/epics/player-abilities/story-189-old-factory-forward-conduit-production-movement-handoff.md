# Story 189: Old Factory Forward Conduit Production Movement Handoff

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Production Movement
> **Type**: Integration + Gameplay Runtime + Production Movement + Visual Readability
> **Estimate**: S
> **Manifest Version**: 2026-07-20
> **Last Updated**: 2026-07-20

## Context

Story067 authored the forward-conduit Spark Rat ambush and its steam hazard,
but the Factory production loop never called its activation API. After Story188
opened the forward hatch, normal movement could cross the conduit without
starting the next ACT encounter.

**GDD**: `design/gdd/player-abilities.md`,
`design/gdd/exploration-ability-gating.md`, `design/gdd/feline-combat.md`,
`design/gdd/scene-management.md`, `design/gdd/death-respawn.md`

**Governing ADRs**: ADR-0002 Event Bus; ADR-0004 Collision Detection;
ADR-0005 Combat State Machine; ADR-0006 Enemy AI; ADR-0007 Scene Management;
ADR-0018 Player Abilities; ADR-0021 Save System.

## Acceptance Criteria

- [x] From a valid Story188-complete local state, real `move_right` input and
  production physics cross inclusive `x=1272` and activate Story067 without a
  direct activation call.
- [x] Entity `2118` becomes visible and targeted with process/physics enabled,
  an opening grace total of `18`, and all six existing gameplay animations at
  three or more frames.
- [x] The active steam hazard reports id
  `old_factory_lower_deck_forward_conduit`, damage `8`, cooldown `1.0`, and a
  playing four-frame `SteamAnimation`.
- [x] Cinderpaw, the Spark Rat and active steam render above the forward hatch
  and service lift; no player-visible placeholder or static character is used.
- [x] Objective feedback changes to `Clear Forward Conduit Ambush`; the opened
  hatch remains non-blocking and the optional service lift remains idle.
- [x] Claimed upstream cache prompts, the completed deep-route prompt and the
  opened hatch prompt do not obscure the active encounter.
- [x] Route feedback is rendered in a screen-space `CanvasLayer` HUD and stays
  visible after the camera follows Cinderpaw into the forward conduit.
- [x] Story068 clear feedback remains hidden and unplayed until entity `2118`
  is defeated; Story069 pressure traversal does not start early.
- [x] Thin RED/GREEN, bounded related regressions, a 180-frame Factory smoke
  and Godot MCP 3.0.4 real-input acceptance pass under Godot 4.7.

## Out Of Scope

Defeating entity `2118`, Story068 clear-feedback changes, Story069 forward
pressure production movement, service-lift routing, save-schema changes,
reward rebalance, new enemy families, new audio and new visual assets.

## Implementation Notes

- Factory production `_process()` now calls the existing Story067 activation
  API immediately after the Story065 post-relay handoff.
- The activation API and inclusive `x=1272` boundary remain authoritative;
  Story189 adds no parallel combat state.
- Forward-conduit combat visuals use `z=26` effective depth above hatch
  `z=25` and lift `z=24`.
- `RouteLabel` now lives under `RouteHud: CanvasLayer`, so camera motion cannot
  move the current objective off screen.
- The hatch prompt remains visible in Story188's just-opened state and hides
  only after the forward-conduit encounter activates.

## Asset Use

No image-generation request was needed. The slice reuses the existing imported
and manifest-listed Cinderpaw, Factory Spark Rat, four-frame steam, hatch,
service-lift and Old Factory environment assets. No placeholder or single-frame
character was added.

## Verification Evidence

- Canonical production RED: `reports/report_2124/report_1/results.xml` failed because
  real movement crossed `x=1272` while entity `2118` remained inactive.
- Layer REDs: `reports/report_2120/report_1/results.xml` and
  `reports/report_2121/report_1/results.xml` isolated enemy and steam depth
  below the hatch/lift.
- Runtime-readability RED: `reports/report_2128/results.xml` isolated the stale
  deep-route and hatch prompts plus the missing screen-space route HUD.
- Final focused GREEN: `reports/report_2129/results.xml` passed `1/1`.
- Final related GREEN: `reports/report_2130/results.xml` passed six suites at
  `9/9`, with zero failures, errors, flaky cases, skips or orphans.
- Godot 4.7 loaded the Factory scene for `180` fixed frames and exited `0` with
  no project parse, script, invalid-call/access or missing-resource error.
- Godot AI MCP 3.0.4 accepted run `r29082530-31`: real `move_right` activated
  entity `2118`; runtime diagnostics confirmed its target, six animations,
  active four-frame steam, exact objective, hidden stale prompts, unchanged
  lift and unplayed clear feedback. Game logs contained helper info only and
  editor logs were empty after excluding one MCP-eval variable-name warning.
- Accepted screenshot:
  `reports/visual/cinderpaw-mcp-old-factory-forward-conduit-production-movement-handoff-20260720.png`.
- Full evidence:
  `production/qa/evidence/old-factory-forward-conduit-production-movement-handoff-2026-07-20.md`.

**Status**: [x] Complete.
