# Story 074: Old Factory Lower Deck Forward Pressure Exit Relay Savepoint

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Savepoint
> **Type**: Integration + Gameplay Runtime + Visual/Feel
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-06

## Context

**GDD**: `design/gdd/player-abilities.md`,
`design/gdd/exploration-ability-gating.md`,
`design/gdd/scene-management.md`, `design/gdd/death-respawn.md`

**Requirements**: `TR-ability-005`, `TR-scene-004`, `TR-respawn-002`

**ADR Governing Implementation**: ADR-0007 Scene management; ADR-0018
Player abilities; ADR-0021 Save system.

Story073 secures the forward-pressure exit after a short animated Spark Rat
guard fight. This story turns that win into a player-visible safety payoff: a
repairable exit relay that becomes the new lower-deck forward-pressure
non-boss respawn anchor without changing the optional service lift or global
SaveSystem schema.

## Acceptance Criteria

- [x] `factory_route_transition_shell.tscn` contains
  `FactoryLowerDeckForwardPressureExitRelaySavepoint` using `SavepointRuntime`,
  with `Visual`, `PromptLabel`, `InteractionArea`, and `CollisionShape2D`.
- [x] The exit relay is hidden, non-monitoring, non-monitorable, and
  non-activable until
  `factory_lower_deck_forward_pressure_exit_guard_defeated=true`.
- [x] Once Story073 is defeated, the relay becomes visible and interactable
  with prompt `Repair Exit Relay`.
- [x] Activating the relay succeeds once, persists
  `factory_lower_deck_forward_pressure_exit_relay_activated=true`, and updates
  route feedback to `Forward Pressure Exit Relay Secured`.
- [x] Activation records the stable savepoint contract
  `old_factory_lower_deck_forward_pressure_exit_relay / area_03_factory /
  lower_deck_forward_pressure_exit_relay`.
- [x] Non-boss death after activation routes the Factory respawn flow to
  `area_03_factory / lower_deck_forward_pressure_exit_relay`, moves Cinderpaw
  back to the relay at 50% HP, starts respawn visual feedback, and updates route
  feedback to `Returned to Forward Pressure Exit Relay`.
- [x] Restoring scene-local completed state keeps the relay activated and does
  not replay Story068 clear burst, Story069/070 encounters, Story071 reward
  cache claim/audio, or Story073 exit guard enemy/hazard.
- [x] `FactoryServiceLift` remains optional with prompt `Call lift`; Story074
  does not alter service-lift destinations.
- [x] No new visual or audio assets are generated; the relay reuses existing
  image-generated Old Factory relay art and records the new usage in asset
  documentation and QA evidence.
- [x] Focused/related GdUnit, headless smoke, and Godot MCP runtime checks pass
  under Godot 4.7 / Godot AI MCP 2.8.3.

## Out of Scope

New enemy family, new combat encounter, new lower-deck room scene, minimap/full
map UI, fast travel UI, SaveSystem schema changes, service-lift route changes,
new player ability, skill-tree branch, authored relay SFX, boss content, new
particles/shaders, and new character frame animation.

## Implementation Notes

- Reuse the existing `SavepointRuntime` contract instead of creating a new
  savepoint type.
- Keep the relay state scene-local through
  `OldFactoryEntranceScene.get_local_state()` / `set_local_state()`.
- Do not change the global save schema. The relay reuses the existing
  last-return-checkpoint snapshot shape.
- Treat the relay as an environment prop; no character frame animation rule is
  triggered by this story.
- Keep Story073's animated exit guard defeated and inactive in restored
  completed states.

## Asset Pipeline

No new asset generation is required. Reuse:

- Runtime prop:
  `assets/environment/old_factory_lower_deck_breach_relay/env_old_factory_lower_deck_breach_relay_256.png`
- Source:
  `assets/generated/source/old_factory_lower_deck_breach_relay_imagegen_20260702.png`
- Alpha source:
  `assets/generated/source/old_factory_lower_deck_breach_relay_alpha_20260702.png`
- Metadata:
  `assets/generated/source/old_factory_lower_deck_breach_relay_imagegen_20260702.json`

Record the Story074 reuse in `design/assets/asset-manifest.md`,
`design/assets/entity-inventory.md`, and QA evidence.

## Test Evidence

- Focused GdUnit:
  `tests/unit/gameplay/old_factory_lower_deck_forward_pressure_exit_relay_test.gd`
- Related regression:
  Story074 focused + Story073, Story072, Story071, Story070, Story069,
  return checkpoint/respawn, service-lift, and factory route roundtrip suites.
- Runtime evidence:
  Headless smoke and Godot MCP runtime checks must confirm scene load, node
  presence, prompt/texture/contract, activation once-only behavior, local-state
  persistence, non-boss respawn to the new relay, no prerequisite replay,
  service lift prompt, clean logs, and a non-empty screenshot with the relay
  visible.

## Verification Summary

- RED restored-checkpoint regression: `reports/report_1122/` failed as
  expected because restored completed state still respawned at
  `lower_deck_breach_relay` instead of `lower_deck_forward_pressure_exit_relay`.
- Focused GREEN: `reports/report_1123/` passed Story074 `2/2`.
- Related GREEN: `reports/report_1124/` passed Story074, Story073, Story072,
  Story071, Story070, Story069, breach relay, return checkpoint/respawn,
  service-lift, factory route roundtrip, and no-loss respawn suites `31/31`.
- Headless smoke:
  `reports/old_factory_forward_pressure_exit_relay_smoke.log` exited `0`; the
  only keyword hit was the known Godot cleanup-time resource message, not a
  project script/resource-load failure.
- Godot AI MCP `2.8.3` on Godot `4.7-stable` launched
  `res://scenes/factory_route_transition_shell.tscn` with `autosave=false` and
  confirmed helper live, relay node/children present, visible/interactable
  after Story073, once-only activation, stable savepoint contract, scene-local
  persistence, non-boss respawn to the exit relay at 50% HP with visual
  feedback, restored old-checkpoint state normalized to the exit relay,
  service lift prompt `Call lift`, clean game/editor logs, and non-empty game
  screenshot metadata `960x539`.

**Status**: [x] Complete.
