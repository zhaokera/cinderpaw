# Story 036: Rat King Phase-I Runtime Intro

> **Epic**: Combat Presentation
> **Status**: Complete
> **Layer**: Gameplay / Presentation Integration
> **Type**: Boss Activation
> **Estimate**: S
> **Manifest Version**: 2026-07-18
> **Last Updated**: 2026-07-18

## Context

**GDD**: `design/gdd/boss-config.md`

**ADR Governing Implementation**: ADR-0002: Signal communication,
ADR-0005: Combat state machine

Story035 authored a distinct three-frame `phase_1_intro`, but the production
Rat King still enters `idle` when Main starts. The prior MCP probe had to stop
Boss physics and force the animation, so it did not prove a playable entrance.
This Story makes that existing animation the natural Phase-I activation gate
without turning it into a cinematic or changing combat balance.

**Engine**: Godot 4.7 | **Risk**: MEDIUM

## Acceptance Criteria

- [x] A live Phase-I Rat King naturally enters `phase_1_intro` once on the
  first physics frame of each Boss attempt; `idle` cannot overwrite it.
- [x] The duration is derived from the existing three-frame, non-looping,
  `4 fps` `SpriteFrames` resource (`0.75s`) rather than duplicated as a tuning
  constant.
- [x] While the intro is active, Rat King damage is rejected, AI and attack
  requests do not advance, and every attack Hitbox remains inactive; body and
  terrain collision remain intact.
- [x] Player control, pause, movement and combat input remain available. The
  Story does not pause SceneTree or apply a cinematic player-control lock.
- [x] Completion hands off exactly once to `idle` and normal Phase-I attack
  startup. A repeated request in the same attempt is ignored.
- [x] Boss-attempt reset/retry re-arms the intro. A defeated Rat King,
  `victory_pending`/`victory`, Phase II/III, or Echo Guardian handoff skips it,
  without adding a persistent save flag or emitting a fake phase-change event.
- [x] One focused GdUnit integration test covers natural start, invulnerability,
  player control, handoff, retry replay and defeated-state skip. Related Rat
  King contracts pass.
- [x] Godot MCP launches the real Main scene without forcing Sprite playback,
  observes intro frame progression and idle/attack handoff, records a non-empty
  screenshot, and reports no new game/editor errors.

## Thin TDD / Verification

- RED: one real Main integration test rejects the missing natural activation
  API and runtime state.
- GREEN: add one bounded Rat King intro state and Main attempt-lifecycle hook,
  then run the focused test plus the smallest related Boss regressions.
- Runtime: one MCP Main launch, one natural intro timeline, one screenshot,
  game/editor log inspection and clean stop.

## Out of Scope

- New art, animation frames, camera choreography, letterboxing, phase title,
  audio, VFX, player lock, attack tuning, arena mutation, or save-schema data.
- Reusing the normal Phase II/III transition queue for Phase-I activation.

## Dependencies

- Depends on: Combat Presentation Stories 014-015 and 035.
- Depends on: Boss Config Stories 007-009.
- Depends on: AGENTS.md Godot frame-animation and MCP verification rules.

## Completion Evidence

- Intentional RED `reports/report_1915`: the focused suite failed its first
  assertion because Main did not expose or start a production intro flow.
- Focused GREEN `reports/report_1917`: Story036 passed `1/1` with zero errors,
  failures, flaky, skipped or orphan cases.
- Final bounded related GREEN `reports/report_1921`: Story036, authored intro
  assets, Rat King runtime, Main attack chain and sequential Boss handoff passed
  `11/11`; exit `0` with clean process teardown.
- Godot MCP 3.0.2 / Godot 4.7 run `r237489661-70` reloaded the real Main scene
  and naturally observed frame `0` then frame `1` without forcing animation or
  disabling physics. Intro damage left HP at `300/300`, attack requests were
  rejected, and player control remained unlocked.
- After `0.75s`, MCP observed one completion and `idle`, then a real
  `claw_swipe` request entered `startup`. Game logs contained three info rows,
  editor logs were empty, and stop restored readiness to `ready`.
- Non-empty `1278x718` screenshot:
  `reports/visual/cinderpaw-mcp-rat-king-phase-one-runtime-intro-20260718.png`.
- Full evidence:
  `production/qa/evidence/rat-king-phase-one-runtime-intro-2026-07-18.md`.
