# QA Evidence: Boss2 Arena Bounds Reset Runtime

> **Story**: `production/epics/player-abilities/story-026-boss2-arena-bounds-reset-runtime.md`
> **Date**: 2026-06-30
> **Engine**: Godot 4.6.3
> **Scope**: Boss2 local arena bounds, leash return, encounter reset, and
> defeated-progress preservation in `res://scenes/main.tscn`.

## Summary

Story026 makes the visible Boss2 Echo Guardian encounter behave like a bounded
ACT fight instead of an unconstrained debug actor. Boss2 now reports its arena
anchor and x bounds, clamps chase movement inside the local arena, returns to
anchor when the target leashes out, and participates in MainScene boss arena
snapshot/reset without reviving defeated progress.

No new visual assets were generated for this story. It reuses the existing
image-generated Boss2 `AnimatedSprite2D + SpriteFrames` assets, including the
Story025 three-frame `run` animation.

## Automated Evidence

| Evidence | Result | Notes |
|----------|--------|-------|
| `reports/report_800/` | RED `3/3` failed | Expected failure before arena diagnostics/clamp behavior existed. |
| `reports/report_804/` | RED `1/4` failed | Expected failure before MainScene captured Boss2 reset snapshot state. |
| `reports/report_808/` | GREEN `5/5` passed | Focused Story026 arena bounds/reset tests. |
| `reports/report_810/` | GREEN `6/6` passed | Boss2 autonomous pressure regression. |
| `reports/report_811/` | GREEN `4/4` passed | Boss2 HUD focus regression. |
| `reports/report_812/` | GREEN `3/3` passed | Boss2 Double Jump payoff/frame rules regression. |
| `reports/report_813/` | GREEN `4/4` passed | Boss2 telegraph strike regression. |
| `reports/report_814/` | GREEN `5/5` passed | GameFlow boss death/arena respawn reset regression. |
| `reports/report_815/` | GREEN `1/1` passed | Simple enemy respawn snapshot regression. |
| `reports/report_816/` | GREEN `2/2` passed | No-loss respawn state contract regression. |

## Headless Smoke

Command:

```bash
godot --headless --path . --scene res://scenes/main.tscn --fixed-fps 60 --quit-after 3 --log-file reports/boss2_arena_bounds_reset_runtime_main_scene_smoke.log
```

Result: exit `0`.

Keyword scan:

```bash
rg -n "SCRIPT ERROR|Parse Error|Invalid call|Invalid get index|Resource file not found|Failed loading resource|ERROR:" reports/boss2_arena_bounds_reset_runtime_main_scene_smoke.log
```

Result: no matches. Godot still prints the existing shutdown-time
ObjectDB/resource cleanup warning to console, but the smoke log contains no
script, parse, invalid-call, missing-resource, or resource-load errors.

## Godot MCP Runtime Evidence

MCP state:

- `editor_state`: Godot `4.6.3-stable`, project
  `废土喵影 (Cat Shadow Wasteland)`, current scene
  `res://scenes/main.tscn`.
- `project_run(mode="main", autosave=false)`: started the runtime without
  persisting editor mutations.
- `editor_manage(game_eval)`: Story026 probe returned `ok=true` with no
  failures.

Runtime probe confirmed:

- Current scene is `/root/Main`.
- `/root/Main/Boss2EchoGuardian` exists.
- Boss2 `Sprite` is `AnimatedSprite2D` with `SpriteFrames`.
- Boss2 `run` animation has `3` frames.
- Arena anchor is `(520, 482)`.
- Arena x bounds are `360..680`.
- Left-side chase clamp keeps Boss2 at or inside `arena_min_x` and plays `run`.
- Leash return enters `behavior_phase="return"` and settles back to
  `behavior_phase="idle"` at the anchor.
- `MainScene.capture_boss_arena_snapshot()` includes `boss2_echo_guardian`.
- `MainScene.reset_boss_arena_to_snapshot()` restores Boss2 to HP `36/36`,
  `attack_phase="idle"`, normal hurtbox, inactive `boss2_echo_swipe`, anchor
  position, and Boss2 HUD focus.
- Defeated progress flag keeps Boss2 defeated, hidden, non-chasing, and out of
  HUD focus after arena reset.

MCP screenshot metadata:

- `editor_screenshot(source="game", include_image=false)` returned
  `640x360` from original `1280x720`.
- Saved runtime screenshot:
  `reports/visual/cinderpaw-mcp-boss2-arena-bounds-reset-runtime-20260630.png`.
- Local pixel check: size `1280x720`, alpha extrema `255..255`, RGB extrema
  `0..255`, `138019` unique colors, mean RGBA `(64.0, 52.14, 47.76, 255.0)`.

MCP logs:

- `logs_read(source="all", include_details=true)` after the final runtime probe
  returned only MCP helper and DataManager info lines:
  `godot_ai game_helper registered mcp capture`, `boss_configs loaded`, and
  `enemy_stats loaded`.
- No script, parse, invalid-call, or editor error rows were reported.

## Acceptance Mapping

| Acceptance Criterion | Evidence | Result |
|----------------------|----------|--------|
| Arena diagnostics expose anchor/min/max/return state | `report_808`, MCP probe | PASS |
| Chase clamps inside local arena bounds | `report_808`, MCP probe | PASS |
| Leashed target returns Boss2 to anchor | `report_808`, MCP probe | PASS |
| Anchor return settles idle and non-run | `report_808`, MCP probe | PASS |
| `reset_encounter()` restores anchor and clears pressure | `report_808`, MCP probe | PASS |
| MainScene arena snapshot/reset restores Boss2 live state | `report_808`, `report_814`, MCP probe | PASS |
| Defeated/restored-defeated Boss2 stays hidden and non-threatening | `report_808`, `report_810`, `report_813`, MCP probe | PASS |
| Scene loads and screenshot is nonblank | Headless smoke, MCP screenshot, pixel check | PASS |

## Residual Risk

- Arena bounds are intentionally local and fixed-width for this story; final
  boss-room art, camera locks, room doors, and authored encounter scripting
  remain future slices.
- Boss2 still uses a small deterministic pressure loop rather than a full
  multi-phase boss AI.
- The story did not add new audio or portrait/HP-bar art.
