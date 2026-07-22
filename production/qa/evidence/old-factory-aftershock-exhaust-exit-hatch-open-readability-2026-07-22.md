# Story212 QA Evidence: Exhaust Exit Hatch Open Readability

## Scope

- Story: `story-212-old-factory-aftershock-exhaust-exit-hatch-open-readability.md`
- Runtime: Godot 4.7 stable / Godot AI MCP 3.0.4
- Assets: existing image-generated hatch, breaker, unlock VFX, Factory shell
  and Cinderpaw; no new generation or import.

## TDD And Regression

- `reports/report_2282/report_1/results.xml`: initial RED, one case and six
  expected visual-state failures.
- `reports/report_2284/report_1/results.xml`: art-review RED, one case and five
  expected final-pose/layer failures.
- `reports/report_2285/report_1/results.xml`: focused GREEN, `1/1`.
- `reports/report_2288/report_1/results.xml`: final five-suite bounded related
  regression, `7/7`, zero failures/errors/flaky/skipped/orphan cases. It covers
  Story210, Story092, Story211, Story093 and Story212.
- Full suite was not run.

An exploratory broader run `report_2286`, isolated again as `report_2287`,
found the already-modified Story090 test waiting `20` render frames against a
`21`-frame warning counter. That unrelated test-timing debt reproduces without
Story212 and was not changed or used as this Story's completion gate.

## Headless Smoke

Godot 4.7 ran `factory_route_transition_shell.tscn` at fixed `60 FPS` for `180`
frames and exited `0`:

`reports/old_factory_aftershock_exhaust_exit_hatch_open_readability_smoke.log`

The log scan contained no project parse/script/invalid-call/invalid-access/
missing-resource/resource-load errors. Godot stdout retained only the known
cleanup-time ObjectDB/resource messages.

## MCP Runtime

Accepted run: `r146333033-74`, session `cinderpaw@1311`.

- Scene force-reloaded from disk and launched with `current_run_errors=[]`.
- READY: hatch root `(3160,392)`, visual local `(0,0)`, root z `25 < 26`
  player, prompt visible, blocker/interaction enabled, VFX count `0`; the cut
  breaker's diagnostic text stayed `Exhaust Cut` while its label was hidden.
- Fresh MCP `interact` opened once: the same imported panel moved to local
  `(48,-136)`, rotated `6deg`, and rendered at effective z `21` behind duct z
  `22` and player z `26`. Hatch prompt hid, blocker/interaction disabled and
  unlock VFX count became exactly `1`.
- Story093 became visible/available but stayed inactive/idle on the opening
  frame. Fresh `move_right` advanced Cinderpaw from x `3236` to `3294.33` and
  entered active/uncrossed `grace` with route label
  `Cross Aftershock Cooling Duct`.
- Final inputs were false. Game log contained only the helper registration;
  editor log was empty. The project stopped and editor returned ready.

## Visual Evidence

Non-empty RGB PNG, `1278x718`, SHA-256
`b9aab2852a1d2982a016a325b84c72fd8b6a19eb1fdcea8403dad6dc603342cb`:

`reports/visual/cinderpaw-mcp-aftershock-exhaust-exit-hatch-open-readability-20260722.png`

The capture shows the panel tucked above and behind the duct shell, Cinderpaw's
full silhouette at the opening, no hatch/breaker prompt overlap, the generated
duct opening, and the active Story093 route objective.
