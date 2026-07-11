# Asset Spec: Underground Corrosion Channel Skirmish

## Scope

Story131 extends the Underground Passage into a second gameplay viewport with a
readable runoff traversal, a sealed combat arena, and a distinct salvage payoff.
The two enemies reuse the completed image-generated Factory Sluice Leech frame
set; this Story introduces no new character family.

## Runtime Assets

| Asset | Runtime path | Contract |
|-------|--------------|----------|
| Corrosion channel background | `assets/environment/underground_passage/env_underground_corrosion_channel_1280x720.png` | Opaque RGB, exact `1280x720`, side-view room continuation |
| Corrosive runoff | `assets/environment/underground_passage/prop_underground_corrosive_runoff_512x160.png` | Transparent RGBA, exact `512x160`, low horizontal hazard |
| Combat seal | `assets/environment/underground_passage/prop_underground_seal_gate_256x384.png` | Transparent RGBA, exact `256x384`, one reusable vertical gate |
| Salvage cache | `assets/environment/underground_passage/prop_underground_salvage_cache_256x256.png` | Transparent RGBA, exact `256x256`, one claimable reward prop |

## Visual Direction

- Continue the entry room's charcoal masonry, rusted steel, oxidized copper,
  cyan mineral seams, and amber work lights.
- Toxic yellow-green remains semantic: it appears on the runoff hazard and at
  the bottom of combat seals, not across the full environment.
- The lower movement lane stays broad and uncluttered. Gates use strong vertical
  silhouettes; enemies remain readable between them.
- The cache uses one amber focal core and is visually distinct from the toxic
  hazard despite sharing the same Underground materials.
- No baked text, UI, characters, enemies, shadows on chroma sources, or visible
  placeholder collision shapes.

## Scene Layout

- Entry background: center `(640,360)`; channel background: `(1920,360)`.
- Runoff hazard: `(1120,566)` with stepping platforms at x `960/1120/1280`.
- Encounter activation: x `1450`; rear seal x `1370`; forward seal x `2250`.
  The rear seal must remain at least `64` px behind the activation threshold.
- Sluice Leeches: x `1760/2040`; salvage cache: `(2410,568)`.
- Camera and authored collision bounds: `0..2560`, height `720`.

## Godot Integration

- Backgrounds and props use `Sprite2D` with nearest filtering.
- `UndergroundCorrosiveRunoff` owns the hazard metadata and Area2D surface.
- Both seal visuals mount on StaticBody2D collision blockers controlled by the
  Underground scene state.
- `UndergroundSalvageCache` reuses the shared one-shot cache contract. Its prompt
  stays hidden until the room is clear and Cinderpaw is within `192` px.
- Enemy visuals remain `AnimatedSprite2D + SpriteFrames`, six animations with
  three transparent `96x96` frames each.

## Generation Records

- `assets/generated/source/underground_corrosion_channel_imagegen_20260711.md`
- `assets/generated/source/underground_corrosive_runoff_imagegen_20260711.md`
- `assets/generated/source/underground_seal_gate_imagegen_20260711.md`
- `assets/generated/source/underground_salvage_cache_imagegen_20260711.md`
