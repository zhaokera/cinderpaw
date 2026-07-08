# QA Evidence: Old Factory Forward Pressure Aftershock Exhaust Traverse

Date: 2026-07-09
Story: `production/epics/player-abilities/story-086-old-factory-lower-deck-forward-pressure-aftershock-exhaust-traverse.md`
Engine: Godot 4.7
Godot AI MCP: 2.9.1

## Scope

Story086 adds a short forward-route ACT traversal beat after Story085. The
factory route scene now exposes `FactoryLowerDeckForwardPressureAftershockExhaustVent`
as a scene-local steam hazard that is locked until
`factory_lower_deck_forward_pressure_aftershock_exit_skirmish_cleared=true`,
activates at x `2416.0`, cycles `grace -> warning -> active -> safe`, damages
the player only during the active phase, completes at x `2480.0`, and persists
`factory_lower_deck_forward_pressure_aftershock_exhaust_activated=true` plus
`factory_lower_deck_forward_pressure_aftershock_exhaust_crossed=true`.

## Asset Pipeline

No new visual or audio assets were generated for this story. Story086 reuses
the existing image-generated Old Factory steam vent hazard:

- Runtime texture:
  `res://assets/environment/old_factory_steam_vent/factory_steam_vent_hazard.png`
- Source:
  `assets/generated/source/old_factory_steam_vent_hazard_imagegen_20260626.png`
- Alpha source:
  `assets/generated/source/old_factory_steam_vent_hazard_alpha_20260626.png`

Reuse is recorded in `design/assets/asset-manifest.md`,
`design/assets/entity-inventory.md`, and the Story086 file.

## Automated Evidence

- RED focused: `reports/report_1187/`
  - Expected failure before Story086 APIs/diagnostics and scene wiring existed.
- Focused GREEN: `reports/report_1188/`
  - `old_factory_lower_deck_forward_pressure_aftershock_exhaust_traverse_test.gd`
  - Passed `3/3`.
- Related GREEN: `reports/report_1190/`
  - Covered Story086 plus Story085, Story084, Story083, Story069 steam
    traversal, Story074 relay, service-lift, audio no-replay, and no-loss
    respawn contracts.
  - Passed `25/25`.
- Headless smoke:
  `reports/old_factory_forward_pressure_aftershock_exhaust_traverse_smoke.log`
  - Exit code `0`.
  - Project error keyword scan found no script/parse/invalid-call/access,
    missing-resource, resource-load, or shadowed-variable errors.

## MCP Runtime Evidence

Godot MCP session `cinderpaw@3094` reported Godot `4.7-stable (official)`,
`plugin_version=2.9.1`, `server_version=2.9.1`, readiness `ready`, and play
state `stopped` after verification.

Final runtime probe confirmed:

- Scene `res://scenes/factory_route_transition_shell.tscn` loads.
- `FactoryLowerDeckForwardPressureAftershockExhaustVent` exists as `Area2D`.
- Script path: `res://src/feature/factory_steam_vent_hazard.gd`.
- Texture path:
  `res://assets/environment/old_factory_steam_vent/factory_steam_vent_hazard.png`.
- Hazard id:
  `old_factory_lower_deck_forward_pressure_aftershock_exhaust`.
- Damage `8`, cooldown `1.0`, position `Vector2(2418, 466)`.
- Locked state: present, unavailable, hidden, non-contacting, activation
  returns `false`.
- Ready state after Story085 clear: available and visible.
- Active traversal: route label `Cross Aftershock Exhaust`; grace/warning/safe
  phases do not open contact damage; active phase opens player contact damage.
- Damage gating: non-player contact ignored; player active-phase contact deals
  `8` HP damage through the existing steam contact path.
- Completion: crossing x `2480.0` persists activated/crossed flags, disables
  the vent, and updates route label to
  `Forward Pressure Aftershock Exhaust Crossed`.
- Restore: crossed state stays inactive/hidden; Story085 cleared, Story084
  cache claimed, Story074 relay id/spawn, Story068/071 no-replay checks, and
  `FactoryServiceLift` prompt `Call lift` are preserved.
- Final game log contained only the helper registration line; final editor log
  was empty.
- Final screenshot was non-empty (`960x539`) and showed the active exhaust
  vent in the route.

## Notes

ADR-0018 and ADR-0021 are still marked `Proposed` in the project documentation.
That is an existing governance/documentation risk; Story086 followed the same
accepted implementation pattern used by the preceding forward-pressure stories.
