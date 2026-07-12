# Story 138: Neon Rooftops Relay Spire Savepoint Traverse

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Core / Gameplay Runtime / Scene Management / Save and Respawn / Visual
> **Type**: Integration + Gameplay Runtime + Traversal + Save/Respawn + Visual
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-12

## Context

**GDD**: `design/gdd/game-concept.md`,
`design/gdd/exploration-ability-gating.md`, `design/gdd/player-abilities.md`,
`design/gdd/health-death.md`, `design/gdd/death-respawn.md`,
`design/gdd/save-system.md`, `design/gdd/scene-management.md`,
`design/gdd/audio-system.md`, `design/art/art-bible.md`

**Requirements**: `TR-explore-001`, `TR-respawn-001`, `TR-respawn-002`,
`TR-respawn-005`, `TR-respawn-006`, `TR-save-006`, `TR-save-007`,
`TR-scene-004`

**ADR Governing Implementation**: ADR-0002 typed signals; ADR-0004 collision
detection; ADR-0007 scene persistence; ADR-0018 player abilities; ADR-0019
HealthComponent; ADR-0021 SaveSystem.

Story137 completes the first rooftop fight and reward, but there is no fair
retry anchor or traversal payoff beyond the Signal Roof. The game-concept GDD
defines the short loop as combat, resource, shortcut/savepoint, then the next
challenge. Story138 adds exactly that follow-through in a third viewport: claim
the Signal Cache, activate a rooftop roost savepoint, cross a lethal gap by
climbing a magnetic relay spire with the existing `wall_climb` ability, and
secure a visible Tower Approach endpoint.

Central Tower still requires parry plus every prerequisite area. This story
reaches only its distant approach and does not register, unlock, or enter the
Tower. Boss4 remains undefined and out of scope.

## Design Decision

- **Selected**: one post-combat savepoint and one physical wall-climb traverse
  in the same `area_05_neon_rooftops` scene. This completes the GDD loop while
  reusing proven SavepointRuntime, GameFlowController, and player animations.
- **Selected**: the Story137 cache claim opens a reused signal seal at x `2580`.
  This keeps the reward meaningful and prevents entry into an inactive screen.
- **Rejected**: another immediate enemy. Story137 already supplies the combat
  beat; recovery and ability traversal improve pacing more than another wave.
- **Rejected**: Central Tower handoff or Boss4. Neither has an approved runtime
  contract in the current documents.

Three read-only level/Godot/QA sidecars were dispatched, but the backend changed
their supported effort to invalid `reasoning.effort=max` before execution. The
bounded design, architecture, and acceptance review therefore continues locally
without another retry.

## Acceptance Criteria

- [x] `neon_rooftops_entry.tscn` expands from `2560x720` to a bounded
  `3840x720` route with a third opaque generated background, Camera2D limit
  `0..3840`, full-width top boundary, right wall at x `3820`, an approach roof,
  visible magnetic relay spire over real collision, two one-way perches, a
  lethal gap, an exit roof, and every Story136-137 node preserved.
- [x] A dedicated `NeonRelaySpireController` owns route access, savepoint, fall,
  respawn, endpoint, objective, and durable state. The parent rooftop script
  only configures adapters, merges state, captures save/no-loss snapshots,
  exposes narrow methods/diagnostics, aligns the savepoint spawn, and delegates
  objective priority.
- [x] Story137 cache claim is the only route prerequisite. Before claim, a reused
  generated signal seal blocks x `2580` and relay/spire interactions are locked.
  Claiming the cache opens the seal without replaying Story137 feedback.
- [x] The generated Relay Spire Roost uses `SavepointRuntime` with stable id
  `neon_rooftops_relay_spire_roost`, scene id `area_05_neon_rooftops`, and spawn
  point `relay_spire_roost`. Nearby first activation restores full HP, records
  the latest savepoint, requests shared savepoint audio/VFX, and triggers one
  slot-0 autosave through `SaveTriggerAdapter`; duplicate/distant attempts fail.
- [x] The generated magnetic spire overlays authored StaticBody2D wall collision.
  Existing Cinderpaw wall contact, climb, wall jump, and three-frame
  `wall_climb` animation are used unchanged to reach the upper perch.
- [x] The authored fall Area2D becomes lethal only after the roost is active.
  `GameFlowController` holds the existing `1.5s` death beat, respawns at the
  roost with `50%` HP, and preserves the `2.0s` revived control lock and
  invincibility window before returning to play.
- [x] Entering the generated Tower Approach endpoint is accepted only after the
  roost is active and Cinderpaw reaches the exit side. It persists
  `neon_rooftops_relay_spire_traversed=true`, rejects duplicates, and advances
  the objective to `Tower Approach Reached` without unlocking Central Tower.
- [x] Death/revive and `get_local_state()` / `set_local_state()` preserve
  Story136 traversal, Story137 encounter/cache, unlocked abilities, roost
  activation, latest savepoint, and endpoint completion without duplicating
  autosave, audio, VFX, enemy, cache, or endpoint feedback.
- [x] Loading or entering with spawn point `relay_spire_roost` aligns Cinderpaw
  to the authored marker and zeroes velocity. The Factory return route remains
  repeatable after roost activation, death, and endpoint completion.
