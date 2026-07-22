# Story 180: Sluice Matriarch Shared Death and Retry Flow

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Boss Combat / Death and Respawn
> **Type**: Integration + Gameplay Runtime + Death/Respawn + Visual Feedback
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-20

## Context

Story128 made the Sluice Matriarch a playable Boss3 encounter, but player death
still used an arena-local deferred reset that immediately restored full HP. That
bypassed the shared death/retry timing, Boss-entry respawn selection, 50% revive
HP, protection window and existing death/revive presentation required by the
GDDs.

This Story mounts the existing `GameFlowController` in the Boss3 arena and
implements the arena snapshot/reset hooks it already uses for other Boss
encounters. It keeps Sluice Matriarch combat ownership in the arena and does not
fork a Boss3-specific retry state machine.

**GDD**: `design/gdd/death-respawn.md`, `design/gdd/health-death.md`,
`design/gdd/combat-presentation.md`, `design/gdd/boss-config.md`, and
`design/gdd/scene-management.md`.

**Governing ADRs**: ADR-0002 Signal Communication; ADR-0004 Collision
Detection; ADR-0005 Combat State Machine; ADR-0007 Scene Management; ADR-0019
Health/Death; ADR-0020 Damage Calculator.

## Acceptance Criteria

- [x] The Boss3 arena owns one shared `GameFlowController`, configures
  `boss_03_sluice_matriarch_arena/boss_entry`, and captures its encounter-entry
  snapshot before combat retry handling begins.
- [x] Lethal player damage enters `dying`, locks control, plays the existing
  multi-frame `death` animation, starts grayscale/death wisps, and keeps the
  active Boss HP, phase and attack state unchanged through `1.49s`.
- [x] Crossing the `1.5s` boundary revives Cinderpaw at `BossEntrySpawn` with
  `50/100` HP, the existing `revive` animation and one golden revive halo.
- [x] Retry restores the Sluice Matriarch to the encounter snapshot: `120/120`
  HP, Phase I, authored `(930, 540)` anchor, idle attack state and no active
  pressure-lunge hitbox.
- [x] The shared `2.0s` protection contract locks control and grants the
  existing `120` HealthComponent i-frames. Damage is rejected before expiry;
  after expiry flow returns to `playing`, control unlocks and damage applies.
- [x] Room seals and scene lock remain active during the retry. Reward and
  Factory return routes remain unavailable until a real Boss defeat.
- [x] Existing player and Boss `AnimatedSprite2D + SpriteFrames` resources and
  CombatPresentation death/revive effects are reused; no placeholder or new
  visual asset is introduced.
- [x] One intentional RED, focused GREEN, bounded related regression, Godot
  4.7 headless smoke and Godot AI MCP 3.0.4 runtime acceptance provide evidence.

## Out Of Scope

- No Sluice Matriarch balance, attack schedule, Phase II presentation, reward,
  persistence, route or arena-art changes.
- No new save fields, new character frames, audio asset, mercy mechanic or
  battle-summary UI.
- No change to the shared contract that keeps control locked for the same two
  seconds as revive protection.
- The obscured Old Factory pressure valve remains a separate image-generation
  presentation Story.

## Implementation Notes

- `scenes/bosses/sluice_matriarch_arena.tscn` mounts the shared
  `GameFlowController` script as an arena child.
- `src/gameplay/sluice_matriarch_arena.gd` configures the Boss-entry respawn,
  routes player death into `handle_player_death()`, and responds to
  `respawn_requested` through the player's public `respawn_at()` path.
- Arena snapshot hooks restore Boss3 through its existing `reset_encounter()`
  API, clear collision hitboxes/adapters and retain sealed encounter ownership.
- Retry diagnostics and deterministic time advancement are bounded test/MCP
  seams over the production shared flow; they do not implement parallel state.
- The obsolete immediate-full-HP test was replaced by the dedicated shared-flow
  acceptance test.

## Test Evidence

- Intentional RED `reports/report_2054/results.xml`: one new acceptance test
  recorded two expected failures for the missing arena retry diagnostics and
  deterministic advancement interfaces.
- Intermediate `reports/report_2055/results.xml` proved the core shared flow but
  was not accepted because the test expected stale presentation phase names.
- Focused GREEN `reports/report_2058/results.xml`: the Story180 suite passed
  `1/1` with zero failures, errors, flaky cases, skips or orphans.
- Post-upgrade focused verification `reports/report_2060/results.xml` repeated
  the Story180 suite at `1/1` with the same zero-count result and exit code `0`
  after the project-local Godot AI MCP 3.0.4 update.
- Related GREEN `reports/report_2059/results.xml`: five shared-flow, Boss3,
  presentation and arena-handoff suites passed `14/14` with zero failures,
  errors, flaky cases, skips or orphans.
- Godot 4.7 loaded the Boss3 arena headlessly for `180` frames and exited `0`
  without parse, script, invalid-call or missing-resource errors.
- Godot AI MCP 3.0.4 session `cinderpaw@36ea`, accepted run `r4500195-2`,
  verified the runtime node, exact death/revive boundaries, Boss reset,
  protection rejection/expiry, clean logs and ready stop state.
- The non-empty opaque RGB `1278x718` revive screenshot is stored at
  `reports/visual/cinderpaw-mcp-sluice-matriarch-shared-revive-protection-20260720.png`.
- Full traceability is recorded in
  `production/qa/evidence/sluice-matriarch-shared-death-retry-flow-2026-07-20.md`.

## Completion Notes

- Completed 2026-07-20 as a bounded Boss3 integration of the existing shared
  death/retry system and presentation.
- No new visual asset was needed. The next player-visible slice should replace
  the obscured Old Factory pressure valve with image-generated authored
  presentation without changing its existing interaction contract.
