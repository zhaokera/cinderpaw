# QA Evidence: Old Factory Return Patrol Reward Cache

> **Story**: Player Abilities Story041
> **Date**: 2026-06-30
> **Engine**: Godot `4.7.stable.official.5b4e0cb0f`
> **Scene**: `res://scenes/factory_route_transition_shell.tscn`

## Automated Tests

- RED focused:
  - Command:
    `"/Applications/Godot 2.app/Contents/MacOS/Godot" --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/old_factory_return_patrol_reward_cache_test.gd --ignoreHeadlessMode`
  - Report: `reports/report_931/`
  - Result: expected failure `1/1`, missing new return cache asset/API.
- GREEN focused:
  - Same focused command.
  - Report: `reports/report_932/`
  - Result: `3/3`, `0` errors, `0` failures, `0` orphans.
- Related regression:
  - Command:
    `"/Applications/Godot 2.app/Contents/MacOS/Godot" --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/old_factory_return_patrol_reward_cache_test.gd -a res://tests/unit/gameplay/old_factory_return_patrol_ambush_test.gd -a res://tests/unit/gameplay/old_factory_service_lift_handoff_test.gd -a res://tests/unit/gameplay/old_factory_service_lift_scene_manager_exit_test.gd -a res://tests/unit/gameplay/factory_route_runtime_roundtrip_test.gd -a res://tests/unit/gameplay/factory_route_return_prompt_test.gd -a res://tests/unit/gameplay/scrap_roost_return_hub_runtime_test.gd -a res://tests/unit/gameplay/old_factory_entrance_room_clear_runtime_test.gd --ignoreHeadlessMode`
  - Report: `reports/report_933/`
  - Result: `18/18`, `0` errors, `0` failures, `0` orphans.

## Asset Import

- Source image:
  `assets/generated/source/old_factory_return_patrol_reward_cache_imagegen_20260630.png`
- Alpha source:
  `assets/generated/source/old_factory_return_patrol_reward_cache_alpha_20260630.png`
- Metadata:
  `assets/generated/source/old_factory_return_patrol_reward_cache_imagegen_20260630.json`
- Runtime PNG:
  `assets/environment/old_factory_return_patrol_reward_cache/env_old_factory_return_patrol_reward_cache_claimable_256.png`
- Import command:
  `"/Applications/Godot 2.app/Contents/MacOS/Godot" --headless --path . --import --quit-after 1`
- Result: imported runtime/source PNGs on Godot 4.7 without resource-load errors.

## Headless Smoke

- Command:
  `"/Applications/Godot 2.app/Contents/MacOS/Godot" --headless --path . --scene res://scenes/factory_route_transition_shell.tscn --fixed-fps 60 --quit-after 3 --log-file reports/old_factory_return_patrol_reward_cache_factory_scene_smoke.log`
- Result: exit code `0`.
- Log scan:
  - No `SCRIPT ERROR`
  - No `Parse Error`
  - No `Invalid call`
  - No `Invalid access`
  - No `Failed loading resource`
  - No `Resource file not found`
- Note: terminal showed known Godot headless shutdown ObjectDB/resource-at-exit
  noise; the smoke log did not contain project script or resource errors.

## Godot MCP Runtime Probe

- MCP session:
  - Godot version: `4.7-stable (official)`
  - Project: `废土喵影 (Cat Shadow Wasteland)`
  - Game helper: live
- Runtime scene tree confirmed:
  - `FactoryReturnPatrolRewardCache`
  - `FactoryReturnPatrolRewardCache/Visual`
  - `FactoryReturnPatrolRewardCache/PromptLabel`
  - `FactoryReturnPatrolRewardCache/InteractionArea`
  - `FactoryReturnSparkRat/Sprite` as `AnimatedSprite2D`
- Probe before patrol clear:
  - `cache_id="old_factory_return_patrol_cache"`
  - `visible=true`
  - `available=false`
  - `claim_available=false`
  - `prompt_text="Clear patrol"`
  - `FactoryServiceLift.prompt_text="Clear patrol"`
  - objective `clear_return_patrol`
- Probe after restoring patrol-defeated state:
  - `available=true`
  - `claim_available=true`
  - `prompt_text="+15 Gears"`
  - objective `return_patrol_cleared`
- Probe claim:
  - `claim_ok=true`
  - `duplicate_claim=false`
  - reward payload:
    `cache_id="old_factory_return_patrol_cache"`, `gears=15`,
    `source="old_factory_return_patrol_cache"`
  - local state:
    `factory_return_patrol_reward_cache_claimed=true`
    and `last_return_patrol_reward_cache_reward` persisted.
- Logs after clearing the earlier eval-probe warning:
  - Game log: helper registration only.
  - Editor log: no entries.
- Screenshot:
  - `reports/visual/cinderpaw-mcp-old-factory-return-patrol-reward-cache-20260630.png`

## Verdict

PASS. Story041 adds a generated, visible, once-only Old Factory return-patrol
reward cache, preserves Story040 service-lift lockout behavior, and keeps all
reward state scene-local.
