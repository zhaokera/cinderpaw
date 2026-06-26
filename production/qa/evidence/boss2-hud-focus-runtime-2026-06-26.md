# QA Evidence: Boss2 HUD Focus Runtime

Date: 2026-06-26
Story: `production/epics/player-abilities/story-023-boss2-hud-focus-runtime.md`

## Scope

This evidence covers the Boss2 HUD focus slice. It verifies that the existing
top-center boss HUD shows `Echo Guardian` while `Boss2EchoGuardian` is the
active visible threat, updates when Boss2 HP changes, ignores Rat King HP/phase
updates during active Boss2 focus, and falls back to the existing Rat King HUD
after Boss2 is defeated.

No new visual assets were generated in this story. The slice reuses the
existing HUD and the Story021 image-generated Boss2
`AnimatedSprite2D + SpriteFrames` assets under
`assets/characters/boss2_echo_guardian/<animation>/`.

## Automated Tests

- RED focused: `reports/report_778/`
  - Expected failure: main-scene start still displayed
    `垃圾桶鼠王  Phase I  300/300` while Boss2 was present and active.
- GREEN focused: `reports/report_782/`
  - Story023 Boss2 HUD focus: `4/4`.
  - Includes direct coverage for restoring
    `boss_02_echo_guardian_defeated=true` while Boss2 HUD focus is active.
- Initial focused/related regression: `reports/report_780/`
  - Story023 Boss2 HUD focus: `3/3`.
  - Story022 Boss2 telegraph strike: `4/4`.
  - Story021 Boss2 Double Jump payoff: `3/3`.
  - Total: `10/10` passing.
- Final post-review focused/related regression: `reports/report_783/`
  - Story023 Boss2 HUD focus: `4/4`.
  - Story022 Boss2 telegraph strike: `4/4`.
  - Story021 Boss2 Double Jump payoff: `3/3`.
  - Total: `11/11` passing.

## Headless Smoke

Command:

```sh
godot --headless --path . --scene res://scenes/main.tscn --fixed-fps 60 --quit-after 3 --log-file reports/boss2_hud_focus_runtime_main_scene_smoke.log
```

Result: exit code `0`.

Keyword scan found no `SCRIPT ERROR`, `Parse Error`, `Invalid call`,
`Invalid get index`, `Resource file not found`, or `Failed loading resource`
entries in `reports/boss2_hud_focus_runtime_main_scene_smoke.log`.

## Godot MCP Runtime

MCP state:

- Editor ready on `res://scenes/main.tscn`.
- Project launched through `project_run(mode="main", autosave=false)`.
- `game_capture_ready=true`.

Fresh runtime probe results:

- Initial HUD label: `Echo Guardian  Phase I  36/36`
- Initial Boss2 HP: `36`
- `MainScene.apply_damage(2200, 14, ...)`: `true`
- HUD label after Boss2 damage: `Echo Guardian  Phase I  22/36`
- HUD label after Rat King `enemy_health_changed(250, 300)`:
  `Echo Guardian  Phase I  22/36`
- HUD label after Rat King phase transition callback:
  `Echo Guardian  Phase I  22/36`
- Boss2 defeat through `apply_damage(2200, remaining_hp, ...)`: `true`
- HUD label after Boss2 defeat: `垃圾桶鼠王  Phase I  300/300`
- Runtime screenshot save result: `OK`
- Screenshot size: `1280x720`

MCP logs after the clean probe:

- Game log: MCP helper registration and DataManager boss/enemy domain loads
  only.
- Editor log: no entries.

Runtime screenshot:

- `reports/visual/cinderpaw-mcp-boss2-hud-focus-runtime-20260626.png`

The screenshot is nonblank and shows the main scene with the top boss HUD label
focused on `Echo Guardian`.

## Acceptance Mapping

| Acceptance item | Evidence | Status |
| --- | --- | --- |
| Boss2 active HUD focus shows Echo Guardian 36/36 | `report_782`, MCP probe | PASS |
| Boss2 damage updates HUD to 22/36 | `report_782`, MCP probe | PASS |
| Rat King HP updates do not override Boss2 focus | `report_782`, MCP probe | PASS |
| Rat King phase updates do not override Boss2 focus | MCP probe | PASS |
| Boss2 defeat falls back to Rat King HUD | `report_782`, MCP probe | PASS |
| Restored defeated flag immediately falls back to Rat King HUD | `report_782` | PASS |
| Story021/Story022 behavior remains intact | `report_783` | PASS |
| MCP runtime logs and screenshot verified | Clean logs, screenshot | PASS |

## Residual Risk

`reset_boss_arena_to_snapshot()` remains Rat King-focused and does not define
full Boss2 encounter reset semantics. That is outside this HUD-focus slice and
should be handled when Boss2 arena reset/save-restore behavior is promoted into
a dedicated encounter-management story.
