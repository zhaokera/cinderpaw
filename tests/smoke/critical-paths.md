# Smoke Test: Critical Paths

**Purpose**: Run these 10-15 checks in under 15 minutes before any QA hand-off.
**Run via**: `/smoke-check` (which reads this file)
**Update**: Add new entries when new core systems are implemented.

## Core Stability (always run)

1. Game launches to main menu without crash
2. New game / session can be started from the main menu
3. Main menu responds to all inputs without freezing

## Core Mechanic (update per sprint)

4. New Game enters Scrap Roost Hunt Initiation before any Boss; real movement
   and jump input cross the safe runway and raised step while the camera remains
   bounded to the room
   (`tests/unit/gameplay/new_game_onboarding_slice_test.gd`)
5. The first ordinary Rat Minion activates after the runway, takes real shared
   attack damage, plays its death state, unlocks the exit and hands off through
   SceneManager to the registered Scrap Roost dodge trial
   (`tests/unit/gameplay/new_game_onboarding_slice_test.gd`)
6. The third onboarding room cycles a four-frame exhaust through safe, warning
   and active phases; a real active-phase dodge overlap preserves player HP,
   unlocks the exit and hands off to the registered Rat King approach
   (`tests/unit/gameplay/new_game_dodge_trial_test.gd`;
   `production/qa/evidence/scrap-roost-dodge-trial-2026-07-19.md`)
7. The first post-onboarding encounter activates one six-state frame-animated
   Shadow Beast; real shared attack damage defeats it, opens the Rat King gate
   and commits `main/scrap_roost` beside the existing savepoint
   (`tests/unit/gameplay/scrap_roost_rat_king_approach_test.gd`;
   `production/qa/evidence/scrap-roost-rat-king-approach-2026-07-19.md`)
8. Old Factory service sluice tailrace requires real positive-x movement,
   cycles its four-frame steam through physical active-only damage, crosses
   once, then uses production movement and `Input.attack` to clear the
   frame-animated Coil Rat while leaving the relay visible and unactivated
   (`tests/smoke/old_factory_service_sluice_tailrace_production_hazard_traverse_ambush_handoff_smoke.gd`;
   `tests/smoke/old_factory_service_sluice_tailrace_ambush_smoke.gd`)
9. Old Factory service sluice tailrace relay requires real `move_right`
   contact after the tailrace ambush, records one savepoint/VFX, removes its
   prompt, enters real player death and revives at 50% HP while the revealed
   runoff stays idle without fresh positive-x input
   (`tests/smoke/old_factory_service_sluice_tailrace_relay_smoke.gd`)
10. Old Factory service sluice tailrace relay runoff requires fresh real
   `move_right`, runs four-frame steam phases, applies exact physical `8`
   damage, guards stationary crossing, and leaves Story121 inactive for 180
   frames
   (`tests/smoke/old_factory_service_sluice_tailrace_relay_runoff_smoke.gd`)
11. Old Factory service sluice tailrace relay runoff pincer requires fresh real
    movement, routes two real light attacks through the Spark/Coil Hurtboxes,
    preserves both three-frame live deaths, and leaves Story122 unclaimed for
    180 frames
    (`tests/smoke/old_factory_service_sluice_tailrace_relay_runoff_pincer_smoke.gd`)
12. Old Factory service sluice tailrace relay runoff pincer reward cache appears
    only after the pincer is cleared, claims once for `+20 Gears`, and persists
    claimed state
    (`tests/smoke/old_factory_service_sluice_tailrace_relay_runoff_pincer_reward_cache_smoke.gd`)
13. Old Factory service sluice tailrace relay runoff pincer exit hatch appears
    after the pincer reward cache is claimed, opens once, clears collision, and
    persists opened state
    (`tests/smoke/old_factory_service_sluice_tailrace_relay_runoff_pincer_exit_hatch_smoke.gd`)
14. Old Factory service sluice tailrace relay runoff pincer exit spillway
    activates after the exit hatch opens, uses active-only steam contact,
    crosses the short spillway pocket, and persists crossed state
    (`tests/smoke/old_factory_service_sluice_tailrace_relay_runoff_pincer_exit_spillway_smoke.gd`)
