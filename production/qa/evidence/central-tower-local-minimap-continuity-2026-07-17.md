# Central Tower Local Minimap Continuity Evidence

> **Story**: Player Abilities 171
> **Date**: 2026-07-17
> **Verdict**: PASS

## Delivered Contract

- The existing `120x120` HUD minimap now displays Tower Threshold, Service
  Spine, Cooling Shaft, Deep Lift and Apex Conduit as one forward-connected,
  shape-readable route.
- Player X selects the current authored `1280px` segment and drives local
  marker progress. Backtracking therefore highlights the player's real segment
  instead of the furthest completed segment.
- The four deeper nodes derive discovery from Story140-143 durable progression
  keys. Live progress uses the existing one-second reveal and notification;
  restoration is immediate and silent.
- No map asset, save field, Autoload or gameplay route state was added.

## Automated Evidence

- RED `reports/report_1872/report_1/results.xml`: the single acceptance case
  failed only because Tower had no minimap diagnostics/runtime connection.
- `report_1873` then caught one integration defect: controller restore signals
  replayed `Apex Conduit discovered`. A scene-local restore guard changed those
  callbacks to immediate synchronization while retaining live reveal feedback.
- Focused GREEN `reports/report_1874/report_1/results.xml`: `1/1` passed with
  zero errors, failures, flaky cases, skips or orphans.
- Post-review focused `reports/report_1877/report_1/results.xml`: `1/1` passed
  after replacing the test's private callback with the real controller signal
  path and adding exact `1280`, left-clamp and right-clamp assertions.
- Final bounded GREEN `reports/report_1875/report_1/results.xml`: `6/6` passed
  across Story171, Story152 Main minimap and Story140 Tower Threshold coverage;
  exit code `0`.
- Story140's older direct `Image.load(res://...)` asset checks still print their
  known export warnings. The multi-suite runner also prints its existing exit
  resource diagnostics after reporting success; Story171 focused runs do not.

## MCP Evidence

Session `cinderpaw@af5f`, Godot `4.7-stable`, Godot AI MCP `3.0.2`, run
`r184502199-54`:

- `central_tower_threshold.tscn` was force-reloaded from disk and launched with
  helper live and `current_run_errors=[]`;
- the runtime tree contained
  `HUD/HudRoot/MinimapHudPanel/MinimapWidget`, Player and Camera2D;
- initial diagnostics reported a visible `120x120` panel, five exact route
  nodes, Threshold current/discovered and the four deeper nodes hollow;
- changing the real guard durable state and placing the player at `x=1600`
  selected Service Spine, normalized local X to `0.25`, started one reveal and
  displayed `Service Spine discovered`;
- restoring all four durable keys and placing the player at `x=5760` selected
  Apex Conduit, restored all five nodes at progress `1.0`, left no active
  reveal or notification, and confirmed no `central_tower_explored_segment_max`
  field exists;
- the `1278x718` screenshot visibly contains Cinderpaw, the Service Spine
  encounter, all five minimap nodes, distinct current/player shapes and no HUD
  overlap;
- game logs contained two info rows only; editor logs contained zero rows; stop
  returned the editor to `ready`.

## Screenshot

- Runtime capture:
  `reports/visual/cinderpaw-mcp-central-tower-local-minimap-continuity-20260717.png`
- Dimensions: `1278x718`, RGB PNG.
- SHA-256:
  `2c2a2afe4e0a2faf4cd3a6426408b0e3e85d0f2f75a132005187bb5be67f16aa`

## Scope Note

No full map, map rotation, marker atlas, fast travel, Tower geometry, combat,
camera, collision, balance, save schema or Story140-145 route behavior changed.
