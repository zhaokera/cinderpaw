# Story 002: Parry Flash + Cat Claw Trail Slice

> **Epic**: Combat Presentation
> **Status**: Complete
> **Layer**: Presentation
> **Type**: Visual/Feel
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-24

## Context

**GDD**: `design/gdd/combat-presentation.md`
**Requirements**: `TR-combatfx-003`, `TR-combatfx-004`
**ADR Governing Implementation**: ADR-0001: Autoload architecture; ADR-0002: Signal communication; ADR-0016: Weapon styles architecture

Story 001 replaced square hit sparks and death debris. The next visible combat
gap is still player-facing feedback: PERFECT parry needs a decisive full-screen
flash plus radial spark burst, and cat claw attacks need three readable slash
trails so the player attack no longer depends only on sprite tinting.

## Acceptance Criteria

- [x] PERFECT parry feedback applies 8 frames of hitstop, 8px shake, one
  80%-alpha white flash, and 20-25 textured radial sparks.
- [x] Cat claw attack start feedback spawns exactly three textured amber/white
  slash trail sprites with a 0.4s lifetime.
- [x] Non-cat-claw weapon attack start events do not spawn cat-claw trails.
- [x] MainScene player light attack routes attack-start metadata to
  CombatPresentation so trails appear in the playable scene.
- [x] New VFX assets are generated through image generation and imported through
  the Godot asset pipeline.
- [x] Runtime validation through Godot MCP confirms parry spark and claw trail
  sprites in `main.tscn` and captures a nonblank 2D game screenshot.

## Out of Scope

- Audio playback for parry or weapon swing.
- Full dodge/charge/weapon-specific VFX beyond cat claw attack trails.
- Core parry input integration in MainScene. This story adds the presentation
  event and runtime probe; full player parry wiring remains a downstream story.
- GPUParticles2D pooling and the full 200-particle cap implementation.

## Test Evidence

**Required evidence**:
- `tests/unit/presentation/combat_presentation_test.gd`
- `tests/unit/gameplay/main_scene_player_attack_core_chain_test.gd`

**Status**: [x] RED/GREEN + MCP runtime evidence complete

- RED: both focus suites failed before implementation with missing
  CombatPresentation parry/weapon attack APIs and missing MainScene trail
  runtime contract.
- GREEN:
  - `tests/unit/presentation/combat_presentation_test.gd`: `9/9` passing,
    exit `0`, latest local report `reports/report_348/`.
  - `tests/unit/gameplay/main_scene_player_attack_core_chain_test.gd`: `2/2`
    passing, exit `0`, latest local report `reports/report_349/`.
- Headless smoke: `godot --headless --path . --scene res://scenes/main.tscn
  --fixed-fps 60 --quit-after 120 --log-file
  reports/combat_presentation_parry_trail_main_scene_smoke.log` exited `0`;
  log scan found no error/warning lines.
- Godot MCP: session `cinderpaw@c1b2`, Godot `4.6.3-stable`, scene
  `res://scenes/main.tscn`; runtime probe returned `trails=3`,
  `parry_sparks=22`, `flashes=1`, `last_flash_alpha=0.8`, `hitstop=8`,
  `shake=8`, `textured_sprite_count=25`, and texture paths for
  `combat_claw_trail.png` and `combat_parry_spark.png`.
- Screenshot:
  `reports/visual/cinderpaw-mcp-parry-claw-trail-runtime-20260624.png`.
- QA evidence:
  `production/qa/evidence/parry-flash-cat-claw-trail-2026-06-24.md`.

## Dependencies

- Depends on: Story 001 textured hit spark/debris asset pipeline.
- Unlocks: Core parry runtime wiring, dodge afterimages, weapon-specific VFX.
