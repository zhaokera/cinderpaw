# Quick Design Spec: Rat King Victory Death Presentation Hold

> **Date**: 2026-07-14
> **Target**: Player-visible Rat King defeat payoff in the real Main scene

## Problem

Rat King currently emits defeat, enters the existing three-frame `death`
animation and immediately opens the full-screen victory/reward menu in the same
call stack. The menu hides the authored death animation, kill particles and
arena state before the player can read the payoff.

`design/gdd/boss-config.md` requires a three-second Boss death animation before
the reward/transition step. The runtime already owns the required generated
frames, kill VFX, defeat audio, reward dispatch and HUD; the missing behavior is
only the presentation hold between gameplay defeat and victory UI.

## Runtime Contract

1. Rat King HP reaching zero immediately disables its combat collision, plays
   the existing non-looping three-frame `death` animation, dispatches configured
   rewards once and persists the defeat as it does today.
2. `GameFlowController` enters `victory_pending` for exactly `3.0s`, locks
   player control and rejects duplicate defeat/death transitions.
3. During the hold, the HUD retry/reward menu remains hidden so the generated
   Rat King death frame and existing kill feedback stay visible.
4. When the hold expires, `GameFlowController` enters `victory` and emits
   `victory_reached` exactly once. Main then hides the Boss HP bar and displays
   the existing `Dash unlocked +50 Gears +5 SP` victory UI.
5. Pause input cannot replace the death payoff with another full-screen menu.

## Ownership

- `RatKingBoss`: existing death animation and collision shutdown authority.
- `GameFlowController`: deterministic three-second pending timer and terminal
  victory signal.
- `MainScene`: existing reward/save ownership and delayed HUD consumer.
- `HUDManager`: unchanged menu renderer.

## Assets

No new asset is required. Reuse:

- `assets/characters/rat_king/death/rat_king_death_000.png` through `_002.png`
- `assets/characters/rat_king/rat_king_sprite_frames.tres`
- existing CombatPresentation kill debris, shake and hitstop
- existing Rat King defeat and victory audio routing

## Verification

- One real Main GdUnit acceptance proves pending state, player lock, three
  death frames, hidden menu before `3.0s`, delayed reward menu and one-shot
  terminal state.
- Related GameFlow, Rat King reward and boss runtime suites remain green.
- Target smoke repeats the real scene contract.
- Godot MCP captures the unobscured death hold and post-hold reward UI in one
  clean run, with non-empty screenshots and no new runtime/editor errors.

## Out Of Scope

- New death frames, VFX, shader, camera cutscene, audio asset or reward values.
- Boss balance, attacks, phases, arena mutations, scene transition or credits.
- Changing when reward data and autosave are committed; only their visible HUD
  presentation is delayed.
