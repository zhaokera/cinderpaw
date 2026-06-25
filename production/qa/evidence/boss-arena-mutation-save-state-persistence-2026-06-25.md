# QA Evidence: Boss Arena Mutation Save-State Persistence - 2026-06-25

## Scope

Verifies Scene Management Story012: active Rat King arena mutations now persist
through `MainScene` save snapshots and SaveSystem slot handoff. Restores rebuild
the existing Story008 mutation nodes, Story009 electric leak hazard behavior,
and Story011 VFX children.

This evidence does not claim new arena art, particles, shaders, camera
choreography, audio, Rat Minion summon persistence, or electric leak cooldown
timer persistence.

## Implementation Contract

- `world_state.arena_mutations` contains deterministic JSON-safe descriptors:
  `boss_id`, `phase`, `id`, and `type`.
- Restore clears existing mutation nodes first, ignores invalid descriptors, and
  reuses `apply_arena_changes()` so fresh and restored nodes share one builder.
- Boss defeat and older saves without `arena_mutations` restore an empty active
  mutation set.
- Contact cooldowns remain runtime-only and are cleared by mutation cleanup.

## Asset Pipeline

No new visual asset was generated for this persistence slice. The restored nodes
reuse existing image-generated arena mutation and VFX assets from Stories 008
and 011.

Runtime screenshot evidence was saved at
`reports/visual/cinderpaw-mcp-arena-mutation-save-state-20260625.png`.

## Automated Evidence

### RED

Command:

```bash
/opt/homebrew/bin/godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/rat_king_arena_mutation_save_state_test.gd --ignoreHeadlessMode
```

Result: exit `100`; transient report was not retained in the working tree.

Summary: expected failure because `world_state.arena_mutations` was absent and
the saved mutation list size was `0`.

### GREEN Focused

Command:

```bash
/opt/homebrew/bin/godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/rat_king_arena_mutation_save_state_test.gd --ignoreHeadlessMode
```

Result: exit `0`, report `reports/report_577/`.

Summary: `6/6` passing, `0` errors, `0` failures, `0` orphans. Coverage also
includes a defeated Rat King JSON-string restore guard so stale saved mutation
lists cannot resurrect hazards after the boss is already defeated.

### Related Regression

Command:

```bash
/opt/homebrew/bin/godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/rat_king_arena_mutation_save_state_test.gd -a res://tests/unit/gameplay/rat_king_arena_mutation_runtime_test.gd -a res://tests/unit/gameplay/rat_king_electric_leak_contact_damage_test.gd -a res://tests/unit/gameplay/rat_king_arena_vfx_polish_test.gd -a res://tests/unit/save/story_004_main_scene_save_system_runtime_handoff_test.gd -a res://tests/unit/gameplay/main_scene_save_load_menu_runtime_test.gd --ignoreHeadlessMode
```

Result: exit `0`, report `reports/report_578/`.

Summary: `26/26` passing, `0` errors, `0` failures, `0` orphans. The Godot
process still emitted an existing ObjectDB/resource cleanup warning at process
exit in this mixed SaveSystem regression run; the focused Story012 suite is
clean.

### Title/Load Handoff Guard

Command:

```bash
/opt/homebrew/bin/godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/main_scene_title_load_handoff_test.gd --ignoreHeadlessMode
```

Result: exit `0`, report `reports/report_579/`.

Summary: `7/7` passing. The same-scene transition short-circuit used by runtime
load restore does not break title, continue, selected slot, rejection, fallback,
or atomic deserialization handoff paths.

## Headless Smoke

Command:

```bash
/opt/homebrew/bin/godot --headless --path . --scene res://scenes/main.tscn --fixed-fps 60 --quit-after 180 --log-file reports/boss_arena_mutation_save_state_main_scene_smoke.log
rg -n "ERROR|SCRIPT ERROR|WARNING|Failed|failed|No loader|Invalid|resources still in use|leaked" reports/boss_arena_mutation_save_state_main_scene_smoke.log
```

Result: Godot exited `0`; `rg` returned no matches.

## Godot MCP Evidence

Session:

- Session id: `cinderpaw@c1b2`.
- Godot version: `4.6.3-stable (official)`.
- Runtime scene: `res://scenes/main.tscn`.
- Runtime state: playing, game capture ready.

MCP probe summary:

```json
{
  "before_count": 3,
  "captured_arena_mutations": [
    {"boss_id": "boss_01_rat_king", "id": "garbage_pile", "phase": 2, "type": "obstacle"},
    {"boss_id": "boss_01_rat_king", "id": "electric_leak", "phase": 3, "type": "damage_zone"},
    {"boss_id": "boss_01_rat_king", "id": "overturned_trash_can", "phase": 3, "type": "obstacle"}
  ],
  "save_ok": true,
  "has_slot_1": true,
  "after_cleanup_count": 0,
  "load_ok": true,
  "restored_count": 3,
  "after_reapply_count": 3
}
```

Restored node probe:

- `ArenaMutation_garbage_pile`: `StaticBody2D`, visible, collision, `Sprite`,
  `Visual`, `Vfx/DebrisDust`, boss/change metadata intact.
- `ArenaMutation_overturned_trash_can`: `StaticBody2D`, visible, collision,
  `Sprite`, `Visual`, `Vfx/DebrisDust`, boss/change metadata intact.
- `ArenaMutation_electric_leak`: `Area2D`, visible, collision, `Sprite`,
  `Visual`, `Vfx/HazardGlow`, `Vfx/ElectricSpark`, `area_entered` and
  `body_entered` connections present, collision layer/mask `16/12`.

Logs:

- `logs_read(source="game", count=100)` returned only MCP helper registration
  and DataManager domain load lines.
- `logs_read(source="editor", count=100)` returned `0` lines after clearing old
  MCP log cache before the run.

Screenshot:

- Runtime screenshot saved at
  `reports/visual/cinderpaw-mcp-arena-mutation-save-state-20260625.png`.
- Screenshot is nonblank and shows the playable main scene with Cinderpaw and
  Rat King while the restored arena mutation nodes are present and inspectable
  via MCP.

## Acceptance Verdict

| Criterion | Evidence | Status |
|-----------|----------|--------|
| Snapshot captures JSON-safe descriptors | `report_577`, MCP probe | PASS |
| Restore rebuilds collision/metadata/VFX/hazard nodes | `report_577`, MCP node probe | PASS |
| SaveSystem slot save/load restores mutations | `report_577`, MCP slot probe | PASS |
| Restore/reapply idempotent | `report_577`, MCP `after_reapply_count=3` | PASS |
| Boss defeat saves empty mutation list | `report_577` | PASS |
| Older saves without field clear stale nodes | `report_577` | PASS |
| Defeated Rat King state clears stale saved mutations | `report_577` | PASS |
| Story008/009/011 regressions preserved | `report_578` | PASS |
| Title/load handoff remains compatible | `report_579` | PASS |
| Main scene launches cleanly | Headless smoke and MCP logs | PASS |
| Screenshot evidence captured | MCP screenshot file | PASS |

## Final Status

PASS. Story012 is implemented and verified by TDD, focused and related GdUnit
coverage, Godot headless smoke, and Godot MCP runtime save/load node/log/
screenshot evidence.
