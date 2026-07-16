# Rat Minion Attack Tell Frame Animation Evidence

> **Story**: Combat Presentation 032
> **Date**: 2026-07-16
> **Verdict**: PASS

## Delivered Contract

- Rat Minion bite startup now uses a dedicated image-generated three-frame
  `attack_tell` state instead of replaying the active attack.
- The existing seven-frame startup, four-frame active window, twelve-frame
  recovery, twenty-eight-frame cooldown, hitbox and eight damage are unchanged.
- Factory Spark Rat retains its independent attack-tell animation and timing.

## Automated Evidence

- RED `reports/report_1853/results.xml`: one expected failure on the absent
  `attack_tell` animation.
- Focused GREEN `reports/report_1854/results.xml`: `1/1` passed.
- Final bounded GREEN `reports/report_1855/results.xml`: `12/12` passed across
  Story032, Rat King live summon and Factory Spark Rat tell behavior; `0`
  errors/failures/flaky/skipped/orphans and exit code `0`.
- Image audit: all runtime frames are sRGBA `96x96`, have transparent corners,
  use `88px` visible width with `4px` side padding, and end at baseline `y=91`.

## MCP Evidence

Session `cinderpaw@af5f`, Godot `4.7-stable`, Godot AI MCP `3.0.2`, run
`r161142464-49`:

- fresh Main launch reported no launch errors and used the actual Rat King
  `request_summon()` path to create one live Rat Minion;
- the minion was visible at `(410,456)` beside Cinderpaw at `(300,456)`;
- startup diagnostics reported animation `attack_tell`, frame `2/3`, all six
  SpriteFrames animation names, seven startup frames and inactive bite hitbox;
- the non-empty `1278x718` capture showed Cinderpaw, the real summoned minion
  in its planted pre-lunge pose, Rat King, authored Scrap Roost environment and
  HUD without placeholder blocks or overlap;
- advancing exactly seven frames reported animation `attack`, active bite
  state, active `rat_minion_bite` hitbox and unchanged damage `8`;
- game logs contained three info rows only, editor logs were empty, and stop
  restored MCP readiness to `ready`.

## Asset Evidence

- Generated RGB strip: `1946x808`.
- Retained alpha intermediate: `1946x808` sRGBA.
- Runtime: three transparent `96x96` sRGBA PNGs.
- Prompt and processing record:
  `assets/characters/rat_minion/source/rat_minion_attack_tell_strip_imagegen_20260716.md`.
- Asset spec:
  `design/assets/specs/rat-minion-attack-tell-frame-animation.md`.

## Scope Note

MCP manually froze the real startup frame only for screenshot readability, then
advanced the production attack state machine by its authored seven frames. No
production timing, state or animation playback rate was modified for evidence.
