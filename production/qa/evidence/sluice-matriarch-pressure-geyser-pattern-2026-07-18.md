# QA Evidence: Sluice Matriarch Pressure Geyser Pattern -- 2026-07-18

## Scope

Story173 extends the existing Boss3 fight with a deterministic alternating
pressure-geyser pattern, generated three-frame boss animations, generated
warning/active VFX, an independent damage hitbox, and a shared recovery pose.
Existing Boss3 health, lunge, phase threshold, reward, route, and persistence
behavior remain unchanged.

## Automated Evidence

- Intentional RED: `reports/report_1922/results.xml` ran the new Story173 test
  and failed `1/1` on the missing geyser `SpriteFrames` contract, with `0`
  errors, skipped, or flaky tests.
- Focused GREEN: `reports/report_1924/results.xml` passed `1/1`, with `0`
  failures, errors, skipped, or flaky tests.
- Final pre-commit focused gate after correcting the MCP-reported shadowed
  parameter warning: `reports/report_1928/results.xml` passed `1/1`, with `0`
  errors, failures, skipped, flaky tests, or engine orphans under Godot 4.7.
- Final bounded regression: `reports/report_1927/results.xml` passed `12/12`,
  with `0` failures, errors, skipped, flaky tests, or engine orphans. It covered
  Story173, playable Boss3 core, aerial-attack reward payoff, and real
  hitstop/input-buffer behavior.
- The related audio fixture now releases both `AudioStreamPlayer` and
  `AudioStreamPlayer2D` streams, removing the prior test-process resource leak
  without changing gameplay audio behavior.

## Asset Generation And Import

- Boss animation source and prompt:
  `assets/characters/sluice_matriarch/source/sluice_matriarch_geyser_recovery_sheet_imagegen_20260718.md`.
- Pressure-geyser VFX source and prompt:
  `assets/environment/sluice_matriarch_arena/pressure_geyser/source/pressure_geyser_sheet_imagegen_20260718.md`.
- Boss runtime animations `geyser_tell`, `geyser_attack`, and
  `attack_recovery` each contain three continuous transparent `192x192` PNG
  frames in the character asset hierarchy.
- VFX runtime animations `warning` and `active` each contain three continuous
  transparent `192x192` PNG frames and are mounted on an independent
  `AnimatedSprite2D`.
- Godot 4.7 headless import completed with exit code `0`; source, alpha,
  previews, runtime frames, and `SpriteFrames` dependencies were imported.

## Godot MCP Runtime Evidence

- Session: `cinderpaw@af5f`; Godot `4.7-stable`; Godot AI MCP `3.0.2`.
- Authored and runtime scene inspection found
  `SluiceMatriarchBoss/PressureGeyser` as an `AnimatedSprite2D`, plus both
  `sluice_matriarch_pressure_lunge` and
  `sluice_matriarch_pressure_geyser` collision areas.
- Natural scheduler history on run token `71` reported
  `pressure_lunge -> pressure_geyser -> pressure_lunge -> pressure_geyser`,
  with `pressure_lunge` selected next.
- Runtime resource inspection reported three frames each for boss
  `geyser_tell`, `geyser_attack`, and `attack_recovery`, and three frames each
  for VFX `warning` and `active`.
- Deterministic run token `72` startup reported `24/10/24`, damage `14`, target
  x `520`, visible `warning`, animation `geyser_tell`, and hitbox inactive.
- After advancing `24` frames, runtime reported animation `geyser_attack`, VFX
  `active`, and the independent geyser hitbox active. After `10` more frames,
  runtime reported `attack_recovery`, hidden VFX, and hitbox inactive.
- Final run token `72` launched live with `current_run_errors=[]`. The game log
  contained only the MCP helper registration line, and the editor log contained
  `0` rows after the shadowed-parameter warning was corrected and reloaded.
- Runtime screenshot:
  `reports/visual/cinderpaw-mcp-sluice-matriarch-pressure-geyser-pattern-20260718.png`.
  It is a non-empty `1278x718` RGB PNG that visibly shows the active pressure
  geyser, generated boss attack frame, player, HUD, and arena without overlap.
  SHA-256:
  `257ea087f135f970cee410ab83b78213a20fa6fcda4e66beeed763d510e8541a`.

## Acceptance Mapping

| Acceptance | Evidence | Result |
|------------|----------|--------|
| Alternating lunge/geyser scheduler | Story173 test; MCP natural history | PASS |
| Phase I/II timing, warning safety, active damage | Story173 test; MCP state probes | PASS |
| Three-frame boss and VFX animation contracts | Asset records; GdUnit; MCP resource probe | PASS |
| Recovery and reset/defeat cleanup | Story173 test; MCP recovery probe | PASS |
| Existing Boss3 behavior preserved | Final 12-test related regression | PASS |
| Godot 4.7 / MCP 3.0.2 clean visible runtime | Final run token 72, logs, screenshot | PASS |
