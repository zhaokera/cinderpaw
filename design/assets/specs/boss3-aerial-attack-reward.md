# Asset Spec: Boss3 Aerial Attack Reward

Date: 2026-07-11
Story: `production/epics/player-abilities/story-129-sluice-matriarch-aerial-attack-reward-payoff.md`
Status: Implemented baseline

## Role

The reward closes the Sluice Matriarch victory loop and teaches that Cinderpaw
can now turn airborne attack input into a downward strike. The relic must read
as Factory/Boss3 progression while the player animation remains unmistakably
the existing Cinderpaw.

## Runtime Contract

| Asset | Contract |
|-------|----------|
| Reward source | Transparent `256x256` PNG mounted by `AbilityRewardSource` |
| Cinderpaw animation | `AnimatedSprite2D + SpriteFrames`, non-looping `aerial_attack` |
| Animation frames | Exactly three transparent `96x96` PNGs |
| Frame path | `assets/characters/cinderpaw/aerial_attack/` |
| Naming | `cinderpaw_aerial_attack_000.png` through `_002.png` |
| Shared anchor | Whole-cell center and pivot retained across all frames |
| Reveal VFX | Reused image-generated ability-gate dissolve burst, `0.55s` |

## Art Direction

- The reward uses dark steel, rust-orange clamps, amber cat-eye light, pale-gold
  downward claw chevrons, and restrained cyan pressure fragments.
- The aerial strip preserves Cinderpaw's black/rust fur, amber eyes, red scarf,
  shoulder armour, and right-facing authored identity.
- Frame silhouettes progress from airborne tuck to vertical dive to compressed
  impact-ready pose. Gold-white downward streaks communicate direction without
  embedding a floor or environment in the character frames.

## Pipeline

Full prompts and processing records live at:

- `assets/characters/cinderpaw/source/cinderpaw_aerial_attack_strip_imagegen_20260711.md`
- `assets/generated/source/boss3_aerial_attack_reward_source_imagegen_20260711.md`

Both retained sources were chroma-keyed with the installed image-generation
helper, normalized to fixed transparent runtime canvases, and imported through
Godot 4.7.

## Validation

- Reward and all three frames have alpha and transparent corners.
- `cinderpaw_sprite_frames.tres` exposes `aerial_attack` with exactly three
  frames and the player scene still uses `AnimatedSprite2D`.
- Runtime reward visibility follows boss-defeated/claimed state without replay
  on restore.
- Runtime attack selects `cat_claw_aerial`, shows the authored frames, damages
  through shared collision/combat, bounces once, and restores one air jump.
- Godot MCP verifies imported resources, scene hierarchy, animation playback,
  reward state, clean logs, and non-empty screenshots.
