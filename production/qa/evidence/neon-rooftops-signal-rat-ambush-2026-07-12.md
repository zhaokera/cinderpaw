# QA Evidence: Neon Rooftops Signal Rat Ambush

## Scope

Story137 expands the existing Neon Rooftops scene to `2560x720` and adds one
generated, frame-animated ordinary enemy encounter. Story136 traversal gates
activation; defeat opens two signal seals, reveals a once-only `+20 Gears`
cache, and preserves the complete rooftop state through scene snapshots.

## Automated Evidence

- Initial RED: `reports/report_1478/results.xml` ran all `3` focused cases and
  recorded `36` expected contract failures with zero framework errors.
- Focused GREEN: `reports/report_1481/results.xml` passed `3/3` with zero errors,
  failures, skipped cases, flaky cases, or orphan nodes.
- The first bounded adjacent run `report_1482` exposed one stale Story136
  objective expectation. Story137 correctly advances it from
  `Neon Rooftops Reached` to `Reach Signal Roof`.
- Final bounded Story136-137 GREEN: `reports/report_1483/results.xml` passed
  `6/6` with zero errors, failures, skipped cases, flaky cases, or orphan nodes.
- Targeted Godot 4.7 headless smoke exited `0` with marker
  `neon_rooftops_signal_rat_ambush_smoke=passed`; it covered gated activation,
  real shared attack damage, clear, reward deduplication, and state restore.
- Godot 4.7 `--import --quit` exited `0` and imported all new scene, script,
  source, alpha, runtime texture, and SpriteFrames resources.

## Asset Evidence

- Built-in image generation produced one opaque `1672x941` Signal Roof source,
  one keyed `1624x969` seal/cache sheet, and one keyed `887x1774` strict `3x6`
  Signal Rat sheet.
- Local resize and installed imagegen chroma-key processing produced exact
  opaque RGB `1280x720`, transparent RGBA `256x384` and `256x256` props, plus
  eighteen transparent `96x96` frames with common anchors.
- Prompt, source, alpha, preview, runtime paths, processing records, asset spec,
  manifest entries, and entity inventory entries are retained.

## Runtime Findings And Fixes

- The first real player attack check teleported Cinderpaw while airborne, so
  the controller correctly chose the aerial attack rather than the requested
  ground light hitbox. The test now establishes grounded state before asserting
  the actual `cat_claw_light` chain; production attack selection was unchanged.
- Adding Story137 superseded Story136's terminal objective. Only the adjacent
  expectation changed; Story136 traversal, return, and persistence remain intact.
- Three read-only design/art/QA sidecars were attempted twice, but the backend
  rejected an injected unsupported `reasoning.effort=max` before execution.
  Bounded design, art, acceptance, and integration reviews completed locally.

## Godot MCP Evidence

- Session: `cinderpaw@e40d`
- Engine: Godot `4.7-stable (official)`
- Plugin/server: Godot AI MCP `2.9.1`
- MCP force-reloaded the exact rooftop scene and inspected `58` authored nodes,
  including both generated backgrounds, physical descent/arena collision,
  Signal Roof controller, two seals, cache, Cinderpaw, objective, and HUD.
- Runtime run `50` contained `86` nodes. Real `move_right` input activated the
  encounter and real `attack` input entered combat. MCP inspected the visible
  `NeonSignalRat/Sprite` as `AnimatedSprite2D`, playing `attack_tell`, with the
  exact generated SpriteFrames resource and `src/characters/neon_signal_rat.gd`.
- A non-empty `1278x718` gameplay capture showed the generated Signal Roof,
  both generated seals, Cinderpaw at `67/100` HP, the animated Signal Rat, HUD,
  and readable `Break Neon Signal Rat` objective without overlap.
- Run `50` returned `current_run_errors=[]`. Current-run game logs contain only
  MCP helper registration, DataManager enemy-stat load, and fixture readiness;
  editor reads after cursor `3` contain no new rows. Retained Old Factory parse
  rows predate this Story and did not recur in the current run.
- The temporary MCP fixture was deleted after capture.

## Verdict

PASS. Story137 provides a generated-art, frame-animated, physically bounded ACT
combat/reward loop with focused regression coverage and clean current-run MCP
evidence on Godot 4.7 and Godot AI MCP 2.9.1.
