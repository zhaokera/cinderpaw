# Story 001: Save Slots + Backup JSON Pipeline

> **Epic**: Save System
> **Status**: Complete
> **Layer**: Feature
> **Type**: Integration
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-24

## Context

**GDD**: `design/gdd/save-system.md`
**Requirements**: `TR-save-001`, `TR-save-002`, `TR-save-003`, `TR-save-004`
*(Requirement text lives in `docs/architecture/tr-registry.yaml` — read fresh at review time)*

**ADR Governing Implementation**: ADR-0021: Save system architecture
**ADR Decision Summary**: SaveSystem owns slot layout, JSON structure, backup
fallback, and ISerializable registration order while gameplay systems expose
their own JSON-safe payloads.

**Engine**: Godot 4.6.3 | **Risk**: MEDIUM
**Engine Notes**: FileAccess/JSON APIs are stable; Godot 4.4 changed
`FileAccess.store_string()` return handling, so writes must explicitly validate
the file after close.

**Control Manifest Rules (Feature layer)**:
- Required: Feature systems use adapter boundaries and do not put gameplay logic
  into Foundation services.
- Forbidden: Do not switch scenes synchronously from SaveSystem; SceneManager
  owns scene transitions.
- Guardrail: Save operations must respect the 100ms no-stall budget where
  possible; this story implements synchronous testable file I/O only, leaving
  async dispatch to a later story.

---

## Acceptance Criteria

- [x] SaveSystem writes JSON save files under a configurable saves directory and
  protects autosave slot 0 from manual saves.
- [x] Save data includes `_meta`, `player_state`, `world_state`, `settings`, and
  registered `systems` payloads.
- [x] Registered serializable systems are serialized and deserialized in
  deterministic order by save key.
- [x] Saving over an existing slot creates a `.bak`, and loading a corrupt main
  file falls back to a valid backup.

---

## Implementation Notes

- Implement `src/feature/save_system.gd` as a Godot node that can be used as an
  Autoload and instantiated directly in GdUnit.
- Keep file paths injectable for tests; production default remains
  `user://saves/`.
- Expose `manual_save(slot, player_state, world_state, settings)` and
  `auto_save(player_state, world_state, settings)` so UI can avoid manual writes
  to slot 0.
- Expose `load_game(slot) -> bool`, `has_save(slot) -> bool`,
  `get_last_loaded_data() -> Dictionary`, and registration APIs.
- Do not implement SceneManager restoration, migrations, thumbnails, async
  Thread writes, or savepoint trigger nodes in this story.

---

## Out of Scope

- Story 002: version migration and richer SaveInfo metadata.
- Story 003: savepoint, boss-defeat, key-event, and scene-change autosave
  adapters.
- Story 004: MainScene runtime snapshot registration and load handoff.
- HUD/UI Story 005: menu presentation of save/load shell.
- Death & Respawn Story 004: savepoint respawn selection.

---

## QA Test Cases

- **AC-1**: SaveSystem writes JSON save files under a configurable saves
  directory and protects autosave slot 0 from manual saves.
  - Given: SaveSystem configured to a test `user://` directory.
  - When: `manual_save(0, ...)` is called.
  - Then: It returns false and no slot 0 file is written.
  - When: `auto_save(...)` is called.
  - Then: `slot_0.json` exists and contains valid JSON.
  - Edge cases: invalid negative slots and slots above 3 return false.

- **AC-2**: Save data includes `_meta`, `player_state`, `world_state`,
  `settings`, and registered `systems` payloads.
  - Given: one mock serializable system registered as `weapon`.
  - When: `manual_save(1, player_state, world_state, settings)` is called.
  - Then: the saved JSON contains all top-level fields and the `weapon` system
    payload.
  - Edge cases: empty dictionaries still serialize as dictionaries.

- **AC-3**: Registered serializable systems are serialized and deserialized in
  deterministic order by save key.
  - Given: two mock systems registered in order.
  - When: a save is loaded.
  - Then: both receive their own data and deserialize callbacks occur in the
    registration order.
  - Edge cases: duplicate save keys are rejected.

- **AC-4**: Saving over an existing slot creates a `.bak`, and loading a corrupt
  main file falls back to a valid backup.
  - Given: a valid slot 1 save exists.
  - When: slot 1 is saved again.
  - Then: `slot_1.json.bak` contains the old valid save.
  - When: `slot_1.json` is replaced with invalid JSON and `load_game(1)` runs.
  - Then: `load_game(1)` succeeds from `.bak` and emits corruption state.

---

## Test Evidence

**Story Type**: Integration
**Required evidence**:
- `tests/unit/save/story_001_save_slots_backup_json_pipeline_test.gd` must exist
  and pass.
- Godot headless main-scene smoke must run after Autoload registration.
- Godot MCP should verify the project starts and SaveSystem is available at
  `/root/SaveSystem`.

**Evidence**:
- `production/qa/evidence/save-slots-backup-json-pipeline-2026-06-24.md`
- `godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/save/story_001_save_slots_backup_json_pipeline_test.gd -a res://tests/unit/input/story_001_action_abstraction_test.gd --ignoreHeadlessMode`
  - PASS: 9/9.
- `godot --headless --path . --scene res://scenes/main.tscn --fixed-fps 60 --quit-after 180 --log-file reports/save_story001_main_scene_smoke_final.log`
  - Exit code 0; error scan returned no matches.
- Godot MCP `cinderpaw@c1b2` verified `autoload/SaveSystem`,
  `/root/SaveSystem`, slot 0 autosave, manual slot 1 save/load, and no
  runtime/editor errors.

**Status**: [x] Complete

---

## Dependencies

- Depends on: DataManager/InputManager foundation autoloads, ADR-0008,
  ADR-0021.
- Unlocks: Save System Story 002, HUD/UI Story 005, Death & Respawn Story 004.
