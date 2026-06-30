# Story 026: Boss2 Arena Bounds Reset Runtime

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Core / Feature / AI Runtime / Gameplay Runtime
> **Type**: Integration + Gameplay Runtime + Combat Feel
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-30

## Context

**GDD**: `design/gdd/ai-framework.md`, `design/gdd/feline-combat.md`,
`design/gdd/boss-config.md`, `design/gdd/player-abilities.md`,
`design/gdd/scene-management.md`

**Requirements**: `TR-ai-001`, `TR-ai-007`, `TR-ai-008`,
`TR-ability-005`

**ADR Governing Implementation**: ADR-0002 Signal communication; ADR-0004
Collision detection; ADR-0005 Combat state machine; ADR-0006 AI behavior
system architecture; ADR-0007 Scene management; ADR-0018 Player abilities;
ADR-0021 Save system architecture.

Stories021-025 made Boss2 visible, reward-bearing, dangerous, HUD-focused,
autonomously pressuring, and animated during chase. The remaining rough edge is
encounter containment: Boss2 can be manually or deterministically moved outside
its intended local combat space, and there is no explicit runtime reset
diagnostic for returning the boss to its arena anchor.

This story adds the smallest Boss2 arena semantics needed for a playable
main-scene encounter: Boss2 chases inside a local horizontal arena, returns to
its spawn anchor when the player leashes out, and reset/restore paths leave it
in a predictable non-sliding state.

## Acceptance Criteria

- [x] Boss2 exposes arena diagnostics through `get_auto_pressure_diagnostics()`,
  including arena min/max x, anchor position, and whether it is returning to
  anchor.
- [x] Boss2's autonomous chase clamps its x position inside the local Boss2
  arena bounds and does not drift past the left/right arena limits.
- [x] If the current target is outside the aggro/leash range while Boss2 is
  undefeated, Boss2 returns toward its arena anchor instead of continuing chase
  pressure.
- [x] Once Boss2 reaches the anchor during leash return, it reports idle,
  clears return velocity, and does not leave the sprite stuck in `run`.
- [x] `reset_encounter()` restores Boss2 to its arena anchor, clears active
  hitboxes, and preserves the Story025 `idle/run/attack/hurt/death` animation
  contract.
- [x] Defeated/restored-defeated Boss2 still disables movement, hitboxes, and
  HUD focus as in Stories021-025.
- [x] Focused RED/GREEN tests, related Boss2 regression, headless smoke, and
  Godot MCP runtime screenshot/log evidence are recorded.

## Out of Scope

- New arena art, camera scripting, cutscene, locked boss door, or full arena
  layout rebuild.
- Multi-phase Boss2 AI, new attacks, summon patterns, navigation/pathfinding,
  authored music/SFX, final balancing, or Boss2 portrait/HP-bar polish.
- Generic boss arena manager, new Autoload, EventBus, or save schema migration.

## Implementation Notes

- Keep the behavior scene-local to `Boss2EchoGuardian`.
- Use deterministic frame stepping for tests; avoid timers, random selection, or
  NavigationAgent2D.
- Preserve existing Story021 reward, Story022 hitbox/damage, Story023 HUD focus,
  Story024 autonomous pressure, and Story025 run animation semantics.
- Clamp only Boss2's local movement; do not lock or teleport the Player.
- MCP evidence must prove scene load, arena diagnostics, bounded movement,
  leash return, clean logs, and a nonblank screenshot.

## Test Evidence

**Required evidence**:

- `tests/unit/gameplay/boss2_arena_bounds_reset_runtime_test.gd`
- `tests/unit/gameplay/boss2_autonomous_pressure_runtime_test.gd`
- `tests/unit/gameplay/boss2_hud_focus_runtime_test.gd`
- `tests/unit/gameplay/boss2_double_jump_payoff_runtime_test.gd`
- Godot MCP runtime evidence under
  `production/qa/evidence/boss2-arena-bounds-reset-runtime-2026-06-30.md`

