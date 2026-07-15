# Quick Design Spec: Crown Warden Wall Climb Reward Payoff

> **Date**: 2026-07-13
> **Story target**: 147
> **Status**: Approved by active-goal standing direction
> **Scope**: one visible, one-shot Boss4 reward claim and durable progression
> handoff inside the completed Crown Observatory

## Decision

Reuse the scene-local `AbilityRewardSource` pattern established by Boss2/Boss3.
Defeating Crown Warden reveals one generated Crown Core. Contact claims it once,
plays a deterministic `1.5s` reward beat, updates HUD/objective feedback and
persists the reward before the existing Tower return.

The GDD defines `wall_climb` as obtainable from Boss4 **or** the hidden Factory
altar. Therefore the claim has two valid outcomes:

- Missing ability: call the player's normal `unlock_ability(&"wall_climb")`
  path and show `Wall Climb Unlocked`.
- Already unlocked: consume the Boss4 reward without emitting a duplicate
  ability event and show `Wall Climb Path Confirmed`.

This preserves equivalent progression rather than substituting currency or a
second ability. A new climb trial is deferred because the current playable
Tower route already consumes wall climb before Boss4.

## Stable Contract

| Contract | Value |
|----------|-------|
| Reward id | `boss_04_wall_climb_reward` |
| State key | `boss_04_wall_climb_reward_claimed` |
| Ability | `wall_climb` |
| Presentation duration | `1.5s` |
| Runtime texture | transparent RGBA `256x256` |
| Source position | `(700, 444)` |
| Persistence targets | arena, `area_05_central_tower`, `main` |

## Player Loop

1. Active fight keeps the reward hidden and unavailable.
2. Crown Warden death opens the arena and reveals the generated Crown Core with
   one gold/cyan expanding reveal pulse.
3. Cinderpaw touches the core. The source is consumed exactly once; missing
   `wall_climb` unlocks through AbilityComponent, while an alternate-path save
   receives confirmation without a duplicate unlock event.
4. For `1.5s`, Cinderpaw is control-locked, the core pulses toward the player,
   HUD/objective text communicates the result, then control returns.
5. Arena, Tower and Main scene state receive the claimed flag/unlocked ability
   list before the player takes the already-open return route.
6. Restoring claimed state keeps the source consumed and never replays the
   reveal, notification or control lock.

## Asset Contract

Generate one isolated mechanical Crown Core on a flat magenta chroma key:

- owl-crown silhouette around a compact magnetic climbing gyroscope;
- steel/brass shell, cat-eye gold ownership light, cyan magnetic arcs;
- strong readable silhouette at `64x64`, no text, UI, ground, shadow or scene;
- retain generated source, exact prompt record and alpha intermediate;
- normalize to `assets/environment/crown_warden_reward/`
  `prop_crown_warden_wall_climb_core_256x256.png`.

No new character animation is required. Existing Cinderpaw and Crown Warden
remain mandatory `AnimatedSprite2D + SpriteFrames` actors.

## Out Of Scope

- Currency, skill points, substitute rewards, new abilities, wall-climb tuning,
  new player frames, a second climb tutorial, new area/registry entry or route.
- Ending, credits, cutscene, bespoke audio, dialogue, arena mutation, Boss
  parry reaction, combat rebalance, SaveSystem schema or Autoload changes.

## Acceptance

- [x] Generated source/prompt/alpha/runtime reward art imports with real alpha.
- [x] Reward is hidden before Boss4 defeat, reveals once after death and is
  claimed once through real player proximity/contact.
- [x] Missing and already-unlocked paths both complete correctly without a
  duplicate ability event.
- [x] The exact `1.5s` presentation, HUD/objective and control restoration run.
- [x] Claimed state and unlocked abilities persist to arena/Tower/Main and
  restore without replay or stale transition state.
- [x] Focused/related tests, target smoke and Godot MCP real input/runtime
  inspection prove the visible payoff with clean logs and a non-empty image.
