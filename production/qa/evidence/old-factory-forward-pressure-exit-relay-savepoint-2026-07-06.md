# QA Evidence: Old Factory Forward Pressure Exit Relay Savepoint

Date: 2026-07-06
Engine: Godot 4.7
MCP: Godot AI 2.8.3
Story: `production/epics/player-abilities/story-074-old-factory-lower-deck-forward-pressure-exit-relay-savepoint.md`

## Scope

Story074 adds a repairable forward-pressure exit relay after Story073's exit
guard is defeated. The relay becomes a scene-local non-boss respawn anchor for
the lower-deck forward-pressure route without changing SaveSystem schema,
service-lift destinations, combat encounters, enemy families, or global quest
state.

## Asset Pipeline

No new visual or audio assets were generated for this story.

- Relay prop reuse:
  `res://assets/environment/old_factory_lower_deck_breach_relay/env_old_factory_lower_deck_breach_relay_256.png`
  via `FactoryLowerDeckForwardPressureExitRelaySavepoint/Visual`.
- Activation VFX reuse:
  `res://assets/environment/old_factory_deep_route/vfx/factory_deep_route_unlock_spark.png`
  through the existing `SavepointRuntime.activation_vfx_texture` path.

Both reused assets were originally created through image generation and are
recorded in `design/assets/asset-manifest.md` and
`design/assets/entity-inventory.md`.

## Automated Verification

- RED restored-checkpoint regression: `reports/report_1122/` failed as expected
  after adding the restored completed-state respawn assertion. The scene still
  routed death to `lower_deck_breach_relay` instead of
  `lower_deck_forward_pressure_exit_relay`.
- Focused GREEN: `reports/report_1123/` passed Story074 `2/2` with no errors,
  failures, skips, flaky cases, or orphans.
- Related regression: `reports/report_1124/` passed Story074, Story073,
  Story072, Story071, Story070, Story069, breach relay, return checkpoint,
  service-lift, factory route roundtrip, player respawn visual feedback, and
  no-loss respawn state suites `31/31` with no errors, failures, skips, flaky
  cases, or orphans.
- Headless scene smoke:
  `reports/old_factory_forward_pressure_exit_relay_smoke.log` exited `0`.
  Keyword scan found no project script, parse, invalid-call, invalid-access,
  missing-resource, or resource-load errors.

The terminal smoke scan surfaced the known Godot cleanup-time
`resources still in use at exit` message; no current project script/resource
failure was reproduced.

## MCP Runtime Verification

Godot AI MCP `2.8.3` on Godot `4.7-stable` launched
`res://scenes/factory_route_transition_shell.tscn` with `autosave=false` and
confirmed helper live.

- Runtime scene tree confirmed
  `FactoryLowerDeckForwardPressureExitRelaySavepoint` with `Visual`,
  `PromptLabel`, `InteractionArea`, and activation VFX child.
- After Story073-completed local state, relay diagnostics showed visible and
  interactable, prompt `Repair Exit Relay`, texture
  `res://assets/environment/old_factory_lower_deck_breach_relay/env_old_factory_lower_deck_breach_relay_256.png`,
  savepoint id `old_factory_lower_deck_forward_pressure_exit_relay`, scene id
  `area_03_factory`, and spawn point `lower_deck_forward_pressure_exit_relay`.
- First activation returned `true`; duplicate activation returned `false`;
  route feedback became `Forward Pressure Exit Relay Secured`, and scene-local
  state persisted `factory_lower_deck_forward_pressure_exit_relay_activated`.
- Non-boss lethal damage after activation selected the exit relay savepoint,
  moved Cinderpaw to relay position, restored HP to `50/100`, started respawn
  visual feedback, and set route feedback to
  `Returned to Forward Pressure Exit Relay`.
- Restoring a completed Story074 state with an older breach-relay checkpoint
  normalized `last_savepoint` to the exit relay contract instead of respawning
  at the older relay.
- Restored completed state kept Story073 inactive/defeated, Story071 cache
  claimed with `claim_audio_request_count=0`, and `FactoryServiceLift` prompt
  `Call lift`.
- Game log contained only the MCP helper registration line; editor log was
  empty.
- MCP game screenshot metadata was non-empty (`960x539`) and captured the
  visible relay route state.

## Result

PASS. Story074 turns the forward-pressure exit guard win into a visible
savepoint payoff, preserves service-lift and SaveSystem boundaries, fixes the
restored-checkpoint regression, and passes focused, related, headless, and MCP
runtime verification.
