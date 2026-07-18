# Echo Guardian Challenge Beacon

## Purpose

Player-facing challenge point for Scene Management Story019. It marks the
optional Echo Guardian encounter during the safe post-Rat-King intermission and
disappears as soon as the encounter starts.

## Runtime Contract

- Consumer: `scenes/main.tscn` / `Boss2ChallengeMarker/Visual`
- Node type: `Sprite2D`
- Final import: `assets/environment/echo_guardian_challenge/`
- Retained source: `assets/generated/source/`
- Intended display footprint: roughly `110x140` world pixels
- Background: transparent after local chroma-key removal
- No baked text, UI prompt, actor, floor, shadow or collision guide

## Generation Prompt

```text
Use case: stylized-concept
Asset type: transparent 2D side-scrolling game prop cutout
Primary request: create a waist-high mechanical challenge beacon for the Echo Guardian in a feline post-apocalyptic Scrap Roost
Subject: a compact cracked-steel plinth with scavenged bolts, a bright violet and cyan echo-energy core, and a subtle abstract cat-ear guardian crest; readable as an object the player deliberately activates
Style/medium: polished hand-painted 2D game asset, dark industrial wasteland materials, crisp silhouette, matching a detailed side-scrolling action game rather than pixel art
Composition/framing: one complete centered object, straight side view with slight three-quarter material readability, generous padding, no crop
Lighting/mood: restrained cool glow against worn gunmetal; dangerous but dormant
Color palette: charcoal steel, oxidized teal, small violet and cyan emissive accents; do not use magenta in the subject
Scene/backdrop: perfectly flat solid #ff00ff chroma-key background for removal
Constraints: background must be one uniform color with no shadow, gradient, texture, reflection, floor plane or lighting variation; crisp separated edges; no cast shadow; no contact shadow; no reflection; no text; no UI; no watermark
Avoid: characters, weapons, doorway, full arena arch, rectangular placeholder block, excessive glow, purple haze
```

## Validation

- [x] Alpha channel present with transparent corners and no visible magenta fringe.
- [x] Subject coverage and silhouette remain legible after Godot scaling.
- [x] Imported texture is non-empty and visible in the Main runtime.
- [x] Asset path, prompt, source and MCP screenshot are recorded in manifest/QA
  evidence before Story completion.
