# QA Evidence: Crown Warden Opening Approach Spacing -- 2026-07-20

## Scope

Player Abilities Story184 applies the AI Framework's chase-before-attack rule
to the Crown Warden opening. A target outside the existing `190px` approach
stop distance is closed with the generated `run` animation before the unchanged
talon-dive/wing-sweep chain can begin. Attack data, damage, timing, alternation,
phase, retry, reward and persistence contracts remain unchanged.

## TDD Evidence

- Canonical RED `reports/report_2080/results.xml` ran one case and recorded one
  expected failure because the fresh `680px` opening immediately entered attack
  startup. Errors, flaky cases, skips and orphans were zero.
- Focused GREEN `reports/report_2081/results.xml` passed `1/1` with all
  failure/error counters at zero.
- Related GREEN `reports/report_2082/results.xml` passed Story184 and the full
  Story146 Boss4 core suite at `7/7`, covering data, frames, both attacks,
  grounded hitboxes, phase two, arena lock, retry and persistent defeat.
  Failures, errors, flaky cases, skips and orphans were all zero.
- Godot 4.7 loaded `res://scenes/bosses/crown_warden_arena.tscn` headlessly for
  `180` frames and exited `0`; no parse, script, invalid-call or missing-resource
  error occurred.
- No full suite was run because the changed surface is isolated to Crown Warden
  autonomous idle/approach routing and diagnostics.

## Runtime Contract

- With Cinderpaw at the authored `(220, 536)` entry and Crown Warden anchored at
  `(900, 540)`, the fresh encounter enters `APPROACH` instead of attack startup.
- Approach faces Cinderpaw, plays `run`, moves at `120px/s`, clamps Boss x to
  `320..1160`, and exposes target distance, commit distance and velocity.
- On entering `190px`, cooldown-ready autonomous behavior starts the existing
  next pattern at startup with its tell animation and no active hitbox.
- If cooldown is still active, the Boss stops inside commit distance and waits;
  the established cooldown later starts the attack.
- Explicit pattern requests from idle remain distance-independent for scripts
  and tests. Disabling autonomy, target loss, hit, phase transition, death,
  reset and progress-defeated restore clear approach velocity.

## Godot MCP Runtime Evidence

- Session `cinderpaw@36ea`; Godot `4.7-stable (official)`; Godot AI MCP
  plugin/server `3.0.4`; accepted run `r15342595-12` (run token `12`).
- The custom disk scene launched with helper status `live` and no launch error.
  A typed deterministic runtime probe reset the live Boss to its authored
  anchor, retained the real player target and advanced one autonomous idle
  decision while physics was frozen for inspection.
- The accepted state reported Boss `(898, 540)`, player approximately
  `(220, 552)`, `678px` horizontal distance, `locomotion_state=approach`,
  `animation=run`, `velocity_x=-120`, `attack_commit_distance_px=190`,
  `attack_phase=idle` and `hitbox_active=false`.
- Game logs contain only Godot AI helper registration and normal DataManager
  enemy/boss configuration loads. Editor logs contain zero rows. Stopping
  playback restored `readiness_after=ready`.
- A discarded run used an unsupported loop form in an optional eval-only probe
  and returned `EVAL_COMPILE_ERROR`. No project file contained that code; the
  run was stopped, logs cleared and the full acceptance repeated in run `12`.
- Accepted screenshot:
  `reports/visual/cinderpaw-mcp-crown-warden-opening-approach-spacing-20260720.png`.
  It is a non-empty RGB `1278x718` PNG showing Cinderpaw at the left entry and
  the Crown Warden visibly holding its generated run/approach pose on the right.
  SHA-256:
  `8d243c6401588924dd3fac1b9ae25783afc4b9348ab8ce7a3bb87ca1439392ad`.

## Asset Use

- No new visual asset was required. Story184 reuses the existing image-generated
  Crown Warden `run` `SpriteFrames` animation: three looping frames at `8 FPS`
  from
  `res://assets/characters/crown_warden/crown_warden_sprite_frames.tres`.
- The asset audit found no static player-visible character placeholders; the
  next visual generation remains Story181's separately blocked pressure valve.

## Acceptance Mapping

| Acceptance | Evidence | Result |
|------------|----------|--------|
| Far opening target enters approach before first attack | RED/GREEN; MCP diagnostics | PASS |
| Approach faces, moves, clamps and plays three-frame run | Focused/related GREEN; MCP screenshot | PASS |
| Commit starts existing tell with inactive hitbox | Focused GREEN; accepted runtime contract | PASS |
| Cooldown approach and established attack chain remain intact | Story146 related GREEN | PASS |
| Interrupt/reset paths clear movement | Focused/related GREEN | PASS |
| Godot 4.7 / MCP 3.0.4 runtime is clean | Run `r15342595-12`; logs; screenshot | PASS |
