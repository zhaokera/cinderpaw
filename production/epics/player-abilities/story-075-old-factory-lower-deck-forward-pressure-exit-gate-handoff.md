# Story 075: Old Factory Lower Deck Forward Pressure Exit Gate Handoff

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

Story074 turns the forward-pressure exit guard win into a reliable local
respawn anchor. This story adds the next player-visible route handoff: an exit
gate that appears after the exit relay is repaired, opens once, and makes the
lower-deck forward-pressure route feel like it is moving beyond the relay
without adding a new room scene or changing service-lift routing.

## Acceptance Criteria

- [x] `factory_route_transition_shell.tscn` contains
  `FactoryLowerDeckForwardPressureExitGate` with `Visual`, `PromptLabel`,
  `StaticBody2D/CollisionShape2D`, `InteractionArea`, and
  `InteractionArea/CollisionShape2D`.
- [x] The exit gate is hidden, non-interactable, non-blocking, and not openable
  until `factory_lower_deck_forward_pressure_exit_relay_activated=true`.
- [x] Once the Story074 exit relay is activated, the gate becomes visible and
  interactable with prompt `Open Exit Gate`, using the existing image-generated
  lower-deck deep bulkhead door texture.
- [x] Opening the gate succeeds once, persists
  `factory_lower_deck_forward_pressure_exit_gate_opened=true`, disables the
  local collision blocker, and updates route feedback to
  `Forward Pressure Exit Gate Opened`.
- [x] Restoring completed scene-local state keeps the gate open and does not
  replay Story068 clear burst, Story071 reward cache audio, or Story073 exit
  guard enemy/hazard.
- [x] Story074's savepoint contract remains unchanged:
  `old_factory_lower_deck_forward_pressure_exit_relay / area_03_factory /
  lower_deck_forward_pressure_exit_relay`.
- [x] `FactoryServiceLift` remains optional with prompt `Call lift`; Story075
  does not alter service-lift destinations or SceneManager handoff targets.
- [x] No new visual or audio assets are generated; the gate reuses existing
  image-generated Old Factory deep-bulkhead door art and the existing unlock
  spark VFX, with reuse recorded in asset documentation and QA evidence.
- [x] Focused/related GdUnit, headless smoke, and Godot MCP runtime checks pass
  under Godot 4.7 / Godot AI MCP 2.8.4.

## Out of Scope

New lower-deck room scene, SceneManager route transition, minimap/full map UI,
fast travel UI, SaveSystem schema changes, service-lift route changes, new
enemy family, new combat encounter, reward cache/economy changes, new player
ability, skill-tree branch, authored gate SFX, boss content, new
particles/shaders, and new character frame animation.

## Implementation Notes

- Reuse `FactoryDeepRouteEndpoint` instead of creating a new gate script.
- Keep the gate state scene-local through
  `OldFactoryEntranceScene.get_local_state()` / `set_local_state()`.
- Keep Story074's relay as the active non-boss respawn anchor; the gate does not
  write a new savepoint contract.
- Treat the gate as an environment prop; no character frame animation rule is
  triggered by this story.
- Preserve Story074's immediate route feedback after relay activation. Story075
  only changes route feedback after the gate itself opens.

## Asset Pipeline

No new asset generation is required. Reuse:

- Runtime gate prop:
  `assets/environment/old_factory_lower_deck_deep_bulkhead/env_old_factory_lower_deck_deep_bulkhead_closed_256.png`
- Gate source:
  `assets/generated/source/old_factory_lower_deck_deep_bulkhead_imagegen_20260702.png`
- Gate alpha source:
  `assets/generated/source/old_factory_lower_deck_deep_bulkhead_alpha_20260702.png`
- Gate metadata:
  `assets/generated/source/old_factory_lower_deck_deep_bulkhead_imagegen_20260702.json`
- Unlock VFX:
  `assets/environment/old_factory_deep_route/vfx/factory_deep_route_unlock_spark.png`

Record the Story075 reuse in `design/assets/asset-manifest.md`,
`design/assets/entity-inventory.md`, and QA evidence.

## Test Evidence

- Focused GdUnit:
  `tests/unit/gameplay/old_factory_lower_deck_forward_pressure_exit_gate_test.gd`
- Related regression:
  Story075 focused + Story074, Story073, Story072, Story071, Story070,
  Story069, service-lift, factory route roundtrip, and no-loss respawn suites.
- Runtime evidence:
  Headless smoke and Godot MCP runtime checks must confirm scene load, node
  presence, relay-gated visibility/interactivity, once-only gate opening,
  local-state persistence, restored completed-state no-replay, unchanged relay
  savepoint contract, service lift prompt, clean logs, and a non-empty
  screenshot with the exit gate visible/opened.

## Verification Summary

- RED focused: `reports/report_1125/` failed as expected because Story075
  diagnostics and open API did not exist.
- Focused GREEN: `reports/report_1127/` passed Story075 `2/2`.
- Related GREEN: `reports/report_1128/` passed Story075, Story074, Story073,
  Story072, Story071, Story070, Story069, service-lift, factory route
  roundtrip, and no-loss respawn suites `21/21`.
- Headless smoke: `reports/old_factory_forward_pressure_exit_gate_smoke.log`
  exited `0`; keyword scan found no project script/parse/invalid-call/access/
  missing-resource/resource-load errors, aside from the known Godot
  cleanup-time resource message in terminal output.
- Godot MCP runtime evidence: Godot AI MCP `2.8.4` launched the scene with
  helper live, confirmed the exit gate node/children, locked/ready/opened/
  restored diagnostics, once-only open behavior, persisted local state, stable
  Story074 savepoint contract, Story068/071/073 no-replay checks, service lift
  prompt `Call lift`, clean game/editor logs, and visual evidence
  `reports/visual/cinderpaw-mcp-old-factory-forward-pressure-exit-gate-20260706.png`.
  MCP `editor_screenshot(source="game")` timed out, so the screenshot was
  captured by a temporary Godot 4.7 render script that was removed after use.

**Status**: [x] Complete.
