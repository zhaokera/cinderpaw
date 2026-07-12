# QA Evidence: Central Tower Cooling Shaft Roost Traverse

## Scope

Story142 expands `area_05_central_tower` to a bounded `3840x720`,
three-viewport ACT area. The generated Cooling Shaft adds one recovery Roost,
one lethal traversal gap, two collision-backed magnetic spines, a one-way
perch, a deterministic electrical arc, and one durable Deep Lift endpoint. It
reuses Cinderpaw's existing movement/animation states and does not define a new
enemy, ability, scene id, or Boss4 content.

## Automated Evidence

- Expected RED `reports/report_1510/results.xml` exited `100` before the
  Story142 controller, generated assets, scene nodes, and expanded bounds
  existed.
- `report_1511` exposed one script indentation error plus pending Godot texture
  imports. A clean Godot 4.7 headless import resolved the resource cache.
- `report_1512` narrowed the remaining failures to binary spine alpha and a
  test that waited one physics frame after synchronous revive. The spine matte
  was feathered; the assertion now reads the exact 120 i-frame grant before a
  legitimate physics decrement.
- Final focused GREEN `reports/report_1513/results.xml` passed `3/3` with zero
  failures, errors, skipped, flaky, or orphan cases. Coverage includes exact
  asset contracts, scene geometry, Story141 gate, one-shot Roost/autosave,
  hazard timing/damage/cooldown, lethal fall, revive, endpoint, exact abilities,
  and fresh restore without feedback replay.
- Adjacent regression `reports/report_1514/results.xml` passed `10/10`: Story141
  `3/3`, Story140 `3/3`, and savepoint selection `4/4`, all with zero failures,
  errors, skipped, flaky, or orphan cases.
- Target headless smoke exited `0` with marker
  `central_tower_cooling_shaft_roost_traverse_smoke=passed`. It covered Story141
  clear, Roost heal/autosave, active-arc damage and cooldown, lethal fall and
  revive, real double-jump/dash APIs and animations, endpoint completion, and
  fresh restore without replay.
- GdUnit's direct `Image.load` cases retain Godot's standard export warning;
  passing headless tests retain existing shutdown resource-cleanup noise. The
  cited final commands all exited `0`, and final MCP current-run logs are clean.

## Asset Evidence

- Image generation produced and retained the opaque environment source and its
  exact prompt at
  `assets/generated/source/central_tower_cooling_shaft_background_imagegen_20260712.*`.
  The runtime background is exact RGB `1280x720`.
- A retained keyed `3x2` image-generation sheet, transparent alpha
  intermediate, and exact prompt produced six isolated runtime assets: Roost
  `256x256`, spine `256x512`, perch `384x128`, endpoint `256x384`, arc
  `512x160`, and contact spark `192x192`.
- Godot 4.7 imported every source, alpha, runtime, scene, script, test, and
  fixture resource. Exact dimensions, alpha channels, transparent corners, and
  required player animation counts are asserted in `report_1513`.
- Visual inspection found no magenta spill, baked actor/text, opaque keyed
  rectangle, primitive debug block, or Boss-arena composition. The generated
  shaft remains readable behind the authored collision and interaction layer.

## Runtime Findings

- `central_tower_relay_mantis_defeated=true` unlocks the third viewport; cache
  claim remains optional. The Roost at `(2740,576)` records spawn
  `(2740,552)`, restores full HP, dispatches established audio/VFX, requests one
  slot-zero autosave, and becomes the newest Tower respawn anchor.
- The gap spans x `2920..3480`; magnetic spines at x `3060/3390` and a one-way
  perch at `(3225,438)` use existing jump, double-jump, dash, wall-climb, fall,
  hurt, and revive states through Cinderpaw's `AnimatedSprite2D + SpriteFrames`.
- Arc `central_tower_cooling_shaft_arc` cycles
  `0.75/0.50/0.35/0.70s` grace/warning/active/safe. Only active overlap routes
  `10` damage through PlayerController, with a `1.0s` same-target cooldown.
- A lethal gap fall uses the existing `1.5s` Tower GameFlow death beat, revives
  at the Cooling Roost with 50% HP and 120 i-frames, and preserves Story140/141
  clears, optional cache state, Roost state, and exact abilities.
- Endpoint `central_tower_cooling_shaft_endpoint` persists
  `central_tower_cooling_shaft_traversed=true`, disables repeat hazard feedback,
  and reports `Cooling Shaft Secured`. Fresh restore rehydrates prerequisites
  without replaying Roost, autosave, audio, VFX, or endpoint feedback.

## Godot MCP Evidence

- Session `cinderpaw@e40d`; Godot `4.7-stable (official)`; Godot AI MCP
  plugin/server `2.9.1`.
- Initial run `66` exposed a live-editor class-cache issue: the cache contained
  `288` classes but none of the new `CentralTower*` classes. After stopping the
  run and reimporting the four Tower scripts, MCP scanned `292` global classes;
  exploratory run `67` and final run `68` loaded the target fixture normally.
- Final run token `68`, id `r436604459-68`, exposed `94` authored and `128`
  runtime nodes with `current_run_errors=[]`. Editor logger cursor `3` gained no
  rows. MCP's retained recent-error list includes old pre-run Old Factory rows
  and the resolved run-66 cache failure; they are not current-run errors.
- Runtime diagnostics reported route width `3840`, unlocked route, active
  Roost, active arc with `0.33s` remaining, objective `Cross Cooling Shaft`,
  player `(3225,402)`, latest savepoint `(2740,552)`, and the exact five
  existing movement/combat abilities.
- MCP node inspection confirmed the generated Roost, arc, and endpoint textures
  are visible at their exact runtime paths. Cinderpaw's live Player/Sprite is an
  `AnimatedSprite2D` using
  `res://assets/characters/cinderpaw/cinderpaw_sprite_frames.tres`.
- MCP sent real `jump` input and observed animation `jump`, frame `1`. It then
  sent real `dash` input and moved Cinderpaw from x `3225` to x `3353.924`,
  approximately `129px`.
- The same run captured a non-empty `1278x718` RGB gameplay frame showing
  Cinderpaw, activated Roost, both magnetic spines, mid perch, visible arc,
  Deep Lift endpoint, objective, and HUD without incoherent overlap:
  `reports/visual/cinderpaw-mcp-central-tower-cooling-shaft-run68-20260712.png`
  (`1,336,522` bytes; SHA-256
  `8eceae0dc68ff1d197830693650d7e2f66e118dcc95c9c0adbf90ae5c3d9a124`).
- Run `68` produced exactly five expected info/probe lines, stopped cleanly, and
  returned editor readiness to `ready`. Machine-readable evidence is retained
  in `central-tower-cooling-shaft-roost-traverse-mcp-run68.json`.

## Verdict

PASS. Story142 delivers a generated-art, playable post-combat recovery and
movement slice with deterministic hazard pressure, durable save/respawn state,
real player input evidence, focused regressions, and clean current-run MCP
validation.
