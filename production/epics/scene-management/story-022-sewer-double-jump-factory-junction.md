# Story 022: Sewer Double-Jump Factory Junction

> **Epic**: Scene Management
> **Status**: Complete
> **Layer**: Feature / Gameplay Integration
> **Type**: Gameplay / Traversal / Visual / Persistence
> **Estimate**: M
> **Manifest Version**: 2026-07-19
> **Last Updated**: 2026-07-19

## Context

**GDD**: `design/gdd/exploration-ability-gating.md`,
`design/gdd/scene-management.md`, `design/gdd/player-abilities.md`

**ADR Governing Implementation**: ADR-0004: Collision architecture,
ADR-0007: Scene management architecture

Story020 and Story021 established the playable Sewer Dash route and pressure
ambush. Story022 completes the GDD's `Sewer -> Factory` boundary with a physical
high platform: Dash alone keeps the route unreachable, while a real airborne
Double Jump opens the gate and hands the player to `area_03_factory`.

**Engine**: Godot 4.7 | **Risk**: MEDIUM

## Acceptance Criteria

- [x] The upper-right pressure-room ledge has authored collision, a generated
  factory platform visual, a visible upward claw marker and a generated Factory
  pipe entrance; no player-facing placeholder rectangle is introduced.
- [x] A normal jump or jump plus Dash cannot reach the high route. The existing
  low exit remains available and still returns to `main/sewer_return`.
- [x] A Player that owns `double_jump` must perform the real second jump near
  the high platform before `double_jump_high_platform` becomes `unlocked`.
- [x] Reaching the opened entrance requests
  `area_03_factory/factory_gate_entry` exactly once.
- [x] Dash, Double Jump, Story020 crossing state, Story021 clear/cache state and
  current Gears persist across the handoff and cold restore.
- [x] Main can no longer bypass Sewer for first Factory entry. Its historical
  Factory shell is available only after the Factory service lift has returned
  to `main/scrap_roost`.
- [x] One intentional RED, focused GREEN, bounded related regression and one
  clean Godot MCP runtime acceptance provide evidence without a full suite.

## Implementation Notes

- `SewerFactoryHighPlatform`, `SewerFactoryDoubleJumpGate` and
  `SewerFactoryRouteShell` compose the junction inside the existing pressure
  chamber. The gate gameplay anchor is centered on the landing while its
  collision and marker remain at the right edge.
- The Sewer owns first-entry route authority and seeds Factory/Main scene state
  only after SceneManager accepts the request. The transition latch resets on
  restore, so an opened gate does not auto-request another scene.
- Main retains its historical Double-Jump marker for save and presentation
  compatibility, but that marker no longer grants first-entry access. The old
  Main shell is now strictly the post-service-lift return shortcut.
- Factory local state now carries Gears so the Sewer handoff cannot silently
  drop currency.

## Asset Reuse

- Reused image-generated Story021 pressure-chamber background.
- Reused image-generated Old Factory entry platform, Double-Jump claw marker
  and Factory route shell. No new visual generation was needed.
- Full reuse and import contract:
  `design/assets/specs/sewer-double-jump-factory-junction.md`.

## Out of Scope

- A new Double Jump reward, new gate ID, new Factory scene, second Sewer enemy,
  additional cache, dialogue, tutorial overlay or full Factory rebalance.
- Removing the historical Main gate marker and migrating every legacy save
  representation; the bypass is closed at the route-shell authority boundary.

## Test Evidence

- Intentional RED: `reports/report_1985/report_1/results.xml` failed the single
  acceptance at the absent junction diagnostics boundary.
- Focused GREEN: `reports/report_1989/report_1/results.xml` passed `1/1` with
  zero errors, failures, flaky cases, skips or orphans and exit `0`.
- Final related GREEN: `reports/report_1994/results.xml` passed eight
  suites and `13/13` cases with zero test errors/failures/flaky/skips/orphans
  and exit `0`. No full suite ran.
- Post-review focused checks `reports/report_1995/results.xml` and
  `reports/report_1996/results.xml` each passed `1/1` after removing stale test
  helpers and moving target-state writes behind SceneManager acceptance.
- Godot MCP 3.0.2 visual run `r330692286-102` rendered the non-empty `1278x718`
  junction screenshot. Final post-review run `r332238403-103` again drove real
  `move_right` plus two `jump` actions, persisted the opened high-platform gate
  and Factory route, retained all abilities plus `22 Gears`, returned only
  three initialization info lines and zero editor errors, then stopped cleanly.
- Detailed evidence:
  `production/qa/evidence/sewer-double-jump-factory-junction-2026-07-19.md`.
