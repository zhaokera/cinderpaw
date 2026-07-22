# Story 224: Old Factory Runoff Outlet Service Hatch Production Input Sluice Handoff

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Production Input + Hazard Handoff
> **Type**: Integration + Production Input + Production Movement + Physical Hazard
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-22

## Context

Story223 stops after Story112's reward cache is claimed, with the service hatch
visible and blocking. Story224 closes the next playable ACT slice: a fresh
production interaction opens the hatch, real forward movement starts Story113,
the live service-sluice vent applies physical contact damage, and a real exit
crossing exposes Story114 without activating its Spark Rat in the same frame.

**GDD**: `design/gdd/input.md`, `design/gdd/collision-detection.md`,
`design/gdd/scene-management.md`, `design/gdd/exploration-ability-gating.md`,
`design/gdd/death-respawn.md`

**Requirements**: `TR-input-001`, `TR-collision-004`, `TR-scene-004`,
`TR-explore-005`, `TR-respawn-002`

**Governing ADRs**: ADR-0004 Collision Detection; ADR-0007 Scene Management;
ADR-0018 Player Abilities; ADR-0021 Save System.

## Acceptance Criteria

- [x] Holding `interact` before entering the Story112 hatch radius remains
  stale; release plus a fresh production rising edge opens the hatch once.
- [x] Opening disables hatch collision, hides its prompt, emits one existing
  unlock VFX, offsets the visual to `(48, -136)` at `6deg`, and renders it at
  effective z `23` between the service-sluice duct z `22` and Cinderpaw z `26`.
- [x] Opening Story112 makes Story113 visible/available but does not activate it
  in the same frame or during later stationary frames.
- [x] No-input placement at x `10164` cannot activate Story113. A real positive-x
  `move_right` frame crossing x `10160` activates it in `grace` and changes the
  objective to `Cross Runoff Outlet Service Sluice`.
- [x] Story113 advances through grace `0.25s`, warning `0.35s`, active `0.40s`
  and safe `0.45s`; only active enables vent collision.
- [x] Physical overlap with the real service-sluice `Area2D` applies exactly
  `8` damage (`100 -> 92`) with the Story113 hazard id as source.
- [x] A real positive-x `move_right` frame crossing x `10720` completes
  Story113 and disables hazard contact.
- [x] Story114 becomes available but remains inactive, hidden, untargeted and
  non-processing/non-physical after the crossing and after no-input placement
  at x `10924`; entity `2142` remains staged at `(11120, 482)`.
- [x] Focused/related GdUnit, a marker-backed `180`-frame Factory smoke, and
  Godot 4.7 / Godot AI MCP 3.0.4 runtime/log/three-screenshot acceptance pass.

## Out of Scope

Story114 production activation/combat/death, Story115 and deeper route content,
new art/audio/VFX, balance changes, SaveSystem schema changes, Boss content and
full-suite testing.

## Implementation Notes

- Story112's service hatch now participates in the shared nearest progression
  interaction router; existing rising-edge ownership remains authoritative.
- Story113 activation/completion and Story114 activation track prior player x
  and require actual held `move_right` plus positive displacement.
- Frame-start availability prevents Story113 completion from activating
  Story114 in the same `_process` pass.
- Public direct APIs remain unchanged for deterministic baseline and restore
  tests; production auto-routing owns the new movement guards.
- The integration test lives under `tests/integration/gameplay/` and obtains
  vent damage through real physics overlap rather than calling a damage API.

## Asset Use

No image generation was required. Existing imported image-generated service
hatch, landing, steam-vent, Factory background and Cinderpaw assets cover the
slice. Story114's existing Factory Spark Rat retains six three-frame
`AnimatedSprite2D + SpriteFrames` animations but is intentionally not activated.

## Verification Evidence

- Canonical RED `reports/report_2354/results.xml` ran `1` integrated test and
  exposed `8` expected production/readability/movement failures.
- Final focused GREEN `reports/report_2357/results.xml` passed `1/1` with zero
  failure/error/flaky/skip/orphan after moving the test to the integration path
  and replacing direct damage with real `Area2D` overlap.
- Final six-suite related GREEN `reports/report_2360/results.xml` passed `10/10`
  with zero failure/error/flaky/skip/orphan across Story224, Story223,
  Stories112-114 and shared progression interaction.
- `reports/report_2358/results.xml` exposed one obsolete Story114 expectation
  that hid a runtime enemy before its authored death animation. The baseline
  now expects visible death presentation with combat physics disabled, while
  restored cleared state remains hidden.
- Factory smoke exited `0` and recorded
  `story224_smoke=passed frames=180` in
  `reports/old_factory_runoff_outlet_service_hatch_production_input_sluice_handoff_smoke.log`.
- Godot MCP 3.0.4 session `cinderpaw@198e`, accepted run token/id `15` /
  `r169905919-15`, proved stale/fresh interaction, no-input guards, real
  movement, physical HP `100 -> 92`, exact hazard source, real crossing and
  the waiting Story114 boundary.
- Both driven actions were released. The current-run game log contained only
  helper registration, editor delta after cursor `2` was empty, and playback
  stopped at readiness `ready`.
- Non-empty RGB `1278x718` captures:
  - `reports/visual/cinderpaw-mcp-runoff-outlet-service-hatch-open-20260722.png`,
    SHA-256 `4a34ea7a7e3ca2fc01ebdf712025024a86a35cf4b1bd4195fb06bd7a58a292b6`.
  - `reports/visual/cinderpaw-mcp-runoff-outlet-service-sluice-active-20260722.png`,
    SHA-256 `20b73730935d775eedcf0e9267c4c1de4a71b14f132c42040f187754940c2137`.
  - `reports/visual/cinderpaw-mcp-runoff-outlet-service-sluice-crossed-handoff-20260722.png`,
    SHA-256 `6ffab17bef08b4e9a55d3ae926e8ca8d48b32245312cfa425e6aaf71f4854adf`.

## Dependencies

- Depends on: Story223 production combat/reward handoff and Stories112-114
  baseline content.
- Unlocks: Story114 production movement/combat/live-death closure.

## Verification Summary

One thin integrated test and one clean MCP run close the Story112 production
input, Story113 real movement/physical hazard, and delayed Story114 handoff.
Focused `1/1`, related `10/10`, marker-backed smoke and runtime/log/visual
acceptance pass without new assets or persistence-schema changes.
