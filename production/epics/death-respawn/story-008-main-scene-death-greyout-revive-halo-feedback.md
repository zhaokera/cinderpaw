# Story 008: Main Scene Death Greyout + Revive Halo Feedback

> **Epic**: Death & Respawn
> **Status**: Complete
> **Layer**: Feature Flow / Presentation Integration
> **Type**: Integration + Visual/Feel
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-14

## Context

**GDD**: `design/gdd/death-respawn.md`, `design/gdd/health-death.md`,
`design/gdd/combat-presentation.md`

**Requirements**: `TR-respawn-001`, `TR-respawn-006`, `TR-respawn-007`

**ADR Governing Implementation**: ADR-0001 scene ownership; ADR-0002 signal
communication; ADR-0007 scene/respawn handoff; ADR-0013 pixel-art rendering;
ADR-0019 HealthComponent.

The existing Main loop already detects lethal damage, plays Cinderpaw's
three-frame `death` animation, waits `1.5s`, selects the real respawn point,
revives at `50% HP`, plays the three-frame `revive` animation and provides
two seconds of invincibility flashing. The player-visible GDD transition is
still absent: the screen never fades to grey, no cat-eye-gold soul particles
leave the body, the grey filter does not fade out after respawn and there is no
one-second revive halo.

## Acceptance Criteria

- [x] A real Main lethal Player damage keeps the existing
  `AnimatedSprite2D + SpriteFrames` `death` animation and starts exactly one
  stable `PlayerDeathFeedbackLayer` with a full-screen
  `PlayerDeathGrayscale` `ColorRect` using a screen-sampling ShaderMaterial.
- [x] Grayscale intensity starts at `0.0`, reaches approximately `0.5` at
  `0.25s`, reaches `1.0` at `0.5s`, then stays fully grey for the remainder of
  the existing `1.5s` death delay without changing GameFlow ownership.
- [x] Death spawns eight textured cat-eye-gold soul wisps around the real
  Player position. The transparent image-generated runtime PNG, source,
  alpha intermediate and prompt metadata are retained and imported through
  Godot.
- [x] The real Main `respawn_requested` path keeps the existing `50% HP`,
  three-frame `revive` animation and invincibility flash, starts a `0.5s`
  grayscale fade-out and creates exactly one generated cat-eye-gold revive
  halo at the respawn position for `1.0s`.
- [x] The grayscale overlay is absent after the `0.5s` revive fade and all
  death wisps/halo nodes expire without stale duplicates. The effect ignores
  mouse input, uses stable node names and does not change HUD layout.
- [x] Focused GdUnit, bounded Main/GameFlow/Player/CombatPresentation
  regression, target smoke and Godot MCP verify the real lethal-to-revive
  transition, generated textures, shader amount, animation states, non-empty
  screenshots and clean logs.

## Out of Scope

- Changing the `1.5s` death delay, respawn priority, revive HP, no-loss rules,
  boss reset, control lock or two-second invincibility window.
- Adding a manual continue prompt, changing battle-summary behavior, replacing
  Cinderpaw death/revive frames or implementing new player-death audio.
- Applying this presentation adapter to every existing area scene in the same
  Story; Main is the bounded runtime acceptance surface.

## Implementation Notes

- `GameFlowController` remains the only death/respawn timing owner. Main bridges
  its existing Player death and respawn callbacks to `CombatPresentation`.
- Use deterministic `advance_time()` state for testable fade and VFX lifetimes;
  do not add a second Tween-only clock.
- Keep the grayscale shader code-native. Only the authored soul wisp and revive
  halo are bitmap assets and must follow the image-generation asset pipeline.

## Test Evidence

**Required evidence**:

- `tests/unit/gameplay/main_scene_death_respawn_visual_feedback_test.gd`
- Existing Main savepoint, GameFlow, Player death/revive animation and
  CombatPresentation tests
- `tests/smoke/main_scene_death_respawn_visual_feedback_smoke.gd`
- Godot MCP evidence under
  `production/qa/evidence/main-scene-death-respawn-visual-feedback-2026-07-14.md`

**Status**: [x] Complete.

- Contract RED: `reports/report_1611/results.xml`.
- Initial focused GREEN: `reports/report_1612/results.xml` (`1/1`).
- MCP-found released-instance lifecycle regression: RED
  `reports/report_1614/results.xml`; GREEN
  `reports/report_1615/results.xml` (`33/33`).
- Gold-above-grayscale layer contract: RED `reports/report_1617/results.xml`;
  focused GREEN `reports/report_1618/results.xml` (`1/1`).
- Final bounded related GREEN: `reports/report_1620/results.xml`, `47/47`,
  zero errors/failures/flaky/skipped/orphans.
- Target smoke prints
  `main_scene_death_respawn_visual_feedback_smoke=passed` with exit code 0.
- Final Godot MCP run `r17306475-20` completed the lethal-to-idle sequence with
  three-frame death/revive, eight wisps, `1.0 -> 0.5 -> 0.0` grayscale,
  `50% HP`, one halo, info-only game log and empty editor log.
