# Story 004: MainScene SaveSystem Runtime Handoff

> **Epic**: Save System
> **Status**: Complete
> **Layer**: Feature
> **Type**: Integration
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-24

## Context

**GDD**: `design/gdd/save-system.md`
**Requirements**: `TR-save-001`, `TR-save-002`, `TR-save-006`
*(Requirement text lives in `docs/architecture/tr-registry.yaml` — read fresh at review time)*

**ADR Governing Implementation**: ADR-0001: Autoload architecture; ADR-0021:
Save system architecture
**ADR Decision Summary**: `SaveSystem` is the Feature-layer Autoload that
coordinates JSON persistence. Scene runtime state stays in scene-owned adapters
and is handed to `SaveSystem` through narrow, testable interfaces.

**Engine**: Godot 4.7 | **Risk**: MEDIUM
**Engine Notes**: `MainScene` must remain unit-testable with an injected
SaveSystem instance, while the running game uses `/root/SaveSystem`.

**Control Manifest Rules (Feature layer)**:
- Required: scene state persistence uses local state / ISerializable style
  handoff.
- Required: public save/load APIs must be dependency-injectable for tests.
- Forbidden: do not synchronously switch scenes from `SaveSystem`.
- Guardrail: do not put HUD save/load menu presentation or SceneManager loading
  into this story.

---

## Acceptance Criteria

- [x] `MainScene` can configure a SaveSystem-like object at runtime and
  registers a serializable `main_scene` payload without requiring the HUD or
  SceneManager.
- [x] `MainScene` exposes a JSON-safe save snapshot with `player_state`,
  `world_state`, and `settings`, including player HP, position, currency,
  current/acquired weapons, weapon levels, HUD settings, and world progress
  flags.
- [x] Manual runtime save writes slots 1-3 through `SaveSystem.manual_save()`
  and keeps slot 0 protected for autosave.
- [x] Runtime load calls `SaveSystem.load_game(slot)` and restores the active
  MainScene state from `SaveSystem.get_last_loaded_data()`.
- [x] Boss defeat in the running MainScene triggers slot 0 autosave through the
  existing `SaveTriggerAdapter`, including `autosave_reason="boss_defeat"` and
  a JSON-safe boss context.

---

## Implementation Notes

- Add a `SaveTriggerAdapter` child in `MainScene` only for save trigger
  delegation; keep `SaveSystem` as the Autoload/service owner.
- Add public methods for runtime save/load handoff, with an injectable
  SaveSystem for GdUnit tests and MCP runtime probes.
- Use `capture_no_loss_state()` / `restore_no_loss_state()` for existing
  currency, inventory, weapon, settings, and world flag handoff.
- Convert engine values such as `Vector2` to JSON-safe dictionaries before
  writing save data.
- Restore player HP and position defensively; do not implement full
  SceneManager respawn selection in this story.

---

## Out of Scope

- HUD Save/Load menu shell, overwrite prompts, delete-save UI, and thumbnails.
- Real savepoint scene nodes and savepoint respawn selection.
- Async SceneManager scene switching.
- Threaded async file writes and save thumbnails.
- Cloud saves, encryption, or platform account integration.

---

## QA Test Cases

- **AC-1**: MainScene writes a SaveSystem-compatible snapshot.
  - Given: a MainScene and injected SaveSystem configured to a clean test
    directory.
  - When: runtime currency, weapon, HP, and HUD settings change, then slot 1 is
    saved.
  - Then: `slot_1.json` contains populated `player_state`, `world_state`,
    `settings`, and `systems.main_scene`.

- **AC-2**: MainScene restores from the last loaded save.
  - Given: slot 1 contains a valid MainScene runtime save.
  - When: the scene state is mutated and `load_runtime_from_slot(1)` runs.
  - Then: player HP, currency, weapon state, HUD settings, and world flags are
    restored from the saved data.

