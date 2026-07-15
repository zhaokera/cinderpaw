# Quick Design Spec: Crown Warden Victory Recall To Scrap Roost

> **Date**: 2026-07-13
> **Story target**: 148
> **Status**: Approved by active-goal standing direction
> **Scope**: one optional post-Boss4 return that closes the session at the
> existing Scrap Roost hub without claiming a final ending

## Decision

Keep Story145's left-side return to Apex Approach and add a distinct right-side
`CrownVictoryRecallRoute` after Story147's Crown Core has been claimed. The new
route requests the established `main / scrap_roost` runtime handoff. On arrival,
MainScene recognizes the persisted Boss4 recall proof, places Cinderpaw at the
existing Scrap Roost savepoint and shows one victory-return acknowledgement.

This is a session close, not an ending. `game-concept.md` defines the complete
session as Boss defeat followed by a return to the hub, but also defines five
Bosses for the full version. Crown Warden is explicitly `boss_04`, so this slice
must not show credits, final-Boss language or main-story completion.

## Alternatives

- **Selected: optional direct recall plus the existing Tower return.** Preserves
  player choice and closes the GDD session loop without invalidating Story145.
- **Rejected: retarget the existing Tower return to Main.** This would break the
  exact Central Tower round-trip contract and related tests.
- **Rejected: ending or credits after Boss4.** The authoritative concept targets
  five Bosses and does not define Crown Warden as the final Boss.

## Stable Contract

| Contract | Value |
|----------|-------|
| Route id | `crown_warden_victory_recall` |
| Availability | Boss4 defeated and Crown Core claimed |
| Target | `main / scrap_roost` |
| Durable proof | `boss_04_victory_recall_requested` |
| Hub world flag | `boss_04_victory_hub_return_secured` |
| Runtime texture | transparent sRGBA `256x384` |
| Route position | `(1180, 536)` |

## Player Loop

1. The recall visual is hidden while Crown Warden is active and while the
   Crown Core remains unclaimed.
2. Claiming the reward reveals a generated owl-crown recall transmitter at the
   arena's right exit. The existing left Tower return remains available.
3. Cinderpaw walks into recall range and presses Interact. The arena persists
   defeated/reward/ability/recall state before requesting `main / scrap_roost`.
4. Duplicate input during the same transition sends no second request.
5. Returned MainScene places Cinderpaw at Scrap Roost, discovers that existing
   savepoint, records the hub-return flag and shows `Crown secured - returned to
   Scrap Roost` once.
6. Restoring arena state clears transient request latches while preserving the
   durable recall proof and both post-victory route choices.

## Asset Contract

Generate one isolated Crown Observatory recall transmitter on a uniform
magenta chroma key. It uses a narrow owl-crown silhouette, brass/steel casing,
cyan concentric transmission rings and one cat-eye gold status lens. Retain the
source, exact prompt and alpha intermediate; normalize to transparent sRGBA
`256x384` at:

`assets/environment/crown_warden_victory_recall/prop_crown_warden_victory_recall_256x384.png`

No new character or character state is introduced. Existing Cinderpaw and Crown
Warden remain `AnimatedSprite2D + SpriteFrames` actors.

## Out Of Scope

- Boss5, final-Boss claims, ending, credits, new game plus, dialogue or lore
  invention.
- New hub scene, SceneManager refactor, SaveSystem schema, autosave UI, new
  player/Boss animation, combat tuning or reward changes.
- Replacing the existing Apex Approach return.

## Acceptance

- [x] Recall is hidden/unavailable before reward claim and visible/available
  after claim while the Tower return remains intact.
- [x] Real range plus Interact requests `main / scrap_roost` once and persists
  the durable recall proof without changing abilities.
- [x] Restore preserves the proof but clears transient request/feedback state.
- [x] MainScene recognizes a valid Boss4 recall, places Cinderpaw at Scrap Roost,
  discovers the savepoint and acknowledges the return once.
- [x] Generated source/prompt/alpha/runtime art imports with real transparency.
- [x] Three focused tests, bounded related regression, one target smoke and one
  Godot MCP runtime pass prove interaction, transition, arrival, visuals and
  clean logs without running the full suite.
