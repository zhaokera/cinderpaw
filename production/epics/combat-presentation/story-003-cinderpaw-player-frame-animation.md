# Story 003: Cinderpaw Player Frame Animation Slice

> **Epic**: Combat Presentation
> **Status**: Complete
> **Layer**: Presentation
> **Type**: Visual/Feel
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-24

## Context

**GDD**: `design/gdd/combat-presentation.md`,
`design/gdd/feline-combat.md`
**Requirements**: `TR-combatfx-010`, player readability gap from
`design/assets/entity-inventory.md`
**ADR Governing Implementation**: ADR-0001: Autoload architecture; ADR-0002:
Signal communication; ADR-0005: Combat state machine architecture

The playable cat warrior is still represented by a static `Sprite2D`, which
makes the current action-game slice read as a prototype block instead of a
character. This story establishes the project-wide frame-animation contract for
Cinderpaw while preserving the existing player controller, combat chain, and
visual feedback behavior.

## Acceptance Criteria

- [x] The player visual node named `Sprite` is an `AnimatedSprite2D` backed by a
  `SpriteFrames` resource, not a static `Sprite2D`.
- [x] Runtime player art is stored under
  `assets/characters/cinderpaw/<animation>/` with continuous transparent PNG
  frames using matching canvas size and anchor.
- [x] `scenes/characters/cinderpaw.tscn` and `src/characters/cinderpaw.gd`
  exist and provide at least `idle`, `run`, and `attack` frame animations.
- [x] `PlayerController` plays idle/run/attack animations from gameplay state
  without breaking `flip_h`, tint, dodge transparency, damage flash, or respawn
  invincibility feedback.
- [x] New visual frames are derived from image generation and imported through
  the Godot asset pipeline.
- [x] Godot MCP loads and runs `res://scenes/main.tscn`, verifies the
  `AnimatedSprite2D`/`SpriteFrames` runtime state, checks logs, and captures a
  nonblank screenshot.

## Out of Scope

- Full jump/fall/dodge/hurt/death/revive animation coverage.
- Animation-frame-authored hitboxes.
- Audio cues for movement or attacks.
- Replacing enemy art.

## Test Evidence

**Required evidence**:
- `tests/unit/gameplay/player_character_animation_test.gd`
- `tests/unit/gameplay/player_respawn_visual_feedback_test.gd`
- `tests/unit/gameplay/main_scene_player_attack_core_chain_test.gd`

**Status**: [x] RED/GREEN + MCP runtime evidence complete

- RED: `reports/report_345/` — failed because `$Sprite` is not
  `AnimatedSprite2D`.
- GREEN: `tests/unit/gameplay/player_character_animation_test.gd` passed `3/3`
  (`reports/report_346/`).
- Regression: focused gameplay/presentation suites passed `17/17`
  (`reports/report_344/`) across player frame animation, respawn visual
  feedback, runtime attack core chain, and CombatPresentation.
- Headless smoke: `godot --headless --path . --scene res://scenes/main.tscn
  --fixed-fps 60 --quit-after 120 --log-file
  reports/cinderpaw_player_frame_animation_main_scene_smoke.log` exited `0`;
  log scan found no error/warning lines.
- Godot MCP: session `cinderpaw@c1b2`, Godot `4.6.3-stable`, ran
  `res://scenes/main.tscn`; runtime probe returned `$Player/Sprite` class
  `AnimatedSprite2D`, script class `CinderpawCharacter`, animations
  `attack/idle/run`, frame counts `3/3/3`, 96x96 frame sizes,
  `request_attack() = true`, and animation after attack `attack`.
- Screenshot:
  `reports/visual/cinderpaw-mcp-player-frame-animation-runtime-20260624.png`.

## Completion Notes

**Completed**: 2026-06-24
**Criteria**: 6/6 passing
**Deviations**: Full jump/fall/dodge/hurt/death/revive animation coverage is
tracked as remaining character-animation scope, not part of this vertical slice.
**QA Evidence**:
`production/qa/evidence/cinderpaw-player-frame-animation-2026-06-24.md`

## Dependencies

- Depends on: Combat Presentation Story 002 textured player attack feedback.
- Unlocks: dodge afterimages, richer attack timing, and full character
  animation coverage.
