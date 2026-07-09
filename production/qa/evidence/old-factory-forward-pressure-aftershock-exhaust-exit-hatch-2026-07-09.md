# QA Evidence: Old Factory Forward Pressure Aftershock Exhaust Exit Hatch

Date: 2026-07-09
Engine: Godot 4.7-stable
MCP: Godot AI 2.9.1

## Scope

Player Abilities Story092 adds the
`FactoryLowerDeckForwardPressureAftershockExhaustExitHatch` route handoff after
Story091's aftershock exhaust escape skirmish. The hatch starts locked/hidden,
becomes visible after the escape skirmish is cleared, opens once, disables its
collision blocker, persists through local state, and advances the route feedback
to `Aftershock Exhaust Exit Opened`.

## Assets

No new image generation was required. Story092 reuses existing imported,
image-generated Old Factory assets:

- Hatch visual:
  `res://assets/environment/old_factory_lower_deck_deep_bulkhead/env_old_factory_lower_deck_deep_bulkhead_closed_256.png`
- Unlock VFX:
  `res://assets/environment/old_factory_deep_route/vfx/factory_deep_route_unlock_spark.png`

## Automated Evidence

- Initial focused RED: `reports/report_1218/`
  - `2` tests ran.
  - Failure captured missing Story092 diagnostics/API before implementation.
- Focused GREEN: `reports/report_1219/`
  - `2/2` tests passed.
- Initial related RED: `reports/report_1220/`
  - `17` tests ran.
  - `3` Story091 expectation failures showed the old route-label contract still
    ended at `Aftershock Exhaust Escape Secured`.
- Related GREEN: `reports/report_1221/`
  - `17/17` tests passed after Story091 expectations were updated to unlock
    Story092's hatch.
- Upload gate GREEN: `reports/report_1222/`
  - `17/17` related tests passed before committing Story092.
- Headless smoke:
  `reports/old_factory_forward_pressure_aftershock_exhaust_exit_hatch_smoke.log`
  exited `0`.
  - Keyword scan found no project script/parse/invalid-call/access/
    missing-resource/resource-load/shadowed-variable errors.

## MCP Evidence

Godot MCP session `cinderpaw@1014` reloaded
`res://scenes/factory_route_transition_shell.tscn` from disk and launched the
current scene. Runtime helper status was live.

MCP verified:

- Runtime node
  `/FactoryRouteTransitionShellScene/FactoryLowerDeckForwardPressureAftershockExhaustExitHatch`
  exists, belongs to `factory_deep_route_endpoint`, and uses
  `res://src/feature/factory_deep_route_endpoint.gd`.
- Endpoint id:
  `old_factory_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch`.
- Position: `Vector2(3160, 392)`.
- Locked diagnostics: available `false`, visible `false`, opened `false`,
  collision blocking `false`, prompt `Secure exhaust escape`.
- Story091-cleared diagnostics: available `true`, visible `true`, opened
  `false`, interaction enabled, collision blocking `true`, prompt
  `Open Exhaust Hatch`, route label `Open Aftershock Exhaust Hatch`.
- Opening with an in-range provider returned `true`, changed prompt to
  `Exhaust Hatch Open`, disabled collision blocking, set route label
  `Aftershock Exhaust Exit Opened`, and spawned one unlock VFX.
- Duplicate activation returned `false`.
- Restoring local state preserved
  `factory_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch_opened=true`.
- Final game log contained only the Godot AI helper registration line.
- Final editor log was empty after clearing a temporary eval-only warning.
- A non-empty `960x539` game screenshot showed the opened hatch at the right
  edge of the Old Factory lower-deck route.

## Verdict

PASS. Story092 meets its focused acceptance criteria and preserves the adjacent
Story086-091 route chain.
