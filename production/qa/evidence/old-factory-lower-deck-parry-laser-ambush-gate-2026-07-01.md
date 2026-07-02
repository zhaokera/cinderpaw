# QA Evidence: Old Factory Lower Deck Parry-Laser Ambush Gate

Date: 2026-07-01
Story: `production/epics/player-abilities/story-054-old-factory-lower-deck-parry-laser-ambush-gate.md`
Engine: Godot `4.7.stable.official.5b4e0cb0f`
MCP session: `cinderpaw@4400`, Godot MCP plugin/server `2.8.1`

## Scope

Story054 adds an optional lower-deck Parry Laser gate after the Story053 lower
deck reward cache. Claiming the lower-deck cache makes the gate available;
using Cinderpaw's `parry` opens it and triggers a Factory Spark Rat exit ambush.
The ambush is player-visible ACT content, but it does not block the already
available service lift.

## Asset Evidence

No new visual assets were generated for this story.

- Reused Parry Laser gate texture:
  `res://assets/environment/parry_laser_gate/parry_laser_gate_marker.png`.
- Reused Factory Spark Rat SpriteFrames:
  `res://assets/characters/factory_spark_rat/factory_spark_rat_sprite_frames.tres`.
- Runtime frame contract observed through tests and MCP:
  `idle/run/attack_tell/attack/hurt/death=3`.

## Automated Verification

Focused RED:

```text
reports/report_1034/
Exit: 100
Expected failure: lower-deck parry gate and exit ambush diagnostics did not exist.
```

Focused GREEN:

```text
reports/report_1037/
Story054: 1/1 passed
Errors: 0
Failures: 0
Flaky: 0
Skipped: 0
Orphans: 0
```

Related regression:

```text
reports/report_1038/
Suites:
- old_factory_lower_deck_exit_ambush_test.gd
- old_factory_lower_deck_skirmish_cache_test.gd
- old_factory_checkpoint_overdrive_duo_test.gd
- old_factory_checkpoint_overdrive_reward_cache_test.gd
- old_factory_service_lift_scene_manager_exit_test.gd
- factory_route_runtime_roundtrip_test.gd

Result: 12/12 passed
Errors: 0
Failures: 0
Flaky: 0
Skipped: 0
Orphans: 0
```

Headless smoke:

```text
reports/old_factory_lower_deck_exit_ambush_smoke.log
Scene: res://scenes/factory_route_transition_shell.tscn
Exit: 0
Keyword scan: no SCRIPT ERROR, Parse Error, Invalid call, Invalid access,
Resource file not found, Failed loading resource, or ERROR entries in the log
file.
```

The terminal still printed the known Godot cleanup-time ObjectDB/resource
messages at process exit; the smoke log did not contain project script/resource
errors.

## MCP Runtime Evidence

Steps:

1. Activated MCP session `cinderpaw@4400`.
2. Confirmed Godot `4.7-stable (official)`.
3. Opened and ran `res://scenes/factory_route_transition_shell.tscn` through
   MCP with `autosave=false`.
4. Set Old Factory local state to the post-Story053 contract:
   checkpoint overdrive duo cleared, lower-deck skirmish defeated, and
   lower-deck reward cache claimed.
5. Moved Cinderpaw to the lower-deck Parry Laser gate and called
   `request_parry()`.
6. Read gate, ambush, route objective, service lift, HP, and frame-count
   diagnostics.
7. Applied fatal damage to entity `2109` and read persistence diagnostics.
8. Captured a game screenshot and read current game/editor logs.

Observed before parry:

- `FactoryLowerDeckParryLaserGate` present.
- `available=true`.
- `gate_state="unlockable"`.
- `collision_blocking=true`.
- `required_ability="parry"`.
- `visual_texture_path="res://assets/environment/parry_laser_gate/parry_laser_gate_marker.png"`.
- `position=(884, 438)`, deliberately outside the active checkpoint steam vent
  collision zone.

Observed after parry:

- `parry_result=true`.
- Gate:
  - `gate_state="unlocked"`.
  - `collision_blocking=false`.
  - `factory_lower_deck_parry_gate_unlocked=true`.
- Exit ambush:
  - `present=true`.
  - `active=true`.
  - `available=true`.
  - `enemy_visible=true`.
  - `enemy_has_target=true`.
  - `enemy_physics_enabled=true`.
  - `enemy_process_enabled=true`.
  - `entity_id=2109`.
  - Sprite class: `AnimatedSprite2D`.
  - SpriteFrames path:
    `res://assets/characters/factory_spark_rat/factory_spark_rat_sprite_frames.tres`.
  - Frame counts: `idle/run/attack_tell/attack/hurt/death=3`.
- Route objective:
  - `objective_id="clear_lower_deck_exit_ambush"`.
  - `route_label_text="Clear Lower Deck Exit"`.
- Service lift:
  - `available=true`.
  - `prompt_text="Call lift"`.
  - no return, forward, rear, or overdrive blocker active.
- Player HP remained `100` after the gate activation path, confirming the gate
  was no longer inside the active checkpoint steam vent hit zone.

Observed after defeating entity `2109`:

- `defeated_result=true`.
- Exit ambush:
  - `active=false`.
  - `defeated=true`.
  - `enemy_visible=false`.
  - `enemy_has_target=false`.
  - `enemy_physics_enabled=false`.
  - `enemy_process_enabled=false`.
- Persistence:
  - `factory_lower_deck_parry_gate_unlocked=true`.
  - `factory_lower_deck_exit_ambush_activated=true`.
  - `factory_lower_deck_exit_ambush_defeated=true`.
- Route objective:
  - `objective_id="lower_deck_exit_cleared"`.
  - `route_label_text="Lower Deck Exit Cleared"`.
  - `complete=true`.

Screenshot:

- MCP game screenshot returned `960x539` from original `1278x718`.
- The screenshot showed the Factory lower deck, route label
  `Clear Lower Deck Exit`, visible Cinderpaw, and the active exit Spark Rat.

Logs:

- Current game log contained only the MCP helper registration line.
- Current editor log was empty.
- `project_run` reported `recent_errors=[]`.

Verdict: PASS.
