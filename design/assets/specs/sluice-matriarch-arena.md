# Asset Spec: Sluice Matriarch Arena

Date: 2026-07-11
Story: `production/epics/player-abilities/story-127-old-factory-tailrace-sluice-matriarch-arena-handoff.md`
Status: Implemented arena baseline

## Role

The Sluice Matriarch arena is the first dedicated destination after the Old
Factory Tailrace route. It must make the chapter handoff immediately visible,
establish Boss3 scale, and keep a clean side-scroller combat plane without
claiming that the boss itself is implemented.

## Visual Contract

| Field | Value |
|-------|-------|
| Runtime type | Opaque `Sprite2D` environment backdrop |
| Runtime canvas | `1280x720` RGB PNG |
| Source | Built-in image generation, retained at `1672x941` RGB |
| Camera framing | Full-screen 16:9, center `(640,360)`, scale `(1,1)` |
| Palette | Charcoal steel, steel blue, rust orange, cyan route light, restrained mutation green |
| Gameplay plane | Broad readable floor across the lower frame with open foreground space |
| Runtime scene | `scenes/bosses/sluice_matriarch_arena.tscn` |

## Composition

- The left side communicates the Factory return route with cool cyan light.
- The central and right background carry pressure machinery, pipes, runoff,
  and cracked containment architecture without obscuring the player lane.
- A dormant giant leech cocoon supplies Boss3 anticipation but is not an active
  character, hit target, or substitute for Story128 frame animation.
- Floor and wall collision are authored as invisible physics surfaces aligned
  to the painted environment. No visible ColorRect, Polygon2D, or plain block
  may stand in for finished arena art.

## Generation And Pipeline

The complete prompt and processing record is stored at
`assets/generated/source/sluice_matriarch_arena_backdrop_imagegen_20260711.md`.
The generated source was resized with `sips` to the fixed runtime canvas and
imported through Godot 4.7. The runtime texture lives at
`assets/environment/sluice_matriarch_arena/env_sluice_matriarch_arena_backdrop_1280x720.png`.

## Validation

- Source is opaque RGB `1672x941`; runtime is opaque RGB `1280x720`.
- The texture loads at the exact manifest path and fills the arena viewport.
- The screenshot is non-empty and shows Cinderpaw, readable floor, return
  route, industrial arena architecture, and dormant cocoon foreshadowing.
- Route prompt and player sprite remain fully inside the frame at desktop MCP
  screenshot size; no text is baked into the background.
- Godot MCP verifies the scene hierarchy, texture path, runtime visibility,
  clean current-run logs, and actual Factory/arena transition requests.
