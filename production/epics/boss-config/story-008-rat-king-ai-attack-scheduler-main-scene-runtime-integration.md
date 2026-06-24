# Story 008: Rat King AI Attack Scheduler MainScene Runtime Integration

> **Epic**: Boss Configuration
> **Status**: Complete
> **Layer**: Core / Integration
> **Type**: Integration + Gameplay Runtime
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-25

## Context

**GDD**: `design/gdd/boss-config.md`, `design/gdd/ai-framework.md`,
`design/gdd/feline-combat.md`

**Requirements**: Rat King already exists as the visible `MainScene` boss shell.
This story connects that runtime shell to data-driven AI attack scheduling so
the playable boss can execute more than one hardcoded claw attack.

**ADR Governing Implementation**: ADR-0002 Signal communication; ADR-0003 Data
management; ADR-0005 Combat state machine architecture; ADR-0006 AI behavior.

Story007 intentionally left full Rat King AI attack scheduling out of scope.
This story implements the first high-value runtime slice: BossConfig phases
select attack pattern ids, `enemy_stats` defines pattern timing/hitbox/damage,
and `RatKingBoss` bridges `AIComponent` execution into the existing
Collision/Combat/MainScene chain.

## Acceptance Criteria

- [x] `AIComponent` exposes the BossConfig adapter contract
  `apply_boss_phase(phase_id, attack_patterns, attack_speed_modifier)`.
- [x] `AIComponent` can report the current phase-filtered attack pattern ids,
  start a specific pattern id for deterministic tests, and apply BossConfig
  attack speed modifiers to future attack timing.
- [x] `data/combat/enemy_stats.json` contains `boss_01_rat_king` attack
  profiles for `charge`, `claw_swipe`, `slam`, and `berserk_combo`; all
  BossConfig phase pattern ids resolve to AI pattern data through DataManager.
- [x] `RatKingBoss` owns a runtime `AIComponent`, disables duplicate automatic
  AI physics advancement, and advances attack startup/active/recovery through
  one deterministic RatKingBoss entry point.
- [x] Phase 1 exposes `charge` and `claw_swipe`; after the 66% threshold and
  phase transition, phase 2 exposes `charge`, `claw_swipe`, and `slam`.
- [x] `request_attack_pattern(&"slam")` after phase 2 starts the slam tell,
  advances to an active `rat_king_slam` hitbox, and preserves metadata including
  `pattern_id`, timing, `damage_type`, `vulnerability_window`, and damage.
- [x] Existing MainScene enemy attack chain still damages the player once per
  hitbox activation and emits `enemy_attack_landed` with Rat King metadata.
- [x] Godot MCP verifies `MainScene` runtime tree, `AnimatedSprite2D`,
  `AIComponent`, pattern switching, clean logs, and a nonblank screenshot.

## Out of Scope

- Physical charge movement, jump-slam movement, three-hit combo sequencing, or
  bespoke animation clips per attack.
- Phase 2 live summon scene spawn, phase 3 arena mutation runtime geometry, boss
  music/SFX state machine, defeat reward presentation, and dash unlock UI.
- Replacing the current shared `attack_tell` / `attack` animations with new
  per-attack generated frame sets. Future animation work must follow
  `AGENTS.md` AnimatedSprite2D + SpriteFrames rules.

## Implementation Notes

- `RatKingBoss` now creates `AIComponent` at runtime beside Health, Collision,
  Combat, StatusEffect, and BossConfig components.
- `RatKingBoss` keeps ownership of attack frame advancement, while
  `AIComponent` owns pattern selection, startup/active/recovery phase state, and
  BossConfig phase filtering.
- `RatKingBoss.activate_hitbox()` is the Collision adapter consumed by
  `AIComponent`; it applies boss facing, merges AI metadata into Rat King Combat
  metadata, and preserves the existing DamageCalculator `injected_damage_params`
  shape.
- Existing MainScene animation remains `attack_tell` then `attack`; the story
  proves multiple data-driven attack patterns without claiming unique visual
  clips for each pattern.

## Test Evidence

**Required evidence**:

- `tests/unit/ai/story_003_data_driven_attack_pattern_loading_test.gd`
- `tests/unit/ai/story_005_boss_phase_focus_mode_signal_integration_test.gd`
- `tests/unit/gameplay/rat_king_boss_runtime_contract_test.gd`
- `tests/unit/gameplay/main_scene_enemy_attack_core_chain_test.gd`
- `tests/unit/gameplay/main_scene_visual_contract_test.gd`

**Status**: [x] RED/GREEN + related regression + headless smoke + MCP runtime
evidence complete

- RED: `reports/report_476/` failed on missing AI phase adapter and RatKingBoss
  scheduler contracts.
- GREEN focused: `reports/report_478/` passed `18/18`.
- Related Boss/AI/Gameplay regression: `reports/report_479/` passed `74/74`.
- Headless smoke:
  `reports/rat_king_ai_attack_scheduler_main_scene_smoke.log` had no
  error/warning keyword matches.
- Godot MCP evidence:
  `production/qa/evidence/rat-king-ai-attack-scheduler-2026-06-25.md`.

## Completion Notes

**Completed**: 2026-06-25
**Criteria**: 8/8 passing
**Deviations**: This completes data-driven Rat King attack scheduling for
phase attack pools only. It does not complete final boss encounter movement,
summons, arena mutation, boss audio, rewards, or unique per-attack animation.
**QA Evidence**:
`production/qa/evidence/rat-king-ai-attack-scheduler-2026-06-25.md`

## Dependencies

- Depends on: BossConfig Stories 001-007, AI Framework Stories 003-006,
  Collision Detection Stories 001-005, Combat Presentation Story014.
- Unlocks: specialized Rat King attack animation expansion, live phase 2 summon
  runtime, arena mutation runtime, boss music/SFX, and reward presentation.
