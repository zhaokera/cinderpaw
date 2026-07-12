# QA Evidence: Central Tower Inner Relay Skirmish

## Scope

Story141 extends `area_05_central_tower` to a bounded `2560x720` two-viewport
ACT area. The new Service Spine adds one generated relay-parry pressure beat,
one ordinary frame-animated Relay Mantis, two combat shutters, one durable
clear, and one established `+20 Gears` cache. Boss4, a third viewport, a new
scene id, and new abilities remain out of scope.

## Automated Evidence

- Expected RED: `reports/report_1503/results.xml` exited `100` against the
  authored three-case Story141 contract before production files existed.
- Intermediate `report_1504` proved the authored/data/animation contract and
  exposed deferred `CollisionShape2D` state in the test harness.
  `report_1505` then passed the first two cases and isolated the death-window
  retry path. Diagnostic `report_1506` confirmed that the deterministic
  GameFlow clock had skipped the physical frames that normally finish Core
  parry state; no production lifecycle workaround was added.
- Final focused GREEN: `reports/report_1507/results.xml` passed `3/3` with zero
  errors, failures, flaky cases, skipped cases, or orphan nodes. It covers exact
  generated asset dimensions, six three-frame Mantis animations, scene bounds,
  relay timing and real parry signal, Mantis hitbox damage, player damage,
  defeat, cache claim, failed-attempt reset, death-window durable clear,
  fresh restore, and exact no-new-ability equality.
- An independent read-only integration review found no blocking bug or soft
  lock, then reran the focused suite as `reports/report_1508/results.xml` with
  `3/3` passing.
- Story140 adjacent regression `reports/report_1509/results.xml` passed `3/3`,
  preserving registry handoff, the first viewport, Threshold Roost, old guard,
  no-loss revive, durable clear, exact abilities, and Rooftops return.
- Target headless smoke exited `0` with marker
  `central_tower_inner_relay_skirmish_smoke=passed`. It started directly from
  Story140 clear, sent a real PlayerController parry, routed a real Mantis
  hitbox for `12` damage, defeated entity `2702`, opened both shutters, claimed
  the cache once, rejected a duplicate claim, and restored claimed state into a
  fresh Tower instance without feedback replay. Output is retained at
  `reports/central_tower_inner_relay_skirmish_smoke.log`.
- GdUnit image-contract cases emit Godot's standard direct `Image.load` export
  warning. Passing headless runs also retain the repository's existing shutdown
  resource cleanup noise; all cited final commands exit `0`, and the MCP run
  below has no current-run gameplay or script error.

## Asset Evidence

- Built-in image generation produced a retained `1672x941` Service Spine
  source and exact opaque RGB `1280x720` runtime background at
  `res://assets/environment/central_tower/env_central_tower_service_spine_1280x720.png`.
- The retained `1536x1024` prop sheet used flat key `#fb03fa`. Alpha processing
  produced `1,295,866` fully transparent and `43,775` partially transparent
  pixels before isolating exact transparent relay `256x512`, shutter `384x512`,
  perch `256x256`, cache `256x256`, and pulse `512x128` canvases.
- The retained Relay Mantis source is a strict `887x1774` `3x6` sheet. Key
  `#fb03f9` processing produced `1,424,484` fully transparent and `65,464`
  partially transparent pixels. All eighteen poses use one normalization scale,
  exact transparent `96x96` canvases, and a common used-image bottom y `88`.
- Runtime animations are `idle`, `run`, `attack_tell`, `attack`, `hurt`, and
  `death`, exactly three continuous `_000.._002` frames each through
  `AnimatedSprite2D + SpriteFrames`. Source prompts, alpha intermediates,
  preview, runtime paths, asset spec, manifest, and entity inventory are all
  retained.
- Visual inspection found a readable broad combat floor, tall maintenance
  depth, distinct narrow Mantis silhouette, clear cyan relay and signal-red
  shutters, no magenta spill, no baked actor/text, and no visible primitive
  placeholder.

## Runtime Findings

- Story140 guard clear is the only prerequisite. Crossing x `1500` closes the
  authored shutters at x `1420/2440` and starts `0.55s / 0.18s / 0.55s`
  telegraph, strike, and recovery timing. A strike-lane miss routes exactly `8`
  electric damage; a real `parry` ability signal completes the relay once.
- Reflection wakes entity `2702` with data id
  `central_tower_relay_mantis`, `40` HP, `20/6/20` scythe-dash timing, `12`
  damage, and shared Health/Collision/Combat/StatusEffect components. Defeat
  immediately opens both shutters, disables the pulse, and exposes the cache.
- Before clear, the existing Threshold Roost/GameFlow path restores 50% HP and
  120 i-frames while resetting relay/Mantis attempt state, HP, authored
  position, hitboxes, and shutters. Defeat or cache claim reached during the
  death window remains durable and does not replay feedback after restore.
- Cache claim records the established `20 Gears` payload and
  `central_tower_inner_cache_claimed=true`; Story141 deliberately does not add
  or rebalance a global economy system and preserves the exact ability set.

## Godot MCP Evidence

- Session: `cinderpaw@e40d`; engine: Godot `4.7-stable (official)`; Godot AI
  MCP plugin/server: `2.9.1`.
- A forced disk reload opened `central_tower_threshold.tscn` with readiness
  `ready`. The editor hierarchy exposed `63` authored nodes, including both
  backgrounds, bounded collision, Story140 nodes, `InnerRelayController`, both
  shutters, relay, pulse, perch, cache, Relay Mantis, Player/Camera2D, HUD, and
  objective. The authored Mantis child is an `AnimatedSprite2D` using the exact
  SpriteFrames and character-script paths.
- Custom MCP fixture run token `65` became `live` with
  `current_run_errors=[]`. Before input, Player was at x `1800`, the pulse was a
  visible full-opacity strike, and Mantis was hidden/disabled.
- MCP sent one real `parry` project action. The pulse became hidden; Mantis
  became visible and active with collision layer/mask `2/17`, acquired runtime
  position near x `2113`, and its `AnimatedSprite2D` played `run` from the exact
  Story141 SpriteFrames resource.
- MCP filesystem inspection loaded the same `SpriteFrames` resource and found
  all six required animation names with three texture frames each. This is
  paired with the live runtime `AnimatedSprite2D` inspection rather than a
  file-only assumption.
- The non-empty `1278x718` RGB game capture clearly shows Cinderpaw, animated
  Relay Mantis, Service Spine background, relay, both generated shutters,
  readable objective and HUD without overlap. Evidence file:
  `reports/visual/cinderpaw-mcp-central-tower-inner-relay-run65-20260712.png`
  (`1,336,565` bytes; SHA-256
  `590e30a1d16cde2c530e7330108026becf237d693c53819ea9b457b5b607ab9b`).
- Current run id `r431937210-65` contains only helper registration and
  `enemy_stats` load info. Editor logger cursor `3` gained no rows. Retained
  project-run errors shown by MCP predate run 65 and are excluded from
  `current_run_errors`; the target scene, focused tests, smoke, and run 65 all
  load cleanly.
- MCP stopped run 65 cleanly and returned editor readiness to `ready`. A
  machine-readable summary is retained at
  `production/qa/evidence/central-tower-inner-relay-skirmish-mcp-run65.json`.

## Verdict

PASS. Story141 adds a generated-art, frame-animated, playable second Central
Tower viewport with real parry pressure, ordinary enemy combat, durable
death/retry state, one-shot reward, bounded regression evidence, and clean
current-run MCP validation.
