# Story 028: Old Factory Service Lift Frame Animation

> **Epic**: Scene Management
> **Status**: Complete
> **Layer**: Presentation / Gameplay Integration
> **Type**: Visual / Integration
> **Estimate**: S
> **Manifest Version**: 2026-07-19
> **Last Updated**: 2026-07-19

## Context

**GDD**: `design/gdd/scene-management.md`,
`design/gdd/player-abilities.md`

**ADR Governing Implementation**: ADR-0004: Collision architecture,
ADR-0007: Scene management architecture

Story035 established a service-lift handoff but represented the entire machine
with one generated call-console image. Stories025-027 completed the playable
return, input priority and checkpoint reentry contracts. Story028 adds the
missing player-visible freight lift without changing those gameplay rules.

**Engine**: Godot 4.7 | **Godot AI MCP**: 3.0.2 | **Risk**: LOW

## Acceptance Criteria

- [x] The existing console remains present while a dedicated
  `AnimatedSprite2D + SpriteFrames` renders the actual freight lift.
- [x] `arrive`, `docked_idle` and `depart` each contain exactly three imported
  transparent `384x384` frames with aligned center and bottom anchor.
- [x] First reveal plays non-looping `arrive`, then loops `docked_idle`.
- [x] Only an accepted SceneManager request starts non-looping `depart`; a
  rejected request does not change to departure.
- [x] Completed departure stays on its last frame across repeated sync, and a
  restored exit snapshot does not replay the animation.
- [x] Endpoint locked, available and activated tint is mirrored without moving
  the existing interaction anchor or changing its `96px` radius.
- [x] Story026 cache-first rising-edge input and Story027 return checkpoint
  selection remain green.
- [x] Built-in image generation source, alpha sheet, exact prompt, runtime
  frames, preview, spec and manifest are retained in the project.
- [x] Focused/related GdUnit and one clean Godot MCP runtime acceptance provide
  bounded evidence without a full suite.

## Implementation Notes

- `FactoryServiceLift/Visual` remains the static console used by the shared
  `FactoryDeepRouteEndpoint` contract. `LiftAnimation` and
  `factory_service_lift_animation.gd` own presentation only.
- The presentation state is transient and derived from existing scene flags;
  no SaveSystem field or shared endpoint abstraction was added.
- The accepted SceneManager request calls `begin_departure()` immediately and
  still proceeds through the existing asynchronous transition. Animation never
  blocks input, loading or logical scene commit.
- Runtime diagnostics expose state, animation, visibility, playback, frame,
  frame counts, loops, tint, SpriteFrames path and generation traceability.
- The generated source crossed nominal contact-sheet row boundaries, so the
  retained alpha sheet was segmented into nine full connected components before
  normalization. Equal-cell cropping was deliberately not used.

## Out of Scope

- Input ordering, rising-edge behavior, interaction radius, collision, camera,
  audio, new traversal or a second confirmation input.
- Main's Story027 route selection, Factory spawn application, Return Patrol,
  Lower Deck progression, rewards or SaveSystem schema.
- Refactoring the shared `FactoryDeepRouteEndpoint` into a general lift system.

## Test Evidence

- Intentional RED: `reports/report_2040/results.xml` failed only because
  `FactoryServiceLift/LiftAnimation` did not exist.
- Initial focused GREEN: `reports/report_2041/results.xml` passed `1/1`.
- Review regression RED/GREEN: `report_2043` exposed Godot `stop()` resetting
  the held departure frame; `report_2044` passed both lifecycle cases after the
  call-order fix.
- Final related GREEN: `reports/report_2045/results.xml` passed three suites and
  `5/5` cases with zero errors, failures, flaky cases, skips or orphans.
- Story027 destination regression remained green in `report_2042` (`3/3`) and
  its route-selection code was not changed afterward.
- Godot MCP 3.0.2 run `r364813803-125` in Godot 4.7 verified the live
  `AnimatedSprite2D`, Nearest filtering, three-state frame/loop contract,
  `arrive -> docked_idle`, real-input `depart`, accepted `main/scrap_roost`, a
  non-empty `1278x718` screenshot, clean game/editor logs and ready stop state.
- Detailed runtime evidence:
  `production/qa/evidence/old-factory-service-lift-frame-animation-2026-07-19.md`.
