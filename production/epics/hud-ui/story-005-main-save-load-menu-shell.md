# Story 005: Main Menu + Save/Load Shell

> **Epic**: HUD/UI
> **Status**: Complete
> **Layer**: Presentation
> **Type**: Integration
> **Estimate**: L
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-24

## Context

**GDD**: `design/gdd/hud-ui.md`
**Requirements**: `TR-hud-003`, `TR-hud-008`

## Acceptance Criteria

- [x] Main menu offers new game, continue, load game, settings, and exit.
- [x] Save/load shell lists slots without owning save-file rules.
- [x] Disabled save/load actions communicate why they are unavailable.
- [x] Returning from gameplay to main menu releases pause state and focus.

## Test Evidence

**Required evidence**: UI interaction tests and MainScene smoke.
**Status**: [x] Complete

- TDD RED: focused HUD/MainScene tests first failed on missing main menu,
  save/load shell APIs and signals (`reports/report_344/`).
- GREEN: focused HUD + MainScene menu runtime suite 20/20 passing
  (`reports/report_346/`).
- Regression: HUD settings/runtime + SaveSystem Story001-004 focused suite
  37/37 passing (`reports/report_349/`).
- Runtime smoke: `reports/hud_story005_main_scene_smoke.log` passes with no
  error or warning matches.
- Godot MCP: `cinderpaw@c1b2` ran `res://scenes/main.tscn`; runtime eval
  verified pause -> main menu releases pause, main menu button order/focus,
  four save slots, disabled reasons, empty editor logs, and non-empty game
  screenshot.

## Blocker Resolution

SaveSystem Story001-004 now provide `SaveInfo`, slot metadata, autosave slot 0,
manual slot 1-3 save/load, and MainScene runtime handoff. SceneManagement is
still not formalized, so this story intentionally implements a presentation
shell plus MainScene adapter signals only; real scene transition and async
loading remain out of scope.

## Dependencies

- Depends on: SaveSystem Epic, SceneManagement Epic, Story 004 settings menu.
