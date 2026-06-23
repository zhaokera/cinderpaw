# Story 004: Focus Mode State + Signals

> **Epic**: Health & Death Detection
> **Status**: Complete
> **Layer**: Core
> **Type**: Integration
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-23

## Context

**GDD**: `design/gdd/health-death.md`
**Requirements**: `TR-health-006`, `TR-health-007`, `TR-health-008`, `TR-health-013`

**ADR Governing Implementation**: ADR-0001: Autoload architecture; ADR-0002: Signal communication; ADR-0006: AI behavior
**Design Reference**: ADR-0019: HealthComponent deep architecture (Proposed)

## Acceptance Criteria

- [x] Focus mode activates when player HP is <=25% and active enemy count is greater than 0.
- [x] Focus mode exits only when HP is >28% or active enemy count becomes 0.
- [x] `on_focus_mode_changed(true/false)` emits exactly on state transitions.
- [x] Revive resets focus mode and emits the false transition when needed.
- [x] Focus transition signal provides enough state for Presentation and AI listeners.

## Out of Scope

- Actual screen flash, audio playback, and enemy windup modification are Presentation/AI consumers.

## QA Test Cases

- **AC-1**: Combat-gated activation
- **AC-2**: Hysteresis boundary at exactly 28%
- **AC-3**: Exit after healing above 28%
- **AC-4**: Exit when active enemies become 0
- **AC-5**: Revive exits focus

## Test Evidence

**Story Type**: Integration
**Required evidence**: `tests/unit/health/story_004_focus_mode_signals_test.gd` — must exist and pass
**Status**: [x] Created and passing

- Red evidence: `reports/report_113/` — 7/7 failed on missing focus signal, player configure flag, active enemy count API, and focus query.
- Story green: `reports/report_114/` — Story 004 suite 7/7 passing.
- Health regression: `reports/report_115/` — full `tests/unit/health` 24/24 passing.
- Adjacent regressions: `reports/report_116/` input 34/34, `reports/report_117/` data 43/43, `reports/report_118/` damage 24/24.
- Static checks: `godot --headless --path . --quit`, `git diff --check`, method-length check, and trailing-whitespace check all passing.

## Implementation Notes

- `configure(..., focus_mode_enabled := true)` marks a HealthComponent as player-focus eligible; non-player components keep focus disabled by default.
- `set_active_enemy_count(count)` injects the combat-state gate without directly depending on AIComponent, preserving testability while AIComponent is not implemented yet.
- Focus activation uses HP <= 25% and active enemy count > 0.
- Focus exit uses HP > 28% or active enemy count == 0; exactly 28% remains active.
- `on_focus_mode_changed(entity_id, active, metadata)` emits only on state transitions. The metadata includes HP percentage, enemy count, thresholds, windup extension frames, Presentation cue ids/durations, tell-area/particle multipliers, reverb flag, and transition reason.
- The focus signal intentionally expands the GDD/ADR bool-only sketch to a three-parameter signal because this story requires enough state for Presentation and AI listeners, and ADR-0002 allows direct parameters for payloads with three fields or fewer.

## Dependencies

- Depends on: Story 001, Story 003
- Unlocks: Feline Combat focus crit-window integration
