# Story 166: Cinderpaw Real-Input Three-Stage Light Combo Runtime

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Core / Feature / Combat Runtime / Visual Integration
> **Type**: Integration + Gameplay Runtime + Frame Animation Contract
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-14

## Context

**GDD**: `design/gdd/feline-combat.md`

**Requirements**: `TR-combat-001`, `TR-combat-002`, `TR-combat-006`

**ADR Governing Implementation**: ADR-0001 input/autoload boundaries; ADR-0002
signal communication; ADR-0004 collision; ADR-0005 combat state machine;
ADR-0010 presentation; ADR-0018 player runtime integration.

Core already owned the three light-attack stages and their `4+8`, `6+12`, and
`10+20` frame contracts. Player input only forwarded `attack` while the local
controller was idle, however, so the existing recovery-window chain branch was
unreachable through real InputMap actions. Player presentation also expired
after six frames and reused `attack` for every stage.

This Story connects the approved Core contract to real player input and gives
each stage a generated frame animation. It coordinates with Feline Combat but
does not reopen that completed Epic's damage, energy, cancellation, or hitbox
contracts.

## Acceptance Criteria

- [x] Real `attack` InputMap presses advance `combo_index` `0 -> 1 -> 2` only
  during the existing recovery windows.
- [x] Holding attack does not auto-chain; one press creates at most one stage;
  a recovery-window press during stage 3 cannot create or restart stage 4.
- [x] A new attack after the completed chain starts from stage 0.
- [x] Player presentation uses Core total durations `12`, `18`, and `30` frames
  instead of the previous fixed six-frame lifetime.
- [x] Combo stages map to non-looping `attack`, `attack_2`, and `attack_3` at
  `15`, `10`, and `6` FPS, with exactly three transparent `96x96` frames each.
- [x] All runtime frames use continuous names, a common `y=88` alpha baseline,
  transparent corners, stable `96x96` canvases, and Nearest texture filtering.
- [x] Existing weapon activation, attack metadata, collision IDs, skill
  modifiers, heavy/aerial/parry/dodge behavior, and Core frame data remain
  unchanged.
- [x] Thin RED/GREEN, bounded related regression, and Godot AI MCP 3.0.2 Main
  runtime acceptance pass with clean logs and non-empty screenshots.

## Preserved Gameplay Contract

| Contract | Preserved value |
| --- | --- |
| Stage startup/recovery | `4/8`, `6/12`, `10/20` frames |
| Core combo range | `0..2` |
| Combo timeout | `300ms` |
| Hitbox activation | Existing immediate `WeaponComponent` call |
| Legacy light hitbox duration | `6` frames, unchanged in this Story |
| Weapon IDs / hitbox IDs | Existing per-weapon runtime contract |
| Damage / cat energy | Existing Core and DamageCalculator values |
| Cancellation | Existing recovery/dodge rules |

## Out of Scope

- Moving hitbox activation onto authored animation frames or changing hitbox
  duration, size, offset, damage, hit stop, trails, audio, or camera shake.
- Reworking Core combo math, the 300ms timeout implementation, or cancellation
  policy.
- Replacing heavy, aerial, parry, dodge, hurt, death, or traversal animations.
- Adding combo HUD counters, tutorial copy, or a new audio mix.

## Implementation Notes

- Idle light attacks explicitly start stage 0. Recovery presses are forwarded
  while Player is attacking, then accepted only when Core resets its attack
  frame to zero for the next stage.
- `_active_light_attack_stage` separates the light-chain presentation from
  heavy attacks and parry counters that also use Player's `ATTACKING` state.
- `get_light_combo_diagnostics()` exposes synchronized Core/Player state for
  focused tests and MCP runtime inspection without duplicating ownership.
- The image-generated sheet is retained with its alpha intermediate and prompt.
  Runtime rows communicate quick slash, rising cross slash, and double-claw
  finisher with increasing silhouette and duration.

## Test Evidence

- Initial RED: `reports/report_1709/results.xml`; expected failures proved
  missing `attack_2`/`attack_3` and real recovery input staying on combo 0.
- Final focused GREEN: `reports/report_1713/results.xml`, `2/2` passed with
  frame-path, size, alpha, speed, loop, filter, real-input and hold assertions.
- Final bounded related GREEN: `reports/report_1714/results.xml`, `20/20`
  passed across six directly related suites; no full suite was run.
- Godot's GdUnit wrapper intentionally reports refused remote-debug port `0`;
  the related run also retains its pre-existing exit cleanup leak warning.
  Test cases completed with exit code `0` and no test errors or failures.
- Runtime evidence:
  `production/qa/evidence/cinderpaw-real-input-three-stage-light-combo-2026-07-14.md`.

## Test-Criterion Traceability

| Criterion | Test / Evidence | Status |
| --- | --- | --- |
| Real input reaches all three stages | Story166 focused test + MCP | PASS |
| Hold and fourth-stage rejection | Story166 focused test + MCP | PASS |
| Core/Player `12/18/30` synchronization | Focused test + MCP diagnostics | PASS |
| Three generated animation sets | PNG inspection + SpriteFrames test | PASS |
| Stable alpha baseline and Nearest filter | Asset metadata + focused test | PASS |
| Existing combat chain preserved | Bounded 20-case regression | PASS |
| Clean Main runtime and screenshots | MCP run `r55211566-9` | PASS |

## Completion Notes

**Completed**: 2026-07-14

**Criteria**: 8/8 passing

**Deviation**: This Story intentionally leaves the existing six-frame weapon
hitbox lifetime unchanged. Aligning hitbox activation and duration to authored
startup/active animation frames needs a separate collision-timing Story so it
can be balanced and regression-tested without conflating visible combo repair
with combat-data changes.
