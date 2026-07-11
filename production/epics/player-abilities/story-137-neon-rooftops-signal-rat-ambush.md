# Story 137: Neon Rooftops Signal Rat Ambush

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Core / Gameplay Runtime / AI / Scene Management / Visual
> **Type**: Integration + Gameplay Runtime + Frame Animation Contract + Reward
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-12

## Context

**GDD**: `design/gdd/game-concept.md`, `design/gdd/ai-framework.md`,
`design/gdd/feline-combat.md`, `design/gdd/exploration-ability-gating.md`,
`design/gdd/health-death.md`, `design/gdd/audio-system.md`

**Requirements**: `TR-ai-001`, `TR-ai-003`, `TR-ai-007`, `TR-ai-008`,
`TR-combat-011`, `TR-health-002`, `TR-scene-004`, `TR-explore-001`

**ADR Governing Implementation**: ADR-0001 component ownership; ADR-0002 typed
signals; ADR-0003 data management; ADR-0004 collision detection; ADR-0005
combat state machine; ADR-0006 AI behavior; ADR-0007 scene persistence.

Story136 establishes a physical wall-climb route and reaches a safe high roof,
but the destination ends before any combat. This story extends the same scene by
one `1280x720` viewport. Cinderpaw leaves the high roof, descends through a short
generated skyline route, triggers a sealed one-enemy ambush, reads and avoids a
magnetized lunge, defeats the enemy through the shared combat chain, and claims
a once-only rooftop signal cache.

The new ordinary enemy is the Neon Signal Rat: a small mechanical scavenger with
a broken billboard antenna and a cyan/violet silhouette that switches to signal
red during its attack tell. It is a normal enemy, not Boss4.

## Design Decision

- **Selected**: one new Signal Rat plus one post-clear cache in a second rooftop
  viewport. It gives the first area screen a complete traversal, combat, defeat,
  reward, UI, and audio loop without creating another registered scene.
- **Rejected**: a traversal-only extension. Story136 already proves wall climb;
  another empty route would not advance the ACT combat loop.
- **Rejected**: two enemies or a second wave. It widens art, state, and runtime
  risk before the new rooftop enemy has one proven encounter.
- **Rejected**: Boss4 approach or combat. No approved Boss4 configuration or
  encounter contract exists.

Standing project approval covers this goal-aligned design and local writes. Three
parallel design/art/QA sidecars were attempted twice, but the backend replaced
their supported effort with invalid `reasoning.effort=max` before execution;
the bounded reviews therefore continue locally without blocking the slice.

## Acceptance Criteria

- [x] `neon_rooftops_entry.tscn` expands to a bounded `2560x720` route with a
  second opaque image-generated background, physical descent/arena support,
  Camera2D limit `0..2560`, top/side bounds, and every Story136 route/return node
  preserved.
- [x] A dedicated `NeonSignalRoofEncounterController` stays locked until
  `neon_rooftops_entry_traversed=true`, activates once at x `1650`, closes the
  rear seal at x `1540`, keeps the forward seal at x `2440` closed, and assigns
  Cinderpaw as the live enemy target.
- [x] New visible character `NeonSignalRat` exists at
  `scenes/characters/neon_signal_rat.tscn` with
  `src/characters/neon_signal_rat.gd`; its gameplay body is isolated in
  `src/gameplay/neon_signal_rat.tscn` and `src/gameplay/neon_signal_rat.gd`.
- [x] The Signal Rat uses `AnimatedSprite2D + SpriteFrames`. `idle`, `run`,
  `attack_tell`, `attack`, `hurt`, and `death` each contain exactly three
  transparent, anchor-consistent `96x96` PNG frames under
  `assets/characters/neon_signal_rat/<animation>/`, named `_000.._002`.
- [x] `data/combat/enemy_stats.json` contains the `neon_signal_rat` balance entry.
  Runtime exposes entity id `2601`, family id `neon_signal_rat`, `36` max HP,
  an `18`-frame startup, `5` active frames, `18` recovery frames, and `11` base
  electric lunge damage. One activation cannot damage the same target twice.
- [x] Player attacks use the mounted Weapon/Combat/Collision chain. A real light
  attack hit-confirmed against target `2601` reduces Signal Rat HP, and defeat
  plays the generated `death` animation before the enemy fades out.
- [x] Defeat immediately opens both generated signal seals, persists
  `neon_rooftops_signal_rat_defeated=true`, requests the shared enemy-death audio
  event, reveals a generated cache at x `2320`, and advances the objective to
  `Claim Signal Cache +20 Gears`.
