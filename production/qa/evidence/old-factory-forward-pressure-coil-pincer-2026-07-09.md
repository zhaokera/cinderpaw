# Old Factory Forward Pressure Coil Pincer Evidence

Date: 2026-07-09
Engine: Godot 4.7
MCP: Godot AI 2.9.1

## Scope

Player Abilities Story082 adds a Story081-gated Old Factory forward-pressure
Coil Pincer in `factory_route_transition_shell.tscn`.

## Automated Tests

- RED: `reports/report_1162/` failed before Story082 APIs existed.
- Focused GREEN: `reports/report_1166/` passed Story082 `2/2`.
- Related GREEN: `reports/report_1167/` passed Story082 plus adjacent
  forward-pressure, service-lift, and no-loss respawn suites `24/24`.

## Headless Smoke

`reports/old_factory_forward_pressure_coil_pincer_smoke.log` exited `0`.
Keyword scan found no project script, parse, invalid-call, invalid-access,
missing-resource, or resource-load errors. Godot still reports the known
cleanup-time ObjectDB/resource noise on exit.

## MCP Runtime

Godot MCP launched `res://scenes/factory_route_transition_shell.tscn` with
`autosave=false` and helper live. Runtime probes confirmed:

- Story081-clear gating before activation.
- Active pincer route label `Break Coil Pincer`.
- Spark Rat side entity `2126`, family `factory_spark_rat`.
- Coil Rat side entity `2127`, family `factory_coil_rat`.
- Both enemies visible, targeted, process/physics enabled while active.
- Both `AnimatedSprite2D + SpriteFrames` resources expose `idle`, `run`,
  `attack_tell`, `attack`, `hurt`, and `death` with `3` frames each.
- Staggered opening grace frames: Spark Rat `10`, Coil Rat `26`.
- Defeating only one enemy keeps the route incomplete.
- Defeating both enemies persists all Story082 local-state keys and updates
  route feedback to `Forward Pressure Coil Pincer Cleared`.
- Restored completed state preserves Story081 defeated, Story080 defeated,
  Story079 breaker cut, Story074 exit-relay savepoint, Story068 clear-feedback
  `spawn_count=0`, Story071 cache audio request count `0`, and
  `FactoryServiceLift` prompt `Call lift`.

Final logs after clearing eval-probe noise:

- Game log: only `[godot_ai game_helper] registered mcp capture`.
- Editor log: empty.

Screenshot:

- `reports/visual/cinderpaw-mcp-old-factory-forward-pressure-coil-pincer-20260709.png`
