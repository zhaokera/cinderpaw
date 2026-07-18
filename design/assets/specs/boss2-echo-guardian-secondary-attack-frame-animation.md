# Asset Spec: Echo Guardian Secondary Attack Frame Animation

Date: 2026-07-18
Story: `production/epics/player-abilities/story-175-echo-guardian-secondary-attack-playable-loop.md`
Status: Implemented

## Role

The secondary animation distinguishes a committed landing-zone attack from the
Echo Guardian's existing close swipe. The tell communicates a fixed target,
the active frames sell a compact vertical landing, and recovery creates a clear
counterattack window without changing the Boss silhouette or arena footprint.

## Contract

| Field | Value |
|-------|-------|
| Runtime type | Existing `AnimatedSprite2D + SpriteFrames` |
| Animations | `echo_pounce_tell`, `echo_pounce`, `echo_pounce_recovery` |
| Frame count | Exactly 3 per animation |
| Runtime canvas | Transparent `160x128` sRGBA PNG |
| Playback | Non-looping at `10`, `30`, and `12 FPS` respectively |
| Facing | Authored left-facing; runtime retains existing `flip_h` behavior |
| Anchor | Shared center pivot and floor baseline |
| Directories | `assets/characters/boss2_echo_guardian/<animation>/` |
| Naming | `boss2_echo_guardian_<animation>_000.png` through `_002.png` |

## Readability

- Tell frames compress the shoulders and legs while violet echo arcs build; no
  strike, airborne pose or landing impact appears before commitment.
- Active frames move from compact descent to four-paw impact and a low rebound.
  The violet pulse stays close to the body so the gameplay hitbox remains the
  authoritative `100x48` footprint.
- Recovery reverses the authored tell poses into a deliberate rise-to-stand
  sequence. It does not freeze on the active impact frame.
- Gunmetal armor, brass trim and violet cat-eye energy preserve the established
  Echo Guardian identity and avoid the Sluice Matriarch's cyan pressure language.

## Gameplay Contract

| Phase | Startup | Active | Recovery | Damage |
|-------|---------|--------|----------|--------|
| I | 18 frames | 6 frames | 18 frames | 12 |
| II | 15 frames | 6 frames | 15 frames | 12 |

Focus adds six startup frames. Target X is captured at startup and clamped to
the existing Boss2 arena. The landing marker is visible only during startup;
the Boss moves and the pounce hitbox activates only when active begins.

## Pipeline

Exact prompts, identity reference, generated source sheets, alpha processing,
normalization, runtime paths and hashes are retained in
`assets/characters/boss2_echo_guardian/source/boss2_echo_guardian_echo_pounce_imagegen_20260718.json`.

## Validation

- All nine runtime frames are exact transparent `160x128` PNGs with continuous
  names, transparent corners and a stable anchor.
- The mounted `SpriteFrames` resource exposes all three animations with three
  frames each through the existing Boss `AnimatedSprite2D`.
- Godot runtime must show marker/tell, landing/active hitbox, then recovery with
  the hitbox closed; later player movement cannot move the locked landing point.
