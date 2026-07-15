# Cinderpaw Grounded Heavy Charge Runtime Evidence - 2026-07-14

## Scope

- Story: `production/epics/feline-combat/story-010-grounded-heavy-charge-runtime.md`
- Input: hold and release `heavy_attack` while grounded.
- Runtime path: `PlayerController -> CombatComponent -> WeaponComponent ->`
  `CollisionComponent -> DamageCalculator`, with HUD, VFX, audio, and camera
  feedback routed by `MainScene` signals.

## Asset Pipeline

- Tool: built-in image generation using the existing Cinderpaw sprite sheet as
  identity and style reference.
- Prompt and processing record:
  `assets/characters/cinderpaw/source/cinderpaw_heavy_charge_attack_sheet_imagegen_20260714.md`.
- Generated source:
  `assets/characters/cinderpaw/source/cinderpaw_heavy_charge_attack_sheet_imagegen_20260714.png`.
- Alpha intermediate:
  `assets/characters/cinderpaw/source/cinderpaw_heavy_charge_attack_sheet_alpha_20260714.png`.
- Runtime frames: three transparent `96x96` PNGs under each of
  `assets/characters/cinderpaw/heavy_charge/` and
  `assets/characters/cinderpaw/heavy_attack/`.
- Godot 4.7 import completed with `godot --headless --path . --import`, exit `0`.
- Manifest entry: `cinderpaw_heavy_charge_attack_frames` in
  `design/assets/asset-manifest.md`.

## TDD Evidence

- RED: `reports/report_1572/report_1/results.xml`
  - Result: expected failure, `1` failure at the missing Player/HUD runtime
    heavy contract.
- GREEN: `reports/report_1575/report_1/results.xml`
  - Result: `4/4` Story010 cases passed, exit `0`.
- Final focused recheck: `reports/report_1577/report_1/results.xml`
  - Result: `26/26` Story010 and HUD cases passed, exit `0`.

## Related Regression

- Report: `reports/report_1576/report_1/results.xml`.
- Result: `42/42` passed across Core heavy charge, Fish Bone shield break,
  damage modifiers, existing player attack integration, and HUD behavior.
- Full suite was not run because this slice used the project risk-layered
  verification policy.

## MCP Runtime Evidence

- Session: `cinderpaw@d40a`.
- Godot: `4.7-stable (official)`.
- Godot AI plugin/server: `2.9.2` / `2.9.2`.
- Main project launch: helper live, no startup errors.
- Mid-charge probe:
  - `heavy_charge` active at `1.0s` / `66.67%`.
  - HUD visible with `HEAVY 67%  1.0s`.
  - `heavy_charge` and `heavy_attack` each report `3` frames.
- Release probe:
  - animation `heavy_attack`, hitbox `cat_claw_heavy` active.
  - retained metadata reports `charge_seconds=1.0`,
    `charge_ratio=0.6666667`, `charge_multiplier=1.6`, and
    `hitbox_size_multiplier=1.25`.
  - HUD hidden and screen shake reports `4` frames.
- Final logs after clearing probe noise and relaunching:
  - editor: `0` lines.
  - game: `3` informational startup lines, helper live, no warnings or errors.
- Screenshots:
  - `production/qa/evidence/cinderpaw-grounded-heavy-charge-mcp-2026-07-14.png`
  - `production/qa/evidence/cinderpaw-grounded-heavy-release-mcp-2026-07-14.png`

## Acceptance Result

PASS. The live player can charge, cancel, release, deal continuously scaled
heavy damage, and enter existing presentation/audio routing with generated
multi-frame character animation and clean Godot MCP runtime validation.
