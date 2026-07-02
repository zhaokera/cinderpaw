# Story 063: Old Factory Lower Deck Breach Relay Activation Feedback

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Savepoint Feedback
> **Type**: Integration + Gameplay Runtime + Visual/Feel
> **Estimate**: XS
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-02

## Context

**GDD**: `design/gdd/player-abilities.md`,
`design/gdd/exploration-ability-gating.md`,
`design/gdd/scene-management.md`, `design/gdd/death-respawn.md`

**Requirements**: `TR-ability-005`, `TR-scene-004`, `TR-death-002`

**ADR Governing Implementation**: ADR-0002 Signal communication; ADR-0007
Scene management; ADR-0018 Player abilities; ADR-0021 Save system.

Story062 adds the lower-deck breach relay savepoint. This story gives that
repair action immediate player-visible activation feedback so the relay no
longer switches from broken to active as a silent state change. It reuses the
existing image-generated Old Factory unlock spark VFX instead of generating a
new asset for a nearly identical factory electrical burst.

## Acceptance Criteria

- [x] `FactoryLowerDeckBreachRelaySavepoint` mounts a generated activation VFX
  texture from
  `res://assets/environment/old_factory_deep_route/vfx/factory_deep_route_unlock_spark.png`.
- [x] Fresh relay activation spawns exactly one short-lived `Sprite2D`
  activation VFX named `ActivationVfx`.
- [x] The activation VFX reports deterministic diagnostics: texture path,
  active count, spawn count, played flag, duration, and last-spawn metadata.
- [x] Last-spawn metadata records `asset_source="image_generation"`,
  `vfx_role="savepoint_activation"`, the relay savepoint id, texture path, and
  duration.
- [x] Duplicate relay activation returns `false` and does not spawn an
  additional activation VFX.
- [x] The VFX expires deterministically through a testable timer without
  changing the relay activation state or savepoint contract.
- [x] Restoring scene-local state with the relay already activated does not
  replay activation feedback.
- [x] Story062 savepoint behavior remains intact: activation still persists
  `factory_lower_deck_breach_relay_activated=true`, updates route feedback to
  `Lower Deck Relay Secured`, and keeps the service lift optional.
- [x] No new visual asset, SFX, SaveSystem schema, service-lift route, enemy,
  or room is added by this story.
- [x] Focused and related GdUnit regressions, headless smoke, and Godot MCP
  runtime evidence pass under Godot 4.7 / Godot AI MCP 2.8.3.

## Out of Scope

New relay art, new VFX generation, new SFX, minimap/full map UI, fast travel
UI, SaveSystem schema changes, service-lift route changes, new enemies, new
rooms, boss content, and character frame animation.

## Implementation Notes

- Extend `SavepointRuntime` with optional activation VFX exports and diagnostics
  so other savepoints remain unaffected unless a texture is assigned.
- Keep the VFX one-shot per savepoint activation instance. Restored activated
  state must not imply the feedback played in the current runtime.
- Reuse the Story012 generated unlock spark VFX and record the reuse in asset
  evidence instead of creating a duplicate factory spark asset.
- Treat this as environment/savepoint feedback; it does not trigger the
  character `AnimatedSprite2D + SpriteFrames` rule.

## Asset Pipeline

No new visual asset was generated. This story reuses the existing
image-generated and imported VFX asset:

- Runtime VFX:
  `assets/environment/old_factory_deep_route/vfx/factory_deep_route_unlock_spark.png`
- Original source:
  `assets/generated/source/factory_deep_route_unlock_spark_imagegen_20260626.png`
- Alpha source:
  `assets/generated/source/factory_deep_route_unlock_spark_alpha_20260626.png`

The reused VFX remains recorded in `design/assets/asset-manifest.md` and
`design/assets/entity-inventory.md`; Story063 only adds a new usage site on
`FactoryLowerDeckBreachRelaySavepoint`.

## Test Evidence

- Focused RED/GREEN:
  - `reports/report_1073/` failed as expected before relay activation VFX APIs
    existed.
  - Fresh focused rerun `reports/report_1076/` passed Story063 `3/3` with `0`
    errors, failures, skipped, flaky, and orphans.
- Related regression:
  - Fresh related rerun `reports/report_1077/` passed Story063, Story062,
    Story012, and return-checkpoint suites `17/17` with `0` errors, failures,
    skipped, flaky, and orphans.
  - MCP Debugger surfaced stale Story015 `CombatComponent` global-class rows;
    the test was made editor-cache-friendly by avoiding global-class type
    annotations and `reports/report_1079/` passed Story015 `5/5`.
- Headless smoke:
  - `reports/old_factory_lower_deck_breach_relay_feedback_smoke.log` exited
    `0`; project error scan found no script, parse, invalid-call/access,
    missing-resource, or resource-load errors. The log retains only known
    Godot cleanup-time ObjectDB/resource messages.
- MCP runtime:
  - Godot AI MCP `2.8.3` launched
    `res://scenes/factory_route_transition_shell.tscn` with `autosave=false`
    and helper live.
  - Runtime probe injected secured breach state, confirmed the relay activation
    VFX texture path, activation `true`, duplicate activation `false`,
    active_count `1`, spawn_count `1`, image-generation metadata, deterministic
    expiry to active_count `0`, route feedback `Lower Deck Relay Secured`,
    service lift prompt `Call lift`, and the Story062 savepoint contract. Game
    logs contained only the MCP helper registration line after the probe.
  - MCP `editor_screenshot(source="game")` captured a non-empty game
    framebuffer during the relay feedback runtime probe. The inline MCP capture
    was used for visual confirmation; no local screenshot artifact is committed
    for this run.
  - Full evidence:
    `production/qa/evidence/old-factory-lower-deck-breach-relay-activation-feedback-2026-07-02.md`.

**Status**: [x] Complete.
