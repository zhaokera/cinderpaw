# Story 132: Underground Recovery Cistern Savepoint Traverse

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Core / Gameplay Runtime / Scene Management / Save and Respawn / Visual
> **Type**: Integration + Gameplay Runtime + Traversal + Save/Respawn + Visual
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-11

## Context

**GDD**: `design/gdd/health-death.md`, `design/gdd/death-respawn.md`,
`design/gdd/save-system.md`, `design/gdd/scene-management.md`,
`design/gdd/exploration-ability-gating.md`, `design/gdd/player-abilities.md`,
`design/art/art-bible.md`

**Requirements**: `TR-respawn-001`, `TR-respawn-002`, `TR-respawn-005`,
`TR-respawn-006`, `TR-save-006`, `TR-save-007`, `TR-scene-004`

**ADR Governing Implementation**: ADR-0002 Signal Communication; ADR-0004
Collision Detection; ADR-0007 Scene Management; ADR-0018 Player Abilities;
ADR-0019 Health Component; ADR-0021 Save System.

Story131 secures the first Underground combat channel but leaves no fair recovery
anchor or deeper traversal payoff. Story132 adds one third viewport that the
player can run through immediately after the clear: activate a visible recovery
relay, cross a platform gap with a lethal fall zone, and secure the deep-route
endpoint. Falling after relay activation exercises the real death delay,
savepoint selection, 50% HP revive, invincibility window, and no-loss state
contract in live Underground gameplay.

## Acceptance Criteria

- [x] `underground_passage.tscn` expands from `2560x720` to a bounded
  `3840x720` route with a third opaque generated background, Camera2D limit
  `0..3840`, the Story130/131 nodes unchanged, an approach ledge, three readable
  stepping platforms over a real gap, an exit ledge, and a right wall at the new
  route bound.
- [x] New recovery-cistern behavior is owned by a dedicated
  `UndergroundRecoveryCisternController` child and script. The existing
  `UndergroundPassageScene` only configures it, merges its durable state, exposes
  nested diagnostics, and applies SceneManager spawn alignment.
- [x] The image-generated recovery relay uses `SavepointRuntime` with stable id
  `underground_recovery_cistern_relay`, scene id
  `area_04_underground_passage`, and spawn point `recovery_cistern_relay`. It is
  unavailable before the corrosion channel is clear and rejects distant,
  locked, or duplicate activation.
- [x] A nearby relay activation succeeds once, restores Cinderpaw to full HP
  through a public player/HealthComponent path, records the last savepoint,
  dispatches shared savepoint audio/VFX feedback, triggers slot-0 autosave
  through `SaveTriggerAdapter`, and updates the objective to
  `Cross Recovery Cistern`.
- [x] Entering the authored fall zone applies lethal damage through the public
  player health path. `GameFlowController` holds the 1.5 second death beat,
  selects the recovery relay, respawns Cinderpaw at it with 50% HP, and retains
  the 2.0 second revived control-lock/invincibility contract before returning to
  normal play.
- [x] Death and revive preserve unlocked abilities, Story131 encounter/cache
  state, and the recovery relay activation without duplicating its autosave,
  audio, or VFX. The Factory return route remains repeatable after revive.
- [x] Reaching the far-side generated route endpoint is accepted only after the
  relay is active, persists
  `underground_recovery_cistern_traversed=true`, disables repeat activation, and
  updates the objective to `Recovery Cistern Secured`.
- [x] `get_local_state()` / `set_local_state()` persist relay activation, last
  savepoint metadata, traversal completion, and unlocked abilities. Loading or
  entering through spawn point `recovery_cistern_relay` aligns Cinderpaw to the
  authored relay marker without replaying one-shot feedback.
- [x] The recovery-cistern background, relay, and endpoint visuals are produced
  through built-in image generation, retain source/alpha files as appropriate,
  import through Godot 4.7, and are recorded in an asset spec, generation
  records, manifest, inventory, and QA evidence.
- [x] One focused RED/GREEN suite, a bounded Story130/131 plus death/save related
  regression set, one targeted SceneManager headless smoke, and one Godot MCP
  2.9.1 runtime pass complete with clean current-run logs and non-empty
  screenshots showing the relay, platform gap, Cinderpaw, and deep endpoint.

## Out of Scope

- New enemy families, a second combat wave, Boss4, new player abilities, new
  character frames, replacement of existing Cinderpaw/Sluice Leech animations,
  or combat balance changes.
