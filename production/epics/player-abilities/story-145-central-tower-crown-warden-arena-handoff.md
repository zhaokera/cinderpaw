# Story 145: Central Tower Crown Warden Arena Handoff

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Feature / Gameplay Runtime / Scene Management / Visual
> **Type**: Integration + Gameplay Runtime + Scene Handoff + Visual
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-12

## Context

**GDD**: `design/gdd/boss-config.md`, `design/gdd/scene-management.md`,
`design/gdd/player-abilities.md`, `design/gdd/exploration-ability-gating.md`,
`design/art/art-bible.md`

**Quick Design**:
`design/quick-specs/central-tower-crown-warden-arena-handoff-2026-07-12.md`

**Requirements**: `TR-scene-001`, `TR-scene-002`, `TR-scene-004`

**ADR Governing Implementation**: ADR-0001, ADR-0002, ADR-0003, ADR-0004,
ADR-0007, ADR-0018, ADR-0021.

Story144 reaches and secures the Apex Approach. Story145 turns that terminal
beacon into a real asynchronous destination and return path. The new Crown
Observatory is an authored arena shell for the approved `boss_04_crown_warden`
identity, but no Boss actor is shown until its mandatory frame-animation and
combat contract land together.

## Acceptance Criteria

- [x] `data/scene_registry.json` and its schema register
  `boss_04_crown_warden_arena` at
  `res://scenes/bosses/crown_warden_arena.tscn` as a non-preloaded
  `boss_arena`, default spawn `boss_entry`, display name `Crown Observatory`.
- [x] `central_tower_threshold.tscn` adds `CrownWardenArenaRoute` near the Apex
  endpoint and `ApexApproachReturnSpawn` at `(6200,296)`. The generated crown
  gate is visible; no ColorRect, Polygon2D or primitive player-facing route art
  is introduced.
- [x] The route stays locked with `Secure Apex Approach` until
  `central_tower_apex_approach_secured=true`, then becomes available with
  `Enter Crown Observatory`. It targets
  `boss_04_crown_warden_arena / boss_entry` and accepts one nearby interaction.
- [x] Out-of-range, missing/loading/locked/unknown SceneManager and rejected
  requests remain retryable. A successful request persists Tower state, calls
  the asynchronous SceneManager exactly once, and exposes pending/rejection
  diagnostics without changing abilities.
- [x] `crown_warden_arena.tscn` is a bounded `1280x720` side-view arena with an
  image-generated opaque Crown Observatory backdrop, floor, side walls,
  `BossEntrySpawn` `(220,536)`, Cinderpaw, bounded Camera2D, objective and
  `CentralTowerReturnRoute`.
- [x] Story145 contains no Crown Warden node, static Boss prop, Boss HUD, room
  seal, hitbox, reward, phase or ending logic. The objective reads
  `Crown Warden Signal Detected`; future Story146 owns the mandatory
  `AnimatedSprite2D + SpriteFrames` Boss actor and playable core.
- [x] The arena return route targets
  `area_05_central_tower / apex_approach_return`, is available before combat
  exists, accepts one nearby interaction and aligns a returned player to
  `(6200,296)` while preserving Story140-144 state and exact abilities.
- [x] Image generation source, exact prompts, alpha intermediate, runtime
  `1280x720` RGB background and transparent `256x384` crown gate, asset spec,
  manifest, inventory and QA evidence are retained and imported by Godot 4.7.
- [x] A two-use-case focused RED/GREEN suite, Story144 related regression, one
  target smoke and Godot MCP 2.9.1 runtime checks cover both scenes, real input,
  transition requests, round-trip state, visible generated art, non-empty
  screenshots and clean current-run/editor-cursor logs. No full suite.

## Stable Contract

| Contract | Value |
|----------|-------|
| Boss identity | `boss_04_crown_warden` / `Crown Warden` |
| Arena | `boss_04_crown_warden_arena` / `crown_warden_arena.tscn` |
| Tower prerequisite | `central_tower_apex_approach_secured` |
| Arena spawn | `boss_entry` / `(220,536)` |
| Return | `area_05_central_tower / apex_approach_return` / `(6200,296)` |
| Arena objective | `Crown Warden Signal Detected` |

## Test Evidence Contract

- Focused suite:
  `tests/unit/gameplay/central_tower_crown_warden_arena_handoff_test.gd`
  - Registry/schema, generated assets, bounded arena, no Boss placeholder.
  - Story144 gate, request failures, one-shot transition, return and exact-state
    round trip.
