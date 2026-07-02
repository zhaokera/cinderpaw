# Story 068: Old Factory Lower Deck Forward Conduit Clear Feedback

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Visual Feedback
> **Type**: Integration + Visual/Feel
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

Story067 adds the forward conduit ambush behind the relay-forward hatch. This
story adds one small player-visible payoff when that combat beat is cleared:
defeating entity `2118` shows a one-shot clear VFX at the conduit fight site so
the player can immediately read that the route is secured.

## Acceptance Criteria

- [x] `factory_route_transition_shell.tscn` contains a hidden
  `FactoryLowerDeckForwardConduitClearBurst` `Sprite2D`.
- [x] The VFX reuses the image-generated texture
  `res://assets/environment/old_factory_overdrive_defeat_burst/vfx_old_factory_overdrive_defeat_burst_256.png`.
- [x] The clear burst is hidden before activation and while entity `2118` is
  still alive.
- [x] Freshly defeating entity `2118` shows the burst at the forward conduit
  Spark Rat position, records `played=true`, `spawn_count=1`, and exposes
  diagnostics with texture path, role, asset source, entity id, hazard id, and
  last position.
- [x] Repeated defeat/sync attempts do not increment the burst spawn count.
- [x] Restored completed state with
  `factory_lower_deck_forward_conduit_defeated=true` does not replay the burst.
- [x] Story067 remains intact: the enemy and steam hazard hide/disable, route
  feedback becomes `Forward Conduit Secured`, and `FactoryServiceLift` remains
  optional with prompt `Call lift`.
- [x] No new visual or audio assets are generated; the reused generated asset
  usage is recorded in asset documentation and QA evidence.
- [x] Focused/related GdUnit, headless smoke, and Godot MCP runtime checks pass
  under Godot 4.7 / Godot AI MCP 2.8.3.

## Out of Scope

New enemy families, new lower-deck rooms, reward caches, new audio events,
particles/shaders, minimap markers, fast travel, SaveSystem schema expansion,
global quest state, service-lift route changes, boss content, and new generated
visual assets.

## Implementation Notes

- `OldFactoryEntranceScene` owns the clear burst visibility, spawn count, and
  deterministic diagnostics.
- The burst is runtime-only feedback. It should not be persisted into local
  state and should not replay when an already-cleared conduit state is restored.
- This story intentionally reuses the Story052 overdrive defeat burst asset but
  uses a dedicated scene node to avoid state coupling with checkpoint overdrive
  left/right defeat bursts.

## Asset Pipeline

No new asset generation is required. Reuse:

- `assets/environment/old_factory_overdrive_defeat_burst/vfx_old_factory_overdrive_defeat_burst_256.png`
- source record:
  `assets/generated/source/old_factory_overdrive_defeat_burst_imagegen_20260701.json`

Record the new usage in `design/assets/asset-manifest.md`,
`design/assets/entity-inventory.md`, and QA evidence.

## Test Evidence

- Focused GdUnit:
  `tests/unit/gameplay/old_factory_lower_deck_forward_conduit_clear_feedback_test.gd`
- Related regression:
  Story068 focused + Story067, Story066, Story065, Story052, and Story015 stale
  row isolation suites.
- Runtime evidence:
  Headless smoke and Godot MCP runtime checks must confirm scene load, node
  presence, texture path, conduit clear state, route label, service lift prompt,
  clean runtime logs, and non-empty screenshot.

## Verification Summary

- RED focused: `reports/report_1097/` failed as expected before Story068 clear
  feedback diagnostics existed.
- Focused GREEN: `reports/report_1101/` passed Story068 `2/2`.
- Related GREEN: `reports/report_1102/` passed Story068 + Story067 + Story066 +
  Story065 + Story052 + Story015 stale-row isolation `15/15`.
- Headless smoke:
  `reports/old_factory_forward_conduit_clear_feedback_smoke.log` exited `0`;
  the only error keyword is known Godot cleanup-time `2 resources still in use`
  noise.
- Godot AI MCP `2.8.3` runtime launched
  `res://scenes/factory_route_transition_shell.tscn` with `autosave=false`,
  confirmed helper live, fresh defeat of entity `2118` produced visible
  `forward_conduit_clear_feedback` with texture
  `res://assets/environment/old_factory_overdrive_defeat_burst/vfx_old_factory_overdrive_defeat_burst_256.png`,
  `spawn_count=1`, `played=true`, last position `(1188, 482)`, route feedback
  `Forward Conduit Secured`, restored state hidden with `spawn_count=0`, service
  lift prompt `Call lift`, game log clean except helper registration, and
  non-empty game screenshot metadata `960x539`. Editor Debugger still showed
  pre-existing Story015 `CombatComponent` stale rows; fresh related CLI
  `reports/report_1102/` passed the Story015 isolation suite.

**Status**: [x] Complete.
