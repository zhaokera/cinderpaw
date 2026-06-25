# Story 009: Rat King Live Phase Two Summon Runtime Integration

> **Epic**: Boss Configuration
> **Status**: Complete
> **Layer**: Core / Integration
> **Type**: Integration + Gameplay Runtime + Visual
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-25

## Context

**GDD**: `design/gdd/boss-config.md`, `design/gdd/ai-framework.md`,
`design/gdd/feline-combat.md`, `design/art/art-bible.md`

**Requirement**: `TR-boss-003`

**ADR Governing Implementation**: ADR-0002 Signal communication; ADR-0003 Data
management; ADR-0005 Combat state machine architecture; ADR-0006 AI behavior.

Story003 proved the BossConfig summon timer and cleanup adapter contract. This
story connects that contract to the playable `MainScene`: Rat King phase 2 now
spawns live Rat Minion enemies, enforces the active summon cap, routes player
damage to summoned entity ids, lets summoned minions bite the player through the
existing collision/damage chain, and cleans up summons on boss death.

## Acceptance Criteria

- [x] Rat Minion has a character scene at `scenes/characters/rat_minion.tscn`
  and a character script at `src/characters/rat_minion.gd`.
- [x] Rat Minion visual assets use `AnimatedSprite2D + SpriteFrames` with
  transparent, same-size, consecutively named PNG frames under
  `assets/characters/rat_minion/<animation_name>/`.
- [x] Rat Minion exposes `idle`, `run`, `attack`, `hurt`, and `death`
  gameplay-state animations, with at least 3 frames per animation.
- [x] Rat Minion has a runtime scene at `src/gameplay/rat_minion.tscn` and
  runtime script at `src/gameplay/rat_minion.gd`.
- [x] `MainScene` implements the BossConfig summon adapter:
  `get_active_summon_count`, `request_summon`, and `cleanup_summons`.
- [x] When Rat King enters phase 2 and 15 seconds elapse, `MainScene` spawns one
  live Rat Minion under a `Summons` container.
- [x] Rat King phase 2 summon runtime enforces a cap of two active minions and
  can replenish after a minion dies.
- [x] Player attacks can route damage to a live minion by entity id instead of
  always damaging the boss.
- [x] Rat Minion bite attacks damage the player through the existing
  Collision/Combat/DamageCalculator chain and emit hit metadata.
- [x] Boss death cleans active Rat Minions from the arena.
- [x] Godot MCP verifies main scene runtime loading, Rat Minion
  `AnimatedSprite2D`, SpriteFrames animation names/frame counts, clean runtime
  logs, and a nonblank screenshot showing the minion in the arena.

## Out of Scope

- Final Rat Minion pathfinding, advanced steering, group tactics, or bespoke
  AI decision trees.
- Rat Minion dedicated SFX, boss music escalation, arena mutation runtime, phase
  HUD polish, reward presentation, and final boss completion.
- Replacing every remaining non-character prototype prop or environment asset.

## Implementation Notes

- `MainScene` preloads `res://src/gameplay/rat_minion.tscn` and owns the
  `Summons` runtime container.
- Rat Minion runtime nodes configure Health, Collision, Combat, and
  StatusEffect components in the same Core chain used by other combat entities.
- Rat Minion attacks use `rat_minion_bite` as the hitbox/source id and inject
  an 8 damage enemy attack profile into the runtime DamageCalculator path.
- `RatKingBoss.set_summon_adapter()` forwards the `MainScene` adapter into
  `BossConfigComponent` after core component setup.
- `MainScene.apply_damage()` now resolves target ids between Rat King and live
  summons, allowing existing player hit-confirmation logic to damage minions.

## Test Evidence

**Required evidence**:

- `tests/unit/gameplay/rat_king_live_summon_runtime_test.gd`
- `tests/unit/save/story_004_main_scene_save_system_runtime_handoff_test.gd`
- `tests/unit/data/story_003_domain_cache_test.gd`

**Status**: [x] RED/GREEN + related regression + headless smoke + MCP runtime
evidence complete

- RED: `reports/report_485/` failed because Rat Minion character scene, runtime
  scene, scripts, and SpriteFrames did not exist.
- GREEN focused: `reports/report_486/` passed `7/7`.
- Related gameplay regression: `reports/report_491/` passed `94/94`.
- Full `reports/report_492/` was not used as passing evidence; it exposed
  unrelated Save/Data test-isolation failures while
  `rat_king_live_summon_runtime_test` still passed `7/7` inside that run.
- Follow-up minimum risk regression: `reports/report_496/` passed `17/17`
  across Data Story003, Save Story004, and Rat King live summon runtime tests.
- Final minimum risk verification: `reports/report_500/` passed `17/17` across
  the same Data Story003, Save Story004, and Rat King live summon runtime set
  after documentation/evidence updates.
- Follow-up full unit triage: `reports/report_497/` still failed only Save
  Story004's load-restore assertion sequence in full order; Data Story003 passed
  `7/7` and Rat King live summon runtime passed `7/7` inside that run. Focused
  Save Story004 and Save Story005/Story004 order checks passed separately.
- Headless smoke:
  `reports/rat_king_live_summon_main_scene_smoke.log` had no error/warning
  keyword matches.
- Godot MCP evidence:
  `production/qa/evidence/rat-king-live-phase-two-summon-runtime-2026-06-25.md`.

## Test-Criterion Traceability

| Criterion | Test / Evidence | Status |
|-----------|-----------------|--------|
| Rat Minion character scene/script/SpriteFrames exist | `test_rat_minion_character_asset_contract_uses_sprite_frames` | COVERED |
| Animation files follow `assets/characters/rat_minion/<animation>/` convention | `test_rat_minion_animation_assets_follow_project_pipeline_paths` | COVERED |
| Runtime minion scene exposes enemy combat contract | `test_rat_minion_runtime_scene_exposes_enemy_contract` | COVERED |
| Phase 2 timer spawns one live minion | `test_main_scene_spawns_live_phase_two_summon_from_boss_timer`; MCP runtime probe | COVERED |
| Summon cap is two and replenishes after minion death | `test_main_scene_enforces_summon_cap_and_replenishes_after_minion_death`; MCP runtime probe | COVERED |
| Boss death cleans live summons | `test_boss_death_cleans_up_live_summons`; MCP runtime probe | COVERED |
| Player damage routes to live minion target id | `test_player_damage_adapter_routes_to_live_summon` | COVERED |
| Rat Minion bite damages player at runtime | MCP runtime probe reports `damage_delta=8` | COVERED |
| Runtime visual is animated, not a block placeholder | MCP SpriteFrames probe and screenshot | COVERED |

## Completion Notes

**Completed**: 2026-06-25
**Criteria**: 11/11 passing
**Deviations**: HUD phase label polish remains outside this Story009 scope and
should be handled by a HUD/Boss phase UI story. The gameplay runtime phase,
summon cap, minion frames, bite damage, and cleanup behavior are verified.
**QA Evidence**:
`production/qa/evidence/rat-king-live-phase-two-summon-runtime-2026-06-25.md`

## Dependencies

- Depends on: BossConfig Stories 001-008, Combat Presentation Stories 014-015,
  Feline Combat Stories 007-009, Collision Detection Stories 001-005, Damage
  Calculator Stories 001-004.
- Unlocks: arena mutation runtime, boss music/SFX state transitions, final boss
  reward presentation, Rat Minion AI polish, and HUD phase label polish.
