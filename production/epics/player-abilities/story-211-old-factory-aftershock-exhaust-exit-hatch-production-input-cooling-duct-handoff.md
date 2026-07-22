# Story 211: Old Factory Aftershock Exhaust Exit Hatch Production Input Cooling Duct Handoff

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Route Progression
> **Type**: Integration + Production Input + Production Movement + Route Handoff
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-22

## Context

**GDD**: `design/gdd/player-abilities.md`,
`design/gdd/exploration-ability-gating.md`,
`design/gdd/scene-management.md`

**Requirements**: `TR-scene-004`, `TR-explore-005`, `TR-respawn-002`

**ADR Governing Implementation**: ADR-0004 collision detection; ADR-0007
scene-local state; ADR-0018 player abilities; ADR-0021 save persistence.

**Control Manifest**: Godot 4.7; input/game logic remains in the gameplay
scene, scene state uses `get_local_state()` / `set_local_state()`, and no new
Autoload or synchronous scene transition is introduced.

Story210 leaves the Story092 exhaust exit hatch visible, interactive and
blocking after the aftershock escape skirmish. Story211 closes the production
gap between the already-complete Story092 and Story093 contracts: Cinderpaw
must open the hatch through the real `interact` input route, then make a fresh
rightward move before the cooling-duct traverse can start.

## Acceptance Criteria

- [x] The production nearest-progression interaction route includes the
  available Story092 exhaust exit hatch and opens it from a real `interact`
  rising edge after Cinderpaw approaches from outside its `96px` radius.
- [x] Holding `interact` before entering range does not open the hatch; the
  player must release it and produce a fresh rising edge while in range.
- [x] The hatch opens once, persists its opened state, disables its blocker and
  interaction, plays exactly one existing unlock VFX burst, and does not route
  the same or held input to another progression prop.
- [x] Opening the hatch reveals Story093 as available but does not activate the
  cooling duct in the same frame, even when the provider is already at or past
  the activation threshold.
- [x] Stationary frames and restored/teleported positions do not auto-start the
  cooling duct. A fresh real rightward movement edge across x `3240.0` starts
  Story093 once and leaves it active, uncrossed, in its initial grace phase.
- [x] Focused and adjacent Story092/093 regressions, a Factory headless smoke,
  and one Godot MCP production-input runtime acceptance pass under Godot 4.7 /
  Godot AI MCP 3.0.4 are clean.

## Out of Scope

Crossing the full cooling duct, changing steam damage/timing, new art or audio,
new enemies, savepoint changes, and deeper condenser content.

## Asset Pipeline

No new visual asset is required. This Story reuses the imported image-generated
Story092 hatch and Story093 cooling-duct/steam-vent assets.

## Implementation Notes

- Story092 is added to the existing nearest-progression interaction candidate
  set; it does not bypass `handle_factory_interact_input()`.
- Story093 auto-activation requires all three signals of intentional movement:
  the route was already available at frame start, player x increased since the
  previous frame, and production `move_right` is currently pressed.
- `set_local_state()` resets the transient x tracker. The new per-frame work is
  constant-time and introduces no new node, allocation-heavy system, Autoload,
  data schema, or asset import.
- This Story deliberately stops at Story093 `active + grace`. Production hazard
  time advancement and the full x `3740.0` crossing are a later slice.

## Test Evidence

- Canonical thin TDD suite:
  `tests/unit/gameplay/old_factory_aftershock_exhaust_exit_hatch_production_input_cooling_duct_handoff_test.gd`
  - Initial RED: `reports/report_2276/report_1/results.xml` (`1` case,
    production interaction missing).
  - Review RED: `reports/report_2279/report_1/results.xml` (`1` precise failure,
    no-input teleport incorrectly activated Story093).
  - Focused GREEN: `reports/report_2280/report_1/results.xml` (`1/1`).
  - Final bounded related: `reports/report_2281/report_1/results.xml` (`8/8`
    across five suites).
- Factory smoke:
  `reports/old_factory_aftershock_exhaust_exit_hatch_production_input_cooling_duct_handoff_smoke.log`
  exited `0` with no project parse/script/invalid-call/access/resource errors.
- Godot MCP 3.0.4 accepted run `r145086182-73`: held approach stayed closed,
  fresh `interact` opened once, no-input x `3244` teleport stayed inactive,
  real `move_right` reached x `3327.3` and started Story093 in `grace`, both
  inputs were released, game log contained helper info only, and editor log was
  empty. Non-empty RGB `1278x718` screenshot:
  `reports/visual/cinderpaw-mcp-aftershock-exhaust-exit-hatch-production-input-cooling-duct-handoff-20260722.png`.

## Dependencies

- Depends on: Story210, Story092 and Story093
- Unlocks: Story093 production hazard-cycle/full-traverse acceptance

## Verification Summary

The first RED proved the hatch was absent from production interaction routing.
The review-hardened RED then proved a position delta alone treated teleport as
movement. The minimal implementation added the hatch candidate plus frame-start
availability, previous-x and `move_right` guards. Final bounded regression is
`8/8`; smoke and MCP runtime acceptance are clean. No full suite was run.

The final screenshot also records non-blocking visual debt: the opened hatch
still reads as a closed panel and nearby world prompts overlap. That belongs in
a focused visual-readability Story rather than widening this input handoff.
