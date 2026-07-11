# Story 128: Sluice Matriarch Playable Boss3 Core

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Core / Gameplay Runtime / Combat / Presentation
> **Type**: Integration + Gameplay Runtime + Frame Animation Contract
> **Estimate**: L
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-11

## Context

**GDD**: `design/gdd/boss-config.md`, `design/gdd/feline-combat.md`,
`design/gdd/player-abilities.md`, `design/gdd/exploration-ability-gating.md`,
`design/gdd/health-death.md`, `design/gdd/hud-ui.md`,
`design/art/art-bible.md`

**Requirements**: `TR-ability-003`, `TR-ability-005`, `TR-boss-001`,
`TR-boss-002`, `TR-combat-001`, `TR-health-001`, `TR-hud-001`

**ADR Governing Implementation**: ADR-0002 Signal Communication; ADR-0004
Collision Detection; ADR-0005 Combat State Machine; ADR-0006 AI Framework;
ADR-0007 Scene Management; ADR-0018 Player Abilities; ADR-0021 Save System.

Story127 creates a real Boss3 destination but intentionally leaves only a
dormant cocoon in the environment. Story128 turns that destination into a
bounded playable boss encounter. It follows the established Boss2 lightweight
runtime pattern rather than expanding Rat King's full data-driven three-phase
framework in the same slice: one readable pressure-lunge attack, a meaningful
phase-two speed increase, shared combat components, Boss HUD, room seals,
defeat persistence, and an opened return route form the smallest complete
player-visible Boss3 loop.

## Acceptance Criteria

- [x] Sluice Matriarch character assets live under
  `assets/characters/sluice_matriarch/<animation>/` and use transparent,
  consistently anchored, continuous `192x192` PNG frames. `idle`, `run`,
  `attack_tell`, `attack`, `hurt`, and `death` each contain exactly three
  frames in `sluice_matriarch_sprite_frames.tres`.
- [x] `scenes/characters/sluice_matriarch.tscn` uses `AnimatedSprite2D +
  SpriteFrames` with `src/characters/sluice_matriarch.gd`; the gameplay shell
  lives at `src/gameplay/sluice_matriarch_boss.tscn` with
  `src/gameplay/sluice_matriarch_boss.gd`.
- [x] The runtime boss uses entity id `2300`, boss id
  `boss_03_sluice_matriarch`, display name `Sluice Matriarch`, and `120` max
  HP through the shared HealthComponent, CollisionComponent, CombatComponent,
  and StatusEffectComponent chain.
- [x] Its pressure lunge has an `18`-frame `attack_tell`, a distinct active
  animation, forward body movement, a shared enemy hitbox, `16` base damage,
  and a recovery window. No damage hitbox is active during startup.
- [x] At `50%` HP or lower, phase two applies only after an active attack chain
  completes, emits deterministic diagnostics, increases lunge movement, and
  shortens attack cooldown without adding a second unproven attack family.
- [x] `sluice_matriarch_arena.tscn` instantiates the boss, binds Cinderpaw's
  attack chain to entity `2300`, binds the boss target to Cinderpaw, and shows
  a live top-center Boss HUD while the encounter is active.
- [x] Left/right room seals are visible and collision-blocking while the boss
  is alive. The arena owns an ADR-0007 SceneManager lock and
  `FactoryReturnRoute` is unavailable during combat; boss defeat releases the
  lock, hides/disables both seals, hides the Boss HUD, and opens the route.
- [x] If Cinderpaw dies during the encounter, the arena respawns Cinderpaw at
  `BossEntrySpawn` with restored HP and resets the active Matriarch to full HP,
  phase one, and its authored arena anchor instead of leaving a zero-HP deadlock.
- [x] Arena local state persists `boss_03_sluice_matriarch_defeated=true`.
  Restoring it keeps the boss defeated/non-damaging, seals open, return route
  available, and transient transition latches clear.
- [x] Built-in image generation source, alpha source, normalized runtime
  frames, prompt/processing record, asset spec, manifest entry, entity
  inventory entry, and QA evidence are retained and imported through Godot 4.7.
- [x] One focused RED/GREEN suite, bounded related regression, one targeted
  headless smoke, and Godot MCP 2.9.1 runtime checks pass. MCP must show the
  frame-animated boss, active HUD/seals, attack phase progression, defeat-open
  state, clean current-run logs, and non-empty screenshots.

## Out of Scope

- `aerial_attack` reward presentation/unlock, post-Boss3 underground route,
  victory cutscene, currency/skill-point grant, full three-phase BossConfig
  data migration, summon attacks, arena mutation hazards, authored audio,
  bespoke Boss3 portrait, particles, shader distortion, or camera shake.
