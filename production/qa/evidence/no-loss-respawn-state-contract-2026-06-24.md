# No-Loss Respawn State Contract Evidence — 2026-06-24

## Scope

Validate Death & Respawn Story 006 against `TR-respawn-005`: death and respawn
must not remove currency, inventory, acquired/current weapon state, or world
progress flags. Health recovery must remain owned by `HealthComponent` via the
existing revive percentage.

## Automated Evidence

- TDD RED: `reports/report_312/` — `GameFlowController` lacked
  `set_no_loss_state_adapter()` and no-loss snapshot restore behavior.
- Story GREEN: `reports/report_313/` —
  `tests/unit/gameplay/no_loss_respawn_state_contract_test.gd` passed 2/2.
- Gameplay regression: `reports/report_314/` — 8/8 focused gameplay tests
  passed across:
  - `tests/unit/gameplay/game_flow_controller_test.gd`
  - `tests/unit/gameplay/no_loss_respawn_state_contract_test.gd`
  - `tests/unit/gameplay/simple_enemy_respawn_reset_test.gd`
- Startup: `godot --headless --path . --quit-after 1` exited 0.

## Godot MCP Runtime Evidence

- MCP server: Godot AI 3.4.2 over `http://127.0.0.1:8000/mcp`.
- Runtime project session: `cinderpaw@c4d7`, Godot `4.6.3-stable`.
- Scene: `res://scenes/main.tscn`.
- Runtime `game_eval` flow:
  - Established protected state: `currency=42`, inventory `rust_key` and
    `sun_lens`, Long Tail acquired/current weapon, and world flags
    `gate_a_open=true`, `rat_king_seen=true`.
  - Killed the player and confirmed GameFlow entered `dying`.
  - Corrupted protected state during the death window to simulate a bad
    save/economy/world-progress mutation.
  - Advanced the respawn timer and confirmed GameFlow entered `revived`.
  - Returned protected state equal to the pre-death snapshot.
  - Returned player HP `50/100`, proving health remains restored by the existing
    revive percentage rather than by the no-loss adapter.
- Game logs contained only the MCP game helper registration line and no runtime
  errors.
- Visual screenshot:
  `reports/visual/cinderpaw-mcp-no-loss-respawn-state-20260624.png`.

## Dependency Note

The full SaveSystem is still pending. This story implements the runtime no-loss
adapter contract and a SaveSystem-compatible snapshot shape. Future SaveSystem
work should provide the same `capture_no_loss_state()` /
`restore_no_loss_state(snapshot)` boundary instead of changing GameFlow rules.

## Result

PASS. Death and respawn now preserve protected progression state in the current
vertical slice, while HealthComponent continues to own HP restoration.
