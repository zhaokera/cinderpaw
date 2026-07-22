# Story 037: Rat Minion Hurt/Death Frame Readability

> **Epic**: Combat Presentation
> **Status**: Complete
> **Layer**: Gameplay / Presentation Integration
> **Type**: Visual/Feel + Frame Animation Contract
> **Estimate**: S
> **Manifest Version**: 2026-07-21
> **Last Updated**: 2026-07-21

## Context

Story202 completed the Factory Coil Pincer production-combat handoff, but also
confirmed that shared `RatMinion` reactions ended before their authored frames
could be read. `hurt` was interrupted after five physics frames, and death
started fading after `0.18s`, before the three-frame `death` animation completed.
Factory encounter callbacks could also hide a defeated rat in the same frame.

This Story makes the existing generated Rat Minion, Factory Spark Rat and
Factory Coil Rat frames readable without changing damage, AI, attack timing,
encounter persistence or asset resources.

**GDD**: `design/gdd/combat-presentation.md`,
`design/gdd/health-death.md`, `design/gdd/feline-combat.md`

**Governing ADRs**: ADR-0002 Signal Communication; ADR-0004 Collision
Detection; ADR-0005 Combat State Machine; ADR-0006 Enemy AI.

**Engine**: Godot 4.7 | **Risk**: MEDIUM

## Acceptance Criteria

- [x] Shared Rat Minion families keep `AnimatedSprite2D + SpriteFrames` and use
  their existing three-frame, non-looping `hurt` and `death` animations.
- [x] `hurt` lasts for the authored animation duration. At `3 frames / 8 fps`,
  the state remains active for `23` physics frames at the project 60 Hz tick.
- [x] Character-hit flash remains exactly three physics frames and resets to
  normal modulation while the longer hurt reaction finishes.
- [x] Lethal damage immediately disables combat physics, body collision and
  hurtbox interaction, while the full `3 frames / 6 fps` death animation stays
  visible at full alpha.
- [x] The completed death pose remains visible for `2.0s`, then fades over
  `0.22s` and frees the node.
- [x] Synchronous Factory defeat callbacks cannot hide the shared death
  presentation. Durable encounter state and partner-survivor behavior remain
  immediate and unchanged.
- [x] Factory Spark Rat and Factory Coil Rat inherit the same behavior without
  duplicating controller code or changing their SpriteFrames resources.
- [x] One canonical GdUnit test covers real HealthComponent signals, complete
  hurt/death frame progression, Factory parent callback behavior and cleanup.
- [x] Related Rat King summon and Factory Stories 080-082/200-202 pass.
- [x] Godot MCP drives the real Factory player attack and Area2D collision
  chain, records non-empty screenshots, verifies death cleanup and reports no
  game/editor errors.

## Thin TDD / Verification

- RED: one canonical test proves the old flash was too long, `hurt` stopped at
  frame zero, death faded before completing and the node freed too early.
- GREEN: derive reaction duration from SpriteFrames, separate hit-flash time,
  then hold the completed death pose before a short fade.
- Related: only shared Rat Minion consumers and the directly affected Factory
  encounter contracts are included; no full-suite run.
- Runtime: one Godot MCP Factory run with real `attack` input, real collision,
  hurt/death probes, screenshots, cleanup probe and log inspection.

## Out of Scope

- New visual/audio assets, VFX, hitstop tuning, damage, HP, enemy movement,
  attack cadence, Rat King behavior or save-schema changes.
- Coil Pincer natural spawn separation and Story083 production combat/handoff.
- Applying this death-presentation contract to unrelated enemy families.

## Asset Use

No image generation was required. The Story reuses the registered transparent
`96x96` Rat Minion, Factory Spark Rat and Factory Coil Rat animation frames.
No PNG, `SpriteFrames`, asset manifest or entity inventory entry changed.

## Completion Evidence

- Canonical RED `reports/report_2208/results.xml`: `1` case with `7` expected
  failures and zero errors.
- Factory-parent diagnostic RED `reports/report_2211/results.xml`: `1` case
  with `4` expected failures, including same-frame Factory hiding.
- Focused GREEN `reports/report_2213/results.xml`: `1/1`, zero failures/errors.
- Final bounded related `reports/report_2214/results.xml`: nine suites and
  `18/18`, zero failures/errors/flaky/skipped/orphan cases.
- Factory headless smoke ran `180` frames and exited `0`; its shutdown emitted
  the existing Factory-family `4 ObjectDB / 2 resources` teardown diagnostic,
  also present in earlier unrelated Factory smoke logs.
- Godot 4.7 / Godot AI MCP 3.0.4 accepted run `r122286549-38` used the real
  `attack` Input action and `cat_claw_light` collision to deal `12 + 12` damage
  to entity `2102`. MCP observed `hurt` frame `1`, then full-alpha `death`
  frame `2`, combat physics disabled, and final node cleanup after the hold.
- The same run inspected the production Coil Rat as `AnimatedSprite2D` with
  `hurt=3@8fps` and `death=3@6fps`. Both returned game screenshots were non-empty
  RGB `1278x718`; game log contained helper registration only and editor log was
  empty before a clean stop.
- Full QA evidence:
  `production/qa/evidence/rat-minion-hurt-death-frame-readability-2026-07-21.md`.

**Status**: [x] Complete.
