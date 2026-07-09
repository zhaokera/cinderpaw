# Story 096: Old Factory Lower Deck Forward Pressure Aftershock Condenser Outlet Traverse

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Hazards
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

Story095 gives the lower-deck aftershock condenser chain a fair recovery point.
Story096 extends beyond that relay into a short visible outlet traverse with a
generated duct/walkway prop and a timed steam hazard window so the route keeps
moving as playable ACT space instead of ending at a marker.

## Acceptance Criteria

- [x] `FactoryLowerDeckForwardPressureAftershockCondenserOutlet` exists in
  `factory_route_transition_shell.tscn`, starts hidden, uses a newly generated
  transparent PNG, and extends the right-side route to x `5120.0`.
- [x] The outlet stays unavailable until
  `factory_lower_deck_forward_pressure_aftershock_condenser_savepoint_activated=true`;
  locked activation returns `false` and keeps contact damage disabled.
- [x] Once Story095 is active, diagnostics expose outlet availability,
  visibility, generated texture path, hazard node name, hazard id
  `old_factory_lower_deck_forward_pressure_aftershock_condenser_outlet`,
  damage `8`, cooldown `1.0`, phase timing, route width, right wall, camera
  limit, activation x, exit x, and route label
  `Aftershock Condenser Savepoint Secured`.
- [x] Crossing the activation point starts the deterministic
  `grace -> warning -> active -> safe` cycle and advances route feedback to
  `Cross Aftershock Condenser Outlet`.
- [x] Only the active phase enables the outlet vent contact shape and player
  steam damage; the reused steam vent prop remains visible as the hazard source.
- [x] Crossing the exit point persists
  `factory_lower_deck_forward_pressure_aftershock_condenser_outlet_activated=true`
  and
  `factory_lower_deck_forward_pressure_aftershock_condenser_outlet_crossed=true`,
  disables contact damage, and advances route feedback to
  `Aftershock Condenser Outlet Crossed`.
- [x] Restoring local state from crossed flags keeps the Story095 savepoint and
  the Story092/Story093/Story094 chain intact without replaying them.
- [x] Focused/related GdUnit, headless smoke, and Godot MCP runtime checks pass
  under Godot 4.7 / Godot AI MCP 2.9.1, including scene reload, runtime helper,
  outlet node, generated texture, active hazard hit, crossed persistence, clean
  current-run logs, and a non-empty screenshot showing the generated outlet.

## Out of Scope

New enemies, new player abilities, new reward cache economy, minimap or fast
travel UI, authored audio, particles/shaders, SaveSystem schema changes, Boss2,
and new player or enemy animation sets.

## Implementation Notes

- Use hazard id
  `old_factory_lower_deck_forward_pressure_aftershock_condenser_outlet`.
- Keep Story096 state scene-local through
  `OldFactoryEntranceScene.get_local_state()` / `set_local_state()`.
- Reuse `src/feature/factory_steam_vent_hazard.gd` for active-phase contact
  damage instead of adding a bespoke hazard controller.
- This story adds an environment outlet prop and reused hazard prop, not a new
  player-visible character; the character frame animation rule is therefore not
  triggered by new art in this story.

## Asset Pipeline

New image-generated runtime prop:

- Source:
  `assets/generated/source/old_factory_aftershock_condenser_outlet_imagegen_20260709.png`
- Alpha source:
  `assets/generated/source/old_factory_aftershock_condenser_outlet_alpha_20260709.png`
- Metadata:
  `assets/generated/source/old_factory_aftershock_condenser_outlet_imagegen_20260709.json`
- Runtime:
  `assets/environment/old_factory_aftershock_condenser_outlet/env_old_factory_aftershock_condenser_outlet_768.png`

The outlet vent reuses the imported image-generated steam vent hazard prop at
`assets/environment/old_factory_steam_vent/factory_steam_vent_hazard.png`.

## Test Evidence

- Focused GdUnit:
  `tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_outlet_traverse_test.gd`
  - Initial RED: `reports/report_1235/` (missing Story096 asset/API/
    diagnostics)
  - Focused GREEN: `reports/report_1237/` (`2/2`)
  - Final focused GREEN after MCP helper-name hardening:
    `reports/report_1239/` (`2/2`)
- Related regression:
  - Minimal related GREEN: `reports/report_1238/` (`16/16`) covering
    Story096, Story095, Story094, Story093, Story092, savepoint respawn
    selection, and no-loss respawn state.
- Runtime evidence:
  Headless factory smoke
  `reports/old_factory_aftershock_condenser_outlet_traverse_smoke.log` exited
  `0`; keyword scan found no project script/parse/invalid-call/access/
  missing-resource/resource-load errors.
- Godot MCP:
  Godot AI MCP `2.9.1` on Godot `4.7-stable` confirmed scene reload from disk,
  runtime helper live, outlet and vent nodes present, generated outlet texture
  path mounted on `Sprite2D`, vent hazard id/damage/cooldown, activation,
  active-phase contact damage from `100` to `92`, crossed persistence, route
  label `Aftershock Condenser Outlet Crossed`, current-run game log containing
  the Story096 probe result, no new editor log entries after cursor `9`, and a
  non-empty `960x539` game screenshot showing the generated outlet duct,
  reused steam vent, and player.

## Dependencies

- Depends on: Story095 Old Factory Lower Deck Forward Pressure Aftershock Condenser Savepoint
- Unlocks: deeper Old Factory route content after the condenser outlet traverse

## Verification Summary

Initial RED `reports/report_1235/` failed before Story096 assets, API, and
diagnostics existed. Focused GREEN `reports/report_1237/` passed `2/2`;
related GREEN `reports/report_1238/` passed `16/16`; final focused GREEN
`reports/report_1239/` passed `2/2` after shortening private helper names for
Godot editor reload stability. Headless smoke and Godot MCP runtime evidence
passed under Godot 4.7 / Godot AI MCP 2.9.1.
