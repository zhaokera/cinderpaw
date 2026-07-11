# QA Evidence: Underground Recovery Cistern Savepoint Traverse

## Scope

Story132 expands `area_04_underground_passage` to `3840x720` with a generated
third viewport, a one-shot recovery relay, three stepping platforms over a
lethal fall zone, a far-side endpoint, autosave, and the existing no-loss
GameFlow death/revive contract.

## Automated Evidence

- Initial RED: `reports/report_1433/results.xml` recorded the missing Story132
  assets, controller, scene, and runtime APIs before implementation.
- MCP HUD regression RED: `reports/report_1442/results.xml` proved the
  Underground HUD was not following player health changes.
- Physics-trigger diagnostics in `reports/report_1444/` exposed Godot errors
  from changing `Area2D.monitoring/monitorable` inside `body_entered`.
- Final focused GREEN: `reports/report_1445/results.xml` passed `3/3`, with zero
  errors, failures, flaky cases, skipped cases, or orphan nodes and no engine
  error output.
- Final bounded related GREEN: `reports/report_1446/results.xml` passed `20/20`
  across Story132, Story131, Story130, GameFlow, savepoint selection, and
  autosave adapter suites. The process ended with the known short-lived
  `6`-object / `3`-resource cleanup report after all assertions passed.
- SceneManager smoke:
  `reports/underground_recovery_cistern_savepoint_traverse_smoke.log` exited
  `0` with `underground_recovery_cistern_savepoint_traverse_smoke=passed`.
  It covered Factory breach, Underground restore, relay heal/autosave, lethal
  fall, 50% revive, endpoint completion, Factory return, Underground re-entry,
  and one-shot state preservation. A two-object cleanup warning followed the
  pass marker.

## Runtime Fixes Found During Verification

- The real Underground HUD remained at `100/100` during damage and revive.
  `UndergroundPassageScene` now binds `player_health_changed` to `HUDManager`;
  the focused test and MCP both verify `0/100 -> 50/100` on fall/revive.
- Endpoint entry initially attempted to disable Area2D monitoring from inside
  the physics callback. All relay, endpoint, and fall-zone monitoring changes
  now use deferred property updates. The focused test physically overlaps the
  endpoint, waits for physics/process frames, and verifies automatic completion
  without Godot error output.

## Asset Evidence

- Built-in image generation produced one opaque background plus two isolated
  magenta-keyed props. Source, retained alpha, prompt intent, processing, and
  runtime paths are recorded in three generation records and one asset spec.
- Runtime contracts verified by GdUnit and ImageMagick:
  - background `1280x720`, opaque RGB;
  - recovery relay `256x256`, transparent RGBA;
  - deep-route endpoint `256x384`, transparent RGBA.
- Godot 4.7 headless import exited `0` and created import metadata for every
  source, alpha, and runtime PNG.

## Godot MCP Evidence

- Session: `cinderpaw@e40d`
- Engine: Godot `4.7-stable (official)`
- Plugin/server: Godot AI MCP `2.9.1`
- Disk authority: `underground_passage.tscn` force-reloaded with
  `reloaded_from_disk=true`.
- Editor inspection found the recovery background/controller/relay, three
  `CisternStep` StaticBody2D nodes, `FallZone`, endpoint, and Camera2D right
  limit `3840`; generated texture paths matched the manifest.
- Direct current-scene run token `29` used real movement and attack input to
  defeat both Sluice Leeches, unlock the third viewport, activate the relay,
  and enter the fall zone. Runtime inspection verified relay position
  `(2720,576)`, objective `Cross Recovery Cistern`, death HUD `0/100`, and
  revived HUD `50/100` at the relay.
- A temporary progression-state fixture supplied the already-earned Dash,
  Double Jump, and Aerial Attack abilities for visual traversal. Real input
  landed Cinderpaw on authored platform coordinates near `(2924,487)` and
  `(3118,409)`, reached the exit ledge near `(3349,576)`, and framed the
  endpoint. The fixture files were removed and are not part of the project.
- Final run token `32` produced a non-empty `1278x718` screenshot showing
  Cinderpaw, the generated relay, all three platforms, lethal pit, generated
  endpoint, objective, and HUD without overlap.
- The final game log contained only MCP helper registration. Editor log reads
  after cursor `3` returned no new rows. Three retained Old Factory parse rows
  were marked as pre-run history and did not recur.

## Verdict

PASS. Story132 is visible, playable, persistent, imported through Godot 4.7,
and verified through focused/related tests, SceneManager smoke, real MCP input,
runtime HUD state, logs, and screenshots.
