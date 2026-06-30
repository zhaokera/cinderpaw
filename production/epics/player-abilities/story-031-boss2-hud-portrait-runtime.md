# Story 031: Boss2 HUD Portrait Runtime

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Presentation / Gameplay Runtime / Visual
> **Type**: Integration + HUD Visual Polish
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-30

## Context

**GDD**: `design/gdd/hud-ui.md`, `design/gdd/player-abilities.md`,
`design/gdd/boss-config.md`, `design/gdd/combat-presentation.md`

**Requirements**: `TR-ability-005`, `TR-boss-004`, `TR-combatfx-001`

**ADR Governing Implementation**: ADR-0002 Signal communication; ADR-0005
Combat state machine; ADR-0010 Combat presentation; ADR-0018 Player abilities.

Stories021-030 made Boss2 visible, animated, threatening, framed by arena art,
camera-locked, room-sealed, and connected to the Double Jump payoff. The Boss
HUD still read as a generic text strip. This story adds a compact generated
Boss2 portrait to the existing Boss HUD while Echo Guardian is the active focus,
then clears it when the HUD hands back to Rat King.

## Acceptance Criteria

- [x] `HUDManager` exposes deterministic Boss portrait diagnostics for tests and
  MCP probes, including visibility, panel visibility, texture path, texture
  size, and display rect size.
- [x] While Boss2 is the active HUD focus, the Boss HUD shows an image-generated
  Echo Guardian portrait using a transparent 128x128 PNG under
  `assets/ui/boss_portraits/`.
- [x] The portrait is displayed as a compact HUD element no larger than 64x64,
  preserving the top-center boss strip layout and existing HUD scale overlap
  rules.
- [x] When Boss2 is defeated or restored as defeated, the Boss HUD does not keep
  a stale Boss2 portrait while the label hands back to Rat King.
- [x] Existing Boss2 focus, hit-flash, arena visual, and HUD settings behavior
  remain unchanged.
- [x] Focused RED/GREEN tests, related HUD/Boss2 regression, headless smoke, and
  Godot MCP runtime evidence are recorded.

## Out of Scope

- Full Boss HUD redesign, Rat King portrait replacement, animated portraits,
  boss phase portraits, new boss music, camera rails, minimap markers, or
  multi-phase Boss2 AI.

## Implementation Notes

- Keep this in `HUDManager`; do not introduce a new HUD portrait manager.
- Display the portrait only for the current `Echo Guardian` Boss HUD focus.
- Use `TextureRect.EXPAND_IGNORE_SIZE` and `STRETCH_KEEP_ASPECT_CENTERED` so the
  runtime 128x128 texture does not expand the HUD panel beyond its intended
  compact size.
- Preserve the existing Boss HP label, ProgressBar, Boss2 focus handoff, and hit
  flash behavior.

## Test Evidence

- RED focused: `reports/report_855/` failed as expected before the portrait
  diagnostics API existed.
- RED focused refinement: `reports/report_858/` failed as expected when MCP
  revealed the portrait was rendering at 128x128 instead of a compact HUD size.
- Final GREEN focused: `reports/report_862/` passed `2/2`.
- Related HUD/Boss2 regression: `reports/report_861/` passed `30/30`.
- Headless main-scene smoke:
  `reports/boss2_hud_portrait_runtime_main_scene_smoke.log`; keyword scan found
  no script, parse, invalid-call, missing-resource, or logged `ERROR:` entries.
- Godot MCP runtime evidence and screenshot:
  `production/qa/evidence/boss2-hud-portrait-runtime-2026-06-30.md`.

**Status**: [x] Complete.
