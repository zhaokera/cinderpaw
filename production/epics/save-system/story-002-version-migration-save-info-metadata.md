# Story 002: Version Migration + SaveInfo Metadata

> **Epic**: Save System
> **Status**: Complete
> **Layer**: Feature
> **Type**: Logic
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-24

## Context

**GDD**: `design/gdd/save-system.md`
**Requirements**: `TR-save-002`, `TR-save-005`
*(Requirement text lives in `docs/architecture/tr-registry.yaml` — read fresh at review time)*

**ADR Governing Implementation**: ADR-0021: Save system architecture
**ADR Decision Summary**: SaveSystem exposes per-slot SaveInfo metadata for
HUD/UI without leaking file rules, and runs a chained migration pipeline from
older save versions to `CURRENT_SAVE_VERSION` before deserializing systems.

**Engine**: Godot 4.6.3 | **Risk**: MEDIUM
**Engine Notes**: FileAccess/JSON APIs are stable; `FileAccess.get_length()`
must be verified on target platforms before relying on byte size in shipping UI.

**Control Manifest Rules (Feature layer)**:
- Required: Feature systems use adapter boundaries and stay testable without
  full scene loading.
- Forbidden: Do not synchronously switch scenes from SaveSystem; SceneManager
  owns scene transitions.
- Guardrail: Save metadata reads must stay small and avoid gameplay stalls.

---

## Acceptance Criteria

- [x] `get_save_info(slot)` returns an empty `SaveInfo` object for missing slots
  and a populated `SaveInfo` object for valid saves.
- [x] SaveInfo includes slot number, autosave flag, timestamp, play time,
  save-point name, version, UI summary data, and file size in bytes.
- [x] Older save versions run through registered migration callbacks before
  registered systems deserialize.
- [x] Missing migration callbacks and future save versions fail cleanly without
  overwriting `last_loaded_data`.

---

## Implementation Notes

- Implement `src/feature/save_info.gd` as `class_name SaveInfo` extending
  `RefCounted`.
- Add `get_save_info(slot: int) -> RefCounted` to `src/feature/save_system.gd`;
  the returned object is instantiated from `SaveInfo`. The public return type is
  intentionally conservative because Godot can compile Autoload scripts before
  resolving newly added `class_name` symbols in headless test runs.
- Store UI summary data under `_meta.summary`; build a conservative summary
  from player state when explicit summary data is absent.
- Add migration registration APIs that tests and future systems can use without
  changing `CURRENT_SAVE_VERSION`.
- Preserve the Story 001 API surface and keep manual slot 0 protection.
- Do not implement HUD menu rendering, async threaded writes, autosave trigger
  adapters, SceneManager load handoff, thumbnails, or cloud/encrypted saves in
  this story.

---

## Out of Scope

- Story 003: savepoint, boss-defeat, key-event, and scene-change autosave
  adapters.
- Story 004: MainScene runtime snapshot registration and load handoff.
- HUD/UI Story 005: menu presentation of save/load shell.
- Death & Respawn Story 004: savepoint respawn selection.
- Threaded async write implementation and screenshot thumbnails.

---

## QA Test Cases

- **AC-1**: `get_save_info(slot)` returns empty or populated SaveInfo.
  - Given: SaveSystem configured to a clean test directory.
  - When: `get_save_info(1)` is called before a save exists.
  - Then: it returns slot 1, `exists=false`, `is_auto=false`.
  - When: slot 1 is saved and `get_save_info(1)` is called again.
  - Then: it returns `exists=true` with metadata read from the JSON file.
  - Edge cases: slot 0 reports `is_auto=true`; invalid slot returns
    `exists=false`.

- **AC-2**: SaveInfo exposes UI metadata.
  - Given: a save with player state values useful for UI summary.
  - When: `get_save_info(slot)` is called.
  - Then: timestamp, play time, save-point name, version, summary, and file size
    are populated.
  - Edge cases: empty player state still returns an empty summary dictionary.

- **AC-3**: Older saves migrate before system deserialize.
  - Given: a version 0 save file and migration callback `0 -> 1`.
  - When: `load_game(1)` runs.
  - Then: migration callback mutates the data, deserialization sees migrated
    system payload, and the original version is passed to the registered system.
  - Edge cases: migrated file is written back with current version.

- **AC-4**: Migration failures fail cleanly.
  - Given: an older save with no registered migration.
  - When: `load_game(1)` runs.
  - Then: it returns false and `last_loaded_data` remains empty.
  - Given: a future-version save.
  - When: `load_game(1)` runs.
  - Then: it returns false and does not use the save.

---

## Test Evidence

**Story Type**: Logic
**Required evidence**:
- `tests/unit/save/story_002_version_migration_save_info_metadata_test.gd`
  must exist and pass.
- Focused SaveSystem regression must include Story 001 and Story 002 suites.
- Godot MCP should verify `SaveSystem.get_save_info()` and migration behavior at
  runtime.

**Status**: [x] Complete

**RED evidence**:
- Command:
  `godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/save/story_002_version_migration_save_info_metadata_test.gd --ignoreHeadlessMode`
- Result: Exit 100 as expected. The suite failed on missing `get_save_info()`,
  missing `register_migration()`, and version 0 saves loading without a
  migration callback.

**GREEN evidence**:
- Command:
  `godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/save/story_002_version_migration_save_info_metadata_test.gd --ignoreHeadlessMode`
- Result: 3/3 tests passing, 0 errors, 0 failures.

**Focused regression**:
- Command:
  `godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/save/story_001_save_slots_backup_json_pipeline_test.gd -a res://tests/unit/save/story_002_version_migration_save_info_metadata_test.gd -a res://tests/unit/input/story_001_action_abstraction_test.gd --ignoreHeadlessMode`
- Result: 12/12 tests passing, 0 errors, 0 failures.

**Runtime smoke**:
- Command:
  `godot --headless --path . --scene res://scenes/main.tscn --fixed-fps 60 --quit-after 180 --log-file reports/save_story002_main_scene_smoke.log`
- Result: Exit 0; log scan found no `ERROR`, `WARNING`, `SCRIPT ERROR`,
  `Parse Error`, `Invalid access`, `Invalid call`, `Failed`, or `Cannot`.

**Godot MCP evidence**:
- MCP `settings_get` confirmed `autoload/SaveSystem` points to
  `*res://src/feature/save_system.gd`.
- MCP reimported `save_system.gd`, `save_info.gd`, and the Story 002 test.
- MCP opened and ran `res://scenes/main.tscn`.
- Runtime `game_eval` wrote manual and autosave metadata, registered a version
  `0 -> 1` migration, loaded an old slot, and observed:
  `manual_ok=true`, `info_exists=true`, `info_slot=1`, `info_is_auto=false`,
  `info_hp=55`, `info_file_size_positive=true`, `auto_is_auto=true`,
  `migration_ok=true`, `loaded=true`, `loaded_version=1`,
  `migrated_focus=false`, `migrated_energy=31`.
- MCP game log contained only the helper registration line; editor log contained
  0 errors.

---

## Dependencies

- Depends on: Save System Story 001 must be Complete.
- Unlocks: Save System Story 003, Save System Story 004, HUD/UI Story 005.
