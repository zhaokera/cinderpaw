# QA Evidence: Old Factory Forward Pressure Aftershock Condenser Savepoint

Date: 2026-07-09
Engine: Godot 4.7-stable
MCP: Godot AI 2.9.1

## Scope

Player Abilities Story095 adds the savepoint and respawn anchor after the
Story094 aftershock condenser landing is secured. The relay stays hidden and
non-interactive until the condenser ambush is cleared, then activates through
the existing savepoint runtime and persists the latest respawn point.

## Assets

New image generation was used for the aftershock condenser savepoint relay:

- Source:
  `assets/generated/source/old_factory_aftershock_condenser_savepoint_imagegen_20260709.png`
- Alpha source:
  `assets/generated/source/old_factory_aftershock_condenser_savepoint_alpha_20260709.png`
- Metadata:
  `assets/generated/source/old_factory_aftershock_condenser_savepoint_imagegen_20260709.json`
- Runtime:
  `res://assets/environment/old_factory_aftershock_condenser_savepoint/env_old_factory_aftershock_condenser_savepoint_256.png`

Prompt summary: compact Old Factory aftershock condenser relay pedestal for a
cat action game, with brass-and-steel body, copper coils, pressure gauge,
ceramic insulators, cyan ember lights, worn bolts, soot, and paw-scale
activation plate on a flat green chroma-key background for local alpha removal.

## Automated Evidence

- Initial focused RED: `reports/report_1232/`
  - Failure captured missing Story095 asset/API/diagnostics before
    implementation.
- Focused GREEN: `reports/report_1233/`
  - `2/2` tests passed.
- Minimal related GREEN: `reports/report_1234/`
  - `19/19` Story095 + adjacent aftershock chain + respawn tests passed.
- Headless smoke:
  `reports/old_factory_aftershock_condenser_savepoint_smoke.log` exited `0`.
  - Keyword scan found no project script/parse/invalid-call/access/
    missing-resource/resource-load errors.
  - Godot emitted existing shutdown cleanup noise about leaked
    ObjectDB/resource instances after `--quit-after`; no Story095 script or
    resource paths were present in that noise.

## MCP Evidence

Godot MCP session `cinderpaw@1014` reloaded
`res://scenes/factory_route_transition_shell.tscn` from disk and launched the
current scene. Runtime helper status was live.

MCP verified:

- Editor and runtime scene trees contain
  `FactoryLowerDeckForwardPressureAftershockCondenserSavepoint` with
  `Visual`, `PromptLabel`, `InteractionArea`, and `CollisionShape2D`.
- Editor properties match the savepoint contract:
  `savepoint_id=old_factory_lower_deck_forward_pressure_aftershock_condenser_savepoint`,
  `scene_id=area_03_factory`,
  `spawn_point=lower_deck_forward_pressure_aftershock_condenser_savepoint`,
  prompt `Repair Condenser Relay`, and generated texture
  `res://assets/environment/old_factory_aftershock_condenser_savepoint/env_old_factory_aftershock_condenser_savepoint_256.png`.
- Runtime probe after Story094 clear reported ready visibility and prompt,
  successful Story095 activation, `active_activated=true`, local flag `true`,
  persisted last savepoint snapshot, and route label
  `Aftershock Condenser Savepoint Secured`.
- Final editor log was empty.
- Final game log contained only Godot AI helper registration plus the Story095
  MCP probe line.
- A non-empty `960x539` game screenshot showed the generated condenser
  savepoint relay and prompt `Repair Condenser Relay`.

## Verdict

PASS. Story095 adds a generated visual savepoint prop, gates it behind the
Story094 condenser landing clear, persists the respawn anchor, and preserves
the Story092/Story093/Story094 route chain.