- A new registered area scene, fast-travel menu, minimap marker UI, save schema
  migration, manual save UI, new Autoload, or full Underground biome production.
- Dynamic liquid simulation, shaders, particles, authored music/SFX files, or a
  generalized level-streaming framework.

## Implementation Notes

- Keep the third viewport in `area_04_underground_passage`; do not add a new
  scene-registry entry for this slice.
- Put relay, fall-zone, endpoint, death/respawn, autosave, audio, and diagnostics
  ownership in `src/gameplay/underground_recovery_cistern_controller.gd`.
- Reuse `SavepointRuntime`, `GameFlowController`, `SaveTriggerAdapter`, and the
  existing player `AnimatedSprite2D + SpriteFrames` death/revive contract.
- Add a narrow public `PlayerController.restore_at_savepoint()` adapter instead
  of reaching into its private HealthComponent from scene code.
- The relay sits before the gap so a normal route attempt activates a fair retry
  point. The fall-zone visual is communicated by the generated background and
  authored gap geometry; it is not a new visible character.
- Parallel level/art/QA sidecars were attempted twice for planning, but the
  backend forced unsupported `reasoning.effort=max` before execution. Their
  review scopes are being completed by the integrating agent.

## Engine, Manifest, and Performance Notes

- Godot `4.7-stable` and Godot AI MCP `2.9.1` are authoritative. Scene,
  collision, import, runtime log, node visibility, and screenshot checks are
  required after implementation.
- Follow the Core/Feature control-manifest rules: typed signals for cross-node
  events, Godot physics collision layers for the fall zone, scene-local durable
  state serialized through SceneManager/SaveSystem adapters, and no new
  Autoload or direct global-state ownership.
- The third viewport adds only static bodies, one Area2D fall trigger, two
  interaction nodes, and one disabled-when-idle flow controller. It must not add
  per-frame allocations or move the project beyond the existing `16.6ms` frame
  budget; MCP monitor inspection is sufficient for this bounded slice.

## Implementation Plan

1. Create the focused GdUnit file first with three grouped acceptance tests and
   run only that file to capture the expected RED state.
2. Generate the background, relay, and endpoint source images; chroma-key the
   two props, normalize exact runtime dimensions, inspect them, and import them
   through Godot 4.7.
3. Add `UndergroundRecoveryCisternController`, its savepoint/fall/endpoint
   scene nodes, and the narrow player health adapter; keep parent integration to
   configuration, state merge, diagnostics, objective, and spawn alignment.
4. Reach focused GREEN, then add one SceneManager smoke and run only Story130,
   Story131, death/respawn, savepoint, and Story132 related regressions.
5. Complete asset/spec/manifest/inventory/evidence records and verify the live
   scene through Godot MCP before story close-out and commit.

## QA Test Cases

- **AC-1: Authored route, assets, and controller boundary**
  - Given: the expanded scene and generated assets are imported.
  - When: the scene and recovery diagnostics are loaded.
  - Then: bounds, ledges, platforms, fall zone, relay, endpoint, texture paths,
    and dedicated controller ownership match authored values.
- **AC-2: Relay activation and deterministic autosave**
  - Given: Story131 is cleared and Cinderpaw is damaged.
  - When: the nearby relay is activated through `SavepointRuntime`.
  - Then: HP restores fully, one last-savepoint snapshot is recorded, one
    autosave/audio/VFX request is dispatched, and duplicate/distant calls fail.
- **AC-3: Fall death, no-loss revive, endpoint, and restore**
  - Given: the relay is active and durable state is captured.
  - When: Cinderpaw enters the fall zone, the death flow advances, then the
    player reaches the endpoint and a fresh scene restores state.
  - Then: the player revives at the relay with 50% HP, progress and abilities
    remain, control unlocks after the revive window, endpoint completion persists,
    and one-shot feedback does not replay.

## Test Evidence

**Required evidence**:

- `tests/unit/gameplay/underground_recovery_cistern_savepoint_traverse_test.gd`
- `tests/smoke/underground_recovery_cistern_savepoint_traverse_smoke.gd`
- `production/qa/evidence/underground-recovery-cistern-savepoint-traverse-2026-07-11.md`

**Status**: [x] Complete. See the QA evidence file above and final reports
`report_1445`, `report_1446`, plus the targeted SceneManager smoke log.

## Dependencies

- Depends on: Story131 Underground Corrosion Channel Skirmish. Complete.
- Unlocks: Story133 deep Underground encounter or scene handoff from the secured
  recovery-cistern endpoint.
