# QA Evidence: Boss2 Autonomous Pressure Runtime

Date: 2026-06-26
Story: `production/epics/player-abilities/story-024-boss2-autonomous-pressure-runtime.md`

## Scope

This evidence covers the smallest autonomous Boss2 pressure slice. It verifies
that `Boss2EchoGuardian` moves from the current `res://scenes/main.tscn`
placement toward Cinderpaw, enters the existing `boss2_echo_swipe`
startup/active/recovery chain without a direct `request_attack()` call, damages
the player once through Core Collision/Combat, and shuts down cleanly when the
Boss2 defeated flag is restored.

No new visual assets were generated. This story reuses the Story021
image-generated Boss2 `AnimatedSprite2D + SpriteFrames` assets under
`assets/characters/boss2_echo_guardian/<animation>/`. The temporary chase
presentation uses the existing `idle` animation; a dedicated Boss2 run/chase
animation remains future polish.

## Automated Tests

- RED focused: `reports/report_784/`
  - Expected failure: `Boss2EchoGuardian` did not yet expose
    `advance_behavior_frames()` or `get_auto_pressure_diagnostics()`.
- Post-review RED: `reports/report_787/`
  - Expected failure: a released stale attack target still reported valid and
    allowed manual `request_attack()` to enter startup.
- Final GREEN focused: `reports/report_788/`
  - Story024 Boss2 autonomous pressure: `5/5`.
- Final related regression: `reports/report_789/`
  - Story024 Boss2 autonomous pressure: `5/5`.
  - Story022 Boss2 telegraph strike: `4/4`.
  - Story023 Boss2 HUD focus: `4/4`.
  - Story021 Boss2 Double Jump payoff: `3/3`.
  - Total: `16/16`.

## Headless Smoke

Command:

```sh
godot --headless --path . --scene res://scenes/main.tscn --fixed-fps 60 --quit-after 3 --log-file reports/boss2_autonomous_pressure_runtime_main_scene_smoke.log
```

Result: exit code `0`.

Keyword scan found no `SCRIPT ERROR`, `Parse Error`, `Invalid call`,
`Invalid get index`, `Resource file not found`, `Failed loading resource`,
or missing-resource entries in
`reports/boss2_autonomous_pressure_runtime_main_scene_smoke.log`.

## Godot MCP Runtime

MCP state:

- Editor connected to `cinderpaw@c1b2`.
- Editor ready on `res://scenes/main.tscn`.
- Project launched through `project_run(mode="main", autosave=false)`.
- `game_capture_ready=true`.

Fresh runtime probe results:

- Runtime nodes found:
  - `/root/Main/Boss2EchoGuardian`
  - `/root/Main/Player`
  - `/root/Main/HUD`
- Boss2 sprite:
  - Class: `AnimatedSprite2D`
  - SpriteFrames:
    `res://assets/characters/boss2_echo_guardian/boss2_echo_guardian_sprite_frames.tres`
  - Frame counts: `idle=3`, `attack=3`, `hurt=3`, `death=3`
- Main-scene start-distance probe:
  - Player reset to `Vector2(300, 456)`
  - Boss2 reset to `Vector2(520, 482)`
  - Start horizontal distance: `220`
  - After one deterministic behavior frame: `217`
  - Diagnostics: `behavior_phase="chase"`, `is_chasing=true`,
    `attack_phase="idle"`, `has_target=true`
- Automatic attack probe:
  - Reached startup without direct `request_attack()` call.
  - Startup diagnostics: `behavior_phase="startup"`,
    `attack_phase="startup"`, `target_distance_x=108`
  - Startup `boss2_echo_swipe` hitbox active: `false`
  - Reached active: `true`
  - Active `boss2_echo_swipe` hitbox active: `true`
- Core Collision/Combat hit probe:
  - Player HP before hit: `100`
  - Player HP after hit: `86`
  - Player HP after duplicate same-frame check: `86`
  - Metadata confirms `source="boss2_echo_guardian"`,
    `weapon_id="boss2_echo_swipe"`, `hitbox_id="boss2_echo_swipe"`,
    `target_id=1`, and `final_damage=14`
- Stale target probe:
  - Target valid before release: `true`
  - Target valid after release: `false`
  - Manual `request_attack()` with released target: `false`
  - Diagnostics after one behavior frame:
    `behavior_phase="idle"`, `attack_phase="idle"`, `has_target=false`,
    `is_chasing=false`
- Defeated flag probe:
  - `set_world_progress_flag("boss_02_echo_guardian_defeated", true)`
    hides and defeats Boss2.
  - Diagnostics: `behavior_phase="defeated"`, `attack_phase="dead"`,
    `is_chasing=false`, `defeated=true`
  - Boss2 moved after defeated flag: `false`
  - Hitbox active after defeated flag: `false`
  - Boss HUD label after defeated flag:
    `垃圾桶鼠王  Phase I  300/300`
  - Reward diagnostics: `reward_available=true`,
    `reward_claim_available=true`, `reward_claimed=false`,
    `boss_visible=false`
- Runtime screenshot save result: `OK`
- Screenshot size: `1280x720`

MCP logs after the clean probe:

- Game log: MCP helper registration and DataManager boss/enemy domain loads
  only.
- Editor log: no entries.

Runtime screenshot:

- `reports/visual/cinderpaw-mcp-boss2-autonomous-pressure-runtime-20260626.png`

The screenshot is nonblank and shows Cinderpaw, Boss2, the Boss2 HUD, and the
Boss2 Double Jump reward source in the main runtime scene.

## Acceptance Mapping

| Acceptance item | Evidence | Status |
| --- | --- | --- |
| Boss2 moves from main-scene start distance while inside aggro | `report_788`, MCP probe | PASS |
| Deterministic `advance_behavior_frames` and diagnostics hooks exist | `report_788`, MCP probe | PASS |
| Boss2 reaches startup without direct `request_attack()` | `report_788`, MCP probe | PASS |
| Startup remains readable with inactive hitbox | `report_788`, MCP probe | PASS |
| Active autonomous hit damages once through Core Collision/Combat | `report_788`, `report_789`, MCP probe | PASS |
| Defeat/restored flag disables pressure and preserves reward/HUD behavior | `report_788`, `report_789`, MCP probe | PASS |
| MCP runtime logs and screenshot verified | Clean logs, screenshot | PASS |

## Residual Risk

This story intentionally does not add Boss2 run/chase art, arena boundaries,
multi-phase AI, or final balancing. Boss2 chase currently uses the existing
`idle` animation while moving; a future visual polish story should generate and
wire a proper `run` or `chase` SpriteFrames animation.
