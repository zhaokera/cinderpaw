# Story 010: Focus Damage Low-HP Final Mix

> **Epic**: Audio System
> **Status**: Complete
> **Layer**: Presentation / Audio Asset Pipeline
> **Type**: Integration + Audio/Feel + Config/Data
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-14

## Context

**GDD**: `design/gdd/audio-system.md`, `design/gdd/health-death.md`

**Requirements**: `TR-audio-006`, `TR-audio-007`, `TR-health-008`

**ADR Governing Implementation**: ADR-0010 Audio system architecture; ADR-0019
Health component; ADR-0002 Signal communication.

Story003 already routes focused damage to `sfx_damage_taken_lowhp`, and Story005
provided a runnable procedural baseline. Health Rule8 still required a clearly
darker low-frequency damage cue with a damped reverb tail rather than a louder
variant of the normal hit.

This story replaces only the low-HP WAV while preserving its cue id, path,
AudioSystem API, Main damage adapter, and SFX pool behavior.

## Acceptance Criteria

- [x] `sfx_damage_taken_lowhp.wav` remains 44.1kHz mono 16-bit PCM at the
  existing stable resource path.
- [x] The new WAV has a new SHA-256 and is not the Story005 baseline or a copy
  of `sfx_damage_taken.wav`.
- [x] The cue is 0.38s, peaks at -4.3dBFS, stays within +1.5dB RMS of the normal
  damage cue, and decays below -30dBFS in its final 10ms.
- [x] RMS-matched analysis shows at least +6dB at 20-80Hz, at least -4dB at
  2-6kHz, and a controlled audible tail after 160ms.
- [x] A deterministic generator, exact command, source/output hashes, recipe,
  objective metrics, and qualification are retained under `assets/audio/source/`.
- [x] Godot imports the replaced WAV as a 0.38s `AudioStreamWAV` after an MCP
  filesystem scan.
- [x] Main normal damage uses `sfx_damage_taken`; real Health focus at 25/100
  changes AudioSystem to `LOW_HP`; subsequent damage uses
  `sfx_damage_taken_lowhp` on the SFX bus; healing above 28% restores normal.
- [x] Thin RED/GREEN, bounded related regression, target smoke, and one Godot
  MCP 3.0.2 runtime acceptance are recorded.

## Out of Scope

- Commercial mastering, external middleware, stereo room simulation, dynamic
  runtime reverb buses, or replacement of other Story005 baseline cues.
- MainScene, HealthComponent, or AudioSystem behavior changes; their existing
  route already satisfies the integration contract.
- Visual changes or image generation. This is an audio-only slice, so image2 is
  not applicable.
- Claiming a subjective human listening approval from automated measurements.

## Implementation Notes

- The normal damage cue is the stable dry source. The generator applies a
  2.1kHz dark body, 42-180Hz reinforcement, three damped mono reflections,
  decaying 86/129Hz resonance, soft transient saturation, and a final fade.
- The historical Story005 source manifest remains unchanged. Story010 adds a
  superseding cue-specific manifest instead of rewriting provenance.
- External asset generation requires `filesystem_manage(scan)` before runtime
  acceptance so Godot refreshes `.godot/imported` from the changed WAV.

## Test Evidence

- RED: `reports/report_1668/` -- 1 case, four expected contract failures.
- Focused GREEN: `reports/report_1669/` -- 1/1.
- Final focused verification: `reports/report_1671/` -- 1/1.
- Bounded related GREEN: `reports/report_1670/` -- 36/36 across the Story010
  asset contract, AudioSystem, and Main audio adapter.
- Target smoke:
  `tests/smoke/main_scene_focus_damage_lowhp_final_mix_smoke.gd` -- PASS.
- MCP evidence:
  `production/qa/evidence/audio-focus-damage-lowhp-final-mix-2026-07-14.md`.

## Test-Criterion Traceability

| Criterion | Test / Evidence | Status |
|-----------|-----------------|--------|
| Stable format/path and replaced baseline | Story010 focused test, source manifest, `report_1669` | PASS |
| Objective low-frequency/damped-tail mix contract | Story010 focused test and recorded FFT/envelope metrics | PASS |
| Godot import resolves new 0.38s stream | target smoke, MCP run `r3451721-2` | PASS |
| Normal/focus/restored cue routing | target smoke, MCP game-eval diagnostics | PASS |
| SFX bus playback and clean runtime logs | MCP run `r3451721-2`, non-empty screenshot, game/editor logs | PASS |
| Human subjective listening approval | Not asserted by automation | PENDING HUMAN LISTENING |
