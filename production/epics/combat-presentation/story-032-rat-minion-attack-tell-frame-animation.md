# Story 032: Rat Minion Attack Tell Frame Animation

> **Epic**: Combat Presentation
> **Status**: Complete
> **Layer**: Feature / Presentation / Combat Runtime
> **Type**: Visual/Feel + Frame Animation Contract
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-16

## Context

**GDD**: `design/gdd/feline-combat.md`, `design/gdd/boss-config.md`,
`design/gdd/combat-presentation.md`

**Requirements**: `TR-combat-001`, `TR-ai-007`

**ADR Governing Implementation**: ADR-0001 input boundaries; ADR-0002 signal
communication; ADR-0004 collision; ADR-0005 combat state machine; ADR-0006 AI;
ADR-0010 presentation; ADR-0018 runtime integration.

The Rat King summon already had a seven-frame bite warning state but displayed
the same `attack` frames as its four-frame active hitbox. This Story gives the
startup a dedicated generated anticipation sequence without changing combat,
AI or summon behavior.

## Acceptance Criteria

- [x] `attack_tell` is a non-looping three-frame SpriteFrames animation backed
  by continuous transparent `96x96` PNGs in the required character path.
- [x] All three frames share the same size, horizontal center, direction and
  `y=91` ground baseline.
- [x] `request_attack()` selects `attack_tell`; the bite hitbox remains disabled
  for the complete seven-frame startup.
- [x] Advancing the seventh frame selects the existing `attack` animation and
  activates the unchanged bite hitbox with damage `8`.
- [x] Rat King live-summon lifecycle and Factory Spark Rat's independent tell
  override remain compatible.
- [x] Thin RED/GREEN, bounded related regression and Godot AI MCP 3.0.2 runtime
  acceptance pass with clean logs and a non-empty screenshot.

## Implementation Notes

- `_get_attack_tell_animation()` now returns the dedicated base animation.
  Factory Spark Rat keeps overriding this method with its own animation.
- Timing, state transitions, movement, collision metadata, damage and cooldown
  constants are untouched.
- The generated strip, alpha intermediate, exact prompt and runtime frames are
  retained under the Rat Minion asset root.

## Test Evidence

- Initial RED: `reports/report_1853/results.xml`, `1/1` failed only because the
  required `attack_tell` animation did not exist.
- Focused GREEN: `reports/report_1854/results.xml`, `1/1` passed.
- Bounded related GREEN: `reports/report_1855/results.xml`, `12/12` passed
  across Story032, Rat King live summon and Factory Spark Rat attack tell; exit
  code `0`. Existing GdUnit process-exit ObjectDB/resource cleanup messages
  appear after all cases pass.
- Runtime evidence:
  `production/qa/evidence/rat-minion-attack-tell-frame-animation-2026-07-16.md`.

## Test-Criterion Traceability

| Criterion | Test / Evidence | Status |
| --- | --- | --- |
| Three generated transparent frames | Story032 focused test + asset audit | PASS |
| Startup uses tell without hitbox | Story032 focused test + MCP | PASS |
| Seventh frame activates original bite | Story032 focused test + MCP | PASS |
| Summon/subclass compatibility | Bounded related suites | PASS |
| Visible runtime and clean logs | MCP run `r161142464-49` | PASS |

## Completion Notes

**Completed**: 2026-07-16

**Criteria**: 6/6 passing

**Deviation**: None. No gameplay or combat-balance value changed.
