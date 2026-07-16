# Quick Design Spec: Crown Warden Four-Boss ACT Complete

> **Date**: 2026-07-16
> **Story target**: 168
> **Status**: Approved by active-goal standing direction
> **Scope**: one durable post-Boss4 ACT-complete payoff at Scrap Roost

## Decision

After the complete Boss4 victory-recall proof returns Cinderpaw to
`main / scrap_roost`, wait `2.5s`, present one full-screen ACT Complete menu,
and persist a one-shot completion flag before autosaving. The player may
continue exploring the implemented world or return to the existing title menu.

This is the ending for the GDD's degraded Tier 4 scope, not an invented fifth
Boss. `game-concept.md` explicitly defines `1` hub, `3` areas, `3` weapons and
`4` Bosses as a complete `5-6` hour game when full scope is reduced. The copy
therefore says `ACT COMPLETE` and `three-region hunt`, while avoiding claims
about unreleased lore, 100% completion or New Game Plus.

## Trigger Contract

| Contract | Value |
|----------|-------|
| Runtime scene | `main / scrap_roost` |
| Required Boss4 scene state | defeated + Crown Core claimed + recall requested |
| Required hub flag | `boss_04_victory_hub_return_secured` |
| Presentation delay | `2.5s` after valid return proof |
| Durable flag | `four_boss_act_completion_seen` |
| Persistence | set flag, then request one runtime autosave |
| Primary action | Continue Exploring |
| Secondary action | Return to Title |

## Player Flow

1. Story148 returns Cinderpaw to the existing Scrap Roost savepoint.
2. Main validates the complete Boss4 proof and secured hub-return flag.
3. After `2.5s`, the generated post-victory backdrop and ACT Complete panel
   appear; gameplay input is locked.
4. Continue Exploring closes the panel and restores player control without
   replaying the completion.
5. Return to Title opens the existing title menu while gameplay remains locked;
   leaving that menu restores the acknowledged exploration state.
6. A loaded save containing the completion flag never replays the payoff.

## Visual Contract

Use one opaque image-generated `1280x720` post-victory Scrap Roost backdrop.
The foreground contains a broken mechanical owl crown and a warm paw lantern;
the background shows the three-region settlement at sunrise. Existing HUD
styles own the centered panel and focusable actions. No character animation is
added or changed by this Story.

## Out Of Scope

- A fifth Boss, credits, cinematic, New Game Plus or new lore/dialogue.
- New regions, new title screen, save schema migration or SceneManager refactor.
- Replaying the physical Boss4 fight, reward and recall contracts already
  accepted by Stories146-148.

## Acceptance

- [x] Only a complete Boss4 recall proof at Scrap Roost starts the delay.
- [x] The payoff appears once after `2.5s`, locks gameplay and uses the generated
  imported backdrop.
- [x] Completion is flagged before exactly one autosave request.
- [x] Continue Exploring and Return to Title preserve coherent input locking.
- [x] Restored seen state and incomplete proof do not replay the payoff.
- [x] Focused/related tests and one Godot MCP runtime pass verify the scene,
  screenshot, physical menu input and clean logs.
