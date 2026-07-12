# Quick Design Spec: Central Tower Threshold Guard

**Type**: Addition
**System**: Exploration gating / Scene management / Ordinary enemy combat
**GDD Reference**: `design/gdd/exploration-ability-gating.md`,
`design/gdd/game-concept.md`, `design/gdd/health-death.md`,
`design/gdd/death-respawn.md`
**Date**: 2026-07-12

## Change Summary

After Story139 secures the Central Tower outer laser net, Cinderpaw can enter a
single-screen threshold vestibule, defeat one non-Boss mechanical guard, open
the inner security seal, and return to Neon Rooftops. This creates a playable
scene handoff without inventing Boss4, a deeper tower layout, or a new reward.

## Motivation

The exploration GDD defines the Central Tower gate but does not define its
interior. A purely empty destination would technically prove scene loading but
would not advance the ACT loop. One bounded guard encounter gives the handoff a
visible combat payoff while keeping every undefined Boss and narrative choice
out of scope.

## Design Delta

The current GDD says Central Tower requires `parry + all prerequisite areas`
and uses a parryable laser net. Story139 already implements and persists that
gate proof.

This addition defines only the first threshold room after that gate:

1. `area_05_central_tower` is a bounded `1280x720` scene at
   `res://scenes/areas/central_tower_threshold.tscn`.
2. Rooftops-to-Tower arrival uses `neon_rooftops_threshold_arrival`; the return
   destination is `area_05_neon_rooftops / central_tower_threshold_return`.
3. Entry requires the existing
   `neon_rooftops_central_tower_threshold_secured=true` state and a second,
   explicit nearby interaction. The laser trial is not replayed or duplicated.
4. The room contains one `central_tower_threshold_guard`, entity `2701`. It is
   an ordinary elite enemy, not Boss4, and uses the established Health,
   Collision, Combat, and data-manager contracts.
5. Crossing x `420` closes the rear and inner seals and activates the guard.
   Defeating it permanently opens both seals and records
   `central_tower_threshold_guard_defeated=true`.
6. A real `SavepointRuntime` Threshold Roost at the arrival marker is activated
   on first entry and becomes the latest discovered savepoint. Lethal damage
   uses the existing 1.5-second death delay, 50% HP revive, and 2-second control
   lock. A failed live attempt clears transient activation, opens both seals,
   resets the guard to full HP, and allows a new x `420` crossing to reactivate
   the fight. A previously defeated guard remains defeated.
7. The room has no reward cache. Its payoff is durable access through the inner
   seal plus the new area itself.

## Visual Contract

- Generate an opaque `1280x720` threshold-vestibule background and transparent
  inner-seal, Threshold Roost, and guard-dock props. No player, enemy, UI, text,
  or collision is baked into the background.
- `central_tower_threshold_guard` uses `AnimatedSprite2D + SpriteFrames` with
  exactly three transparent `96x96` frames for `idle`, `run`, `attack_tell`,
  `attack`, `hurt`, and `death`.
- The 96px canvas is a deliberate unique-elite exception matching the existing
  Neon Signal Rat runtime pipeline. Every frame shares bottom-center anchor
  `(48, 88)` and continuous `_000.._002` naming.
- Signal red appears only in attack warning/active frames; cyan is status light,
  while cat-eye gold remains reserved for player/safe-route semantics.

## Affected Systems

| System | Impact | Action Required |
|--------|--------|-----------------|
| Scene registry | Adds one lazy-loaded area | Update JSON and schema together |
| Scene persistence | Adds Tower local state and Rooftops return spawn | Reuse SceneManager state API |
| Combat | Adds one data-driven ordinary enemy | Reuse Core combat adapters |
| Death/respawn | Adds a real Threshold Roost savepoint | Reuse SavepointRuntime and GameFlowController |
| Asset pipeline | Adds generated background, props, and 18 frames | Preserve sources and manifest evidence |

## Acceptance Criteria

- [x] Secured Story139 state permits one explicit Tower request; all rejected or
  duplicate requests are side-effect free.
- [x] SceneManager swaps both directions with exact scene and spawn IDs while
  preserving Story136-139 and Tower durable state.
- [x] The authored room is bounded, visually generated, collision-backed, and
  contains no visible primitive placeholder.
- [x] The guard activates once, deals real combat damage, receives real player
  damage, drives six three-frame animations, and opens both seals on defeat.
- [x] Threshold Roost activation precedes combat; death revives there with 50%
  HP and resets an uncleared guard attempt to ready without erasing durable
  progression.
- [x] Fresh restore keeps the clear state and does not replay activation or
  defeat feedback.
- [x] Focused tests, one adjacent regression, one headless smoke, and one Godot
  MCP pass verify scene loading, runtime behavior, animation, screenshots, and
  clean current-run logs.

## GDD Update Required?

No. This is a bounded implementation contract beneath the existing Central
Tower gate rule. Boss4, deeper tower content, rewards, narrative, minimap, and
fast travel remain undefined and out of scope.
