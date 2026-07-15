# Story 147: Crown Warden Wall Climb Reward Payoff

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Core / Feature / Gameplay Runtime / Presentation
> **Type**: Integration + Gameplay Runtime + Generated Visual Contract
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-13

## Context

**GDD**: `design/gdd/player-abilities.md`,
`design/gdd/exploration-ability-gating.md`, `design/gdd/hud-ui.md`,
`design/gdd/scene-management.md`, `design/art/art-bible.md`

**Quick Design**:
`design/quick-specs/crown-warden-wall-climb-reward-payoff-2026-07-13.md`

**Requirements**: `TR-ability-001`, `TR-ability-002`, `TR-ability-005`,
`TR-scene-004`

**ADR Governing Implementation**: ADR-0001, ADR-0002, ADR-0003, ADR-0007,
ADR-0018, ADR-0021.

Story146 ends with Crown Warden defeated, a persistent corpse, open room seals
and a Tower return, while intentionally deferring the Boss4 reward. This Story
completes the GDD payoff without undoing its nonlinear path: `wall_climb` may
already be unlocked through Story135's hidden altar, so the Boss route must be
claimable and durable without duplicating ability events or inventing a
substitute reward.

## Acceptance Criteria

- [x] The arena contains `WallClimbRewardSource` using the shared
  `AbilityRewardSource`, reward id `boss_04_wall_climb_reward`, ability
  `wall_climb`, state key `boss_04_wall_climb_reward_claimed`, and an imported
  transparent generated texture at the authored `(700,444)` anchor.
- [x] Exact prompt, generated source, alpha intermediate and normalized
  transparent `256x256` runtime PNG are retained under
  `assets/environment/crown_warden_reward/` and recorded in asset spec,
  manifest, inventory and QA evidence.
- [x] Before Boss4 defeat the source is hidden/unavailable. Death reveals it
  once with a generated-art gold/cyan pulse; the existing death animation,
  open seals, hidden Boss HUD and return route remain intact.
- [x] Real player contact claims the reward exactly once. If `wall_climb` is
  missing, the player unlocks it through the existing AbilityComponent path and
  receives one `ability_unlocked` event plus `Wall Climb Unlocked` feedback.
- [x] If `wall_climb` was already obtained from Story135, the same source is
  consumed without a duplicate unlock event and reports
  `Wall Climb Path Confirmed`; currency and skill points remain zero.
- [x] Claim runs an exact `1.5s` presentation beat, temporarily locks player
  control, pulses the generated core, updates HUD/objective, then restores
  control and shows `Return to Apex Approach`.
- [x] Local state stores the Boss defeated flag, reward claimed flag and exact
  unlocked ability list. Claimed restore keeps the source consumed, guarantees
  `wall_climb`, clears transient feedback/transition latches and never replays
  reveal, notification or control lock.
- [x] Claim and Tower return persist the current unlocked ability list into the
  arena, `area_05_central_tower` and `main` SceneManager states without
  overwriting unrelated keys.
- [x] Existing Crown Warden and Cinderpaw `AnimatedSprite2D + SpriteFrames`,
  Boss4 combat, death retry and opened return regressions remain green; no
  primitive reward placeholder is visible.
- [x] Focused RED/GREEN, bounded Story146/Story135 related regression, one
  target smoke and Godot MCP `2.9.1` evidence cover real contact claim,
  alternate-path safety, persistence, HUD/objective, generated texture,
  non-empty screenshot and clean current-run/editor-cursor logs. No full suite.

## Out Of Scope

- New ability mechanics, wall-climb tuning/frames, climb trial, new area or
  route, currency, skill points, substitute reward, ending, credits, cutscene,
  dialogue, bespoke audio, arena mutation or Boss combat changes.
- SaveSystem schema, new Autoload, global reward refactor, Boss1-3 rewrites or
  full-suite/launch validation.

## Test Evidence Contract

- Focused suite:
  `tests/unit/gameplay/crown_warden_wall_climb_reward_payoff_test.gd`
- Target smoke:
  `tests/smoke/crown_warden_wall_climb_reward_payoff_smoke.gd`
- QA evidence:
  `production/qa/evidence/crown-warden-wall-climb-reward-payoff-2026-07-13.md`

## Dependencies

- Depends on: Story146 Crown Warden Playable Boss4 Core. Complete.
- Unlocks: a separately authored post-Boss4 continuation or ending slice.

## Implementation

- Added a shared `AbilityRewardSource` at `(700,444)` with generated Crown Core
  art, one reveal pulse and a grounded `128px` contact radius.
- Missing `wall_climb` uses the existing player unlock path and emits one event;
  the Story135 alternate path consumes the source without a duplicate event.
- Added exact `1.5s` control lock, core pulse, HUD/objective feedback and clean
  control restoration, plus claimed restore with no transient replay.
- Arena, Tower and Main state merge the current unlocked ability list while
  retaining unrelated keys.
- Fixed `RouteTransitionShell` to defer Area2D monitoring changes during a
  physics frame, removing Godot 4.7 signal-flush errors found by regression.

## Test-Criterion Traceability

| AC | Evidence | Status |
|----|----------|--------|
| 1-3. Source, generated art and reveal | asset spec/manifest; focused suite; MCP revealed screenshot | COVERED |
| 4-6. Contact, alternate path and feedback | focused suite; grounded-contact smoke; MCP real movement | COVERED |
| 7-8. Restore and three-scene state merge | focused suite with fake SceneManager; target smoke | COVERED |
| 9. Boss/player animation and combat regression | bounded Story146/Story135 run | COVERED |
| 10. Runtime, screenshot and clean logs | MCP Run `r7762730-6`; QA evidence | COVERED |

## Verification

- Expected RED: `reports/report_1554/results.xml`, `3/3` cases with nine
  expected missing-contract failures.
- Final focused GREEN: `reports/report_1559/results.xml`, `3/3`, zero errors,
  failures, skipped tests or orphans.
- Final bounded related GREEN: `reports/report_1558/results.xml`, `9/9`, zero
  errors/failures. It covers Story146 Boss4 and Story135 hidden-altar behavior.
- Target smoke exited `0` with marker
  `crown_warden_wall_climb_reward_payoff_smoke=passed`; the final form keeps
  Cinderpaw at ground height instead of teleporting to the reward center.
- Godot `4.7-stable` / MCP `2.9.1` Run `r7762730-6` exposed 84 runtime nodes.
  Real `move_right` input moved Cinderpaw `(220,551.99) -> (633.33,551.99)`
  and naturally claimed the core once. Current game logs were helper/data only,
  `current_run_errors=[]`, and editor cursor `4 -> 4` added no rows.
- MCP screenshots:
  `production/qa/evidence/crown-warden-wall-climb-reward-revealed-mcp.png` and
  `production/qa/evidence/crown-warden-wall-climb-reward-claimed-mcp.png`.
- No full suite was run, per the bounded verification contract.

## Completion Notes

**Completed**: 2026-07-13

**Verdict**: COMPLETE

**Criteria**: 10/10 covered; post-Boss4 continuation and ending remain later
scope.

**Review**: Three requested read-only sidecars failed before project access
because the backend rewrote their supported effort to invalid `max`. The
integrating agent completed the bounded acceptance/art/QA review locally and
owned all final tests and MCP evidence.
