# QA Evidence: Central Tower Threshold Guard Handoff

## Scope

Story140 turns the secured Story139 endpoint into a bidirectional scene handoff
to `area_05_central_tower`. The first Tower room contains a real Threshold Roost,
one data-driven frame-animated guard, two encounter seals, shared combat
collision, no-loss death/revive, durable clear state, and a Rooftops return.
Boss4, deeper Tower rooms, rewards, NPCs, and new abilities remain out of scope.

## Automated Evidence

- Expected RED: `reports/report_1493/results.xml` loaded all three Story140 cases
  and exited `100` with `48` expected missing-file/API assertions before
  implementation.
- First post-implementation attempt:
  `reports/report_1494/report_1/results.xml` exposed an asset-pipeline
  prerequisite: the new PNGs existed but had not entered the Godot import cache.
  No production fallback was added.
- Godot `4.7-stable` headless editor import exited `0`, imported the environment,
  props, source sheets and all eighteen frames, and registered
  `CentralTowerThresholdGuardCharacter`, `CentralTowerThresholdGuard`,
  `CentralTowerThresholdGuardController`, and `CentralTowerThresholdScene`.
- Final focused GREEN: `reports/report_1495/report_1/results.xml` passed `3/3`
  with zero errors, failures, flaky cases, skipped cases, or orphan nodes. It
  covers registry/data/schema contracts, exact asset dimensions and frame
  counts, Rooftops entry/return, one-shot requests, ability handoff, guard/player
  hitboxes, 14-damage enemy attack, death/revive reset, durable clear, restore,
  and exact return IDs.
- Post-review focused GREEN: `reports/report_1497/report_1/results.xml` passed
  `3/3` with zero errors or failures after two lifecycle hardening fixes. Failed
  attempts now deactivate every active guard hitbox before reactivation, with a
  direct zero-active-hitbox assertion; first-entry Roost activation is deferred
  until SceneManager can restore durable state, preventing restored-room replay.
- Story139 adjacent regression: `reports/report_1496/report_1/results.xml` passed
  `3/3` with zero errors or failures, preserving laser miss damage, three real
  parries, outer-gate clear, and no-replay restoration after the new route was
  attached.
- Final consolidated regression `reports/report_1500/results.xml` passed the
  Story140 and Story139 suites `6/6` with zero errors or failures. Story140 now
  also covers loading/locked/unknown rejection, async load-failure retry, all six
  runtime animation states, authored-position reset, revive control plus i-frames,
  and guard defeat during the player-death window.
- Final review-closure run `reports/report_1501/results.xml` passed Story140
  `3/3` with zero errors or failures after adding exact no-new-ability equality
  and explicit 120-frame i-frame expiry assertions.
- Targeted Godot 4.7 headless smoke exited `0` with marker
  `central_tower_threshold_guard_handoff_smoke=passed`. It used the real
  SceneManager for secured Rooftops -> Tower -> Rooftops loading, checked exact
  spawn ids/positions and preserved state, validated all six three-frame
  animations, activated both seals, routed one real guard hit for `14` damage,
  defeated entity `2701`, and verified both seals and the completion objective
  opened. Before the three-second deferred unload expired, it entered Tower a
  second time, asserted the same runtime instance id, durable clear, and exact
  complete ability set, then returned to Rooftops again and rechecked the same
  ability set. Full output is retained at
  `reports/central_tower_threshold_guard_handoff_smoke.log`.
- GdUnit image-dimension cases emit Godot's standard direct `Image.load` export
  warning; headless shutdown also reports the repository's existing ObjectDB and
  resource-in-use cleanup noise. Both passing runs exit `0`; MCP current-run
  logs below contain no gameplay or script error.

## Asset Evidence

- Built-in image generation produced an opaque `1672x941` RGB vestibule source,
  retained at
  `assets/generated/source/central_tower_threshold_background_imagegen_20260712.png`
  and normalized to exact opaque `1280x720` runtime output.
- The keyed prop sheet is `1774x887`. Border key `#f904eb` was alpha-matted with
  `1,191,554` transparent and `16,800` partially transparent pixels, then split,
  trimmed, fitted, and centered into exact transparent `384x512`, `256x256`, and
  `256x256` seal, roost, and dock canvases.
