# Story 139: Neon Rooftops Central Tower Parry-Laser Trial

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Core / Gameplay Runtime / Exploration Gate / Visual
> **Type**: Integration + Gameplay Runtime + Parry Timing + Visual
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-12

## Context

**GDD**: `design/gdd/game-concept.md`,
`design/gdd/exploration-ability-gating.md`, `design/gdd/player-abilities.md`,
`design/gdd/health-death.md`, `design/gdd/death-respawn.md`,
`design/gdd/scene-management.md`, `design/gdd/audio-system.md`,
`design/gdd/combat-presentation.md`, `design/art/art-bible.md`

**Requirements**: `TR-explore-001`, `TR-explore-002`, `TR-explore-006`,
`TR-ability-003`, `TR-input-006`, `TR-respawn-001`, `TR-respawn-002`,
`TR-respawn-005`, `TR-scene-004`

**ADR Governing Implementation**: ADR-0001 Autoload architecture; ADR-0002
typed signals; ADR-0004 collision detection; ADR-0005 combat state machine;
ADR-0007 scene persistence; ADR-0018 player abilities; ADR-0019
HealthComponent; ADR-0021 SaveSystem.

The exploration GDD defines the Central Tower gate as a laser net requiring
`parry` plus all prerequisite areas. Story138's Tower Approach endpoint is the
end of the implemented sequential route through Factory, Underground Passage,
Factory Upper Altar, and Neon Rooftops, so its durable traversed flag is the
bounded proof that the current prerequisite chain is complete.

There is no approved Central Tower interior, Boss4 configuration, or Boss4
encounter contract. Story139 therefore builds the player-visible outer gate
challenge only: enter a fourth rooftop viewport, read a telegraphed laser pulse,
perform three real parries, survive misses through the existing health and
roost-respawn loop, then secure the threshold without changing scene.

## Design Decision

- **Selected**: a three-pulse timing trial in the existing Neon Rooftops scene.
  It makes the GDD's laser-net gate playable and exercises the real player
  `parry` input, cooldown, animation, damage, death, revive, audio, and VFX.
- **Selected**: Story138's traversed state is the route prerequisite. Reaching
  it already implies the implemented prerequisite chain; adding disconnected
  global completion flags here would duplicate progression ownership.
- **Selected**: retain `ExplorationGate` for its locked/unlockable/unlocked
  collision and presentation contract, but let the dedicated trial controller
  open it only after three timed reflections rather than the first activation.
- **Rejected**: creating Central Tower interior or Boss4. Current GDD/JSON has
  no encounter data to implement those honestly.
- **Rejected**: another ordinary enemy ambush. A timing trial advances the
  missing ACT mechanic and gives the rooftop sequence a distinct final beat.

Three read-only level/art/QA sidecars were dispatched with supported `high`
effort, but the backend rewrote all three requests to invalid
`reasoning.effort=max` before execution. They were closed without retries; the
bounded design, art, and QA review continues locally.

## Acceptance Criteria

- [x] `neon_rooftops_entry.tscn` expands from `3840x720` to a bounded
  `5120x720` route with a fourth opaque generated background, full-width top
  boundary, Camera2D limit `0..5120`, right wall at x `5100`, collision-backed
  trial floor, visible laser assembly, trial Area2D, tower gate collision, and
  threshold endpoint while preserving every Story136-138 node.
- [x] A dedicated `NeonTowerParryTrialController` owns route access, pulse
  timing, parry success, miss damage, tower gate state, threshold completion,
  objective priority, durable state, presentation counts, and diagnostics. The
  parent rooftop script only configures it, delegates narrow APIs, merges state,
  persists progress, and selects the objective.
- [x] Story138 `neon_rooftops_relay_spire_traversed=true` is the only route
  proof. Before it, a reused generated seal blocks x `3860`; afterward the
  fourth screen is open and the laser trial can activate only for a nearby
  provider that owns `parry`.
- [x] The authored trial uses exported timing/damage values: `0.60s` telegraph,
  `0.18s` strike window, `0.55s` recovery, three required reflections, and
  `18` miss damage. The laser pulse has readable idle/telegraph/strike/
  reflected/recovery visual states and deterministic diagnostics.
- [x] A real `PlayerController.request_parry()` or `parry` input during the
  strike window records exactly one reflection, plays the existing three-frame
  `parry` animation, requests shared perfect-parry audio/VFX feedback, and
  cannot double-count the same pulse. Early, late, distant, wrong-ability, and
  cooldown-rejected activations do not count.
- [x] An unreflected strike routes `18` damage through PlayerController. Lethal
  misses are handled by the existing Story138 `GameFlowController`, revive at
  the active Relay Spire Roost with `50%` HP, retain the `2.0s` control lock,
  and preserve no-loss trial progress.
- [x] The third valid reflection permanently unlocks the `ExplorationGate`,
  disables tower-gate collision, requests shared gate-unlock audio/VFX once,
  and advances the objective to `Enter Central Tower Threshold`.
- [x] Entering the generated threshold endpoint is accepted once after gate
  unlock, persists `neon_rooftops_central_tower_threshold_secured=true`, and
  displays `Central Tower Gate Secured` without registering or entering a
  Central Tower scene.
- [x] `get_local_state()` / `set_local_state()` and the no-loss death loop
  preserve Story136-138 state, unlocked abilities, reflection count, open gate,
  and threshold state without replaying pulse, parry, gate, endpoint, audio, or
  VFX feedback.
