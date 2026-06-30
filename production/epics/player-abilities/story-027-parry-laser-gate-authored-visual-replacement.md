# Story 027: Parry Laser Gate Authored Visual Replacement

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Core / Feature / Gameplay Runtime / Presentation Integration
> **Type**: Integration + Visual
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-30

## Context

**GDD**: `design/gdd/player-abilities.md`,
`design/gdd/exploration-ability-gating.md`, `design/gdd/feline-combat.md`

**Requirements**: `TR-ability-003`, `TR-ability-004`, `TR-ability-005`,
`TR-explore-001`, `TR-explore-002`, `TR-explore-006`,
`TR-combat-004`

**ADR Governing Implementation**: ADR-0005 Combat state machine; ADR-0018
Player abilities; ADR-0007 Scene management; ADR-0021 Save system.

Story019 made the Parry Laser gate playable but explicitly left final gate art
out of scope and reused the Rat King electric-leak texture as a replaceable
baseline. This story replaces that player-visible placeholder with a dedicated
image-generated Parry Laser gate marker while preserving the existing parry,
unlock, collision, and save-state behavior.

## Acceptance Criteria

- [x] `ParryLaserExplorationGate/Visual` in `scenes/main.tscn` uses a dedicated
  texture under `assets/environment/parry_laser_gate/` and no longer references
  `assets/environment/rat_king_arena/electric_leak.png`.
- [x] The Parry Laser gate visual is a transparent 256x256 PNG, imported through
  Godot with a `.import` sidecar, and does not require the old 90-degree
  rotation used by the reused electric-leak asset.
- [x] Existing Story019 runtime behavior remains intact: the gate starts
  `unlockable`, blocks collision before use, unlocks when Cinderpaw parries in
  range, and persists its gate/world flags into the save snapshot.
- [x] The image generation prompt, source PNG, runtime PNG, import status, and
  usage are recorded in asset manifest and QA evidence.
- [x] Godot MCP verifies `res://scenes/main.tscn` runs, the Parry Laser gate
  visual uses the new texture, Player `parry` still has three frames, logs are
  clean, and a nonblank screenshot shows the authored gate in the runtime scene.

## Out of Scope

- Full Central Tower scene, minimap/fast-travel updates, route prerequisite
  chains, and new route content beyond the existing gate.
- Reworking Dash gate art, Boss2 arena art, boss doors, camera scripting, and
  broader main-scene background polish.
- New Parry SFX/VFX or combat parry balance changes; this story only replaces
  the visible gate marker art.

## Implementation Notes

- Keep `ExplorationGate` behavior unchanged. This is a scene/resource wiring and
  asset-pipeline story.
- The runtime texture path is
  `res://assets/environment/parry_laser_gate/parry_laser_gate_marker.png`.
- Source prompt metadata is stored at
  `assets/generated/source/parry_laser_gate_marker_imagegen_20260630.json`.

## Test Evidence

**Required evidence**:

- `tests/unit/gameplay/player_parry_laser_gate_runtime_test.gd`
- `tests/unit/gameplay/main_scene_visual_contract_test.gd`
- Headless main-scene smoke
- Godot MCP runtime evidence under
  `production/qa/evidence/parry-laser-gate-authored-visual-replacement-2026-06-30.md`

**Status**: [x] RED/GREEN focused evidence, related regression, import, headless
smoke, and MCP runtime evidence complete.

- RED focused: `reports/report_827/` failed as expected because
  `ParryLaserExplorationGate/Visual` still referenced the reused Rat King
  electric-leak texture, the new PNG/import did not exist, the old texture was
  `256x181`, and the visual was still rotated `1.5708`.
- Godot import: `/opt/homebrew/bin/godot --headless --path . --import --quit`
  exited `0` and imported the new runtime/source PNG files.
- GREEN focused: `reports/report_828/` passed Story019/027 Parry Laser gate
  runtime and visual asset coverage `5/5`.
- Related regression: `reports/report_829/` passed Parry Laser gate and main
  scene visual contract coverage `9/9`.
- Headless smoke:
  `reports/parry_laser_gate_authored_visual_replacement_main_scene_smoke.log`.
- Godot MCP evidence:
  `production/qa/evidence/parry-laser-gate-authored-visual-replacement-2026-06-30.md`.
- MCP runtime screenshot:
  `reports/visual/cinderpaw-mcp-parry-laser-gate-authored-visual-replacement-20260630.png`.

## Test-Criterion Traceability

| Criterion | Test / Evidence | Status |
|-----------|-----------------|--------|
| Dedicated Parry Laser texture replaces electric-leak reuse | `report_827`, `report_828`, MCP probe | COVERED |
| Runtime PNG/import/size/rotation contract | `report_828`, asset manifest, MCP probe | COVERED |
| Story019 unlock/save behavior preserved | `report_828` | COVERED |
| Image generation source/runtime paths documented | Asset manifest; QA evidence | COVERED |
| Runtime scene, logs, and screenshot verified through MCP | Headless smoke; QA evidence | COVERED |

## Completion Notes

**Completed**: 2026-06-30
**Criteria**: 5/5 passing
**Deviations**: None.
**QA Evidence**:
`production/qa/evidence/parry-laser-gate-authored-visual-replacement-2026-06-30.md`
