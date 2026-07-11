# QA Evidence: Underground Deep Cistern Stalker Ambush

## Scope

Story133 expands `area_04_underground_passage` to `5120x720` with a fourth
image-generated viewport and one new frame-animated elite. Story132 traversal
unlocks the arena; x `4050` closes seals at x `3980/4960`, activates entity
`2501`, and starts a 48 HP Stalker with a 24-frame tell, 6-frame 14-damage
leap-lunge, and 18-frame recovery.

## Automated Evidence

- RED: `reports/report_1448/results.xml` failed on the absent background,
  character/runtime scenes, SpriteFrames, controller, and diagnostics before
  implementation. All failures mapped to Story133 contracts.
- Intermediate GREEN diagnostic: `reports/report_1449/results.xml` passed the
  full asset/scene contract and exposed one real-combat error: the parent room's
  fixed 12-damage player adapter overrode the Stalker's authored 14 damage.
- Final focused GREEN: `reports/report_1456/results.xml` passed `3/3` with zero
  errors, failures, flaky cases, skipped cases, or orphan nodes. It includes the
  runtime-discovered endpoint prompt visibility and death-presentation
  regressions.
- Bounded related GREEN: `reports/report_1451/results.xml` passed `9/9` across
  Story131 corrosion combat, Story132 recovery traversal, and Story133 Stalker
  combat before the isolated prompt-visibility fix; the final Story133 suite and
  MCP run exercise that fix.
- Targeted runtime smoke:
  `reports/underground_deep_cistern_stalker_ambush_smoke.log` exited `0` with
  `underground_deep_cistern_stalker_ambush_smoke=passed`. It covered logical
  Underground SceneManager setup, Story132 prerequisite restore, activation,
  both seals, real 14-damage enemy collision, real player target routing,
  defeat, objective, and local-state persistence.

## Asset Evidence

- Built-in image generation produced an opaque `1672x941` deep-cistern source
  and an `887x1774` flat-magenta strict `3x6` Stalker sheet.
- The background was center-cropped/downsampled to exact opaque RGB
  `1280x720`. The installed imagegen helper removed key `#f702f1` with soft
  matte/despill; equal grid cells were normalized into eighteen transparent
  `96x96` frames with an `88x88` content box and common center origin.
- Automated image inspection found 18 files, transparent corners, non-empty
  alpha bounds, and no frame touching a canvas edge. The retained checkerboard
  preview confirms distinct idle, run, red-spine tell, leap, hurt, and death
  rows.
- Godot 4.7 imported source, alpha, preview, background, and all runtime frames.
  `underground_cistern_stalker_sprite_frames.tres` exposes all six required
  animation names with exactly three frames each.

## Runtime Fixes Found During Verification

- The enemy initially received the parent room's player damage calculator and
  dealt `12` instead of `14`. Its CombatComponent now uses the dedicated
  encounter controller's fixed leap-damage adapter; duplicate hit detection
  remains owned by CollisionComponent.
- The first MCP screenshot showed the completed Story132 endpoint prompt clipped
  at the left viewport edge. Recovery relay and endpoint labels now appear only
  within `192` px. `report_1452` captured the failing visibility assertion;
  `report_1454` and MCP run `34` verify the fix.
- Local review found the encounter controller opened the route and hid the
  Stalker in the same frame, preventing its authored death animation from being
  visible. `report_1455` captured the regression. The controller now completes
  gameplay state immediately while retaining and fading the non-damaging death
  sprite; `report_1456` and MCP run `36` verify the fix.

## Godot MCP Evidence

- Session: `cinderpaw@e40d`
- Engine: Godot `4.7-stable (official)`
- Plugin/server: Godot AI MCP `2.9.1`
- Disk authority: `underground_passage.tscn` force-reloaded with
  `reloaded_from_disk=true`.
- Authored inspection found `97` nodes, including the fourth background,
  dedicated controller, continuous ground, two seals, Stalker CharacterBody2D,
  and its AnimatedSprite2D. Background texture resolved to
  `env_underground_deep_cistern_1280x720.png`; Camera2D right limit was `5120`.
- Temporary non-project fixtures restored Story132 completion, activated the
  arena, and drove the bounded death check. They were deleted after validation.
- Final run token `34` exposed a `146`-node runtime tree. Real `move_right` and
  `attack` input moved Cinderpaw from x `4050` to x `4261.67`; the visible
  Stalker remained active near x `4517.20` with animation `run`, frame `1`, and
  the expected SpriteFrames resource.
- The final non-empty `1278x718` screenshot shows Cinderpaw, generated deep
  cistern, both generated seal visuals, the live non-placeholder Stalker,
  objective `Break Cistern Stalker`, HUD, and no clipped endpoint text.
- Run token `36` captured the Stalker's `AnimatedSprite2D` while visible in
  `death` frame `1` and fading, with both seals already non-colliding and the
  objective already changed to `Deep Cistern Secured`.
- `project_run.current_run_errors=[]`. Final run `36` game logs contain only MCP
  helper registration. Editor reads after cursor `3` contain no new rows. Three
  retained Old Factory parse records predate these runs and did not recur.

## Verdict

PASS. Story133 is visible, frame-animated, playable through the shared combat
chain, deterministic across restore, imported through Godot 4.7, and verified
through focused/related tests, smoke, real MCP input, logs, node inspection, and
a non-empty gameplay screenshot.
