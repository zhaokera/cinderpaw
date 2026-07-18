# Quick Spec: Sluice Matriarch Phase II Transition Readability

Date: 2026-07-18
Story: `production/epics/player-abilities/story-174-sluice-matriarch-phase-two-transition-readability.md`
Status: Implemented

## Problem

Sluice Matriarch currently changes to Phase II immediately after the threshold
attack finishes. The HUD and body tint change, but there is no dedicated state,
invulnerability window, readable transformation, phase VFX, or phase audio.
The player cannot clearly tell when the faster Phase II rules begin.

## Decision

- Crossing `60/120` HP during an attack queues the transition until that full
  startup/active/recovery chain ends.
- The Boss then enters one `2.5s` `phase_transition` state. Movement and attack
  scheduling stop, all attack hitboxes close, the geyser disappears, and the
  Boss Hurtbox uses `gone` so damage is explicitly rejected.
- A dedicated looping three-frame `phase_transition` animation communicates
  pressure build-up without reusing the short hurt reaction or an attack tell.
- The existing CombatPresentation, AudioSystem, Boss HUD, room seals, player
  control, and SceneManager lock remain active. Their phase feedback is routed
  from the Boss's existing transition signal exactly once.
- On the `2.5s` boundary the Hurtbox returns to `normal`, the Boss enters idle,
  and the existing Phase II cooldown and Story173 attack alternation resume.

## Presentation

- Boss animation: `phase_transition`, three transparent `192x192` frames,
  `6 FPS`, looping for five cycles over the transition window.
- Pose language: planted body, clamps locking, ceramic pressure plates lifting,
  cyan seams and pale pressure sacs pulsing. Avoid signal-red attack language,
  strike extensions, injury collapse, text, and environmental elements.
- Existing phase presentation supplies four feedback frames, screen shake, one
  center-clear overlay, thirty-two debris pieces, and `sfx_boss_phase`.

## Boundaries

No Phase III, summon, arena mutation, new attack, damage change, camera
choreography, music authoring, reward, route, save schema, or BossConfig
migration. The existing source/alpha/import pipeline and asset manifest rules
remain mandatory for the new character frames.
