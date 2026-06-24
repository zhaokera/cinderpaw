# Story 001: Textured Hit Spark + Enemy Debris Slice

> **Epic**: Combat Presentation
> **Status**: Complete
> **Layer**: Presentation
> **Type**: Visual/Runtime
> **Estimate**: S
> **Manifest Version**: 2026-06-24
> **Last Updated**: 2026-06-24

## Context

**GDD**: `design/gdd/combat-presentation.md`
**Requirements**: `TR-combatfx-001`, `TR-combatfx-002`, `TR-combatfx-007`

The runtime scene already had generated player, enemy, platform, and background
art, but hit sparks and kill debris still used `ColorRect` prototype blocks.
This story replaces those square placeholders with image-generated transparent
PNG VFX imported through Godot.

## Acceptance Criteria

- [x] Normal hit feedback spawns 5-8 textured hit-spark sprites.
- [x] Critical hit feedback uses the same generated spark silhouette with gold
  critical tint and stronger hitstop/shake.
- [x] Enemy kill feedback spawns 15-20 textured debris sprites.
- [x] Combat VFX nodes do not use visible `ColorRect` prototype blocks.
- [x] New VFX assets are generated through image generation and imported through
  the Godot asset pipeline.
- [x] Runtime validation through Godot MCP confirms textured sprites in
  `main.tscn` and captures a nonblank 2D game screenshot.

## Test Evidence

**Required evidence**: `tests/unit/presentation/combat_presentation_test.gd`
**Status**: [x] Created and passing

- RED: focused suite failed before implementation because sparks/debris were
  `ColorRect` children and no textured `Sprite2D` VFX existed.
- GREEN: CombatPresentation focused suite passed 6/6 with exit `0`.
- Runtime evidence: `production/qa/evidence/combat-presentation-textured-vfx-2026-06-24.md`.
- Screenshot: `reports/visual/cinderpaw-mcp-textured-combat-vfx-20260624.png`.

## Dependencies

- Depends on: CombatPresentation scene node, Godot import pipeline, generated
  VFX PNG assets.
- Unlocks: parry flash, claw slash trail, weapon-specific VFX, boss debris.
