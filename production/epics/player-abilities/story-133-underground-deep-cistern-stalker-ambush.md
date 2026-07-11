# Story 133: Underground Deep Cistern Stalker Ambush

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Core / Gameplay Runtime / AI / Scene Management / Visual
> **Type**: Integration + Gameplay Runtime + Frame Animation Contract
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-11

## Context

**GDD**: `design/gdd/game-concept.md`, `design/gdd/ai-framework.md`,
`design/gdd/feline-combat.md`, `design/gdd/scene-management.md`,
`design/gdd/exploration-ability-gating.md`, `design/gdd/health-death.md`,
`design/art/art-bible.md`

**Requirements**: `TR-ai-001`, `TR-ai-003`, `TR-ai-007`, `TR-ai-008`,
`TR-combat-011`, `TR-health-002`, `TR-scene-004`

**ADR Governing Implementation**: ADR-0002 Signal Communication; ADR-0004
Collision Detection; ADR-0005 Combat State Machine; ADR-0006 AI Behavior;
ADR-0007 Scene Management.

Story132 leaves Cinderpaw at a secured recovery endpoint with no deep-route
combat payoff. Story133 extends the same bounded Underground scene by one
viewport and introduces a new mutated enemy family, the Cistern Stalker. The
player crosses the endpoint, triggers a sealed one-enemy ambush, reads a long
attack tell, avoids or counters a real leap-lunge, and clears the route through
the shared Weapon, Combat, Collision, and Health component chain.

This is deliberately a compact ACT encounter. It adds a distinct silhouette and
attack rhythm without inventing Boss4, a new progression reward, or an empty
destination scene before those designs are approved.

## Design Decision

- **Selected**: one new elite Cistern Stalker in a fourth Underground viewport.
  This provides the strongest immediate gameplay and visual payoff while keeping
  scene ownership and verification bounded.
- **Rejected**: an immediate SceneManager handoff. It would add registry and
  transition work but leave the destination without meaningful gameplay.
- **Rejected**: another pair of Factory Sluice Leeches. It is cheaper but repeats
  Story131's silhouette, timing, and combat composition instead of expanding the
  Underground enemy vocabulary.

Standing project approval covers this goal-aligned design and its local writes.
Parallel sidecars are not retried for this Story because the preceding two
attempts failed before execution on the unsupported backend reasoning setting;
design, art, QA, and integration review remain local and explicitly bounded.

## Acceptance Criteria

- [x] `underground_passage.tscn` expands from `3840x720` to a bounded
  `5120x720` route with a fourth opaque image-generated background, continuous
  encounter ground, Camera2D limit `0..5120`, right wall x `5100`, and all
  Story130-132 route, savepoint, and return nodes preserved.
- [x] New encounter behavior is owned by a dedicated
  `UndergroundDeepCisternAmbushController`. It remains locked until
  `underground_recovery_cistern_traversed=true`, activates once when Cinderpaw
  crosses x `4050`, closes a rear seal at x `3980`, keeps a forward seal at x
  `4960` closed, and assigns the player as the enemy target.
- [x] A new `UndergroundCisternStalker` visible character is implemented through
  `scenes/characters/underground_cistern_stalker.tscn` and
  `src/characters/underground_cistern_stalker.gd`, with runtime gameplay scene
  ownership under `src/gameplay/`. It is not a recolored rectangle or a reused
  Sluice Leech visual.
- [x] The Stalker uses `AnimatedSprite2D + SpriteFrames`. Its `idle`, `run`,
  `attack_tell`, `attack`, `hurt`, and `death` animations each contain exactly
  three transparent, anchor-consistent `96x96` PNG frames stored under
  `assets/characters/underground_cistern_stalker/<animation>/` with continuous
  `_000.._002` names.
- [x] The enemy has stable entity id `2501`, family id
  `underground_cistern_stalker`, `48` max HP, an explicit `24` physics-frame
  attack tell, one `6`-frame leap-lunge active window, `14` base contact damage,
  and an `18`-frame recovery. Its active hitbox routes through the shared
  Collision/Combat calculation path and cannot damage the same target twice in
  one activation.
- [x] Underground player attacks continue to use the mounted WeaponComponent
  and hit-confirmed target-id routing. A real light or aerial attack against
  entity `2501` reduces Stalker HP through its public health adapter; reaching
  zero HP emits the existing defeat contract and plays the authored death
  animation.
- [x] Defeating the Stalker opens and disables both encounter seals, marks
  `underground_deep_cistern_stalker_defeated=true`, updates the shared objective
  to `Deep Cistern Secured`, and prevents reactivation on the current or a fresh
  scene instance.
- [x] `get_local_state()` / `set_local_state()` persist activation and defeat
  state alongside Story130-132 state and unlocked abilities. Restoring an
  uncleared encounter recreates the correct seal/enemy state; restoring a clear
  encounter leaves the route open without replaying activation feedback.
- [x] The deep-cistern background and all Stalker frames are generated through
  built-in image generation, retain source/alpha/preview records, import through
  Godot 4.7, and are recorded in an asset spec, generation records, manifest,
  inventory, and QA evidence.
