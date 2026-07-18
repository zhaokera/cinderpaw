# Story 176: Crown Warden Dedicated Phase Transition Frame Animation

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Boss Combat / Visual Integration / Data
> **Type**: Visual/Feel + Frame Animation + Data Integration
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-19

## Context

Story163 made Crown Warden's Phase II transition mechanically correct, but it
reused the non-looping three-frame `hurt` animation. At `8 FPS` that animation
finishes in `0.375s`, leaving the Boss frozen in a hit reaction for about
`2.125s` of the `2.5s` rules-change window. This Story replaces only that
presentation mapping with a dedicated generated loop while preserving the
verified Story163 combat contract.

**GDD**: `design/gdd/boss-config.md`,
`design/gdd/combat-presentation.md`.

**Governing ADRs**: ADR-0002 Signal Communication; ADR-0004 Collision
Detection; ADR-0005 Combat State Machine; ADR-0006 AI Framework; ADR-0010
Combat Presentation; ADR-0019 Health/Death; ADR-0020 Damage Calculator.

## Acceptance Criteria

- [x] Add `phase_transition` to Crown Warden's existing
  `AnimatedSprite2D + SpriteFrames` surface with exactly three distinct frames,
  `6 FPS`, and `loop=true`.
- [x] Runtime frames are continuously named transparent sRGBA `192x192` PNGs
  under `assets/characters/crown_warden/phase_transition/`; their center and
  floor baselines remain within the Story146 tolerance.
- [x] Retain the image-generation source, alpha intermediate, exact prompt,
  processing details, hashes and Godot import sidecars.
- [x] Phase II data maps `transition_animation` to `phase_transition`; ordinary
  damage still uses the unchanged `hurt` animation and defeat still uses the
  unchanged `death` animation.
- [x] Crossing `80/160` HP during `wing_sweep` remains pending until the full
  active/recovery chain ends, then starts one exact `2.5s` transition.
- [x] During transition the Boss remains stationary and invulnerable, both
  attack hitboxes are closed, Hurtbox is `gone`, and new attacks are rejected.
- [x] The existing single signal still drives one overlay, 32 debris pieces,
  Phase II HUD and `boss_phase_transition / sfx_boss_phase`; metadata changes
  only its animation value.
- [x] At `2.49s` transition remains active. At `2.50s` the Boss returns to
  `idle`, restores a normal Hurtbox, keeps hitboxes closed, sets cooldown to
  `30`, and accepts an explicit `talon_dive` request.
- [x] Focused RED/GREEN, the smallest related Boss4 regression, the existing
  target smoke, and one Godot 4.7 + MCP 3.0.2 runtime acceptance pass without
  project errors and with a non-empty screenshot.

## Out Of Scope

- No changes to `crown_warden_boss.gd`, `crown_warden_arena.gd`, scene nodes,
  HP, threshold, attack timing, damage, Phase II modifier, cooldown or collision
  geometry.
- No new signal, overlay, debris, HUD, audio, camera, hitstop, attack, phase,
  reward, save, route or death behavior.
- No regeneration or remapping of the existing `idle`, `run`, attack, `hurt`
  or `death` frames, and no rewrite of Story163's historical evidence.

## Implementation Notes

- `crown_warden_sprite_frames.tres` now contains 27 frames across nine
  animations. The new three-frame loop is additive.
- `data/combat/boss_configs.json` changes the Phase II animation mapping from
  `hurt` to `phase_transition`; the existing configuration-driven state machine
  required no gameplay-script changes.
- The generated visual uses a compact royal lock, a broad symmetric energy
  crest, and a stable empowered return. It avoids the red warning language,
  forward translation and unilateral strike silhouette used by attacks.

## Test Evidence

- Intentional RED `report_1942`: `1/1` failed only because the dedicated
  animation did not yet exist; `0` engine errors or orphans.
- Focused GREEN `report_1943`: `1/1` passed.
- Bounded related GREEN `report_1944`: Story176, Story163, Boss4 core and death
  hold passed `9/9`, with `0` failures, errors, skipped, flaky tests or orphans.
- The existing target smoke printed
  `crown_warden_phase_two_transition_feedback_smoke=passed` and exited `0`.
- Godot MCP run token `79` verified natural frame progression, the exact
  `2.49s/2.50s` boundary, preserved presentation/audio outputs, clean final
  logs and a non-empty `1278x718` game screenshot.
- Full traceability is recorded in
  `production/qa/evidence/crown-warden-dedicated-phase-transition-frame-animation-2026-07-19.md`.

## Completion Notes

- Completed 2026-07-19 as a bounded asset/SpriteFrames/configuration change.
- The broader complete-game goal remains active. The next slice should come
  from a short player-visible critical-path audit and prioritize playable ACT
  depth over another presentation-only pass.
