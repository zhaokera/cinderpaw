# Player Death / Revive Audio State Evidence

> **Story**: Audio System Story011
> **Engine**: Godot 4.7-stable
> **Godot AI MCP**: plugin/server 3.0.4
> **Date**: 2026-07-20

## Delivered Runtime Contract

- `AudioSystem` now includes `DEATH`, idempotent player death/revive adapters,
  previous-state and mix restoration, cumulative request diagnostics and two
  dedicated imported spatial SFX cues.
- Sluice Matriarch forwards one death event when Story180 enters `dying` and one
  revive event only after the existing `1.5s` boundary respawns Cinderpaw.
- The Story180 contract remains `50/100` HP, `2.0s` protection, Boss reset to
  Phase I, room seals retained and return route unavailable.

## Asset Provenance

Both files were generated locally by the deterministic Python `wave` pipeline;
image generation is not applicable to audio-only output.

| Cue | Runtime Path | Duration | Peak | SHA-256 |
|-----|--------------|----------|------|---------|
| `sfx_player_death` | `res://assets/audio/sfx/sfx_player_death.wav` | 1.50s | -3.8dBFS | `a350c1b1d3eceba28530caac53b20769da2fa2b8c75e526c49d906fd2c01a014` |
| `sfx_player_revive` | `res://assets/audio/sfx/sfx_player_revive.wav` | 0.90s | -5.0dBFS | `33a871dceadd1fb40e810077014ae6f6b248297f4331a63bc0b33ae951ae6af3` |

Format for both: mono, 44.1kHz, signed PCM16 WAV. Generator, command and RMS
metrics are retained in
`assets/audio/source/player_death_revive_sfx_generation_20260720.json`.
Godot `--import` produced both `.wav.import` files before accepted tests.

## TDD And Regression

- RED `report_2063`: `1` case, one expected missing `on_player_death` failure,
  zero errors.
- `report_2064` was an implementation parse-check failure and is not accepted.
- `report_2065` passed behavior but exposed unimported WAV loader errors and is
  not accepted.
- Initial focused GREEN `report_2066`: `1/1`, zero failures, errors, flaky cases, skips
  or orphans, with imported streams.
- `report_2067` exposed an absolute-counter test-isolation assumption after the
  related Story180 suite; the assertion was corrected to verify one-event
  deltas.
- `report_2068` then passed `27/27`. A final GDD silence audit added one
  assertion: `report_2069` intentionally failed because the Boss Phase voice
  remained active alongside death. AudioSystem now stops prior gameplay SFX;
  focused `report_2070` passed `1/1`.
- Final bounded GREEN `report_2071`: `27/27` across four directly related
  suites, with zero failures, errors, flaky cases, skips or orphans.
- Boss3 target scene ran headless for `180` frames and exited `0` without parse,
  resource-loader or runtime errors.

No full suite ran.

## MCP Runtime Acceptance

Session `cinderpaw@36ea`, final run `r10169929-4`, Godot `4.7-stable`, MCP
plugin/server `3.0.4`:

1. A frozen Story180 death boundary reported `flow_state=dying`, `HP=0/100`,
   player animation `death`, eight death wisps, grayscale presentation,
   `audio_state=DEATH`, and `death_audio_active=true`.
2. Its last semantic event was `player_death / sfx_player_death` at the player
   world position. The actual SFX request reported `stream_found=true`,
   priority `100`, exactly one active SFX voice, and a live non-null stream on
   the `SFX` bus; the preceding Boss Phase voice had been stopped.
3. Manually advancing the existing retry flow by `1.51s` reported
   `flow_state=revived`, `HP=50/100`, animation `revive`, one revive halo and
   exactly `2.0s` protection remaining.
4. Audio returned to `BOSS_FIGHT`; its last event was
   `player_revived / sfx_player_revive`, `stream_found=true`, priority `90`, at
   `boss_entry`. Death/revive cumulative counts were exactly `1/1`.
5. Current-run game logs contained only the Godot AI helper registration line;
   Editor logs returned zero rows. Stop restored editor readiness to `ready`.

## Visual Evidence

- Death hold:
  `reports/visual/cinderpaw-mcp-sluice-matriarch-death-audio-state-20260720.png`
  -- opaque RGB `1278x718`, showing `0/100`, death pose, grayscale and retry
  notification.
- Revive boundary:
  `reports/visual/cinderpaw-mcp-sluice-matriarch-revive-audio-state-20260720.png`
  -- opaque RGB `1278x718`, showing `50/100` at the Boss entry with the arena
  still sealed.

Screenshots prove the runtime boundary, not sound quality. Human listening and
final mix approval remain a separate manual sign-off.

## Result

PASS for Story011 automated acceptance. The `CUTSCENE` state and subjective
mix approval remain future Audio System work.