15. Old Factory tailrace exit Sluice Leech appears only after the spillway is
    crossed, telegraphs for 18 frames, lunges through the shared hitbox path,
    and persists its cleared state
    (`tests/smoke/old_factory_tailrace_exit_spillway_sluice_leech_skirmish_smoke.gd`)
16. Old Factory Sluice Leech clear unlocks the Matriarch route, SceneManager
    enters the authored Boss3 arena at `boss_entry`, and the return route
    restores Factory at `tailrace_matriarch_gate_return` without losing the
    leech clear or carrying a stale transition latch
    (`tests/smoke/old_factory_tailrace_sluice_matriarch_arena_handoff_smoke.gd`)
17. Sluice Matriarch starts with Boss HUD and room seals active, telegraphs and
    lands the pressure lunge through the shared hitbox chain, enters phase two,
    and opens the persistent return route on defeat
    (`tests/smoke/sluice_matriarch_playable_boss3_core_smoke.gd`)
18. Boss3 defeat reveals and persists the `aerial_attack` reward; airborne
    attack input drives the three-frame downward strike, lands shared damage,
    grants eight cat energy, bounces, and restores one air-jump use
    (`tests/smoke/sluice_matriarch_aerial_attack_reward_payoff_smoke.gd`)
19. The Factory tailrace floor unlocks only from a nearby real aerial attack,
    persists open, swaps into the authored Underground Passage, and returns to
    the exact Factory breach marker with `aerial_attack` intact
    (`tests/smoke/factory_aerial_breach_underground_passage_handoff_smoke.gd`)
20. The Underground corrosion channel crosses a generated runoff hazard, closes
    both generated seals around two frame-animated Sluice Leeches, accepts a
    real Core attack, opens on dual defeat, claims one salvage reward, and
    restores the claimed state after Factory return and Underground re-entry
    (`tests/smoke/underground_corrosion_channel_skirmish_smoke.gd`)
21. The Underground recovery cistern activates a generated savepoint, restores
    full HP and autosaves once, revives a lethal fall at 50% HP, secures the
    far-side endpoint, and preserves relay/route state through Factory return
    and Underground re-entry
    (`tests/smoke/underground_recovery_cistern_savepoint_traverse_smoke.gd`)
22. The Neon Signal Roof unlocks from Story136 traversal, closes both generated
    seals around a frame-animated Signal Rat, accepts real shared attack damage,
    opens on defeat, grants one `+20 Gears` signal cache, and restores clear and
    claimed state without replaying feedback
    (`tests/smoke/neon_rooftops_signal_rat_ambush_smoke.gd`)
23. The Neon Relay Spire route opens only after the signal cache claim,
    activates and autosaves the generated roost once, revives a lethal fall at
    50% HP, uses real wall-climb input to cross the magnetic spire, persists the
    Tower Approach endpoint, and restores all rooftop state without replay
    (`tests/smoke/neon_rooftops_relay_spire_savepoint_traverse_smoke.gd`)
24. The Central Tower outer laser trial opens only after Story138 traversal,
    routes a missed pulse through player damage and roost revive, accepts three
    real strike-window parries, opens the generated ExplorationGate once,
    secures the threshold, and restores state without replay
    (`tests/smoke/neon_rooftops_central_tower_parry_laser_trial_smoke.gd`)
25. The secured Rooftops threshold enters the generated Central Tower vestibule,
    uses the real SceneManager for exact entry and return spawns, activates a real
    Threshold Roost, closes both seals around the frame-animated guard, routes its
    14-damage latch thrust through shared collision, opens both seals on entity
    `2701` defeat, retains durable clear/ability/return state, and reuses the same
    cleared Tower runtime instance during a cache-window second round trip
    (`tests/smoke/central_tower_threshold_guard_handoff_smoke.gd`)

## Data Integrity

26. Save game completes without error (once save system is implemented)
27. Load game restores correct state (once load system is implemented)

## Performance

28. No visible frame rate drops on target hardware (60fps target)
29. No memory growth over 5 minutes of play (once core loop is implemented)