- **AC-3**: Boss defeat uses autosave trigger handoff.
  - Given: MainScene is configured with SaveSystem and the runtime boss is
    defeated.
  - When: the boss defeat signal reaches MainScene.
  - Then: slot 0 exists, the save is marked as autosave, and world state records
    `autosave_reason="boss_defeat"`.

---

## Test Evidence

**Story Type**: Integration
**Required evidence**:
- `tests/unit/save/story_004_main_scene_save_system_runtime_handoff_test.gd`
  must exist and pass.
- Focused SaveSystem regression must include Story 001 through Story 004 suites.
- Godot MCP must run `res://scenes/main.tscn`, verify MainScene can save/load
  through `/root/SaveSystem` or an injected runtime SaveSystem, and report no
  runtime/editor errors.

**Status**: [x] Complete

**RED evidence**:
- Command:
  `godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/save/story_004_main_scene_save_system_runtime_handoff_test.gd --ignoreHeadlessMode`
- Result: Exit 100 as expected. The first run failed because `MainScene` lacked
  `configure_save_system_runtime()` and `save_runtime_to_slot()`.

**GREEN evidence**:
- Command:
  `godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/save/story_004_main_scene_save_system_runtime_handoff_test.gd --ignoreHeadlessMode`
- Result: 3/3 tests passing, 0 errors, 0 failures, 0 orphans.

**Focused regression**:
- Command:
  `godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/save/story_001_save_slots_backup_json_pipeline_test.gd -a res://tests/unit/save/story_002_version_migration_save_info_metadata_test.gd -a res://tests/unit/save/story_003_autosave_trigger_adapter_test.gd -a res://tests/unit/save/story_004_main_scene_save_system_runtime_handoff_test.gd --ignoreHeadlessMode`
- Result: 13/13 tests passing, 0 errors, 0 failures, 0 orphans.

**MainScene regression**:
- Command:
  `godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/main_scene_hud_settings_runtime_test.gd -a res://tests/unit/gameplay/main_scene_weapon_swap_runtime_test.gd -a res://tests/unit/gameplay/main_scene_enemy_attack_core_chain_test.gd --ignoreHeadlessMode`
- Result: 7/7 tests passing, 0 errors, 0 failures, 0 orphans.

**Runtime smoke**:
- Command:
  `godot --headless --path . --scene res://scenes/main.tscn --fixed-fps 60 --quit-after 180 --log-file reports/save_story004_main_scene_smoke.log`
- Result: Exit 0; log scan found no `ERROR`, `WARNING`, `SCRIPT ERROR`,
  `Parse Error`, `Invalid access`, `Invalid call`, `Failed`, or `Cannot`.

**Godot MCP evidence**:
- MCP confirmed Godot `4.6.3-stable`, project ready, and
  `res://scenes/main.tscn` running.
- MCP reimported `res://src/gameplay/main_scene.gd` and the Story 004 test.
- Runtime `game_eval` configured `/root/SaveSystem` to a temporary save
  directory, saved slot 1, mutated MainScene runtime state, loaded slot 1, and
  defeated the runtime boss to trigger slot 0 autosave.
- Observed runtime result:
  `configured=true`, `manual_ok=true`, `load_ok=true`, `has_manual_1=true`,
  `has_auto_0=true`, `manual_hp=78`, `manual_weapon="long_tail"`,
  `manual_hud_scale=1.5`, `restored_hp=78`, `restored_currency=11`,
  `restored_weapon="long_tail"`, `restored_flag=true`,
  `restored_hud_scale=1.5`, `auto_reason="boss_defeat"`,
  `auto_boss="shadow_beast"`, `auto_defeated_has_shadow=true`,
  `auto_currency=36`.
- MCP game log contained only the helper registration line; editor log contained
  0 warnings/errors. MCP game screenshot metadata was non-empty
  (1280x720 source, 640x360 returned).

---

## Dependencies

- Depends on: Save System Story 003 must be Complete.
- Unlocks: HUD/UI Story 005 and Death & Respawn savepoint respawn selection.
