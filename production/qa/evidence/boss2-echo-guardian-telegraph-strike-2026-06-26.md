# QA Evidence: Boss2 Echo Guardian Telegraph Strike

Date: 2026-06-26
Story: `production/epics/player-abilities/story-022-boss2-echo-guardian-telegraph-strike.md`

## Scope

This evidence covers the minimal Boss2 combat-threat slice. It verifies a
single `boss2_echo_swipe` attack with startup, active hitbox, recovery, Player
damage, MainScene presentation/audio routing, defeat cleanup, and Story021
Double Jump reward compatibility.

No new visual assets were generated in this story. Boss2 reuses the Story021
image-generated `AnimatedSprite2D + SpriteFrames` character art under
`assets/characters/boss2_echo_guardian/<animation>/`.

## Automated Tests

- RED focused: `reports/report_772/`
  - Expected failure: Boss2 lacked `enemy_attack_landed`,
    `get_collision_component()`, `advance_attack_frames()`,
    `get_current_attack_startup_frames()`, `get_attack_phase()`,
    `is_enemy_attack_active()`, and `get_last_enemy_attack_metadata()`.
- Intermediate RED: `reports/report_773/`, `reports/report_774/`
  - Expected refinement failure: final Boss2 attack metadata did not yet retain
    `source="boss2_echo_guardian"`.
- Intermediate GREEN focused: `reports/report_775/`
  - Passed before restored-defeated threat cleanup coverage was added.
- Final focused/related regression: `reports/report_777/`
  - Story022 Boss2 telegraph strike: `4/4`
  - Boss2 Double Jump payoff runtime: `3/3`
  - MainScene enemy attack Core chain: `2/2`
  - MainScene player attack Core chain: `4/4`
  - Total: `13/13` passing.

## Headless Smoke

Command:

```sh
godot --headless --path . --quit-after 2 > reports/boss2_echo_guardian_telegraph_strike_main_scene_smoke.log 2>&1
```

Result: exit code `0`.

Keyword scan found no `SCRIPT ERROR`, `Parse Error`, `Invalid call`,
`Invalid get index`, `Resource file not found`, or `Failed loading resource`
entries. The log only contains the known cleanup-time ObjectDB/resource message
seen in prior headless smoke runs.

## Godot MCP Runtime

MCP state:

- Editor ready on `res://scenes/main.tscn`.
- Project launched through `project_run(mode="main", autosave=false)`.
- `game_capture_ready=true`.

Runtime probe results:

- Boss path: `/root/Main/Boss2EchoGuardian`
- Boss sprite class: `AnimatedSprite2D`
- SpriteFrames:
  `res://assets/characters/boss2_echo_guardian/boss2_echo_guardian_sprite_frames.tres`
- Animation frame counts: `idle=3`, `attack=3`, `hurt=3`, `death=3`
- `request_attack()` returned `true`
- Startup phase: `startup`
- Startup hitbox active: `false`
- Active phase after startup frames: `active`
- Active hitbox active: `true`
- Player HP: `100 -> 86`
- Damage delta: `14`
- Duplicate same-active hit check preserved HP at `86`
- Damage number count after hit: `1`
- Metadata:
  - `source=boss2_echo_guardian`
  - `hitbox_id=boss2_echo_swipe`
  - `weapon_id=boss2_echo_swipe`
  - `target_id=1`
  - `final_damage=14`
- Boss defeated through `apply_damage(boss.get_current_hp(), ...)`: `true`
- Attack after defeat: `false`
- Reward available after defeat: `true`
- Player moved into reward range, claim returned `true`
- Player `has_ability("double_jump")`: `true`

Fresh runtime restored-defeated probe:

- `set_world_progress_flag("boss_02_echo_guardian_defeated", true)` marked
  Boss2 defeated without firing a combat defeat sequence.
- Boss visible: `false`
- `request_attack()` after restored defeat: `false`
- `boss2_echo_swipe` active: `false`
- Boss2 hurtbox state: `gone`
- Boss2 body `collision_layer=0`, `collision_mask=0`

MCP logs after clearing:

- Game log: DataManager boss/enemy domains only; no errors.
- Editor log: no entries.

Runtime screenshot:

- `reports/visual/cinderpaw-mcp-boss2-echo-guardian-telegraph-strike-20260626.png`

## Result

PASS. Boss2 now has a minimal readable attack threat and the existing mainline
Double Jump payoff remains intact.
