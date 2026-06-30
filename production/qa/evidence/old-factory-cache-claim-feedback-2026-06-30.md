# QA Evidence: Old Factory Cache Claim Feedback

> **Story**: Player Abilities Story042
> **Date**: 2026-06-30
> **Engine**: Godot `4.7.stable.official.5b4e0cb0f`
> **Scene**: `res://scenes/factory_route_transition_shell.tscn`

## Automated Tests

- RED focused:
  - Command:
    `"/Applications/Godot 2.app/Contents/MacOS/Godot" --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/old_factory_cache_claim_feedback_test.gd --ignoreHeadlessMode`
  - Report: `reports/report_934/`
  - Result: expected failure. The entrance cache claim route label was still
    `Reach Deep Guard`, and claim feedback diagnostics were missing.
- GREEN focused:
  - Same focused command.
  - Report: `reports/report_935/`
  - Result: `2/2`, `0` errors, `0` failures, `0` orphans.
- Related regression:
  - Command: ran each target test file with the same GdUnit4 CLI command.
  - Reports: `reports/report_936/` through `reports/report_945/`.
  - Result: `22/22`, `0` errors, `0` failures.
  - Covered files:
    `old_factory_cache_claim_feedback_test.gd`,
    `old_factory_entrance_room_clear_runtime_test.gd`,
    `old_factory_return_patrol_reward_cache_test.gd`,
    `old_factory_return_patrol_ambush_test.gd`,
    `old_factory_route_objective_handoff_test.gd`,
    `old_factory_service_lift_handoff_test.gd`,
    `old_factory_service_lift_scene_manager_exit_test.gd`,
    `factory_route_runtime_roundtrip_test.gd`,
    `factory_route_return_prompt_test.gd`, and
    `scrap_roost_return_hub_runtime_test.gd`.
  - Note: the factory return prompt and Scrap Roost hub tests still show known
    Godot ObjectDB/resource-at-exit warnings after passing; this story did not
    introduce test failures or script/resource load errors.
- Post-refactor verification:
  - Reports: `reports/report_946/` through `reports/report_950/`.
  - Result: `13/13`, `0` errors, `0` failures.
  - Covered files:
    `old_factory_cache_claim_feedback_test.gd`,
    `old_factory_entrance_room_clear_runtime_test.gd`,
    `old_factory_return_patrol_reward_cache_test.gd`,
    `old_factory_return_patrol_ambush_test.gd`, and
    `old_factory_service_lift_handoff_test.gd`.
  - Purpose: rechecked focused behavior and highest-risk Old Factory
    regressions after tightening claim feedback to avoid duplicate recording
    when the cache signal and scene API both observe the same claim.

## Godot MCP Runtime Probe

- MCP session:
  - Godot version: `4.7-stable (official)`
  - Project: `废土喵影 (Cat Shadow Wasteland)`
  - Game helper: live
- Runtime scene tree confirmed:
  - `RouteLabel`
  - `FactoryCombatCache/Visual`
  - `FactoryCombatCache/PromptLabel`
  - `FactoryCombatCache/InteractionArea`
  - `FactoryReturnPatrolRewardCache/Visual`
  - `FactoryReturnPatrolRewardCache/PromptLabel`
  - `FactoryReturnPatrolRewardCache/InteractionArea`
- Entrance cache claim probe:
  - `claim_ok=true`
  - `duplicate_ok=false`
  - `feedback_unchanged_after_duplicate=true`
  - `route_label_visible=true`
  - `route_label_text="Cache Claimed +10 Gears"`
  - `last_cache_claim_feedback`:
    `cache_id="old_factory_entrance_cache"`, `gears=10`,
    `source="old_factory_combat_cache"`,
    `text="Cache Claimed +10 Gears"`
- Return patrol reward cache claim probe:
  - `claim_ok=true`
  - `duplicate_ok=false`
  - `feedback_unchanged_after_duplicate=true`
  - `route_label_visible=true`
  - `route_label_text="Return Cache Claimed +15 Gears"`
  - `last_claim_feedback`:
    `cache_id="old_factory_return_patrol_cache"`, `gears=15`,
    `source="old_factory_return_patrol_cache"`,
    `text="Return Cache Claimed +15 Gears"`
- Logs:
  - Game log: helper registration only.
  - Editor log: no entries.
- Screenshot:
  - MCP `editor_screenshot(source="game")` captured a non-empty Old Factory
    frame with `Return Cache Claimed +15 Gears` visible over the scene.

## Verdict

PASS. Story042 makes both Old Factory cache rewards readable at the moment of
claim, keeps reward feedback scene-local, rejects duplicate claims, and avoids
global economy/HUD scope.
