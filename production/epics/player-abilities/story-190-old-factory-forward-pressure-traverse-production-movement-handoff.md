# Story 190: Old Factory Forward Pressure Traverse Production Movement Handoff

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Production Movement
> **Type**: Integration + Gameplay Runtime + Production Movement + Visual Readability
> **Estimate**: S
> **Manifest Version**: 2026-07-21
> **Last Updated**: 2026-07-21

## Context

Story069 authored the forward-pressure traversal state, timed steam phases and
persistence contract, but the Factory production loop never invoked its
activation, timing or completion APIs. After Story189 secured the forward
conduit, normal movement could pass the pressure leak without starting or
finishing the authored traversal.

**GDD**: `design/gdd/player-abilities.md`,
`design/gdd/exploration-ability-gating.md`, `design/gdd/feline-combat.md`,
`design/gdd/scene-management.md`, `design/gdd/death-respawn.md`

**Governing ADRs**: ADR-0002 Event Bus; ADR-0004 Collision Detection;
ADR-0005 Combat State Machine; ADR-0006 Enemy AI; ADR-0007 Scene Management;
ADR-0018 Player Abilities; ADR-0021 Save System.

## Acceptance Criteria

- [x] From a valid Story189-complete local state, real `move_right` input and
  production physics cross inclusive `x=1284` and activate Story069 without a
  direct activation call.
- [x] Production time advances the traversal through initial grace, warning,
  active and safe phases using the existing `0.25/0.35/0.40/0.45` second
  contract.
- [x] The pressure vent reports id
  `old_factory_lower_deck_forward_pressure_traverse`, damage `8`, cooldown
  `1.0`, and safe/warning/active animations of four frames each.
- [x] Warning and active steam remain visible above the forward hatch and
  service lift; no player-visible placeholder or static character is added.
- [x] Objective feedback changes from `Forward Conduit Secured` to
  `Cross Forward Pressure Leak` while active.
- [x] Continued real movement crosses inclusive `x=1328`, persists the crossed
  flag, hides/disables the vent and changes the objective to
  `Forward Pressure Traverse Crossed`.
- [x] Story070 becomes available after the crossing but remains inactive with
  its enemy and hazard hidden; the optional service lift remains idle and
  Story068 clear feedback does not replay.
- [x] Thin RED/GREEN, bounded related regressions, a 180-frame Factory smoke
  and Godot MCP 3.0.4 real-input acceptance pass under Godot 4.7.

## Out Of Scope

Story070 counter-ambush production activation, later pressure-route content,
service-lift routing, death/reset redesign, save-schema changes, reward or
hazard rebalance, new audio and new visual assets.

## Implementation Notes

- Factory production `_process()` now calls Story069 immediately after the
  Story067 forward-conduit handoff in the authoritative order: activate,
  advance by production delta, then complete.
- Story069's existing inclusive `x=1284` activation and `x=1328` exit
  boundaries remain authoritative; Story190 adds no parallel traversal state.
- Story070 is intentionally not wired into the production loop in this slice.
- The target pressure vent now renders at effective `z=26`, above hatch
  `z=25` and lift `z=24`.
- A fast player may clear the short traversal during grace. Tests and MCP pause
  movement after activation only to prove that production time independently
  advances the authored warning/active cycle.

## Asset Use

No image-generation request was needed. The slice reuses the imported and
manifest-listed four-frame steam resource at
`assets/environment/old_factory_steam_vent/factory_steam_vent_sprite_frames.tres`.
Its recorded generation prompt is
`assets/environment/old_factory_steam_vent/source/factory_steam_vent_motion_sheet_imagegen_20260716.md`,
with source image
`assets/generated/source/old_factory_steam_vent_hazard_imagegen_20260626.png`.
No placeholder or single-frame character was added.

## Verification Evidence

- Canonical RED: `reports/report_2131/results.xml` ran one production movement
  case and failed 14 assertions for the intended missing activation/timing/
  completion wiring plus steam depth below hatch/lift.
- Final focused GREEN: `reports/report_2132/results.xml` passed `1/1`.
- Final related GREEN: `reports/report_2133/results.xml` passed five suites at
  `8/8`, with zero failures, errors, flaky cases, skips or orphans.
- Godot 4.7 loaded the Factory scene for `180` fixed frames and exited `0`;
  `reports/old_factory_forward_pressure_traverse_production_movement_handoff_smoke.log`
  contains no project parse, script, invalid-call/access, warning or error.
- Godot AI MCP 3.0.4 accepted run `r92604283-1`: real `move_right` activated at
  `x=1284.6667`, production time reached warning at `0.2667s` and active at
  `0.6083s`, then continued movement completed at `x=1328.0002`.
- Runtime diagnostics confirmed exact phase, animation, hazard, HUD, depth,
  persistence and Story070/lift/clear-feedback boundaries. Current-run game
  logs contained helper registration only; editor logs were empty and stop
  restored editor readiness to `ready`.
- Accepted screenshots:
  `reports/visual/cinderpaw-mcp-old-factory-forward-pressure-traverse-production-movement-handoff-warning-20260721.png`
  and
  `reports/visual/cinderpaw-mcp-old-factory-forward-pressure-traverse-production-movement-handoff-active-20260721.png`.
- Full evidence:
  `production/qa/evidence/old-factory-forward-pressure-traverse-production-movement-handoff-2026-07-21.md`.

**Status**: [x] Complete.
