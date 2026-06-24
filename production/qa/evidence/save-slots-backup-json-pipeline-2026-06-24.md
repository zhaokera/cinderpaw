# QA Evidence: SaveSystem Story 001 Save Slots + Backup JSON Pipeline

> **Story**: `production/epics/save-system/story-001-save-slots-backup-json-pipeline.md`
> **Date**: 2026-06-24
> **Result**: PASS

## 范围

实现 SaveSystem 持久化基础：可配置 `user://` 存档目录、0 号自动存档槽、
1-3 号手动槽、JSON 顶层结构、注册系统序列化顺序、覆盖写入 `.bak`
备份，以及主存档损坏时回退到备份。此 Story 不新增视觉素材。

## TDD Evidence

- RED:
  - `tests/unit/save/story_001_save_slots_backup_json_pipeline_test.gd`
    先于实现创建，初次运行因
    `res://src/feature/save_system.gd` 缺失而失败。
  - 早期实现使用 `class_name SaveSystem` 与 Autoload 名称冲突；测试随后
    加入 `script.can_instantiate()` 断言，避免假绿。
- GREEN:
  - `godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/save/story_001_save_slots_backup_json_pipeline_test.gd --ignoreHeadlessMode`
  - PASS: 4/4.
- 最终聚焦回归:
  - `godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/save/story_001_save_slots_backup_json_pipeline_test.gd -a res://tests/unit/input/story_001_action_abstraction_test.gd --ignoreHeadlessMode`
  - PASS: 9/9.

## Godot Smoke

- `godot --headless --path . --scene res://scenes/main.tscn --fixed-fps 60 --quit-after 180 --log-file reports/save_story001_main_scene_smoke_final.log`
  - Exit code 0.
- `rg -n "ERROR|WARNING|SCRIPT ERROR|Parse Error|Invalid access|Invalid call|Failed|Cannot" reports/save_story001_main_scene_smoke_final.log`
  - No matches.

## MCP Runtime Evidence

- MCP endpoint: `http://127.0.0.1:8000/mcp`
- Server: Godot AI `3.4.2`
- Godot session: `cinderpaw@c1b2`
- Godot version: `4.6.3-stable (official)`
- Scene: `res://scenes/main.tscn`
- Project setting: `autoload/SaveSystem = "*res://src/feature/save_system.gd"`

Runtime probe result:

```json
{
  "auto_save": true,
  "available": true,
  "from_backup": false,
  "has_auto": true,
  "loaded": true,
  "loaded_boss": true,
  "loaded_hp": 44.0,
  "loaded_hud_scale": 1.5,
  "manual_slot": true,
  "manual_zero": false,
  "systems_present": true
}
```

MCP logs:

- Game log: only `[godot_ai game_helper] registered mcp capture`.
- Editor log: empty after `logs_clear`.

## Acceptance Criteria

| Criterion | Evidence | Result |
|---|---|---|
| SaveSystem writes JSON under configurable saves directory and protects autosave slot 0 from manual saves. | GdUnit `manual_save(0)` rejection and `auto_save()` slot 0 write; MCP `manual_zero=false`, `auto_save=true`, `has_auto=true`. | PASS |
| Save data includes `_meta`, `player_state`, `world_state`, `settings`, and registered `systems`. | GdUnit JSON payload assertions. | PASS |
| Registered systems serialize and deserialize in deterministic save-key order. | GdUnit two-system registration and deserialize callback order assertions. | PASS |
| Existing slot overwrite creates `.bak`, corrupt main save falls back to valid backup. | GdUnit backup file and corrupt-main fallback assertions. | PASS |
| Autoload starts in runtime without scene/script errors. | Headless main-scene smoke and MCP `/root/SaveSystem` runtime probe. | PASS |
