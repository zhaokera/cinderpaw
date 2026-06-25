# Story 015: Rat King Specialized Attack Animation Expansion

> **Epic**: Combat Presentation
> **Status**: Complete
> **Layer**: Presentation
> **Type**: Visual/Feel
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-25

## Context

**GDD**: `design/gdd/boss-config.md`, `design/gdd/combat-presentation.md`,
`design/art/art-bible.md`
**Requirements**: Rat King BossConfig attack identities; action-game frame
animation readability rule in `AGENTS.md`

**ADR Governing Implementation**: ADR-0001: Autoload architecture; ADR-0002:
Signal communication; ADR-0005: Combat state machine architecture

Story014 gave Rat King a visible boss body and shared attack animation states.
Story008 then connected BossConfig attack scheduling, but every Rat King attack
still presented through generic `attack_tell` / `attack` frames. This story
adds data-aligned specialized attack animations so the playable boss no longer
reads as one repeated generic pose.

## Acceptance Criteria

- [x] `rat_king_sprite_frames.tres` includes `charge`, `claw_swipe`,
  `summon_minion`, `slam`, and `berserk_combo`, with at least 3 textured frames
  per animation.
- [x] New PNG frames are image-generated, transparent 192x192 files stored under
  `assets/characters/rat_king/<animation>/rat_king_<animation>_000.png`
  through `_002.png`.
- [x] Rat King runtime maps BossConfig / AI pattern ids to matching animation
  names instead of generic shared attack frames.
- [x] Runtime attack requests for `charge`, `claw_swipe`, `slam`, and
  `berserk_combo` preserve existing hitbox metadata and activate the expected
  hitbox.
- [x] `summon_minion` has a visible presentation hook without requiring live
  minion spawn implementation in this Presentation story.
- [x] Godot import, focused tests, related regression, headless smoke, and MCP
  runtime verification prove the animations load and play in the running game.

## Out of Scope

- Physical charge movement, jump-slam displacement, multi-hit combo movement,
  live phase 2 minion spawning, arena mutation, boss music/SFX, and final reward
  presentation.
- Changing BossConfig pattern selection weights or attack data schema.
- Replacing other enemy or player animation states.

## Test Evidence

**Required evidence**:
- `tests/unit/gameplay/rat_king_character_animation_test.gd`
- `tests/unit/gameplay/rat_king_specialized_attack_animation_test.gd`
- `tests/unit/gameplay/rat_king_boss_runtime_contract_test.gd`
- `tests/unit/gameplay/main_scene_enemy_attack_core_chain_test.gd`
- `tests/unit/gameplay/main_scene_visual_contract_test.gd`

**Status**: [x] RED/GREEN + import + MCP runtime evidence complete

- RED: `reports/report_480/` — failed because the five specialized Rat King
  animation sets were not present in `rat_king_sprite_frames.tres`.
- GREEN focused: `reports/report_482/` — `15/15` passing after SpriteFrames and
  runtime pattern mapping were implemented.
- Related regression: `reports/report_484/` — Boss, AI, Rat King gameplay, and
  main-scene visual suites passed `82/82`, `0` failures.
- Headless smoke: `reports/rat_king_specialized_attack_animation_main_scene_smoke.log`
  had no error/warning keyword matches.
- MCP runtime probe verified `/Main/Enemy/Sprite` is `AnimatedSprite2D`, the
  five specialized animations each have 3 frames, pattern ids map to matching
  animation names, hitbox metadata stays aligned, game/editor logs are clean,
  and a nonblank game screenshot shows Rat King in the playable arena.

## Completion Notes

**Completed**: 2026-06-25
**Criteria**: 6/6 passing
**Deviations**: `summon_minion` is intentionally a visual presentation hook in
this story. The live summon adapter remains BossConfig gameplay scope.
**QA Evidence**:
`production/qa/evidence/rat-king-specialized-attack-animation-2026-06-25.md`

## Dependencies

- Depends on: Combat Presentation Story014, Boss Configuration Story007, Boss
  Configuration Story008.
- Unlocks: live summon presentation sync, arena-mutation visuals, boss SFX/music
  state transitions, and final Rat King encounter polish.
