# Audio Focus Damage Low-HP Final Mix Evidence

## Scope

- Story: Audio System Story010.
- Requirements: `TR-audio-006`, `TR-audio-007`, `TR-health-008` Rule8 item 4.
- Runtime path and cue id remain
  `res://assets/audio/sfx/sfx_damage_taken_lowhp.wav` /
  `sfx_damage_taken_lowhp`.
- This is an audio-only slice. No image-generation asset was required.

## Asset Result

The Story005 low-HP procedural baseline SHA-256
`4c4ad0579a6edb60402ae91ca1c59ef257b69a2c0936cfe1e5779c6e615d1397`
was replaced by
`75b307218c47308f8720beb8c472464dffe8a5d46b998146d30896afe527548d`.
The normal damage cue remains unchanged at
`f4e53e7601a27965ea3d1cca92027746126152f2fe88940d61ac75071cf991f1`.

| Metric | Normal damage | Story010 low-HP | Contract |
|--------|---------------|-----------------|----------|
| Format | 44.1kHz mono PCM16 | 44.1kHz mono PCM16 | Stable |
| Duration | 0.22s | 0.38s | 0.32-0.42s |
| Peak | -5.81dBFS | -4.30dBFS | -8 to -3dBFS |
| RMS | -14.34dBFS | -13.03dBFS | no more than +1.5dB |
| Spectral centroid | 293.70Hz | 112.75Hz | darker |
| RMS-matched 20-80Hz | reference | +6.59dB | at least +6dB |
| RMS-matched 2-6kHz | reference | -4.06dB | at most -4dB |
| RMS-matched 6-16kHz | reference | -11.43dB | strongly attenuated |
| Tail after 160ms | -19.65dBFS | -19.39dBFS | -26 to -14dBFS |
| Final 10ms | -32.48dBFS | -71.09dBFS | at most -30dBFS |

Reproduction recipe and exact command are stored in
`assets/audio/source/focus_damage_lowhp_final_mix_20260714.json`; the
deterministic generator is
`assets/audio/source/generate_focus_damage_lowhp_final_mix.py`.

## Thin TDD

1. RED: `reports/report_1668/results.xml` -- 1 case, 4 expected failures:
   known Story005 hash, excessive baseline loudness, over-strong old tail, and
   missing Story010 provenance.
2. Focused GREEN: `reports/report_1669/results.xml` -- 1/1.
3. Final focused verification: `reports/report_1671/results.xml` -- 1/1.
4. Bounded related GREEN: `reports/report_1670/results.xml` -- 36/36 across:
   `audio_focus_damage_lowhp_final_mix_test.gd`, `audio_system_test.gd`, and
   `main_scene_audio_event_adapter_test.gd`.
5. Target smoke:
   `tests/smoke/main_scene_focus_damage_lowhp_final_mix_smoke.gd` -- PASS;
   normal cue, real Health focus, LOW_HP cue/SFX bus, imported 0.38s stream,
   and normal restore all matched.

No full suite was run because the production change is one stable-path audio
asset; AudioSystem and Main code were not modified.

## Import Diagnosis

The first MCP `reimport` response reported success while the editor filesystem
index still pointed at the old June 25 import cache. Evidence showed source WAV
MD5 `29cb9eb39ac6cddc10f9bbc2e0085bc4` but cached source MD5
`a1c726760aa5bb1d8b28b882e389ae10` and a stale 0.34s stream.

One MCP `filesystem_manage(scan)` refreshed the cache to the current source MD5
and regenerated the imported sample; the target smoke then resolved 0.38s and
passed. Root cause: an externally generated asset must enter the editor
filesystem index before runtime validation.

## MCP 3.0.2 Runtime

- Session: `cinderpaw@3736`.
- Godot: `4.7-stable (official)`.
- Plugin/server: `3.0.2` / `3.0.2`, managed `uvx` launch.
- Run: `r3451721-2`, Main scene, helper live, no launch errors.
- Focus diagnostics: HP 25/100, Health focus true, AudioSystem focus true,
  state `LOW_HP`, last event `damage_taken`, cue `sfx_damage_taken_lowhp`,
  stream found at the stable path, imported length 0.38s, `SFXPlayer02`
  playing on `SFX`.
- Restore diagnostics: HP 35/100, both focus flags false, state `NORMAL`, cue
  restored to `sfx_damage_taken`.
- Logs: 3 game info lines, 0 game errors, 0 editor errors, 0 dropped lines.
- Screenshot:
  `reports/visual/cinderpaw-mcp-focus-damage-lowhp-final-mix-20260714.png`,
  1278x718 RGB PNG, 1,206,068 bytes, non-empty.
- Stop: success, editor readiness returned to `ready`.

Structured evidence is retained in
`audio-focus-damage-lowhp-final-mix-mcp-run2.json`.

## Verdict

**PASS for Story010 implementation and Rule8 technical integration.** The
objective signal contract and real Godot route are proven. Automated evidence
does not claim subjective human listening approval or commercial mastering;
that remains a playtest/audio-review sign-off rather than an implementation
blocker.
