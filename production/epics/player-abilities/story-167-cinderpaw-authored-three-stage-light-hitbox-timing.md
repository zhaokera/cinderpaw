# Story 167: Cinderpaw Authored Three-Stage Light Hitbox Timing

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Core / Feature / Combat Runtime / Visual Integration
> **Type**: Integration + Gameplay Runtime + Collision Timing
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-15

## Context

**GDD**: `design/gdd/feline-combat.md`

**Requirements**: `TR-combat-001`, `TR-combat-002`, `TR-combat-006`

**ADR Governing Implementation**: ADR-0001 input boundaries; ADR-0002 signal
communication; ADR-0004 collision; ADR-0005 combat state machine; ADR-0010
presentation; ADR-0018 player runtime integration.

Story166 made all three authored light-combo animations reachable but preserved
the previous immediate six-frame weapon hitbox. That hitbox expired before the
second and third animations reached their contact poses. This Story binds each
light hitbox and visible contact pose to the existing Core attack frame data.

## Acceptance Criteria

- [x] Stage 0 uses startup/active/post-active windows `4/4/4` within 12 frames.
- [x] Stage 1 uses startup/active/post-active windows `6/6/6` within 18 frames.
- [x] Stage 2 uses startup/active/post-active windows `10/10/10` within 30 frames.
- [x] `cat_claw_light` remains inactive during startup, activates exactly at
  each authored contact boundary, and deactivates at active-window end.
- [x] Light animation frames are deterministic: frame 0 startup, frame 1 active
  contact, and frame 2 pure recovery.
- [x] An attack press during an active window queues one next stage and commits
  only after that active window; stage 2 cannot create a fourth stage.
- [x] Existing damage, cat energy, duplicate suppression, collision ID, skill
  modifiers, combo timeout, and heavy/aerial behavior remain unchanged.
- [x] Thin RED/GREEN, bounded related regression, and Godot AI MCP 3.0.2 Main
  runtime acceptance pass with clean logs and a non-empty screenshot.

## Authored Timing Contract

| Stage | Startup | Active | Pure recovery | Total | Animation |
| --- | ---: | ---: | ---: | ---: | --- |
| 0 | `[0,4)` | `[4,8)` | `[8,12)` | 12 | `attack` |
| 1 | `[0,6)` | `[6,12)` | `[12,18)` | 18 | `attack_2` |
| 2 | `[0,10)` | `[10,20)` | `[20,30)` | 30 | `attack_3` |

## Preserved Gameplay Contract

| Contract | Preserved value |
| --- | --- |
| Core combo range | `0..2` |
| Combo timeout | `300ms` |
| Hitbox ID | Existing `<weapon_id>_light` contract |
| Baseline Cat Claw hit | `10` final damage and `+5` cat energy |
| Crit timing input | Explicit legacy `hit_frame=6` |
| Skill metadata | Existing lunge, range, damage and status modifiers |
| Duplicate suppression | One target hit per activation |
| Heavy/aerial/parry/dodge | Unchanged |

## Implementation Notes

- `CombatComponent` emits the advanced stage/frame after deterministic attack
  frame increment and exposes `active_frames` plus pure recovery data.
- Player schedules hitbox activation until the Core startup boundary. Combat,
  collision and controller physics priorities preserve advance, detect, then
  input-consumption order.
- Active-period input is queued so it cannot truncate the current contact
  window; pure-recovery input keeps the existing immediate chain transition.
- Light attack `AnimatedSprite2D` playback is phase-driven instead of relying
  on an independent animation clock. Other character animations are unchanged.
- `get_light_combo_diagnostics()` exposes pending/active hitbox state, window
  bounds, hitbox ID and queued-chain state for tests and MCP inspection.
- No visual asset was added or regenerated. Story166's existing generated
  `attack`, `attack_2`, and `attack_3` frames are reused.

## Test Evidence

- Initial timing RED: `reports/report_1715/results.xml`; expected failures
  proved immediate activation and missing authored-window diagnostics.
- Runtime visual-sync RED: `reports/report_1725/results.xml`; deterministic
  Core advancement proved the contact callback left visual frame 0 active.
- Final focused GREEN: `reports/report_1730/results.xml`, `3/3` passed.
- Final bounded related GREEN: `reports/report_1731/results.xml`, `34/34`
  passed across nine directly related suites; no full suite was run.
- The related run retains the existing ObjectDB/resource cleanup warning after
  all cases pass with exit code `0`; the final MCP logs contain no errors.
- Runtime evidence:
  `production/qa/evidence/cinderpaw-authored-light-hitbox-timing-2026-07-15.md`.

## Test-Criterion Traceability

| Criterion | Test / Evidence | Status |
| --- | --- | --- |
| Three authored windows | Story167 focused test + MCP | PASS |
| Contact frame and hitbox synchronization | Sync regression + MCP | PASS |
| Active input queues without truncation | Story167 focused test + MCP | PASS |
| Damage, energy and duplicate suppression | Story167 focused hit test | PASS |
| Existing combat systems remain compatible | Bounded 34-case regression | PASS |
| Clean Main runtime and screenshot | MCP run `r59179809-12` | PASS |

## Completion Notes

**Completed**: 2026-07-15

**Criteria**: 8/8 passing

**Deviation**: None. Existing generated character frames were sufficient, so
no new image-generation task or asset-pipeline import was required.
