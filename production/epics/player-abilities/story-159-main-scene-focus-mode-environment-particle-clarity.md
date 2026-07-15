# Story 159: Main Scene Focus Mode Environment Particle Clarity

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Presentation / Main Runtime
> **Type**: Integration + Combat Readability + Generated Visual
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-14

## Context

**GDD**: `design/gdd/health-death.md`

**Requirements**: `TR-health-008`, Health & Death rule 8 item 3.

Story154 made focus activation visible, Story157 extended new Boss windups and
Story158 amplified Boss attack tells. Rule 8 also requires background particle
interference to fall to `30%` during focus. Main previously had no authored
environment-particle layer, so this slice adds sparse generated dust and wires
only its opacity to the real Player Health focus signal.

## Acceptance Criteria

- [x] Main owns one stable-named `FocusEnvironmentParticles`
  `CPUParticles2D` behind actors, props, ground and HUD but above the background.
- [x] The particle layer continuously emits `24` sparse motes with fixed seed
  `159` and a generated transparent `64x64` dust texture.
- [x] Normal mode uses alpha `1.0`; real focus entry at `25/100` HP with active
  enemies changes only the particle layer to alpha `0.30`.
- [x] Healing above the focus exit threshold restores alpha `1.0`.
- [x] Camera zoom/limits, viewport, background, actors, hitboxes and gameplay
  timing remain unchanged; no persistent vignette or screen mask is added.
- [x] Image-generation source, alpha intermediate, exact processing record and
  Godot import metadata are retained in the project asset pipeline.
- [x] Intentional RED, focused/related GREEN, target smoke and Godot MCP runtime
  verify the lifecycle, node contract, non-empty screenshots and clean logs.

## Out Of Scope

- Rule 8 low-frequency/reverberant hurt-audio final mix.
- A full weather system, GPU particles, collision particles or particle pooling.
- Camera/FOV changes, color grading, blur, vignette or persistent focus overlay.
- Boss windup and attack-tell behavior already owned by Stories157/158.

## Implementation Notes

- `FocusEnvironmentParticles` owns presentation alpha only; Health remains the
  focus-state authority and Main remains the integration adapter.
- The node stays emitting across transitions so focus does not reset particle
  positions or create a gameplay-readable timing cue.
- The GDD contains both a loose "slight vignette" phrase and an explicit visual
  direction requiring no vignette/unchanged view. This bounded Story follows the
  explicit non-vignette requirement and implements only the unambiguous `30%`
  particle-opacity change.

## Test Evidence

- `tests/unit/gameplay/main_scene_focus_mode_environment_particle_clarity_test.gd`
- `tests/smoke/main_scene_focus_mode_environment_particle_clarity_smoke.gd`
- `production/qa/evidence/main-scene-focus-mode-environment-particle-clarity-2026-07-14.md`
- `production/qa/evidence/main-scene-focus-mode-environment-particle-clarity-mcp-run35.json`

**Status**: [x] Complete.

- Initial RED: `reports/report_1664/results.xml`, one case with three expected
  missing-contract failures.
- Focused GREEN: `reports/report_1665/results.xml`, `1/1` passed.
- Bounded related GREEN: `reports/report_1666/results.xml`, `15/15` passed
  across Story159 and directly related focus/Boss/Main-audio contracts.
- Post-MCP-upgrade focused verification: `reports/report_1667/results.xml`,
  `1/1` passed under the project `3.0.2` plugin baseline.
- Target smoke exited `0` with
  `main_scene_focus_mode_environment_particle_clarity_smoke=passed`.
- Godot `4.7-stable` / MCP plugin `2.9.2` clean run `r29075015-35` verified
  normal/focus/restored alpha `1.0/0.3/1.0`, fixed camera framing, two non-empty
  screenshots, three info-only game lines, zero editor lines and clean stop.
- Godot AI MCP was subsequently upgraded and separately boot-validated at the
  project baseline `3.0.2`; focused Story159 and target smoke were rerun after
  the upgrade, while run35 remains the historical visual-runtime evidence.
