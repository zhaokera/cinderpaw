# Story 013: Weapon Style VFX Variants

> **Epic**: Combat Presentation
> **Status**: Complete
> **Layer**: Presentation
> **Type**: Visual/Feel
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-24

## Context

**GDD**: `design/gdd/combat-presentation.md`
**Requirements**: `TR-combatfx-003`, `TR-combatfx-007`
**ADR Governing Implementation**:
ADR-0002: Signal communication; ADR-0016: Weapon styles

The Combat Presentation layer already covers generic hit sparks, parry sparks,
cat-claw trails, dodge afterimages, Boss phase debris, colorblind remaps, and
the 200-particle performance cap. This story adds the remaining normal weapon
attack-start presentation variants from the GDD particle list:

- `long_tail` uses one silver `trail_blade` arc for `0.5s`.
- `fish_bone` uses one white `wave_bone` shockwave for `0.3s`.
- `electro_bell` uses five to eight blue `arc_bell` electric arcs for `0.4s`.

This is a Presentation-only slice. `CombatPresentation` may consume attack
metadata or weapon-style event dictionaries, but it must not call Core weapon,
damage, hitbox, shield-break, slow-status, HUD, audio, or sprite-animation APIs.

## Acceptance Criteria

- [x] Given a normal weapon attack-start event with weapon style
  `long_tail`, when `CombatPresentation` receives the presentation event, then
  it spawns exactly one textured silver `trail_blade` arc using
  `res://assets/generated/combat_long_tail_arc_runtime.png` with a `0.5s` lifetime.
- [x] Given a normal weapon attack-start event with weapon style
  `fish_bone`, when `CombatPresentation` receives the presentation event, then
  it spawns exactly one textured white `wave_bone` shockwave using
  `res://assets/generated/combat_fish_bone_wave_runtime.png` with a `0.3s` lifetime.
- [x] Given a normal weapon attack-start event with weapon style
  `electro_bell`, when `CombatPresentation` receives the presentation event,
  then it spawns between five and eight textured blue `arc_bell` electric arcs
  using `res://assets/generated/combat_electro_bell_arc_runtime.png` with a `0.4s`
  lifetime.
- [x] The new weapon-style particles are included in the existing
  `TR-combatfx-003` 200-particle cap and oldest-first eviction behavior.
- [x] The new weapon-style particles preserve the existing
  `TR-combatfx-007` performance budget diagnostics and do not regress the
  Story012 particle budget sample.
- [x] Presentation remains signal/event driven per ADR-0002: no reverse calls
  from Presentation into Core weapon rules, damage calculation, hitboxes,
  status effects, HUD, audio, or animation controllers.
- [x] Godot MCP opens/runs `res://scenes/main.tscn`, verifies the target
  `CombatPresentation` node exists, triggers or inspects the three
  weapon-style VFX variants, checks clean logs, and captures a nonblank
  screenshot with visible VFX evidence.

## Implementation Notes

- Keep the public surface narrow and Presentation-owned. If an event payload is
  needed, consume plain metadata such as `weapon_style`, `particle_type`,
  `position`, and `facing_direction` without querying Core state.
- Use the imported image-generated PNGs already in the Godot asset pipeline:
  - `res://assets/generated/combat_long_tail_arc_runtime.png`
  - `res://assets/generated/combat_fish_bone_wave_runtime.png`
  - `res://assets/generated/combat_electro_bell_arc_runtime.png`
- Runtime particle nodes should stay transient and self-cleaning, matching the
  existing Sprite2D VFX path and Story012 particle registry.
- Names should map to the GDD particle vocabulary: `trail_blade`, `wave_bone`,
  and `arc_bell`.

## Out of Scope

- Changing Core weapon-style rules, weapon swap behavior, damage formulas,
  combo rules, hitbox shapes, shield-break behavior, or slow-status behavior.
- Implementing fish-bone shield break, electro-bell slow, long-tail
  multi-target rules, or any special attack behavior.
- Adding HUD, audio, camera, screen shake, hitstop, damage-number, or
  colorblind-mode changes beyond existing shared presentation behavior.
- Replacing the Sprite2D VFX path with `GPUParticles2D`, pooling, or a new
  renderer.
- Adding or changing character `AnimatedSprite2D` / `SpriteFrames` assets.

## QA Test Cases

- **AC-1**: Long-tail normal attack-start VFX
  - Given: `CombatPresentation` receives a normal weapon attack-start event for
    `long_tail`
  - When: the event is processed
  - Then: one `trail_blade` particle appears, uses the long-tail generated
    texture, and expires after `0.5s`
  - Edge cases: unknown style must not spawn this particle

- **AC-2**: Fish-bone normal attack-start VFX
  - Given: `CombatPresentation` receives a normal weapon attack-start event for
    `fish_bone`
  - When: the event is processed
  - Then: one `wave_bone` particle appears, uses the fish-bone generated
    texture, and expires after `0.3s`
  - Edge cases: the particle must not invoke shield-break logic

- **AC-3**: Electro-bell normal attack-start VFX
  - Given: `CombatPresentation` receives a normal weapon attack-start event for
    `electro_bell`
  - When: the event is processed
  - Then: five to eight `arc_bell` particles appear, use the electro-bell
    generated texture, and expire after `0.4s`
  - Edge cases: the particle must not invoke slow-status logic

- **AC-4**: Particle cap and performance guardrails
  - Given: the three new weapon VFX families are spawned alongside existing
    combat particles
  - When: active particles exceed the cap or diagnostics are sampled
  - Then: active Sprite2D particles remain capped at `200`, oldest-first
    eviction still applies, and diagnostic sampling remains within GDD budget

## Test Evidence

**Required evidence**:
- `tests/unit/presentation/combat_presentation_test.gd`
- Godot headless smoke for `res://scenes/main.tscn`
- Godot MCP runtime probe and screenshot evidence

**Evidence file**:
`production/qa/evidence/weapon-style-vfx-variants-2026-06-24.md`

**Status**: [x] Complete. Final RED/GREEN, related regression, headless smoke,
Godot MCP runtime probe, clean logs, and screenshot evidence are recorded in
`production/qa/evidence/weapon-style-vfx-variants-2026-06-24.md`.

## Traceability

| Source | Requirement | Story Coverage |
|--------|-------------|----------------|
| `design/gdd/combat-presentation.md` | `trail_blade`: silver arc, count `1`, lifetime `0.5s` | Long-tail normal attack-start VFX |
| `design/gdd/combat-presentation.md` | `wave_bone`: white shockwave/ring, count `1`, lifetime `0.3s` | Fish-bone normal attack-start VFX |
| `design/gdd/combat-presentation.md` | `arc_bell`: blue electric arcs, count `5-8`, lifetime `0.4s` | Electro-bell normal attack-start VFX |
| `TR-combatfx-003` | Particle system supports GDD particle types with a `200`-particle cap | Adds remaining weapon particle families to the existing cap path |
| `TR-combatfx-007` | Combat presentation stays within the `3ms` total frame budget | Requires Story012 diagnostics to remain passing |
| ADR-0002 | Presentation listens to signals/events and does not call Core methods | Payload-only, Presentation-owned VFX handling |
| ADR-0016 | Weapon metadata can specialize feedback without bypassing Core rules | Uses weapon-style metadata only for visual specialization |

## Dependencies

- Depends on: Combat Presentation Stories 001, 002, 011, and 012.
- Coordinates with: Core Weapon Styles runtime work, but does not alter Core
  behavior.
- Unlocks: final Combat Presentation particle-family closure for
  `TR-combatfx-003`.
