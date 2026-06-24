# Asset Manifest

> Last Updated: 2026-06-24

This manifest records generated visual assets that have entered the Godot asset
pipeline. Source prompts are summarized for traceability; final runtime files
are the transparent PNGs referenced by scenes or scripts.

| Asset ID | Runtime Path | Source | Prompt Summary | Import Status | Used By |
|----------|--------------|--------|----------------|---------------|---------|
| combat_hit_spark | `res://assets/generated/combat_hit_spark.png` | image generation | Pixel-art white slash burst with cat-eye gold core, sharp triangular shards, chroma-key background removed to alpha. | Imported | `src/presentation/combat_presentation.gd` |
| combat_enemy_debris | `res://assets/generated/combat_enemy_debris.png` | image generation | Pixel-art enemy death debris burst with dark red fragments, black shadow splinters, signal-red accents, chroma-key background removed to alpha. | Imported | `src/presentation/combat_presentation.gd` |
| combat_parry_spark | `res://assets/generated/combat_parry_spark.png` | image generation | Pixel-art PERFECT parry radial burst with white blade shards, cat-eye gold core, and signal-red flecks; chroma-key background removed to alpha. | Imported | `src/presentation/combat_presentation.gd` |
| combat_claw_trail | `res://assets/generated/combat_claw_trail.png` | image generation | Pixel-art cat claw attack trail with three amber/gold-white curved slash arcs; chroma-key background removed to alpha. | Imported | `src/presentation/combat_presentation.gd` |
| cinderpaw_player_sprite_frames | `res://assets/characters/cinderpaw/cinderpaw_sprite_frames.tres` | image generation | Pixel-art Cinderpaw animation frames for idle, run, claw attack, and dodge; chroma-key background removed to alpha and sliced into 96x96 transparent PNG frames. | Imported | `scenes/characters/cinderpaw.tscn`; `scenes/player.tscn` |
| cinderpaw_dodge_frames | `res://assets/characters/cinderpaw/dodge/cinderpaw_dodge_000.png` through `_002.png` | image generation | Pixel-art Cinderpaw dodge strip with crouch, dash, and recovery poses; generated source strip kept under `assets/characters/cinderpaw/source/`, chroma-key background removed to alpha, exported as three 96x96 transparent frames. | Imported | `assets/characters/cinderpaw/cinderpaw_sprite_frames.tres`; `src/gameplay/player_controller.gd`; `src/presentation/combat_presentation.gd` |
