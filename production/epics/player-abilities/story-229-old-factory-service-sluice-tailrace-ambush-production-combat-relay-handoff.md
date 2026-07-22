# Story 229: Old Factory Service Sluice Tailrace Ambush Production Combat Relay Handoff

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Combat / Route Handoff
> **Type**: Integration + Production Movement + Production Combat + Live Death + Route Handoff
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-22

## Context

**GDD**: `design/gdd/player-abilities.md`,
`design/gdd/exploration-ability-gating.md`, `design/gdd/feline-combat.md`,
`design/gdd/scene-management.md`, `design/gdd/death-respawn.md`

**Requirements**: `TR-scene-004`, `TR-explore-005`, `TR-combat-001`,
`TR-combat-003`, `TR-respawn-002`

**ADR Governing Implementation**: ADR-0002 Data-driven entities; ADR-0004
collision detection; ADR-0005 feline combat; ADR-0007 scene management.

Story228 completes the physical tailrace and leaves Story118 available but
inactive. Story229 closes the next production ACT beat: real positive-x input
activates the frame-animated Coil Rat, a real player attack defeats it through
the shared hitbox path, the live death state remains readable, and Story119 is
revealed without being activated for the player.

## Acceptance Criteria

- [x] Story228 terminal state leaves Story118 available, inactive, hidden,
  untargeted and non-processing while Story119 remains unavailable and hidden.
- [x] Real `move_right` displacement across activation x `12620` activates
  Story118 and entity `2143`; direct activation APIs are not used.
- [x] The activated Coil Rat is visible, targeted, processing, physics-enabled,
  has `24` HP, and uses six three-frame `AnimatedSprite2D + SpriteFrames`
  actions from the registered Factory Coil Rat resource.
- [x] A nonlethal `12`-damage setup leaves `12` HP; real `Input.attack`
  activates `cat_claw_light` and applies the exact final `12` damage through
  the Coil Rat Hurtbox with target id `2143` and attack type `light`.
- [x] Lethal resolution persists Story118 activated/defeated/cleared state,
  disables target, physics, hurtbox and collision, and preserves the visible,
  processing three-frame `death` presentation before fade/despawn.
- [x] Story119 becomes available, visible, monitoring and unactivated with
  route feedback `Repair Tailrace Relay`; this Story does not trigger relay
  activation or savepoint writes.
- [x] Focused/related GdUnit, one `180`-frame smoke and one Godot MCP runtime
  pass under Godot 4.7 / Godot AI MCP 3.0.4 with clean current-run logs and
  non-empty screenshots.

## Out of Scope

Story119 contact activation, autosave and death/respawn; Story120 runoff
traversal; new enemy families, generated art, authored audio, particles,
shaders, economy changes, save schema changes, and full-suite testing.

## Implementation Notes

- Existing production code already satisfied the new integration acceptance;
  the initial Story229 test was therefore recorded as characterization GREEN,
  not misrepresented as a canonical RED.
- The old Story118 smoke expected immediate enemy hiding and used direct
  activation/lethal damage. It now exercises real movement and attack input and
  checks the shared live-death contract plus a stable 180-frame relay handoff.
- Direct damage is used only for deterministic nonlethal setup. The final hit
  always comes from the player's production `cat_claw_light` hitbox.

## Asset Pipeline

Existing imported image-generated Factory, Cinderpaw, Tailrace Relay and
Factory Coil Rat assets cover this slice. All six Coil Rat states already use
three-frame animation. No image generation, new asset import or manifest
change was required.

## Test Evidence

- Characterization GREEN: `reports/report_2378/report_1/results.xml`, `1/1`.
  This proved the existing production implementation already met Story229.
- The pre-update Story118 smoke failed only on its stale immediate-hide
  assertion after the current live-death implementation remained visible.
- Final related GREEN: `reports/report_2379/report_1/results.xml`, five suites
  and `7/7`, zero error/failure/flaky/skip/orphan.
- Updated headless smoke exited `0` and printed
  `story118_production_smoke=passed frames=180`.
- Godot MCP 3.0.4 session `cinderpaw@198e`, accepted run `r187717447-28`, used
  real `move_right` and `attack`. Runtime metadata recorded target `2143`,
  `cat_claw_light`, attack type `light`, applied damage `12`, HP `0`, live
  `death`, and a visible/available/unactivated Story119 relay. Game log was
  helper-only, editor delta after cursor `2` was empty, inputs were released,
  and playback stopped at readiness `ready`.
- Non-empty RGB `1278x718` screenshots:
  `reports/visual/cinderpaw-mcp-story229-tailrace-coil-active-20260722.png`
  (SHA-256 `acfb0955411a6eff732ffe78dd9d00171c7f0c97dad13dd499f5d742bde3413c`)
  and `reports/visual/cinderpaw-mcp-story229-tailrace-relay-handoff-20260722.png`
  (SHA-256 `d513956c5cf8b700fae3dd6864ce44b15c5a904ce8f5dafa4579c7b9b9c91ae1`).

## Dependencies

- Depends on: Story228 production tailrace hazard traverse
- Unlocks: Story119 production contact activation and death/respawn closure

## Verification Summary

Accepted under Godot 4.7 / Godot AI MCP 3.0.4. Story118 is now covered through
real production activation, shared-hitbox combat, live death and Story119 relay
handoff. Full-suite testing was intentionally omitted.
