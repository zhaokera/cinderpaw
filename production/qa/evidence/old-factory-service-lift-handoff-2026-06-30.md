# Old Factory Service Lift Handoff Evidence

Date: 2026-06-30

## Scope

Story035 adds a visual-only `FactoryServiceLift` call console to
`res://scenes/factory_route_transition_shell.tscn`. It is locked until the
Factory Spark Rat patrol is cleared, can be activated once, persists
`factory_service_lift_activated`, and does not request a scene transition.

## Asset Evidence

- Runtime asset:
  `res://assets/environment/old_factory_service_lift/factory_service_lift_console.png`
- Source:
  `assets/generated/source/old_factory_service_lift_console_imagegen_20260630.png`
- Alpha source:
  `assets/generated/source/old_factory_service_lift_console_alpha_20260630.png`
- Metadata:
  `assets/generated/source/old_factory_service_lift_console_imagegen_20260630.json`
- Prompt summary: image-generated pixel-art Old Factory service lift call
  console with rusted metal, amber cat-paw indicator, hazard stripes, blue cable
  accents, and green chroma-key background for local alpha removal.

## Automated Tests

- RED focused:
  `reports/report_886/`
  - Expected failure on missing service lift PNG, node, and scene API.
- GREEN focused:
  `reports/report_889/`
  - `old_factory_service_lift_handoff_test.gd`: `2/2` passed.
- Related Old Factory regression:
  `reports/report_890/`
  - Service lift handoff, route objective handoff, deep-route unlock feedback,
    and Spark Rat pacing polish: `14/14` passed.

Commands used Godot 4.6.3:

```bash
/Users/zhaok/Downloads/Godot.app/Contents/MacOS/Godot --headless --path . \
  -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd \
  -a res://tests/unit/gameplay/old_factory_service_lift_handoff_test.gd \
  --ignoreHeadlessMode -rd res://reports -c
```

```bash
/Users/zhaok/Downloads/Godot.app/Contents/MacOS/Godot --headless --path . \
  -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd \
  -a res://tests/unit/gameplay/old_factory_service_lift_handoff_test.gd \
  -a res://tests/unit/gameplay/old_factory_route_objective_handoff_test.gd \
  -a res://tests/unit/gameplay/old_factory_deep_route_unlock_feedback_test.gd \
  -a res://tests/unit/gameplay/old_factory_spark_rat_pacing_polish_test.gd \
  --ignoreHeadlessMode -rd res://reports -c
```

## Headless Scene Smoke

- Command:

```bash
/Users/zhaok/Downloads/Godot.app/Contents/MacOS/Godot --headless --path . \
  res://scenes/factory_route_transition_shell.tscn --quit \
  > reports/old_factory_service_lift_handoff_factory_scene_smoke.log 2>&1
```

- Exit code: `0`
- Keyword scan found no script errors, parse errors, invalid calls, missing
  resources, or resource-load failures.
- The only matched `ERROR:` line is Godot cleanup-time
  `2 resources still in use at exit`, consistent with prior headless scene
  smoke behavior.

## MCP Runtime Evidence

- MCP session: `cinderpaw@573d`
- MCP editor state at start: ready, custom scene launch successful.
- Note: the active MCP editor reported Godot `4.7-stable`, while automated
  tests and import/smoke used the project-pinned Godot `4.6.3`.
- `project_run(mode="custom", scene="res://scenes/factory_route_transition_shell.tscn")`
  returned helper live and no recent errors.
- Runtime scene tree contained:
  `/FactoryRouteTransitionShellScene/FactoryServiceLift`
  with children `Visual`, `PromptLabel`, and `InteractionArea`.
- Runtime node info for `FactoryServiceLift`:
  - `visible=true`
  - `endpoint_id=old_factory_service_lift`
  - `locked_prompt_text=Clear patrol`
  - `available_prompt_text=Call lift`
  - `activated_prompt_text=Lift online`
  - `script=res://src/feature/factory_deep_route_endpoint.gd`
- Runtime diagnostics from `get_factory_service_lift_diagnostics()`:
  - `present=true`
  - `available=false`
  - `activated=false`
  - `activation_ready=false`
  - `prompt_text=Clear patrol`
  - `texture_path=res://assets/environment/old_factory_service_lift/factory_service_lift_console.png`
  - `route_cleared=false`
  - `unlock_feedback_spawn_count=0`
- Runtime game log had no errors; it only included the MCP helper registration
  info line.
- MCP game screenshot captured at `960x539` and showed the right-side service
  lift console, `Clear patrol` prompt, route label, and existing Old Factory
  combat scene.
- Editor log contained two unrelated `.uid` cache-recreation warnings for old
  Boss2 tests; no service-lift scene/script errors were reported.
