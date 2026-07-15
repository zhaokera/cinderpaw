# Story 152: Main Scene Local Minimap Discovery Runtime

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Feature / Presentation / Exploration / Save Integration
> **Type**: Integration + UI + Player Feedback
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-14

## Context

**GDD**: `design/gdd/hud-ui.md`,
`design/gdd/exploration-ability-gating.md`, `design/gdd/scene-management.md`

**Requirements**: `TR-hud-001`, `TR-hud-002`, `TR-hud-004`,
`TR-explore-004`, `TR-explore-006`

**ADR Governing Implementation**: ADR-0001 Autoload architecture; ADR-0002
signal communication; ADR-0007 scene management; ADR-0008 save serialization;
ADR-0011 UI focus management; ADR-0013 pixel-art rendering; ADR-0015
accessibility; ADR-0021 save system.

Story151 completed the first four weapon T1-A Build choices. The highest-value
bounded player-visible gap is now the HUD minimap slot already required by the
GDD but absent from runtime. This slice adds a schematic local route map to
`main`: it shows the current hub route and player position, keeps destination
regions visibly locked, and turns the existing ExplorationGate unlock event
into the designed one-second gray-to-color discovery feedback plus a concise
notification. Existing gate/world flags remain the source of truth so save
restoration does not add another persistence owner.

## Acceptance Criteria

- [x] `HUDManager` mounts one stable `120x120` minimap panel below the top-right
  currency panel, and HUD scale `0.5-1.5` keeps it inside the viewport without
  overlapping the other core HUD panels.
- [x] The map is a code-drawn industrial route schematic using the established
  HUD palette. Discovered regions are filled, locked regions are hollow, the
  current region and player use distinct shapes, so state is not color-only.
- [x] Main configures `main`, `area_02_sewer`, `area_03_factory` and
  `area_05_central_tower` route nodes. `main` starts discovered/current while
  the three destinations derive discovery from existing world flags.
- [x] The player marker tracks and clamps normalized horizontal position within
  Main's `1280x720` authored bounds without changing gameplay or camera state.
- [x] Unlocking a Main ExplorationGate reveals its `target_area_id` over exactly
  `1.0s`, keeps the destination discovered afterward, and shows one
  `<Area Name> discovered` notification.
- [x] Existing gate audio, collision removal, unlock VFX and world flags remain
  unchanged; duplicate unlock/state sync does not replay discovery animation or
  notification.
- [x] Save/no-loss restoration uses existing `world_flags` and immediately
  restores discovered regions at full progress without adding a new save
  schema, duplicate map state or replay feedback.
- [x] Focused GdUnit, bounded HUD/gate/save regression, target smoke and Godot
  MCP verify the panel node, positions, reveal timing, persisted state,
  non-empty gameplay capture and clean logs.

## Out of Scope

- A full-screen world map, zoom/pan, room geometry, fog-of-war, completion
  percentage, secret-room icons, shortcut connection authoring or fast travel.
- Minimap integration in every Factory/Underground/Rooftop/Tower scene; this is
  the reusable Main-scene baseline and GDD discovery event proof.
- New map bitmap, minimap icon atlas, audio, character frames or image-generated
  art. The schematic is functional code-native UI inside the existing styled
  HUD panel, so no external visual asset is introduced in this slice.
- T1-B/T2-T5 skills, Boss5 identity, ending, credits, dialogue or quest systems.

## Implementation Notes

- Add a focused Presentation widget rather than storing discovery state in
  `HUDManager`. HUD owns layout/delegation; Main owns mapping from world flags
  and gate signals; ExplorationGate remains unchanged.
- Region definitions use normalized coordinates and explicit connections.
  Rendering uses filled versus hollow nodes plus a diamond/triangle marker so
  colorblind modes retain shape semantics.
- Run the reveal timer through the HUD's existing deterministic
  `advance_time()` path. Do not create a second process loop or Tween owner.
- Main updates marker position from its existing `_process()` and synchronizes
  discovery after initial setup and save restoration.

## Test Evidence

**Required evidence**:

- `tests/unit/gameplay/main_scene_minimap_discovery_runtime_test.gd`
- Existing `tests/unit/presentation/hud_manager_test.gd`, ExplorationGate Main
  runtime tests and SaveSystem/Main snapshot regression
- `tests/smoke/main_scene_minimap_discovery_runtime_smoke.gd`
- Godot MCP evidence under
  `production/qa/evidence/main-scene-local-minimap-discovery-2026-07-14.md`

**Status**: [x] Complete. RED `report_1592`; focused GREEN `report_1595`
`2/2`; bounded related GREEN `report_1596` `45/45`; target smoke passed;
Godot MCP `2.9.2` / Godot `4.7-stable` run `r12582583-12` verified the live
panel, route states, exact reveal timing, persistence, duplicate suppression,
clean logs and non-empty gameplay capture.
