# Story 212: Old Factory Aftershock Exhaust Exit Hatch Open Readability

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Route Presentation
> **Type**: Visual/Feel + Integration
> **Estimate**: XS
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-22

## Context

**GDD**: `design/gdd/player-abilities.md`,
`design/gdd/exploration-ability-gating.md`,
`design/gdd/scene-management.md`

**Requirements**: `TR-scene-004`, `TR-explore-005`, `TR-respawn-002`

**ADR Governing Implementation**: ADR-0004 collision detection; ADR-0007
scene-local state; ADR-0018 player abilities; ADR-0021 save persistence.

**Control Manifest**: Godot 4.7; the existing scene-local endpoint and imported
Old Factory assets remain authoritative. No new Autoload or synchronous scene
transition is introduced.

Story211 proves that production `interact` opens the Story092 exhaust hatch and
a fresh `move_right` starts Story093. Its accepted screenshot also proves a
presentation defect: the activated hatch still occupies its closed position,
can cover Cinderpaw, and leaves completed hatch/breaker prompts overlapping the
active route objective.

## Acceptance Criteria

- [x] Before activation, the existing hatch panel remains in its authored
  closed position and its available interaction prompt remains visible.
- [x] Opening the hatch reuses the existing imported panel and retracts its
  visual upward by at least `120px`, creating a clearly open route silhouette.
- [x] The hatch endpoint renders behind Cinderpaw in both closed and opened
  states so the player silhouette remains readable at the threshold.
- [x] Activated hatch and already-cut exhaust-breaker world prompts are hidden;
  their deterministic diagnostic text remains unchanged for state inspection.
- [x] Hatch blocker/interaction shutdown, exactly-once unlock VFX, restored
  opened state, and Story093 availability remain behaviorally unchanged.
- [x] One focused/related GdUnit pass, a Factory headless smoke, and one Godot
  MCP 3.0.4 runtime check under Godot 4.7 confirm clean logs and a non-empty
  screenshot showing the retracted hatch and unobscured Cinderpaw.

## Out of Scope

New art or audio, a timed hatch tween, changing the hatch interaction contract,
advancing the full Story093 hazard cycle, or changing any downstream route
state.

## Asset Pipeline

No new visual asset is required. This Story deliberately reuses the registered
image-generated Story092 hatch, breaker, unlock VFX, Factory shell and Cinderpaw
character assets already imported by Godot.

## Implementation Notes

- The endpoint visual-state option must default to no movement so existing
  route endpoints keep their authored presentation.
- The scene owns the hatch-specific retraction distance, layer and completed
  prompt policy. The selected art pose is local `Vector2(48, -136)` with a
  `6deg` clockwise tilt behind the duct shell; gameplay code continues to own
  only route state.
- Restoring an opened save applies the final visual state without replaying the
  one-shot unlock VFX.

## Test Evidence

- Canonical thin TDD suite:
  `tests/unit/gameplay/old_factory_aftershock_exhaust_exit_hatch_open_readability_test.gd`
  - Initial RED: `reports/report_2282/report_1/results.xml` (`1` case, `6`
    expected failures for layer, prompt and live/restored retraction).
  - Art-review RED: `reports/report_2284/report_1/results.xml` (`1` case, `5`
    expected failures for the selected panel pose and duct-shell layer).
  - Focused GREEN: `reports/report_2285/report_1/results.xml` (`1/1`).
  - Final bounded related: `reports/report_2288/report_1/results.xml` (`7/7`
    across Story210, Story092, Story211, Story093 and Story212).
- Factory smoke:
  `reports/old_factory_aftershock_exhaust_exit_hatch_open_readability_smoke.log`
  exited `0`; the project error-keyword scan was empty.
- Godot MCP 3.0.4 accepted run `r146333033-74`: closed visual `(0,0)` became
  local `(48,-136)` at `6deg`, effective panel z `21` stayed behind duct z
  `22` and player z `26`, both completed prompts hid, blocker/interaction
  disabled, unlock VFX remained exactly once, and fresh `move_right` advanced
  x `3236 -> 3294.33` into Story093 `grace`. Inputs were released, game log
  was helper-only and editor log was empty. Non-empty RGB `1278x718` screenshot:
  `reports/visual/cinderpaw-mcp-aftershock-exhaust-exit-hatch-open-readability-20260722.png`.

## Dependencies

- Depends on: Story211, Story092 and Story093
- Unlocks: Story093 production hazard-cycle/full-traverse acceptance

## Verification Summary

The initial RED proved the screenshot debt was encoded in the real scene. A
read-only art review selected an offset/tilt that tucks the existing panel
behind the duct shell; the review RED then proved the coarse vertical-only
implementation did not yet satisfy it. The final endpoint option defaults to
zero offset/rotation, so other endpoint visuals remain unchanged. Final bounded
regression passed `7/7`; smoke and MCP runtime acceptance are clean. No full
suite and no new image generation were needed.
