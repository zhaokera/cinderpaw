# Story 135: Factory Hidden Altar Wall Climb Reward Traversal

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Core / Feature / Gameplay Runtime / Presentation
> **Type**: Integration + Player Movement + Frame Animation Contract
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-11

## Context

**GDD**: `design/gdd/player-abilities.md`,
`design/gdd/exploration-ability-gating.md`,
`design/gdd/scene-management.md`

**Requirements**: `TR-ability-001`, `TR-ability-002`, `TR-ability-004`,
`TR-ability-005`, `TR-explore-001`, `TR-explore-002`, `TR-explore-006`

**ADR Governing Implementation**: ADR-0001 component ownership; ADR-0002 typed
signals; ADR-0003 data management; ADR-0005 combat state coordination; ADR-0007
scene persistence; ADR-0018 player abilities; ADR-0021 save system.

Story134 makes the hidden Old Factory altar reachable but deliberately leaves it
dormant. The player-abilities GDD defines that altar as the alternate source for
`wall_climb`, equivalent to the future Boss4 path. This story turns that authored
landmark into a complete ACT-game reward: Cinderpaw claims the ability, receives
visible generated feedback, uses a dedicated frame animation to climb a magnetic
wall, and reaches a high perch that cannot be reached by the existing jump and
double-jump alone.

ADR-0018 remains `Proposed`, matching the project-level condition already
recorded by Stories129-134. This story follows it as governing guidance without
changing ADR status.

## Acceptance Criteria

- [x] `data/abilities.json` and its schema define data-driven `wall_climb`
  movement values for climb speed, neutral wall-slide speed, wall-jump horizontal
  and vertical velocity, and regrab lock frames; the player does not hardcode
  those tuning values.
- [x] Cinderpaw exposes a `wall_climb` animation through the existing
  `AnimatedSprite2D + SpriteFrames` surface with at least three transparent,
  consistent `96x96` frames under `assets/characters/cinderpaw/wall_climb/`.
- [x] The Factory upper scene contains an image-generated awakened altar,
  magnetic-wall visual, wall-contact glow, collision-backed top perch, and a
  high-route proof area. No primitive placeholder is visible in gameplay.
- [x] After Story134 discovery, nearby `interact` claims the altar exactly once,
  calls the player's `AbilityComponent` path to unlock `wall_climb`, runs a
  `1.5` second visible reward beat, updates the objective, and immediately
  persists the claimed flag plus unlocked abilities through SceneManager.
- [x] Claim is idempotent across duplicate input and local-state restore. If
  `wall_climb` was already unlocked through another path, the altar can still be
  marked claimed without emitting a duplicate ability unlock.
- [x] While unlocked, airborne, touching a near-horizontal wall normal, and not
  in a blocking action, holding toward the wall plus `move_up`/`move_down`
  climbs vertically; neutral vertical input produces a controlled slide. Without
  the ability or valid wall contact, normal gravity/movement remains unchanged.
- [x] Pressing jump during wall climb launches Cinderpaw away from the wall using
  configured velocities, exits wall-climb state, and applies the configured
  regrab lock. Floor contact, lost wall contact, control lock, hurt/death, and
  respawn also clear wall-climb state safely.
- [x] Wall-climb start drives the generated `wall_climb` frames and one generated
  contact-glow feedback event. The animation does not replace attack, hurt,
  death, revive, dash, dodge, parry, or aerial-attack priority.
- [x] Reaching the high proof area requires `wall_climb`, records
  `factory_upper_wall_climb_route_proven=true` once, persists it, and changes the
  objective to `Rooftop Route Reached` without creating the Neon Rooftops scene.
- [x] Focused RED/GREEN tests, one bounded adjacent regression, one targeted
  headless smoke, and Godot MCP verify data/schema, reward, persistence, real
  wall collision and movement, SpriteFrames, generated textures, objective,
  logs, key nodes, and non-empty gameplay screenshots.

