# QA Evidence: Rat Minion Hurt/Death Frame Readability

> **Story**: Combat Presentation 037
> **Date**: 2026-07-21
> **Engine**: Godot 4.7-stable
> **Godot AI MCP**: plugin/server 3.0.4

## Acceptance Summary

| Criterion | Evidence | Result |
| --- | --- | --- |
| Shared authored animation | Spark/Coil Rat use AnimatedSprite2D and existing 3-frame hurt/death resources | PASS |
| Hurt readability | 3@8fps completes across a 23-physics-frame HIT state | PASS |
| Flash timing | Warm hit flash ends after 3 physics frames without ending hurt | PASS |
| Death readability | 3@6fps reaches final frame at full alpha, then holds for 2.0s | PASS |
| Combat safety | Physics, collision and hurtbox interaction stop immediately on death | PASS |
| Factory integration | Parent defeat callback cannot hide the death pose; survivor/state contracts pass | PASS |
| Runtime cleanup | 0.22s fade frees the node after the corpse hold | PASS |
| Clean MCP runtime | Non-empty screenshots, info-only game log, empty editor log, clean stop | PASS |

## Automated Evidence

- Intentional canonical RED: `reports/report_2208/results.xml`
  - One case produced seven expected failures and zero errors.
  - It exposed five-frame flash duration, incomplete hurt playback, premature
    death fade and early node cleanup.
- Production-parent diagnostic RED: `reports/report_2211/results.xml`
  - One case produced four expected failures and zero errors.
  - It proved the synchronous Factory defeat callback could immediately hide a
    correctly started shared death animation.
- Focused GREEN: `reports/report_2213/results.xml`
  - Canonical Story037 passed `1/1` with zero failures or errors.
- Final bounded related GREEN: `reports/report_2214/results.xml`
  - Nine suites passed `18/18` with zero failure, error, flaky, skipped or
    orphan cases.
  - Coverage includes Rat Minion attack tell, Rat King live summon/cap cleanup,
    Factory production Stories 200-202 and original Stories 080-082.
- Full suite was not run. The verification set is intentionally limited to the
  shared Rat Minion family and directly affected Factory encounter contracts.

## Runtime Contract

- Hurt-state duration is calculated from each SpriteFrames animation's per-frame
  duration and FPS, then rounded up to physics ticks. The shared current assets
  resolve to `ceil(3 / 8 * 60) = 23` physics frames.
- Hit flash has an independent three-frame timer. It no longer dictates when
  enemy control returns from the longer hurt animation.
- Death emits `enemy_defeated` immediately so encounter persistence, summon-cap
  release and partner progression are unchanged. After synchronous listeners
  return, the shared enemy reasserts visual/process ownership while leaving
  physics and all combat collision disabled.
- Death wait is data-derived `0.5s` animation time plus `2.0s` completed-pose
  hold, followed by a `0.22s` alpha fade and `queue_free()`.

## MCP Runtime Evidence

- Session: `cinderpaw@1311`
- Run: `r122286549-38`
- Custom scene: `res://scenes/factory_route_transition_shell.tscn`
- The production Factory state activated `FactorySparkRat` entity `2102` at
  `24 HP`. MCP placed it within the player's normal right-facing attack range;
  damage itself was not injected.
- First real `attack` Input action:
  - `cat_claw_light`, `target_id=2102`, `final_damage=12`
  - HP `24 -> 12`
  - runtime probe observed `animation=hurt`, `frame=1`, visible and full alpha
- Second real `attack` Input action:
  - `cat_claw_light`, `target_id=2102`, `final_damage=12`
  - HP `12 -> 0`
  - after `0.52s`: `animation=death`, `frame=2`, alpha `1.0`, visible, physics
    processing disabled
  - after the hold/fade window: `FactorySparkRat` no longer existed
- Production Coil Rat inspection returned `AnimatedSprite2D`, `hurt=3@8fps`
  and `death=3@6fps`, proving the shared inherited resource contract.
- Two game screenshots returned RGB `1278x718` images with the Factory scene,
  Cinderpaw and animated rats visible; neither viewport was empty.
- Game log contained only game-helper registration. Editor log had zero rows.
  The run stopped successfully and the editor returned to `ready`.

## Headless Smoke Note

`reports/rat_minion_hurt_death_frame_readability_smoke.log` completed the real
Factory scene for `180` frames and exited `0`. Godot then printed
`4 ObjectDB instances were leaked` and `2 resources still in use` during
shutdown. The identical counts exist in many earlier Factory smoke logs,
including Story200's production-combat smoke, while accepted MCP run 38 had no
game/editor error. This is retained as an existing headless teardown diagnostic,
not represented as a clean-shutdown assertion for Story037.

## Scope Audit

- No image generation was needed and no visual/audio resource changed.
- No damage, HP, attack timing, enemy locomotion, summon cap, encounter state,
  reward, persistence or save-schema rule changed.
- Existing Factory Spark Rat and Factory Coil Rat generated assets remain in
  the registered asset pipeline paths.
- Technical-art review noted about two pixels of ground alignment variance in
  the Coil Rat's third hurt frame. It does not block this timing Story and
  remains a future asset-polish item.
- Coil Pincer natural spawn separation remains the next Factory readability
  item; the complete-game objective remains active.
