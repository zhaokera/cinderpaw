# Story 006: Cinderpaw Jump and Fall Animation Slice

> **Epic**: Combat Presentation
> **Status**: Complete
> **Layer**: Presentation
> **Type**: Visual/Feel
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-24

## Context

**GDD**: `design/gdd/combat-presentation.md`,
`design/gdd/feline-combat.md`, `design/gdd/player-abilities.md`
**Requirements**: `TR-combatfx-010`
**ADR Governing Implementation**: ADR-0001: Autoload architecture; ADR-0002:
Signal communication; ADR-0005: Combat state machine architecture

Stories 003 through 005 established Cinderpaw `AnimatedSprite2D +
SpriteFrames` coverage for idle, run, attack, dodge, hurt, death, and revive.
The remaining visible player movement gap is airborne readability: jumping and
falling still reuse grounded idle/run visuals. This story adds authored
image-generated air-state frames while preserving movement, combat, dodge,
damage, death, and revive state priority.

## Acceptance Criteria

- [x] Cinderpaw has `jump` and `fall` SpriteFrames animations with three
  transparent 96x96 PNG frames each under
  `assets/characters/cinderpaw/<animation>/`.
- [x] New frames are generated from image generation, retained as workspace
  source sheets, chroma-keyed to alpha, sliced, imported, and referenced by
  `assets/characters/cinderpaw/cinderpaw_sprite_frames.tres`.
- [x] Upward airborne player velocity plays `jump`.
- [x] Downward airborne player velocity plays `fall`.
- [x] Air animations do not override higher-priority attack, dodge, hurt,
  death, or revive animation states.
- [x] Godot MCP runs `res://scenes/main.tscn`, verifies SpriteFrames and
  runtime air-state transitions, checks logs, and captures a nonblank
  screenshot.

## Out of Scope

- Double-jump ability unlock logic.
- Landing dust, landing recovery, or coyote-time gameplay changes.
- Animation-frame-authored hitboxes.
- Replacing the existing movement controller physics.

## Test Evidence

**Required evidence**:
- `tests/unit/gameplay/player_air_animation_test.gd`
- `tests/unit/gameplay/player_character_animation_test.gd`
- `tests/unit/gameplay/player_dodge_animation_test.gd`
- `tests/unit/gameplay/player_hurt_death_revive_animation_test.gd`

**Status**: [x] RED/GREEN + MCP runtime evidence captured in
`production/qa/evidence/cinderpaw-jump-fall-animation-2026-06-24.md`

## Dependencies

- Depends on: Combat Presentation Stories 003, 004, and 005.
- Unlocks: landing dust, double-jump visual polish, and full player movement
  animation readability review.
