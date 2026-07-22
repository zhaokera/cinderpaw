# Story 011: Player Death / Revive Audio State

> **Epic**: Audio System
> **Status**: Complete
> **Layer**: Presentation / Gameplay Adapter / Audio Asset Pipeline
> **Type**: Integration + Audio/Feel
> **Estimate**: S
> **Last Updated**: 2026-07-20

## Context

**GDD**: `design/gdd/audio-system.md`, `design/gdd/death-respawn.md`

**Requirements**: `TR-audio-006`, `TR-audio-007`, `TR-audio-009`

**ADR Governing Implementation**: ADR-0010 Audio system architecture; ADR-0002
Signal communication.

Story180 established the Sluice Matriarch's shared `1.5s` death hold, `50%` HP
revive and `2.0s` protection window. This story adds the missing presentation
layer at those existing boundaries without giving AudioSystem ownership of retry
timing or boss reset behavior.

## Acceptance Criteria

- [x] AudioSystem exposes idempotent `on_player_death`, `on_player_revived` and
  `get_death_audio_state` APIs, including the `DEATH` audio state.
- [x] Death captures the previous audio state and active music/ambience ids,
  requests exactly one critical `sfx_player_death`, and does not block gameplay
  if a stream is unavailable.
- [x] Revive requests exactly one high-priority `sfx_player_revive`, restores the
  pre-death state and previously active music/ambience through the existing fade
  request API, and ignores duplicate revive callbacks.
- [x] Boss3 forwards death and revive metadata only at the existing Story180
  boundaries. The `1.5s`, `50%` HP and `2.0s` protection contracts are unchanged.
- [x] `sfx_player_death.wav` is a deterministic 1.50s heavy landing, one-second
  silence and low minor-string tail; `sfx_player_revive.wav` is a deterministic
  0.90s gentle feline mew with rising harmonics.
- [x] Both cues are mono 44.1kHz PCM16 WAV files, imported by Godot and loaded
  through the shared 16-voice spatial SFX pool.
- [x] Thin RED/GREEN, bounded related regression, Boss3 headless smoke and one
  Godot 4.7 / MCP 3.0.4 runtime acceptance are recorded.

## Out of Scope

- `CUTSCENE` state completion, a general-purpose nested audio-state stack, or
  changes to GameFlow timing and persistence.
- Commercial mastering, external middleware, stereo room simulation or claims
  of subjective human listening approval.
- Visual changes or image generation. This is an audio-only slice, so image2 is
  not applicable.

## Implementation Notes

- AudioSystem remains the sole cue/path owner. Boss3 forwards semantic metadata
  (`boss_id`, `scene_id`, death count, position and revive settings) and never
  references WAV paths.
- Duplicate death callbacks cannot overwrite the captured pre-death state;
  duplicate revive callbacks cannot replay the cue.
- The death cue itself contains the required impact/silence/string progression,
  while the existing music/ambience API records the short death-stop and revive
  return fade intents.
- Exact generation command, format, hashes and objective levels are retained in
  `assets/audio/source/player_death_revive_sfx_generation_20260720.json`.

## Test Evidence

- Canonical RED: `reports/report_2063/` -- one expected missing death API
  failure, zero parse errors.
- Initial clean focused GREEN: `reports/report_2066/` -- `1/1`, zero
  failures/errors.
- Silence-contract RED/GREEN: `reports/report_2069/` observed two active voices;
  `reports/report_2070/` passed after death clears prior gameplay SFX.
- Final bounded related GREEN: `reports/report_2071/` -- `27/27` across AudioSystem,
  Story180 retry, Boss3 phase transition and Story011, with all error counters
  zero.
- Boss3 headless smoke: target scene ran `180` frames under Godot 4.7 and exited
  `0`.
- MCP evidence:
  `production/qa/evidence/player-death-revive-audio-state-2026-07-20.md`.

## Test-Criterion Traceability

| Criterion | Test / Evidence | Status |
|-----------|-----------------|--------|
| DEATH lifecycle and exactly-once requests | Story011 focused/related GdUnit | PASS |
| Story180 timing and Boss3 reset remain unchanged | Story180 related suite in `report_2071` | PASS |
| Imported WAVs resolve and play | Godot import, AudioSystem suite, MCP runtime | PASS |
| Runtime state, one-voice silence, cue metadata and visible boundary | MCP run `r10169929-4`, screenshots and logs | PASS |
| Human subjective listening approval | Not asserted by automation | PENDING HUMAN LISTENING |
