# QA Evidence: Rat King Phase-I Runtime Intro

> **Story**: Combat Presentation 036
> **Date**: 2026-07-18
> **Engine**: Godot 4.7-stable
> **Godot AI MCP**: plugin/server 3.0.2

## Acceptance Summary

| Criterion | Evidence | Result |
| --- | --- | --- |
| Natural Main activation | First Main physics tick requests the Boss-owned intro state | PASS |
| Authored frame playback | Three-frame non-looping intro advanced from frame 0 to frame 1 | PASS |
| Boss safety gate | Damage rejected, HP unchanged, AI request rejected, zero active Hitboxes | PASS |
| Player agency | Game flow and player control remained unlocked | PASS |
| Combat handoff | One completion returned to idle, then claw swipe entered startup | PASS |
| Attempt lifecycle | Same-attempt replay rejected, retry re-armed, defeated state skipped | PASS |
| Clean runtime | Info-only game log, zero editor errors, clean MCP stop | PASS |

## Automated Evidence

- Intentional RED: `reports/report_1915/results.xml`
  - Story036 failed its first capability assertion because Main had no natural
    Rat King intro API or runtime state.
- Focused GREEN: `reports/report_1917/results.xml`
  - Story036 passed `1/1`.
  - Zero errors, failures, flaky, skipped and orphan cases; exit `0`.
- Final bounded related GREEN: `reports/report_1921/results.xml`
  - Story036, Story035 assets, Rat King runtime, Main enemy attack chain and
    sequential Boss handoff passed `11/11` across five suites.
  - Zero errors, failures, flaky, skipped, orphan, ObjectDB leak or retained
    resource cases; exit `0` with clean teardown.
- `report_1916` exposed a test-order observation: a coroutine awaiting
  `physics_frame` resumes before node physics callbacks. A two-frame timing
  probe proved Main starts the intro during that first callback; the final test
  waits through one completed tick rather than changing production order.
- The existing sequential Boss handoff fixture started global runtime audio but
  did not stop it. Its teardown now stops AudioSystem players; isolated
  `report_1920` passed `2/2` with a clean process exit.

## Runtime Contract

- `RatKingBoss.State.INTRO` owns playback and prevents the regular idle update
  from overwriting `phase_1_intro`.
- Duration is the sum of SpriteFrames relative frame durations divided by its
  configured `4 fps`; no duplicate `0.75s` gameplay tuning constant exists.
- Intro rejects damage before HealthComponent, suppresses attack requests via
  the non-idle state and deactivates attack Hitboxes. BossConfig time does not
  advance until handoff.
- Main requests the state at physics priority `-100`, before Player and Boss
  default-priority physics callbacks. Main does not set Player control lock or
  pause SceneTree.
- `reset_boss_arena_to_snapshot()` re-arms the request for a new attempt.
  Defeated, victory and non-Phase-I states reject it without persisting a new
  save field or emitting a phase-change signal.

## MCP Runtime Evidence

- Session: `cinderpaw@af5f`
- Run: `r237489661-70`
- Custom scene: `res://scenes/main.tscn`
- MCP reloaded the current Main scene and waited through the production physics
  path. It did not call `Sprite.play()`, disable Boss physics or mutate project
  resources.
- First observation:
  - `animation=phase_1_intro`, `frame=0`, `playing=true`
  - `frame_count=3`, `loop=false`, `speed_fps=4`, `duration_sec=0.75`
  - `started_count=1`, `remaining_sec=0.733333`
  - `active_hitbox_count=0`, `player_control_locked=false`
- Midpoint after `0.30s`: frame `1`, intro still active, remaining
  `0.433333s`.
- Intro damage probe kept Rat King at `300/300`; `claw_swipe` request returned
  `false` while active.
- After another `0.55s`, diagnostics reported `active=false`,
  `completed_count=1`, `remaining_sec=0`, `animation=idle`. The next
  `claw_swipe` request returned `true` with `attack_phase=startup`.
- Game log: helper registration plus normal `boss_configs` and `enemy_stats`
  DataManager loads only. Editor log: zero rows. Stop returned `stopped=true`
  and editor readiness `ready`.

## Screenshot

- Path:
  `reports/visual/cinderpaw-mcp-rat-king-phase-one-runtime-intro-20260718.png`
- Dimensions: `1278x718`
- Size: `1,209,516` bytes
- SHA-256:
  `7cfa025daf1da1381609d873026796b3bbad3e878f1cfb8b67fedb406c83188b`
- Visual review: the real Main viewport contains Cinderpaw, Scrap Roost, HUD
  and the large textured Rat King in the red-core ignition frame. It is not an
  empty viewport, placeholder block or idle frame.

## Scope Audit

- No new visual or audio asset was required; Story036 reuses Story035's
  image-generated transparent intro frames.
- No attack timing, damage, HP, arena mutation, camera, HUD, reward, save schema
  or phase-transition data changed.
- Runtime edits are limited to Rat King intro state ownership, Main attempt
  activation and directly related test teardown.
- The broader complete-game objective remains active.