- Refactoring Rat King or Boss2, changing global combat formulas, adding a new
  Autoload, or changing the SaveSystem schema.

## Implementation Notes

- Reuse the proven Boss2 component wiring but keep the Boss3 class and runtime
  state isolated. Arena integration owns player/boss adapters, HUD, seals,
  persistence, and the victory route; the boss owns health and attack timing.
- The Matriarch is a giant low-bodied industrial leech with pressure clamps,
  cracked ceramic plates, cyan mutation seams, rust-orange hardware, and
  signal-red attack spines. It must not read as a scaled-up rat.
- Use a flat magenta chroma key for generation because cyan/green mutation
  accents are part of the subject. Normalize every frame with one shared scale,
  x anchor, and ground baseline.
- Story129 should consume the defeated flag to present and persist the
  `aerial_attack` reward; Story128 does not silently unlock progression.

## QA Test Cases

- **AC-1: Frame-animated boss attack**
  - Given: the Matriarch runtime has Cinderpaw as target.
  - When: a pressure lunge is requested and advanced through startup/active.
  - Then: `attack_tell` precedes `attack`, no startup hitbox exists, the body
    moves toward Cinderpaw during active frames, and the shared hitbox carries
    `16` base damage metadata.
- **AC-2: Arena lock, defeat, and restore**
  - Given: a fresh or defeated-state arena.
  - When: entity `2300` reaches zero HP or defeated state is restored.
  - Then: active combat shows HUD/seals and locks return; defeated combat keeps
    a non-damaging death sprite, hides the HUD, opens seals/return, persists the
    flag, and never restores a stale transition request.
- **AC-3: Player death retry**
  - Given: Cinderpaw and the Matriarch have both taken damage.
  - When: Cinderpaw reaches zero HP before the boss is defeated.
  - Then: Cinderpaw respawns at `BossEntrySpawn` and the Matriarch returns to
    its arena anchor at full HP and phase one with the room seals still active.

## Test Evidence

**Required evidence**:

- `tests/unit/gameplay/sluice_matriarch_playable_boss3_core_test.gd`
- `tests/smoke/sluice_matriarch_playable_boss3_core_smoke.gd`
- `production/qa/evidence/sluice-matriarch-playable-boss3-core-2026-07-11.md`

**Status**: [x] Complete. Final focused GdUnit `report_1414` passed `4/4`;
final bounded related GdUnit `report_1415` passed `14/14`; targeted smoke passed;
Godot 4.7 + MCP 2.9.1 runtime evidence is recorded in the required QA file.

## Completion Traceability

| Criterion | Evidence | Status |
|-----------|----------|--------|
| Asset folders, alpha canvases, six three-frame animations | `test_character_frames_follow_boss3_animation_contract`; generation record; asset spec | COVERED |
| Character scene and gameplay shell | Character-frame test; MCP hierarchy/resource inspection | COVERED |
| Entity identity, HP, shared components, and player WeaponComponent binding | Pressure-lunge/arena test; smoke; MCP player-hit diagnostics | COVERED |
| Telegraph, movement, active hitbox, 16 damage, recovery | Pressure-lunge test; smoke; MCP attack/hit probes | COVERED |
| Phase-two movement/cooldown and HUD refresh | Phase-HUD test; smoke; MCP phase-two screenshot | COVERED |
| Arena adapters, Boss HUD, room seals, SceneManager lock, defeat route | Arena contract test; Story127 related test; smoke; MCP diagnostics/screenshots | COVERED |
| Player-death retry and combat-capable hurtbox restore | Death-retry test; reports 1407/1408; MCP retry/hit probes | COVERED |
| Persistent defeated/non-damaging state | Arena restore test; smoke; MCP local-state probe | COVERED |
| Asset pipeline and Godot/MCP verification | Manifest/inventory/spec; QA evidence; final logs/screenshots | COVERED |

## Completion Notes

- The playable core intentionally uses two phases and one pressure-lunge attack
  family. A full three-phase BossConfig migration, summons, arena hazards, and
  additional attacks remain outside this bounded slice.
- The room seals reuse the already image-generated Boss2 seal art; Story128
  does not claim bespoke Boss3 seal generation.
- The generated death animation remains visible as a non-damaging corpse after
  victory. Boss HUD and collisions are disabled, and the route opens.
- MCP uncovered and Story128 fixed a shared respawn defect: `respawn_at()` now
  restores the player's Core hurtbox from `gone` to `normal` before gameplay
  resumes.
- Story129 owns the victory reward presentation, persistent `aerial_attack`
  unlock, and post-Boss3 progression handoff.

## Dependencies

- Depends on: Story127 Sluice Matriarch Arena Handoff.
- Unlocks: Story129 Sluice Matriarch defeat reward and `aerial_attack` payoff.
