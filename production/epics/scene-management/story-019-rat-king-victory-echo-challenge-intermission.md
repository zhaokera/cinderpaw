# Story 019: Rat King Victory Echo Challenge Intermission

> **Epic**: Scene Management
> **Status**: Complete
> **Layer**: Feature / Gameplay Integration
> **Type**: Gameplay / Pacing / Visual / Save
> **Estimate**: M
> **Manifest Version**: 2026-07-19
> **Last Updated**: 2026-07-19

## Context

**GDD**: `design/gdd/game-concept.md`, `design/gdd/boss-config.md`,
`design/gdd/scene-management.md`

**Requirements**: Boss-clear breathing room, player-owned encounter start,
deterministic save/restore, `TR-scene-004`

**ADR Governing Implementation**: ADR-0007: Scene management architecture,
ADR-0021: Save system architecture

Story169 made the Rat King reward menu's Continue action immediately activate
Echo Guardian in the same Main runtime. That closes a technical handoff but
removes the GDD's post-Boss stopping point: the player cannot use the Scrap
Roost savepoint, review rewards or choose the next route before another Boss
locks the room. This Story supersedes only that automatic activation step with
a safe intermission and an explicit, visible challenge point.

**Engine**: Godot 4.7 | **Risk**: MEDIUM

## Acceptance Criteria

- [x] A live Rat King defeat records the safe-intermission flag before the
  defeated flag; Continue exits victory, restores control and leaves Echo
  Guardian AI, collision, HUD, camera lock, arena frame and room seals inactive.
- [x] A generated, imported Echo challenge beacon becomes visible after
  Continue. Its proximity prompt never appears before Rat King defeat or after
  Echo Guardian starts/has been defeated.
- [x] Only a real `interact` action while the player is in challenge range sets
  the once-only encounter-started flag and atomically activates Echo Guardian,
  its HUD, camera lock, arena frame and room seals.
- [x] Starting the challenge captures the existing Boss-entry no-loss snapshot
  through `GameFlowController`, so subsequent death/retry still targets the Echo
  Guardian encounter.
- [x] New saves preserve both intermission and started states. Legacy saves that
  contain Rat King defeat but neither new flag preserve Story156's historical
  automatic Echo Guardian activation.
- [x] The marker uses generated bitmap art through a `Sprite2D`; no visible
  `ColorRect`, `Polygon2D` or plain block is added.
- [x] One intentional RED/GREEN acceptance, bounded Story156/169 regression and
  one Godot MCP runtime pass verify real movement/interact, persistence, visible
  activation, screenshot and clean logs.

## Implementation Notes

- Add `boss_02_intermission_started` and `boss_02_encounter_started` to Main's
  existing world-progress flags; do not add another Autoload or save schema.
- `_should_activate_boss2_encounter()` keeps legacy fallback behavior only when
  both flags are absent. New live defeats always write the intermission flag.
- The challenge beacon is scene presentation owned by Main. Shared Echo
  Guardian AI, collision, camera, HUD and room-seal systems remain unchanged.

## Thin TDD / Verification

- RED: one Main acceptance proves Continue currently starts Boss2 immediately
  and the authored challenge beacon/API do not exist.
- GREEN: persist the intermission, expose the challenge point and route one real
  `interact` action through the existing atomic Boss2 activation path.
- Related: Story156 legacy restore and Story169 same-runtime handoff only; update
  the latter's superseded expectation instead of widening to the full suite.
- Runtime: one Main MCP run defeats Rat King through the existing test probe,
  continues to the safe state, moves to the beacon, sends `interact`, then
  checks Echo nodes, HUD, seals, camera, screenshot and logs.

## Out of Scope

- Echo Guardian attack changes, balance, animation replacement or rewards.
- A new room, Sewer implementation, Rat King combat retuning or dialogue.
- Reworking the retry menu, skill tree or Scrap Roost savepoint.

## Dependencies

- Depends on: Scene Management Stories001-007, 014-018.
- Supersedes only the automatic activation clause of Player Abilities Story169.
- Reuses: Main, GameFlowController, Echo Guardian, Boss2 HUD/camera/seals and
  existing world-progress save snapshot.

## Test Evidence

- Intentional RED: `reports/report_1967/report_1/results.xml` ran the single
  Story019 acceptance and failed only on the old automatic handoff and missing
  challenge contract.
- Focused GREEN: `reports/report_1969/report_1/results.xml` passed `1/1` with no
  errors, failures, flaky cases, skips or orphans.
- Bounded related GREEN: `reports/report_1972/report_1/results.xml` passed the
  Story019 acceptance plus updated Story156/169 sequencing `3/3`, including the
  explicit legacy-save fallback, with a clean exit code `0`.
- Godot 4.7 / Godot AI MCP 3.0.2 accepted run `r291709325-91` (token `91`). A
  real mouse Continue entered the safe state, real movement reached challenge
  range, and physical `E` activated Echo Guardian. Runtime diagnostics proved
  AI target, physics, collision `2/17`, arena frame, HUD, camera and seals;
  both flags were present in the save snapshot. Two `1278x718` screenshots were
  non-empty, game output contained three info lines, editor logs were empty and
  the game stopped cleanly.
- Detailed evidence:
  `production/qa/evidence/rat-king-victory-echo-challenge-intermission-2026-07-19.md`.
