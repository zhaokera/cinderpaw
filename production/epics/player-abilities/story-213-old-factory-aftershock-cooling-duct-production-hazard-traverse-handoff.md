# Story 213: Old Factory Aftershock Cooling Duct Production Hazard Traverse Handoff

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Production Route
> **Type**: Integration + Production Movement + Hazard Timing + Route Handoff
> **Estimate**: XS
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-22

## Context

**GDD**: `design/gdd/player-abilities.md`,
`design/gdd/exploration-ability-gating.md`,
`design/gdd/scene-management.md`

**Requirements**: `TR-scene-004`, `TR-explore-005`, `TR-respawn-002`

**ADR Governing Implementation**: ADR-0004 collision detection; ADR-0007
scene-local state; ADR-0018 player abilities; ADR-0021 save persistence.

**Control Manifest**: Godot 4.7 and the existing Story093/094 route state are
authoritative. No new Autoload, input action, scene transition or asset is
introduced.

Story211 proves that fresh production `move_right` starts Story093 after the
Story092 hatch opens. Story093 already owns deterministic steam-cycle APIs and
Story094 already owns the condenser landing encounter, but the production
Factory loop does not advance Story093 time and can evaluate Story094 after
Story093 changes state in the same frame.

## Acceptance Criteria

- [x] Once Story093 starts through production movement, Factory `_process(delta)`
  advances the existing `grace -> warning -> active -> safe` steam cycle.
- [x] The existing Story093 vent rejects contact outside `active`, applies its
  authored `8` damage once when active, and becomes harmless after the route is
  crossed.
- [x] A real rightward player movement can complete Story093 beyond x `3740.0`.
- [x] The Story093 completion frame exposes Story094 as available and visible,
  but does not activate its enemies in that same frame even when the player
  reaches Story094's x threshold.
- [x] Story093 local state persists as activated/crossed and its route objective
  hands off to the existing Story094 objective without replaying the duct.
- [x] Focused/related GdUnit, one Factory headless smoke and one Godot MCP 3.0.4
  runtime acceptance under Godot 4.7 complete without new errors.

## Out of Scope

Changing steam timings or damage, adding hazard art/audio, changing Story094
enemy behavior, completing the Story094 fight, or extending later condenser
route slices.

## Asset Pipeline

No new visual asset is required. This Story reuses the registered
image-generated Story093 cooling duct/steam vent and Story094 condenser/enemy
assets already imported by Godot.

## Dependencies

- Depends on: Story211, Story212, Story093 and Story094
- Unlocks: Story094 production ambush acceptance

## Test Evidence

- Canonical thin TDD suite:
  `tests/unit/gameplay/old_factory_aftershock_cooling_duct_production_hazard_traverse_handoff_test.gd`
  - Initial RED: `reports/report_2289/report_1/results.xml` (`1` case, `7`
    expected failures proving production time did not advance).
  - Focused GREEN: `reports/report_2290/report_1/results.xml` (`1/1`).
  - Final bounded related: `reports/report_2291/report_1/results.xml` (`6/6`
    across Story211, Story093, Story094 and Story213).
- Factory smoke:
  `reports/old_factory_aftershock_cooling_duct_production_hazard_traverse_handoff_smoke.log`
  exited `0`; the project error-keyword scan was empty. Godot printed the
  repository's existing ObjectDB/resource teardown messages outside the
  project log.
- Godot MCP 3.0.4 accepted run `r148345568-3` under Godot 4.7 observed
  `idle -> grace -> warning -> active -> safe`, real overlap HP
  `100 -> 92`, safe x `3432.66`, and then a controlled real movement x
  `3919.5 -> 3920.17`. That single production `_process` completed Story093
  while Story094 stayed available/inactive with both enemies hidden,
  non-processing and untargeted. Inputs were released; game log was
  helper-only and editor log was empty.
- Non-empty RGB `1278x718` screenshot:
  `reports/visual/cinderpaw-mcp-story213-cooling-duct-20260722.png`
  (SHA-256 `29100d2cf2141f213aab1df0073cbfcb2c228214016f9aa6a9ca9bfb35d9770b`).
  The PNG was losslessly re-encoded on 2026-07-22 after Godot 4.7 rejected a
  later on-disk encoding; the rendered pixels and `1278x718` evidence remain
  unchanged, and Godot CLI import now succeeds.

## Verification Summary

The RED isolated the missing production time connection without reopening the
Story093 hazard implementation. Factory `_process(delta)` now advances that
existing API exactly once and snapshots Story094 availability at frame start,
so new downstream state cannot be consumed in the completion frame. Focused
and four-suite related tests passed, the Factory smoke exited cleanly, and one
final MCP run verified the visible cycle, real `8` damage, crossed objective,
hidden Story094 enemies, clean logs and non-empty screenshot. No full suite or
new image generation was needed.