- [x] One focused RED/GREEN suite, one bounded related regression pass, one
  targeted headless smoke, and one Godot MCP 2.9.1 runtime pass complete with
  clean current-run logs and a non-empty screenshot showing Cinderpaw, the live
  AnimatedSprite2D Stalker, generated background, and encounter seals.

## Out of Scope

- Boss4, wall climb, a new ability reward, a new registered area, a save schema
  migration, fast travel, a second enemy wave, ranged/status attacks, or dynamic
  navigation.
- New music/SFX files, particles, shaders, destructible terrain, dynamic liquid,
  a generalized encounter framework, or a new Autoload.
- Rebalancing Cinderpaw, Factory enemies, Boss3, Story131 corrosion damage, or
  Story132 death/respawn timings.

## Implementation Notes

- Keep the fourth viewport in `area_04_underground_passage`; Story134 may own a
  deliberate destination handoff after the encounter is proven playable.
- Use the existing six-state enemy contract and shared components. A subclass
  may reuse stable motion/component plumbing, but this Story owns a new visual,
  family id, HP configuration, telegraph timing, leap behavior, and metadata.
- Keep the parent scene integration thin: configure the dedicated controller,
  delegate target-id damage, merge local state and diagnostics, and let the
  deepest active slice own the shared objective.
- Do not introduce NavigationAgent2D. The Stalker uses deterministic target
  facing and local CharacterBody2D motion within the authored sealed arena.

## Engine, Manifest, and Performance Notes

- Godot `4.7-stable` and Godot AI MCP `2.9.1` are authoritative.
- Scene, script, SpriteFrames import, animation names/frame counts, hit routing,
  current-run logs, visibility, and screenshot checks are required after final
  implementation. MCP errors block further feature work until fixed.
- The slice adds one active CharacterBody2D, two static seals, one background,
  and one dedicated controller. No per-frame allocations or unbounded searches
  are permitted in enemy processing.

## Implementation Plan

1. Add three grouped GdUnit acceptance tests and run only the new suite to
   capture RED before production implementation.
2. Generate the fourth background and a strict 3-column by 6-row keyed character
   sheet; normalize transparent `96x96` frames and inspect source/alpha/preview.
3. Implement the character SpriteFrames, gameplay enemy, dedicated encounter
   controller, authored scene nodes, and thin parent state/combat integration.
4. Reach focused GREEN, run one bounded Story131-133 regression set, and run one
   SceneManager smoke covering prerequisite, activation, real damage, clear, and
   restore.
5. Complete asset and QA records, then force-reload and play the encounter once
   through Godot MCP before Story close-out, commit, and push.

## QA Test Cases

- **AC-1: Authored route and frame-animation contract**
  - Given: the fourth viewport and imported Stalker assets.
  - When: the scene, character scene, SpriteFrames, and diagnostics load.
  - Then: route bounds, seals, background, files, six animation names, three
    frames each, alpha, dimensions, entity id, family, HP, and timings match.
- **AC-2: Prerequisite, tell, leap, and player damage**
  - Given: an uncleared Story132 endpoint and then a traversed endpoint.
  - When: Cinderpaw crosses x `4050`, requests the enemy attack, and lands one
    real weapon hit.
  - Then: locked activation rejects first, seals close behind/onward, the Stalker
    targets Cinderpaw, exposes a 24-frame tell and leap metadata, and loses HP
    through target-id routing.
- **AC-3: Clear and deterministic restore**
  - Given: the live ambush.
  - When: enough real-routed attacks defeat entity `2501`, local state is
    captured, and a fresh scene restores it.
  - Then: both seals open, objective reads `Deep Cistern Secured`, the defeated
    enemy stays inactive, and the encounter cannot reactivate.

## Test Evidence

**Required evidence**:

- `tests/unit/gameplay/underground_deep_cistern_stalker_ambush_test.gd`
- `tests/smoke/underground_deep_cistern_stalker_ambush_smoke.gd`
- `production/qa/evidence/underground-deep-cistern-stalker-ambush-2026-07-11.md`

**Status**: [x] Complete. RED `report_1448`; death-presentation regression RED
`report_1455`; final focused GREEN `report_1456` (`3/3`); bounded related GREEN
`report_1451` (`9/9`); targeted smoke passed; Godot MCP run token `36`
completed with clean current-run logs.

## Dependencies

- Depends on: Story132 Underground Recovery Cistern Savepoint Traverse. Complete.
- Unlocks: Story134 deep Underground scene handoff or Boss4 approach design.

## Completion Notes

**Completed**: 2026-07-11
**Criteria**: 10/10 passing
**Deviations**: The Stalker reuses stable RatMinion/FactorySparkRat state and
component plumbing, but owns a new generated amphibious visual family, 48 HP
configuration, 24/6/18 leap timing, 14-damage calculator, hitbox metadata, and
dedicated encounter controller. MCP found and drove one presentation fix: old
Story132 relay/endpoint labels now use proximity visibility so completed text
does not clip into the fourth viewport. Local review also found that immediate
enemy cleanup hid the authored death animation; clear state now opens the route
immediately while the non-damaging death sprite remains visible and fades out.
**QA Evidence**:
`production/qa/evidence/underground-deep-cistern-stalker-ambush-2026-07-11.md`
**Code Review**: Approved locally. No blocking GDD, accepted ADR, ownership,
collision, frame-animation, restore, or runtime-log issue remains.
