# Pause Retry Menu Vertical Slice Evidence -- 2026-06-24

## Scope

GDD-driven HUD/UI and death-respawn presentation slice for
`res://scenes/main.tscn`. This is not a formal Epic story close-out because no
death-respawn or HUD/UI epic has been generated yet; it implements the current
playable slice's pause and retry route against `design/gdd/hud-ui.md`,
`design/gdd/death-respawn.md`, and ADR-0011.

## Automated Evidence

- TDD RED: focused HUD test failed because `HUDManager` did not expose menu
  signals or `show_pause_menu()` / `show_retry_menu()` APIs.
- Presentation regression after implementation and layout fix:
  `reports/report_299/` -- 10/10 passing.
- Godot startup parse check: `godot --headless --path . --quit` -- exited 0.

## Godot MCP Runtime Evidence

- MCP server: Godot AI 3.4.2 over `http://127.0.0.1:8000/mcp`.
- Runtime project session: `cinderpaw@c4d7`, Godot `4.6.3-stable`.
- Pause flow:
  - Before Esc: `paused=false`, `menu_visible=false`, `menu_mode=none`.
  - After Esc: `paused=true`, `menu_visible=true`, `menu_mode=pause`,
    `menu_title=Paused`, focused button `Resume`.
  - Screenshot: `reports/visual/cinderpaw-mcp-pause-menu-20260624.png`.
- Resume flow:
  - After second Esc: `paused=false`, `menu_visible=false`, `menu_mode=none`.
- Victory retry flow:
  - After enemy defeat: `flow=victory`, `menu_visible=true`, `menu_mode=retry`,
    `menu_title=Shadow beast defeated`, focused button `Continue`.
  - Screenshot:
    `reports/visual/cinderpaw-mcp-victory-retry-menu-20260624.png`.
- Retry button:
  - After pressing runtime Retry button: scene reloaded to `flow=playing`,
    player HP `100`, enemy HP `3`, `paused=false`, menu hidden.
- Logs:
  - Game log contained only MCP helper registration.
  - Incremental editor log read returned no new errors.

## Remaining Work

- Add settings, save/load, main menu, and final death-summary routes.
- Add final menu audio and controller glyph/iconography.
- Generate formal HUD/UI or death-respawn epics/stories if this slice should be
  closed through the normal story-done process.
