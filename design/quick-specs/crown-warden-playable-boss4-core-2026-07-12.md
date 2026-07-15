# Quick Design Spec: Crown Warden Playable Boss4 Core

> **Date**: 2026-07-12
> **Story target**: 146
> **Status**: Approved by active-goal standing direction
> **Scope**: one complete, replayable Boss4 combat loop inside the authored
> Crown Observatory; reward and ending remain separate slices

## Decision

Use the existing lightweight Boss3 integration pattern, but raise the encounter
quality with two data-driven attack families. Crown Warden is a giant mechanical
owl sentinel that alternates a moving `talon_dive` and a stationary wide
`wing_sweep`. Both expose long, animation-backed tells before a real shared
CollisionComponent hitbox becomes active. At 50% HP phase two shortens cooldowns
and accelerates the dive without introducing summons or arena mutation.

This is preferable to either a one-attack reskin or a full Rat King-style
three-phase framework. It creates a distinct playable fight now while keeping
reward, ending, bespoke audio and cinematic work independently testable.

## Stable Runtime Contract

| Contract | Value |
|----------|-------|
| Boss id | `boss_04_crown_warden` |
| Entity id | `2400` |
| Display name | `Crown Warden` |
| Max HP | `160` |
| Arena | `boss_04_crown_warden_arena` |
| Defeated key | `boss_04_crown_warden_defeated` |
| Phase two | HP ratio `<= 0.50`, after the current attack chain |
| Phase one cooldown | `48` frames |
| Phase two cooldown | `30` frames |
| Character frame size | transparent RGBA `192x192` |

## Attack Contract

### Talon Dive

- Data id / hitbox id: `talon_dive` / `crown_warden_talon_dive`.
- `20` startup frames, `8` active frames, `20` recovery frames.
- `18` physical damage with a `140x78` hitbox at facing-relative offset
  `(92,-34)`.
- Moves toward Cinderpaw only during active frames. Phase one step is `8px`
  per frame; phase two step is `12px` per frame, clamped to arena x `320..1160`.

### Wing Sweep

- Data id / hitbox id: `wing_sweep` / `crown_warden_wing_sweep`.
- `24` startup frames, `10` active frames, `18` recovery frames.
- `14` physical damage with a wide `220x120` hitbox at facing-relative offset
  `(74,-50)`.
- No body translation during active frames. Its wider silhouette pressures
  jump/dodge/parry timing without requiring wall climb.

The boss alternates attacks while autonomous. Deterministic tests and MCP probes
may request either pattern explicitly. Startup never owns an active hitbox;
active hitboxes deactivate before recovery.

## Frame Animation Contract

Use one strict keyed `3x8` source sheet and normalize twenty-four common-anchor
frames. Every visible gameplay state has exactly three frames:

1. `idle`
2. `run`
3. `talon_dive_tell`
4. `talon_dive`
5. `wing_sweep_tell`
6. `wing_sweep`
7. `hurt`
8. `death`

Runtime integration is mandatory:

- `assets/characters/crown_warden/<animation>/`
- `assets/characters/crown_warden/crown_warden_sprite_frames.tres`
- `scenes/characters/crown_warden.tscn`
- `src/characters/crown_warden.gd`
- `src/gameplay/crown_warden_boss.tscn`
- `src/gameplay/crown_warden_boss.gd`

## Arena Loop

- Fresh entry shows Crown Warden, live Boss HUD and two collision-backed crown
  seals. The existing return route is unavailable while the boss is alive and
  SceneManager is locked by the arena.
- Arena binds Cinderpaw's real WeaponComponent chain to entity `2400`; the boss
  binds both attacks to Cinderpaw through shared Health, Collision, Combat and
  StatusEffect components.
- Player death before victory respawns at `BossEntrySpawn` with full HP and
  resets Crown Warden to full HP, phase one, idle state and authored anchor.
- Boss death persists `boss_04_crown_warden_defeated=true`, disables hitboxes,
  keeps the three-frame death presentation visible, opens both seals, hides the
  Boss HUD, releases scene lock and enables the Tower return route.
- Restoring defeated state never replays combat or retains a transition latch.

## Out Of Scope

- `wall_climb` reward claim/unlock presentation, currency, skill points,
  ending/cutscene, credits, post-game state, bespoke portrait, new audio,
  particles, camera shake, summons, projectiles, arena mutation, third phase,
  new Autoloads or SaveSystem schema changes.

## Acceptance

- [ ] Data entries and schemas validate both attack patterns and Boss4 config.
- [ ] All eight visible states use three imported transparent frames through
  `AnimatedSprite2D + SpriteFrames` and mandatory character/gameplay scenes.
- [ ] Both attacks prove startup, active hitbox, damage, recovery and distinct
  movement behavior through the shared combat chain.
- [ ] Phase two, HUD, seals, SceneManager lock, player-death reset, persistent
  defeat and return route form one complete arena loop.
- [ ] Focused/related tests, target smoke and Godot MCP real input/screenshots
  verify a non-placeholder playable Boss fight with clean current-run logs.
