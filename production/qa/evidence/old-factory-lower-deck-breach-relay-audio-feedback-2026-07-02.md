# Old Factory Lower Deck Breach Relay Audio Feedback Evidence

## Scope

- Story:
  `production/epics/player-abilities/story-064-old-factory-lower-deck-breach-relay-audio-feedback.md`
- Scene: `res://scenes/factory_route_transition_shell.tscn`
- Runtime scripts:
  - `res://src/presentation/audio_system.gd`
  - `res://src/gameplay/old_factory_entrance_scene.gd`
- Test files:
  - `res://tests/unit/presentation/audio_system_test.gd`
  - `res://tests/unit/gameplay/old_factory_lower_deck_breach_relay_feedback_test.gd`

## Implementation Evidence

- `AudioSystem.on_savepoint_activated(...)` routes savepoint activation events to
  `sfx_door_unlock` through the existing gameplay SFX path.
- `OldFactoryEntranceScene._on_factory_lower_deck_breach_relay_activated(...)`
  requests the audio event only after the fresh lower-deck relay activation
  signal passes the savepoint id and duplicate guards.
- Relay diagnostics now expose:
  - `activation_audio_requested`
  - `activation_audio_request_count`
  - `activation_audio_event`
- Duplicate relay activation leaves `activation_audio_request_count` at `1`.
- Restored activated relay state leaves `activation_audio_requested=false` and
  `activation_audio_request_count=0`.

## Asset Evidence

No new asset was generated. Story064 reuses the existing imported Story016 SFX:

- Runtime:
  `assets/audio/sfx/sfx_door_unlock_baseline_short.wav`
- Source recipe:
  `assets/audio/source/ability_gate_unlock_sfx_generation_20260626.json`
- Audio event:
  `savepoint_activated`
- SFX id:
  `sfx_door_unlock`

The cue is a replaceable baseline confirmation sound. A final authored relay SFX
can replace or specialize this route later without changing the savepoint
contract.

## Automated Verification

- RED focused:
  `reports/report_1080/` failed as expected before the savepoint audio API and
  relay activation-audio diagnostics existed.
- Fresh focused GREEN:
  `reports/report_1081/` passed AudioSystem + relay feedback suites `27/27`
  with `0` errors, failures, skipped, flaky, and orphans.
- Fresh related GREEN:
  `reports/report_1082/` passed relay feedback, breach reward route, and
  AudioSystem suites `29/29` with `0` errors, failures, skipped, flaky, and
  orphans.
- Stale editor-row isolation:
  `reports/report_1083/` passed Story015 dodge-counter readability `5/5`. This
  confirms the editor Debugger's old `CombatComponent` rows are not currently
  reproducible by CLI verification.
- Headless smoke:
  `reports/old_factory_lower_deck_breach_relay_audio_feedback_smoke.log` exited
  `0`; script/parse/invalid-call/access/missing-resource/resource-load keyword
  scan returned no project errors. Godot still printed known cleanup-time
  ObjectDB/resource messages to terminal.

## MCP Runtime Verification

- Godot version: `4.7.stable.official.5b4e0cb0f`.
- Godot AI MCP: plugin/server `2.8.3`.
- MCP launch:
  `project_run(mode="custom", scene="res://scenes/factory_route_transition_shell.tscn", autosave=false)`
  returned helper live with no recent errors.
- Runtime probe:
  - AudioSystem present: `true`
  - Relay position: `(1218, 382)`
  - Activation result: `true`
  - Duplicate activation result: `false`
  - `activation_audio_requested`: `true`
  - `activation_audio_request_count`: `1`
  - `event_id`: `savepoint_activated`
  - `sfx_id`: `sfx_door_unlock`
  - `priority`: `90`
  - `stream_found`: `true`
  - Metadata: `savepoint_id=old_factory_lower_deck_breach_relay`,
    `scene_id=area_03_factory`, `spawn_point=lower_deck_breach_relay`,
    `feedback_role=savepoint_activation`,
    `source=factory_lower_deck_breach_relay`, `world_position=(1218, 382)`
  - Route label: `Lower Deck Relay Secured`
  - VFX spawn count remains `1`
- Runtime logs:
  Game logs contained only the MCP helper registration line after the probe.
  Editor logs still showed stale Story015 Debugger rows with old line mappings;
  `reports/report_1083/` is the current pass evidence for that referenced test.
- MCP screenshot:
  `editor_screenshot(source="game")` captured a non-empty runtime framebuffer
  with the activated relay visible. The capture was available inline from MCP;
  no local screenshot artifact is committed for this run.

## Result

PASS. Story064 adds spatial audio confirmation to the lower-deck breach relay
repair while preserving Story062 savepoint behavior and Story063 visual
activation feedback.
