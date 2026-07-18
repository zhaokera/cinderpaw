# QA Evidence: Sluice Matriarch Phase II Transition Readability -- 2026-07-18

## Scope

Story174 replaces Boss3's immediate half-health tint with one bounded,
invulnerable transformation. It preserves Story173's lunge/geyser alternation,
combat values, reward, route and persistence while routing the existing phase
signal to presentation, audio and HUD.

## Automated Evidence

- Intentional RED: `reports/report_1931/results.xml` failed the new Story174
  test `1/1` on the missing deterministic transition API, with `0` engine errors
  or orphans.
- Intermediate `reports/report_1932/results.xml` was not accepted as GREEN:
  assertions passed, but the newly generated PNGs lacked Godot import sidecars
  and emitted loader errors.
- Godot 4.7 headless import completed with exit `0`; clean focused GREEN
  `reports/report_1933/results.xml` then passed `1/1` with `0` failures, errors,
  skipped, flaky tests, or orphans.
- The first related run, `reports/report_1934/results.xml`, exposed two stale
  pre-Story174 expectations: nine total Boss3 animations and immediate Phase II
  attack availability. The tests were updated to the new approved transition
  contract.
- Final bounded regression `reports/report_1935/results.xml` passed Story174,
  Story173, Boss3 core, aerial reward and real collision/presentation suites
  `14/14` with `0` failures, errors, skipped, flaky tests, or orphans.

## Asset Generation And Import

- Exact image-generation prompt, identity reference, source, alpha processing,
  normalization and hashes are retained in
  `assets/characters/sluice_matriarch/source/sluice_matriarch_phase_transition_sheet_imagegen_20260718.md`.
- Runtime frames are continuous transparent `192x192` PNGs at
  `assets/characters/sluice_matriarch/phase_transition/` and are mounted as the
  looping `phase_transition` animation at `6 FPS` through the existing
  `AnimatedSprite2D + SpriteFrames` path.
- The asset spec and manifest record all source, alpha, preview, runtime and
  Story ownership paths.

## Godot MCP Runtime Evidence

- Session `cinderpaw@af5f`; Godot `4.7-stable`; Godot AI MCP plugin/server
  `3.0.2`; final run `r256409167-74` (run token `74`).
- Runtime scene inspection found the Boss and Player as `CharacterBody2D`, the
  Boss `Sprite` and `PressureGeyser` as `AnimatedSprite2D`, and both lunge and
  geyser CollisionComponent hitbox areas.
- A deterministic lunge reached active state before the `60`-damage threshold
  hit. Runtime remained Phase I with `phase_two_pending=true` until all `6`
  active and `18` recovery frames completed.
- Transition diagnostics then reported Phase II, state/animation
  `phase_transition`, one start, `2.5s` remaining, Hurtbox `gone`, both hitboxes
  inactive and geyser hidden. A live `12`-damage Arena request returned `false`
  and HP remained `60`.
- Mounted SpriteFrames reported exactly three transition frames, loop enabled,
  and `6 FPS`. CombatPresentation reported one overlay, `32` debris pieces and
  the authored phase texture; HUD showed `Sluice Matriarch Phase II 60/120`;
  AudioSystem reported `boss_phase_transition / sfx_boss_phase` once.
- At `2.49s`, transition remained active with about `0.01s` remaining. At
  `2.50s`, runtime returned to idle with Hurtbox `normal`, Phase II cooldown
  `28`, and the next attack remained pressure geyser with `18/10/18` timing.
- `project_run` returned `current_run_errors=[]`; the game log contained only
  the MCP helper registration line, the editor log contained `0` rows, and stop
  restored editor readiness.
- Screenshot:
  `reports/visual/cinderpaw-mcp-sluice-matriarch-phase-two-transition-20260718.png`.
  It is a non-empty `1278x718` PNG showing the generated cyan transformation
  frame, Phase II HUD, player and arena without overlap. SHA-256:
  `5a0ae169c09e0c6a287db3d0af167d74d45068085397ffbeafa7a8407e31d28d`.

## Acceptance Mapping

| Acceptance | Evidence | Result |
|------------|----------|--------|
| Threshold defers through attack recovery | Story174 test; MCP active/pending probe | PASS |
| One exact `2.5s` invulnerable window | Story174 test; MCP boundary/damage probes | PASS |
| Dedicated three-frame generated animation | Asset record; GdUnit; MCP SpriteFrames probe | PASS |
| Hitbox, Hurtbox and geyser cleanup | Story174 test; MCP collision diagnostics | PASS |
| HUD, overlay, debris and audio routing | Story174 test; MCP presentation diagnostics | PASS |
| Story173 schedule and Boss3 flow preserved | Final `14/14` related regression | PASS |
| Godot 4.7 / MCP 3.0.2 clean visible runtime | Run token `74`, logs and screenshot | PASS |
