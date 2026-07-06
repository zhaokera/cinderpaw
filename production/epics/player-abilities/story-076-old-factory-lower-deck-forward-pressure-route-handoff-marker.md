# Story 076: Old Factory Lower Deck Forward Pressure Route Handoff Marker

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Route Handoff
> **Type**: Integration + Gameplay Runtime + Visual/Feel
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-06

## Context

**GDD**: `design/gdd/player-abilities.md`,
`design/gdd/exploration-ability-gating.md`,
`design/gdd/scene-management.md`, `design/gdd/death-respawn.md`

**Requirements**: `TR-scene-004`, `TR-explore-005`, `TR-respawn-002`

**ADR Governing Implementation**: ADR-0007 Scene management; ADR-0018
Player abilities; ADR-0021 Save system.

Story075 opens the forward-pressure exit gate without adding a new room or
changing service-lift routing. This story adds the next player-visible route
payoff inside the same Factory scene: a small door-after route handoff marker
that appears after the gate opens, lights once, and records scene-local
completion so the route no longer stops at a static open doorway.

## Acceptance Criteria

- [x] `factory_route_transition_shell.tscn` contains
  `FactoryLowerDeckForwardPressureRouteHandoffMarker` with `Visual`,
  `PromptLabel`, `InteractionArea`, and
  `InteractionArea/CollisionShape2D`.
- [x] The route handoff marker is hidden and non-interactable until
  `factory_lower_deck_forward_pressure_exit_gate_opened=true`.
- [x] Once the Story075 exit gate is open, the marker becomes visible and
  interactable with prompt `Light Route Beacon`, using the existing
  image-generated Old Factory deep-route endpoint texture.
- [x] Lighting the marker succeeds once, persists
  `factory_lower_deck_forward_pressure_route_handoff_marker_lit=true`, and
  updates route feedback to `Forward Pressure Route Beacon Lit`.
- [x] Restoring completed scene-local state keeps the marker lit and does not
  replay Story068 clear burst, Story071 reward cache audio, or Story073 exit
  guard enemy/hazard.
- [x] Story074's savepoint contract remains unchanged:
  `old_factory_lower_deck_forward_pressure_exit_relay / area_03_factory /
  lower_deck_forward_pressure_exit_relay`.
- [x] `FactoryServiceLift` remains optional with prompt `Call lift`; Story076
  does not alter service-lift destinations or SceneManager handoff targets.
- [x] No new visual or audio assets are generated; the marker reuses existing
  image-generated Old Factory endpoint art and unlock spark VFX, with reuse
  recorded in asset documentation and QA evidence.
- [x] Focused/related GdUnit, headless smoke, and Godot MCP runtime checks pass
  under Godot 4.7 / Godot AI MCP 2.9.1.

## Out of Scope

New lower-deck room scene, SceneManager route transition, minimap/full map UI,
fast travel UI, SaveSystem schema changes, service-lift route changes, new
enemy family, new combat encounter, reward cache/economy changes, new player
ability, skill-tree branch, authored beacon SFX, boss content, new
particles/shaders, new generated visual assets, and new character frame
animation.

## Implementation Notes

- Reuse `FactoryDeepRouteEndpoint` instead of creating a new marker script.
- Keep the marker state scene-local through
  `OldFactoryEntranceScene.get_local_state()` / `set_local_state()`.
- Keep Story074's relay as the active non-boss respawn anchor; the marker does
  not write a new savepoint contract.
- Treat the marker as an environment prop; no character frame animation rule is
  triggered by this story.
- Preserve Story075's route feedback after gate opening. Story076 only changes
  route feedback after the marker itself is lit.

## Asset Pipeline

No new asset generation is required. Reuse:

- Runtime marker prop:
  `assets/environment/old_factory_deep_route/factory_deep_route_endpoint.png`
- Marker source:
  `assets/generated/source/factory_deep_route_endpoint_imagegen_20260626.png`
- Marker alpha source:
  `assets/generated/source/factory_deep_route_endpoint_alpha_20260626.png`
- Unlock VFX:
  `assets/environment/old_factory_deep_route/vfx/factory_deep_route_unlock_spark.png`

Record the Story076 reuse in `design/assets/asset-manifest.md`,
`design/assets/entity-inventory.md`, and QA evidence.

## Test Evidence

- Focused GdUnit:
  `tests/unit/gameplay/old_factory_lower_deck_forward_pressure_route_handoff_marker_test.gd`
- Related regression:
  Story076 focused + Story075, Story074, Story073, Story072, Story071,
  Story070, Story069, service-lift, factory route roundtrip, and no-loss
  respawn suites.
- Runtime evidence:
  Headless smoke and Godot MCP runtime checks must confirm scene load, node
  presence, gate-open gated visibility/interactivity, once-only marker
  lighting, local-state persistence, restored completed-state no-replay,
  unchanged relay savepoint contract, service lift prompt, clean logs, and a
  non-empty screenshot with the marker visible/lit.

## Verification Summary

- RED focused: `reports/report_1129/` failed as expected because Story076
  diagnostics and activation API did not exist.
- Focused GREEN: `reports/report_1130/` passed Story076 `2/2`.
- Related GREEN: `reports/report_1131/` passed Story076, Story075, Story074,
  Story073, Story072, Story071, Story070, Story069, service-lift, factory
  route roundtrip, and no-loss respawn suites `23/23`.
- Headless smoke: `reports/old_factory_forward_pressure_route_handoff_marker_smoke.log`
  exited `0`; keyword scan found no project script/parse/invalid-call/access/
  missing-resource/resource-load errors.
- Godot MCP runtime evidence: Godot AI MCP `2.9.1` launched the scene with
  helper live, confirmed the marker node/children, locked/ready/lit/restored
  diagnostics, once-only activation, persisted local state, stable Story074
  savepoint contract, Story068/071/073 no-replay checks, service lift prompt
  `Call lift`, clean game/editor logs, and a non-empty MCP game screenshot
  response at `960x539` showing the lit marker and route label.

**Status**: [x] Complete.
