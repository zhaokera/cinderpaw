# Story 004: Dodge Afterimage + Cinderpaw Dodge Animation Slice

> **Epic**: Combat Presentation
> **Status**: Complete
> **Layer**: Presentation
> **Type**: Visual/Feel
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-24

## Context

**GDD**: `design/gdd/combat-presentation.md`, `design/gdd/feline-combat.md`
**Requirements**: `TR-combatfx-004`, `TR-combatfx-010`
**ADR Governing Implementation**: ADR-0001: Autoload architecture; ADR-0002:
Signal communication; ADR-0005: Combat state machine architecture

Story 003 replaced the static player image with idle/run/attack
`AnimatedSprite2D + SpriteFrames`. The next player-facing action readability gap
is dodge: runtime dodge currently changes velocity and alpha, but does not play
a dodge animation or leave the 3-frame afterimage trail specified by the GDD.

## Acceptance Criteria

- [x] Cinderpaw has a `dodge` SpriteFrames animation with three transparent,
  same-size frames under `assets/characters/cinderpaw/dodge/`.
- [x] Player dodge can be requested through a testable runtime API and plays the
  `dodge` animation without breaking existing dodge cooldown/invincibility
  behavior.
- [x] Starting a player dodge emits presentation metadata without moving
  afterimage spawning into Core gameplay code.
- [x] MainScene routes player dodge-start metadata to CombatPresentation.
- [x] CombatPresentation spawns exactly three textured afterimage sprites at
  50%/30%/10% alpha, using the current player frame texture and facing.
- [x] Godot MCP runs `res://scenes/main.tscn`, verifies runtime `dodge`
  SpriteFrames, afterimage count/alpha values, clean logs, and captures a
  nonblank screenshot.

## Out of Scope

- Perfect-dodge gold variant.
- Dash/high-speed afterimage modes beyond player dodge.
- Hitbox timing tied to animation frames.
- Full jump/fall/hurt/death/revive animation coverage.

## Test Evidence

**Required evidence**:
- `tests/unit/gameplay/player_dodge_animation_test.gd`
- `tests/unit/gameplay/main_scene_player_dodge_afterimage_test.gd`
- `tests/unit/presentation/combat_presentation_test.gd`

**Status**: [x] RED/GREEN + MCP runtime evidence captured in
`production/qa/evidence/dodge-afterimage-cinderpaw-dodge-animation-2026-06-24.md`

## Dependencies

- Depends on: Combat Presentation Story 003 Cinderpaw Player Frame Animation.
- Unlocks: perfect-dodge gold afterimage, dash afterimages, and fuller player
  animation-state coverage.
