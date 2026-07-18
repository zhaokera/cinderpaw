# QA Evidence: Rat King Phase-I Authored Intro

> **Story**: Combat Presentation 035
> **Date**: 2026-07-18
> **Engine**: Godot 4.7-stable
> **Godot AI MCP**: plugin/server 3.0.2

## Acceptance Summary

| Criterion | Evidence | Result |
| --- | --- | --- |
| Authored entrance sequence | Generated anticipation, ignition and threat frames | PASS |
| No idle duplication | Three runtime hashes are unique and differ from matching idle frames | PASS |
| Stable frame pipeline | Transparent `192x192`, continuous names, shared `y=191` baseline | PASS |
| Existing gameplay preserved | SpriteFrames path/state retained; no controller, timing, hitbox or data edit | PASS |
| Visible Godot runtime | Real Main Rat King AnimatedSprite2D advanced through imported intro frames | PASS |
| Clean runtime | Info-only game log, zero editor errors, clean MCP stop | PASS |

## Automated Evidence

- Intentional RED: `reports/report_1911/results.xml`
  - Story035 failed with five expected assertions: missing generated
    source/prompt and three runtime hashes equal to idle.
- Focused GREEN: `reports/report_1912/results.xml`
  - Story035 passed `1/1`.
  - Zero errors, failures, flaky, skipped and orphan cases; exit `0`.
- Bounded related GREEN: `reports/report_1914/results.xml`
  - Story035, Rat King character animation and Main runtime contracts passed
    `8/8` across three suites.
  - Zero errors, failures, flaky, skipped, orphan, ObjectDB leak or retained
    resource cases; exit `0` with clean teardown.
- A one-run verbose diagnosis traced the prior teardown warning to two global
  AudioSystem players started by the existing phase-transition test
  (`sfx_boss_phase` and `mus_boss_rat_p2`). Its fixture now stops those players
  after each test without changing runtime audio behavior.

## Asset Evidence

- Generated RGB source: `2172x724`, SHA-256
  `9be3ac2005143c8dbfc4ffaeadb9b741518bd23f8a03149e5f015fa61db4b661`.
- Retained sRGBA alpha intermediate: `2172x724`, SHA-256
  `1a64a8c349d821782dc7259c313ec6bc396a2be84f83f33b79cb377d820aceb6`.
- Runtime frame SHA-256 values:
  - `000`: `698644c6028ad41aea4ecb3ea6ea4cb28980973fd6c6f24d01a151db796a4e81`
  - `001`: `12854a90ba4bd43be9c3db5e7f556c6c57ef633b7869e2d0bee7f5bc518994df`
  - `002`: `a0debad81a6fac3e4795f20d448339caee6510f9cde237d07e044e1564a1a116`
- Visible bounds are `164x115+7+77`, `170x142+3+50` and
  `185x143+1+48`; all end on baseline `y=191` and retain transparent edge
  padding.
- Exact prompt, key color, matte/despill thresholds, cell geometry, placement
  and hashes are retained in
  `assets/characters/rat_king/source/rat_king_phase_1_intro_sheet_imagegen_20260718.md`.

## MCP Runtime Evidence

- Session: `cinderpaw@af5f`
- Run: `r233397649-69`
- Custom scene: `res://scenes/main.tscn`
- Runtime tree found `/root/Main/Enemy/Sprite` as `AnimatedSprite2D`.
- The acceptance probe disabled only the Boss physics loop so its production
  idle update could not overwrite the inspected visual state, then played the
  real imported `phase_1_intro` from frame 0 for `0.36s`.
- Playback inspection reported frame `1`, progress `0.466667`, frame count `3`,
  loop `false`, visibility `true`, and texture
  `res://assets/characters/rat_king/phase_1_intro/rat_king_phase_1_intro_001.png`.
- Runtime HashingContext returned the same three SHA-256 values listed above.
- The game log contained the helper registration plus two normal DataManager
  domain-load rows. The editor log contained zero rows after the clean
  baseline. Stop returned `stopped=true` and readiness `ready`.

## Screenshot

- Path:
  `reports/visual/cinderpaw-mcp-rat-king-phase-one-authored-intro-20260718.png`
- Dimensions: `1278x718`
- Mean channel value: `0.223675`
- SHA-256:
  `df1f2bf8dbd2fd2c126bf7807025b00d746964d4bdc80109ad771adccfc65e86`
- Visual review: the real Main frame visibly contains Cinderpaw, the Scrap
  Roost arena, HUD and Rat King in the red-core ignition pose. The Boss is a
  textured character silhouette rather than an empty viewport, color block or
  duplicated idle frame.

## Scope Audit

- Only the three existing `phase_1_intro` runtime PNGs were replaced.
- `rat_king_sprite_frames.tres`, Boss controller, AI, phase timing, damage,
  collision, camera, rewards, save state, audio and environment are unchanged.
- The MCP playback freeze was acceptance-only and did not modify project files.
- Production activation/onboarding for the intro remains a separate Story.
- The broader complete-game objective remains active.