**Status**: [x] Complete. RED/GREEN focused evidence, related regression,
headless smoke, and MCP runtime evidence are recorded in
`production/qa/evidence/boss2-arena-bounds-reset-runtime-2026-06-30.md`.

## Test-Criterion Traceability

| Criterion | Test / Evidence | Status |
|-----------|-----------------|--------|
| Arena diagnostics exposed | `tests/unit/gameplay/boss2_arena_bounds_reset_runtime_test.gd`, MCP runtime probe | PASS |
| Chase clamps inside arena | `reports/report_808/`, MCP runtime probe | PASS |
| Leash target returns Boss2 to anchor | `reports/report_808/`, MCP runtime probe | PASS |
| Anchor return settles idle/non-run | `reports/report_808/`, MCP runtime probe | PASS |
| `reset_encounter()` restores anchor and cleanup | `reports/report_808/`, `reports/report_814/`, MCP runtime probe | PASS |
| Defeated/restored defeated behavior preserved | `reports/report_808/`, `reports/report_810/`-`report_816/` | PASS |
| Focused/related tests and MCP evidence recorded | QA evidence 2026-06-30 | PASS |

## Implementation Summary

- `Boss2EchoGuardian` now records an arena anchor at ready time, exposes
  `arena_anchor_position`, `arena_min_x`, `arena_max_x`,
  `is_returning_to_anchor`, and `is_at_anchor` in diagnostics, and clamps
  autonomous chase inside a 320px-wide local arena centered on the anchor.
- When the target is outside the aggro/leash window, undefeated Boss2 returns
  toward the arena anchor with the existing Story025 `run` animation and settles
  back to `idle` once it reaches the anchor.
- `reset_encounter()` now restores Boss2 to its arena anchor and clears
  movement pressure. `capture_respawn_snapshot()` /
  `restore_respawn_snapshot()` were added so `MainScene` arena reset can restore
  Boss2 HP, collision, hitbox, hurtbox, status, sprite, facing, and anchor state.
- `MainScene.capture_boss_arena_snapshot()` now includes live Boss2 snapshot
  data, and `reset_boss_arena_to_snapshot()` restores Boss2 unless the defeated
  world flag says it should remain defeated and hidden.

## Verification Summary

- RED: `reports/report_800/` failed `3/3` before arena diagnostics and clamp
  behavior existed; `reports/report_804/` failed the MainScene Boss2 snapshot
  reset case before `capture_boss_arena_snapshot()` included Boss2 state.
- GREEN focused: `reports/report_808/` passed Story026 `5/5`.
- Related regression: `reports/report_810/` passed Boss2 autonomous pressure
  `6/6`; `reports/report_811/` passed Boss2 HUD focus `4/4`;
  `reports/report_812/` passed Boss2 Double Jump payoff `3/3`;
  `reports/report_813/` passed Boss2 telegraph strike `4/4`;
  `reports/report_814/` passed GameFlow boss respawn reset `5/5`;
  `reports/report_815/` passed simple enemy respawn reset `1/1`;
  `reports/report_816/` passed no-loss respawn contract `2/2`.
- Headless smoke: `reports/boss2_arena_bounds_reset_runtime_main_scene_smoke.log`
  exited `0`; keyword scan found no script, parse, invalid-call, missing
  resource, or resource-load errors.
- Godot MCP: runtime probe on `res://scenes/main.tscn` confirmed `/root/Main`,
  `/root/Main/Boss2EchoGuardian`, `AnimatedSprite2D + SpriteFrames`, `run`
  frame count `3`, arena anchor `(520, 482)`, arena x bounds `360..680`,
  chase clamp, leash return to idle, MainScene Boss2 snapshot reset, defeated
  progress preservation, game screenshot metadata, and no MCP log errors.
- Screenshot: `reports/visual/cinderpaw-mcp-boss2-arena-bounds-reset-runtime-20260630.png`
  is `1280x720` and nonblank by pixel inspection.
