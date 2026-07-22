# Story 227: Old Factory Service Sluice Exit Hatch Production Input Tailrace Handoff

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Route Handoff
> **Type**: Integration + Production Input + UI/Visual + Route Handoff
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-22

## Context

**GDD**: `design/gdd/player-abilities.md`,
`design/gdd/exploration-ability-gating.md`, `design/gdd/feline-combat.md`,
`design/gdd/scene-management.md`, `design/gdd/death-respawn.md`

**Requirements**: `TR-scene-004`, `TR-explore-005`, `TR-respawn-002`

**ADR Governing Implementation**: ADR-0004 Collision detection; ADR-0007 Scene
management; ADR-0018 Player abilities; ADR-0021 Save system.

Story226 leaves Story116 visible, blocking and ready after the service-sluice
reward is claimed. Story227 connects that Hatch to the production interaction
router, gives its opening a readable authored pose, and exposes Story117 without
allowing stale input, stationary frames or no-input displacement to start the
tailrace.

## Acceptance Criteria

- [x] Story226 terminal state exposes Story116 as visible, available, blocking
  and unopened while Story117 remains hidden and unavailable.
- [x] An `interact` held before entering the `96px` Hatch radius remains stale;
  no-input placement in range does not open the Hatch or spawn unlock VFX.
- [x] A released/rearmed fresh production `Input.interact` edge opens Story116
  once through the nearest-progression router and persists its opened flag.
- [x] Opening clears collision and interaction monitoring, keeps diagnostic text
  `Service Exit Open`, hides the world prompt, and leaves unlock VFX spawn count
  at exactly one across duplicate fresh presses.
- [x] The opened door Visual moves to local `(48,-136)`, rotates `+6deg`, and
  renders at effective z `23`, above the tailrace environment and below
  Cinderpaw z `26`.
- [x] Story117 becomes present, visible and available after the open edge, while
  remaining inactive, uncrossed and non-contact in the same and stationary
  frames.
- [x] No-input placement beyond Story117 activation x `12020` remains inactive;
  automatic activation now requires prior availability, held `move_right` and
  real positive-x movement.
- [x] Focused/related GdUnit, a `180`-frame headless smoke and Godot MCP runtime
  checks pass under Godot 4.7 / Godot AI MCP 3.0.4.

## Out of Scope

Story117 real movement activation, steam phase timing, damage, crossing and its
following ambush; new enemies, savepoints, audio, shaders, particles, image
generation, and broader Factory biome replacement.

## Implementation Notes

- The shared progression router now includes the Story116 exit Hatch and keeps
  nearest-distance deterministic selection.
- Story117 tracks the previous player x and snapshots availability at frame
  start, matching the movement guards used by adjacent production route slices.
- The Hatch root and blocker remain at `(11680,392)`; only the child Visual is
  retracted and rotated, so interaction and persistence coordinates stay stable.

## Asset Pipeline

Existing imported image-generated Factory, Hatch, unlock VFX, Cinderpaw,
tailrace duct and four-frame steam assets cover the slice. No new visual asset
or animation resource was required.

## Test Evidence

- Canonical RED: `reports/report_2368/report_1/results.xml`, `1` test with six
  expected assertions covering the missing router, visual pose/z and no-input
  tailrace guard.
- Focused GREEN: `reports/report_2369/report_1/results.xml`, `1/1`.
- Initial related GREEN: `reports/report_2370/report_1/results.xml`, `9/9`.
- Final GDD prompt-hiding related GREEN:
  `reports/report_2371/report_1/results.xml`, six suites and `9/9`, zero
  errors/failures/flaky/skipped/orphans.
- Headless smoke:
  `reports/old_factory_service_sluice_exit_hatch_production_input_tailrace_handoff_smoke.log`
  exited `0` with `story227_smoke=passed frames=180`.
- Godot MCP 3.0.4 run `r182022878-24` used real `interact`, confirmed the exact
  door pose/z, hidden world prompt, one VFX, visible waiting Story117, no-input
  x `12024` rejection, helper-only game log, empty editor delta after cursor
  `2`, released inputs and a non-empty RGB `1278x718` framebuffer.

## Dependencies

- Depends on: Story226 production reward-cache input and closed-Hatch handoff
- Unlocks: Story117 production movement, hazard timing and tailrace crossing

## Verification Summary

Accepted under Godot 4.7 / Godot AI MCP 3.0.4. Story116 now opens through real
production input with a readable, non-occluding pose and hands off to a visible
but safely inactive Story117. Full-suite testing was intentionally omitted.