## Implementation Notes

- Keep movement ownership in `PlayerController`; the upper-scene controller owns
  only reward, local route state, scene persistence, prompts, and presentation.
- Expose the ability config through a read-only duplicate from `AbilityComponent`
  so the movement controller consumes JSON values without mutating Core state.
- Start wall climb only from a valid `CharacterBody2D` wall contact and an input
  held toward that wall. Do not create global raycasts or an Autoload ability
  manager.
- Use the existing Story134 dormant altar as the pre-claim state and switch to a
  distinct generated awakened texture after claim. Unlock feedback must remain
  legible without covering Cinderpaw or the HUD.
- Keep the high proof perch within the existing `1280x720` scene and below the
  camera top limit. Its geometry must remain unreachable by the current combined
  jump/double-jump height from ApproachPlatformC.

## Out of Scope

- Wall-climb stamina, depletion, upgrades, or exhaustion. The GDD still marks
  stamina as an open question and defines no cooldown.
- Boss4 design, encounter, reward, art, or alternate-path implementation.
- A Neon Rooftops scene, registry entry, full magnetic-wall gate, map update, or
  route handoff; the high perch only proves the movement ability.
- Wall combat, wall attacks, ledge grab, mantling, ceiling crawl, or moving walls.
- New ability HUD inventory, bespoke audio production, controller remapping, or
  mobile controls.

## QA Test Cases

- **AC-1/2/3**: Data and generated asset contract
  - Given: Story135 files are present.
  - When: JSON, schema, SpriteFrames, PNGs, and upper scene are inspected.
  - Then: tuning is data-driven, `wall_climb` has at least three normalized
    frames, and all generated runtime textures/collision nodes resolve.
- **AC-4/5**: Reward and restore
  - Given: the altar is discovered and Cinderpaw is in claim range.
  - When: claim is requested twice, then state is serialized/restored.
  - Then: `wall_climb` is unlocked, feedback occurs once, state and ability are
    persisted, duplicate unlock is suppressed, and restored feedback does not
    replay.
- **AC-6/7/8**: Movement and animation
  - Given: a player with or without `wall_climb` and a deterministic wall normal.
  - When: climb, slide, detach, wall jump, control lock, hurt/death, and respawn
    transitions are exercised.
  - Then: configured velocity/state rules hold, blocking states remain dominant,
    and `wall_climb`/contact feedback occur only on valid entry.
- **AC-9/10**: Playable proof
  - Given: the claimed upper scene is running through Godot.
  - When: Cinderpaw climbs the magnetic wall and enters the top proof area.
  - Then: the route-proven flag persists once, objective changes, screenshots
    show the generated player/wall/altar, and current-run logs remain clean.

## Test Evidence

**Required evidence**:

- `tests/unit/gameplay/factory_hidden_altar_wall_climb_reward_test.gd`
- `tests/smoke/factory_hidden_altar_wall_climb_reward_smoke.gd`
- `production/qa/evidence/factory-hidden-altar-wall-climb-reward-2026-07-11.md`

**Status**: [x] Complete. Initial RED `report_1464`; final focused GREEN
`report_1471` passed `3/3`; bounded related GREEN `report_1466` passed `12/12`;
targeted smoke passed; Godot MCP runs `42-45` verified real input, generated
textures, frame animation, physical traversal, objective, screenshot, and logs.

## Completion Notes

- Acceptance: `10/10` complete.
- Generated four visual groups and imported them through Godot 4.7.
- MCP verification found and drove fixes for the proof perch underside, scene-top
  escape, and HUD-adjacent landing position before completion.
- Boss4, wall stamina, wall combat, and Neon Rooftops remain intentionally out
  of scope.

## Dependencies

- Depends on: Story134 Deep Cistern Ascender Factory Upper Altar Approach.
  Complete.
- Unlocks: a future Neon Rooftops magnetic-wall gate and route handoff story.
