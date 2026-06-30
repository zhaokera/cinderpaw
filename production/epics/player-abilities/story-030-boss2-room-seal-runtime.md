# Story 030: Boss2 Room Seal Runtime

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Core / Feature / Gameplay Runtime / Presentation Integration
> **Type**: Integration + Gameplay Runtime + Visual/Feel
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-30

## Context

**GDD**: `design/gdd/player-abilities.md`,
`design/gdd/exploration-ability-gating.md`, `design/gdd/boss-config.md`,
`design/gdd/scene-management.md`, `design/gdd/combat-presentation.md`

**Requirements**: `TR-ability-005`, `TR-scene-005`, `TR-boss-004`,
`TR-combatfx-001`

**ADR Governing Implementation**: ADR-0002 Signal communication; ADR-0005
Combat state machine; ADR-0007 Scene management; ADR-0018 Player abilities;
ADR-0021 Save system architecture.

Stories021-029 made Boss2 visible, animated, threatening, bounded, readable in
the HUD, backed by authored audio, framed by arena art, and camera-locked during
the encounter. The room still lacks a player-visible containment rule: the
fight reads as an arena, but there is no visible sealed entrance/exit state that
opens when the Echo Guardian is defeated.

This story adds the smallest room-seal runtime needed for the Boss2 payoff:
two generated seal-door props in `scenes/main.tscn` block the Boss2 room while
Boss2 is active and undefeated, then open when Boss2 is defeated or restored as
defeated. It does not add a new scene, cutscene, minimap marker, or final boss
room layout.

## Acceptance Criteria

- [x] `MainScene` exposes deterministic Boss2 room-seal diagnostics for tests
  and MCP probes, including enabled state, reason, texture path, per-seal
  visibility, blocking state, collision layer, and position.
- [x] While Boss2 is active and undefeated, the left and right Boss2 room seals
  are visible player-facing `Sprite2D` props with collision that blocks
  traversal through the Boss2 room edges.
- [x] When Boss2 is defeated or restored from defeated progress, both room
  seals open by disabling collision and hiding the blocking seal sprites, while
  the Boss2 Double Jump reward remains available.
- [x] The seal art is an image-generated transparent PNG under
  `assets/environment/boss2_arena/`, with source image and prompt metadata
  preserved under `assets/generated/source/`, imported through Godot, and
  recorded in the asset manifest / QA evidence.
- [x] Boss2 AI, arena bounds/reset, camera lock, HUD focus, reward claim, and
  CombatPresentation screen shake behavior remain unchanged.
- [x] Focused RED/GREEN tests, related Boss2 regression, headless smoke, and
  Godot MCP runtime evidence are recorded.

## Out of Scope

- Full boss-room layout rebuild, new minimap markers, fast-travel nodes,
  cutscenes, camera rails, dynamic door animation, or new post-boss route.
- Boss2 multi-phase AI, final balance, boss portrait/HP-bar redesign, music
  mix, or new attack patterns.
- Generic door manager, new Autoload, save schema migration, or non-Boss2 room
  locking behavior.

## Implementation Notes

- Keep the implementation scene-local to `MainScene` and `scenes/main.tscn`.
- Use `StaticBody2D` + `CollisionShape2D` for the blocking seals and `Sprite2D`
  for the player-visible prop.
- Keep collision on environment layer `16`, matching existing main-scene
  blocking geometry.
- Reuse existing Boss2 defeated world progress and reward-source sync hooks.
- Do not touch `Camera2D.offset`; CombatPresentation owns offset for screen
  shake.
- MCP evidence must prove scene load, seal diagnostics, active blocking state,
  defeated release behavior, clean logs, and a nonblank screenshot.

## Test Evidence

**Required evidence**:

- `tests/unit/gameplay/boss2_room_seal_runtime_test.gd`
- Related Boss2 regressions for camera lock, HUD focus, arena reset,
  autonomous pressure, and Double Jump payoff
- Headless main-scene smoke
- Godot MCP runtime evidence under
  `production/qa/evidence/boss2-room-seal-runtime-2026-06-30.md`

**Recorded evidence**:

- RED focused: `reports/report_848/` failed before implementation because
  `refresh_boss2_room_seals()` and `get_boss2_room_seal_diagnostics()` did not
  exist.
- GREEN focused after implementation: `reports/report_849/` passed `3/3`.
- Autonomous Boss2 pressure regression: `reports/report_850/` passed `6/6`.
- Related Boss2 regression before final placement refinement:
  `reports/report_851/` passed `19/19`.
- Final focused after placement/refactor refinement:
  `reports/report_854/` passed `3/3`.
- Final related Boss2 regression: `reports/report_853/` passed `19/19`.
- Headless main-scene smoke:
  `reports/boss2_room_seal_runtime_main_scene_smoke.log`; keyword scan found no
  script, parse, invalid-call, missing-resource, or logged `ERROR:` entries.
- Godot MCP runtime evidence and screenshot:
  `production/qa/evidence/boss2-room-seal-runtime-2026-06-30.md`.

**Status**: [x] Complete.
