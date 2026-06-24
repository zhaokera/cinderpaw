# Epic: HUD/UI

> **Layer**: Presentation
> **GDD**: design/gdd/hud-ui.md
> **Architecture Module**: HUDManager
> **Status**: In Progress
> **Stories**: 6 stories

## Overview

Implement the MVP interface shell that keeps combat readable while still
surfacing critical player state: HP, boss HP, weapon/cooldown, currency,
notifications, pause/retry menus, and optional death lesson summaries. HUD/UI is
Presentation-only: it consumes signals and state snapshots from Core/Feature
systems without owning combat, save, scene, or economy rules.

## Governing ADRs

| ADR | Decision Summary | Engine Risk |
|-----|------------------|-------------|
| ADR-0001: Autoload architecture | HUD is scene-mounted Presentation, not a global state owner. | LOW |
| ADR-0002: Signal communication | HUD actions emit typed signals back to MainScene adapters. | LOW |
| ADR-0011: UI focus management | Godot 4.6 dual-focus risk; menu controls must explicitly grab and release focus. | HIGH |

## GDD Requirements

| TR-ID | Requirement | ADR Coverage |
|-------|-------------|--------------|
| TR-hud-001 | Combat HUD shows HP, weapon, cooldown, boss HP, currency, minimap-ready slots. | ADR-0001 ⚠️ partial |
| TR-hud-002 | HUD visibility states: combat, exploring, dialogue, cutscene, boss, menu. | ADR-0002 ⚠️ partial |
| TR-hud-003 | Pause, settings, save/load, main menu entry points. | ADR-0011 ⚠️ |
| TR-hud-004 | HP/menu/damage-number animations meet readability rules. | ADR-0011 ⚠️ partial |
| TR-hud-005 | Colorblind mode, HUD scale, subtitles, damage number toggle. | ADR-0011 ⚠️ |
| TR-hud-006 | HUD render and menu open performance budgets. | ADR-0011 ⚠️ |
| TR-hud-007 | Boss phase markers and boss HP state. | ADR-0002 ⚠️ partial |
| TR-hud-008 | MVP screen list: combat HUD through weapon upgrade UI. | ADR-0011 ⚠️ partial |

## Stories

| # | Story | Type | Status | ADR |
|---|-------|------|--------|-----|
| 001 | Combat HUD Baseline | UI | Complete | ADR-0001, ADR-0002 |
| 002 | Pause + Retry Menu Focus Loop | UI | Complete | ADR-0002, ADR-0011 |
| 003 | Battle Summary Lesson Panel | UI | Complete | ADR-0002, ADR-0011 |
| 004 | Settings + Accessibility Controls | UI | Complete | ADR-0011 |
| 005 | Main Menu + Save/Load Shell | Integration | Blocked by SaveSystem Epic | ADR-0011 |
| 006 | HUD Scale + Colorblind Mode | UI | Ready | ADR-0011 |

## Definition of Done

This epic is complete when:
- All six stories are implemented and closed with evidence.
- Combat HUD and menus are usable by keyboard/gamepad through Godot 4.6 focus.
- Colorblind and scale settings are persisted or explicitly handed off to
  SaveSystem.
- Runtime smoke is captured through Godot MCP when available.

## Next Step

Continue with Story 006, the HUD scale/colorblind validation and persistence
handoff, because Story 004 now provides the runtime settings controls and
toggles.
