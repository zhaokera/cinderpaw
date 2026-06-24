# Story 004: Settings + Accessibility Controls

> **Epic**: HUD/UI
> **Status**: Complete
> **Layer**: Presentation
> **Type**: UI
> **Estimate**: L
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-24

## Context

**GDD**: `design/gdd/hud-ui.md`
**Requirements**: `TR-hud-003`, `TR-hud-005`, `TR-hud-006`

## Acceptance Criteria

- [x] Settings menu exposes audio, display, controls, and gameplay groups.
- [x] Battle-summary and damage-number toggles update runtime HUD behavior.
- [x] HUD scale accepts 50%-150% and keeps core HUD elements non-overlapping.
- [x] Colorblind mode changes HP color palette without changing HP values.
- [x] Menu focus returns to the invoking menu after close.

## Test Evidence

**Required evidence**: HUD interaction tests plus runtime screenshot evidence.
**Status**: [x] `production/qa/evidence/settings-accessibility-controls-2026-06-24.md`

## Dependencies

- Depends on: Story 002 pause menu.
- Unlocks: Story 006 HUD scale/colorblind validation and death summary default
  toggle.
