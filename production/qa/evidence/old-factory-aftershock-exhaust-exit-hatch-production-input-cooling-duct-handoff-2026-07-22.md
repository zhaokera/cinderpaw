# Story211 QA Evidence: Exhaust Exit Hatch Production Input Cooling Duct Handoff

## Scope

- Story: `story-211-old-factory-aftershock-exhaust-exit-hatch-production-input-cooling-duct-handoff.md`
- Runtime: Godot 4.7 stable / Godot AI MCP 3.0.4
- Assets: existing image-generated Story092 hatch, Story093 cooling duct and
  steam vent; no new image generation or import.

## TDD

- `reports/report_2276/report_1/results.xml`: initial RED, `1` case, `11`
  expected failures because the production interaction route could not open
  Story092.
- `reports/report_2279/report_1/results.xml`: review-hardened RED, `1` precise
  failure proving a no-input teleport beyond x `3240` still activated Story093.
- `reports/report_2280/report_1/results.xml`: focused GREEN, `1/1`.
- `reports/report_2281/report_1/results.xml`: final bounded related regression,
  five suites / `8/8`, zero failures, errors, flaky, skipped or orphan cases.
- Full suite was not run; the verification budget stayed bounded to Story210,
  Story092, Story093 and shared lower-deck interaction arbitration.

## Headless Smoke

Godot 4.7 ran `factory_route_transition_shell.tscn` for `180` fixed frames and
exited `0`:

`reports/old_factory_aftershock_exhaust_exit_hatch_production_input_cooling_duct_handoff_smoke.log`

The project parse/script/invalid-call/access/missing-resource scan was empty.
Godot still prints the known cleanup-time ObjectDB/resource messages after
shutdown; no Story211 runtime error preceded them.

## MCP Runtime

Accepted run: `r145086182-73`, session `cinderpaw@1311`.

- Disk scene force-reloaded; launch returned `current_run_errors=[]`.
- Ready state: hatch x `3160`, radius `96`, visible/available/interacting and
  blocking; duct hidden/inactive.
- MCP held `interact` before real `move_right` approach from x `3080` to
  x `3123.9`; the hatch stayed closed.
- Releasing and sending a fresh `interact` rising edge opened once, disabled
  blocker and interaction monitoring/monitorable, and produced unlock VFX count
  `1`; Story093 became visible/available but remained inactive.
- With both inputs released, teleport to x `3244` remained inactive/idle with
  hazard contact off.
- Reset to x `3236` followed by real `move_right` reached x `3327.3` and started
  Story093 active/uncrossed in `grace`, route label
  `Cross Aftershock Cooling Duct`.
- Final MCP input state reported `interact=false`, `move_right=false`.
- Game log contained only the helper registration line; editor log was empty.
  The project was stopped and the editor returned ready.

## Visual Evidence

Non-empty RGB PNG, `1278x718`:

`reports/visual/cinderpaw-mcp-aftershock-exhaust-exit-hatch-production-input-cooling-duct-handoff-20260722.png`

The capture shows Cinderpaw, the opened-route hatch state, generated cooling
duct and steam vent. It also records follow-up visual debt: the opened hatch
still uses a closed-panel silhouette and nearby world prompts overlap. The next
focused visual Story should retract the panel, hide completed local prompts and
keep the player's silhouette unobstructed without generating new art.
