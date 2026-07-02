# Story 002: Weapon Upgrade State + Serialization Prep

> **Epic**: Weapon Styles
> **Status**: Complete
> **Layer**: Core
> **Type**: Logic
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-23

## Context

**GDD**: `design/gdd/weapon-styles.md`
**Requirement**: `TR-weapon-004`

**ADR Governing Implementation**: ADR-0016: Weapon styles architecture
**ADR Decision Summary**: WeaponComponent owns per-weapon level indexes,
upgrade bounds, next-level preview queries, and a small serialize/deserialize
payload for future SaveSystem integration.

**Engine**: Godot 4.7 | **Risk**: LOW
**Engine Notes**: Pure GDScript dictionaries; no engine-specific API risk.

**Control Manifest Rules (Core)**:
- Required: Component APIs must be testable without full scenes.
- Forbidden: Do not write save files from Core components.

## Acceptance Criteria

- [x] Each weapon starts at level 1.
- [x] `upgrade_weapon()` increments one weapon until level 5, then returns false.
- [x] `get_next_level_damage()` previews the next configured damage value.
- [x] `serialize()` includes current weapon index and weapon levels.
- [x] `deserialize()` restores current weapon and levels defensively.

## Implementation Notes

Keep actual save-slot ownership out of scope. This story only prepares the
ISerializable-compatible payload.

## Out of Scope

- Story 003: swap timing.
- Feature-layer SaveSystem registration.

## QA Test Cases

- **AC-1**: Upgrade cap.
  - Given: a new WeaponComponent.
  - When: Cat Claw is upgraded repeatedly.
  - Then: it stops at level 5 and reports base damage 18.

- **AC-2**: Serialization.
  - Given: weapon levels and current weapon changed.
  - When: data is serialized then restored into a fresh component.
  - Then: the new component returns the same weapon and levels.

## Test Evidence

**Story Type**: Logic
**Required evidence**:
- Logic: `tests/unit/weapon/story_002_weapon_upgrade_serialization_test.gd`.

**Status**: [x] Created and passing

## Test-Criterion Traceability

| Criterion | Test | Status |
|-----------|------|--------|
| AC-1: Default levels and next damage preview | `tests/unit/weapon/story_002_weapon_upgrade_serialization_test.gd::test_all_weapons_start_at_level_one_with_next_damage_preview` | COVERED |
| AC-2: Upgrade to level 5 and signal emission | `tests/unit/weapon/story_002_weapon_upgrade_serialization_test.gd::test_upgrade_weapon_increments_until_level_five_and_emits_signal` | COVERED |
| AC-3: Invalid upgrades rejected | `tests/unit/weapon/story_002_weapon_upgrade_serialization_test.gd::test_invalid_upgrade_requests_are_rejected_without_state_change` | COVERED |
| AC-4: Serialize/deserialize restores state | `tests/unit/weapon/story_002_weapon_upgrade_serialization_test.gd::test_serialize_and_deserialize_restore_current_weapon_and_levels` | COVERED |
| AC-5: Deserialize clamps invalid data | `tests/unit/weapon/story_002_weapon_upgrade_serialization_test.gd::test_deserialize_clamps_invalid_indices_and_ignores_unknown_weapons` | COVERED |

## Dependencies

- Depends on: Story 001.
- Unlocks: Story 003.

## Completion Notes

**Completed**: 2026-06-23
**Criteria**: 5/5 passing
**Deviations**: None. Story scope prepares SaveSystem-compatible payloads but
does not register with SaveSystem or write save files.

**Implementation**:
- Extended `src/core/weapon_component.gd` with `upgrade_weapon()`,
  `get_next_level_damage()`, `serialize()`, and `deserialize()`.
- Upgrade state remains zero-based internally while signals report player-facing
  level numbers 2 through 5.
- Deserialization clamps invalid current weapon indexes and weapon levels, ignores
  unknown weapon ids, and avoids implicit `int(null)` conversion.

**Test Evidence**:
- RED: `reports/report_279/` failed because Story002 upgrade/serialization APIs
  did not exist.
- GREEN: `reports/report_281/` Story002 suite 5/5 passing.
- Weapon suite: `reports/report_282/` 10/10 passing.
- Regression: `reports/report_283/` full `tests/unit` suite 289/289 passing.

**Runtime Evidence**:
- `reports/weapon_story002_project_boot.log`
- `reports/weapon_story002_main_scene_smoke.log`
- Both commands exited 0 and logs show `[godot_ai game_helper] registered mcp capture`
  with no `ERROR`, `SCRIPT ERROR`, `Invalid call`, `Parse Error`, or `WARNING`
  matches.
- No direct Godot MCP run/screenshot tool is exposed in this Codex session, so
  validation used Godot CLI/headless fallback after confirming MCP capture registration.

**Static Evidence**:
- `git diff --check` passed.
- Related source, data, schema, tests, and Story/Epic docs have no trailing whitespace.
- Related source and tests have no lines over 100 characters.

**Code Review**: Complete locally. Reviewed against AGENTS.md, ADR-0016,
Control Manifest Core rules, TR-weapon-004, and Story002 acceptance criteria.
Full specialist sub-agent gates were not spawned because the active Codex
multi-agent tool policy requires an explicit user request for delegation.
