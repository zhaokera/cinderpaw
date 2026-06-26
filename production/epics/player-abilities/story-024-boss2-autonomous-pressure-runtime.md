# Story 024: Boss2 Autonomous Pressure Runtime

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Core / Feature / AI Runtime / Gameplay Runtime
> **Type**: Integration + Gameplay Runtime + Combat Feel
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-26

## Context

**GDD**: `design/gdd/ai-framework.md`, `design/gdd/feline-combat.md`,
`design/gdd/boss-config.md`, `design/gdd/player-abilities.md`

**Requirements**: `TR-ai-001`, `TR-ai-007`, `TR-ai-008`,
`TR-ability-005`

**ADR Governing Implementation**: ADR-0002 Signal communication; ADR-0004
Collision detection; ADR-0005 Combat state machine; ADR-0006 AI behavior
system architecture; ADR-0007 Scene management; ADR-0018 Player abilities;
ADR-0021 Save system architecture.

Story021 made Boss2 visible and reward-bearing. Story022 gave Boss2 a readable
`boss2_echo_swipe`, but the attack still only pressures the player once the
player is already inside a tight attack range. From the playable main-scene
start, Boss2 is visible but too passive.

This story adds the smallest autonomous pressure loop: while Boss2 is visible,
undefeated, and has the Player target, it slowly closes horizontal distance
inside an aggro window, then automatically enters the existing
`boss2_echo_swipe` startup/active/recovery chain. It does not add new attack
patterns or new art.

## Acceptance Criteria

- [x] From the current `res://scenes/main.tscn` placement, Boss2 autonomously
  moves toward the Player while outside `boss2_echo_swipe` range but inside the
  aggro window.
- [x] Boss2 exposes deterministic diagnostics/test hooks for the pressure loop:
  `advance_behavior_frames(frames)` and `get_auto_pressure_diagnostics()`.
- [x] Once Boss2 reaches attack range, it enters the existing startup phase
  without a direct `request_attack()` call; startup remains readable and the
  hitbox is inactive.
- [x] The autonomous attack can reach active frames and still damages the
  Player exactly once through the existing Core Collision/Combat path.
- [x] Boss2 defeat or restored defeated world flag disables autonomous chase,
  hitboxes, and new pressure diagnostics while preserving Story021 reward and
  Story023 HUD behavior.
- [x] Godot MCP verifies main-scene runtime Boss2 chase/attack pressure, clean
  logs, and a nonblank screenshot.

## Out of Scope

- New Boss2 art, `run` animation, boss portrait, HP-bar polish, authored music
  or SFX.
- Multi-phase AI, summon patterns, navigation/pathfinding, wall avoidance,
  arena boundaries, or final Boss2 balancing.
- A generic boss target selector, new Autoload, EventBus, or BehaviorTree.

## Implementation Notes

- Keep the behavior scene-local to `Boss2EchoGuardian`.
- Reuse the existing `boss2_echo_swipe` attack, Core `CollisionComponent`, and
  MainScene presentation/audio routing.
- Use deterministic frame stepping for tests; avoid timers or random selection.
- If movement needs a placeholder visual, keep it on the existing `idle`
  animation and record that a future Boss2 polish story should generate a
  proper `run`/`chase` animation.

## Test Evidence

**Required evidence**:

- `tests/unit/gameplay/boss2_autonomous_pressure_runtime_test.gd`
- `tests/unit/gameplay/boss2_echo_guardian_telegraph_strike_test.gd`
- `tests/unit/gameplay/boss2_hud_focus_runtime_test.gd`
- `tests/unit/gameplay/boss2_double_jump_payoff_runtime_test.gd`
- Godot MCP runtime evidence under
  `production/qa/evidence/boss2-autonomous-pressure-runtime-2026-06-26.md`

**Status**: [x] RED/GREEN focused evidence, related regression, headless smoke,
and MCP runtime evidence captured.

## Test-Criterion Traceability

| Criterion | Test / Evidence | Status |
|-----------|-----------------|--------|
| Main-scene Boss2 chase from start distance | `boss2_autonomous_pressure_runtime_test`; MCP probe | PASS |
| Deterministic diagnostics/test hooks | `boss2_autonomous_pressure_runtime_test` | PASS |
| Autonomous startup without direct request | `boss2_autonomous_pressure_runtime_test`; MCP probe | PASS |
| Active autonomous hit damages once | `boss2_autonomous_pressure_runtime_test`; Story022 regression | PASS |
| Defeat/restore disables pressure | `boss2_autonomous_pressure_runtime_test`; Story021/023 regressions | PASS |
| MCP runtime logs and screenshot verified | QA evidence | PASS |

## Implementation Summary

`Boss2EchoGuardian` now has the smallest scene-local pressure loop needed for a
playable mainline Boss2 threat. While visible, undefeated, inside the aggro
window, and outside `boss2_echo_swipe` range, it closes horizontal distance by a
deterministic 3 px frame step, reports `behavior_phase="chase"`, then enters the
existing startup/active/recovery attack chain when it reaches range.

No new visual assets were generated. This story reuses the Story021
image-generated Boss2 `AnimatedSprite2D + SpriteFrames` assets and keeps the
temporary chase presentation on the existing `idle` animation until a dedicated
Boss2 run/chase animation story lands.

## Verification Summary

- RED focused: `reports/report_784/`
  - Expected failure: missing `advance_behavior_frames()` and
    `get_auto_pressure_diagnostics()`.
- Post-review RED: `reports/report_787/`
  - Expected failure: stale released attack target still reported valid and
    allowed manual `request_attack()` to enter startup.
- Final GREEN focused: `reports/report_788/`
  - Story024 Boss2 autonomous pressure: `5/5`.
- Final related regression: `reports/report_789/`
  - Story024 autonomous pressure: `5/5`.
  - Story022 telegraph strike: `4/4`.
  - Story023 HUD focus: `4/4`.
  - Story021 Double Jump payoff: `3/3`.
  - Total: `16/16`.
- Headless smoke:
  `reports/boss2_autonomous_pressure_runtime_main_scene_smoke.log`
  exited `0`; keyword scan found no script, parse, invalid-call, missing
  resource, or resource-load errors.
- Godot MCP runtime verified chase diagnostics, automatic startup, inactive
  startup hitbox, active hitbox damage `100 -> 86`, duplicate hit suppression,
  stale target rejection, defeated-flag shutdown, HUD fallback, clean logs, and
  screenshot
  `reports/visual/cinderpaw-mcp-boss2-autonomous-pressure-runtime-20260626.png`.
