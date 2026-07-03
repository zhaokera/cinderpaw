# Story 069: Old Factory Lower Deck Forward Pressure Traverse

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Traversal Hazard
> **Type**: Integration + Gameplay Runtime + Visual/Feel
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-03

## Context

**GDD**: `design/gdd/player-abilities.md`,
`design/gdd/exploration-ability-gating.md`,
`design/gdd/feline-combat.md`, `design/gdd/scene-management.md`,
`design/gdd/death-respawn.md`

**Requirements**: `TR-ability-005`, `TR-scene-004`

**ADR Governing Implementation**: ADR-0004 Collision architecture; ADR-0007
Scene management; ADR-0018 Player abilities; ADR-0021 Save system.

Stories067-068 secure the relay-forward conduit combat beat and make the clear
state readable. This story turns the next few meters into a playable traversal
pressure beat: after the forward conduit is defeated, Cinderpaw crosses a
short vent leak with deterministic grace, warning, active, and safe windows,
then persists the crossed state locally.

## Acceptance Criteria

- [x] `factory_route_transition_shell.tscn` contains a
  `FactoryLowerDeckForwardPressureVent` hazard node, hidden and non-contacting
  before `factory_lower_deck_forward_conduit_defeated=true`.
- [x] The pressure vent reuses the existing image-generated steam vent texture
  `res://assets/environment/old_factory_steam_vent/factory_steam_vent_hazard.png`
  with hazard id `old_factory_lower_deck_forward_pressure_traverse`.
- [x] After the forward conduit is defeated and before the traverse starts,
  Story068 route feedback remains `Forward Conduit Secured`; the vent is
  visible, and crossing the Story069 activation boundary starts a deterministic
  pressure cycle with route feedback `Cross Forward Pressure Leak`.
- [x] The pressure cycle exposes diagnostics for `initial_grace_sec`,
  `warning_sec`, `active_sec`, `safe_sec`, current phase, elapsed time, hazard
  id, damage, cooldown, texture path, activation x, exit x, active/crossed flags,
  and contact state.
- [x] During grace, warning, and safe phases, `apply_factory_steam_vent_contact`
  does not damage the player. During the active phase, player contact applies
  deterministic steam damage with cooldown; non-player targets remain ignored.
- [x] Crossing the exit boundary succeeds once, persists
  `factory_lower_deck_forward_pressure_traverse_crossed=true`, disables the
  pressure vent, and updates route feedback to
  `Forward Pressure Traverse Crossed`.
- [x] Restored completed state does not replay Story068 clear burst, does not
  restart entity `2118`, keeps the Story069 pressure vent inactive, and keeps
  `FactoryServiceLift` optional with prompt `Call lift`.
- [x] No new visual or audio assets are generated; the reused generated asset
  usage is recorded in asset documentation and QA evidence.
- [x] Focused/related GdUnit, headless smoke, and Godot MCP runtime checks pass
  under Godot 4.7 / Godot AI MCP 2.8.3.

## Out of Scope

New enemy families, new Spark Rat ids, reward caches, new lower-deck rooms,
new audio events, particles/shaders, minimap markers, fast travel, SaveSystem
schema expansion, global quest state, service-lift route changes, boss content,
and new generated visual assets.

## Implementation Notes

- `OldFactoryEntranceScene` owns Story069 activation, cycle timing, contact
  enablement, local persistence, and diagnostics.
- Keep Story067 and Story068 state independent: clearing entity `2118` must not
  replay when Story069 activates or completes.
- This is a scene-local traversal flag only. Do not add a SaveSystem schema key
  or global quest state.

## Asset Pipeline

No new asset generation is required. Reuse:

- `assets/environment/old_factory_steam_vent/factory_steam_vent_hazard.png`
- source record:
  `assets/generated/source/old_factory_steam_vent_hazard_imagegen_20260626.png`

Record the new usage in `design/assets/asset-manifest.md`,
`design/assets/entity-inventory.md`, and QA evidence.

## Test Evidence

- Focused GdUnit:
  `tests/unit/gameplay/old_factory_lower_deck_forward_pressure_traverse_test.gd`
- Related regression:
  Story069 focused + Story068, Story067, Story066, Story065, Story009, and
  service-lift suites.
- Runtime evidence:
  Headless smoke and Godot MCP runtime checks must confirm scene load, hazard
  node presence, timing diagnostics, active-window damage, crossed-state
  persistence, route label, service lift prompt, clean runtime logs, and
  non-empty screenshot.

## Verification Summary

- RED focused: `reports/report_1103/` failed as expected before Story069
  pressure-traverse APIs existed.
- Focused GREEN: `reports/report_1104/` passed Story069 `2/2`.
- Related GREEN: `reports/report_1105/` passed Story069 + Story068 + Story067 +
  Story066 + Story065 + Story009 + service-lift regression `16/16`.
- Story015 stale-row isolation: `reports/report_1106/` passed `5/5`.
- Headless smoke:
  `reports/old_factory_forward_pressure_traverse_smoke.log` exited `0`; keyword
  scan found no project script/parse/invalid-call/access/missing-resource/
  resource-load errors.
- Godot AI MCP `2.8.3` runtime launched
  `res://scenes/factory_route_transition_shell.tscn` with `autosave=false`,
  confirmed helper live, pressure vent presence, phase diagnostics, active-window
  damage `100 -> 92`, safe-window disablement, crossed persistence, route label
  `Forward Pressure Traverse Crossed`, Story068 clear burst `spawn_count=0`,
  inactive entity `2118`, service lift prompt `Call lift`, clean game log except
  helper registration, and non-empty screenshot metadata `960x539`. Editor log
  still surfaced pre-existing Story015 `CombatComponent` stale rows; fresh CLI
  isolation passed in `reports/report_1106/`.

**Status**: [x] Complete.
