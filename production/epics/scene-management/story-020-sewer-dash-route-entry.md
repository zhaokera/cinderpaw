# Story 020: Sewer Dash Route Entry

> **Epic**: Scene Management
> **Status**: Complete
> **Layer**: Feature / Gameplay Integration
> **Type**: Gameplay / Traversal / Visual
> **Estimate**: M
> **Manifest Version**: 2026-07-19
> **Last Updated**: 2026-07-19

## Context

**GDD**: `design/gdd/exploration-ability-gating.md`,
`design/gdd/scene-management.md`, `design/gdd/game-concept.md`

**Requirements**: Dash-gated Commercial Street to Sewer route, physical
ability proof, deterministic local reset, registered scene round trip,
`TR-scene-001`, `TR-scene-004`

**ADR Governing Implementation**: ADR-0004: Collision architecture,
ADR-0007: Scene management architecture

Main's authored Dash gate already targeted `area_02_sewer`, but the registry and
runtime scene did not exist. This Story turns that dead gate into a short ACT
route: the player enters through the real gate, fails safely when trying to jump
through the exhaust channel, proves Dash across a real gap and returns to a
dedicated Main spawn. It does not bypass the GDD requirement that the later
Sewer-to-Factory route needs Double Jump.

**Engine**: Godot 4.7 | **Risk**: MEDIUM

## Acceptance Criteria

- [x] `area_02_sewer` is registered and loads
  `res://scenes/areas/sewer.tscn` through SceneManager from Main's existing
  Dash gate and a separate `SewerRouteEntry` body overlap.
- [x] Entry requires the production Player, an unlocked Dash gate and the real
  Dash ability; accepted transitions preserve unlocked abilities.
- [x] The Sewer uses an imported image-generated opaque `1280x720` background,
  separate collision and a real `92px` open floor gap with no hidden bridge.
- [x] The visible exhaust hazard uses the existing four-frame
  `AnimatedSprite2D + SpriteFrames`; a normal jump/contact or fall performs one
  local no-loss reset without requesting a scene transition.
- [x] Only a right-facing Dash started in the authored pre-gap band can complete
  the crossing. Success disables the hazard, switches it to `safe` and records
  one crossing.
- [x] Reaching the far exit after success returns once to
  `main/sewer_return`, aligns Cinderpaw with `SewerReturnSpawn` and persists
  `area_02_sewer_unlocked` plus `sewer_dash_route_crossed`; the previously
  opened Dash gate is restored immediately without another proximity pass.
- [x] Cinderpaw remains a production `AnimatedSprite2D`; its Dash animation has
  at least three frames and no visible block actor is introduced.
- [x] One intentional RED/GREEN acceptance, bounded related regression and one
  clean Godot MCP round trip verify physical inputs, scene nodes, screenshot
  and logs.

## Implementation Notes

- `SewerDashRoute` owns only route-local reset, Dash proof, hazard state and
  Main return state. Scene loading and residency remain SceneManager-owned.
- The generated plate supplies environment presentation only. `LeftPlatform`,
  `RightPlatform`, `FallZone`, `SewerExhaustHazard` and `ExitArea` own gameplay.
- The background generator did not retain a ceiling low enough to enforce the
  jump rule. The existing animated exhaust plume therefore supplies the visible
  and physical rejection volume instead of adding invisible ceiling collision.
- The return path intentionally goes back to Main. A direct Sewer-to-Factory
  exit is out of scope until the player has Double Jump.

## Thin TDD / Verification

- RED: one integration acceptance attempts Main entry, failed real jump, real
  Dash, exit and Main return before the Sewer scene exists.
- GREEN: add the registry entry, generated environment, authored geometry,
  route controller and Main entry/return contract.
- Related: Player Dash runtime, ExplorationGate Dash state, SceneManager tree
  swap, existing Factory round trip and Sewer audio mapping only.
- Runtime: one MCP run uses real `move_right`, `dash` and `jump` actions, then
  checks diagnostics, imported visuals, round trip, screenshot and logs.

## Out of Scope

- Sewer combat, collectibles, dialogue, tutorial text or a new enemy.
- Double Jump acquisition or the Sewer-to-Factory route.
- Player Dash balance, animation replacement or full Main progression replay.

## Dependencies

- Depends on: Scene Management Stories001-007 and Player Abilities Dash/gate
  runtime.
- Reuses: Player, HUD, CombatPresentation, HitstopInputBridge, ExplorationGate,
  SceneManager and Old Factory steam-vent SpriteFrames.

## Test Evidence

- Intentional RED: `reports/report_1974/report_1/results.xml` executed the single
  Story020 acceptance and failed because `res://scenes/areas/sewer.tscn` did not
  exist.
- Focused GREEN: `reports/report_1976/report_1/results.xml` passed `1/1`, zero
  errors/failures/flaky/skips/orphans and exit `0` after the Godot import pass.
- Bounded related GREEN: `reports/report_1977/report_1/results.xml` passed six
  suites and `35/35` tests with zero errors, failures, flaky cases, skips or
  orphans and exit `0`. No full suite was run.
- Runtime-discovered regression RED: `reports/report_1978/results.xml` failed
  the new returned-Gate assertion only because `world_flags` were assigned after
  Gate synchronization.
- Post-fix focused GREEN: `reports/report_1979/results.xml` passed `1/1`, zero
  errors/failures/flaky/skips/orphans and exit `0` after restoring flags before
  Gate synchronization.
- Godot 4.7 / Godot AI MCP 3.0.2 accepted run `r294836394-94` (token `94`).
  Physical Main movement plus Dash entered Sewer; a physical jump caused one
  `exhaust` reset; the next physical Dash crossed once; physical movement then
  returned to `main/sewer_return` at `0px` spawn error. The `1278x718`
  screenshot was non-empty, game output had three info lines, editor errors
  were empty and the editor stopped in `ready`.
- Post-fix MCP run `r295492330-95` (token `95`) restored the completed route at
  `735px` from the Dash gate and proved `unlocked`, collision disabled and Dash
  retained without a proximity refresh. Logs were info-only, editor errors were
  empty and stop returned `ready`.
- Detailed evidence:
  `production/qa/evidence/sewer-dash-route-entry-2026-07-19.md`.
