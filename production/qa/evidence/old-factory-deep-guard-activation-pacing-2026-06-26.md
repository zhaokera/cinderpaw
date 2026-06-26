# QA Evidence: Old Factory Deep Guard Activation Pacing

Date: 2026-06-26
Story: `production/epics/player-abilities/story-011-old-factory-deep-guard-activation-pacing.md`

## Scope

Story011 adjusts the pacing of the Old Factory deep-route encounter introduced
in Story010. The second Rat Minion stays visible as a readable future threat,
but it remains inactive until the entrance guard is defeated and the player
crosses the deeper route pressure point. Once activated, it behaves as a normal
Rat Minion guard and still gates the generated endpoint switch.

Out of scope remains unchanged: no new enemy family, no new player ability, no
new visual asset, no multi-room Old Factory layout, and no SaveSystem schema
rewrite.

## Asset Evidence

No new visual asset was generated for this story.

Runtime assets reused:

- `res://assets/environment/old_factory_deep_route/factory_deep_route_endpoint.png`
- `res://assets/characters/rat_minion/rat_minion_sprite_frames.tres`

Reasoning:

- The story is a gameplay pacing fix, not a new visual content slice.
- The deep guard already uses the existing Rat Minion `AnimatedSprite2D +
  SpriteFrames` contract.
- The endpoint remains the Story010 image-generated transparent PNG prop.

## Automated Test Evidence

RED:

- Command:
  `godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/old_factory_deep_guard_activation_pacing_test.gd --ignoreHeadlessMode`
- Result: `reports/report_662/` failed as expected with `4` tests,
  `11` failures, and `4` errors because the factory scene did not expose
  `try_activate_factory_deep_guard()`, `is_factory_deep_guard_activated()`, or
  the new deep guard activation diagnostics.

GREEN focused:

- Command:
  `godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/old_factory_deep_guard_activation_pacing_test.gd --ignoreHeadlessMode`
- Result: `reports/report_663/` passed `4/4`.

Related regression:

- Command:
  `godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/old_factory_deep_guard_activation_pacing_test.gd,res://tests/unit/gameplay/old_factory_deep_route_micro_slice_runtime_test.gd,res://tests/unit/gameplay/old_factory_entrance_combat_slice_runtime_test.gd,res://tests/unit/gameplay/old_factory_entrance_room_clear_runtime_test.gd,res://tests/unit/gameplay/old_factory_steam_vent_hazard_runtime_test.gd,res://tests/unit/gameplay/rat_king_live_summon_runtime_test.gd --ignoreHeadlessMode`
- Result: `reports/report_665/` passed `26/26`.
- Covered suites:
  - `old_factory_deep_guard_activation_pacing_test.gd`: `4/4`
  - `old_factory_deep_route_micro_slice_runtime_test.gd`: `4/4`
  - `old_factory_entrance_combat_slice_runtime_test.gd`: `4/4`
  - `old_factory_entrance_room_clear_runtime_test.gd`: `3/3`
  - `old_factory_steam_vent_hazard_runtime_test.gd`: `4/4`
  - `rat_king_live_summon_runtime_test.gd`: `7/7`

The related set covers the directly touched Old Factory content plus Rat Minion
runtime reuse. Full-suite testing was not run because this was a localized
gameplay pacing change and the goal calls for risk-layered verification.

## Headless Smoke Evidence

Commands:

- `godot --headless --path . --scene res://scenes/factory_route_transition_shell.tscn --fixed-fps 60 --quit-after 3 --log-file reports/old_factory_deep_guard_activation_pacing_factory_scene_smoke.log`
- `godot --headless --path . --scene res://scenes/main.tscn --fixed-fps 60 --quit-after 3 --log-file reports/old_factory_deep_guard_activation_pacing_main_scene_smoke.log`

Result:

- Both commands exited `0`.
- Keyword scans found no script parse, invalid call, missing resource, or
  resource-load errors in the smoke logs.
- Smoke logs contain DataManager domain load lines and the MCP game helper
  registration line only.

## Godot MCP Runtime Evidence

Scene:

- `res://scenes/factory_route_transition_shell.tscn`
- Run mode: custom scene through MCP with `autosave=false`.

Runtime tree evidence:

- Root scene: `FactoryRouteTransitionShellScene`
- Scene id: `area_03_factory`
- Nodes present:
  - `Player`
  - `FactoryRatMinion`
  - `FactoryDeepGuardRatMinion`
  - `FactoryCombatCache`
  - `FactorySteamVentHazard`
  - `FactoryDeepRouteEndpoint`

Runtime probe evidence:

- Initial diagnostics:
  - `deep_guard_activated=false`
  - `deep_guard_has_target=false`
  - `deep_guard_physics_enabled=false`
  - `deep_guard_process_enabled=false`
  - `endpoint_available=false`
  - `endpoint_activated=false`
- Activation gates:
  - before entrance clear: `try_activate_factory_deep_guard(...) == false`
  - after entrance clear but before threshold: `false`
  - after entrance clear and crossing `deep_guard_activation_x`: `true`
  - duplicate activation: `false`
- Activated diagnostics:
  - `deep_guard_activated=true`
  - `deep_guard_has_target=true`
  - `deep_guard_physics_enabled=true`
  - `deep_guard_process_enabled=true`
  - `endpoint_available=false`
  - `endpoint_activated=false`
- Defeat and endpoint:
  - after deep guard defeat: `deep_guard_defeated=true`
  - endpoint becomes available
  - endpoint activation succeeds once
  - duplicate endpoint activation remains rejected
- Local scene state:
  - `factory_deep_guard_activated=true`
  - `factory_deep_guard_defeated=true`
  - `factory_deep_route_cleared=true`
- Character animation:
  - `Player/Sprite`: `AnimatedSprite2D`
  - Player `idle/run/jump` frames: `3/3/3`
  - `FactoryDeepGuardRatMinion/Sprite`: `AnimatedSprite2D`
  - Deep guard `idle/run/attack/hurt/death` frames: `3/3/3/3/3`

MCP logs:

- `logs_read(source="all", include_details=true)` returned plugin traffic and
  the game helper registration line only after the successful probe.
- No game/editor script errors were reported.

Screenshot:

- `reports/visual/cinderpaw-mcp-old-factory-deep-guard-activation-pacing-20260626.png`
- The screenshot is 1280x720 and shows the Old Factory backdrop, Cinderpaw past
  the deeper pressure point, the activated deep Rat Minion visible to the right,
  the generated endpoint still locked with `Clear guard`, the route label
  `Deep guard alerted`, and prior room content still present.

## Verdict

PASS. Story011 turns the second Old Factory Rat Minion from an immediate
two-enemy brawl into a readable second encounter. The guard is visible but inert
until the player clears the entrance and pushes deeper, activation is
deterministic and persisted, the endpoint remains locked until guard defeat, and
Godot MCP runtime verification confirms clean logs and a non-empty gameplay
screenshot.
