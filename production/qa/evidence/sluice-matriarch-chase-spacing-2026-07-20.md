# QA Evidence: Sluice Matriarch Chase Spacing -- 2026-07-20

## Scope

Player Abilities Story182 gives the playable Sluice Matriarch a bounded
`CHASE` state. A valid target beyond `300px` is approached with the existing
generated `run` animation before the unchanged lunge/geyser chain starts.
Attack timing, damage, cooldown, alternation, phase, retry, reward and save
contracts remain unchanged.

## TDD Evidence

- Exploratory RED `reports/report_2072/results.xml` was superseded because its
  two failures described the same absent chase API.
- Canonical RED `reports/report_2073/results.xml` ran one case with exactly one
  expected missing-API failure and zero errors, flaky cases, skips or orphans.
- Focused GREEN `reports/report_2075/results.xml` and final pre-completion
  `reports/report_2078/results.xml` each passed `1/1`, including the Phase II
  speed assertion, with all failure/error counters at zero.
- Related GREEN `reports/report_2076/results.xml` passed five suites at `7/7`:
  chase spacing, playable Boss3 core, pressure geyser, phase transition and
  shared death/retry. Failures, errors, flaky cases, skips and orphans were all
  zero.
- Godot 4.7 loaded `res://scenes/bosses/sluice_matriarch_arena.tscn`
  headlessly for `180` frames and exited `0`; no parse, script, invalid-call or
  missing-resource error occurred.
- No full suite was run because the changed surface is isolated to Boss3 idle
  spacing and reuses the established attack chain.

## Runtime Contract

- A target at the authored `670px` opening distance enters `chase`, faces left,
  plays `run`, and moves at `210px/s` in Phase I.
- Chase remains bounded to the arena and stops at the `300px` attack commit
  distance. The next established attack starts in `startup` with
  `attack_tell`; its hitbox remains disabled until the existing active window.
- Phase II uses `270px/s`, while lunge/geyser startup, active, recovery,
  cooldown, damage and strict alternation remain unchanged.
- Target loss, hit, phase transition, death, progress-defeated restore and
  encounter reset clear velocity so no stale chase motion or damage survives.
- Explicit attack requests can still bypass chase for deterministic probes and
  existing focused tests.

## Godot MCP Runtime Evidence

- Session `cinderpaw@36ea`; Godot `4.7-stable (official)`; Godot AI MCP
  plugin/server `3.0.4`; accepted run `r12135259-8` (run token `8`).
- The custom disk scene loaded with helper status `live` and no launch errors.
  Runtime hierarchy inspection found Cinderpaw and Sluice Matriarch as
  `CharacterBody2D` nodes, each with an `AnimatedSprite2D` child; Boss attack
  areas and the pressure-geyser `AnimatedSprite2D` were also present.
- An earlier clean diagnostic observation measured `670.0px -> 668.25px` in
  one deterministic chase frame, with `behavior_state=chase`, `animation=run`,
  `velocity_x=-210`, Phase I/II speeds `210/270`, no active hitbox and
  `pressure_lunge` next. Natural runtime subsequently closed the opening gap
  and continued the existing lunge/geyser alternation.
- Accepted run game logs contain only the Godot AI helper registration line.
  Editor logs contain zero rows. Stopping playback restored
  `readiness_after=ready`.
- Two discarded diagnostic runs used invalid eval-only syntax under the
  project's warnings-as-errors policy. They were stopped and cleared; no
  project file contained that code and no evidence from those runs is accepted.
- Accepted screenshot:
  `reports/visual/cinderpaw-mcp-sluice-matriarch-chase-spacing-20260720.png`.
  It is a non-empty RGB `1278x718` PNG showing Cinderpaw, the visible Boss3
  multi-frame presentation, sealed arena, health HUD and active encounter.
  SHA-256:
  `d61c771d281d02a784e3737a51a0fa6484f1c4bad66f6b1cf9fedf9b62ae7470`.

## Asset Use

- No new visual asset was required. Story182 reuses the image-generated
  Sluice Matriarch `run` `SpriteFrames` resource with three looping frames at
  `7 FPS` from
  `res://assets/characters/sluice_matriarch/sluice_matriarch_sprite_frames.tres`.
- Story181 remains responsible for the separately blocked image-generated
  pressure-valve presentation.

## Acceptance Mapping

| Acceptance | Evidence | Result |
|------------|----------|--------|
| Far target enters chase instead of attacking in place | Focused GREEN; MCP diagnostics | PASS |
| Chase faces, moves, stays bounded and uses `run` | Focused/related GREEN; screenshot | PASS |
| Attack starts only inside `300px` with inactive startup hitbox | Focused GREEN | PASS |
| Phase II chase is faster without attack contract drift | Focused/related GREEN | PASS |
| Loss, hit, phase, death and retry clear movement | Related GREEN | PASS |
| Godot 4.7 / MCP 3.0.4 runtime is clean | Run `r12135259-8`; logs; screenshot | PASS |
