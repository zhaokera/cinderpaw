# Asset Spec: Crown Warden Wall Climb Reward Payoff

> **Story**: 147
> **Generation policy**: built-in image generation, retained keyed source,
> deterministic alpha processing, Godot 4.7 import

## Runtime Contract

| Asset | Contract | Runtime path |
|-------|----------|--------------|
| Crown Core reward | Transparent sRGBA `256x256`; centered owl-crown and cat-eye magnetic core; readable at gameplay scale; no text, UI, environment, shadow or primitive placeholder | `res://assets/environment/crown_warden_reward/prop_crown_warden_wall_climb_core_256x256.png` |
| Retained generation record | Opaque `1254x1254` keyed source, full-size alpha intermediate and exact prompt/processing record | `res://assets/environment/crown_warden_reward/source/` |

## Visual Direction

The Crown Core combines Crown Warden's brass owl silhouette with a compact
cyan magnetic gyroscope and cat-eye gold lens. It reads as a rare victory
reward against the Crown Observatory while remaining mechanically distinct
from the Boss corpse, return gate and HUD.

## Processing And Import

- Generate one isolated object over uniform magenta and retain the exact
  prompt in `crown_warden_wall_climb_core_imagegen_20260713.md`.
- Sample key `#fa03eb`, apply a soft matte with thresholds `12/220` and
  despill, then retain the full-resolution sRGBA alpha intermediate.
- Trim, fit inside `224x224`, and center on a transparent `256x256` canvas.
- Import with nearest filtering. `WallClimbRewardSource` owns availability,
  contact, persistence and prompt state; the PNG is presentation only.
- MCP must show the generated core after Boss4 defeat and confirm a grounded
  Cinderpaw can claim it by normal movement.

## Source Files

- `crown_warden_wall_climb_core_imagegen_20260713.png`
- `crown_warden_wall_climb_core_alpha_20260713.png`
- `crown_warden_wall_climb_core_imagegen_20260713.md`
