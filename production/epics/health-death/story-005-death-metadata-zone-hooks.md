# Story 005: Death Metadata + Zone Hooks

> **Epic**: Health & Death Detection
> **Status**: Complete
> **Layer**: Core
> **Type**: Integration
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-23

## Context

**GDD**: `design/gdd/health-death.md`
**Requirements**: `TR-health-010`, `TR-health-015`

**ADR Governing Implementation**: ADR-0001: Autoload architecture; ADR-0002: Signal communication
**Design Reference**: ADR-0019: HealthComponent deep architecture (Proposed)

## Acceptance Criteria

- [x] `on_death` metadata contains `last_hit`, `battle_stats`, and `context` sections.
- [x] Missing CombatComponent or battle stats degrade to empty safe defaults.
- [x] `on_death_in_zone(entity_id, zone_id)` emits on death when a zone id is configured.
- [x] Metadata is duplicated before emission so callers cannot mutate internal state.

## Out of Scope

- Death/respawn flow, UI lesson display, and save penalties.

## QA Test Cases

- **AC-1**: Full metadata shape
- **AC-2**: Safe missing CombatComponent defaults
- **AC-3**: Zone death signal
- **AC-4**: Metadata immutability

## Test Evidence

**Story Type**: Integration
**Required evidence**: `tests/unit/health/story_005_death_metadata_zone_hooks_test.gd` — must exist and pass
**Status**: [x] Created and passing

**Evidence**:
- Red: `reports/report_119/` — failed on missing `set_current_zone_id()` and missing structured death metadata.
- Green Story 005: `reports/report_120/` — 4/4 passing.
- Full health: `reports/report_121/` — 28/28 passing.
- Input regression: `reports/report_122/` — 34/34 passing.
- Data regression: `reports/report_123/` — 43/43 passing.
- Damage regression: `reports/report_124/` — 24/24 passing.
- Static: `godot --headless --path . --quit`, `git diff --check`, method-length quick check, and trailing-whitespace scan passed.

## Implementation Notes

- `on_death` now emits structured metadata with `last_hit`, `battle_stats`, and `context`, while preserving a top-level `source` compatibility value for existing Story 001 consumers.
- `set_current_zone_id(zone_id)` configures the exploration/narrative zone used by death metadata and `on_death_in_zone(entity_id, zone_id)`.
- `observe_damage_dealt(amount)` lets CombatComponent report outbound damage without creating a reverse dependency from HealthComponent to combat implementation details.
- Missing `CombatComponent`, missing `get_battle_stats()`, or sparse battle stats return safe zero/empty defaults.
- `on_death_in_zone` emits before terminal `on_death` so the existing `apply_damage` order still ends with `on_death`.
- Combat battle stats are deep-copied before emission to prevent listeners from mutating provider-owned nested dictionaries.

## Dependencies

- Depends on: Story 001, Story 002
- Unlocks: Death & Respawn system
