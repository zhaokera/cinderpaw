# QA Evidence: Factory Route Return Prompt

> **Story**: Player Abilities Story038
> **Date**: 2026-06-30
> **Engine**: Godot 4.7
> **Scope**: Player-visible Factory route return prompt after the Old Factory
> service lift returns the player to Scrap Roost.

## Automated Evidence

- RED focused: `reports/report_908/` failed as expected before the prompt
  synchronization fix. The focused test expected `Return to Factory Route` and
  caught incorrect return prompt output.
- Initial GREEN focused: `reports/report_909/` passed `1/1` with `0` orphan
  nodes.
- Negative-coverage RED: `reports/report_911/` failed while adding locked and
  incomplete-state coverage because the test expected generic `Route locked`
  instead of the authored main-scene `Factory route locked` text.
- Final focused GREEN: `reports/report_912/` passed `2/2` with `0` orphan
  nodes:
  - valid service-lift return state changes prompt to
    `Return to Factory Route` and preserves target
    `area_03_factory / factory_gate_entry`
  - locked route and incomplete return state do not show the return prompt
- Related regression: `reports/report_913/` passed `7/7` with `0` orphan nodes:
  - Story038 Factory route return prompt
  - Factory route transition shell runtime
  - Boss2 victory route handoff
  - Story037 Factory route runtime roundtrip
- Headless main-scene smoke:
  `reports/factory_route_return_prompt_main_scene_smoke.log` exited `0`.
  Keyword scan found no `SCRIPT ERROR`, parse error, invalid call/access,
  missing resource, failed load, or `ERROR:` entry. Godot still reports the
  existing cleanup-time ObjectDB/resource warnings after process exit.

## MCP Runtime Evidence

- MCP session `cinderpaw@573d` connected to Godot `4.7-stable (official)`.
- Runtime launched the project main scene with `autosave=false`.
- Probe used public runtime APIs to:
  - unlock `area_03_factory_unlocked`
  - write `area_03_factory` scene state with
    `factory_service_lift_exit_requested=true`,
    `factory_service_lift_exit_scene_id="main"`, and
    `factory_service_lift_exit_spawn_point="scrap_roost"`
  - resync the existing main-scene `FactoryRouteTransitionShell`
  - move the player to the Factory route entrance and request the transition
- Request probe result:
  - `prompt == "Return to Factory Route"`
  - `label_text == "Return to Factory Route"`
  - `available == true`
  - `loading_before == false`
  - `request_result == true`
  - `loading_after == true`
  - `pending_scene == "area_03_factory"`
  - `pending_spawn == "factory_gate_entry"`
- Screenshot probe result:
  - Prompt stayed visible with `transition_requested == false`.
  - `label_text == "Return to Factory Route"`
  - `target_scene == "area_03_factory"`
  - `spawn_point == "factory_gate_entry"`
  - screenshot saved with `save_error == 0`,
    `image_size == 1278x718`.
- Screenshot:
  `reports/visual/cinderpaw-mcp-factory-route-return-prompt-20260630.png`
  is nonblank and shows the main scene with the right-side Factory route prompt
  reading `Return to Factory Route`.
- MCP game logs contained only helper/DataManager info lines.
- MCP editor logs contained only unrelated Godot file-system warnings about
  auto-recreated `.uid` files for existing tests:
  `boss2_phase_two_runtime_test.gd` and
  `audio_system_boss2_phase_mix_test.gd`.

## Notes

- No new visual or audio assets were generated for this story.
- No new player-visible character or gameplay animation state was introduced;
  this story reuses existing `AnimatedSprite2D + SpriteFrames` character assets
  and the existing Factory route shell prompt label.
- This is a player-visible route clarity polish story after Story037's runtime
  roundtrip, not a new combat encounter or deeper ACT content slice.
