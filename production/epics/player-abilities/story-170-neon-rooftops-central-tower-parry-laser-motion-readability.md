# Story 170: Neon Rooftops Central Tower Parry-Laser Motion Readability

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Presentation / Environment Runtime
> **Type**: Visual/Feel + Frame Animation Contract
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-17

## Context

**GDD**: `design/gdd/player-abilities.md`,
`design/gdd/combat-presentation.md`,
`design/gdd/exploration-ability-gating.md`

**Requirements**: `TR-ability-001`, `TR-combatfx-003`, `TR-explore-006`

**Governing ADRs**: ADR-0001 player runtime, ADR-0002 signals, ADR-0004
collision, ADR-0005 combat states, ADR-0010 presentation, ADR-0018 abilities.

Story139 delivered a playable three-parry Central Tower laser trial, but one
static pulse texture represented telegraph, strike and both recovery outcomes.
This Story adds state-specific frame motion without moving the fixed gameplay
anchor or changing the established parry timing and damage contract.

## Acceptance Criteria

- [x] The existing `LaserPulseVisual` remains at `(4480, 500)` as the hidden
  gameplay anchor used by strike-lane distance checks.
- [x] One runtime `AnimatedSprite2D` named `LaserPulseAnimation` uses a shared
  `SpriteFrames` resource with `telegraph`, `strike`, `recovery_reflected`, and
  `recovery_missed`.
- [x] Every animation contains three transparent sRGBA `512x128` frames with
  continuous names and one common center; telegraph loops while strike and
  both recoveries are non-looping.
- [x] Successful real parry input selects the cyan/gold reflected recovery;
  an unresolved strike selects the decaying red missed recovery.
- [x] Telegraph `0.60s`, strike `0.18s`, recovery `0.55s`, three required
  parries, miss damage `18`, collision, persistence and gate behavior remain
  unchanged.
- [x] Thin RED, bounded related GdUnit regression and one Godot AI MCP 3.0.2
  runtime acceptance verify frame motion, real input, logs and a non-empty
  screenshot.

## Out Of Scope

- New pulse states, parry windows, damage tuning, gate rules or persistence
  keys.
- Moving or replacing the fixed gameplay anchor.
- New particles, shaders, audio events or additive beam copies.

## Implementation Notes

- The controller creates the presentation node at runtime beside the legacy
  anchor, copies its transform, z-index and nearest filtering, then keeps the
  legacy sprite hidden.
- Gameplay timers remain authoritative. Animation completion cannot apply
  damage, increment a parry or unlock the gate.
- `STATE_RECOVERY + _last_pulse_reflected` is only a visual mapping; no new
  gameplay state was introduced.
- Four image-generated RGB strips were keyed to alpha, fixed-cropped and
  normalized to twelve runtime frames. Source, alpha intermediates and preview
  remain under the asset root.

## Test Evidence

- Initial RED: `reports/report_1867/report_1/results.xml`, one acceptance case
  with thirteen expected failures for the absent resource, frames and runtime
  node.
- Final bounded GREEN: `reports/report_1871/results.xml`, `10/10` passed across
  Story170, Story139 and Neon Rooftops combat-impact coverage with zero test
  errors, failures, flaky cases, skips or orphans; exit code `0`.
- Runtime evidence:
  `production/qa/evidence/neon-rooftops-central-tower-parry-laser-motion-readability-2026-07-17.md`.

## Test-Criterion Traceability

| Criterion | Test / Evidence | Status |
| --- | --- | --- |
| Four named three-frame animations | Story170 focused test + asset audit | PASS |
| Fixed gameplay anchor | Story170 focused test + MCP diagnostics | PASS |
| Real-input reflected mapping | MCP run `r181947024-53` | PASS |
| Missed recovery and damage contract | Story170/Story139 tests + MCP | PASS |
| Perfect-parry feedback preserved | Neon Rooftops combat-impact test | PASS |
| Visible runtime and logs | MCP screenshot/log read | PASS |

## Completion Notes

**Completed**: 2026-07-17

**Criteria**: 6/6 passing

**Deviation**: Runtime PNG disk size is `380 KiB` and decoded texture budget is
`3 MiB`, an explicit VFX exception to the Art Bible's generic small-sprite
target. Only one `512x128` quad is visible at a time.
