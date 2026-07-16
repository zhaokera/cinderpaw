# Story 171: Central Tower Local Minimap Continuity

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Feature / Presentation / Exploration / Save Integration
> **Type**: Integration + UI + Player Feedback
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-17

## Context

**GDD**: `design/gdd/map-system.md`, `design/gdd/hud-ui.md`,
`design/gdd/exploration-ability-gating.md`

**Requirements**: `TR-hud-001`, `TR-hud-002`, `TR-hud-004`,
`TR-explore-004`, `TR-explore-006`

**Governing ADRs**: ADR-0001 Autoload architecture; ADR-0002 signal
communication; ADR-0007 scene management; ADR-0008 save serialization;
ADR-0011 UI focus management; ADR-0013 pixel-art rendering; ADR-0015
accessibility; ADR-0021 save system.

Story152 established the reusable `120x120` shape-readable HUD minimap in
Main. Central Tower is one authored `6400x720` scene containing five contiguous
ACT route segments, but its HUD currently provides no local route continuity.
This Story connects those five segments to the existing widget, updates the
current segment from player position, and derives discovery from existing Tower
progress so no second persistence owner is introduced.

## Acceptance Criteria

- [x] The existing HUD mounts one visible `120x120` minimap for Tower with five
  forward-connected schematic nodes: Tower Threshold, Service Spine, Cooling
  Shaft, Deep Lift and Apex Conduit.
- [x] The current node changes at the authored `1280px` segment boundaries;
  returning or respawning in an earlier segment highlights that segment rather
  than the furthest completed one.
- [x] The player marker tracks and clamps local horizontal progress inside the
  current `1280x720` segment without changing gameplay or camera state.
- [x] Threshold starts discovered. The next four nodes derive discovery from
  `central_tower_threshold_guard_defeated`,
  `central_tower_relay_mantis_defeated`,
  `central_tower_cooling_shaft_traversed`, and
  `central_tower_deep_lift_ascended` respectively.
- [x] A live durable progress transition reveals its destination over exactly
  `1.0s` and emits one `<Area Name> discovered` notification; duplicate sync
  cannot replay either feedback.
- [x] Save/no-loss restoration synchronizes discovered nodes immediately at
  full progress with no reveal or notification and adds no save field.
- [x] Main's existing minimap behavior remains unchanged, and focused GdUnit
  plus one Godot AI MCP runtime acceptance verify clean logs, a non-empty
  screenshot and a visible shape-readable route.

## Out Of Scope

- Full-screen map, zoom/pan, rotation, completion percentages, savepoint/Boss/
  secret/shortcut markers, fast travel or Crown Observatory mapping.
- New bitmap art, icon atlas, animation, audio, map shader or generated visual
  asset. This slice reuses the established code-drawn HUD widget.
- New save fields, Autoloads or duplicate discovery state.
- Changes to Story140-145 combat, traversal, collision, balance, route gates or
  progression semantics.
- A new continuous-geometry minimap rendering mode or a redesign of Main's
  existing schematic marker behavior.

## Implementation Notes

- Add a small current-area setter to `MinimapWidget` and delegate it through
  `HUDManager`; changing current area must not rebuild regions or clear active
  reveals.
- Tower owns the mapping from player X and existing local-state keys into the
  presentation model. The widget remains presentation-only.
- Use current-segment world bounds for marker normalization because the widget
  intentionally draws local progress beside the current schematic node.
- Runtime progress callbacks request animated reveal; `set_local_state()` uses
  immediate discovery synchronization so restoration never replays feedback.

## Test Evidence

- Initial RED: `reports/report_1872/report_1/results.xml`, `1/1` expected
  failure because the Tower minimap diagnostics contract did not exist.
- Focused GREEN: `reports/report_1874/report_1/results.xml`, `1/1` passed after
  the restore-notification regression exposed by `report_1873` was fixed.
- Post-review focused gate: `reports/report_1877/report_1/results.xml`, `1/1`
  passed using the real controller signal path plus exact/clamped boundaries.
- Final bounded GREEN: `reports/report_1875/report_1/results.xml`, `6/6` passed
  across Story171, Story152 Main minimap and Story140 Tower Threshold coverage;
  exit code `0`.
- Godot MCP runtime evidence:
  `production/qa/evidence/central-tower-local-minimap-continuity-2026-07-17.md`.

## Completion Notes

**Completed**: 2026-07-17

**Criteria**: 7/7 passing

**Deviation**: None. No visual asset or save field was added because this
Story intentionally reuses the established code-drawn HUD and existing durable
Tower progression.
