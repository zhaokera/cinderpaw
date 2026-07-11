# QA Evidence: Deep Cistern Ascender Factory Upper Altar Approach

## Scope

Story134 connects the Story133-cleared deep cistern to a registered, bounded
Old Factory upper-works scene. The route persists Underground state and unlocked
abilities, performs a real SceneManager handoff, supports a return trip, and lets
Cinderpaw discover a dormant hidden altar without granting `wall_climb`.

## Automated Evidence

- Initial RED: `reports/report_1457/results.xml` failed on the absent registry,
  schema, route, destination scene, scripts, generated textures, and state
  contracts before implementation.
- Runtime objective RED: `reports/report_1461/results.xml` reproduced a stale
  parent objective when restored encounter state changed after scene setup.
- Final focused GREEN: `reports/report_1463/results.xml` passed `3/3` with zero
  errors, failures, flaky cases, skipped cases, or orphan nodes.
- Bounded related GREEN: `reports/report_1459/results.xml` passed `15/15` across
  Story133, Story134, and SceneManager transition coverage.
- Targeted headless smoke exited `0` with marker
  `deep_cistern_ascender_factory_upper_altar_approach_smoke=passed`. It covered
  prerequisite restore, route availability, one-shot request, persisted target
  state, upper-scene discovery, return target/spawn, and ability preservation.

## Asset Evidence

- Built-in image generation produced an opaque `1672x941` upper-works source and
  a `1536x1024` flat-magenta ascender/altar prop source.
- The background was center-cropped and downsampled to exact opaque RGB
  `1280x720`. The prop source used sampled key `#fa02f9`; soft matte, despill,
  edge contraction, feathering, alpha trim, fit, and centering produced exact
  transparent RGBA `384x512` ascender and `384x384` altar assets.
- Godot 4.7 imported all source, alpha, and runtime PNG files. The destination
  resolves the generated background, ascender, and altar textures from
  `assets/environment/factory_upper_altar/`.
- Generation prompts, intended use, processing, retained sources, runtime paths,
  asset spec, manifest entries, and entity inventory entries are recorded.

## Runtime Fixes Found During Verification

- A restored Story133 clear state could leave the parent objective at
  `Deep Cistern Secured` after the route became actionable. The parent now
  refreshes objective priority during runtime; the focused regression verifies
  `Ride Ascender to Upper Factory`.
- The Underground interaction label could clip against the right viewport edge.
  Its authored position now stays inside the visible gameplay frame.
- The first upper-scene layout placed the altar beneath the Gears HUD and later
  in front of Cinderpaw. The final position, scale, and z-order keep the landmark,
  player, and HUD simultaneously readable.
- Fresh discovery initially showed both a local prompt and the top objective.
  Discovery now hides the local prompt and leaves one authoritative
  `Dormant Altar Found` message.

## Godot MCP Evidence

- Session: `cinderpaw@e40d`
- Engine: Godot `4.7-stable (official)`
- Plugin/server: Godot AI MCP `2.9.1`
- The destination scene was force-opened from disk. Authored inspection found
  `38` nodes, including Cinderpaw with `AnimatedSprite2D`, Camera2D, HUD,
  objective, three `StaticBody2D/CollisionShape2D` platforms, return route, and
  generated background/ascender/altar textures. Camera limits are
  `0/0/1280/720`.
- Run `39` restored a cleared deep cistern, showed the generated ascender and
  actionable objective, accepted real `E` input, and swapped the runtime tree to
  `FactoryUpperAltarApproachScene`. Real right movement moved Cinderpaw from
  x `196` to approximately x `553` without runtime errors.
- Run `41` restored altar proximity and captured Cinderpaw visibly in front of
  the altar with `factory_upper_hidden_altar_discovered=true`, altar z-index
  `18`, local prompt hidden, and objective `Dormant Altar Found`.
- Both final screenshots were non-empty and showed generated gameplay visuals,
  Cinderpaw, HUD, and readable objectives without overlap. Final
  `project_run.current_run_errors=[]`; game logs contain only MCP helper/fixture
  markers, and editor reads after cursor `3` contain no new rows.
- Temporary validation fixtures were deleted after use. Retained Old Factory
  parse records predate these runs and did not recur.

## Verdict

PASS. Story134 is a visible, bidirectional, state-safe playable route with
generated art, collision-backed traversal, idempotent altar discovery, focused
and adjacent automated coverage, a targeted smoke, and clean Godot MCP runtime
evidence. `wall_climb` remains intentionally locked for Story135.
