# QA Evidence: Factory Hidden Altar Wall Climb Reward Traversal

## Scope

Story135 turns the discovered upper Factory altar into the alternate
`wall_climb` source defined by the ability GDD. It adds a data-driven movement
state, generated three-frame Cinderpaw animation, one-shot persisted reward,
generated altar/wall/contact visuals, and a bounded physical climb-and-wall-jump
proof without inventing Boss4 or the Neon Rooftops scene.

## Automated Evidence

- Initial RED: `reports/report_1464/results.xml` ran all three focused cases and
  recorded `30` expected contract failures before implementation, with no
  framework errors.
- First focused GREEN: `reports/report_1465/results.xml` passed `3/3` after the
  data, animation, reward, persistence, scene, and movement implementation.
- Bounded related GREEN: `reports/report_1466/results.xml` passed `12/12` across
  Story134, Story135, AbilityComponent runtime gating, and player animation.
- One-way-platform RED/GREEN: `reports/report_1467/results.xml` reproduced the
  solid-underface route bug with one focused failure; `report_1468` passed
  `3/3` after the proof perch became one-way.
- Scene-top-boundary RED/GREEN: `reports/report_1469/results.xml` reproduced the
  climb-out-of-bounds issue with one focused failure; `report_1470` passed
  `3/3` after the authored top boundary was added.
- Final focused GREEN: `reports/report_1471/results.xml` passed `3/3` with zero
  errors, failures, skipped cases, or orphan nodes after the proof perch moved
  down for HUD-safe framing.
- Targeted headless smoke exited `0` with marker
  `factory_hidden_altar_wall_climb_reward_smoke=passed`. It entered real wall
  contact, climbed upward, wall-jumped, and proved the route.

## Asset Evidence

- Built-in image generation produced a `2172x724` three-cell Cinderpaw wall
  climb strip, a `1254x1254` awakened altar, an `887x1774` magnetic wall, and a
  `1254x1254` claw-contact glow.
- Sampled-key soft matte, despill, edge contraction, feathering, equal-cell
  slicing or alpha trim, and proportional fit produced three transparent
  `96x96` frames plus exact transparent `384x384`, `256x512`, and `192x192`
  runtime assets.
- Godot 4.7 imported all source, alpha, runtime, SpriteFrames, scene, and script
  resources. Prompts, processing, paths, asset spec, manifest, and inventory are
  retained for audit.

## Runtime Fixes Found During Verification

- The first proof perch blocked a wall jump from below. It is now a one-way
  platform, so Cinderpaw can pass upward and land from above.
- Holding climb at the right wall initially allowed the player to leave the
  scene above the camera. A collision-backed `TopBoundary` now keeps the full
  route inside the `1280x720` play space.
- The first successful landing sat too close to the Gears HUD. The proof perch
  and proof area moved down `25` pixels, preserving the physical challenge while
  keeping Cinderpaw and objective readable.
- The upper-scene controller declared an unused magnetic-wall node reference.
  That warning-only field was removed before delivery; visual control remains
  on the actual generated Sprite2D.

## Godot MCP Evidence

- Session: `cinderpaw@e40d`
- Engine: Godot `4.7-stable (official)`
- Plugin/server: Godot AI MCP `2.9.1`
- The disk scene was force-opened and inspected for Cinderpaw's
  `AnimatedSprite2D`, the generated wall/altar/glow texture paths, wall and top
  collision, one-way proof perch, and high proof Area2D.
- Runs `42-45` used real `E`, horizontal, vertical, jump, dash, and return input.
  MCP observed `wall_climb` animation during contact, found the one-way and top
  escape defects above, and verified both fixes in fresh runs.
- Final run `45` landed Cinderpaw on the lowered proof perch at approximately
  `(1068.66, 90.93)` with objective `Rooftop Route Reached`. The non-empty
  `1278x718` game frame clearly shows generated upper Factory art, awakened
  altar, magnetic wall, Cinderpaw, HUD, and the completed objective without
  overlap.
- Final game logs contain only MCP helper and temporary fixture markers, with no
  game error rows. The retained Old Factory parse rows predate Story135 runs and
  did not recur. The temporary MCP fixture was deleted after capture.

## Verdict

PASS. Story135 is a persisted, image-generated, frame-animated, physically
playable wall-climb reward and traversal proof with bounded automated coverage
and direct Godot MCP runtime evidence.
