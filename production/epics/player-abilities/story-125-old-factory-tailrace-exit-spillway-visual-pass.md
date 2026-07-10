# Story 125: Old Factory Tailrace Exit Spillway Visual Pass

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Core / Feature / Gameplay Runtime / Presentation Integration
> **Type**: Integration + Visual
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-10

## Context

**GDD**: `design/gdd/player-abilities.md`,
`design/gdd/exploration-ability-gating.md`, `design/gdd/scene-management.md`,
`design/art/art-bible.md`

**Requirements**: `TR-ability-003`, `TR-explore-001`, `TR-explore-006`,
`TR-scene-001`

**ADR Governing Implementation**: ADR-0004 Scene Tree Composition; ADR-0005
Combat State Machine; ADR-0007 Scene Management; ADR-0018 Player Abilities;
ADR-0021 Save System.

Story124 added a playable Tailrace Exit Spillway traversal after the pincer exit
hatch, but its visible duct still reused the earlier service-sluice landing
texture. That made the new ACT route read as another repeated block instead of
a distinct exit spillway. Story125 replaces that reused visual with a dedicated
image-generated Old Factory tailrace spillway prop while preserving Story124
hazard timing, bounds, state keys, route labels, and save behavior.

## Acceptance Criteria

- [x] `FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffOutletServiceSluiceTailraceRelayRunoffPincerExitSpillwayDuct`
  uses a dedicated generated texture at
  `res://assets/environment/old_factory_tailrace_exit_spillway/env_old_factory_tailrace_exit_spillway_768.png`.
- [x] The new runtime texture is a transparent `768x320` PNG imported through
  Godot, with source image, alpha source, metadata, prompt summary, runtime
  path, and usage recorded in the asset manifest and QA evidence.
- [x] Story124 gameplay behavior remains intact: hatch-open gating, visible
  ready state, active-only steam hazard contact, hazard id/damage/cooldown,
  route bounds, and route feedback are unchanged.
- [x] The spillway visual keeps the existing node position, scale, z-order, and
  layering so the steam vent hazard remains readable and is not hidden behind
  the new prop.
- [x] No new player-visible character is added; the AGENTS frame-animation rule
  is not triggered by this environment-only visual pass.
- [x] Godot MCP verifies the scene reloads from disk, the runtime texture path
  and size are correct, game/editor logs have no current-run errors, and a
  non-empty screenshot shows the updated spillway segment.

## Out of Scope

- New route length, enemy placement, AI, reward cache, savepoint, save schema,
  minimap/fast travel, authored audio, particles, shaders, or Story124 hazard
  timing changes.
- New character animation or enemy family. This story only replaces an
  environment Sprite2D texture.
- Broader Old Factory biome art replacement.

## Implementation Notes

- The new runtime prop is
  `assets/environment/old_factory_tailrace_exit_spillway/env_old_factory_tailrace_exit_spillway_768.png`.
- Source and processing evidence:
  - `assets/generated/source/old_factory_tailrace_exit_spillway_imagegen_20260710.png`
  - `assets/generated/source/old_factory_tailrace_exit_spillway_alpha_20260710.png`
  - `assets/generated/source/old_factory_tailrace_exit_spillway_imagegen_20260710.json`
- The scene keeps the existing Story124 duct transform:
  `position=Vector2(16720, 392)`, `scale=Vector2(0.78, 0.78)`, `z_index=12`,
  `z_as_relative=false`.
- `tests/unit/gameplay/old_factory_tailrace_exit_spillway_visual_pass_test.gd`
  intentionally asserts the duct no longer uses
  `env_old_factory_runoff_service_hatch_landing_768.png`.

## Test Evidence

**Required evidence**:

- `tests/unit/gameplay/old_factory_tailrace_exit_spillway_visual_pass_test.gd`
- Existing Story124 targeted smoke script:
  `tests/smoke/old_factory_service_sluice_tailrace_relay_runoff_pincer_exit_spillway_smoke.gd`
- Godot MCP runtime evidence under
  `production/qa/evidence/old-factory-tailrace-exit-spillway-visual-pass-2026-07-10.md`

**Status**: [x] RED/GREEN focused evidence, import, targeted smoke, and MCP
runtime evidence complete.

- RED focused: `reports/report_1383/` failed as expected because the spillway
  duct still used the previous service-sluice landing texture.
- Godot import:
  `"/Applications/Godot 2.app/Contents/MacOS/Godot" --headless --path . --import --quit`
  exited `0` and reimported the new runtime/source PNG files.
- GREEN focused: `reports/report_1384/` passed Story125 visual contract `1/1`.
- Headless smoke:
  `reports/old_factory_tailrace_exit_spillway_visual_pass_smoke.log` exited `0`
  and printed `service_sluice_tailrace_relay_runoff_pincer_exit_spillway_smoke=passed`.
- Godot MCP evidence:
  `production/qa/evidence/old-factory-tailrace-exit-spillway-visual-pass-2026-07-10.md`.

## Test-Criterion Traceability

| Criterion | Test / Evidence | Status |
|-----------|-----------------|--------|
| Dedicated spillway texture replaces reused landing | `reports/report_1384`; MCP node props/eval | COVERED |
| Runtime texture is transparent 768x320 and imported | Image stats; Godot import; manifest | COVERED |
| Story124 hazard parameters and bounds preserved | `reports/report_1384`; MCP eval | COVERED |
| Headless smoke confirms Story124 traversal still works | Smoke log | COVERED |
| MCP scene reload, runtime logs, and screenshot verified | QA evidence | COVERED |

## Completion Notes

**Completed**: 2026-07-10
**Criteria**: 6/6 passing
**Deviations**: No new smoke script was added; Story125 reuses the existing
Story124 targeted smoke because this story only changes the spillway visual
texture on the same runtime node.
**QA Evidence**:
`production/qa/evidence/old-factory-tailrace-exit-spillway-visual-pass-2026-07-10.md`
