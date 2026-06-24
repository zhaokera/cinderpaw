# Story 006: HUD Scale + Colorblind Mode

> **Epic**: HUD/UI
> **Status**: Complete
> **Layer**: Presentation
> **Type**: UI
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-24

## Context

**GDD**: `design/gdd/hud-ui.md`
**Requirements**: `TR-hud-005`, `TR-hud-006`

## Acceptance Criteria

- [x] HUD scale applies to combat HUD and menu text without overlap.
- [x] Red-green mode uses blue-to-yellow HP mapping.
- [x] Blue-yellow mode uses red-to-white HP mapping.
- [x] Boss phase markers remain distinguishable without color.
- [x] Runtime screenshots cover default, 150% scale, and colorblind modes.

## Test Evidence

**Required evidence**: automated HUD assertions plus MCP screenshots.
**Status**: [x] `production/qa/evidence/hud-scale-colorblind-mode-2026-06-24.md`

## Implementation Notes

- `HUDManager` now exposes runtime-safe HUD scale, menu overlap, colorblind HP
  palette, boss phase marker, and settings-state handoff APIs.
- `MainScene` includes HUD accessibility settings in its no-loss state snapshot
  so a future SaveSystem can persist the values without reaching into
  Presentation.
- Godot MCP validated `res://scenes/main.tscn` with clean game/editor logs and
  captured default, 150% scale, settings, red-green, and blue-yellow runtime
  screenshots.

## Dependencies

- Depends on: Story 004 settings controls.
