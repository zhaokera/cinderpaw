# Story 022: Boss2 Echo Guardian Telegraph Strike

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Core / Feature / Gameplay Runtime / Presentation Integration
> **Type**: Integration + Gameplay Runtime + Combat Feel
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-14

## Context

**GDD**: `design/gdd/player-abilities.md`,
`design/gdd/feline-combat.md`, `design/gdd/ai-framework.md`,
`design/gdd/boss-config.md`

**Requirements**: `TR-ability-001`, `TR-ability-002`,
`TR-ability-005`, `TR-combat-001`, `TR-combat-004`,
`TR-ai-003`, `TR-ai-004`

**ADR Governing Implementation**: ADR-0004 Collision detection; ADR-0005
Combat state machine; ADR-0007 Scene management; ADR-0018 Player abilities;
ADR-0021 Save system architecture.

Story021 made the mainline Boss2 reward path visible and claimable, but the
`Boss2EchoGuardian` was still only a defeat/reward shell. This story turns that
shell into the smallest playable Boss2 combat threat: a single readable
`echo_swipe` strike with startup, active frames, recovery, player damage, and
presentation/audio feedback, while preserving the existing Double Jump reward
flow.

## Acceptance Criteria

- [x] `Boss2EchoGuardian` exposes deterministic runtime attack APIs for tests
  and MCP: `request_attack()`, `advance_attack_frames()`,
  `get_current_attack_startup_frames()`, `get_attack_phase()`,
  `is_enemy_attack_active()`, `get_collision_component()`, and
  `get_last_enemy_attack_metadata()`.
- [x] `echo_swipe` has a readable startup window where the dedicated
  `attack_tell` animation plays but the hitbox is inactive. Story165 supersedes
  only this story's original startup-to-`attack` animation mapping.
- [x] After startup, `boss2_echo_swipe` becomes active for fixed frames and
  damages the Player exactly once through the existing Core Collision/Combat
  damage path when the Player hurtbox overlaps it.
- [x] Boss2 attack metadata records `source="boss2_echo_guardian"`,
  `weapon_id="boss2_echo_swipe"`, `hitbox_id="boss2_echo_swipe"`,
  `target_id=1`, and the resolved final damage.
- [x] MainScene routes Boss2 attack hits to CombatPresentation damage numbers
  and the existing damage-taken audio event path.
- [x] Boss2 rejects attack re-entry during startup/active/recovery, recovers
  after cooldown, and rejects attacks after defeat while preserving Story021
  reward availability and Double Jump claim behavior.
- [x] Godot MCP verifies `main.tscn` load, Boss2 `AnimatedSprite2D` runtime,
  attack state/hitbox contract, player damage, reward reveal, clean logs, and a
  nonblank screenshot.

## Out of Scope

- Multi-phase Boss2 AI, summon patterns, authored boss music, cutscene/camera
  scripting, final arena layout, HP bar polish, or full boss balancing.
- New Boss2 art or animation generation was out of scope for this original
  slice. Story165 later adds the generated `attack_tell` frames without changing
  Story022's combat timing, hitbox, damage, metadata, or reward contract.
- New route gates, minimap updates, fast travel, or full Old Factory route
  content.
- A generic AI rewrite, new Autoload, EventBus, or NavigationAgent2D.

## Implementation Notes

- Keep Boss2 scene-local and reuse the existing Core `HealthComponent`,
  `CollisionComponent`, and `CombatComponent` pattern already used by Rat King
  summons.
- Use a single `boss2_echo_swipe` hitbox and one damage entry so the behavior is
  readable and deterministic.
- Keep Story021 payoff compatibility: defeating Boss2 still opens
  `Boss2DoubleJumpRewardSource`, and claiming it still uses
  `MainScene.unlock_ability("double_jump")`.
- Prefer focused tests and MCP runtime probes over broad full-suite runs.

## Test Evidence

**Required evidence**:

- `tests/unit/gameplay/boss2_echo_guardian_telegraph_strike_test.gd`
- `tests/unit/gameplay/boss2_double_jump_payoff_runtime_test.gd`
- `tests/unit/gameplay/main_scene_enemy_attack_core_chain_test.gd`
- Godot MCP runtime evidence under
  `production/qa/evidence/boss2-echo-guardian-telegraph-strike-2026-06-26.md`

**Status**: [x] RED/GREEN focused evidence, related regression, headless smoke,
and MCP runtime evidence complete.

- RED focused: `reports/report_772/` failed as expected because Boss2 did not
  yet expose `enemy_attack_landed`, collision component, attack phase, active
  hitbox, or last attack metadata APIs.
- Intermediate RED: `reports/report_773/` and `reports/report_774/` exposed
  the missing Boss2 metadata `source` propagation before the local Boss2
  metadata fix.
- Intermediate GREEN focused: `reports/report_775/` passed before the
  restored-defeated threat cleanup regression was added.
- Final focused/related regression: `reports/report_777/` passed Story022
  `4/4` and total `13/13` across Story022, Boss2 payoff, MainScene enemy
  attack Core chain, and MainScene player attack Core chain tests.
- Headless smoke:
  `reports/boss2_echo_guardian_telegraph_strike_main_scene_smoke.log` exited
  `0`; keyword scan found no script, parse, invalid-call, missing-resource, or
  resource-load errors. Only the existing cleanup-time ObjectDB/resource message
  appeared.
- Godot MCP evidence:
  `production/qa/evidence/boss2-echo-guardian-telegraph-strike-2026-06-26.md`.
- MCP runtime screenshot:
  `reports/visual/cinderpaw-mcp-boss2-echo-guardian-telegraph-strike-20260626.png`.

## Test-Criterion Traceability

| Criterion | Test / Evidence | Status |
|-----------|-----------------|--------|
| Runtime attack APIs exist | `boss2_echo_guardian_telegraph_strike_test` | COVERED |
| Startup has no active hitbox | `boss2_echo_guardian_telegraph_strike_test`; MCP probe | COVERED |
| Active hitbox damages player once | `boss2_echo_guardian_telegraph_strike_test`; MCP probe | COVERED |
| Metadata contract | `boss2_echo_guardian_telegraph_strike_test`; MCP probe | COVERED |
| MainScene presentation/audio bridge | `boss2_echo_guardian_telegraph_strike_test`; MCP probe | COVERED |
| Re-entry/recovery/defeat/restore behavior | `boss2_echo_guardian_telegraph_strike_test`; Boss2 payoff regression; MCP restore probe | COVERED |
| MCP runtime logs and screenshot verified | QA evidence | COVERED |

## Completion Notes

**Completed**: 2026-06-26
**Criteria**: 7/7 passing
**Deviations**: This is a single-attack Boss2 threat slice. Multi-phase AI,
final arena layout, HP bar polish, authored music, and full boss balancing
remain out of scope.
**QA Evidence**:
`production/qa/evidence/boss2-echo-guardian-telegraph-strike-2026-06-26.md`

**Supersession note**: Story165 replaces only the startup presentation with
`attack_tell`; active frames continue to use `attack`, and every gameplay value
verified by this story remains unchanged.
