# QA Evidence: Crown Warden Dedicated Phase Transition Frame Animation -- 2026-07-19

## Scope

Story176 replaces Crown Warden's non-looping `hurt` hold during Phase II with a
dedicated generated three-frame loop. It changes only assets, SpriteFrames, the
Phase II animation mapping and directly related tests; Story163 combat timing,
collision, signal and presentation behavior remain frozen.

## Automated Evidence

- Intentional RED `reports/report_1942/results.xml`: the new focused suite
  failed `1/1` only on the absent `phase_transition` animation, with `0` engine
  errors and `0` orphans.
- Focused GREEN `reports/report_1943/results.xml`: `1/1` passed with `0`
  failures, errors, skipped, flaky tests or orphans.
- Bounded related GREEN `reports/report_1944/results.xml`: Story176, Story163,
  Boss4 core and Crown Warden death-hold suites passed `9/9`, with `0`
  failures, errors, skipped, flaky tests or orphans.
- Godot 4.7 headless import exited `0` and imported source, alpha and three
  runtime PNGs.
- Existing target smoke
  `tests/smoke/crown_warden_phase_two_transition_feedback_smoke.gd` exited `0`
  and printed `crown_warden_phase_two_transition_feedback_smoke=passed`.
- No full suite or unrelated Boss/ability regression was run.

## Asset Generation And Import

- OpenAI image generation used the existing Crown Warden preview as identity
  reference and produced a retained RGB `2172x724` three-cell source.
- The sampled-key soft-matte/despill pipeline retained a full-size RGBA alpha
  intermediate. Three distinct transparent `192x192` runtime frames were
  normalized with continuous names and imported by Godot 4.7.
- Exact prompt, source/runtime hashes, alpha statistics and offsets are in
  `assets/characters/crown_warden/source/crown_warden_phase_transition_sheet_imagegen_20260719.md`.
- The shared SpriteFrames resource now exposes nine animations / 27 frames;
  `phase_transition` is exactly three frames, looping at `6 FPS`. Existing
  `hurt` and `death` remain three-frame non-looping animations.

## Godot MCP Runtime Evidence

- Session `cinderpaw@af5f`; Godot `4.7-stable (official)`; Godot AI MCP
  plugin/server `3.0.2`; final clean arena run `r276785351-79` (token `79`).
- Entry diagnostics proved Phase II at `80/160`, transition duration `2.5s`,
  start count `1`, animation/config/metadata `phase_transition`, velocity zero,
  Hurtbox `gone`, both attack hitboxes closed, overlay `1`, debris `32`, Phase
  II HUD and `boss_phase_transition / sfx_boss_phase`.
- Natural playback sampling over `0.64s` returned frames `[0,1,0]`, two distinct
  frame indices, `playing=true`, and `1.9167s` remaining. This directly proves
  motion beyond the old `0.375s` hurt animation duration.
- A 12-damage arena probe was rejected and HP remained `80`; an explicit
  `talon_dive` was rejected during transition. At `2.49s` state remained active,
  Hurtbox stayed `gone` and both hitboxes stayed closed. At `2.50s` the Boss
  returned to `idle`, Hurtbox became `normal`, cooldown was `30`, hitboxes
  remained closed and an explicit `talon_dive` was accepted.
- The inline MCP game screenshot was non-empty at `1278x718`. Manual inspection
  confirmed the full generated Crown Warden, readable Phase II HUD, player and
  arena with no crop, placeholder block or UI overlap.
- Final game log contained only the MCP helper plus `enemy_stats` and
  `boss_configs` DataManager info lines. Editor log contained `0` rows. Stop
  restored editor readiness to `ready`.

One earlier run (`78`) stopped at a debugger break because the temporary MCP
probe passed a Boss object to the arena's integer `target_id` argument. No
project file caused the error. The probe was corrected to entity `2400`, logs
were cleared, and all acceptance evidence above comes from clean run `79`.

## Acceptance Mapping

| Acceptance | Evidence | Result |
|------------|----------|--------|
| Dedicated three-frame `6 FPS` loop and exact texture paths | Focused GREEN; SpriteFrames; MCP | PASS |
| Transparent aligned distinct `192x192` runtime frames | Focused GREEN; asset record | PASS |
| Story163 threshold, timing, invulnerability and recovery preserved | Related GREEN; smoke; MCP | PASS |
| Existing signal, VFX, HUD and audio routing preserved | Story163 regression; MCP | PASS |
| Natural playback, clean logs and non-empty visible runtime | MCP run `79` | PASS |
