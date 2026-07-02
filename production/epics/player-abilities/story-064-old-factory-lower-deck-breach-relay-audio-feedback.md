# Story 064: Old Factory Lower Deck Breach Relay Audio Feedback

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Savepoint Audio
> **Type**: Integration + Gameplay Runtime + Visual/Feel + Audio
> **Estimate**: XS
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-02

## Context

**GDD**: `design/gdd/player-abilities.md`,
`design/gdd/exploration-ability-gating.md`,
`design/gdd/scene-management.md`, `design/gdd/death-respawn.md`,
`design/gdd/audio-system.md`

**Requirements**: `TR-ability-005`, `TR-scene-004`, `TR-death-002`

**ADR Governing Implementation**: ADR-0002 Signal communication; ADR-0007
Scene management; ADR-0010 Audio architecture; ADR-0018 Player abilities;
ADR-0021 Save system.

Story062 adds the lower-deck breach relay savepoint and Story063 gives it visual
activation feedback. This story adds the matching short audio confirmation so a
successful repair has visual and spatial audio payoff without turning all
savepoints into a global audio feature.

## Acceptance Criteria

- [x] `AudioSystem` exposes `on_savepoint_activated(...)` and routes the event
  to imported `sfx_door_unlock`.
- [x] The routed event records deterministic gameplay audio metadata:
  `event_id="savepoint_activated"`, `sfx_id="sfx_door_unlock"`,
  `savepoint_id`, `scene_id`, `spawn_point`, `world_position`, source, and
  feedback role.
- [x] `FactoryLowerDeckBreachRelaySavepoint` calls the savepoint audio route only
  on fresh successful relay activation.
- [x] Duplicate activation returns `false` and does not increase the relay audio
  request count.
- [x] Restored activated relay state does not replay audio.
- [x] Missing or unsupported `AudioSystem` does not block relay activation.
- [x] Story062/063 behavior remains intact: route label, savepoint contract,
  VFX spawn/expiry, and optional service-lift route still work.
- [x] No new WAV, SaveSystem schema, service-lift route, visual asset, enemy, or
  room is added by this story.
- [x] Focused and related GdUnit regressions, headless smoke, and Godot MCP
  runtime evidence pass under Godot 4.7 / Godot AI MCP 2.8.3.

## Out of Scope

New relay WAV generation, final authored SFX mastering, bus/mix changes, global
savepoint audio policy, subtitles/accessibility audio visualization, minimap,
fast travel, SaveSystem schema changes, service-lift route changes, new
characters, new enemies, and new rooms.

## Implementation Notes

- `AudioSystem.on_savepoint_activated(...)` reuses the existing
  `sfx_door_unlock` cue as a short metal/electric confirmation sound.
- `OldFactoryEntranceScene` owns the lower-deck relay-specific call site in
  `_on_factory_lower_deck_breach_relay_activated(...)`; `SavepointRuntime` is
  not made responsible for all savepoint audio.
- Relay diagnostics now expose `activation_audio_requested`,
  `activation_audio_request_count`, and `activation_audio_event` for tests and
  MCP runtime probes.

## Asset Pipeline

No new audio or visual asset was generated. Story064 reuses the existing imported
SFX asset:

- Runtime SFX:
  `assets/audio/sfx/sfx_door_unlock_baseline_short.wav`
- Source recipe:
  `assets/audio/source/ability_gate_unlock_sfx_generation_20260626.json`

The reuse is recorded in `design/assets/asset-manifest.md`,
`design/assets/entity-inventory.md`, and QA evidence. This story does not add a
character animation asset and does not trigger the character frame-animation
rules.

## Test Evidence

- Focused RED/GREEN:
  - `reports/report_1080/` failed as expected before
    `AudioSystem.on_savepoint_activated` and relay activation-audio diagnostics
    existed.
  - `reports/report_1081/` passed focused AudioSystem + relay feedback suites
    `27/27` with `0` errors, failures, skipped, flaky, and orphans.
- Related regression:
  - `reports/report_1082/` passed relay feedback, breach reward route, and
    AudioSystem suites `29/29` with `0` errors, failures, skipped, flaky, and
    orphans.
  - `reports/report_1083/` passed Story015 dodge-counter readability `5/5`,
    isolating stale editor Debugger `CombatComponent` rows as non-reproducible
    in current CLI verification.
- Headless smoke:
  - `reports/old_factory_lower_deck_breach_relay_audio_feedback_smoke.log`
    exited `0`; keyword scan found no project script, parse, invalid-call,
    access, missing-resource, or resource-load errors. Godot still prints known
    cleanup-time ObjectDB/resource messages to terminal on exit.
- MCP runtime:
  - Godot AI MCP `2.8.3` launched
    `res://scenes/factory_route_transition_shell.tscn` with `autosave=false`
    and helper live.
  - Runtime probe injected secured breach state, moved Cinderpaw to the relay,
    confirmed activation `true`, duplicate activation `false`,
    `activation_audio_request_count=1`, `savepoint_activated -> sfx_door_unlock`,
    relay position `(1218, 382)`, `stream_found=true`, route label
    `Lower Deck Relay Secured`, and existing VFX spawn count `1`.
  - Game logs contained only the MCP helper registration line after the probe.
    Editor Debugger still displayed stale Story015 rows with old line mappings;
    `reports/report_1083/` proves the referenced test currently passes.
  - MCP `editor_screenshot(source="game")` captured a non-empty runtime
    framebuffer with the relay visible after activation.
  - Full evidence:
    `production/qa/evidence/old-factory-lower-deck-breach-relay-audio-feedback-2026-07-02.md`.

**Status**: [x] Complete.
