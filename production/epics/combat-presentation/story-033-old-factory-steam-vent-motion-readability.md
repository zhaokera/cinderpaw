# Story 033: Old Factory Steam Vent Motion Readability

> **Epic**: Combat Presentation
> **Status**: Complete
> **Layer**: Feature / Presentation / Environment Runtime
> **Type**: Visual/Feel + Hazard Telegraph Contract
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-16

## Context

**GDD**: `design/gdd/combat-presentation.md`,
`design/gdd/player-abilities.md`, `design/gdd/exploration-ability-gating.md`

**Requirements**: `TR-combatfx-003`, `TR-explore-006`

**ADR Governing Implementation**: ADR-0002 signal communication; ADR-0004
collision; ADR-0010 presentation; ADR-0018 runtime integration.

Old Factory had twenty-six gameplay steam-vent instances backed by one static
prop. Periodic vents already exposed grace, warning, active and safe phases,
but the player-facing art did not communicate those windows. This Story adds a
shared generated phase animation while preserving the contact-hazard contract.

## Acceptance Criteria

- [x] All twenty-six Factory steam-vent hazards retain their existing `Visual`
  compatibility node and receive one runtime `AnimatedSprite2D` named
  `SteamAnimation` backed by the shared SpriteFrames resource.
- [x] `safe`, `warning`, and `active` each contain four distinct, looping,
  transparent `256x256` frames with continuous names and a fixed vent base.
- [x] Periodic vent grace/safe windows select `safe`, warning selects
  `warning`, and the damage window selects `active` without changing phase
  durations.
- [x] Hidden or disabled vents stop at frame zero instead of animating offscreen.
- [x] Damage `8`, cooldown `1.0`, player-only filtering, collision layer/mask,
  hazard ids, positions, scale and shape remain unchanged.
- [x] Thin RED/GREEN, bounded related regression and Godot AI MCP 3.0.2 runtime
  acceptance pass with clean logs and a non-empty screenshot.

## Implementation Notes

- `FactorySteamVentHazard` creates the animated presentation child at runtime,
  preserving the existing scene and diagnostic contract used by earlier Stories.
- `OldFactoryEntranceScene` forwards the already-authored phase values for the
  eleven periodic shared vents; no cycle constant or hazard activation rule was
  changed.
- Static always-live vents default to the readable `active` loop. Hidden
  checkpoint fixtures synchronize playback through `visibility_changed`.

## Test Evidence

- Initial RED: `reports/report_1856/results.xml`, expected failure on the absent
  SpriteFrames/runtime animation contract.
- Focused GREEN: `reports/report_1858/results.xml`, `1/1` passed after the
  visibility/playback synchronization fix.
- Bounded related GREEN: `reports/report_1859/results.xml`, `10/10` passed
  across Story033, Story009 contact hazard, Story047 checkpoint gauntlet and
  Story069 forward-pressure traversal; exit code `0`.
- Fresh completion gate: `reports/report_1860/report_1/results.xml`, the same
  four suites passed `10/10` with no errors, failures, flaky, skipped or orphan
  cases; exit code `0`.
- Runtime evidence:
  `production/qa/evidence/old-factory-steam-vent-motion-readability-2026-07-16.md`.

## Test-Criterion Traceability

| Criterion | Test / Evidence | Status |
| --- | --- | --- |
| Twenty-six shared animated instances | Story033 focused test + MCP tree | PASS |
| Four frames for all three phases | Story033 focused test + asset audit | PASS |
| Gameplay phase mapping | Story069 related test | PASS |
| Contact damage and cooldown unchanged | Story009 related test | PASS |
| Hidden playback stops | Story033 focused test + MCP | PASS |
| Visible runtime and clean logs | MCP run `r164212247-51` | PASS |

## Completion Notes

**Completed**: 2026-07-16

**Criteria**: 6/6 passing

**Deviation**: None. No gameplay, balance, collision or encounter timing value
changed.
