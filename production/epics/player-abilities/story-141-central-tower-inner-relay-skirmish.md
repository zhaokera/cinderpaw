# Story 141: Central Tower Inner Relay Skirmish

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Core / Gameplay Runtime / Combat / Visual
> **Type**: Integration
> **Estimate**: L
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-12

## Context

**GDD**: `design/gdd/game-concept.md`,
`design/gdd/exploration-ability-gating.md`, `design/gdd/feline-combat.md`,
`design/gdd/ai-framework.md`, `design/gdd/health-death.md`,
`design/gdd/death-respawn.md`, `design/gdd/combat-presentation.md`,
`design/art/art-bible.md`

**Quick Design**:
`design/quick-specs/central-tower-inner-relay-skirmish-2026-07-12.md`

**Requirements**: `TR-ai-003`, `TR-ai-007`, `TR-ai-008`, `TR-combat-004`,
`TR-combat-007`, `TR-respawn-001`, `TR-respawn-002`, `TR-respawn-005`,
`TR-respawn-006`, `TR-respawn-007`, `TR-scene-004`

**ADR Governing Implementation**: ADR-0001, ADR-0002, ADR-0003, ADR-0004,
ADR-0005, ADR-0006, ADR-0007, ADR-0010. Proposed ADR-0018/0019/0021 are
reused only through already implemented interfaces and are not expanded here.

Story140 creates a complete but single-screen Tower threshold. The approved
Quick Design defines the next bounded interior contract without inventing
Boss4: one generated second viewport, one real relay parry, one ordinary new
enemy, one durable clear, and one established small cache reward.

## Acceptance Criteria

- [x] `central_tower_threshold.tscn` expands to a bounded `2560x720` scene while
  preserving Story140's first viewport, threshold Roost, return route, guard,
  spawn, and state keys. Ground/top collision, Camera2D, and right boundary match
  the expanded width.
- [x] The generated Service Spine background and five separate transparent props
  meet exact asset dimensions, appear at authored positions, and contain no
  visible primitive/debug placeholder, baked actor, or baked text.
- [x] Only a defeated Threshold Guard allows crossing x `1500` to activate the
  inner relay. Activation closes the back and forward shutters, starts a
  deterministic telegraph/strike/recovery pulse, and cannot duplicate feedback.
- [x] A missed strike deals exactly `8` damage through the player health API and
  cycles. Only a real `parry` ability activation while the player is in the
  strike lane marks `central_tower_inner_relay_parried=true`; early, late,
  distant, missing-ability, or duplicate parries do not clear it.
- [x] `central_tower_relay_mantis` is entity `2702`, data-driven, and owns a
  `20/6/20` telegraphed 12-damage scythe dash through shared
  Health/Collision/Combat components. `idle`, `run`, `attack_tell`, `attack`,
  `hurt`, and `death` each use exactly three transparent `96x96` frames through
  `AnimatedSprite2D + SpriteFrames` and the mandatory character paths.
- [x] Reflecting the relay wakes the Mantis. Its real hitbox can damage the
  player; the player's established attack route can damage and defeat entity
  `2702`. Defeat opens both shutters, disables the pulse, and exposes cache
  `central_tower_inner_relay_cache`.
- [x] The cache can be claimed once at close range, records exactly `20 Gears`,
  persists `central_tower_inner_cache_claimed=true`, updates feedback/objective,
  and never changes the exact unlocked-ability set.
- [x] Lethal damage before clear revives at the Threshold Roost after `1.5s` at
  50% HP with existing `2.0s / 120` frame protection; relay/Mantis attempt state,
  hitboxes, seals, HP, and authored position reset. A Mantis defeated during the
  death window, or an already cleared/cache-claimed room, remains durable.
- [x] One focused RED/GREEN suite, one Story140 adjacent regression, one target
  headless smoke, and one final Godot MCP run verify the complete sequence,
  generated assets, animation states, persistence, non-empty screenshot, and no
  new current-run errors. No full suite is required.

## Stable Contract

| Contract | Value |
|----------|-------|
| Scene | `area_05_central_tower` / `central_tower_threshold.tscn` |
| Scene size | `2560x720` |
| Activation x | `1500` |
| Relay clear | `central_tower_inner_relay_parried` |
| Mantis entity / config | `2702` / `central_tower_relay_mantis` |
| Mantis clear | `central_tower_relay_mantis_defeated` |
| Cache / reward | `central_tower_inner_relay_cache` / `20 Gears` |
| Cache clear | `central_tower_inner_cache_claimed` |

## Test Evidence Contract

- Focused suite:
  `tests/unit/gameplay/central_tower_inner_relay_skirmish_test.gd`
  - Authored/data/assets/animation/geometry contract.
  - Real relay parry, Mantis attack/damage/defeat, cache claim, no-new-ability
    contract.
  - Miss damage, death/revive failed-attempt reset, death-window durable clear,
    and restore without replay.
- Headless smoke:
  `tests/smoke/central_tower_inner_relay_skirmish_smoke.gd`; starts directly in
  `area_05_central_tower` with Story140 clear, completes the one-parry combat
  loop, claims the cache, and restores the same scene state once.
- MCP evidence:
  `production/qa/evidence/central-tower-inner-relay-skirmish-2026-07-12.md`.

## Completion Evidence

- RED `report_1503`; focused GREEN `report_1507` (`3/3`); independent review
  rerun `report_1508` (`3/3`); Story140 adjacent GREEN `report_1509` (`3/3`).
- Target smoke marker:
  `central_tower_inner_relay_skirmish_smoke=passed`.
- Godot MCP `2.9.1` / Godot `4.7-stable` run `65` used real `parry` input,
  inspected the live `AnimatedSprite2D` Mantis and six three-frame animations,
  captured a non-empty `1278x718` Service Spine combat frame, and returned no
  current-run game error or new editor row after cursor `3`.

## Out Of Scope

- Boss4, Boss arena, phases, Boss data/art/music/reward, ending content.
- Third viewport, new scene id/handoff, second Roost, new ability, NPC/dialogue,
  minimap, fast travel, secret room, or global economy implementation.
- Shared SceneManager, SaveSystem, Combat, Ability, or Audio refactors.
- Rebalancing Story139 outer parry trial or Story140 Threshold Guard.

## Dependencies

- Depends on: Story140 Central Tower Threshold Guard Handoff. Complete.
- Unlocks: a future bounded deeper-Tower route contract; no Boss contract is
  implied.
