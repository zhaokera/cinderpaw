# Central Tower Deep Lift Props Prompt

- Tool: OpenAI built-in image generation (`image2`)
- Date: 2026-07-12
- Use: Story143 moving platform, machinery, gates, endpoint, and warning VFX
- Source size: `1536x1024`
- Key color: detected border `#f902f6` from requested `#FF00FF`
- Alpha source: `central_tower_deep_lift_props_alpha_20260712.png`

Generate exactly one strict 3-column by 2-row keyed asset sheet on one perfectly
uniform flat `#FF00FF` background. Exactly six isolated assets, one per equal
cell, row-major: wide moving Deep Lift platform; tall guided counterweight
carriage; tall entry interlock shutter; empty Counterweight Sentry deployment
cradle; narrow Deep Lift brake console; thin horizontal lock-stop warning sweep.
Match Central Tower steel-blue industrial-fantasy game art with cyan mechanics
and restrained amber safety accents; signal red only in asset six. Keep every
silhouette inside a 12% cell safety margin. Exclude overlap, duplicates,
characters, floor, scenery, cast shadows, labels, text, UI, grid lines, magenta
inside subjects, translucent rectangular haze, and cropped extremities.

## Processing

The installed imagegen chroma helper used border auto-key, soft matte, despill,
and one-pixel edge contraction. It produced `1,135,268` fully transparent and
`16,885` partially transparent pixels. Because the generated silhouettes use
the complete visual cells rather than strict mathematical cell bounds, each of
the six isolated assets was cropped from its measured non-overlapping source
region, then trimmed, fitted without aspect distortion, and centered on its
exact transparent runtime canvas.
