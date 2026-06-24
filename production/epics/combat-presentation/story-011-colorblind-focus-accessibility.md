# Story 011: Colorblind Combat VFX + Focus Shake Accessibility

> **Epic**: Combat Presentation
> **Status**: Complete
> **Layer**: Presentation
> **Type**: Accessibility/Integration
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-24

## Context

**GDD**: `design/gdd/combat-presentation.md`
**Requirements**: `TR-combatfx-008`, `TR-combatfx-009`
**ADR Governing Implementation**: ADR-0002: Signal communication

Combat Presentation currently renders textured hit sparks, parry sparks, claw
trails, kill debris, and boss phase debris with fixed colors. The HUD already
owns runtime colorblind settings, while HealthComponent already emits low-HP
focus mode changes. This story connects those existing runtime states to combat
feedback without changing combat rules.

## Acceptance Criteria

- [x] `CombatPresentation` exposes `set_colorblind_mode(mode: StringName)` and
  `get_colorblind_mode()` using the existing `none`, `red_green`, and
  `blue_yellow` modes; invalid values fall back to `none`.
- [x] New particles spawned after a colorblind-mode switch use the current
  accessibility palette for normal hit sparks, critical hit sparks, perfect
  parry sparks, cat-claw trails, kill debris, boss phase 2 debris, and boss
  phase 3 overload debris.
- [x] Colorblind remapping does not change particle counts, textures,
  lifetimes, hitstop, or screen-shake duration.
- [x] `HUDManager.set_colorblind_mode()` emits a runtime setting change and
  `MainScene` forwards it to `CombatPresentation`; save/restore settings also
  resync the combat palette.
- [x] `CombatPresentation.on_focus_mode_changed(entity_id, active, metadata)`
  consumes the existing HealthComponent-style signal and reduces subsequent
  screen-shake intensity by 30% while focus is active.
- [x] Focus-mode shake scaling preserves existing duration, hitstop, particle
  counts, and same-frame maximum-intensity aggregation.
- [x] `MainScene` forwards `Player/HealthComponent.on_focus_mode_changed` to
  `CombatPresentation` without Presentation directly querying Core/Feature
  nodes.
- [x] Godot MCP runs `res://scenes/main.tscn`, toggles colorblind/focus states,
  checks clean logs, and captures nonblank screenshots showing representative
  combat VFX.

## Accessibility Palette

| Particle Semantic | Default | `red_green` | `blue_yellow` |
|---|---:|---:|---:|
| Normal hit / neutral spark | `#FFF0C2` | `#4299E1` | `#FED7D7` |
| Crit / claw / gold emphasis | `#ECC94B` / `#FFE67A` | `#F6E05E` | `#F97316` |
| Perfect parry spark | `#FFF5B8` | `#F6E05E` | `#FFFFFF` |
| Kill / danger debris | `#C72E29` | `#D69E2E` | `#E53E3E` |
| Boss phase metal / overload debris | `#6B8A9E` / `#E53E3E` | `#2B6CB0` / `#F6E05E` | `#F97316` / `#FFFFFF` |

## Out of Scope

- Changing HealthComponent focus thresholds, hysteresis, or combat state rules.
- Changing CombatComponent focus crit windows or AI focus behavior.
- Changing HUD menu structure, HUD HP palette semantics, particle textures,
  particle counts, lifetimes, hitstop values, or damage-number tiers.
- Retroactively recoloring already-spawned short-lived particles.
- Audio, boss HUD banners, or new generated image assets.

## Test Evidence

**Required evidence**:
- `tests/unit/presentation/combat_presentation_test.gd`
- `tests/unit/gameplay/main_scene_hud_settings_runtime_test.gd`
- Godot headless smoke for `res://scenes/main.tscn`
- Godot MCP runtime probe and screenshot evidence

**Status**: [x] RED/GREEN + MCP runtime evidence complete

**Evidence**:

- RED: `reports/report_370/` failed because `CombatPresentation` lacked the
  colorblind/focus APIs and MainScene did not yet sync HUD accessibility state
  into combat particles.
- GREEN: `reports/report_372/` passed focused CombatPresentation and MainScene
  HUD settings tests `27/27`.
- Regression: `reports/report_373/` passed CombatPresentation, MainScene HUD
  settings, MainScene attack chains, MainScene visual contract, Health focus,
  and Boss phase signal contract tests `44/44`.
- Headless smoke: `reports/combat_presentation_tr008_009_main_scene_smoke.log`
  exited `0`; log scan found no error or warning matches.
- Godot MCP: ran `res://scenes/main.tscn`, toggled `none` / `red_green` /
  `blue_yellow`, triggered hit/parry/kill/boss phase VFX, emitted
  `Player/HealthComponent.on_focus_mode_changed`, observed focus hit shake
  `1.4` for `3` frames, verified Player and Enemy `AnimatedSprite2D`
  SpriteFrames have at least 3 frames per gameplay animation, found `0`
  presentation `ColorRect` nodes, clean game/editor logs, and saved screenshots:
  `reports/visual/cinderpaw-mcp-combatfx-default-hit-20260624.png`,
  `reports/visual/cinderpaw-mcp-combatfx-red-green-20260624.png`,
  `reports/visual/cinderpaw-mcp-combatfx-blue-yellow-20260624.png`, and
  `reports/visual/cinderpaw-mcp-combatfx-focus-hit-20260624.png`.
- QA evidence:
  `production/qa/evidence/colorblind-focus-accessibility-2026-06-24.md`.

## Dependencies

- Depends on: HUD accessibility settings and HealthComponent focus-mode signal.
- Unlocks: broader accessibility QA pass and combat presentation performance
  budget verification.

## Completion Notes

**Completed**: 2026-06-24
**Criteria**: 8/8 passing
**Deviations**: No new image asset was required; this story remaps existing
textured particles and focus-mode shake state. Existing short-lived particles
are not recolored retroactively after runtime mode switches.
