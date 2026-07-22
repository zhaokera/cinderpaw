# Story 193: Old Factory Forward Pressure Exit Guard Production Movement Handoff

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Production Input + Movement
> **Type**: Integration + Gameplay Runtime + Production Movement + Combat Readability
> **Estimate**: S
> **Manifest Version**: 2026-07-21
> **Last Updated**: 2026-07-21

## Context

Story073 authored the forward-pressure exit guard, entity `2120`, its steam
hazard and persistence contract. Story192 then connected the preceding reward
cache to real `interact`, but normal movement still could not start Story073.
This story connects the complete claim-to-movement sequence without letting the
claim edge activate newly unlocked combat in the same frame.

**GDD**: `design/gdd/input.md`, `design/gdd/player-abilities.md`,
`design/gdd/exploration-ability-gating.md`, `design/gdd/feline-combat.md`,
`design/gdd/scene-management.md`

**Governing ADRs**: ADR-0002 Event Bus; ADR-0004 Collision Detection;
ADR-0005 Combat State Machine; ADR-0006 Enemy AI; ADR-0007 Scene Management;
ADR-0018 Player Abilities; ADR-0021 Save System.

## Acceptance Criteria

- [x] From a valid Story191-complete state at `x=1352`, real `interact` claims
  Story071 once; the claim frame and at least three stationary held frames make
  Story073 available but do not activate it.
- [x] After release, real `move_right` from the same `x=1352` boundary advances
  Cinderpaw and activates Story073 without calling its activation API directly.
- [x] Entity `2120` becomes visible and processing with Cinderpaw as its target;
  `idle`, `run`, `attack_tell`, `attack`, `hurt` and `death` each contain at
  least three frames and opening pacing starts in non-attacking `idle`.
- [x] The existing Story073 vent contract is unchanged: it becomes visible and
  contact-active with hazard id
  `old_factory_lower_deck_forward_pressure_exit_guard`, damage `8` and cooldown
  `1.0s`; its active animation contains four frames.
- [x] Active HUD reads `Clear Forward Pressure Exit Guard`; enemy and steam
  render at effective `z=26`, above hatch `z=25` and lift `z=24`.
- [x] Story074's exit relay remains unavailable, hidden, non-monitoring and
  unactivated until entity `2120` is defeated. The optional service lift stays
  idle and makes no exit request.
- [x] Thin RED/GREEN, bounded related regressions, a 180-frame Factory smoke
  and Godot MCP 3.0.4 real-input acceptance pass under Godot 4.7.

## Out Of Scope

Story073 combat tuning, a new vent grace or hazard redesign, Story074 relay
production activation, Story075 exit gate, service-lift routing, save-schema
changes, new attacks and new visual/audio assets.

## Implementation Notes

- `_process()` snapshots Story073 availability before handling `interact`.
  A cache claim therefore cannot activate combat in the same frame.
- The scene tracks Cinderpaw's previous global x at the end of each production
  frame. Story073 auto-activation requires the previous position not to be to
  the right of `x=1352`, the current position to be at or beyond the boundary,
  and a strictly positive x movement. Stationary held input stays inert while
  movement from the exact boundary remains valid.
- Story073 production activation runs after Story070 and before the later
  beacon ambush. Its authored activation API, enemy pacing, hazard behavior,
  defeat and persistence contracts remain unchanged.
- The exit-guard Spark Rat now renders at `z=26`; the vent root renders at
  `z=25`, making its `SteamAnimation` effective `z=26`.

## Asset Use

No image-generation request was needed. The slice reuses the imported,
manifest-listed Factory Spark Rat `AnimatedSprite2D + SpriteFrames`, the
four-frame Factory steam resource, Cinderpaw, cache, hatch, lift and authored
Factory environment. No placeholder or single-frame character was added.

## Verification Evidence

- Canonical integration RED `reports/report_2147/results.xml` failed its single
  test because real movement crossing `x=1352` did not activate entity `2120`.
- Parallel QA then identified the exact-boundary continuation gap. Strengthened
  RED `reports/report_2151/results.xml` reproduced a real cache claim at
  `x=1352`, three held stationary frames, release and real forward movement;
  the player moved but Story073 remained inactive.
- Focused GREEN `reports/report_2153/results.xml` passed `1/1`. Final related
  GREEN `reports/report_2154/results.xml` passed five suites at `9/9`, with zero
  failures, errors, flaky cases, skips or orphans.
- Godot 4.7 loaded the Factory scene for `180` fixed frames and exited `0`;
  `reports/old_factory_forward_pressure_exit_guard_production_movement_handoff_smoke.log`
  contains only normal startup plus the established cleanup-only Factory
  terminal baseline.
- Godot AI MCP 3.0.4 accepted clean run `r99624813-11`. Real `interact` claimed
  Story071 once while Story073 stayed inactive; real `move_right` then moved
  Cinderpaw from `x=1352` to `x=1388.6667` and activated entity `2120`.
- MCP confirmed exact frame counts, active steam, hazard values, objective,
  depth, locked Story074 relay and idle lift. The game log was helper-only,
  editor logs were empty and stop restored `ready`.
- Accepted non-empty RGB `1278x718` screenshot:
  `reports/visual/cinderpaw-mcp-old-factory-forward-pressure-exit-guard-production-movement-handoff-active-20260721.png`.
- Full evidence:
  `production/qa/evidence/old-factory-forward-pressure-exit-guard-production-movement-handoff-2026-07-21.md`.

**Status**: [x] Complete.
