# Story 062: Old Factory Lower Deck Breach Relay Savepoint

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Savepoint
> **Type**: Integration + Gameplay Runtime + Visual/Feel
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-02

## Context

**GDD**: `design/gdd/player-abilities.md`,
`design/gdd/exploration-ability-gating.md`,
`design/gdd/scene-management.md`, `design/gdd/death-respawn.md`

**Requirements**: `TR-ability-005`, `TR-scene-004`, `TR-death-002`

**ADR Governing Implementation**: ADR-0007 Scene management; ADR-0018
Player abilities; ADR-0021 Save system.

Story061 secures the post-bulkhead breach corridor. This story gives the
player a visible safety and progress payoff after that fight: a repaired
lower-deck relay that acts as the new non-boss respawn point for the deeper
Factory route without changing the optional service lift or SaveSystem schema.

## Acceptance Criteria

- [x] `factory_route_transition_shell.tscn` contains
  `FactoryLowerDeckBreachRelaySavepoint` using `SavepointRuntime`, with
  `Visual`, `PromptLabel`, `InteractionArea`, and `CollisionShape2D`.
- [x] The relay is hidden, non-monitoring, non-monitorable, and non-activable
  until `factory_lower_deck_breach_corridor_secured=true`.
- [x] Once the breach corridor is secured, the relay becomes visible and
  interactable with prompt `Repair Relay`.
- [x] Activating the relay succeeds once, persists
  `factory_lower_deck_breach_relay_activated=true`, and updates route feedback
  to `Lower Deck Relay Secured`.
- [x] Activation records the stable savepoint contract
  `old_factory_lower_deck_breach_relay / area_03_factory /
  lower_deck_breach_relay`.
- [x] Non-boss death after activation routes the Factory respawn flow to
  `area_03_factory / lower_deck_breach_relay`, moves Cinderpaw back to the
  relay, and updates route feedback to `Returned to Lower Deck Relay`.
- [x] Restoring scene-local state keeps the relay activated and does not replay
  the Story054-061 lower-deck prerequisite chain, enemies, or breach hazard.
- [x] `FactoryServiceLift` remains optional with prompt `Call lift`; Story062
  does not alter service-lift destinations.
- [x] New relay art is generated through image generation, preserved as source
  and alpha source, imported as a transparent runtime PNG, and recorded in the
  asset manifest plus entity inventory.
- [x] Focused and related GdUnit regressions, headless smoke, and Godot MCP
  runtime evidence pass under Godot 4.7 / Godot AI MCP 2.8.3.

## Out of Scope

New enemy family, new combat encounter, minimap/full map UI, fast travel UI,
SaveSystem schema changes, service-lift route changes, new player ability,
skill-tree branch, authored relay SFX, boss content, and new character frame
animation.

## Implementation Notes

- Reuse the existing `SavepointRuntime` contract instead of creating a new
  savepoint type.
- Keep the relay state scene-local through
  `OldFactoryEntranceScene.get_local_state()` / `set_local_state()`.
- Do not change the global save schema. The relay reuses the existing
  last-return-checkpoint snapshot shape.
- Treat the relay as an environment prop; no character frame animation rule is
  triggered by this story.

## Asset Pipeline

New visual asset generated through image generation:

- Source:
  `assets/generated/source/old_factory_lower_deck_breach_relay_imagegen_20260702.png`
- Alpha source:
  `assets/generated/source/old_factory_lower_deck_breach_relay_alpha_20260702.png`
- Runtime prop:
  `assets/environment/old_factory_lower_deck_breach_relay/env_old_factory_lower_deck_breach_relay_256.png`
- Metadata:
  `assets/generated/source/old_factory_lower_deck_breach_relay_imagegen_20260702.json`

The source was generated as a pixel-art Old Factory lower-deck relay prop on a
chroma-key background, alpha-matted, des-pilled, resized to a 256x256
transparent runtime PNG, imported through Godot, and mounted on
`FactoryLowerDeckBreachRelaySavepoint/Visual`.

## Test Evidence

- Focused RED/GREEN:
  - `reports/report_1067/` failed as expected before the Story062 diagnostics
    and activation APIs existed.
  - Fresh focused rerun `reports/report_1071/` passed Story062 `2/2` with
    `0` errors, failures, skipped, flaky, and orphans.
- Related regression:
  - Fresh related rerun `reports/report_1072/` passed deep bulkhead, breach
    corridor, breach relay, return checkpoint, and service-lift SceneManager
    exit suites `15/15` with `0` errors, failures, skipped, flaky, and
    orphans.
- Headless smoke:
  - `reports/old_factory_lower_deck_breach_relay_savepoint_smoke.log` exited
    `0`; project error scan found no script, parse, invalid-call/access,
    missing-resource, or resource-load errors. The log retains only known
    Godot cleanup-time ObjectDB/resource messages.
- MCP runtime:
  - Godot AI MCP `2.8.3` launched
    `res://scenes/factory_route_transition_shell.tscn` with `autosave=false`
    and helper live.
  - Runtime probe injected secured breach state, confirmed
    `FactoryLowerDeckBreachRelaySavepoint` present and visible, `Visual` as
    `Sprite2D`, texture path
    `res://assets/environment/old_factory_lower_deck_breach_relay/env_old_factory_lower_deck_breach_relay_256.png`,
    texture size `256x256`, prompt `Repair Relay`, activation `true`,
    duplicate activation `false`, route feedback `Lower Deck Relay Secured`,
    local relay flag persisted, breach enemies/hazard inactive, and relay
    savepoint contract `old_factory_lower_deck_breach_relay /
    area_03_factory / lower_deck_breach_relay`.
  - MCP `editor_screenshot(source="game")` captured a non-empty `960x539`
    game framebuffer during the relay runtime probe. The inline MCP capture was
    used for visual confirmation; no local screenshot artifact is committed for
    this run.
  - Full evidence:
    `production/qa/evidence/old-factory-lower-deck-breach-relay-savepoint-2026-07-02.md`.

**Status**: [x] Complete.
