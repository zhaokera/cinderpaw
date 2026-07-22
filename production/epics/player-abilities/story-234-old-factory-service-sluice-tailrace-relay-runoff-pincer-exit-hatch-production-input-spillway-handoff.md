# Story 234: Old Factory Service Sluice Tailrace Relay Runoff Pincer Exit Hatch Production Input Spillway Handoff

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Route Handoff
> **Type**: Integration + Production Input + UI/Visual + Route Handoff
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-22

## Context

**GDD**: `design/gdd/player-abilities.md`, `design/gdd/input.md`,
`design/gdd/exploration-ability-gating.md`, `design/gdd/scene-management.md`

**Requirements**: `TR-input-001`, `TR-scene-004`, `TR-explore-005`

**ADR Governing Implementation**: ADR-0004 collision detection; ADR-0007
scene management; ADR-0018 player abilities; ADR-0021 save system.

Story233 leaves Story123 visible, available and blocking after its reward cache
is claimed. Story234 routes one fresh production `interact` edge into that
hatch, gives the opening a readable authored pose, and exposes Story124 as a
visible but inactive spillway handoff.

## Acceptance Criteria

- [x] Story233 terminal state exposes the closed Story123 hatch at
  `Vector2(16080, 392)` with `Open Tailrace Exit`, collision enabled and unlock
  VFX spawn count `0`; Story124 remains hidden and unavailable.
- [x] `interact` pressed outside the `96px` activation radius remains stale
  after entering range. Release/rearm and no-input placement also leave the
  hatch closed.
- [x] One fresh production `Input.interact` edge travels through Factory
  `_process()`, `handle_factory_interact_input()` and the deterministic nearest
  progression router to open Story123 exactly once.
- [x] Opening disables availability, monitoring, monitorability and collision,
  hides the world prompt, preserves diagnostic text `Tailrace Exit Open`, and
  advances the route label to `Tailrace Runoff Exit Opened`.
- [x] The existing unlock spark plays once. Diagnostics report its active
  lifetime through `active_count`, and held or duplicate fresh input cannot
  increase spawn count beyond `1`.
- [x] The hatch root remains at `(16080,392)`. Child `Visual` moves to
  `(48,-136)`, rotates `+6deg`, and uses child z `-4`, giving effective z `23`
  above spillway art z `12/18` and below Cinderpaw z `26`.
- [x] Story124 becomes visible and available on the opening edge but remains
  inactive, uncrossed, idle, non-contacting and collision-disabled.
- [x] Held hatch input, stationary frames and no-input placement beyond Story124
  activation/exit thresholds cannot consume the next beat. Automatic activation
  requires availability at frame start, held `move_right`, initialized previous
  x and real positive-x displacement.
- [x] Focused/related GdUnit, one 180-frame smoke and one Godot MCP runtime pass
  under Godot 4.7 / Godot AI MCP 3.0.4 with clean accepted-run logs and
  non-empty screenshots.

## Out of Scope

Story124 production movement, steam timing, physical damage and crossing;
Sluice Leech combat; new rewards, savepoints, generated art, audio, particles,
shaders, save schema, route expansion or full-suite testing.

## Implementation Notes

- Story123 is appended to the existing nearest progression candidate list;
  shared rising-edge input handling remains the only production entry point.
- Story124 snapshots frame-start availability and tracks prior player x. This
  prevents the hatch-open edge, stationary frames and diagnostic teleporting
  from consuming a movement-gated ACT beat.
- The hatch uses the same proven opened pose as the earlier service-sluice exit.
  Its root, interaction radius and blocker position do not move.
- Story123 diagnostics now read VFX `active_count`, matching
  `FactoryDeepRouteEndpoint.get_unlock_vfx_snapshot()` and the other Factory
  endpoint diagnostics.

## Asset Pipeline

No new asset was required. The slice reuses the imported image-generated deep
bulkhead door, unlock spark, Story125 spillway, four-frame steam vent and
Cinderpaw frame animation. Reuse is recorded in `design/assets/asset-manifest.md`.

## Test Evidence

- Canonical RED: `reports/report_2399/results.xml`, one case with eight expected
  router, pose, z-order, prompt and spillway-guard failures.
- Initial focused GREEN: `reports/report_2400/results.xml`, `1/1`.
- Initial related GREEN: `reports/report_2401/results.xml`, five suites and
  `7/7`.
- Diagnostic regression RED/GREEN: `reports/report_2402/results.xml` failed only
  because `unlock_feedback_active` read the wrong key;
  `reports/report_2403/results.xml` passed `1/1` after the correction.
- Final bounded related GREEN: `reports/report_2404/results.xml`, five suites and
  `7/7`; zero errors, failures, flaky, skipped or orphaned tests.
- Updated smoke exited `0` after 180 frames and printed
  `story234_production_smoke=passed frames=180`.
- Godot MCP 3.0.4 accepted run `r198694429-38` exercised stale, release/no-input,
  fresh and duplicate real `interact`, validated hatch pose/VFX and Story124
  waiting guards, and ended with helper-only game logs plus an empty editor
  delta after cursor `2`.

## Dependencies

- Depends on: Story233 production reward handoff and Story123/124 authored
  hatch/spillway contracts
- Unlocks: Story235 real production Story124 movement, steam contact and
  crossing into the Sluice Leech handoff

## Verification Summary

Accepted under Godot 4.7 / Godot AI MCP 3.0.4. Story123 now opens only through
fresh production input, has a readable once-only visual payoff, and hands an
unconsumed Story124 traversal to the next bounded slice. Full-suite testing was
intentionally omitted.
