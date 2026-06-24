# Story 007: Textured Parry Flash + Main Scene Visual Contract

> **Epic**: Combat Presentation
> **Status**: Complete
> **Layer**: Presentation
> **Type**: Visual/Feel
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-24

## Context

**GDD**: `design/gdd/combat-presentation.md`
**Requirements**: `TR-combatfx-006`, `TR-combatfx-010`
**ADR Governing Implementation**: ADR-0001: Autoload architecture; ADR-0002: Signal communication

Stories 001-006 replaced square hit/debris VFX and brought Cinderpaw and Shadow
Beast into the `AnimatedSprite2D + SpriteFrames` pipeline. The remaining
player-visible presentation gap is the PERFECT parry full-screen flash: it still
uses a pure `ColorRect` overlay, which reads like prototype UI rather than an
authored combat effect when the scene is inspected. This story textures that
flash and adds a main-scene visual contract so future regressions do not return
player-visible characters to square or single-image placeholders.

## Acceptance Criteria

- [x] PERFECT parry still applies 8 frames of hitstop, 8px shake, one
  80%-alpha full-screen flash, and 20-25 textured radial sparks.
- [x] PERFECT parry flash uses a textured overlay node with a generated/imported
  texture, not a visible `ColorRect` block.
- [x] `main.tscn` visual contract confirms Player and Enemy runtime visuals are
  `AnimatedSprite2D` nodes backed by `SpriteFrames`.
- [x] `main.tscn` startup contract has no visible gameplay `ColorRect` blocks;
  UI overlays are allowed only when menus are explicitly opened.
- [x] New or reused VFX texture provenance is recorded in the asset manifest or
  QA evidence.
- [x] Godot MCP runs `res://scenes/main.tscn`, checks logs and key visual nodes,
  and captures a nonblank screenshot showing Cinderpaw and Shadow Beast.

## Out of Scope

- Core parry input integration in MainScene.
- New parry audio.
- Reworking Cinderpaw or Shadow Beast frame sets.
- Full colorblind particle remaps.
- Boss phase presentation.

## Test Evidence

**Required evidence**:
- `tests/unit/presentation/combat_presentation_test.gd`
- `tests/unit/gameplay/main_scene_visual_contract_test.gd`

**Status**: [x] RED/GREEN + MCP runtime evidence complete

- RED: focused suite failed before implementation because PERFECT parry flash
  spawned a nested `ColorRect` and no textured `TextureRect` overlay existed
  (`reports/report_350/`).
- GREEN:
  - Focused Story007 suite passed `14/14`, exit `0`
    (`reports/report_353/`).
  - Related combat/character visual regression passed `39/39`, exit `0`
    (`reports/report_354/`).
- Headless smoke: `res://scenes/main.tscn` exited `0`, and log scan found no
  error/warning matches in
  `reports/combat_presentation_story007_main_scene_smoke.log`.
- Godot MCP: session `cinderpaw@c1b2`, Godot `4.6.3-stable`, ran
  `res://scenes/main.tscn`; runtime probe returned `TextureRect=1`,
  `ColorRect=0`, `texture_rect_paths=["res://assets/generated/combat_parry_flash_overlay.png"]`,
  `flashes=1`, `last_flash_alpha=0.8`, `parry_sparks=22`, `hitstop=8`,
  `shake=8`, and confirmed Player/Enemy `AnimatedSprite2D` animation coverage.
- Screenshots:
  - `reports/visual/cinderpaw-mcp-textured-parry-flash-20260624.png`
  - `reports/visual/cinderpaw-mcp-main-scene-visual-contract-20260624.png`
- QA evidence:
  `production/qa/evidence/textured-parry-flash-visual-contract-2026-06-24.md`.

## Dependencies

- Depends on: Story 001 textured VFX asset pipeline.
- Depends on: Story 002 parry flash and parry spark presentation.
- Depends on: Story 003 and Feline Combat Story 009 character frame animation.
- Unlocks: stricter visual regression gates for future combat and boss polish.
