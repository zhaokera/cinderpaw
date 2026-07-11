# Story 131: Underground Corrosion Channel Skirmish

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Core / Gameplay Runtime / Scene Management / Presentation
> **Type**: Integration + Gameplay Runtime + Environmental Hazard + Visual
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-11

## Context

**GDD**: `design/gdd/ai-framework.md`, `design/gdd/feline-combat.md`,
`design/gdd/exploration-ability-gating.md`, `design/gdd/scene-management.md`,
`design/gdd/health-death.md`, `design/gdd/audio-system.md`,
`design/art/art-bible.md`

**Requirements**: `TR-ai-001`, `TR-ai-003`, `TR-ai-007`, `TR-ai-008`,
`TR-combat-011`, `TR-health-002`, `TR-scene-004`

**ADR Governing Implementation**: ADR-0002 Signal Communication; ADR-0004
Collision Detection; ADR-0005 Combat State Machine; ADR-0006 AI Behavior;
ADR-0007 Scene Management; ADR-0018 Player Abilities; ADR-0021 Save System.

Story130 establishes a real bidirectional Factory-to-Underground route, but the
destination is still one empty viewport. Story131 turns that destination into
the first compact Underground ACT beat: Cinderpaw crosses a readable corrosive
runoff obstacle, enters a sealed two-enemy channel, clears it through the shared
combat chain, opens the forward seal, and claims a visible salvage payoff. The
slice stays small enough for direct runtime verification while proving that the
new area supports traversal, hazard pressure, combat, reward feedback, and
durable scene state.

## Acceptance Criteria

- [x] `underground_passage.tscn` expands to a bounded `2560x720` route with two
  opaque generated backgrounds, continuous collision, three readable runoff
  stepping platforms, Camera2D limits `0..2560`, and the Story130 entry/Factory
  return nodes unchanged.
- [x] `CorrosiveRunoffHazard` is an `Area2D` with a generated transparent visual,
  environment collision routing, `8` contact damage, and a per-target `1.0`
  second cooldown. Immediate duplicate contact is rejected; contact after the
  cooldown damages again through the player's public health path.
- [x] Crossing activation x `1450` starts the encounter once, closes the rear
  seal, keeps the forward seal closed, activates exactly two authored
  `FactorySluiceLeech` instances with entity ids `2401` and `2402`, assigns
  Cinderpaw as their target, and updates the objective to
  `Clear Corrosion Channel`.
- [x] Underground combat mounts the shared `WeaponComponent`, binds player
  `CombatComponent`/`CollisionComponent`, routes hit-confirmed target ids to the
  correct leech, and allows a real Cinderpaw light or aerial attack to reduce
  enemy HP without bypassing duplicate-hit protection.
- [x] Both visible enemies continue to use the existing
  `AnimatedSprite2D + SpriteFrames` Factory Sluice Leech character contract:
  `idle`, `run`, `attack_tell`, `attack`, `hurt`, and `death` each have exactly
  three transparent `96x96` frames.
- [x] Defeating both enemies marks the encounter cleared, hides/disables any
  surviving combat nodes, opens both seals, makes one generated Underground
  salvage cache claimable, and updates the objective to
  `Claim Underground Salvage`.
- [x] A nearby cache claim succeeds once, returns `20` gears in its reward
  payload, dispatches the shared reward audio feedback, and changes the
  objective to `Corrosion Channel Secured`; distant or duplicate claims fail.
- [x] Local state persists encounter activation, each enemy defeat, clear, cache
  claim, and unlocked abilities. Restoring a cleared state does not reactivate
  enemies or seals, replay a cache claim, or break the Story130 Factory return.
- [x] New background, corrosive runoff, seal, and salvage visuals are produced
  through built-in image generation, imported through Godot 4.7, and recorded
  in an asset spec, generation records, manifest, inventory, and QA evidence.
- [x] Focused RED/GREEN, a bounded related regression set, one targeted headless
  smoke, and one Godot MCP 2.9.1 runtime pass complete with clean current-run
  logs and non-empty screenshots showing traversal and the live encounter.

## Out of Scope

- A new enemy family or replacement of the completed Factory Sluice Leech
  character frames; additional enemy waves; ranged/status-effect attacks;
  Boss4; or combat balance refactors outside this scene.
