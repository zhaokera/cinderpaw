# Story 005: Cinderpaw Hurt, Death, and Revive Animation Slice

> **Epic**: Combat Presentation
> **Status**: Complete
> **Layer**: Presentation
> **Type**: Visual/Feel
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-24

## Context

**GDD**: `design/gdd/combat-presentation.md`,
`design/gdd/death-respawn.md`, `design/gdd/health-death.md`
**Requirements**: `TR-combatfx-010`, `TR-respawn-001`, `TR-respawn-007`
**ADR Governing Implementation**: ADR-0001: Autoload architecture; ADR-0002:
Signal communication; ADR-0005: Combat state machine architecture; ADR-0019:
Health component

Story 003 established Cinderpaw `AnimatedSprite2D + SpriteFrames` for
idle/run/attack, and Story 004 added dodge animation plus afterimages. Damage,
death, and revive still read as tint/alpha changes over the base animation.
This story adds authored player state frames for hurt, death, and revive while
preserving Core health/death ownership and the existing respawn invincibility
feedback.

## Acceptance Criteria

- [x] Cinderpaw has `hurt`, `death`, and `revive` SpriteFrames animations with
  three transparent 96x96 PNG frames each under
  `assets/characters/cinderpaw/<animation>/`.
- [x] New frames are generated from image generation, retained as workspace
  source sheets, chroma-keyed to alpha, sliced, imported, and referenced by
  `assets/characters/cinderpaw/cinderpaw_sprite_frames.tres`.
- [x] Non-lethal player damage plays `hurt` without relying on generic HP-change
  callbacks that could also fire for healing.
- [x] Lethal player damage plays `death` from the HealthComponent death signal.
- [x] `PlayerController.respawn_at()` plays `revive` and keeps the existing 50%
  revive HP plus 120-frame invincibility flash.
- [x] Hurt, death, and revive animations are briefly locked so the normal
  idle/run updater does not overwrite them on the next physics frame.
- [x] Godot MCP runs `res://scenes/main.tscn`, verifies SpriteFrames and runtime
  state transitions, checks logs, and captures a nonblank screenshot.

## Out of Scope

- Jump and fall animation coverage.
- Death dissolve particles and revive ring VFX beyond the revive frame art.
- Death screen layout or battle-summary tuning.
- Animation-frame-authored hitboxes.

## Test Evidence

**Required evidence**:
- `tests/unit/gameplay/player_hurt_death_revive_animation_test.gd`
- `tests/unit/gameplay/player_character_animation_test.gd`
- `tests/unit/gameplay/player_dodge_animation_test.gd`
- `tests/unit/gameplay/player_respawn_visual_feedback_test.gd`
- `tests/unit/gameplay/game_flow_controller_test.gd`

**Status**: [x] RED/GREEN + MCP runtime evidence captured in
`production/qa/evidence/cinderpaw-hurt-death-revive-animation-2026-06-24.md`

## Dependencies

- Depends on: Combat Presentation Stories 003 and 004; Death & Respawn Stories
  001 and 002.
- Unlocks: jump/fall animation coverage, death dissolve VFX, revive ring VFX,
  and tighter animation-state priority work.
