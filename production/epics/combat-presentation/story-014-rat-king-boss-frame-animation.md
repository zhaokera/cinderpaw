# Story 014: Rat King Boss Frame Animation Slice

> **Epic**: Combat Presentation
> **Status**: Complete
> **Layer**: Presentation
> **Type**: Visual/Feel
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-25

## Context

**GDD**: `design/gdd/boss-config.md`, `design/art/art-bible.md`,
`design/gdd/combat-presentation.md`
**Requirements**: Rat King visual identity from `design/gdd/boss-config.md`;
boss readability gap from `design/assets/entity-inventory.md`

**ADR Governing Implementation**: ADR-0001: Autoload architecture; ADR-0002:
Signal communication; ADR-0005: Combat state machine architecture

The Rat King exists in BossConfig data, but the visual inventory still marks it
as `Needed`. This keeps the first boss as an abstract data object rather than a
visible action-game opponent. This story creates the first Rat King character
animation asset slice using the project `AnimatedSprite2D + SpriteFrames`
contract while keeping runtime BossConfig/AI integration out of scope.

## Acceptance Criteria

- [x] `scenes/characters/rat_king.tscn` and `src/characters/rat_king.gd` exist
  and expose a presentation-only `AnimatedSprite2D` character surface.
- [x] Rat King animation frames are image-generated, alpha-matted, same-size
  transparent PNGs stored under `assets/characters/rat_king/<animation>/`.
- [x] `assets/characters/rat_king/rat_king_sprite_frames.tres` provides
  `idle`, `attack_tell`, `attack`, `hurt`, `death`, `phase_1_intro`,
  `phase_2_rebuild`, and `phase_3_overload`, with at least 3 frames each.
- [x] The Rat King source image and import summary are recorded in
  `design/assets/asset-manifest.md`, and entity inventory status is updated to
  `Partial`.
- [x] Godot imports the PNGs through the asset pipeline and automated tests
  prove the scene loads, frames are textured, and all canvases match.
- [x] Godot MCP validates the character scene/runtime resource state, checks
  logs, and captures visual evidence when available.

## Out of Scope

- Replacing `MainScene/Enemy` with a runtime Rat King boss.
- Implementing `RatKingBoss` gameplay, BossConfig wiring, AI scheduling,
  summons, arena changes, rewards, or phase damage windows.
- Full specialized Boss attack animation coverage beyond this first slice;
  later covered by Story015 with data-aligned `charge`, `claw_swipe`,
  `summon_minion`, `slam`, and `berserk_combo` animations.
- Boss theme, SFX, or HUD phase text changes.

## Test Evidence

**Required evidence**:
- `tests/unit/gameplay/rat_king_character_animation_test.gd`

**Status**: [x] RED/GREEN + import + MCP runtime evidence complete

- RED: `reports/report_463/` — failed because Rat King scene, script, and
  SpriteFrames resource did not exist.
- Import correction: `reports/report_464/` exposed missing Godot import sidecar
  files for new PNG frames; resolved by running the Godot import pipeline.
- GREEN: `reports/report_466/` — Rat King character animation contract passed
  `2/2`, `0` errors, `0` failures.

## Completion Notes

**Completed**: 2026-06-25
**Criteria**: 6/6 passing
**Deviations**: This is a visual asset slice. Runtime BossConfig/AI integration
is deliberately deferred so the existing Shadow Beast runtime chain remains
stable.
**QA Evidence**:
`production/qa/evidence/rat-king-boss-frame-animation-2026-06-25.md`

## Dependencies

- Depends on: Boss Configuration Epic core data contract, Combat Presentation
  frame-animation rules.
- Unlocks: `RatKingBoss` runtime scene, MainScene boss replacement, boss phase
  animation routing, boss HUD/audio integration, and full specialized attack
  animation coverage.
