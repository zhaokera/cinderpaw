# QA Evidence: Scrap Roost Return Hub Runtime

> **Story**: Player Abilities Story039
> **Date**: 2026-06-30
> **Engine**: Godot 4.7
> **Scope**: Player-visible Scrap Roost return hub closure after the Factory
> service lift returns the player to `main / scrap_roost`.

## Automated Evidence

- RED focused: `reports/report_916/` failed as expected before implementation.
  The test caught missing `last_savepoint`, missing
  `scrap_roost_return_hub_secured`, missing savepoint position, and missing HUD
  `Returned to Scrap Roost` notification.
- Focused GREEN: `reports/report_917/` passed `2/2` with `0` orphan nodes:
  - complete Factory service-lift return state plus current
    `main / scrap_roost` secures the hub once
  - incomplete return state does not secure the hub or show the return
    notification
- Related regressions passed independently:
  - `reports/report_918/` Story038 Factory route return prompt `2/2`
  - `reports/report_919/` Factory route runtime roundtrip `1/1`
  - `reports/report_920/` Main scene savepoint runtime `3/3`
  - `reports/report_921/` Factory route transition shell runtime `3/3`
  - `reports/report_922/` Old Factory service-lift SceneManager exit `2/2`
  - `reports/report_923/` Old Factory service-lift handoff `2/2`
- Headless main-scene smoke:
  `reports/scrap_roost_return_hub_main_scene_smoke.log` exited `0`.
  Keyword scan found no `SCRIPT ERROR`, parse error, invalid call/access,
  missing resource, or failed resource load. Godot still reports existing
  cleanup-time ObjectDB/resource messages after process exit.

## MCP Runtime Evidence

- MCP session `cinderpaw@573d` connected to Godot `4.7-stable (official)`.
- Runtime launched the project main scene with `autosave=false`.
- Runtime scene tree confirmed:
  - `/Main/ScrapRoostSavepoint` present, visible, group `savepoint`,
    `savepoint_id="scrap_roost"`, `scene_id="main"`,
    `spawn_point="scrap_roost"`, authored position `(210, 432)`
  - `/Main/FactoryRouteTransitionShell` present, target
    `area_03_factory / factory_gate_entry`
  - `/Main/Player/Sprite` is `AnimatedSprite2D` using
    `res://assets/characters/cinderpaw/cinderpaw_sprite_frames.tres`
- Runtime probe set SceneManager current scene/spawn to `main / scrap_roost`,
  wrote the full `area_03_factory` service-lift return state, unlocked
  `area_03_factory_unlocked`, and resynced MainScene.
- Probe result:
  - `secured == true`
  - `factory_route_unlocked == true`
  - `service_lift_returned == true`
  - `current_scene == "main"`
  - `current_spawn_point == "scrap_roost"`
  - `last_savepoint.id == "scrap_roost"`
  - `last_savepoint.scene_id == "main"`
  - `last_savepoint.spawn_point == "scrap_roost"`
  - `last_savepoint.position == (210, 432)`
  - `hud_notification_text == "Returned to Scrap Roost"`
- MCP screenshot metadata from the running game returned a non-empty
  framebuffer (`1278x718` original, scaled `720x404`).
- MCP game logs contained only helper/DataManager info lines.
- MCP editor logs contained only unrelated Godot file-system warnings about
  auto-recreated `.uid` files for existing tests:
  `boss2_phase_two_runtime_test.gd` and
  `audio_system_boss2_phase_mix_test.gd`.

## Notes

- No new visual or audio assets were generated for this story.
- No new player-visible character or gameplay animation state was introduced;
  this story reuses existing `AnimatedSprite2D + SpriteFrames` character assets
  and the existing image-generated Scrap Roost savepoint.
- The hub closure deliberately records progress through `discover_savepoint()`
  and does not call `activate_runtime_savepoint()`, so it does not trigger
  savepoint autosave or the normal `Scrap Roost saved` notification.
