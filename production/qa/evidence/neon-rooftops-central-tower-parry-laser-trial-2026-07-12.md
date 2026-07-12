# QA Evidence: Neon Rooftops Central Tower Parry-Laser Trial

## Scope

Story139 expands Neon Rooftops to `5120x720` with a generated fourth viewport.
Story138 completion opens the approach; three real, timed `parry` activations
reflect the tower laser, permanently open the outer `ExplorationGate`, and
secure a generated threshold endpoint without inventing Central Tower interior
or Boss4.

## Automated Evidence

- Initial RED: `reports/report_1488/results.xml` exited `100` with `17`
  expected missing-controller, asset, node, and scene-width failures. There were
  no parser or framework errors; GdUnit stopped after the first assertion-heavy
  case at the failure cap.
- Early GREEN attempts `report_1489` and `report_1490` passed the authored and
  miss-damage cases but exposed a deterministic test-harness timing mistake:
  state restoration re-enabled process, then a redundant `0.19s` advance ate
  the next pulse window. Production state-machine rollover behavior was kept;
  the test now disables automatic process after restore and removes the extra
  post-reflection advance.
- Final focused GREEN: `reports/report_1491/results.xml` passed `3/3` with zero
  errors, failures, flaky cases, skipped cases, or orphan nodes.
- Final bounded Story138-139 GREEN: `reports/report_1492/results.xml` passed
  `6/6`. Story138 now protects a minimum `3840px` authored route while allowing
  Story139's legal `5120px` extension; its controller diagnostics stay exact.
- Targeted Godot 4.7 headless smoke exited `0` with marker
  `neon_rooftops_central_tower_parry_laser_trial_smoke=passed`. It covered a
  lethal `18`-damage miss, Story138 roost revive at 50% HP, two-second control
  lock, real headless `parry` input, three reflections, one gate unlock, one
  threshold completion, and fresh no-replay restore. The first smoke attempt
  released the synthetic action on the pre-physics signal; holding it through
  the following process frame corrected input delivery without production code
  changes.
- Godot 4.7 `--import --quit` exited `0`, registered
  `NeonTowerParryTrialController`, and imported all source/runtime PNGs.

## Asset Evidence

- Built-in image generation produced one opaque `1672x941` fourth-screen
  background and one keyed `1774x887` three-asset sheet.
- Chroma removal sampled `#f803f6`, produced an RGBA source with `1,204,023`
  transparent and `84,122` partially transparent pixels, then normalized exact
  opaque RGB `1280x720` and RGBA `384x512`, `512x128`, and `256x384` runtime
  files.
- Visual review confirmed an unobstructed side-view floor, strong tower
  silhouette, readable cat-ear laser frame, continuous pulse, clean beacon,
  transparent corners, no baked text, and no primitive placeholders.
- Prompts, source/alpha/runtime paths, processing record, spec, manifest, and
  entity inventory are retained.

## Runtime Findings And Fixes

- The three-pulse controller accepts only the typed player
  `ability_activated(&"parry")` signal during strike, immediately latches one
  result, and keeps large-delta telegraph/strike/recovery rollover deterministic.
- Story138's existing `GameFlowController` already listens to the same player's
  death signal. Laser misses therefore required no second death controller and
  retained no-loss reflection progress through the existing roost path.
- MCP run `56` hit the editor's stale global-class cache even though CLI import
  and GdUnit parsed the script. The run was stopped; MCP reimported the new
  controller, root script, scene, and fixture, then scanned the filesystem.
  Global class count advanced to `288`; no production workaround was needed.
- Three read-only level/art/QA sidecars were requested with supported `high`
  effort, but the backend rewrote all requests to invalid
  `reasoning.effort=max`. They failed before execution, were closed once, and
  were not retried.

## Godot MCP Evidence

- Session: `cinderpaw@e40d`
- Engine: Godot `4.7-stable (official)`
- Plugin/server: Godot AI MCP `2.9.1`
- Forced disk reload exposed `108` authored nodes, including the fourth
  background, trial floor, access seal, Area2D, generated pulse, ExplorationGate
  visual/collision, endpoint, full-width boundary, Camera2D, objective, and HUD.
- Clean runs `57-58` exposed `145` runtime nodes. Run `57` captured the white/red
  strike and accepted real MCP `parry` input, advancing the objective from
  `Reflect Tower Laser 0/3` to `1/3`, tinting the generated pulse cyan, and
  leaving the gate collision blocking after one reflection.
- Run `58` immediately inspected the live player sprite after real MCP input:
  `AnimatedSprite2D animation="parry"`, frame `2`, script
  `res://src/characters/cinderpaw.gd`, and SpriteFrames
  `res://assets/characters/cinderpaw/cinderpaw_sprite_frames.tres`.
- The non-empty `1278x718` gameplay capture shows generated exterior art, gate,
  reflected pulse, visible Cinderpaw, `100/100` HUD, weapon/currency panels, and
  `Reflect Tower Laser 1/3` without incoherent overlap.
- Runs `57-58` returned `current_run_errors=[]`. Final game logs contain only
  helper registration, enemy-stat load, and fixture readiness. Editor reads
  after cursor `3` contain no new rows; retained Old Factory rows and the fixed
  run-56 cache error predate the clean run.
- The temporary MCP fixture and generated `.uid` were deleted after capture.

## Verdict

PASS. Story139 adds a generated-art, real-input parry timing challenge with
miss damage, existing roost death/revive, durable three-reflection gate state,
focused regression evidence, and clean current-run MCP validation.
