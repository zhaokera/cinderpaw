# Factory Overdrive Cache / Service-Lift Input Priority Evidence

## Scope

- Story: `production/epics/scene-management/story-026-factory-overdrive-cache-service-lift-input-priority.md`
- Scene: `res://scenes/factory_route_transition_shell.tscn`
- Runtime script: `res://src/gameplay/old_factory_entrance_scene.gd`
- Focused test: `res://tests/unit/gameplay/old_factory_overdrive_cache_input_priority_test.gd`
- Engine: Godot 4.7 stable
- Godot AI MCP: 3.0.2

## Automated Evidence

| Gate | Result | Evidence |
|------|--------|----------|
| Intentional Story RED | Expected failure, one case with four failed assertions | `reports/report_2025/results.xml`: production input requested the lift before claiming the cache |
| Focused GREEN | Pass `1/1` | `reports/report_2026/results.xml` |
| Related regression | Pass `9/9` | `reports/report_2027/results.xml` |
| Overdrive Duo regression | Pass `4/4` | `reports/report_2028/results.xml` |

The related run covered the production-input priority case, direct overdrive
reward contract, service-lift SceneManager exit, Story025 return-loop input and
Story024 entry-route input. The additional Overdrive Duo run retained its full
clear-to-lift state chain. All final reports recorded zero errors, failures,
flaky cases, skips or orphan nodes. No full suite was run.

## MCP Runtime Acceptance

Final run `r352318194-116` launched
`res://scenes/factory_route_transition_shell.tscn` through Godot MCP.

Overlap and first-input probe:

- MCP restored the complete post-Overdrive-Duo state with the reward unclaimed,
  the service lift idle and its `main/scrap_roost` contract intact.
- The Player began at the reward-cache center `(1148, 394)`. Diagnostics
  reported both `cache.claim_available=true` and
  `lift.activation_ready=true` before input.
- MCP pressed and held the production `interact` action. The cache became
  claimed with one `{gears: 25, source: old_factory_checkpoint_overdrive_cache}`
  payload and feedback `Overdrive Cache Claimed +25 Gears`.
- While the action remained pressed, the lift stayed unactivated, recorded no
  exit request and SceneManager exposed no pending scene. This verifies that a
  held input cannot chain both actions.

Second-input and handoff probe:

- MCP released `interact`, placed the Player on the stable floor overlap at
  `(1122, 450)`, then pressed the same production action again.
- The lift recorded `activated=true`, `exit_requested=true`, route feedback
  `Service Lift Departing`, and one accepted pending destination of
  `main/scrap_roost`.
- The already-claimed cache did not replay or alter its `25 Gears` payload.

Presentation and log gate:

- The `1278x718` game framebuffer was non-empty and showed the generated
  Factory environment with the reward-cache/service-lift interaction area.
- Game log contained one MCP helper registration info line and no warning or
  error. Editor log contained zero entries.
- MCP stopped the project cleanly after acceptance.

## Asset Decision

No new visual asset was generated. The slice changes only production input
ordering and reuses the existing image-generated Factory environment, overdrive
cache, service lift and existing frame-animated characters.
