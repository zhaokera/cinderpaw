# Story 146: Crown Warden Playable Boss4 Core

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Core / Gameplay Runtime / Combat / Presentation
> **Type**: Integration + Gameplay Runtime + Frame Animation Contract
> **Estimate**: L
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-13

## Context

**GDD**: `design/gdd/boss-config.md`, `design/gdd/feline-combat.md`,
`design/gdd/player-abilities.md`, `design/gdd/health-death.md`,
`design/gdd/hud-ui.md`, `design/gdd/scene-management.md`,
`design/art/art-bible.md`

**Quick Design**:
`design/quick-specs/crown-warden-playable-boss4-core-2026-07-12.md`

**Requirements**: `TR-boss-001`, `TR-boss-002`, `TR-combat-001`,
`TR-health-001`, `TR-hud-001`, `TR-scene-004`

**ADR Governing Implementation**: ADR-0001, ADR-0002, ADR-0003, ADR-0004,
ADR-0005, ADR-0006, ADR-0007, ADR-0018, ADR-0019, ADR-0021.

Story145 provides a generated-art Crown Observatory and exact Tower round trip,
but deliberately contains no Boss placeholder. Story146 turns that destination
into a complete player-visible Boss4 loop: a data-backed mechanical owl with
two readable attacks, phase pressure, real combat components, Boss HUD, room
seals, death retry and persistent victory. Reward and ending remain later
slices so combat acceptance cannot be hidden behind progression work.

## Acceptance Criteria

- [x] `data/combat/enemy_stats.json` and schema define
  `boss_04_crown_warden` with `160` max HP plus `talon_dive` and `wing_sweep`
  timing, damage and hitboxes. `boss_configs.json` and schema define its two
  phases, 50% threshold, attack-speed modifiers, parry rules, future
  `wall_climb` reward metadata and `1280x720` arena bounds.
- [x] Image-generation source, exact prompt/processing record, alpha source,
  preview and twenty-four transparent common-anchor `192x192` frames are
  retained under `assets/characters/crown_warden/`.
- [x] `crown_warden_sprite_frames.tres` contains exactly three frames for each
  `idle`, `run`, `talon_dive_tell`, `talon_dive`, `wing_sweep_tell`,
  `wing_sweep`, `hurt` and `death` animation.
- [x] `scenes/characters/crown_warden.tscn` uses `AnimatedSprite2D +
  SpriteFrames` with `src/characters/crown_warden.gd`; the gameplay shell is
  `src/gameplay/crown_warden_boss.tscn` plus
  `src/gameplay/crown_warden_boss.gd`.
- [x] Runtime identity is entity `2400`, Boss id `boss_04_crown_warden`, display
  name `Crown Warden`, max HP `160`; shared Health, Collision, Combat and
  StatusEffect components are present and attack patterns load through
  DataManager with deterministic fallback diagnostics.
- [x] `talon_dive` has 20 startup frames with no hitbox, 8 moving active frames
  with real hitbox and 18 damage, then 20 recovery frames. Phase two raises its
  step from `8px` to `12px` without leaving arena bounds.
- [x] `wing_sweep` has 24 startup frames with no hitbox, 10 stationary active
  frames with a distinct wide hitbox and 14 damage, then 18 recovery frames.
  Autonomous combat alternates the two patterns and deterministic APIs can
  request either one.
- [x] At 50% HP or lower, phase two waits for an active chain to finish, emits
  one transition signal, shortens cooldown `48 -> 30`, updates the Boss HUD and
  preserves exact player abilities.
- [x] `crown_warden_arena.tscn` instantiates Crown Warden, binds Cinderpaw's real
  attack chain to entity `2400`, shows live Boss HUD and two generated-art crown
  seals, locks SceneManager and disables `CentralTowerReturnRoute` while alive.
- [x] Player death before victory respawns at `BossEntrySpawn` with full HP and
  resets Crown Warden to full HP, phase one, idle state and authored anchor;
  seals/HUD remain active and abilities do not change.
- [x] Boss death persists `boss_04_crown_warden_defeated=true`, disables damage,
  keeps the death animation visible, opens seals, hides Boss HUD, releases the
  scene lock and enables return. Fresh restore has no stale transition latch.
- [x] Asset spec, manifest, inventory, focused RED/GREEN, Story145 related
  regression, target smoke and Godot MCP 2.9.1 evidence cover actual attacks,
  hit/phase/death states, real player input, HUD/seals, generated frames,
  non-empty screenshots and clean current-run/editor-cursor logs. No full suite.

## Stable Contract

| Contract | Value |
|----------|-------|
| Boss / entity | `boss_04_crown_warden` / `2400` |
| HP / phase threshold | `160` / `0.50` |
| Dive | `20/8/20`, 18 damage, `8px -> 12px` active step |
| Sweep | `24/10/18`, 14 damage, stationary |
| Cooldown | `48 -> 30` frames |
| Defeated state | `boss_04_crown_warden_defeated` |

