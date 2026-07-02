# Story 065: Old Factory Lower Deck Post-Relay Combat Feedback

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Route Combat Pressure
> **Type**: Integration + Gameplay Runtime + Visual/Feel
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-02

## Context

**GDD**: `design/gdd/player-abilities.md`,
`design/gdd/exploration-ability-gating.md`,
`design/gdd/feline-combat.md`, `design/gdd/scene-management.md`,
`design/gdd/death-respawn.md`

**Requirements**: `TR-ability-005`, `TR-scene-004`

**ADR Governing Implementation**: ADR-0004 Collision architecture; ADR-0007
Scene management; ADR-0018 Player abilities; ADR-0021 Save system.

Story062-064 turn the lower-deck breach relay into a visible, audible
savepoint payoff. This story prevents that branch from becoming only a static
checkpoint by adding a short relay-forward combat pressure beat after the relay
is repaired.

## Acceptance Criteria

- [x] `FactoryLowerDeckPostRelaySparkRat` and
  `FactoryLowerDeckPostRelaySteamHazard` are authored in
  `factory_route_transition_shell.tscn`.
- [x] The trial is unavailable until
  `factory_lower_deck_breach_relay_activated=true`.
- [x] Crossing activation x `1232.0` after relay repair activates entity
  `2117`, assigns the player target, starts Spark Rat pacing, and updates route
  feedback to `Clear Relay Forward Trial`.
- [x] The visible enemy uses `AnimatedSprite2D + SpriteFrames` with at least
  three frames for `idle`, `run`, `attack_tell`, `attack`, `hurt`, and `death`.
- [x] The relay-forward steam hazard is visible and contact-active while the
  trial is active, with hazard id `old_factory_lower_deck_post_relay_trial`,
  damage `8`, and cooldown `1.0`.
- [x] Defeating entity `2117` hides/disables the enemy and hazard, persists
  `factory_lower_deck_post_relay_trial_activated=true` and
  `factory_lower_deck_post_relay_trial_defeated=true`, and advances feedback to
  `Relay Forward Secured`.
- [x] Restored defeated state does not replay Story061-064 prerequisites and
  keeps the service lift optional with prompt `Call lift`.
- [x] No new visual or audio assets are generated; the story reuses the existing
  image-generated Factory Spark Rat and Old Factory steam vent assets and
  records the new usage in the asset manifest and entity inventory.
- [x] Focused/related GdUnit, headless smoke, and Godot MCP runtime checks pass
  under Godot 4.7 / Godot AI MCP 2.8.3.

## Out of Scope

New enemy family art, new lower-deck backdrop art, authored steam or combat SFX,
minimap markers, fast travel, SaveSystem schema expansion, global quest state,
service-lift route changes, broader lower-deck rooms, and boss content.

## Implementation Notes

- `OldFactoryEntranceScene` owns the new state flags, activation API,
  diagnostics, defeat callback, local-state persistence, route objective
  priority, and damage-target mapping for entity `2117`.
- The new trial reuses the existing Spark Rat gameplay scene instead of adding
  another enemy family, but gives it a distinct owner id, entity id, spawn point,
  pacing diagnostics, and route objective.
- The steam hazard is included in the Factory hazard registry only while active,
  preserving the existing environment contact contract.

## Asset Pipeline

No new visual asset was generated. Story065 intentionally reuses already
imported image-generated assets:

- `assets/characters/factory_spark_rat/factory_spark_rat_sprite_frames.tres`
- `assets/environment/old_factory_steam_vent/factory_steam_vent_hazard.png`
- `assets/environment/old_factory_lower_deck_post_bulkhead/env_old_factory_lower_deck_post_bulkhead_backdrop_1280x720.png`

The new usage is recorded in `design/assets/asset-manifest.md`,
`design/assets/entity-inventory.md`, and QA evidence.

## Test Evidence

- RED focused:
  - `reports/report_1084/` failed as expected before the Story065 activation
    and diagnostics APIs existed.
- Focused GREEN:
  - `reports/report_1086/` passed Story065 `2/2` with `0` errors, failures,
    skipped, flaky, and orphans.
- Related regression:
  - `reports/report_1088/` passed Story065, breach relay feedback, breach
    reward route, breach corridor ambush, and service-lift SceneManager exit
    suites `12/12` with `0` errors, failures, skipped, flaky, and orphans.
- Headless smoke:
  - `reports/old_factory_lower_deck_post_relay_combat_feedback_smoke.log`
    exited `0`; keyword scan found no project script, parse, invalid-call,
    access, missing-resource, or resource-load errors.
- MCP runtime:
  - Godot AI MCP `2.8.3` confirmed helper live in
    `res://scenes/factory_route_transition_shell.tscn`.
  - Runtime probe confirmed active trial diagnostics, frame counts, hazard
    state, route feedback, defeat transition, persisted local flags, clean game
    log, and non-empty game framebuffer capture.
  - Full evidence:
    `production/qa/evidence/old-factory-lower-deck-post-relay-combat-feedback-2026-07-02.md`.

**Status**: [x] Complete.
