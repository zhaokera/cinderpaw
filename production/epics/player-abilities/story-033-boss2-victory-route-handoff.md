# Story 033: Boss2 Victory Route Handoff

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Scene Management / Presentation
> **Type**: Integration + Gameplay Runtime + Visual/Feel
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-30

## Context

**GDD**: `design/gdd/player-abilities.md`,
`design/gdd/exploration-ability-gating.md`,
`design/gdd/scene-management.md`, `design/gdd/audio-system.md`

**Requirements**: `TR-ability-005`, `TR-scene-001`, `TR-scene-003`

**ADR Governing Implementation**: ADR-0002 Signal communication; ADR-0007
Scene management; ADR-0018 Player abilities; ADR-0021 Save system.

Stories021-032 made Boss2 visible, animated, sealed, HUD-focused, and playable
through a Phase II pressure mix. The post-victory chain still needed one
end-to-end player-facing handoff: defeat Echo Guardian, claim Double Jump, use
Double Jump to open the high-platform gate, and enter the Factory Route shell
without relying on tester knowledge of separate systems.

## Acceptance Criteria

- [x] Defeating `Boss2EchoGuardian` records
  `boss_02_echo_guardian_defeated`, releases the Boss2 room seals, and shows a
  clear HUD prompt that tells the player to claim Double Jump.
- [x] `Boss2DoubleJumpRewardSource` exposes deterministic diagnostics for
  prompt text, claimability, and visual state; defeat changes the prompt from
  `Defeat Echo Guardian` to `Claim Double Jump`.
- [x] Claiming the Boss2 reward unlocks exactly one `double_jump`, records
  `boss_02_double_jump_claimed`, and moves `DoubleJumpExplorationGate` into
  `unlockable`.
- [x] Using Double Jump at `DoubleJumpExplorationGate` unlocks
  `area_03_factory_unlocked`, makes `FactoryRouteTransitionShell` available,
  and shows `Enter Factory Route`.
- [x] Requesting the route transition sends `area_03_factory /
  factory_gate_entry` to the configured SceneManager, shows the HUD loading
  label `Factory Route`, and rejects duplicate route requests while loading.
- [x] Focused RED/GREEN tests, related Boss2/route regressions, headless smoke,
  and Godot MCP runtime evidence are recorded.

## Out of Scope

- New Factory room content, minimap markers, fast-travel UI, new Boss2 attacks,
  cutscenes, final balancing, and new visual or audio assets.

## Implementation Notes

- Keep this story as orchestration over existing systems: Boss2 defeated flag,
  Boss2 reward source, ExplorationGate, RouteTransitionShell, SceneManager, and
  HUD.
- Do not add a new autoload or generic quest system.
- Use diagnostics for test/MCP observability instead of scene-tree guessing.
- Reuse existing generated Boss2 reward, room seal, gate, and Factory Route
  shell assets. No new image generation is required for this slice.

## Test Evidence

- Story033 RED focused: `reports/report_879/` failed as expected before
  `MainScene` exposed Boss2 victory route handoff diagnostics.
- Story033 GREEN focused: `reports/report_880/` passed `1/1`.
- Related regression: `reports/report_881/` passed `14/14` across Story033,
  Boss2 Double Jump payoff, Factory Route transition shell, Boss2 room seal,
  and Boss2 camera lock suites.
- Headless main-scene smoke:
  `reports/boss2_victory_route_handoff_main_scene_smoke.log`; keyword scan
  found no script, parse, invalid-call, missing-resource, or resource-load
  errors; only Godot's known cleanup-time `resources still in use at exit`
  message appeared after exit.
- Godot MCP 2.8.1 runtime evidence and screenshot:
  `production/qa/evidence/boss2-victory-route-handoff-2026-06-30.md`.

**Status**: [x] Complete.
