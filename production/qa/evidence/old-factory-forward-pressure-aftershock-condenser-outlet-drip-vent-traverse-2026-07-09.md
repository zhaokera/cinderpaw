# QA Evidence: Old Factory Forward Pressure Aftershock Condenser Outlet Drip Vent Traverse

Date: 2026-07-09
Engine: Godot 4.7-stable
MCP: Godot AI 2.9.1

## Scope

Player Abilities Story098 extends the route beyond the Story097 aftershock
condenser outlet clamp ambush into a short drain-gantry traversal pocket. The
slice adds a new image-generated gantry prop, reuses the existing
image-generated Old Factory steam vent prop as an active-window drip vent
hazard, and persists the crossed state without replaying the Story094-097
condenser chain.

## Assets

New image generation was used for the aftershock condenser drain gantry prop:

- Source:
  `assets/generated/source/old_factory_aftershock_condenser_drain_gantry_imagegen_20260709.png`
- Alpha source:
  `assets/generated/source/old_factory_aftershock_condenser_drain_gantry_alpha_20260709.png`
- Metadata:
  `assets/generated/source/old_factory_aftershock_condenser_drain_gantry_imagegen_20260709.json`
- Runtime:
  `res://assets/environment/old_factory_aftershock_condenser_drain_gantry/env_old_factory_aftershock_condenser_drain_gantry_768.png`

Prompt summary: Old Factory aftershock condenser drain gantry for a side-view cat
action game, with a long horizontal grated walkway, rusted pipes, black right
pipe mouth, cyan condenser lights, riveted blue-grey metal, soot, hazard
striping, and a flat green chroma-key background for local alpha removal.

The hazard reuses the imported Old Factory steam vent prop at
`res://assets/environment/old_factory_steam_vent/factory_steam_vent_hazard.png`.

## Automated Evidence

- Initial focused RED: `reports/report_1244/`
  - Failure captured missing Story098 asset/API/diagnostics before
    implementation.
- Focused GREEN: `reports/report_1245/`
  - `2/2` tests passed.
- Commit-prep focused GREEN: `reports/report_1249/report_1/`
  - `2/2` tests passed with `0` errors, `0` failures, `0` skipped, and
    `0` orphans.
- Initial related GREEN: `reports/report_1246/`
  - `20/20` Story098 + Story097 + Story096 + Story095 + Story094 + Story093 +
    Story092 + savepoint respawn + no-loss respawn tests passed.
- Shared collision-state focused GREEN: `reports/report_1247/`
  - `14/14` Story098 + collision hurtbox state + entity death cleanup + player
    respawn visual tests passed after the MCP-exposed deferred collision fix.
- Final related GREEN: `reports/report_1248/`
  - `32/32` Story098 chain + collision and respawn regression tests passed.
- Headless smoke:
  `reports/old_factory_aftershock_condenser_outlet_drip_vent_traverse_smoke.log`
  exited `0`.
  - Keyword scan found no project script/parse/invalid-call/access/
    missing-resource/resource-load/flushing-query/in-out-signal state-change
    errors.
  - Godot emitted existing shutdown cleanup noise about resources still in use;
    no Story098 script or resource paths were present in that noise.

## MCP Evidence

Godot MCP session `cinderpaw@1014` reloaded
`res://scenes/factory_route_transition_shell.tscn` from disk and launched the
current scene. The live editor reported Godot `4.7-stable`, plugin `2.9.1`, and
server `2.9.1`; runtime helper status was live.

MCP verified:

- Editor scene contains
  `FactoryLowerDeckForwardPressureAftershockCondenserDrainGantry` and
  `FactoryLowerDeckForwardPressureAftershockCondenserOutletDripVentHazard`.
- The gantry `Sprite2D` uses the generated runtime texture, starts hidden, and
  the route geometry extends to ground width `6400`, right wall x `6380`, and
  camera limit right `6400`.
- The drip vent `Area2D` starts hidden/non-contacting, uses hazard id
  `old_factory_lower_deck_forward_pressure_aftershock_condenser_outlet_drip_vent`,
  damage `8`, cooldown `1.0`, and the reused steam vent texture.
- Locked diagnostics before Story097 clear reported unavailable, invisible, and
  no active contact.
- After setting Story097 cleared state, diagnostics reported available/visible
  with route label `Outlet Clamp Ambush Cleared`.
- Activation at x `5840` advanced route feedback to `Cross Outlet Drip Vent`
  and cycled deterministic `grace`, `warning`, `active`, and `safe` phases.
- Active phase contact applied `8` damage (`100 -> 92`); grace/warning/safe
  phases rejected contact damage.
- Crossing x `6260` persisted activated/crossed local-state flags, disabled
  hazard contact, and advanced route feedback to `Outlet Drip Vent Crossed`.
- A player death/respawn repro through the active vent produced no new
  flushing-query or in/out-signal state-change errors after the deferred
  collision-state fix.
- Final game log contained only the Godot AI helper registration line, and
  `logs_read(source="editor", since_cursor=9)` returned no new editor errors.
- A non-empty `960x539` game screenshot showed the generated drain gantry and
  reused steam vent prop.

## Verdict

PASS. Story098 adds a generated visible traversal prop and a real active-window
drip vent hazard after the aftershock condenser outlet clamp ambush, gates it
behind Story097 completion, persists crossed state, and keeps the lower-deck
route moving as playable ACT content without block placeholders.
