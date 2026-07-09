# Story 100: Main Scene Dash Gate Authored Visual Replacement

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Core / Feature / Gameplay Runtime / Presentation Integration
> **Type**: Integration + Visual
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-09

## Context

**GDD**: `design/gdd/player-abilities.md`,
`design/gdd/exploration-ability-gating.md`, `design/gdd/feline-combat.md`

**Requirements**: `TR-ability-003`, `TR-ability-004`, `TR-ability-005`,
`TR-explore-001`, `TR-explore-002`, `TR-explore-006`

**ADR Governing Implementation**: ADR-0005 Combat state machine; ADR-0018
Player abilities; ADR-0007 Scene management; ADR-0021 Save system.

Story002 made the Dash gate playable but reused the Rat King arena electric
leak texture as a replaceable baseline. Story100 replaces that player-visible
placeholder with a dedicated image-generated Dash gate marker while preserving
the existing dash unlock, collision, prompt, and save-state behavior.

## Acceptance Criteria

- [x] `DashExplorationGate/Visual` in `scenes/main.tscn` uses a dedicated
  texture under `assets/environment/dash_gate/` and no longer references
  `assets/environment/rat_king_arena/electric_leak.png`.
- [x] The Dash gate visual is a transparent 256x256 PNG, imported through
  Godot with `.import` sidecars for both source and runtime assets.
- [x] The Dash gate no longer requires the old 90-degree rotation or non-uniform
  scaling used by the reused electric-leak baseline.
- [x] Existing Story002 runtime behavior remains intact: the gate requires
  Dash, unlocks through the existing `ExplorationGate` path, and persists the
  gate/world flags in `MainScene` snapshots.
- [x] The image generation prompt summary, source PNG, alpha PNG, runtime PNG,
  import status, and usage are recorded in asset manifest and QA evidence.
- [x] Godot MCP verifies `res://scenes/main.tscn` loads, the runtime Dash gate
  uses the new texture, Cinderpaw remains `AnimatedSprite2D`, the current run
  has no new errors, and a non-empty screenshot shows the authored gate.

## Out of Scope

- New Dash mechanics, cooldown tuning, collision size changes, or save schema
  changes.
- Reworking Double Jump/Parry gates, Boss2 arena art, Old Factory route content,
  minimap, or broader main-scene background polish.
- New Dash SFX/VFX or unlock dissolve changes; this story only replaces the
  persistent visible Dash gate marker art.

## Implementation Notes

- Keep `ExplorationGate` behavior unchanged. This is a scene/resource wiring and
  asset-pipeline story.
- The runtime texture path is
  `res://assets/environment/dash_gate/dash_gate_marker.png`.
- Source prompt metadata is stored at
  `assets/generated/source/dash_gate_marker_imagegen_20260709.json`.

## Test Evidence

**Required evidence**:

- `tests/unit/gameplay/main_scene_dash_gate_authored_visual_test.gd`
- `tests/unit/gameplay/exploration_dash_gate_runtime_test.gd`
- `tests/unit/gameplay/main_scene_visual_contract_test.gd`
- Headless main-scene smoke
- Godot MCP runtime evidence under
  `production/qa/evidence/dash-gate-authored-visual-replacement-2026-07-09.md`

**Status**: [x] RED/GREEN focused evidence, related regression, import,
headless smoke, and MCP runtime evidence complete.

- RED focused: `reports/report_1254/` failed as expected because
  `DashExplorationGate/Visual` still referenced the reused Rat King electric
  leak texture, the dedicated PNG did not exist, the old texture was `256x181`,
  and the visual still used rotation `1.5708` plus non-uniform scale.
- Godot import:
  `"/Applications/Godot 2.app/Contents/MacOS/Godot" --headless --path . --import --quit`
  exited `0` and imported the new runtime/source PNG files.
- GREEN focused: `reports/report_1255/` passed Story100 Dash gate visual
  replacement coverage `2/2`.
- Related regression: `reports/report_1256/` passed Dash gate runtime and main
  scene visual contract coverage `8/8`.
- Headless smoke:
  `reports/dash_gate_authored_visual_main_scene_smoke.log` exited `0`.
- Godot MCP evidence:
  `production/qa/evidence/dash-gate-authored-visual-replacement-2026-07-09.md`.

## Test-Criterion Traceability

| Criterion | Test / Evidence | Status |
|-----------|-----------------|--------|
| Dedicated Dash texture replaces electric-leak reuse | `report_1254`, `report_1255`, MCP probe | COVERED |
| Runtime PNG/import/size/rotation/scale contract | `report_1255`, asset manifest, MCP probe | COVERED |
| Story002 unlock/save behavior preserved | `report_1256` | COVERED |
| Image generation source/runtime paths documented | Asset manifest; QA evidence | COVERED |
| Runtime scene, current-run errors, and screenshot verified through MCP | Headless smoke; QA evidence | COVERED |

## Completion Notes

**Completed**: 2026-07-09
**Criteria**: 6/6 passing
**Deviations**: MCP `project_run` still reported retained old editor errors from
an earlier cache with `recent_errors_scope=retained_recent`, but
`current_run_errors=[]` for the Story100 run and runtime node/screenshot checks
passed.
**QA Evidence**:
`production/qa/evidence/dash-gate-authored-visual-replacement-2026-07-09.md`
