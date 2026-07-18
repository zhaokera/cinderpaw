# Story 021: Sewer Pressure Ambush

> **Epic**: Scene Management
> **Status**: Complete
> **Layer**: Feature / Gameplay Integration
> **Type**: Gameplay / Combat / Visual / Persistence
> **Estimate**: M
> **Manifest Version**: 2026-07-19
> **Last Updated**: 2026-07-19

## Context

**GDD**: `design/gdd/game-concept.md`,
`design/gdd/exploration-ability-gating.md`, `design/gdd/scene-management.md`

**ADR Governing Implementation**: ADR-0004: Collision architecture,
ADR-0007: Scene management architecture

Story020 established the physical Dash entry but intentionally ended before
combat. Story021 extends the same registered Sewer to a second pressure chamber:
the player crosses a real trigger, reads an animated pressure warning, defeats
one production frame-animated Sluice Leech, claims a one-shot salvage cache and
returns to Main. It does not grant Double Jump or open Factory.

**Engine**: Godot 4.7 | **Risk**: MEDIUM

## Acceptance Criteria

- [x] `area_02_sewer` extends to a second `1280x720` chamber with a separately
  imported image-generated background, authored floor and `2560px` camera limit.
- [x] Only a completed Dash crossing permits the deep-room trigger. Activation
  starts a four-frame `warning -> active` back-pressure beat, one existing
  `FactorySluiceLeech` and a blocking visible seal.
- [x] The leech uses production combat adapters plus `AnimatedSprite2D +
  SpriteFrames`; `idle/run/attack_tell/attack/hurt/death` each have at least
  three frames.
- [x] Real Player attacks are the only clear path. Death or pressure contact
  performs a no-loss deep-room reset with a fresh full-HP enemy; a cleared
  encounter never respawns it.
- [x] Defeat emits one kill confirmation, makes the pressure safe, removes the
  seal and enables one salvage claim worth `15 Gears`.
- [x] Currency, clear and claimed state persist through `get_local_state()` /
  `set_local_state()` and Main return. Cold restore does not duplicate the enemy
  or reward.
- [x] The exit still targets only `main/sewer_return`; no request or world flag
  unlocks `area_03_factory`, and Cinderpaw does not receive Double Jump.
- [x] One intentional RED, focused GREEN, bounded Sewer/Factory regression and
  one clean post-fix MCP runtime acceptance provide evidence without a full
  suite.

## Implementation Notes

- The first Story020 room remains intact at `x=0..1280`; the pressure chamber is
  `x=1280..2560`. The old right wall and exit move to the new far boundary.
- The pressure vent forms a readable back edge after entry. The forward seal
  prevents running past the enemy; both become safe/non-blocking after defeat.
- Existing generated Sluice Leech, Underground seal/cache and steam frames are
  deliberately reused. Only the new opaque room background required generation.
- Main transfers current currency into Sewer and receives the updated amount on
  return. SceneManager continues to own state capture and scene swapping.

## Out of Scope

- Sewer-to-Factory transition, Factory unlock, Double Jump acquisition or gate
  migration.
- New enemy family, shared enemy balance changes, dialogue, tutorial text,
  minimap expansion, Boss, second wave or complete Sewer zone production.

## Test Evidence

- Intentional RED: `reports/report_1981/report_1/results.xml` failed the single
  acceptance only because `get_sewer_act_depth_diagnostics()` did not exist.
- Focused GREEN: `reports/report_1982/report_1/results.xml` passed `1/1` with
  zero errors, failures, flaky cases, skips or orphans and exit `0`.
- Related GREEN: `reports/report_1983/report_1/results.xml` passed the existing
  Sewer round trip and Factory Double-Jump route suites, `4/4`, with zero test
  errors/failures/flaky/skips/orphans and exit `0`. No full suite ran.
- Fresh pre-commit verification: `reports/report_1984/report_1/results.xml`
  passed all three bounded suites, `5/5`, with zero test errors, failures,
  flaky cases, skips or orphans and exit `0`.
- Godot MCP 3.0.2 final post-fix run `r297957500-99` (token `99`) restored the
  cleared/claimed state, kept Gears at `22`, showed no active enemy or seal,
  produced a non-empty `1278x718` screenshot, returned one game info line and
  zero editor errors, then stopped in `ready`.
- Detailed evidence:
  `production/qa/evidence/sewer-pressure-ambush-2026-07-19.md`.
