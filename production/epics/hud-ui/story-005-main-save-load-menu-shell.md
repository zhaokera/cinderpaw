# Story 005: Main Menu + Save/Load Shell

> **Epic**: HUD/UI
> **Status**: Blocked
> **Layer**: Presentation
> **Type**: Integration
> **Estimate**: L
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-24

## Context

**GDD**: `design/gdd/hud-ui.md`
**Requirements**: `TR-hud-003`, `TR-hud-008`

## Acceptance Criteria

- [ ] Main menu offers new game, continue, load game, settings, and exit.
- [ ] Save/load shell lists slots without owning save-file rules.
- [ ] Disabled save/load actions communicate why they are unavailable.
- [ ] Returning from gameplay to main menu releases pause state and focus.

## Test Evidence

**Required evidence**: UI interaction tests and MainScene smoke.
**Status**: [ ] Blocked

## Blocker

Save/load behavior depends on the SaveSystem Epic and SceneManagement Epic not
yet formalized in production epics.

## Dependencies

- Depends on: SaveSystem Epic, SceneManagement Epic, Story 004 settings menu.
