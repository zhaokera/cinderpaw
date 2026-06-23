# Story 003: Battle Summary Lesson Panel

> **Epic**: HUD/UI
> **Status**: Complete
> **Layer**: Presentation
> **Type**: UI
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-24

## Context

**GDD**: `design/gdd/hud-ui.md`, `design/gdd/death-respawn.md`
**Requirements**: `TR-hud-003`, `TR-respawn-004`, `TR-respawn-007`

## Acceptance Criteria

- [x] `show_battle_summary(summary)` opens a dedicated lesson panel.
- [x] Summary displays duration, damage dealt, damage taken, dodge rate, and
  parry rate.
- [x] Missing tips are generated from dodge/parry performance.
- [x] Panel offers `Skip Lesson` and `Retry Encounter` actions.
- [x] Death metadata can be handed from PlayerController to MainScene without
  making battle summary default-on.

## Test Evidence

**Required evidence**: `tests/unit/presentation/hud_manager_test.gd`
**Status**: [x] Created and passing

- TDD RED: `reports/report_300/` — failed on missing HUD battle-summary APIs.
- Story green: `reports/report_301/` — HUD focused suite 8/8 passing.
- Focused regression: `reports/report_302/` — presentation + gameplay suites
  15/15 passing.
- Runtime evidence:
  `production/qa/evidence/battle-summary-hud-2026-06-24.md`.

## Implementation Notes

- The GDD default for battle summary is off; MainScene keeps
  `BATTLE_SUMMARY_ENABLED` false until settings controls exist.
- HUDManager owns presentation and button labeling only. HealthComponent already
  owns death metadata and battle-stat collection.

## Dependencies

- Depends on: HealthComponent death metadata, PlayerController death signal.
- Unlocks: Story 004 battle-summary toggle in settings.
