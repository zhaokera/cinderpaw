# Story 003: I-Frames + Healing + Revive

> **Epic**: Health & Death Detection
> **Status**: Complete
> **Layer**: Core
> **Type**: Logic
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-23

## Context

**GDD**: `design/gdd/health-death.md`
**Requirements**: `TR-health-009`, `TR-health-013`

**ADR Governing Implementation**: ADR-0001: Autoload architecture; ADR-0002: Signal communication
**Design Reference**: ADR-0019: HealthComponent deep architecture (Proposed)

## Acceptance Criteria

- [x] `grant_iframes(frames)` uses max-take and never stacks frame counts.
- [x] Damage while i-frames are active is ignored without HP or signal changes.
- [x] Healing clamps to max HP.
- [x] Save-point recovery restores HP and shield to max values.
- [x] `revive()` restores at least 1 HP and returns state to ALIVE.

## Out of Scope

- Focus-mode reset is implemented in Story 004.

## QA Test Cases

- **AC-1**: I-frame max-take
- **AC-2**: I-frame damage immunity
- **AC-3**: Healing clamp
- **AC-4**: Save-point full restore
- **AC-5**: Revive HP floor

## Test Evidence

**Story Type**: Logic
**Required evidence**: `tests/unit/health/story_003_iframes_healing_revive_test.gd` — must exist and pass
**Status**: [x] Created and passing

- Red evidence: `reports/report_106/` — 6/6 failed on missing i-frame/heal/savepoint/revive APIs.
- Story green: `reports/report_107/` — Story 003 suite 6/6 passing.
- Health regression: `reports/report_108/` — full `tests/unit/health` 17/17 passing.
- Adjacent regressions: `reports/report_110/` input 34/34, `reports/report_111/` data 43/43, `reports/report_112/` damage 24/24.
- Static checks: `godot --headless --path . --quit`, `git diff --check`, method-length check, and trailing-whitespace check all passing.

## Implementation Notes

- `grant_iframes(frames)` uses `max(current, frames)` and ignores non-positive grants.
- `apply_damage()` ignores all damage while i-frames are active, without shield, HP, milestone, phase, or death signal changes.
- `heal(amount)` clamps to max HP and emits `on_hp_changed` only when HP changes.
- `restore_at_savepoint()` refills HP and shield to max values and returns the component to ALIVE when HP is positive.
- `revive(revive_hp_percentage := 0.5)` restores `max(1, floor(max_hp * percentage))`, refills shield, resets per-life milestone and boss phase gates, clears i-frames, and returns state to ALIVE.
- `TR-health-013` focus-mode reset is explicitly deferred to Story 004 because this story declares focus-mode reset out of scope and no focus state/signal exists yet.

## Dependencies

- Depends on: Story 001
- Unlocks: Story 004 Focus Mode State + Signals
