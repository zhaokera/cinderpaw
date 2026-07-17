# Story 034: Old Factory Environment Cohesion

> **Epic**: Combat Presentation
> **Status**: Complete
> **Layer**: Presentation / Environment Runtime
> **Type**: Visual/Environment Cohesion Contract
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-17

## Context

**GDD**: `design/gdd/combat-presentation.md`,
`design/gdd/scene-management.md`, `design/art/art-bible.md`

**Requirements**: `TR-combatfx-003`, Old Factory readability and visual
identity

**ADR Governing Implementation**: ADR-0004 collision; ADR-0010 presentation;
ADR-0018 runtime integration.

The `30080px` Old Factory route reused two `1280x720` plates as stretched
TextureRects, producing blurred color columns across long stretches. This
Story covers those compatibility nodes with four generated, unscaled factory
variants while preserving every existing gameplay and save contract.

## Acceptance Criteria

- [x] Entry, furnace, condenser and tailrace variants each retain an unchanged
  `1672x941` image-generation source and import as exact opaque RGB
  `1280x720` runtime PNGs.
- [x] Complete prompts, source/runtime paths and SHA-256 hashes are recorded.
- [x] `EnvironmentCohesion` creates 24 runtime `Sprite2D` plates at
  `Vector2.ONE`, cycles all four textures and covers `30720px`.
- [x] The new layer renders above both legacy stretched backgrounds and below
  the existing floor, props, hazards, characters, VFX and UI.
- [x] Ground width remains `30080px`; no collision, camera, encounter, enemy,
  hazard, reward, route-state, save or audio rule changes.
- [x] Thin RED/GREEN, bounded floor/vent regression and Godot AI MCP 3.0.2
  runtime acceptance pass with clean logs and a non-empty screenshot.

## Implementation Notes

- `OldFactoryEnvironmentCohesion` owns generated plate loading, deterministic
  placement and diagnostics only.
- Existing `Background` and `PostBulkheadBackground` nodes stay in the scene
  for backward-compatible diagnostics, but are fully covered at runtime.
- Runtime children are named `FactoryBackdropTile00` through `23` so MCP can
  prove the plate count and inspect individual texture assignments.

## Test Evidence

- Initial RED: `reports/report_1887`, expected failures for the absent
  controller, generation record, source/runtime images and scene node.
- Focused GREEN: `reports/report_1890`, `1/1` passed with no errors, failures,
  flaky, skipped, orphan or process-exit leak entries.
- Bounded related GREEN: `reports/report_1892`, Story034, route floor/platform
  and steam-vent motion suites passed `3/3` with a clean exit.
- MCP: Godot `4.7-stable`, plugin/server `3.0.2`, session `cinderpaw@af5f`,
  run `r213728878-59`. Runtime diagnostics proved 24 unscaled plates, four
  textures and `30720px` coverage; the `1278x718` screenshot was non-empty,
  game logs were info-only, editor logs were empty and stop restored `ready`.

## Test-Criterion Traceability

| Criterion | Test / Evidence | Status |
| --- | --- | --- |
| Four generated opaque variants | Story034 focused test + generation record | PASS |
| 24 unscaled plates / 30720px coverage | Story034 focused test | PASS |
| Legacy background cover order | Story034 focused test | PASS |
| Ground and foreground visuals preserved | Related regression | PASS |
| Visible runtime and clean logs | Godot AI MCP 3.0.2 | PASS |

## Completion Notes

**Completed**: 2026-07-17

**Deviation**: None. This Story does not change gameplay, balance,
collision, camera, encounter, hazard, reward, save or audio behavior.
