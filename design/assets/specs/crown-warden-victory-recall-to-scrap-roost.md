# Asset Spec: Crown Warden Victory Recall To Scrap Roost

> **Story**: 148
> **Generation policy**: built-in image generation, retained keyed source,
> deterministic alpha processing, Godot 4.7 import

## Runtime Contract

| Asset | Contract | Runtime path |
|-------|----------|--------------|
| Victory recall transmitter | Transparent sRGBA `256x384`; narrow owl-crown transmitter with brass/steel shell, cyan transmission rings and cat-eye gold lens; readable at gameplay scale; no text, UI, ground, shadow or primitive placeholder | `res://assets/environment/crown_warden_victory_recall/prop_crown_warden_victory_recall_256x384.png` |
| Retained generation record | Opaque keyed `1024x1536` source, full-size alpha intermediate and exact prompt/processing record | `res://assets/environment/crown_warden_victory_recall/source/` |

## Visual Direction

The transmitter carries Crown Warden's owl-crown identity but uses a tall
homeward-signal silhouette rather than the compact Crown Core reward. Cyan rings
communicate a route transition; the single gold cat eye communicates Clan
ownership. The generated image is presentation only. `RouteTransitionShell`
owns range, availability, prompt and transition behavior.

## Processing And Import

- Generate one isolated device over uniform magenta; retain exact source and
  prompt in the asset-local `source/` directory.
- Sample border key `#f903ec`, soft-matte with thresholds `12/220`, despill and
  retain the full-size alpha intermediate.
- Trim and nearest-neighbor fit inside `224x344`, centered on an exact
  transparent `256x384` canvas.
- Import with nearest filtering. The authored route remains hidden until Boss4
  defeat plus Crown Core claim.
- MCP must show the generated transmitter at the right arena exit, a visible
  Cinderpaw in interaction range and the completed `main / scrap_roost` runtime
  handoff without block-color placeholders.

## Character Animation Impact

No character or character gameplay state is added. Existing Cinderpaw and
Crown Warden remain validated `AnimatedSprite2D + SpriteFrames` actors.
