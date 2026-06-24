# QA Evidence: Runtime Player Attack Core Chain — 2026-06-24

## Scope

Verifies that the playable MainScene player attack path now uses the completed Core combat chain instead of prototype direct damage:

`PlayerController.request_attack()` -> `CombatComponent` -> `WeaponComponent.activate_current_attack_hitbox()` -> `CollisionComponent.on_hit_confirmed` -> `DamageCalculator` -> enemy `HealthComponent` -> `WeaponComponent.apply_confirmed_hit_effects()` -> enemy `StatusEffectComponent`.

## Automated Evidence

### RED

Command:

```bash
godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/main_scene_player_attack_core_chain_test.gd --ignoreHeadlessMode
```

Result: exit `100`, report `reports/report_341/`.

Observed failure: runtime attack contract was missing on `Player`, `Enemy`, and `MainScene`, proving the new integration test guarded absent behavior rather than existing behavior.

### GREEN

Command:

```bash
godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/main_scene_player_attack_core_chain_test.gd --ignoreHeadlessMode
```

Result: exit `0`, report `reports/report_342/`.

Summary: `2/2` passing, `0` errors, `0` failures.

### Focused Regression

Command: gameplay attack integration, weapon swap runtime, combat stories 001-007, collision stories 001-005, health story 001, status stories 001-006, weapon stories 001-008.

Result: exit `0`, report `reports/report_343/`.

Summary: `29` suites, `134/134` passing, `0` errors, `0` failures, `0` skipped, `0` orphans.

## Runtime Evidence

### Headless Main Scene Smoke

Command:

```bash
godot --headless --path . --scene res://scenes/main.tscn --fixed-fps 60 --quit-after 120 --log-file reports/player_attack_core_chain_main_scene_smoke.log
rg -n "ERROR|Error|error|WARNING|Warning|warning|Parse Error|SCRIPT ERROR" reports/player_attack_core_chain_main_scene_smoke.log || true
```

Result: Godot exited `0`; log scan returned no matching error or warning lines.

### Godot MCP

Session:

- MCP server: `Godot AI 3.4.2`
- Godot session: `cinderpaw@c4d7`
- Godot version: `4.6.3-stable (official)`
- Scene: `res://scenes/main.tscn`

Runtime cat-claw probe:

```json
{
  "scene": "Main",
  "request": true,
  "start_hp": 30,
  "after_hp": 12,
  "damage": 18,
  "weapon": "cat_claw",
  "hits": 1
}
```

Runtime electro-bell probe after fresh MCP restart:

```json
{
  "scene": "Main",
  "weapon_before": "electro_bell",
  "request": true,
  "start_hp": 30,
  "after_hp": 18,
  "damage": 12,
  "metadata_weapon": "electro_bell",
  "slow_applied": true,
  "has_slow": true,
  "slow_remaining": 2.0,
  "movement_modifier": 0.7
}
```

Game logs:

- `logs_read(source="game", count=80)` returned only the MCP helper registration line.
- No runtime error or warning entries were reported by the game log buffer.

Screenshot:

- `reports/visual/cinderpaw-mcp-player-attack-core-chain-20260624.png`

## Verdict

PASS. Runtime player attacks now exercise the Core combat/collision/health/weapon/status chain in `main.tscn`, and the path is covered by automated tests plus Godot MCP runtime evidence.
