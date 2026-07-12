# QA Evidence: Neon Rooftops Relay Spire Savepoint Traverse

## Scope

Story138 expands Neon Rooftops to `3840x720` after the Signal Roof reward.
Claiming the Story137 cache opens a reused signal seal, a generated roost
provides one autosaving recovery point, and the existing wall-climb system
crosses a lethal magnetic-spire gap to a persistent Tower Approach endpoint.

## Automated Evidence

- Initial RED: `reports/report_1484/results.xml` ran all `3` focused cases and
  recorded `24` expected contract failures with zero framework errors.
- Focused GREEN: `reports/report_1485/results.xml` passed `3/3` with zero errors,
  failures, skipped cases, flaky cases, or orphan nodes.
- The first Story137-138 run `report_1486` found one stale Story137 camera
  assertion fixed at exactly `2560`. It now correctly requires at least its own
  `2560px` slice while permitting Story138's `3840px` extension.
- Final bounded Story137-138 GREEN: `reports/report_1487/results.xml` passed
  `6/6` with zero errors, failures, skipped cases, flaky cases, or orphan nodes.
- Targeted Godot 4.7 headless smoke exited `0` with marker
  `neon_rooftops_relay_spire_savepoint_traverse_smoke=passed`. It covered route
  state, full heal and one autosave, lethal fall, 50% revive, two-second control
  lock, real input wall climb, endpoint completion, and fresh no-replay restore.
- Godot 4.7 `--import --quit` exited `0`, registered
  `NeonRelaySpireController`, and imported every new source/runtime texture.

## Asset Evidence

- Built-in image generation produced one opaque `1672x941` third-screen source
  and one keyed `1693x929` three-prop source.
- Local processing normalized exact opaque RGB `1280x720`, transparent RGBA
  `256x256`, `256x512`, and `256x384` runtime assets. The chroma helper sampled
  `#fa03e2` and retained both RGB and RGBA source sheets.
- Visual review confirmed readable left/right roofs, central climb path, safe
  roost silhouette, clean alpha edges, consistent lighting, and no baked text.
- Prompts, source/alpha/runtime paths, processing record, spec, manifest, and
  entity inventory are retained.

## Runtime Findings And Fixes

- The first adjacent test retained Story137's exact final camera width. Story138
  legally extends the same scene, so the older assertion now protects a minimum
  width rather than blocking later content.
- MCP run `51` initially hit a stale editor global-class cache even though
  Godot 4.7 headless/import and tests parsed the project. Reimporting the three
  related scripts and forcing an editor filesystem scan rebuilt the class table;
  final runs loaded normally without production changes.
- The first MCP fixture placement naturally fell into the gap during startup
  and proved the live 50% roost respawn. A delayed-physics fixture then isolated
  the requested real wall input long enough to capture the climb frame. Both
  fixture-only timing changes were removed after evidence capture.
- Three parallel level/Godot/QA sidecars failed before execution because the
  backend injected unsupported `reasoning.effort=max`; bounded reviews completed
  locally and no retry was performed.

## Godot MCP Evidence

- Session: `cinderpaw@e40d`
- Engine: Godot `4.7-stable (official)`
- Plugin/server: Godot AI MCP `2.9.1`
- A second force reload read the scene from disk and exposed `87` authored nodes,
  including the third background, approach/exit roofs, lower/upper perches,
  magnetic wall/visual, access seal, roost, fall zone, spawn marker, endpoint,
  Camera2D, objective, and HUD with exact generated texture paths.
- Final run `55` exposed `145` runtime nodes. Real MCP `move_right + move_up`
  input drove Cinderpaw's visible `AnimatedSprite2D` to animation `wall_climb`,
  frame `1`, using `cinderpaw_sprite_frames.tres` on the generated magnetic
  spire. The non-empty `1278x718` frame shows the roost, central spire, endpoint,
  Cinderpaw climbing, 100/100 HUD, and `Climb Relay Spire` without overlap.
- Final run `55` returned `current_run_errors=[]`. Its game log contains only
  helper registration, enemy-stat load, and fixture readiness; editor reads
  after cursor `3` contain no new rows. Retained Old Factory parse rows predate
  Story138 and did not recur.
- The temporary MCP fixture was deleted after capture.

## Verdict

PASS. Story138 adds a generated-art recovery and wall-climb traversal loop with
one-shot autosave, fair no-loss respawn, durable endpoint state, focused
regression coverage, and clean current-run MCP evidence.
