# QA Evidence: Rat King Defeat Reward Runtime - 2026-06-25

## Scope

Verifies Boss Configuration Story010: defeating Rat King in `MainScene` now
consumes the configured BossConfig rewards, updates runtime progression,
presents the reward to the player, and persists the result through SaveSystem
snapshots and boss-defeat autosave.

This evidence does not claim full PlayerAbilityManager gating, skill tree
spending UI, or new reward art/audio.

## Asset Pipeline

No new visual asset was generated for this reward-runtime slice. The MCP
screenshot reuses existing MainScene, Rat King, HUD, and arena VFX assets.

Runtime screenshot evidence was saved at
`reports/visual/cinderpaw-mcp-rat-king-reward-runtime-20260625.png`.

## Automated Evidence

### RED

Command:

```bash
godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/rat_king_defeat_reward_runtime_test.gd --ignoreHeadlessMode
```

Result: exit `100`, report `reports/report_588/`.

Summary: expected failure because `MainScene` still granted `25` Gears, did not
consume `dash` or `5` skill points, HUD did not show the configured reward, and
save snapshots lacked reward progression fields.

### GREEN Focused

Command:

```bash
godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/rat_king_defeat_reward_runtime_test.gd --ignoreHeadlessMode
```

Result: exit `0`, report `reports/report_589/`.

Summary: `1/1` passing, `0` errors, `0` failures.

### Related Regression

Command:

```bash
godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/rat_king_defeat_reward_runtime_test.gd -a res://tests/unit/boss/story_005_desperation_reward_test.gd -a res://tests/unit/gameplay/rat_king_boss_runtime_contract_test.gd -a res://tests/unit/save/story_004_main_scene_save_system_runtime_handoff_test.gd --ignoreHeadlessMode
```

Result: exit `0`, report `reports/report_595/`.

Summary: `13/13` passing, `0` errors, `0` failures. Godot still emitted an
ObjectDB/resource cleanup warning at process exit in this mixed test run; no
GdUnit test failed and no runtime script error was reported.

## Headless Smoke

Command:

```bash
godot --headless --path . --scene res://scenes/main.tscn --fixed-fps 60 --quit-after 180 --log-file reports/rat_king_reward_runtime_main_scene_smoke.log
rg -n "ERROR|SCRIPT ERROR|WARNING|Invalid call|Parse Error|FAILED|Failed loading resource|Cannot" reports/rat_king_reward_runtime_main_scene_smoke.log
```

Result: Godot exited `0`; `rg` returned no matches in the log file. The process
stderr still printed a cleanup-time `ObjectDB/resource still in use` message
after exit; this did not appear in the scene log and is tracked as residual
Godot cleanup noise, not a Story010 runtime blocker.

## Godot MCP Evidence

Session:

- Session id: `cinderpaw@c1b2`.
- Godot version: `4.6.3-stable (official)`.
- Editor scene: `res://scenes/main.tscn`.
- Runtime state: playing, game capture ready.

Runtime tree:

- `/Main/Enemy`: `CharacterBody2D`.
- `/Main/Enemy/Sprite`: `AnimatedSprite2D`.
- `/Main/Enemy/BossConfigComponent`: present.
- `/Main/HUD`: present with reward retry menu.

MCP reward probe:

```json
{
  "enemy_hp": 0,
  "flow_state": "victory",
  "currency": 50,
  "skill_points": 5,
  "unlocked_abilities": ["dash"],
  "world_flags": {"boss_rat_king_defeated": true},
  "notification": "Dash unlocked +50 Gears +5 SP",
  "menu_title": "Rat King defeated",
  "menu_subtitle": "Rewards claimed: Dash unlocked +50 Gears +5 SP. Retry the encounter or stay with your prize.",
  "save_currency": 50,
  "save_skill_points": 5,
  "save_unlocked_abilities": ["dash"],
  "defeated_bosses": ["boss_01_rat_king"]
}
```

Logs:

- `logs_read(source="game", count=80)` returned only MCP helper registration
  and DataManager domain load lines.
- `logs_read(source="editor", count=80)` returned `0` lines.

Screenshot:

- Saved at
  `reports/visual/cinderpaw-mcp-rat-king-reward-runtime-20260625.png`.
- Screenshot is nonblank and shows the victory retry menu with
  `Rewards claimed: Dash unlocked +50 Gears +5 SP` plus the HUD currency panel
  showing `Gears 50`.

## Acceptance Verdict

| Criterion | Evidence | Status |
|-----------|----------|--------|
| RatKingBoss forwards reward adapter to BossConfigComponent | `report_589`, MCP runtime probe | PASS |
| Defeat consumes dash/50/5 configured reward | `report_589`, MCP reward probe | PASS |
| Hard-coded 25 Gears removed | RED `report_588`, GREEN `report_589` | PASS |
| Runtime progress includes unlocked abilities and skill points | `report_589`, MCP reward probe | PASS |
| Save snapshot and autosave persist reward state | `report_595`, MCP reward probe | PASS |
| HUD notification and retry menu present reward | `report_589`, MCP screenshot | PASS |
| Duplicate victory presentation does not duplicate reward | `report_589` | PASS |
| Runtime logs clean through MCP | MCP game/editor logs | PASS |
