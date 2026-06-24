# Story 003: Autosave Trigger Adapters

> **Epic**: Save System
> **Status**: Complete
> **Layer**: Feature
> **Type**: Integration
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-24

## Context

**GDD**: `design/gdd/save-system.md`
**Requirement**: `TR-save-006`
*(Requirement text lives in `docs/architecture/tr-registry.yaml` — read fresh at review time)*

**ADR Governing Implementation**: ADR-0021: Save system architecture
**ADR Decision Summary**: SaveSystem owns autosave trigger boundaries while
callers such as savepoints, boss health, key-event systems, and SceneManager
stay decoupled through narrow adapters.

**Engine**: Godot 4.6.3 | **Risk**: MEDIUM
**Engine Notes**: Godot signal connections must use typed `signal.connect`
syntax or `Object.connect(StringName, Callable)`. Runtime signal binding must be
verified in Godot because adapters will eventually attach to scene nodes.

**Control Manifest Rules (Feature layer)**:
- Required: Feature systems use narrow adapters and stay testable without full
  scene loading.
- Forbidden: Do not synchronously switch scenes from SaveSystem; SceneManager
  owns scene transitions.
- Guardrail: Autosave trigger handling must avoid gameplay stalls and stay
  below the save-system 100ms budget.

---

## Acceptance Criteria

- [x] Savepoint trigger adapters convert savepoint entry signals into slot 0
  autosaves with provider-supplied player/world/settings snapshots.
- [x] Boss defeat, key-event, and scene-change trigger adapters all invoke slot
  0 autosave through the same path and emit the trigger reason.
- [x] Invalid adapters, missing save systems, failed autosaves, and missing
  snapshot providers fail cleanly without writing manual slots.
- [x] The adapter remains decoupled from concrete savepoint, boss, quest,
  ability, SceneManager, HUD, and MainScene classes.

---

## Implementation Notes

- Add a Feature-layer adapter node at `src/feature/save_trigger_adapter.gd`.
- The adapter should be configured with a SaveSystem-like object and an optional
  snapshot provider callable returning:
  `{ "player_state": Dictionary, "world_state": Dictionary, "settings": Dictionary }`.
- Expose direct `trigger_auto_save(reason, context)` and signal-binding helpers
  for savepoint, boss defeat, key event, and scene change triggers.
- All autosave triggers must call `SaveSystem.auto_save(...)`, never
  `manual_save(0, ...)`.
- Include `autosave_reason` and adapter context in `world_state` so later HUD,
  QA, and debugging surfaces can identify why slot 0 was written.
- Emit success/failure signals using at most three payload fields.
- Do not implement real savepoint scene nodes, MainScene state capture,
  SceneManager load handoff, HUD Save/Load UI, async threaded writes,
  screenshots, delete-save UI, or manual overwrite selection in this story.

---

## Out of Scope

- Story 004: MainScene SaveSystem runtime state provider and load handoff.
- HUD/UI Story 005: save/load menu presentation, overwrite prompts, and slot
  card interactions.
- Death & Respawn Story 004: savepoint respawn selection.
- SceneManagement Epic: real async scene switching and scene-change save hook.
- Threaded async write implementation and screenshot thumbnails.

---

## QA Test Cases

- **AC-1**: Savepoint signal writes autosave slot.
  - Given: SaveSystem is configured to a clean test directory and the adapter
    has a snapshot provider.
  - When: a savepoint `body_entered` signal is emitted.
  - Then: `slot_0.json` exists, includes provider player/world/settings data,
    and records `autosave_reason="savepoint"`.
  - Edge cases: context contains a savepoint name and still serializes as JSON.

- **AC-2**: Boss/key/scene triggers share one autosave path.
  - Given: three mock trigger sources are bound to the adapter.
  - When: boss defeat, key event, and scene-change signals emit.
  - Then: each writes slot 0 through `auto_save()` and emits the matching
    trigger reason.
  - Edge cases: repeated triggers overwrite slot 0 and keep `.bak` usable.

- **AC-3**: Invalid or failed triggers fail cleanly.
  - Given: the adapter has no SaveSystem, an invalid source, or a SaveSystem
    returning false.
  - When: binding or triggering autosave is attempted.
  - Then: the operation returns false, emits failure when appropriate, and does
    not attempt a manual slot write.

- **AC-4**: Adapter stays decoupled from concrete gameplay classes.
  - Given: only mock signal emitters and a SaveSystem-like object are available.
  - When: all adapter APIs are exercised.
  - Then: no concrete savepoint, boss, quest, ability, SceneManager, HUD, or
    MainScene class is required.

---

## Test Evidence

**Story Type**: Integration
**Required evidence**:
- `tests/unit/save/story_003_autosave_trigger_adapter_test.gd` must exist and
  pass.
- Focused SaveSystem regression must include Story 001, Story 002, and Story
  003 suites.
- Godot MCP should verify `SaveTriggerAdapter` and `SaveSystem` can run in
  `res://scenes/main.tscn` without runtime errors.

**Status**: [x] Complete

**RED evidence**:
- Command:
  `godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/save/story_003_autosave_trigger_adapter_test.gd --ignoreHeadlessMode`
- Result: Exit 100 as expected. The first run failed because
  `res://src/feature/save_trigger_adapter.gd` did not exist.

**GREEN evidence**:
- Command:
  `godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/save/story_003_autosave_trigger_adapter_test.gd --ignoreHeadlessMode`
- Result: 3/3 tests passing, 0 errors, 0 failures, 0 orphans.

**Focused regression**:
- Command:
  `godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/save/story_001_save_slots_backup_json_pipeline_test.gd -a res://tests/unit/save/story_002_version_migration_save_info_metadata_test.gd -a res://tests/unit/save/story_003_autosave_trigger_adapter_test.gd --ignoreHeadlessMode`
- Result: 10/10 tests passing, 0 errors, 0 failures, 0 orphans.

**Runtime smoke**:
- Command:
  `godot --headless --path . --scene res://scenes/main.tscn --fixed-fps 60 --quit-after 180 --log-file reports/save_story003_main_scene_smoke.log`
- Result: Exit 0; log scan found no `ERROR`, `WARNING`, `SCRIPT ERROR`,
  `Parse Error`, `Invalid access`, `Invalid call`, `Failed`, or `Cannot`.

**Godot MCP evidence**:
- MCP server: Godot AI 3.4.2, session `cinderpaw@c1b2`, Godot
  `4.6.3-stable (official)`.
- MCP reimported `save_trigger_adapter.gd`, `save_system.gd`, and the Story
  003 test.
- MCP opened and ran `res://scenes/main.tscn`.
- Runtime `game_eval` created a temporary `SaveTriggerAdapter`, bound mock
  savepoint and boss defeat signals, emitted both, and observed:
  `bind_savepoint=true`, `bind_boss=true`, `has_auto=true`,
  `has_manual_1=false`, `reasons=["savepoint","boss_defeat"]`,
  `reason="boss_defeat"`, `context_boss="rat_king"`, `hp=71`,
  `hud_scale=1.25`, `file_size_positive=true`.
- MCP game log contained only the helper registration line; editor log
  contained 0 warnings/errors after clearing stale dynamic-script warnings and
  rerunning the probe.

---

## Dependencies

- Depends on: Save System Story 002 must be Complete.
- Unlocks: Save System Story 004, HUD/UI Story 005, Death & Respawn Story 004.
