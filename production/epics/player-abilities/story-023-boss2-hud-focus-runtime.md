# Story 023: Boss2 HUD Focus Runtime

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Core / Feature / Gameplay Runtime / Presentation Integration
> **Type**: Integration + Gameplay Runtime + HUD/Feel
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-26

## Context

**GDD**: `design/gdd/hud-ui.md`, `design/gdd/player-abilities.md`,
`design/gdd/boss-config.md`

**Requirements**: `TR-ability-005`, `TR-hud-001`, `TR-hud-002`,
`TR-hud-007`

**ADR Governing Implementation**: ADR-0002 Event bus and signals; ADR-0007
Scene management; ADR-0018 Player abilities; ADR-0021 Save system architecture.

Story021 and Story022 made Boss2 visible, damageable, and threatening, but the
main scene HUD still focused the existing Rat King boss panel. When the player
fights the generated `Boss2EchoGuardian`, the top boss strip can therefore show
`垃圾桶鼠王 Phase I 300/300`, which is incorrect and weakens combat readability.

This story makes the existing boss HUD focus the active Boss2 threat while
Boss2 is present and not defeated, update when Boss2 HP changes, and hand back
to the existing Rat King HUD state after Boss2 is defeated or restored as
already defeated.

## Acceptance Criteria

- [x] While Boss2 is present, visible, and not defeated, the top boss HUD label
  shows `Echo Guardian` with Boss2 HP `36/36` instead of Rat King HP.
- [x] Boss2 HP changes update the existing boss HUD strip immediately, e.g.
  damage `14` changes the label to `22/36`.
- [x] Rat King HP/phase updates do not override Boss2 HUD focus while Boss2 is
  still active.
- [x] Once Boss2 is defeated or restored from a defeated world flag, the HUD no
  longer presents Boss2 as active and can fall back to the existing Rat King
  boss HUD state.
- [x] The Story021 Double Jump reward path and Story022 attack threat remain
  unchanged.
- [x] Godot MCP verifies the runtime HUD label, Boss2 HP update, Boss2 defeat
  fallback, clean logs, and a nonblank screenshot.

## Out of Scope

- New HUD art, boss portrait, HP-bar animation polish, boss arena layout,
  multi-phase Boss2 UI, or authored Boss2 music/SFX.
- New visual assets. This slice reuses the existing HUD and Story021/Story022
  Boss2 generated sprite assets.
- Full boss encounter manager or generic boss target selector.

## Implementation Notes

- Reuse `HUDManager.update_boss_hp()` and `HUDManager.get_boss_label_text()`.
- Keep Boss2 HUD focus scene-local inside `MainScene`; do not add a new Autoload
  or global EventBus.
- Prefer a small `MainScene` refresh helper that selects Boss2 while active and
  Rat King otherwise.

## Test Evidence

**Required evidence**:

- `tests/unit/gameplay/boss2_hud_focus_runtime_test.gd`
- `tests/unit/gameplay/boss2_echo_guardian_telegraph_strike_test.gd`
- `tests/unit/gameplay/boss2_double_jump_payoff_runtime_test.gd`
- Godot MCP runtime evidence under
  `production/qa/evidence/boss2-hud-focus-runtime-2026-06-26.md`

**Status**: [x] RED/GREEN focused evidence, related regression, headless smoke,
and MCP runtime evidence complete.

- RED focused: `reports/report_778/` failed as expected because the HUD still
  displayed `垃圾桶鼠王  Phase I  300/300` on main-scene start while Boss2 was
  the active visible threat.
- GREEN focused: `reports/report_782/` passed Story023 `4/4` after adding the
  direct restored-defeated-flag coverage path.
- Initial related regression: `reports/report_780/` passed `10/10` across
  Story023, Story022 Boss2 telegraph strike, and Story021 Boss2 Double Jump
  payoff tests.
- Final post-review related regression: `reports/report_783/` passed `11/11`
  across the same suites.
- Headless smoke:
  `reports/boss2_hud_focus_runtime_main_scene_smoke.log` exited `0`; keyword
  scan found no script, parse, invalid-call, missing-resource, or resource-load
  errors.
- Godot MCP evidence:
  `production/qa/evidence/boss2-hud-focus-runtime-2026-06-26.md`.
- MCP runtime screenshot:
  `reports/visual/cinderpaw-mcp-boss2-hud-focus-runtime-20260626.png`.

## Test-Criterion Traceability

| Criterion | Test / Evidence | Status |
|-----------|-----------------|--------|
| Initial Boss2 HUD focus | `boss2_hud_focus_runtime_test`; MCP probe | COVERED |
| Boss2 HP update | `boss2_hud_focus_runtime_test`; MCP probe | COVERED |
| Rat King does not override active Boss2 | `boss2_hud_focus_runtime_test`; MCP probe | COVERED |
| Boss2 defeat/restore fallback | `boss2_hud_focus_runtime_test`; MCP probe | COVERED |
| Reward and attack regressions | Story021/Story022 focused tests | COVERED |
| MCP runtime logs and screenshot verified | QA evidence | COVERED |

## Completion Notes

**Completed**: 2026-06-26
**Criteria**: 6/6 passing
**Deviations**: This story corrects the existing boss HUD focus selector only.
It does not add new HUD art, boss portraits, HP-bar animation polish, arena
layout, music, SFX, or a generic boss target manager.
**QA Evidence**:
`production/qa/evidence/boss2-hud-focus-runtime-2026-06-26.md`
