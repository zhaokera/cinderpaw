# Old Factory Forward Pressure Traverse Evidence

## Scope

Story069 adds a short scene-local traversal pressure beat after the lower-deck
forward conduit combat is secured.

- New scene node:
  `FactoryLowerDeckForwardPressureVent` in
  `res://scenes/factory_route_transition_shell.tscn`.
- Runtime owner:
  `src/gameplay/old_factory_entrance_scene.gd`.
- Focused test:
  `tests/unit/gameplay/old_factory_lower_deck_forward_pressure_traverse_test.gd`.

## Asset Pipeline

No new visual or audio asset was generated.

Story069 reuses the existing image-generated steam vent hazard:

- Runtime texture:
  `res://assets/environment/old_factory_steam_vent/factory_steam_vent_hazard.png`
- Source:
  `assets/generated/source/old_factory_steam_vent_hazard_imagegen_20260626.png`
- Alpha source:
  `assets/generated/source/old_factory_steam_vent_hazard_alpha_20260626.png`

The new usage is recorded in:

- `design/assets/asset-manifest.md`
- `design/assets/entity-inventory.md`

## Automated Verification

- RED focused:
  `reports/report_1103/` failed as expected before Story069 APIs existed.
  Failures were method-contract assertions for
  `get_factory_lower_deck_forward_pressure_traverse_diagnostics`,
  `try_activate_factory_lower_deck_forward_pressure_traverse`,
  `advance_factory_lower_deck_forward_pressure_traverse_time`, and
  `try_complete_factory_lower_deck_forward_pressure_traverse`.
- Focused GREEN:
  `reports/report_1104/` passed Story069 `2/2` under Godot
  `4.7.stable.official.5b4e0cb0f`.
- Related GREEN:
  `reports/report_1105/` passed Story069 + Story068 + Story067 + Story066 +
  Story065 + Story009 steam vent hazard + service-lift SceneManager exit
  suites `16/16`.
- Story015 stale-row isolation:
  `reports/report_1106/` passed `5/5`, confirming the Editor Debugger
  `CombatComponent` rows remain stale cache noise rather than a current CLI
  parse failure.
- Headless Factory smoke:
  `reports/old_factory_forward_pressure_traverse_smoke.log` exited `0`.
  Keyword scan found no project script/parse/invalid-call/invalid-access/
  missing-resource/resource-load errors; only the known Godot cleanup-time
  ObjectDB/resource message appeared on process exit.

## Runtime Contract

The focused suite verifies:

- Before `factory_lower_deck_forward_conduit_defeated=true`, the pressure vent
  is present but hidden, unavailable, inactive, and non-contacting.
- After the conduit is defeated, Story068 route feedback remains
  `Forward Conduit Secured`; the pressure vent becomes visible and available
  but still non-contacting.
- Crossing the Story069 activation boundary starts the pressure cycle and
  updates route feedback to `Cross Forward Pressure Leak`.
- The cycle exposes deterministic grace, warning, active, and safe windows.
- Player contact during active phase applies `8` steam damage with hazard source
  `old_factory_lower_deck_forward_pressure_traverse`; grace, warning, and safe
  phases do not enable contact.
- Crossing the exit boundary persists
  `factory_lower_deck_forward_pressure_traverse_crossed=true`, disables the
  vent, and updates route feedback to `Forward Pressure Traverse Crossed`.
- Restored completed state does not replay Story068 clear burst, does not
  restart entity `2118`, and keeps `FactoryServiceLift` optional with prompt
  `Call lift`.

## Godot MCP Runtime Verification

Godot AI MCP `2.8.3` launched
`res://scenes/factory_route_transition_shell.tscn` with `autosave=false` and
confirmed the game helper was live.

Runtime eval verified:

- Scene `FactoryRouteTransitionShellScene` was running.
- `FactoryLowerDeckForwardPressureVent` was present.
- Ready state after forward conduit defeat exposed the reused steam vent texture,
  hazard id `old_factory_lower_deck_forward_pressure_traverse`, damage `8`,
  cooldown `1.0`, and route label `Forward Conduit Secured`.
- Activating at x `1284` succeeded and entered `grace`; route label advanced
  to `Cross Forward Pressure Leak`.
- Advancing `0.32s` entered `warning` with contact disabled.
- Advancing another `0.36s` entered `active` with contact enabled.
- Applying vent contact during active reduced Cinderpaw HP from `100` to `92`.
- Advancing another `0.45s` entered `safe` with contact disabled.
- Completing at x `1328` succeeded once, duplicate completion returned `false`,
  persisted `factory_lower_deck_forward_pressure_traverse_crossed=true`, hid and
  disabled the vent, and set route label `Forward Pressure Traverse Crossed`.
- Story068 clear burst remained hidden with `spawn_count=0`; entity `2118` and
  the Story067 conduit hazard remained inactive/hidden.
- `FactoryServiceLift` stayed optional with prompt `Call lift`.
- Game screenshot metadata was non-empty: `960x539`.
- Game log contained only the MCP helper registration line.

Editor log note:

- MCP editor log still surfaced pre-existing Story015 `CombatComponent` Debugger
  rows. Fresh CLI isolation in `reports/report_1106/` passed `5/5`, matching the
  existing stale-row treatment from Stories067-068.
