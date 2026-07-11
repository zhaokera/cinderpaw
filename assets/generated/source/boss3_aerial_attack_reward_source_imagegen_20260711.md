# Boss3 Aerial Attack Reward Image Generation Record

Date: 2026-07-11
Mode: built-in image generation with Boss2 reward reference
Use case: `stylized-concept`
Story: `production/epics/player-abilities/story-129-sluice-matriarch-aerial-attack-reward-payoff.md`

## Prompt

Create one isolated pixel-art ability reward relic for a polished Godot 4.7
side-scrolling action game, matching the production quality and centered icon
scale of the reference but clearly representing a downward aerial claw strike
rather than wings or double jump. Design a compact industrial cat-eye core:
dark steel and rust-orange pressure clamps around a luminous amber vertical cat
pupil, three sharp pale-gold claw chevrons pointing downward beneath it,
restrained cyan pressure droplets and sparks, and a subtle broken Sluice
Matriarch shell motif. Strong readable silhouette at `256x256`, centered with
generous transparent-safe padding. Use a perfectly uniform flat `#ff00ff`
chroma-key background for later alpha removal. No character, wings, paw icon,
text, letters, UI panel, environment, floor, cast shadow, border, watermark,
crop, blur, gradient background, 3D, or photorealism.

Reference:
`assets/environment/double_jump_reward/boss2_double_jump_reward_source.png`

## Outputs

- Chroma source: `boss3_aerial_attack_reward_source_imagegen_20260711.png`
- Alpha source: `boss3_aerial_attack_reward_source_alpha_20260711.png`
- Runtime texture:
  `assets/environment/aerial_attack_reward/boss3_aerial_attack_reward_source.png`

## Processing

- The generated source is `1254x1254` RGB.
- Border auto-key selected `#f803f7`; soft matte thresholds `12/220` and
  despill produced the retained RGBA source.
- The full centered subject was downsampled to a transparent `256x256` runtime
  texture without trimming, retaining equal padding around the relic.
- Godot 4.7 imported all three files through the standard texture pipeline.

## Runtime Use

`AerialAttackRewardSource` in the Sluice Matriarch arena mounts the runtime
texture. It is hidden before Boss3 defeat, becomes claimable after victory,
and remains consumed on restore. The reveal reuses the already image-generated
ability-gate unlock burst for a short one-shot gold payoff.