- [x] The fourth background, laser-gate assembly, laser pulse, and endpoint
  beacon are produced with built-in image generation, retain source/alpha/
  processing records, import in Godot 4.7, and are recorded in asset spec,
  manifest, inventory, and QA evidence.
- [x] One focused RED/GREEN suite, one bounded Story138-139 regression, one
  targeted headless smoke, and one Godot MCP `2.9.1` pass verify real parry
  input, miss damage, death/revive, collision, persistence, logs, generated
  assets, key nodes, and a non-empty gameplay screenshot. Do not run full suite.

## Out of Scope

- Central Tower scene/registry/schema entry, tower interior, scene handoff,
  Boss4 config/arena/phases/reward, final boss, ending, credits, cutscene, NPC,
  quest, minimap, fast travel, secret room, or another enemy.
- New ability, parry balance changes, player frame generation, wall-climb
  changes, weapon changes, new Health/Combat/Collision framework, new Autoload,
  save schema migration, or global progression manager.
- New music/SFX files, complex shader, dynamic lighting, procedural level,
  navigation, moving platform, or generalized laser-trial framework.

## Implementation Notes

- Keep the fourth viewport at scene x `3840..5120`. Place the route seal near
  x `3860`, trial activation around x `4300`, pulse lane around x `4480`, tower
  gate near x `4740`, endpoint near x `4970`, and right wall at x `5100`.
- Use `ExplorationGate` with `required_ability="parry"` and manually call its
  permanent unlock after three reflections. Its automatic radius must not make
  the first nearby parry bypass the trial.
- Listen to the typed PlayerController `ability_activated(StringName)` signal.
  A pulse owns one result latch so one activation cannot score twice.
- Reuse Story138's active GameFlowController and roost savepoint for lethal
  miss recovery. Do not create a second death controller.
- Keep durable state under `neon_rooftops_central_tower_*` keys. Runtime timers,
  active VFX, and one-shot counts are not serialized.

## Engine, Manifest, and Performance Notes

- Godot `4.7-stable` and Godot AI MCP `2.9.1` are authoritative.
- The slice adds static collision, two Area2D triggers, one gate, one pulse
  Sprite2D, and one controller with no tree polling or navigation. Processing is
  disabled while the route is locked, completed, or the player is outside the
  trial.
- Scene/script/resource edits require one final MCP scene, runtime, log, real
  input, and screenshot pass after focused automation is green.

## Implementation Plan

1. Add three focused GdUnit cases and capture expected RED.
2. Generate one opaque fourth-screen background and one keyed prop/VFX sheet;
   normalize runtime PNGs and import them through Godot 4.7.
3. Add the dedicated controller and authored scene nodes, then wire narrow
   parent APIs, state merge, objective priority, and Story138 route proof.
4. Reach focused GREEN, run Story138-139 once, add one targeted headless smoke,
   then perform one final Godot MCP runtime pass.
5. Complete source records, asset spec, manifest/inventory, QA evidence, Story,
   Epic, critical paths, and session-state updates.

## QA Test Cases

- **AC-1: Authored fourth viewport and asset contract**
  - Given: Story139 files are present.
  - When: the scene, controller, generated assets, gate, collision, bounds, and
    diagnostics are inspected.
  - Then: exact paths, sizes, alpha, nodes, geometry, timing, player parry
    SpriteFrames, camera, and right-wall values match this contract.
- **AC-2: Route proof, pulse timing, and miss damage**
  - Given: Story138 before and after its endpoint completion.
  - When: a nearby parry-capable player enters the trial and misses one pulse.
  - Then: locked activation fails, valid activation starts telegraph, the strike
    deals exactly `18` damage, and the gate remains blocking.
- **AC-3: Three real parries, threshold, and deterministic restore**
  - Given: an active trial and Story138 roost.
  - When: three strike windows receive real PlayerController parries, the player
    crosses the gate, and a fresh scene restores captured state.
  - Then: three reflections, one gate unlock, one threshold completion, durable
    state, no replay counts, and all earlier rooftop progress remain correct.

## Test Evidence

**Required evidence**:

- `tests/unit/gameplay/neon_rooftops_central_tower_parry_laser_trial_test.gd`
- `tests/smoke/neon_rooftops_central_tower_parry_laser_trial_smoke.gd`
- `production/qa/evidence/neon-rooftops-central-tower-parry-laser-trial-2026-07-12.md`

**Status**: [x] Complete. Initial RED `report_1488`; final focused GREEN
`report_1491` (`3/3`); final Story138-139 GREEN `report_1492` (`6/6`);
targeted headless smoke marker
`neon_rooftops_central_tower_parry_laser_trial_smoke=passed`; Godot MCP clean
runs `57-58` verified 108 authored nodes, 145 runtime nodes, generated assets,
real-input `parry` frame `2`, reflected pulse/objective `1/3`, gate collision,
non-empty `1278x718` gameplay capture, `current_run_errors=[]`, and no editor
rows after cursor `3`.

## Dependencies

- Depends on: Story138 Neon Rooftops Relay Spire Savepoint Traverse. Complete.
- Unlocks: a future approved Central Tower scene handoff and tower interior
  story. Boss4 still requires its own approved data and encounter contract.
