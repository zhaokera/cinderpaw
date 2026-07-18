# Asset Spec: Scrap Roost Rat King Approach Background

> **Story**: Scene Management 018
> **Generation policy**: built-in image generation, retained source and exact
> prompt, deterministic resize, Godot 4.7 import

## Runtime Contract

| Asset | Contract | Runtime path |
|-------|----------|--------------|
| Scrap Roost Rat King approach background | Opaque RGB `1280x720`; safe left entry, clear lower gameplay corridor, threatening circular gate on the right, layered junk settlement, torn cat-clan banner and distant mechanical-rat silhouette; no baked playable character, foreground enemy, UI, text, collision guide or gate-state effect | `res://assets/environment/scrap_roost_rat_king_approach/scrap_roost_rat_king_approach_background_1280x720.png` |

The production Cinderpaw, Shadow Beast, red gate seal, collision, HUD and combat
effects remain separate runtime nodes. The environment plate establishes place
and threat without becoming gameplay state.

## Visual Direction

The approach should read as the exterior threshold of Rat King territory rather
than another tutorial room. Cold cyan dawn and distant landfill silhouettes
hold the left half open; oxidized steel, amber lamps and restrained red warnings
concentrate threat around the right gate. The mechanical-rat profile and torn
banner carry environmental storytelling above the play lane while the lower
third stays legible for two animated combatants.

## Processing And Import

- Retain the generated `1672x941` opaque RGB source and exact prompt under
  `assets/environment/scrap_roost_rat_king_approach/source/`.
- Resize to exact opaque RGB `1280x720`; do not add alpha, actors, labels, UI,
  foreground enemies, collision guides or runtime gate effects.
- This full-screen plate follows the established authored-background pipeline
  and is an explicit exception to the older generic `256x256` background budget.
- Godot nodes own ground, walls, activation, enemy AI, attack collision, gate
  state, player, HUD and CombatPresentation. The background is presentation only.
- Godot MCP acceptance must confirm the imported plate is visible, Cinderpaw
  and Shadow Beast remain separate `AnimatedSprite2D` nodes, the red tell and
  gate state are readable, screenshots are non-empty and HUD does not obscure
  the traversal lane.
