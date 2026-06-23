# Story 002: HP Milestones + Boss Phase Gates

> **Epic**: Health & Death Detection
> **Status**: Complete
> **Layer**: Core
> **Type**: Logic
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-23

## Context

**GDD**: `design/gdd/health-death.md`
**Requirements**: `TR-health-004`, `TR-health-005`, `TR-health-011`, `TR-health-015`

**ADR Governing Implementation**: ADR-0001: Autoload architecture; ADR-0002: Signal communication
**Design Reference**: ADR-0019: HealthComponent deep architecture (Proposed)

## Acceptance Criteria

- [x] HP milestones 0.75, 0.50, 0.25, and 0.01 emit once per lifecycle.
- [x] Repeated crossings of an already-triggered milestone do not emit duplicates.
- [x] Boss phase thresholds use a while loop so large damage crossing multiple thresholds emits all phase changes in order.
- [x] Phase signals emit after HP/milestone signals and before terminal death.

## Out of Scope

- Focus mode, revive reset, and full death metadata.

## QA Test Cases

- **AC-1**: First milestone emit
- **AC-2**: Duplicate milestone suppression
- **AC-3**: Boss phase cross-jump emit order
- **AC-4**: Boss lethal hit emits phase before death

## Test Evidence

**Story Type**: Logic
**Required evidence**: `tests/unit/health/story_002_milestones_boss_phases_test.gd` — must exist and pass
**Status**: [x] Created and passing

**Evidence**:
- Red: Story 002 suite first failed because `HealthComponent` did not expose `on_hp_milestone` (`reports/report_99/`).
- Red: after adding milestone/phase signals, lethal low-HP Boss scenario exposed incorrect milestone triggering for thresholds already below the previous HP percentage (`reports/report_100/`).
- Green: Story 002 suite passed 4/4 (`reports/report_101/`).
- Health regression: full `tests/unit/health` passed 11/11 (`reports/report_102/`).
- Regression: full `tests/unit/input` passed 34/34 (`reports/report_103/`).
- Regression: full `tests/unit/data` passed 43/43 (`reports/report_104/`); expected negative schema/version tests emitted warnings/errors while passing.
- Regression: full `tests/unit/damage` passed 24/24 (`reports/report_105/`).
- Static checks: `godot --headless --path . --quit` passed; `git diff --check` passed; changed GDScript methods are under 50 lines.

**Completion Notes**:
- Added typed `on_hp_milestone(entity_id, threshold)` and `on_boss_phase_change(entity_id, phase, hp_percentage)` signals.
- Added lifecycle milestone tracking with previous-HP-percentage crossing semantics so already-below thresholds do not backfill.
- Added `configure_boss_phases()` and while-loop phase emission with 1-based phase numbers.
- Preserved required order: `on_hp_changed` → `on_hp_milestone` → `on_boss_phase_change` → `on_death`. Focus-mode ordering remains for Story 004.

## Dependencies

- Depends on: Story 001
- Unlocks: Story 005 Death Metadata + Zone Hooks