- Headless smoke:
  `tests/smoke/central_tower_crown_warden_arena_handoff_smoke.gd`.
- MCP evidence:
  `production/qa/evidence/central-tower-crown-warden-arena-handoff-2026-07-12.md`.

## Out Of Scope

- Crown Warden character frames, gameplay shell, HP, HUD, seals, camera lock,
  attacks, AI, phases, damage, death, reward, audio, narrative, ending or
  victory return. Story146 and later slices own these.
- New Autoloads, SceneManager refactors, full Tower replay, Boss1-3 changes,
  SaveSystem schema changes, minimap or fast travel.

## Dependencies

- Depends on: Story144 Central Tower Apex Conduit Purge Run. Complete.
- Unlocks: Story146 Crown Warden playable Boss4 core.

## Implementation

- Registered `boss_04_crown_warden_arena` and added a Story144-gated generated
  crown route plus exact `(6200,296)` return spawn to the existing Tower scene.
- `CrownWardenArena` owns only entry alignment, durable discovery, exact ability
  transfer, retryable SceneManager requests, return handling and diagnostics.
- The authored arena uses generated observatory and crown-gate art, real floor
  and side-wall collision, existing animated Cinderpaw and bounded Camera2D.
  It deliberately contains no Boss placeholder or premature encounter logic.

## Test-Criterion Traceability

| AC | Evidence | Status |
|----|----------|--------|
| 1. Registry and schema | focused case 1 | COVERED |
| 2. Tower route, return marker and generated gate | focused cases 1-2; MCP | COVERED |
| 3. Story144 gate and one-shot route | focused case 2; target smoke | COVERED |
| 4. Retryable SceneManager failures and persistence | focused case 2 | COVERED |
| 5. Bounded generated-art arena | focused case 1; MCP Run77 | COVERED |
| 6. No static Boss placeholder or premature fight | focused case 1; authored/runtime hierarchy | COVERED |
| 7. Exact return spawn, state and abilities | focused case 2; target smoke | COVERED |
| 8. Image-generation pipeline records | focused case 1; spec/manifest/inventory | COVERED |
| 9. Bounded automation and clean MCP evidence | RED `1530`; final GREEN `1536`; related `1537`; smoke; MCP Run77 | COVERED |

## Verification

- Expected RED: `reports/report_1530/report_1/results.xml`, 2 cases with 10
  expected failures, exit `100`.
- `report_1531` is retained as an intermediate diagnostic only: assertions
  passed but Godot reported unimported PNG resource errors.
- First clean focused GREEN after import: `reports/report_1532/results.xml`,
  `2/2`, zero errors, failures, skipped tests or orphans, exit `0`.
- Final post-MCP-visual-fix focused GREEN: `reports/report_1534/results.xml`,
  `2/2`, zero errors, failures, skipped tests or orphans, exit `0`.
- Review hardening `report_1535` exposed a test-harness assumption that the
  GdUnit runtime lacked the real SceneManager autoload; the test now injects
  `null` explicitly before checking the missing-manager path.
- Final hardened focused GREEN: `reports/report_1536/results.xml`, `2/2`, zero
  errors, failures, skipped tests or orphans, exit `0`.
- Final Story144-145 related GREEN: `reports/report_1537/results.xml`, `5/5`, zero
  errors, failures, skipped tests or orphans, exit `0`.
- Target smoke: exit `0`, clean shutdown, marker
  `central_tower_crown_warden_arena_handoff_smoke=passed`.
- Godot MCP `2.9.1` / Godot `4.7-stable` Run77 returned
  `current_run_errors=[]`, added no editor rows after cursor `8`, inspected
  `25` authored and `29` runtime nodes, moved Cinderpaw with real input and
  captured a non-empty `1278x718` generated-art frame with unclipped labels.

## Completion Notes

**Completed**: 2026-07-12

**Verdict**: COMPLETE

**Criteria**: 9/9 passing; no deferred Story145 acceptance criteria.

**Deviations**: None. Crown Warden frame animation, combat, HUD, seals, reward
and ending remain intentionally out of scope for Story146 and later slices.

**Review**: Integrator review rejected the first assertion-only GREEN because
Godot logged missing import resources, and MCP visual review found and fixed one
clipped return prompt before final acceptance.
