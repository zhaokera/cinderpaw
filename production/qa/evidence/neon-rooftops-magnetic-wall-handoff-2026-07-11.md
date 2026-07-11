# QA Evidence: Neon Rooftops Magnetic Wall Gate Handoff

## Scope

Story136 connects the Story135 Factory high perch to the registered first Neon
Rooftops screen. The slice persists a permanent area gate, carries abilities
through SceneManager, provides exact high-perch return alignment, requests the
existing rooftop audio cues, and requires real wall-climb physics to reach a
high route proof over generated rooftop art.

## Automated Evidence

- Initial RED: `reports/report_1472/results.xml` executed all `3` focused cases
  and recorded `18` expected missing-contract failures with zero framework
  errors before registry, assets, scene, scripts, audio mapping, and handoff
  implementation existed.
- Focused GREEN: `reports/report_1475/results.xml` passed `3/3` with zero errors,
  failures, flaky cases, skipped cases, or orphan nodes.
- The first bounded adjacent run `report_1476` exposed one intentionally stale
  Story135 objective expectation after the new destination became actionable.
  The adjacent contract now expects `Enter Neon Rooftops`.
- Final bounded adjacent GREEN: `reports/report_1477/results.xml` passed `9/9`
  across Stories134-136 with zero errors, failures, flaky cases, skipped cases,
  or orphan nodes.
- The targeted headless smoke exited `0` with marker
  `neon_rooftops_magnetic_wall_handoff_smoke=passed`. It used the real
  SceneManager, transitioned Factory→Rooftops, preserved abilities, entered
  actual wall collision, climbed with project input state, wall-jumped, reached
  the one-way high roof, recorded the proof, returned to Factory, and verified
  exact high-perch spawn alignment.
- Godot 4.7 `--import --quit` exited `0` and registered both new global scene
  classes plus every new source/runtime texture.

## Asset Evidence

- Built-in image generation produced one opaque `1672x941` rooftop source and
  one keyed `1672x941` two-prop source.
- The background became exact opaque RGB `1280x720`. Sampled-key matte/despill,
  edge contraction/feather, equal-half slicing, trim, fit, and centering produced
  exact transparent RGBA `256x512` magnetic tower and `256x384` bridge beacon.
- Runtime alpha bounds retain safe padding and visual inspection found no
  magenta fringe, crop, baked text, or primitive substitute.
- Generation prompts, processing, source/alpha/runtime paths, asset spec,
  manifest, and entity inventory are retained.

## Runtime Findings And Fixes

- The first adjacent expectation ended Story135 at `Rooftop Route Reached`.
  Story136 correctly supersedes that state with actionable `Enter Neon Rooftops`;
  the adjacent test was updated without changing Story135 movement behavior.
- The destination top boundary initially reused the shorter lower-roof shape.
  It now has a dedicated full-width `1280x48` collision shape so the magnetic
  climb cannot escape above either side of the scene.
- Two exploratory MCP eval probes contained an invalid diagnostic call and mixed
  indentation. They affected only generated eval scripts, not project files;
  both runs were stopped. Final run `48` used a temporary fixture with no eval
  and clean current-run logs. The fixture was deleted after capture.

## Godot MCP Evidence

- Session: `cinderpaw@e40d`
- Engine: Godot `4.7-stable (official)`
- Plugin/server: Godot AI MCP `2.9.1`
- Authored inspection found `36` nodes: generated background, lower/upper roof
  collision, full top and side bounds, generated magnetic tower/contact glow,
  proof area, Cinderpaw `AnimatedSprite2D`, Camera2D, generated Factory bridge,
  return interaction, objective, and HUD.
- MCP confirmed exact texture paths, Cinderpaw SpriteFrames resource, Camera2D
  limits `0/0/1280/720`, and one-way upper-roof collision with margin `4`.
- Run `46` used a real `E` key event at the Factory high route and reached the
  logical/current runtime scene `area_05_neon_rooftops` with the expected
  `factory_rooftop_arrival` handoff state before the exploratory probe was
  discarded.
- Final run `48` returned `current_run_errors=[]`. Its non-empty `1278x718`
  screenshot clearly shows the generated moonlit rooftop scene, bridge beacon,
  generated magnetic tower, Cinderpaw in the `wall_climb` frame state, HUD, and
  `Climb the Neon Magnetic Tower` without overlap.
- Final game logs contain only MCP helper registration and
  `story136_mcp_fixture=ready wall_climb_started=true`; editor reads after cursor
  `3` contain no new rows. Retained Old Factory parse rows predate this story and
  did not recur.

## Verdict

PASS. Story136 is a visible, bidirectional, state-safe Neon Rooftops entry with
generated art, rooftop audio, real SceneManager handoff, physical wall-climb
proof, bounded regression coverage, and clean final Godot MCP evidence.
