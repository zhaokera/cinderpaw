# Story 008: Damage Number Tier Polish

> **Epic**: Combat Presentation
> **Status**: Complete
> **Layer**: Presentation
> **Type**: Visual/Feel
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-24

## Context

**GDD**: `design/gdd/combat-presentation.md`
**Requirements**: `TR-combatfx-005`, `TR-combatfx-007`
**ADR Governing Implementation**: ADR-0001: Autoload architecture; ADR-0002: Signal communication

Stories 001-007 replaced prototype combat VFX blocks, added Cinderpaw and
Shadow Beast frame-animation contracts, and textured the remaining PERFECT
parry flash. Damage numbers still use only a simplified color path and do not
represent all six GDD damage tiers. This story polishes the existing Label-based
damage-number presentation without changing Core damage, weapon balance, enemy
HP, or HUD settings persistence.

## Acceptance Criteria

- [x] `on_hit_event()` maps damage values `1`, `6`, `16`, `31`, `61`, and
  `151` to six GDD tiers with font sizes `12`, `16`, `20`, `28`, `36`, and
  `48`.
- [x] Damage-number color communicates tier: `1-15` white, `16-30` yellow,
  `31-60` gold, `61+` cat-eye gold, and `151+` adds a white outline or
  equivalent readability boost.
- [x] Each damage number records a 30px upward float distance and a 1.5 second
  lifetime, then leaves the active damage-number list when its lifetime expires.
- [x] `show_damage_number=false` still suppresses only the Label, not hitstop,
  screen shake, hit sparks, or other impact feedback.
- [x] Boundary values are safe: `damage<=0` displays as tier-1 damage and
  `damage>999` uses the highest tier without empty text or runtime errors.
- [x] Ten rapid hit events create ten active damage numbers and clean them all
  after their lifetime without leaving stale nodes in the active list.
- [x] Godot MCP runs `res://scenes/main.tscn`, triggers representative damage
  numbers, checks logs, and captures a nonblank screenshot while preserving the
  Story 007 main-scene `AnimatedSprite2D` visual contract.

## Out of Scope

- Boss phase feedback, boss phase Health signal wiring, metal debris, dark
  vignette, and boss transition hitstop.
- Slow-motion effects for legendary damage; this remains an open GDD question.
- Core damage formulas, crit chance, enemy HP, weapon tuning, or hit-confirm
  gameplay rules.
- HUD settings persistence and menu controls for damage-number toggles.
- Colorblind particle remaps, low-HP focus shake reduction, audio, or new
  character frame-animation states.

## Test Evidence

**Required evidence**:
- `tests/unit/presentation/combat_presentation_test.gd`

**Status**: [x] RED/GREEN + MCP runtime evidence complete

- RED: focused `CombatPresentation` suite failed before implementation because
  the `31`, `61`, and `151` tiers did not have the GDD color/size/outline
  styling (`reports/report_355/`).
- GREEN:
  - Focused presentation suite passed `17/17`, exit `0`
    (`reports/report_356/`).
  - Related runtime/presentation regression passed `26/26`, exit `0`
    (`reports/report_357/`).
- Headless smoke: `res://scenes/main.tscn` exited `0`, and log scan found no
  error/warning matches in `reports/damage_number_story008_main_scene_smoke.log`.
- Godot MCP: ran `res://scenes/main.tscn`; runtime probe triggered
  `final_damage=151` and returned `active_damage_numbers=1`, `last_text="151"`,
  `last_font_size=48`, `last_color="ecc94b"`, `last_outline_size=2`,
  `last_float_distance=30`, `last_lifetime=1.5`, clean game/editor logs, and
  Player/Enemy `AnimatedSprite2D` contract intact.
- Screenshot:
  `reports/visual/cinderpaw-mcp-damage-number-tier-polish-20260624.png`.
- QA evidence:
  `production/qa/evidence/damage-number-tier-polish-2026-06-24.md`.

## Dependencies

- Depends on: Story 001 hit feedback and Story 007 main-scene visual contract.
- Unlocks: boss phase feedback, colorblind remaps, and performance-budget checks.