- [x] The cache is claimable only after defeat and within proximity. First claim
  records a `20`-gear reward and `neon_rooftops_signal_cache_claimed=true`,
  requests shared reward audio, and shows `Signal Roof Secured`; duplicate claims
  are rejected.
- [x] `get_local_state()` / `set_local_state()` preserve Story136 arrival,
  traversal, return route, and unlocked abilities plus activation, defeat, and
  cache state. Restoring active state rebuilds the sealed fight; restoring clear
  or claimed state leaves the route open without replaying feedback.
- [x] Background, seal/cache props, and all enemy frames are produced with
  built-in image generation, retain source/alpha/processing records, import in
  Godot 4.7, and are recorded in asset spec, manifest, inventory, and QA evidence.
- [x] One focused RED/GREEN suite, one bounded Story136-137 regression, one
  targeted headless combat/restore smoke, and Godot MCP 2.9.1 verify imported
  assets, real input combat, frame animation, gates/cache, logs, and a non-empty
  gameplay screenshot. Do not run the full suite.

## Out of Scope

- Boss4, an arena boss, another registered scene, Central Tower, fast travel,
  savepoint/schema migration, a second enemy, waves, ranged attacks, or dynamic
  navigation.
- New player abilities, wall combat, wall stamina, ledge grab, moving platforms,
  procedural rooms, or rebalancing Cinderpaw and existing enemies.
- New music files, new ambient files, shaders, complex particles, minimap work,
  NPCs, merchants, secrets, or generalized encounter/reward frameworks.

## Implementation Notes

- Keep Story137 in `area_05_neon_rooftops`; the first `1280x720` entry viewport
  remains intact while the new content owns x `1280..2560`.
- Keep root integration thin: mount the shared WeaponComponent, delegate target
  damage to the dedicated controller, merge local state/diagnostics, and let the
  deepest active slice own the objective.
- The enemy may reuse proven RatMinion/Sluice Leech component plumbing, but owns
  a new generated visual family, data entry, metadata, timings, and identity.
- Collision stays invisible over generated art. Do not use visible primitives as
  environment, enemy, seal, or cache substitutes.

## Engine, Manifest, and Performance Notes

- Godot `4.7-stable` and Godot AI MCP `2.9.1` are authoritative.
- The slice adds one active CharacterBody2D, two static seals, one cache, one
  background, and one dedicated controller. No NavigationAgent2D, unbounded tree
  searches, or per-frame data parsing.
- Scene/script/SpriteFrames changes require final MCP hierarchy, animation,
  runtime log, real input, and screenshot evidence. MCP errors block new work.

## QA Test Cases

- **AC-1: Route, generated art, data, and frame animation**
  - Given: Story137 files are present.
  - When: the scene, JSON entry, source/runtime PNGs, character/runtime scenes,
    SpriteFrames, camera, gates, cache, and diagnostics are inspected.
  - Then: exact paths, dimensions, alpha, frame counts, entity identity, and
    2560px physical bounds match the contract.
- **AC-2: Gate, attack tell, duplicate suppression, and real player hit**
  - Given: Story136 traversal state before and after proof.
  - When: Cinderpaw crosses x `1650`, the Signal Rat lunges, and Cinderpaw lands
    one real light attack.
  - Then: locked activation rejects, seals close, 18/5/18 timing is observable,
    enemy damage applies once per activation, and target `2601` loses HP through
    the shared hit-confirm path.
- **AC-3: Defeat, reward, and deterministic restore**
  - Given: the active ambush.
  - When: the rat is defeated, the nearby cache is claimed twice, and a fresh
    scene restores the captured state.
  - Then: gates open, death remains visible briefly, reward succeeds once,
    objective/state persist, and the encounter cannot replay.

## Test Evidence

**Required evidence**:

- `tests/unit/gameplay/neon_rooftops_signal_rat_ambush_test.gd`
- `tests/smoke/neon_rooftops_signal_rat_ambush_smoke.gd`
- `production/qa/evidence/neon-rooftops-signal-rat-ambush-2026-07-12.md`

**Status**: [x] Complete. RED `report_1478`; focused GREEN `report_1481`
(`3/3`); bounded Story136-137 GREEN `report_1483` (`6/6`); targeted headless
smoke marker `neon_rooftops_signal_rat_ambush_smoke=passed`; Godot MCP run `50`
verified real movement/attack input, generated art, live `attack_tell` frame
animation, readable HUD/objective, `current_run_errors=[]`, helper-only current
game logs, and no new editor rows after cursor `3`.

## Dependencies

- Depends on: Story136 Neon Rooftops Magnetic Wall Gate Handoff. Complete.
- Unlocks: a future rooftop savepoint, traversal branch, second encounter, or
  deliberate Boss4 approach story after its configuration exists.
