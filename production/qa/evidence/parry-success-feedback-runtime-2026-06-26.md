# QA Evidence: Parry Success Feedback Runtime

Date: 2026-06-26

Story:
`production/epics/player-abilities/story-020-parry-success-feedback-runtime.md`

## Scope

This slice connects the running player's Core parry resolution to the existing
combat presentation and audio feedback systems. `MainScene` now listens to
`CombatComponent.on_parry_resolved`, enriches the Core metadata with Cinderpaw's
visible sprite position and `source="player_parry"`, then forwards the event to
`CombatPresentation.on_parry_event()` and `AudioSystem.on_parry_event()`.

The story does not change parry timing, counterattack behavior, or asset
content. It makes the existing PERFECT/GOOD parry feedback playable in the main
runtime scene.

## Asset Pipeline

No new visual or audio asset was generated for this story.

Reused existing imported assets:

- Player parry frames from Story019:
  `assets/characters/cinderpaw/parry/cinderpaw_parry_000.png` through `_002.png`
- Player SpriteFrames:
  `assets/characters/cinderpaw/cinderpaw_sprite_frames.tres`
- Existing image-generated parry VFX:
  `assets/generated/combat_parry_flash_overlay.png`
  and `assets/generated/combat_parry_spark.png`
- Existing imported parry SFX:
  `assets/audio/sfx/sfx_parry_perfect.wav`
  and `assets/audio/sfx/sfx_parry_good.wav`

The MCP runtime probe confirmed the player remains `AnimatedSprite2D` with
`SpriteFrames`, and the `parry` animation still has three frames.

## Automated Tests

- RED: `reports/report_733/`
  - Command: `/opt/homebrew/bin/godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/main_scene_audio_event_adapter_test.gd --ignoreHeadlessMode`
  - Result: expected failure. The new test resolved a PERFECT parry through
    Cinderpaw's runtime combat component, but MainScene did not yet forward the
    event, so `CombatPresentation` had `0` flash/sparks and the fake audio
    system received `0` parry events.
- Initial GREEN focused: `reports/report_734/`
  - Same focused command.
  - Result: exit `0`, `8/8`.
- Focused after GOOD-parry negative coverage: `reports/report_736/`
  - Same focused command.
  - Result: exit `0`, `9/9`.
  - Notes: Existing Godot process-exit ObjectDB/resource cleanup warnings
    appeared after the GdUnit result; test result itself passed.
- Final related regression: `reports/report_737/`
  - Command:
    `/opt/homebrew/bin/godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/main_scene_audio_event_adapter_test.gd -a res://tests/unit/presentation/combat_presentation_test.gd -a res://tests/unit/presentation/audio_system_test.gd -a res://tests/unit/combat/story_004_parry_timing_counter_outcome_test.gd -a res://tests/unit/gameplay/player_parry_laser_gate_runtime_test.gd --ignoreHeadlessMode`
  - Result: exit `0`, `72/72`.
  - Coverage: MainScene bridge, PERFECT/GOOD parry presentation behavior,
    parry SFX mapping, Core parry timing windows, and Story019 parry laser gate.
  - Notes: Existing Godot process-exit ObjectDB/resource cleanup warnings
    appeared after the GdUnit result; test result itself passed.

## Headless Smoke

- Main scene:
  - Command: `/opt/homebrew/bin/godot --headless --path . --scene res://scenes/main.tscn --fixed-fps 60 --quit-after 180 --log-file reports/parry_success_feedback_runtime_main_scene_smoke.log`
  - Result: exit `0`.
- Log keyword scan:
  - Command: `rg -n "SCRIPT ERROR|Parse Error|Invalid call|Invalid get index|Cannot open|Failed loading resource|Resource file not found|missing resource|Condition .* is true|ERROR:" reports/parry_success_feedback_runtime_main_scene_smoke.log`
  - Result: no matches.
  - Notes: the console still printed the project's known cleanup-time
    ObjectDB/resource warning after process exit; the smoke log itself contained
    no script, parse, invalid-call, or resource-load errors.

## Godot MCP Runtime

Session: `cinderpaw@c1b2`, Godot `4.6.3-stable`, custom run scene
`res://scenes/main.tscn`, `autosave=false`.

MCP evidence:

- Runtime tree confirmed:
  - `/Main/Player/Sprite` is `AnimatedSprite2D`
  - `/Main/Player/CombatComponent` exists
  - `/Main/CombatPresentation` exists
  - `/root/AudioSystem` exists
- Runtime probe triggered:
  - `player.request_parry()`
  - `player.get_combat_component().resolve_parry_result()`
- Runtime probe returned:
  - `request_ok=true`
  - `metadata.is_success=true`
  - `metadata.parry_type="perfect"`
  - `metadata.parry_frame=0`
  - `metadata.stun_seconds=1.0`
  - Sprite animation `parry`
  - SpriteFrames resource
    `res://assets/characters/cinderpaw/cinderpaw_sprite_frames.tres`
  - `parry_frame_count=3`
  - `presentation_flash_count=1`
  - `presentation_parry_spark_count=22`
  - `presentation_hitstop_frames=8`
  - `presentation_shake_intensity=8.0`
  - `last_sfx_request.sfx_id="sfx_parry_perfect"`
  - `last_sfx_request.stream_found=true`
  - `last_sfx_request.position=(460, 340)`, matching the Cinderpaw sprite
    position used by the enriched parry event
- MCP game logs contained only game helper registration and DataManager
  `boss_configs` / `enemy_stats` load lines.
- MCP editor logs were empty.
- Runtime screenshot was written by the running game to
  `reports/visual/cinderpaw-mcp-parry-success-feedback-runtime-20260626.png`;
  screenshot is `1280x720`, nonblank, and shows the main scene, Cinderpaw,
  Boss HUD, and ability gates.

## Acceptance Mapping

| Acceptance item | Evidence | Status |
| --- | --- | --- |
| MainScene connects player Core parry resolve signal | `report_736`, MCP runtime probe | PASS |
| PERFECT parry routes to presentation | `report_736`, MCP runtime probe | PASS |
| PERFECT parry produces 8 hitstop, strong shake, flash, 20-25 sparks | `report_737`, MCP runtime probe | PASS |
| PERFECT parry routes to audio and requests `sfx_parry_perfect` | `report_737`, MCP runtime probe | PASS |
| GOOD parry routes without PERFECT-only flash/sparks | `report_736` | PASS |
| Metadata preserves Core fields and adds position/source | `report_736`, MCP runtime probe | PASS |
| Existing Core parry timing and laser gate do not regress | `report_737` | PASS |
| Main scene runs under MCP with clean logs and screenshot | Headless smoke, MCP logs, MCP screenshot | PASS |