- A third Underground room, deeper-area SceneManager handoff, savepoint,
  minimap/fast travel, collectible economy persistence, or SaveSystem schema
  expansion. The salvage reward remains the established scene-local gear
  feedback contract.
- Full Underground biome replacement, dynamic liquids, shaders, particles,
  destructible terrain, new music/SFX files, or a new Autoload.

## Implementation Notes

- Reuse `FactorySluiceLeech`; this is encounter composition, not a new character.
  Its completed frame-animation contract remains authoritative.
- Keep encounter ownership in `UndergroundPassageScene`. Use small feature nodes
  for hazard/cache state, native signals, and the existing scene-local
  `get_local_state()` / `set_local_state()` contract.
- Keep one focused public diagnostics surface for tests and MCP. Transient
  activation/request/cooldown latches must not be persisted as durable state.
- Request existing `mus_sewer` and `amb_sewer` ids through AudioSystem. New
  authored audio is not required for this slice.

## QA Test Cases

- **AC-1: Authored traversal and visual contract**
  - Given: the expanded Underground scene and generated assets are imported.
  - When: the scene and diagnostics are loaded.
  - Then: bounds, platforms, hazard, seals, enemies, cache, texture paths, and
    existing six-animation leech contract match the authored values.
- **AC-2: Real combat, clear, reward, and restore**
  - Given: Cinderpaw crosses x `1450`.
  - When: one real Core light attack hits a leech, then both enemies are
    defeated and the nearby cache is claimed.
  - Then: target-id routing, HP loss, seals, objective, reward, one-shot
    behavior, local state, and fresh-instance restore remain deterministic.
- **AC-3: Corrosive runoff cooldown**
  - Given: Cinderpaw overlaps the runoff hazard.
  - When: contact is applied twice immediately and once after `1.0` second.
  - Then: exactly two `8`-damage contacts are accepted and the duplicate is
    rejected without creating another health path.

## Test Evidence

**Required evidence**:

- `tests/unit/gameplay/underground_corrosion_channel_skirmish_test.gd`
- `tests/smoke/underground_corrosion_channel_skirmish_smoke.gd`
- `production/qa/evidence/underground-corrosion-channel-skirmish-2026-07-11.md`

**Status**: [x] RED/GREEN, smoke, import, and MCP evidence complete.

- RED: `reports/report_1426/` captured all three missing Story131 contracts.
- Final focused GREEN: `reports/report_1432/` passed `3/3`.
- Bounded related GREEN: `reports/report_1429/` passed Story131 plus Story130 and
  Story126 suites `7/7`.
- SceneManager smoke:
  `reports/underground_corrosion_channel_skirmish_smoke.log` exited `0` with
  `underground_corrosion_channel_skirmish_smoke=passed`.
- Godot MCP: session `cinderpaw@e40d`, Godot `4.7-stable`, MCP `2.9.1`, final
  run token `27`; authored/runtime hierarchies, real movement, seal geometry,
  frame-animated enemies, prompt visibility, non-empty screenshot, clean
  current-run game log, and no editor rows after cursor `3` passed.
- Full evidence:
  `production/qa/evidence/underground-corrosion-channel-skirmish-2026-07-11.md`.

## Dependencies

- Depends on: Story126 Factory Sluice Leech Skirmish and Story130 Factory
  Aerial Breach Underground Passage Handoff. Both are Complete.
- Unlocks: Story132 deeper Underground route, savepoint, or second encounter.

## Completion Notes

**Completed**: 2026-07-11
**Criteria**: 10/10 passing
**Deviations**: The slice reuses the completed Factory Sluice Leech character
family instead of generating a duplicate Underground variant. MCP play exposed
and drove two fixes before acceptance: the rear seal moved from x `1488` to
`1370` so it closes behind the trigger, and the salvage prompt now stays hidden
until clear plus proximity. Parallel design/art/QA sidecars could not start
because the backend forced unsupported `reasoning.effort=max`; their review
scopes were completed locally without blocking integration.
**QA Evidence**:
`production/qa/evidence/underground-corrosion-channel-skirmish-2026-07-11.md`
**Code Review**: Approved with suggestions. No blocking ADR, runtime, or
testability issue was found. Before adding substantially more Underground room
logic, extract the corrosion encounter from the `1107`-line scene controller so
new playable slices do not keep expanding one owner.
