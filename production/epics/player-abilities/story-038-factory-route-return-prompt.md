# Story 038: Factory Route Return Prompt

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Scene Management / UI Feedback
> **Type**: Integration + Gameplay Runtime + Scene Management + UI
> **Estimate**: XS
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-30

## Context

**GDD**: `design/gdd/player-abilities.md`,
`design/gdd/exploration-ability-gating.md`,
`design/gdd/scene-management.md`

**Requirements**: `TR-ability-005`, `TR-scene-001`, `TR-scene-003`,
`TR-scene-005`

**ADR Governing Implementation**: ADR-0007 Scene management; ADR-0018 Player
abilities; ADR-0021 Save system.

Story037 hardens the player-visible runtime loop
`main -> area_03_factory -> main/scrap_roost`. This story adds a small
player-visible clarity pass: after the Factory service lift has returned the
player to Scrap Roost, the main-scene Factory route entrance should read as a
return route instead of a first-time route entry.

## Acceptance Criteria

- [x] From the real `scenes/main.tscn`, an unlocked Factory route without a
  valid service-lift return state continues to show `Enter Factory Route`.
- [x] When `area_03_factory` scene state records
  `factory_service_lift_exit_requested=true`,
  `factory_service_lift_exit_scene_id="main"`, and
  `factory_service_lift_exit_spawn_point="scrap_roost"`,
  `FactoryRouteTransitionShell` shows `Return to Factory Route`.
- [x] Incomplete or wrong return state does not show the return prompt.
- [x] Locked route state remains locked and does not become available because
  service-lift return state exists.
- [x] The prompt change does not alter the route target; activation still
  requests `area_03_factory / factory_gate_entry`.
- [x] Focused and related GdUnit regressions, headless main-scene smoke, and
  Godot MCP runtime evidence pass with no new project script errors.

## Out of Scope

- New Factory rooms, enemies, combat encounters, rewards, minimap updates,
  fast travel UI, SaveSystem schema changes, SceneManager architecture changes,
  moving lift animation, new visual/audio assets, and new character animation
  states.

## Implementation Notes

- `MainScene` now owns explicit Factory route prompt constants:
  `FACTORY_ROUTE_ENTRY_PROMPT` and `FACTORY_ROUTE_RETURN_PROMPT`.
- `_sync_factory_route_transition_shell()` updates the existing
  `RouteTransitionShell.available_prompt_text` before applying route
  availability.
- `_has_factory_service_lift_returned_to_scrap_roost()` reads
  `SceneManager.get_scene_state(&"area_03_factory")` and only returns true for
  the full service-lift exit contract back to `main / scrap_roost`.
- No new visual assets were generated. This story reuses the existing
  image-generated Factory route shell, main-scene `PromptLabel`, Cinderpaw,
  Boss2, Factory route, Old Factory, Spark Rat, and service lift assets.
- No new player-visible character or gameplay animation state was added, so the
  AGENTS.md `AnimatedSprite2D + SpriteFrames` new-character rule is not
  triggered by this story.

## Test Evidence

- Story038 RED focused: `reports/report_908/` failed on incorrect return prompt
  text before the prompt synchronization was fixed.
- Story038 focused GREEN after implementation: `reports/report_909/` passed
  `1/1` with `0` orphans.
- Story038 negative-coverage RED: `reports/report_911/` failed because the new
  locked-route assertion initially expected the wrong authored locked text.
- Story038 final focused GREEN: `reports/report_912/` passed `2/2` with `0`
  orphans.
- Related regression: `reports/report_913/` passed `7/7` with `0` orphans
  across Story038, Factory route shell, Boss2 victory route handoff, and
  Story037 Factory route runtime roundtrip.
- Headless main scene smoke:
  `reports/factory_route_return_prompt_main_scene_smoke.log` exited `0`;
  keyword scan found no script, parse, invalid-call, invalid-access,
  missing-resource, resource-load, or `ERROR:` entries.
- Godot MCP runtime evidence:
  `production/qa/evidence/factory-route-return-prompt-2026-06-30.md`.

**Status**: [x] Complete.
