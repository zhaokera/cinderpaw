# Story 010: Rat King Defeat Reward Runtime Consumption

> **Epic**: Boss Configuration
> **Status**: Complete
> **Layer**: Core / Feature Integration
> **Type**: Integration + Gameplay Runtime + UI
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-25

## Context

**GDD**: `design/gdd/boss-config.md`, `design/gdd/save-system.md`

**Requirement**: `TR-boss-007`

**ADR Governing Implementation**: ADR-0002 Signal communication; ADR-0003 Data
management; ADR-0021 Save system architecture.

Story005 proved the BossConfig reward dispatch adapter in isolation. The
playable `MainScene` still needed to consume the configured Rat King defeat
rewards at runtime, present the reward to the player, and persist it through
SaveSystem snapshots.

## Acceptance Criteria

- [x] `RatKingBoss` forwards a reward adapter into its mounted
  `BossConfigComponent`.
- [x] `MainScene` injects itself as Rat King reward adapter without coupling
  BossConfigComponent to HUD, SaveSystem, or player ability internals.
- [x] Defeating Rat King consumes the configured rewards from
  `data/combat/boss_configs.json`: unlock `dash`, grant `50` Gears, and grant
  `5` skill points.
- [x] The old hard-coded `25` Gears victory reward is removed from the victory
  path.
- [x] Runtime progress exposes and no-loss restores `currency`,
  `unlocked_abilities`, and `skill_points`.
- [x] `capture_save_snapshot()` persists `currency`, `unlocked_abilities`, and
  `skill_points` in `player_state`, and boss-defeat autosave captures the same
  reward state.
- [x] HUD victory notification and retry menu show the claimed reward:
  `Dash unlocked +50 Gears +5 SP`.
- [x] Re-entering the victory presentation path does not duplicate currency,
  skill points, or dash unlock.
- [x] Godot MCP verifies main scene runtime loading, Rat King
  `BossConfigComponent` presence, reward state after defeat, HUD text, save
  snapshot contents, clean runtime logs, and a nonblank screenshot.

## Out of Scope

- Full PlayerAbilityManager implementation, dash cooldown gating, skill tree
  spending UI, or area gating with `requires_ability`.
- New visual, audio, or VFX assets.
- Additional boss reward tables beyond `boss_01_rat_king`.

## Implementation Notes

- `RatKingBoss.set_reward_adapter()` mirrors the existing summon and scene
  adapter seams and forwards to `BossConfigComponent`.
- `BossConfigComponent` optionally brackets defeat reward dispatch with
  `begin_boss_defeat_rewards()` / `finish_boss_defeat_rewards()` adapter calls,
  so scene-level UI can summarize only the rewards claimed by that boss defeat.
- `MainScene` owns runtime progression state for this slice:
  `_unlocked_abilities`, `_skill_points`, and existing `_currency_amount`.
- Boss reward UI text is derived from the reward adapter calls, not duplicated
  as hard-coded data in `_on_victory_reached()`.
- Health death signal connection order ensures `BossConfigComponent` dispatches
  rewards before RatKingBoss emits `enemy_defeated`, so the boss-defeat autosave
  contains the claimed reward state.

## Test Evidence

**Required evidence**:

- `tests/unit/gameplay/rat_king_defeat_reward_runtime_test.gd`
- `tests/unit/boss/story_005_desperation_reward_test.gd`
- `tests/unit/gameplay/rat_king_boss_runtime_contract_test.gd`
- `tests/unit/save/story_004_main_scene_save_system_runtime_handoff_test.gd`

**Status**: [x] RED/GREEN + related regression + headless smoke + MCP runtime
evidence complete

- RED: `reports/report_588/` failed because runtime progress had no
  `unlocked_abilities` / `skill_points`, defeat still granted `25` Gears, HUD
  did not show configured rewards, and save snapshots lacked reward fields.
- GREEN focused: `reports/report_589/` passed `1/1`.
- Related regression: `reports/report_595/` passed `13/13` across reward
  runtime, BossConfig reward adapter compatibility, RatKingBoss runtime
  contract, and SaveSystem Story004 autosave handoff.
- Headless smoke:
  `reports/rat_king_reward_runtime_main_scene_smoke.log` had no script error,
  warning, or failed resource-load keyword matches.
- Godot MCP evidence:
  `production/qa/evidence/rat-king-defeat-reward-runtime-2026-06-25.md`.

## Test-Criterion Traceability

| Criterion | Test / Evidence | Status |
|-----------|-----------------|--------|
| Reward adapter is forwarded into RatKingBoss/BossConfig | `test_rat_king_defeat_consumes_configured_rewards_once_and_persists_progress`; MCP runtime probe | COVERED |
| Rat King grants dash/50/5 from config | `test_rat_king_defeat_consumes_configured_rewards_once_and_persists_progress` | COVERED |
| Hard-coded 25 reward removed | RED `report_588`; GREEN `report_589` | COVERED |
| Reward state is saved in player_state and autosave | reward runtime test; SaveSystem Story004 regression | COVERED |
| HUD victory reward presentation appears | reward runtime test; MCP screenshot | COVERED |
| Duplicate victory presentation does not duplicate reward | reward runtime test | COVERED |
| Runtime logs and screenshot verified through MCP | QA evidence | COVERED |

## Completion Notes

**Completed**: 2026-06-25
**Criteria**: 9/9 passing
**Deviations**: Full ability-system gating and skill-tree spending remain
outside this story and should be implemented under Player Abilities /
Progression stories.
**QA Evidence**:
`production/qa/evidence/rat-king-defeat-reward-runtime-2026-06-25.md`