## Test Evidence Contract

- Focused suite:
  `tests/unit/gameplay/crown_warden_playable_boss4_core_test.gd`
- Target smoke:
  `tests/smoke/crown_warden_playable_boss4_core_smoke.gd`
- QA evidence:
  `production/qa/evidence/crown-warden-playable-boss4-core-2026-07-12.md`

## Out Of Scope

- Wall-climb reward claim/unlock presentation, currency, skill points, ending,
  cutscene, credits, bespoke Boss portrait, bespoke audio, particles, camera
  shake, projectiles, summons, arena mutation, third phase or post-game state.
- New Autoloads, global combat refactors, SceneManager refactors, SaveSystem
  schema changes, Boss1-3 rewrites or full-suite/launch validation.

## Dependencies

- Depends on: Story145 Central Tower Crown Warden Arena Handoff. Complete.
- Unlocks: Story147 Crown Warden wall-climb reward payoff.

## Implementation

- Added data/schema contracts for entity `2400`, Boss4 phases, exact attacks,
  arena bounds, parry metadata and future `wall_climb` reward metadata.
- Added twenty-four generated transparent `192x192` frames and eight exact
  three-frame SpriteFrames animations. `run` is reachable through autonomous
  approach locomotion; all death-frame opaque bottoms share the same anchor.
- Added the Crown Warden character and gameplay scenes with shared Health,
  Collision, Combat and StatusEffect components plus DataManager fallback
  diagnostics and damage-calculator injection.
- Evolved the observatory into a complete bounded fight with real Cinderpaw
  attacks, two Boss hitboxes, chain-safe phase two, HUD, seals, SceneManager
  lock ownership, death retry, persistent defeat and opened return route.
- Fixed a shared physics-frame respawn race in `CollisionComponent` so a
  deferred `gone` update cannot override a same-frame `normal` restoration.

## Test-Criterion Traceability

| AC | Evidence | Status |
|----|----------|--------|
| 1. Boss4 data and recursive schemas | schema tests; Story146 focused suite | COVERED |
| 2-4. Generated frames, SpriteFrames and required scenes | asset records/spec; focused suite; MCP screenshot | COVERED |
| 5. Identity, shared components and DataManager | focused suite; MCP runtime diagnostics | COVERED |
| 6-7. Dive and sweep timing, movement, hitboxes and damage | focused suite; target smoke; MCP real overlaps | COVERED |
| 8. Chain-safe phase two and unchanged abilities | focused suite; target smoke; MCP Phase II probe | COVERED |
| 9. Real player chain, HUD, seals and scene lock | related suite; target smoke; MCP real input | COVERED |
| 10. Full retry contract | collision regression; target smoke; MCP lethal retry | COVERED |
| 11. Persistent defeat/open route | focused suite; target smoke; MCP restore probe | COVERED |
| 12. Asset/docs/test/MCP evidence | report `1553`; smoke log; QA evidence and screenshots | COVERED |

## Verification

- Expected RED: `reports/report_1547/results.xml` exposed recursive array-item
  schema and injected-damage gaps; `report_1549` exposed death anchors and the
  unreachable `run` state.
- Final focused GREEN: `reports/report_1551/results.xml`, `6/6`, zero errors,
  failures, skipped tests or orphans.
- Shared collision regression: `reports/report_1552/results.xml`, `6/6`.
- Final bounded related GREEN: `reports/report_1553/results.xml`, `34/34`, zero
  errors, failures, skipped tests or orphans. It includes schema, shared
  collision, Story145 handoff, Boss3 and Story146 coverage.
- Target smoke: `reports/crown_warden_playable_boss4_core_smoke.log`, exit `0`
  with marker `crown_warden_playable_boss4_core_smoke=passed`.
- Godot `4.7-stable` / Godot AI MCP `2.9.1` final Run `r3362590-4` used real
  attack input, verified exact `12/18/14` damage, phase pending/complete, fully
  collidable retry, defeat persistence and fresh restore. Current-run logs had
  only helper/DataManager info and editor cursor `4 -> 4` added no rows.
- MCP screenshots:
  `production/qa/evidence/crown-warden-playable-boss4-phase2-mcp.png` and
  `production/qa/evidence/crown-warden-playable-boss4-defeated-mcp.png`.
- No full suite was run, per the bounded verification contract.

## Completion Notes

**Completed**: 2026-07-13

**Verdict**: COMPLETE

**Criteria**: 12/12 covered; reward and ending remain Story147+ scope.

**Deviations**: None from the Story146 stable contract. The broader cinematic
phase-transition presentation, parry-specific Boss reaction and arena mutation
remain outside this bounded core and are not claimed by this completion.

**Review**: Three parallel read-only acceptance, asset and QA reviewers fed
findings to the integrating agent. Final edits, tests and MCP validation were
owned and rechecked by the integrating agent.
