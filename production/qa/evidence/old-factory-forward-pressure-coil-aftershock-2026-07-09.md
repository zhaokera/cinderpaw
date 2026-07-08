# Old Factory Forward Pressure Coil Aftershock Evidence

Date: 2026-07-09
Engine: Godot 4.7
MCP: Godot AI 2.9.1

## Scope

Player Abilities Story083 adds a Story082-gated Old Factory forward-pressure
Coil Aftershock in `factory_route_transition_shell.tscn`.

## Automated Tests

- RED: `reports/report_1169/` failed before Story083 diagnostics and activation
  APIs existed.
- Focused GREEN: `reports/report_1170/` passed Story083 `2/2`.
- Related GREEN: `reports/report_1171/` passed Story083 plus adjacent
  forward-pressure, service-lift, and no-loss respawn suites `24/24`.

## Headless Smoke

`reports/old_factory_forward_pressure_coil_aftershock_smoke.log` exited `0`.
Keyword scan found no project script, parse, invalid-call, invalid-access,
missing-resource, or resource-load errors. Godot still reports the known
cleanup-time ObjectDB/resource noise on terminal exit.

## MCP Runtime

Godot MCP launched `res://scenes/factory_route_transition_shell.tscn` with
`autosave=false` and helper live. Runtime probes confirmed:

- Story082-clear gating before activation.
- Ready route label `Forward Pressure Coil Pincer Cleared`.
- Active aftershock route label `Contain Coil Aftershock`.
- Coil Rat entity `2128`, family `factory_coil_rat`.
- Enemy visible, targeted, process/physics enabled while active.
- `AnimatedSprite2D + SpriteFrames` resource exposes `idle`, `run`,
  `attack_tell`, `attack`, `hurt`, and `death` with `3` frames each.
- Opening grace frames: Coil Rat `8`.
- Defeating the Coil Rat persists Story083 local-state keys and updates route
  feedback to `Forward Pressure Coil Aftershock Cleared`.
- Restored completed state preserves Story082 cleared, Story074 exit-relay
  savepoint, Story068 clear-feedback `spawn_count=0`, Story071 cache audio
  request count `0`, and `FactoryServiceLift` prompt `Call lift`.

Final logs after clearing eval-probe noise:

- Game log: only `[godot_ai game_helper] registered mcp capture`.
- Editor log: empty.

Screenshot:

- MCP `editor_screenshot(source="game")` returned a non-empty `960x539`
  framebuffer from an active aftershock state showing Cinderpaw and the visible
  Coil Rat against the Old Factory lower-deck backdrop.

## Asset Pipeline

No new visual or audio assets were generated. Story083 reuses the image-generated
Factory Coil Rat `AnimatedSprite2D + SpriteFrames` asset:

- `res://assets/characters/factory_coil_rat/factory_coil_rat_sprite_frames.tres`
- `res://src/gameplay/factory_coil_rat.tscn`

Runtime verification must confirm the reused `idle`, `run`, `attack_tell`,
`attack`, `hurt`, and `death` animations each have at least `3` frames and that
the active encounter screenshot shows the Coil Rat, not a placeholder block.
