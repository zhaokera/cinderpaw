# Story 007: Rat King Runtime MainScene Replacement

> **Epic**: Boss Configuration
> **Status**: Complete
> **Layer**: Core / Integration
> **Type**: Integration + Visual/Feel
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-25

## Context

**GDD**: `design/gdd/boss-config.md`, `design/gdd/feline-combat.md`,
`design/gdd/combat-presentation.md`, `design/art/art-bible.md`

**Requirements**: Rat King must become the visible MVP boss in the playable
`MainScene`, while preserving the completed Core combat, save, presentation,
audio, and BossConfig contracts.

**ADR Governing Implementation**: ADR-0001 Autoload architecture; ADR-0002
Signal communication; ADR-0003 Data management; ADR-0005 Combat state machine
architecture; ADR-0006 AI behavior.

The previous runtime enemy in `MainScene` was the Shadow Beast prototype. Rat
King art and BossConfig data existed, but the playable scene still did not
instantiate a Rat King boss. This story adds a `RatKingBoss` runtime shell and
replaces `MainScene/Enemy` with it, without claiming the full final boss AI
encounter is complete.

## Acceptance Criteria

- [x] `res://src/gameplay/rat_king_boss.tscn` and
  `res://src/gameplay/rat_king_boss.gd` exist and instantiate as the
  `MainScene/Enemy` runtime boss.
- [x] `MainScene/Enemy/Sprite` is an `AnimatedSprite2D` using
  `res://assets/characters/rat_king/rat_king_sprite_frames.tres`; no visible
  gameplay boss surface uses a pure block, `ColorRect`, or single-frame
  placeholder.
- [x] Rat King runtime exposes the existing MainScene enemy contract:
  `enemy_health_changed`, `enemy_defeated`, `enemy_attack_landed`,
  `request_attack()`, `advance_attack_frames()`, `apply_damage()`,
  `break_shield()`, `apply_status()`, `set_attack_target()`,
  `set_damage_calculator_adapter()`, and respawn snapshot methods.
- [x] Runtime HP and identity come from BossConfig:
  `boss_01_rat_king`, display name `垃圾桶鼠王`, max HP `300`, and phase
  thresholds from `boss_configs`.
- [x] MainScene HUD, CombatPresentation, AudioSystem, SaveSystem autosave, and
  world defeated boss state use the Rat King boss ID instead of the Shadow Beast
  prototype ID.
- [x] Crossing the 66% HP threshold starts phase 2 through
  `BossConfigComponent`, routes the event to `CombatPresentation`, and plays the
  Rat King `phase_2_rebuild` animation.
- [x] Godot CLI/GdUnit and Godot MCP verify scene load, script health, runtime
  logs, running game tree, and a nonblank screenshot showing Rat King in
  `MainScene`.

## Out of Scope

- Full final Rat King AI attack scheduler and all GDD special attacks:
  `charge`, `claw_attack`, `summon`, `jump_slam`, and `combo_attack`.
- Phase 2 live minion scene spawning, full arena geometry mutations, boss music
  state machine, bespoke boss SFX, defeat cutscene, dash unlock presentation,
  and complete progression reward consumption.
- Replacing the Shadow Beast prototype asset everywhere in the project. It
  remains available as a separate prototype enemy/fixture.

## Implementation Notes

- Added `RatKingBoss` as a `CharacterBody2D` shell that mounts Health,
  Collision, Combat, StatusEffect, and BossConfig components at runtime.
- Reused the existing Rat King frame-animation character scene as the visual
  surface through `AnimatedSprite2D + SpriteFrames`.
- Kept MainScene's public enemy integration stable by preserving signal names,
  attack metadata shape, combat adapter seams, and respawn snapshot behavior.
- During MCP validation, the editor initially held a stale cached
  `SimpleEnemy` instance even though disk had the new scene reference. The
  stale editor node was replaced through MCP, the scene was saved, and the
  follow-up MCP/runtime probes confirmed the live scene uses `RatKingBoss`.

## Test Evidence

**Required evidence**:

- `tests/unit/gameplay/rat_king_boss_runtime_contract_test.gd`
- `tests/unit/gameplay/main_scene_visual_contract_test.gd`
- `tests/unit/gameplay/main_scene_enemy_attack_core_chain_test.gd`
- `tests/unit/gameplay/main_scene_audio_event_adapter_test.gd`
- `tests/unit/gameplay/main_scene_hud_settings_runtime_test.gd`
- `tests/unit/save/story_004_main_scene_save_system_runtime_handoff_test.gd`

**Status**: [x] RED/GREEN + related regression + headless smoke + MCP runtime
evidence complete

- RED: `reports/report_468/` failed because RatKingBoss scene/script did not
  exist and MainScene still failed the Rat King visual contract.
- GREEN focused: `reports/report_469/` passed `7/7`.
- Related visual/runtime regression: `reports/report_470/` passed `28/28`.
- Related boss/gameplay/save regression: `reports/report_475/` passed `57/57`
  effective tests.
- Post-MCP-save focused check: `reports/report_474/` passed `7/7`.
- Headless smoke logs:
  `reports/rat_king_boss_main_scene_smoke_after_mcp.log` and
  `reports/rat_king_boss_scene_smoke.log` had no error/warning keyword matches.
- Godot MCP evidence:
  `production/qa/evidence/rat-king-boss-runtime-main-scene-replacement-2026-06-25.md`.

## Completion Notes

**Completed**: 2026-06-25
**Criteria**: 7/7 passing
**Deviations**: This completes the runtime shell and playable MainScene boss
replacement only. The entity remains `Partial` in the visual inventory until
the remaining boss-specific AI attacks, arena execution, audio, and reward
presentation are implemented and verified.
**QA Evidence**:
`production/qa/evidence/rat-king-boss-runtime-main-scene-replacement-2026-06-25.md`

## Dependencies

- Depends on: BossConfig Stories 001-006, Combat Presentation Story014 Rat King
  frame animation, MainScene visual contract.
- Unlocks: full Rat King AI attack scheduling, boss music/SFX, boss reward
  presentation, and specialized attack frame expansion.
