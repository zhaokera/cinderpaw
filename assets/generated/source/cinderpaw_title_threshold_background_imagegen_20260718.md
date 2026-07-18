# Cinderpaw Title Threshold Background Image Generation Record

- Date: 2026-07-18
- Tool: built-in image generation, precise-object-edit
- Edit reference: prior in-session generated title draft; the superseded draft
  was not shipped after the actor-free environment source passed acceptance.
- Retained source: `cinderpaw_title_threshold_background_imagegen_20260718.png`
- Runtime texture: `assets/ui/title/cinderpaw_title_threshold_background_1280x720.png`
- Source SHA-256: `8ff629975e63b40ed6de77a7e9e70a25e77410dd473320da449819cb72060191`
- Runtime SHA-256: `ccab35298e31c70cc38a2066ea81d1c380455cda1d2400dadd52ab7b928da595`

## Exact Prompt

Use case: precise-object-edit.

Asset type: 1280x720 Godot title-screen background plate for a side-scrolling
action game.

Primary request: Remove the standing anthropomorphic cat hero completely from
the image and reconstruct the obscured industrial ruins, pipes, distant towers,
platform edge, and floor behind him. Preserve the exact camera, perspective,
framing, painterly hand-painted action-game style, lighting, texture detail, and
cold teal-left / warm amber-right color relationship of the source.

Composition constraints: Keep the left 42% dark and low-detail enough for title
text and menu readability. Keep a clear visual threshold between cold darkness
on the left and warm firelight toward the middle-right. Leave the right
foreground platform visually usable as an empty stage for a separately animated
seated character sprite. No new character, silhouette, creature, text, logo,
UI, border, watermark, or poster typography.

Output: one clean environment-only landscape image, 16:9, full bleed.

## Processing

- The built-in edit returned opaque RGB `1672x941`.
- ImageMagick used aspect-cover resize and center extent to exact opaque RGB
  `1280x720`; no actor, UI or text is baked into the runtime plate.
- Godot 4.7 imported both retained source and runtime texture.
