# Story 228: Old Factory Service Sluice Tailrace Production Hazard Traverse Ambush Handoff

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Traversal Hazard / Route Handoff
> **Type**: Integration + Production Movement + Physical Hazard + Route Handoff
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-22

## Context

**GDD**: `design/gdd/player-abilities.md`,
`design/gdd/exploration-ability-gating.md`, `design/gdd/feline-combat.md`,
`design/gdd/scene-management.md`, `design/gdd/death-respawn.md`

**Requirements**: `TR-scene-004`, `TR-explore-005`, `TR-respawn-002`

**ADR Governing Implementation**: ADR-0004 Collision detection; ADR-0007 Scene
management; ADR-0018 Player abilities; ADR-0021 Save system.

Story227 opens the service-sluice exit Hatch and leaves Story117 visible but
inactive. Story228 turns that handoff into a production ACT traverse: real
positive-x movement starts the tailrace, the existing animated steam vent runs
through its full physical hazard cadence, and a real crossing exposes Story118
without prematurely starting its Coil Rat ambush.

## Acceptance Criteria

- [x] Story227 terminal state leaves Story117 visible, available, inactive and
  uncrossed while Story118 remains unavailable, inactive and hidden.
- [x] Tailrace environment tiles `09` and `10` use the imported image-generated
  tailrace background instead of the generic Factory route texture.
- [x] No-input placement beyond activation x `12020` does not activate Story117;
  held `move_right` plus real positive-x displacement activates it and displays
  `Cross Service Sluice Tailrace`.
- [x] `SteamAnimation` is an `AnimatedSprite2D` with four-frame
  `warning`/`active` presentation and follows `grace -> warning -> active -> safe`.
- [x] Steam monitoring and collision use layer `16` / mask `12` only while
  active; a real `Area2D` overlap applies exact HP `100 -> 92`, damage `8`, type
  `steam`, and the Story117 hazard source id.
- [x] No-input placement beyond exit x `12480` does not complete Story117; real
  positive-x `move_right` crossing completes it once, disables contact and
  persists the crossed flag.
- [x] The crossing frame makes Story118 available but leaves it inactive,
  hidden, untargeted and non-processing.
- [x] Stationary/no-input placement at x `12624`, and held `move_right` without
  positive displacement, do not activate Story118.
- [x] Focused/related GdUnit, a `180`-frame headless smoke, and Godot MCP runtime
  checks pass under Godot 4.7 / Godot AI MCP 3.0.4.

## Out of Scope

Story118 production activation, combat, damage and defeat; Story119 relay
handoff; new visual/audio assets, savepoints, particles, shaders, image
generation, and full-suite testing.

## Implementation Notes

- Story117 completion and Story118 activation now each track previous player x
  and require held `move_right` plus real positive displacement.
- Story118 availability is snapshotted at frame start, preventing Story117's
  crossing frame from also activating the ambush.
- Existing direct diagnostic APIs remain unchanged; production guards live in
  the automatic runtime path.
- Hazard acceptance uses the real vent `Area2D` overlap path, including the
  normal post-restore hazard cooldown, rather than calling damage directly.

## Asset Pipeline

Existing imported image-generated tailrace background, duct, four-frame steam,
Cinderpaw and Factory Coil Rat assets cover the slice. No new visual asset or
animation resource was required.

## Test Evidence

- Canonical RED: `reports/report_2372/report_1/results.xml`, `1` test with four
  expected failures for tiles `09/10`, no-input Story117 completion and
  no-input Story118 activation.
- Focused GREEN: `reports/report_2373/report_1/results.xml`, `1/1`.
- Related diagnostic runs `reports/report_2374/report_1/results.xml` and
  `reports/report_2375/report_1/results.xml` isolated one stale Story118 death
  visibility expectation; no production regression was found.
- Corrected Story118 contract:
  `reports/report_2376/report_1/results.xml`, `2/2`.
- Final related GREEN: `reports/report_2377/report_1/results.xml`, five suites
  and `7/7`, zero errors/failures/skips.
- Headless smoke exited `0` with `story228_smoke=passed frames=180`.
- Godot MCP 3.0.4 session `cinderpaw@198e`, accepted run `r184730101-26`, used
  real `move_right`, real vent overlap and stationary handoff probes; current-run
  game log was helper-only, editor delta after cursor `2` was empty, inputs were
  released, three RGB `1278x718` framebuffers were non-empty, and playback
  stopped at readiness `ready`.

## Dependencies

- Depends on: Story227 production Hatch input and guarded Story117 handoff
- Unlocks: Story118 production movement, combat and live-death closure

## Verification Summary

Accepted under Godot 4.7 / Godot AI MCP 3.0.4. Story117 now runs as a real
movement-driven physical hazard traverse and hands off to an available but
safely inactive Story118. Full-suite testing was intentionally omitted.
