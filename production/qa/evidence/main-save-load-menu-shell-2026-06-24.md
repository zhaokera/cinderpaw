# QA Evidence: HUD/UI Story 005 Main Save/Load Menu Shell

Date: 2026-06-24
Story: `production/epics/hud-ui/story-005-main-save-load-menu-shell.md`
Scope: HUD main menu, save/load shell, disabled action reasons, and MainScene
pause release adapter.

## Result

PASS

## Coverage

- `HUDManager.show_main_menu()` displays New Game, Continue, Load Game,
  Settings, and Exit.
- `HUDManager.show_save_load_menu()` renders caller-provided slot metadata
  without reading or writing save files.
- Disabled Continue/Load/Save actions expose user-facing unavailable reasons.
- MainScene receives `menu_main_menu_requested`, releases `SceneTree.paused`,
  and restores focus to New Game.
- SaveSystem remains the only owner of save slot and file rules; HUD consumes
  `SaveInfo`-style dictionaries.

## Automated Evidence

- RED: `godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/presentation/hud_manager_test.gd -a res://tests/unit/gameplay/main_scene_save_load_menu_runtime_test.gd --ignoreHeadlessMode`
  - Exit 100.
  - First failures were missing `show_main_menu`,
    `get_menu_button_texts`, `get_disabled_menu_button_reasons`, and
    `menu_main_menu_requested`.
  - Report: `reports/report_344/`.
- GREEN focused: same focused command.
  - Exit 0.
  - Result: 20/20 passing.
  - Report: `reports/report_346/`.
- Focused regression:
  - Command included `hud_manager_test.gd`, `main_scene_hud_settings_runtime_test.gd`,
    `main_scene_save_load_menu_runtime_test.gd`, and SaveSystem Story001-004 tests.
  - Exit 0.
  - Result: 37/37 passing.
  - Report: `reports/report_349/`.
- Headless smoke:
  - `godot --headless --path . --scene res://scenes/main.tscn --fixed-fps 60 --quit-after 120 --log-file reports/hud_story005_main_scene_smoke.log`
  - Exit 0.
  - Log scan found no `ERROR`, `SCRIPT ERROR`, `WARNING`, `ERR_`, `Invalid`, or `failed` matches.

## Godot MCP Runtime Evidence

- Session: `cinderpaw@c1b2`, Godot 4.6.3, `res://scenes/main.tscn`.
- Runtime eval verified:
  - Pause menu sets `paused=true`, mode `pause`, focus `Resume`.
  - Main menu sets `paused=false`, mode `main_menu`, title `Cinderpaw`,
    focus `New Game`, buttons `New Game / Continue / Load Game / Settings / Exit`.
  - Main menu Settings returns to `main_menu` with focus restored to Settings.
  - No-save main menu disables Continue and Load Game with
    `No save file available`.
  - Save/load shell mode `save_load`, title `Save / Load`, focus `Back`.
  - Slot labels: `Autosave: Empty`, `Slot 1: Manual Save | HP 91 | cat_claw | Gears 4`,
    `Slot 2: Empty`, `Slot 3: Empty`.
  - Disabled reasons: `Load Autosave -> No autosave available`,
    `Save Slot 1 -> Saving requires a save point`.
- Runtime scene tree included `/Main/HUD/HudRoot/MenuOverlay` and
  player/enemy `AnimatedSprite2D` nodes.
- Game log after clear contained only the MCP capture registration line.
- Editor log after clear was empty.
- MCP game screenshot was non-empty at 960x540 and showed the save/load shell
  with focus and disabled states.

## Notes

SceneManager is still not formalized in production epics. This story therefore
implements the menu shell and MainScene adapter only; real title scene loading,
continue-to-scene handoff, and async scene transitions remain future work.
