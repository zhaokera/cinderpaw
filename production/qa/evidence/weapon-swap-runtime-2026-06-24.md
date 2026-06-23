# Weapon Swap Runtime Evidence — 2026-06-24

## Scope

- Story: `production/epics/weapon-styles/story-003-weapon-swap-state-machine-combat-adapter.md`
- Runtime integration: MainScene creates `WeaponComponent`, registers `weapon_swap`,
  and syncs weapon changes to HUD plus no-loss progress state.

## Automated Evidence

- RED: `reports/report_315/` —
  `tests/unit/gameplay/main_scene_weapon_swap_runtime_test.gd` failed because
  `weapon_swap` was not registered.
- GREEN: `reports/report_317/` —
  `tests/unit/gameplay/main_scene_weapon_swap_runtime_test.gd` passed 2/2.
- Regression: `reports/report_319/` passed 10/10:
  - `tests/unit/weapon/story_003_weapon_swap_state_machine_test.gd`
  - `tests/unit/gameplay/main_scene_weapon_swap_runtime_test.gd`
  - `tests/unit/gameplay/no_loss_respawn_state_contract_test.gd`
- Startup: `godot --headless --path . --quit-after 1` exited 0.

## Godot MCP Runtime Evidence

- MCP server: Godot AI 3.4.2 over `http://127.0.0.1:8000/mcp`.
- Runtime session: `cinderpaw@c4d7`, Godot `4.6.3-stable (official)`,
  `res://scenes/main.tscn`, `game_capture_ready=true`.
- MCP `game_eval` result:
  - Before: `cat_claw`, HUD `猫爪\nSpecial 0%`
  - Request: `true`
  - After 0.5s: `long_tail`, HUD `长尾刃\nSpecial 0%`
- MCP runtime node check: `Enemy` exists, script path
  `res://src/gameplay/simple_enemy.gd`, HP query returned `3`.
- MCP game log check: source `game` contained only the game-helper registration
  line for run `r108392672`.
- Screenshot: `reports/visual/cinderpaw-mcp-weapon-swap-runtime-20260624.png`.

## Notes

- Backgrounded MCP play sessions did not advance `await RenderingServer.frame_post_draw`;
  visual screenshot is retained as nonblank runtime evidence, while the weapon
  transition itself is verified by deterministic `game_eval` state and HUD reads.
