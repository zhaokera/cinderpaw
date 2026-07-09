# Story 095: Old Factory Lower Deck Forward Pressure Aftershock Condenser Savepoint

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Death/Respawn
> **Type**: Integration + Gameplay Runtime + Visual/Feel
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-09

## Context

**GDD**: `design/gdd/player-abilities.md`,
`design/gdd/exploration-ability-gating.md`,
`design/gdd/scene-management.md`, `design/gdd/death-respawn.md`

**Requirements**: `TR-scene-004`, `TR-explore-005`, `TR-respawn-002`

**ADR Governing Implementation**: ADR-0004 Collision detection; ADR-0007 Scene
management; ADR-0018 Player abilities; ADR-0021 Save system.

Story094 ends with the aftershock condenser landing secured. Story095 turns
that challenge-clear point into a player-visible repair relay savepoint and
respawn anchor so the longer lower-deck ACT chain has a fair recovery point
before deeper Old Factory content.

## Acceptance Criteria

- [x] `FactoryLowerDeckForwardPressureAftershockCondenserSavepoint` exists in
  `factory_route_transition_shell.tscn`, starts hidden, uses a newly generated
  transparent PNG, and is positioned at the secured condenser landing.
- [x] The savepoint remains unavailable while
  `factory_lower_deck_forward_pressure_aftershock_condenser_valve_cleared=false`;
  locked activation returns `false` and keeps interaction monitoring disabled.
- [x] Once Story094 is cleared, diagnostics expose availability, visibility,
  savepoint id
  `old_factory_lower_deck_forward_pressure_aftershock_condenser_savepoint`,
  scene id `area_03_factory`, spawn point
  `lower_deck_forward_pressure_aftershock_condenser_savepoint`, prompt text
  `Repair Condenser Relay`, texture path, interaction state, position, and
  route label `Aftershock Condenser Landing Secured`.
- [x] Activating the relay through `SavepointRuntime` records the last
  discovered savepoint, persists
  `factory_lower_deck_forward_pressure_aftershock_condenser_savepoint_activated=true`,
  disables repeat interaction, and advances route feedback to
  `Aftershock Condenser Savepoint Secured`.
- [x] Restoring local state from the activated flag reconstructs a valid
  savepoint snapshot if needed and preserves the Story092 hatch, Story093
  cooling duct, and Story094 condenser landing chain without replaying them.
- [x] Respawning through SceneManager spawn point
  `lower_deck_forward_pressure_aftershock_condenser_savepoint` moves Cinderpaw
  to the relay, grants hazard respawn grace, and sets route feedback to
  `Returned to Aftershock Condenser Savepoint`.
- [x] Focused/related GdUnit, headless smoke, and Godot MCP runtime checks pass
  under Godot 4.7 / Godot AI MCP 2.9.1, including scene reload, runtime helper,
  savepoint node, generated texture, activation, persisted state, clean logs,
  and a non-empty screenshot showing the new relay.

## Out of Scope

New minimap UI, fast travel selection UI, new enemy encounters, new player
ability rewards, SaveSystem schema changes, authored audio, shaders, Boss2, and
new player or enemy animation sets.

## Implementation Notes

- Use savepoint id
  `old_factory_lower_deck_forward_pressure_aftershock_condenser_savepoint`.
- Keep Story095 state scene-local through
  `OldFactoryEntranceScene.get_local_state()` / `set_local_state()`.
- Reuse `src/feature/savepoint_runtime.gd` for interaction and snapshot
  metadata instead of adding a bespoke savepoint controller.
- The relay is only an environment savepoint prop, so the character frame
  animation rule does not create a new `AnimatedSprite2D` character for this
  story.

## Asset Pipeline

New image-generated runtime prop:

- Source:
  `assets/generated/source/old_factory_aftershock_condenser_savepoint_imagegen_20260709.png`
- Alpha source:
  `assets/generated/source/old_factory_aftershock_condenser_savepoint_alpha_20260709.png`
- Metadata:
  `assets/generated/source/old_factory_aftershock_condenser_savepoint_imagegen_20260709.json`
- Runtime:
  `assets/environment/old_factory_aftershock_condenser_savepoint/env_old_factory_aftershock_condenser_savepoint_256.png`

## Test Evidence

- Focused GdUnit:
  `tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_savepoint_test.gd`
  - Initial RED: `reports/report_1232/` (missing Story095 asset/API/
    diagnostics)
  - Focused GREEN: `reports/report_1233/` (`2/2`)
- Related regression:
  - Minimal related GREEN: `reports/report_1234/` (`19/19`) covering
    Story095, Story094, Story093, Story092, Story074, savepoint respawn
    selection, no-loss respawn state, and player respawn feedback.
- Runtime evidence:
  Headless factory smoke
  `reports/old_factory_aftershock_condenser_savepoint_smoke.log` exited `0`;
  keyword scan found no project script/parse/invalid-call/access/
  missing-resource/resource-load errors.
- Godot MCP:
  Godot AI MCP `2.9.1` on Godot `4.7-stable` confirmed scene reload from disk,
  runtime helper live, savepoint node and children present, generated texture
  path mounted on `Visual`, locked-to-ready transition after Story094 clear,
  successful activation through `SavepointRuntime`, persisted last savepoint
  snapshot, route label `Aftershock Condenser Savepoint Secured`, clean final
  editor log, and a non-empty `960x539` game screenshot showing the generated
  savepoint relay with prompt `Repair Condenser Relay`.

## Dependencies

- Depends on: Story094 Old Factory Lower Deck Forward Pressure Aftershock Condenser Valve Ambush
- Unlocks: deeper Old Factory route content after a fair aftershock condenser respawn anchor

## Verification Summary

Initial RED `reports/report_1232/` failed before Story095 assets, API, and
diagnostics existed. Focused GREEN `reports/report_1233/` passed `2/2`;
related GREEN `reports/report_1234/` passed `19/19`. Headless smoke and Godot
MCP runtime evidence passed under Godot 4.7 / Godot AI MCP 2.9.1.