- The guard source is a strict `887x1773` `3x6` sheet. Border key `#f803f8` was
  alpha-matted with `1,160,189` transparent and `61,859` partially transparent
  pixels. All eighteen poses were fitted to exact transparent `96x96` frames,
  centered, and aligned to common bottom baseline y `88`.
- Runtime animations are `idle`, `run`, `attack_tell`, `attack`, `hurt`, and
  `death`, exactly three continuous `_000.._002` frames each, connected through
  `AnimatedSprite2D + SpriteFrames` at
  `res://assets/characters/central_tower_threshold_guard/central_tower_threshold_guard_sprite_frames.tres`.
- Visual review confirmed an unobstructed combat floor, detailed Tower machinery,
  readable safe roost, imposing security seals, distinct heavy guard silhouette,
  transparent corners, no baked text, and no visible primitive placeholder.

## Runtime Findings

- Rooftops keeps Story139's trial controller unchanged. The parent scene exposes
  a second `RouteTransitionShell` only when
  `neon_rooftops_central_tower_threshold_secured=true`, persists Story136-139,
  copies unlocked abilities into the Tower state, and latches one request.
- `central_tower_threshold_roost` is a real `SavepointRuntime` at the arrival
  marker. Existing `GameFlowController` provides `1.5s` death delay, 50% HP
  revive, immediate control restoration, and `2.0s / 120` frames of player
  invincibility. The arrival Marker uses the valid standing center at `y=552`
  above the floor surface at `y=576`, and the Roost snapshot reuses that position.
  Restore clears transient encounter activation, reopens the seals, and restores
  the living guard to `48/48` HP at its authored position; a death-window clear
  is never rolled back.
- The guard reuses established Core Health/Collision/Combat components while
  retaining its own entity `2701`, data id, character scene/script, gameplay
  wrapper, attack metadata, `24/6/24` latch-thrust timing, and `14` damage.

## Godot MCP Evidence

- Session: `cinderpaw@e40d`
- Engine: Godot `4.7-stable (official)`
- Plugin/server: Godot AI MCP `2.9.1`
- Forced disk scene open succeeded with readiness `ready`. Editor hierarchy
  exposed `44` authored nodes including the generated background, real floor and
  boundaries, Threshold Roost interaction, return route, both seals, guard
  `AnimatedSprite2D`, Player/Camera2D, GameFlow, HUD, and objective.
- Custom run token `62` became `live` with helper capture ready and
  `current_run_errors=[]`. Runtime hierarchy exposed `78` nodes, including the
  guard's dynamic Health, Collision, Hurtbox, Combat, and StatusEffect components.
- MCP held real `move_right` input long enough to cross x `420`. The objective
  changed to `Break the Threshold Guard`, both generated seals became visible and
  blocking, and the guard appeared on its generated dock beside Cinderpaw.
- Runtime node inspection found the visible guard sprite as `AnimatedSprite2D`,
  animation `run`, script
  `res://src/characters/central_tower_threshold_guard.gd`, and SpriteFrames
  `res://assets/characters/central_tower_threshold_guard/central_tower_threshold_guard_sprite_frames.tres`.
- The non-empty `1278x718` game capture clearly shows the generated Tower room,
  Threshold Roost, Cinderpaw, animated heavy guard, both sealed doors, objective,
  and HUD without incoherent overlap. The audited PNG is
  `reports/visual/cinderpaw-mcp-central-tower-threshold-guard-run62-20260712.png`
  (`1,426,538` bytes; SHA-256
  `5ac26d6fa4138e90c2bef97c65d8f4dfaf632eb80b6d7b19fe0d8fea30c1d7f5`).
- Current-run game logs contain only MCP helper registration and enemy-stat load.
  Editor logs after cursor `3` contain no new rows. Retained Old Factory and old
  global-class-cache errors reported by `project_run` explicitly predate run 62
  and are not current-run failures.
- MCP stopped the custom run cleanly and returned editor readiness to `ready`.
  A machine-readable summary is retained at
  `production/qa/evidence/central-tower-threshold-guard-handoff-mcp-run62.json`.

## Verdict

PASS. Story140 provides a generated-art, bidirectional, playable Central Tower
threshold room with real combat, frame animation, savepoint death/revive, durable
state, bounded regression evidence, and clean current-run MCP validation.
