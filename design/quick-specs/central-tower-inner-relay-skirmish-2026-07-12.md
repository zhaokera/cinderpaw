# Quick Design Spec: Central Tower Inner Relay Skirmish

> **Status**: Approved for bounded implementation
> **Story**: 141
> **Date**: 2026-07-12

## Problem

Story140 proves the Central Tower threshold, local Roost, ordinary guard, and
Rooftops round trip. The next slice must make the Tower feel like a playable
area rather than a one-room destination, but the project still has no approved
Boss4 identity, arena, reward, or encounter contract.

## Decision

Extend `area_05_central_tower` from one to two `1280x720` viewports. The new
right-hand Service Spine is a short ACT sequence:

1. Story140's Threshold Guard must already be defeated.
2. Crossing x `1500` closes the room and starts a telegraphed relay pulse.
3. One real `parry` during the strike window reflects the pulse and wakes a
   frame-animated `central_tower_relay_mantis`.
4. Defeating entity `2702` opens the observation shutter and exposes a one-shot
   `+20 Gears` relay cache.
5. The scene ends at a bounded deeper-Tower shutter. No Boss or next scene is
   implied.

This sequence reuses the existing combat, ability, collision, no-loss revive,
scene-state, feedback, and reward-cache contracts. It adds no Autoload and no
new ability.

## Stable Contract

| Contract | Value |
|----------|-------|
| Scene id / path | `area_05_central_tower` / `res://scenes/areas/central_tower_threshold.tscn` |
| Expanded scene size | `2560x720` |
| Activation x | `1500` |
| Relay state | `central_tower_inner_relay_activated` |
| Relay clear state | `central_tower_inner_relay_parried` |
| Mantis entity / family | `2702` / `central_tower_relay_mantis` |
| Mantis activation state | `central_tower_relay_mantis_activated` |
| Mantis clear state | `central_tower_relay_mantis_defeated` |
| Cache id / state | `central_tower_inner_relay_cache` / `central_tower_inner_cache_claimed` |
| Cache reward | `20 Gears` |
| Failed-pulse damage | `8` |

## Attempt And Persistence Rules

- Relay activation, relay parry, and a living Mantis are attempt-local. Player
  death resets all three, opens the seals, restores the Mantis to full health,
  and revives at `central_tower_threshold_roost` using Story140's existing
  `1.5s -> 50% HP -> 2.0s / 120-frame i-frame` flow.
- Mantis defeat and cache claim are durable. A clear that occurs during the
  player death window cannot be rolled back by the earlier respawn snapshot.
- Restoring a cleared room does not replay relay, activation, defeat, reward,
  gate, or audio feedback.
- The exact unlocked-ability set is preserved. Story141 grants no ability.

## Visual Direction

- Second viewport: tall maintenance spine, bundled vertical conduits, deep blue
  machinery, sparse amber service lights, cyan diagnostics, and one old-world
  observation booth embedded in newer angular Tower hardware.
- Relay Mantis: tall, narrow maintenance automaton with curved legs and sharp
  scythe forearms. Its silhouette must contrast with the square heavy Threshold
  Guard. Signal red appears only in attack telegraph/attack frames.
- Runtime character art uses `AnimatedSprite2D + SpriteFrames`; `idle`, `run`,
  `attack_tell`, `attack`, `hurt`, and `death` each contain exactly three
  transparent `96x96` frames on a common bottom-center anchor.
- Interactive props are separate transparent sprites. No visible primitive,
  debug rectangle, baked text, or baked character is accepted.

## Out Of Scope

- Boss4 identity, data, arena, phases, music, reward, cinematic, or story payoff.
- A third Tower viewport, a new scene id, scene handoff, second savepoint, NPC,
  dialogue, minimap, fast travel, hidden room, or new ability.
- Shared Combat, SceneManager, SaveSystem, PlayerAbility, or reward-economy
  refactors.
- Rebalancing Story139's three-parry outer trial or Story140's Threshold Guard.

## Verification Budget

- One three-case focused RED/GREEN suite.
- One Story140 adjacent regression after integration.
- One target headless smoke that starts from a cleared threshold; no Rooftops
  replay and no full suite.
- One final Godot MCP run with real movement/parry/combat state, hierarchy,
  animation inspection, non-empty screenshot, and current-run log review.
