# Neon Tower Parry Trial Props Generation Record

- Date: 2026-07-12
- Generator: built-in image generation
- Use case: stylized-concept
- Key color sampled by removal helper: `#f803f6`
- Source: `neon_tower_parry_trial_props_imagegen_20260712.png`
- Source dimensions: opaque RGB `1774x887`
- Alpha source: `neon_tower_parry_trial_props_alpha_20260712.png`
- Alpha result: `1,204,023 / 1,573,538` fully transparent pixels and `84,122`
  partially transparent edge pixels

## Prompt

Create exactly three isolated high-detail pixel-art game assets left-to-right
on one perfectly uniform `#ff00ff` chroma-key background: a tall side-view
Central Tower laser-net gate with cat-ear steel pylons, cyan status lamps,
restrained warning cores, amber service lights, bolts and cables; one long
horizontal parryable signal-red laser pulse with a white core and cyan electric
edge accents; and one compact threshold beacon with a cat-paw emblem, cyan
unlocked indicator, amber rim lights and rooftop base. Keep the objects fully
separated inside equal thirds with generous padding. Use no key color in the
objects, floor, shadow, reflection, haze, characters, labels, text, UI, logo,
watermark, extra prop, duplicate, or cropped edge.

## Alpha Processing

```bash
python3 ~/.codex/skills/.system/imagegen/scripts/remove_chroma_key.py \
  --input neon_tower_parry_trial_props_imagegen_20260712.png \
  --out neon_tower_parry_trial_props_alpha_20260712.png \
  --auto-key border --soft-matte --transparent-threshold 12 \
  --opaque-threshold 220 --despill --edge-contract 1 \
  --edge-feather 0.25 --force
```

## Runtime Derivatives

| Asset | Crop / normalization | Runtime path |
|-------|----------------------|--------------|
| Laser gate | crop `670x887+0+0`, trim `575x715`, fit within `352x464`, center on RGBA `384x512` | `res://assets/environment/neon_rooftops/prop_neon_tower_laser_gate_384x512.png` |
| Laser pulse | crop `630x887+650+0`, trim `602x123`, fit within `480x98`, center on RGBA `512x128` | `res://assets/environment/neon_rooftops/vfx_neon_tower_laser_pulse_512x128.png` |
| Threshold beacon | crop `494x887+1280+0`, trim `415x572`, fit within `224x344`, center on RGBA `256x384` | `res://assets/environment/neon_rooftops/prop_neon_tower_threshold_beacon_256x384.png` |

All three derivatives retain transparent corners, partially transparent edge
pixels, opaque subject cores, continuous laser details, and no visible key-color
background.
