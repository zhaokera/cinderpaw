# Story 181: Old Factory Pressure Valve Authored Motion Readability

> **Epic**: Player Abilities
> **Status**: Blocked
> **Layer**: Presentation / Gameplay Integration / Old Factory
> **Type**: Visual/Feel + Frame Animation Contract
> **Estimate**: S
> **Manifest Version**: 2026-07-20
> **Last Updated**: 2026-07-20

## Context

Story058 completed the guarded pressure-valve gameplay gate but deliberately
reused the generic cat-paw endpoint visual. The endpoint at `(1220, 400)` now
overlaps the animated service lift and is later covered by the Deep Bulkhead.
This Story replaces only that presentation with a dedicated image-generated
pressure valve while preserving the completed interaction and progression
contract.

**GDD**: `design/gdd/exploration-ability-gating.md`,
`design/gdd/scene-management.md`

**Governing Architecture**: `docs/architecture/architecture.md`, ADR-0007 Scene
Management, `docs/architecture/control-manifest.md`

**Asset Spec**:
`design/assets/specs/old-factory-pressure-valve-authored-motion.md`

## Acceptance Criteria

- [ ] `FactoryLowerDeckPressureValve/ValveAnimation` uses
  `AnimatedSprite2D + SpriteFrames` and the old generic endpoint sprite is not
  visible in gameplay.
- [ ] `closed_idle`, `opening` and `opened_idle` each contain exactly three
  transparent `256x256` frames with a common pivot and baseline; loops are
  `true/false/true`.
- [ ] The source sheet, alpha intermediate, runtime frames, preview and exact
  image2 prompt are retained and recorded in the asset manifest.
- [ ] An accepted valve interaction plays `opening` and then `opened_idle`;
  restoring an already-open snapshot starts directly in `opened_idle`.
- [ ] Locked/available tint and prompt remain derived from the existing shared
  endpoint while animation never owns input, collision, persistence or route
  progression.
- [ ] The endpoint id, root position, `96px` radius, prompts, guard entity
  `2112`, Story058 state keys, service-lift independence and Story059/060
  downstream gates remain unchanged.
- [ ] The valve remains readable beside the service lift and after Deep
  Bulkhead presentation appears, without covering Cinderpaw or route prompts.
- [ ] Focused/related GdUnit, a bounded Factory headless smoke, and Godot MCP
  3.0.4 runtime evidence pass under Godot 4.7 with clean current-run logs and
  non-empty inspected screenshots.

## Out Of Scope

New interaction rules, collision changes, guard AI changes, SaveSystem schema,
new route objectives, service-lift behavior, Steam Sluice behavior, Deep
Bulkhead behavior, audio and shared endpoint refactoring.

## TDD Evidence

- Initial exploratory RED `reports/report_2061/` exposed the full missing
  presentation surface but produced redundant assertions.
- Canonical thin RED `reports/report_2062/results.xml` executes one case and
  records exactly one expected failure: `ValveAnimation` is absent. It has no
  parse error, flaky case, skip or orphan.
- Focused GREEN, related regression, smoke and MCP evidence remain pending.

## Current Implementation State

- `src/presentation/factory_pressure_valve_animation.gd` defines the isolated
  presentation state machine and traceability diagnostics but is not connected
  to the scene until valid generated frames exist.
- Built-in image2 calls failed five times at the external request layer on
  2026-07-20: once on the reference-image edit endpoint and four times on the
  pure-generation endpoint. The fifth attempt used the approved strict `3x3`
  chroma-key prompt and failed with a network error before producing output.
  Neither the project nor the local imagegen output directory contains an
  artifact from those calls.
- Story181 is therefore project-blocked until built-in image2 connectivity
  returns or an explicitly approved CLI fallback has an available API key.
- The local environment does not currently expose `OPENAI_API_KEY`, so the CLI
  fallback cannot run. No placeholder or hand-authored substitute is accepted.

**Status**: Blocked; [ ] Complete.
