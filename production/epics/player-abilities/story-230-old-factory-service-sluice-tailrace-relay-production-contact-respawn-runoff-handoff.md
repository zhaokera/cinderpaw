# Story 230: Old Factory Service Sluice Tailrace Relay Production Contact Respawn Runoff Handoff

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Savepoint / Route Handoff
> **Type**: Integration + Production Movement + Contact Activation + Death/Respawn + Route Handoff
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-22

## Context

**GDD**: `design/gdd/player-abilities.md`,
`design/gdd/exploration-ability-gating.md`, `design/gdd/scene-management.md`,
`design/gdd/death-respawn.md`

**Requirements**: `TR-scene-004`, `TR-explore-005`, `TR-respawn-002`,
`TR-respawn-004`

**ADR Governing Implementation**: ADR-0004 collision detection; ADR-0007
scene management; ADR-0018 player abilities; ADR-0021 save system.

Story229 leaves Story119 visible and waiting after the Tailrace Coil Rat dies.
Story230 closes the relay's production ACT beat: real movement enters the
contact, the relay becomes the exact restart anchor, lethal player damage
returns Cinderpaw at 50% HP, and Story120 is revealed without being silently
started by the relay handoff or a no-input position change.

## Acceptance Criteria

- [x] Story118 clear state leaves Story119 available, visible, monitoring and
  unactivated while Story120 remains unavailable and hidden.
- [x] Real `move_right` movement starts outside the relay overlap and activates
  Story119 through `SavepointRuntime.body_entered`; no direct relay activation
  API is used.
- [x] Activation occurs exactly once, disables relay contact/collision, hides
  `Repair Tailrace Relay`, spawns one existing unlock VFX and records the exact
  relay id, scene `area_03_factory` and relay spawn point.
- [x] Story120 becomes available and visible but remains `idle`, inactive,
  uncrossed and non-contacting after relay activation.
- [x] Placing the player beyond Story120 activation x without fresh
  `move_right` input and positive-x displacement cannot start the runoff.
- [x] Real lethal `PlayerController.apply_damage` enters the three-frame
  `death` state. The Factory respawn flow selects the relay, restores 50% HP,
  plays `revive`, locks control during protection and returns to `playing`.
- [x] Respawn feedback reads `Returned to Tailrace Relay`; Story120 remains
  idle and the relay activation VFX is not replayed.
- [x] Focused/related GdUnit, one `180`-frame smoke and one Godot MCP runtime
  pass under Godot 4.7 / Godot AI MCP 3.0.4 with clean current-run logs and
  non-empty screenshots.

## Out of Scope

Story120 production hazard activation/traversal/crossing; slot-0 autosave
persistence; new art, audio, particles or shaders; SaveSystem schema changes;
new enemy families; economy changes; full-suite testing.

## Implementation Notes

- The relay signal callback now defers Story120 visual synchronization until
  the contact callback has completed, avoiding scene-state mutation inside the
  physics signal.
- Relay synchronization owns prompt visibility, so restored or newly activated
  relays cannot leave a stale interaction prompt on screen.
- Story120 auto-activation snapshots availability before the frame and requires
  held `move_right` plus new positive-x displacement. This prevents the relay
  contact frame, respawn placement and test/MCP teleports from consuming the
  next ACT beat.
- The smoke SceneManager keeps current and pending spawn points separate so a
  requested transition cannot overwrite the source used to select the active
  checkpoint.

## Asset Pipeline

Existing imported image-generated Factory, Cinderpaw, Tailrace Relay, runoff
duct, steam vent and unlock VFX assets fully cover this slice. Cinderpaw's
`death` and `revive` states already use three-frame `AnimatedSprite2D +
SpriteFrames` animation. No image generation, asset import or manifest change
was required.

## Test Evidence

- Canonical RED: `reports/report_2381/report_1/results.xml`, `1` case with
  three expected failures: stale prompt, missing immediate Story120 reveal and
  no-input Story120 activation.
- Focused GREEN: `reports/report_2382/report_1/results.xml`, `1/1`.
- Related GREEN: `reports/report_2383/report_1/results.xml`, six suites and
  `8/8`; zero error/failure/flaky/skip/orphan.
- Updated headless smoke exited `0` and printed
  `story119_production_smoke=passed frames=180`.
- Godot MCP 3.0.4 session `cinderpaw@198e`, accepted run `r190526212-29`, used
  real `move_right`, moved `191.652px`, activated the relay once, preserved the
  no-input Story120 guard, entered real player `death`, then completed the
  same-scene relay respawn with `50/100` HP and Story120 still idle. Game log
  was helper-only, editor delta after cursor `2` was empty, inputs were
  released, and playback stopped at readiness `ready`.
- Non-empty RGB `1278x718` screenshots:
  `reports/visual/cinderpaw-mcp-story230-tailrace-relay-activated-20260722.png`
  (SHA-256 `4c95cf60e76e95bd1f40ebd21b24a0edf117bfc794176a8a8f8567bcd8eb74bb`)
  and
  `reports/visual/cinderpaw-mcp-story230-tailrace-relay-revive-20260722.png`
  (SHA-256 `cf29c24f36518118f713ba657b4fe87ccaa3ae674ac298bf96aeae70cfd74105`).

## Dependencies

- Depends on: Story229 production Tailrace Ambush combat closure
- Unlocks: Story120 production runoff hazard traversal

## Verification Summary

Accepted under Godot 4.7 / Godot AI MCP 3.0.4. Story119 now has real contact,
one-shot savepoint, live death/respawn and guarded Story120 handoff coverage.
Full-suite testing was intentionally omitted.
