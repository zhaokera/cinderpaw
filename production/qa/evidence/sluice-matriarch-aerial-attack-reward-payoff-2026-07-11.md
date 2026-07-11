# QA Evidence: Sluice Matriarch Aerial Attack Reward Payoff -- 2026-07-11

## Scope

Story129 completes the Boss3 victory payoff. Defeating Sluice Matriarch reveals
a generated ability core; proximity claim unlocks and persists
`aerial_attack`; airborne regular attack input starts a generated three-frame
downward strike that deals shared weapon damage, grants eight cat energy,
bounces once, and restores one consumed double-jump use. The Underground route
and its first traversal gate remain Story130 scope.

## Automated Evidence

- Expected RED: `reports/report_1416/`
  - The focused suite ran three tests and failed on the missing reward node,
    claim/persistence API, SpriteFrames animation, and aerial runtime methods.
- Import-only intermediate: `reports/report_1417/`
  - Generated PNGs existed but had not yet passed Godot import. This run is not
    used as final evidence.
- First focused GREEN: `reports/report_1418/`
  - All three Story129 tests passed after import and runtime integration.
- Final focused GREEN: `reports/report_1419/`
  - Story129 passed `3/3` after the one-shot reward reveal VFX was added.
- Final bounded related GREEN: `reports/report_1420/`
  - Story129, Story128 Boss3, Story127 arena handoff, player double-jump gate,
    shared heavy/aerial hooks, and Factory roundtrip passed `20/20`.

## Asset Generation And Import

- Built-in image generation created a strict three-cell Cinderpaw aerial
  attack strip and a dedicated Boss3 ability core.
- Cinderpaw records:
  `assets/characters/cinderpaw/source/cinderpaw_aerial_attack_strip_imagegen_20260711.md`;
  retained RGB/alpha strip sources live beside the record.
- The strip was chroma-keyed, normalized, and split into three transparent,
  consistently anchored `96x96` frames under
  `assets/characters/cinderpaw/aerial_attack/`.
- Reward records:
  `assets/generated/source/boss3_aerial_attack_reward_source_imagegen_20260711.md`
  and `design/assets/specs/boss3-aerial-attack-reward.md`.
- The runtime reward is a transparent `256x256` PNG at
  `assets/environment/aerial_attack_reward/boss3_aerial_attack_reward_source.png`.
- Godot 4.7 headless import exited `0`; source, alpha, runtime frames, reward,
  and dependent SpriteFrames resources all produced import metadata.

## Headless Runtime Smoke

- Script: `tests/smoke/sluice_matriarch_aerial_attack_reward_payoff_smoke.gd`.
- Log: `reports/sluice_matriarch_aerial_attack_reward_payoff_smoke.log`.
- Result: exit `0` with marker
  `sluice_matriarch_aerial_attack_reward_payoff_smoke=passed`.
- Coverage: defeat reveal, one-time claim, HUD/objective update, restored claim,
  SceneManager Factory/Main ability handoff, active-boss aerial hit, 12 damage,
  eight energy, upward bounce, and one restored double-jump use.

## Godot MCP Runtime Evidence

- Session: `cinderpaw@e40d`; Godot `4.7-stable (official)`; Godot AI MCP
  plugin/server `2.9.1`; final run token `22`.
- MCP force-reloaded
  `res://scenes/bosses/sluice_matriarch_arena.tscn` from disk. The authored
  hierarchy reported `42` nodes and included Cinderpaw, Sluice Matriarch,
  `AerialAttackRewardSource`, its visual/interaction/prompt children, seals,
  return route, objective, and HUD.
- Cinderpaw's editor node is an `AnimatedSprite2D` whose SpriteFrames resource
  resolves to
  `res://assets/characters/cinderpaw/cinderpaw_sprite_frames.tres`.
- The reward visual resolved to the imported runtime texture
  `res://assets/environment/aerial_attack_reward/boss3_aerial_attack_reward_source.png`.
- The live runtime hierarchy reported `72` nodes, including both generated
  character sprites, shared player/boss combat nodes, the reward source, HUD,
  room seals, and return route.
- A non-empty `1278x718` game screenshot showed Cinderpaw, the frame-animated
  Sluice Matriarch, authored arena art, readable objective, Boss HUD, player
  HUD, and no incoherent overlap.
- `project_run` reported `current_run_errors=[]`. The game log contained only
  Godot AI helper registration, and editor logs since cursor `3` had no new
  rows after stop. Three retained Old Factory parse rows were explicitly marked
  as pre-run history and did not recur in the current run.

## Acceptance Mapping

| Acceptance | Evidence | Result |
|------------|----------|--------|
| Defeat reveals one claimable generated reward | Story129 GdUnit; targeted smoke; MCP reward hierarchy/texture | PASS |
| Claim unlocks, persists, and hands off `aerial_attack` | Story129 GdUnit; smoke; Factory roundtrip regression | PASS |
| Airborne input selects the three-frame aerial attack | Story129 GdUnit; SpriteFrames asset audit; MCP player resource | PASS |
| Hit deals 12, grants 8 energy, bounces, and restores one jump | Story129 GdUnit; targeted smoke; related combat tests | PASS |
| Generated art is documented and imported | Generation records; specs/manifest; Godot import | PASS |
| Godot 4.7 / MCP 2.9.1 run is clean and visible | MCP run token 22; logs; hierarchy; screenshot | PASS |