- [x] Background, roost, spire, and endpoint visuals are generated with built-in
  image generation, retain source/alpha/processing records, import in Godot 4.7,
  and are recorded in asset spec, manifest, inventory, and QA evidence.
- [x] One focused RED/GREEN suite, one bounded Story137-138 regression, one
  targeted headless savepoint/traversal smoke, and one Godot MCP 2.9.1 pass
  verify collision, real movement/wall climb, death/revive, logs, generated
  assets, key node visibility, and a non-empty gameplay screenshot. Do not run
  the full suite.

## Out of Scope

- Central Tower scene/registry entry/unlock, laser-net parry gate, Boss4, Boss4
  arena/config/reward, new enemy, second wave, miniboss, fast travel, minimap,
  secret room, NPC, merchant, quest, or narrative cutscene.
- New ability, new player frame animation, wall stamina, wall combat, ledge grab,
  moving magnetic walls, dynamic navigation, or player balance changes.
- New music/SFX files, shaders, complex particles, save schema migration, manual
  save UI, new Autoload, or generalized traversal/savepoint framework.

## Implementation Notes

- Keep the third viewport at scene x `2560..3840`; generated background art is
  the only visible environment surface while collision stays invisible.
- Place the access seal at x `2580`, roost near x `2730`, lethal gap at
  x `2860..3460`, magnetic spire near x `3180`, upper perch near x `3300`,
  exit roof from x `3460`, and endpoint near x `3680`.
- Reuse `SavepointRuntime`, `SaveTriggerAdapter`, `GameFlowController`, shared
  savepoint audio, existing unlock spark VFX, and public PlayerController health,
  respawn, control-lock, wall-contact, and ability APIs.
- Keep all Story138 state under `neon_rooftops_relay_spire_*` keys. JSON snapshots
  must store Vector2 values as `{x, y}` dictionaries.

## Engine, Manifest, and Performance Notes

- Godot `4.7-stable` and Godot AI MCP `2.9.1` are authoritative.
- The slice adds static collision, one savepoint, one fall Area2D, one endpoint,
  and one disabled-when-idle GameFlowController. No navigation, polling tree
  searches, per-frame JSON parsing, or new always-on effects.
- Scene/script/resource edits require one final MCP scene, runtime, log, input,
  and screenshot pass after focused automation is green.

## Implementation Plan

1. Add three focused GdUnit cases and capture the expected RED result.
2. Generate one opaque third-screen background and one keyed three-prop sheet;
   normalize background, roost, spire, and endpoint runtime PNGs and import them.
3. Add the dedicated controller and authored scene nodes, then wire the parent
   through narrow runtime, state, snapshot, objective, and spawn adapters.
4. Reach focused GREEN, run Story137-138 once, add one targeted headless smoke,
   then perform one final Godot MCP runtime pass.
5. Complete source records, asset spec, manifest/inventory, QA evidence, Story,
   Epic, and session-state updates.

## QA Test Cases

- **AC-1: Third viewport, generated art, and controller boundary**
  - Given: Story138 files are present.
  - When: the scene, controller, background/props, collision, bounds, and
    diagnostics are inspected.
  - Then: exact paths, dimensions, alpha, geometry, access seal, spire, gap,
    endpoint, camera/right-wall values, and dedicated ownership match contract.
- **AC-2: Route gate and one-shot savepoint**
  - Given: Story137 state before and after Signal Cache claim.
  - When: Cinderpaw approaches and activates the roost while damaged.
  - Then: locked/distant calls fail, route opens after claim, HP fully restores,
    latest savepoint is valid, and autosave/audio/VFX occur exactly once.
- **AC-3: Fall revive, traversal endpoint, and deterministic restore**
  - Given: active roost and wall-climb ability.
  - When: Cinderpaw falls, advances through death/revive, reaches the endpoint,
    and a fresh scene restores captured state.
  - Then: 50% roost revive, 2s lock, no-loss state, wall-climb route, endpoint
    completion, Factory return, and no-replay counts remain correct.

## Test Evidence

**Required evidence**:

- `tests/unit/gameplay/neon_rooftops_relay_spire_savepoint_traverse_test.gd`
- `tests/smoke/neon_rooftops_relay_spire_savepoint_traverse_smoke.gd`
- `production/qa/evidence/neon-rooftops-relay-spire-savepoint-traverse-2026-07-12.md`

**Status**: [x] Complete. RED `report_1484`; focused GREEN `report_1485`
(`3/3`); final Story137-138 GREEN `report_1487` (`6/6`); targeted headless
smoke marker `neon_rooftops_relay_spire_savepoint_traverse_smoke=passed`;
Godot MCP run `55` verified the 87-node authored scene, 145-node runtime, exact
generated textures, real-input `wall_climb` frame `1`, readable 1278x718
gameplay capture, `current_run_errors=[]`, helper/data/fixture-only game logs,
and no new editor rows after cursor `3`.

## Dependencies

- Depends on: Story137 Neon Rooftops Signal Rat Ambush. Complete.
- Unlocks: a future parry/all-prerequisites Central Tower gate story or another
  bounded rooftop branch. Boss4 still requires its own approved contract.
