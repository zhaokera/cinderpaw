# Story 005: Battle Summary Handoff

> **Epic**: Death & Respawn
> **Status**: Complete
> **Layer**: Feature
> **Type**: Integration
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-24

## Context

**GDD**: `design/gdd/death-respawn.md`, `design/gdd/hud-ui.md`
**Requirements**: `TR-respawn-004`, `TR-respawn-007`, `TR-hud-003`

## Acceptance Criteria

- [x] HealthComponent emits death metadata with battle stats.
- [x] PlayerController forwards death metadata without mutation.
- [x] MainScene can convert death metadata into HUD battle-summary input.
- [x] Battle summary remains default-off until settings controls exist.

## Test Evidence

**Required evidence**: Health death metadata tests and HUD battle-summary tests.
**Status**: [x] Created and passing

- Existing health metadata evidence:
  `tests/unit/health/story_005_death_metadata_zone_hooks_test.gd`.
- HUD TDD RED: `reports/report_300/`.
- HUD Story green: `reports/report_301/` — 8/8 passing.
- Focused regression: `reports/report_302/` — presentation + gameplay suites
  15/15 passing.
- Runtime evidence:
  `production/qa/evidence/battle-summary-hud-2026-06-24.md`.

## Dependencies

- Depends on: Health & Death Detection Story 005, HUD/UI Story 003.
- Unlocks: settings-controlled death lesson display.
