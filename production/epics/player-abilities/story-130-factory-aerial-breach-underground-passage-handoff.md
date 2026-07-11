# Story 130: Factory Aerial Breach Underground Passage Handoff

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Core / Gameplay Runtime / Scene Management / Presentation
> **Type**: Integration + Ability Gate + Scene Handoff + Visual
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-11

## Context

**GDD**: `design/gdd/player-abilities.md`,
`design/gdd/exploration-ability-gating.md`, `design/gdd/scene-management.md`,
`design/gdd/hud-ui.md`, `design/art/art-bible.md`

**Requirements**: `TR-ability-003`, `TR-ability-005`, `TR-scene-001`,
`TR-scene-004`, `TR-scene-007`

**ADR Governing Implementation**: ADR-0002 Signal Communication; ADR-0004
Collision Detection; ADR-0007 Scene Management; ADR-0018 Player Abilities;
ADR-0021 Save System.

Story129 makes `aerial_attack` playable and persists it back into Factory.
Story130 spends that key immediately: a cracked tailrace floor remains blocked
without the ability, unlocks only when Cinderpaw activates the airborne strike
in range, persists open, and hands the player into the first authored
Underground Passage destination. The destination supports a verified return to
the Factory breach so this is a real bidirectional SceneManager route rather
than a decorative endpoint.

## Acceptance Criteria

- [x] Factory contains a dedicated `ExplorationGate` floor breach whose gate
  id is `factory_tailrace_underground_aerial_breach`, required ability is
  `aerial_attack`, and target area is `area_04_underground_passage`.
- [x] Without `aerial_attack`, the gate remains locked/collision-blocking and
  shows `Requires Aerial Attack` only in prompt range.
- [x] With `aerial_attack`, activating the real airborne strike in gate range
  opens the floor once, disables its collision, plays one unlock VFX, updates
  Factory objective feedback, and never responds to unrelated abilities.
- [x] The open flag persists in Factory local state. Restoring it keeps the
  floor open, preserves unlocked abilities, clears transient request latches,
  and does not replay the one-shot VFX.
- [x] Opening the gate requests `area_04_underground_passage` at
  `factory_drop_entry` through SceneManager exactly once.
- [x] The registered Underground Passage is a bounded playable Godot scene
  with Cinderpaw, Camera2D, floor/walls, HUD/objective, generated opaque
  `1280x720` backdrop, entry marker, and Factory return route.
- [x] Underground return requests `area_03_factory` at
  `tailrace_underground_return` exactly once; Factory restores Cinderpaw at
  that authored marker with the breach still open and `aerial_attack` intact.
- [x] New floor-gate and Underground environment visuals are produced through
  built-in image generation, imported through Godot 4.7, and recorded in the
  asset spec/manifest/inventory.
- [x] Focused RED/GREEN, one bounded adjacent regression set, one bidirectional
  headless smoke, and one Godot MCP 2.9.1 runtime pass complete with clean
  current-run logs and non-empty screenshots.

## Out of Scope

- Underground enemies, hazards, collectibles, savepoints, minimap/fast travel,
  additional rooms, wall-climb reward, Boss4, new combat attacks, authored
  audio, new Autoloads, or SaveSystem schema expansion.
- Retrofitting every old Factory floor collision into separate physical tiles.
  The floor breach owns the authored transition point and scene handoff.

## Implementation Notes

- Reuse `ExplorationGate`; do not create a second ability-gate state machine.
- The Factory controller owns SceneManager requests and local persistence.
- `ability_activated(aerial_attack)` plus gate range is the authoritative
  breach trigger. Restored open state must use `set_gate_unlocked(true)` so it
  cannot replay unlock feedback.
- Reuse the current Factory WeaponComponent and Story129 aerial runtime without
  changing damage, bounce, energy, or animation timings.

## QA Test Cases

- **AC-1: Ability-gated breach**
  - Given: Cinderpaw at the cracked floor with and without `aerial_attack`.
  - When: Cinderpaw activates the airborne strike in range.
  - Then: only the unlocked case opens once, disables collision, records the
    state, and requests the Underground destination.
- **AC-2: Bidirectional route**
  - Given: the Factory breach has opened.
  - When: SceneManager swaps Factory -> Underground -> Factory.
  - Then: exact spawn ids/markers, open state, and unlocked ability survive.
- **AC-3: Runtime presentation**
  - Given: generated gate and backdrop assets are imported.
  - When: both scenes are opened/run through MCP.
  - Then: nodes/resources resolve, gameplay screenshots are non-empty, and no
    new current-run script/runtime errors are present.

## Test Evidence

**Required evidence**:

- `tests/unit/gameplay/factory_aerial_breach_underground_passage_handoff_test.gd`
- `tests/smoke/factory_aerial_breach_underground_passage_handoff_smoke.gd`
- `production/qa/evidence/factory-aerial-breach-underground-passage-handoff-2026-07-11.md`

**Status**: [x] Complete.

- Expected RED: `reports/report_1421/` (missing scene, registry, art, gate, and
  route contracts).
- Final focused GREEN: `reports/report_1423/` (`2/2`).
- Bounded adjacent GREEN: `reports/report_1424/` (`11/11`).
- Bidirectional smoke:
  `reports/factory_aerial_breach_underground_passage_handoff_smoke.log`, exit
  `0`, marker `factory_aerial_breach_underground_passage_handoff_smoke=passed`.
- Godot MCP: session `cinderpaw@e40d`, Godot `4.7-stable`, MCP `2.9.1`, run
  tokens `23` and `24`; Factory gate inspection, Underground hierarchy/runtime,
  clean current-run logs, and non-empty `1278x718` gameplay screenshot passed.
- Full evidence:
  `production/qa/evidence/factory-aerial-breach-underground-passage-handoff-2026-07-11.md`.

## Dependencies

- Depends on: Story129 Sluice Matriarch Aerial Attack Reward Payoff.
- Unlocks: Story131 first playable Underground Passage traversal/combat beat.
