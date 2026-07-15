# Story 014: Rat King Arena Camera Choreography

> **Epic**: Scene Management
> **Status**: Complete
> **Layer**: Feature / Presentation Boundary
> **Type**: Visual / Integration
> **Estimate**: S
> **Last Updated**: 2026-07-14

## Context

**GDD**: `design/gdd/boss-config.md`, `design/gdd/combat-presentation.md`,
`design/gdd/scene-management.md`

**Requirements**: `TR-boss-004`, `TR-scene-005`

**ADR Governing Implementation**: ADR-0007: Scene management architecture

Stories008-013 made the Rat King arena mutations functional, textured, and
persistent, while Player Abilities Story156 made the Rat King and Echo Guardian
encounters sequential. The remaining presentation gap is that the Rat King fight
uses the same wide camera framing as ordinary exploration. This story adds a
small phase-aware camera choreography layer without changing combat rules or the
Story156 handoff.

## Acceptance Criteria

- [x] A fresh Main scene applies a Rat King camera profile while Rat King is the
  active encounter, with deterministic diagnostics and the original camera state
  retained for release.
- [x] Rat King phases 1, 2, and 3 use progressively tighter zoom profiles while
  preserving camera smoothing and CombatPresentation ownership of camera offset.
- [x] Rat King phase transition signals refresh the camera profile without a new
  manager, timer, or duplicate signal path.
- [x] Rat King defeat releases its camera profile to the default Main framing
  during `victory_pending`; Echo Guardian remains inactive during that hold.
- [x] The existing Story156 handoff can subsequently apply the Boss2 camera lock
  without Rat King camera state overwriting it.
- [x] Focused GdUnit, bounded Rat King/Boss2 regressions, one headless smoke, and
  Godot MCP runtime logs/diagnostics/screenshot pass.

## Implementation Notes

- Keep MainScene as camera-profile owner because it already owns Rat King arena
  mutations and the Boss2 camera lock.
- Reuse the existing `Player/Camera2D` and existing image-generated arena assets;
  this story requires no new visual asset generation.
- Keep `Camera2D.offset` untouched so hit shake remains owned by
  CombatPresentation.

## Out of Scope

- New arena textures, shaders, particles, character frames, or audio.
- Rat King damage, attacks, phase thresholds, rewards, or mutation behavior.
- Echo Guardian camera profile tuning beyond compatibility with Story156.
- Cinematic bars, cutscenes, or a reusable global camera director.

## Test Evidence

**Status**: Complete

- RED: `reports/report_1646/report_1/results.xml`, `1` case with `2` expected
  missing-API failures.
- Focused GREEN: `reports/report_1650/report_1/results.xml`, `1/1` passing.
- Related GREEN: `reports/report_1651/report_1/results.xml`, `12/12` passing
  across Rat King phase/runtime, victory hold, Story156 handoff, and Boss2 camera
  ownership.
- Headless smoke:
  `tests/smoke/rat_king_arena_camera_choreography_smoke.gd` exited `0` with
  phase zooms `1.08 -> 1.12 -> 1.16` and default release `1.0`.
- Godot MCP run `r23858246-29`: Phase 1 and Phase 3 diagnostics, three-frame
  `phase_3_overload`, three active arena mutations, death release, Story156
  victory hold, clean game/editor logs, and a nonblank `1278x718` screenshot.
- QA evidence:
  `production/qa/evidence/rat-king-arena-camera-choreography-2026-07-14.md`.

## Completion Notes

MainScene now retains one shared default arena-camera snapshot for Rat King and
Echo Guardian. Rat King applies phase-aware camera limits and zoom without
changing camera offset; its profile releases on defeat, while an active Boss2
profile has explicit priority. No new asset was generated because the slice
reuses the existing image-generated Rat King and arena mutation presentation.
