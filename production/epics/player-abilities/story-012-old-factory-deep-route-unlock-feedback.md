# Story 012: Old Factory Deep Route Unlock Feedback

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Core / Feature / Gameplay Runtime / Visual Integration
> **Type**: Integration + Gameplay Runtime + Visual/Feel
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-26

## Context

**GDD**: `design/gdd/player-abilities.md`,
`design/gdd/exploration-ability-gating.md`,
`design/gdd/scene-management.md`

**Requirements**: `TR-ability-005`, `TR-explore-001`,
`TR-explore-002`, `TR-explore-006`, `TR-scene-001`

**ADR Governing Implementation**: ADR-0018 Player abilities; ADR-0002 signal
architecture; ADR-0007 Scene management; ADR-0021 Save system architecture.

Stories010-011 made the Old Factory deep-route endpoint functional and paced
the second Rat Minion encounter. Endpoint activation currently changes prompt
text and color only. This story adds a short image-generated unlock VFX when
the endpoint opens so the player gets a readable route-complete payoff.

This is a feedback slice on the existing single-room micro-slice, not a new
factory room or next-area transition.

## Acceptance Criteria

- [x] `FactoryDeepRouteEndpoint` mounts an imported image-generated transparent
  PNG VFX texture for route unlock feedback; no visible `ColorRect` or
  `Polygon2D` placeholder art is used for the feedback.
- [x] Activating the endpoint once spawns exactly one short-lived `Sprite2D`
  unlock VFX near the endpoint and records deterministic diagnostics for tests
  and MCP probes.
- [x] Duplicate endpoint activation attempts return `false` and do not spawn
  extra unlock VFX.
- [x] The unlock VFX expires deterministically after its configured lifetime
  and does not persist as an active runtime node.
- [x] Restoring `factory_deep_route_cleared=true` through scene local state keeps
  the endpoint activated but does not replay the unlock VFX.
- [x] Story010-011 behavior remains valid: guard defeat still gates endpoint
  availability, deep guard activation pacing remains intact, and prior Old
  Factory room content does not regress.
- [x] RED/GREEN focused test, related regression, Godot import, headless smoke,
  and Godot MCP runtime screenshot/log evidence are recorded.

## Out of Scope

- New Old Factory room, full route transition, Boss2, hidden-boss combat,
  savepoints, minimap, new enemy family, or new player abilities.
- Full gate dissolve system for every ExplorationGate, authored final VFX
  replacement, particles/shaders, camera choreography, or SFX asset expansion.
- SaveSystem schema changes; feedback state remains runtime-only while endpoint
  activated/cleared state remains scene-local.

## Implementation Notes

- Keep the VFX owned by `FactoryDeepRouteEndpoint`; the endpoint already owns
  activation state and emits `endpoint_activated`.
- Use a generated transparent PNG mounted on a `Sprite2D` child at activation
  time. Keep it short-lived and deterministic with a test hook that advances
  VFX time without waiting for wall-clock time.
- Do not replay feedback from `set_activated(true)` or
  `OldFactoryEntranceScene.set_local_state(...)`; persistence restores state,
  not one-shot juice.
- Expose small diagnostics such as texture path, active count, lifetime, and
  last spawn metadata for GdUnit and MCP.
- Record the generation prompt, source image, alpha image, runtime PNG, and
  import status in the asset manifest and QA evidence.

## Test Evidence

**Required evidence**:

- `tests/unit/gameplay/old_factory_deep_route_unlock_feedback_test.gd`
- `tests/unit/gameplay/old_factory_deep_guard_activation_pacing_test.gd`
- `tests/unit/gameplay/old_factory_deep_route_micro_slice_runtime_test.gd`
- Godot MCP runtime evidence under
  `production/qa/evidence/old-factory-deep-route-unlock-feedback-2026-06-26.md`

**Status**: [x] Recorded in
`production/qa/evidence/old-factory-deep-route-unlock-feedback-2026-06-26.md`.

## QA Test Cases

- **AC-1**: Imported generated VFX texture.
  - Given: `res://scenes/factory_route_transition_shell.tscn` is instantiated.
  - When: `FactoryDeepRouteEndpoint` diagnostics are inspected.
  - Then: the unlock VFX texture path points to a Godot-imported PNG under
    `assets/environment/old_factory_deep_route/vfx/`, and active feedback
    nodes do not include `ColorRect` or `Polygon2D`.

- **AC-2**: One-shot activation feedback.
  - Given: the entrance guard and deep guard have been defeated.
  - When: the player activates the endpoint once.
  - Then: endpoint activation returns `true`, active VFX count becomes `1`, the
    VFX uses the generated texture, and metadata records `asset_source`.

- **AC-3**: Duplicate activation guard.
  - Given: the endpoint has already been activated.
  - When: activation is requested again.
  - Then: the request returns `false` and active VFX count remains unchanged.

- **AC-4**: Deterministic VFX expiry.
  - Given: unlock VFX is active.
  - When: endpoint VFX time advances beyond its lifetime.
  - Then: active VFX count becomes `0`.

- **AC-5**: Restore does not replay feedback.
  - Given: local scene state restores `factory_deep_route_cleared=true`.
  - When: endpoint diagnostics are inspected after restore.
  - Then: endpoint is activated, route is cleared, and no unlock VFX is active.

## Completion Notes

**Completed**: 2026-06-26
**Criteria**: 7/7 passing
**Deviations**: None. SFX expansion remains out of scope for this VFX-only
feedback slice.
**QA Evidence**:
`production/qa/evidence/old-factory-deep-route-unlock-feedback-2026-06-26.md`
