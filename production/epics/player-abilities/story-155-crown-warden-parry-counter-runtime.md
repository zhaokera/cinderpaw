# Story 155: Crown Warden Parry Counter Runtime

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Combat Runtime / Boss Config / Presentation / Audio
> **Type**: Integration + ACT Feel
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-14

## Context

**GDD**: `design/gdd/feline-combat.md`, `design/gdd/boss-config.md`,
`design/gdd/combat-presentation.md`, `design/gdd/audio-system.md`

**Requirements**: `TR-boss-005`, Feline Combat parry timing/counter outcome,
Player Abilities Story146 downstream parry integration.

Story146's two Boss4 attacks reach the player through real Core collision, and
CombatComponent already classifies PERFECT/GOOD/LATE. BossConfig Story006 also
exposes the approved `5.0x`/no-STUN outcome, but neither boundary is consumed by
the playable Crown Warden fight. Its data entry additionally drifted to
`1.5x + enter_stun`, so the visible parry pose currently does not protect the
player or punish the Boss.

## Acceptance Criteria

- [x] A real Crown Warden hit during Cinderpaw's active parry window resolves
  through CombatComponent and applies zero player HP damage.
- [x] Crown Warden's config resolves every successful parry type to `5.0x` and
  `enter_stun=false`; missed/non-parry outcomes remain neutral.
- [x] The counter uses the current weapon's effective base damage, applies once
  per real Boss contact, records source/timing/damage metadata and does not add
  STUN to Crown Warden.
- [x] The player exits the visible parry pose into the existing multi-frame
  attack/counter presentation while Core remains the timing authority.
- [x] PERFECT forwards the current parry frame to the existing
  CombatPresentation gold afterimage/flash/sparks and routes the existing
  perfect parry SFX; no new visual or audio asset is required.
- [x] Focused GdUnit, bounded related regression, target smoke and one Godot MCP
  run verify real overlap, exact HP delta, one-shot behavior, no STUN, visible
  actors/effect, non-empty screenshot and clean logs.

## Out Of Scope

- New parry timings, Boss attacks, Boss phases, reward flow or weapon balance.
- A new EventBus, Autoload, global parry manager or duplicate combat state.
- Generic enemy STUN integration outside this Boss4 runtime consumer.
- New art/audio generation when the approved generated parry assets already
  satisfy the visible result.

## Test Evidence

- `tests/unit/gameplay/crown_warden_parry_counter_runtime_test.gd`
- `tests/smoke/crown_warden_parry_counter_runtime_smoke.gd`
- `production/qa/evidence/crown-warden-parry-counter-runtime-2026-07-14.md`

**Status**: [x] Complete.

- Initial RED: `reports/report_1627/results.xml`, `1` case with `2` expected
  failures for the drifted `1.5x + enter_stun` BossConfig contract.
- Runtime refinement RED: `reports/report_1628/results.xml`, config GREEN and
  one expected overlap-fixture failure before the test used real physics.
- Focused GREEN: `reports/report_1629/results.xml`, `2/2` passed.
- Final bounded related GREEN: `reports/report_1630/results.xml`, `24/24`
  passed across six related suites with no errors, failures, skips or orphans.
- Target smoke exited `0` with
  `crown_warden_parry_counter_runtime_smoke=passed`.
- Godot `4.7-stable` / MCP `2.9.2` run `r19802568-24` verified a real
  `talon_dive` PERFECT parry: player HP `100 -> 100`, Boss HP `160 -> 110`,
  one `50` damage counter at `5.0x`, no STUN, visible three-frame actors and
  clean final logs.
