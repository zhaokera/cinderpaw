# QA Evidence: Old Factory Forward Pressure Route Handoff Marker

Date: 2026-07-06
Engine: Godot 4.7
MCP: Godot AI 2.9.1
Story: `production/epics/player-abilities/story-076-old-factory-lower-deck-forward-pressure-route-handoff-marker.md`

## Scope

Story076 adds a scene-local forward-pressure route handoff marker after
Story075's exit gate. The marker is a visible route beacon that appears once
the gate is open, lights once from player range, persists local lit state, and
preserves the relay savepoint, service-lift, SaveSystem, and no-replay
contracts.

## Asset Pipeline

No new visual or audio assets were generated for this story.

- Route marker prop reuse:
  `res://assets/environment/old_factory_deep_route/factory_deep_route_endpoint.png`
  via `FactoryLowerDeckForwardPressureRouteHandoffMarker/Visual`.
- Marker light VFX reuse:
  `res://assets/environment/old_factory_deep_route/vfx/factory_deep_route_unlock_spark.png`
  through the existing `FactoryDeepRouteEndpoint.unlock_vfx_texture` path.
- Visual evidence: MCP `editor_screenshot(source="game")` returned a non-empty
  `960x539` game framebuffer showing the lit marker and route label.

Both reused assets were originally created through image generation and are
recorded in `design/assets/asset-manifest.md` and
`design/assets/entity-inventory.md`.

## Automated Verification

- RED focused: `reports/report_1129/` failed as expected after adding Story076
  tests, because route-handoff marker diagnostics and activation APIs did not
  exist.
- Focused GREEN: `reports/report_1130/` passed Story076 `2/2` with no errors,
  failures, skips, flaky cases, or orphans.
- Related regression: `reports/report_1131/` passed Story076, Story075,
  Story074, Story073, Story072, Story071, Story070, Story069, service-lift,
  factory route roundtrip, and no-loss respawn suites `23/23` with no errors,
  failures, skips, flaky cases, or orphans.
- Headless scene smoke:
  `reports/old_factory_forward_pressure_route_handoff_marker_smoke.log` exited
  `0`. Keyword scan found no project script, parse, invalid-call,
  invalid-access, missing-resource, or resource-load errors.

The focused CLI run surfaced the known Godot cleanup-time `ObjectDB` /
`resources still in use at exit` messages; no current project script/resource
failure was reproduced.

## MCP Runtime Verification

Godot AI MCP `2.9.1` on Godot `4.7-stable` launched
`res://scenes/factory_route_transition_shell.tscn` with `autosave=false` and
confirmed helper live with no `recent_errors`.

- Runtime scene tree confirmed
  `FactoryLowerDeckForwardPressureRouteHandoffMarker` with `Visual`,
  `PromptLabel`, `InteractionArea`, and `InteractionArea/CollisionShape2D`.
- Locked state before exit gate opening: marker present but hidden,
  non-interactable, `collision_disabled=true`, and
  `try_activate_factory_lower_deck_forward_pressure_route_handoff_marker(...)`
  returned `false`.
- Ready state after
  `factory_lower_deck_forward_pressure_exit_gate_opened=true`: marker visible
  and available, prompt `Light Route Beacon`, texture
  `res://assets/environment/old_factory_deep_route/factory_deep_route_endpoint.png`,
  and interaction monitoring enabled.
- Lighting from player range returned `true`; duplicate activation returned
  `false`; lit state used prompt `Route Beacon Lit`, persisted
  `factory_lower_deck_forward_pressure_route_handoff_marker_lit=true`, and set
  route feedback `Forward Pressure Route Beacon Lit`.
- Restored completed state kept the marker lit, preserved savepoint contract
  `old_factory_lower_deck_forward_pressure_exit_relay / area_03_factory /
  lower_deck_forward_pressure_exit_relay`, kept Story073 inactive/defeated,
  kept Story071 cache claimed with `claim_audio_request_count=0`, kept Story068
  clear burst `spawn_count=0`, and preserved `FactoryServiceLift` prompt
  `Call lift`.
- Game and editor logs contained no project script errors after clearing probe
  noise.

MCP screenshot evidence returned a non-empty `960x539` game framebuffer with
the lit marker visible in the tool response.

## Result

PASS. Story076 provides a small player-visible beyond-gate route payoff, keeps
the Story074 relay savepoint stable, avoids replaying completed lower-deck
content on restore, preserves the optional service lift, and passes focused,
related, headless, MCP runtime, and visual-evidence checks.
