# QA Evidence: Old Factory Forward Pressure Exit Gate Handoff

Date: 2026-07-06
Engine: Godot 4.7
MCP: Godot AI 2.8.4
Story: `production/epics/player-abilities/story-075-old-factory-lower-deck-forward-pressure-exit-gate-handoff.md`

## Scope

Story075 adds a scene-local forward-pressure exit gate after Story074's exit
relay savepoint. The gate is a visible route handoff that opens once after the
relay is repaired, persists local open state, disables its collision blocker,
and preserves the relay savepoint, service-lift, SaveSystem, and no-replay
contracts.

## Asset Pipeline

No new visual or audio assets were generated for this story.

- Exit gate prop reuse:
  `res://assets/environment/old_factory_lower_deck_deep_bulkhead/env_old_factory_lower_deck_deep_bulkhead_closed_256.png`
  via `FactoryLowerDeckForwardPressureExitGate/Visual`.
- Gate open VFX reuse:
  `res://assets/environment/old_factory_deep_route/vfx/factory_deep_route_unlock_spark.png`
  through the existing `FactoryDeepRouteEndpoint.unlock_vfx_texture` path.
- Visual evidence:
  `reports/visual/cinderpaw-mcp-old-factory-forward-pressure-exit-gate-20260706.png`.

Both reused assets were originally created through image generation and are
recorded in `design/assets/asset-manifest.md` and
`design/assets/entity-inventory.md`.

## Automated Verification

- RED focused: `reports/report_1125/` failed as expected after adding Story075
  tests, because exit-gate diagnostics and open APIs did not exist.
- Focused GREEN: `reports/report_1127/` passed Story075 `2/2` with no errors,
  failures, skips, flaky cases, or orphans.
- Related regression: `reports/report_1128/` passed Story075, Story074,
  Story073, Story072, Story071, Story070, Story069, service-lift, factory
  route roundtrip, and no-loss respawn suites `21/21` with no errors,
  failures, skips, flaky cases, or orphans.
- Headless scene smoke:
  `reports/old_factory_forward_pressure_exit_gate_smoke.log` exited `0`.
  Keyword scan found no project script, parse, invalid-call, invalid-access,
  missing-resource, or resource-load errors.

The terminal smoke output also surfaced the known Godot cleanup-time
`ObjectDB` / `resources still in use at exit` messages; no current project
script/resource failure was reproduced.

## MCP Runtime Verification

Godot AI MCP `2.8.4` on Godot `4.7-stable` launched
`res://scenes/factory_route_transition_shell.tscn` with `autosave=false` and
confirmed helper live with no `recent_errors`.

- Runtime scene tree confirmed `FactoryLowerDeckForwardPressureExitGate` with
  `StaticBody2D/CollisionShape2D`, `Visual`, `PromptLabel`, `InteractionArea`,
  and `InteractionArea/CollisionShape2D`.
- Locked state before exit relay repair: gate present but hidden,
  non-interactable, non-blocking, `collision_disabled=true`, and
  `try_open_factory_lower_deck_forward_pressure_exit_gate(...)` returned
  `false`.
- Ready state after `factory_lower_deck_forward_pressure_exit_relay_activated`:
  gate visible and available, prompt `Open Exit Gate`, texture
  `res://assets/environment/old_factory_lower_deck_deep_bulkhead/env_old_factory_lower_deck_deep_bulkhead_closed_256.png`,
  interaction monitoring enabled, and local collision blocking enabled.
- Opening from player range returned `true`; duplicate open returned `false`;
  opened state used prompt `Exit Gate Open`, disabled local blocking, persisted
  `factory_lower_deck_forward_pressure_exit_gate_opened=true`, and set route
  feedback `Forward Pressure Exit Gate Opened`.
- Restored completed state kept the gate open, preserved savepoint contract
  `old_factory_lower_deck_forward_pressure_exit_relay / area_03_factory /
  lower_deck_forward_pressure_exit_relay`, kept Story073 inactive/defeated,
  kept Story071 cache claimed with `claim_audio_request_count=0`, kept Story068
  clear burst `spawn_count=0`, and preserved `FactoryServiceLift` prompt
  `Call lift`.
- Game log contained only the MCP helper registration line after clearing eval
  probe noise; no project game/editor script errors were present.

MCP `editor_screenshot(source="game")` timed out twice even though
`game_capture_ready=true`. This was isolated to the screenshot helper/channel:
runtime scene inspection, `game_eval` diagnostics, and logs remained live and
clean. A separate Godot 4.7 local render capture produced the final non-empty
visual evidence PNG listed above, showing the exit relay and the open exit gate.

## Result

PASS. Story075 provides the next player-visible forward-pressure route handoff,
keeps the Story074 relay savepoint stable, avoids replaying completed lower-deck
content on restore, preserves the optional service lift, and passes focused,
related, headless, MCP runtime, and visual-evidence checks.
