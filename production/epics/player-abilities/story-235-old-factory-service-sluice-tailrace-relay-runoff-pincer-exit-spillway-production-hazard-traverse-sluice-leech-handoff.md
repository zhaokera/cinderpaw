# Story 235: Old Factory Service Sluice Tailrace Relay Runoff Pincer Exit Spillway Production Hazard Traverse Sluice Leech Handoff

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Traversal / Route Handoff
> **Type**: Integration + Production Movement + Physical Hazard + Route Handoff
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-22

## Context

**GDD**: `design/gdd/player-abilities.md`, `design/gdd/input.md`,
`design/gdd/collision-detection.md`, `design/gdd/health-death.md`,
`design/gdd/exploration-ability-gating.md`,
`design/gdd/scene-management.md`, `design/gdd/death-respawn.md`

**Requirements**: `TR-input-001`, `TR-collision-004`, `TR-health-001`,
`TR-health-002`, `TR-scene-004`, `TR-explore-005`, `TR-respawn-002`

**ADR Governing Implementation**: ADR-0004 collision detection; ADR-0007
scene management.

Story234 opens the post-pincer exit hatch through one fresh production
`interact` edge and leaves Story124 visible, available and idle. Story235
closes that playable ACT traversal: real continuous positive-x movement starts
the authored steam cadence, a physical overlap applies one exact hit, and a
second guarded movement crossing exposes Story126 without consuming it in the
same frame or through stationary threshold placement.

## Acceptance Criteria

- [x] Story234 terminal state exposes Story124 as visible and available but
  inactive, uncrossed, idle and non-contacting. Story126 remains unavailable,
  inactive, hidden, untargeted, non-processing and non-physical.
- [x] Story124 automatic activation requires availability at frame start,
  initialized previous-x tracking, held continuous `move_right`, positive-x
  displacement and current x at or beyond `16560`. No-input placement beyond
  the threshold remains idle.
- [x] Production processing runs the first cadence as grace `0.25s`, warning
  `0.35s`, active `0.40s` and safe `0.45s`. Grace uses the safe presentation;
  safe, warning and active each use the existing four-frame
  `AnimatedSprite2D + SpriteFrames` animation.
- [x] Only active steam enables the real vent `Area2D`, collision shape,
  monitoring and monitorability at collision layer `16`, mask `12`. All other
  phases are non-contacting with layer/mask `0/0`.
- [x] One real physics overlap during active steam applies exact player HP
  `100 -> 92`, damage `8`, type `steam`, the full Story124 hazard source and
  visible Cinderpaw `hurt` presentation. The acceptance path does not call the
  contact-damage API directly.
- [x] Story124 automatic completion requires active state at frame start,
  initialized previous-x tracking, held `move_right`, positive-x displacement
  and current x at or beyond `17040`. No-input placement beyond the exit does
  not cross.
- [x] A qualifying movement frame persists crossed state, changes phase to
  `crossed`, disables contact and displays `Tailrace Exit Spillway Crossed`.
- [x] Story126 uses its own frame-start availability snapshot and previous-x
  tracker. The Story124 crossing frame cannot activate it, and no-input
  placement beyond x `17360` or held input without displacement keeps it
  waiting.
- [x] Terminal Story126 state is available but inactive/uncleared; entity
  `2146` stays hidden, untargeted, non-processing and non-physical, with its
  activated/defeated/cleared persistence keys false. The Story119 Tailrace
  Relay checkpoint remains unchanged.
- [x] Canonical/focused/related GdUnit, one 180-frame smoke and one Godot MCP
  runtime pass succeed under Godot 4.7 / Godot AI MCP 3.0.4 with clean
  accepted-run logs and non-empty ready/warning/active/crossed screenshots.

## Out of Scope

Story126 successful production activation, attack tell, lunge, combat, damage,
defeat or clear persistence; Story127 Matriarch transition; public direct-API
contract changes; hazard balance changes; new assets, enemies, rewards,
savepoints, audio, particles, shaders, save schema, route expansion or
full-suite testing.

## Implementation Notes

- Production auto-routing snapshots Story124 active and Story126 available at
  frame start. This prevents same-frame state cascades while preserving the
  continuous movement action defined by the input GDD.
- Story124 completion and Story126 activation use separate previous-x trackers.
  `set_local_state()` resets both trackers so restore or diagnostic placement
  cannot be mistaken for player movement.
- Public Story124/126 activation and completion methods retain their existing
  authored direct-test contracts; movement guards apply only to automatic
  production routing.
- The related Story126 test now matches the shared RatMinion live-death
  contract: a freshly defeated enemy remains visible/processing for its death
  animation while targeting, physics and collision are disabled. Restored
  cleared state remains hidden.

## Asset Pipeline

No new asset was required. The slice reuses the image-generated Story125
spillway, Story033 four-frame steam animations, Cinderpaw frame animation and
Story126 Sluice Leech frames already imported by Godot. Reuse is recorded in
`design/assets/asset-manifest.md`.

## Test Evidence

- Canonical RED: `reports/report_2405/results.xml`, one case with two expected
  failures proving no-input Story124 crossing and no-input Story126 activation.
- Initial focused GREEN: `reports/report_2406/results.xml`, `1/1`.
- Related regression evidence: `reports/report_2407/results.xml`; Story235 and
  adjacent Story234/231/124 behavior passed, while two old Story126 immediate-
  hide assertions exposed drift from the shared live-death contract.
- Standalone diagnostic RED/GREEN: `reports/report_2408/results.xml` reproduced
  only those two assertions; `reports/report_2409/results.xml` passed Story126
  `2/2` after aligning the test with the shared death presentation.
- Final bounded related GREEN: `reports/report_2410/results.xml`, five suites
  and `7/7`; zero errors, failures, flaky, skipped or orphaned tests.
- The 180-frame smoke exited `0`, printed
  `story124_production_smoke=passed frames=180`, and is recorded in
  `reports/old_factory_service_sluice_tailrace_relay_runoff_pincer_exit_spillway_smoke.log`.
- Godot MCP 3.0.4 accepted run `r200395661-39`, token `39`, exercised real
  `move_right`, production processing, physical overlap and waiting guards.
  Current-run game logs were helper-only and the editor delta after cursor `2`
  was empty.

## Dependencies

- Depends on: Story234 production hatch input; Story124/125 authored spillway;
  Story126 authored Sluice Leech gate and frame animation
- Unlocks: Story236 real Story126 movement/combat/live-death closure into the
  Story127 Sluice Matriarch route handoff

## Verification Summary

Accepted under Godot 4.7 / Godot AI MCP 3.0.4. Story124 is now a complete
production movement and physical-hazard beat, and its crossing hands off an
unconsumed Story126 encounter. Existing authored assets remained readable at
runtime, so no image generation or import change was needed. Full-suite testing
was intentionally omitted.
