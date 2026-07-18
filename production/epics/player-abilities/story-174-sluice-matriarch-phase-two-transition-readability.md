# Story 174: Sluice Matriarch Phase II Transition Readability

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Feature / Boss Combat / Presentation / Audio
> **Type**: Integration + Gameplay Runtime + Frame Animation
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-18

## Context

Story128 established the Boss3 Phase II threshold and deferred it until the
current attack chain ended. Story173 added the pressure-geyser alternation, but
Phase II still begins as an immediate tint and HUD update. This Story closes the
GDD phase-transition contract with one bounded invulnerable transformation and
routes the existing presentation/audio systems without changing combat balance.

**GDD**: `design/gdd/boss-config.md`, `design/gdd/combat-presentation.md`,
`design/gdd/hud-ui.md`, `design/gdd/audio-system.md`.

**Quick Spec**:
`design/quick-specs/sluice-matriarch-phase-two-transition-readability-2026-07-18.md`.

**Governing ADRs**: ADR-0002 Signal Communication; ADR-0004 Collision
Detection; ADR-0005 Combat State Machine; ADR-0006 AI Framework; ADR-0010
Audio; ADR-0019 Health/Death; ADR-0020 Damage Calculator.

## Acceptance Criteria

- [x] Crossing `60/120` HP during lunge or geyser startup/active/recovery only
  sets Phase II pending; the complete current attack and recovery finish before
  transition begins.
- [x] Transition starts exactly once, lasts `2.5s`, reports
  `phase_transition`, stops movement/new attacks, closes every attack hitbox,
  hides geyser VFX, and sets the Boss Hurtbox to `gone`.
- [x] Arena damage requests return `false` during transition and do not change
  HP or emit ordinary damage feedback. Lethal damage wins over phase change.
- [x] Boss uses a dedicated looping three-frame `phase_transition` animation
  made from transparent, consistently anchored `192x192` PNGs under
  `assets/characters/sluice_matriarch/phase_transition/`.
- [x] The single transition signal reaches CombatPresentation, AudioSystem and
  HUD: Phase II is visible, four-frame phase feedback runs, one overlay and at
  least thirty debris pieces exist, and `sfx_boss_phase` is requested once.
- [x] At `2.49s` transition remains active; at `2.50s` it restores idle,
  `normal` Hurtbox and Phase II cooldown. Story173's next attack remains geyser
  after lunge and uses Phase II `18/10/18` timing.
- [x] Retry, progress-defeated restore and death clear pending state, transition
  timing, attack hitboxes, geyser VFX and temporary presentation state without
  replaying the phase event.
- [x] Built-in image generation source, exact prompt, alpha intermediate,
  processing record, SpriteFrames update, asset spec/manifest, focused
  RED/GREEN, minimal related regression and Godot MCP runtime evidence pass.

## Out Of Scope

- Phase III, summon, arena hazards/mutations, new attacks, balance changes,
  BossConfig migration, parry redesign, death hold, reward, route or save work.
- New scene nodes, bespoke full-screen VFX, camera choreography, new music, or
  global CombatPresentation/AudioSystem refactors.
- Crown Warden's separate `hurt`-animation transition debt.

## Test Evidence

- Intentional RED: `reports/report_1931/results.xml` failed `1/1` on the
  intentionally missing deterministic transition API with `0` engine errors or
  orphans.
- Focused GREEN: after Godot 4.7 imported the generated PNGs,
  `reports/report_1933/results.xml` passed `1/1` with `0` failures, errors,
  skipped, flaky tests, or orphans. Intermediate `report_1932` was discarded
  because missing import sidecars produced loader errors despite assertions
  passing.
- Related regression: `reports/report_1935/results.xml` passed the five directly
  related Boss3 suites `14/14` with `0` failures, errors, skipped, flaky tests,
  or orphans. `report_1934` identified and retired two pre-Story174 test
  assumptions: nine total animations and immediate Phase II attacks.
- Godot MCP runtime: session `cinderpaw@af5f`, run token `74`, Godot
  `4.7-stable`, plugin/server `3.0.2`. Runtime probes verified deferred entry,
  the exact `2.49s/2.50s` boundary, transition invulnerability, three looping
  frames, clean collision restoration, Phase II geyser timing, HUD,
  presentation and audio routing, zero editor errors and helper-only game log.
  The non-empty `1278x718` screenshot is retained at
  `reports/visual/cinderpaw-mcp-sluice-matriarch-phase-two-transition-20260718.png`.
- Full evidence:
  `production/qa/evidence/sluice-matriarch-phase-two-transition-readability-2026-07-18.md`.

## Dependencies

- Depends on: Story128 playable Boss3 core and Story173 pressure-geyser pattern.
- Preserves: Story129 aerial-attack reward payoff and Story130 route handoff.
