# Story 018: Echo Guardian Death Presentation Hold

> **Epic**: Combat Presentation
> **Status**: Complete
> **Layer**: Presentation / Gameplay Runtime Integration
> **Type**: Visual/Feel + Integration
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-14

## Context

**GDD**: `design/gdd/health-death.md`, `design/gdd/boss-config.md`,
`design/gdd/player-abilities.md`

**Requirements**: `TR-health-003`, `TR-ability-005`

**ADR Governing Implementation**: ADR-0002 Signal communication; ADR-0005
Combat state machine; ADR-0007 Scene management; ADR-0018 Player abilities.

Echo Guardian already owns a three-frame image-generated `death` animation,
but Main synchronizes the defeated flag, hides the Boss, releases the arena,
and reveals the Double Jump reward in the same frame. The GDD requires Boss
death to remain readable for `2-3s`. This Story makes the existing animation
player-visible before the mainline reward handoff continues.

## Acceptance Criteria

- [x] Lethal damage starts a deterministic `2.0s` Echo Guardian death
  presentation while its `AnimatedSprite2D` remains visible on the three-frame
  non-looping `death` animation.
- [x] During the hold, the persistent defeated flag is committed, active Boss
  hitboxes stay disabled, the Double Jump reward remains unavailable, Boss2
  camera framing and room seals remain active, and player control is locked.
- [x] Advancing less than `2.0s` does not release the presentation; duplicate
  defeat callbacks cannot restart or shorten it.
- [x] At completion, Main hides the defeated Boss, releases camera framing and
  room seals, unlocks player control, exposes the existing Double Jump reward,
  and shows the existing claim notification exactly once.
- [x] Existing restore/payoff behavior remains post-victory and idempotent; a
  loaded defeated Boss does not replay the transient presentation.
- [x] Focused RED/GREEN, bounded Boss2 regressions, target smoke, and Godot MCP
  runtime evidence verify timing, animation visibility, reward state, arena
  state, screenshot, and clean logs.

## Out of Scope

- New Echo Guardian art, sound, attacks, balancing, phase logic, reward logic,
  arena geometry, or a generic cutscene framework.
- Changing Rat King, Sluice Matriarch, or Crown Warden death presentation.
- Persisting the transient presentation timer in save data.

## Implementation Notes

- Reuse the existing image-generated three-frame `death` animation under
  `assets/characters/boss2_echo_guardian/death/`.
- Commit durable defeat progress immediately, but gate scene synchronization
  while the presentation is pending.
- Keep the timing deterministic through an explicit MainScene advance API so
  GdUnit and MCP can verify exact boundaries without wall-clock sleeps.

## Test Evidence

- `tests/unit/gameplay/echo_guardian_death_presentation_hold_test.gd`
- `tests/smoke/echo_guardian_death_presentation_hold_smoke.gd`
- Godot MCP evidence under `production/qa/evidence/`.

**Status**: [x] Complete.

- Expected RED: `reports/report_1652/results.xml`, `1` case with `2` failures
  because Main lacked the Story018 diagnostics and deterministic advance APIs.
- Focused GREEN: `reports/report_1653/results.xml`, `1/1` passing.
- Final bounded related GREEN: `reports/report_1655/results.xml`, `17/17`
  across Story018, payoff, route handoff, camera, room seals, attack, and
  sequential Boss handoff.
- Target smoke:
  `reports/echo_guardian_death_presentation_hold_smoke.log`, exited `0` and
  printed `echo_guardian_death_presentation_hold_smoke=passed`.
- Godot MCP `2.9.2` run `r24878458-30` verified the exact `2.0s` hold,
  three-frame `death`, disabled hitboxes, held camera/room seals, delayed
  reward, completion release, a nonblank `1278x718` screenshot, three
  info-only game logs, zero editor logs, and clean stop to `ready`.

## Completion Notes

**Completed**: 2026-07-14
**Criteria**: 6/6 passing
**Assets**: No new asset. Reuses the existing image-generated Echo Guardian
`death` frames and existing arena/reward art.
**QA Evidence**:
`production/qa/evidence/echo-guardian-death-presentation-hold-2026-07-14.md`
