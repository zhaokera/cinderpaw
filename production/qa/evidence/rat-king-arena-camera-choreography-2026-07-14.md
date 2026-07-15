# Rat King Arena Camera Choreography Evidence

- Story: Scene Management Story014
- Date: 2026-07-14
- Engine: Godot 4.7-stable (official)
- Godot AI MCP: plugin/server 2.9.2

## Runtime Result

Fresh Main retains the original `0/0/1280/720`, zoom `1.0` camera profile,
then applies Rat King limits `0/0/1120/720` and phase zooms `1.08`, `1.12`,
and `1.16`. Phase signals drive the update through MainScene's existing boss
transition path. Camera offset is never written by the choreography, preserving
CombatPresentation hit-shake ownership.

Rat King death restores the default bounds, zoom and smoothing during the
existing `victory_pending` hold. Echo Guardian remains hidden and inactive in
that hold; the bounded Story156 and Boss2 camera suites confirm it can own the
camera after the sequential handoff.

## Automated Evidence

- RED: `reports/report_1646/report_1/results.xml` - `1` case, `2` expected
  missing-API failures.
- Focused GREEN: `reports/report_1650/report_1/results.xml` - `1/1`.
- Related GREEN: `reports/report_1651/report_1/results.xml` - `12/12`.
- Smoke: `reports/rat_king_arena_camera_choreography_smoke.log` contains
  `rat_king_arena_camera_choreography_smoke=passed` and exits `0`.
- `git diff --check` exits `0` for the Story files.

GdUnit/headless shutdown retains the project's known Godot 4.7
ObjectDB/resource cleanup messages; accepted reports contain no test failures,
errors, skips, or orphans.

## MCP Evidence

MCP run `r23858246-29` launched Main with `autosave=false`.

- Phase 1: Rat King visible, Boss2 inactive, camera enabled with reason
  `rat_king_phase_1`, right limit `1120`, zoom `1.08`.
- Phase 3: camera reason `rat_king_phase_3`, zoom `1.16`; Rat King plays
  three-frame `phase_3_overload`; three arena mutation nodes are active.
- Defeat: Rat King plays three-frame `death`; camera reason becomes
  `rat_king_defeated`, right limit returns to `1280`, zoom returns to `1.0`;
  game flow is `victory_pending` and Boss2 camera remains disabled.
- Game log: `3` info-only lines; editor log: `0` lines.
- Stop result: `stopped=true`, readiness `ready`.

Screenshot:

- `reports/visual/cinderpaw-mcp-rat-king-arena-camera-phase3-20260714.png`
  (`1278x718`, SHA-256
  `72a2a9287b93ea3a62798e3b767ca6cca0d6b95656afd273fb72b5ad6b04df56`).

The screenshot is nonblank and visually inspected. It shows Cinderpaw and the
animated Rat King together in the tighter Phase III frame, with generated arena
debris and electric-hazard VFX visible and no placeholder blocks.

## Asset Pipeline

No new visual or audio asset was required. Story014 reuses the existing
image-generated Rat King frames, arena props, arena VFX, Main environment, and
HUD assets already tracked by the project pipeline.
