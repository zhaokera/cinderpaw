# QA Evidence: Old Factory Aftershock Condenser Outlet Clamp Production Combat Drip Vent Handoff

**Story**: Player Abilities Story217

**Date**: 2026-07-22

**Status**: Accepted

**Engine / MCP**: Godot 4.7 / Godot AI MCP 3.0.4

## Scope

Verify Story097 production movement and light-attack combat, preserve entity
`2138` live death presentation, and require a later fresh movement frame before
Story098 begins. Story098 traversal, balance and assets remain unchanged.

## TDD Evidence

- `reports/report_2317/results.xml`: strengthened canonical RED, `1` case with
  `1` expected failure. Held `move_right` and positive x movement on the lethal
  frame incorrectly started Story098.
- `reports/report_2318/results.xml`: focused GREEN, `1/1`.
- `reports/report_2319/results.xml`: bounded related GREEN, `6/6` across
  Story216, Story097, Story098 and Story217; zero
  failure/error/flaky/skip/orphan.
- Full suite was intentionally not run.

## Smoke Evidence

`reports/old_factory_aftershock_condenser_outlet_clamp_production_combat_drip_vent_handoff_smoke.log`
completed `180` fixed-FPS frames and exited `0`. No project parse/script,
invalid-call/access, missing-resource or resource-load error was found.

## MCP Runtime Evidence

Accepted input/combat run: `cinderpaw@1b14` / `r155047659-13`.

- No-input placement at x `5224.0` kept Story097 idle and entity `2138`
  hidden/inert. Real `move_right` moved x `5208.0 -> 5220.2222` and activated
  the ambush with `24 HP`, target/process/physics enabled, hurtbox normal,
  `idle` animation and `18` opening-grace frames.
- A deterministic nonlethal setup reduced HP to `12`; the lethal hit used real
  `Input.attack`, `cat_claw_light`, target `2138` and applied `12` damage.
- Immediate defeat state was cleared with animation `death`, visible/process
  true, physics/target false, body layer/mask `0`, hurtbox `gone` and bite
  hitbox inactive.
- With `move_right` still held and player x advanced beyond `5840.0`, Story098
  remained available/visible in `idle`, inactive and non-contacting on the
  killing frame and stationary follow-up. A later fresh movement x
  `5848.0 -> 5852.0` started `grace` with contact still disabled.
- Game log contained only helper registration; editor log was empty. All
  gameplay inputs were released and the project stopped at editor `ready`.

Visual capture run `r155315013-14` reproduced the cleared handoff, allowed the
existing death animation to reach frame `2` naturally, and captured it while
paused before corpse fade. Its game log was helper-only and editor log empty.

## Visual Evidence

Non-empty RGB PNG, `1278x718`, SHA-256
`bf2dad7de8b612b74b1a5e91d3d351cb864310f2f8f7373a55fd789d10613530`:

`reports/visual/cinderpaw-mcp-aftershock-condenser-outlet-clamp-death-handoff-20260722.png`

The gameplay framebuffer shows Cinderpaw, the fallen Spark Rat, generated drain
gantry, idle vent and `Outlet Clamp Ambush Cleared` route feedback together.

## Asset Review

No image generation was needed. Existing character and environment assets are
valid and reused. Read-only art review recorded two pre-existing follow-ups:
Spark Rat's 12-frame startup is shorter than its 3-frame/10 FPS tell, and its z
layer can pass behind the clamp. They do not change this Story's combat/handoff
logic and should be handled by a dedicated readability slice.
