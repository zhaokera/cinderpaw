# QA Evidence: Old Factory Runoff Outlet Service Hatch Production Input Sluice Handoff

**Story**: Player Abilities Story224

**Date**: 2026-07-22

**Status**: Accepted

**Engine / MCP**: Godot 4.7 / Godot AI MCP 3.0.4

## Scope

Verify Story112 production hatch input/readability, Story113 real movement and
physical vent traversal, then stop with Story114 available but inactive. Story114
combat is deliberately outside this acceptance run.

## TDD Evidence

- `reports/report_2354/results.xml`: canonical RED, `1` test with `8` expected
  failures for missing hatch routing/readability and missing movement guards.
- `reports/report_2357/results.xml`: final focused GREEN, `1/1`, zero
  failure/error/flaky/skip/orphan.
- `reports/report_2360/results.xml`: final six-suite related GREEN, `10/10`,
  zero failure/error/flaky/skip/orphan.
- `reports/report_2356/results.xml` captured a test-fixture physics restore
  omission after switching to real vent overlap. `report_2358` then exposed an
  obsolete Story114 visibility assertion that predated live death animation;
  both test-contract issues were corrected before the final green run.
- Full suite was intentionally not run.

The integrated test uses production `Input.interact`, actual `move_right`, and
the connected vent `Area2D`. It does not call the hatch, traversal completion or
hazard damage APIs to manufacture the accepted transitions.

## Smoke Evidence

`reports/old_factory_runoff_outlet_service_hatch_production_input_sluice_handoff_smoke.log`
completed `180` fixed-FPS Factory frames, exited `0`, and ends with the explicit
marker `story224_smoke=passed frames=180`. No targeted parse/script,
invalid-call/access or missing-resource error was present.

## MCP Runtime Evidence

Accepted session: `cinderpaw@198e`; accepted run token/id:
`15` / `r169905919-15`.

- The editor session reported Godot `4.7-stable`, plugin/server `3.0.4`, the
  Factory scene open and readiness `ready`.
- Held `interact` armed at x `9680` remained stale after entering the hatch's
  `96px` range. Release plus fresh `interact` opened Story112 once.
- Open hatch diagnostics reported collision off, prompt hidden, one unlock VFX,
  visual offset `(48,-136)`, rotation `6deg`, and effective z `23` between duct
  `22` and Cinderpaw `26`.
- Story113 became available/visible but inactive. No-input x `10164` remained
  rejected. Controlled real `move_right` advanced x `10159.900 -> 10160.123`
  and entered `grace`.
- Warning reported contact false. Active reported contact true, layer `16`,
  mask `12`; physical vent contact applied HP `100 -> 92`, damage `8`, type
  `steam`, and exact source
  `old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice`.
- Safe disabled contact. Controlled real `move_right` advanced x
  `10719.900 -> 10720.123`, crossed Story113 and left Story114 available but
  inactive.
- After release and two stationary frames at x `10924`, entity `2142` remained
  hidden, untargeted, non-processing and non-physical at `(11120,482)`.
- Final input state reported `interact=false`, `move_right=false`. Current-run
  game log contained only helper registration; editor log after cursor `2` was
  empty; playback stopped at readiness `ready`.
- A prior retained editor record referenced a screenshot while it was being
  written. The PNG was verified as valid, forced through a successful reimport,
  and produced no new editor row; accepted-run `current_run_errors=[]`.

## Visual Evidence

- Hatch open/readable, non-empty RGB `1278x718`:
  `reports/visual/cinderpaw-mcp-runoff-outlet-service-hatch-open-20260722.png`,
  SHA-256 `4a34ea7a7e3ca2fc01ebdf712025024a86a35cf4b1bd4195fb06bd7a58a292b6`.
- Service-sluice active vent/contact, non-empty RGB `1278x718`:
  `reports/visual/cinderpaw-mcp-runoff-outlet-service-sluice-active-20260722.png`,
  SHA-256 `20b73730935d775eedcf0e9267c4c1de4a71b14f132c42040f187754940c2137`.
- Crossed/waiting Story114 handoff, non-empty RGB `1278x718`:
  `reports/visual/cinderpaw-mcp-runoff-outlet-service-sluice-crossed-handoff-20260722.png`,
  SHA-256 `6ffab17bef08b4e9a55d3ae926e8ca8d48b32245312cfa425e6aaf71f4854adf`.

The captures show authored Factory art, frame-animated Cinderpaw, the lifted
hatch, visible service-sluice landing/vent states and expected objective text.
No player-visible rectangle placeholder was introduced.

## Asset Review

No image generation was needed. Existing imported image-generated service
hatch, landing, vent, Factory environment and Cinderpaw assets cover Story224.
Story114's hidden Factory Spark Rat keeps its existing six three-frame
`AnimatedSprite2D + SpriteFrames` contract for the next production-combat slice.
