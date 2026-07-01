# Story 052: Old Factory Overdrive Defeat Burst

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Visual Feedback
> **Type**: Integration + Visual/Feel
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-01

## Context

**GDD**: `design/gdd/player-abilities.md`,
`design/gdd/exploration-ability-gating.md`,
`design/gdd/scene-management.md`, `design/gdd/combat-presentation.md`

**Requirements**: `TR-ability-005`, `TR-scene-003`, `TR-scene-005`

**ADR Governing Implementation**: ADR-0004 Collision Detection; ADR-0007 Scene
management; ADR-0018 Player abilities; ADR-0021 Save system.

Stories049-051 make the Old Factory checkpoint overdrive duo a readable final
combat gate with optional reward cache payoff. This story improves the moment
the player defeats each overdrive Spark Rat: instead of only hiding the enemy,
the scene now shows an image-generated debris/electric burst at the defeated
rat's position.

## Acceptance Criteria

- [x] `factory_route_transition_shell.tscn` contains hidden
  `FactoryCheckpointOverdriveLeftDefeatBurst` and
  `FactoryCheckpointOverdriveRightDefeatBurst` `Sprite2D` nodes.
- [x] Both burst nodes use the image-generated transparent runtime PNG
  `res://assets/environment/old_factory_overdrive_defeat_burst/vfx_old_factory_overdrive_defeat_burst_256.png`.
- [x] Defeating entity `2106` shows the left burst at the left overdrive Spark
  Rat position and records `last_side="left"`.
- [x] Defeating entity `2107` shows the right burst at the right overdrive
  Spark Rat position and records `last_side="right"`.
- [x] Restoring an already-cleared overdrive duo through `set_local_state()`
  does not replay either burst.
- [x] Existing overdrive duo clear, service-lift unlock, and optional reward
  cache behavior remain intact.
- [x] Focused and related GdUnit regressions, Godot import, and Godot MCP
  runtime evidence pass with no new project script or resource errors.

## Out of Scope

New enemies, new lower-deck room or SceneManager target, reward-cache changes,
global economy, service-lift behavior changes, Spark Rat tuning, new SFX, timer
fade animation, particles, shaders, or additional character frame generation.

## Implementation Notes

- The story uses two scene-authored `Sprite2D` VFX nodes, default hidden, rather
  than a particle system. This keeps the slice deterministic and easy to verify.
- The existing Spark Rat `AnimatedSprite2D + SpriteFrames` enemy remains the
  player-visible character; this story adds non-character VFX only.
- Burst state is intentionally runtime-only. Scene-local restored state should
  preserve combat clear state without replaying visual feedback.

## Asset Pipeline

- New generated source:
  `assets/generated/source/old_factory_overdrive_defeat_burst_imagegen_20260701.png`.
- Alpha source:
  `assets/generated/source/old_factory_overdrive_defeat_burst_alpha_20260701.png`.
- Metadata:
  `assets/generated/source/old_factory_overdrive_defeat_burst_imagegen_20260701.json`.
- Runtime PNG:
  `assets/environment/old_factory_overdrive_defeat_burst/vfx_old_factory_overdrive_defeat_burst_256.png`.
- Manifest row:
  `design/assets/asset-manifest.md`.

## Test Evidence

- Focused RED:
  - `reports/report_1026/` failed because
    `get_factory_checkpoint_overdrive_defeat_burst_diagnostics()` did not
    exist.
- Focused GREEN:
  - `reports/report_1027/` passed Story052 `2/2` with `0` errors, failures,
    flaky tests, skipped tests, or orphans on Godot
    `4.7.stable.official.5b4e0cb0f`.
- Related regression, headless smoke, and MCP runtime evidence:
  - `reports/report_1028/` passed `11/11` across Story052, overdrive duo,
    overdrive reward cache, service-lift SceneManager exit, and Factory route
    roundtrip.
  - `reports/old_factory_overdrive_defeat_burst_smoke.log` exited `0`; keyword
    scan found no project script, parse, invalid-call, invalid-access,
    missing-resource, or resource-load errors in the log file. Godot still
    printed known cleanup-time ObjectDB/resource-at-exit noise to terminal.
  - Godot MCP 4.7 runtime evidence:
    `production/qa/evidence/old-factory-overdrive-defeat-burst-2026-07-01.md`.

**Status**: [x] Complete.
