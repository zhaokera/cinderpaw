# Story 067: Old Factory Lower Deck Forward Conduit Ambush

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Combat Route
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

Story066 opens the local relay-forward hatch after the post-relay trial and
reward cache. This story adds the next small playable ACT beat behind that
hatch: a deeper lower-deck conduit ambush with one animated Factory Spark Rat
and one steam hazard. It keeps the slice scene-local and does not expand
service-lift routing, minimap, fast travel, global quest state, or save schema.

## Acceptance Criteria

- [x] `FactoryLowerDeckForwardConduitSparkRat` and
  `FactoryLowerDeckForwardConduitSteamHazard` are authored in
  `factory_route_transition_shell.tscn`.
- [x] Both nodes stay hidden, non-processing, non-physics, and non-contacting
  until `factory_lower_deck_forward_hatch_opened=true`.
- [x] Crossing the forward conduit activation boundary after the hatch opens
  activates entity `2118`, assigns Cinderpaw as target, starts Spark Rat pacing,
  enables the steam hazard, and updates route feedback to
  `Clear Forward Conduit Ambush`.
- [x] The visible enemy uses `AnimatedSprite2D + SpriteFrames` and has
  `idle`, `run`, `attack_tell`, `attack`, `hurt`, and `death` animations with
  at least `3` frames each.
- [x] The forward conduit steam hazard is active only while the encounter is
  active, uses hazard id `old_factory_lower_deck_forward_conduit`, damage `8`,
  and cooldown `1.0`.
- [x] Defeating entity `2118` hides/disables the enemy and hazard, persists
  `factory_lower_deck_forward_conduit_activated=true` and
  `factory_lower_deck_forward_conduit_defeated=true`, and updates route
  feedback to `Forward Conduit Secured`.
- [x] Restored completed state keeps Story061-066 flags intact without replaying
  breach relay VFX/audio, Story065 trial, Story066 cache claim, or hatch open.
- [x] `FactoryServiceLift` remains optional with prompt `Call lift`; this story
  does not change service-lift destination or SceneManager contracts.
- [x] No new visual or audio assets are generated; the story reuses the existing
  image-generated Factory Spark Rat frames, steam vent art, and post-bulkhead
  lower-deck backdrop, with usage recorded in asset documentation.
- [x] Focused/related GdUnit, headless smoke, and Godot MCP runtime checks pass
  under Godot 4.7 / Godot AI MCP 2.8.3.

## Out of Scope

New enemy family art, new lower-deck room scene, authored SFX, minimap markers,
fast travel, SaveSystem schema expansion, global quest state, service-lift
route changes, boss content, player animation replacement, and reward caches.

## Implementation Notes

- `OldFactoryEntranceScene` owns scene-local flags, activation API,
  diagnostics, local-state persistence, route feedback, and enemy/hazard state.
- The encounter reuses the existing `FactorySparkRat` scene so it complies with
  the project `AnimatedSprite2D + SpriteFrames` rule without generating new
  character art.
- The hazard reuses `FactorySteamVentHazard` wiring and remains excluded from
  contact damage until the encounter is active.

## Asset Pipeline

No new visual or audio asset should be generated for this story. Reuse:

- `res://src/gameplay/factory_spark_rat.tscn`
- `assets/environment/old_factory_steam_vent/factory_steam_vent_hazard.png`
- `assets/environment/old_factory_lower_deck_post_bulkhead/env_old_factory_lower_deck_post_bulkhead_backdrop_1280x720.png`

Record the new usage in `design/assets/asset-manifest.md`,
`design/assets/entity-inventory.md`, and QA evidence.

## Test Evidence

- Focused GdUnit:
  `tests/unit/gameplay/old_factory_lower_deck_forward_conduit_ambush_test.gd`
- Related regression:
  Story067 focused + Story066, Story065, breach route, lower-deck cache/gate,
  steam sluice, pressure valve, deep bulkhead, and service-lift exit suites.
- Runtime evidence:
  Headless smoke and Godot MCP runtime checks must confirm scene load, node
  presence, animation frame counts, hazard state, route label, local-state
  persistence, service lift prompt, clean logs, and non-empty screenshot.

## Verification Summary

- RED focused: `reports/report_1093/` failed as expected before the Story067
  activation APIs and diagnostics existed.
- Focused GREEN: `reports/report_1094/` passed Story067 `2/2`.
- Related regression, headless smoke, and MCP runtime evidence are recorded in
  `production/qa/evidence/old-factory-lower-deck-forward-conduit-ambush-2026-07-02.md`.

**Status**: [x] Complete.
