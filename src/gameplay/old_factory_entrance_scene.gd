## Runtime wiring for the first Old Factory entrance combat room.
class_name OldFactoryEntranceScene
extends Node2D

const FACTORY_SCENE_ID: StringName = &"area_03_factory"
const FACTORY_MUSIC_ID: StringName = &"mus_factory"
const FACTORY_AMBIENT_ID: StringName = &"amb_factory"
const FACTORY_AUDIO_FADE_SEC: float = 3.0
const FACTORY_PLAYER_LIGHT_DAMAGE: int = 12
const FACTORY_STEAM_DAMAGE_FALLBACK: int = 8
const FACTORY_STEAM_CONTACT_COOLDOWN_FALLBACK_SEC: float = 1.0
const FACTORY_ENTRY_GUARD_ENTITY_ID: int = 2100
const FACTORY_DEEP_GUARD_ENTITY_ID: int = 2101
const FACTORY_SPARK_RAT_ENTITY_ID: int = 2102
const FACTORY_RETURN_SPARK_RAT_ENTITY_ID: int = 2103
const FACTORY_CHECKPOINT_FORWARD_SPARK_RAT_ENTITY_ID: int = 2104
const FACTORY_CHECKPOINT_REAR_SPARK_RAT_ENTITY_ID: int = 2105
const FACTORY_CHECKPOINT_OVERDRIVE_LEFT_SPARK_RAT_ENTITY_ID: int = 2106
const FACTORY_CHECKPOINT_OVERDRIVE_RIGHT_SPARK_RAT_ENTITY_ID: int = 2107
const FACTORY_LOWER_DECK_SPARK_RAT_ENTITY_ID: int = 2108
const FACTORY_LOWER_DECK_EXIT_SPARK_RAT_ENTITY_ID: int = 2109
const FACTORY_LOWER_DECK_SHORTCUT_SPARK_RAT_ENTITY_ID: int = 2110
const FACTORY_LOWER_DECK_SHORTCUT_PURSUER_ENTITY_ID: int = 2111
const FACTORY_LOWER_DECK_PRESSURE_GUARD_ENTITY_ID: int = 2112
const FACTORY_LOWER_DECK_STEAM_SLUICE_ENTITY_ID: int = 2113
const FACTORY_LOWER_DECK_DEEP_BULKHEAD_ENTITY_ID: int = 2114
const FACTORY_LOWER_DECK_BREACH_FRONT_ENTITY_ID: int = 2115
const FACTORY_LOWER_DECK_BREACH_REAR_ENTITY_ID: int = 2116
const FACTORY_LOWER_DECK_POST_RELAY_ENTITY_ID: int = 2117
const FACTORY_LOWER_DECK_FORWARD_CONDUIT_ENTITY_ID: int = 2118
const FACTORY_LOWER_DECK_FORWARD_COUNTER_AMBUSH_ENTITY_ID: int = 2119
const FACTORY_LOWER_DECK_FORWARD_EXIT_GUARD_ENTITY_ID: int = 2120
const FACTORY_LOWER_DECK_FORWARD_BEACON_AMBUSH_ENTITY_ID: int = 2121
const FACTORY_LOWER_DECK_FORWARD_OVERRUN_ENTITY_ID: int = 2122
const FACTORY_LOWER_DECK_FORWARD_BREAKER_ENTITY_ID: int = 2123
const FACTORY_LOWER_DECK_FORWARD_RELIEF_AMBUSH_ENTITY_ID: int = 2124
const FACTORY_LOWER_DECK_FORWARD_COIL_RAT_ENTITY_ID: int = 2125
const FACTORY_LOWER_DECK_FORWARD_COIL_PINCER_SPARK_RAT_ENTITY_ID: int = 2126
const FACTORY_LOWER_DECK_FORWARD_COIL_PINCER_COIL_RAT_ENTITY_ID: int = 2127
const FACTORY_LOWER_DECK_FORWARD_COIL_AFTERSHOCK_COIL_RAT_ENTITY_ID: int = 2128
const FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_EXIT_SPARK_RAT_ENTITY_ID: int = 2129
const FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_EXIT_COIL_RAT_ENTITY_ID: int = 2130
const FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_EXHAUST_PURSUER_ENTITY_ID: int = 2131
const FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_EXHAUST_FLANK_ENTITY_ID: int = 2132
const FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_EXHAUST_BREAKER_ENTITY_ID: int = 2133
const FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_EXHAUST_ESCAPE_SPARK_ENTITY_ID: int = 2134
const FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_EXHAUST_ESCAPE_COIL_ENTITY_ID: int = 2135
const FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_CONDENSER_SPARK_ENTITY_ID: int = 2136
const FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_CONDENSER_COIL_ENTITY_ID: int = 2137
const FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_CONDENSER_CLAMP_SPARK_ENTITY_ID: int = 2138
const FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_CONDENSER_OVERFLOW_COIL_ENTITY_ID: int = 2139
const FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_CONDENSER_OVERFLOW_RUNOFF_EXIT_COIL_ENTITY_ID: int = 2140
const FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_CONDENSER_OVERFLOW_RUNOFF_OUTLET_SPARK_ENTITY_ID: int = 2141
const FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_CONDENSER_OVERFLOW_RUNOFF_OUTLET_SERVICE_SLUICE_SPARK_ENTITY_ID: int = 2142
const FACTORY_SPARK_RAT_BITE_DAMAGE_FALLBACK: int = 9
const FACTORY_DEEP_GUARD_ACTIVATION_X: float = 980.0
const FACTORY_SPARK_RAT_ACTIVATION_X: float = 1140.0
const FACTORY_CHECKPOINT_FORWARD_PATROL_ACTIVATION_X: float = 900.0
const FACTORY_CHECKPOINT_REAR_AMBUSH_ACTIVATION_X: float = 1108.0
const FACTORY_CHECKPOINT_OVERDRIVE_DUO_ACTIVATION_X: float = 1196.0
const FACTORY_LOWER_DECK_SKIRMISH_ACTIVATION_X: float = 780.0
const FACTORY_LOWER_DECK_SHORTCUT_ACTIVATION_X: float = 1136.0
const FACTORY_LOWER_DECK_SHORTCUT_PURSUER_ACTIVATION_X: float = 1218.0
const FACTORY_LOWER_DECK_PRESSURE_VALVE_ACTIVATION_X: float = 1240.0
const FACTORY_LOWER_DECK_STEAM_SLUICE_ACTIVATION_X: float = 1248.0
const FACTORY_LOWER_DECK_DEEP_BULKHEAD_ACTIVATION_X: float = 1252.0
const FACTORY_LOWER_DECK_BREACH_CORRIDOR_ACTIVATION_X: float = 1256.0
const FACTORY_LOWER_DECK_BREACH_PINCER_MIDPOINT_X: float = 1264.0
const FACTORY_LOWER_DECK_POST_RELAY_TRIAL_ACTIVATION_X: float = 1232.0
const FACTORY_LOWER_DECK_FORWARD_CONDUIT_ACTIVATION_X: float = 1272.0
const FACTORY_LOWER_DECK_FORWARD_PRESSURE_ACTIVATION_X: float = 1284.0
const FACTORY_LOWER_DECK_FORWARD_PRESSURE_EXIT_X: float = 1328.0
const FACTORY_LOWER_DECK_FORWARD_COUNTER_AMBUSH_ACTIVATION_X: float = 1336.0
const FACTORY_LOWER_DECK_FORWARD_EXIT_GUARD_ACTIVATION_X: float = 1352.0
const FACTORY_LOWER_DECK_FORWARD_BEACON_AMBUSH_ACTIVATION_X: float = 1560.0
const FACTORY_LOWER_DECK_FORWARD_OVERRUN_ACTIVATION_X: float = 1620.0
const FACTORY_LOWER_DECK_FORWARD_BREAKER_ACTIVATION_X: float = 1668.0
const FACTORY_LOWER_DECK_FORWARD_RELIEF_AMBUSH_ACTIVATION_X: float = 1804.0
const FACTORY_LOWER_DECK_FORWARD_COIL_RAT_ACTIVATION_X: float = 1888.0
const FACTORY_LOWER_DECK_FORWARD_COIL_PINCER_ACTIVATION_X: float = 2016.0
const FACTORY_LOWER_DECK_FORWARD_COIL_AFTERSHOCK_ACTIVATION_X: float = 2144.0
const FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_EXIT_SKIRMISH_ACTIVATION_X: float = 2288.0
const FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_EXHAUST_ACTIVATION_X: float = 2416.0
const FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_EXHAUST_EXIT_X: float = 2480.0
const FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_EXHAUST_PURSUER_ACTIVATION_X: float = 2552.0
const FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_EXHAUST_FLANK_ACTIVATION_X: float = 2768.0
const FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_EXHAUST_BREAKER_ACTIVATION_X: float = 2928.0
const FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_EXHAUST_ESCAPE_ACTIVATION_X: float = 3112.0
const FACTORY_LOWER_DECK_FORWARD_PRESSURE_REWARD_CACHE_ID: StringName = (
	&"old_factory_lower_deck_forward_pressure_reward_cache"
)
const FACTORY_LOWER_DECK_FORWARD_PRESSURE_AFTERSHOCK_REWARD_CACHE_ID: StringName = (
	&"old_factory_lower_deck_forward_pressure_aftershock_reward_cache"
)
const FACTORY_LOWER_DECK_FORWARD_PRESSURE_AFTERSHOCK_EXHAUST_PURSUER_REWARD_CACHE_ID: StringName = (
	&"old_factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache"
)
const FACTORY_LOWER_DECK_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_REWARD_CACHE_ID: StringName = (
	&"old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_reward_cache"
)
const FACTORY_LOWER_DECK_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_RUNOFF_EXIT_REWARD_CACHE_ID: StringName = (
	&"old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_reward_cache"
)
const FACTORY_LOWER_DECK_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_RUNOFF_OUTLET_REWARD_CACHE_ID: StringName = (
	&"old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_reward_cache"
)
const FACTORY_LOWER_DECK_FORWARD_PRESSURE_INITIAL_GRACE_SEC: float = 0.25
const FACTORY_LOWER_DECK_FORWARD_PRESSURE_WARNING_SEC: float = 0.35
const FACTORY_LOWER_DECK_FORWARD_PRESSURE_ACTIVE_SEC: float = 0.40
const FACTORY_LOWER_DECK_FORWARD_PRESSURE_SAFE_SEC: float = 0.45
const FACTORY_SPARK_RAT_OPENING_GRACE_FRAMES: int = 18
const FACTORY_CHECKPOINT_OVERDRIVE_LEFT_OPENING_GRACE_FRAMES: int = 12
const FACTORY_CHECKPOINT_OVERDRIVE_RIGHT_OPENING_GRACE_FRAMES: int = 30
const FACTORY_COIL_PINCER_SPARK_RAT_OPENING_GRACE_FRAMES: int = 10
const FACTORY_COIL_PINCER_COIL_RAT_OPENING_GRACE_FRAMES: int = 26
const FACTORY_COIL_AFTERSHOCK_COIL_RAT_OPENING_GRACE_FRAMES: int = 8
const FACTORY_AFTERSHOCK_EXIT_SPARK_RAT_OPENING_GRACE_FRAMES: int = 12
const FACTORY_AFTERSHOCK_EXIT_COIL_RAT_OPENING_GRACE_FRAMES: int = 24
const FACTORY_AFTERSHOCK_EXHAUST_PURSUER_OPENING_GRACE_FRAMES: int = 10
const FACTORY_AFTERSHOCK_EXHAUST_FLANK_OPENING_GRACE_FRAMES: int = 14
const FACTORY_AFTERSHOCK_EXHAUST_BREAKER_OPENING_GRACE_FRAMES: int = 10
const FACTORY_AFTERSHOCK_EXHAUST_ESCAPE_SPARK_OPENING_GRACE_FRAMES: int = 10
const FACTORY_AFTERSHOCK_EXHAUST_ESCAPE_COIL_OPENING_GRACE_FRAMES: int = 22
const FACTORY_AFTERSHOCK_CONDENSER_OVERFLOW_COIL_OPENING_GRACE_FRAMES: int = 10
const FACTORY_AFTERSHOCK_CONDENSER_OVERFLOW_RUNOFF_EXIT_COIL_OPENING_GRACE_FRAMES: int = 10
const FACTORY_AFTERSHOCK_CONDENSER_OVERFLOW_RUNOFF_OUTLET_SPARK_OPENING_GRACE_FRAMES: int = 12
const FACTORY_AFTERSHOCK_CONDENSER_OVERFLOW_RUNOFF_OUTLET_SERVICE_SLUICE_SPARK_OPENING_GRACE_FRAMES: int = 12
const FACTORY_RESPAWN_HAZARD_GRACE_FRAMES: int = 18
const FACTORY_RETURN_CHECKPOINT_SPAWN_SNAP_FRAMES: int = 18
const FACTORY_RAT_MINION_COLLISION_LAYER: int = 2
const FACTORY_RAT_MINION_COLLISION_MASK: int = 17
const FACTORY_OBJECTIVE_CLEAR_ENTRANCE: StringName = &"clear_factory_entrance"
const FACTORY_OBJECTIVE_REACH_DEEP_GUARD: StringName = &"reach_deep_guard"
const FACTORY_OBJECTIVE_OPEN_DEEP_ROUTE: StringName = &"open_deep_route_endpoint"
const FACTORY_OBJECTIVE_DEFEAT_SPARK_RAT: StringName = &"defeat_spark_rat_patrol"
const FACTORY_OBJECTIVE_ROUTE_CLEARED: StringName = &"factory_route_cleared"
const FACTORY_OBJECTIVE_CLEAR_RETURN_PATROL: StringName = &"clear_return_patrol"
const FACTORY_OBJECTIVE_RETURN_PATROL_CLEARED: StringName = &"return_patrol_cleared"
const FACTORY_OBJECTIVE_CLEAR_CHECKPOINT_FORWARD_PATROL: StringName = &"clear_checkpoint_forward_patrol"
const FACTORY_OBJECTIVE_CHECKPOINT_FORWARD_ROUTE_OPENED: StringName = &"checkpoint_forward_route_opened"
const FACTORY_OBJECTIVE_CLEAR_CHECKPOINT_REAR_AMBUSH: StringName = &"clear_checkpoint_rear_ambush"
const FACTORY_OBJECTIVE_CHECKPOINT_REAR_AMBUSH_CLEARED: StringName = &"checkpoint_rear_ambush_cleared"
const FACTORY_OBJECTIVE_CLEAR_CHECKPOINT_OVERDRIVE_DUO: StringName = &"clear_checkpoint_overdrive_duo"
const FACTORY_OBJECTIVE_CHECKPOINT_OVERDRIVE_DUO_CLEARED: StringName = &"checkpoint_overdrive_duo_cleared"
const FACTORY_OBJECTIVE_CLEAR_LOWER_DECK_SKIRMISH: StringName = &"clear_lower_deck_skirmish"
const FACTORY_OBJECTIVE_LOWER_DECK_CLEARED: StringName = &"lower_deck_cleared"
const FACTORY_OBJECTIVE_CLEAR_LOWER_DECK_EXIT_AMBUSH: StringName = &"clear_lower_deck_exit_ambush"
const FACTORY_OBJECTIVE_LOWER_DECK_EXIT_CLEARED: StringName = &"lower_deck_exit_cleared"
const FACTORY_OBJECTIVE_CLEAR_LOWER_DECK_SHORTCUT_GUARD: StringName = &"clear_lower_deck_shortcut_guard"
const FACTORY_OBJECTIVE_OPEN_LOWER_DECK_SHORTCUT: StringName = &"open_lower_deck_shortcut"
const FACTORY_OBJECTIVE_LOWER_DECK_SHORTCUT_OPENED: StringName = &"lower_deck_shortcut_opened"
const FACTORY_OBJECTIVE_CLEAR_SHORTCUT_PURSUER: StringName = &"clear_shortcut_pursuer"
const FACTORY_OBJECTIVE_SHORTCUT_PURSUER_CLEARED: StringName = &"shortcut_pursuer_cleared"
const FACTORY_OBJECTIVE_CLEAR_PRESSURE_VALVE_GUARD: StringName = &"clear_pressure_valve_guard"
const FACTORY_OBJECTIVE_OPEN_PRESSURE_VALVE: StringName = &"open_pressure_valve"
const FACTORY_OBJECTIVE_PRESSURE_VALVE_OPENED: StringName = &"pressure_valve_opened"
const FACTORY_OBJECTIVE_CLEAR_STEAM_SLUICE_AMBUSH: StringName = &"clear_steam_sluice_ambush"
const FACTORY_OBJECTIVE_STEAM_SLUICE_CLEARED: StringName = &"steam_sluice_cleared"
const FACTORY_OBJECTIVE_CLEAR_DEEP_BULKHEAD_GUARD: StringName = &"clear_deep_bulkhead_guard"
const FACTORY_OBJECTIVE_OPEN_DEEP_BULKHEAD: StringName = &"open_deep_bulkhead"
const FACTORY_OBJECTIVE_DEEP_BULKHEAD_OPENED: StringName = &"deep_bulkhead_opened"
const FACTORY_OBJECTIVE_CLEAR_BREACH_CORRIDOR_AMBUSH: StringName = &"clear_breach_corridor_ambush"
const FACTORY_OBJECTIVE_SURVIVE_BREACH_PINCER: StringName = &"survive_breach_pincer"
const FACTORY_OBJECTIVE_BREACH_CORRIDOR_SECURED: StringName = &"breach_corridor_secured"
const FACTORY_OBJECTIVE_BREACH_RELAY_SECURED: StringName = &"breach_relay_secured"
const FACTORY_OBJECTIVE_CLEAR_POST_RELAY_TRIAL: StringName = &"clear_post_relay_trial"
const FACTORY_OBJECTIVE_POST_RELAY_TRIAL_SECURED: StringName = &"post_relay_trial_secured"
const FACTORY_OBJECTIVE_CLAIM_RELAY_FORWARD_CACHE: StringName = &"claim_relay_forward_cache"
const FACTORY_OBJECTIVE_OPEN_FORWARD_HATCH: StringName = &"open_forward_hatch"
const FACTORY_OBJECTIVE_FORWARD_HATCH_OPENED: StringName = &"forward_hatch_opened"
const FACTORY_OBJECTIVE_CLEAR_FORWARD_CONDUIT_AMBUSH: StringName = &"clear_forward_conduit_ambush"
const FACTORY_OBJECTIVE_FORWARD_CONDUIT_SECURED: StringName = &"forward_conduit_secured"
const FACTORY_OBJECTIVE_CROSS_FORWARD_PRESSURE_LEAK: StringName = &"cross_forward_pressure_leak"
const FACTORY_OBJECTIVE_FORWARD_PRESSURE_TRAVERSE_CROSSED: StringName = (
	&"forward_pressure_traverse_crossed"
)
const FACTORY_OBJECTIVE_SURVIVE_FORWARD_PRESSURE_AMBUSH: StringName = (
	&"survive_forward_pressure_ambush"
)
const FACTORY_OBJECTIVE_FORWARD_PRESSURE_AMBUSH_CLEARED: StringName = (
	&"forward_pressure_ambush_cleared"
)
const FACTORY_OBJECTIVE_CLEAR_FORWARD_PRESSURE_EXIT_GUARD: StringName = (
	&"clear_forward_pressure_exit_guard"
)
const FACTORY_OBJECTIVE_FORWARD_PRESSURE_EXIT_SECURED: StringName = (
	&"forward_pressure_exit_secured"
)
const FACTORY_OBJECTIVE_FORWARD_PRESSURE_EXIT_RELAY_SECURED: StringName = (
	&"forward_pressure_exit_relay_secured"
)
const FACTORY_OBJECTIVE_FORWARD_PRESSURE_EXIT_GATE_OPENED: StringName = (
	&"forward_pressure_exit_gate_opened"
)
const FACTORY_OBJECTIVE_FORWARD_PRESSURE_ROUTE_BEACON_LIT: StringName = (
	&"forward_pressure_route_beacon_lit"
)
const FACTORY_OBJECTIVE_CLEAR_FORWARD_PRESSURE_BEACON_AMBUSH: StringName = (
	&"clear_forward_pressure_beacon_ambush"
)
const FACTORY_OBJECTIVE_FORWARD_PRESSURE_BEACON_AMBUSH_CLEARED: StringName = (
	&"forward_pressure_beacon_ambush_cleared"
)
const FACTORY_OBJECTIVE_SURVIVE_FORWARD_PRESSURE_OVERRUN: StringName = (
	&"survive_forward_pressure_overrun"
)
const FACTORY_OBJECTIVE_FORWARD_PRESSURE_OVERRUN_CLEARED: StringName = (
	&"forward_pressure_overrun_cleared"
)
const FACTORY_OBJECTIVE_SECURE_FORWARD_PRESSURE_BREAKER: StringName = (
	&"secure_forward_pressure_breaker"
)
const FACTORY_OBJECTIVE_CUT_FORWARD_PRESSURE: StringName = &"cut_forward_pressure"
const FACTORY_OBJECTIVE_FORWARD_PRESSURE_BREAKER_CUT: StringName = (
	&"forward_pressure_breaker_cut"
)
const FACTORY_OBJECTIVE_SURVIVE_FORWARD_PRESSURE_RELIEF_AMBUSH: StringName = (
	&"survive_forward_pressure_relief_ambush"
)
const FACTORY_OBJECTIVE_FORWARD_PRESSURE_RELIEF_AMBUSH_CLEARED: StringName = (
	&"forward_pressure_relief_ambush_cleared"
)
const FACTORY_OBJECTIVE_FACE_FORWARD_PRESSURE_COIL_RAT: StringName = (
	&"face_forward_pressure_coil_rat"
)
const FACTORY_OBJECTIVE_FORWARD_PRESSURE_COIL_RAT_CLEARED: StringName = (
	&"forward_pressure_coil_rat_cleared"
)
const FACTORY_OBJECTIVE_BREAK_FORWARD_PRESSURE_COIL_PINCER: StringName = (
	&"break_forward_pressure_coil_pincer"
)
const FACTORY_OBJECTIVE_FORWARD_PRESSURE_COIL_PINCER_CLEARED: StringName = (
	&"forward_pressure_coil_pincer_cleared"
)
const FACTORY_OBJECTIVE_CONTAIN_FORWARD_PRESSURE_COIL_AFTERSHOCK: StringName = (
	&"contain_forward_pressure_coil_aftershock"
)
const FACTORY_OBJECTIVE_FORWARD_PRESSURE_COIL_AFTERSHOCK_CLEARED: StringName = (
	&"forward_pressure_coil_aftershock_cleared"
)
const FACTORY_OBJECTIVE_FORWARD_PRESSURE_AFTERSHOCK_CACHE_CLAIMED: StringName = (
	&"forward_pressure_aftershock_cache_claimed"
)
const FACTORY_OBJECTIVE_BREAK_FORWARD_PRESSURE_AFTERSHOCK_EXIT_SKIRMISH: StringName = (
	&"break_forward_pressure_aftershock_exit_skirmish"
)
const FACTORY_OBJECTIVE_FORWARD_PRESSURE_AFTERSHOCK_EXIT_SKIRMISH_CLEARED: StringName = (
	&"forward_pressure_aftershock_exit_skirmish_cleared"
)
const FACTORY_OBJECTIVE_CROSS_FORWARD_PRESSURE_AFTERSHOCK_EXHAUST: StringName = (
	&"cross_forward_pressure_aftershock_exhaust"
)
const FACTORY_OBJECTIVE_FORWARD_PRESSURE_AFTERSHOCK_EXHAUST_CROSSED: StringName = (
	&"forward_pressure_aftershock_exhaust_crossed"
)
const FACTORY_OBJECTIVE_PURGE_FORWARD_PRESSURE_AFTERSHOCK_EXHAUST_PURSUER: StringName = (
	&"purge_forward_pressure_aftershock_exhaust_pursuer"
)
const FACTORY_OBJECTIVE_FORWARD_PRESSURE_AFTERSHOCK_EXHAUST_PURSUER_CLEARED: StringName = (
	&"forward_pressure_aftershock_exhaust_pursuer_cleared"
)
const FACTORY_OBJECTIVE_FORWARD_PRESSURE_AFTERSHOCK_EXHAUST_PURSUER_CACHE_CLAIMED: StringName = (
	&"forward_pressure_aftershock_exhaust_pursuer_cache_claimed"
)
const FACTORY_OBJECTIVE_BREAK_FORWARD_PRESSURE_AFTERSHOCK_EXHAUST_FLANK: StringName = (
	&"break_forward_pressure_aftershock_exhaust_flank"
)
const FACTORY_OBJECTIVE_FORWARD_PRESSURE_AFTERSHOCK_EXHAUST_FLANK_CLEARED: StringName = (
	&"forward_pressure_aftershock_exhaust_flank_cleared"
)
const FACTORY_OBJECTIVE_SECURE_FORWARD_PRESSURE_AFTERSHOCK_EXHAUST_BREAKER: StringName = (
	&"secure_forward_pressure_aftershock_exhaust_breaker"
)
const FACTORY_OBJECTIVE_CUT_FORWARD_PRESSURE_AFTERSHOCK_EXHAUST: StringName = (
	&"cut_forward_pressure_aftershock_exhaust"
)
const FACTORY_OBJECTIVE_FORWARD_PRESSURE_AFTERSHOCK_EXHAUST_BREAKER_CUT: StringName = (
	&"forward_pressure_aftershock_exhaust_breaker_cut"
)
const FACTORY_OBJECTIVE_BREAK_FORWARD_PRESSURE_AFTERSHOCK_EXHAUST_ESCAPE: StringName = (
	&"break_forward_pressure_aftershock_exhaust_escape"
)
const FACTORY_OBJECTIVE_FORWARD_PRESSURE_AFTERSHOCK_EXHAUST_ESCAPE_SECURED: StringName = (
	&"forward_pressure_aftershock_exhaust_escape_secured"
)
const FACTORY_OBJECTIVE_OPEN_FORWARD_PRESSURE_AFTERSHOCK_EXHAUST_EXIT_HATCH: StringName = (
	&"open_forward_pressure_aftershock_exhaust_exit_hatch"
)
const FACTORY_OBJECTIVE_FORWARD_PRESSURE_AFTERSHOCK_EXHAUST_EXIT_OPENED: StringName = (
	&"forward_pressure_aftershock_exhaust_exit_opened"
)
const FACTORY_OBJECTIVE_CROSS_FORWARD_PRESSURE_AFTERSHOCK_COOLING_DUCT: StringName = (
	&"cross_forward_pressure_aftershock_cooling_duct"
)
const FACTORY_OBJECTIVE_FORWARD_PRESSURE_AFTERSHOCK_COOLING_DUCT_CROSSED: StringName = (
	&"forward_pressure_aftershock_cooling_duct_crossed"
)
const FACTORY_OBJECTIVE_SECURE_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER: StringName = (
	&"secure_forward_pressure_aftershock_condenser"
)
const FACTORY_OBJECTIVE_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_SECURED: StringName = (
	&"forward_pressure_aftershock_condenser_secured"
)
const FACTORY_OBJECTIVE_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_SAVEPOINT_SECURED: StringName = (
	&"forward_pressure_aftershock_condenser_savepoint_secured"
)
const FACTORY_OBJECTIVE_CROSS_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_OUTLET: StringName = (
	&"cross_forward_pressure_aftershock_condenser_outlet"
)
const FACTORY_OBJECTIVE_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_OUTLET_CROSSED: StringName = (
	&"forward_pressure_aftershock_condenser_outlet_crossed"
)
const FACTORY_OBJECTIVE_CLEAR_FORWARD_PRESSURE_AFTERSHOCK_OUTLET_CLAMP_AMBUSH: StringName = (
	&"clear_forward_pressure_aftershock_outlet_clamp_ambush"
)
const FACTORY_OBJECTIVE_FORWARD_PRESSURE_AFTERSHOCK_OUTLET_CLAMP_AMBUSH_CLEARED: StringName = (
	&"forward_pressure_aftershock_outlet_clamp_ambush_cleared"
)
const FACTORY_OBJECTIVE_CROSS_FORWARD_PRESSURE_AFTERSHOCK_OUTLET_DRIP_VENT: StringName = (
	&"cross_forward_pressure_aftershock_outlet_drip_vent"
)
const FACTORY_OBJECTIVE_FORWARD_PRESSURE_AFTERSHOCK_OUTLET_DRIP_VENT_CROSSED: StringName = (
	&"forward_pressure_aftershock_outlet_drip_vent_crossed"
)
const FACTORY_OBJECTIVE_CLEAR_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP: StringName = (
	&"clear_forward_pressure_aftershock_condenser_overflow_pump"
)
const FACTORY_OBJECTIVE_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_CLEARED: StringName = (
	&"forward_pressure_aftershock_condenser_overflow_pump_cleared"
)
const FACTORY_OBJECTIVE_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_CACHE_CLAIMED: StringName = (
	&"forward_pressure_aftershock_condenser_overflow_pump_cache_claimed"
)
const FACTORY_OBJECTIVE_OPEN_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_EXIT_HATCH: StringName = (
	&"open_forward_pressure_aftershock_condenser_overflow_pump_exit_hatch"
)
const FACTORY_OBJECTIVE_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_EXIT_HATCH_OPENED: StringName = (
	&"forward_pressure_aftershock_condenser_overflow_pump_exit_hatch_opened"
)
const FACTORY_OBJECTIVE_CROSS_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_RUNOFF_DUCT: StringName = (
	&"cross_forward_pressure_aftershock_condenser_overflow_pump_runoff_duct"
)
const FACTORY_OBJECTIVE_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_RUNOFF_DUCT_CROSSED: StringName = (
	&"forward_pressure_aftershock_condenser_overflow_pump_runoff_duct_crossed"
)
const FACTORY_OBJECTIVE_CLEAR_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_RUNOFF_EXIT: StringName = (
	&"clear_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit"
)
const FACTORY_OBJECTIVE_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_RUNOFF_EXIT_CLEARED: StringName = (
	&"forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_cleared"
)
const FACTORY_OBJECTIVE_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_RUNOFF_EXIT_CACHE_CLAIMED: StringName = (
	&"forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_cache_claimed"
)
const FACTORY_OBJECTIVE_OPEN_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_RUNOFF_EXIT_GATE: StringName = (
	&"open_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_gate"
)
const FACTORY_OBJECTIVE_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_RUNOFF_EXIT_GATE_OPENED: StringName = (
	&"forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_gate_opened"
)
const FACTORY_OBJECTIVE_CROSS_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_RUNOFF_OUTLET: StringName = (
	&"cross_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet"
)
const FACTORY_OBJECTIVE_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_RUNOFF_OUTLET_CROSSED: StringName = (
	&"forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_crossed"
)
const FACTORY_OBJECTIVE_CLEAR_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_RUNOFF_OUTLET_SKIRMISH: StringName = (
	&"clear_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_skirmish"
)
const FACTORY_OBJECTIVE_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_RUNOFF_OUTLET_SKIRMISH_CLEARED: StringName = (
	&"forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_skirmish_cleared"
)
const FACTORY_OBJECTIVE_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_RUNOFF_OUTLET_CACHE_CLAIMED: StringName = (
	&"forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_cache_claimed"
)
const FACTORY_OBJECTIVE_OPEN_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_RUNOFF_OUTLET_SERVICE_HATCH: StringName = (
	&"open_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_hatch"
)
const FACTORY_OBJECTIVE_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_RUNOFF_OUTLET_SERVICE_HATCH_OPENED: StringName = (
	&"forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_hatch_opened"
)
const FACTORY_OBJECTIVE_CROSS_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_RUNOFF_OUTLET_SERVICE_SLUICE: StringName = (
	&"cross_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice"
)
const FACTORY_OBJECTIVE_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_RUNOFF_OUTLET_SERVICE_SLUICE_CROSSED: StringName = (
	&"forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_crossed"
)
const FACTORY_OBJECTIVE_CLEAR_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_RUNOFF_OUTLET_SERVICE_SLUICE_SKIRMISH: StringName = (
	&"clear_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_skirmish"
)
const FACTORY_OBJECTIVE_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_RUNOFF_OUTLET_SERVICE_SLUICE_SKIRMISH_CLEARED: StringName = (
	&"forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_skirmish_cleared"
)
const FACTORY_LOWER_DECK_FORWARD_COUNTER_AMBUSH_HAZARD_ID: StringName = (
	&"old_factory_lower_deck_forward_pressure_counter_ambush"
)
const FACTORY_LOWER_DECK_FORWARD_EXIT_GUARD_HAZARD_ID: StringName = (
	&"old_factory_lower_deck_forward_pressure_exit_guard"
)
const FACTORY_LOWER_DECK_FORWARD_BEACON_AMBUSH_HAZARD_ID: StringName = (
	&"old_factory_lower_deck_forward_pressure_beacon_ambush"
)
const FACTORY_LOWER_DECK_FORWARD_OVERRUN_HAZARD_ID: StringName = (
	&"old_factory_lower_deck_forward_pressure_overrun"
)
const FACTORY_LOWER_DECK_FORWARD_BREAKER_HAZARD_ID: StringName = (
	&"old_factory_lower_deck_forward_pressure_breaker"
)
const FACTORY_LOWER_DECK_FORWARD_RELIEF_AMBUSH_HAZARD_ID: StringName = (
	&"old_factory_lower_deck_forward_pressure_relief_ambush"
)
const FACTORY_LOWER_DECK_PARRY_GATE_ID: StringName = &"old_factory_lower_deck_parry_laser"
const FACTORY_LOWER_DECK_SHORTCUT_SEAL_ID: StringName = &"old_factory_lower_deck_shortcut_seal"
const FACTORY_LOWER_DECK_PRESSURE_VALVE_ID: StringName = &"old_factory_lower_deck_pressure_valve"
const FACTORY_LOWER_DECK_DEEP_BULKHEAD_ID: StringName = &"old_factory_lower_deck_deep_bulkhead"
const FACTORY_LOWER_DECK_BREACH_RELAY_ID: StringName = &"old_factory_lower_deck_breach_relay"
const FACTORY_LOWER_DECK_FORWARD_PRESSURE_EXIT_RELAY_ID: StringName = (
	&"old_factory_lower_deck_forward_pressure_exit_relay"
)
const FACTORY_LOWER_DECK_FORWARD_PRESSURE_EXIT_GATE_ID: StringName = (
	&"old_factory_lower_deck_forward_pressure_exit_gate"
)
const FACTORY_LOWER_DECK_FORWARD_PRESSURE_ROUTE_HANDOFF_MARKER_ID: StringName = (
	&"old_factory_lower_deck_forward_pressure_route_handoff_marker"
)
const FACTORY_LOWER_DECK_FORWARD_PRESSURE_BREAKER_ID: StringName = (
	&"old_factory_lower_deck_forward_pressure_breaker"
)
const FACTORY_LOWER_DECK_FORWARD_PRESSURE_COIL_RAT_ID: StringName = (
	&"old_factory_lower_deck_forward_pressure_coil_rat_breakthrough"
)
const FACTORY_LOWER_DECK_FORWARD_PRESSURE_COIL_PINCER_ID: StringName = (
	&"old_factory_lower_deck_forward_pressure_coil_pincer"
)
const FACTORY_LOWER_DECK_FORWARD_PRESSURE_COIL_AFTERSHOCK_ID: StringName = (
	&"old_factory_lower_deck_forward_pressure_coil_aftershock"
)
const FACTORY_LOWER_DECK_FORWARD_PRESSURE_AFTERSHOCK_EXIT_SKIRMISH_ID: StringName = (
	&"old_factory_lower_deck_forward_pressure_aftershock_exit_skirmish"
)
const FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_EXHAUST_HAZARD_ID: StringName = (
	&"old_factory_lower_deck_forward_pressure_aftershock_exhaust"
)
const FACTORY_LOWER_DECK_FORWARD_PRESSURE_AFTERSHOCK_EXHAUST_PURSUER_ID: StringName = (
	&"old_factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer"
)
const FACTORY_LOWER_DECK_FORWARD_PRESSURE_AFTERSHOCK_EXHAUST_FLANK_ID: StringName = (
	&"old_factory_lower_deck_forward_pressure_aftershock_exhaust_flank_ambush"
)
const FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_EXHAUST_FLANK_HAZARD_ID: StringName = (
	&"old_factory_lower_deck_forward_pressure_aftershock_exhaust_flank_ambush"
)
const FACTORY_LOWER_DECK_FORWARD_PRESSURE_AFTERSHOCK_EXHAUST_BREAKER_ID: StringName = (
	&"old_factory_lower_deck_forward_pressure_aftershock_exhaust_breaker"
)
const FACTORY_LOWER_DECK_FORWARD_PRESSURE_AFTERSHOCK_EXHAUST_ESCAPE_ID: StringName = (
	&"old_factory_lower_deck_forward_pressure_aftershock_exhaust_escape_skirmish"
)
const FACTORY_LOWER_DECK_FORWARD_PRESSURE_AFTERSHOCK_EXHAUST_EXIT_HATCH_ID: StringName = (
	&"old_factory_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch"
)
const FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_EXHAUST_BREAKER_HAZARD_ID: StringName = (
	&"old_factory_lower_deck_forward_pressure_aftershock_exhaust_breaker"
)
const FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_COOLING_DUCT_HAZARD_ID: StringName = (
	&"old_factory_lower_deck_forward_pressure_aftershock_cooling_duct"
)
const FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_COOLING_DUCT_ACTIVATION_X: float = 3240.0
const FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_COOLING_DUCT_EXIT_X: float = 3740.0
const FACTORY_LOWER_DECK_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_VALVE_ID: StringName = (
	&"old_factory_lower_deck_forward_pressure_aftershock_condenser_valve"
)
const FACTORY_LOWER_DECK_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_SAVEPOINT_ID: StringName = (
	&"old_factory_lower_deck_forward_pressure_aftershock_condenser_savepoint"
)
const FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_CONDENSER_OUTLET_HAZARD_ID: StringName = (
	&"old_factory_lower_deck_forward_pressure_aftershock_condenser_outlet"
)
const FACTORY_LOWER_DECK_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_OUTLET_CLAMP_ID: StringName = (
	&"old_factory_lower_deck_forward_pressure_aftershock_condenser_outlet_clamp_ambush"
)
const FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_CONDENSER_DRIP_VENT_HAZARD_ID: StringName = (
	&"old_factory_lower_deck_forward_pressure_aftershock_condenser_outlet_drip_vent"
)
const FACTORY_LOWER_DECK_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_ID: StringName = (
	&"old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump"
)
const FACTORY_LOWER_DECK_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_EXIT_HATCH_ID: StringName = (
	&"old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_exit_hatch"
)
const FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_RUNOFF_DUCT_HAZARD_ID: StringName = (
	&"old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_duct"
)
const FACTORY_LOWER_DECK_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_RUNOFF_EXIT_ID: StringName = (
	&"old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_skirmish"
)
const FACTORY_LOWER_DECK_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_RUNOFF_EXIT_GATE_ID: StringName = (
	&"old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_gate"
)
const FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_RUNOFF_OUTLET_HAZARD_ID: StringName = (
	&"old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet"
)
const FACTORY_LOWER_DECK_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_RUNOFF_OUTLET_SERVICE_HATCH_ID: StringName = (
	&"old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_hatch"
)
const FACTORY_LOWER_DECK_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_RUNOFF_OUTLET_SERVICE_SLUICE_HAZARD_ID: StringName = (
	&"old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice"
)
const FACTORY_LOWER_DECK_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_RUNOFF_OUTLET_SERVICE_SLUICE_SKIRMISH_ID: StringName = (
	&"old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_skirmish"
)
const FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_CONDENSER_ACTIVATION_X: float = 3920.0
const FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_CONDENSER_OUTLET_ACTIVATION_X: float = 4560.0
const FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_CONDENSER_OUTLET_EXIT_X: float = 5020.0
const FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_CONDENSER_OUTLET_CLAMP_ACTIVATION_X: float = 5220.0
const FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_CONDENSER_DRIP_VENT_ACTIVATION_X: float = 5840.0
const FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_CONDENSER_DRIP_VENT_EXIT_X: float = 6260.0
const FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_ACTIVATION_X: float = 6540.0
const FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_RUNOFF_DUCT_ACTIVATION_X: float = 7160.0
const FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_RUNOFF_DUCT_EXIT_X: float = 7560.0
const FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_RUNOFF_EXIT_ACTIVATION_X: float = 7800.0
const FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_RUNOFF_OUTLET_ACTIVATION_X: float = 8480.0
const FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_RUNOFF_OUTLET_EXIT_X: float = 9060.0
const FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_RUNOFF_OUTLET_SKIRMISH_ACTIVATION_X: float = 9280.0
const FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_RUNOFF_OUTLET_SERVICE_SLUICE_ACTIVATION_X: float = 10160.0
const FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_RUNOFF_OUTLET_SERVICE_SLUICE_EXIT_X: float = 10720.0
const FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_RUNOFF_OUTLET_SERVICE_SLUICE_SKIRMISH_ACTIVATION_X: float = 10920.0
const FACTORY_LOWER_DECK_FORWARD_HATCH_ID: StringName = &"old_factory_lower_deck_forward_hatch"
const FACTORY_LOWER_DECK_BREACH_RELAY_SPAWN_POINT: StringName = &"lower_deck_breach_relay"
const FACTORY_LOWER_DECK_FORWARD_PRESSURE_EXIT_RELAY_SPAWN_POINT: StringName = (
	&"lower_deck_forward_pressure_exit_relay"
)
const FACTORY_LOWER_DECK_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_SAVEPOINT_SPAWN_POINT: StringName = (
	&"lower_deck_forward_pressure_aftershock_condenser_savepoint"
)
const FACTORY_SERVICE_LIFT_ENDPOINT_ID: StringName = &"old_factory_service_lift"
const FACTORY_SERVICE_LIFT_EXIT_SCENE_ID: StringName = &"main"
const FACTORY_SERVICE_LIFT_EXIT_SPAWN_POINT: StringName = &"scrap_roost"
const FACTORY_RETURN_CHECKPOINT_ID: StringName = &"old_factory_return_checkpoint"
const FACTORY_RETURN_CHECKPOINT_SPAWN_POINT: StringName = &"return_checkpoint"
const FACTORY_GATE_ENTRY_SPAWN_POINT: StringName = &"factory_gate_entry"
const FACTORY_RETURN_CHECKPOINT_ACTIVATION_RADIUS: float = 112.0
const FACTORY_RETURN_CHECKPOINT_RESPAWN_LABEL: String = "Returned to Factory Savepoint"
const FACTORY_LOWER_DECK_BREACH_RELAY_RESPAWN_LABEL: String = "Returned to Lower Deck Relay"
const FACTORY_LOWER_DECK_FORWARD_PRESSURE_EXIT_RELAY_RESPAWN_LABEL: String = (
	"Returned to Forward Pressure Exit Relay"
)
const FACTORY_LOWER_DECK_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_SAVEPOINT_RESPAWN_LABEL: String = (
	"Returned to Aftershock Condenser Savepoint"
)
const GAME_FLOW_SCRIPT: Script = preload("res://src/gameplay/game_flow_controller.gd")
const WEAPON_COMPONENT_SCRIPT: Script = preload("res://src/core/weapon_component.gd")

@onready var _spawn: Marker2D = $FactoryGateEntrySpawn
@onready var _player: Node2D = $Player
@onready var _enemy: Node2D = $FactoryRatMinion
@onready var _deep_guard: Node2D = get_node_or_null("FactoryDeepGuardRatMinion") as Node2D
@onready var _spark_rat: Node2D = get_node_or_null("FactorySparkRat") as Node2D
@onready var _return_spark_rat: Node2D = get_node_or_null("FactoryReturnSparkRat") as Node2D
@onready var _checkpoint_forward_spark_rat: Node2D = get_node_or_null("FactoryCheckpointForwardSparkRat") as Node2D
@onready var _checkpoint_rear_spark_rat: Node2D = get_node_or_null("FactoryCheckpointRearSparkRat") as Node2D
@onready var _checkpoint_overdrive_left_spark_rat: Node2D = (
	get_node_or_null("FactoryCheckpointOverdriveSparkRatLeft") as Node2D
)
@onready var _checkpoint_overdrive_right_spark_rat: Node2D = (
	get_node_or_null("FactoryCheckpointOverdriveSparkRatRight") as Node2D
)
@onready var _lower_deck_spark_rat: Node2D = (
	get_node_or_null("FactoryLowerDeckSparkRat") as Node2D
)
@onready var _lower_deck_exit_spark_rat: Node2D = (
	get_node_or_null("FactoryLowerDeckExitSparkRat") as Node2D
)
@onready var _lower_deck_shortcut_spark_rat: Node2D = (
	get_node_or_null("FactoryLowerDeckShortcutSparkRat") as Node2D
)
@onready var _lower_deck_shortcut_pursuer_spark_rat: Node2D = (
	get_node_or_null("FactoryLowerDeckShortcutPursuerSparkRat") as Node2D
)
@onready var _lower_deck_pressure_guard_spark_rat: Node2D = (
	get_node_or_null("FactoryLowerDeckPressureValveSparkRat") as Node2D
)
@onready var _lower_deck_steam_sluice_spark_rat: Node2D = (
	get_node_or_null("FactoryLowerDeckSteamSluiceSparkRat") as Node2D
)
@onready var _lower_deck_deep_bulkhead_spark_rat: Node2D = (
	get_node_or_null("FactoryLowerDeckDeepBulkheadSparkRat") as Node2D
)
@onready var _lower_deck_breach_front_spark_rat: Node2D = (
	get_node_or_null("FactoryLowerDeckBreachFrontSparkRat") as Node2D
)
@onready var _lower_deck_breach_rear_spark_rat: Node2D = (
	get_node_or_null("FactoryLowerDeckBreachRearSparkRat") as Node2D
)
@onready var _lower_deck_post_relay_spark_rat: Node2D = (
	get_node_or_null("FactoryLowerDeckPostRelaySparkRat") as Node2D
)
@onready var _lower_deck_forward_conduit_spark_rat: Node2D = (
	get_node_or_null("FactoryLowerDeckForwardConduitSparkRat") as Node2D
)
@onready var _lower_deck_forward_counter_spark_rat: Node2D = (
	get_node_or_null("FactoryLowerDeckForwardCounterSparkRat") as Node2D
)
@onready var _lower_deck_forward_exit_guard_spark_rat: Node2D = (
	get_node_or_null("FactoryLowerDeckForwardPressureExitGuardSparkRat") as Node2D
)
@onready var _lower_deck_forward_beacon_ambush_spark_rat: Node2D = (
	get_node_or_null("FactoryLowerDeckForwardPressureBeaconAmbushSparkRat") as Node2D
)
@onready var _lower_deck_forward_overrun_spark_rat: Node2D = (
	get_node_or_null("FactoryLowerDeckForwardPressureOverrunSparkRat") as Node2D
)
@onready var _lower_deck_forward_breaker_spark_rat: Node2D = (
	get_node_or_null("FactoryLowerDeckForwardPressureBreakerSparkRat") as Node2D
)
@onready var _lower_deck_forward_relief_ambush_spark_rat: Node2D = (
	get_node_or_null("FactoryLowerDeckForwardPressureReliefSparkRat") as Node2D
)
@onready var _lower_deck_forward_pressure_coil_rat: Node2D = (
	get_node_or_null("FactoryLowerDeckForwardPressureCoilRat") as Node2D
)
@onready var _lower_deck_forward_pressure_coil_pincer_spark_rat: Node2D = (
	get_node_or_null("FactoryLowerDeckForwardPressureCoilPincerSparkRat") as Node2D
)
@onready var _lower_deck_forward_pressure_coil_pincer_coil_rat: Node2D = (
	get_node_or_null("FactoryLowerDeckForwardPressureCoilPincerCoilRat") as Node2D
)
@onready var _lower_deck_forward_pressure_coil_aftershock_coil_rat: Node2D = (
	get_node_or_null("FactoryLowerDeckForwardPressureCoilAftershockCoilRat") as Node2D
)
@onready var _lower_deck_forward_pressure_aftershock_exit_spark_rat: Node2D = (
	get_node_or_null(
		"FactoryLowerDeckForwardPressureAftershockExitSkirmishSparkRat"
	) as Node2D
)
@onready var _lower_deck_forward_pressure_aftershock_exit_coil_rat: Node2D = (
	get_node_or_null(
		"FactoryLowerDeckForwardPressureAftershockExitSkirmishCoilRat"
	) as Node2D
)
@onready var _lower_deck_forward_pressure_aftershock_exhaust_pursuer_coil_rat: Node2D = (
	get_node_or_null(
		"FactoryLowerDeckForwardPressureAftershockExhaustPursuerCoilRat"
	) as Node2D
)
@onready var _lower_deck_forward_pressure_aftershock_exhaust_flank_spark_rat: Node2D = (
	get_node_or_null(
		"FactoryLowerDeckForwardPressureAftershockExhaustFlankAmbushSparkRat"
	) as Node2D
)
@onready var _lower_deck_forward_pressure_aftershock_exhaust_breaker_coil_rat: Node2D = (
	get_node_or_null(
		"FactoryLowerDeckForwardPressureAftershockExhaustBreakerCoilRat"
	) as Node2D
)
@onready var _lower_deck_forward_pressure_aftershock_exhaust_escape_spark_rat: Node2D = (
	get_node_or_null(
		"FactoryLowerDeckForwardPressureAftershockExhaustEscapeSkirmishSparkRat"
	) as Node2D
)
@onready var _lower_deck_forward_pressure_aftershock_exhaust_escape_coil_rat: Node2D = (
	get_node_or_null(
		"FactoryLowerDeckForwardPressureAftershockExhaustEscapeSkirmishCoilRat"
	) as Node2D
)
@onready var _lower_deck_forward_pressure_aftershock_condenser_spark_rat: Node2D = (
	get_node_or_null(
		"FactoryLowerDeckForwardPressureAftershockCondenserLandingSparkRat"
	) as Node2D
)
@onready var _lower_deck_forward_pressure_aftershock_condenser_coil_rat: Node2D = (
	get_node_or_null(
		"FactoryLowerDeckForwardPressureAftershockCondenserLandingCoilRat"
	) as Node2D
)
@onready var _lower_deck_forward_pressure_aftershock_condenser_outlet_clamp_spark_rat: Node2D = (
	get_node_or_null(
		"FactoryLowerDeckForwardPressureAftershockCondenserOutletClampSparkRat"
	) as Node2D
)
@onready var _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_coil_rat: Node2D = (
	get_node_or_null(
		"FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpCoilRat"
	) as Node2D
)
@onready var _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_coil_rat: Node2D = (
	get_node_or_null(
		"FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffExitCoilRat"
	) as Node2D
)
@onready var _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_spark_rat: Node2D = (
	get_node_or_null(
		"FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffOutletSparkRat"
	) as Node2D
)
@onready var _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_spark_rat: Node2D = (
	get_node_or_null(
		"FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffOutletServiceSluiceSparkRat"
	) as Node2D
)
@onready var _checkpoint_overdrive_left_defeat_burst: Sprite2D = (
	get_node_or_null("FactoryCheckpointOverdriveLeftDefeatBurst") as Sprite2D
)
@onready var _checkpoint_overdrive_right_defeat_burst: Sprite2D = (
	get_node_or_null("FactoryCheckpointOverdriveRightDefeatBurst") as Sprite2D
)
@onready var _lower_deck_forward_conduit_clear_burst: Sprite2D = (
	get_node_or_null("FactoryLowerDeckForwardConduitClearBurst") as Sprite2D
)
@onready var _cache: Node = $FactoryCombatCache
@onready var _return_patrol_reward_cache: Node = get_node_or_null(
	"FactoryReturnPatrolRewardCache"
)
@onready var _checkpoint_overdrive_reward_cache: Node = get_node_or_null(
	"FactoryCheckpointOverdriveRewardCache"
)
@onready var _lower_deck_reward_cache: Node = get_node_or_null("FactoryLowerDeckRewardCache")
@onready var _lower_deck_parry_gate: Node = get_node_or_null("FactoryLowerDeckParryLaserGate")
@onready var _lower_deck_shortcut_seal: Node = get_node_or_null("FactoryLowerDeckShortcutSeal")
@onready var _lower_deck_shortcut_reward_cache: Node = get_node_or_null(
	"FactoryLowerDeckShortcutRewardCache"
)
@onready var _lower_deck_relay_forward_reward_cache: Node = get_node_or_null(
	"FactoryLowerDeckRelayForwardRewardCache"
)
@onready var _lower_deck_forward_pressure_reward_cache: Node = get_node_or_null(
	"FactoryLowerDeckForwardPressureRewardCache"
)
@onready var _lower_deck_forward_pressure_aftershock_reward_cache: Node = (
	get_node_or_null("FactoryLowerDeckForwardPressureAftershockRewardCache")
)
@onready var _lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache: Node = (
	get_node_or_null(
		"FactoryLowerDeckForwardPressureAftershockExhaustPursuerRewardCache"
	)
)
@onready var _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_reward_cache: Node = (
	get_node_or_null(
		"FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRewardCache"
	)
)
@onready var _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_reward_cache: Node = (
	get_node_or_null(
		"FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffExitRewardCache"
	)
)
@onready var _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_reward_cache: Node = (
	get_node_or_null(
		"FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffOutletRewardCache"
	)
)
@onready var _lower_deck_pressure_valve: Node = get_node_or_null("FactoryLowerDeckPressureValve")
@onready var _lower_deck_deep_bulkhead: Node = get_node_or_null("FactoryLowerDeckDeepBulkhead")
@onready var _lower_deck_forward_hatch: Node = get_node_or_null("FactoryLowerDeckForwardHatch")
@onready var _return_checkpoint: Node = get_node_or_null("FactoryReturnCheckpoint")
@onready var _lower_deck_breach_relay: Node = get_node_or_null(
	"FactoryLowerDeckBreachRelaySavepoint"
)
@onready var _lower_deck_forward_pressure_exit_relay: Node = get_node_or_null(
	"FactoryLowerDeckForwardPressureExitRelaySavepoint"
)
@onready var _lower_deck_forward_pressure_exit_gate: Node = get_node_or_null(
	"FactoryLowerDeckForwardPressureExitGate"
)
@onready var _lower_deck_forward_pressure_route_handoff_marker: Node = get_node_or_null(
	"FactoryLowerDeckForwardPressureRouteHandoffMarker"
)
@onready var _lower_deck_forward_pressure_breaker: Node = get_node_or_null(
	"FactoryLowerDeckForwardPressureBreaker"
)
@onready var _lower_deck_forward_pressure_aftershock_exhaust_breaker: Node = (
	get_node_or_null("FactoryLowerDeckForwardPressureAftershockExhaustBreaker")
)
@onready var _lower_deck_forward_pressure_aftershock_exhaust_exit_hatch: Node = (
	get_node_or_null("FactoryLowerDeckForwardPressureAftershockExhaustExitHatch")
)
@onready var _lower_deck_forward_pressure_aftershock_cooling_duct: Sprite2D = (
	get_node_or_null("FactoryLowerDeckForwardPressureAftershockCoolingDuct")
		as Sprite2D
)
@onready var _lower_deck_forward_pressure_aftershock_condenser_valve: Sprite2D = (
	get_node_or_null("FactoryLowerDeckForwardPressureAftershockCondenserValve")
		as Sprite2D
)
@onready var _lower_deck_forward_pressure_aftershock_condenser_savepoint: Node = (
	get_node_or_null("FactoryLowerDeckForwardPressureAftershockCondenserSavepoint")
)
@onready var _lower_deck_forward_pressure_aftershock_condenser_outlet: Sprite2D = (
	get_node_or_null("FactoryLowerDeckForwardPressureAftershockCondenserOutlet")
		as Sprite2D
)
@onready var _lower_deck_forward_pressure_aftershock_condenser_outlet_clamp: Sprite2D = (
	get_node_or_null("FactoryLowerDeckForwardPressureAftershockCondenserOutletClamp")
		as Sprite2D
)
@onready var _lower_deck_forward_pressure_aftershock_condenser_drain_gantry: Sprite2D = (
	get_node_or_null("FactoryLowerDeckForwardPressureAftershockCondenserDrainGantry")
		as Sprite2D
)
@onready var _lower_deck_forward_pressure_aftershock_condenser_overflow_pump: Sprite2D = (
	get_node_or_null("FactoryLowerDeckForwardPressureAftershockCondenserOverflowPump")
		as Sprite2D
)
@onready var _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_exit_hatch: Node = (
	get_node_or_null("FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpExitHatch")
)
@onready var _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_gate: Node = (
	get_node_or_null("FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffExitGate")
)
@onready var _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_hatch: Node = (
	get_node_or_null(
		"FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffOutletServiceHatch"
	)
)
@onready var _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_duct: Sprite2D = (
	get_node_or_null(
		"FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffOutletServiceSluiceDuct"
	)
		as Sprite2D
)
@onready var _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_vent: Node = (
	get_node_or_null(
		"FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffOutletServiceSluiceSteamVent"
	)
)
@onready var _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_duct: Sprite2D = (
	get_node_or_null(
		"FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffOutletDuct"
	)
		as Sprite2D
)
@onready var _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_vent: Node = (
	get_node_or_null(
		"FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffOutletSteamVent"
	)
)
@onready var _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_duct: Sprite2D = (
	get_node_or_null("FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffDuct")
		as Sprite2D
)
@onready var _steam_vent: Area2D = get_node_or_null("FactorySteamVentHazard") as Area2D
@onready var _checkpoint_steam_vent: Area2D = (
	get_node_or_null("FactoryCheckpointSteamVentHazard") as Area2D
)
@onready var _lower_deck_steam_vent: Area2D = (
	get_node_or_null("FactoryLowerDeckSteamVentHazard") as Area2D
)
@onready var _lower_deck_steam_sluice_hazard: Area2D = (
	get_node_or_null("FactoryLowerDeckSteamSluiceHazard") as Area2D
)
@onready var _lower_deck_breach_steam_hazard: Area2D = (
	get_node_or_null("FactoryLowerDeckBreachSteamHazard") as Area2D
)
@onready var _lower_deck_post_relay_steam_hazard: Area2D = (
	get_node_or_null("FactoryLowerDeckPostRelaySteamHazard") as Area2D
)
@onready var _lower_deck_forward_conduit_steam_hazard: Area2D = (
	get_node_or_null("FactoryLowerDeckForwardConduitSteamHazard") as Area2D
)
@onready var _lower_deck_forward_pressure_vent: Area2D = (
	get_node_or_null("FactoryLowerDeckForwardPressureVent") as Area2D
)
@onready var _lower_deck_forward_counter_pressure_vent: Area2D = (
	get_node_or_null("FactoryLowerDeckForwardCounterPressureVent") as Area2D
)
@onready var _lower_deck_forward_exit_guard_pressure_vent: Area2D = (
	get_node_or_null("FactoryLowerDeckForwardPressureExitGuardVent") as Area2D
)
@onready var _lower_deck_forward_beacon_ambush_pressure_vent: Area2D = (
	get_node_or_null("FactoryLowerDeckForwardPressureBeaconAmbushVent") as Area2D
)
@onready var _lower_deck_forward_overrun_pressure_vent: Area2D = (
	get_node_or_null("FactoryLowerDeckForwardPressureOverrunVent") as Area2D
)
@onready var _lower_deck_forward_breaker_pressure_vent: Area2D = (
	get_node_or_null("FactoryLowerDeckForwardPressureBreakerVent") as Area2D
)
@onready var _lower_deck_forward_relief_ambush_pressure_vent: Area2D = (
	get_node_or_null("FactoryLowerDeckForwardPressureReliefVent") as Area2D
)
@onready var _lower_deck_forward_pressure_aftershock_exhaust_vent: Area2D = (
	get_node_or_null("FactoryLowerDeckForwardPressureAftershockExhaustVent") as Area2D
)
@onready var _lower_deck_forward_pressure_aftershock_exhaust_flank_vent: Area2D = (
	get_node_or_null(
		"FactoryLowerDeckForwardPressureAftershockExhaustFlankAmbushVent"
	) as Area2D
)
@onready var _lower_deck_forward_pressure_aftershock_exhaust_breaker_vent: Area2D = (
	get_node_or_null(
		"FactoryLowerDeckForwardPressureAftershockExhaustBreakerVent"
	) as Area2D
)
@onready var _lower_deck_forward_pressure_aftershock_cooling_duct_vent: Area2D = (
	get_node_or_null("FactoryLowerDeckForwardPressureAftershockCoolingDuctVent")
		as Area2D
)
@onready var _lower_deck_forward_pressure_aftershock_condenser_outlet_vent: Area2D = (
	get_node_or_null("FactoryLowerDeckForwardPressureAftershockCondenserOutletVent")
		as Area2D
)
@onready var _lower_deck_forward_pressure_aftershock_condenser_drip_vent: Area2D = (
	get_node_or_null("FactoryLowerDeckForwardPressureAftershockCondenserOutletDripVentHazard")
		as Area2D
)
@onready var _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_duct_vent: Area2D = (
	get_node_or_null("FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffSteamVent")
		as Area2D
)
@onready var _deep_endpoint: Node = get_node_or_null("FactoryDeepRouteEndpoint")
@onready var _service_lift: Node = get_node_or_null("FactoryServiceLift")
@onready var _post_bulkhead_background: TextureRect = (
	get_node_or_null("PostBulkheadBackground") as TextureRect
)

var _last_player_hit_metadata: Dictionary = {}
var _last_cache_reward: Dictionary = {}
var _last_cache_claim_feedback: Dictionary = {}
var _last_return_patrol_reward_cache_reward: Dictionary = {}
var _last_return_patrol_reward_cache_claim_feedback: Dictionary = {}
var _last_checkpoint_overdrive_reward_cache_reward: Dictionary = {}
var _last_checkpoint_overdrive_reward_cache_claim_feedback: Dictionary = {}
var _last_lower_deck_reward_cache_reward: Dictionary = {}
var _last_lower_deck_reward_cache_claim_feedback: Dictionary = {}
var _last_lower_deck_shortcut_reward_cache_reward: Dictionary = {}
var _last_lower_deck_shortcut_reward_cache_claim_feedback: Dictionary = {}
var _last_lower_deck_relay_forward_reward_cache_reward: Dictionary = {}
var _last_lower_deck_relay_forward_reward_cache_claim_feedback: Dictionary = {}
var _last_lower_deck_forward_pressure_reward_cache_reward: Dictionary = {}
var _last_lower_deck_forward_pressure_reward_cache_claim_feedback: Dictionary = {}
var _last_lower_deck_forward_pressure_aftershock_reward_cache_reward: Dictionary = {}
var _last_lower_deck_forward_pressure_aftershock_reward_cache_claim_feedback: Dictionary = {}
var _last_lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache_reward: Dictionary = {}
var _last_lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache_claim_feedback: Dictionary = {}
var _last_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_reward_cache_reward: Dictionary = {}
var _last_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_reward_cache_claim_feedback: Dictionary = {}
var _last_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_reward_cache_reward: Dictionary = {}
var _last_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_reward_cache_claim_feedback: Dictionary = {}
var _last_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_reward_cache_reward: Dictionary = {}
var _last_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_reward_cache_claim_feedback: Dictionary = {}
var _last_checkpoint_overdrive_defeat_burst_side: StringName = &""
var _lower_deck_forward_conduit_clear_feedback_played: bool = false
var _lower_deck_forward_conduit_clear_feedback_spawn_count: int = 0
var _last_lower_deck_forward_conduit_clear_feedback_position: Vector2 = Vector2.ZERO
var _last_hazard_damage: Dictionary = {}
var _last_spark_rat_counter_diagnostics: Dictionary = {}
var _last_spark_rat_bite_sequence_id_resolved: int = -1
var _encounter_cleared: bool = false
var _cache_claimed: bool = false
var _deep_guard_activated: bool = false
var _deep_guard_defeated: bool = false
var _deep_route_cleared: bool = false
var _spark_rat_activated: bool = false
var _spark_rat_defeated: bool = false
var _return_patrol_activated: bool = false
var _return_patrol_defeated: bool = false
var _checkpoint_forward_patrol_activated: bool = false
var _checkpoint_forward_patrol_defeated: bool = false
var _checkpoint_rear_ambush_activated: bool = false
var _checkpoint_rear_ambush_defeated: bool = false
var _checkpoint_overdrive_duo_activated: bool = false
var _checkpoint_overdrive_left_defeated: bool = false
var _checkpoint_overdrive_right_defeated: bool = false
var _return_patrol_reward_cache_claimed: bool = false
var _checkpoint_overdrive_reward_cache_claimed: bool = false
var _lower_deck_skirmish_activated: bool = false
var _lower_deck_skirmish_defeated: bool = false
var _lower_deck_reward_cache_claimed: bool = false
var _lower_deck_parry_gate_unlocked: bool = false
var _lower_deck_exit_ambush_activated: bool = false
var _lower_deck_exit_ambush_defeated: bool = false
var _lower_deck_shortcut_activated: bool = false
var _lower_deck_shortcut_guard_defeated: bool = false
var _lower_deck_shortcut_unlocked: bool = false
var _lower_deck_shortcut_reward_cache_claimed: bool = false
var _lower_deck_shortcut_pursuer_activated: bool = false
var _lower_deck_shortcut_pursuer_defeated: bool = false
var _lower_deck_pressure_guard_activated: bool = false
var _lower_deck_pressure_guard_defeated: bool = false
var _lower_deck_pressure_valve_opened: bool = false
var _lower_deck_steam_sluice_activated: bool = false
var _lower_deck_steam_sluice_defeated: bool = false
var _lower_deck_deep_bulkhead_guard_activated: bool = false
var _lower_deck_deep_bulkhead_guard_defeated: bool = false
var _lower_deck_deep_bulkhead_opened: bool = false
var _lower_deck_breach_corridor_activated: bool = false
var _lower_deck_breach_front_guard_defeated: bool = false
var _lower_deck_breach_rear_ambusher_activated: bool = false
var _lower_deck_breach_rear_ambusher_defeated: bool = false
var _lower_deck_breach_corridor_secured: bool = false
var _lower_deck_breach_relay_activated: bool = false
var _lower_deck_breach_relay_activation_audio_event: Dictionary = {}
var _lower_deck_breach_relay_activation_audio_request_count: int = 0
var _lower_deck_post_relay_trial_activated: bool = false
var _lower_deck_post_relay_trial_defeated: bool = false
var _lower_deck_relay_forward_reward_cache_claimed: bool = false
var _lower_deck_forward_hatch_opened: bool = false
var _lower_deck_forward_conduit_activated: bool = false
var _lower_deck_forward_conduit_defeated: bool = false
var _lower_deck_forward_pressure_traverse_active: bool = false
var _lower_deck_forward_pressure_traverse_crossed: bool = false
var _lower_deck_forward_pressure_traverse_elapsed_sec: float = 0.0
var _lower_deck_forward_pressure_counter_ambush_activated: bool = false
var _lower_deck_forward_pressure_counter_ambush_defeated: bool = false
var _lower_deck_forward_pressure_reward_cache_claimed: bool = false
var _lower_deck_forward_pressure_reward_cache_claim_audio_event: Dictionary = {}
var _lower_deck_forward_pressure_reward_cache_claim_audio_request_count: int = 0
var _lower_deck_forward_pressure_exit_guard_activated: bool = false
var _lower_deck_forward_pressure_exit_guard_defeated: bool = false
var _lower_deck_forward_pressure_exit_relay_activated: bool = false
var _lower_deck_forward_pressure_exit_gate_opened: bool = false
var _lower_deck_forward_pressure_route_handoff_marker_lit: bool = false
var _lower_deck_forward_pressure_beacon_ambush_activated: bool = false
var _lower_deck_forward_pressure_beacon_ambush_defeated: bool = false
var _lower_deck_forward_pressure_overrun_activated: bool = false
var _lower_deck_forward_pressure_overrun_defeated: bool = false
var _lower_deck_forward_pressure_breaker_activated: bool = false
var _lower_deck_forward_pressure_breaker_secured: bool = false
var _lower_deck_forward_pressure_breaker_cut: bool = false
var _lower_deck_forward_pressure_relief_ambush_activated: bool = false
var _lower_deck_forward_pressure_relief_ambush_defeated: bool = false
var _lower_deck_forward_pressure_coil_rat_activated: bool = false
var _lower_deck_forward_pressure_coil_rat_defeated: bool = false
var _lower_deck_forward_pressure_coil_pincer_activated: bool = false
var _lower_deck_forward_pressure_coil_pincer_spark_rat_defeated: bool = false
var _lower_deck_forward_pressure_coil_pincer_coil_rat_defeated: bool = false
var _lower_deck_forward_pressure_coil_aftershock_activated: bool = false
var _lower_deck_forward_pressure_coil_aftershock_defeated: bool = false
var _lower_deck_forward_pressure_aftershock_reward_cache_claimed: bool = false
var _lower_deck_forward_pressure_aftershock_exit_skirmish_activated: bool = false
var _lower_deck_forward_pressure_aftershock_exit_spark_rat_defeated: bool = false
var _lower_deck_forward_pressure_aftershock_exit_coil_rat_defeated: bool = false
var _lower_deck_forward_pressure_aftershock_exhaust_activated: bool = false
var _lower_deck_forward_pressure_aftershock_exhaust_crossed: bool = false
var _lower_deck_forward_pressure_aftershock_exhaust_elapsed_sec: float = 0.0
var _lower_deck_forward_pressure_aftershock_exhaust_pursuer_activated: bool = false
var _lower_deck_forward_pressure_aftershock_exhaust_pursuer_defeated: bool = false
var _lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache_claimed: bool = false
var _lower_deck_forward_pressure_aftershock_exhaust_flank_activated: bool = false
var _lower_deck_forward_pressure_aftershock_exhaust_flank_spark_rat_defeated: bool = false
var _lower_deck_forward_pressure_aftershock_exhaust_breaker_activated: bool = false
var _lower_deck_forward_pressure_aftershock_exhaust_breaker_coil_rat_defeated: bool = false
var _lower_deck_forward_pressure_aftershock_exhaust_breaker_secured: bool = false
var _lower_deck_forward_pressure_aftershock_exhaust_breaker_cut: bool = false
var _lower_deck_forward_pressure_aftershock_exhaust_escape_skirmish_activated: bool = false
var _lower_deck_forward_pressure_aftershock_exhaust_escape_spark_rat_defeated: bool = false
var _lower_deck_forward_pressure_aftershock_exhaust_escape_coil_rat_defeated: bool = false
var _lower_deck_forward_pressure_aftershock_exhaust_exit_hatch_opened: bool = false
var _lower_deck_forward_pressure_aftershock_cooling_duct_activated: bool = false
var _lower_deck_forward_pressure_aftershock_cooling_duct_crossed: bool = false
var _lower_deck_forward_pressure_aftershock_cooling_duct_elapsed_sec: float = 0.0
var _lower_deck_forward_pressure_aftershock_condenser_valve_activated: bool = false
var _lower_deck_forward_pressure_aftershock_condenser_valve_spark_rat_defeated: bool = false
var _lower_deck_forward_pressure_aftershock_condenser_valve_coil_rat_defeated: bool = false
var _lower_deck_forward_pressure_aftershock_condenser_savepoint_activated: bool = false
var _lower_deck_forward_pressure_aftershock_condenser_outlet_activated: bool = false
var _lower_deck_forward_pressure_aftershock_condenser_outlet_crossed: bool = false
var _lower_deck_forward_pressure_aftershock_condenser_outlet_elapsed_sec: float = 0.0
var _lower_deck_forward_pressure_aftershock_condenser_outlet_clamp_ambush_activated: bool = false
var _lower_deck_forward_pressure_aftershock_condenser_outlet_clamp_spark_rat_defeated: bool = false
var _lower_deck_forward_pressure_aftershock_condenser_drip_vent_activated: bool = false
var _lower_deck_forward_pressure_aftershock_condenser_drip_vent_crossed: bool = false
var _lower_deck_forward_pressure_aftershock_condenser_drip_vent_elapsed_sec: float = 0.0
var _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_activated: bool = false
var _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_coil_rat_defeated: bool = false
var _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_reward_cache_claimed: bool = false
var _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_exit_hatch_opened: bool = false
var _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_duct_activated: bool = false
var _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_duct_crossed: bool = false
var _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_duct_elapsed_sec: float = 0.0
var _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_skirmish_activated: bool = false
var _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_coil_rat_defeated: bool = false
var _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_reward_cache_claimed: bool = false
var _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_gate_opened: bool = false
var _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_activated: bool = false
var _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_crossed: bool = false
var _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_elapsed_sec: float = 0.0
var _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_skirmish_activated: bool = false
var _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_spark_rat_defeated: bool = false
var _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_reward_cache_claimed: bool = false
var _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_hatch_opened: bool = false
var _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_activated: bool = false
var _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_crossed: bool = false
var _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_elapsed_sec: float = 0.0
var _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_skirmish_activated: bool = false
var _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_spark_rat_defeated: bool = false
var _return_checkpoint_activated: bool = false
var _last_return_checkpoint: Dictionary = {}
var _service_lift_activated: bool = false
var _service_lift_exit_requested: bool = false
var _last_service_lift_exit_rejected_reason: StringName = &""
var _last_service_lift_exit_request: Dictionary = {}
var _factory_hazard_elapsed_sec: float = 0.0
var _factory_hazard_contact_cooldowns: Dictionary = {}
var _factory_hazard_respawn_grace_frames: int = 0
var _factory_return_checkpoint_spawn_snap_frames: int = 0
var _factory_game_flow: GameFlowController = null
var _weapon_component: WeaponComponent = null
var _scene_manager: Object = null


func _ready() -> void:
	_setup_weapon_component()
	_align_player_to_spawn()
	_bind_enemy_to_player()
	_setup_factory_cache()
	_setup_factory_return_patrol_reward_cache()
	_setup_factory_checkpoint_overdrive_reward_cache()
	_setup_factory_lower_deck_reward_cache()
	_setup_factory_lower_deck_parry_gate()
	_setup_factory_lower_deck_shortcut_seal()
	_setup_factory_lower_deck_shortcut_reward_cache()
	_sync_lower_deck_shortcut_pursuer_state()
	_setup_factory_lower_deck_pressure_valve()
	_sync_lower_deck_steam_sluice_state()
	_setup_factory_lower_deck_deep_bulkhead()
	_sync_lower_deck_breach_corridor_state()
	_setup_factory_lower_deck_breach_relay()
	_sync_lower_deck_post_relay_trial_state()
	_setup_factory_lower_deck_relay_forward_reward_cache()
	_setup_factory_lower_deck_forward_pressure_reward_cache()
	_setup_factory_lower_deck_forward_hatch()
	_reset_lower_deck_forward_conduit_clear_feedback()
	_sync_lower_deck_forward_conduit_state()
	_sync_lower_deck_forward_pressure_traverse_state()
	_sync_lower_deck_forward_pressure_counter_ambush_state()
	_sync_lower_deck_forward_pressure_exit_guard_state()
	_setup_factory_lower_deck_forward_pressure_exit_relay()
	_setup_factory_lower_deck_forward_pressure_exit_gate()
	_setup_factory_lower_deck_forward_pressure_route_handoff_marker()
	_sync_lower_deck_forward_pressure_beacon_ambush_state()
	_sync_lower_deck_forward_pressure_overrun_state()
	_setup_factory_lower_deck_forward_pressure_breaker()
	_sync_lower_deck_forward_pressure_relief_ambush_state()
	_sync_lower_deck_forward_pressure_coil_rat_state()
	_sync_lower_deck_forward_pressure_coil_pincer_state()
	_sync_lower_deck_forward_pressure_coil_aftershock_state()
	_setup_factory_lower_deck_forward_pressure_aftershock_reward_cache()
	_sync_lower_deck_forward_pressure_aftershock_exit_skirmish_state()
	_sync_lower_deck_forward_pressure_aftershock_exhaust_state()
	_sync_lower_deck_forward_pressure_aftershock_exhaust_pursuer_state()
	_setup_factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache()
	_sync_lower_deck_forward_pressure_aftershock_exhaust_flank_state()
	_setup_factory_lower_deck_forward_pressure_aftershock_exhaust_breaker()
	_sync_lower_deck_forward_pressure_aftershock_exhaust_escape_skirmish_state()
	_setup_factory_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch()
	_sync_lower_deck_forward_pressure_aftershock_cooling_duct_state()
	_sync_lower_deck_forward_pressure_aftershock_condenser_valve_state()
	_setup_factory_lower_deck_forward_pressure_aftershock_condenser_savepoint()
	_sync_lower_deck_forward_pressure_aftershock_condenser_outlet_state()
	_sync_outlet_clamp_ambush_state()
	_sync_outlet_drip_vent_state()
	_sync_overflow_pump_state()
	_sync_overflow_pump_reward_cache_state()
	_sync_overflow_pump_exit_hatch_state()
	_sync_overflow_pump_runoff_duct_state()
	_sync_overflow_pump_runoff_exit_skirmish_state()
	_sync_overflow_pump_runoff_outlet_state()
	_sync_overflow_pump_runoff_outlet_skirmish_state()
	_sync_overflow_pump_runoff_outlet_reward_cache_state()
	_sync_overflow_pump_runoff_outlet_service_hatch_state()
	_sync_overflow_pump_runoff_outlet_service_sluice_state()
	_sync_overflow_pump_runoff_outlet_service_sluice_skirmish_state()
	_setup_factory_return_checkpoint()
	_setup_factory_hazards()
	_setup_factory_deep_route()
	_setup_factory_spark_rat()
	_setup_factory_service_lift()
	_setup_factory_respawn_flow()
	_bind_player_combat_to_room()
	_refresh_factory_route_objective()
	_request_factory_audio()


func _process(_delta: float) -> void:
	_factory_hazard_respawn_grace_frames = maxi(_factory_hazard_respawn_grace_frames - 1, 0)
	_snap_return_checkpoint_spawn_if_needed()
	_try_auto_activate_checkpoint_forward_patrol()
	_try_auto_activate_checkpoint_rear_ambush()
	_try_auto_activate_checkpoint_overdrive_duo()
	_try_auto_activate_forward_pressure_beacon_ambush()
	_try_auto_activate_forward_pressure_overrun()
	_try_auto_activate_forward_pressure_breaker()
	_try_auto_activate_forward_pressure_relief_ambush()
	_try_auto_activate_forward_pressure_coil_rat_breakthrough()
	_try_auto_activate_forward_pressure_coil_pincer()
	_try_auto_activate_forward_pressure_coil_aftershock()
	_try_auto_activate_forward_pressure_aftershock_exit_skirmish()
	_try_auto_activate_forward_pressure_aftershock_exhaust()
	_try_auto_activate_forward_pressure_aftershock_exhaust_pursuer()
	_try_auto_activate_forward_pressure_aftershock_exhaust_flank()
	_try_auto_activate_forward_pressure_aftershock_exhaust_breaker()
	_try_auto_activate_forward_pressure_aftershock_exhaust_escape_skirmish()
	_try_auto_activate_forward_pressure_aftershock_cooling_duct()
	_try_auto_complete_forward_pressure_aftershock_cooling_duct()
	_try_auto_activate_forward_pressure_aftershock_condenser_valve()
	_auto_activate_condenser_outlet()
	_auto_complete_condenser_outlet()
	_auto_activate_outlet_clamp_ambush()
	_auto_activate_outlet_drip_vent()
	advance_factory_lower_deck_forward_pressure_aftershock_condenser_outlet_drip_vent_time(
		_delta
	)
	_auto_complete_outlet_drip_vent()
	_auto_activate_overflow_pump()
	_auto_activate_overflow_pump_runoff_exit_skirmish()
	_auto_activate_overflow_pump_runoff_outlet()
	advance_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_time(
		_delta
	)
	_auto_complete_overflow_pump_runoff_outlet()
	_auto_activate_overflow_pump_runoff_outlet_skirmish()
	_auto_activate_overflow_pump_runoff_outlet_service_sluice()
	advance_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_time(
		_delta
	)
	_auto_complete_overflow_pump_runoff_outlet_service_sluice()
	_auto_activate_overflow_pump_runoff_outlet_service_sluice_skirmish()
	_sync_factory_player_control_lock()


func calculate_damage(
	_attack_type: StringName,
	_weapon_id: StringName,
	_hit_frame: int,
	combo_index: int,
	_parry_timing: int,
	_attack_power: int,
	_enemy_defense: int,
	_skill_modifiers: Dictionary = {},
	_injected_damage_params: Dictionary = {},
	_data_manager: Object = null
) -> Dictionary:
	return {
		"final_damage": FACTORY_PLAYER_LIGHT_DAMAGE,
		"base_damage": FACTORY_PLAYER_LIGHT_DAMAGE,
		"attack_damage": float(FACTORY_PLAYER_LIGHT_DAMAGE),
		"reduction_factor": 1.0,
		"damage_multiplier": 1.0,
		"is_crit": false,
		"crit_type": &"none",
		"parry_type": &"none",
		"combo_stage": combo_index,
		"damage_category": &"scratch",
	}


func apply_damage(target_id: int, final_damage: int, metadata: Dictionary = {}) -> bool:
	var damage_target: Node = _get_factory_enemy_by_entity_id(target_id)
	if damage_target == null or not damage_target.has_method("apply_damage"):
		return false
	damage_target.call("apply_damage", final_damage, metadata)
	_sync_factory_damage_target_defeat(target_id, damage_target)
	return true


func get_last_player_hit_metadata() -> Dictionary:
	return _last_player_hit_metadata.duplicate(true)


## Returns whether the Factory entrance combat encounter has been cleared.
func is_encounter_cleared() -> bool:
	return _encounter_cleared


## Returns whether the Factory entrance combat cache was already claimed.
func is_factory_cache_claimed() -> bool:
	return _cache_claimed


## Returns whether the deeper Old Factory route endpoint was activated.
func is_factory_deep_route_cleared() -> bool:
	return _deep_route_cleared


## Returns whether the deeper Old Factory guard has been alerted.
func is_factory_deep_guard_activated() -> bool:
	return _deep_guard_activated


## Returns whether the Factory spark rat patrol enemy has been defeated.
func is_factory_spark_rat_defeated() -> bool:
	return _spark_rat_defeated


## Returns whether the authored Factory Route objective chain is complete.
func is_factory_route_objective_complete() -> bool:
	var objective_id: StringName = _get_factory_route_objective_id()
	return (
		objective_id == FACTORY_OBJECTIVE_ROUTE_CLEARED
		or objective_id == FACTORY_OBJECTIVE_RETURN_PATROL_CLEARED
		or objective_id == FACTORY_OBJECTIVE_CHECKPOINT_OVERDRIVE_DUO_CLEARED
		or objective_id == FACTORY_OBJECTIVE_LOWER_DECK_CLEARED
		or objective_id == FACTORY_OBJECTIVE_LOWER_DECK_EXIT_CLEARED
		or objective_id == FACTORY_OBJECTIVE_LOWER_DECK_SHORTCUT_OPENED
		or objective_id == FACTORY_OBJECTIVE_PRESSURE_VALVE_OPENED
		or objective_id == FACTORY_OBJECTIVE_STEAM_SLUICE_CLEARED
		or objective_id == FACTORY_OBJECTIVE_CLEAR_DEEP_BULKHEAD_GUARD
		or objective_id == FACTORY_OBJECTIVE_OPEN_DEEP_BULKHEAD
		or objective_id == FACTORY_OBJECTIVE_DEEP_BULKHEAD_OPENED
		or objective_id == FACTORY_OBJECTIVE_BREACH_CORRIDOR_SECURED
		or objective_id == FACTORY_OBJECTIVE_BREACH_RELAY_SECURED
		or objective_id == FACTORY_OBJECTIVE_POST_RELAY_TRIAL_SECURED
		or objective_id == FACTORY_OBJECTIVE_FORWARD_HATCH_OPENED
		or objective_id == FACTORY_OBJECTIVE_FORWARD_PRESSURE_AMBUSH_CLEARED
		or objective_id == FACTORY_OBJECTIVE_FORWARD_PRESSURE_EXIT_SECURED
		or objective_id == FACTORY_OBJECTIVE_FORWARD_PRESSURE_BEACON_AMBUSH_CLEARED
		or objective_id == FACTORY_OBJECTIVE_FORWARD_PRESSURE_OVERRUN_CLEARED
		or objective_id == FACTORY_OBJECTIVE_FORWARD_PRESSURE_BREAKER_CUT
		or objective_id == FACTORY_OBJECTIVE_FORWARD_PRESSURE_RELIEF_AMBUSH_CLEARED
		or objective_id == FACTORY_OBJECTIVE_FORWARD_PRESSURE_COIL_RAT_CLEARED
		or objective_id == FACTORY_OBJECTIVE_FORWARD_PRESSURE_COIL_PINCER_CLEARED
		or objective_id == FACTORY_OBJECTIVE_FORWARD_PRESSURE_COIL_AFTERSHOCK_CLEARED
		or objective_id == FACTORY_OBJECTIVE_FORWARD_PRESSURE_AFTERSHOCK_CACHE_CLAIMED
		or objective_id == FACTORY_OBJECTIVE_FORWARD_PRESSURE_AFTERSHOCK_EXIT_SKIRMISH_CLEARED
		or objective_id == FACTORY_OBJECTIVE_FORWARD_PRESSURE_AFTERSHOCK_EXHAUST_CROSSED
		or objective_id == FACTORY_OBJECTIVE_FORWARD_PRESSURE_AFTERSHOCK_EXHAUST_PURSUER_CLEARED
		or objective_id == FACTORY_OBJECTIVE_FORWARD_PRESSURE_AFTERSHOCK_EXHAUST_PURSUER_CACHE_CLAIMED
		or objective_id == FACTORY_OBJECTIVE_FORWARD_PRESSURE_AFTERSHOCK_EXHAUST_FLANK_CLEARED
		or objective_id == FACTORY_OBJECTIVE_FORWARD_PRESSURE_AFTERSHOCK_EXHAUST_BREAKER_CUT
		or objective_id == FACTORY_OBJECTIVE_FORWARD_PRESSURE_AFTERSHOCK_EXHAUST_ESCAPE_SECURED
		or objective_id == FACTORY_OBJECTIVE_FORWARD_PRESSURE_AFTERSHOCK_EXHAUST_EXIT_OPENED
		or objective_id == FACTORY_OBJECTIVE_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_SAVEPOINT_SECURED
		or objective_id == FACTORY_OBJECTIVE_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_OUTLET_CROSSED
		or objective_id == FACTORY_OBJECTIVE_FORWARD_PRESSURE_AFTERSHOCK_OUTLET_CLAMP_AMBUSH_CLEARED
		or objective_id == FACTORY_OBJECTIVE_FORWARD_PRESSURE_AFTERSHOCK_OUTLET_DRIP_VENT_CROSSED
		or objective_id == FACTORY_OBJECTIVE_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_CLEARED
		or objective_id == FACTORY_OBJECTIVE_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_CACHE_CLAIMED
		or objective_id == FACTORY_OBJECTIVE_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_EXIT_HATCH_OPENED
		or objective_id == FACTORY_OBJECTIVE_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_RUNOFF_DUCT_CROSSED
		or objective_id == FACTORY_OBJECTIVE_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_RUNOFF_EXIT_CLEARED
		or objective_id == FACTORY_OBJECTIVE_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_RUNOFF_EXIT_GATE_OPENED
				or objective_id == FACTORY_OBJECTIVE_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_RUNOFF_OUTLET_CROSSED
				or objective_id == FACTORY_OBJECTIVE_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_RUNOFF_OUTLET_SKIRMISH_CLEARED
				or objective_id == FACTORY_OBJECTIVE_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_RUNOFF_OUTLET_SERVICE_SLUICE_CROSSED
				or objective_id == FACTORY_OBJECTIVE_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_RUNOFF_OUTLET_SERVICE_SLUICE_SKIRMISH_CLEARED
			)


## Returns whether the post-route service lift handoff has been activated.
func is_factory_service_lift_activated() -> bool:
	return _service_lift_activated


## Returns whether the one-time Factory return patrol has been cleared.
func is_factory_return_patrol_defeated() -> bool:
	return _return_patrol_defeated


## Returns whether the checkpoint-forward patrol has been cleared.
func is_factory_checkpoint_forward_patrol_defeated() -> bool:
	return _checkpoint_forward_patrol_defeated


## Returns whether the checkpoint rear ambush has been cleared.
func is_factory_checkpoint_rear_ambush_defeated() -> bool:
	return _checkpoint_rear_ambush_defeated


## Returns whether the checkpoint overdrive duo has been cleared.
func is_factory_checkpoint_overdrive_duo_cleared() -> bool:
	return _is_checkpoint_overdrive_duo_cleared()


## Returns whether the optional lower-deck skirmish has been cleared.
func is_factory_lower_deck_skirmish_defeated() -> bool:
	return _lower_deck_skirmish_defeated


## Attempts to activate the Old Factory return checkpoint after the return patrol is clear.
func try_activate_factory_return_checkpoint(provider: Node = null) -> bool:
	if _return_checkpoint == null or not _return_patrol_defeated:
		return false
	var activation_provider: Node = provider
	if activation_provider == null:
		activation_provider = _player
	if not _is_return_checkpoint_provider_in_range(activation_provider):
		return false
	if not _return_checkpoint.has_method("try_activate"):
		return false
	if not bool(_return_checkpoint.call("try_activate", activation_provider)):
		return false
	_return_checkpoint_activated = true
	_sync_return_checkpoint_state()
	if _last_return_checkpoint.is_empty():
		_last_return_checkpoint = _build_return_checkpoint_snapshot(
			FACTORY_RETURN_CHECKPOINT_ID,
			FACTORY_SCENE_ID,
			FACTORY_RETURN_CHECKPOINT_SPAWN_POINT,
			(_return_checkpoint as Node2D).global_position
				if _return_checkpoint is Node2D
				else Vector2.ZERO,
			{}
		)
	_update_route_label("Factory Savepoint Secured")
	return true


## Attempts to trigger the checkpoint-forward patrol after the return checkpoint is active.
func try_activate_factory_checkpoint_forward_patrol(provider: Node = null) -> bool:
	if (
		_checkpoint_forward_spark_rat == null
		or not _return_checkpoint_activated
		or _checkpoint_forward_patrol_defeated
		or _checkpoint_forward_patrol_activated
	):
		return false
	var activation_provider: Node = provider if provider != null else _player
	if not _is_checkpoint_forward_patrol_activation_provider_in_range(activation_provider):
		return false
	_checkpoint_forward_patrol_activated = true
	_service_lift_activated = false
	_service_lift_exit_requested = false
	_last_service_lift_exit_request = {}
	_last_service_lift_exit_rejected_reason = &""
	_sync_checkpoint_forward_patrol_state()
	_sync_service_lift_state()
	_set_checkpoint_forward_spark_rat_attack_target(activation_provider)
	_begin_checkpoint_forward_spark_rat_pacing(FACTORY_SPARK_RAT_OPENING_GRACE_FRAMES)
	_refresh_factory_route_objective()
	return true


## Attempts to activate the post-vent checkpoint rear ambush.
func try_activate_factory_checkpoint_rear_ambush(provider: Node = null) -> bool:
	if (
		_checkpoint_rear_spark_rat == null
		or not _checkpoint_forward_patrol_defeated
		or _checkpoint_rear_ambush_defeated
		or _checkpoint_rear_ambush_activated
	):
		return false
	var activation_provider: Node = provider if provider != null else _player
	if not _is_checkpoint_rear_ambush_activation_provider_in_range(activation_provider):
		return false
	_checkpoint_rear_ambush_activated = true
	_service_lift_activated = false
	_service_lift_exit_requested = false
	_last_service_lift_exit_request = {}
	_last_service_lift_exit_rejected_reason = &""
	_sync_checkpoint_rear_ambush_state()
	_sync_service_lift_state()
	_set_checkpoint_rear_spark_rat_attack_target(activation_provider)
	_begin_checkpoint_rear_spark_rat_pacing(FACTORY_SPARK_RAT_OPENING_GRACE_FRAMES)
	_refresh_factory_route_objective()
	return true


## Attempts to activate the final checkpoint overdrive duo before the service lift.
func try_activate_factory_checkpoint_overdrive_duo(provider: Node = null) -> bool:
	if (
		_checkpoint_overdrive_left_spark_rat == null
		or _checkpoint_overdrive_right_spark_rat == null
		or not _checkpoint_rear_ambush_defeated
		or _is_checkpoint_overdrive_duo_cleared()
		or _checkpoint_overdrive_duo_activated
	):
		return false
	var activation_provider: Node = provider if provider != null else _player
	if not _is_checkpoint_overdrive_duo_activation_provider_in_range(activation_provider):
		return false
	_checkpoint_overdrive_duo_activated = true
	_service_lift_activated = false
	_service_lift_exit_requested = false
	_last_service_lift_exit_request = {}
	_last_service_lift_exit_rejected_reason = &""
	_sync_checkpoint_overdrive_duo_state()
	_sync_service_lift_state()
	_set_checkpoint_overdrive_spark_rat_attack_targets(activation_provider)
	_begin_checkpoint_overdrive_spark_rat_pacing(
		FACTORY_CHECKPOINT_OVERDRIVE_LEFT_OPENING_GRACE_FRAMES,
		FACTORY_CHECKPOINT_OVERDRIVE_RIGHT_OPENING_GRACE_FRAMES
	)
	_refresh_factory_route_objective()
	return true


## Attempts to activate the optional lower-deck skirmish after the overdrive duo is clear.
func try_activate_factory_lower_deck_skirmish(provider: Node = null) -> bool:
	if (
		_lower_deck_spark_rat == null
		or not _is_checkpoint_overdrive_duo_cleared()
		or _lower_deck_skirmish_defeated
		or _lower_deck_skirmish_activated
	):
		return false
	var activation_provider: Node = provider if provider != null else _player
	if not _is_lower_deck_skirmish_activation_provider_in_range(activation_provider):
		return false
	_lower_deck_skirmish_activated = true
	_sync_lower_deck_skirmish_state()
	_sync_lower_deck_pressure_hazard_state()
	_sync_lower_deck_reward_cache_state()
	_set_lower_deck_spark_rat_attack_target(activation_provider)
	_begin_lower_deck_spark_rat_pacing(FACTORY_SPARK_RAT_OPENING_GRACE_FRAMES)
	_refresh_factory_route_objective()
	return true


## Activates the optional lower-deck exit ambush after the parry-laser gate opens.
func try_activate_factory_lower_deck_exit_ambush(provider: Node = null) -> bool:
	if (
		_lower_deck_exit_spark_rat == null
		or not _lower_deck_reward_cache_claimed
		or not _lower_deck_parry_gate_unlocked
		or _lower_deck_exit_ambush_defeated
		or _lower_deck_exit_ambush_activated
	):
		return false
	var activation_provider: Node = provider if provider != null else _player
	_lower_deck_exit_ambush_activated = true
	_sync_lower_deck_exit_ambush_state()
	_set_lower_deck_exit_spark_rat_attack_target(activation_provider)
	_begin_lower_deck_exit_spark_rat_pacing(FACTORY_SPARK_RAT_OPENING_GRACE_FRAMES)
	_refresh_factory_route_objective()
	return true


## Activates the optional lower-deck shortcut guard after the exit ambush is clear.
func try_activate_factory_lower_deck_shortcut_seal(provider: Node = null) -> bool:
	if (
		_lower_deck_shortcut_spark_rat == null
		or _lower_deck_shortcut_seal == null
		or not _lower_deck_exit_ambush_defeated
		or _lower_deck_shortcut_unlocked
		or _lower_deck_shortcut_guard_defeated
		or _lower_deck_shortcut_activated
	):
		return false
	var activation_provider: Node = provider if provider != null else _player
	if not _is_lower_deck_shortcut_activation_provider_in_range(activation_provider):
		return false
	_lower_deck_shortcut_activated = true
	_sync_lower_deck_shortcut_state()
	_set_lower_deck_shortcut_spark_rat_attack_target(activation_provider)
	_begin_lower_deck_shortcut_spark_rat_pacing(FACTORY_SPARK_RAT_OPENING_GRACE_FRAMES)
	_refresh_factory_route_objective()
	return true


## Opens the optional lower-deck shortcut seal after its guard is defeated.
func try_open_factory_lower_deck_shortcut_seal(provider: Node = null) -> bool:
	if (
		_lower_deck_shortcut_seal == null
		or not _lower_deck_shortcut_guard_defeated
		or _lower_deck_shortcut_unlocked
	):
		return false
	var activation_provider: Node = provider if provider != null else _player
	if (
		not _lower_deck_shortcut_seal.has_method("try_activate")
		or not bool(_lower_deck_shortcut_seal.call("try_activate", activation_provider))
	):
		return false
	_lower_deck_shortcut_unlocked = true
	_sync_lower_deck_shortcut_state()
	_sync_lower_deck_shortcut_reward_cache_state()
	_refresh_factory_route_objective()
	return true


func get_last_discovered_savepoint() -> Dictionary:
	return (
		_last_return_checkpoint.duplicate(true)
		if (
			_return_checkpoint_activated
			or _lower_deck_breach_relay_activated
			or _lower_deck_forward_pressure_exit_relay_activated
			or _lower_deck_forward_pressure_aftershock_condenser_savepoint_activated
		)
		else {}
	)


func clear_last_discovered_savepoint() -> bool:
	_return_checkpoint_activated = false
	_lower_deck_breach_relay_activated = false
	_lower_deck_forward_pressure_exit_relay_activated = false
	_lower_deck_forward_pressure_aftershock_condenser_savepoint_activated = false
	_last_return_checkpoint.clear()
	_sync_return_checkpoint_state()
	_sync_lower_deck_breach_relay_state()
	_sync_lower_deck_forward_pressure_exit_relay_state()
	_sync_lower_deck_forward_pressure_aftershock_condenser_savepoint_state()
	return true


## Attempts to alert the deep-route guard after the entrance encounter is clear.
func try_activate_factory_deep_guard(provider: Node = null) -> bool:
	if _deep_guard == null or _deep_guard_defeated or _deep_guard_activated:
		return false
	if not _encounter_cleared:
		return false
	var activation_provider: Node = provider
	if activation_provider == null:
		activation_provider = _player
	if not _is_deep_guard_activation_provider_in_range(activation_provider):
		return false
	_deep_guard_activated = true
	_sync_deep_route_state()
	_refresh_factory_route_objective()
	return true


## Attempts to activate the Factory spark rat after the deep route endpoint opens.
func try_activate_factory_spark_rat(provider: Node = null) -> bool:
	if _spark_rat == null or _spark_rat_defeated or _spark_rat_activated:
		return false
	if not _deep_route_cleared:
		return false
	var activation_provider: Node = provider
	if activation_provider == null:
		activation_provider = _player
	if not _is_spark_rat_activation_provider_in_range(activation_provider):
		return false
	_spark_rat_activated = true
	_sync_spark_rat_state()
	if activation_provider != null:
		_set_spark_rat_attack_target(activation_provider)
	_begin_spark_rat_pacing(FACTORY_SPARK_RAT_OPENING_GRACE_FRAMES)
	_refresh_factory_route_objective()
	return true


## Attempts to request the SceneManager-backed service lift exit after route clear.
func try_activate_factory_service_lift(provider: Node = null) -> bool:
	if _service_lift == null or _service_lift_activated or _service_lift_exit_requested:
		return false
	if not _spark_rat_defeated:
		_record_service_lift_exit_rejection(&"route_not_cleared")
		return false
	if _is_return_patrol_blocking_service_lift():
		_record_service_lift_exit_rejection(&"return_patrol_active")
		_sync_service_lift_state()
		return false
	if _is_checkpoint_forward_patrol_blocking_service_lift():
		_record_service_lift_exit_rejection(&"forward_patrol_active")
		_sync_service_lift_state()
		return false
	if _is_checkpoint_rear_ambush_blocking_service_lift():
		_record_service_lift_exit_rejection(&"rear_ambush_active")
		_sync_service_lift_state()
		return false
	if _is_checkpoint_overdrive_duo_blocking_service_lift():
		_record_service_lift_exit_rejection(&"overdrive_duo_active")
		_sync_service_lift_state()
		return false
	var activation_provider: Node = provider
	if activation_provider == null:
		activation_provider = _player
	if _service_lift.has_method("set_available"):
		_service_lift.call("set_available", true)
	if not _service_lift.has_method("try_activate"):
		_record_service_lift_exit_rejection(&"missing_service_lift_activation_api")
		return false
	if not _is_service_lift_activation_ready(_is_service_lift_available(), activation_provider):
		_record_service_lift_exit_rejection(&"provider_out_of_range")
		return false
	if not _request_service_lift_scene_exit():
		return false
	var activated: bool = bool(_service_lift.call("try_activate", activation_provider))
	if not activated:
		_record_service_lift_exit_rejection(&"service_lift_activation_rejected")
		return false
	_service_lift_activated = true
	_sync_service_lift_state()
	_update_route_label("Service Lift Departing")
	return true


## Injects or refreshes the SceneManager adapter used by the service lift exit.
func configure_scene_manager_runtime(scene_manager: Object) -> bool:
	_scene_manager = scene_manager
	var valid_scene_manager: bool = _is_valid_scene_manager(_scene_manager)
	_configure_factory_respawn_scene_transition()
	if valid_scene_manager:
		_apply_current_scene_manager_spawn_point()
	return valid_scene_manager


## Advances the Factory-owned respawn flow deterministically for tests and MCP probes.
func advance_factory_respawn_flow(delta_sec: float) -> void:
	if _factory_game_flow == null or not is_instance_valid(_factory_game_flow):
		return
	_factory_game_flow.advance_time(delta_sec)
	_sync_factory_player_control_lock()


## Returns deterministic Factory respawn-flow diagnostics for tests and MCP probes.
func get_factory_respawn_flow_diagnostics() -> Dictionary:
	if _factory_game_flow == null or not is_instance_valid(_factory_game_flow):
		return {
			"present": false,
			"state": "",
			"control_locked": false,
			"invincibility_remaining": 0.0,
			"last_selected_respawn_point": {},
		}
	return {
		"present": true,
		"state": String(_factory_game_flow.get_flow_state()),
		"control_locked": _factory_game_flow.is_player_control_locked(),
		"invincibility_remaining": _factory_game_flow.get_invincibility_remaining(),
		"last_selected_respawn_point": _factory_game_flow.get_last_selected_respawn_point(),
	}


## Resolves the active Factory Spark Rat bite against the current player dodge state.
func resolve_factory_spark_rat_bite_against_player() -> Dictionary:
	var result: Dictionary = {
		"resolved": false,
		"dodged": false,
		"damage_applied": false,
		"damage": 0,
		"weapon_id": &"",
		"source": &"",
	}
	if _spark_rat == null or _player == null or not _spark_rat_activated or _spark_rat_defeated:
		_record_spark_rat_counter_result(result)
		return result.duplicate(true)
	var attack_sequence_id: int = _get_spark_rat_attack_sequence_id()
	if (
		not _is_spark_rat_attack_active()
		or attack_sequence_id <= 0
		or attack_sequence_id == _last_spark_rat_bite_sequence_id_resolved
	):
		result["attack_active"] = _is_spark_rat_attack_active()
		result["attack_sequence_id"] = attack_sequence_id
		result["already_resolved"] = attack_sequence_id == _last_spark_rat_bite_sequence_id_resolved
		if bool(result["already_resolved"]) and not _last_spark_rat_counter_diagnostics.is_empty():
			_last_spark_rat_counter_diagnostics["last_bite_already_resolved"] = true
			_last_spark_rat_counter_diagnostics["last_bite_attack_active"] = bool(
				result["attack_active"]
			)
			_last_spark_rat_counter_diagnostics["last_bite_attack_sequence_id"] = attack_sequence_id
		else:
			_record_spark_rat_counter_result(result)
		return result.duplicate(true)

	var bite_metadata: Dictionary = _get_spark_rat_bite_metadata()
	var bite_damage: int = _get_spark_rat_bite_damage(bite_metadata)
	var dodged: bool = _is_player_dodge_iframe_active()
	var hp_before: int = _get_player_hp()
	var hp_after: int = hp_before

	if not dodged and _player.has_method("apply_damage"):
		_player.call("apply_damage", bite_damage, bite_metadata)
		hp_after = _get_player_hp()

	result = {
		"resolved": true,
		"dodged": dodged,
		"damage_applied": hp_after < hp_before,
		"damage": bite_damage,
		"weapon_id": StringName(bite_metadata.get("weapon_id", &"")),
		"source": StringName(bite_metadata.get("source", &"")),
		"player_hp_before": hp_before,
		"player_hp_after": hp_after,
		"counter_window_frames": _get_player_dodge_counter_window(),
		"attack_active": true,
		"attack_sequence_id": attack_sequence_id,
		"already_resolved": false,
	}
	_last_spark_rat_bite_sequence_id_resolved = attack_sequence_id
	_record_spark_rat_counter_result(result)
	_update_route_label("Dodge counter ready" if dodged else "Spark rat bite hit")
	return result.duplicate(true)


## Attempts to claim the room-clear cache with the player or supplied provider.
func try_claim_factory_cache(provider: Node = null) -> bool:
	if not _encounter_cleared or _cache == null:
		return false
	var claim_provider: Node = provider
	if claim_provider == null:
		claim_provider = _player
	if not _cache.has_method("try_claim") or not bool(_cache.call("try_claim", claim_provider)):
		return false
	_cache_claimed = true
	var reward_payload: Dictionary = _get_cache_reward_payload()
	if _last_cache_reward.is_empty():
		_last_cache_reward = reward_payload
	if _last_cache_claim_feedback.is_empty():
		_record_cache_claim_feedback(reward_payload, "Cache Claimed")
	return true


## Attempts to claim the return-patrol reward cache after the ambush is cleared.
func try_claim_factory_return_patrol_reward_cache(provider: Node = null) -> bool:
	if not _return_patrol_defeated or _return_patrol_reward_cache == null:
		return false
	var claim_provider: Node = provider
	if claim_provider == null:
		claim_provider = _player
	if (
		not _return_patrol_reward_cache.has_method("try_claim")
		or not bool(_return_patrol_reward_cache.call("try_claim", claim_provider))
	):
		return false
	_return_patrol_reward_cache_claimed = true
	var reward_payload: Dictionary = _get_return_patrol_reward_cache_payload()
	if _last_return_patrol_reward_cache_reward.is_empty():
		_last_return_patrol_reward_cache_reward = reward_payload
	_sync_return_patrol_reward_cache_state()
	if _last_return_patrol_reward_cache_claim_feedback.is_empty():
		_record_return_patrol_reward_cache_claim_feedback(
			reward_payload,
			"Return Cache Claimed"
		)
	return true


## Attempts to claim the checkpoint overdrive reward cache after the duo is cleared.
func try_claim_factory_checkpoint_overdrive_reward_cache(provider: Node = null) -> bool:
	if not _is_checkpoint_overdrive_duo_cleared() or _checkpoint_overdrive_reward_cache == null:
		return false
	var claim_provider: Node = provider
	if claim_provider == null:
		claim_provider = _player
	if (
		not _checkpoint_overdrive_reward_cache.has_method("try_claim")
		or not bool(_checkpoint_overdrive_reward_cache.call("try_claim", claim_provider))
	):
		return false
	_checkpoint_overdrive_reward_cache_claimed = true
	var reward_payload: Dictionary = _get_checkpoint_overdrive_reward_cache_payload()
	if _last_checkpoint_overdrive_reward_cache_reward.is_empty():
		_last_checkpoint_overdrive_reward_cache_reward = reward_payload
	_sync_checkpoint_overdrive_reward_cache_state()
	if _last_checkpoint_overdrive_reward_cache_claim_feedback.is_empty():
		_record_checkpoint_overdrive_reward_cache_claim_feedback(
			reward_payload,
			"Overdrive Cache Claimed"
		)
	return true


## Attempts to claim the lower-deck reward cache after the optional skirmish is cleared.
func try_claim_factory_lower_deck_reward_cache(provider: Node = null) -> bool:
	if not _lower_deck_skirmish_defeated or _lower_deck_reward_cache == null:
		return false
	var claim_provider: Node = provider
	if claim_provider == null:
		claim_provider = _player
	if (
		not _lower_deck_reward_cache.has_method("try_claim")
		or not bool(_lower_deck_reward_cache.call("try_claim", claim_provider))
	):
		return false
	_lower_deck_reward_cache_claimed = true
	var reward_payload: Dictionary = _get_lower_deck_reward_cache_payload()
	if _last_lower_deck_reward_cache_reward.is_empty():
		_last_lower_deck_reward_cache_reward = reward_payload
	_sync_lower_deck_reward_cache_state()
	if _last_lower_deck_reward_cache_claim_feedback.is_empty():
		_record_lower_deck_reward_cache_claim_feedback(
			reward_payload,
			"Lower Deck Cache Claimed"
		)
	return true


## Attempts to claim the shortcut payoff cache after the shortcut seal is opened.
func try_claim_factory_lower_deck_shortcut_reward_cache(provider: Node = null) -> bool:
	if not _lower_deck_shortcut_unlocked or _lower_deck_shortcut_reward_cache == null:
		return false
	var claim_provider: Node = provider
	if claim_provider == null:
		claim_provider = _player
	if (
		not _lower_deck_shortcut_reward_cache.has_method("try_claim")
		or not bool(_lower_deck_shortcut_reward_cache.call("try_claim", claim_provider))
	):
		return false
	_lower_deck_shortcut_reward_cache_claimed = true
	var reward_payload: Dictionary = _get_lower_deck_shortcut_reward_cache_payload()
	if _last_lower_deck_shortcut_reward_cache_reward.is_empty():
		_last_lower_deck_shortcut_reward_cache_reward = reward_payload
	_sync_lower_deck_shortcut_reward_cache_state()
	if _last_lower_deck_shortcut_reward_cache_claim_feedback.is_empty():
		_record_lower_deck_shortcut_reward_cache_claim_feedback(
			reward_payload,
			"Shortcut Cache Claimed"
		)
	return true


## Attempts to claim the relay-forward payoff cache after the post-relay trial is cleared.
func try_claim_factory_lower_deck_relay_forward_reward_cache(provider: Node = null) -> bool:
	if (
		not _lower_deck_post_relay_trial_defeated
		or _lower_deck_relay_forward_reward_cache == null
	):
		return false
	var claim_provider: Node = provider
	if claim_provider == null:
		claim_provider = _player
	if (
		not _lower_deck_relay_forward_reward_cache.has_method("try_claim")
		or not bool(_lower_deck_relay_forward_reward_cache.call("try_claim", claim_provider))
	):
		return false
	_lower_deck_relay_forward_reward_cache_claimed = true
	var reward_payload: Dictionary = _get_lower_deck_relay_forward_reward_cache_payload()
	if _last_lower_deck_relay_forward_reward_cache_reward.is_empty():
		_last_lower_deck_relay_forward_reward_cache_reward = reward_payload
	_sync_lower_deck_relay_forward_reward_cache_state()
	_sync_lower_deck_forward_hatch_state()
	if _last_lower_deck_relay_forward_reward_cache_claim_feedback.is_empty():
		_record_lower_deck_relay_forward_reward_cache_claim_feedback(
			reward_payload,
			"Relay Forward Cache Claimed"
		)
	return true


## Attempts to claim the forward-pressure payoff cache after the counter-ambush is cleared.
func try_claim_factory_lower_deck_forward_pressure_reward_cache(provider: Node = null) -> bool:
	if (
		not _lower_deck_forward_pressure_counter_ambush_defeated
		or _lower_deck_forward_pressure_reward_cache == null
	):
		return false
	var claim_provider: Node = provider
	if claim_provider == null:
		claim_provider = _player
	if (
		not _lower_deck_forward_pressure_reward_cache.has_method("try_claim")
		or not bool(_lower_deck_forward_pressure_reward_cache.call(
			"try_claim",
			claim_provider
		))
	):
		return false
	_lower_deck_forward_pressure_reward_cache_claimed = true
	var reward_payload: Dictionary = _get_lower_deck_forward_pressure_reward_cache_payload()
	if _last_lower_deck_forward_pressure_reward_cache_reward.is_empty():
		_last_lower_deck_forward_pressure_reward_cache_reward = reward_payload
	_sync_lower_deck_forward_pressure_reward_cache_state()
	_sync_lower_deck_forward_pressure_exit_guard_state()
	if _last_lower_deck_forward_pressure_reward_cache_claim_feedback.is_empty():
		_record_lower_deck_forward_pressure_reward_cache_claim_feedback(
			reward_payload,
			"Forward Pressure Cache Claimed"
		)
	return true


## Attempts to claim the aftershock payoff cache after the Coil Aftershock is cleared.
func try_claim_factory_lower_deck_forward_pressure_aftershock_reward_cache(
	provider: Node = null
) -> bool:
	if (
		not _lower_deck_forward_pressure_coil_aftershock_defeated
		or _lower_deck_forward_pressure_aftershock_reward_cache == null
	):
		return false
	var claim_provider: Node = provider if provider != null else _player
	if (
		not _lower_deck_forward_pressure_aftershock_reward_cache.has_method("try_claim")
		or not bool(_lower_deck_forward_pressure_aftershock_reward_cache.call(
			"try_claim",
			claim_provider
		))
	):
		return false
	_lower_deck_forward_pressure_aftershock_reward_cache_claimed = true
	var reward_payload: Dictionary = (
		_get_lower_deck_forward_pressure_aftershock_reward_cache_payload()
	)
	if _last_lower_deck_forward_pressure_aftershock_reward_cache_reward.is_empty():
		_last_lower_deck_forward_pressure_aftershock_reward_cache_reward = (
			reward_payload
		)
	_sync_lower_deck_forward_pressure_aftershock_reward_cache_state()
	if _last_lower_deck_forward_pressure_aftershock_reward_cache_claim_feedback.is_empty():
		_record_lower_deck_forward_pressure_aftershock_reward_cache_claim_feedback(
			reward_payload,
			"Forward Pressure Aftershock Cache Claimed"
		)
	_sync_lower_deck_forward_pressure_aftershock_exit_skirmish_state()
	_refresh_factory_route_objective()
	return true


## Attempts to claim the payoff cache after the aftershock exhaust pursuer is cleared.
func try_claim_factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache(
	provider: Node = null
) -> bool:
	if (
		not _lower_deck_forward_pressure_aftershock_exhaust_pursuer_defeated
		or _lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache == null
	):
		return false
	var claim_provider: Node = provider if provider != null else _player
	if (
		not _lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache.has_method(
			"try_claim"
		)
		or not bool(_lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache.call(
			"try_claim",
			claim_provider
		))
	):
		return false
	_lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache_claimed = true
	var reward_payload: Dictionary = (
		_get_lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache_payload()
	)
	if (
		_last_lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache_reward
		.is_empty()
	):
		_last_lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache_reward = (
			reward_payload
		)
	_sync_lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache_state()
	_sync_lower_deck_forward_pressure_aftershock_exhaust_flank_state()
	if (
		_last_lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache_claim_feedback
		.is_empty()
	):
		_record_lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache_claim_feedback(
			reward_payload,
			"Forward Pressure Exhaust Pursuer Cache Claimed"
		)
	_refresh_factory_route_objective()
	return true


## Attempts to claim the overflow-pump payoff cache after the pump skirmish clears.
func try_claim_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_reward_cache(
	provider: Node = null
) -> bool:
	if (
		not _is_overflow_pump_cleared()
		or _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_reward_cache == null
	):
		return false
	var claim_provider: Node = provider if provider != null else _player
	if (
		not _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_reward_cache.has_method(
			"try_claim"
		)
		or not bool(
			_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_reward_cache.call(
				"try_claim",
				claim_provider
			)
		)
	):
		return false
	_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_reward_cache_claimed = true
	var reward_payload: Dictionary = _get_overflow_pump_reward_cache_payload()
	if (
		_last_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_reward_cache_reward
		.is_empty()
	):
		_last_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_reward_cache_reward = (
			reward_payload
		)
	_sync_overflow_pump_reward_cache_state()
	_sync_overflow_pump_exit_hatch_state()
	if (
		_last_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_reward_cache_claim_feedback
		.is_empty()
	):
		_record_overflow_pump_reward_cache_claim_feedback(
			reward_payload,
			"Overflow Pump Cache Claimed"
		)
	return true


## Attempts to claim the runoff-exit payoff cache after the exit skirmish clears.
func try_claim_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_reward_cache(
	provider: Node = null
) -> bool:
	if (
		not _is_overflow_pump_runoff_exit_skirmish_cleared()
		or _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_reward_cache == null
	):
		return false
	var claim_provider: Node = provider if provider != null else _player
	if (
		not _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_reward_cache.has_method(
			"try_claim"
		)
		or not bool(
			_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_reward_cache.call(
				"try_claim",
				claim_provider
			)
		)
	):
		return false
	_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_reward_cache_claimed = true
	var reward_payload: Dictionary = _get_overflow_pump_runoff_exit_reward_cache_payload()
	if (
		_last_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_reward_cache_reward
		.is_empty()
	):
		_last_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_reward_cache_reward = (
			reward_payload
		)
	_sync_overflow_pump_runoff_exit_reward_cache_state()
	_sync_overflow_pump_runoff_exit_gate_state()
	if (
		_last_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_reward_cache_claim_feedback
		.is_empty()
	):
		_record_overflow_pump_runoff_exit_reward_cache_claim_feedback(
			reward_payload,
			"Runoff Exit Cache Claimed"
		)
	_refresh_factory_route_objective()
	return true


## Attempts to activate the forward-pressure exit guard after the payoff cache is claimed.
func try_activate_factory_lower_deck_forward_pressure_exit_guard(
	provider: Node = null
) -> bool:
	if (
		_lower_deck_forward_exit_guard_spark_rat == null
		or _lower_deck_forward_exit_guard_pressure_vent == null
		or not _is_lower_deck_forward_pressure_exit_guard_available()
		or _lower_deck_forward_pressure_exit_guard_activated
	):
		return false
	var activation_provider: Node = provider if provider != null else _player
	if not _is_lower_deck_forward_exit_guard_provider_in_range(activation_provider):
		return false
	_lower_deck_forward_pressure_exit_guard_activated = true
	_sync_lower_deck_forward_pressure_exit_guard_state()
	_set_lower_deck_forward_exit_guard_attack_target(activation_provider)
	_begin_lower_deck_forward_exit_guard_pacing(FACTORY_SPARK_RAT_OPENING_GRACE_FRAMES)
	_refresh_factory_route_objective()
	return true


## Attempts to activate the optional pursuer after the shortcut payoff is claimed.
func try_activate_factory_lower_deck_shortcut_pursuer(provider: Node = null) -> bool:
	if (
		_lower_deck_shortcut_pursuer_spark_rat == null
		or not _is_lower_deck_shortcut_pursuer_available()
		or _lower_deck_shortcut_pursuer_activated
	):
		return false
	var activation_provider: Node = provider
	if activation_provider == null:
		activation_provider = _player
	if not _is_lower_deck_shortcut_pursuer_activation_provider_in_range(
		activation_provider
	):
		return false
	_lower_deck_shortcut_pursuer_activated = true
	_sync_lower_deck_shortcut_pursuer_state()
	_set_lower_deck_shortcut_pursuer_attack_target(activation_provider)
	_begin_lower_deck_shortcut_pursuer_pacing(FACTORY_SPARK_RAT_OPENING_GRACE_FRAMES)
	_refresh_factory_route_objective()
	return true


## Attempts to activate the pressure valve guard after the shortcut pursuer is clear.
func try_activate_factory_lower_deck_pressure_guard(provider: Node = null) -> bool:
	if (
		_lower_deck_pressure_guard_spark_rat == null
		or not _is_lower_deck_pressure_guard_available()
		or _lower_deck_pressure_guard_activated
	):
		return false
	var activation_provider: Node = provider if provider != null else _player
	if not _is_lower_deck_pressure_guard_activation_provider_in_range(activation_provider):
		return false
	_lower_deck_pressure_guard_activated = true
	_sync_lower_deck_pressure_valve_state()
	_set_lower_deck_pressure_guard_attack_target(activation_provider)
	_begin_lower_deck_pressure_guard_pacing(FACTORY_SPARK_RAT_OPENING_GRACE_FRAMES)
	_refresh_factory_route_objective()
	return true


## Opens the deeper lower-deck pressure valve after its guard is defeated.
func try_open_factory_lower_deck_pressure_valve(provider: Node = null) -> bool:
	if (
		_lower_deck_pressure_valve == null
		or not _lower_deck_pressure_guard_defeated
		or _lower_deck_pressure_valve_opened
	):
		return false
	var activation_provider: Node = provider if provider != null else _player
	if (
		not _lower_deck_pressure_valve.has_method("try_activate")
		or not bool(_lower_deck_pressure_valve.call("try_activate", activation_provider))
	):
		return false
	_lower_deck_pressure_valve_opened = true
	_sync_lower_deck_pressure_valve_state()
	_refresh_factory_route_objective()
	return true


## Attempts to activate the steam sluice ambush after the pressure valve opens.
func try_activate_factory_lower_deck_steam_sluice(provider: Node = null) -> bool:
	if (
		_lower_deck_steam_sluice_spark_rat == null
		or not _is_lower_deck_steam_sluice_available()
		or _lower_deck_steam_sluice_activated
	):
		return false
	var activation_provider: Node = provider if provider != null else _player
	if not _is_lower_deck_steam_sluice_activation_provider_in_range(activation_provider):
		return false
	_lower_deck_steam_sluice_activated = true
	_sync_lower_deck_steam_sluice_state()
	_set_lower_deck_steam_sluice_attack_target(activation_provider)
	_begin_lower_deck_steam_sluice_pacing(FACTORY_SPARK_RAT_OPENING_GRACE_FRAMES)
	_refresh_factory_route_objective()
	return true


## Attempts to activate the deeper lower-deck bulkhead guard after the steam sluice is clear.
func try_activate_factory_lower_deck_deep_bulkhead_guard(provider: Node = null) -> bool:
	if (
		_lower_deck_deep_bulkhead_spark_rat == null
		or not _is_lower_deck_deep_bulkhead_guard_available()
		or _lower_deck_deep_bulkhead_guard_activated
	):
		return false
	var activation_provider: Node = provider if provider != null else _player
	if not _is_lower_deck_deep_bulkhead_guard_activation_provider_in_range(activation_provider):
		return false
	_lower_deck_deep_bulkhead_guard_activated = true
	_sync_lower_deck_deep_bulkhead_state()
	_set_lower_deck_deep_bulkhead_guard_attack_target(activation_provider)
	_begin_lower_deck_deep_bulkhead_guard_pacing(FACTORY_SPARK_RAT_OPENING_GRACE_FRAMES)
	_refresh_factory_route_objective()
	return true


## Opens the deeper lower-deck bulkhead after its guard is defeated.
func try_open_factory_lower_deck_deep_bulkhead(provider: Node = null) -> bool:
	if (
		_lower_deck_deep_bulkhead == null
		or not _lower_deck_deep_bulkhead_guard_defeated
		or _lower_deck_deep_bulkhead_opened
	):
		return false
	var activation_provider: Node = provider if provider != null else _player
	if (
		not _lower_deck_deep_bulkhead.has_method("try_activate")
		or not bool(_lower_deck_deep_bulkhead.call("try_activate", activation_provider))
	):
		return false
	_lower_deck_deep_bulkhead_opened = true
	_sync_lower_deck_deep_bulkhead_state()
	_sync_lower_deck_breach_corridor_state()
	_refresh_factory_route_objective()
	return true


## Attempts to activate the breach corridor ambush after the deep bulkhead opens.
func try_activate_factory_lower_deck_breach_corridor_ambush(provider: Node = null) -> bool:
	if (
		_lower_deck_breach_front_spark_rat == null
		or not _is_lower_deck_breach_corridor_available()
		or _lower_deck_breach_corridor_activated
	):
		return false
	var activation_provider: Node = provider if provider != null else _player
	if not _is_lower_deck_breach_corridor_activation_provider_in_range(
		activation_provider
	):
		return false
	_lower_deck_breach_corridor_activated = true
	_sync_lower_deck_breach_corridor_state()
	_set_lower_deck_breach_front_attack_target(activation_provider)
	_begin_lower_deck_breach_front_pacing(FACTORY_SPARK_RAT_OPENING_GRACE_FRAMES)
	_refresh_factory_route_objective()
	return true


## Activates the rear ambusher once Cinderpaw pushes into the breach corridor midpoint.
func try_activate_factory_lower_deck_breach_rear_ambusher(provider: Node = null) -> bool:
	if (
		_lower_deck_breach_rear_spark_rat == null
		or not _is_lower_deck_breach_corridor_active()
		or _lower_deck_breach_rear_ambusher_activated
		or _lower_deck_breach_rear_ambusher_defeated
	):
		return false
	var activation_provider: Node = provider if provider != null else _player
	if not _is_lower_deck_breach_rear_activation_provider_in_range(activation_provider):
		return false
	_lower_deck_breach_rear_ambusher_activated = true
	_sync_lower_deck_breach_corridor_state()
	_set_lower_deck_breach_rear_attack_target(activation_provider)
	_begin_lower_deck_breach_rear_pacing(FACTORY_SPARK_RAT_OPENING_GRACE_FRAMES)
	_refresh_factory_route_objective()
	return true


## Activates the post-breach lower-deck relay savepoint after the corridor is secured.
func try_activate_factory_lower_deck_breach_relay(provider: Node = null) -> bool:
	if (
		_lower_deck_breach_relay == null
		or not _is_lower_deck_breach_relay_available()
		or _lower_deck_breach_relay_activated
	):
		return false
	var activation_provider: Node = provider if provider != null else _player
	if not _is_lower_deck_breach_relay_provider_in_range(activation_provider):
		return false
	if (
		not _lower_deck_breach_relay.has_method("try_activate")
		or not bool(_lower_deck_breach_relay.call("try_activate", activation_provider))
	):
		return false
	_lower_deck_breach_relay_activated = true
	_sync_lower_deck_breach_relay_state()
	_update_route_label("Lower Deck Relay Secured")
	return true


## Activates the forward-pressure exit relay savepoint after the exit guard is secured.
func try_activate_factory_lower_deck_forward_pressure_exit_relay(
	provider: Node = null
) -> bool:
	if (
		_lower_deck_forward_pressure_exit_relay == null
		or not _is_lower_deck_forward_pressure_exit_relay_available()
		or _lower_deck_forward_pressure_exit_relay_activated
	):
		return false
	var activation_provider: Node = provider if provider != null else _player
	if not _is_lower_deck_forward_pressure_exit_relay_provider_in_range(
		activation_provider
	):
		return false
	if (
		not _lower_deck_forward_pressure_exit_relay.has_method("try_activate")
		or not bool(_lower_deck_forward_pressure_exit_relay.call(
			"try_activate",
			activation_provider
		))
	):
		return false
	_lower_deck_forward_pressure_exit_relay_activated = true
	_sync_lower_deck_forward_pressure_exit_relay_state()
	_update_route_label("Forward Pressure Exit Relay Secured")
	return true


## Opens the forward-pressure exit gate after the exit relay is repaired.
func try_open_factory_lower_deck_forward_pressure_exit_gate(provider: Node = null) -> bool:
	if (
		_lower_deck_forward_pressure_exit_gate == null
		or not _is_lower_deck_forward_pressure_exit_gate_available()
		or _lower_deck_forward_pressure_exit_gate_opened
	):
		return false
	var activation_provider: Node = provider if provider != null else _player
	if not _is_lower_deck_forward_pressure_exit_gate_provider_in_range(
		activation_provider
	):
		return false
	if (
		not _lower_deck_forward_pressure_exit_gate.has_method("try_activate")
		or not bool(_lower_deck_forward_pressure_exit_gate.call(
			"try_activate",
			activation_provider
		))
	):
		return false
	_lower_deck_forward_pressure_exit_gate_opened = true
	_sync_lower_deck_forward_pressure_exit_gate_state()
	_update_route_label("Forward Pressure Exit Gate Opened")
	return true


## Lights the route handoff marker after the forward-pressure exit gate is opened.
func try_activate_factory_lower_deck_forward_pressure_route_handoff_marker(
	provider: Node = null
) -> bool:
	if (
		_lower_deck_forward_pressure_route_handoff_marker == null
		or not _is_lower_deck_forward_pressure_route_handoff_marker_available()
		or _lower_deck_forward_pressure_route_handoff_marker_lit
	):
		return false
	var activation_provider: Node = provider if provider != null else _player
	if not _is_lower_deck_forward_pressure_route_handoff_marker_provider_in_range(
		activation_provider
	):
		return false
	if (
		not _lower_deck_forward_pressure_route_handoff_marker.has_method("try_activate")
		or not bool(_lower_deck_forward_pressure_route_handoff_marker.call(
			"try_activate",
			activation_provider
		))
	):
		return false
	_lower_deck_forward_pressure_route_handoff_marker_lit = true
	_sync_lower_deck_forward_pressure_route_handoff_marker_state()
	_update_route_label("Forward Pressure Route Beacon Lit")
	return true


## Activates the route-beacon follow-up ambush after the marker is lit.
func try_activate_factory_lower_deck_forward_pressure_beacon_ambush(
	provider: Node = null
) -> bool:
	if (
		_lower_deck_forward_beacon_ambush_spark_rat == null
		or _lower_deck_forward_beacon_ambush_pressure_vent == null
		or not _is_lower_deck_forward_pressure_beacon_ambush_available()
		or _lower_deck_forward_pressure_beacon_ambush_activated
	):
		return false
	var activation_provider: Node = provider if provider != null else _player
	if not _is_lower_deck_forward_beacon_ambush_provider_in_range(
		activation_provider
	):
		return false
	_lower_deck_forward_pressure_beacon_ambush_activated = true
	_sync_lower_deck_forward_pressure_beacon_ambush_state()
	_set_lower_deck_forward_beacon_ambush_attack_target(activation_provider)
	_begin_lower_deck_forward_beacon_ambush_pacing(
		FACTORY_SPARK_RAT_OPENING_GRACE_FRAMES
	)
	_refresh_factory_route_objective()
	return true


## Activates the beacon-ambush follow-up overrun after the route is secured.
func try_activate_factory_lower_deck_forward_pressure_overrun(
	provider: Node = null
) -> bool:
	if (
		_lower_deck_forward_overrun_spark_rat == null
		or _lower_deck_forward_overrun_pressure_vent == null
		or not _is_lower_deck_forward_pressure_overrun_available()
		or _lower_deck_forward_pressure_overrun_activated
	):
		return false
	var activation_provider: Node = provider if provider != null else _player
	if not _is_lower_deck_forward_overrun_provider_in_range(activation_provider):
		return false
	_lower_deck_forward_pressure_overrun_activated = true
	_sync_lower_deck_forward_pressure_overrun_state()
	_set_lower_deck_forward_overrun_attack_target(activation_provider)
	_begin_lower_deck_forward_overrun_pacing(FACTORY_SPARK_RAT_OPENING_GRACE_FRAMES)
	_refresh_factory_route_objective()
	return true


## Activates the forward-pressure breaker stand after the overrun is cleared.
func try_activate_factory_lower_deck_forward_pressure_breaker_stand(
	provider: Node = null
) -> bool:
	if (
		_lower_deck_forward_breaker_spark_rat == null
		or _lower_deck_forward_breaker_pressure_vent == null
		or not _is_lower_deck_forward_pressure_breaker_stand_available()
		or _lower_deck_forward_pressure_breaker_activated
	):
		return false
	var activation_provider: Node = provider if provider != null else _player
	if not _is_lower_deck_forward_breaker_provider_in_range(activation_provider):
		return false
	_lower_deck_forward_pressure_breaker_activated = true
	_sync_lower_deck_forward_pressure_breaker_state()
	_set_lower_deck_forward_breaker_attack_target(activation_provider)
	_begin_lower_deck_forward_breaker_pacing(FACTORY_SPARK_RAT_OPENING_GRACE_FRAMES)
	_refresh_factory_route_objective()
	return true


## Cuts the forward-pressure breaker once its guard is secured.
func try_activate_factory_lower_deck_forward_pressure_breaker(
	provider: Node = null
) -> bool:
	if (
		_lower_deck_forward_pressure_breaker == null
		or not _is_lower_deck_forward_pressure_breaker_available()
		or _lower_deck_forward_pressure_breaker_cut
	):
		return false
	var activation_provider: Node = provider if provider != null else _player
	if not _is_lower_deck_forward_pressure_breaker_provider_in_range(
		activation_provider
	):
		return false
	if (
		not _lower_deck_forward_pressure_breaker.has_method("try_activate")
		or not bool(_lower_deck_forward_pressure_breaker.call(
			"try_activate",
			activation_provider
		))
	):
		return false
	_lower_deck_forward_pressure_breaker_cut = true
	_sync_lower_deck_forward_pressure_breaker_endpoint_state()
	_update_route_label("Forward Pressure Breaker Cut")
	return true


## Activates the breaker-cut follow-up relief ambush after pressure is released.
func try_activate_factory_lower_deck_forward_pressure_relief_ambush(
	provider: Node = null
) -> bool:
	if (
		_lower_deck_forward_relief_ambush_spark_rat == null
		or _lower_deck_forward_relief_ambush_pressure_vent == null
		or not _is_lower_deck_forward_pressure_relief_ambush_available()
		or _lower_deck_forward_pressure_relief_ambush_activated
	):
		return false
	var activation_provider: Node = provider if provider != null else _player
	if not _is_lower_deck_forward_relief_ambush_provider_in_range(
		activation_provider
	):
		return false
	_lower_deck_forward_pressure_relief_ambush_activated = true
	_sync_lower_deck_forward_pressure_relief_ambush_state()
	_set_lower_deck_forward_relief_ambush_attack_target(activation_provider)
	_begin_lower_deck_forward_relief_ambush_pacing(
		FACTORY_SPARK_RAT_OPENING_GRACE_FRAMES
	)
	_refresh_factory_route_objective()
	return true


## Activates the Coil Rat breakthrough after the relief ambush is cleared.
func try_activate_factory_lower_deck_forward_pressure_coil_rat_breakthrough(
	provider: Node = null
) -> bool:
	if (
		_lower_deck_forward_pressure_coil_rat == null
		or not _is_lower_deck_forward_pressure_coil_rat_available()
		or _lower_deck_forward_pressure_coil_rat_activated
	):
		return false
	var activation_provider: Node = provider if provider != null else _player
	if not _is_lower_deck_forward_pressure_coil_rat_provider_in_range(
		activation_provider
	):
		return false
	_lower_deck_forward_pressure_coil_rat_activated = true
	_sync_lower_deck_forward_pressure_coil_rat_state()
	_set_lower_deck_forward_pressure_coil_rat_attack_target(activation_provider)
	_begin_lower_deck_forward_pressure_coil_rat_pacing(
		FACTORY_SPARK_RAT_OPENING_GRACE_FRAMES
	)
	_refresh_factory_route_objective()
	return true


## Activates the Story081 follow-up Spark Rat + Coil Rat pincer.
func try_activate_factory_lower_deck_forward_pressure_coil_pincer(
	provider: Node = null
) -> bool:
	if (
		_lower_deck_forward_pressure_coil_pincer_spark_rat == null
		or _lower_deck_forward_pressure_coil_pincer_coil_rat == null
		or not _is_lower_deck_forward_pressure_coil_pincer_available()
		or _lower_deck_forward_pressure_coil_pincer_activated
	):
		return false
	var activation_provider: Node = provider if provider != null else _player
	if not _is_lower_deck_forward_pressure_coil_pincer_provider_in_range(
		activation_provider
	):
		return false
	_lower_deck_forward_pressure_coil_pincer_activated = true
	_sync_lower_deck_forward_pressure_coil_pincer_state()
	_set_lower_deck_forward_pressure_coil_pincer_attack_targets(activation_provider)
	_begin_lower_deck_forward_pressure_coil_pincer_pacing(
		FACTORY_COIL_PINCER_SPARK_RAT_OPENING_GRACE_FRAMES,
		FACTORY_COIL_PINCER_COIL_RAT_OPENING_GRACE_FRAMES
	)
	_refresh_factory_route_objective()
	return true


## Activates the Story082 follow-up Coil Rat aftershock.
func try_activate_factory_lower_deck_forward_pressure_coil_aftershock(
	provider: Node = null
) -> bool:
	if (
		_lower_deck_forward_pressure_coil_aftershock_coil_rat == null
		or not _is_lower_deck_forward_pressure_coil_aftershock_available()
		or _lower_deck_forward_pressure_coil_aftershock_activated
	):
		return false
	var activation_provider: Node = provider if provider != null else _player
	if not _is_lower_deck_forward_pressure_coil_aftershock_provider_in_range(
		activation_provider
	):
		return false
	_lower_deck_forward_pressure_coil_aftershock_activated = true
	_sync_lower_deck_forward_pressure_coil_aftershock_state()
	_set_lower_deck_forward_pressure_coil_aftershock_attack_target(
		activation_provider
	)
	_begin_lower_deck_forward_pressure_coil_aftershock_pacing(
		FACTORY_COIL_AFTERSHOCK_COIL_RAT_OPENING_GRACE_FRAMES
	)
	_refresh_factory_route_objective()
	return true


## Activates the Story084 follow-up Spark Rat + Coil Rat exit skirmish.
func try_activate_factory_lower_deck_forward_pressure_aftershock_exit_skirmish(
	provider: Node = null
) -> bool:
	if (
		_lower_deck_forward_pressure_aftershock_exit_spark_rat == null
		or _lower_deck_forward_pressure_aftershock_exit_coil_rat == null
		or not _is_lower_deck_forward_pressure_aftershock_exit_skirmish_available()
		or _lower_deck_forward_pressure_aftershock_exit_skirmish_activated
	):
		return false
	var activation_provider: Node = provider if provider != null else _player
	if not _is_lower_deck_forward_pressure_aftershock_exit_skirmish_provider_in_range(
		activation_provider
	):
		return false
	_lower_deck_forward_pressure_aftershock_exit_skirmish_activated = true
	_sync_lower_deck_forward_pressure_aftershock_exit_skirmish_state()
	_set_lower_deck_forward_pressure_aftershock_exit_skirmish_attack_targets(
		activation_provider
	)
	_begin_lower_deck_forward_pressure_aftershock_exit_skirmish_pacing(
		FACTORY_AFTERSHOCK_EXIT_SPARK_RAT_OPENING_GRACE_FRAMES,
		FACTORY_AFTERSHOCK_EXIT_COIL_RAT_OPENING_GRACE_FRAMES
	)
	_refresh_factory_route_objective()
	return true


## Starts the Story086 aftershock exhaust timing traverse after the exit skirmish.
func try_activate_factory_lower_deck_forward_pressure_aftershock_exhaust(
	provider: Node = null
) -> bool:
	if (
		_lower_deck_forward_pressure_aftershock_exhaust_vent == null
		or not _is_lower_deck_forward_pressure_aftershock_exhaust_available()
		or _lower_deck_forward_pressure_aftershock_exhaust_activated
	):
		return false
	var activation_provider: Node = provider if provider != null else _player
	if not _is_lower_deck_forward_pressure_aftershock_exhaust_provider_at_activation(
		activation_provider
	):
		return false
	_lower_deck_forward_pressure_aftershock_exhaust_activated = true
	_lower_deck_forward_pressure_aftershock_exhaust_elapsed_sec = 0.0
	_sync_lower_deck_forward_pressure_aftershock_exhaust_state()
	_refresh_factory_route_objective()
	return true


## Advances the Story086 aftershock exhaust cycle deterministically.
func advance_factory_lower_deck_forward_pressure_aftershock_exhaust_time(
	delta_sec: float
) -> void:
	if not _is_lower_deck_forward_pressure_aftershock_exhaust_active():
		return
	var safe_delta_sec: float = maxf(0.0, delta_sec)
	_lower_deck_forward_pressure_aftershock_exhaust_elapsed_sec += safe_delta_sec
	_factory_hazard_elapsed_sec += safe_delta_sec
	_sync_lower_deck_forward_pressure_aftershock_exhaust_state()


## Completes the Story086 aftershock exhaust traverse at the exit boundary.
func try_complete_factory_lower_deck_forward_pressure_aftershock_exhaust(
	provider: Node = null
) -> bool:
	if (
		_lower_deck_forward_pressure_aftershock_exhaust_vent == null
		or not _is_lower_deck_forward_pressure_aftershock_exhaust_active()
		or _lower_deck_forward_pressure_aftershock_exhaust_crossed
	):
		return false
	var completion_provider: Node = provider if provider != null else _player
	if not _is_lower_deck_forward_pressure_aftershock_exhaust_provider_at_exit(
		completion_provider
	):
		return false
	_lower_deck_forward_pressure_aftershock_exhaust_activated = true
	_lower_deck_forward_pressure_aftershock_exhaust_crossed = true
	_lower_deck_forward_pressure_aftershock_exhaust_elapsed_sec = 0.0
	_sync_lower_deck_forward_pressure_aftershock_exhaust_state()
	_refresh_factory_route_objective()
	return true


## Activates the Story087 Coil Rat pursuer after the aftershock exhaust.
func try_activate_factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer(
	provider: Node = null
) -> bool:
	if (
		_lower_deck_forward_pressure_aftershock_exhaust_pursuer_coil_rat == null
		or not _is_lower_deck_forward_pressure_aftershock_exhaust_pursuer_available()
		or _lower_deck_forward_pressure_aftershock_exhaust_pursuer_activated
	):
		return false
	var activation_provider: Node = provider if provider != null else _player
	if not _is_lower_deck_forward_pressure_aftershock_exhaust_pursuer_provider_in_range(
		activation_provider
	):
		return false
	_lower_deck_forward_pressure_aftershock_exhaust_pursuer_activated = true
	_sync_lower_deck_forward_pressure_aftershock_exhaust_pursuer_state()
	_set_lower_deck_forward_pressure_aftershock_exhaust_pursuer_attack_target(
		activation_provider
	)
	_begin_lower_deck_forward_pressure_aftershock_exhaust_pursuer_pacing(
		FACTORY_AFTERSHOCK_EXHAUST_PURSUER_OPENING_GRACE_FRAMES
	)
	_refresh_factory_route_objective()
	return true


## Activates the Story089 Spark Rat flank after the exhaust pursuer cache payoff.
func try_activate_factory_lower_deck_forward_pressure_aftershock_exhaust_flank_ambush(
	provider: Node = null
) -> bool:
	if (
		_lower_deck_forward_pressure_aftershock_exhaust_flank_spark_rat == null
		or _lower_deck_forward_pressure_aftershock_exhaust_flank_vent == null
		or not _is_lower_deck_forward_pressure_aftershock_exhaust_flank_available()
		or _lower_deck_forward_pressure_aftershock_exhaust_flank_activated
	):
		return false
	var activation_provider: Node = provider if provider != null else _player
	if not _is_lower_deck_forward_pressure_aftershock_exhaust_flank_provider_in_range(
		activation_provider
	):
		return false
	_lower_deck_forward_pressure_aftershock_exhaust_flank_activated = true
	_sync_lower_deck_forward_pressure_aftershock_exhaust_flank_state()
	_set_lower_deck_forward_pressure_aftershock_exhaust_flank_attack_target(
		activation_provider
	)
	_begin_lower_deck_forward_pressure_aftershock_exhaust_flank_pacing(
		FACTORY_AFTERSHOCK_EXHAUST_FLANK_OPENING_GRACE_FRAMES
	)
	_refresh_factory_route_objective()
	return true


## Activates the Story090 Coil Rat breaker stand after the exhaust flank is clear.
func try_activate_factory_lower_deck_forward_pressure_aftershock_exhaust_breaker_stand(
	provider: Node = null
) -> bool:
	if (
		_lower_deck_forward_pressure_aftershock_exhaust_breaker_coil_rat == null
		or _lower_deck_forward_pressure_aftershock_exhaust_breaker_vent == null
		or not _is_lower_deck_forward_pressure_aftershock_exhaust_breaker_stand_available()
		or _lower_deck_forward_pressure_aftershock_exhaust_breaker_activated
	):
		return false
	var activation_provider: Node = provider if provider != null else _player
	if not _is_lower_deck_forward_pressure_aftershock_exhaust_breaker_provider_in_range(
		activation_provider
	):
		return false
	_lower_deck_forward_pressure_aftershock_exhaust_breaker_activated = true
	_sync_lower_deck_forward_pressure_aftershock_exhaust_breaker_state()
	_set_lower_deck_forward_pressure_aftershock_exhaust_breaker_attack_target(
		activation_provider
	)
	_begin_lower_deck_forward_pressure_aftershock_exhaust_breaker_pacing(
		FACTORY_AFTERSHOCK_EXHAUST_BREAKER_OPENING_GRACE_FRAMES
	)
	_refresh_factory_route_objective()
	return true


## Cuts the Story090 aftershock exhaust breaker after its Coil Rat guard is secured.
func try_activate_factory_lower_deck_forward_pressure_aftershock_exhaust_breaker(
	provider: Node = null
) -> bool:
	if (
		_lower_deck_forward_pressure_aftershock_exhaust_breaker == null
		or not _is_lower_deck_forward_pressure_aftershock_exhaust_breaker_available()
		or _lower_deck_forward_pressure_aftershock_exhaust_breaker_cut
	):
		return false
	var activation_provider: Node = provider if provider != null else _player
	if not _is_lower_deck_forward_pressure_aftershock_exhaust_breaker_provider_in_range(
		activation_provider
	):
		return false
	if (
		not _lower_deck_forward_pressure_aftershock_exhaust_breaker.has_method(
			"try_activate"
		)
		or not bool(_lower_deck_forward_pressure_aftershock_exhaust_breaker.call(
			"try_activate",
			activation_provider
		))
	):
		return false
	_lower_deck_forward_pressure_aftershock_exhaust_breaker_cut = true
	_sync_lower_deck_forward_pressure_aftershock_exhaust_breaker_endpoint_state()
	_update_route_label("Aftershock Exhaust Pressure Cut")
	return true


## Activates the Story091 escape skirmish after the aftershock exhaust is cut.
func try_activate_factory_lower_deck_forward_pressure_aftershock_exhaust_escape_skirmish(
	provider: Node = null
) -> bool:
	if (
		_lower_deck_forward_pressure_aftershock_exhaust_escape_spark_rat == null
		or _lower_deck_forward_pressure_aftershock_exhaust_escape_coil_rat == null
		or not _is_lower_deck_forward_pressure_aftershock_exhaust_escape_skirmish_available()
		or _lower_deck_forward_pressure_aftershock_exhaust_escape_skirmish_activated
	):
		return false
	var activation_provider: Node = provider if provider != null else _player
	if not _is_lower_deck_forward_pressure_aftershock_exhaust_escape_skirmish_provider_in_range(
		activation_provider
	):
		return false
	_lower_deck_forward_pressure_aftershock_exhaust_escape_skirmish_activated = true
	_sync_lower_deck_forward_pressure_aftershock_exhaust_escape_skirmish_state()
	_set_lower_deck_forward_pressure_aftershock_exhaust_escape_skirmish_attack_targets(
		activation_provider
	)
	_begin_lower_deck_forward_pressure_aftershock_exhaust_escape_skirmish_pacing(
		FACTORY_AFTERSHOCK_EXHAUST_ESCAPE_SPARK_OPENING_GRACE_FRAMES,
		FACTORY_AFTERSHOCK_EXHAUST_ESCAPE_COIL_OPENING_GRACE_FRAMES
	)
	_refresh_factory_route_objective()
	return true


## Opens the aftershock exhaust exit hatch after the escape skirmish is secured.
func try_open_factory_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch(
	provider: Node = null
) -> bool:
	if (
		_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch == null
		or not _is_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch_available()
		or _lower_deck_forward_pressure_aftershock_exhaust_exit_hatch_opened
	):
		return false
	var activation_provider: Node = provider if provider != null else _player
	if not _is_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch_provider_in_range(
		activation_provider
	):
		return false
	if (
		not _lower_deck_forward_pressure_aftershock_exhaust_exit_hatch.has_method(
			"try_activate"
		)
		or not bool(_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch.call(
			"try_activate",
			activation_provider
		))
	):
		return false
	_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch_opened = true
	_sync_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch_state()
	_sync_lower_deck_forward_pressure_aftershock_cooling_duct_state()
	_update_route_label("Aftershock Exhaust Exit Opened")
	return true


## Opens the overflow-pump runoff hatch after its reward cache is claimed.
func try_open_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_exit_hatch(
	provider: Node = null
) -> bool:
	if (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_exit_hatch == null
		or not _is_overflow_pump_exit_hatch_available()
		or _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_exit_hatch_opened
	):
		return false
	var activation_provider: Node = provider if provider != null else _player
	if not _is_overflow_pump_exit_hatch_provider_in_range(activation_provider):
		return false
	if (
		not _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_exit_hatch.has_method(
			"try_activate"
		)
		or not bool(
			_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_exit_hatch.call(
				"try_activate",
				activation_provider
			)
		)
	):
		return false
	_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_exit_hatch_opened = true
	_sync_overflow_pump_exit_hatch_state()
	_update_route_label("Overflow Pump Runoff Hatch Open")
	return true


## Opens the runoff-exit gate after its reward cache is claimed.
func try_open_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_gate(
	provider: Node = null
) -> bool:
	if (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_gate == null
		or not _is_overflow_pump_runoff_exit_gate_available()
		or _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_gate_opened
	):
		return false
	var activation_provider: Node = provider if provider != null else _player
	if not _is_overflow_pump_runoff_exit_gate_provider_in_range(activation_provider):
		return false
	if (
		not _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_gate.has_method(
			"try_activate"
		)
		or not bool(
			_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_gate.call(
				"try_activate",
				activation_provider
			)
		)
	):
		return false
	_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_gate_opened = true
	_sync_overflow_pump_runoff_exit_gate_state()
	_update_route_label("Overflow Pump Runoff Exit Gate Open")
	return true


## Starts the runoff outlet traverse beyond the opened runoff exit gate.
func try_activate_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet(
	provider: Node = null
) -> bool:
	if (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_duct == null
		or _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_vent == null
		or not _is_overflow_pump_runoff_outlet_available()
		or _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_activated
	):
		return false
	var activation_provider: Node = provider if provider != null else _player
	if not _is_overflow_pump_runoff_outlet_provider_at_activation(
		activation_provider
	):
		return false
	_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_activated = true
	_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_elapsed_sec = 0.0
	_sync_overflow_pump_runoff_outlet_state()
	_refresh_factory_route_objective()
	return true


## Advances the runoff outlet steam cycle deterministically for tests/MCP.
func advance_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_time(
	delta_sec: float
) -> void:
	if not _is_overflow_pump_runoff_outlet_active():
		return
	var safe_delta_sec: float = maxf(0.0, delta_sec)
	_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_elapsed_sec += safe_delta_sec
	_factory_hazard_elapsed_sec += safe_delta_sec
	_sync_overflow_pump_runoff_outlet_state()


## Completes the runoff outlet traverse after Cinderpaw reaches the far edge.
func try_complete_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet(
	provider: Node = null
) -> bool:
	if (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_duct == null
		or _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_vent == null
		or not _is_overflow_pump_runoff_outlet_active()
		or _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_crossed
	):
		return false
	var completion_provider: Node = provider if provider != null else _player
	if not _is_overflow_pump_runoff_outlet_provider_at_exit(completion_provider):
		return false
	_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_activated = true
	_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_crossed = true
	_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_elapsed_sec = 0.0
	_sync_overflow_pump_runoff_outlet_state()
	_refresh_factory_route_objective()
	return true


## Starts the runoff outlet Spark Rat skirmish after the outlet traverse is crossed.
func try_activate_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_skirmish(
	provider: Node = null
) -> bool:
	if (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_spark_rat == null
		or not _is_overflow_pump_runoff_outlet_skirmish_available()
		or _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_skirmish_activated
	):
		return false
	var activation_provider: Node = provider if provider != null else _player
	if not _is_overflow_pump_runoff_outlet_skirmish_provider_in_range(
		activation_provider
	):
		return false
	_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_skirmish_activated = true
	_sync_overflow_pump_runoff_outlet_skirmish_state()
	_set_overflow_pump_runoff_outlet_spark_rat_attack_target(activation_provider)
	_begin_overflow_pump_runoff_outlet_skirmish_pacing(
		FACTORY_AFTERSHOCK_CONDENSER_OVERFLOW_RUNOFF_OUTLET_SPARK_OPENING_GRACE_FRAMES
	)
	_refresh_factory_route_objective()
	return true


## Attempts to claim the runoff-outlet payoff cache after the Spark Rat clears.
func try_claim_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_reward_cache(
	provider: Node = null
) -> bool:
	if (
		not _is_overflow_pump_runoff_outlet_skirmish_cleared()
		or _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_reward_cache == null
	):
		return false
	var claim_provider: Node = provider if provider != null else _player
	if (
		not _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_reward_cache.has_method(
			"try_claim"
		)
		or not bool(
			_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_reward_cache.call(
				"try_claim",
				claim_provider
			)
		)
	):
		return false
	_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_reward_cache_claimed = true
	var reward_payload: Dictionary = _get_overflow_pump_runoff_outlet_reward_cache_payload()
	if (
		_last_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_reward_cache_reward
		.is_empty()
	):
		_last_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_reward_cache_reward = (
			reward_payload
		)
	_sync_overflow_pump_runoff_outlet_reward_cache_state()
	_sync_overflow_pump_runoff_outlet_service_hatch_state()
	if (
		_last_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_reward_cache_claim_feedback
		.is_empty()
	):
		_record_overflow_pump_runoff_outlet_reward_cache_claim_feedback(
			reward_payload,
			"Runoff Outlet Cache Claimed"
		)
	_refresh_factory_route_objective()
	return true


## Opens the runoff-outlet service hatch after its reward cache is claimed.
func try_open_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_hatch(
	provider: Node = null
) -> bool:
	if (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_hatch == null
		or not _is_overflow_pump_runoff_outlet_service_hatch_available()
		or _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_hatch_opened
	):
		return false
	var activation_provider: Node = provider if provider != null else _player
	if not _is_overflow_pump_runoff_outlet_service_hatch_provider_in_range(
		activation_provider
	):
		return false
	if (
		not _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_hatch.has_method(
			"try_activate"
		)
		or not bool(
			_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_hatch.call(
				"try_activate",
				activation_provider
			)
		)
	):
		return false
	_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_hatch_opened = true
	_sync_overflow_pump_runoff_outlet_service_hatch_state()
	_sync_overflow_pump_runoff_outlet_service_sluice_state()
	_refresh_factory_route_objective()
	return true


## Starts the service sluice traverse beyond the opened runoff-outlet hatch.
func try_activate_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice(
	provider: Node = null
) -> bool:
	if (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_duct == null
		or _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_vent == null
		or not _is_overflow_pump_runoff_outlet_service_sluice_available()
		or _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_activated
	):
		return false
	var activation_provider: Node = provider if provider != null else _player
	if not _is_overflow_pump_runoff_outlet_service_sluice_provider_at_activation(
		activation_provider
	):
		return false
	_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_activated = true
	_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_elapsed_sec = 0.0
	_sync_overflow_pump_runoff_outlet_service_sluice_state()
	_refresh_factory_route_objective()
	return true


## Advances the service sluice pressure cycle deterministically for tests/MCP.
func advance_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_time(
	delta_sec: float
) -> void:
	if not _is_overflow_pump_runoff_outlet_service_sluice_active():
		return
	var safe_delta_sec: float = maxf(0.0, delta_sec)
	_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_elapsed_sec += safe_delta_sec
	_factory_hazard_elapsed_sec += safe_delta_sec
	_sync_overflow_pump_runoff_outlet_service_sluice_state()


## Completes the service sluice traverse after Cinderpaw reaches the far edge.
func try_complete_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice(
	provider: Node = null
) -> bool:
	if (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_duct == null
		or _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_vent == null
		or not _is_overflow_pump_runoff_outlet_service_sluice_active()
		or _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_crossed
	):
		return false
	var completion_provider: Node = provider if provider != null else _player
	if not _is_overflow_pump_runoff_outlet_service_sluice_provider_at_exit(
		completion_provider
	):
		return false
	_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_activated = true
	_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_crossed = true
	_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_elapsed_sec = 0.0
	_sync_overflow_pump_runoff_outlet_service_sluice_state()
	_refresh_factory_route_objective()
	return true


## Starts the Spark Rat skirmish after the runoff-outlet service sluice is crossed.
func try_activate_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_skirmish(
	provider: Node = null
) -> bool:
	if (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_spark_rat == null
		or not _is_overflow_pump_runoff_outlet_service_sluice_skirmish_available()
		or _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_skirmish_activated
	):
		return false
	var activation_provider: Node = provider if provider != null else _player
	if not _is_overflow_pump_runoff_outlet_service_sluice_skirmish_provider_in_range(
		activation_provider
	):
		return false
	_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_skirmish_activated = true
	_sync_overflow_pump_runoff_outlet_service_sluice_skirmish_state()
	_set_overflow_pump_runoff_outlet_service_sluice_spark_rat_attack_target(
		activation_provider
	)
	_begin_overflow_pump_runoff_outlet_service_sluice_skirmish_pacing(
		FACTORY_AFTERSHOCK_CONDENSER_OVERFLOW_RUNOFF_OUTLET_SERVICE_SLUICE_SPARK_OPENING_GRACE_FRAMES
	)
	_refresh_factory_route_objective()
	return true


## Starts the overflow pump runoff duct traversal beyond the opened hatch.
func try_activate_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_duct(
	provider: Node = null
) -> bool:
	if (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_duct == null
		or _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_duct_vent == null
		or not _is_overflow_pump_runoff_duct_available()
		or _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_duct_activated
	):
		return false
	var activation_provider: Node = provider if provider != null else _player
	if not _is_overflow_pump_runoff_duct_provider_at_activation(
		activation_provider
	):
		return false
	_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_duct_activated = true
	_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_duct_elapsed_sec = 0.0
	_sync_overflow_pump_runoff_duct_state()
	_refresh_factory_route_objective()
	return true


## Advances the overflow pump runoff duct cycle deterministically for tests/MCP.
func advance_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_duct_time(
	delta_sec: float
) -> void:
	if not _is_overflow_pump_runoff_duct_active():
		return
	var safe_delta_sec: float = maxf(0.0, delta_sec)
	_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_duct_elapsed_sec += safe_delta_sec
	_factory_hazard_elapsed_sec += safe_delta_sec
	_sync_overflow_pump_runoff_duct_state()


## Completes the overflow pump runoff duct after Cinderpaw reaches the far edge.
func try_complete_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_duct(
	provider: Node = null
) -> bool:
	if (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_duct == null
		or _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_duct_vent == null
		or not _is_overflow_pump_runoff_duct_active()
		or _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_duct_crossed
	):
		return false
	var completion_provider: Node = provider if provider != null else _player
	if not _is_overflow_pump_runoff_duct_provider_at_exit(completion_provider):
		return false
	_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_duct_activated = true
	_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_duct_crossed = true
	_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_duct_elapsed_sec = 0.0
	_sync_overflow_pump_runoff_duct_state()
	_refresh_factory_route_objective()
	return true


## Starts the overflow pump runoff exit skirmish after the duct is crossed.
func try_activate_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_skirmish(
	provider: Node = null
) -> bool:
	if (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_coil_rat == null
		or not _is_overflow_pump_runoff_exit_skirmish_available()
		or _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_skirmish_activated
	):
		return false
	var activation_provider: Node = provider if provider != null else _player
	if not _is_overflow_pump_runoff_exit_skirmish_provider_in_range(
		activation_provider
	):
		return false
	_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_skirmish_activated = true
	_sync_overflow_pump_runoff_exit_skirmish_state()
	_set_overflow_pump_runoff_exit_attack_target(activation_provider)
	_begin_overflow_pump_runoff_exit_pacing(
		FACTORY_AFTERSHOCK_CONDENSER_OVERFLOW_RUNOFF_EXIT_COIL_OPENING_GRACE_FRAMES
	)
	_refresh_factory_route_objective()
	return true


## Starts the Story093 aftershock cooling duct traversal beyond the opened hatch.
func try_activate_factory_lower_deck_forward_pressure_aftershock_cooling_duct(
	provider: Node = null
) -> bool:
	if (
		_lower_deck_forward_pressure_aftershock_cooling_duct == null
		or _lower_deck_forward_pressure_aftershock_cooling_duct_vent == null
		or not _is_lower_deck_forward_pressure_aftershock_cooling_duct_available()
		or _lower_deck_forward_pressure_aftershock_cooling_duct_activated
	):
		return false
	var activation_provider: Node = provider if provider != null else _player
	if not _is_lower_deck_forward_pressure_aftershock_cooling_duct_provider_at_activation(
		activation_provider
	):
		return false
	_lower_deck_forward_pressure_aftershock_cooling_duct_activated = true
	_lower_deck_forward_pressure_aftershock_cooling_duct_elapsed_sec = 0.0
	_sync_lower_deck_forward_pressure_aftershock_cooling_duct_state()
	_refresh_factory_route_objective()
	return true


## Advances the aftershock cooling duct cycle deterministically for tests/MCP.
func advance_factory_lower_deck_forward_pressure_aftershock_cooling_duct_time(
	delta_sec: float
) -> void:
	if not _is_lower_deck_forward_pressure_aftershock_cooling_duct_active():
		return
	var safe_delta_sec: float = maxf(0.0, delta_sec)
	_lower_deck_forward_pressure_aftershock_cooling_duct_elapsed_sec += safe_delta_sec
	_factory_hazard_elapsed_sec += safe_delta_sec
	_sync_lower_deck_forward_pressure_aftershock_cooling_duct_state()


## Completes the Story093 cooling duct traversal after Cinderpaw reaches the far edge.
func try_complete_factory_lower_deck_forward_pressure_aftershock_cooling_duct(
	provider: Node = null
) -> bool:
	if (
		_lower_deck_forward_pressure_aftershock_cooling_duct == null
		or _lower_deck_forward_pressure_aftershock_cooling_duct_vent == null
		or not _is_lower_deck_forward_pressure_aftershock_cooling_duct_active()
		or _lower_deck_forward_pressure_aftershock_cooling_duct_crossed
	):
		return false
	var completion_provider: Node = provider if provider != null else _player
	if not _is_lower_deck_forward_pressure_aftershock_cooling_duct_provider_at_exit(
		completion_provider
	):
		return false
	_lower_deck_forward_pressure_aftershock_cooling_duct_activated = true
	_lower_deck_forward_pressure_aftershock_cooling_duct_crossed = true
	_lower_deck_forward_pressure_aftershock_cooling_duct_elapsed_sec = 0.0
	_sync_lower_deck_forward_pressure_aftershock_cooling_duct_state()
	_sync_lower_deck_forward_pressure_aftershock_condenser_valve_state()
	_refresh_factory_route_objective()
	return true


## Starts the Story094 condenser valve landing ambush beyond the cooling duct.
func try_activate_factory_lower_deck_forward_pressure_aftershock_condenser_valve(
	provider: Node = null
) -> bool:
	if (
		_lower_deck_forward_pressure_aftershock_condenser_valve == null
		or _lower_deck_forward_pressure_aftershock_condenser_spark_rat == null
		or _lower_deck_forward_pressure_aftershock_condenser_coil_rat == null
		or not _is_lower_deck_forward_pressure_aftershock_condenser_valve_available()
		or _lower_deck_forward_pressure_aftershock_condenser_valve_activated
	):
		return false
	var activation_provider: Node = provider if provider != null else _player
	if not _is_lower_deck_forward_pressure_aftershock_condenser_valve_provider_in_range(
		activation_provider
	):
		return false
	_lower_deck_forward_pressure_aftershock_condenser_valve_activated = true
	_sync_lower_deck_forward_pressure_aftershock_condenser_valve_state()
	_set_lower_deck_forward_pressure_aftershock_condenser_valve_attack_targets(
		activation_provider
	)
	_begin_lower_deck_forward_pressure_aftershock_condenser_valve_pacing()
	_refresh_factory_route_objective()
	return true


## Activates the aftershock condenser savepoint after the landing is secured.
func try_activate_factory_lower_deck_forward_pressure_aftershock_condenser_savepoint(
	provider: Node = null
) -> bool:
	if (
		_lower_deck_forward_pressure_aftershock_condenser_savepoint == null
		or not _is_lower_deck_forward_pressure_aftershock_condenser_savepoint_available()
		or _lower_deck_forward_pressure_aftershock_condenser_savepoint_activated
	):
		return false
	var activation_provider: Node = provider if provider != null else _player
	if not _is_lower_deck_forward_pressure_aftershock_condenser_savepoint_provider_in_range(
		activation_provider
	):
		return false
	if (
		not _lower_deck_forward_pressure_aftershock_condenser_savepoint.has_method(
			"try_activate"
		)
		or not bool(_lower_deck_forward_pressure_aftershock_condenser_savepoint.call(
			"try_activate",
			activation_provider
		))
	):
		return false
	_lower_deck_forward_pressure_aftershock_condenser_savepoint_activated = true
	_sync_lower_deck_forward_pressure_aftershock_condenser_savepoint_state()
	_update_route_label("Aftershock Condenser Savepoint Secured")
	return true


## Starts the Story096 condenser outlet traversal beyond the condenser savepoint.
func try_activate_factory_lower_deck_forward_pressure_aftershock_condenser_outlet(
	provider: Node = null
) -> bool:
	if (
		_lower_deck_forward_pressure_aftershock_condenser_outlet == null
		or _lower_deck_forward_pressure_aftershock_condenser_outlet_vent == null
		or not _is_lower_deck_forward_pressure_aftershock_condenser_outlet_available()
		or _lower_deck_forward_pressure_aftershock_condenser_outlet_activated
	):
		return false
	var activation_provider: Node = provider if provider != null else _player
	if not _is_lower_deck_forward_pressure_aftershock_condenser_outlet_provider_at_activation(
		activation_provider
	):
		return false
	_lower_deck_forward_pressure_aftershock_condenser_outlet_activated = true
	_lower_deck_forward_pressure_aftershock_condenser_outlet_elapsed_sec = 0.0
	_sync_lower_deck_forward_pressure_aftershock_condenser_outlet_state()
	_refresh_factory_route_objective()
	return true


## Advances the aftershock condenser outlet cycle deterministically for tests/MCP.
func advance_factory_lower_deck_forward_pressure_aftershock_condenser_outlet_time(
	delta_sec: float
) -> void:
	if not _is_lower_deck_forward_pressure_aftershock_condenser_outlet_active():
		return
	var safe_delta_sec: float = maxf(0.0, delta_sec)
	_lower_deck_forward_pressure_aftershock_condenser_outlet_elapsed_sec += safe_delta_sec
	_factory_hazard_elapsed_sec += safe_delta_sec
	_sync_lower_deck_forward_pressure_aftershock_condenser_outlet_state()


## Completes the Story096 condenser outlet traversal after Cinderpaw reaches the far edge.
func try_complete_factory_lower_deck_forward_pressure_aftershock_condenser_outlet(
	provider: Node = null
) -> bool:
	if (
		_lower_deck_forward_pressure_aftershock_condenser_outlet == null
		or _lower_deck_forward_pressure_aftershock_condenser_outlet_vent == null
		or not _is_lower_deck_forward_pressure_aftershock_condenser_outlet_active()
		or _lower_deck_forward_pressure_aftershock_condenser_outlet_crossed
	):
		return false
	var completion_provider: Node = provider if provider != null else _player
	if not _is_lower_deck_forward_pressure_aftershock_condenser_outlet_provider_at_exit(
		completion_provider
	):
		return false
	_lower_deck_forward_pressure_aftershock_condenser_outlet_activated = true
	_lower_deck_forward_pressure_aftershock_condenser_outlet_crossed = true
	_lower_deck_forward_pressure_aftershock_condenser_outlet_elapsed_sec = 0.0
	_sync_lower_deck_forward_pressure_aftershock_condenser_outlet_state()
	_refresh_factory_route_objective()
	return true


## Starts the Story097 condenser outlet clamp ambush beyond the outlet hazard.
func try_activate_factory_lower_deck_forward_pressure_aftershock_condenser_outlet_clamp_ambush(
	provider: Node = null
) -> bool:
	if (
		_lower_deck_forward_pressure_aftershock_condenser_outlet_clamp == null
		or _lower_deck_forward_pressure_aftershock_condenser_outlet_clamp_spark_rat == null
		or not _is_outlet_clamp_ambush_available()
		or _lower_deck_forward_pressure_aftershock_condenser_outlet_clamp_ambush_activated
	):
		return false
	var activation_provider: Node = provider if provider != null else _player
	if not _is_outlet_clamp_ambush_provider_in_range(activation_provider):
		return false
	_lower_deck_forward_pressure_aftershock_condenser_outlet_clamp_ambush_activated = true
	_sync_outlet_clamp_ambush_state()
	_set_outlet_clamp_ambush_attack_target(activation_provider)
	_begin_outlet_clamp_ambush_pacing()
	_refresh_factory_route_objective()
	return true


## Starts the Story098 outlet drip vent traversal beyond the clamp ambush.
func try_activate_factory_lower_deck_forward_pressure_aftershock_condenser_outlet_drip_vent(
	provider: Node = null
) -> bool:
	if (
		_lower_deck_forward_pressure_aftershock_condenser_drain_gantry == null
		or _lower_deck_forward_pressure_aftershock_condenser_drip_vent == null
		or not _is_outlet_drip_vent_available()
		or _lower_deck_forward_pressure_aftershock_condenser_drip_vent_activated
	):
		return false
	var activation_provider: Node = provider if provider != null else _player
	if not _is_outlet_drip_vent_provider_at_activation(activation_provider):
		return false
	_lower_deck_forward_pressure_aftershock_condenser_drip_vent_activated = true
	_lower_deck_forward_pressure_aftershock_condenser_drip_vent_elapsed_sec = 0.0
	_sync_outlet_drip_vent_state()
	_refresh_factory_route_objective()
	return true


## Advances the outlet drip vent cycle deterministically for tests/MCP.
func advance_factory_lower_deck_forward_pressure_aftershock_condenser_outlet_drip_vent_time(
	delta_sec: float
) -> void:
	if not _is_outlet_drip_vent_active():
		return
	var safe_delta_sec: float = maxf(0.0, delta_sec)
	_lower_deck_forward_pressure_aftershock_condenser_drip_vent_elapsed_sec += safe_delta_sec
	_factory_hazard_elapsed_sec += safe_delta_sec
	_sync_outlet_drip_vent_state()


## Completes the Story098 outlet drip vent traversal after Cinderpaw reaches the far edge.
func try_complete_factory_lower_deck_forward_pressure_aftershock_condenser_outlet_drip_vent(
	provider: Node = null
) -> bool:
	if (
		_lower_deck_forward_pressure_aftershock_condenser_drain_gantry == null
		or _lower_deck_forward_pressure_aftershock_condenser_drip_vent == null
		or not _is_outlet_drip_vent_active()
		or _lower_deck_forward_pressure_aftershock_condenser_drip_vent_crossed
	):
		return false
	var completion_provider: Node = provider if provider != null else _player
	if not _is_outlet_drip_vent_provider_at_exit(completion_provider):
		return false
	_lower_deck_forward_pressure_aftershock_condenser_drip_vent_activated = true
	_lower_deck_forward_pressure_aftershock_condenser_drip_vent_crossed = true
	_lower_deck_forward_pressure_aftershock_condenser_drip_vent_elapsed_sec = 0.0
	_sync_outlet_drip_vent_state()
	_refresh_factory_route_objective()
	return true


## Starts the Story099 overflow pump skirmish beyond the outlet drip vent.
func try_activate_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump(
	provider: Node = null
) -> bool:
	if (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_coil_rat == null
		or not _is_overflow_pump_available()
		or _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_activated
	):
		return false
	var activation_provider: Node = provider if provider != null else _player
	if not _is_overflow_pump_provider_in_range(activation_provider):
		return false
	_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_activated = true
	_sync_overflow_pump_state()
	_set_overflow_pump_attack_target(activation_provider)
	_begin_overflow_pump_pacing(
		FACTORY_AFTERSHOCK_CONDENSER_OVERFLOW_COIL_OPENING_GRACE_FRAMES
	)
	_refresh_factory_route_objective()
	return true


## Attempts to activate the relay-forward combat trial after the breach relay is repaired.
func try_activate_factory_lower_deck_post_relay_trial(provider: Node = null) -> bool:
	if (
		_lower_deck_post_relay_spark_rat == null
		or not _is_lower_deck_post_relay_trial_available()
		or _lower_deck_post_relay_trial_activated
	):
		return false
	var activation_provider: Node = provider if provider != null else _player
	if not _is_lower_deck_post_relay_trial_provider_in_range(activation_provider):
		return false
	_lower_deck_post_relay_trial_activated = true
	_sync_lower_deck_post_relay_trial_state()
	_set_lower_deck_post_relay_trial_attack_target(activation_provider)
	_begin_lower_deck_post_relay_trial_pacing(FACTORY_SPARK_RAT_OPENING_GRACE_FRAMES)
	_refresh_factory_route_objective()
	return true


## Opens the relay-forward hatch after the post-relay reward cache is claimed.
func try_open_factory_lower_deck_forward_hatch(provider: Node = null) -> bool:
	if (
		_lower_deck_forward_hatch == null
		or not _is_lower_deck_forward_hatch_available()
		or _lower_deck_forward_hatch_opened
	):
		return false
	var activation_provider: Node = provider if provider != null else _player
	if (
		not _lower_deck_forward_hatch.has_method("try_activate")
		or not bool(_lower_deck_forward_hatch.call("try_activate", activation_provider))
	):
		return false
	_lower_deck_forward_hatch_opened = true
	_sync_lower_deck_forward_hatch_state()
	_refresh_factory_route_objective()
	return true


## Attempts to activate the deeper forward conduit ambush after the hatch opens.
func try_activate_factory_lower_deck_forward_conduit(provider: Node = null) -> bool:
	if (
		_lower_deck_forward_conduit_spark_rat == null
		or not _is_lower_deck_forward_conduit_available()
		or _lower_deck_forward_conduit_activated
	):
		return false
	var activation_provider: Node = provider if provider != null else _player
	if not _is_lower_deck_forward_conduit_provider_in_range(activation_provider):
		return false
	_lower_deck_forward_conduit_activated = true
	_sync_lower_deck_forward_conduit_state()
	_set_lower_deck_forward_conduit_attack_target(activation_provider)
	_begin_lower_deck_forward_conduit_pacing(FACTORY_SPARK_RAT_OPENING_GRACE_FRAMES)
	_refresh_factory_route_objective()
	return true


## Starts the forward pressure traversal cycle after the conduit is secured.
func try_activate_factory_lower_deck_forward_pressure_traverse(provider: Node = null) -> bool:
	if (
		_lower_deck_forward_pressure_vent == null
		or not _is_lower_deck_forward_pressure_traverse_available()
		or _lower_deck_forward_pressure_traverse_active
	):
		return false
	var activation_provider: Node = provider if provider != null else _player
	if not _is_lower_deck_forward_pressure_provider_at_activation(activation_provider):
		return false
	_lower_deck_forward_pressure_traverse_active = true
	_lower_deck_forward_pressure_traverse_elapsed_sec = 0.0
	_sync_lower_deck_forward_pressure_traverse_state()
	_refresh_factory_route_objective()
	return true


## Advances the forward pressure cycle deterministically for tests and MCP probes.
func advance_factory_lower_deck_forward_pressure_traverse_time(delta_sec: float) -> void:
	if not _lower_deck_forward_pressure_traverse_active:
		return
	var safe_delta_sec: float = maxf(0.0, delta_sec)
	_lower_deck_forward_pressure_traverse_elapsed_sec += safe_delta_sec
	_factory_hazard_elapsed_sec += safe_delta_sec
	_sync_lower_deck_forward_pressure_traverse_state()


## Completes the forward pressure traversal once Cinderpaw reaches the exit edge.
func try_complete_factory_lower_deck_forward_pressure_traverse(provider: Node = null) -> bool:
	if (
		_lower_deck_forward_pressure_vent == null
		or not _lower_deck_forward_pressure_traverse_active
		or _lower_deck_forward_pressure_traverse_crossed
	):
		return false
	var completion_provider: Node = provider if provider != null else _player
	if not _is_lower_deck_forward_pressure_provider_at_exit(completion_provider):
		return false
	_lower_deck_forward_pressure_traverse_active = false
	_lower_deck_forward_pressure_traverse_crossed = true
	_lower_deck_forward_pressure_traverse_elapsed_sec = 0.0
	_sync_lower_deck_forward_pressure_traverse_state()
	_refresh_factory_route_objective()
	return true


## Attempts to activate the pressure counter-ambush after Cinderpaw crosses the leak.
func try_activate_factory_lower_deck_forward_pressure_counter_ambush(
	provider: Node = null
) -> bool:
	if (
		_lower_deck_forward_counter_spark_rat == null
		or _lower_deck_forward_counter_pressure_vent == null
		or not _is_lower_deck_forward_pressure_counter_ambush_available()
		or _lower_deck_forward_pressure_counter_ambush_activated
	):
		return false
	var activation_provider: Node = provider if provider != null else _player
	if not _is_lower_deck_forward_counter_ambush_provider_in_range(activation_provider):
		return false
	_lower_deck_forward_pressure_counter_ambush_activated = true
	_sync_lower_deck_forward_pressure_counter_ambush_state()
	_set_lower_deck_forward_counter_ambush_attack_target(activation_provider)
	_begin_lower_deck_forward_counter_ambush_pacing(FACTORY_SPARK_RAT_OPENING_GRACE_FRAMES)
	_refresh_factory_route_objective()
	return true


## Attempts to activate the deep route endpoint after its guard is defeated.
func try_activate_factory_deep_route_endpoint(provider: Node = null) -> bool:
	if not _deep_guard_defeated or _deep_endpoint == null:
		return false
	var activation_provider: Node = provider
	if activation_provider == null:
		activation_provider = _player
	if not _deep_endpoint.has_method("try_activate") \
			or not bool(_deep_endpoint.call("try_activate", activation_provider)):
		return false
	_deep_route_cleared = true
	_sync_deep_route_state()
	_refresh_factory_route_objective()
	return true


## Advances scene-local hazard time and applies sustained overlap ticks.
func advance_factory_hazard_time(delta_sec: float) -> void:
	_factory_hazard_elapsed_sec += maxf(0.0, delta_sec)
	_process_factory_hazard_overlaps()


## Advances the Spark Rat pacing loop deterministically for tests and MCP probes.
func advance_factory_spark_rat_pacing_frames(frames: int) -> void:
	if _spark_rat == null or not _spark_rat_activated or _spark_rat_defeated:
		return
	if _spark_rat.has_method("advance_pacing_frames"):
		_spark_rat.call("advance_pacing_frames", frames)


## Advances the checkpoint overdrive duo pacing loop deterministically for tests and MCP probes.
func advance_factory_checkpoint_overdrive_duo_pacing_frames(frames: int) -> void:
	var safe_frames: int = maxi(0, frames)
	if (
		_checkpoint_overdrive_left_spark_rat != null
		and _checkpoint_overdrive_left_spark_rat.has_method("advance_pacing_frames")
		and _checkpoint_overdrive_duo_activated
		and not _checkpoint_overdrive_left_defeated
	):
		_checkpoint_overdrive_left_spark_rat.call("advance_pacing_frames", safe_frames)
	if (
		_checkpoint_overdrive_right_spark_rat != null
		and _checkpoint_overdrive_right_spark_rat.has_method("advance_pacing_frames")
		and _checkpoint_overdrive_duo_activated
		and not _checkpoint_overdrive_right_defeated
	):
		_checkpoint_overdrive_right_spark_rat.call("advance_pacing_frames", safe_frames)


## Applies steam vent contact damage to the player with per-target cooldown.
func apply_factory_steam_vent_contact(hazard: Area2D, target: Node) -> bool:
	if hazard == null or target == null or _player == null or not is_instance_valid(hazard):
		return false
	if target != _player:
		return false
	if _factory_hazard_respawn_grace_frames > 0:
		return false
	var hazard_id: StringName = _get_hazard_id(hazard)
	if not _is_factory_steam_hazard_id(hazard_id):
		return false
	if not _is_hazard_contact_active(hazard):
		return false
	var target_id: int = PlayerController.PLAYER_ENTITY_ID
	var cooldown_key: String = _factory_hazard_cooldown_key(hazard_id, target_id)
	var next_allowed_sec: float = float(_factory_hazard_contact_cooldowns.get(cooldown_key, -1.0))
	if next_allowed_sec > _factory_hazard_elapsed_sec:
		return false
	var steam_damage: int = _get_hazard_damage(hazard)
	var hp_before: int = int(_player.call("get_current_hp")) if _player.has_method("get_current_hp") else 0
	var damage_data: Dictionary = {
		"damage": steam_damage,
		"final_damage": steam_damage,
		"hit_position": hazard.global_position,
		"is_crit": false,
		"source": hazard_id,
		"damage_type": &"steam",
		"scene_id": FACTORY_SCENE_ID,
		"target_id": target_id,
	}
	if _player.has_method("apply_damage"):
		_player.call("apply_damage", steam_damage, damage_data)
	var hp_after: int = int(_player.call("get_current_hp")) if _player.has_method("get_current_hp") else hp_before
	if hp_after >= hp_before:
		return false
	_last_hazard_damage = damage_data.duplicate(true)
	_factory_hazard_contact_cooldowns[cooldown_key] = (
		_factory_hazard_elapsed_sec + _get_hazard_cooldown_sec(hazard)
	)
	_update_route_label("Steam vent hit")
	return true


## Captures scene-local state for SceneManager runtime swap persistence.
func get_local_state() -> Dictionary:
	return {
		"encounter_cleared": _encounter_cleared,
		"factory_cache_claimed": _cache_claimed,
		"factory_deep_guard_activated": _deep_guard_activated,
		"factory_deep_guard_defeated": _deep_guard_defeated,
		"factory_deep_route_cleared": _deep_route_cleared,
		"factory_spark_rat_activated": _spark_rat_activated,
		"factory_spark_rat_defeated": _spark_rat_defeated,
		"factory_spark_rat_opening_grace_frames": _get_spark_rat_opening_grace_frames(),
		"factory_return_patrol_activated": _return_patrol_activated,
		"factory_return_patrol_defeated": _return_patrol_defeated,
		"factory_checkpoint_forward_patrol_activated": _checkpoint_forward_patrol_activated,
		"factory_checkpoint_forward_patrol_defeated": _checkpoint_forward_patrol_defeated,
		"factory_checkpoint_forward_patrol_opening_grace_frames": (
			_get_checkpoint_forward_patrol_opening_grace_frames()
		),
		"factory_checkpoint_rear_ambush_activated": _checkpoint_rear_ambush_activated,
		"factory_checkpoint_rear_ambush_defeated": _checkpoint_rear_ambush_defeated,
		"factory_checkpoint_rear_ambush_opening_grace_frames": (
			_get_checkpoint_rear_ambush_opening_grace_frames()
		),
		"factory_checkpoint_overdrive_duo_activated": _checkpoint_overdrive_duo_activated,
		"factory_checkpoint_overdrive_left_defeated": _checkpoint_overdrive_left_defeated,
		"factory_checkpoint_overdrive_right_defeated": _checkpoint_overdrive_right_defeated,
		"factory_checkpoint_overdrive_duo_cleared": _is_checkpoint_overdrive_duo_cleared(),
		"factory_checkpoint_overdrive_duo_opening_grace_frames": (
			_get_checkpoint_overdrive_duo_opening_grace_frames()
		),
		"factory_checkpoint_overdrive_left_opening_grace_frames": (
			_get_checkpoint_overdrive_left_opening_grace_frames()
		),
		"factory_checkpoint_overdrive_right_opening_grace_frames": (
			_get_checkpoint_overdrive_right_opening_grace_frames()
		),
		"factory_lower_deck_skirmish_activated": _lower_deck_skirmish_activated,
		"factory_lower_deck_skirmish_defeated": _lower_deck_skirmish_defeated,
		"factory_lower_deck_skirmish_opening_grace_frames": (
			_get_lower_deck_skirmish_opening_grace_frames()
		),
		"factory_lower_deck_parry_gate_unlocked": _lower_deck_parry_gate_unlocked,
		"factory_lower_deck_exit_ambush_activated": _lower_deck_exit_ambush_activated,
		"factory_lower_deck_exit_ambush_defeated": _lower_deck_exit_ambush_defeated,
		"factory_lower_deck_exit_ambush_opening_grace_frames": (
			_get_lower_deck_exit_ambush_opening_grace_frames()
		),
		"factory_lower_deck_shortcut_activated": _lower_deck_shortcut_activated,
		"factory_lower_deck_shortcut_guard_defeated": (
			_lower_deck_shortcut_guard_defeated
		),
		"factory_lower_deck_shortcut_unlocked": _lower_deck_shortcut_unlocked,
		"factory_lower_deck_shortcut_opening_grace_frames": (
			_get_lower_deck_shortcut_opening_grace_frames()
		),
		"factory_return_patrol_reward_cache_claimed": _return_patrol_reward_cache_claimed,
		"factory_checkpoint_overdrive_reward_cache_claimed": (
			_checkpoint_overdrive_reward_cache_claimed
		),
		"factory_lower_deck_reward_cache_claimed": _lower_deck_reward_cache_claimed,
		"factory_lower_deck_shortcut_reward_cache_claimed": (
			_lower_deck_shortcut_reward_cache_claimed
		),
		"factory_lower_deck_shortcut_pursuer_activated": (
			_lower_deck_shortcut_pursuer_activated
		),
		"factory_lower_deck_shortcut_pursuer_defeated": (
			_lower_deck_shortcut_pursuer_defeated
		),
		"factory_lower_deck_pressure_guard_activated": (
			_lower_deck_pressure_guard_activated
		),
		"factory_lower_deck_pressure_guard_defeated": (
			_lower_deck_pressure_guard_defeated
		),
		"factory_lower_deck_pressure_valve_opened": _lower_deck_pressure_valve_opened,
		"factory_lower_deck_steam_sluice_activated": (
			_lower_deck_steam_sluice_activated
		),
		"factory_lower_deck_steam_sluice_defeated": _lower_deck_steam_sluice_defeated,
		"factory_lower_deck_deep_bulkhead_guard_activated": (
			_lower_deck_deep_bulkhead_guard_activated
		),
		"factory_lower_deck_deep_bulkhead_guard_defeated": (
			_lower_deck_deep_bulkhead_guard_defeated
		),
		"factory_lower_deck_deep_bulkhead_opened": _lower_deck_deep_bulkhead_opened,
		"factory_lower_deck_breach_corridor_activated": (
			_lower_deck_breach_corridor_activated
		),
		"factory_lower_deck_breach_front_guard_defeated": (
			_lower_deck_breach_front_guard_defeated
		),
		"factory_lower_deck_breach_rear_ambusher_activated": (
			_lower_deck_breach_rear_ambusher_activated
		),
		"factory_lower_deck_breach_rear_ambusher_defeated": (
			_lower_deck_breach_rear_ambusher_defeated
		),
		"factory_lower_deck_breach_corridor_secured": (
			_lower_deck_breach_corridor_secured
		),
		"factory_lower_deck_breach_relay_activated": (
			_lower_deck_breach_relay_activated
		),
		"factory_lower_deck_post_relay_trial_activated": (
			_lower_deck_post_relay_trial_activated
		),
		"factory_lower_deck_post_relay_trial_defeated": (
			_lower_deck_post_relay_trial_defeated
		),
		"factory_lower_deck_relay_forward_reward_cache_claimed": (
			_lower_deck_relay_forward_reward_cache_claimed
		),
		"factory_lower_deck_forward_hatch_opened": _lower_deck_forward_hatch_opened,
		"factory_lower_deck_forward_conduit_activated": (
			_lower_deck_forward_conduit_activated
		),
		"factory_lower_deck_forward_conduit_defeated": (
			_lower_deck_forward_conduit_defeated
		),
		"factory_lower_deck_forward_pressure_traverse_crossed": (
			_lower_deck_forward_pressure_traverse_crossed
		),
		"factory_lower_deck_forward_pressure_counter_ambush_activated": (
			_lower_deck_forward_pressure_counter_ambush_activated
		),
		"factory_lower_deck_forward_pressure_counter_ambush_defeated": (
			_lower_deck_forward_pressure_counter_ambush_defeated
		),
		"factory_lower_deck_forward_pressure_reward_cache_claimed": (
			_lower_deck_forward_pressure_reward_cache_claimed
		),
		"factory_lower_deck_forward_pressure_exit_guard_activated": (
			_lower_deck_forward_pressure_exit_guard_activated
		),
		"factory_lower_deck_forward_pressure_exit_guard_defeated": (
			_lower_deck_forward_pressure_exit_guard_defeated
		),
		"factory_lower_deck_forward_pressure_exit_guard_opening_grace_frames": (
			_get_lower_deck_forward_exit_guard_opening_grace_frames()
		),
		"factory_lower_deck_forward_pressure_exit_relay_activated": (
			_lower_deck_forward_pressure_exit_relay_activated
		),
		"factory_lower_deck_forward_pressure_exit_gate_opened": (
			_lower_deck_forward_pressure_exit_gate_opened
		),
		"factory_lower_deck_forward_pressure_route_handoff_marker_lit": (
			_lower_deck_forward_pressure_route_handoff_marker_lit
		),
		"factory_lower_deck_forward_pressure_beacon_ambush_activated": (
			_lower_deck_forward_pressure_beacon_ambush_activated
		),
		"factory_lower_deck_forward_pressure_beacon_ambush_defeated": (
			_lower_deck_forward_pressure_beacon_ambush_defeated
		),
		"factory_lower_deck_forward_pressure_overrun_activated": (
			_lower_deck_forward_pressure_overrun_activated
		),
		"factory_lower_deck_forward_pressure_overrun_defeated": (
			_lower_deck_forward_pressure_overrun_defeated
		),
		"factory_lower_deck_forward_pressure_breaker_activated": (
			_lower_deck_forward_pressure_breaker_activated
		),
		"factory_lower_deck_forward_pressure_breaker_secured": (
			_lower_deck_forward_pressure_breaker_secured
		),
		"factory_lower_deck_forward_pressure_breaker_cut": (
			_lower_deck_forward_pressure_breaker_cut
		),
		"factory_lower_deck_forward_pressure_relief_ambush_activated": (
			_lower_deck_forward_pressure_relief_ambush_activated
		),
		"factory_lower_deck_forward_pressure_relief_ambush_defeated": (
			_lower_deck_forward_pressure_relief_ambush_defeated
		),
		"factory_lower_deck_forward_pressure_coil_rat_breakthrough_activated": (
			_lower_deck_forward_pressure_coil_rat_activated
		),
		"factory_lower_deck_forward_pressure_coil_rat_breakthrough_defeated": (
			_lower_deck_forward_pressure_coil_rat_defeated
		),
		"factory_lower_deck_forward_pressure_coil_pincer_activated": (
			_lower_deck_forward_pressure_coil_pincer_activated
		),
		"factory_lower_deck_forward_pressure_coil_pincer_spark_rat_defeated": (
			_lower_deck_forward_pressure_coil_pincer_spark_rat_defeated
		),
		"factory_lower_deck_forward_pressure_coil_pincer_coil_rat_defeated": (
			_lower_deck_forward_pressure_coil_pincer_coil_rat_defeated
		),
		"factory_lower_deck_forward_pressure_coil_pincer_cleared": (
			_is_lower_deck_forward_pressure_coil_pincer_cleared()
		),
		"factory_lower_deck_forward_pressure_coil_aftershock_activated": (
			_lower_deck_forward_pressure_coil_aftershock_activated
		),
		"factory_lower_deck_forward_pressure_coil_aftershock_coil_rat_defeated": (
			_lower_deck_forward_pressure_coil_aftershock_defeated
		),
		"factory_lower_deck_forward_pressure_coil_aftershock_cleared": (
			_lower_deck_forward_pressure_coil_aftershock_defeated
		),
		"factory_lower_deck_forward_pressure_aftershock_reward_cache_claimed": (
			_lower_deck_forward_pressure_aftershock_reward_cache_claimed
		),
		"factory_lower_deck_forward_pressure_aftershock_exit_skirmish_activated": (
			_lower_deck_forward_pressure_aftershock_exit_skirmish_activated
		),
		"factory_lower_deck_forward_pressure_aftershock_exit_skirmish_spark_rat_defeated": (
			_lower_deck_forward_pressure_aftershock_exit_spark_rat_defeated
		),
		"factory_lower_deck_forward_pressure_aftershock_exit_skirmish_coil_rat_defeated": (
			_lower_deck_forward_pressure_aftershock_exit_coil_rat_defeated
		),
		"factory_lower_deck_forward_pressure_aftershock_exit_skirmish_cleared": (
			_is_lower_deck_forward_pressure_aftershock_exit_skirmish_cleared()
		),
		"factory_lower_deck_forward_pressure_aftershock_exhaust_activated": (
			_lower_deck_forward_pressure_aftershock_exhaust_activated
		),
		"factory_lower_deck_forward_pressure_aftershock_exhaust_crossed": (
			_lower_deck_forward_pressure_aftershock_exhaust_crossed
		),
		"factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_activated": (
			_lower_deck_forward_pressure_aftershock_exhaust_pursuer_activated
		),
		"factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_coil_rat_defeated": (
			_lower_deck_forward_pressure_aftershock_exhaust_pursuer_defeated
		),
		"factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_cleared": (
			_lower_deck_forward_pressure_aftershock_exhaust_pursuer_defeated
		),
		"factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache_claimed": (
			_lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache_claimed
		),
		"factory_lower_deck_forward_pressure_aftershock_exhaust_flank_ambush_activated": (
			_lower_deck_forward_pressure_aftershock_exhaust_flank_activated
		),
		"factory_lower_deck_forward_pressure_aftershock_exhaust_flank_ambush_spark_rat_defeated": (
			_lower_deck_forward_pressure_aftershock_exhaust_flank_spark_rat_defeated
		),
		"factory_lower_deck_forward_pressure_aftershock_exhaust_flank_ambush_cleared": (
			_lower_deck_forward_pressure_aftershock_exhaust_flank_spark_rat_defeated
		),
		"factory_lower_deck_forward_pressure_aftershock_exhaust_breaker_activated": (
			_lower_deck_forward_pressure_aftershock_exhaust_breaker_activated
		),
		"factory_lower_deck_forward_pressure_aftershock_exhaust_breaker_coil_rat_defeated": (
			_lower_deck_forward_pressure_aftershock_exhaust_breaker_coil_rat_defeated
		),
		"factory_lower_deck_forward_pressure_aftershock_exhaust_breaker_secured": (
			_lower_deck_forward_pressure_aftershock_exhaust_breaker_secured
		),
		"factory_lower_deck_forward_pressure_aftershock_exhaust_breaker_cut": (
			_lower_deck_forward_pressure_aftershock_exhaust_breaker_cut
		),
		"factory_lower_deck_forward_pressure_aftershock_exhaust_escape_skirmish_activated": (
			_lower_deck_forward_pressure_aftershock_exhaust_escape_skirmish_activated
		),
		"factory_lower_deck_forward_pressure_aftershock_exhaust_escape_skirmish_spark_rat_defeated": (
			_lower_deck_forward_pressure_aftershock_exhaust_escape_spark_rat_defeated
		),
		"factory_lower_deck_forward_pressure_aftershock_exhaust_escape_skirmish_coil_rat_defeated": (
			_lower_deck_forward_pressure_aftershock_exhaust_escape_coil_rat_defeated
		),
		"factory_lower_deck_forward_pressure_aftershock_exhaust_escape_skirmish_cleared": (
			_is_lower_deck_forward_pressure_aftershock_exhaust_escape_skirmish_cleared()
		),
		"factory_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch_opened": (
			_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch_opened
		),
		"factory_lower_deck_forward_pressure_aftershock_cooling_duct_activated": (
			_lower_deck_forward_pressure_aftershock_cooling_duct_activated
		),
		"factory_lower_deck_forward_pressure_aftershock_cooling_duct_crossed": (
			_lower_deck_forward_pressure_aftershock_cooling_duct_crossed
		),
		"factory_lower_deck_forward_pressure_aftershock_condenser_valve_activated": (
			_lower_deck_forward_pressure_aftershock_condenser_valve_activated
		),
		"factory_lower_deck_forward_pressure_aftershock_condenser_valve_spark_rat_defeated": (
			_lower_deck_forward_pressure_aftershock_condenser_valve_spark_rat_defeated
		),
		"factory_lower_deck_forward_pressure_aftershock_condenser_valve_coil_rat_defeated": (
			_lower_deck_forward_pressure_aftershock_condenser_valve_coil_rat_defeated
		),
		"factory_lower_deck_forward_pressure_aftershock_condenser_valve_cleared": (
			_is_lower_deck_forward_pressure_aftershock_condenser_valve_cleared()
		),
		"factory_lower_deck_forward_pressure_aftershock_condenser_savepoint_activated": (
			_lower_deck_forward_pressure_aftershock_condenser_savepoint_activated
		),
		"factory_lower_deck_forward_pressure_aftershock_condenser_outlet_activated": (
			_lower_deck_forward_pressure_aftershock_condenser_outlet_activated
		),
		"factory_lower_deck_forward_pressure_aftershock_condenser_outlet_crossed": (
			_lower_deck_forward_pressure_aftershock_condenser_outlet_crossed
		),
		"factory_lower_deck_forward_pressure_aftershock_condenser_outlet_clamp_ambush_activated": (
			_lower_deck_forward_pressure_aftershock_condenser_outlet_clamp_ambush_activated
		),
		"factory_lower_deck_forward_pressure_aftershock_condenser_outlet_clamp_ambush_spark_rat_defeated": (
			_lower_deck_forward_pressure_aftershock_condenser_outlet_clamp_spark_rat_defeated
		),
		"factory_lower_deck_forward_pressure_aftershock_condenser_outlet_clamp_ambush_cleared": (
			_is_outlet_clamp_ambush_cleared()
		),
		"factory_lower_deck_forward_pressure_aftershock_condenser_outlet_drip_vent_activated": (
			_lower_deck_forward_pressure_aftershock_condenser_drip_vent_activated
		),
		"factory_lower_deck_forward_pressure_aftershock_condenser_outlet_drip_vent_crossed": (
			_lower_deck_forward_pressure_aftershock_condenser_drip_vent_crossed
		),
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_activated": (
			_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_activated
		),
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_coil_rat_defeated": (
			_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_coil_rat_defeated
		),
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_cleared": (
			_is_overflow_pump_cleared()
		),
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_reward_cache_claimed": (
			_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_reward_cache_claimed
		),
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_exit_hatch_opened": (
			_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_exit_hatch_opened
		),
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_duct_activated": (
			_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_duct_activated
		),
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_duct_crossed": (
			_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_duct_crossed
		),
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_skirmish_activated": (
			_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_skirmish_activated
		),
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_coil_rat_defeated": (
			_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_coil_rat_defeated
		),
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_skirmish_cleared": (
			_is_overflow_pump_runoff_exit_skirmish_cleared()
		),
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_reward_cache_claimed": (
			_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_reward_cache_claimed
		),
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_gate_opened": (
			_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_gate_opened
		),
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_activated": (
			_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_activated
		),
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_crossed": (
			_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_crossed
		),
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_skirmish_activated": (
			_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_skirmish_activated
		),
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_spark_rat_defeated": (
			_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_spark_rat_defeated
		),
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_skirmish_cleared": (
			_is_overflow_pump_runoff_outlet_skirmish_cleared()
		),
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_reward_cache_claimed": (
			_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_reward_cache_claimed
		),
			"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_hatch_opened": (
				_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_hatch_opened
			),
			"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_activated": (
				_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_activated
			),
			"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_crossed": (
				_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_crossed
			),
			"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_skirmish_activated": (
				_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_skirmish_activated
			),
			"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_spark_rat_defeated": (
				_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_spark_rat_defeated
			),
			"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_skirmish_cleared": (
				_is_overflow_pump_runoff_outlet_service_sluice_skirmish_cleared()
			),
			"factory_return_checkpoint_activated": _return_checkpoint_activated,
		"factory_route_objective_id": String(_get_factory_route_objective_id()),
		"factory_service_lift_activated": _service_lift_activated,
		"factory_service_lift_exit_requested": _service_lift_exit_requested,
		"factory_service_lift_exit_scene_id": String(FACTORY_SERVICE_LIFT_EXIT_SCENE_ID),
		"factory_service_lift_exit_spawn_point": String(FACTORY_SERVICE_LIFT_EXIT_SPAWN_POINT),
		"factory_service_lift_exit_rejected_reason": String(_last_service_lift_exit_rejected_reason),
		"factory_service_lift_exit_request": _last_service_lift_exit_request.duplicate(true),
		"last_cache_reward": _last_cache_reward.duplicate(true),
		"last_cache_claim_feedback": _last_cache_claim_feedback.duplicate(true),
		"last_return_patrol_reward_cache_reward": (
			_last_return_patrol_reward_cache_reward.duplicate(true)
		),
		"last_return_patrol_reward_cache_claim_feedback": (
			_last_return_patrol_reward_cache_claim_feedback.duplicate(true)
		),
		"last_checkpoint_overdrive_reward_cache_reward": (
			_last_checkpoint_overdrive_reward_cache_reward.duplicate(true)
		),
		"last_checkpoint_overdrive_reward_cache_claim_feedback": (
			_last_checkpoint_overdrive_reward_cache_claim_feedback.duplicate(true)
		),
		"last_lower_deck_reward_cache_reward": (
			_last_lower_deck_reward_cache_reward.duplicate(true)
		),
		"last_lower_deck_reward_cache_claim_feedback": (
			_last_lower_deck_reward_cache_claim_feedback.duplicate(true)
		),
		"last_lower_deck_shortcut_reward_cache_reward": (
			_last_lower_deck_shortcut_reward_cache_reward.duplicate(true)
		),
		"last_lower_deck_shortcut_reward_cache_claim_feedback": (
			_last_lower_deck_shortcut_reward_cache_claim_feedback.duplicate(true)
		),
		"last_lower_deck_relay_forward_reward_cache_reward": (
			_last_lower_deck_relay_forward_reward_cache_reward.duplicate(true)
		),
		"last_lower_deck_relay_forward_reward_cache_claim_feedback": (
			_last_lower_deck_relay_forward_reward_cache_claim_feedback.duplicate(true)
		),
		"last_lower_deck_forward_pressure_reward_cache_reward": (
			_last_lower_deck_forward_pressure_reward_cache_reward.duplicate(true)
		),
		"last_lower_deck_forward_pressure_reward_cache_claim_feedback": (
			_last_lower_deck_forward_pressure_reward_cache_claim_feedback.duplicate(true)
		),
		"last_lower_deck_forward_pressure_aftershock_reward_cache_reward": (
			_last_lower_deck_forward_pressure_aftershock_reward_cache_reward.duplicate(true)
		),
		"last_lower_deck_forward_pressure_aftershock_reward_cache_claim_feedback": (
			_last_lower_deck_forward_pressure_aftershock_reward_cache_claim_feedback.duplicate(
				true
			)
		),
		"last_lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache_reward": (
			_last_lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache_reward.duplicate(
				true
			)
		),
		"last_lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache_claim_feedback": (
			_last_lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache_claim_feedback.duplicate(
				true
			)
		),
		"last_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_reward_cache_reward": (
			_last_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_reward_cache_reward
			.duplicate(true)
		),
		"last_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_reward_cache_claim_feedback": (
			_last_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_reward_cache_claim_feedback
			.duplicate(true)
		),
		"last_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_reward_cache_reward": (
			_last_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_reward_cache_reward
			.duplicate(true)
		),
		"last_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_reward_cache_claim_feedback": (
			_last_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_reward_cache_claim_feedback
			.duplicate(true)
		),
		"last_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_reward_cache_reward": (
			_last_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_reward_cache_reward
			.duplicate(true)
		),
		"last_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_reward_cache_claim_feedback": (
			_last_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_reward_cache_claim_feedback
			.duplicate(true)
		),
		"last_return_checkpoint": _last_return_checkpoint.duplicate(true),
		"last_savepoint": _last_return_checkpoint.duplicate(true),
		"last_hazard_damage": _last_hazard_damage.duplicate(true),
	}


## Restores scene-local state from SceneManager runtime swap persistence.
func set_local_state(state: Dictionary) -> void:
	_encounter_cleared = bool(state.get("encounter_cleared", false))
	_cache_claimed = bool(state.get("factory_cache_claimed", false))
	_deep_guard_activated = bool(state.get("factory_deep_guard_activated", false))
	_deep_guard_defeated = bool(state.get("factory_deep_guard_defeated", false))
	_deep_route_cleared = bool(state.get("factory_deep_route_cleared", false))
	_spark_rat_activated = bool(state.get("factory_spark_rat_activated", false))
	_spark_rat_defeated = bool(state.get("factory_spark_rat_defeated", false))
	_return_patrol_defeated = bool(state.get("factory_return_patrol_defeated", false))
	_return_patrol_activated = bool(state.get(
		"factory_return_patrol_activated",
		_is_service_lift_return_contract_in_state(state) and not _return_patrol_defeated
	))
	_checkpoint_forward_patrol_activated = bool(state.get(
		"factory_checkpoint_forward_patrol_activated",
		false
	))
	_checkpoint_forward_patrol_defeated = bool(state.get(
		"factory_checkpoint_forward_patrol_defeated",
		false
	))
	_checkpoint_rear_ambush_activated = bool(state.get(
		"factory_checkpoint_rear_ambush_activated",
		false
	))
	_checkpoint_rear_ambush_defeated = bool(state.get(
		"factory_checkpoint_rear_ambush_defeated",
		false
	))
	_checkpoint_overdrive_duo_activated = bool(state.get(
		"factory_checkpoint_overdrive_duo_activated",
		false
	))
	_checkpoint_overdrive_left_defeated = bool(state.get(
		"factory_checkpoint_overdrive_left_defeated",
		false
	))
	_checkpoint_overdrive_right_defeated = bool(state.get(
		"factory_checkpoint_overdrive_right_defeated",
		false
	))
	if bool(state.get("factory_checkpoint_overdrive_duo_cleared", false)):
		_checkpoint_overdrive_left_defeated = true
		_checkpoint_overdrive_right_defeated = true
	_lower_deck_skirmish_activated = bool(state.get(
		"factory_lower_deck_skirmish_activated",
		false
	))
	_lower_deck_skirmish_defeated = bool(state.get(
		"factory_lower_deck_skirmish_defeated",
		false
	))
	_lower_deck_parry_gate_unlocked = bool(state.get(
		"factory_lower_deck_parry_gate_unlocked",
		false
	))
	_lower_deck_exit_ambush_activated = bool(state.get(
		"factory_lower_deck_exit_ambush_activated",
		false
	))
	_lower_deck_exit_ambush_defeated = bool(state.get(
		"factory_lower_deck_exit_ambush_defeated",
		false
	))
	_lower_deck_shortcut_activated = bool(state.get(
		"factory_lower_deck_shortcut_activated",
		false
	))
	_lower_deck_shortcut_guard_defeated = bool(state.get(
		"factory_lower_deck_shortcut_guard_defeated",
		false
	))
	_lower_deck_shortcut_unlocked = bool(state.get(
		"factory_lower_deck_shortcut_unlocked",
		false
	))
	_return_patrol_reward_cache_claimed = bool(state.get(
		"factory_return_patrol_reward_cache_claimed",
		false
	))
	_checkpoint_overdrive_reward_cache_claimed = bool(state.get(
		"factory_checkpoint_overdrive_reward_cache_claimed",
		false
	))
	_lower_deck_reward_cache_claimed = bool(state.get(
		"factory_lower_deck_reward_cache_claimed",
		false
	))
	_lower_deck_shortcut_reward_cache_claimed = bool(state.get(
		"factory_lower_deck_shortcut_reward_cache_claimed",
		false
	))
	_lower_deck_shortcut_pursuer_activated = bool(state.get(
		"factory_lower_deck_shortcut_pursuer_activated",
		false
	))
	_lower_deck_shortcut_pursuer_defeated = bool(state.get(
		"factory_lower_deck_shortcut_pursuer_defeated",
		false
	))
	_lower_deck_pressure_guard_activated = bool(state.get(
		"factory_lower_deck_pressure_guard_activated",
		false
	))
	_lower_deck_pressure_guard_defeated = bool(state.get(
		"factory_lower_deck_pressure_guard_defeated",
		false
	))
	_lower_deck_pressure_valve_opened = bool(state.get(
		"factory_lower_deck_pressure_valve_opened",
		false
	))
	_lower_deck_steam_sluice_activated = bool(state.get(
		"factory_lower_deck_steam_sluice_activated",
		false
	))
	_lower_deck_steam_sluice_defeated = bool(state.get(
		"factory_lower_deck_steam_sluice_defeated",
		false
	))
	_lower_deck_deep_bulkhead_guard_activated = bool(state.get(
		"factory_lower_deck_deep_bulkhead_guard_activated",
		false
	))
	_lower_deck_deep_bulkhead_guard_defeated = bool(state.get(
		"factory_lower_deck_deep_bulkhead_guard_defeated",
		false
	))
	_lower_deck_deep_bulkhead_opened = bool(state.get(
		"factory_lower_deck_deep_bulkhead_opened",
		false
	))
	_lower_deck_breach_corridor_activated = bool(state.get(
		"factory_lower_deck_breach_corridor_activated",
		false
	))
	_lower_deck_breach_front_guard_defeated = bool(state.get(
		"factory_lower_deck_breach_front_guard_defeated",
		false
	))
	_lower_deck_breach_rear_ambusher_activated = bool(state.get(
		"factory_lower_deck_breach_rear_ambusher_activated",
		false
	))
	_lower_deck_breach_rear_ambusher_defeated = bool(state.get(
		"factory_lower_deck_breach_rear_ambusher_defeated",
		false
	))
	_lower_deck_breach_corridor_secured = bool(state.get(
		"factory_lower_deck_breach_corridor_secured",
		(
			_lower_deck_breach_front_guard_defeated
			and _lower_deck_breach_rear_ambusher_defeated
		)
	))
	_lower_deck_breach_relay_activated = bool(state.get(
		"factory_lower_deck_breach_relay_activated",
		false
	))
	_lower_deck_post_relay_trial_activated = bool(state.get(
		"factory_lower_deck_post_relay_trial_activated",
		false
	))
	_lower_deck_post_relay_trial_defeated = bool(state.get(
		"factory_lower_deck_post_relay_trial_defeated",
		state.get(
			"factory_lower_deck_post_relay_spark_rat_defeated",
			state.get("factory_lower_deck_post_relay_trial_cleared", false)
		)
	))
	_lower_deck_relay_forward_reward_cache_claimed = bool(state.get(
		"factory_lower_deck_relay_forward_reward_cache_claimed",
		false
	))
	_lower_deck_forward_hatch_opened = bool(state.get(
		"factory_lower_deck_forward_hatch_opened",
		false
	))
	_lower_deck_forward_conduit_activated = bool(state.get(
		"factory_lower_deck_forward_conduit_activated",
		false
	))
	_lower_deck_forward_conduit_defeated = bool(state.get(
		"factory_lower_deck_forward_conduit_defeated",
		state.get(
			"factory_lower_deck_forward_conduit_spark_rat_defeated",
			state.get("factory_lower_deck_forward_conduit_cleared", false)
		)
	))
	_lower_deck_forward_pressure_traverse_crossed = bool(state.get(
		"factory_lower_deck_forward_pressure_traverse_crossed",
		state.get("factory_lower_deck_forward_pressure_crossed", false)
	))
	_lower_deck_forward_pressure_traverse_active = false
	_lower_deck_forward_pressure_traverse_elapsed_sec = 0.0
	_lower_deck_forward_pressure_counter_ambush_activated = bool(state.get(
		"factory_lower_deck_forward_pressure_counter_ambush_activated",
		false
	))
	_lower_deck_forward_pressure_counter_ambush_defeated = bool(state.get(
		"factory_lower_deck_forward_pressure_counter_ambush_defeated",
		state.get(
			"factory_lower_deck_forward_pressure_counter_spark_rat_defeated",
			state.get("factory_lower_deck_forward_pressure_counter_ambush_cleared", false)
		)
	))
	_lower_deck_forward_pressure_reward_cache_claimed = bool(state.get(
		"factory_lower_deck_forward_pressure_reward_cache_claimed",
		false
	))
	_lower_deck_forward_pressure_exit_guard_activated = bool(state.get(
		"factory_lower_deck_forward_pressure_exit_guard_activated",
		false
	))
	_lower_deck_forward_pressure_exit_guard_defeated = bool(state.get(
		"factory_lower_deck_forward_pressure_exit_guard_defeated",
		false
	))
	_lower_deck_forward_pressure_exit_relay_activated = bool(state.get(
		"factory_lower_deck_forward_pressure_exit_relay_activated",
		false
	))
	_lower_deck_forward_pressure_exit_gate_opened = bool(state.get(
		"factory_lower_deck_forward_pressure_exit_gate_opened",
		false
	))
	_lower_deck_forward_pressure_route_handoff_marker_lit = bool(state.get(
		"factory_lower_deck_forward_pressure_route_handoff_marker_lit",
		false
	))
	_lower_deck_forward_pressure_beacon_ambush_activated = bool(state.get(
		"factory_lower_deck_forward_pressure_beacon_ambush_activated",
		false
	))
	_lower_deck_forward_pressure_beacon_ambush_defeated = bool(state.get(
		"factory_lower_deck_forward_pressure_beacon_ambush_defeated",
		false
	))
	_lower_deck_forward_pressure_overrun_activated = bool(state.get(
		"factory_lower_deck_forward_pressure_overrun_activated",
		false
	))
	_lower_deck_forward_pressure_overrun_defeated = bool(state.get(
		"factory_lower_deck_forward_pressure_overrun_defeated",
		false
	))
	_lower_deck_forward_pressure_breaker_activated = bool(state.get(
		"factory_lower_deck_forward_pressure_breaker_activated",
		false
	))
	_lower_deck_forward_pressure_breaker_secured = bool(state.get(
		"factory_lower_deck_forward_pressure_breaker_secured",
		false
	))
	_lower_deck_forward_pressure_breaker_cut = bool(state.get(
		"factory_lower_deck_forward_pressure_breaker_cut",
		false
	))
	_lower_deck_forward_pressure_relief_ambush_activated = bool(state.get(
		"factory_lower_deck_forward_pressure_relief_ambush_activated",
		false
	))
	_lower_deck_forward_pressure_relief_ambush_defeated = bool(state.get(
		"factory_lower_deck_forward_pressure_relief_ambush_defeated",
		false
	))
	_lower_deck_forward_pressure_coil_rat_activated = bool(state.get(
		"factory_lower_deck_forward_pressure_coil_rat_breakthrough_activated",
		false
	))
	_lower_deck_forward_pressure_coil_rat_defeated = bool(state.get(
		"factory_lower_deck_forward_pressure_coil_rat_breakthrough_defeated",
		false
	))
	_lower_deck_forward_pressure_coil_pincer_activated = bool(state.get(
		"factory_lower_deck_forward_pressure_coil_pincer_activated",
		false
	))
	_lower_deck_forward_pressure_coil_pincer_spark_rat_defeated = bool(state.get(
		"factory_lower_deck_forward_pressure_coil_pincer_spark_rat_defeated",
		false
	))
	_lower_deck_forward_pressure_coil_pincer_coil_rat_defeated = bool(state.get(
		"factory_lower_deck_forward_pressure_coil_pincer_coil_rat_defeated",
		false
	))
	if bool(state.get("factory_lower_deck_forward_pressure_coil_pincer_cleared", false)):
		_lower_deck_forward_pressure_coil_pincer_spark_rat_defeated = true
		_lower_deck_forward_pressure_coil_pincer_coil_rat_defeated = true
	_lower_deck_forward_pressure_coil_aftershock_activated = bool(state.get(
		"factory_lower_deck_forward_pressure_coil_aftershock_activated",
		false
	))
	_lower_deck_forward_pressure_coil_aftershock_defeated = bool(state.get(
		"factory_lower_deck_forward_pressure_coil_aftershock_coil_rat_defeated",
		false
	))
	if bool(state.get("factory_lower_deck_forward_pressure_coil_aftershock_cleared", false)):
		_lower_deck_forward_pressure_coil_aftershock_defeated = true
	_lower_deck_forward_pressure_aftershock_reward_cache_claimed = bool(state.get(
		"factory_lower_deck_forward_pressure_aftershock_reward_cache_claimed",
		false
	))
	_lower_deck_forward_pressure_aftershock_exit_skirmish_activated = bool(state.get(
		"factory_lower_deck_forward_pressure_aftershock_exit_skirmish_activated",
		false
	))
	_lower_deck_forward_pressure_aftershock_exit_spark_rat_defeated = bool(state.get(
		"factory_lower_deck_forward_pressure_aftershock_exit_skirmish_spark_rat_defeated",
		state.get(
			"factory_lower_deck_forward_pressure_aftershock_exit_spark_rat_defeated",
			false
		)
	))
	_lower_deck_forward_pressure_aftershock_exit_coil_rat_defeated = bool(state.get(
		"factory_lower_deck_forward_pressure_aftershock_exit_skirmish_coil_rat_defeated",
		state.get(
			"factory_lower_deck_forward_pressure_aftershock_exit_coil_rat_defeated",
			false
		)
	))
	if bool(state.get(
		"factory_lower_deck_forward_pressure_aftershock_exit_skirmish_cleared",
		false
	)):
		_lower_deck_forward_pressure_aftershock_exit_spark_rat_defeated = true
		_lower_deck_forward_pressure_aftershock_exit_coil_rat_defeated = true
	_lower_deck_forward_pressure_aftershock_exhaust_crossed = bool(state.get(
		"factory_lower_deck_forward_pressure_aftershock_exhaust_crossed",
		false
	))
	_lower_deck_forward_pressure_aftershock_exhaust_activated = bool(state.get(
		"factory_lower_deck_forward_pressure_aftershock_exhaust_activated",
		_lower_deck_forward_pressure_aftershock_exhaust_crossed
	))
	_lower_deck_forward_pressure_aftershock_exhaust_elapsed_sec = 0.0
	_lower_deck_forward_pressure_aftershock_exhaust_pursuer_activated = bool(
		state.get(
			"factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_activated",
			false
		)
	)
	_lower_deck_forward_pressure_aftershock_exhaust_pursuer_defeated = bool(
		state.get(
			"factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_coil_rat_defeated",
			false
		)
	)
	if bool(state.get(
		"factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_cleared",
		false
	)):
		_lower_deck_forward_pressure_aftershock_exhaust_pursuer_defeated = true
	_lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache_claimed = bool(
		state.get(
			"factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache_claimed",
			false
		)
	)
	_lower_deck_forward_pressure_aftershock_exhaust_flank_activated = bool(
		state.get(
			"factory_lower_deck_forward_pressure_aftershock_exhaust_flank_ambush_activated",
			false
		)
	)
	_lower_deck_forward_pressure_aftershock_exhaust_flank_spark_rat_defeated = bool(
		state.get(
			"factory_lower_deck_forward_pressure_aftershock_exhaust_flank_ambush_spark_rat_defeated",
			false
		)
	)
	if bool(state.get(
		"factory_lower_deck_forward_pressure_aftershock_exhaust_flank_ambush_cleared",
		false
	)):
		_lower_deck_forward_pressure_aftershock_exhaust_flank_spark_rat_defeated = true
	_lower_deck_forward_pressure_aftershock_exhaust_breaker_cut = bool(
		state.get(
			"factory_lower_deck_forward_pressure_aftershock_exhaust_breaker_cut",
			false
		)
	)
	_lower_deck_forward_pressure_aftershock_exhaust_breaker_secured = bool(
		state.get(
			"factory_lower_deck_forward_pressure_aftershock_exhaust_breaker_secured",
			_lower_deck_forward_pressure_aftershock_exhaust_breaker_cut
		)
	)
	_lower_deck_forward_pressure_aftershock_exhaust_breaker_coil_rat_defeated = bool(
		state.get(
			"factory_lower_deck_forward_pressure_aftershock_exhaust_breaker_coil_rat_defeated",
			_lower_deck_forward_pressure_aftershock_exhaust_breaker_secured
		)
	)
	_lower_deck_forward_pressure_aftershock_exhaust_breaker_activated = bool(
		state.get(
			"factory_lower_deck_forward_pressure_aftershock_exhaust_breaker_activated",
			_lower_deck_forward_pressure_aftershock_exhaust_breaker_secured
		)
	)
	if _lower_deck_forward_pressure_aftershock_exhaust_breaker_cut:
		_lower_deck_forward_pressure_aftershock_exhaust_breaker_secured = true
		_lower_deck_forward_pressure_aftershock_exhaust_breaker_coil_rat_defeated = true
		_lower_deck_forward_pressure_aftershock_exhaust_breaker_activated = true
	_lower_deck_forward_pressure_aftershock_exhaust_escape_skirmish_activated = bool(
		state.get(
			"factory_lower_deck_forward_pressure_aftershock_exhaust_escape_skirmish_activated",
			false
		)
	)
	_lower_deck_forward_pressure_aftershock_exhaust_escape_spark_rat_defeated = bool(
		state.get(
			"factory_lower_deck_forward_pressure_aftershock_exhaust_escape_skirmish_spark_rat_defeated",
			false
		)
	)
	_lower_deck_forward_pressure_aftershock_exhaust_escape_coil_rat_defeated = bool(
		state.get(
			"factory_lower_deck_forward_pressure_aftershock_exhaust_escape_skirmish_coil_rat_defeated",
			false
		)
	)
	if bool(state.get(
		"factory_lower_deck_forward_pressure_aftershock_exhaust_escape_skirmish_cleared",
		false
	)):
		_lower_deck_forward_pressure_aftershock_exhaust_escape_spark_rat_defeated = true
		_lower_deck_forward_pressure_aftershock_exhaust_escape_coil_rat_defeated = true
	_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch_opened = bool(
		state.get(
			"factory_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch_opened",
			false
		)
	)
	_lower_deck_forward_pressure_aftershock_cooling_duct_crossed = bool(
		state.get(
			"factory_lower_deck_forward_pressure_aftershock_cooling_duct_crossed",
			false
		)
	)
	_lower_deck_forward_pressure_aftershock_cooling_duct_activated = bool(
		state.get(
			"factory_lower_deck_forward_pressure_aftershock_cooling_duct_activated",
			_lower_deck_forward_pressure_aftershock_cooling_duct_crossed
		)
	)
	_lower_deck_forward_pressure_aftershock_cooling_duct_elapsed_sec = 0.0
	_lower_deck_forward_pressure_aftershock_condenser_valve_activated = bool(
		state.get(
			"factory_lower_deck_forward_pressure_aftershock_condenser_valve_activated",
			false
		)
	)
	_lower_deck_forward_pressure_aftershock_condenser_valve_spark_rat_defeated = bool(
		state.get(
			"factory_lower_deck_forward_pressure_aftershock_condenser_valve_spark_rat_defeated",
			false
		)
	)
	_lower_deck_forward_pressure_aftershock_condenser_valve_coil_rat_defeated = bool(
		state.get(
			"factory_lower_deck_forward_pressure_aftershock_condenser_valve_coil_rat_defeated",
			false
		)
	)
	if bool(state.get(
		"factory_lower_deck_forward_pressure_aftershock_condenser_valve_cleared",
		false
	)):
		_lower_deck_forward_pressure_aftershock_condenser_valve_activated = true
		_lower_deck_forward_pressure_aftershock_condenser_valve_spark_rat_defeated = true
		_lower_deck_forward_pressure_aftershock_condenser_valve_coil_rat_defeated = true
	_lower_deck_forward_pressure_aftershock_condenser_savepoint_activated = bool(
		state.get(
			"factory_lower_deck_forward_pressure_aftershock_condenser_savepoint_activated",
			false
		)
	)
	_lower_deck_forward_pressure_aftershock_condenser_outlet_crossed = bool(
		state.get(
			"factory_lower_deck_forward_pressure_aftershock_condenser_outlet_crossed",
			false
		)
	)
	_lower_deck_forward_pressure_aftershock_condenser_outlet_activated = bool(
		state.get(
			"factory_lower_deck_forward_pressure_aftershock_condenser_outlet_activated",
			_lower_deck_forward_pressure_aftershock_condenser_outlet_crossed
		)
	)
	_lower_deck_forward_pressure_aftershock_condenser_outlet_elapsed_sec = 0.0
	_lower_deck_forward_pressure_aftershock_condenser_outlet_clamp_spark_rat_defeated = bool(
		state.get(
			"factory_lower_deck_forward_pressure_aftershock_condenser_outlet_clamp_ambush_spark_rat_defeated",
			false
		)
	)
	if bool(state.get(
		"factory_lower_deck_forward_pressure_aftershock_condenser_outlet_clamp_ambush_cleared",
		false
	)):
		_lower_deck_forward_pressure_aftershock_condenser_outlet_clamp_spark_rat_defeated = true
	_lower_deck_forward_pressure_aftershock_condenser_outlet_clamp_ambush_activated = bool(
		state.get(
			"factory_lower_deck_forward_pressure_aftershock_condenser_outlet_clamp_ambush_activated",
			_lower_deck_forward_pressure_aftershock_condenser_outlet_clamp_spark_rat_defeated
		)
	)
	_lower_deck_forward_pressure_aftershock_condenser_drip_vent_crossed = bool(
		state.get(
			"factory_lower_deck_forward_pressure_aftershock_condenser_outlet_drip_vent_crossed",
			false
		)
	)
	_lower_deck_forward_pressure_aftershock_condenser_drip_vent_activated = bool(
		state.get(
			"factory_lower_deck_forward_pressure_aftershock_condenser_outlet_drip_vent_activated",
			_lower_deck_forward_pressure_aftershock_condenser_drip_vent_crossed
		)
	)
	_lower_deck_forward_pressure_aftershock_condenser_drip_vent_elapsed_sec = 0.0
	_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_coil_rat_defeated = (
		bool(state.get(
			"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_coil_rat_defeated",
			false
		))
	)
	if bool(state.get(
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_cleared",
		false
	)):
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_coil_rat_defeated = true
	_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_activated = bool(
		state.get(
			"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_activated",
			_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_coil_rat_defeated
		)
	)
	if _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_coil_rat_defeated:
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_activated = true
	_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_reward_cache_claimed = bool(
		state.get(
			"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_reward_cache_claimed",
			false
		)
	)
	_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_exit_hatch_opened = bool(
		state.get(
			"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_exit_hatch_opened",
			false
		)
	)
	if _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_exit_hatch_opened:
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_reward_cache_claimed = true
	if _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_reward_cache_claimed:
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_coil_rat_defeated = true
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_activated = true
	_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_duct_crossed = bool(
		state.get(
			"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_duct_crossed",
			false
		)
	)
	_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_duct_activated = bool(
		state.get(
			"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_duct_activated",
			_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_duct_crossed
		)
	)
	_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_duct_elapsed_sec = 0.0
	if _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_duct_crossed:
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_duct_activated = true
	if (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_duct_activated
		or _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_duct_crossed
	):
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_exit_hatch_opened = true
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_reward_cache_claimed = true
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_coil_rat_defeated = true
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_activated = true
	_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_coil_rat_defeated = bool(
		state.get(
			"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_coil_rat_defeated",
			false
		)
	)
	if bool(state.get(
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_skirmish_cleared",
		false
	)):
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_coil_rat_defeated = true
	_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_skirmish_activated = bool(
		state.get(
			"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_skirmish_activated",
			_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_coil_rat_defeated
		)
	)
	if _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_coil_rat_defeated:
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_skirmish_activated = true
	if (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_skirmish_activated
		or _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_coil_rat_defeated
	):
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_duct_activated = true
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_duct_crossed = true
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_exit_hatch_opened = true
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_reward_cache_claimed = true
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_coil_rat_defeated = true
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_activated = true
	_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_reward_cache_claimed = bool(
		state.get(
			"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_reward_cache_claimed",
			false
		)
	)
	_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_gate_opened = bool(
		state.get(
			"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_gate_opened",
			false
		)
	)
	_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_activated = bool(
		state.get(
			"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_activated",
			false
		)
	)
	_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_crossed = bool(
		state.get(
			"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_crossed",
			false
		)
	)
	if _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_crossed:
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_activated = true
	_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_spark_rat_defeated = bool(
		state.get(
			"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_spark_rat_defeated",
			false
		)
	)
	if bool(state.get(
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_skirmish_cleared",
		false
	)):
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_spark_rat_defeated = true
	_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_skirmish_activated = bool(
		state.get(
			"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_skirmish_activated",
			_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_spark_rat_defeated
		)
	)
	_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_reward_cache_claimed = bool(
		state.get(
			"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_reward_cache_claimed",
			false
		)
	)
	_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_hatch_opened = bool(
		state.get(
			"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_hatch_opened",
			false
		)
	)
	_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_crossed = bool(
		state.get(
			"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_crossed",
			false
		)
	)
	_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_activated = bool(
		state.get(
			"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_activated",
			_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_crossed
		)
	)
	_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_elapsed_sec = 0.0
	_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_spark_rat_defeated = bool(
		state.get(
			"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_spark_rat_defeated",
			false
		)
	)
	if bool(state.get(
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_skirmish_cleared",
		false
	)):
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_spark_rat_defeated = true
	_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_skirmish_activated = bool(
		state.get(
			"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_skirmish_activated",
			_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_spark_rat_defeated
		)
	)
	if _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_spark_rat_defeated:
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_skirmish_activated = true
	if (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_skirmish_activated
		or _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_spark_rat_defeated
	):
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_activated = true
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_crossed = true
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_hatch_opened = true
	if _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_crossed:
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_activated = true
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_hatch_opened = true
	if _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_activated:
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_hatch_opened = true
	if _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_hatch_opened:
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_reward_cache_claimed = true
	if _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_reward_cache_claimed:
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_spark_rat_defeated = true
	if _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_spark_rat_defeated:
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_skirmish_activated = true
	if (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_skirmish_activated
		or _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_spark_rat_defeated
	):
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_activated = true
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_crossed = true
	if (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_activated
		or _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_crossed
	):
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_gate_opened = true
	if _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_gate_opened:
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_reward_cache_claimed = true
	if _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_reward_cache_claimed:
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_skirmish_activated = true
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_coil_rat_defeated = true
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_duct_activated = true
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_duct_crossed = true
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_exit_hatch_opened = true
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_reward_cache_claimed = true
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_coil_rat_defeated = true
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_activated = true
	_reset_lower_deck_forward_conduit_clear_feedback()
	_return_checkpoint_activated = bool(state.get("factory_return_checkpoint_activated", false))
	_service_lift_activated = bool(state.get("factory_service_lift_activated", false))
	_service_lift_exit_requested = bool(state.get(
		"factory_service_lift_exit_requested",
		_service_lift_activated
	))
	_last_service_lift_exit_rejected_reason = StringName(String(state.get(
		"factory_service_lift_exit_rejected_reason",
		""
	)))
	var exit_request_variant: Variant = state.get("factory_service_lift_exit_request", {})
	_last_service_lift_exit_request = (
		(exit_request_variant as Dictionary).duplicate(true)
		if exit_request_variant is Dictionary
		else {}
	)
	var spark_rat_opening_grace_frames: int = int(state.get(
		"factory_spark_rat_opening_grace_frames",
		FACTORY_SPARK_RAT_OPENING_GRACE_FRAMES if _spark_rat_activated and not _spark_rat_defeated else 0
	))
	var checkpoint_forward_opening_grace_frames: int = int(state.get(
		"factory_checkpoint_forward_patrol_opening_grace_frames",
		(
			FACTORY_SPARK_RAT_OPENING_GRACE_FRAMES
			if _checkpoint_forward_patrol_activated and not _checkpoint_forward_patrol_defeated
			else 0
		)
	))
	var checkpoint_rear_opening_grace_frames: int = int(state.get(
		"factory_checkpoint_rear_ambush_opening_grace_frames",
		(
			FACTORY_SPARK_RAT_OPENING_GRACE_FRAMES
			if _checkpoint_rear_ambush_activated and not _checkpoint_rear_ambush_defeated
			else 0
		)
	))
	var checkpoint_overdrive_opening_grace_frames: int = int(state.get(
		"factory_checkpoint_overdrive_duo_opening_grace_frames",
		(
			FACTORY_CHECKPOINT_OVERDRIVE_RIGHT_OPENING_GRACE_FRAMES
			if _checkpoint_overdrive_duo_activated and not _is_checkpoint_overdrive_duo_cleared()
			else 0
		)
	))
	var checkpoint_overdrive_left_opening_grace_frames: int = int(state.get(
		"factory_checkpoint_overdrive_left_opening_grace_frames",
		(
			checkpoint_overdrive_opening_grace_frames
			if state.has("factory_checkpoint_overdrive_duo_opening_grace_frames")
			else (
				FACTORY_CHECKPOINT_OVERDRIVE_LEFT_OPENING_GRACE_FRAMES
				if (
					_checkpoint_overdrive_duo_activated
					and not _is_checkpoint_overdrive_duo_cleared()
				)
				else 0
			)
		)
	))
	var checkpoint_overdrive_right_opening_grace_frames: int = int(state.get(
		"factory_checkpoint_overdrive_right_opening_grace_frames",
		(
			checkpoint_overdrive_opening_grace_frames
			if state.has("factory_checkpoint_overdrive_duo_opening_grace_frames")
			else (
				FACTORY_CHECKPOINT_OVERDRIVE_RIGHT_OPENING_GRACE_FRAMES
				if (
					_checkpoint_overdrive_duo_activated
					and not _is_checkpoint_overdrive_duo_cleared()
				)
				else 0
			)
		)
	))
	var lower_deck_opening_grace_frames: int = int(state.get(
		"factory_lower_deck_skirmish_opening_grace_frames",
		(
			FACTORY_SPARK_RAT_OPENING_GRACE_FRAMES
			if _lower_deck_skirmish_activated and not _lower_deck_skirmish_defeated
			else 0
		)
	))
	var lower_deck_exit_opening_grace_frames: int = int(state.get(
		"factory_lower_deck_exit_ambush_opening_grace_frames",
		(
			FACTORY_SPARK_RAT_OPENING_GRACE_FRAMES
			if _lower_deck_exit_ambush_activated and not _lower_deck_exit_ambush_defeated
			else 0
		)
	))
	var lower_deck_shortcut_opening_grace_frames: int = int(state.get(
		"factory_lower_deck_shortcut_opening_grace_frames",
		(
			FACTORY_SPARK_RAT_OPENING_GRACE_FRAMES
			if _lower_deck_shortcut_activated and not _lower_deck_shortcut_guard_defeated
			else 0
		)
	))
	var lower_deck_forward_exit_guard_opening_grace_frames: int = int(state.get(
		"factory_lower_deck_forward_pressure_exit_guard_opening_grace_frames",
		(
			FACTORY_SPARK_RAT_OPENING_GRACE_FRAMES
			if _is_lower_deck_forward_pressure_exit_guard_active()
			else 0
		)
	))
	var reward_variant: Variant = state.get("last_cache_reward", {})
	_last_cache_reward = (
		(reward_variant as Dictionary).duplicate(true)
		if reward_variant is Dictionary
		else {}
	)
	var cache_feedback_variant: Variant = state.get("last_cache_claim_feedback", {})
	_last_cache_claim_feedback = (
		(cache_feedback_variant as Dictionary).duplicate(true)
		if cache_feedback_variant is Dictionary
		else {}
	)
	var return_reward_variant: Variant = state.get("last_return_patrol_reward_cache_reward", {})
	_last_return_patrol_reward_cache_reward = (
		(return_reward_variant as Dictionary).duplicate(true)
		if return_reward_variant is Dictionary
		else {}
	)
	var return_feedback_variant: Variant = state.get(
		"last_return_patrol_reward_cache_claim_feedback",
		{}
	)
	_last_return_patrol_reward_cache_claim_feedback = (
		(return_feedback_variant as Dictionary).duplicate(true)
		if return_feedback_variant is Dictionary
		else {}
	)
	var overdrive_reward_variant: Variant = state.get(
		"last_checkpoint_overdrive_reward_cache_reward",
		{}
	)
	_last_checkpoint_overdrive_reward_cache_reward = (
		(overdrive_reward_variant as Dictionary).duplicate(true)
		if overdrive_reward_variant is Dictionary
		else {}
	)
	var overdrive_feedback_variant: Variant = state.get(
		"last_checkpoint_overdrive_reward_cache_claim_feedback",
		{}
	)
	_last_checkpoint_overdrive_reward_cache_claim_feedback = (
		(overdrive_feedback_variant as Dictionary).duplicate(true)
		if overdrive_feedback_variant is Dictionary
		else {}
	)
	var lower_deck_reward_variant: Variant = state.get(
		"last_lower_deck_reward_cache_reward",
		{}
	)
	_last_lower_deck_reward_cache_reward = (
		(lower_deck_reward_variant as Dictionary).duplicate(true)
		if lower_deck_reward_variant is Dictionary
		else {}
	)
	var lower_deck_feedback_variant: Variant = state.get(
		"last_lower_deck_reward_cache_claim_feedback",
		{}
	)
	_last_lower_deck_reward_cache_claim_feedback = (
		(lower_deck_feedback_variant as Dictionary).duplicate(true)
		if lower_deck_feedback_variant is Dictionary
		else {}
	)
	var lower_deck_shortcut_reward_variant: Variant = state.get(
		"last_lower_deck_shortcut_reward_cache_reward",
		{}
	)
	_last_lower_deck_shortcut_reward_cache_reward = (
		(lower_deck_shortcut_reward_variant as Dictionary).duplicate(true)
		if lower_deck_shortcut_reward_variant is Dictionary
		else {}
	)
	var lower_deck_shortcut_feedback_variant: Variant = state.get(
		"last_lower_deck_shortcut_reward_cache_claim_feedback",
		{}
	)
	_last_lower_deck_shortcut_reward_cache_claim_feedback = (
		(lower_deck_shortcut_feedback_variant as Dictionary).duplicate(true)
		if lower_deck_shortcut_feedback_variant is Dictionary
		else {}
	)
	var lower_deck_relay_forward_reward_variant: Variant = state.get(
		"last_lower_deck_relay_forward_reward_cache_reward",
		{}
	)
	_last_lower_deck_relay_forward_reward_cache_reward = (
		(lower_deck_relay_forward_reward_variant as Dictionary).duplicate(true)
		if lower_deck_relay_forward_reward_variant is Dictionary
		else {}
	)
	var lower_deck_relay_forward_feedback_variant: Variant = state.get(
		"last_lower_deck_relay_forward_reward_cache_claim_feedback",
		{}
	)
	_last_lower_deck_relay_forward_reward_cache_claim_feedback = (
		(lower_deck_relay_forward_feedback_variant as Dictionary).duplicate(true)
		if lower_deck_relay_forward_feedback_variant is Dictionary
		else {}
	)
	var lower_deck_forward_pressure_reward_variant: Variant = state.get(
		"last_lower_deck_forward_pressure_reward_cache_reward",
		{}
	)
	_last_lower_deck_forward_pressure_reward_cache_reward = (
		(lower_deck_forward_pressure_reward_variant as Dictionary).duplicate(true)
		if lower_deck_forward_pressure_reward_variant is Dictionary
		else {}
	)
	var lower_deck_forward_pressure_feedback_variant: Variant = state.get(
		"last_lower_deck_forward_pressure_reward_cache_claim_feedback",
		{}
	)
	_last_lower_deck_forward_pressure_reward_cache_claim_feedback = (
		(lower_deck_forward_pressure_feedback_variant as Dictionary).duplicate(true)
		if lower_deck_forward_pressure_feedback_variant is Dictionary
		else {}
	)
	var lower_deck_forward_pressure_aftershock_reward_variant: Variant = state.get(
		"last_lower_deck_forward_pressure_aftershock_reward_cache_reward",
		{}
	)
	_last_lower_deck_forward_pressure_aftershock_reward_cache_reward = (
		(lower_deck_forward_pressure_aftershock_reward_variant as Dictionary).duplicate(
			true
		)
		if lower_deck_forward_pressure_aftershock_reward_variant is Dictionary
		else {}
	)
	var lower_deck_forward_pressure_aftershock_feedback_variant: Variant = state.get(
		"last_lower_deck_forward_pressure_aftershock_reward_cache_claim_feedback",
		{}
	)
	_last_lower_deck_forward_pressure_aftershock_reward_cache_claim_feedback = (
		(lower_deck_forward_pressure_aftershock_feedback_variant as Dictionary).duplicate(
			true
		)
		if lower_deck_forward_pressure_aftershock_feedback_variant is Dictionary
		else {}
	)
	var lower_deck_forward_pressure_exhaust_pursuer_reward_variant: Variant = state.get(
		"last_lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache_reward",
		{}
	)
	_last_lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache_reward = (
		(
			lower_deck_forward_pressure_exhaust_pursuer_reward_variant
			as Dictionary
		).duplicate(true)
		if lower_deck_forward_pressure_exhaust_pursuer_reward_variant is Dictionary
		else {}
	)
	var lower_deck_forward_pressure_exhaust_pursuer_feedback_variant: Variant = state.get(
		"last_lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache_claim_feedback",
		{}
	)
	_last_lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache_claim_feedback = (
		(
			lower_deck_forward_pressure_exhaust_pursuer_feedback_variant
			as Dictionary
		).duplicate(true)
		if lower_deck_forward_pressure_exhaust_pursuer_feedback_variant is Dictionary
		else {}
	)
	var lower_deck_forward_pressure_overflow_pump_reward_variant: Variant = state.get(
		"last_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_reward_cache_reward",
		{}
	)
	_last_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_reward_cache_reward = (
		(
			lower_deck_forward_pressure_overflow_pump_reward_variant
			as Dictionary
		).duplicate(true)
		if lower_deck_forward_pressure_overflow_pump_reward_variant is Dictionary
		else {}
	)
	var lower_deck_forward_pressure_overflow_pump_feedback_variant: Variant = state.get(
		"last_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_reward_cache_claim_feedback",
		{}
	)
	_last_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_reward_cache_claim_feedback = (
		(
			lower_deck_forward_pressure_overflow_pump_feedback_variant
			as Dictionary
		).duplicate(true)
		if lower_deck_forward_pressure_overflow_pump_feedback_variant is Dictionary
		else {}
	)
	var lower_deck_forward_pressure_runoff_exit_reward_variant: Variant = state.get(
		"last_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_reward_cache_reward",
		{}
	)
	_last_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_reward_cache_reward = (
		(
			lower_deck_forward_pressure_runoff_exit_reward_variant
			as Dictionary
		).duplicate(true)
		if lower_deck_forward_pressure_runoff_exit_reward_variant is Dictionary
		else {}
	)
	var lower_deck_forward_pressure_runoff_exit_feedback_variant: Variant = state.get(
		"last_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_reward_cache_claim_feedback",
		{}
	)
	_last_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_reward_cache_claim_feedback = (
		(
			lower_deck_forward_pressure_runoff_exit_feedback_variant
			as Dictionary
		).duplicate(true)
		if lower_deck_forward_pressure_runoff_exit_feedback_variant is Dictionary
		else {}
	)
	var lower_deck_forward_pressure_runoff_outlet_reward_variant: Variant = state.get(
		"last_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_reward_cache_reward",
		{}
	)
	_last_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_reward_cache_reward = (
		(
			lower_deck_forward_pressure_runoff_outlet_reward_variant
			as Dictionary
		).duplicate(true)
		if lower_deck_forward_pressure_runoff_outlet_reward_variant is Dictionary
		else {}
	)
	var lower_deck_forward_pressure_runoff_outlet_feedback_variant: Variant = state.get(
		"last_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_reward_cache_claim_feedback",
		{}
	)
	_last_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_reward_cache_claim_feedback = (
		(
			lower_deck_forward_pressure_runoff_outlet_feedback_variant
			as Dictionary
		).duplicate(true)
		if lower_deck_forward_pressure_runoff_outlet_feedback_variant is Dictionary
		else {}
	)
	var return_checkpoint_variant: Variant = state.get(
		"last_return_checkpoint",
		state.get("last_savepoint", {})
	)
	_last_return_checkpoint = (
		(return_checkpoint_variant as Dictionary).duplicate(true)
		if return_checkpoint_variant is Dictionary
		else {}
	)
	if not _last_return_checkpoint.is_empty():
		_return_checkpoint_activated = true
		if String(_last_return_checkpoint.get("id", "")) == String(FACTORY_LOWER_DECK_BREACH_RELAY_ID):
			_lower_deck_breach_relay_activated = true
		if (
			String(_last_return_checkpoint.get("id", ""))
			== String(FACTORY_LOWER_DECK_FORWARD_PRESSURE_EXIT_RELAY_ID)
		):
			_lower_deck_forward_pressure_exit_relay_activated = true
		if (
			String(_last_return_checkpoint.get("id", ""))
			== String(FACTORY_LOWER_DECK_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_SAVEPOINT_ID)
		):
			_lower_deck_forward_pressure_aftershock_condenser_savepoint_activated = true
	if (
		_lower_deck_forward_pressure_exit_relay_activated
		and (
			_last_return_checkpoint.is_empty()
			or String(_last_return_checkpoint.get("id", ""))
			!= String(FACTORY_LOWER_DECK_FORWARD_PRESSURE_EXIT_RELAY_ID)
		)
	):
		_last_return_checkpoint = _build_forward_pressure_exit_relay_checkpoint_snapshot()
		_return_checkpoint_activated = true
	if (
		_lower_deck_forward_pressure_aftershock_condenser_savepoint_activated
		and (
			_last_return_checkpoint.is_empty()
			or String(_last_return_checkpoint.get("id", ""))
			!= String(FACTORY_LOWER_DECK_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_SAVEPOINT_ID)
		)
	):
		_last_return_checkpoint = (
			_build_aftershock_condenser_savepoint_checkpoint_snapshot()
		)
		_return_checkpoint_activated = true
	var hazard_variant: Variant = state.get("last_hazard_damage", {})
	_last_hazard_damage = (
		(hazard_variant as Dictionary).duplicate(true)
		if hazard_variant is Dictionary
		else {}
	)
	if _is_return_patrol_blocking_service_lift():
		_service_lift_activated = false
		_service_lift_exit_requested = false
		_last_service_lift_exit_rejected_reason = &""
		_last_service_lift_exit_request = {}
	if _is_checkpoint_forward_patrol_blocking_service_lift():
		_service_lift_activated = false
		_service_lift_exit_requested = false
		_last_service_lift_exit_rejected_reason = &""
		_last_service_lift_exit_request = {}
	if _is_checkpoint_rear_ambush_blocking_service_lift():
		_service_lift_activated = false
		_service_lift_exit_requested = false
		_last_service_lift_exit_rejected_reason = &""
		_last_service_lift_exit_request = {}
	if _is_checkpoint_overdrive_duo_blocking_service_lift():
		_service_lift_activated = false
		_service_lift_exit_requested = false
		_last_service_lift_exit_rejected_reason = &""
		_last_service_lift_exit_request = {}
	_sync_room_clear_state()
	_sync_deep_route_state()
	_sync_spark_rat_state()
	_sync_return_patrol_state()
	_sync_checkpoint_forward_patrol_state()
	_sync_checkpoint_rear_ambush_state()
	_sync_checkpoint_overdrive_duo_state()
	_sync_checkpoint_steam_vent_state()
	_sync_lower_deck_skirmish_state()
	_sync_lower_deck_pressure_hazard_state()
	_sync_lower_deck_parry_gate_state()
	_sync_lower_deck_exit_ambush_state()
	_sync_lower_deck_shortcut_state()
	_sync_return_patrol_reward_cache_state()
	_sync_checkpoint_overdrive_reward_cache_state()
	_sync_lower_deck_reward_cache_state()
	_sync_lower_deck_shortcut_reward_cache_state()
	_sync_lower_deck_shortcut_pursuer_state()
	_sync_lower_deck_pressure_valve_state()
	_sync_lower_deck_steam_sluice_state()
	_sync_lower_deck_deep_bulkhead_state()
	_sync_lower_deck_breach_corridor_state()
	_sync_lower_deck_breach_relay_state()
	_sync_lower_deck_post_relay_trial_state()
	_sync_lower_deck_relay_forward_reward_cache_state()
	_sync_lower_deck_forward_pressure_reward_cache_state()
	_sync_lower_deck_forward_hatch_state()
	_sync_lower_deck_forward_conduit_state()
	_sync_lower_deck_forward_pressure_traverse_state()
	_sync_lower_deck_forward_pressure_counter_ambush_state()
	_sync_lower_deck_forward_pressure_exit_guard_state()
	_sync_lower_deck_forward_pressure_exit_relay_state()
	_sync_lower_deck_forward_pressure_exit_gate_state()
	_sync_lower_deck_forward_pressure_route_handoff_marker_state()
	_sync_lower_deck_forward_pressure_beacon_ambush_state()
	_sync_lower_deck_forward_pressure_overrun_state()
	_sync_lower_deck_forward_pressure_breaker_state()
	_sync_lower_deck_forward_pressure_breaker_endpoint_state()
	_sync_lower_deck_forward_pressure_relief_ambush_state()
	_sync_lower_deck_forward_pressure_coil_rat_state()
	_sync_lower_deck_forward_pressure_coil_pincer_state()
	_sync_lower_deck_forward_pressure_coil_aftershock_state()
	_sync_lower_deck_forward_pressure_aftershock_reward_cache_state()
	_sync_lower_deck_forward_pressure_aftershock_exit_skirmish_state()
	_sync_lower_deck_forward_pressure_aftershock_exhaust_state()
	_sync_lower_deck_forward_pressure_aftershock_exhaust_pursuer_state()
	_sync_lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache_state()
	_sync_lower_deck_forward_pressure_aftershock_exhaust_flank_state()
	_sync_lower_deck_forward_pressure_aftershock_exhaust_breaker_state()
	_sync_lower_deck_forward_pressure_aftershock_exhaust_breaker_endpoint_state()
	_sync_lower_deck_forward_pressure_aftershock_exhaust_escape_skirmish_state()
	_sync_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch_state()
	_sync_lower_deck_forward_pressure_aftershock_cooling_duct_state()
	_sync_lower_deck_forward_pressure_aftershock_condenser_valve_state()
	_sync_lower_deck_forward_pressure_aftershock_condenser_savepoint_state()
	_sync_lower_deck_forward_pressure_aftershock_condenser_outlet_state()
	_sync_overflow_pump_state()
	_sync_overflow_pump_reward_cache_state()
	_sync_overflow_pump_exit_hatch_state()
	_sync_overflow_pump_runoff_duct_state()
	_sync_overflow_pump_runoff_exit_skirmish_state()
	_sync_overflow_pump_runoff_exit_reward_cache_state()
	_sync_overflow_pump_runoff_exit_gate_state()
	_sync_overflow_pump_runoff_outlet_state()
	_sync_overflow_pump_runoff_outlet_reward_cache_state()
	_sync_overflow_pump_runoff_outlet_service_hatch_state()
	_sync_return_checkpoint_state()
	_sync_service_lift_state()
	if _spark_rat_activated and not _spark_rat_defeated:
		_begin_spark_rat_pacing(spark_rat_opening_grace_frames)
	if _return_patrol_activated and not _return_patrol_defeated:
		_begin_return_spark_rat_pacing(FACTORY_SPARK_RAT_OPENING_GRACE_FRAMES)
	if _checkpoint_forward_patrol_activated and not _checkpoint_forward_patrol_defeated:
		_begin_checkpoint_forward_spark_rat_pacing(checkpoint_forward_opening_grace_frames)
	if _checkpoint_rear_ambush_activated and not _checkpoint_rear_ambush_defeated:
		_begin_checkpoint_rear_spark_rat_pacing(checkpoint_rear_opening_grace_frames)
	if _checkpoint_overdrive_duo_activated and not _is_checkpoint_overdrive_duo_cleared():
		_begin_checkpoint_overdrive_spark_rat_pacing(
			checkpoint_overdrive_left_opening_grace_frames,
			checkpoint_overdrive_right_opening_grace_frames
		)
	if _lower_deck_skirmish_activated and not _lower_deck_skirmish_defeated:
		_begin_lower_deck_spark_rat_pacing(lower_deck_opening_grace_frames)
	if _lower_deck_exit_ambush_activated and not _lower_deck_exit_ambush_defeated:
		_begin_lower_deck_exit_spark_rat_pacing(lower_deck_exit_opening_grace_frames)
	if _lower_deck_shortcut_activated and not _lower_deck_shortcut_guard_defeated:
		_begin_lower_deck_shortcut_spark_rat_pacing(lower_deck_shortcut_opening_grace_frames)
	if _is_lower_deck_shortcut_pursuer_active():
		_begin_lower_deck_shortcut_pursuer_pacing(FACTORY_SPARK_RAT_OPENING_GRACE_FRAMES)
	if _is_lower_deck_pressure_guard_active():
		_begin_lower_deck_pressure_guard_pacing(FACTORY_SPARK_RAT_OPENING_GRACE_FRAMES)
	if _is_lower_deck_steam_sluice_active():
		_begin_lower_deck_steam_sluice_pacing(FACTORY_SPARK_RAT_OPENING_GRACE_FRAMES)
	if _is_lower_deck_deep_bulkhead_guard_active():
		_begin_lower_deck_deep_bulkhead_guard_pacing(FACTORY_SPARK_RAT_OPENING_GRACE_FRAMES)
	if _is_lower_deck_breach_front_active():
		_begin_lower_deck_breach_front_pacing(FACTORY_SPARK_RAT_OPENING_GRACE_FRAMES)
	if _is_lower_deck_breach_rear_active():
		_begin_lower_deck_breach_rear_pacing(FACTORY_SPARK_RAT_OPENING_GRACE_FRAMES)
	if _is_lower_deck_post_relay_trial_active():
		_begin_lower_deck_post_relay_trial_pacing(FACTORY_SPARK_RAT_OPENING_GRACE_FRAMES)
	if _is_lower_deck_forward_conduit_active():
		_begin_lower_deck_forward_conduit_pacing(FACTORY_SPARK_RAT_OPENING_GRACE_FRAMES)
	if _is_lower_deck_forward_pressure_counter_ambush_active():
		_begin_lower_deck_forward_counter_ambush_pacing(
			FACTORY_SPARK_RAT_OPENING_GRACE_FRAMES
		)
	if _is_lower_deck_forward_pressure_exit_guard_active():
		_begin_lower_deck_forward_exit_guard_pacing(
			lower_deck_forward_exit_guard_opening_grace_frames
		)
	if _is_lower_deck_forward_pressure_beacon_ambush_active():
		_begin_lower_deck_forward_beacon_ambush_pacing(
			FACTORY_SPARK_RAT_OPENING_GRACE_FRAMES
		)
	if _is_lower_deck_forward_pressure_overrun_active():
		_begin_lower_deck_forward_overrun_pacing(FACTORY_SPARK_RAT_OPENING_GRACE_FRAMES)
	if _is_lower_deck_forward_pressure_breaker_stand_active():
		_begin_lower_deck_forward_breaker_pacing(FACTORY_SPARK_RAT_OPENING_GRACE_FRAMES)
	if _is_lower_deck_forward_pressure_relief_ambush_active():
		_begin_lower_deck_forward_relief_ambush_pacing(FACTORY_SPARK_RAT_OPENING_GRACE_FRAMES)
	if _is_lower_deck_forward_pressure_coil_rat_active():
		_begin_lower_deck_forward_pressure_coil_rat_pacing(
			FACTORY_SPARK_RAT_OPENING_GRACE_FRAMES
		)
	if _is_lower_deck_forward_pressure_coil_pincer_active():
		_begin_lower_deck_forward_pressure_coil_pincer_pacing(
			FACTORY_COIL_PINCER_SPARK_RAT_OPENING_GRACE_FRAMES,
			FACTORY_COIL_PINCER_COIL_RAT_OPENING_GRACE_FRAMES
		)
	if _is_lower_deck_forward_pressure_coil_aftershock_active():
		_begin_lower_deck_forward_pressure_coil_aftershock_pacing(
			FACTORY_COIL_AFTERSHOCK_COIL_RAT_OPENING_GRACE_FRAMES
		)
	if _is_lower_deck_forward_pressure_aftershock_exit_skirmish_active():
		_begin_lower_deck_forward_pressure_aftershock_exit_skirmish_pacing(
			FACTORY_AFTERSHOCK_EXIT_SPARK_RAT_OPENING_GRACE_FRAMES,
			FACTORY_AFTERSHOCK_EXIT_COIL_RAT_OPENING_GRACE_FRAMES
		)
	if _is_lower_deck_forward_pressure_aftershock_exhaust_pursuer_active():
		_begin_lower_deck_forward_pressure_aftershock_exhaust_pursuer_pacing(
			FACTORY_AFTERSHOCK_EXHAUST_PURSUER_OPENING_GRACE_FRAMES
		)
	if _is_lower_deck_forward_pressure_aftershock_exhaust_flank_active():
		_begin_lower_deck_forward_pressure_aftershock_exhaust_flank_pacing(
			FACTORY_AFTERSHOCK_EXHAUST_FLANK_OPENING_GRACE_FRAMES
		)
	if _is_lower_deck_forward_pressure_aftershock_exhaust_breaker_stand_active():
		_begin_lower_deck_forward_pressure_aftershock_exhaust_breaker_pacing(
			FACTORY_AFTERSHOCK_EXHAUST_BREAKER_OPENING_GRACE_FRAMES
		)
	if _is_lower_deck_forward_pressure_aftershock_exhaust_escape_skirmish_active():
		_begin_lower_deck_forward_pressure_aftershock_exhaust_escape_skirmish_pacing(
			FACTORY_AFTERSHOCK_EXHAUST_ESCAPE_SPARK_OPENING_GRACE_FRAMES,
			FACTORY_AFTERSHOCK_EXHAUST_ESCAPE_COIL_OPENING_GRACE_FRAMES
		)
	if _is_outlet_clamp_ambush_active():
		_begin_outlet_clamp_ambush_pacing()
	if _is_overflow_pump_active():
		_begin_overflow_pump_pacing(
			FACTORY_AFTERSHOCK_CONDENSER_OVERFLOW_COIL_OPENING_GRACE_FRAMES
		)
	if _is_overflow_pump_runoff_outlet_skirmish_active():
		_begin_overflow_pump_runoff_outlet_skirmish_pacing(
			FACTORY_AFTERSHOCK_CONDENSER_OVERFLOW_RUNOFF_OUTLET_SPARK_OPENING_GRACE_FRAMES
		)
	if _is_overflow_pump_runoff_outlet_service_sluice_skirmish_active():
		_begin_overflow_pump_runoff_outlet_service_sluice_skirmish_pacing(
			FACTORY_AFTERSHOCK_CONDENSER_OVERFLOW_RUNOFF_OUTLET_SERVICE_SLUICE_SPARK_OPENING_GRACE_FRAMES
		)
	_refresh_factory_route_objective()
	if _service_lift_activated:
		_update_route_label("Service Lift Departing")
	_apply_current_scene_manager_spawn_point()


## Returns deterministic room-clear/cache diagnostics for tests and MCP probes.
func get_factory_room_clear_diagnostics() -> Dictionary:
	return {
		"encounter_cleared": _encounter_cleared,
		"cache_present": _cache != null,
		"cache_id": String(_cache.call("get_cache_id")) if _cache != null and _cache.has_method("get_cache_id") else "",
		"cache_available": bool(_cache.call("is_available")) if _cache != null and _cache.has_method("is_available") else false,
		"cache_claim_available": bool(_cache.call("is_claim_available")) if _cache != null and _cache.has_method("is_claim_available") else false,
		"cache_claimed": _cache_claimed,
		"cache_texture_path": (
			String(_cache.call("get_visual_texture_path"))
			if _cache != null and _cache.has_method("get_visual_texture_path")
			else ""
		),
		"has_cache_platform": get_node_or_null("FactoryCachePlatform/CollisionShape2D") != null,
		"player_position": _player.global_position if _player != null else Vector2.ZERO,
		"cache_position": _cache.global_position if _cache != null else Vector2.ZERO,
		"last_cache_reward": _last_cache_reward.duplicate(true),
		"last_cache_claim_feedback": _last_cache_claim_feedback.duplicate(true),
	}


## Returns deterministic route floor/platform visual diagnostics for tests and MCP probes.
func get_factory_route_visual_diagnostics() -> Dictionary:
	var ground_shape := get_node_or_null("Ground/CollisionShape2D") as CollisionShape2D
	var ground_rect := (
		ground_shape.shape as RectangleShape2D
		if ground_shape != null and ground_shape.shape is RectangleShape2D
		else null
	)
	var floor_tiles: Array[Sprite2D] = _get_factory_route_floor_visual_tiles()
	return {
		"ground_collision_width": ground_rect.size.x if ground_rect != null else 0.0,
		"ground_collision_height": ground_rect.size.y if ground_rect != null else 0.0,
		"floor": _build_factory_route_floor_visual_snapshot(floor_tiles),
		"entry_platform": _build_factory_route_sprite_visual_snapshot(
			get_node_or_null("EntryPlatform/FactoryRouteEntryPlatformVisual") as Sprite2D
		),
		"cache_platform": _build_factory_route_sprite_visual_snapshot(
			get_node_or_null(
				"FactoryCachePlatform/FactoryRouteCachePlatformVisual"
			) as Sprite2D
		),
		"uses_placeholder_color_rect": _has_visible_placeholder_visual(self),
	}


func _get_factory_route_floor_visual_tiles() -> Array[Sprite2D]:
	var ground := get_node_or_null("Ground")
	var tiles: Array[Sprite2D] = []
	if ground == null:
		return tiles
	for child: Node in ground.get_children():
		if child is Sprite2D and String(child.name).begins_with("FactoryRouteFloorVisual"):
			tiles.append(child as Sprite2D)
	return tiles


func _build_factory_route_floor_visual_snapshot(tiles: Array[Sprite2D]) -> Dictionary:
	var first_tile := get_node_or_null("Ground/FactoryRouteFloorVisual") as Sprite2D
	var snapshot: Dictionary = _build_factory_route_sprite_visual_snapshot(first_tile)
	snapshot["tile_count"] = tiles.size()
	snapshot["world_width"] = _get_factory_route_floor_visual_width(tiles)
	snapshot["world_height"] = _get_factory_route_sprite_world_size(first_tile).y
	return snapshot


func _build_factory_route_sprite_visual_snapshot(sprite: Sprite2D) -> Dictionary:
	var texture_size := Vector2.ZERO
	var texture_path := ""
	if sprite != null and sprite.texture != null:
		texture_size = sprite.texture.get_size()
		texture_path = sprite.texture.resource_path
	return {
		"present": sprite != null,
		"node_path": String(get_path_to(sprite)) if sprite != null else "",
		"visible": sprite.visible if sprite != null else false,
		"is_visible_in_tree": sprite.is_visible_in_tree() if sprite != null else false,
		"texture_path": texture_path,
		"texture_size": texture_size,
		"world_width": _get_factory_route_sprite_world_size(sprite).x,
		"world_height": _get_factory_route_sprite_world_size(sprite).y,
		"z_index": sprite.z_index if sprite != null else -999,
		"z_as_relative": sprite.z_as_relative if sprite != null else true,
	}


func _get_factory_route_floor_visual_width(tiles: Array[Sprite2D]) -> float:
	var width := 0.0
	for tile: Sprite2D in tiles:
		width += _get_factory_route_sprite_world_size(tile).x
	return width


func _get_factory_route_sprite_world_size(sprite: Sprite2D) -> Vector2:
	if sprite == null or sprite.texture == null:
		return Vector2.ZERO
	var texture_size: Vector2 = sprite.texture.get_size()
	return Vector2(texture_size.x * absf(sprite.scale.x), texture_size.y * absf(sprite.scale.y))


func _has_visible_placeholder_visual(root: Node) -> bool:
	if root is ColorRect and (root as ColorRect).visible:
		return true
	if root is Polygon2D and (root as Polygon2D).visible:
		return true
	for child: Node in root.get_children():
		if _has_visible_placeholder_visual(child):
			return true
	return false


## Returns deterministic steam vent hazard diagnostics for tests and MCP probes.
func get_factory_hazard_diagnostics() -> Dictionary:
	return {
		"steam_vent_present": _steam_vent != null,
		"steam_vent_id": String(_get_hazard_id(_steam_vent)),
		"steam_damage": _get_hazard_damage(_steam_vent),
		"steam_cooldown_sec": _get_hazard_cooldown_sec(_steam_vent),
		"steam_vent_texture_path": (
			String(_steam_vent.call("get_visual_texture_path"))
			if _steam_vent != null and _steam_vent.has_method("get_visual_texture_path")
			else ""
		),
		"steam_vent_layer": _steam_vent.collision_layer if _steam_vent != null else 0,
		"steam_vent_mask": _steam_vent.collision_mask if _steam_vent != null else 0,
		"checkpoint_steam_vent_present": _checkpoint_steam_vent != null,
		"checkpoint_steam_vent_visible": (
			_checkpoint_steam_vent.visible if _checkpoint_steam_vent != null else false
		),
		"checkpoint_steam_vent_active": (
			_is_hazard_contact_active(_checkpoint_steam_vent)
			if _checkpoint_steam_vent != null
			else false
		),
		"checkpoint_steam_vent_id": String(_get_hazard_id(_checkpoint_steam_vent)),
		"checkpoint_steam_damage": _get_hazard_damage(_checkpoint_steam_vent),
		"checkpoint_steam_cooldown_sec": _get_hazard_cooldown_sec(_checkpoint_steam_vent),
		"checkpoint_steam_vent_texture_path": (
			String(_checkpoint_steam_vent.call("get_visual_texture_path"))
			if (
				_checkpoint_steam_vent != null
				and _checkpoint_steam_vent.has_method("get_visual_texture_path")
			)
			else ""
		),
		"checkpoint_steam_vent_layer": (
			_checkpoint_steam_vent.collision_layer if _checkpoint_steam_vent != null else 0
		),
		"checkpoint_steam_vent_mask": (
			_checkpoint_steam_vent.collision_mask if _checkpoint_steam_vent != null else 0
		),
		"last_hazard_damage": _last_hazard_damage.duplicate(true),
	}


## Returns deterministic deep route diagnostics for tests and MCP probes.
func get_factory_deep_route_diagnostics() -> Dictionary:
	var unlock_vfx_snapshot: Dictionary = _get_deep_route_unlock_vfx_snapshot()
	return {
		"deep_guard_present": _deep_guard != null,
		"deep_guard_entity_id": (
			int(_deep_guard.call("get_entity_id"))
			if _deep_guard != null and _deep_guard.has_method("get_entity_id")
			else 0
		),
		"deep_guard_defeated": _deep_guard_defeated,
		"deep_guard_activated": _deep_guard_activated,
		"deep_guard_activation_x": FACTORY_DEEP_GUARD_ACTIVATION_X,
		"deep_guard_has_target": _does_deep_guard_have_target(),
		"deep_guard_physics_enabled": (
			_deep_guard.is_physics_processing()
			if _deep_guard != null
			else false
		),
		"deep_guard_process_enabled": (
			_deep_guard.is_processing()
			if _deep_guard != null
			else false
		),
		"deep_route_cleared": _deep_route_cleared,
		"endpoint_present": _deep_endpoint != null,
		"endpoint_available": (
			bool(_deep_endpoint.call("is_available"))
			if _deep_endpoint != null and _deep_endpoint.has_method("is_available")
			else false
		),
		"endpoint_activated": (
			bool(_deep_endpoint.call("is_activated"))
			if _deep_endpoint != null and _deep_endpoint.has_method("is_activated")
			else false
		),
		"endpoint_id": (
			String(_deep_endpoint.call("get_endpoint_id"))
			if _deep_endpoint != null and _deep_endpoint.has_method("get_endpoint_id")
			else ""
		),
		"endpoint_texture_path": (
			String(_deep_endpoint.call("get_visual_texture_path"))
			if _deep_endpoint != null and _deep_endpoint.has_method("get_visual_texture_path")
			else ""
		),
		"unlock_feedback_texture_path": String(unlock_vfx_snapshot.get("texture_path", "")),
		"unlock_feedback_active": int(unlock_vfx_snapshot.get("active_count", 0)) > 0,
		"unlock_feedback_played": bool(unlock_vfx_snapshot.get("played", false)),
		"unlock_feedback_spawn_count": int(unlock_vfx_snapshot.get("spawn_count", 0)),
		"player_position": _player.global_position if _player != null else Vector2.ZERO,
		"deep_guard_position": _deep_guard.global_position if _deep_guard != null else Vector2.ZERO,
		"endpoint_position": (
			(_deep_endpoint as Node2D).global_position
			if _deep_endpoint != null and _deep_endpoint is Node2D
			else Vector2.ZERO
		),
	}


## Returns deterministic spark-rat diagnostics for tests and MCP probes.
func get_factory_spark_rat_diagnostics() -> Dictionary:
	var sprite: AnimatedSprite2D = (
		_spark_rat.get_node_or_null("Sprite") as AnimatedSprite2D
		if _spark_rat != null
		else null
	)
	var pacing_diagnostics: Dictionary = _get_spark_rat_pacing_diagnostics()
	return {
		"present": _spark_rat != null,
		"visible": _spark_rat.visible if _spark_rat != null else false,
		"active": _spark_rat_activated and not _spark_rat_defeated,
		"defeated": _spark_rat_defeated,
		"activation_x": FACTORY_SPARK_RAT_ACTIVATION_X,
		"activation_ready": _is_spark_rat_activation_provider_in_range(_player),
		"distance_to_player": _get_spark_rat_distance_to_provider(_player),
		"entity_id": (
			int(_spark_rat.call("get_entity_id"))
			if _spark_rat != null and _spark_rat.has_method("get_entity_id")
			else 0
		),
		"has_target": _does_spark_rat_have_target(),
		"physics_enabled": _spark_rat.is_physics_processing() if _spark_rat != null else false,
		"process_enabled": _spark_rat.is_processing() if _spark_rat != null else false,
		"collision_layer": _spark_rat.collision_layer if _spark_rat != null else 0,
		"collision_mask": _spark_rat.collision_mask if _spark_rat != null else 0,
		"sprite_frames_path": (
			sprite.sprite_frames.resource_path
			if sprite != null and sprite.sprite_frames != null
			else ""
		),
		"animation_frame_counts": _get_sprite_animation_frame_counts(sprite),
		"counter": get_factory_spark_rat_counter_diagnostics(),
		"pacing": pacing_diagnostics,
		"position": _spark_rat.global_position if _spark_rat != null else Vector2.ZERO,
	}


## Returns deterministic return patrol diagnostics for tests and MCP probes.
func get_factory_return_patrol_diagnostics() -> Dictionary:
	var sprite: AnimatedSprite2D = (
		_return_spark_rat.get_node_or_null("Sprite") as AnimatedSprite2D
		if _return_spark_rat != null
		else null
	)
	return {
		"present": _return_spark_rat != null,
		"visible": _return_spark_rat.visible if _return_spark_rat != null else false,
		"active": _return_patrol_activated and not _return_patrol_defeated,
		"defeated": _return_patrol_defeated,
		"entity_id": (
			int(_return_spark_rat.call("get_entity_id"))
			if _return_spark_rat != null and _return_spark_rat.has_method("get_entity_id")
			else 0
		),
		"has_target": _does_return_spark_rat_have_target(),
		"physics_enabled": (
			_return_spark_rat.is_physics_processing()
			if _return_spark_rat != null
			else false
		),
		"process_enabled": _return_spark_rat.is_processing() if _return_spark_rat != null else false,
		"collision_layer": _return_spark_rat.collision_layer if _return_spark_rat != null else 0,
		"collision_mask": _return_spark_rat.collision_mask if _return_spark_rat != null else 0,
		"sprite_frames_path": (
			sprite.sprite_frames.resource_path
			if sprite != null and sprite.sprite_frames != null
			else ""
		),
		"animation_frame_counts": _get_sprite_animation_frame_counts(sprite),
		"position": _return_spark_rat.global_position if _return_spark_rat != null else Vector2.ZERO,
	}


## Returns deterministic checkpoint-forward patrol diagnostics for tests and MCP probes.
func get_factory_checkpoint_forward_patrol_diagnostics() -> Dictionary:
	var sprite: AnimatedSprite2D = (
		_checkpoint_forward_spark_rat.get_node_or_null("Sprite") as AnimatedSprite2D
		if _checkpoint_forward_spark_rat != null
		else null
	)
	var pacing_diagnostics: Dictionary = _get_checkpoint_forward_patrol_pacing_diagnostics()
	return {
		"present": _checkpoint_forward_spark_rat != null,
		"visible": (
			_checkpoint_forward_spark_rat.visible
			if _checkpoint_forward_spark_rat != null
			else false
		),
		"available": _return_checkpoint_activated and not _checkpoint_forward_patrol_defeated,
		"active": _checkpoint_forward_patrol_activated and not _checkpoint_forward_patrol_defeated,
		"defeated": _checkpoint_forward_patrol_defeated,
		"activation_x": FACTORY_CHECKPOINT_FORWARD_PATROL_ACTIVATION_X,
		"activation_ready": _is_checkpoint_forward_patrol_activation_provider_in_range(_player),
		"entity_id": (
			int(_checkpoint_forward_spark_rat.call("get_entity_id"))
			if (
				_checkpoint_forward_spark_rat != null
				and _checkpoint_forward_spark_rat.has_method("get_entity_id")
			)
			else 0
		),
		"has_target": _does_checkpoint_forward_spark_rat_have_target(),
		"physics_enabled": (
			_checkpoint_forward_spark_rat.is_physics_processing()
			if _checkpoint_forward_spark_rat != null
			else false
		),
		"process_enabled": (
			_checkpoint_forward_spark_rat.is_processing()
			if _checkpoint_forward_spark_rat != null
			else false
		),
		"collision_layer": (
			_checkpoint_forward_spark_rat.collision_layer
			if _checkpoint_forward_spark_rat != null
			else 0
		),
		"collision_mask": (
			_checkpoint_forward_spark_rat.collision_mask
			if _checkpoint_forward_spark_rat != null
			else 0
		),
		"sprite_frames_path": (
			sprite.sprite_frames.resource_path
			if sprite != null and sprite.sprite_frames != null
			else ""
		),
		"animation_frame_counts": _get_sprite_animation_frame_counts(sprite),
		"pacing": pacing_diagnostics,
		"position": (
			_checkpoint_forward_spark_rat.global_position
			if _checkpoint_forward_spark_rat != null
			else Vector2.ZERO
		),
	}


## Returns deterministic checkpoint rear ambush diagnostics for tests and MCP probes.
func get_factory_checkpoint_rear_ambush_diagnostics() -> Dictionary:
	var sprite: AnimatedSprite2D = (
		_checkpoint_rear_spark_rat.get_node_or_null("Sprite") as AnimatedSprite2D
		if _checkpoint_rear_spark_rat != null
		else null
	)
	var pacing_diagnostics: Dictionary = _get_checkpoint_rear_ambush_pacing_diagnostics()
	return {
		"present": _checkpoint_rear_spark_rat != null,
		"visible": (
			_checkpoint_rear_spark_rat.visible
			if _checkpoint_rear_spark_rat != null
			else false
		),
		"available": _checkpoint_forward_patrol_defeated and not _checkpoint_rear_ambush_defeated,
		"active": _checkpoint_rear_ambush_activated and not _checkpoint_rear_ambush_defeated,
		"defeated": _checkpoint_rear_ambush_defeated,
		"activation_x": FACTORY_CHECKPOINT_REAR_AMBUSH_ACTIVATION_X,
		"activation_ready": _is_checkpoint_rear_ambush_activation_provider_in_range(_player),
		"entity_id": (
			int(_checkpoint_rear_spark_rat.call("get_entity_id"))
			if (
				_checkpoint_rear_spark_rat != null
				and _checkpoint_rear_spark_rat.has_method("get_entity_id")
			)
			else 0
		),
		"has_target": _does_checkpoint_rear_spark_rat_have_target(),
		"physics_enabled": (
			_checkpoint_rear_spark_rat.is_physics_processing()
			if _checkpoint_rear_spark_rat != null
			else false
		),
		"process_enabled": (
			_checkpoint_rear_spark_rat.is_processing()
			if _checkpoint_rear_spark_rat != null
			else false
		),
		"collision_layer": (
			_checkpoint_rear_spark_rat.collision_layer
			if _checkpoint_rear_spark_rat != null
			else 0
		),
		"collision_mask": (
			_checkpoint_rear_spark_rat.collision_mask
			if _checkpoint_rear_spark_rat != null
			else 0
		),
		"sprite_frames_path": (
			sprite.sprite_frames.resource_path
			if sprite != null and sprite.sprite_frames != null
			else ""
		),
		"animation_frame_counts": _get_sprite_animation_frame_counts(sprite),
		"pacing": pacing_diagnostics,
		"position": (
			_checkpoint_rear_spark_rat.global_position
			if _checkpoint_rear_spark_rat != null
			else Vector2.ZERO
		),
	}


## Returns deterministic checkpoint overdrive duo diagnostics for tests and MCP probes.
func get_factory_checkpoint_overdrive_duo_diagnostics() -> Dictionary:
	var left_sprite: AnimatedSprite2D = (
		_checkpoint_overdrive_left_spark_rat.get_node_or_null("Sprite") as AnimatedSprite2D
		if _checkpoint_overdrive_left_spark_rat != null
		else null
	)
	var right_sprite: AnimatedSprite2D = (
		_checkpoint_overdrive_right_spark_rat.get_node_or_null("Sprite") as AnimatedSprite2D
		if _checkpoint_overdrive_right_spark_rat != null
		else null
	)
	var pacing_diagnostics: Dictionary = _get_checkpoint_overdrive_duo_pacing_diagnostics()
	return {
		"present": (
			_checkpoint_overdrive_left_spark_rat != null
			and _checkpoint_overdrive_right_spark_rat != null
		),
		"available": _checkpoint_rear_ambush_defeated and not _is_checkpoint_overdrive_duo_cleared(),
		"active": _is_checkpoint_overdrive_duo_active(),
		"cleared": _is_checkpoint_overdrive_duo_cleared(),
		"activation_x": FACTORY_CHECKPOINT_OVERDRIVE_DUO_ACTIVATION_X,
		"activation_ready": _is_checkpoint_overdrive_duo_activation_provider_in_range(_player),
		"left_visible": (
			_checkpoint_overdrive_left_spark_rat.visible
			if _checkpoint_overdrive_left_spark_rat != null
			else false
		),
		"right_visible": (
			_checkpoint_overdrive_right_spark_rat.visible
			if _checkpoint_overdrive_right_spark_rat != null
			else false
		),
		"left_defeated": _checkpoint_overdrive_left_defeated,
		"right_defeated": _checkpoint_overdrive_right_defeated,
		"left_entity_id": (
			int(_checkpoint_overdrive_left_spark_rat.call("get_entity_id"))
			if (
				_checkpoint_overdrive_left_spark_rat != null
				and _checkpoint_overdrive_left_spark_rat.has_method("get_entity_id")
			)
			else 0
		),
		"right_entity_id": (
			int(_checkpoint_overdrive_right_spark_rat.call("get_entity_id"))
			if (
				_checkpoint_overdrive_right_spark_rat != null
				and _checkpoint_overdrive_right_spark_rat.has_method("get_entity_id")
			)
			else 0
		),
		"left_has_target": _does_checkpoint_overdrive_left_spark_rat_have_target(),
		"right_has_target": _does_checkpoint_overdrive_right_spark_rat_have_target(),
		"left_physics_enabled": (
			_checkpoint_overdrive_left_spark_rat.is_physics_processing()
			if _checkpoint_overdrive_left_spark_rat != null
			else false
		),
		"right_physics_enabled": (
			_checkpoint_overdrive_right_spark_rat.is_physics_processing()
			if _checkpoint_overdrive_right_spark_rat != null
			else false
		),
		"left_process_enabled": (
			_checkpoint_overdrive_left_spark_rat.is_processing()
			if _checkpoint_overdrive_left_spark_rat != null
			else false
		),
		"right_process_enabled": (
			_checkpoint_overdrive_right_spark_rat.is_processing()
			if _checkpoint_overdrive_right_spark_rat != null
			else false
		),
		"left_collision_layer": (
			_checkpoint_overdrive_left_spark_rat.collision_layer
			if _checkpoint_overdrive_left_spark_rat != null
			else 0
		),
		"right_collision_layer": (
			_checkpoint_overdrive_right_spark_rat.collision_layer
			if _checkpoint_overdrive_right_spark_rat != null
			else 0
		),
		"left_collision_mask": (
			_checkpoint_overdrive_left_spark_rat.collision_mask
			if _checkpoint_overdrive_left_spark_rat != null
			else 0
		),
		"right_collision_mask": (
			_checkpoint_overdrive_right_spark_rat.collision_mask
			if _checkpoint_overdrive_right_spark_rat != null
			else 0
		),
		"left_sprite_frames_path": (
			left_sprite.sprite_frames.resource_path
			if left_sprite != null and left_sprite.sprite_frames != null
			else ""
		),
		"right_sprite_frames_path": (
			right_sprite.sprite_frames.resource_path
			if right_sprite != null and right_sprite.sprite_frames != null
			else ""
		),
		"left_animation_frame_counts": _get_sprite_animation_frame_counts(left_sprite),
		"right_animation_frame_counts": _get_sprite_animation_frame_counts(right_sprite),
		"pacing": pacing_diagnostics,
		"left_position": (
			_checkpoint_overdrive_left_spark_rat.global_position
			if _checkpoint_overdrive_left_spark_rat != null
			else Vector2.ZERO
		),
		"right_position": (
			_checkpoint_overdrive_right_spark_rat.global_position
			if _checkpoint_overdrive_right_spark_rat != null
			else Vector2.ZERO
		),
	}


## Returns deterministic lower-deck skirmish/cache diagnostics for tests and MCP probes.
func get_factory_lower_deck_skirmish_diagnostics() -> Dictionary:
	var sprite: AnimatedSprite2D = (
		_lower_deck_spark_rat.get_node_or_null("Sprite") as AnimatedSprite2D
		if _lower_deck_spark_rat != null
		else null
	)
	return {
		"present": _lower_deck_spark_rat != null and _lower_deck_reward_cache != null,
		"available": _is_checkpoint_overdrive_duo_cleared() and not _lower_deck_skirmish_defeated,
		"active": _is_lower_deck_skirmish_active(),
		"defeated": _lower_deck_skirmish_defeated,
		"activation_x": FACTORY_LOWER_DECK_SKIRMISH_ACTIVATION_X,
		"activation_ready": _is_lower_deck_skirmish_activation_provider_in_range(_player),
		"enemy_visible": _lower_deck_spark_rat.visible if _lower_deck_spark_rat != null else false,
		"enemy_has_target": _does_lower_deck_spark_rat_have_target(),
		"enemy_physics_enabled": (
			_lower_deck_spark_rat.is_physics_processing()
			if _lower_deck_spark_rat != null
			else false
		),
		"enemy_process_enabled": (
			_lower_deck_spark_rat.is_processing()
			if _lower_deck_spark_rat != null
			else false
		),
		"entity_id": (
			int(_lower_deck_spark_rat.call("get_entity_id"))
			if _lower_deck_spark_rat != null and _lower_deck_spark_rat.has_method("get_entity_id")
			else 0
		),
		"sprite_frames_path": (
			sprite.sprite_frames.resource_path
			if sprite != null and sprite.sprite_frames != null
			else ""
		),
		"animation_frame_counts": _get_sprite_animation_frame_counts(sprite),
		"pressure_hazard_present": _lower_deck_steam_vent != null,
		"pressure_hazard_active": _is_hazard_contact_active(_lower_deck_steam_vent),
		"pressure_hazard_id": String(_get_hazard_id(_lower_deck_steam_vent)),
		"pressure_hazard_damage": _get_hazard_damage(_lower_deck_steam_vent),
		"pressure_hazard_cooldown_sec": _get_hazard_cooldown_sec(_lower_deck_steam_vent),
		"cache_present": _lower_deck_reward_cache != null,
		"cache_visible": (
			_lower_deck_reward_cache.visible
			if _lower_deck_reward_cache != null
			else false
		),
		"cache_available": (
			bool(_lower_deck_reward_cache.call("is_available"))
			if (
				_lower_deck_reward_cache != null
				and _lower_deck_reward_cache.has_method("is_available")
			)
			else false
		),
		"cache_claim_available": (
			bool(_lower_deck_reward_cache.call("is_claim_available"))
			if (
				_lower_deck_reward_cache != null
				and _lower_deck_reward_cache.has_method("is_claim_available")
			)
			else false
		),
		"cache_claimed": _lower_deck_reward_cache_claimed,
		"cache_id": (
			String(_lower_deck_reward_cache.call("get_cache_id"))
			if (
				_lower_deck_reward_cache != null
				and _lower_deck_reward_cache.has_method("get_cache_id")
			)
			else ""
		),
		"cache_texture_path": (
			String(_lower_deck_reward_cache.call("get_visual_texture_path"))
			if (
				_lower_deck_reward_cache != null
				and _lower_deck_reward_cache.has_method("get_visual_texture_path")
			)
			else ""
		),
		"cache_position": (
			(_lower_deck_reward_cache as Node2D).global_position
			if _lower_deck_reward_cache != null and _lower_deck_reward_cache is Node2D
			else Vector2.ZERO
		),
		"cache_prompt_text": _get_lower_deck_reward_cache_prompt_text(),
		"last_reward": _last_lower_deck_reward_cache_reward.duplicate(true),
		"last_claim_feedback": _last_lower_deck_reward_cache_claim_feedback.duplicate(true),
	}


## Returns deterministic lower-deck parry-laser gate diagnostics.
func get_factory_lower_deck_parry_gate_diagnostics() -> Dictionary:
	var gate_position: Vector2 = (
		(_lower_deck_parry_gate as Node2D).global_position
		if _lower_deck_parry_gate != null and _lower_deck_parry_gate is Node2D
		else Vector2.ZERO
	)
	return {
		"present": _lower_deck_parry_gate != null,
		"available": _is_lower_deck_parry_gate_available(),
		"unlocked": _lower_deck_parry_gate_unlocked,
		"gate_id": _get_lower_deck_parry_gate_id(),
		"required_ability": _get_lower_deck_parry_gate_required_ability(),
		"gate_state": _get_lower_deck_parry_gate_state(),
		"collision_blocking": _is_lower_deck_parry_gate_collision_blocking(),
		"visual_texture_path": _get_lower_deck_parry_gate_visual_texture_path(),
		"prompt_text": _get_lower_deck_parry_gate_prompt_text(),
		"position": gate_position,
		"visible": _lower_deck_parry_gate.visible if _lower_deck_parry_gate != null else false,
		"provider_in_range": (
			bool(_lower_deck_parry_gate.call("is_provider_in_unlock_range"))
			if (
				_lower_deck_parry_gate != null
				and _lower_deck_parry_gate.has_method("is_provider_in_unlock_range")
			)
			else false
		),
	}


## Returns deterministic lower-deck exit ambush diagnostics.
func get_factory_lower_deck_exit_ambush_diagnostics() -> Dictionary:
	var sprite: AnimatedSprite2D = (
		_lower_deck_exit_spark_rat.get_node_or_null("Sprite") as AnimatedSprite2D
		if _lower_deck_exit_spark_rat != null
		else null
	)
	return {
		"present": _lower_deck_exit_spark_rat != null,
		"available": _lower_deck_reward_cache_claimed and not _lower_deck_exit_ambush_defeated,
		"active": _is_lower_deck_exit_ambush_active(),
		"defeated": _lower_deck_exit_ambush_defeated,
		"gate_unlocked": _lower_deck_parry_gate_unlocked,
		"enemy_visible": (
			_lower_deck_exit_spark_rat.visible if _lower_deck_exit_spark_rat != null else false
		),
		"enemy_has_target": _does_lower_deck_exit_spark_rat_have_target(),
		"enemy_physics_enabled": (
			_lower_deck_exit_spark_rat.is_physics_processing()
			if _lower_deck_exit_spark_rat != null
			else false
		),
		"enemy_process_enabled": (
			_lower_deck_exit_spark_rat.is_processing()
			if _lower_deck_exit_spark_rat != null
			else false
		),
		"entity_id": (
			int(_lower_deck_exit_spark_rat.call("get_entity_id"))
			if (
				_lower_deck_exit_spark_rat != null
				and _lower_deck_exit_spark_rat.has_method("get_entity_id")
			)
			else 0
		),
		"sprite_frames_path": (
			sprite.sprite_frames.resource_path
			if sprite != null and sprite.sprite_frames != null
			else ""
		),
		"animation_frame_counts": _get_sprite_animation_frame_counts(sprite),
		"pacing": _get_lower_deck_exit_ambush_pacing_diagnostics(),
		"position": (
			_lower_deck_exit_spark_rat.global_position
			if _lower_deck_exit_spark_rat != null
			else Vector2.ZERO
		),
	}


## Returns deterministic lower-deck shortcut seal diagnostics.
func get_factory_lower_deck_shortcut_seal_diagnostics() -> Dictionary:
	var sprite: AnimatedSprite2D = (
		_lower_deck_shortcut_spark_rat.get_node_or_null("Sprite") as AnimatedSprite2D
		if _lower_deck_shortcut_spark_rat != null
		else null
	)
	return {
		"present": _lower_deck_shortcut_spark_rat != null and _lower_deck_shortcut_seal != null,
		"available": _is_lower_deck_shortcut_available(),
		"active": _is_lower_deck_shortcut_active(),
		"guard_defeated": _lower_deck_shortcut_guard_defeated,
		"unlocked": _lower_deck_shortcut_unlocked,
		"activation_x": FACTORY_LOWER_DECK_SHORTCUT_ACTIVATION_X,
		"guard_visible": (
			_lower_deck_shortcut_spark_rat.visible
			if _lower_deck_shortcut_spark_rat != null
			else false
		),
		"guard_has_target": _does_lower_deck_shortcut_spark_rat_have_target(),
		"guard_physics_enabled": (
			_lower_deck_shortcut_spark_rat.is_physics_processing()
			if _lower_deck_shortcut_spark_rat != null
			else false
		),
		"guard_process_enabled": (
			_lower_deck_shortcut_spark_rat.is_processing()
			if _lower_deck_shortcut_spark_rat != null
			else false
		),
		"guard_entity_id": (
			int(_lower_deck_shortcut_spark_rat.call("get_entity_id"))
			if (
				_lower_deck_shortcut_spark_rat != null
				and _lower_deck_shortcut_spark_rat.has_method("get_entity_id")
			)
			else 0
		),
		"guard_sprite_frames_path": (
			sprite.sprite_frames.resource_path
			if sprite != null and sprite.sprite_frames != null
			else ""
		),
		"guard_animation_frame_counts": _get_sprite_animation_frame_counts(sprite),
		"pacing": _get_lower_deck_shortcut_pacing_diagnostics(),
		"seal_id": _get_lower_deck_shortcut_seal_id(),
		"seal_visible": (
			_lower_deck_shortcut_seal.visible
			if _lower_deck_shortcut_seal != null
			else false
		),
		"seal_unlockable": _is_lower_deck_shortcut_seal_unlockable(),
		"seal_activated": _is_lower_deck_shortcut_seal_activated(),
		"collision_blocking": _is_lower_deck_shortcut_collision_blocking(),
		"seal_prompt_text": _get_lower_deck_shortcut_prompt_text(),
		"seal_texture_path": _get_lower_deck_shortcut_visual_texture_path(),
		"seal_position": _get_lower_deck_shortcut_position(),
		"guard_position": (
			_lower_deck_shortcut_spark_rat.global_position
			if _lower_deck_shortcut_spark_rat != null
			else Vector2.ZERO
		),
	}


## Returns deterministic shortcut payoff cache diagnostics for tests and MCP probes.
func get_factory_lower_deck_shortcut_reward_cache_diagnostics() -> Dictionary:
	return {
		"present": _lower_deck_shortcut_reward_cache != null,
		"visible": (
			_lower_deck_shortcut_reward_cache.visible
			if _lower_deck_shortcut_reward_cache != null
			else false
		),
		"cache_id": (
			String(_lower_deck_shortcut_reward_cache.call("get_cache_id"))
			if (
				_lower_deck_shortcut_reward_cache != null
				and _lower_deck_shortcut_reward_cache.has_method("get_cache_id")
			)
			else ""
		),
		"texture_path": (
			String(_lower_deck_shortcut_reward_cache.call("get_visual_texture_path"))
			if (
				_lower_deck_shortcut_reward_cache != null
				and _lower_deck_shortcut_reward_cache.has_method("get_visual_texture_path")
			)
			else ""
		),
		"available": (
			bool(_lower_deck_shortcut_reward_cache.call("is_available"))
			if (
				_lower_deck_shortcut_reward_cache != null
				and _lower_deck_shortcut_reward_cache.has_method("is_available")
			)
			else false
		),
		"claim_available": (
			bool(_lower_deck_shortcut_reward_cache.call("is_claim_available"))
			if (
				_lower_deck_shortcut_reward_cache != null
				and _lower_deck_shortcut_reward_cache.has_method("is_claim_available")
			)
			else false
		),
		"claimed": _lower_deck_shortcut_reward_cache_claimed,
		"prompt_text": _get_lower_deck_shortcut_reward_cache_prompt_text(),
		"shortcut_unlocked": _lower_deck_shortcut_unlocked,
		"shortcut_guard_defeated": _lower_deck_shortcut_guard_defeated,
		"position": (
			(_lower_deck_shortcut_reward_cache as Node2D).global_position
			if (
				_lower_deck_shortcut_reward_cache != null
				and _lower_deck_shortcut_reward_cache is Node2D
			)
			else Vector2.ZERO
		),
		"last_reward": _last_lower_deck_shortcut_reward_cache_reward.duplicate(true),
		"last_claim_feedback": (
			_last_lower_deck_shortcut_reward_cache_claim_feedback.duplicate(true)
		),
	}


## Returns deterministic shortcut pursuer diagnostics for tests and MCP probes.
func get_factory_lower_deck_shortcut_pursuer_diagnostics() -> Dictionary:
	var sprite: AnimatedSprite2D = (
		_lower_deck_shortcut_pursuer_spark_rat.get_node_or_null("Sprite") as AnimatedSprite2D
		if _lower_deck_shortcut_pursuer_spark_rat != null
		else null
	)
	return {
		"present": _lower_deck_shortcut_pursuer_spark_rat != null,
		"available": _is_lower_deck_shortcut_pursuer_available(),
		"active": _is_lower_deck_shortcut_pursuer_active(),
		"defeated": _lower_deck_shortcut_pursuer_defeated,
		"shortcut_unlocked": _lower_deck_shortcut_unlocked,
		"shortcut_cache_claimed": _lower_deck_shortcut_reward_cache_claimed,
		"activation_x": FACTORY_LOWER_DECK_SHORTCUT_PURSUER_ACTIVATION_X,
		"enemy_visible": (
			_lower_deck_shortcut_pursuer_spark_rat.visible
			if _lower_deck_shortcut_pursuer_spark_rat != null
			else false
		),
		"enemy_has_target": _does_lower_deck_shortcut_pursuer_have_target(),
		"enemy_physics_enabled": (
			_lower_deck_shortcut_pursuer_spark_rat.is_physics_processing()
			if _lower_deck_shortcut_pursuer_spark_rat != null
			else false
		),
		"enemy_process_enabled": (
			_lower_deck_shortcut_pursuer_spark_rat.is_processing()
			if _lower_deck_shortcut_pursuer_spark_rat != null
			else false
		),
		"entity_id": (
			int(_lower_deck_shortcut_pursuer_spark_rat.call("get_entity_id"))
			if (
				_lower_deck_shortcut_pursuer_spark_rat != null
				and _lower_deck_shortcut_pursuer_spark_rat.has_method("get_entity_id")
			)
			else 0
		),
		"sprite_frames_path": (
			sprite.sprite_frames.resource_path
			if sprite != null and sprite.sprite_frames != null
			else ""
		),
		"animation_frame_counts": _get_sprite_animation_frame_counts(sprite),
		"pacing": _get_lower_deck_shortcut_pursuer_pacing_diagnostics(),
		"position": (
			_lower_deck_shortcut_pursuer_spark_rat.global_position
			if _lower_deck_shortcut_pursuer_spark_rat != null
			else Vector2.ZERO
		),
	}


## Returns deterministic pressure valve diagnostics for tests and MCP probes.
func get_factory_lower_deck_pressure_valve_diagnostics() -> Dictionary:
	var sprite: AnimatedSprite2D = (
		_lower_deck_pressure_guard_spark_rat.get_node_or_null("Sprite") as AnimatedSprite2D
		if _lower_deck_pressure_guard_spark_rat != null
		else null
	)
	return {
		"present": (
			_lower_deck_pressure_guard_spark_rat != null
			and _lower_deck_pressure_valve != null
		),
		"available": _is_lower_deck_pressure_guard_available(),
		"guard_active": _is_lower_deck_pressure_guard_active(),
		"guard_defeated": _lower_deck_pressure_guard_defeated,
		"valve_available": _is_lower_deck_pressure_valve_available(),
		"valve_opened": _lower_deck_pressure_valve_opened,
		"shortcut_pursuer_defeated": _lower_deck_shortcut_pursuer_defeated,
		"activation_x": FACTORY_LOWER_DECK_PRESSURE_VALVE_ACTIVATION_X,
		"guard_visible": (
			_lower_deck_pressure_guard_spark_rat.visible
			if _lower_deck_pressure_guard_spark_rat != null
			else false
		),
		"guard_has_target": _does_lower_deck_pressure_guard_have_target(),
		"guard_physics_enabled": (
			_lower_deck_pressure_guard_spark_rat.is_physics_processing()
			if _lower_deck_pressure_guard_spark_rat != null
			else false
		),
		"guard_process_enabled": (
			_lower_deck_pressure_guard_spark_rat.is_processing()
			if _lower_deck_pressure_guard_spark_rat != null
			else false
		),
		"guard_entity_id": (
			int(_lower_deck_pressure_guard_spark_rat.call("get_entity_id"))
			if (
				_lower_deck_pressure_guard_spark_rat != null
				and _lower_deck_pressure_guard_spark_rat.has_method("get_entity_id")
			)
			else 0
		),
		"guard_sprite_frames_path": (
			sprite.sprite_frames.resource_path
			if sprite != null and sprite.sprite_frames != null
			else ""
		),
		"guard_animation_frame_counts": _get_sprite_animation_frame_counts(sprite),
		"pacing": _get_lower_deck_pressure_guard_pacing_diagnostics(),
		"valve_id": _get_lower_deck_pressure_valve_id(),
		"valve_visible": (
			_lower_deck_pressure_valve.visible
			if _lower_deck_pressure_valve != null
			else false
		),
		"valve_prompt_text": _get_lower_deck_pressure_valve_prompt_text(),
		"valve_texture_path": _get_lower_deck_pressure_valve_visual_texture_path(),
		"valve_position": _get_lower_deck_pressure_valve_position(),
		"guard_position": (
			_lower_deck_pressure_guard_spark_rat.global_position
			if _lower_deck_pressure_guard_spark_rat != null
			else Vector2.ZERO
		),
	}


## Returns deterministic steam sluice ambush diagnostics for tests and MCP probes.
func get_factory_lower_deck_steam_sluice_diagnostics() -> Dictionary:
	var sprite: AnimatedSprite2D = (
		_lower_deck_steam_sluice_spark_rat.get_node_or_null("Sprite") as AnimatedSprite2D
		if _lower_deck_steam_sluice_spark_rat != null
		else null
	)
	return {
		"present": (
			_lower_deck_steam_sluice_spark_rat != null
			and _lower_deck_steam_sluice_hazard != null
		),
		"available": _is_lower_deck_steam_sluice_available(),
		"active": _is_lower_deck_steam_sluice_active(),
		"defeated": _lower_deck_steam_sluice_defeated,
		"pressure_valve_opened": _lower_deck_pressure_valve_opened,
		"activation_x": FACTORY_LOWER_DECK_STEAM_SLUICE_ACTIVATION_X,
		"enemy_visible": (
			_lower_deck_steam_sluice_spark_rat.visible
			if _lower_deck_steam_sluice_spark_rat != null
			else false
		),
		"enemy_has_target": _does_lower_deck_steam_sluice_have_target(),
		"enemy_physics_enabled": (
			_lower_deck_steam_sluice_spark_rat.is_physics_processing()
			if _lower_deck_steam_sluice_spark_rat != null
			else false
		),
		"enemy_process_enabled": (
			_lower_deck_steam_sluice_spark_rat.is_processing()
			if _lower_deck_steam_sluice_spark_rat != null
			else false
		),
		"entity_id": (
			int(_lower_deck_steam_sluice_spark_rat.call("get_entity_id"))
			if (
				_lower_deck_steam_sluice_spark_rat != null
				and _lower_deck_steam_sluice_spark_rat.has_method("get_entity_id")
			)
			else 0
		),
		"sprite_frames_path": (
			sprite.sprite_frames.resource_path
			if sprite != null and sprite.sprite_frames != null
			else ""
		),
		"animation_frame_counts": _get_sprite_animation_frame_counts(sprite),
		"pacing": _get_lower_deck_steam_sluice_pacing_diagnostics(),
		"hazard_present": _lower_deck_steam_sluice_hazard != null,
		"hazard_active": _is_hazard_contact_active(_lower_deck_steam_sluice_hazard),
		"hazard_visible": (
			_lower_deck_steam_sluice_hazard.visible
			if _lower_deck_steam_sluice_hazard != null
			else false
		),
		"hazard_id": String(_get_hazard_id(_lower_deck_steam_sluice_hazard)),
		"hazard_damage": _get_hazard_damage(_lower_deck_steam_sluice_hazard),
		"hazard_cooldown_sec": _get_hazard_cooldown_sec(_lower_deck_steam_sluice_hazard),
		"hazard_layer": (
			_lower_deck_steam_sluice_hazard.collision_layer
			if _lower_deck_steam_sluice_hazard != null
			else 0
		),
		"hazard_mask": (
			_lower_deck_steam_sluice_hazard.collision_mask
			if _lower_deck_steam_sluice_hazard != null
			else 0
		),
		"hazard_texture_path": (
			String(_lower_deck_steam_sluice_hazard.call("get_visual_texture_path"))
			if (
				_lower_deck_steam_sluice_hazard != null
				and _lower_deck_steam_sluice_hazard.has_method("get_visual_texture_path")
			)
			else ""
		),
		"enemy_position": (
			_lower_deck_steam_sluice_spark_rat.global_position
			if _lower_deck_steam_sluice_spark_rat != null
			else Vector2.ZERO
		),
		"hazard_position": (
			_lower_deck_steam_sluice_hazard.global_position
			if _lower_deck_steam_sluice_hazard != null
			else Vector2.ZERO
		),
	}


## Returns deterministic post-relay trial diagnostics for tests and MCP probes.
func get_factory_lower_deck_post_relay_trial_diagnostics() -> Dictionary:
	var sprite: AnimatedSprite2D = (
		_lower_deck_post_relay_spark_rat.get_node_or_null("Sprite") as AnimatedSprite2D
		if _lower_deck_post_relay_spark_rat != null
		else null
	)
	return {
		"present": (
			_lower_deck_post_relay_spark_rat != null
			and _lower_deck_post_relay_steam_hazard != null
		),
		"available": _is_lower_deck_post_relay_trial_available(),
		"active": _is_lower_deck_post_relay_trial_active(),
		"defeated": _lower_deck_post_relay_trial_defeated,
		"breach_relay_activated": _lower_deck_breach_relay_activated,
		"activation_x": FACTORY_LOWER_DECK_POST_RELAY_TRIAL_ACTIVATION_X,
		"enemy_visible": (
			_lower_deck_post_relay_spark_rat.visible
			if _lower_deck_post_relay_spark_rat != null
			else false
		),
		"enemy_has_target": _does_lower_deck_post_relay_trial_have_target(),
		"enemy_physics_enabled": (
			_lower_deck_post_relay_spark_rat.is_physics_processing()
			if _lower_deck_post_relay_spark_rat != null
			else false
		),
		"enemy_process_enabled": (
			_lower_deck_post_relay_spark_rat.is_processing()
			if _lower_deck_post_relay_spark_rat != null
			else false
		),
		"entity_id": (
			int(_lower_deck_post_relay_spark_rat.call("get_entity_id"))
			if (
				_lower_deck_post_relay_spark_rat != null
				and _lower_deck_post_relay_spark_rat.has_method("get_entity_id")
			)
			else 0
		),
		"sprite_frames_path": (
			sprite.sprite_frames.resource_path
			if sprite != null and sprite.sprite_frames != null
			else ""
		),
		"animation_frame_counts": _get_sprite_animation_frame_counts(sprite),
		"pacing": _get_lower_deck_post_relay_trial_pacing_diagnostics(),
		"hazard_present": _lower_deck_post_relay_steam_hazard != null,
		"hazard_active": _is_hazard_contact_active(_lower_deck_post_relay_steam_hazard),
		"hazard_visible": (
			_lower_deck_post_relay_steam_hazard.visible
			if _lower_deck_post_relay_steam_hazard != null
			else false
		),
		"hazard_id": String(_get_hazard_id(_lower_deck_post_relay_steam_hazard)),
		"hazard_damage": _get_hazard_damage(_lower_deck_post_relay_steam_hazard),
		"hazard_cooldown_sec": _get_hazard_cooldown_sec(_lower_deck_post_relay_steam_hazard),
		"enemy_position": (
			_lower_deck_post_relay_spark_rat.global_position
			if _lower_deck_post_relay_spark_rat != null
			else Vector2.ZERO
		),
		"hazard_position": (
			_lower_deck_post_relay_steam_hazard.global_position
			if _lower_deck_post_relay_steam_hazard != null
			else Vector2.ZERO
		),
	}


## Returns deterministic relay-forward reward cache diagnostics for tests and MCP probes.
func get_factory_lower_deck_relay_forward_reward_cache_diagnostics() -> Dictionary:
	return {
		"present": _lower_deck_relay_forward_reward_cache != null,
		"visible": (
			_lower_deck_relay_forward_reward_cache.visible
			if _lower_deck_relay_forward_reward_cache != null
			else false
		),
		"cache_id": (
			String(_lower_deck_relay_forward_reward_cache.call("get_cache_id"))
			if (
				_lower_deck_relay_forward_reward_cache != null
				and _lower_deck_relay_forward_reward_cache.has_method("get_cache_id")
			)
			else ""
		),
		"texture_path": (
			String(_lower_deck_relay_forward_reward_cache.call("get_visual_texture_path"))
			if (
				_lower_deck_relay_forward_reward_cache != null
				and _lower_deck_relay_forward_reward_cache.has_method("get_visual_texture_path")
			)
			else ""
		),
		"available": (
			bool(_lower_deck_relay_forward_reward_cache.call("is_available"))
			if (
				_lower_deck_relay_forward_reward_cache != null
				and _lower_deck_relay_forward_reward_cache.has_method("is_available")
			)
			else false
		),
		"claim_available": (
			bool(_lower_deck_relay_forward_reward_cache.call("is_claim_available"))
			if (
				_lower_deck_relay_forward_reward_cache != null
				and _lower_deck_relay_forward_reward_cache.has_method("is_claim_available")
			)
			else false
		),
		"claimed": _lower_deck_relay_forward_reward_cache_claimed,
		"prompt_text": _get_lower_deck_relay_forward_reward_cache_prompt_text(),
		"post_relay_trial_defeated": _lower_deck_post_relay_trial_defeated,
		"position": (
			(_lower_deck_relay_forward_reward_cache as Node2D).global_position
			if (
				_lower_deck_relay_forward_reward_cache != null
				and _lower_deck_relay_forward_reward_cache is Node2D
			)
			else Vector2.ZERO
		),
		"last_reward": _last_lower_deck_relay_forward_reward_cache_reward.duplicate(true),
		"last_claim_feedback": (
			_last_lower_deck_relay_forward_reward_cache_claim_feedback.duplicate(true)
		),
	}


## Returns deterministic forward-pressure reward cache diagnostics for tests and MCP probes.
func get_factory_lower_deck_forward_pressure_reward_cache_diagnostics() -> Dictionary:
	return {
		"present": _lower_deck_forward_pressure_reward_cache != null,
		"visible": (
			_lower_deck_forward_pressure_reward_cache.visible
			if _lower_deck_forward_pressure_reward_cache != null
			else false
		),
		"cache_id": (
			String(_lower_deck_forward_pressure_reward_cache.call("get_cache_id"))
			if (
				_lower_deck_forward_pressure_reward_cache != null
				and _lower_deck_forward_pressure_reward_cache.has_method("get_cache_id")
			)
			else ""
		),
		"texture_path": (
			String(_lower_deck_forward_pressure_reward_cache.call(
				"get_visual_texture_path"
			))
			if (
				_lower_deck_forward_pressure_reward_cache != null
				and _lower_deck_forward_pressure_reward_cache.has_method(
					"get_visual_texture_path"
				)
			)
			else ""
		),
		"available": (
			bool(_lower_deck_forward_pressure_reward_cache.call("is_available"))
			if (
				_lower_deck_forward_pressure_reward_cache != null
				and _lower_deck_forward_pressure_reward_cache.has_method("is_available")
			)
			else false
		),
		"claim_available": (
			bool(_lower_deck_forward_pressure_reward_cache.call("is_claim_available"))
			if (
				_lower_deck_forward_pressure_reward_cache != null
				and _lower_deck_forward_pressure_reward_cache.has_method(
					"is_claim_available"
				)
			)
			else false
		),
		"claimed": _lower_deck_forward_pressure_reward_cache_claimed,
		"prompt_text": _get_lower_deck_forward_pressure_reward_cache_prompt_text(),
		"counter_ambush_defeated": _lower_deck_forward_pressure_counter_ambush_defeated,
		"position": (
			(_lower_deck_forward_pressure_reward_cache as Node2D).global_position
			if (
				_lower_deck_forward_pressure_reward_cache != null
				and _lower_deck_forward_pressure_reward_cache is Node2D
			)
			else Vector2.ZERO
		),
		"last_reward": (
			_last_lower_deck_forward_pressure_reward_cache_reward.duplicate(true)
		),
		"last_claim_feedback": (
			_last_lower_deck_forward_pressure_reward_cache_claim_feedback.duplicate(true)
		),
		"claim_audio_requested": (
			_lower_deck_forward_pressure_reward_cache_claim_audio_request_count > 0
		),
		"claim_audio_request_count": (
			_lower_deck_forward_pressure_reward_cache_claim_audio_request_count
		),
		"claim_audio_event": (
			_lower_deck_forward_pressure_reward_cache_claim_audio_event.duplicate(true)
		),
	}


## Returns deterministic aftershock reward cache diagnostics for tests and MCP probes.
func get_factory_lower_deck_forward_pressure_aftershock_reward_cache_diagnostics(
) -> Dictionary:
	return {
		"present": _lower_deck_forward_pressure_aftershock_reward_cache != null,
		"visible": (
			_lower_deck_forward_pressure_aftershock_reward_cache.visible
			if _lower_deck_forward_pressure_aftershock_reward_cache != null
			else false
		),
		"cache_id": (
			String(_lower_deck_forward_pressure_aftershock_reward_cache.call("get_cache_id"))
			if (
				_lower_deck_forward_pressure_aftershock_reward_cache != null
				and _lower_deck_forward_pressure_aftershock_reward_cache.has_method(
					"get_cache_id"
				)
			)
			else ""
		),
		"texture_path": (
			String(_lower_deck_forward_pressure_aftershock_reward_cache.call(
				"get_visual_texture_path"
			))
			if (
				_lower_deck_forward_pressure_aftershock_reward_cache != null
				and _lower_deck_forward_pressure_aftershock_reward_cache.has_method(
					"get_visual_texture_path"
				)
			)
			else ""
		),
		"available": (
			bool(_lower_deck_forward_pressure_aftershock_reward_cache.call("is_available"))
			if (
				_lower_deck_forward_pressure_aftershock_reward_cache != null
				and _lower_deck_forward_pressure_aftershock_reward_cache.has_method(
					"is_available"
				)
			)
			else false
		),
		"claim_available": (
			bool(_lower_deck_forward_pressure_aftershock_reward_cache.call(
				"is_claim_available"
			))
			if (
				_lower_deck_forward_pressure_aftershock_reward_cache != null
				and _lower_deck_forward_pressure_aftershock_reward_cache.has_method(
					"is_claim_available"
				)
			)
			else false
		),
		"claimed": _lower_deck_forward_pressure_aftershock_reward_cache_claimed,
		"prompt_text": (
			_get_lower_deck_forward_pressure_aftershock_reward_cache_prompt_text()
		),
		"coil_aftershock_cleared": _lower_deck_forward_pressure_coil_aftershock_defeated,
		"position": (
			(_lower_deck_forward_pressure_aftershock_reward_cache as Node2D).global_position
			if (
				_lower_deck_forward_pressure_aftershock_reward_cache != null
				and _lower_deck_forward_pressure_aftershock_reward_cache is Node2D
			)
			else Vector2.ZERO
		),
		"last_reward": (
			_last_lower_deck_forward_pressure_aftershock_reward_cache_reward.duplicate(
				true
			)
		),
		"last_claim_feedback": (
			_last_lower_deck_forward_pressure_aftershock_reward_cache_claim_feedback.duplicate(
				true
			)
		),
	}


## Returns deterministic exhaust-pursuer reward cache diagnostics for tests and MCP probes.
func get_factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache_diagnostics(
) -> Dictionary:
	var cache: Node = _lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache
	return {
		"present": cache != null,
		"visible": cache.visible if cache != null else false,
		"cache_id": (
			String(cache.call("get_cache_id"))
			if cache != null and cache.has_method("get_cache_id")
			else ""
		),
		"texture_path": (
			String(cache.call("get_visual_texture_path"))
			if cache != null and cache.has_method("get_visual_texture_path")
			else ""
		),
		"available": (
			bool(cache.call("is_available"))
			if cache != null and cache.has_method("is_available")
			else false
		),
		"claim_available": (
			bool(cache.call("is_claim_available"))
			if cache != null and cache.has_method("is_claim_available")
			else false
		),
		"claimed": (
			_lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache_claimed
		),
		"prompt_text": (
			_get_lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache_prompt_text()
		),
		"exhaust_pursuer_cleared": (
			_lower_deck_forward_pressure_aftershock_exhaust_pursuer_defeated
		),
		"position": (
			(cache as Node2D).global_position
			if cache != null and cache is Node2D
			else Vector2.ZERO
		),
		"last_reward": (
			_last_lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache_reward
			.duplicate(true)
		),
		"last_claim_feedback": (
			_last_lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache_claim_feedback
			.duplicate(true)
		),
	}


## Returns deterministic aftershock exhaust breaker diagnostics for tests and MCP probes.
func get_factory_lower_deck_forward_pressure_aftershock_exhaust_breaker_diagnostics(
) -> Dictionary:
	var sprite: AnimatedSprite2D = (
		_lower_deck_forward_pressure_aftershock_exhaust_breaker_coil_rat.get_node_or_null(
			"Sprite"
		) as AnimatedSprite2D
		if _lower_deck_forward_pressure_aftershock_exhaust_breaker_coil_rat != null
		else null
	)
	var prompt_label := (
		_lower_deck_forward_pressure_aftershock_exhaust_breaker.get_node_or_null(
			"PromptLabel"
		) as Label
		if _lower_deck_forward_pressure_aftershock_exhaust_breaker != null
		else null
	)
	var unlock_vfx_snapshot: Dictionary = {}
	if (
		_lower_deck_forward_pressure_aftershock_exhaust_breaker != null
		and _lower_deck_forward_pressure_aftershock_exhaust_breaker.has_method(
			"get_unlock_vfx_snapshot"
		)
	):
		var snapshot_variant: Variant = (
			_lower_deck_forward_pressure_aftershock_exhaust_breaker.call(
				"get_unlock_vfx_snapshot"
			)
		)
		if snapshot_variant is Dictionary:
			unlock_vfx_snapshot = (snapshot_variant as Dictionary).duplicate(true)
	var route: Dictionary = get_factory_route_objective_diagnostics()
	return {
		"present": (
			_lower_deck_forward_pressure_aftershock_exhaust_breaker_coil_rat != null
			and _lower_deck_forward_pressure_aftershock_exhaust_breaker_vent != null
			and _lower_deck_forward_pressure_aftershock_exhaust_breaker != null
		),
		"flank_cleared": (
			_lower_deck_forward_pressure_aftershock_exhaust_flank_spark_rat_defeated
		),
		"available": (
			_is_lower_deck_forward_pressure_aftershock_exhaust_breaker_stand_available()
		),
		"active": (
			_is_lower_deck_forward_pressure_aftershock_exhaust_breaker_stand_active()
		),
		"secured": _lower_deck_forward_pressure_aftershock_exhaust_breaker_secured,
		"cut": _lower_deck_forward_pressure_aftershock_exhaust_breaker_cut,
		"activation_x": FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_EXHAUST_BREAKER_ACTIVATION_X,
		"coil_visible": (
			_lower_deck_forward_pressure_aftershock_exhaust_breaker_coil_rat.visible
			if _lower_deck_forward_pressure_aftershock_exhaust_breaker_coil_rat != null
			else false
		),
		"coil_has_target": (
			_does_lower_deck_forward_pressure_aftershock_exhaust_breaker_coil_rat_have_target()
		),
		"coil_physics_enabled": (
			_lower_deck_forward_pressure_aftershock_exhaust_breaker_coil_rat.is_physics_processing()
			if _lower_deck_forward_pressure_aftershock_exhaust_breaker_coil_rat != null
			else false
		),
		"coil_process_enabled": (
			_lower_deck_forward_pressure_aftershock_exhaust_breaker_coil_rat.is_processing()
			if _lower_deck_forward_pressure_aftershock_exhaust_breaker_coil_rat != null
			else false
		),
		"coil_entity_id": (
			int(_lower_deck_forward_pressure_aftershock_exhaust_breaker_coil_rat.call(
				"get_entity_id"
			))
			if (
				_lower_deck_forward_pressure_aftershock_exhaust_breaker_coil_rat != null
				and _lower_deck_forward_pressure_aftershock_exhaust_breaker_coil_rat.has_method(
					"get_entity_id"
				)
			)
			else 0
		),
		"coil_family_id": (
			String(_lower_deck_forward_pressure_aftershock_exhaust_breaker_coil_rat.call(
				"get_enemy_family_id"
			))
			if (
				_lower_deck_forward_pressure_aftershock_exhaust_breaker_coil_rat != null
				and _lower_deck_forward_pressure_aftershock_exhaust_breaker_coil_rat.has_method(
					"get_enemy_family_id"
				)
			)
			else ""
		),
		"coil_sprite_frames_path": (
			sprite.sprite_frames.resource_path
			if sprite != null and sprite.sprite_frames != null
			else ""
		),
		"coil_animation_frame_counts": _get_sprite_animation_frame_counts(sprite),
		"pacing": (
			_get_lower_deck_forward_pressure_aftershock_exhaust_breaker_pacing_diagnostics()
		),
		"hazard_visible": (
			_lower_deck_forward_pressure_aftershock_exhaust_breaker_vent.visible
			if _lower_deck_forward_pressure_aftershock_exhaust_breaker_vent != null
			else false
		),
		"hazard_contact_active": _is_hazard_contact_active(
			_lower_deck_forward_pressure_aftershock_exhaust_breaker_vent
		),
		"hazard_id": String(_get_hazard_id(
			_lower_deck_forward_pressure_aftershock_exhaust_breaker_vent
		)),
		"hazard_damage": _get_hazard_damage(
			_lower_deck_forward_pressure_aftershock_exhaust_breaker_vent
		),
		"hazard_cooldown_sec": _get_hazard_cooldown_sec(
			_lower_deck_forward_pressure_aftershock_exhaust_breaker_vent
		),
		"hazard_texture_path": (
			String(_lower_deck_forward_pressure_aftershock_exhaust_breaker_vent.call(
				"get_visual_texture_path"
			))
			if (
				_lower_deck_forward_pressure_aftershock_exhaust_breaker_vent != null
				and _lower_deck_forward_pressure_aftershock_exhaust_breaker_vent.has_method(
					"get_visual_texture_path"
				)
			)
			else ""
		),
		"breaker_visible": (
			_lower_deck_forward_pressure_aftershock_exhaust_breaker.visible
			if _lower_deck_forward_pressure_aftershock_exhaust_breaker != null
			else false
		),
		"breaker_id": (
			String(_lower_deck_forward_pressure_aftershock_exhaust_breaker.call(
				"get_endpoint_id"
			))
			if (
				_lower_deck_forward_pressure_aftershock_exhaust_breaker != null
				and _lower_deck_forward_pressure_aftershock_exhaust_breaker.has_method(
					"get_endpoint_id"
				)
			)
			else String(FACTORY_LOWER_DECK_FORWARD_PRESSURE_AFTERSHOCK_EXHAUST_BREAKER_ID)
		),
		"prompt_text": prompt_label.text if prompt_label != null else "",
		"texture_path": (
			String(_lower_deck_forward_pressure_aftershock_exhaust_breaker.call(
				"get_visual_texture_path"
			))
			if (
				_lower_deck_forward_pressure_aftershock_exhaust_breaker != null
				and _lower_deck_forward_pressure_aftershock_exhaust_breaker.has_method(
					"get_visual_texture_path"
				)
			)
			else ""
		),
		"unlock_feedback_played": bool(unlock_vfx_snapshot.get("played", false)),
		"unlock_feedback_spawn_count": int(unlock_vfx_snapshot.get("spawn_count", 0)),
		"route_label_text": String(route.get("route_label_text", "")),
	}


## Returns deterministic aftershock exhaust escape skirmish diagnostics.
func get_factory_lower_deck_forward_pressure_aftershock_exhaust_escape_skirmish_diagnostics(
) -> Dictionary:
	var spark_rat: Node2D = _get_valid_node2d(
		_lower_deck_forward_pressure_aftershock_exhaust_escape_spark_rat
	)
	var coil_rat: Node2D = _get_valid_node2d(
		_lower_deck_forward_pressure_aftershock_exhaust_escape_coil_rat
	)
	var spark_sprite: AnimatedSprite2D = (
		spark_rat.get_node_or_null("Sprite") as AnimatedSprite2D
		if spark_rat != null
		else null
	)
	var coil_sprite: AnimatedSprite2D = (
		coil_rat.get_node_or_null("Sprite") as AnimatedSprite2D
		if coil_rat != null
		else null
	)
	var route: Dictionary = get_factory_route_objective_diagnostics()
	return {
		"present": spark_rat != null and coil_rat != null,
		"available": (
			_is_lower_deck_forward_pressure_aftershock_exhaust_escape_skirmish_available()
		),
		"active": _is_lower_deck_forward_pressure_aftershock_exhaust_escape_skirmish_active(),
		"cleared": _is_lower_deck_forward_pressure_aftershock_exhaust_escape_skirmish_cleared(),
		"breaker_cut": _lower_deck_forward_pressure_aftershock_exhaust_breaker_cut,
		"encounter_id": String(
			FACTORY_LOWER_DECK_FORWARD_PRESSURE_AFTERSHOCK_EXHAUST_ESCAPE_ID
		),
		"activation_x": FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_EXHAUST_ESCAPE_ACTIVATION_X,
		"spark_visible": spark_rat.visible if spark_rat != null else false,
		"coil_visible": coil_rat.visible if coil_rat != null else false,
		"spark_has_target": (
			_does_lower_deck_forward_pressure_aftershock_exhaust_escape_spark_rat_have_target()
		),
		"coil_has_target": (
			_does_lower_deck_forward_pressure_aftershock_exhaust_escape_coil_rat_have_target()
		),
		"spark_physics_enabled": (
			spark_rat.is_physics_processing()
			if spark_rat != null
			else false
		),
		"coil_physics_enabled": (
			coil_rat.is_physics_processing()
			if coil_rat != null
			else false
		),
		"spark_process_enabled": (
			spark_rat.is_processing()
			if spark_rat != null
			else false
		),
		"coil_process_enabled": (
			coil_rat.is_processing()
			if coil_rat != null
			else false
		),
		"spark_defeated": (
			_lower_deck_forward_pressure_aftershock_exhaust_escape_spark_rat_defeated
		),
		"coil_defeated": (
			_lower_deck_forward_pressure_aftershock_exhaust_escape_coil_rat_defeated
		),
		"spark_entity_id": _get_enemy_entity_id(spark_rat),
		"coil_entity_id": _get_enemy_entity_id(coil_rat),
		"spark_family_id": _get_enemy_family_id(spark_rat),
		"coil_family_id": _get_enemy_family_id(coil_rat),
		"spark_sprite_frames_path": (
			spark_sprite.sprite_frames.resource_path
			if spark_sprite != null and spark_sprite.sprite_frames != null
			else ""
		),
		"coil_sprite_frames_path": (
			coil_sprite.sprite_frames.resource_path
			if coil_sprite != null and coil_sprite.sprite_frames != null
			else ""
		),
		"spark_animation_frame_counts": _get_sprite_animation_frame_counts(spark_sprite),
		"coil_animation_frame_counts": _get_sprite_animation_frame_counts(coil_sprite),
		"pacing": (
			_get_lower_deck_forward_pressure_aftershock_exhaust_escape_skirmish_pacing_diagnostics()
		),
		"spark_position": (
			spark_rat.global_position
			if spark_rat != null
			else Vector2.ZERO
		),
		"coil_position": (
			coil_rat.global_position
			if coil_rat != null
			else Vector2.ZERO
		),
		"route_label_text": String(route.get("route_label_text", "")),
	}


## Returns deterministic aftershock exhaust exit hatch diagnostics for tests and MCP probes.
func get_factory_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch_diagnostics(
) -> Dictionary:
	var interaction_area := (
		_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch.get_node_or_null(
			"InteractionArea"
		) as Area2D
		if _lower_deck_forward_pressure_aftershock_exhaust_exit_hatch != null
		else null
	)
	var collision_shape := (
		_get_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch_collision_shape()
	)
	var route: Dictionary = get_factory_route_objective_diagnostics()
	var unlock_vfx_snapshot: Dictionary = (
		_get_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch_unlock_vfx_snapshot()
	)
	return {
		"present": _lower_deck_forward_pressure_aftershock_exhaust_exit_hatch != null,
		"available": (
			_is_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch_available()
		),
		"visible": (
			_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch.visible
			if _lower_deck_forward_pressure_aftershock_exhaust_exit_hatch != null
			else false
		),
		"opened": _lower_deck_forward_pressure_aftershock_exhaust_exit_hatch_opened,
		"escape_skirmish_cleared": (
			_is_lower_deck_forward_pressure_aftershock_exhaust_escape_skirmish_cleared()
		),
		"hatch_id": _get_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch_id(),
		"prompt_text": (
			_get_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch_prompt_text()
		),
		"texture_path": (
			_get_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch_texture_path()
		),
		"interaction_monitoring": interaction_area.monitoring if interaction_area != null else false,
		"interaction_monitorable": interaction_area.monitorable if interaction_area != null else false,
		"collision_disabled": collision_shape.disabled if collision_shape != null else true,
		"collision_blocking": (
			_is_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch_collision_blocking()
		),
		"position": _get_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch_position(),
		"route_label_text": String(route.get("route_label_text", "")),
		"unlock_feedback_texture_path": String(unlock_vfx_snapshot.get("texture_path", "")),
		"unlock_feedback_active": int(unlock_vfx_snapshot.get("active_count", 0)) > 0,
		"unlock_feedback_played": bool(unlock_vfx_snapshot.get("played", false)),
		"unlock_feedback_spawn_count": int(unlock_vfx_snapshot.get("spawn_count", 0)),
	}


## Returns deterministic aftershock cooling duct diagnostics for tests and MCP probes.
func get_factory_lower_deck_forward_pressure_aftershock_cooling_duct_diagnostics(
) -> Dictionary:
	var route: Dictionary = get_factory_route_objective_diagnostics()
	var duct_present: bool = _lower_deck_forward_pressure_aftershock_cooling_duct != null
	var hazard_present: bool = (
		_lower_deck_forward_pressure_aftershock_cooling_duct_vent != null
	)
	var ground_shape := (
		get_node_or_null("Ground/CollisionShape2D") as CollisionShape2D
	)
	var ground_rect := (
		ground_shape.shape as RectangleShape2D
		if ground_shape != null and ground_shape.shape is RectangleShape2D
		else null
	)
	var right_wall := get_node_or_null("RightWall") as Node2D
	var camera := get_node_or_null("Player/Camera2D") as Camera2D
	return {
		"present": duct_present and hazard_present,
		"available": _is_lower_deck_forward_pressure_aftershock_cooling_duct_available(),
		"active": _is_lower_deck_forward_pressure_aftershock_cooling_duct_active(),
		"crossed": _lower_deck_forward_pressure_aftershock_cooling_duct_crossed,
		"visible": (
			_lower_deck_forward_pressure_aftershock_cooling_duct.visible
			if duct_present
			else false
		),
		"exit_hatch_opened": _lower_deck_forward_pressure_aftershock_exhaust_exit_hatch_opened,
		"node_name": (
			String(_lower_deck_forward_pressure_aftershock_cooling_duct.name)
			if duct_present
			else ""
		),
		"hazard_node_name": (
			String(_lower_deck_forward_pressure_aftershock_cooling_duct_vent.name)
			if hazard_present
			else ""
		),
		"duct_texture_path": (
			_lower_deck_forward_pressure_aftershock_cooling_duct.texture.resource_path
			if (
				duct_present
				and _lower_deck_forward_pressure_aftershock_cooling_duct.texture != null
			)
			else ""
		),
		"hazard_visible": (
			_lower_deck_forward_pressure_aftershock_cooling_duct_vent.visible
			if hazard_present
			else false
		),
		"hazard_contact_active": _is_hazard_contact_active(
			_lower_deck_forward_pressure_aftershock_cooling_duct_vent
		),
		"hazard_id": String(_get_hazard_id(
			_lower_deck_forward_pressure_aftershock_cooling_duct_vent
		)),
		"hazard_damage": _get_hazard_damage(
			_lower_deck_forward_pressure_aftershock_cooling_duct_vent
		),
		"hazard_cooldown_sec": _get_hazard_cooldown_sec(
			_lower_deck_forward_pressure_aftershock_cooling_duct_vent
		),
		"hazard_texture_path": (
			String(_lower_deck_forward_pressure_aftershock_cooling_duct_vent.call(
				"get_visual_texture_path"
			))
			if (
				hazard_present
				and _lower_deck_forward_pressure_aftershock_cooling_duct_vent.has_method(
					"get_visual_texture_path"
				)
			)
			else ""
		),
		"phase": String(_get_lower_deck_forward_pressure_aftershock_cooling_duct_phase()),
		"initial_grace_sec": FACTORY_LOWER_DECK_FORWARD_PRESSURE_INITIAL_GRACE_SEC,
		"warning_sec": FACTORY_LOWER_DECK_FORWARD_PRESSURE_WARNING_SEC,
		"active_sec": FACTORY_LOWER_DECK_FORWARD_PRESSURE_ACTIVE_SEC,
		"safe_sec": FACTORY_LOWER_DECK_FORWARD_PRESSURE_SAFE_SEC,
		"activation_x": FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_COOLING_DUCT_ACTIVATION_X,
		"exit_x": FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_COOLING_DUCT_EXIT_X,
		"ground_width": ground_rect.size.x if ground_rect != null else 0.0,
		"right_wall_x": right_wall.global_position.x if right_wall != null else 0.0,
		"camera_limit_right": camera.limit_right if camera != null else 0,
		"route_label_text": String(route.get("route_label_text", "")),
	}


## Returns deterministic condenser valve ambush diagnostics for tests and MCP probes.
func get_factory_lower_deck_forward_pressure_aftershock_condenser_valve_diagnostics(
) -> Dictionary:
	var route: Dictionary = get_factory_route_objective_diagnostics()
	var valve_present: bool = _lower_deck_forward_pressure_aftershock_condenser_valve != null
	var spark_rat: Node2D = _get_valid_node2d(
		_lower_deck_forward_pressure_aftershock_condenser_spark_rat
	)
	var coil_rat: Node2D = _get_valid_node2d(
		_lower_deck_forward_pressure_aftershock_condenser_coil_rat
	)
	var spark_sprite: AnimatedSprite2D = (
		spark_rat.get_node_or_null("Sprite") as AnimatedSprite2D
		if spark_rat != null
		else null
	)
	var coil_sprite: AnimatedSprite2D = (
		coil_rat.get_node_or_null("Sprite") as AnimatedSprite2D
		if coil_rat != null
		else null
	)
	var ground_shape := (
		get_node_or_null("Ground/CollisionShape2D") as CollisionShape2D
	)
	var ground_rect := (
		ground_shape.shape as RectangleShape2D
		if ground_shape != null and ground_shape.shape is RectangleShape2D
		else null
	)
	var right_wall := get_node_or_null("RightWall") as Node2D
	var camera := get_node_or_null("Player/Camera2D") as Camera2D
	return {
		"present": valve_present and spark_rat != null and coil_rat != null,
		"available": _is_lower_deck_forward_pressure_aftershock_condenser_valve_available(),
		"active": _is_lower_deck_forward_pressure_aftershock_condenser_valve_active(),
		"cleared": _is_lower_deck_forward_pressure_aftershock_condenser_valve_cleared(),
		"cooling_duct_crossed": _lower_deck_forward_pressure_aftershock_cooling_duct_crossed,
		"visible": (
			_lower_deck_forward_pressure_aftershock_condenser_valve.visible
			if valve_present
			else false
		),
		"node_name": (
			String(_lower_deck_forward_pressure_aftershock_condenser_valve.name)
			if valve_present
			else ""
		),
		"texture_path": (
			_lower_deck_forward_pressure_aftershock_condenser_valve.texture.resource_path
			if (
				valve_present
				and _lower_deck_forward_pressure_aftershock_condenser_valve.texture != null
			)
			else ""
		),
		"activation_x": FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_CONDENSER_ACTIVATION_X,
		"ground_width": ground_rect.size.x if ground_rect != null else 0.0,
		"right_wall_x": right_wall.global_position.x if right_wall != null else 0.0,
		"camera_limit_right": camera.limit_right if camera != null else 0,
		"spark_visible": spark_rat.visible if spark_rat != null else false,
		"coil_visible": coil_rat.visible if coil_rat != null else false,
		"spark_has_target": _does_lower_deck_forward_pressure_aftershock_condenser_spark_rat_have_target(),
		"coil_has_target": _does_lower_deck_forward_pressure_aftershock_condenser_coil_rat_have_target(),
		"spark_process_enabled": spark_rat.is_processing() if spark_rat != null else false,
		"coil_process_enabled": coil_rat.is_processing() if coil_rat != null else false,
		"spark_physics_enabled": spark_rat.is_physics_processing() if spark_rat != null else false,
		"coil_physics_enabled": coil_rat.is_physics_processing() if coil_rat != null else false,
		"spark_defeated": (
			_lower_deck_forward_pressure_aftershock_condenser_valve_spark_rat_defeated
		),
		"coil_defeated": (
			_lower_deck_forward_pressure_aftershock_condenser_valve_coil_rat_defeated
		),
		"spark_entity_id": _get_enemy_entity_id(spark_rat),
		"coil_entity_id": _get_enemy_entity_id(coil_rat),
		"spark_family_id": _get_enemy_family_id(spark_rat),
		"coil_family_id": _get_enemy_family_id(coil_rat),
		"spark_sprite_frames_path": (
			spark_sprite.sprite_frames.resource_path
			if spark_sprite != null and spark_sprite.sprite_frames != null
			else ""
		),
		"coil_sprite_frames_path": (
			coil_sprite.sprite_frames.resource_path
			if coil_sprite != null and coil_sprite.sprite_frames != null
			else ""
		),
		"spark_animation_frame_counts": _get_sprite_animation_frame_counts(spark_sprite),
		"coil_animation_frame_counts": _get_sprite_animation_frame_counts(coil_sprite),
		"route_label_text": String(route.get("route_label_text", "")),
	}


## Returns deterministic relay-forward hatch diagnostics for tests and MCP probes.
func get_factory_lower_deck_forward_hatch_diagnostics() -> Dictionary:
	return {
		"present": _lower_deck_forward_hatch != null,
		"visible": (
			_lower_deck_forward_hatch.visible
			if _lower_deck_forward_hatch != null
			else false
		),
		"available": _is_lower_deck_forward_hatch_available(),
		"opened": _lower_deck_forward_hatch_opened,
		"cache_claimed": _lower_deck_relay_forward_reward_cache_claimed,
		"hatch_id": _get_lower_deck_forward_hatch_id(),
		"prompt_text": _get_lower_deck_forward_hatch_prompt_text(),
		"texture_path": _get_lower_deck_forward_hatch_visual_texture_path(),
		"position": _get_lower_deck_forward_hatch_position(),
		"collision_blocking": _is_lower_deck_forward_hatch_collision_blocking(),
	}


## Returns deterministic forward conduit ambush diagnostics for tests and MCP probes.
func get_factory_lower_deck_forward_conduit_diagnostics() -> Dictionary:
	var sprite: AnimatedSprite2D = (
		_lower_deck_forward_conduit_spark_rat.get_node_or_null("Sprite") as AnimatedSprite2D
		if _lower_deck_forward_conduit_spark_rat != null
		else null
	)
	return {
		"present": (
			_lower_deck_forward_conduit_spark_rat != null
			and _lower_deck_forward_conduit_steam_hazard != null
		),
		"available": _is_lower_deck_forward_conduit_available(),
		"active": _is_lower_deck_forward_conduit_active(),
		"defeated": _lower_deck_forward_conduit_defeated,
		"forward_hatch_opened": _lower_deck_forward_hatch_opened,
		"activation_x": FACTORY_LOWER_DECK_FORWARD_CONDUIT_ACTIVATION_X,
		"enemy_visible": (
			_lower_deck_forward_conduit_spark_rat.visible
			if _lower_deck_forward_conduit_spark_rat != null
			else false
		),
		"enemy_has_target": _does_lower_deck_forward_conduit_have_target(),
		"enemy_physics_enabled": (
			_lower_deck_forward_conduit_spark_rat.is_physics_processing()
			if _lower_deck_forward_conduit_spark_rat != null
			else false
		),
		"enemy_process_enabled": (
			_lower_deck_forward_conduit_spark_rat.is_processing()
			if _lower_deck_forward_conduit_spark_rat != null
			else false
		),
		"entity_id": (
			int(_lower_deck_forward_conduit_spark_rat.call("get_entity_id"))
			if (
				_lower_deck_forward_conduit_spark_rat != null
				and _lower_deck_forward_conduit_spark_rat.has_method("get_entity_id")
			)
			else 0
		),
		"sprite_frames_path": (
			sprite.sprite_frames.resource_path
			if sprite != null and sprite.sprite_frames != null
			else ""
		),
		"animation_frame_counts": _get_sprite_animation_frame_counts(sprite),
		"pacing": _get_lower_deck_forward_conduit_pacing_diagnostics(),
		"hazard_present": _lower_deck_forward_conduit_steam_hazard != null,
		"hazard_active": _is_hazard_contact_active(_lower_deck_forward_conduit_steam_hazard),
		"hazard_visible": (
			_lower_deck_forward_conduit_steam_hazard.visible
			if _lower_deck_forward_conduit_steam_hazard != null
			else false
		),
		"hazard_id": String(_get_hazard_id(_lower_deck_forward_conduit_steam_hazard)),
		"hazard_damage": _get_hazard_damage(_lower_deck_forward_conduit_steam_hazard),
		"hazard_cooldown_sec": _get_hazard_cooldown_sec(
			_lower_deck_forward_conduit_steam_hazard
		),
		"hazard_texture_path": (
			String(_lower_deck_forward_conduit_steam_hazard.call("get_visual_texture_path"))
			if (
				_lower_deck_forward_conduit_steam_hazard != null
				and _lower_deck_forward_conduit_steam_hazard.has_method("get_visual_texture_path")
			)
			else ""
		),
		"enemy_position": (
			_lower_deck_forward_conduit_spark_rat.global_position
			if _lower_deck_forward_conduit_spark_rat != null
			else Vector2.ZERO
		),
		"hazard_position": (
			_lower_deck_forward_conduit_steam_hazard.global_position
			if _lower_deck_forward_conduit_steam_hazard != null
			else Vector2.ZERO
		),
	}


## Returns deterministic forward conduit clear feedback diagnostics for tests and MCP probes.
func get_factory_lower_deck_forward_conduit_clear_feedback_diagnostics() -> Dictionary:
	return {
		"present": _lower_deck_forward_conduit_clear_burst != null,
		"visible": (
			_lower_deck_forward_conduit_clear_burst.visible
			if _lower_deck_forward_conduit_clear_burst != null
			else false
		),
		"played": _lower_deck_forward_conduit_clear_feedback_played,
		"spawn_count": _lower_deck_forward_conduit_clear_feedback_spawn_count,
		"texture_path": _get_lower_deck_forward_conduit_clear_feedback_texture_path(),
		"last_position": _last_lower_deck_forward_conduit_clear_feedback_position,
		"asset_source": "image_generation",
		"vfx_role": "forward_conduit_clear_feedback",
		"entity_id": FACTORY_LOWER_DECK_FORWARD_CONDUIT_ENTITY_ID,
		"hazard_id": String(_get_hazard_id(_lower_deck_forward_conduit_steam_hazard)),
	}


## Returns deterministic forward pressure traversal diagnostics for tests and MCP probes.
func get_factory_lower_deck_forward_pressure_traverse_diagnostics() -> Dictionary:
	return {
		"present": _lower_deck_forward_pressure_vent != null,
		"available": _is_lower_deck_forward_pressure_traverse_available(),
		"visible": (
			_lower_deck_forward_pressure_vent.visible
			if _lower_deck_forward_pressure_vent != null
			else false
		),
		"active": _lower_deck_forward_pressure_traverse_active,
		"crossed": _lower_deck_forward_pressure_traverse_crossed,
		"phase": String(_get_lower_deck_forward_pressure_phase()),
		"elapsed_sec": _lower_deck_forward_pressure_traverse_elapsed_sec,
		"initial_grace_sec": FACTORY_LOWER_DECK_FORWARD_PRESSURE_INITIAL_GRACE_SEC,
		"warning_sec": FACTORY_LOWER_DECK_FORWARD_PRESSURE_WARNING_SEC,
		"active_sec": FACTORY_LOWER_DECK_FORWARD_PRESSURE_ACTIVE_SEC,
		"safe_sec": FACTORY_LOWER_DECK_FORWARD_PRESSURE_SAFE_SEC,
		"activation_x": FACTORY_LOWER_DECK_FORWARD_PRESSURE_ACTIVATION_X,
		"exit_x": FACTORY_LOWER_DECK_FORWARD_PRESSURE_EXIT_X,
		"hazard_present": _lower_deck_forward_pressure_vent != null,
		"hazard_contact_active": _is_hazard_contact_active(_lower_deck_forward_pressure_vent),
		"hazard_visible": (
			_lower_deck_forward_pressure_vent.visible
			if _lower_deck_forward_pressure_vent != null
			else false
		),
		"hazard_id": String(_get_hazard_id(_lower_deck_forward_pressure_vent)),
		"hazard_damage": _get_hazard_damage(_lower_deck_forward_pressure_vent),
		"hazard_cooldown_sec": _get_hazard_cooldown_sec(_lower_deck_forward_pressure_vent),
		"hazard_texture_path": (
			String(_lower_deck_forward_pressure_vent.call("get_visual_texture_path"))
			if (
				_lower_deck_forward_pressure_vent != null
				and _lower_deck_forward_pressure_vent.has_method("get_visual_texture_path")
			)
			else ""
		),
		"hazard_position": (
			_lower_deck_forward_pressure_vent.global_position
			if _lower_deck_forward_pressure_vent != null
			else Vector2.ZERO
		),
	}


## Returns deterministic forward pressure counter-ambush diagnostics for tests and MCP probes.
func get_factory_lower_deck_forward_pressure_counter_ambush_diagnostics() -> Dictionary:
	var sprite: AnimatedSprite2D = (
		_lower_deck_forward_counter_spark_rat.get_node_or_null("Sprite") as AnimatedSprite2D
		if _lower_deck_forward_counter_spark_rat != null
		else null
	)
	return {
		"present": (
			_lower_deck_forward_counter_spark_rat != null
			and _lower_deck_forward_counter_pressure_vent != null
		),
		"available": _is_lower_deck_forward_pressure_counter_ambush_available(),
		"active": _is_lower_deck_forward_pressure_counter_ambush_active(),
		"defeated": _lower_deck_forward_pressure_counter_ambush_defeated,
		"pressure_traverse_crossed": _lower_deck_forward_pressure_traverse_crossed,
		"activation_x": FACTORY_LOWER_DECK_FORWARD_COUNTER_AMBUSH_ACTIVATION_X,
		"enemy_visible": (
			_lower_deck_forward_counter_spark_rat.visible
			if _lower_deck_forward_counter_spark_rat != null
			else false
		),
		"enemy_has_target": _does_lower_deck_forward_counter_ambush_have_target(),
		"enemy_physics_enabled": (
			_lower_deck_forward_counter_spark_rat.is_physics_processing()
			if _lower_deck_forward_counter_spark_rat != null
			else false
		),
		"enemy_process_enabled": (
			_lower_deck_forward_counter_spark_rat.is_processing()
			if _lower_deck_forward_counter_spark_rat != null
			else false
		),
		"entity_id": (
			int(_lower_deck_forward_counter_spark_rat.call("get_entity_id"))
			if (
				_lower_deck_forward_counter_spark_rat != null
				and _lower_deck_forward_counter_spark_rat.has_method("get_entity_id")
			)
			else 0
		),
		"sprite_frames_path": (
			sprite.sprite_frames.resource_path
			if sprite != null and sprite.sprite_frames != null
			else ""
		),
		"animation_frame_counts": _get_sprite_animation_frame_counts(sprite),
		"pacing": _get_lower_deck_forward_counter_ambush_pacing_diagnostics(),
		"hazard_present": _lower_deck_forward_counter_pressure_vent != null,
		"hazard_active": _is_hazard_contact_active(_lower_deck_forward_counter_pressure_vent),
		"hazard_visible": (
			_lower_deck_forward_counter_pressure_vent.visible
			if _lower_deck_forward_counter_pressure_vent != null
			else false
		),
		"hazard_id": String(_get_hazard_id(_lower_deck_forward_counter_pressure_vent)),
		"hazard_damage": _get_hazard_damage(_lower_deck_forward_counter_pressure_vent),
		"hazard_cooldown_sec": _get_hazard_cooldown_sec(
			_lower_deck_forward_counter_pressure_vent
		),
		"hazard_texture_path": (
			String(_lower_deck_forward_counter_pressure_vent.call("get_visual_texture_path"))
			if (
				_lower_deck_forward_counter_pressure_vent != null
				and _lower_deck_forward_counter_pressure_vent.has_method(
					"get_visual_texture_path"
				)
			)
			else ""
		),
		"enemy_position": (
			_lower_deck_forward_counter_spark_rat.global_position
			if _lower_deck_forward_counter_spark_rat != null
			else Vector2.ZERO
		),
		"hazard_position": (
			_lower_deck_forward_counter_pressure_vent.global_position
			if _lower_deck_forward_counter_pressure_vent != null
			else Vector2.ZERO
		),
	}


## Returns deterministic forward pressure exit guard diagnostics for tests and MCP probes.
func get_factory_lower_deck_forward_pressure_exit_guard_diagnostics() -> Dictionary:
	var sprite: AnimatedSprite2D = (
		_lower_deck_forward_exit_guard_spark_rat.get_node_or_null("Sprite") as AnimatedSprite2D
		if _lower_deck_forward_exit_guard_spark_rat != null
		else null
	)
	return {
		"present": (
			_lower_deck_forward_exit_guard_spark_rat != null
			and _lower_deck_forward_exit_guard_pressure_vent != null
		),
		"available": _is_lower_deck_forward_pressure_exit_guard_available(),
		"active": _is_lower_deck_forward_pressure_exit_guard_active(),
		"defeated": _lower_deck_forward_pressure_exit_guard_defeated,
		"reward_cache_claimed": _lower_deck_forward_pressure_reward_cache_claimed,
		"activation_x": FACTORY_LOWER_DECK_FORWARD_EXIT_GUARD_ACTIVATION_X,
		"enemy_visible": (
			_lower_deck_forward_exit_guard_spark_rat.visible
			if _lower_deck_forward_exit_guard_spark_rat != null
			else false
		),
		"enemy_has_target": _does_lower_deck_forward_exit_guard_have_target(),
		"enemy_physics_enabled": (
			_lower_deck_forward_exit_guard_spark_rat.is_physics_processing()
			if _lower_deck_forward_exit_guard_spark_rat != null
			else false
		),
		"enemy_process_enabled": (
			_lower_deck_forward_exit_guard_spark_rat.is_processing()
			if _lower_deck_forward_exit_guard_spark_rat != null
			else false
		),
		"entity_id": (
			int(_lower_deck_forward_exit_guard_spark_rat.call("get_entity_id"))
			if (
				_lower_deck_forward_exit_guard_spark_rat != null
				and _lower_deck_forward_exit_guard_spark_rat.has_method("get_entity_id")
			)
			else 0
		),
		"sprite_frames_path": (
			sprite.sprite_frames.resource_path
			if sprite != null and sprite.sprite_frames != null
			else ""
		),
		"animation_frame_counts": _get_sprite_animation_frame_counts(sprite),
		"pacing": _get_lower_deck_forward_exit_guard_pacing_diagnostics(),
		"hazard_present": _lower_deck_forward_exit_guard_pressure_vent != null,
		"hazard_active": _is_hazard_contact_active(_lower_deck_forward_exit_guard_pressure_vent),
		"hazard_visible": (
			_lower_deck_forward_exit_guard_pressure_vent.visible
			if _lower_deck_forward_exit_guard_pressure_vent != null
			else false
		),
		"hazard_id": String(_get_hazard_id(_lower_deck_forward_exit_guard_pressure_vent)),
		"hazard_damage": _get_hazard_damage(_lower_deck_forward_exit_guard_pressure_vent),
		"hazard_cooldown_sec": _get_hazard_cooldown_sec(
			_lower_deck_forward_exit_guard_pressure_vent
		),
		"hazard_texture_path": (
			String(_lower_deck_forward_exit_guard_pressure_vent.call("get_visual_texture_path"))
			if (
				_lower_deck_forward_exit_guard_pressure_vent != null
				and _lower_deck_forward_exit_guard_pressure_vent.has_method(
					"get_visual_texture_path"
				)
			)
			else ""
		),
		"enemy_position": (
			_lower_deck_forward_exit_guard_spark_rat.global_position
			if _lower_deck_forward_exit_guard_spark_rat != null
			else Vector2.ZERO
		),
		"hazard_position": (
			_lower_deck_forward_exit_guard_pressure_vent.global_position
			if _lower_deck_forward_exit_guard_pressure_vent != null
			else Vector2.ZERO
		),
	}


## Returns deterministic deep bulkhead diagnostics for tests and MCP probes.
func get_factory_lower_deck_deep_bulkhead_diagnostics() -> Dictionary:
	var sprite: AnimatedSprite2D = (
		_lower_deck_deep_bulkhead_spark_rat.get_node_or_null("Sprite") as AnimatedSprite2D
		if _lower_deck_deep_bulkhead_spark_rat != null
		else null
	)
	return {
		"present": (
			_lower_deck_deep_bulkhead_spark_rat != null
			and _lower_deck_deep_bulkhead != null
		),
		"available": _is_lower_deck_deep_bulkhead_guard_available(),
		"guard_active": _is_lower_deck_deep_bulkhead_guard_active(),
		"guard_defeated": _lower_deck_deep_bulkhead_guard_defeated,
		"bulkhead_available": _is_lower_deck_deep_bulkhead_available(),
		"bulkhead_opened": _lower_deck_deep_bulkhead_opened,
		"steam_sluice_defeated": _lower_deck_steam_sluice_defeated,
		"activation_x": FACTORY_LOWER_DECK_DEEP_BULKHEAD_ACTIVATION_X,
		"guard_visible": (
			_lower_deck_deep_bulkhead_spark_rat.visible
			if _lower_deck_deep_bulkhead_spark_rat != null
			else false
		),
		"guard_has_target": _does_lower_deck_deep_bulkhead_guard_have_target(),
		"guard_physics_enabled": (
			_lower_deck_deep_bulkhead_spark_rat.is_physics_processing()
			if _lower_deck_deep_bulkhead_spark_rat != null
			else false
		),
		"guard_process_enabled": (
			_lower_deck_deep_bulkhead_spark_rat.is_processing()
			if _lower_deck_deep_bulkhead_spark_rat != null
			else false
		),
		"guard_entity_id": (
			int(_lower_deck_deep_bulkhead_spark_rat.call("get_entity_id"))
			if (
				_lower_deck_deep_bulkhead_spark_rat != null
				and _lower_deck_deep_bulkhead_spark_rat.has_method("get_entity_id")
			)
			else 0
		),
		"guard_sprite_frames_path": (
			sprite.sprite_frames.resource_path
			if sprite != null and sprite.sprite_frames != null
			else ""
		),
		"guard_animation_frame_counts": _get_sprite_animation_frame_counts(sprite),
		"pacing": _get_lower_deck_deep_bulkhead_guard_pacing_diagnostics(),
		"bulkhead_id": _get_lower_deck_deep_bulkhead_id(),
		"bulkhead_visible": (
			_lower_deck_deep_bulkhead.visible
			if _lower_deck_deep_bulkhead != null
			else false
		),
		"bulkhead_prompt_text": _get_lower_deck_deep_bulkhead_prompt_text(),
		"bulkhead_texture_path": _get_lower_deck_deep_bulkhead_visual_texture_path(),
		"bulkhead_position": _get_lower_deck_deep_bulkhead_position(),
		"bulkhead_collision_blocking": _is_lower_deck_deep_bulkhead_collision_blocking(),
		"guard_position": (
			_lower_deck_deep_bulkhead_spark_rat.global_position
			if _lower_deck_deep_bulkhead_spark_rat != null
			else Vector2.ZERO
		),
	}


## Returns deterministic breach corridor ambush diagnostics for tests and MCP probes.
func get_factory_lower_deck_breach_corridor_diagnostics() -> Dictionary:
	var front_sprite: AnimatedSprite2D = (
		_lower_deck_breach_front_spark_rat.get_node_or_null("Sprite") as AnimatedSprite2D
		if _lower_deck_breach_front_spark_rat != null
		else null
	)
	var rear_sprite: AnimatedSprite2D = (
		_lower_deck_breach_rear_spark_rat.get_node_or_null("Sprite") as AnimatedSprite2D
		if _lower_deck_breach_rear_spark_rat != null
		else null
	)
	return {
		"present": (
			_lower_deck_breach_front_spark_rat != null
			and _lower_deck_breach_rear_spark_rat != null
			and _lower_deck_breach_steam_hazard != null
		),
		"available": _is_lower_deck_breach_corridor_available(),
		"active": _is_lower_deck_breach_corridor_active(),
		"secured": _is_lower_deck_breach_corridor_secured(),
		"deep_bulkhead_opened": _lower_deck_deep_bulkhead_opened,
		"activation_x": FACTORY_LOWER_DECK_BREACH_CORRIDOR_ACTIVATION_X,
		"midpoint_x": FACTORY_LOWER_DECK_BREACH_PINCER_MIDPOINT_X,
		"front_defeated": _lower_deck_breach_front_guard_defeated,
		"front_visible": (
			_lower_deck_breach_front_spark_rat.visible
			if _lower_deck_breach_front_spark_rat != null
			else false
		),
		"front_has_target": _does_lower_deck_breach_front_have_target(),
		"front_physics_enabled": (
			_lower_deck_breach_front_spark_rat.is_physics_processing()
			if _lower_deck_breach_front_spark_rat != null
			else false
		),
		"front_process_enabled": (
			_lower_deck_breach_front_spark_rat.is_processing()
			if _lower_deck_breach_front_spark_rat != null
			else false
		),
		"front_entity_id": (
			int(_lower_deck_breach_front_spark_rat.call("get_entity_id"))
			if (
				_lower_deck_breach_front_spark_rat != null
				and _lower_deck_breach_front_spark_rat.has_method("get_entity_id")
			)
			else 0
		),
		"front_sprite_frames_path": (
			front_sprite.sprite_frames.resource_path
			if front_sprite != null and front_sprite.sprite_frames != null
			else ""
		),
		"front_animation_frame_counts": _get_sprite_animation_frame_counts(front_sprite),
		"front_pacing": _get_lower_deck_breach_front_pacing_diagnostics(),
		"front_position": (
			_lower_deck_breach_front_spark_rat.global_position
			if _lower_deck_breach_front_spark_rat != null
			else Vector2.ZERO
		),
		"rear_activated": _lower_deck_breach_rear_ambusher_activated,
		"rear_defeated": _lower_deck_breach_rear_ambusher_defeated,
		"rear_visible": (
			_lower_deck_breach_rear_spark_rat.visible
			if _lower_deck_breach_rear_spark_rat != null
			else false
		),
		"rear_has_target": _does_lower_deck_breach_rear_have_target(),
		"rear_physics_enabled": (
			_lower_deck_breach_rear_spark_rat.is_physics_processing()
			if _lower_deck_breach_rear_spark_rat != null
			else false
		),
		"rear_process_enabled": (
			_lower_deck_breach_rear_spark_rat.is_processing()
			if _lower_deck_breach_rear_spark_rat != null
			else false
		),
		"rear_entity_id": (
			int(_lower_deck_breach_rear_spark_rat.call("get_entity_id"))
			if (
				_lower_deck_breach_rear_spark_rat != null
				and _lower_deck_breach_rear_spark_rat.has_method("get_entity_id")
			)
			else 0
		),
		"rear_sprite_frames_path": (
			rear_sprite.sprite_frames.resource_path
			if rear_sprite != null and rear_sprite.sprite_frames != null
			else ""
		),
		"rear_animation_frame_counts": _get_sprite_animation_frame_counts(rear_sprite),
		"rear_pacing": _get_lower_deck_breach_rear_pacing_diagnostics(),
		"rear_position": (
			_lower_deck_breach_rear_spark_rat.global_position
			if _lower_deck_breach_rear_spark_rat != null
			else Vector2.ZERO
		),
		"hazard_present": _lower_deck_breach_steam_hazard != null,
		"hazard_active": _is_hazard_contact_active(_lower_deck_breach_steam_hazard),
		"hazard_visible": (
			_lower_deck_breach_steam_hazard.visible
			if _lower_deck_breach_steam_hazard != null
			else false
		),
		"hazard_id": String(_get_hazard_id(_lower_deck_breach_steam_hazard)),
		"hazard_texture_path": (
			String(_lower_deck_breach_steam_hazard.call("get_visual_texture_path"))
			if (
				_lower_deck_breach_steam_hazard != null
				and _lower_deck_breach_steam_hazard.has_method("get_visual_texture_path")
			)
			else ""
		),
		"post_bulkhead_background_visible": (
			_post_bulkhead_background.visible
			if _post_bulkhead_background != null
			else false
		),
		"post_bulkhead_background_texture_path": _get_post_bulkhead_background_texture_path(),
	}


## Returns deterministic post-breach relay savepoint diagnostics for tests and MCP probes.
func get_factory_lower_deck_breach_relay_diagnostics() -> Dictionary:
	var interaction_area := (
		_lower_deck_breach_relay.get_node_or_null("InteractionArea") as Area2D
		if _lower_deck_breach_relay != null
		else null
	)
	var collision_shape := (
		_lower_deck_breach_relay.get_node_or_null("InteractionArea/CollisionShape2D")
		as CollisionShape2D
		if _lower_deck_breach_relay != null
		else null
	)
	var route: Dictionary = get_factory_route_objective_diagnostics()
	var activation_vfx_snapshot: Dictionary = (
		_get_lower_deck_breach_relay_activation_vfx_snapshot()
	)
	return {
		"present": _lower_deck_breach_relay != null,
		"available": _is_lower_deck_breach_relay_available(),
		"visible": (
			_lower_deck_breach_relay.visible
			if _lower_deck_breach_relay != null
			else false
		),
		"activated": _lower_deck_breach_relay_activated,
		"breach_secured": _is_lower_deck_breach_corridor_secured(),
		"savepoint_id": _get_lower_deck_breach_relay_savepoint_id(),
		"scene_id": _get_lower_deck_breach_relay_scene_id(),
		"spawn_point": _get_lower_deck_breach_relay_spawn_point(),
		"display_name": _get_lower_deck_breach_relay_display_name(),
		"prompt_text": _get_lower_deck_breach_relay_prompt_text(),
		"texture_path": _get_lower_deck_breach_relay_texture_path(),
		"interaction_monitoring": interaction_area.monitoring if interaction_area != null else false,
		"interaction_monitorable": interaction_area.monitorable if interaction_area != null else false,
		"collision_disabled": collision_shape.disabled if collision_shape != null else true,
		"position": (
			(_lower_deck_breach_relay as Node2D).global_position
			if _lower_deck_breach_relay != null and _lower_deck_breach_relay is Node2D
			else Vector2.ZERO
		),
		"last_savepoint": _last_return_checkpoint.duplicate(true),
		"route_label_text": String(route.get("route_label_text", "")),
		"activation_feedback_texture_path": String(activation_vfx_snapshot.get(
			"texture_path",
			""
			)),
			"activation_feedback_active": int(activation_vfx_snapshot.get("active_count", 0)) > 0,
			"activation_feedback_played": bool(activation_vfx_snapshot.get("played", false)),
			"activation_feedback_spawn_count": int(activation_vfx_snapshot.get("spawn_count", 0)),
			"activation_audio_requested": _lower_deck_breach_relay_activation_audio_request_count > 0,
			"activation_audio_request_count": _lower_deck_breach_relay_activation_audio_request_count,
			"activation_audio_event": _lower_deck_breach_relay_activation_audio_event.duplicate(true),
		}


## Returns deterministic forward-pressure exit relay savepoint diagnostics for tests and MCP probes.
func get_factory_lower_deck_forward_pressure_exit_relay_diagnostics() -> Dictionary:
	var interaction_area := (
		_lower_deck_forward_pressure_exit_relay.get_node_or_null("InteractionArea") as Area2D
		if _lower_deck_forward_pressure_exit_relay != null
		else null
	)
	var collision_shape := (
		_lower_deck_forward_pressure_exit_relay.get_node_or_null(
			"InteractionArea/CollisionShape2D"
		) as CollisionShape2D
		if _lower_deck_forward_pressure_exit_relay != null
		else null
	)
	var route: Dictionary = get_factory_route_objective_diagnostics()
	return {
		"present": _lower_deck_forward_pressure_exit_relay != null,
		"available": _is_lower_deck_forward_pressure_exit_relay_available(),
		"visible": (
			_lower_deck_forward_pressure_exit_relay.visible
			if _lower_deck_forward_pressure_exit_relay != null
			else false
		),
		"activated": _lower_deck_forward_pressure_exit_relay_activated,
		"exit_guard_defeated": _lower_deck_forward_pressure_exit_guard_defeated,
		"savepoint_id": _get_lower_deck_forward_pressure_exit_relay_savepoint_id(),
		"scene_id": _get_lower_deck_forward_pressure_exit_relay_scene_id(),
		"spawn_point": _get_lower_deck_forward_pressure_exit_relay_spawn_point(),
		"display_name": _get_lower_deck_forward_pressure_exit_relay_display_name(),
		"prompt_text": _get_lower_deck_forward_pressure_exit_relay_prompt_text(),
		"texture_path": _get_lower_deck_forward_pressure_exit_relay_texture_path(),
		"interaction_monitoring": interaction_area.monitoring if interaction_area != null else false,
		"interaction_monitorable": interaction_area.monitorable if interaction_area != null else false,
		"collision_disabled": collision_shape.disabled if collision_shape != null else true,
		"position": (
			(_lower_deck_forward_pressure_exit_relay as Node2D).global_position
			if (
				_lower_deck_forward_pressure_exit_relay != null
				and _lower_deck_forward_pressure_exit_relay is Node2D
			)
			else Vector2.ZERO
		),
		"last_savepoint": _last_return_checkpoint.duplicate(true),
		"route_label_text": String(route.get("route_label_text", "")),
	}


## Returns deterministic forward-pressure exit gate diagnostics for tests and MCP probes.
func get_factory_lower_deck_forward_pressure_exit_gate_diagnostics() -> Dictionary:
	var interaction_area := (
		_lower_deck_forward_pressure_exit_gate.get_node_or_null("InteractionArea")
		as Area2D
		if _lower_deck_forward_pressure_exit_gate != null
		else null
	)
	var collision_shape := _get_lower_deck_forward_pressure_exit_gate_collision_shape()
	var route: Dictionary = get_factory_route_objective_diagnostics()
	return {
		"present": _lower_deck_forward_pressure_exit_gate != null,
		"available": _is_lower_deck_forward_pressure_exit_gate_available(),
		"visible": (
			_lower_deck_forward_pressure_exit_gate.visible
			if _lower_deck_forward_pressure_exit_gate != null
			else false
		),
		"opened": _lower_deck_forward_pressure_exit_gate_opened,
		"exit_relay_activated": _lower_deck_forward_pressure_exit_relay_activated,
		"gate_id": _get_lower_deck_forward_pressure_exit_gate_id(),
		"prompt_text": _get_lower_deck_forward_pressure_exit_gate_prompt_text(),
		"texture_path": _get_lower_deck_forward_pressure_exit_gate_texture_path(),
		"interaction_monitoring": interaction_area.monitoring if interaction_area != null else false,
		"interaction_monitorable": interaction_area.monitorable if interaction_area != null else false,
		"collision_disabled": collision_shape.disabled if collision_shape != null else true,
		"collision_blocking": _is_lower_deck_forward_pressure_exit_gate_collision_blocking(),
		"position": _get_lower_deck_forward_pressure_exit_gate_position(),
		"route_label_text": String(route.get("route_label_text", "")),
	}


## Returns deterministic aftershock condenser savepoint diagnostics for tests and MCP probes.
func get_factory_lower_deck_forward_pressure_aftershock_condenser_savepoint_diagnostics(
) -> Dictionary:
	var interaction_area := (
		_lower_deck_forward_pressure_aftershock_condenser_savepoint.get_node_or_null(
			"InteractionArea"
		) as Area2D
		if _lower_deck_forward_pressure_aftershock_condenser_savepoint != null
		else null
	)
	var collision_shape := (
		_lower_deck_forward_pressure_aftershock_condenser_savepoint.get_node_or_null(
			"InteractionArea/CollisionShape2D"
		) as CollisionShape2D
		if _lower_deck_forward_pressure_aftershock_condenser_savepoint != null
		else null
	)
	var route: Dictionary = get_factory_route_objective_diagnostics()
	return {
		"present": _lower_deck_forward_pressure_aftershock_condenser_savepoint != null,
		"available": _is_lower_deck_forward_pressure_aftershock_condenser_savepoint_available(),
		"visible": (
			_lower_deck_forward_pressure_aftershock_condenser_savepoint.visible
			if _lower_deck_forward_pressure_aftershock_condenser_savepoint != null
			else false
		),
		"activated": _lower_deck_forward_pressure_aftershock_condenser_savepoint_activated,
		"condenser_landing_secured": (
			_is_lower_deck_forward_pressure_aftershock_condenser_valve_cleared()
		),
		"savepoint_id": (
			_get_lower_deck_forward_pressure_aftershock_condenser_savepoint_id()
		),
		"scene_id": (
			_get_lower_deck_forward_pressure_aftershock_condenser_savepoint_scene_id()
		),
		"spawn_point": (
			_get_lower_deck_forward_pressure_aftershock_condenser_savepoint_spawn_point()
		),
		"display_name": (
			_get_lower_deck_forward_pressure_aftershock_condenser_savepoint_display_name()
		),
		"prompt_text": (
			_get_lower_deck_forward_pressure_aftershock_condenser_savepoint_prompt_text()
		),
		"texture_path": (
			_get_lower_deck_forward_pressure_aftershock_condenser_savepoint_texture_path()
		),
		"interaction_monitoring": interaction_area.monitoring if interaction_area != null else false,
		"interaction_monitorable": interaction_area.monitorable if interaction_area != null else false,
		"collision_disabled": collision_shape.disabled if collision_shape != null else true,
		"position": (
			(_lower_deck_forward_pressure_aftershock_condenser_savepoint as Node2D).global_position
			if (
				_lower_deck_forward_pressure_aftershock_condenser_savepoint != null
				and _lower_deck_forward_pressure_aftershock_condenser_savepoint is Node2D
			)
			else Vector2.ZERO
		),
		"last_savepoint": _last_return_checkpoint.duplicate(true),
		"route_label_text": String(route.get("route_label_text", "")),
	}


## Returns deterministic aftershock condenser outlet diagnostics for tests and MCP probes.
func get_factory_lower_deck_forward_pressure_aftershock_condenser_outlet_diagnostics(
) -> Dictionary:
	var route: Dictionary = get_factory_route_objective_diagnostics()
	var outlet_present: bool = _lower_deck_forward_pressure_aftershock_condenser_outlet != null
	var hazard_present: bool = (
		_lower_deck_forward_pressure_aftershock_condenser_outlet_vent != null
	)
	var ground_shape := (
		get_node_or_null("Ground/CollisionShape2D") as CollisionShape2D
	)
	var ground_rect := (
		ground_shape.shape as RectangleShape2D
		if ground_shape != null and ground_shape.shape is RectangleShape2D
		else null
	)
	var right_wall := get_node_or_null("RightWall") as Node2D
	var camera := get_node_or_null("Player/Camera2D") as Camera2D
	return {
		"present": outlet_present and hazard_present,
		"available": _is_lower_deck_forward_pressure_aftershock_condenser_outlet_available(),
		"active": _is_lower_deck_forward_pressure_aftershock_condenser_outlet_active(),
		"crossed": _lower_deck_forward_pressure_aftershock_condenser_outlet_crossed,
		"visible": (
			_lower_deck_forward_pressure_aftershock_condenser_outlet.visible
			if outlet_present
			else false
		),
		"savepoint_activated": (
			_lower_deck_forward_pressure_aftershock_condenser_savepoint_activated
		),
		"node_name": (
			String(_lower_deck_forward_pressure_aftershock_condenser_outlet.name)
			if outlet_present
			else ""
		),
		"hazard_node_name": (
			String(_lower_deck_forward_pressure_aftershock_condenser_outlet_vent.name)
			if hazard_present
			else ""
		),
		"outlet_texture_path": (
			_lower_deck_forward_pressure_aftershock_condenser_outlet.texture.resource_path
			if (
				outlet_present
				and _lower_deck_forward_pressure_aftershock_condenser_outlet.texture != null
			)
			else ""
		),
		"hazard_visible": (
			_lower_deck_forward_pressure_aftershock_condenser_outlet_vent.visible
			if hazard_present
			else false
		),
		"hazard_contact_active": _is_hazard_contact_active(
			_lower_deck_forward_pressure_aftershock_condenser_outlet_vent
		),
		"hazard_id": String(_get_hazard_id(
			_lower_deck_forward_pressure_aftershock_condenser_outlet_vent
		)),
		"hazard_damage": _get_hazard_damage(
			_lower_deck_forward_pressure_aftershock_condenser_outlet_vent
		),
		"hazard_cooldown_sec": _get_hazard_cooldown_sec(
			_lower_deck_forward_pressure_aftershock_condenser_outlet_vent
		),
		"hazard_texture_path": (
			String(_lower_deck_forward_pressure_aftershock_condenser_outlet_vent.call(
				"get_visual_texture_path"
			))
			if (
				hazard_present
				and _lower_deck_forward_pressure_aftershock_condenser_outlet_vent.has_method(
					"get_visual_texture_path"
				)
			)
			else ""
		),
		"phase": String(_get_condenser_outlet_phase()),
		"initial_grace_sec": FACTORY_LOWER_DECK_FORWARD_PRESSURE_INITIAL_GRACE_SEC,
		"warning_sec": FACTORY_LOWER_DECK_FORWARD_PRESSURE_WARNING_SEC,
		"active_sec": FACTORY_LOWER_DECK_FORWARD_PRESSURE_ACTIVE_SEC,
		"safe_sec": FACTORY_LOWER_DECK_FORWARD_PRESSURE_SAFE_SEC,
		"activation_x": (
			FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_CONDENSER_OUTLET_ACTIVATION_X
		),
		"exit_x": FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_CONDENSER_OUTLET_EXIT_X,
		"ground_width": ground_rect.size.x if ground_rect != null else 0.0,
		"right_wall_x": right_wall.global_position.x if right_wall != null else 0.0,
		"camera_limit_right": camera.limit_right if camera != null else 0,
		"route_label_text": String(route.get("route_label_text", "")),
	}


## Returns deterministic outlet clamp ambush diagnostics for tests and MCP probes.
func get_factory_lower_deck_forward_pressure_aftershock_condenser_outlet_clamp_ambush_diagnostics(
) -> Dictionary:
	var route: Dictionary = get_factory_route_objective_diagnostics()
	var clamp_present: bool = (
		_lower_deck_forward_pressure_aftershock_condenser_outlet_clamp != null
	)
	var spark_rat: Node2D = _get_valid_node2d(
		_lower_deck_forward_pressure_aftershock_condenser_outlet_clamp_spark_rat
	)
	var spark_sprite: AnimatedSprite2D = (
		spark_rat.get_node_or_null("Sprite") as AnimatedSprite2D
		if spark_rat != null
		else null
	)
	var ground_shape := get_node_or_null("Ground/CollisionShape2D") as CollisionShape2D
	var ground_rect := (
		ground_shape.shape as RectangleShape2D
		if ground_shape != null and ground_shape.shape is RectangleShape2D
		else null
	)
	var right_wall := get_node_or_null("RightWall") as Node2D
	var camera := get_node_or_null("Player/Camera2D") as Camera2D
	return {
		"present": clamp_present and spark_rat != null,
		"available": _is_outlet_clamp_ambush_available(),
		"active": _is_outlet_clamp_ambush_active(),
		"cleared": _is_outlet_clamp_ambush_cleared(),
		"outlet_crossed": _lower_deck_forward_pressure_aftershock_condenser_outlet_crossed,
		"visible": (
			_lower_deck_forward_pressure_aftershock_condenser_outlet_clamp.visible
			if clamp_present
			else false
		),
		"node_name": (
			String(_lower_deck_forward_pressure_aftershock_condenser_outlet_clamp.name)
			if clamp_present
			else ""
		),
		"texture_path": (
			_lower_deck_forward_pressure_aftershock_condenser_outlet_clamp.texture.resource_path
			if (
				clamp_present
				and _lower_deck_forward_pressure_aftershock_condenser_outlet_clamp.texture != null
			)
			else ""
		),
		"activation_x": (
			FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_CONDENSER_OUTLET_CLAMP_ACTIVATION_X
		),
		"ground_width": ground_rect.size.x if ground_rect != null else 0.0,
		"right_wall_x": right_wall.global_position.x if right_wall != null else 0.0,
		"camera_limit_right": camera.limit_right if camera != null else 0,
		"spark_node_name": String(spark_rat.name) if spark_rat != null else "",
		"spark_visible": spark_rat.visible if spark_rat != null else false,
		"spark_has_target": _does_outlet_clamp_spark_rat_have_target(),
		"spark_process_enabled": spark_rat.is_processing() if spark_rat != null else false,
		"spark_physics_enabled": (
			spark_rat.is_physics_processing() if spark_rat != null else false
		),
		"spark_defeated": (
			_lower_deck_forward_pressure_aftershock_condenser_outlet_clamp_spark_rat_defeated
		),
		"spark_entity_id": _get_enemy_entity_id(spark_rat),
		"spark_family_id": _get_enemy_family_id(spark_rat),
		"spark_sprite_frames_path": (
			spark_sprite.sprite_frames.resource_path
			if spark_sprite != null and spark_sprite.sprite_frames != null
			else ""
		),
		"spark_animation_frame_counts": _get_sprite_animation_frame_counts(spark_sprite),
		"route_label_text": String(route.get("route_label_text", "")),
	}


## Returns deterministic outlet drip vent traverse diagnostics for tests and MCP probes.
func get_factory_lower_deck_forward_pressure_aftershock_condenser_outlet_drip_vent_diagnostics(
) -> Dictionary:
	var route: Dictionary = get_factory_route_objective_diagnostics()
	var gantry_present: bool = (
		_lower_deck_forward_pressure_aftershock_condenser_drain_gantry != null
	)
	var hazard_present: bool = (
		_lower_deck_forward_pressure_aftershock_condenser_drip_vent != null
	)
	var ground_shape := get_node_or_null("Ground/CollisionShape2D") as CollisionShape2D
	var ground_rect := (
		ground_shape.shape as RectangleShape2D
		if ground_shape != null and ground_shape.shape is RectangleShape2D
		else null
	)
	var right_wall := get_node_or_null("RightWall") as Node2D
	var camera := get_node_or_null("Player/Camera2D") as Camera2D
	return {
		"present": gantry_present and hazard_present,
		"available": _is_outlet_drip_vent_available(),
		"active": _is_outlet_drip_vent_active(),
		"crossed": _lower_deck_forward_pressure_aftershock_condenser_drip_vent_crossed,
		"outlet_clamp_cleared": _is_outlet_clamp_ambush_cleared(),
		"visible": (
			_lower_deck_forward_pressure_aftershock_condenser_drain_gantry.visible
			if gantry_present
			else false
		),
		"node_name": (
			String(_lower_deck_forward_pressure_aftershock_condenser_drain_gantry.name)
			if gantry_present
			else ""
		),
		"hazard_node_name": (
			String(_lower_deck_forward_pressure_aftershock_condenser_drip_vent.name)
			if hazard_present
			else ""
		),
		"drain_gantry_texture_path": (
			_lower_deck_forward_pressure_aftershock_condenser_drain_gantry.texture.resource_path
			if (
				gantry_present
				and _lower_deck_forward_pressure_aftershock_condenser_drain_gantry.texture != null
			)
			else ""
		),
		"hazard_visible": (
			_lower_deck_forward_pressure_aftershock_condenser_drip_vent.visible
			if hazard_present
			else false
		),
		"hazard_contact_active": _is_hazard_contact_active(
			_lower_deck_forward_pressure_aftershock_condenser_drip_vent
		),
		"hazard_id": String(_get_hazard_id(
			_lower_deck_forward_pressure_aftershock_condenser_drip_vent
		)),
		"hazard_damage": _get_hazard_damage(
			_lower_deck_forward_pressure_aftershock_condenser_drip_vent
		),
		"hazard_cooldown_sec": _get_hazard_cooldown_sec(
			_lower_deck_forward_pressure_aftershock_condenser_drip_vent
		),
		"hazard_texture_path": (
			String(_lower_deck_forward_pressure_aftershock_condenser_drip_vent.call(
				"get_visual_texture_path"
			))
			if (
				hazard_present
				and _lower_deck_forward_pressure_aftershock_condenser_drip_vent.has_method(
					"get_visual_texture_path"
				)
			)
			else ""
		),
		"phase": String(_get_outlet_drip_vent_phase()),
		"initial_grace_sec": FACTORY_LOWER_DECK_FORWARD_PRESSURE_INITIAL_GRACE_SEC,
		"warning_sec": FACTORY_LOWER_DECK_FORWARD_PRESSURE_WARNING_SEC,
		"active_sec": FACTORY_LOWER_DECK_FORWARD_PRESSURE_ACTIVE_SEC,
		"safe_sec": FACTORY_LOWER_DECK_FORWARD_PRESSURE_SAFE_SEC,
		"activation_x": (
			FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_CONDENSER_DRIP_VENT_ACTIVATION_X
		),
		"exit_x": FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_CONDENSER_DRIP_VENT_EXIT_X,
		"ground_width": ground_rect.size.x if ground_rect != null else 0.0,
		"right_wall_x": right_wall.global_position.x if right_wall != null else 0.0,
		"camera_limit_right": camera.limit_right if camera != null else 0,
		"route_label_text": String(route.get("route_label_text", "")),
	}


## Returns deterministic overflow pump skirmish diagnostics for tests and MCP probes.
func get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_diagnostics(
) -> Dictionary:
	var route: Dictionary = get_factory_route_objective_diagnostics()
	var pump_present: bool = (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump != null
	)
	var coil_rat: Node2D = _get_valid_node2d(
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_coil_rat
	)
	var coil_sprite: AnimatedSprite2D = (
		coil_rat.get_node_or_null("Sprite") as AnimatedSprite2D
		if coil_rat != null
		else null
	)
	var ground_shape := get_node_or_null("Ground/CollisionShape2D") as CollisionShape2D
	var ground_rect := (
		ground_shape.shape as RectangleShape2D
		if ground_shape != null and ground_shape.shape is RectangleShape2D
		else null
	)
	var right_wall := get_node_or_null("RightWall") as Node2D
	var camera := get_node_or_null("Player/Camera2D") as Camera2D
	return {
		"present": pump_present and coil_rat != null,
		"available": _is_overflow_pump_available(),
		"active": _is_overflow_pump_active(),
		"cleared": _is_overflow_pump_cleared(),
		"drip_vent_crossed": (
			_lower_deck_forward_pressure_aftershock_condenser_drip_vent_crossed
		),
		"node_name": (
			String(_lower_deck_forward_pressure_aftershock_condenser_overflow_pump.name)
			if pump_present
			else ""
		),
		"coil_node_name": String(coil_rat.name) if coil_rat != null else "",
		"prop_visible": (
			_lower_deck_forward_pressure_aftershock_condenser_overflow_pump.visible
			if pump_present
			else false
		),
		"prop_texture_path": (
			_lower_deck_forward_pressure_aftershock_condenser_overflow_pump.texture.resource_path
			if (
				pump_present
				and _lower_deck_forward_pressure_aftershock_condenser_overflow_pump.texture != null
			)
			else ""
		),
		"activation_x": (
			FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_ACTIVATION_X
		),
		"ground_width": ground_rect.size.x if ground_rect != null else 0.0,
		"right_wall_x": right_wall.global_position.x if right_wall != null else 0.0,
		"camera_limit_right": camera.limit_right if camera != null else 0,
		"coil_visible": coil_rat.visible if coil_rat != null else false,
		"coil_has_target": _does_overflow_pump_coil_rat_have_target(),
		"coil_process_enabled": coil_rat.is_processing() if coil_rat != null else false,
		"coil_physics_enabled": (
			coil_rat.is_physics_processing() if coil_rat != null else false
		),
		"coil_defeated": (
			_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_coil_rat_defeated
		),
		"coil_entity_id": _get_enemy_entity_id(coil_rat),
		"coil_family_id": _get_enemy_family_id(coil_rat),
		"coil_sprite_frames_path": (
			coil_sprite.sprite_frames.resource_path
			if coil_sprite != null and coil_sprite.sprite_frames != null
			else ""
		),
		"coil_animation_frame_counts": _get_sprite_animation_frame_counts(coil_sprite),
		"pacing": _get_overflow_pump_pacing_diagnostics(),
		"coil_position": coil_rat.global_position if coil_rat != null else Vector2.ZERO,
		"route_label_text": String(route.get("route_label_text", "")),
	}


## Returns deterministic overflow-pump reward cache diagnostics for tests and MCP probes.
func get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_reward_cache_diagnostics(
) -> Dictionary:
	var cache: Node = (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_reward_cache
	)
	return {
		"present": cache != null,
		"overflow_pump_cleared": _is_overflow_pump_cleared(),
		"available": (
			bool(cache.call("is_available"))
			if cache != null and cache.has_method("is_available")
			else false
		),
		"visible": cache.visible if cache != null else false,
		"claim_available": (
			bool(cache.call("is_claim_available"))
			if cache != null and cache.has_method("is_claim_available")
			else false
		),
		"claimed": _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_reward_cache_claimed,
		"cache_id": String(
			cache.call("get_cache_id")
			if cache != null and cache.has_method("get_cache_id")
			else FACTORY_LOWER_DECK_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_REWARD_CACHE_ID
		),
		"texture_path": _get_overflow_pump_reward_cache_texture_path(),
		"prompt_text": _get_overflow_pump_reward_cache_prompt_text(),
		"position": _get_overflow_pump_reward_cache_position(),
		"last_reward": (
			_last_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_reward_cache_reward
			.duplicate(true)
		),
		"last_claim_feedback": (
			_last_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_reward_cache_claim_feedback
			.duplicate(true)
		),
	}


## Returns deterministic overflow-pump runoff hatch diagnostics for tests and MCP probes.
func get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_exit_hatch_diagnostics(
) -> Dictionary:
	var hatch: Node = (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_exit_hatch
	)
	return {
		"present": hatch != null,
		"cache_claimed": (
			_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_reward_cache_claimed
		),
		"available": _is_overflow_pump_exit_hatch_available(),
		"visible": hatch.visible if hatch != null else false,
		"opened": (
			_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_exit_hatch_opened
		),
		"hatch_id": _get_overflow_pump_exit_hatch_id(),
		"texture_path": _get_overflow_pump_exit_hatch_texture_path(),
		"prompt_text": _get_overflow_pump_exit_hatch_prompt_text(),
		"position": _get_overflow_pump_exit_hatch_position(),
		"collision_blocking": _is_overflow_pump_exit_hatch_collision_blocking(),
	}


## Returns deterministic runoff-exit reward cache diagnostics for tests/MCP probes.
func get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_reward_cache_diagnostics(
) -> Dictionary:
	var route: Dictionary = get_factory_route_objective_diagnostics()
	var cache: Node = (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_reward_cache
	)
	return {
		"present": cache != null,
		"runoff_exit_skirmish_cleared": _is_overflow_pump_runoff_exit_skirmish_cleared(),
		"available": (
			bool(cache.call("is_available"))
			if cache != null and cache.has_method("is_available")
			else false
		),
		"visible": cache.visible if cache != null else false,
		"claim_available": (
			bool(cache.call("is_claim_available"))
			if cache != null and cache.has_method("is_claim_available")
			else false
		),
		"claimed": (
			_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_reward_cache_claimed
		),
		"cache_id": String(
			cache.call("get_cache_id")
			if cache != null and cache.has_method("get_cache_id")
			else FACTORY_LOWER_DECK_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_RUNOFF_EXIT_REWARD_CACHE_ID
		),
		"texture_path": _get_overflow_pump_runoff_exit_reward_cache_texture_path(),
		"prompt_text": _get_overflow_pump_runoff_exit_reward_cache_prompt_text(),
		"position": _get_overflow_pump_runoff_exit_reward_cache_position(),
		"last_reward": (
			_last_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_reward_cache_reward
			.duplicate(true)
		),
		"last_claim_feedback": (
			_last_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_reward_cache_claim_feedback
			.duplicate(true)
		),
		"route_label_text": String(route.get("route_label_text", "")),
	}


## Returns deterministic runoff-exit gate diagnostics for tests/MCP probes.
func get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_gate_diagnostics(
) -> Dictionary:
	var route: Dictionary = get_factory_route_objective_diagnostics()
	var gate: Node = (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_gate
	)
	return {
		"present": gate != null,
		"cache_claimed": (
			_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_reward_cache_claimed
		),
		"available": _is_overflow_pump_runoff_exit_gate_available(),
		"visible": gate.visible if gate != null else false,
		"opened": (
			_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_gate_opened
		),
		"gate_id": _get_overflow_pump_runoff_exit_gate_id(),
		"texture_path": _get_overflow_pump_runoff_exit_gate_texture_path(),
		"prompt_text": _get_overflow_pump_runoff_exit_gate_prompt_text(),
		"position": _get_overflow_pump_runoff_exit_gate_position(),
		"collision_blocking": _is_overflow_pump_runoff_exit_gate_collision_blocking(),
		"route_label_text": String(route.get("route_label_text", "")),
	}


## Returns deterministic runoff outlet traverse diagnostics for tests/MCP probes.
func get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_diagnostics(
) -> Dictionary:
	var route: Dictionary = get_factory_route_objective_diagnostics()
	var duct_present: bool = (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_duct != null
	)
	var hazard_present: bool = (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_vent != null
	)
	var ground_shape := get_node_or_null("Ground/CollisionShape2D") as CollisionShape2D
	var ground_rect := (
		ground_shape.shape as RectangleShape2D
		if ground_shape != null and ground_shape.shape is RectangleShape2D
		else null
	)
	var right_wall := get_node_or_null("RightWall") as Node2D
	var camera := get_node_or_null("Player/Camera2D") as Camera2D
	return {
		"present": duct_present and hazard_present,
		"available": _is_overflow_pump_runoff_outlet_available(),
		"active": _is_overflow_pump_runoff_outlet_active(),
		"crossed": (
			_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_crossed
		),
		"runoff_exit_gate_opened": (
			_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_gate_opened
		),
		"visible": (
			_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_duct.visible
			if duct_present
			else false
		),
		"node_name": (
			String(
				_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_duct.name
			)
			if duct_present
			else ""
		),
		"hazard_node_name": (
			String(
				_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_vent.name
			)
			if hazard_present
			else ""
		),
		"duct_texture_path": (
			_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_duct
			.texture
			.resource_path
			if (
				duct_present
				and _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_duct
				.texture
				!= null
			)
			else ""
		),
		"hazard_visible": (
			_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_vent.visible
			if hazard_present
			else false
		),
		"hazard_contact_active": _is_hazard_contact_active(
			_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_vent
		),
		"hazard_id": String(_get_hazard_id(
			_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_vent
		)),
		"hazard_damage": _get_hazard_damage(
			_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_vent
		),
		"hazard_cooldown_sec": _get_hazard_cooldown_sec(
			_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_vent
		),
		"hazard_texture_path": (
			String(
				_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_vent.call(
					"get_visual_texture_path"
				)
			)
			if (
				hazard_present
				and _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_vent.has_method(
					"get_visual_texture_path"
				)
			)
			else ""
		),
		"phase": String(_get_overflow_pump_runoff_outlet_phase()),
		"initial_grace_sec": FACTORY_LOWER_DECK_FORWARD_PRESSURE_INITIAL_GRACE_SEC,
		"warning_sec": FACTORY_LOWER_DECK_FORWARD_PRESSURE_WARNING_SEC,
		"active_sec": FACTORY_LOWER_DECK_FORWARD_PRESSURE_ACTIVE_SEC,
		"safe_sec": FACTORY_LOWER_DECK_FORWARD_PRESSURE_SAFE_SEC,
		"activation_x": (
			FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_RUNOFF_OUTLET_ACTIVATION_X
		),
		"exit_x": (
			FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_RUNOFF_OUTLET_EXIT_X
		),
		"ground_width": ground_rect.size.x if ground_rect != null else 0.0,
		"right_wall_x": right_wall.global_position.x if right_wall != null else 0.0,
		"camera_limit_right": camera.limit_right if camera != null else 0,
		"floor_tile_count": _get_factory_route_floor_visual_tiles().size(),
		"route_label_text": String(route.get("route_label_text", "")),
	}


## Returns deterministic runoff outlet Spark Rat skirmish diagnostics.
func get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_skirmish_diagnostics(
) -> Dictionary:
	var route: Dictionary = get_factory_route_objective_diagnostics()
	var spark_rat: Node2D = _get_valid_node2d(
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_spark_rat
	)
	var spark_sprite: AnimatedSprite2D = (
		spark_rat.get_node_or_null("Sprite") as AnimatedSprite2D
		if spark_rat != null
		else null
	)
	var ground_shape := get_node_or_null("Ground/CollisionShape2D") as CollisionShape2D
	var ground_rect := (
		ground_shape.shape as RectangleShape2D
		if ground_shape != null and ground_shape.shape is RectangleShape2D
		else null
	)
	var right_wall := get_node_or_null("RightWall") as Node2D
	var camera := get_node_or_null("Player/Camera2D") as Camera2D
	return {
		"present": spark_rat != null,
		"available": _is_overflow_pump_runoff_outlet_skirmish_available(),
		"active": _is_overflow_pump_runoff_outlet_skirmish_active(),
		"cleared": _is_overflow_pump_runoff_outlet_skirmish_cleared(),
		"runoff_outlet_crossed": (
			_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_crossed
		),
		"activation_x": (
			FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_RUNOFF_OUTLET_SKIRMISH_ACTIVATION_X
		),
		"ground_width": ground_rect.size.x if ground_rect != null else 0.0,
		"right_wall_x": right_wall.global_position.x if right_wall != null else 0.0,
		"camera_limit_right": camera.limit_right if camera != null else 0,
		"spark_node_name": String(spark_rat.name) if spark_rat != null else "",
		"spark_visible": spark_rat.visible if spark_rat != null else false,
		"spark_has_target": _does_overflow_pump_runoff_outlet_spark_rat_have_target(),
		"spark_process_enabled": spark_rat.is_processing() if spark_rat != null else false,
		"spark_physics_enabled": (
			spark_rat.is_physics_processing() if spark_rat != null else false
		),
		"spark_defeated": (
			_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_spark_rat_defeated
		),
		"spark_entity_id": _get_enemy_entity_id(spark_rat),
		"spark_family_id": _get_enemy_family_id(spark_rat),
		"spark_sprite_frames_path": (
			spark_sprite.sprite_frames.resource_path
			if spark_sprite != null and spark_sprite.sprite_frames != null
			else ""
		),
		"spark_animation_frame_counts": _get_sprite_animation_frame_counts(spark_sprite),
		"pacing": _get_overflow_pump_runoff_outlet_skirmish_pacing_diagnostics(),
		"position": spark_rat.global_position if spark_rat != null else Vector2.ZERO,
		"route_label_text": String(route.get("route_label_text", "")),
	}


## Returns deterministic runoff-outlet reward cache diagnostics for tests/MCP probes.
func get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_reward_cache_diagnostics(
) -> Dictionary:
	var route: Dictionary = get_factory_route_objective_diagnostics()
	var cache: Node = (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_reward_cache
	)
	var ground_shape := get_node_or_null("Ground/CollisionShape2D") as CollisionShape2D
	var ground_rect := (
		ground_shape.shape as RectangleShape2D
		if ground_shape != null and ground_shape.shape is RectangleShape2D
		else null
	)
	var right_wall := get_node_or_null("RightWall") as Node2D
	var camera := get_node_or_null("Player/Camera2D") as Camera2D
	return {
		"present": cache != null,
		"runoff_outlet_skirmish_cleared": _is_overflow_pump_runoff_outlet_skirmish_cleared(),
		"available": (
			bool(cache.call("is_available"))
			if cache != null and cache.has_method("is_available")
			else false
		),
		"visible": cache.visible if cache != null else false,
		"claim_available": (
			bool(cache.call("is_claim_available"))
			if cache != null and cache.has_method("is_claim_available")
			else false
		),
		"claimed": (
			_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_reward_cache_claimed
		),
		"cache_id": String(
			cache.call("get_cache_id")
			if cache != null and cache.has_method("get_cache_id")
			else FACTORY_LOWER_DECK_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_RUNOFF_OUTLET_REWARD_CACHE_ID
		),
		"texture_path": _get_overflow_pump_runoff_outlet_reward_cache_texture_path(),
		"prompt_text": _get_overflow_pump_runoff_outlet_reward_cache_prompt_text(),
		"position": _get_overflow_pump_runoff_outlet_reward_cache_position(),
		"last_reward": (
			_last_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_reward_cache_reward
			.duplicate(true)
		),
		"last_claim_feedback": (
			_last_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_reward_cache_claim_feedback
			.duplicate(true)
		),
		"ground_width": ground_rect.size.x if ground_rect != null else 0.0,
		"right_wall_x": right_wall.global_position.x if right_wall != null else 0.0,
		"camera_limit_right": camera.limit_right if camera != null else 0,
		"floor_tile_count": _get_factory_route_floor_visual_tiles().size(),
		"route_label_text": String(route.get("route_label_text", "")),
	}


## Returns deterministic runoff-outlet service hatch diagnostics for tests/MCP probes.
func get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_hatch_diagnostics(
) -> Dictionary:
	var route: Dictionary = get_factory_route_objective_diagnostics()
	var hatch: Node = (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_hatch
	)
	return {
		"present": hatch != null,
		"cache_claimed": (
			_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_reward_cache_claimed
		),
		"available": _is_overflow_pump_runoff_outlet_service_hatch_available(),
		"visible": hatch.visible if hatch != null else false,
		"opened": (
			_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_hatch_opened
		),
		"hatch_id": _get_overflow_pump_runoff_outlet_service_hatch_id(),
		"texture_path": _get_overflow_pump_runoff_outlet_service_hatch_texture_path(),
		"prompt_text": _get_overflow_pump_runoff_outlet_service_hatch_prompt_text(),
		"position": _get_overflow_pump_runoff_outlet_service_hatch_position(),
		"collision_blocking": _is_overflow_pump_runoff_outlet_service_hatch_collision_blocking(),
		"route_label_text": String(route.get("route_label_text", "")),
	}


## Returns deterministic runoff-outlet service sluice diagnostics for tests/MCP probes.
func get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_diagnostics(
) -> Dictionary:
	var route: Dictionary = get_factory_route_objective_diagnostics()
	var duct: Sprite2D = (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_duct
	)
	var hazard: Area2D = (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_vent
			as Area2D
	)
	var ground_shape := get_node_or_null("Ground/CollisionShape2D") as CollisionShape2D
	var ground_rect := (
		ground_shape.shape as RectangleShape2D
		if ground_shape != null and ground_shape.shape is RectangleShape2D
		else null
	)
	var right_wall := get_node_or_null("RightWall") as Node2D
	var camera := get_node_or_null("Player/Camera2D") as Camera2D
	var background := get_node_or_null("Background") as TextureRect
	return {
		"present": duct != null and hazard != null,
		"available": _is_overflow_pump_runoff_outlet_service_sluice_available(),
		"active": _is_overflow_pump_runoff_outlet_service_sluice_active(),
		"crossed": (
			_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_crossed
		),
		"service_hatch_opened": (
			_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_hatch_opened
		),
		"visible": duct.visible if duct != null else false,
		"node_name": String(duct.name) if duct != null else "",
		"hazard_node_name": String(hazard.name) if hazard != null else "",
		"duct_texture_path": (
			duct.texture.resource_path
			if duct != null and duct.texture != null
			else ""
		),
		"hazard_visible": hazard.visible if hazard != null else false,
		"hazard_contact_active": _is_hazard_contact_active(hazard),
		"hazard_id": String(_get_hazard_id(hazard)),
		"hazard_damage": _get_hazard_damage(hazard),
		"hazard_cooldown_sec": _get_hazard_cooldown_sec(hazard),
		"hazard_texture_path": (
			String(hazard.call("get_visual_texture_path"))
			if hazard != null and hazard.has_method("get_visual_texture_path")
			else ""
		),
		"phase": String(_get_overflow_pump_runoff_outlet_service_sluice_phase()),
		"initial_grace_sec": FACTORY_LOWER_DECK_FORWARD_PRESSURE_INITIAL_GRACE_SEC,
		"warning_sec": FACTORY_LOWER_DECK_FORWARD_PRESSURE_WARNING_SEC,
		"active_sec": FACTORY_LOWER_DECK_FORWARD_PRESSURE_ACTIVE_SEC,
		"safe_sec": FACTORY_LOWER_DECK_FORWARD_PRESSURE_SAFE_SEC,
		"activation_x": (
			FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_RUNOFF_OUTLET_SERVICE_SLUICE_ACTIVATION_X
		),
		"exit_x": (
			FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_RUNOFF_OUTLET_SERVICE_SLUICE_EXIT_X
		),
		"ground_width": ground_rect.size.x if ground_rect != null else 0.0,
		"right_wall_x": right_wall.global_position.x if right_wall != null else 0.0,
		"camera_limit_right": camera.limit_right if camera != null else 0,
		"background_width": background.size.x if background != null else 0.0,
		"floor_tile_count": _get_factory_route_floor_visual_tiles().size(),
		"collision_layer": hazard.collision_layer if hazard != null else 0,
		"collision_mask": hazard.collision_mask if hazard != null else 0,
		"route_label_text": String(route.get("route_label_text", "")),
	}


## Returns deterministic service-sluice Spark Rat skirmish diagnostics.
func get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_skirmish_diagnostics(
) -> Dictionary:
	var route: Dictionary = get_factory_route_objective_diagnostics()
	var spark_rat: Node2D = _get_valid_node2d(
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_spark_rat
	)
	var spark_sprite: AnimatedSprite2D = (
		spark_rat.get_node_or_null("Sprite") as AnimatedSprite2D
		if spark_rat != null
		else null
	)
	var right_wall := get_node_or_null("RightWall") as Node2D
	var camera := get_node_or_null("Player/Camera2D") as Camera2D
	var background := get_node_or_null("Background") as TextureRect
	var ground := get_node_or_null("Ground") as Node2D
	var ground_shape := get_node_or_null("Ground/CollisionShape2D") as CollisionShape2D
	var ground_rect := (
		ground_shape.shape as RectangleShape2D
		if ground_shape != null and ground_shape.shape is RectangleShape2D
		else null
	)
	var ground_right_edge_x: float = (
		ground.global_position.x + (ground_rect.size.x * 0.5)
		if ground != null and ground_rect != null
		else 0.0
	)
	return {
		"present": spark_rat != null,
		"available": _is_overflow_pump_runoff_outlet_service_sluice_skirmish_available(),
		"active": _is_overflow_pump_runoff_outlet_service_sluice_skirmish_active(),
		"cleared": _is_overflow_pump_runoff_outlet_service_sluice_skirmish_cleared(),
		"service_sluice_crossed": (
			_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_crossed
		),
		"activation_x": (
			FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_RUNOFF_OUTLET_SERVICE_SLUICE_SKIRMISH_ACTIVATION_X
		),
		"right_wall_x": right_wall.global_position.x if right_wall != null else 0.0,
		"camera_limit_right": camera.limit_right if camera != null else 0,
		"background_width": background.size.x if background != null else 0.0,
		"ground_width": ground_rect.size.x if ground_rect != null else 0.0,
		"ground_right_edge_x": ground_right_edge_x,
		"spark_node_name": String(spark_rat.name) if spark_rat != null else "",
		"spark_visible": spark_rat.visible if spark_rat != null else false,
		"spark_has_target": (
			_does_overflow_pump_runoff_outlet_service_sluice_spark_rat_have_target()
		),
		"spark_process_enabled": spark_rat.is_processing() if spark_rat != null else false,
		"spark_physics_enabled": (
			spark_rat.is_physics_processing() if spark_rat != null else false
		),
		"spark_defeated": (
			_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_spark_rat_defeated
		),
		"spark_entity_id": _get_enemy_entity_id(spark_rat),
		"spark_family_id": _get_enemy_family_id(spark_rat),
		"spark_sprite_frames_path": (
			spark_sprite.sprite_frames.resource_path
			if spark_sprite != null and spark_sprite.sprite_frames != null
			else ""
		),
		"spark_animation_frame_counts": _get_sprite_animation_frame_counts(spark_sprite),
		"pacing": (
			_get_overflow_pump_runoff_outlet_service_sluice_skirmish_pacing_diagnostics()
		),
		"position": spark_rat.global_position if spark_rat != null else Vector2.ZERO,
		"route_label_text": String(route.get("route_label_text", "")),
	}


## Returns deterministic overflow-pump runoff duct diagnostics for tests/MCP probes.
func get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_duct_diagnostics(
) -> Dictionary:
	var route: Dictionary = get_factory_route_objective_diagnostics()
	var duct_present: bool = (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_duct != null
	)
	var hazard_present: bool = (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_duct_vent != null
	)
	var ground_shape := get_node_or_null("Ground/CollisionShape2D") as CollisionShape2D
	var ground_rect := (
		ground_shape.shape as RectangleShape2D
		if ground_shape != null and ground_shape.shape is RectangleShape2D
		else null
	)
	var right_wall := get_node_or_null("RightWall") as Node2D
	var camera := get_node_or_null("Player/Camera2D") as Camera2D
	return {
		"present": duct_present and hazard_present,
		"available": _is_overflow_pump_runoff_duct_available(),
		"active": _is_overflow_pump_runoff_duct_active(),
		"crossed": (
			_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_duct_crossed
		),
		"overflow_pump_exit_hatch_opened": (
			_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_exit_hatch_opened
		),
		"visible": (
			_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_duct.visible
			if duct_present
			else false
		),
		"node_name": (
			String(
				_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_duct.name
			)
			if duct_present
			else ""
		),
		"hazard_node_name": (
			String(
				_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_duct_vent.name
			)
			if hazard_present
			else ""
		),
		"duct_texture_path": (
			_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_duct.texture.resource_path
			if (
				duct_present
				and _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_duct.texture != null
			)
			else ""
		),
		"hazard_visible": (
			_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_duct_vent.visible
			if hazard_present
			else false
		),
		"hazard_contact_active": _is_hazard_contact_active(
			_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_duct_vent
		),
		"hazard_id": String(_get_hazard_id(
			_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_duct_vent
		)),
		"hazard_damage": _get_hazard_damage(
			_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_duct_vent
		),
		"hazard_cooldown_sec": _get_hazard_cooldown_sec(
			_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_duct_vent
		),
		"hazard_texture_path": (
			String(
				_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_duct_vent.call(
					"get_visual_texture_path"
				)
			)
			if (
				hazard_present
				and _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_duct_vent.has_method(
					"get_visual_texture_path"
				)
			)
			else ""
		),
		"phase": String(_get_overflow_pump_runoff_duct_phase()),
		"initial_grace_sec": FACTORY_LOWER_DECK_FORWARD_PRESSURE_INITIAL_GRACE_SEC,
		"warning_sec": FACTORY_LOWER_DECK_FORWARD_PRESSURE_WARNING_SEC,
		"active_sec": FACTORY_LOWER_DECK_FORWARD_PRESSURE_ACTIVE_SEC,
		"safe_sec": FACTORY_LOWER_DECK_FORWARD_PRESSURE_SAFE_SEC,
		"activation_x": (
			FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_RUNOFF_DUCT_ACTIVATION_X
		),
		"exit_x": (
			FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_RUNOFF_DUCT_EXIT_X
		),
		"ground_width": ground_rect.size.x if ground_rect != null else 0.0,
		"right_wall_x": right_wall.global_position.x if right_wall != null else 0.0,
		"camera_limit_right": camera.limit_right if camera != null else 0,
		"route_label_text": String(route.get("route_label_text", "")),
	}


## Returns deterministic overflow-pump runoff exit skirmish diagnostics.
func get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_skirmish_diagnostics(
) -> Dictionary:
	var route: Dictionary = get_factory_route_objective_diagnostics()
	var coil_rat: Node2D = _get_valid_node2d(
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_coil_rat
	)
	var coil_sprite: AnimatedSprite2D = (
		coil_rat.get_node_or_null("Sprite") as AnimatedSprite2D
		if coil_rat != null
		else null
	)
	var ground_shape := get_node_or_null("Ground/CollisionShape2D") as CollisionShape2D
	var ground_rect := (
		ground_shape.shape as RectangleShape2D
		if ground_shape != null and ground_shape.shape is RectangleShape2D
		else null
	)
	var right_wall := get_node_or_null("RightWall") as Node2D
	var camera := get_node_or_null("Player/Camera2D") as Camera2D
	return {
		"present": coil_rat != null,
		"available": _is_overflow_pump_runoff_exit_skirmish_available(),
		"active": _is_overflow_pump_runoff_exit_skirmish_active(),
		"cleared": _is_overflow_pump_runoff_exit_skirmish_cleared(),
		"runoff_duct_crossed": (
			_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_duct_crossed
		),
		"activation_x": (
			FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_RUNOFF_EXIT_ACTIVATION_X
		),
		"ground_width": ground_rect.size.x if ground_rect != null else 0.0,
		"right_wall_x": right_wall.global_position.x if right_wall != null else 0.0,
		"camera_limit_right": camera.limit_right if camera != null else 0,
		"coil_node_name": String(coil_rat.name) if coil_rat != null else "",
		"coil_visible": coil_rat.visible if coil_rat != null else false,
		"coil_has_target": _does_overflow_pump_runoff_exit_coil_rat_have_target(),
		"coil_process_enabled": coil_rat.is_processing() if coil_rat != null else false,
		"coil_physics_enabled": (
			coil_rat.is_physics_processing() if coil_rat != null else false
		),
		"coil_defeated": (
			_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_coil_rat_defeated
		),
		"coil_entity_id": _get_enemy_entity_id(coil_rat),
		"coil_family_id": _get_enemy_family_id(coil_rat),
		"coil_sprite_frames_path": (
			coil_sprite.sprite_frames.resource_path
			if coil_sprite != null and coil_sprite.sprite_frames != null
			else ""
		),
		"coil_animation_frame_counts": _get_sprite_animation_frame_counts(coil_sprite),
		"pacing": _get_overflow_pump_runoff_exit_pacing_diagnostics(),
		"coil_position": coil_rat.global_position if coil_rat != null else Vector2.ZERO,
		"route_label_text": String(route.get("route_label_text", "")),
	}


## Returns deterministic forward-pressure route handoff marker diagnostics for tests and MCP probes.
func get_factory_lower_deck_forward_pressure_route_handoff_marker_diagnostics() -> Dictionary:
	var interaction_area := (
		_lower_deck_forward_pressure_route_handoff_marker.get_node_or_null(
			"InteractionArea"
		) as Area2D
		if _lower_deck_forward_pressure_route_handoff_marker != null
		else null
	)
	var collision_shape := (
		_lower_deck_forward_pressure_route_handoff_marker.get_node_or_null(
			"InteractionArea/CollisionShape2D"
		) as CollisionShape2D
		if _lower_deck_forward_pressure_route_handoff_marker != null
		else null
	)
	var route: Dictionary = get_factory_route_objective_diagnostics()
	var unlock_vfx_snapshot: Dictionary = (
		_get_lower_deck_forward_pressure_route_handoff_marker_unlock_vfx_snapshot()
	)
	return {
		"present": _lower_deck_forward_pressure_route_handoff_marker != null,
		"available": _is_lower_deck_forward_pressure_route_handoff_marker_available(),
		"visible": (
			_lower_deck_forward_pressure_route_handoff_marker.visible
			if _lower_deck_forward_pressure_route_handoff_marker != null
			else false
		),
		"lit": _lower_deck_forward_pressure_route_handoff_marker_lit,
		"exit_gate_opened": _lower_deck_forward_pressure_exit_gate_opened,
		"marker_id": _get_lower_deck_forward_pressure_route_handoff_marker_id(),
		"prompt_text": _get_lower_deck_forward_pressure_route_handoff_marker_prompt_text(),
		"texture_path": _get_lower_deck_forward_pressure_route_handoff_marker_texture_path(),
		"interaction_monitoring": interaction_area.monitoring if interaction_area != null else false,
		"interaction_monitorable": interaction_area.monitorable if interaction_area != null else false,
		"collision_disabled": collision_shape.disabled if collision_shape != null else true,
		"position": _get_lower_deck_forward_pressure_route_handoff_marker_position(),
		"route_label_text": String(route.get("route_label_text", "")),
		"unlock_feedback_texture_path": String(unlock_vfx_snapshot.get("texture_path", "")),
		"unlock_feedback_active": int(unlock_vfx_snapshot.get("active_count", 0)) > 0,
		"unlock_feedback_played": bool(unlock_vfx_snapshot.get("played", false)),
		"unlock_feedback_spawn_count": int(unlock_vfx_snapshot.get("spawn_count", 0)),
	}


## Returns deterministic route-beacon ambush diagnostics for tests and MCP probes.
func get_factory_lower_deck_forward_pressure_beacon_ambush_diagnostics() -> Dictionary:
	var sprite: AnimatedSprite2D = (
		_lower_deck_forward_beacon_ambush_spark_rat.get_node_or_null("Sprite")
		as AnimatedSprite2D
		if _lower_deck_forward_beacon_ambush_spark_rat != null
		else null
	)
	return {
		"present": (
			_lower_deck_forward_beacon_ambush_spark_rat != null
			and _lower_deck_forward_beacon_ambush_pressure_vent != null
		),
		"available": _is_lower_deck_forward_pressure_beacon_ambush_available(),
		"active": _is_lower_deck_forward_pressure_beacon_ambush_active(),
		"defeated": _lower_deck_forward_pressure_beacon_ambush_defeated,
		"route_marker_lit": _lower_deck_forward_pressure_route_handoff_marker_lit,
		"activation_x": FACTORY_LOWER_DECK_FORWARD_BEACON_AMBUSH_ACTIVATION_X,
		"enemy_visible": (
			_lower_deck_forward_beacon_ambush_spark_rat.visible
			if _lower_deck_forward_beacon_ambush_spark_rat != null
			else false
		),
		"enemy_has_target": _does_lower_deck_forward_beacon_ambush_have_target(),
		"enemy_physics_enabled": (
			_lower_deck_forward_beacon_ambush_spark_rat.is_physics_processing()
			if _lower_deck_forward_beacon_ambush_spark_rat != null
			else false
		),
		"enemy_process_enabled": (
			_lower_deck_forward_beacon_ambush_spark_rat.is_processing()
			if _lower_deck_forward_beacon_ambush_spark_rat != null
			else false
		),
		"entity_id": (
			int(_lower_deck_forward_beacon_ambush_spark_rat.call("get_entity_id"))
			if (
				_lower_deck_forward_beacon_ambush_spark_rat != null
				and _lower_deck_forward_beacon_ambush_spark_rat.has_method(
					"get_entity_id"
				)
			)
			else 0
		),
		"sprite_frames_path": (
			sprite.sprite_frames.resource_path
			if sprite != null and sprite.sprite_frames != null
			else ""
		),
		"animation_frame_counts": _get_sprite_animation_frame_counts(sprite),
		"pacing": _get_lower_deck_forward_beacon_ambush_pacing_diagnostics(),
		"hazard_present": _lower_deck_forward_beacon_ambush_pressure_vent != null,
		"hazard_active": _is_hazard_contact_active(
			_lower_deck_forward_beacon_ambush_pressure_vent
		),
		"hazard_visible": (
			_lower_deck_forward_beacon_ambush_pressure_vent.visible
			if _lower_deck_forward_beacon_ambush_pressure_vent != null
			else false
		),
		"hazard_id": String(_get_hazard_id(_lower_deck_forward_beacon_ambush_pressure_vent)),
		"hazard_damage": _get_hazard_damage(
			_lower_deck_forward_beacon_ambush_pressure_vent
		),
		"hazard_cooldown_sec": _get_hazard_cooldown_sec(
			_lower_deck_forward_beacon_ambush_pressure_vent
		),
		"hazard_texture_path": (
			String(_lower_deck_forward_beacon_ambush_pressure_vent.call(
				"get_visual_texture_path"
			))
			if (
				_lower_deck_forward_beacon_ambush_pressure_vent != null
				and _lower_deck_forward_beacon_ambush_pressure_vent.has_method(
					"get_visual_texture_path"
				)
			)
			else ""
		),
		"enemy_position": (
			_lower_deck_forward_beacon_ambush_spark_rat.global_position
			if _lower_deck_forward_beacon_ambush_spark_rat != null
			else Vector2.ZERO
		),
		"hazard_position": (
			_lower_deck_forward_beacon_ambush_pressure_vent.global_position
			if _lower_deck_forward_beacon_ambush_pressure_vent != null
			else Vector2.ZERO
		),
		"route_label_text": String(
			get_factory_route_objective_diagnostics().get("route_label_text", "")
		),
	}


## Returns deterministic forward-pressure overrun diagnostics for tests and MCP probes.
func get_factory_lower_deck_forward_pressure_overrun_diagnostics() -> Dictionary:
	var sprite: AnimatedSprite2D = (
		_lower_deck_forward_overrun_spark_rat.get_node_or_null("Sprite")
		as AnimatedSprite2D
		if _lower_deck_forward_overrun_spark_rat != null
		else null
	)
	return {
		"present": (
			_lower_deck_forward_overrun_spark_rat != null
			and _lower_deck_forward_overrun_pressure_vent != null
		),
		"available": _is_lower_deck_forward_pressure_overrun_available(),
		"active": _is_lower_deck_forward_pressure_overrun_active(),
		"defeated": _lower_deck_forward_pressure_overrun_defeated,
		"beacon_ambush_defeated": _lower_deck_forward_pressure_beacon_ambush_defeated,
		"activation_x": FACTORY_LOWER_DECK_FORWARD_OVERRUN_ACTIVATION_X,
		"enemy_visible": (
			_lower_deck_forward_overrun_spark_rat.visible
			if _lower_deck_forward_overrun_spark_rat != null
			else false
		),
		"enemy_has_target": _does_lower_deck_forward_overrun_have_target(),
		"enemy_physics_enabled": (
			_lower_deck_forward_overrun_spark_rat.is_physics_processing()
			if _lower_deck_forward_overrun_spark_rat != null
			else false
		),
		"enemy_process_enabled": (
			_lower_deck_forward_overrun_spark_rat.is_processing()
			if _lower_deck_forward_overrun_spark_rat != null
			else false
		),
		"entity_id": (
			int(_lower_deck_forward_overrun_spark_rat.call("get_entity_id"))
			if (
				_lower_deck_forward_overrun_spark_rat != null
				and _lower_deck_forward_overrun_spark_rat.has_method("get_entity_id")
			)
			else 0
		),
		"sprite_frames_path": (
			sprite.sprite_frames.resource_path
			if sprite != null and sprite.sprite_frames != null
			else ""
		),
		"animation_frame_counts": _get_sprite_animation_frame_counts(sprite),
		"pacing": _get_lower_deck_forward_overrun_pacing_diagnostics(),
		"hazard_present": _lower_deck_forward_overrun_pressure_vent != null,
		"hazard_active": _is_hazard_contact_active(_lower_deck_forward_overrun_pressure_vent),
		"hazard_visible": (
			_lower_deck_forward_overrun_pressure_vent.visible
			if _lower_deck_forward_overrun_pressure_vent != null
			else false
		),
		"hazard_id": String(_get_hazard_id(_lower_deck_forward_overrun_pressure_vent)),
		"hazard_damage": _get_hazard_damage(_lower_deck_forward_overrun_pressure_vent),
		"hazard_cooldown_sec": _get_hazard_cooldown_sec(
			_lower_deck_forward_overrun_pressure_vent
		),
		"hazard_texture_path": (
			String(_lower_deck_forward_overrun_pressure_vent.call(
				"get_visual_texture_path"
			))
			if (
				_lower_deck_forward_overrun_pressure_vent != null
				and _lower_deck_forward_overrun_pressure_vent.has_method(
					"get_visual_texture_path"
				)
			)
			else ""
		),
		"enemy_position": (
			_lower_deck_forward_overrun_spark_rat.global_position
			if _lower_deck_forward_overrun_spark_rat != null
			else Vector2.ZERO
		),
		"hazard_position": (
			_lower_deck_forward_overrun_pressure_vent.global_position
			if _lower_deck_forward_overrun_pressure_vent != null
			else Vector2.ZERO
		),
		"route_label_text": String(
			get_factory_route_objective_diagnostics().get("route_label_text", "")
		),
	}


## Returns deterministic forward-pressure breaker stand diagnostics for tests and MCP probes.
func get_factory_lower_deck_forward_pressure_breaker_stand_diagnostics() -> Dictionary:
	var sprite: AnimatedSprite2D = (
		_lower_deck_forward_breaker_spark_rat.get_node_or_null("Sprite")
		as AnimatedSprite2D
		if _lower_deck_forward_breaker_spark_rat != null
		else null
	)
	var route: Dictionary = get_factory_route_objective_diagnostics()
	return {
		"present": (
			_lower_deck_forward_breaker_spark_rat != null
			and _lower_deck_forward_breaker_pressure_vent != null
			and _lower_deck_forward_pressure_breaker != null
		),
		"available": _is_lower_deck_forward_pressure_breaker_stand_available(),
		"active": _is_lower_deck_forward_pressure_breaker_stand_active(),
		"secured": _lower_deck_forward_pressure_breaker_secured,
		"cut": _lower_deck_forward_pressure_breaker_cut,
		"overrun_defeated": _lower_deck_forward_pressure_overrun_defeated,
		"activation_x": FACTORY_LOWER_DECK_FORWARD_BREAKER_ACTIVATION_X,
		"enemy_visible": (
			_lower_deck_forward_breaker_spark_rat.visible
			if _lower_deck_forward_breaker_spark_rat != null
			else false
		),
		"enemy_has_target": _does_lower_deck_forward_breaker_have_target(),
		"enemy_physics_enabled": (
			_lower_deck_forward_breaker_spark_rat.is_physics_processing()
			if _lower_deck_forward_breaker_spark_rat != null
			else false
		),
		"enemy_process_enabled": (
			_lower_deck_forward_breaker_spark_rat.is_processing()
			if _lower_deck_forward_breaker_spark_rat != null
			else false
		),
		"entity_id": (
			int(_lower_deck_forward_breaker_spark_rat.call("get_entity_id"))
			if (
				_lower_deck_forward_breaker_spark_rat != null
				and _lower_deck_forward_breaker_spark_rat.has_method("get_entity_id")
			)
			else 0
		),
		"sprite_frames_path": (
			sprite.sprite_frames.resource_path
			if sprite != null and sprite.sprite_frames != null
			else ""
		),
		"animation_frame_counts": _get_sprite_animation_frame_counts(sprite),
		"pacing": _get_lower_deck_forward_breaker_pacing_diagnostics(),
		"hazard_present": _lower_deck_forward_breaker_pressure_vent != null,
		"hazard_active": _is_hazard_contact_active(_lower_deck_forward_breaker_pressure_vent),
		"hazard_visible": (
			_lower_deck_forward_breaker_pressure_vent.visible
			if _lower_deck_forward_breaker_pressure_vent != null
			else false
		),
		"hazard_id": String(_get_hazard_id(_lower_deck_forward_breaker_pressure_vent)),
		"hazard_damage": _get_hazard_damage(_lower_deck_forward_breaker_pressure_vent),
		"hazard_cooldown_sec": _get_hazard_cooldown_sec(
			_lower_deck_forward_breaker_pressure_vent
		),
		"hazard_texture_path": (
			String(_lower_deck_forward_breaker_pressure_vent.call(
				"get_visual_texture_path"
			))
			if (
				_lower_deck_forward_breaker_pressure_vent != null
				and _lower_deck_forward_breaker_pressure_vent.has_method(
					"get_visual_texture_path"
				)
			)
			else ""
		),
		"breaker_visible": (
			_lower_deck_forward_pressure_breaker.visible
			if _lower_deck_forward_pressure_breaker != null
			else false
		),
		"breaker_id": _get_lower_deck_forward_pressure_breaker_id(),
		"prompt_text": _get_lower_deck_forward_pressure_breaker_prompt_text(),
		"texture_path": _get_lower_deck_forward_pressure_breaker_texture_path(),
		"enemy_position": (
			_lower_deck_forward_breaker_spark_rat.global_position
			if _lower_deck_forward_breaker_spark_rat != null
			else Vector2.ZERO
		),
		"hazard_position": (
			_lower_deck_forward_breaker_pressure_vent.global_position
			if _lower_deck_forward_breaker_pressure_vent != null
			else Vector2.ZERO
		),
		"breaker_position": _get_lower_deck_forward_pressure_breaker_position(),
		"route_label_text": String(route.get("route_label_text", "")),
	}


## Returns deterministic forward-pressure breaker console diagnostics.
func get_factory_lower_deck_forward_pressure_breaker_diagnostics() -> Dictionary:
	var interaction_area := (
		_lower_deck_forward_pressure_breaker.get_node_or_null("InteractionArea")
		as Area2D
		if _lower_deck_forward_pressure_breaker != null
		else null
	)
	var collision_shape := (
		_lower_deck_forward_pressure_breaker.get_node_or_null(
			"InteractionArea/CollisionShape2D"
		) as CollisionShape2D
		if _lower_deck_forward_pressure_breaker != null
		else null
	)
	var route: Dictionary = get_factory_route_objective_diagnostics()
	var unlock_vfx_snapshot: Dictionary = (
		_get_lower_deck_forward_pressure_breaker_unlock_vfx_snapshot()
	)
	return {
		"present": _lower_deck_forward_pressure_breaker != null,
		"overrun_defeated": _lower_deck_forward_pressure_overrun_defeated,
		"secured": _lower_deck_forward_pressure_breaker_secured,
		"cut": _lower_deck_forward_pressure_breaker_cut,
		"available": _is_lower_deck_forward_pressure_breaker_available(),
		"visible": (
			_lower_deck_forward_pressure_breaker.visible
			if _lower_deck_forward_pressure_breaker != null
			else false
		),
		"breaker_id": _get_lower_deck_forward_pressure_breaker_id(),
		"prompt_text": _get_lower_deck_forward_pressure_breaker_prompt_text(),
		"texture_path": _get_lower_deck_forward_pressure_breaker_texture_path(),
		"interaction_monitoring": interaction_area.monitoring if interaction_area != null else false,
		"interaction_monitorable": interaction_area.monitorable if interaction_area != null else false,
		"collision_disabled": collision_shape.disabled if collision_shape != null else true,
		"position": _get_lower_deck_forward_pressure_breaker_position(),
		"route_label_text": String(route.get("route_label_text", "")),
		"unlock_feedback_texture_path": String(unlock_vfx_snapshot.get("texture_path", "")),
		"unlock_feedback_active": int(unlock_vfx_snapshot.get("active_count", 0)) > 0,
		"unlock_feedback_played": bool(unlock_vfx_snapshot.get("played", false)),
		"unlock_feedback_spawn_count": int(unlock_vfx_snapshot.get("spawn_count", 0)),
	}


## Returns deterministic forward-pressure relief ambush diagnostics for tests and MCP probes.
func get_factory_lower_deck_forward_pressure_relief_ambush_diagnostics() -> Dictionary:
	var sprite: AnimatedSprite2D = (
		_lower_deck_forward_relief_ambush_spark_rat.get_node_or_null("Sprite")
		as AnimatedSprite2D
		if _lower_deck_forward_relief_ambush_spark_rat != null
		else null
	)
	var route: Dictionary = get_factory_route_objective_diagnostics()
	return {
		"present": (
			_lower_deck_forward_relief_ambush_spark_rat != null
			and _lower_deck_forward_relief_ambush_pressure_vent != null
		),
		"available": _is_lower_deck_forward_pressure_relief_ambush_available(),
		"active": _is_lower_deck_forward_pressure_relief_ambush_active(),
		"defeated": _lower_deck_forward_pressure_relief_ambush_defeated,
		"breaker_cut": _lower_deck_forward_pressure_breaker_cut,
		"activation_x": FACTORY_LOWER_DECK_FORWARD_RELIEF_AMBUSH_ACTIVATION_X,
		"enemy_visible": (
			_lower_deck_forward_relief_ambush_spark_rat.visible
			if _lower_deck_forward_relief_ambush_spark_rat != null
			else false
		),
		"enemy_has_target": _does_lower_deck_forward_relief_ambush_have_target(),
		"enemy_physics_enabled": (
			_lower_deck_forward_relief_ambush_spark_rat.is_physics_processing()
			if _lower_deck_forward_relief_ambush_spark_rat != null
			else false
		),
		"enemy_process_enabled": (
			_lower_deck_forward_relief_ambush_spark_rat.is_processing()
			if _lower_deck_forward_relief_ambush_spark_rat != null
			else false
		),
		"entity_id": (
			int(_lower_deck_forward_relief_ambush_spark_rat.call("get_entity_id"))
			if (
				_lower_deck_forward_relief_ambush_spark_rat != null
				and _lower_deck_forward_relief_ambush_spark_rat.has_method(
					"get_entity_id"
				)
			)
			else 0
		),
		"sprite_frames_path": (
			sprite.sprite_frames.resource_path
			if sprite != null and sprite.sprite_frames != null
			else ""
		),
		"animation_frame_counts": _get_sprite_animation_frame_counts(sprite),
		"pacing": _get_lower_deck_forward_relief_ambush_pacing_diagnostics(),
		"hazard_present": _lower_deck_forward_relief_ambush_pressure_vent != null,
		"hazard_active": _is_hazard_contact_active(
			_lower_deck_forward_relief_ambush_pressure_vent
		),
		"hazard_visible": (
			_lower_deck_forward_relief_ambush_pressure_vent.visible
			if _lower_deck_forward_relief_ambush_pressure_vent != null
			else false
		),
		"hazard_id": String(_get_hazard_id(
			_lower_deck_forward_relief_ambush_pressure_vent
		)),
		"hazard_damage": _get_hazard_damage(
			_lower_deck_forward_relief_ambush_pressure_vent
		),
		"hazard_cooldown_sec": _get_hazard_cooldown_sec(
			_lower_deck_forward_relief_ambush_pressure_vent
		),
		"hazard_texture_path": (
			String(_lower_deck_forward_relief_ambush_pressure_vent.call(
				"get_visual_texture_path"
			))
			if (
				_lower_deck_forward_relief_ambush_pressure_vent != null
				and _lower_deck_forward_relief_ambush_pressure_vent.has_method(
					"get_visual_texture_path"
				)
			)
			else ""
		),
		"enemy_position": (
			_lower_deck_forward_relief_ambush_spark_rat.global_position
			if _lower_deck_forward_relief_ambush_spark_rat != null
			else Vector2.ZERO
		),
			"hazard_position": (
				_lower_deck_forward_relief_ambush_pressure_vent.global_position
				if _lower_deck_forward_relief_ambush_pressure_vent != null
				else Vector2.ZERO
			),
			"route_label_text": (
				"Survive Forward Pressure Relief Ambush"
				if _is_lower_deck_forward_pressure_relief_ambush_active()
				else (
					"Forward Pressure Relief Ambush Cleared"
					if _lower_deck_forward_pressure_relief_ambush_defeated
					else String(route.get("route_label_text", ""))
				)
			),
		}


## Returns deterministic forward-pressure Coil Rat diagnostics for tests and MCP probes.
func get_factory_lower_deck_forward_pressure_coil_rat_breakthrough_diagnostics() -> Dictionary:
	var sprite: AnimatedSprite2D = (
		_lower_deck_forward_pressure_coil_rat.get_node_or_null("Sprite")
		as AnimatedSprite2D
		if _lower_deck_forward_pressure_coil_rat != null
		else null
	)
	var route: Dictionary = get_factory_route_objective_diagnostics()
	return {
		"present": _lower_deck_forward_pressure_coil_rat != null,
		"available": _is_lower_deck_forward_pressure_coil_rat_available(),
		"active": _is_lower_deck_forward_pressure_coil_rat_active(),
		"defeated": _lower_deck_forward_pressure_coil_rat_defeated,
		"relief_defeated": _lower_deck_forward_pressure_relief_ambush_defeated,
		"activation_x": FACTORY_LOWER_DECK_FORWARD_COIL_RAT_ACTIVATION_X,
		"enemy_visible": (
			_lower_deck_forward_pressure_coil_rat.visible
			if _lower_deck_forward_pressure_coil_rat != null
			else false
		),
		"enemy_has_target": _does_lower_deck_forward_pressure_coil_rat_have_target(),
		"enemy_physics_enabled": (
			_lower_deck_forward_pressure_coil_rat.is_physics_processing()
			if _lower_deck_forward_pressure_coil_rat != null
			else false
		),
		"enemy_process_enabled": (
			_lower_deck_forward_pressure_coil_rat.is_processing()
			if _lower_deck_forward_pressure_coil_rat != null
			else false
		),
		"entity_id": (
			int(_lower_deck_forward_pressure_coil_rat.call("get_entity_id"))
			if (
				_lower_deck_forward_pressure_coil_rat != null
				and _lower_deck_forward_pressure_coil_rat.has_method("get_entity_id")
			)
			else 0
		),
		"enemy_family_id": (
			String(_lower_deck_forward_pressure_coil_rat.call("get_enemy_family_id"))
			if (
				_lower_deck_forward_pressure_coil_rat != null
				and _lower_deck_forward_pressure_coil_rat.has_method("get_enemy_family_id")
			)
			else ""
		),
		"sprite_frames_path": (
			sprite.sprite_frames.resource_path
			if sprite != null and sprite.sprite_frames != null
			else ""
		),
		"animation_frame_counts": _get_sprite_animation_frame_counts(sprite),
		"pacing": _get_lower_deck_forward_pressure_coil_rat_pacing_diagnostics(),
		"enemy_position": (
			_lower_deck_forward_pressure_coil_rat.global_position
			if _lower_deck_forward_pressure_coil_rat != null
			else Vector2.ZERO
		),
		"route_label_text": String(route.get("route_label_text", "")),
	}


## Returns deterministic forward-pressure Coil Pincer diagnostics for tests and MCP probes.
func get_factory_lower_deck_forward_pressure_coil_pincer_diagnostics() -> Dictionary:
	var spark_sprite: AnimatedSprite2D = (
		_lower_deck_forward_pressure_coil_pincer_spark_rat.get_node_or_null("Sprite")
		as AnimatedSprite2D
		if _lower_deck_forward_pressure_coil_pincer_spark_rat != null
		else null
	)
	var coil_sprite: AnimatedSprite2D = (
		_lower_deck_forward_pressure_coil_pincer_coil_rat.get_node_or_null("Sprite")
		as AnimatedSprite2D
		if _lower_deck_forward_pressure_coil_pincer_coil_rat != null
		else null
	)
	var route: Dictionary = get_factory_route_objective_diagnostics()
	return {
		"present": (
			_lower_deck_forward_pressure_coil_pincer_spark_rat != null
			and _lower_deck_forward_pressure_coil_pincer_coil_rat != null
		),
		"available": _is_lower_deck_forward_pressure_coil_pincer_available(),
		"active": _is_lower_deck_forward_pressure_coil_pincer_active(),
		"cleared": _is_lower_deck_forward_pressure_coil_pincer_cleared(),
		"coil_breakthrough_defeated": _lower_deck_forward_pressure_coil_rat_defeated,
		"activation_x": FACTORY_LOWER_DECK_FORWARD_COIL_PINCER_ACTIVATION_X,
		"spark_visible": (
			_lower_deck_forward_pressure_coil_pincer_spark_rat.visible
			if _lower_deck_forward_pressure_coil_pincer_spark_rat != null
			else false
		),
		"coil_visible": (
			_lower_deck_forward_pressure_coil_pincer_coil_rat.visible
			if _lower_deck_forward_pressure_coil_pincer_coil_rat != null
			else false
		),
		"spark_has_target": _does_lower_deck_forward_pressure_coil_pincer_spark_rat_have_target(),
		"coil_has_target": _does_lower_deck_forward_pressure_coil_pincer_coil_rat_have_target(),
		"spark_physics_enabled": (
			_lower_deck_forward_pressure_coil_pincer_spark_rat.is_physics_processing()
			if _lower_deck_forward_pressure_coil_pincer_spark_rat != null
			else false
		),
		"coil_physics_enabled": (
			_lower_deck_forward_pressure_coil_pincer_coil_rat.is_physics_processing()
			if _lower_deck_forward_pressure_coil_pincer_coil_rat != null
			else false
		),
		"spark_process_enabled": (
			_lower_deck_forward_pressure_coil_pincer_spark_rat.is_processing()
			if _lower_deck_forward_pressure_coil_pincer_spark_rat != null
			else false
		),
		"coil_process_enabled": (
			_lower_deck_forward_pressure_coil_pincer_coil_rat.is_processing()
			if _lower_deck_forward_pressure_coil_pincer_coil_rat != null
			else false
		),
		"spark_defeated": _lower_deck_forward_pressure_coil_pincer_spark_rat_defeated,
		"coil_defeated": _lower_deck_forward_pressure_coil_pincer_coil_rat_defeated,
		"spark_entity_id": (
			int(_lower_deck_forward_pressure_coil_pincer_spark_rat.call("get_entity_id"))
			if (
				_lower_deck_forward_pressure_coil_pincer_spark_rat != null
				and _lower_deck_forward_pressure_coil_pincer_spark_rat.has_method(
					"get_entity_id"
				)
			)
			else 0
		),
		"coil_entity_id": (
			int(_lower_deck_forward_pressure_coil_pincer_coil_rat.call("get_entity_id"))
			if (
				_lower_deck_forward_pressure_coil_pincer_coil_rat != null
				and _lower_deck_forward_pressure_coil_pincer_coil_rat.has_method(
					"get_entity_id"
				)
			)
			else 0
		),
		"spark_family_id": (
			String(_lower_deck_forward_pressure_coil_pincer_spark_rat.call(
				"get_enemy_family_id"
			))
			if (
				_lower_deck_forward_pressure_coil_pincer_spark_rat != null
				and _lower_deck_forward_pressure_coil_pincer_spark_rat.has_method(
					"get_enemy_family_id"
				)
			)
			else ""
		),
		"coil_family_id": (
			String(_lower_deck_forward_pressure_coil_pincer_coil_rat.call(
				"get_enemy_family_id"
			))
			if (
				_lower_deck_forward_pressure_coil_pincer_coil_rat != null
				and _lower_deck_forward_pressure_coil_pincer_coil_rat.has_method(
					"get_enemy_family_id"
				)
			)
			else ""
		),
		"spark_sprite_frames_path": (
			spark_sprite.sprite_frames.resource_path
			if spark_sprite != null and spark_sprite.sprite_frames != null
			else ""
		),
		"coil_sprite_frames_path": (
			coil_sprite.sprite_frames.resource_path
			if coil_sprite != null and coil_sprite.sprite_frames != null
			else ""
		),
		"spark_animation_frame_counts": _get_sprite_animation_frame_counts(spark_sprite),
		"coil_animation_frame_counts": _get_sprite_animation_frame_counts(coil_sprite),
		"pacing": _get_lower_deck_forward_pressure_coil_pincer_pacing_diagnostics(),
		"spark_position": (
			_lower_deck_forward_pressure_coil_pincer_spark_rat.global_position
			if _lower_deck_forward_pressure_coil_pincer_spark_rat != null
			else Vector2.ZERO
		),
		"coil_position": (
			_lower_deck_forward_pressure_coil_pincer_coil_rat.global_position
			if _lower_deck_forward_pressure_coil_pincer_coil_rat != null
			else Vector2.ZERO
		),
		"route_label_text": String(route.get("route_label_text", "")),
	}


## Returns deterministic forward-pressure Coil Aftershock diagnostics.
func get_factory_lower_deck_forward_pressure_coil_aftershock_diagnostics() -> Dictionary:
	var coil_sprite: AnimatedSprite2D = (
		_lower_deck_forward_pressure_coil_aftershock_coil_rat.get_node_or_null("Sprite")
		as AnimatedSprite2D
		if _lower_deck_forward_pressure_coil_aftershock_coil_rat != null
		else null
	)
	var route: Dictionary = get_factory_route_objective_diagnostics()
	return {
		"present": _lower_deck_forward_pressure_coil_aftershock_coil_rat != null,
		"available": _is_lower_deck_forward_pressure_coil_aftershock_available(),
		"active": _is_lower_deck_forward_pressure_coil_aftershock_active(),
		"cleared": _lower_deck_forward_pressure_coil_aftershock_defeated,
		"coil_pincer_cleared": _is_lower_deck_forward_pressure_coil_pincer_cleared(),
		"activation_x": FACTORY_LOWER_DECK_FORWARD_COIL_AFTERSHOCK_ACTIVATION_X,
		"coil_visible": (
			_lower_deck_forward_pressure_coil_aftershock_coil_rat.visible
			if _lower_deck_forward_pressure_coil_aftershock_coil_rat != null
			else false
		),
		"coil_has_target": (
			_does_lower_deck_forward_pressure_coil_aftershock_coil_rat_have_target()
		),
		"coil_physics_enabled": (
			_lower_deck_forward_pressure_coil_aftershock_coil_rat.is_physics_processing()
			if _lower_deck_forward_pressure_coil_aftershock_coil_rat != null
			else false
		),
		"coil_process_enabled": (
			_lower_deck_forward_pressure_coil_aftershock_coil_rat.is_processing()
			if _lower_deck_forward_pressure_coil_aftershock_coil_rat != null
			else false
		),
		"coil_defeated": _lower_deck_forward_pressure_coil_aftershock_defeated,
		"coil_entity_id": (
			int(_lower_deck_forward_pressure_coil_aftershock_coil_rat.call("get_entity_id"))
			if (
				_lower_deck_forward_pressure_coil_aftershock_coil_rat != null
				and _lower_deck_forward_pressure_coil_aftershock_coil_rat.has_method(
					"get_entity_id"
				)
			)
			else 0
		),
		"coil_family_id": (
			String(_lower_deck_forward_pressure_coil_aftershock_coil_rat.call(
				"get_enemy_family_id"
			))
			if (
				_lower_deck_forward_pressure_coil_aftershock_coil_rat != null
				and _lower_deck_forward_pressure_coil_aftershock_coil_rat.has_method(
					"get_enemy_family_id"
				)
			)
			else ""
		),
		"coil_sprite_frames_path": (
			coil_sprite.sprite_frames.resource_path
			if coil_sprite != null and coil_sprite.sprite_frames != null
			else ""
		),
		"coil_animation_frame_counts": _get_sprite_animation_frame_counts(coil_sprite),
		"pacing": _get_lower_deck_forward_pressure_coil_aftershock_pacing_diagnostics(),
		"coil_position": (
			_lower_deck_forward_pressure_coil_aftershock_coil_rat.global_position
			if _lower_deck_forward_pressure_coil_aftershock_coil_rat != null
			else Vector2.ZERO
		),
		"route_label_text": String(route.get("route_label_text", "")),
	}


## Returns deterministic forward-pressure aftershock exit skirmish diagnostics.
func get_factory_lower_deck_forward_pressure_aftershock_exit_skirmish_diagnostics(
) -> Dictionary:
	var spark_sprite: AnimatedSprite2D = (
		_lower_deck_forward_pressure_aftershock_exit_spark_rat.get_node_or_null("Sprite")
		as AnimatedSprite2D
		if _lower_deck_forward_pressure_aftershock_exit_spark_rat != null
		else null
	)
	var coil_sprite: AnimatedSprite2D = (
		_lower_deck_forward_pressure_aftershock_exit_coil_rat.get_node_or_null("Sprite")
		as AnimatedSprite2D
		if _lower_deck_forward_pressure_aftershock_exit_coil_rat != null
		else null
	)
	var route: Dictionary = get_factory_route_objective_diagnostics()
	return {
		"present": (
			_lower_deck_forward_pressure_aftershock_exit_spark_rat != null
			and _lower_deck_forward_pressure_aftershock_exit_coil_rat != null
		),
		"available": (
			_is_lower_deck_forward_pressure_aftershock_exit_skirmish_available()
		),
		"active": _is_lower_deck_forward_pressure_aftershock_exit_skirmish_active(),
		"cleared": _is_lower_deck_forward_pressure_aftershock_exit_skirmish_cleared(),
		"aftershock_reward_cache_claimed": (
			_lower_deck_forward_pressure_aftershock_reward_cache_claimed
		),
		"encounter_id": String(
			FACTORY_LOWER_DECK_FORWARD_PRESSURE_AFTERSHOCK_EXIT_SKIRMISH_ID
		),
		"activation_x": FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_EXIT_SKIRMISH_ACTIVATION_X,
		"spark_visible": (
			_lower_deck_forward_pressure_aftershock_exit_spark_rat.visible
			if _lower_deck_forward_pressure_aftershock_exit_spark_rat != null
			else false
		),
		"coil_visible": (
			_lower_deck_forward_pressure_aftershock_exit_coil_rat.visible
			if _lower_deck_forward_pressure_aftershock_exit_coil_rat != null
			else false
		),
		"spark_has_target": (
			_does_lower_deck_forward_pressure_aftershock_exit_spark_rat_have_target()
		),
		"coil_has_target": (
			_does_lower_deck_forward_pressure_aftershock_exit_coil_rat_have_target()
		),
		"spark_physics_enabled": (
			_lower_deck_forward_pressure_aftershock_exit_spark_rat.is_physics_processing()
			if _lower_deck_forward_pressure_aftershock_exit_spark_rat != null
			else false
		),
		"coil_physics_enabled": (
			_lower_deck_forward_pressure_aftershock_exit_coil_rat.is_physics_processing()
			if _lower_deck_forward_pressure_aftershock_exit_coil_rat != null
			else false
		),
		"spark_process_enabled": (
			_lower_deck_forward_pressure_aftershock_exit_spark_rat.is_processing()
			if _lower_deck_forward_pressure_aftershock_exit_spark_rat != null
			else false
		),
		"coil_process_enabled": (
			_lower_deck_forward_pressure_aftershock_exit_coil_rat.is_processing()
			if _lower_deck_forward_pressure_aftershock_exit_coil_rat != null
			else false
		),
		"spark_defeated": _lower_deck_forward_pressure_aftershock_exit_spark_rat_defeated,
		"coil_defeated": _lower_deck_forward_pressure_aftershock_exit_coil_rat_defeated,
		"spark_entity_id": _get_enemy_entity_id(
			_lower_deck_forward_pressure_aftershock_exit_spark_rat
		),
		"coil_entity_id": _get_enemy_entity_id(
			_lower_deck_forward_pressure_aftershock_exit_coil_rat
		),
		"spark_family_id": _get_enemy_family_id(
			_lower_deck_forward_pressure_aftershock_exit_spark_rat
		),
		"coil_family_id": _get_enemy_family_id(
			_lower_deck_forward_pressure_aftershock_exit_coil_rat
		),
		"spark_sprite_frames_path": (
			spark_sprite.sprite_frames.resource_path
			if spark_sprite != null and spark_sprite.sprite_frames != null
			else ""
		),
		"coil_sprite_frames_path": (
			coil_sprite.sprite_frames.resource_path
			if coil_sprite != null and coil_sprite.sprite_frames != null
			else ""
		),
		"spark_animation_frame_counts": _get_sprite_animation_frame_counts(spark_sprite),
		"coil_animation_frame_counts": _get_sprite_animation_frame_counts(coil_sprite),
		"pacing": _get_lower_deck_forward_pressure_aftershock_exit_skirmish_pacing_diagnostics(),
		"spark_position": (
			_lower_deck_forward_pressure_aftershock_exit_spark_rat.global_position
			if _lower_deck_forward_pressure_aftershock_exit_spark_rat != null
			else Vector2.ZERO
		),
		"coil_position": (
			_lower_deck_forward_pressure_aftershock_exit_coil_rat.global_position
			if _lower_deck_forward_pressure_aftershock_exit_coil_rat != null
			else Vector2.ZERO
		),
		"route_label_text": String(route.get("route_label_text", "")),
	}


## Returns deterministic Story086 aftershock exhaust diagnostics.
func get_factory_lower_deck_forward_pressure_aftershock_exhaust_diagnostics(
) -> Dictionary:
	var route: Dictionary = get_factory_route_objective_diagnostics()
	return {
		"present": _lower_deck_forward_pressure_aftershock_exhaust_vent != null,
		"available": _is_lower_deck_forward_pressure_aftershock_exhaust_available(),
		"aftershock_exit_skirmish_cleared": (
			_is_lower_deck_forward_pressure_aftershock_exit_skirmish_cleared()
		),
		"visible": (
			_lower_deck_forward_pressure_aftershock_exhaust_vent.visible
			if _lower_deck_forward_pressure_aftershock_exhaust_vent != null
			else false
		),
		"monitoring": (
			_lower_deck_forward_pressure_aftershock_exhaust_vent.monitoring
			if _lower_deck_forward_pressure_aftershock_exhaust_vent != null
			else false
		),
		"monitorable": (
			_lower_deck_forward_pressure_aftershock_exhaust_vent.monitorable
			if _lower_deck_forward_pressure_aftershock_exhaust_vent != null
			else false
		),
		"active": _is_lower_deck_forward_pressure_aftershock_exhaust_active(),
		"activated": _lower_deck_forward_pressure_aftershock_exhaust_activated,
		"crossed": _lower_deck_forward_pressure_aftershock_exhaust_crossed,
		"phase": String(_get_lower_deck_forward_pressure_aftershock_exhaust_phase()),
		"elapsed_sec": _lower_deck_forward_pressure_aftershock_exhaust_elapsed_sec,
		"initial_grace_sec": FACTORY_LOWER_DECK_FORWARD_PRESSURE_INITIAL_GRACE_SEC,
		"warning_sec": FACTORY_LOWER_DECK_FORWARD_PRESSURE_WARNING_SEC,
		"active_sec": FACTORY_LOWER_DECK_FORWARD_PRESSURE_ACTIVE_SEC,
		"safe_sec": FACTORY_LOWER_DECK_FORWARD_PRESSURE_SAFE_SEC,
		"activation_x": FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_EXHAUST_ACTIVATION_X,
		"exit_x": FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_EXHAUST_EXIT_X,
		"hazard_present": _lower_deck_forward_pressure_aftershock_exhaust_vent != null,
		"hazard_contact_active": (
			_is_lower_deck_forward_pressure_aftershock_exhaust_contact_active()
		),
		"hazard_visible": (
			_lower_deck_forward_pressure_aftershock_exhaust_vent.visible
			if _lower_deck_forward_pressure_aftershock_exhaust_vent != null
			else false
		),
		"hazard_id": String(_get_hazard_id(
			_lower_deck_forward_pressure_aftershock_exhaust_vent
		)),
		"hazard_damage": _get_hazard_damage(
			_lower_deck_forward_pressure_aftershock_exhaust_vent
		),
		"hazard_cooldown_sec": _get_hazard_cooldown_sec(
			_lower_deck_forward_pressure_aftershock_exhaust_vent
		),
		"hazard_texture_path": (
			String(_lower_deck_forward_pressure_aftershock_exhaust_vent.call(
				"get_visual_texture_path"
			))
			if (
				_lower_deck_forward_pressure_aftershock_exhaust_vent != null
				and _lower_deck_forward_pressure_aftershock_exhaust_vent.has_method(
					"get_visual_texture_path"
				)
			)
			else ""
		),
		"hazard_position": (
			_lower_deck_forward_pressure_aftershock_exhaust_vent.global_position
			if _lower_deck_forward_pressure_aftershock_exhaust_vent != null
			else Vector2.ZERO
		),
		"collision_layer": (
			_lower_deck_forward_pressure_aftershock_exhaust_vent.collision_layer
			if _lower_deck_forward_pressure_aftershock_exhaust_vent != null
			else 0
		),
		"collision_mask": (
			_lower_deck_forward_pressure_aftershock_exhaust_vent.collision_mask
			if _lower_deck_forward_pressure_aftershock_exhaust_vent != null
			else 0
		),
		"route_label_text": String(route.get("route_label_text", "")),
	}


## Returns deterministic Story087 aftershock exhaust pursuer diagnostics.
func get_factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_diagnostics(
) -> Dictionary:
	var coil_sprite: AnimatedSprite2D = (
		_lower_deck_forward_pressure_aftershock_exhaust_pursuer_coil_rat.get_node_or_null(
			"Sprite"
		) as AnimatedSprite2D
		if _lower_deck_forward_pressure_aftershock_exhaust_pursuer_coil_rat != null
		else null
	)
	var route: Dictionary = get_factory_route_objective_diagnostics()
	return {
		"present": (
			_lower_deck_forward_pressure_aftershock_exhaust_pursuer_coil_rat != null
		),
		"available": (
			_is_lower_deck_forward_pressure_aftershock_exhaust_pursuer_available()
		),
		"active": _is_lower_deck_forward_pressure_aftershock_exhaust_pursuer_active(),
		"cleared": _lower_deck_forward_pressure_aftershock_exhaust_pursuer_defeated,
		"aftershock_exhaust_crossed": (
			_lower_deck_forward_pressure_aftershock_exhaust_crossed
		),
		"encounter_id": String(
			FACTORY_LOWER_DECK_FORWARD_PRESSURE_AFTERSHOCK_EXHAUST_PURSUER_ID
		),
		"activation_x": (
			FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_EXHAUST_PURSUER_ACTIVATION_X
		),
		"coil_visible": (
			_lower_deck_forward_pressure_aftershock_exhaust_pursuer_coil_rat.visible
			if _lower_deck_forward_pressure_aftershock_exhaust_pursuer_coil_rat != null
			else false
		),
		"coil_has_target": (
			_does_lower_deck_forward_pressure_aftershock_exhaust_pursuer_coil_rat_have_target()
		),
		"coil_physics_enabled": (
			_lower_deck_forward_pressure_aftershock_exhaust_pursuer_coil_rat.is_physics_processing()
			if _lower_deck_forward_pressure_aftershock_exhaust_pursuer_coil_rat != null
			else false
		),
		"coil_process_enabled": (
			_lower_deck_forward_pressure_aftershock_exhaust_pursuer_coil_rat.is_processing()
			if _lower_deck_forward_pressure_aftershock_exhaust_pursuer_coil_rat != null
			else false
		),
		"coil_defeated": _lower_deck_forward_pressure_aftershock_exhaust_pursuer_defeated,
		"coil_entity_id": _get_enemy_entity_id(
			_lower_deck_forward_pressure_aftershock_exhaust_pursuer_coil_rat
		),
		"coil_family_id": _get_enemy_family_id(
			_lower_deck_forward_pressure_aftershock_exhaust_pursuer_coil_rat
		),
		"coil_sprite_frames_path": (
			coil_sprite.sprite_frames.resource_path
			if coil_sprite != null and coil_sprite.sprite_frames != null
			else ""
		),
		"coil_animation_frame_counts": _get_sprite_animation_frame_counts(coil_sprite),
		"pacing": (
			_get_lower_deck_forward_pressure_aftershock_exhaust_pursuer_pacing_diagnostics()
		),
		"coil_position": (
			_lower_deck_forward_pressure_aftershock_exhaust_pursuer_coil_rat.global_position
			if _lower_deck_forward_pressure_aftershock_exhaust_pursuer_coil_rat != null
			else Vector2.ZERO
		),
		"route_label_text": String(route.get("route_label_text", "")),
	}


## Returns deterministic Story089 aftershock exhaust flank ambush diagnostics.
func get_factory_lower_deck_forward_pressure_aftershock_exhaust_flank_ambush_diagnostics(
) -> Dictionary:
	var spark_rat: Node2D = (
		_lower_deck_forward_pressure_aftershock_exhaust_flank_spark_rat
		if is_instance_valid(
			_lower_deck_forward_pressure_aftershock_exhaust_flank_spark_rat
		)
		else null
	)
	var spark_sprite: AnimatedSprite2D = (
		spark_rat.get_node_or_null(
			"Sprite"
		) as AnimatedSprite2D
		if spark_rat != null
		else null
	)
	var route: Dictionary = get_factory_route_objective_diagnostics()
	return {
		"present": (
			spark_rat != null
			and _lower_deck_forward_pressure_aftershock_exhaust_flank_vent != null
		),
		"available": (
			_is_lower_deck_forward_pressure_aftershock_exhaust_flank_available()
		),
		"active": _is_lower_deck_forward_pressure_aftershock_exhaust_flank_active(),
		"cleared": _lower_deck_forward_pressure_aftershock_exhaust_flank_spark_rat_defeated,
		"exhaust_pursuer_reward_cache_claimed": (
			_lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache_claimed
		),
		"encounter_id": String(
			FACTORY_LOWER_DECK_FORWARD_PRESSURE_AFTERSHOCK_EXHAUST_FLANK_ID
		),
		"activation_x": (
			FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_EXHAUST_FLANK_ACTIVATION_X
		),
		"spark_visible": (
			spark_rat.visible
			if spark_rat != null
			else false
		),
		"spark_has_target": (
			_does_lower_deck_forward_pressure_aftershock_exhaust_flank_spark_rat_have_target()
		),
		"spark_physics_enabled": (
			spark_rat.is_physics_processing()
			if spark_rat != null
			else false
		),
		"spark_process_enabled": (
			spark_rat.is_processing()
			if spark_rat != null
			else false
		),
		"spark_defeated": (
			_lower_deck_forward_pressure_aftershock_exhaust_flank_spark_rat_defeated
		),
		"spark_entity_id": (
			0
			if _lower_deck_forward_pressure_aftershock_exhaust_flank_spark_rat_defeated
			else _get_enemy_entity_id(spark_rat)
		),
		"spark_family_id": _get_enemy_family_id(spark_rat),
		"spark_sprite_frames_path": (
			spark_sprite.sprite_frames.resource_path
			if spark_sprite != null and spark_sprite.sprite_frames != null
			else ""
		),
		"spark_animation_frame_counts": _get_sprite_animation_frame_counts(
			spark_sprite
		),
		"pacing": (
			_get_lower_deck_forward_pressure_aftershock_exhaust_flank_pacing_diagnostics()
		),
		"spark_position": (
			spark_rat.global_position
			if spark_rat != null
			else Vector2.ZERO
		),
		"hazard_present": (
			_lower_deck_forward_pressure_aftershock_exhaust_flank_vent != null
		),
		"hazard_visible": (
			_lower_deck_forward_pressure_aftershock_exhaust_flank_vent.visible
			if _lower_deck_forward_pressure_aftershock_exhaust_flank_vent != null
			else false
		),
		"hazard_contact_active": (
			_is_lower_deck_forward_pressure_aftershock_exhaust_flank_contact_active()
		),
		"hazard_id": String(_get_hazard_id(
			_lower_deck_forward_pressure_aftershock_exhaust_flank_vent
		)),
		"hazard_damage": _get_hazard_damage(
			_lower_deck_forward_pressure_aftershock_exhaust_flank_vent
		),
		"hazard_cooldown_sec": _get_hazard_cooldown_sec(
			_lower_deck_forward_pressure_aftershock_exhaust_flank_vent
		),
		"hazard_texture_path": (
			String(_lower_deck_forward_pressure_aftershock_exhaust_flank_vent.call(
				"get_visual_texture_path"
			))
			if (
				_lower_deck_forward_pressure_aftershock_exhaust_flank_vent != null
				and _lower_deck_forward_pressure_aftershock_exhaust_flank_vent.has_method(
					"get_visual_texture_path"
				)
			)
			else ""
		),
		"hazard_position": (
			_lower_deck_forward_pressure_aftershock_exhaust_flank_vent.global_position
			if _lower_deck_forward_pressure_aftershock_exhaust_flank_vent != null
			else Vector2.ZERO
		),
		"route_label_text": String(route.get("route_label_text", "")),
	}


## Returns visual defeat burst diagnostics for tests and MCP probes.
func get_factory_checkpoint_overdrive_defeat_burst_diagnostics() -> Dictionary:
	return {
		"present": (
			_checkpoint_overdrive_left_defeat_burst != null
			and _checkpoint_overdrive_right_defeat_burst != null
		),
		"texture_path": _get_checkpoint_overdrive_defeat_burst_texture_path(),
		"last_side": String(_last_checkpoint_overdrive_defeat_burst_side),
		"left_visible": (
			_checkpoint_overdrive_left_defeat_burst.visible
			if _checkpoint_overdrive_left_defeat_burst != null
			else false
		),
		"right_visible": (
			_checkpoint_overdrive_right_defeat_burst.visible
			if _checkpoint_overdrive_right_defeat_burst != null
			else false
		),
		"left_position": (
			_checkpoint_overdrive_left_defeat_burst.global_position
			if _checkpoint_overdrive_left_defeat_burst != null
			else Vector2.ZERO
		),
		"right_position": (
			_checkpoint_overdrive_right_defeat_burst.global_position
			if _checkpoint_overdrive_right_defeat_burst != null
			else Vector2.ZERO
		),
	}


## Returns deterministic return-patrol reward cache diagnostics for tests and MCP probes.
func get_factory_return_patrol_reward_cache_diagnostics() -> Dictionary:
	return {
		"present": _return_patrol_reward_cache != null,
		"visible": (
			_return_patrol_reward_cache.visible
			if _return_patrol_reward_cache != null
			else false
		),
		"cache_id": (
			String(_return_patrol_reward_cache.call("get_cache_id"))
			if (
				_return_patrol_reward_cache != null
				and _return_patrol_reward_cache.has_method("get_cache_id")
			)
			else ""
		),
		"texture_path": (
			String(_return_patrol_reward_cache.call("get_visual_texture_path"))
			if (
				_return_patrol_reward_cache != null
				and _return_patrol_reward_cache.has_method("get_visual_texture_path")
			)
			else ""
		),
		"available": (
			bool(_return_patrol_reward_cache.call("is_available"))
			if (
				_return_patrol_reward_cache != null
				and _return_patrol_reward_cache.has_method("is_available")
			)
			else false
		),
		"claim_available": (
			bool(_return_patrol_reward_cache.call("is_claim_available"))
			if (
				_return_patrol_reward_cache != null
				and _return_patrol_reward_cache.has_method("is_claim_available")
			)
			else false
		),
		"claimed": _return_patrol_reward_cache_claimed,
		"prompt_text": _get_return_patrol_reward_cache_prompt_text(),
		"return_patrol_active": _return_patrol_activated and not _return_patrol_defeated,
		"return_patrol_defeated": _return_patrol_defeated,
		"position": (
			(_return_patrol_reward_cache as Node2D).global_position
			if _return_patrol_reward_cache != null and _return_patrol_reward_cache is Node2D
			else Vector2.ZERO
		),
		"last_reward": _last_return_patrol_reward_cache_reward.duplicate(true),
		"last_claim_feedback": _last_return_patrol_reward_cache_claim_feedback.duplicate(true),
	}


## Returns deterministic checkpoint-overdrive reward cache diagnostics.
func get_factory_checkpoint_overdrive_reward_cache_diagnostics() -> Dictionary:
	return {
		"present": _checkpoint_overdrive_reward_cache != null,
		"visible": (
			_checkpoint_overdrive_reward_cache.visible
			if _checkpoint_overdrive_reward_cache != null
			else false
		),
		"cache_id": (
			String(_checkpoint_overdrive_reward_cache.call("get_cache_id"))
			if (
				_checkpoint_overdrive_reward_cache != null
				and _checkpoint_overdrive_reward_cache.has_method("get_cache_id")
			)
			else ""
		),
		"texture_path": (
			String(_checkpoint_overdrive_reward_cache.call("get_visual_texture_path"))
			if (
				_checkpoint_overdrive_reward_cache != null
				and _checkpoint_overdrive_reward_cache.has_method("get_visual_texture_path")
			)
			else ""
		),
		"available": (
			bool(_checkpoint_overdrive_reward_cache.call("is_available"))
			if (
				_checkpoint_overdrive_reward_cache != null
				and _checkpoint_overdrive_reward_cache.has_method("is_available")
			)
			else false
		),
		"claim_available": (
			bool(_checkpoint_overdrive_reward_cache.call("is_claim_available"))
			if (
				_checkpoint_overdrive_reward_cache != null
				and _checkpoint_overdrive_reward_cache.has_method("is_claim_available")
			)
			else false
		),
		"claimed": _checkpoint_overdrive_reward_cache_claimed,
		"prompt_text": _get_checkpoint_overdrive_reward_cache_prompt_text(),
		"overdrive_duo_activated": _checkpoint_overdrive_duo_activated,
		"overdrive_duo_cleared": _is_checkpoint_overdrive_duo_cleared(),
		"position": (
			(_checkpoint_overdrive_reward_cache as Node2D).global_position
			if (
				_checkpoint_overdrive_reward_cache != null
				and _checkpoint_overdrive_reward_cache is Node2D
			)
			else Vector2.ZERO
		),
		"last_reward": _last_checkpoint_overdrive_reward_cache_reward.duplicate(true),
		"last_claim_feedback": (
			_last_checkpoint_overdrive_reward_cache_claim_feedback.duplicate(true)
		),
	}


## Returns deterministic return checkpoint diagnostics for tests and MCP probes.
func get_factory_return_checkpoint_diagnostics() -> Dictionary:
	var checkpoint_position: Vector2 = (
		(_return_checkpoint as Node2D).global_position
		if _return_checkpoint != null and _return_checkpoint is Node2D
		else Vector2.ZERO
	)
	return {
		"present": _return_checkpoint != null,
		"visible": _return_checkpoint.visible if _return_checkpoint != null else false,
		"available": _return_patrol_defeated,
		"activated": _return_checkpoint_activated,
		"savepoint_id": _get_return_checkpoint_savepoint_id(),
		"scene_id": _get_return_checkpoint_scene_id(),
		"spawn_point": _get_return_checkpoint_spawn_point(),
		"display_name": _get_return_checkpoint_display_name(),
		"prompt_text": _get_return_checkpoint_prompt_text(),
		"texture_path": _get_return_checkpoint_texture_path(),
		"position": checkpoint_position,
		"player_position": _player.global_position if _player != null else Vector2.ZERO,
		"last_checkpoint": _last_return_checkpoint.duplicate(true),
	}


## Returns deterministic Spark Rat dodge-counter diagnostics for tests and MCP probes.
func get_factory_spark_rat_counter_diagnostics() -> Dictionary:
	var diagnostics: Dictionary = {
		"last_bite_resolved": false,
		"last_bite_dodged": false,
		"last_bite_damage_applied": false,
		"last_bite_damage": 0,
		"last_bite_weapon_id": "",
		"last_bite_source": "",
	}
	if not _last_spark_rat_counter_diagnostics.is_empty():
		diagnostics.merge(_last_spark_rat_counter_diagnostics, true)
	diagnostics["counter_window_frames"] = _get_player_dodge_counter_window()
	diagnostics["counter_ready"] = int(diagnostics["counter_window_frames"]) > 0
	diagnostics["player_dodge_iframe_active"] = _is_player_dodge_iframe_active()
	diagnostics["spark_rat_active"] = _spark_rat_activated and not _spark_rat_defeated
	return diagnostics


## Returns deterministic Factory Route objective diagnostics for tests and MCP probes.
func get_factory_route_objective_diagnostics() -> Dictionary:
	var route_label := get_node_or_null("RouteLabel") as Label
	var objective_id: StringName = _get_factory_route_objective_id()
	return {
		"objective_id": String(objective_id),
		"objective_text": _get_factory_route_objective_text(objective_id),
		"complete": is_factory_route_objective_complete(),
		"scene_id": String(get_meta("scene_id", String(FACTORY_SCENE_ID))),
		"arrival_spawn_present": _spawn != null,
		"player_present": _player != null,
		"encounter_cleared": _encounter_cleared,
		"deep_guard_activated": _deep_guard_activated,
		"deep_guard_defeated": _deep_guard_defeated,
		"deep_route_cleared": _deep_route_cleared,
		"spark_rat_activated": _spark_rat_activated,
		"spark_rat_defeated": _spark_rat_defeated,
		"return_patrol_activated": _return_patrol_activated,
		"return_patrol_defeated": _return_patrol_defeated,
		"checkpoint_forward_patrol_activated": _checkpoint_forward_patrol_activated,
		"checkpoint_forward_patrol_defeated": _checkpoint_forward_patrol_defeated,
		"checkpoint_rear_ambush_activated": _checkpoint_rear_ambush_activated,
		"checkpoint_rear_ambush_defeated": _checkpoint_rear_ambush_defeated,
		"checkpoint_overdrive_duo_activated": _checkpoint_overdrive_duo_activated,
		"checkpoint_overdrive_left_defeated": _checkpoint_overdrive_left_defeated,
		"checkpoint_overdrive_right_defeated": _checkpoint_overdrive_right_defeated,
		"checkpoint_overdrive_duo_cleared": _is_checkpoint_overdrive_duo_cleared(),
		"lower_deck_skirmish_activated": _lower_deck_skirmish_activated,
		"lower_deck_skirmish_defeated": _lower_deck_skirmish_defeated,
		"lower_deck_parry_gate_unlocked": _lower_deck_parry_gate_unlocked,
		"lower_deck_exit_ambush_activated": _lower_deck_exit_ambush_activated,
		"lower_deck_exit_ambush_defeated": _lower_deck_exit_ambush_defeated,
		"lower_deck_shortcut_activated": _lower_deck_shortcut_activated,
		"lower_deck_shortcut_guard_defeated": _lower_deck_shortcut_guard_defeated,
		"lower_deck_shortcut_unlocked": _lower_deck_shortcut_unlocked,
		"lower_deck_pressure_valve_opened": _lower_deck_pressure_valve_opened,
		"lower_deck_steam_sluice_activated": _lower_deck_steam_sluice_activated,
		"lower_deck_steam_sluice_defeated": _lower_deck_steam_sluice_defeated,
		"lower_deck_deep_bulkhead_guard_activated": (
			_lower_deck_deep_bulkhead_guard_activated
		),
		"lower_deck_deep_bulkhead_guard_defeated": (
			_lower_deck_deep_bulkhead_guard_defeated
		),
		"lower_deck_deep_bulkhead_opened": _lower_deck_deep_bulkhead_opened,
		"lower_deck_breach_corridor_activated": _lower_deck_breach_corridor_activated,
		"lower_deck_breach_front_guard_defeated": (
			_lower_deck_breach_front_guard_defeated
		),
		"lower_deck_breach_rear_ambusher_activated": (
			_lower_deck_breach_rear_ambusher_activated
		),
		"lower_deck_breach_rear_ambusher_defeated": (
			_lower_deck_breach_rear_ambusher_defeated
		),
		"lower_deck_breach_corridor_secured": _lower_deck_breach_corridor_secured,
		"lower_deck_breach_relay_activated": _lower_deck_breach_relay_activated,
		"lower_deck_post_relay_trial_activated": _lower_deck_post_relay_trial_activated,
		"lower_deck_post_relay_trial_defeated": _lower_deck_post_relay_trial_defeated,
		"lower_deck_relay_forward_reward_cache_claimed": (
			_lower_deck_relay_forward_reward_cache_claimed
		),
		"lower_deck_forward_hatch_opened": _lower_deck_forward_hatch_opened,
		"lower_deck_forward_conduit_activated": _lower_deck_forward_conduit_activated,
		"lower_deck_forward_conduit_defeated": _lower_deck_forward_conduit_defeated,
		"lower_deck_forward_pressure_traverse_active": (
			_lower_deck_forward_pressure_traverse_active
		),
		"lower_deck_forward_pressure_traverse_crossed": (
			_lower_deck_forward_pressure_traverse_crossed
		),
		"lower_deck_forward_pressure_counter_ambush_activated": (
			_lower_deck_forward_pressure_counter_ambush_activated
		),
		"lower_deck_forward_pressure_counter_ambush_defeated": (
			_lower_deck_forward_pressure_counter_ambush_defeated
		),
			"lower_deck_forward_pressure_reward_cache_claimed": (
				_lower_deck_forward_pressure_reward_cache_claimed
			),
			"lower_deck_forward_pressure_aftershock_reward_cache_claimed": (
				_lower_deck_forward_pressure_aftershock_reward_cache_claimed
			),
			"lower_deck_forward_pressure_aftershock_exit_skirmish_activated": (
				_lower_deck_forward_pressure_aftershock_exit_skirmish_activated
			),
			"lower_deck_forward_pressure_aftershock_exit_skirmish_cleared": (
				_is_lower_deck_forward_pressure_aftershock_exit_skirmish_cleared()
			),
			"route_label_visible": route_label.visible if route_label != null else false,
		"route_label_text": route_label.text if route_label != null else "",
	}


## Returns deterministic service-lift handoff diagnostics for tests and MCP probes.
func get_factory_service_lift_diagnostics() -> Dictionary:
	var route_label := get_node_or_null("RouteLabel") as Label
	var unlock_vfx_snapshot: Dictionary = _get_service_lift_unlock_vfx_snapshot()
	var available: bool = _is_service_lift_available()
	return {
		"present": _service_lift != null,
		"available": available,
		"activated": _service_lift_activated,
		"activation_ready": _is_service_lift_activation_ready(available),
		"return_patrol_active": _is_return_patrol_blocking_service_lift(),
		"forward_patrol_active": _is_checkpoint_forward_patrol_blocking_service_lift(),
		"rear_ambush_active": _is_checkpoint_rear_ambush_blocking_service_lift(),
		"overdrive_duo_active": _is_checkpoint_overdrive_duo_blocking_service_lift(),
		"endpoint_id": _get_service_lift_endpoint_id(),
		"expected_endpoint_id": String(FACTORY_SERVICE_LIFT_ENDPOINT_ID),
		"texture_path": _get_service_lift_texture_path(),
		"prompt_text": _get_service_lift_prompt_text(),
		"route_cleared": is_factory_route_objective_complete(),
		"route_label_text": route_label.text if route_label != null else "",
		"exit_requested": _service_lift_exit_requested,
		"exit_target_scene_id": String(FACTORY_SERVICE_LIFT_EXIT_SCENE_ID),
		"exit_spawn_point": String(FACTORY_SERVICE_LIFT_EXIT_SPAWN_POINT),
		"exit_rejected_reason": String(_last_service_lift_exit_rejected_reason),
		"scene_manager_present": _is_valid_scene_manager(_resolve_scene_manager_for_runtime()),
		"scene_manager_loading": _is_scene_manager_loading(),
		"scene_manager_pending_scene": _get_scene_manager_pending_scene(),
		"scene_manager_pending_spawn_point": _get_scene_manager_pending_spawn_point(),
		"last_exit_request": _last_service_lift_exit_request.duplicate(true),
		"position": _get_service_lift_position(),
		"player_position": _player.global_position if _player != null else Vector2.ZERO,
		"unlock_feedback_texture_path": String(unlock_vfx_snapshot.get("texture_path", "")),
		"unlock_feedback_active": int(unlock_vfx_snapshot.get("active_count", 0)) > 0,
		"unlock_feedback_played": bool(unlock_vfx_snapshot.get("played", false)),
		"unlock_feedback_spawn_count": int(unlock_vfx_snapshot.get("spawn_count", 0)),
	}


func get_factory_entrance_diagnostics() -> Dictionary:
	var backdrop := get_node_or_null("Background") as TextureRect
	var enemy_sprite := get_node_or_null("FactoryRatMinion/Sprite") as AnimatedSprite2D
	return {
		"scene_id": String(get_meta("scene_id", String(FACTORY_SCENE_ID))),
		"has_spawn": _spawn != null,
		"has_player": _player != null,
		"has_enemy": _enemy != null,
		"backdrop_texture_path": (
			backdrop.texture.resource_path
			if backdrop != null and backdrop.texture != null
			else ""
		),
		"enemy_sprite_frames_path": (
			enemy_sprite.sprite_frames.resource_path
			if enemy_sprite != null and enemy_sprite.sprite_frames != null
			else ""
		),
		"room_clear": get_factory_room_clear_diagnostics(),
		"hazards": get_factory_hazard_diagnostics(),
		"deep_route": get_factory_deep_route_diagnostics(),
		"spark_rat": get_factory_spark_rat_diagnostics(),
		"return_patrol": get_factory_return_patrol_diagnostics(),
		"checkpoint_forward_patrol": get_factory_checkpoint_forward_patrol_diagnostics(),
		"checkpoint_rear_ambush": get_factory_checkpoint_rear_ambush_diagnostics(),
		"checkpoint_overdrive_duo": get_factory_checkpoint_overdrive_duo_diagnostics(),
		"lower_deck_skirmish": get_factory_lower_deck_skirmish_diagnostics(),
		"lower_deck_parry_gate": get_factory_lower_deck_parry_gate_diagnostics(),
		"lower_deck_exit_ambush": get_factory_lower_deck_exit_ambush_diagnostics(),
		"lower_deck_shortcut_seal": get_factory_lower_deck_shortcut_seal_diagnostics(),
		"lower_deck_shortcut_reward_cache": (
			get_factory_lower_deck_shortcut_reward_cache_diagnostics()
		),
		"lower_deck_shortcut_pursuer": (
			get_factory_lower_deck_shortcut_pursuer_diagnostics()
		),
		"lower_deck_pressure_valve": get_factory_lower_deck_pressure_valve_diagnostics(),
		"lower_deck_steam_sluice": get_factory_lower_deck_steam_sluice_diagnostics(),
		"lower_deck_deep_bulkhead": get_factory_lower_deck_deep_bulkhead_diagnostics(),
		"lower_deck_breach_corridor": (
			get_factory_lower_deck_breach_corridor_diagnostics()
		),
		"lower_deck_breach_relay": get_factory_lower_deck_breach_relay_diagnostics(),
		"lower_deck_post_relay_trial": (
			get_factory_lower_deck_post_relay_trial_diagnostics()
		),
		"lower_deck_relay_forward_reward_cache": (
			get_factory_lower_deck_relay_forward_reward_cache_diagnostics()
		),
		"lower_deck_forward_hatch": get_factory_lower_deck_forward_hatch_diagnostics(),
		"lower_deck_forward_conduit": (
			get_factory_lower_deck_forward_conduit_diagnostics()
		),
		"lower_deck_forward_conduit_clear_feedback": (
			get_factory_lower_deck_forward_conduit_clear_feedback_diagnostics()
		),
		"lower_deck_forward_pressure_traverse": (
			get_factory_lower_deck_forward_pressure_traverse_diagnostics()
		),
		"lower_deck_forward_pressure_counter_ambush": (
			get_factory_lower_deck_forward_pressure_counter_ambush_diagnostics()
		),
		"lower_deck_forward_pressure_exit_guard": (
			get_factory_lower_deck_forward_pressure_exit_guard_diagnostics()
		),
		"lower_deck_forward_pressure_reward_cache": (
			get_factory_lower_deck_forward_pressure_reward_cache_diagnostics()
		),
		"lower_deck_forward_pressure_exit_relay": (
			get_factory_lower_deck_forward_pressure_exit_relay_diagnostics()
		),
		"lower_deck_forward_pressure_exit_gate": (
			get_factory_lower_deck_forward_pressure_exit_gate_diagnostics()
		),
		"lower_deck_forward_pressure_route_handoff_marker": (
			get_factory_lower_deck_forward_pressure_route_handoff_marker_diagnostics()
		),
		"lower_deck_forward_pressure_beacon_ambush": (
			get_factory_lower_deck_forward_pressure_beacon_ambush_diagnostics()
		),
		"lower_deck_forward_pressure_overrun": (
			get_factory_lower_deck_forward_pressure_overrun_diagnostics()
		),
		"lower_deck_forward_pressure_breaker_stand": (
			get_factory_lower_deck_forward_pressure_breaker_stand_diagnostics()
		),
		"lower_deck_forward_pressure_breaker": (
			get_factory_lower_deck_forward_pressure_breaker_diagnostics()
		),
		"lower_deck_forward_pressure_relief_ambush": (
			get_factory_lower_deck_forward_pressure_relief_ambush_diagnostics()
		),
		"return_patrol_reward_cache": get_factory_return_patrol_reward_cache_diagnostics(),
		"checkpoint_overdrive_reward_cache": (
			get_factory_checkpoint_overdrive_reward_cache_diagnostics()
		),
		"return_checkpoint": get_factory_return_checkpoint_diagnostics(),
		"route_objective": get_factory_route_objective_diagnostics(),
		"service_lift": get_factory_service_lift_diagnostics(),
		"last_player_hit_metadata": get_last_player_hit_metadata(),
	}


func _get_deep_route_unlock_vfx_snapshot() -> Dictionary:
	if _deep_endpoint == null or not _deep_endpoint.has_method("get_unlock_vfx_snapshot"):
		return {}
	var snapshot_variant: Variant = _deep_endpoint.call("get_unlock_vfx_snapshot")
	if snapshot_variant is Dictionary:
		return (snapshot_variant as Dictionary).duplicate(true)
	return {}


func _get_service_lift_unlock_vfx_snapshot() -> Dictionary:
	if _service_lift == null or not _service_lift.has_method("get_unlock_vfx_snapshot"):
		return {}
	var snapshot_variant: Variant = _service_lift.call("get_unlock_vfx_snapshot")
	if snapshot_variant is Dictionary:
		return (snapshot_variant as Dictionary).duplicate(true)
	return {}


func _get_lower_deck_breach_relay_activation_vfx_snapshot() -> Dictionary:
	if (
		_lower_deck_breach_relay == null
		or not _lower_deck_breach_relay.has_method("get_activation_vfx_snapshot")
	):
		return {}
	var snapshot_variant: Variant = _lower_deck_breach_relay.call("get_activation_vfx_snapshot")
	if snapshot_variant is Dictionary:
		return (snapshot_variant as Dictionary).duplicate(true)
	return {}


func _is_service_lift_available() -> bool:
	return (
		bool(_service_lift.call("is_available"))
		if _service_lift != null and _service_lift.has_method("is_available")
		else false
	)


func _is_service_lift_activation_ready(available: bool, provider: Node = null) -> bool:
	if (
		not available
		or _service_lift == null
		or not _service_lift.has_method("is_provider_in_activation_range")
	):
		return false
	var activation_provider: Node = provider if provider != null else _player
	return bool(_service_lift.call("is_provider_in_activation_range", activation_provider))


func _get_service_lift_endpoint_id() -> String:
	return (
		String(_service_lift.call("get_endpoint_id"))
		if _service_lift != null and _service_lift.has_method("get_endpoint_id")
		else ""
	)


func _get_service_lift_texture_path() -> String:
	return (
		String(_service_lift.call("get_visual_texture_path"))
		if _service_lift != null and _service_lift.has_method("get_visual_texture_path")
		else ""
	)


func _get_service_lift_prompt_text() -> String:
	var prompt_label := (
		_service_lift.get_node_or_null("PromptLabel") as Label
		if _service_lift != null
		else null
	)
	return prompt_label.text if prompt_label != null else ""


func _get_service_lift_position() -> Vector2:
	return (
		(_service_lift as Node2D).global_position
		if _service_lift != null and _service_lift is Node2D
		else Vector2.ZERO
	)


func _request_service_lift_scene_exit() -> bool:
	var scene_manager: Object = _resolve_scene_manager_for_runtime()
	if not _is_valid_scene_manager(scene_manager):
		_record_service_lift_exit_rejection(&"scene_manager_missing")
		return false
	if scene_manager.has_method("is_loading") and bool(scene_manager.call("is_loading")):
		_record_service_lift_exit_rejection(&"scene_manager_loading")
		return false
	if scene_manager.has_method("is_scene_locked") and bool(scene_manager.call("is_scene_locked")):
		_record_service_lift_exit_rejection(&"scene_locked")
		return false
	if scene_manager.has_method("has_scene") \
			and not bool(scene_manager.call("has_scene", FACTORY_SERVICE_LIFT_EXIT_SCENE_ID)):
		_record_service_lift_exit_rejection(&"unknown_scene")
		return false

	var request_started: bool = false
	if scene_manager.has_method("request_scene_change"):
		request_started = bool(scene_manager.call(
			"request_scene_change",
			FACTORY_SERVICE_LIFT_EXIT_SCENE_ID,
			FACTORY_SERVICE_LIFT_EXIT_SPAWN_POINT
		))
	elif scene_manager.has_method("change_scene"):
		request_started = bool(scene_manager.call(
			"change_scene",
			FACTORY_SERVICE_LIFT_EXIT_SCENE_ID,
			FACTORY_SERVICE_LIFT_EXIT_SPAWN_POINT
		))
	if not request_started:
		_record_service_lift_exit_rejection(&"request_rejected")
		return false

	_service_lift_exit_requested = true
	_last_service_lift_exit_rejected_reason = &""
	_last_service_lift_exit_request = {
		"scene_id": String(FACTORY_SERVICE_LIFT_EXIT_SCENE_ID),
		"spawn_point": String(FACTORY_SERVICE_LIFT_EXIT_SPAWN_POINT),
		"scene_manager_loading": _is_scene_manager_loading(),
		"pending_scene": _get_scene_manager_pending_scene(),
		"pending_spawn_point": _get_scene_manager_pending_spawn_point(),
	}
	return true


func _record_service_lift_exit_rejection(reason: StringName) -> void:
	_last_service_lift_exit_rejected_reason = reason
	_last_service_lift_exit_request = {}


func _resolve_scene_manager_for_runtime() -> Object:
	if _is_valid_scene_manager(_scene_manager):
		return _scene_manager
	if not is_inside_tree():
		return null
	var root_scene_manager: Node = get_node_or_null("/root/SceneManager")
	if _is_valid_scene_manager(root_scene_manager):
		_scene_manager = root_scene_manager
		return _scene_manager
	return null


func _is_valid_scene_manager(scene_manager: Object) -> bool:
	return (
		scene_manager != null
		and is_instance_valid(scene_manager)
		and (
			scene_manager.has_method("request_scene_change")
			or scene_manager.has_method("change_scene")
		)
	)


func _is_scene_manager_loading() -> bool:
	var scene_manager: Object = _resolve_scene_manager_for_runtime()
	return (
		bool(scene_manager.call("is_loading"))
		if scene_manager != null and scene_manager.has_method("is_loading")
		else false
	)


func _apply_current_scene_manager_spawn_point() -> bool:
	var scene_manager: Object = _resolve_scene_manager_for_runtime()
	if scene_manager == null or not scene_manager.has_method("get_current_scene"):
		return false
	return _apply_scene_manager_spawn_point(StringName(scene_manager.call("get_current_scene")))


func _apply_scene_manager_spawn_point(scene_id: StringName) -> bool:
	if scene_id != FACTORY_SCENE_ID:
		return false
	var scene_manager: Object = _resolve_scene_manager_for_runtime()
	if scene_manager == null or not scene_manager.has_method("get_current_spawn_point"):
		return false
	var spawn_point: StringName = StringName(scene_manager.call("get_current_spawn_point"))
	if (
		spawn_point == FACTORY_RETURN_CHECKPOINT_SPAWN_POINT
		or spawn_point == FACTORY_LOWER_DECK_BREACH_RELAY_SPAWN_POINT
		or spawn_point == FACTORY_LOWER_DECK_FORWARD_PRESSURE_EXIT_RELAY_SPAWN_POINT
		or spawn_point == (
			FACTORY_LOWER_DECK_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_SAVEPOINT_SPAWN_POINT
		)
	):
		_grant_factory_hazard_respawn_grace()
	if not _move_player_to_spawn_point(spawn_point):
		return false
	if spawn_point == FACTORY_RETURN_CHECKPOINT_SPAWN_POINT:
		_factory_return_checkpoint_spawn_snap_frames = FACTORY_RETURN_CHECKPOINT_SPAWN_SNAP_FRAMES
		_set_player_physics_pinned_for_return_checkpoint(true)
		_update_route_label(FACTORY_RETURN_CHECKPOINT_RESPAWN_LABEL)
	elif spawn_point == FACTORY_LOWER_DECK_BREACH_RELAY_SPAWN_POINT:
		_factory_return_checkpoint_spawn_snap_frames = 0
		_set_player_physics_pinned_for_return_checkpoint(false)
		_update_route_label(FACTORY_LOWER_DECK_BREACH_RELAY_RESPAWN_LABEL)
	elif spawn_point == FACTORY_LOWER_DECK_FORWARD_PRESSURE_EXIT_RELAY_SPAWN_POINT:
		_factory_return_checkpoint_spawn_snap_frames = 0
		_set_player_physics_pinned_for_return_checkpoint(false)
		_update_route_label(FACTORY_LOWER_DECK_FORWARD_PRESSURE_EXIT_RELAY_RESPAWN_LABEL)
	elif (
		spawn_point
		== FACTORY_LOWER_DECK_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_SAVEPOINT_SPAWN_POINT
	):
		_factory_return_checkpoint_spawn_snap_frames = 0
		_set_player_physics_pinned_for_return_checkpoint(false)
		_update_route_label(
			FACTORY_LOWER_DECK_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_SAVEPOINT_RESPAWN_LABEL
		)
	else:
		_factory_return_checkpoint_spawn_snap_frames = 0
		_set_player_physics_pinned_for_return_checkpoint(false)
	return true


func _move_player_to_spawn_point(spawn_point: StringName) -> bool:
	if _player == null or not is_instance_valid(_player):
		return false
	var spawn_node: Node2D = null
	if spawn_point == FACTORY_GATE_ENTRY_SPAWN_POINT:
		spawn_node = _spawn
	elif spawn_point == FACTORY_RETURN_CHECKPOINT_SPAWN_POINT:
		spawn_node = _return_checkpoint as Node2D
	elif spawn_point == FACTORY_LOWER_DECK_BREACH_RELAY_SPAWN_POINT:
		spawn_node = _lower_deck_breach_relay as Node2D
	elif spawn_point == FACTORY_LOWER_DECK_FORWARD_PRESSURE_EXIT_RELAY_SPAWN_POINT:
		spawn_node = _lower_deck_forward_pressure_exit_relay as Node2D
	elif (
		spawn_point
		== FACTORY_LOWER_DECK_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_SAVEPOINT_SPAWN_POINT
	):
		spawn_node = _lower_deck_forward_pressure_aftershock_condenser_savepoint as Node2D
	if spawn_node == null:
		return false
	_player.global_position = spawn_node.global_position
	if _player is CharacterBody2D:
		(_player as CharacterBody2D).velocity = Vector2.ZERO
	return true


func _snap_return_checkpoint_spawn_if_needed() -> void:
	if _factory_return_checkpoint_spawn_snap_frames <= 0:
		return
	_factory_return_checkpoint_spawn_snap_frames -= 1
	_move_player_to_spawn_point(FACTORY_RETURN_CHECKPOINT_SPAWN_POINT)
	if _factory_return_checkpoint_spawn_snap_frames <= 0:
		_set_player_physics_pinned_for_return_checkpoint(false)


func _set_player_physics_pinned_for_return_checkpoint(pinned: bool) -> void:
	if _player == null or not is_instance_valid(_player):
		return
	_player.set_physics_process(not pinned)


func _get_scene_manager_pending_scene() -> String:
	var scene_manager: Object = _resolve_scene_manager_for_runtime()
	return (
		String(scene_manager.call("get_pending_scene"))
		if scene_manager != null and scene_manager.has_method("get_pending_scene")
		else ""
	)


func _get_scene_manager_pending_spawn_point() -> String:
	var scene_manager: Object = _resolve_scene_manager_for_runtime()
	return (
		String(scene_manager.call("get_pending_spawn_point"))
		if scene_manager != null and scene_manager.has_method("get_pending_spawn_point")
		else ""
	)


func _align_player_to_spawn() -> void:
	if _spawn == null or _player == null:
		return
	_player.global_position = _spawn.global_position


func _bind_enemy_to_player() -> void:
	if _player == null:
		return
	_bind_factory_guard(
		_enemy,
		&"old_factory_entrance",
		FACTORY_ENTRY_GUARD_ENTITY_ID,
		&"factory_patrol",
		_on_factory_enemy_defeated,
		_player
	)
	_bind_factory_guard(
		_deep_guard,
		&"old_factory_deep_route",
		FACTORY_DEEP_GUARD_ENTITY_ID,
		&"factory_deep_guard",
		_on_factory_deep_guard_defeated
	)
	_bind_factory_guard(
		_spark_rat,
		&"old_factory_spark_rat_patrol",
		FACTORY_SPARK_RAT_ENTITY_ID,
		&"factory_spark_rat_patrol",
		_on_factory_spark_rat_defeated
	)
	_bind_factory_guard(
		_return_spark_rat,
		&"old_factory_return_patrol",
		FACTORY_RETURN_SPARK_RAT_ENTITY_ID,
		&"factory_return_spark_rat",
		_on_factory_return_spark_rat_defeated
	)
	_bind_factory_guard(
		_checkpoint_forward_spark_rat,
		&"old_factory_checkpoint_forward_patrol",
		FACTORY_CHECKPOINT_FORWARD_SPARK_RAT_ENTITY_ID,
		&"factory_checkpoint_forward_spark_rat",
		_on_factory_checkpoint_forward_spark_rat_defeated
	)
	_bind_factory_guard(
		_checkpoint_rear_spark_rat,
		&"old_factory_checkpoint_rear_ambush",
		FACTORY_CHECKPOINT_REAR_SPARK_RAT_ENTITY_ID,
		&"factory_checkpoint_rear_spark_rat",
		_on_factory_checkpoint_rear_spark_rat_defeated
	)
	_bind_factory_guard(
		_checkpoint_overdrive_left_spark_rat,
		&"old_factory_checkpoint_overdrive_duo",
		FACTORY_CHECKPOINT_OVERDRIVE_LEFT_SPARK_RAT_ENTITY_ID,
		&"factory_checkpoint_overdrive_spark_rat_left",
		_on_factory_checkpoint_overdrive_left_spark_rat_defeated
	)
	_bind_factory_guard(
		_checkpoint_overdrive_right_spark_rat,
		&"old_factory_checkpoint_overdrive_duo",
		FACTORY_CHECKPOINT_OVERDRIVE_RIGHT_SPARK_RAT_ENTITY_ID,
		&"factory_checkpoint_overdrive_spark_rat_right",
		_on_factory_checkpoint_overdrive_right_spark_rat_defeated
	)
	_bind_factory_guard(
		_lower_deck_spark_rat,
		&"old_factory_lower_deck_skirmish",
		FACTORY_LOWER_DECK_SPARK_RAT_ENTITY_ID,
		&"factory_lower_deck_spark_rat",
		_on_factory_lower_deck_spark_rat_defeated
	)
	_bind_factory_guard(
		_lower_deck_exit_spark_rat,
		&"old_factory_lower_deck_exit_ambush",
		FACTORY_LOWER_DECK_EXIT_SPARK_RAT_ENTITY_ID,
		&"factory_lower_deck_exit_spark_rat",
		_on_factory_lower_deck_exit_spark_rat_defeated
	)
	_bind_factory_guard(
		_lower_deck_shortcut_spark_rat,
		&"old_factory_lower_deck_shortcut",
		FACTORY_LOWER_DECK_SHORTCUT_SPARK_RAT_ENTITY_ID,
		&"factory_lower_deck_shortcut_spark_rat",
		_on_factory_lower_deck_shortcut_spark_rat_defeated
	)
	_bind_factory_guard(
		_lower_deck_shortcut_pursuer_spark_rat,
		&"old_factory_lower_deck_shortcut_pursuer",
		FACTORY_LOWER_DECK_SHORTCUT_PURSUER_ENTITY_ID,
		&"factory_lower_deck_shortcut_pursuer_spark_rat",
		_on_factory_lower_deck_shortcut_pursuer_defeated
	)
	_bind_factory_guard(
		_lower_deck_pressure_guard_spark_rat,
		&"old_factory_lower_deck_pressure_valve",
		FACTORY_LOWER_DECK_PRESSURE_GUARD_ENTITY_ID,
		&"factory_lower_deck_pressure_valve_spark_rat",
		_on_factory_lower_deck_pressure_guard_defeated
	)
	_bind_factory_guard(
		_lower_deck_steam_sluice_spark_rat,
		&"old_factory_lower_deck_steam_sluice",
		FACTORY_LOWER_DECK_STEAM_SLUICE_ENTITY_ID,
		&"factory_lower_deck_steam_sluice_spark_rat",
		_on_factory_lower_deck_steam_sluice_defeated
	)
	_bind_factory_guard(
		_lower_deck_deep_bulkhead_spark_rat,
		&"old_factory_lower_deck_deep_bulkhead",
		FACTORY_LOWER_DECK_DEEP_BULKHEAD_ENTITY_ID,
		&"factory_lower_deck_deep_bulkhead_spark_rat",
		_on_factory_lower_deck_deep_bulkhead_guard_defeated
	)
	_bind_factory_guard(
		_lower_deck_breach_front_spark_rat,
		&"old_factory_lower_deck_breach_corridor",
		FACTORY_LOWER_DECK_BREACH_FRONT_ENTITY_ID,
		&"factory_lower_deck_breach_front_spark_rat",
		_on_factory_lower_deck_breach_front_guard_defeated
	)
	_bind_factory_guard(
		_lower_deck_breach_rear_spark_rat,
		&"old_factory_lower_deck_breach_corridor",
		FACTORY_LOWER_DECK_BREACH_REAR_ENTITY_ID,
		&"factory_lower_deck_breach_rear_spark_rat",
		_on_factory_lower_deck_breach_rear_ambusher_defeated
	)
	_bind_factory_guard(
		_lower_deck_post_relay_spark_rat,
		&"old_factory_lower_deck_post_relay_trial",
		FACTORY_LOWER_DECK_POST_RELAY_ENTITY_ID,
		&"factory_lower_deck_post_relay_spark_rat",
		_on_factory_lower_deck_post_relay_trial_defeated
	)
	_bind_factory_guard(
		_lower_deck_forward_conduit_spark_rat,
		&"old_factory_lower_deck_forward_conduit",
		FACTORY_LOWER_DECK_FORWARD_CONDUIT_ENTITY_ID,
		&"factory_lower_deck_forward_conduit_spark_rat",
		_on_factory_lower_deck_forward_conduit_defeated
	)
	_bind_factory_guard(
		_lower_deck_forward_counter_spark_rat,
		&"old_factory_lower_deck_forward_pressure_counter_ambush",
		FACTORY_LOWER_DECK_FORWARD_COUNTER_AMBUSH_ENTITY_ID,
		&"factory_lower_deck_forward_counter_spark_rat",
		_on_factory_lower_deck_forward_pressure_counter_ambush_defeated
	)
	_bind_factory_guard(
		_lower_deck_forward_exit_guard_spark_rat,
		FACTORY_LOWER_DECK_FORWARD_EXIT_GUARD_HAZARD_ID,
		FACTORY_LOWER_DECK_FORWARD_EXIT_GUARD_ENTITY_ID,
		&"factory_lower_deck_forward_pressure_exit_guard_spark_rat",
		_on_factory_lower_deck_forward_pressure_exit_guard_defeated
	)
	_bind_factory_guard(
		_lower_deck_forward_beacon_ambush_spark_rat,
		FACTORY_LOWER_DECK_FORWARD_BEACON_AMBUSH_HAZARD_ID,
		FACTORY_LOWER_DECK_FORWARD_BEACON_AMBUSH_ENTITY_ID,
		&"factory_lower_deck_forward_pressure_beacon_ambush_spark_rat",
		_on_factory_lower_deck_forward_pressure_beacon_ambush_defeated
	)
	_bind_factory_guard(
		_lower_deck_forward_overrun_spark_rat,
		FACTORY_LOWER_DECK_FORWARD_OVERRUN_HAZARD_ID,
		FACTORY_LOWER_DECK_FORWARD_OVERRUN_ENTITY_ID,
		&"factory_lower_deck_forward_pressure_overrun_spark_rat",
		_on_factory_lower_deck_forward_pressure_overrun_defeated
	)
	_bind_factory_guard(
		_lower_deck_forward_breaker_spark_rat,
		FACTORY_LOWER_DECK_FORWARD_BREAKER_HAZARD_ID,
		FACTORY_LOWER_DECK_FORWARD_BREAKER_ENTITY_ID,
		&"factory_lower_deck_forward_pressure_breaker_spark_rat",
		_on_factory_lower_deck_forward_pressure_breaker_defeated
	)
	_bind_factory_guard(
		_lower_deck_forward_relief_ambush_spark_rat,
		FACTORY_LOWER_DECK_FORWARD_RELIEF_AMBUSH_HAZARD_ID,
		FACTORY_LOWER_DECK_FORWARD_RELIEF_AMBUSH_ENTITY_ID,
		&"factory_lower_deck_forward_pressure_relief_ambush_spark_rat",
		_on_factory_lower_deck_forward_pressure_relief_ambush_defeated
	)
	_bind_factory_guard(
		_lower_deck_forward_pressure_coil_rat,
		FACTORY_LOWER_DECK_FORWARD_PRESSURE_COIL_RAT_ID,
		FACTORY_LOWER_DECK_FORWARD_COIL_RAT_ENTITY_ID,
		&"factory_lower_deck_forward_pressure_coil_rat",
		_on_factory_lower_deck_forward_pressure_coil_rat_defeated
	)
	_bind_factory_guard(
		_lower_deck_forward_pressure_coil_pincer_spark_rat,
		FACTORY_LOWER_DECK_FORWARD_PRESSURE_COIL_PINCER_ID,
		FACTORY_LOWER_DECK_FORWARD_COIL_PINCER_SPARK_RAT_ENTITY_ID,
		&"factory_lower_deck_forward_pressure_coil_pincer_spark_rat",
		_on_factory_lower_deck_forward_pressure_coil_pincer_spark_rat_defeated
	)
	_bind_factory_guard(
		_lower_deck_forward_pressure_coil_pincer_coil_rat,
		FACTORY_LOWER_DECK_FORWARD_PRESSURE_COIL_PINCER_ID,
		FACTORY_LOWER_DECK_FORWARD_COIL_PINCER_COIL_RAT_ENTITY_ID,
		&"factory_lower_deck_forward_pressure_coil_pincer_coil_rat",
		_on_factory_lower_deck_forward_pressure_coil_pincer_coil_rat_defeated
	)
	_bind_factory_guard(
		_lower_deck_forward_pressure_coil_aftershock_coil_rat,
		FACTORY_LOWER_DECK_FORWARD_PRESSURE_COIL_AFTERSHOCK_ID,
		FACTORY_LOWER_DECK_FORWARD_COIL_AFTERSHOCK_COIL_RAT_ENTITY_ID,
		&"factory_lower_deck_forward_pressure_coil_aftershock_coil_rat",
		_on_factory_lower_deck_forward_pressure_coil_aftershock_defeated
	)
	_bind_factory_guard(
		_lower_deck_forward_pressure_aftershock_exit_spark_rat,
		FACTORY_LOWER_DECK_FORWARD_PRESSURE_AFTERSHOCK_EXIT_SKIRMISH_ID,
		FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_EXIT_SPARK_RAT_ENTITY_ID,
		&"factory_lower_deck_forward_pressure_aftershock_exit_spark_rat",
		_on_factory_lower_deck_forward_pressure_aftershock_exit_spark_rat_defeated
	)
	_bind_factory_guard(
		_lower_deck_forward_pressure_aftershock_exit_coil_rat,
		FACTORY_LOWER_DECK_FORWARD_PRESSURE_AFTERSHOCK_EXIT_SKIRMISH_ID,
		FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_EXIT_COIL_RAT_ENTITY_ID,
		&"factory_lower_deck_forward_pressure_aftershock_exit_coil_rat",
		_on_factory_lower_deck_forward_pressure_aftershock_exit_coil_rat_defeated
	)
	_bind_factory_guard(
		_lower_deck_forward_pressure_aftershock_exhaust_pursuer_coil_rat,
		FACTORY_LOWER_DECK_FORWARD_PRESSURE_AFTERSHOCK_EXHAUST_PURSUER_ID,
		FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_EXHAUST_PURSUER_ENTITY_ID,
		&"factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_coil_rat",
		_on_factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_defeated
	)
	_bind_factory_guard(
		_lower_deck_forward_pressure_aftershock_exhaust_flank_spark_rat,
		FACTORY_LOWER_DECK_FORWARD_PRESSURE_AFTERSHOCK_EXHAUST_FLANK_ID,
		FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_EXHAUST_FLANK_ENTITY_ID,
		&"factory_lower_deck_forward_pressure_aftershock_exhaust_flank_spark_rat",
		_on_factory_lower_deck_forward_pressure_aftershock_exhaust_flank_defeated
	)
	_bind_factory_guard(
		_lower_deck_forward_pressure_aftershock_exhaust_breaker_coil_rat,
		FACTORY_LOWER_DECK_FORWARD_PRESSURE_AFTERSHOCK_EXHAUST_BREAKER_ID,
		FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_EXHAUST_BREAKER_ENTITY_ID,
		&"factory_lower_deck_forward_pressure_aftershock_exhaust_breaker_coil_rat",
		_on_factory_lower_deck_forward_pressure_aftershock_exhaust_breaker_defeated
	)
	_bind_factory_guard(
		_lower_deck_forward_pressure_aftershock_exhaust_escape_spark_rat,
		FACTORY_LOWER_DECK_FORWARD_PRESSURE_AFTERSHOCK_EXHAUST_ESCAPE_ID,
		FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_EXHAUST_ESCAPE_SPARK_ENTITY_ID,
		&"factory_lower_deck_forward_pressure_aftershock_exhaust_escape_spark_rat",
		_on_factory_lower_deck_forward_pressure_aftershock_exhaust_escape_spark_rat_defeated
	)
	_bind_factory_guard(
		_lower_deck_forward_pressure_aftershock_exhaust_escape_coil_rat,
		FACTORY_LOWER_DECK_FORWARD_PRESSURE_AFTERSHOCK_EXHAUST_ESCAPE_ID,
		FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_EXHAUST_ESCAPE_COIL_ENTITY_ID,
		&"factory_lower_deck_forward_pressure_aftershock_exhaust_escape_coil_rat",
		_on_factory_lower_deck_forward_pressure_aftershock_exhaust_escape_coil_rat_defeated
	)
	_bind_factory_guard(
		_lower_deck_forward_pressure_aftershock_condenser_spark_rat,
		FACTORY_LOWER_DECK_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_VALVE_ID,
		FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_CONDENSER_SPARK_ENTITY_ID,
		&"factory_lower_deck_forward_pressure_aftershock_condenser_spark_rat",
		_on_factory_lower_deck_forward_pressure_aftershock_condenser_spark_rat_defeated
	)
	_bind_factory_guard(
		_lower_deck_forward_pressure_aftershock_condenser_coil_rat,
		FACTORY_LOWER_DECK_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_VALVE_ID,
		FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_CONDENSER_COIL_ENTITY_ID,
		&"factory_lower_deck_forward_pressure_aftershock_condenser_coil_rat",
		_on_factory_lower_deck_forward_pressure_aftershock_condenser_coil_rat_defeated
	)
	_bind_factory_guard(
		_lower_deck_forward_pressure_aftershock_condenser_outlet_clamp_spark_rat,
		FACTORY_LOWER_DECK_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_OUTLET_CLAMP_ID,
		FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_CONDENSER_CLAMP_SPARK_ENTITY_ID,
		&"factory_lower_deck_forward_pressure_aftershock_condenser_outlet_clamp_spark_rat",
		_on_outlet_clamp_spark_rat_defeated
	)
	_bind_factory_guard(
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_coil_rat,
		FACTORY_LOWER_DECK_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_ID,
		FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_CONDENSER_OVERFLOW_COIL_ENTITY_ID,
		&"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_coil_rat",
		_on_overflow_pump_coil_rat_defeated
	)
	_bind_factory_guard(
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_coil_rat,
		FACTORY_LOWER_DECK_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_RUNOFF_EXIT_ID,
		FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_CONDENSER_OVERFLOW_RUNOFF_EXIT_COIL_ENTITY_ID,
		&"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_coil_rat",
		_on_overflow_pump_runoff_exit_coil_rat_defeated
	)
	_bind_factory_guard(
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_spark_rat,
		FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_RUNOFF_OUTLET_HAZARD_ID,
		FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_CONDENSER_OVERFLOW_RUNOFF_OUTLET_SPARK_ENTITY_ID,
		&"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_spark_rat",
		_on_overflow_pump_runoff_outlet_spark_rat_defeated
	)
	_bind_factory_guard(
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_spark_rat,
		FACTORY_LOWER_DECK_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_RUNOFF_OUTLET_SERVICE_SLUICE_SKIRMISH_ID,
		FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_CONDENSER_OVERFLOW_RUNOFF_OUTLET_SERVICE_SLUICE_SPARK_ENTITY_ID,
		&"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_spark_rat",
		_on_overflow_pump_runoff_outlet_service_sluice_spark_rat_defeated
	)


func _setup_factory_cache() -> void:
	_sync_room_clear_state()
	if _cache == null or not _cache.has_signal("cache_claimed"):
		return
	var claimed_signal: Signal = _cache.get("cache_claimed")
	if not claimed_signal.is_connected(_on_factory_cache_claimed):
		claimed_signal.connect(_on_factory_cache_claimed)


func _setup_factory_return_patrol_reward_cache() -> void:
	_sync_return_patrol_reward_cache_state()
	if _return_patrol_reward_cache == null or not _return_patrol_reward_cache.has_signal(
		"cache_claimed"
	):
		return
	var claimed_signal: Signal = _return_patrol_reward_cache.get("cache_claimed")
	if not claimed_signal.is_connected(_on_factory_return_patrol_reward_cache_claimed):
		claimed_signal.connect(_on_factory_return_patrol_reward_cache_claimed)


func _setup_factory_checkpoint_overdrive_reward_cache() -> void:
	_sync_checkpoint_overdrive_reward_cache_state()
	if (
		_checkpoint_overdrive_reward_cache == null
		or not _checkpoint_overdrive_reward_cache.has_signal("cache_claimed")
	):
		return
	var claimed_signal: Signal = _checkpoint_overdrive_reward_cache.get("cache_claimed")
	if not claimed_signal.is_connected(_on_factory_checkpoint_overdrive_reward_cache_claimed):
		claimed_signal.connect(_on_factory_checkpoint_overdrive_reward_cache_claimed)


func _setup_factory_lower_deck_reward_cache() -> void:
	_sync_lower_deck_reward_cache_state()
	if (
		_lower_deck_reward_cache == null
		or not _lower_deck_reward_cache.has_signal("cache_claimed")
	):
		return
	var claimed_signal: Signal = _lower_deck_reward_cache.get("cache_claimed")
	if not claimed_signal.is_connected(_on_factory_lower_deck_reward_cache_claimed):
		claimed_signal.connect(_on_factory_lower_deck_reward_cache_claimed)


func _setup_factory_lower_deck_shortcut_reward_cache() -> void:
	_sync_lower_deck_shortcut_reward_cache_state()
	if (
		_lower_deck_shortcut_reward_cache == null
		or not _lower_deck_shortcut_reward_cache.has_signal("cache_claimed")
	):
		return
	var claimed_signal: Signal = _lower_deck_shortcut_reward_cache.get("cache_claimed")
	if not claimed_signal.is_connected(_on_factory_lower_deck_shortcut_reward_cache_claimed):
		claimed_signal.connect(_on_factory_lower_deck_shortcut_reward_cache_claimed)


func _setup_factory_lower_deck_relay_forward_reward_cache() -> void:
	_sync_lower_deck_relay_forward_reward_cache_state()
	if (
		_lower_deck_relay_forward_reward_cache == null
		or not _lower_deck_relay_forward_reward_cache.has_signal("cache_claimed")
	):
		return
	var claimed_signal: Signal = _lower_deck_relay_forward_reward_cache.get("cache_claimed")
	if not claimed_signal.is_connected(_on_factory_lower_deck_relay_forward_reward_cache_claimed):
		claimed_signal.connect(_on_factory_lower_deck_relay_forward_reward_cache_claimed)


func _setup_factory_lower_deck_forward_pressure_reward_cache() -> void:
	_sync_lower_deck_forward_pressure_reward_cache_state()
	if (
		_lower_deck_forward_pressure_reward_cache == null
		or not _lower_deck_forward_pressure_reward_cache.has_signal("cache_claimed")
	):
		return
	var claimed_signal: Signal = _lower_deck_forward_pressure_reward_cache.get(
		"cache_claimed"
	)
	if not claimed_signal.is_connected(
		_on_factory_lower_deck_forward_pressure_reward_cache_claimed
	):
		claimed_signal.connect(_on_factory_lower_deck_forward_pressure_reward_cache_claimed)


func _setup_factory_lower_deck_forward_pressure_aftershock_reward_cache() -> void:
	_sync_lower_deck_forward_pressure_aftershock_reward_cache_state()
	if (
		_lower_deck_forward_pressure_aftershock_reward_cache == null
		or not _lower_deck_forward_pressure_aftershock_reward_cache.has_signal(
			"cache_claimed"
		)
	):
		return
	var claimed_signal: Signal = _lower_deck_forward_pressure_aftershock_reward_cache.get(
		"cache_claimed"
	)
	if not claimed_signal.is_connected(
		_on_factory_lower_deck_forward_pressure_aftershock_reward_cache_claimed
	):
		claimed_signal.connect(
			_on_factory_lower_deck_forward_pressure_aftershock_reward_cache_claimed
		)


func _setup_factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache(
) -> void:
	_sync_lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache_state()
	if (
		_lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache == null
		or not _lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache.has_signal(
			"cache_claimed"
		)
	):
		return
	var claimed_signal: Signal = (
		_lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache.get(
			"cache_claimed"
		)
	)
	if not claimed_signal.is_connected(
		_on_factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache_claimed
	):
		claimed_signal.connect(
			_on_factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache_claimed
		)


func _setup_factory_lower_deck_forward_hatch() -> void:
	_sync_lower_deck_forward_hatch_state()
	if _lower_deck_forward_hatch == null or not _lower_deck_forward_hatch.has_signal(
		"endpoint_activated"
	):
		return
	var endpoint_signal: Signal = _lower_deck_forward_hatch.get("endpoint_activated")
	if not endpoint_signal.is_connected(_on_factory_lower_deck_forward_hatch_activated):
		endpoint_signal.connect(_on_factory_lower_deck_forward_hatch_activated)


func _setup_factory_lower_deck_parry_gate() -> void:
	_sync_lower_deck_parry_gate_state()
	if _lower_deck_parry_gate == null:
		return
	if _lower_deck_parry_gate.has_method("set_ability_provider"):
		_lower_deck_parry_gate.call("set_ability_provider", _player)
	if not _lower_deck_parry_gate.has_signal("gate_state_changed"):
		return
	var gate_signal: Signal = _lower_deck_parry_gate.get("gate_state_changed")
	if not gate_signal.is_connected(_on_factory_lower_deck_parry_gate_state_changed):
		gate_signal.connect(_on_factory_lower_deck_parry_gate_state_changed)


func _setup_factory_lower_deck_shortcut_seal() -> void:
	_sync_lower_deck_shortcut_state()
	if _lower_deck_shortcut_seal == null or not _lower_deck_shortcut_seal.has_signal(
		"endpoint_activated"
	):
		return
	var endpoint_signal: Signal = _lower_deck_shortcut_seal.get("endpoint_activated")
	if not endpoint_signal.is_connected(_on_factory_lower_deck_shortcut_seal_activated):
		endpoint_signal.connect(_on_factory_lower_deck_shortcut_seal_activated)


func _setup_factory_lower_deck_pressure_valve() -> void:
	_sync_lower_deck_pressure_valve_state()
	if _lower_deck_pressure_valve == null or not _lower_deck_pressure_valve.has_signal(
		"endpoint_activated"
	):
		return
	var endpoint_signal: Signal = _lower_deck_pressure_valve.get("endpoint_activated")
	if not endpoint_signal.is_connected(_on_factory_lower_deck_pressure_valve_activated):
		endpoint_signal.connect(_on_factory_lower_deck_pressure_valve_activated)


func _setup_factory_lower_deck_deep_bulkhead() -> void:
	_sync_lower_deck_deep_bulkhead_state()
	if _lower_deck_deep_bulkhead == null or not _lower_deck_deep_bulkhead.has_signal(
		"endpoint_activated"
	):
		return
	var endpoint_signal: Signal = _lower_deck_deep_bulkhead.get("endpoint_activated")
	if not endpoint_signal.is_connected(_on_factory_lower_deck_deep_bulkhead_activated):
		endpoint_signal.connect(_on_factory_lower_deck_deep_bulkhead_activated)


func _setup_factory_return_checkpoint() -> void:
	_sync_return_checkpoint_state()
	if _return_checkpoint == null or not _return_checkpoint.has_signal("savepoint_activated"):
		return
	var activated_signal: Signal = _return_checkpoint.get("savepoint_activated")
	if not activated_signal.is_connected(_on_factory_return_checkpoint_activated):
		activated_signal.connect(_on_factory_return_checkpoint_activated)


func _setup_factory_lower_deck_breach_relay() -> void:
	_sync_lower_deck_breach_relay_state()
	if (
		_lower_deck_breach_relay == null
		or not _lower_deck_breach_relay.has_signal("savepoint_activated")
	):
		return
	var activated_signal: Signal = _lower_deck_breach_relay.get("savepoint_activated")
	if not activated_signal.is_connected(_on_factory_lower_deck_breach_relay_activated):
		activated_signal.connect(_on_factory_lower_deck_breach_relay_activated)


func _setup_factory_lower_deck_forward_pressure_exit_relay() -> void:
	_sync_lower_deck_forward_pressure_exit_relay_state()
	if (
		_lower_deck_forward_pressure_exit_relay == null
		or not _lower_deck_forward_pressure_exit_relay.has_signal("savepoint_activated")
	):
		return
	var activated_signal: Signal = _lower_deck_forward_pressure_exit_relay.get(
		"savepoint_activated"
	)
	if not activated_signal.is_connected(
		_on_factory_lower_deck_forward_pressure_exit_relay_activated
	):
		activated_signal.connect(
			_on_factory_lower_deck_forward_pressure_exit_relay_activated
		)


func _setup_factory_lower_deck_forward_pressure_aftershock_condenser_savepoint() -> void:
	_sync_lower_deck_forward_pressure_aftershock_condenser_savepoint_state()
	if (
		_lower_deck_forward_pressure_aftershock_condenser_savepoint == null
		or not _lower_deck_forward_pressure_aftershock_condenser_savepoint.has_signal(
			"savepoint_activated"
		)
	):
		return
	var activated_signal: Signal = (
		_lower_deck_forward_pressure_aftershock_condenser_savepoint.get(
			"savepoint_activated"
		)
	)
	if not activated_signal.is_connected(
		_on_factory_lower_deck_forward_pressure_aftershock_condenser_savepoint_activated
	):
		activated_signal.connect(
			_on_factory_lower_deck_forward_pressure_aftershock_condenser_savepoint_activated
		)


func _setup_factory_lower_deck_forward_pressure_exit_gate() -> void:
	_sync_lower_deck_forward_pressure_exit_gate_state()
	if (
		_lower_deck_forward_pressure_exit_gate == null
		or not _lower_deck_forward_pressure_exit_gate.has_signal("endpoint_activated")
	):
		return
	var activated_signal: Signal = _lower_deck_forward_pressure_exit_gate.get(
		"endpoint_activated"
	)
	if not activated_signal.is_connected(
		_on_factory_lower_deck_forward_pressure_exit_gate_activated
	):
		activated_signal.connect(
			_on_factory_lower_deck_forward_pressure_exit_gate_activated
		)


func _setup_factory_lower_deck_forward_pressure_route_handoff_marker() -> void:
	_sync_lower_deck_forward_pressure_route_handoff_marker_state()
	if (
		_lower_deck_forward_pressure_route_handoff_marker == null
		or not _lower_deck_forward_pressure_route_handoff_marker.has_signal(
			"endpoint_activated"
		)
	):
		return
	var activated_signal: Signal = _lower_deck_forward_pressure_route_handoff_marker.get(
		"endpoint_activated"
	)
	if not activated_signal.is_connected(
		_on_factory_lower_deck_forward_pressure_route_handoff_marker_activated
	):
		activated_signal.connect(
			_on_factory_lower_deck_forward_pressure_route_handoff_marker_activated
		)


func _setup_factory_lower_deck_forward_pressure_breaker() -> void:
	_sync_lower_deck_forward_pressure_breaker_state()
	_sync_lower_deck_forward_pressure_breaker_endpoint_state()
	if (
		_lower_deck_forward_pressure_breaker == null
		or not _lower_deck_forward_pressure_breaker.has_signal("endpoint_activated")
	):
		return
	var activated_signal: Signal = _lower_deck_forward_pressure_breaker.get(
		"endpoint_activated"
	)
	if not activated_signal.is_connected(
		_on_factory_lower_deck_forward_pressure_breaker_activated
	):
		activated_signal.connect(
			_on_factory_lower_deck_forward_pressure_breaker_activated
		)


func _setup_factory_lower_deck_forward_pressure_aftershock_exhaust_breaker() -> void:
	_sync_lower_deck_forward_pressure_aftershock_exhaust_breaker_state()
	_sync_lower_deck_forward_pressure_aftershock_exhaust_breaker_endpoint_state()
	if (
		_lower_deck_forward_pressure_aftershock_exhaust_breaker == null
		or not _lower_deck_forward_pressure_aftershock_exhaust_breaker.has_signal(
			"endpoint_activated"
		)
	):
		return
	var activated_signal: Signal = (
		_lower_deck_forward_pressure_aftershock_exhaust_breaker.get(
			"endpoint_activated"
		)
	)
	if not activated_signal.is_connected(
		_on_factory_lower_deck_forward_pressure_aftershock_exhaust_breaker_activated
	):
		activated_signal.connect(
			_on_factory_lower_deck_forward_pressure_aftershock_exhaust_breaker_activated
		)


func _setup_factory_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch() -> void:
	_sync_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch_state()
	if (
		_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch == null
		or not _lower_deck_forward_pressure_aftershock_exhaust_exit_hatch.has_signal(
			"endpoint_activated"
		)
	):
		return
	var activated_signal: Signal = (
		_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch.get(
			"endpoint_activated"
		)
	)
	if not activated_signal.is_connected(
		_on_factory_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch_activated
	):
		activated_signal.connect(
			_on_factory_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch_activated
		)


func _setup_factory_respawn_flow() -> void:
	if _factory_game_flow == null or not is_instance_valid(_factory_game_flow):
		var existing_flow := get_node_or_null("FactoryGameFlowController") as GameFlowController
		if existing_flow != null:
			_factory_game_flow = existing_flow
		else:
			_factory_game_flow = GAME_FLOW_SCRIPT.new() as GameFlowController
			_factory_game_flow.name = "FactoryGameFlowController"
			add_child(_factory_game_flow)

	_factory_game_flow.set_savepoint_adapter(self)
	_factory_game_flow.configure_clan_base_respawn(
		FACTORY_SERVICE_LIFT_EXIT_SCENE_ID,
		FACTORY_SERVICE_LIFT_EXIT_SPAWN_POINT,
		_spawn.global_position if _spawn != null else Vector2.ZERO
	)
	_factory_game_flow.start_encounter(_spawn.global_position if _spawn != null else Vector2.ZERO)
	_configure_factory_respawn_scene_transition()

	var respawn_callback := Callable(self, "_on_factory_respawn_requested")
	if not _factory_game_flow.respawn_requested.is_connected(respawn_callback):
		_factory_game_flow.respawn_requested.connect(respawn_callback)

	var player_death_callback := Callable(self, "_on_factory_player_died")
	if (
		_player != null
		and _player.has_signal("player_died")
		and not _player.is_connected("player_died", player_death_callback)
	):
		_player.connect("player_died", player_death_callback)


func _configure_factory_respawn_scene_transition() -> void:
	if _factory_game_flow == null or not is_instance_valid(_factory_game_flow):
		return
	_factory_game_flow.set_scene_transition_adapter(_resolve_scene_manager_for_runtime())


func _sync_factory_player_control_lock() -> void:
	if (
		_factory_game_flow == null
		or not is_instance_valid(_factory_game_flow)
		or _player == null
		or not is_instance_valid(_player)
		or not _player.has_method("set_control_locked")
	):
		return
	_player.call("set_control_locked", _factory_game_flow.is_player_control_locked())


func _setup_factory_hazards() -> void:
	_sync_checkpoint_steam_vent_state()
	_sync_lower_deck_pressure_hazard_state()
	_sync_lower_deck_forward_pressure_traverse_state()
	_sync_lower_deck_forward_pressure_exit_guard_state()
	for hazard: Area2D in _get_factory_hazards():
		var area_entered_callback := Callable(self, "_on_factory_hazard_area_entered").bind(hazard)
		if not hazard.area_entered.is_connected(area_entered_callback):
			hazard.area_entered.connect(area_entered_callback)
		var body_entered_callback := Callable(self, "_on_factory_hazard_body_entered").bind(hazard)
		if not hazard.body_entered.is_connected(body_entered_callback):
			hazard.body_entered.connect(body_entered_callback)


func _setup_factory_deep_route() -> void:
	_sync_deep_route_state()
	if _deep_endpoint == null or not _deep_endpoint.has_signal("endpoint_activated"):
		return
	var endpoint_signal: Signal = _deep_endpoint.get("endpoint_activated")
	if not endpoint_signal.is_connected(_on_factory_deep_route_endpoint_activated):
		endpoint_signal.connect(_on_factory_deep_route_endpoint_activated)


func _setup_factory_spark_rat() -> void:
	_sync_spark_rat_state()
	_sync_return_patrol_state()
	_sync_checkpoint_forward_patrol_state()
	_sync_checkpoint_rear_ambush_state()
	_sync_checkpoint_overdrive_duo_state()
	_sync_lower_deck_skirmish_state()
	_sync_lower_deck_exit_ambush_state()
	_sync_lower_deck_shortcut_state()
	_sync_lower_deck_steam_sluice_state()
	_sync_lower_deck_forward_pressure_counter_ambush_state()
	_sync_lower_deck_forward_pressure_exit_guard_state()


func _setup_factory_service_lift() -> void:
	_sync_service_lift_state()
	if _service_lift == null or not _service_lift.has_signal("endpoint_activated"):
		return
	var endpoint_signal: Signal = _service_lift.get("endpoint_activated")
	if not endpoint_signal.is_connected(_on_factory_service_lift_activated):
		endpoint_signal.connect(_on_factory_service_lift_activated)


func _bind_player_combat_to_room() -> void:
	if _player == null:
		return
	if _player.has_method("set_target_health_adapter"):
		_player.call("set_target_health_adapter", self)
	if _player.has_method("set_damage_calculator_adapter"):
		_player.call("set_damage_calculator_adapter", self)
	if _player.has_method("set_weapon_component"):
		_player.call("set_weapon_component", _weapon_component)
	if _weapon_component != null:
		if _player.has_method("get_combat_component"):
			_weapon_component.set_combat_adapter(_player.call("get_combat_component"))
		if _player.has_method("get_collision_component"):
			_weapon_component.set_collision_adapter(_player.call("get_collision_component"))
	if _player.has_signal("attack_landed"):
		var attack_signal: Signal = _player.get("attack_landed")
		if not attack_signal.is_connected(_on_player_attack_landed):
			attack_signal.connect(_on_player_attack_landed)


func _on_player_attack_landed(metadata: Dictionary) -> void:
	_last_player_hit_metadata = metadata.duplicate(true)


func _on_factory_enemy_defeated() -> void:
	_encounter_cleared = true
	_sync_room_clear_state()
	_refresh_factory_route_objective()


func _on_factory_deep_guard_defeated() -> void:
	_deep_guard_activated = true
	_deep_guard_defeated = true
	_sync_deep_route_state()
	_refresh_factory_route_objective()


func _on_factory_spark_rat_defeated() -> void:
	_spark_rat_activated = true
	_spark_rat_defeated = true
	_sync_spark_rat_state()
	_sync_service_lift_state()
	_refresh_factory_route_objective()


func _on_factory_return_spark_rat_defeated() -> void:
	_return_patrol_activated = true
	_return_patrol_defeated = true
	_service_lift_activated = false
	_service_lift_exit_requested = false
	_last_service_lift_exit_request = {}
	_last_service_lift_exit_rejected_reason = &""
	_sync_return_patrol_state()
	_sync_return_patrol_reward_cache_state()
	_sync_service_lift_state()
	_refresh_factory_route_objective()


func _on_factory_checkpoint_forward_spark_rat_defeated() -> void:
	_checkpoint_forward_patrol_activated = true
	_checkpoint_forward_patrol_defeated = true
	_service_lift_activated = false
	_service_lift_exit_requested = false
	_last_service_lift_exit_request = {}
	_last_service_lift_exit_rejected_reason = &""
	_sync_checkpoint_forward_patrol_state()
	_sync_checkpoint_steam_vent_state()
	_sync_service_lift_state()
	_refresh_factory_route_objective()


func _on_factory_checkpoint_rear_spark_rat_defeated() -> void:
	_checkpoint_rear_ambush_activated = true
	_checkpoint_rear_ambush_defeated = true
	_service_lift_activated = false
	_service_lift_exit_requested = false
	_last_service_lift_exit_request = {}
	_last_service_lift_exit_rejected_reason = &""
	_sync_checkpoint_rear_ambush_state()
	_sync_checkpoint_overdrive_duo_state()
	_sync_service_lift_state()
	_refresh_factory_route_objective()


func _on_factory_checkpoint_overdrive_left_spark_rat_defeated() -> void:
	_show_checkpoint_overdrive_defeat_burst(
		&"left",
		_checkpoint_overdrive_left_spark_rat
	)
	_checkpoint_overdrive_duo_activated = true
	_checkpoint_overdrive_left_defeated = true
	_service_lift_activated = false
	_service_lift_exit_requested = false
	_last_service_lift_exit_request = {}
	_last_service_lift_exit_rejected_reason = &""
	_sync_checkpoint_overdrive_duo_state()
	_sync_checkpoint_overdrive_reward_cache_state()
	_sync_service_lift_state()
	_refresh_factory_route_objective()


func _on_factory_checkpoint_overdrive_right_spark_rat_defeated() -> void:
	_show_checkpoint_overdrive_defeat_burst(
		&"right",
		_checkpoint_overdrive_right_spark_rat
	)
	_checkpoint_overdrive_duo_activated = true
	_checkpoint_overdrive_right_defeated = true
	_service_lift_activated = false
	_service_lift_exit_requested = false
	_last_service_lift_exit_request = {}
	_last_service_lift_exit_rejected_reason = &""
	_sync_checkpoint_overdrive_duo_state()
	_sync_checkpoint_overdrive_reward_cache_state()
	_sync_service_lift_state()
	_refresh_factory_route_objective()


func _on_factory_lower_deck_spark_rat_defeated() -> void:
	_lower_deck_skirmish_activated = true
	_lower_deck_skirmish_defeated = true
	_sync_lower_deck_skirmish_state()
	_sync_lower_deck_pressure_hazard_state()
	_sync_lower_deck_reward_cache_state()
	_refresh_factory_route_objective()


func _on_factory_lower_deck_exit_spark_rat_defeated() -> void:
	_lower_deck_parry_gate_unlocked = true
	_lower_deck_exit_ambush_activated = true
	_lower_deck_exit_ambush_defeated = true
	_sync_lower_deck_parry_gate_state()
	_sync_lower_deck_exit_ambush_state()
	_sync_lower_deck_shortcut_state()
	_refresh_factory_route_objective()


func _on_factory_lower_deck_shortcut_spark_rat_defeated() -> void:
	_lower_deck_shortcut_activated = true
	_lower_deck_shortcut_guard_defeated = true
	_sync_lower_deck_shortcut_state()
	_refresh_factory_route_objective()


func _on_factory_lower_deck_shortcut_pursuer_defeated() -> void:
	_lower_deck_shortcut_pursuer_activated = true
	_lower_deck_shortcut_pursuer_defeated = true
	_sync_lower_deck_shortcut_pursuer_state()
	_sync_lower_deck_pressure_valve_state()
	_refresh_factory_route_objective()


func _on_factory_lower_deck_pressure_guard_defeated() -> void:
	_lower_deck_pressure_guard_activated = true
	_lower_deck_pressure_guard_defeated = true
	_sync_lower_deck_pressure_valve_state()
	_refresh_factory_route_objective()


func _on_factory_lower_deck_steam_sluice_defeated() -> void:
	_lower_deck_steam_sluice_activated = true
	_lower_deck_steam_sluice_defeated = true
	_sync_lower_deck_steam_sluice_state()
	_sync_lower_deck_deep_bulkhead_state()
	_refresh_factory_route_objective()


func _on_factory_lower_deck_deep_bulkhead_guard_defeated() -> void:
	_lower_deck_deep_bulkhead_guard_activated = true
	_lower_deck_deep_bulkhead_guard_defeated = true
	_sync_lower_deck_deep_bulkhead_state()
	_refresh_factory_route_objective()


func _on_factory_lower_deck_breach_front_guard_defeated() -> void:
	_lower_deck_breach_corridor_activated = true
	_lower_deck_breach_front_guard_defeated = true
	if _lower_deck_breach_rear_ambusher_defeated:
		_lower_deck_breach_corridor_secured = true
	_sync_lower_deck_breach_corridor_state()
	_refresh_factory_route_objective()


func _on_factory_lower_deck_breach_rear_ambusher_defeated() -> void:
	_lower_deck_breach_corridor_activated = true
	_lower_deck_breach_rear_ambusher_activated = true
	_lower_deck_breach_rear_ambusher_defeated = true
	if _lower_deck_breach_front_guard_defeated:
		_lower_deck_breach_corridor_secured = true
	_sync_lower_deck_breach_corridor_state()
	_refresh_factory_route_objective()


func _on_factory_lower_deck_post_relay_trial_defeated() -> void:
	_lower_deck_post_relay_trial_activated = true
	_lower_deck_post_relay_trial_defeated = true
	_sync_lower_deck_post_relay_trial_state()
	_sync_lower_deck_relay_forward_reward_cache_state()
	_sync_lower_deck_forward_hatch_state()
	_refresh_factory_route_objective()


func _on_factory_lower_deck_forward_conduit_defeated() -> void:
	_lower_deck_forward_conduit_activated = true
	_lower_deck_forward_conduit_defeated = true
	_show_lower_deck_forward_conduit_clear_feedback()
	_sync_lower_deck_forward_conduit_state()
	_refresh_factory_route_objective()


func _on_factory_lower_deck_forward_pressure_counter_ambush_defeated() -> void:
	_lower_deck_forward_pressure_counter_ambush_activated = true
	_lower_deck_forward_pressure_counter_ambush_defeated = true
	_sync_lower_deck_forward_pressure_counter_ambush_state()
	_sync_lower_deck_forward_pressure_reward_cache_state()
	_refresh_factory_route_objective()


func _on_factory_lower_deck_forward_pressure_exit_guard_defeated() -> void:
	_lower_deck_forward_pressure_exit_guard_activated = true
	_lower_deck_forward_pressure_exit_guard_defeated = true
	_sync_lower_deck_forward_pressure_exit_guard_state()
	_refresh_factory_route_objective()


func _on_factory_lower_deck_forward_pressure_beacon_ambush_defeated() -> void:
	_lower_deck_forward_pressure_beacon_ambush_activated = true
	_lower_deck_forward_pressure_beacon_ambush_defeated = true
	_sync_lower_deck_forward_pressure_beacon_ambush_state()
	_refresh_factory_route_objective()


func _on_factory_lower_deck_forward_pressure_overrun_defeated() -> void:
	_lower_deck_forward_pressure_overrun_activated = true
	_lower_deck_forward_pressure_overrun_defeated = true
	_sync_lower_deck_forward_pressure_overrun_state()
	_refresh_factory_route_objective()


func _on_factory_lower_deck_forward_pressure_breaker_defeated() -> void:
	_lower_deck_forward_pressure_breaker_activated = true
	_lower_deck_forward_pressure_breaker_secured = true
	_sync_lower_deck_forward_pressure_breaker_state()
	_sync_lower_deck_forward_pressure_breaker_endpoint_state()
	_refresh_factory_route_objective()


func _on_factory_lower_deck_forward_pressure_relief_ambush_defeated() -> void:
	_lower_deck_forward_pressure_relief_ambush_activated = true
	_lower_deck_forward_pressure_relief_ambush_defeated = true
	_sync_lower_deck_forward_pressure_relief_ambush_state()
	_refresh_factory_route_objective()


func _on_factory_lower_deck_forward_pressure_coil_rat_defeated() -> void:
	_lower_deck_forward_pressure_coil_rat_activated = true
	_lower_deck_forward_pressure_coil_rat_defeated = true
	_sync_lower_deck_forward_pressure_coil_rat_state()
	_refresh_factory_route_objective()


func _on_factory_lower_deck_forward_pressure_coil_pincer_spark_rat_defeated() -> void:
	_lower_deck_forward_pressure_coil_pincer_activated = true
	_lower_deck_forward_pressure_coil_pincer_spark_rat_defeated = true
	_sync_lower_deck_forward_pressure_coil_pincer_state()
	_refresh_factory_route_objective()


func _on_factory_lower_deck_forward_pressure_coil_pincer_coil_rat_defeated() -> void:
	_lower_deck_forward_pressure_coil_pincer_activated = true
	_lower_deck_forward_pressure_coil_pincer_coil_rat_defeated = true
	_sync_lower_deck_forward_pressure_coil_pincer_state()
	_refresh_factory_route_objective()


func _on_factory_lower_deck_forward_pressure_coil_aftershock_defeated() -> void:
	_lower_deck_forward_pressure_coil_aftershock_activated = true
	_lower_deck_forward_pressure_coil_aftershock_defeated = true
	_sync_lower_deck_forward_pressure_coil_aftershock_state()
	_sync_lower_deck_forward_pressure_aftershock_reward_cache_state()
	_refresh_factory_route_objective()


func _on_factory_lower_deck_forward_pressure_aftershock_exit_spark_rat_defeated(
) -> void:
	_lower_deck_forward_pressure_aftershock_exit_skirmish_activated = true
	_lower_deck_forward_pressure_aftershock_exit_spark_rat_defeated = true
	_sync_lower_deck_forward_pressure_aftershock_exit_skirmish_state()
	_refresh_factory_route_objective()


func _on_factory_lower_deck_forward_pressure_aftershock_exit_coil_rat_defeated(
) -> void:
	_lower_deck_forward_pressure_aftershock_exit_skirmish_activated = true
	_lower_deck_forward_pressure_aftershock_exit_coil_rat_defeated = true
	_sync_lower_deck_forward_pressure_aftershock_exit_skirmish_state()
	_refresh_factory_route_objective()


func _on_factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_defeated(
) -> void:
	_lower_deck_forward_pressure_aftershock_exhaust_pursuer_activated = true
	_lower_deck_forward_pressure_aftershock_exhaust_pursuer_defeated = true
	_sync_lower_deck_forward_pressure_aftershock_exhaust_pursuer_state()
	_sync_lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache_state()
	_refresh_factory_route_objective()


func _on_factory_lower_deck_forward_pressure_aftershock_exhaust_flank_defeated(
) -> void:
	_lower_deck_forward_pressure_aftershock_exhaust_flank_activated = true
	_lower_deck_forward_pressure_aftershock_exhaust_flank_spark_rat_defeated = true
	_sync_lower_deck_forward_pressure_aftershock_exhaust_flank_state()
	_refresh_factory_route_objective()


func _on_factory_lower_deck_forward_pressure_aftershock_exhaust_breaker_defeated(
) -> void:
	_lower_deck_forward_pressure_aftershock_exhaust_breaker_activated = true
	_lower_deck_forward_pressure_aftershock_exhaust_breaker_coil_rat_defeated = true
	_lower_deck_forward_pressure_aftershock_exhaust_breaker_secured = true
	_sync_lower_deck_forward_pressure_aftershock_exhaust_breaker_state()
	_sync_lower_deck_forward_pressure_aftershock_exhaust_breaker_endpoint_state()
	_refresh_factory_route_objective()


func _on_factory_lower_deck_forward_pressure_aftershock_exhaust_escape_spark_rat_defeated(
) -> void:
	_lower_deck_forward_pressure_aftershock_exhaust_escape_skirmish_activated = true
	_lower_deck_forward_pressure_aftershock_exhaust_escape_spark_rat_defeated = true
	_sync_lower_deck_forward_pressure_aftershock_exhaust_escape_skirmish_state()
	_sync_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch_state()
	_refresh_factory_route_objective()


func _on_factory_lower_deck_forward_pressure_aftershock_exhaust_escape_coil_rat_defeated(
) -> void:
	_lower_deck_forward_pressure_aftershock_exhaust_escape_skirmish_activated = true
	_lower_deck_forward_pressure_aftershock_exhaust_escape_coil_rat_defeated = true
	_sync_lower_deck_forward_pressure_aftershock_exhaust_escape_skirmish_state()
	_sync_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch_state()
	_refresh_factory_route_objective()


func _on_factory_lower_deck_forward_pressure_aftershock_condenser_spark_rat_defeated(
) -> void:
	_lower_deck_forward_pressure_aftershock_condenser_valve_activated = true
	_lower_deck_forward_pressure_aftershock_condenser_valve_spark_rat_defeated = true
	_sync_lower_deck_forward_pressure_aftershock_condenser_valve_state()
	_refresh_factory_route_objective()


func _on_factory_lower_deck_forward_pressure_aftershock_condenser_coil_rat_defeated(
) -> void:
	_lower_deck_forward_pressure_aftershock_condenser_valve_activated = true
	_lower_deck_forward_pressure_aftershock_condenser_valve_coil_rat_defeated = true
	_sync_lower_deck_forward_pressure_aftershock_condenser_valve_state()
	_refresh_factory_route_objective()


func _on_outlet_clamp_spark_rat_defeated() -> void:
	_lower_deck_forward_pressure_aftershock_condenser_outlet_clamp_ambush_activated = true
	_lower_deck_forward_pressure_aftershock_condenser_outlet_clamp_spark_rat_defeated = true
	_sync_outlet_clamp_ambush_state()
	_refresh_factory_route_objective()


func _on_overflow_pump_coil_rat_defeated() -> void:
	_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_activated = true
	_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_coil_rat_defeated = true
	_sync_overflow_pump_state()
	_refresh_factory_route_objective()


func _on_overflow_pump_runoff_exit_coil_rat_defeated() -> void:
	_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_skirmish_activated = true
	_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_coil_rat_defeated = true
	_sync_overflow_pump_runoff_exit_skirmish_state()
	_refresh_factory_route_objective()


func _on_overflow_pump_runoff_outlet_spark_rat_defeated() -> void:
	_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_skirmish_activated = true
	_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_spark_rat_defeated = true
	_sync_overflow_pump_runoff_outlet_skirmish_state()
	_refresh_factory_route_objective()


func _on_overflow_pump_runoff_outlet_service_sluice_spark_rat_defeated() -> void:
	_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_skirmish_activated = true
	_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_spark_rat_defeated = true
	_sync_overflow_pump_runoff_outlet_service_sluice_skirmish_state()
	_refresh_factory_route_objective()


func _on_factory_lower_deck_parry_gate_state_changed(
	gate_id: StringName,
	gate_state: StringName
) -> void:
	if gate_id != FACTORY_LOWER_DECK_PARRY_GATE_ID or gate_state != &"unlocked":
		return
	_lower_deck_parry_gate_unlocked = true
	_sync_lower_deck_parry_gate_state()
	try_activate_factory_lower_deck_exit_ambush(_player)


func _on_factory_lower_deck_shortcut_seal_activated(endpoint_id: StringName) -> void:
	if endpoint_id != FACTORY_LOWER_DECK_SHORTCUT_SEAL_ID:
		return
	_lower_deck_shortcut_unlocked = true
	_sync_lower_deck_shortcut_state()
	_sync_lower_deck_shortcut_reward_cache_state()
	_refresh_factory_route_objective()


func _on_factory_lower_deck_pressure_valve_activated(endpoint_id: StringName) -> void:
	if endpoint_id != FACTORY_LOWER_DECK_PRESSURE_VALVE_ID:
		return
	_lower_deck_pressure_valve_opened = true
	_sync_lower_deck_pressure_valve_state()
	_sync_lower_deck_steam_sluice_state()
	_refresh_factory_route_objective()


func _on_factory_lower_deck_deep_bulkhead_activated(endpoint_id: StringName) -> void:
	if endpoint_id != FACTORY_LOWER_DECK_DEEP_BULKHEAD_ID:
		return
	_lower_deck_deep_bulkhead_opened = true
	_sync_lower_deck_deep_bulkhead_state()
	_refresh_factory_route_objective()


func _on_factory_cache_claimed(_cache_id: StringName, reward: Dictionary) -> void:
	_cache_claimed = true
	_last_cache_reward = reward.duplicate(true)
	_record_cache_claim_feedback(_last_cache_reward, "Cache Claimed")


func _on_factory_return_patrol_reward_cache_claimed(
	_cache_id: StringName,
	reward: Dictionary
) -> void:
	_return_patrol_reward_cache_claimed = true
	_last_return_patrol_reward_cache_reward = reward.duplicate(true)
	_record_return_patrol_reward_cache_claim_feedback(
		_last_return_patrol_reward_cache_reward,
		"Return Cache Claimed"
	)


func _on_factory_checkpoint_overdrive_reward_cache_claimed(
	_cache_id: StringName,
	reward: Dictionary
) -> void:
	_checkpoint_overdrive_reward_cache_claimed = true
	_last_checkpoint_overdrive_reward_cache_reward = reward.duplicate(true)
	_record_checkpoint_overdrive_reward_cache_claim_feedback(
		_last_checkpoint_overdrive_reward_cache_reward,
		"Overdrive Cache Claimed"
	)


func _on_factory_lower_deck_reward_cache_claimed(
	_cache_id: StringName,
	reward: Dictionary
) -> void:
	_lower_deck_reward_cache_claimed = true
	_last_lower_deck_reward_cache_reward = reward.duplicate(true)
	_record_lower_deck_reward_cache_claim_feedback(
		_last_lower_deck_reward_cache_reward,
		"Lower Deck Cache Claimed"
	)
	_sync_lower_deck_parry_gate_state()


func _on_factory_lower_deck_shortcut_reward_cache_claimed(
	_cache_id: StringName,
	reward: Dictionary
) -> void:
	_lower_deck_shortcut_reward_cache_claimed = true
	_last_lower_deck_shortcut_reward_cache_reward = reward.duplicate(true)
	_record_lower_deck_shortcut_reward_cache_claim_feedback(
		_last_lower_deck_shortcut_reward_cache_reward,
		"Shortcut Cache Claimed"
	)


func _on_factory_lower_deck_relay_forward_reward_cache_claimed(
	_cache_id: StringName,
	reward: Dictionary
) -> void:
	_lower_deck_relay_forward_reward_cache_claimed = true
	_last_lower_deck_relay_forward_reward_cache_reward = reward.duplicate(true)
	_record_lower_deck_relay_forward_reward_cache_claim_feedback(
		_last_lower_deck_relay_forward_reward_cache_reward,
		"Relay Forward Cache Claimed"
	)
	_sync_lower_deck_forward_hatch_state()


func _on_factory_lower_deck_forward_pressure_reward_cache_claimed(
	_cache_id: StringName,
	reward: Dictionary
) -> void:
	_lower_deck_forward_pressure_reward_cache_claimed = true
	_last_lower_deck_forward_pressure_reward_cache_reward = reward.duplicate(true)
	_record_lower_deck_forward_pressure_reward_cache_claim_feedback(
		_last_lower_deck_forward_pressure_reward_cache_reward,
		"Forward Pressure Cache Claimed"
	)
	_request_lower_deck_forward_pressure_reward_cache_claim_audio(
		_last_lower_deck_forward_pressure_reward_cache_reward
	)


func _on_factory_lower_deck_forward_pressure_aftershock_reward_cache_claimed(
	_cache_id: StringName,
	reward: Dictionary
) -> void:
	_lower_deck_forward_pressure_aftershock_reward_cache_claimed = true
	_last_lower_deck_forward_pressure_aftershock_reward_cache_reward = reward.duplicate(
		true
	)
	_record_lower_deck_forward_pressure_aftershock_reward_cache_claim_feedback(
		_last_lower_deck_forward_pressure_aftershock_reward_cache_reward,
		"Forward Pressure Aftershock Cache Claimed"
	)
	_sync_lower_deck_forward_pressure_aftershock_exit_skirmish_state()
	_refresh_factory_route_objective()


func _on_factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache_claimed(
	_cache_id: StringName,
	reward: Dictionary
) -> void:
	_lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache_claimed = true
	_last_lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache_reward = (
		reward.duplicate(true)
	)
	_record_lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache_claim_feedback(
		_last_lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache_reward,
		"Forward Pressure Exhaust Pursuer Cache Claimed"
	)
	_sync_lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache_state()
	_sync_lower_deck_forward_pressure_aftershock_exhaust_flank_state()
	_refresh_factory_route_objective()


func _on_factory_lower_deck_forward_hatch_activated(endpoint_id: StringName) -> void:
	if endpoint_id != FACTORY_LOWER_DECK_FORWARD_HATCH_ID:
		return
	_lower_deck_forward_hatch_opened = true
	_sync_lower_deck_forward_hatch_state()
	_refresh_factory_route_objective()


func _on_factory_lower_deck_forward_pressure_exit_gate_activated(
	endpoint_id: StringName
) -> void:
	if endpoint_id != FACTORY_LOWER_DECK_FORWARD_PRESSURE_EXIT_GATE_ID:
		return
	_lower_deck_forward_pressure_exit_gate_opened = true
	_sync_lower_deck_forward_pressure_exit_gate_state()
	_sync_lower_deck_forward_pressure_route_handoff_marker_state()
	_update_route_label("Forward Pressure Exit Gate Opened")


func _on_factory_lower_deck_forward_pressure_route_handoff_marker_activated(
	endpoint_id: StringName
) -> void:
	if endpoint_id != FACTORY_LOWER_DECK_FORWARD_PRESSURE_ROUTE_HANDOFF_MARKER_ID:
		return
	_lower_deck_forward_pressure_route_handoff_marker_lit = true
	_sync_lower_deck_forward_pressure_route_handoff_marker_state()
	_update_route_label("Forward Pressure Route Beacon Lit")


func _on_factory_lower_deck_forward_pressure_breaker_activated(
	endpoint_id: StringName
) -> void:
	if endpoint_id != FACTORY_LOWER_DECK_FORWARD_PRESSURE_BREAKER_ID:
		return
	_lower_deck_forward_pressure_breaker_cut = true
	_sync_lower_deck_forward_pressure_breaker_endpoint_state()
	_update_route_label("Forward Pressure Breaker Cut")


func _on_factory_lower_deck_forward_pressure_aftershock_exhaust_breaker_activated(
	endpoint_id: StringName
) -> void:
	if endpoint_id != FACTORY_LOWER_DECK_FORWARD_PRESSURE_AFTERSHOCK_EXHAUST_BREAKER_ID:
		return
	_lower_deck_forward_pressure_aftershock_exhaust_breaker_cut = true
	_sync_lower_deck_forward_pressure_aftershock_exhaust_breaker_endpoint_state()
	_update_route_label("Aftershock Exhaust Pressure Cut")


func _on_factory_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch_activated(
	endpoint_id: StringName
) -> void:
	if endpoint_id != FACTORY_LOWER_DECK_FORWARD_PRESSURE_AFTERSHOCK_EXHAUST_EXIT_HATCH_ID:
		return
	_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch_opened = true
	_sync_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch_state()
	_update_route_label("Aftershock Exhaust Exit Opened")


func _on_factory_return_checkpoint_activated(
	savepoint_id: StringName,
	scene_id: StringName,
	spawn_point: StringName,
	world_position: Vector2,
	context: Dictionary
) -> void:
	_return_checkpoint_activated = true
	_last_return_checkpoint = _build_return_checkpoint_snapshot(
		savepoint_id,
		scene_id,
		spawn_point,
		world_position,
		context
	)
	_sync_return_checkpoint_state()
	if _is_checkpoint_route_chain_started():
		_refresh_factory_route_objective()
	else:
		_update_route_label("Factory Savepoint Secured")


func _on_factory_lower_deck_breach_relay_activated(
	savepoint_id: StringName,
	scene_id: StringName,
	spawn_point: StringName,
	world_position: Vector2,
	context: Dictionary
) -> void:
	if savepoint_id != FACTORY_LOWER_DECK_BREACH_RELAY_ID:
		return
	if _lower_deck_breach_relay_activated:
		return
	_lower_deck_breach_relay_activated = true
	_last_return_checkpoint = _build_return_checkpoint_snapshot(
		savepoint_id,
		scene_id,
		spawn_point,
		world_position,
		context
	)
	_sync_lower_deck_breach_relay_state()
	_update_route_label("Lower Deck Relay Secured")
	_request_lower_deck_breach_relay_activation_audio(world_position, context)


func _on_factory_lower_deck_forward_pressure_exit_relay_activated(
	savepoint_id: StringName,
	scene_id: StringName,
	spawn_point: StringName,
	world_position: Vector2,
	context: Dictionary
) -> void:
	if savepoint_id != FACTORY_LOWER_DECK_FORWARD_PRESSURE_EXIT_RELAY_ID:
		return
	if _lower_deck_forward_pressure_exit_relay_activated:
		return
	_lower_deck_forward_pressure_exit_relay_activated = true
	_last_return_checkpoint = _build_return_checkpoint_snapshot(
		savepoint_id,
		scene_id,
		spawn_point,
		world_position,
		context
	)
	_sync_lower_deck_forward_pressure_exit_relay_state(true)
	_update_route_label("Forward Pressure Exit Relay Secured")


func _on_factory_lower_deck_forward_pressure_aftershock_condenser_savepoint_activated(
	savepoint_id: StringName,
	scene_id: StringName,
	spawn_point: StringName,
	world_position: Vector2,
	context: Dictionary
) -> void:
	if savepoint_id != FACTORY_LOWER_DECK_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_SAVEPOINT_ID:
		return
	if _lower_deck_forward_pressure_aftershock_condenser_savepoint_activated:
		return
	_lower_deck_forward_pressure_aftershock_condenser_savepoint_activated = true
	_last_return_checkpoint = _build_return_checkpoint_snapshot(
		savepoint_id,
		scene_id,
		spawn_point,
		world_position,
		context
	)
	_return_checkpoint_activated = true
	_sync_lower_deck_forward_pressure_aftershock_condenser_savepoint_state(true)
	_update_route_label("Aftershock Condenser Savepoint Secured")


func _on_factory_player_died(_death_metadata: Dictionary) -> void:
	if _factory_game_flow == null or not is_instance_valid(_factory_game_flow):
		return
	_factory_game_flow.handle_player_death()
	_sync_factory_player_control_lock()


func _on_factory_respawn_requested(respawn_position: Vector2, revive_hp_percentage: float) -> void:
	_grant_factory_hazard_respawn_grace()
	if _player != null and is_instance_valid(_player) and _player.has_method("respawn_at"):
		_player.call("respawn_at", respawn_position, revive_hp_percentage)
	_sync_factory_player_control_lock()

	var selected_respawn_point: Dictionary = _factory_game_flow.get_last_selected_respawn_point()
	if String(selected_respawn_point.get("spawn_point", "")) == String(FACTORY_RETURN_CHECKPOINT_SPAWN_POINT):
		_update_route_label(FACTORY_RETURN_CHECKPOINT_RESPAWN_LABEL)
	elif String(selected_respawn_point.get("spawn_point", "")) == String(
		FACTORY_LOWER_DECK_BREACH_RELAY_SPAWN_POINT
	):
		_update_route_label(FACTORY_LOWER_DECK_BREACH_RELAY_RESPAWN_LABEL)
	elif String(selected_respawn_point.get("spawn_point", "")) == String(
		FACTORY_LOWER_DECK_FORWARD_PRESSURE_EXIT_RELAY_SPAWN_POINT
	):
		_update_route_label(FACTORY_LOWER_DECK_FORWARD_PRESSURE_EXIT_RELAY_RESPAWN_LABEL)
	elif String(selected_respawn_point.get("spawn_point", "")) == String(
		FACTORY_LOWER_DECK_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_SAVEPOINT_SPAWN_POINT
	):
		_update_route_label(
			FACTORY_LOWER_DECK_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_SAVEPOINT_RESPAWN_LABEL
		)
	_apply_current_scene_manager_spawn_point()


func _on_factory_deep_route_endpoint_activated(_endpoint_id: StringName) -> void:
	_deep_route_cleared = true
	_sync_deep_route_state()
	_sync_spark_rat_state()
	_sync_service_lift_state()
	_refresh_factory_route_objective()


func _on_factory_service_lift_activated(endpoint_id: StringName) -> void:
	if endpoint_id != FACTORY_SERVICE_LIFT_ENDPOINT_ID:
		return
	_service_lift_activated = true
	_sync_service_lift_state()
	_update_route_label("Service Lift Departing")


func _on_factory_hazard_area_entered(area: Area2D, hazard: Area2D) -> void:
	var target: Node = _resolve_factory_hazard_target_from_area(area)
	if target != null:
		apply_factory_steam_vent_contact(hazard, target)


func _on_factory_hazard_body_entered(body: Node2D, hazard: Area2D) -> void:
	if body == _player:
		apply_factory_steam_vent_contact(hazard, _player)


func _setup_weapon_component() -> void:
	_weapon_component = get_node_or_null("WeaponComponent") as WeaponComponent
	if _weapon_component == null:
		_weapon_component = WEAPON_COMPONENT_SCRIPT.new() as WeaponComponent
		_weapon_component.name = "WeaponComponent"
		add_child(_weapon_component)
	var root_data_manager: Node = get_node_or_null("/root/DataManager")
	if root_data_manager != null:
		_weapon_component.set_data_manager(root_data_manager)


func _request_factory_audio() -> void:
	var audio_system := get_node_or_null("/root/AudioSystem")
	if audio_system == null:
		return
	if audio_system.has_method("play_music"):
		audio_system.call("play_music", FACTORY_MUSIC_ID, FACTORY_AUDIO_FADE_SEC)
	if audio_system.has_method("play_ambient"):
		audio_system.call("play_ambient", FACTORY_AMBIENT_ID, FACTORY_AUDIO_FADE_SEC)


func _request_lower_deck_breach_relay_activation_audio(world_position: Vector2, context: Dictionary) -> void:
	var metadata: Dictionary = context.duplicate(true)
	metadata["display_name"] = _get_lower_deck_breach_relay_display_name()
	metadata["feedback_role"] = &"savepoint_activation"
	metadata["route_label"] = "Lower Deck Relay Secured"
	metadata["source"] = &"factory_lower_deck_breach_relay"
	metadata["world_position"] = world_position

	_lower_deck_breach_relay_activation_audio_request_count += 1
	_lower_deck_breach_relay_activation_audio_event = {
		"event_id": &"savepoint_activated",
		"sfx_id": &"sfx_door_unlock",
		"position": world_position,
		"priority": 90,
		"metadata": metadata.duplicate(true),
	}

	var audio_system := get_node_or_null("/root/AudioSystem")
	if audio_system == null or not audio_system.has_method("on_savepoint_activated"):
		return
	audio_system.call(
		"on_savepoint_activated",
		FACTORY_LOWER_DECK_BREACH_RELAY_ID,
		FACTORY_SCENE_ID,
		FACTORY_LOWER_DECK_BREACH_RELAY_SPAWN_POINT,
		world_position,
		metadata
	)
	if audio_system.has_method("get_last_gameplay_audio_event"):
		var runtime_event: Variant = audio_system.call("get_last_gameplay_audio_event")
		if runtime_event is Dictionary:
			_lower_deck_breach_relay_activation_audio_event = (runtime_event as Dictionary).duplicate(true)


func _request_lower_deck_forward_pressure_reward_cache_claim_audio(reward: Dictionary) -> void:
	var world_position: Vector2 = Vector2.ZERO
	if _lower_deck_forward_pressure_reward_cache is Node2D:
		world_position = (_lower_deck_forward_pressure_reward_cache as Node2D).global_position
	var metadata: Dictionary = {
		"cache_id": FACTORY_LOWER_DECK_FORWARD_PRESSURE_REWARD_CACHE_ID,
		"display_name": "Forward Pressure Cache",
		"feedback_role": &"reward_cache_claim",
		"gears": int(reward.get("gears", 0)),
		"reward_gears": int(reward.get("gears", 0)),
		"route_label": "Forward Pressure Cache Claimed +20 Gears",
		"scene_id": FACTORY_SCENE_ID,
		"source": FACTORY_LOWER_DECK_FORWARD_PRESSURE_REWARD_CACHE_ID,
		"world_position": world_position,
	}
	_lower_deck_forward_pressure_reward_cache_claim_audio_request_count += 1
	_lower_deck_forward_pressure_reward_cache_claim_audio_event = {
		"event_id": &"reward_cache_claimed",
		"sfx_id": &"sfx_door_unlock",
		"position": world_position,
		"priority": 90,
		"metadata": metadata.duplicate(true),
	}

	var audio_system := get_node_or_null("/root/AudioSystem")
	if audio_system == null or not audio_system.has_method("on_reward_cache_claimed"):
		return
	audio_system.call(
		"on_reward_cache_claimed",
		FACTORY_LOWER_DECK_FORWARD_PRESSURE_REWARD_CACHE_ID,
		reward,
		world_position,
		metadata
	)
	if audio_system.has_method("get_last_gameplay_audio_event"):
		var runtime_event: Variant = audio_system.call("get_last_gameplay_audio_event")
		if runtime_event is Dictionary:
			_lower_deck_forward_pressure_reward_cache_claim_audio_event = (
				(runtime_event as Dictionary).duplicate(true)
			)


func _sync_room_clear_state() -> void:
	if _cache != null:
		if _cache.has_method("set_available"):
			_cache.call("set_available", _encounter_cleared)
		if _cache.has_method("set_claimed"):
			_cache.call("set_claimed", _cache_claimed)
	if _encounter_cleared:
		_refresh_factory_route_objective()
	if _enemy != null and _encounter_cleared and _cache_claimed:
		_enemy.visible = false
		_enemy.set_physics_process(false)
		_enemy.set_process(false)
		_enemy.set_deferred("collision_layer", 0)
		_enemy.set_deferred("collision_mask", 0)


func _sync_deep_route_state() -> void:
	if _deep_endpoint != null:
		if _deep_endpoint.has_method("set_available"):
			_deep_endpoint.call("set_available", _deep_guard_defeated)
		if _deep_endpoint.has_method("set_activated"):
			_deep_endpoint.call("set_activated", _deep_route_cleared)
	if _deep_guard != null and _deep_guard_defeated:
		_deep_guard.visible = false
		_deep_guard.set_physics_process(false)
		_deep_guard.set_process(false)
		_deep_guard.set_deferred("collision_layer", 0)
		_deep_guard.set_deferred("collision_mask", 0)
	elif _deep_guard != null:
		_deep_guard.visible = true
		_deep_guard.set_physics_process(_deep_guard_activated)
		_deep_guard.set_process(_deep_guard_activated)
		if _deep_guard_activated:
			_deep_guard.set_deferred("collision_layer", FACTORY_RAT_MINION_COLLISION_LAYER)
			_deep_guard.set_deferred("collision_mask", FACTORY_RAT_MINION_COLLISION_MASK)
			_set_deep_guard_attack_target(_player)
		else:
			_deep_guard.set_deferred("collision_layer", 0)
			_deep_guard.set_deferred("collision_mask", 0)
			_set_deep_guard_attack_target(null)


func _sync_spark_rat_state() -> void:
	if _spark_rat == null:
		return
	if _spark_rat_defeated:
		_spark_rat.visible = false
		_spark_rat.set_physics_process(false)
		_spark_rat.set_process(false)
		_spark_rat.collision_layer = 0
		_spark_rat.collision_mask = 0
		_set_spark_rat_attack_target(null)
		return
	_spark_rat.visible = true
	var active: bool = _deep_route_cleared and _spark_rat_activated
	_spark_rat.set_physics_process(active)
	_spark_rat.set_process(active)
	if active:
		_spark_rat.collision_layer = FACTORY_RAT_MINION_COLLISION_LAYER
		_spark_rat.collision_mask = FACTORY_RAT_MINION_COLLISION_MASK
		_set_spark_rat_attack_target(_player)
	else:
		_spark_rat.collision_layer = 0
		_spark_rat.collision_mask = 0
		_set_spark_rat_attack_target(null)


func _sync_return_patrol_state() -> void:
	if _return_spark_rat == null:
		return
	if _return_patrol_defeated or not _return_patrol_activated:
		_return_spark_rat.visible = false
		_return_spark_rat.set_physics_process(false)
		_return_spark_rat.set_process(false)
		_return_spark_rat.collision_layer = 0
		_return_spark_rat.collision_mask = 0
		_set_return_spark_rat_attack_target(null)
		return
	_return_spark_rat.visible = true
	_return_spark_rat.set_physics_process(true)
	_return_spark_rat.set_process(true)
	_return_spark_rat.collision_layer = FACTORY_RAT_MINION_COLLISION_LAYER
	_return_spark_rat.collision_mask = FACTORY_RAT_MINION_COLLISION_MASK
	_set_return_spark_rat_attack_target(_player)


func _sync_checkpoint_forward_patrol_state() -> void:
	if _checkpoint_forward_spark_rat == null:
		return
	if (
		_checkpoint_forward_patrol_defeated
		or not _return_checkpoint_activated
		or not _checkpoint_forward_patrol_activated
	):
		_checkpoint_forward_spark_rat.visible = false
		_checkpoint_forward_spark_rat.set_physics_process(false)
		_checkpoint_forward_spark_rat.set_process(false)
		_checkpoint_forward_spark_rat.collision_layer = 0
		_checkpoint_forward_spark_rat.collision_mask = 0
		_set_checkpoint_forward_spark_rat_attack_target(null)
		return
	_checkpoint_forward_spark_rat.visible = true
	_checkpoint_forward_spark_rat.set_physics_process(true)
	_checkpoint_forward_spark_rat.set_process(true)
	_checkpoint_forward_spark_rat.collision_layer = FACTORY_RAT_MINION_COLLISION_LAYER
	_checkpoint_forward_spark_rat.collision_mask = FACTORY_RAT_MINION_COLLISION_MASK
	_set_checkpoint_forward_spark_rat_attack_target(_player)


func _sync_checkpoint_rear_ambush_state() -> void:
	if _checkpoint_rear_spark_rat == null:
		return
	if (
		_checkpoint_rear_ambush_defeated
		or not _checkpoint_forward_patrol_defeated
		or not _checkpoint_rear_ambush_activated
	):
		_checkpoint_rear_spark_rat.visible = false
		_checkpoint_rear_spark_rat.set_physics_process(false)
		_checkpoint_rear_spark_rat.set_process(false)
		_checkpoint_rear_spark_rat.collision_layer = 0
		_checkpoint_rear_spark_rat.collision_mask = 0
		_set_checkpoint_rear_spark_rat_attack_target(null)
		return
	_checkpoint_rear_spark_rat.visible = true
	_checkpoint_rear_spark_rat.set_physics_process(true)
	_checkpoint_rear_spark_rat.set_process(true)
	_checkpoint_rear_spark_rat.collision_layer = FACTORY_RAT_MINION_COLLISION_LAYER
	_checkpoint_rear_spark_rat.collision_mask = FACTORY_RAT_MINION_COLLISION_MASK
	_set_checkpoint_rear_spark_rat_attack_target(_player)


func _sync_checkpoint_overdrive_duo_state() -> void:
	_sync_checkpoint_overdrive_spark_rat_state(
		_checkpoint_overdrive_left_spark_rat,
		_checkpoint_overdrive_left_defeated
	)
	_sync_checkpoint_overdrive_spark_rat_state(
		_checkpoint_overdrive_right_spark_rat,
		_checkpoint_overdrive_right_defeated
	)


func _sync_checkpoint_overdrive_spark_rat_state(
	spark_rat: Node2D,
	defeated: bool
) -> void:
	if spark_rat == null:
		return
	if (
		defeated
		or not _checkpoint_rear_ambush_defeated
		or not _checkpoint_overdrive_duo_activated
	):
		spark_rat.visible = false
		spark_rat.set_physics_process(false)
		spark_rat.set_process(false)
		spark_rat.collision_layer = 0
		spark_rat.collision_mask = 0
		if spark_rat.has_method("set_attack_target"):
			spark_rat.call("set_attack_target", null)
		return
	spark_rat.visible = true
	spark_rat.set_physics_process(true)
	spark_rat.set_process(true)
	spark_rat.collision_layer = FACTORY_RAT_MINION_COLLISION_LAYER
	spark_rat.collision_mask = FACTORY_RAT_MINION_COLLISION_MASK
	if spark_rat.has_method("set_attack_target"):
		spark_rat.call("set_attack_target", _player)


func _sync_checkpoint_steam_vent_state() -> void:
	if _checkpoint_steam_vent == null:
		return
	var active: bool = _checkpoint_forward_patrol_defeated
	_checkpoint_steam_vent.visible = active
	_checkpoint_steam_vent.monitoring = active
	_checkpoint_steam_vent.collision_layer = (
		CollisionComponent.COLLISION_LAYER_ENVIRONMENT if active else 0
	)
	_checkpoint_steam_vent.collision_mask = (
		CollisionComponent.COLLISION_MASK_ENVIRONMENT if active else 0
	)
	var collision_shape := (
		_checkpoint_steam_vent.get_node_or_null("CollisionShape2D")
		as CollisionShape2D
	)
	if collision_shape != null:
		collision_shape.disabled = not active


func _sync_lower_deck_skirmish_state() -> void:
	if _lower_deck_spark_rat == null:
		return
	if (
		_lower_deck_skirmish_defeated
		or not _is_checkpoint_overdrive_duo_cleared()
		or not _lower_deck_skirmish_activated
	):
		_lower_deck_spark_rat.visible = false
		_lower_deck_spark_rat.set_physics_process(false)
		_lower_deck_spark_rat.set_process(false)
		_lower_deck_spark_rat.collision_layer = 0
		_lower_deck_spark_rat.collision_mask = 0
		_set_lower_deck_spark_rat_attack_target(null)
		return
	_lower_deck_spark_rat.visible = true
	_lower_deck_spark_rat.set_physics_process(true)
	_lower_deck_spark_rat.set_process(true)
	_lower_deck_spark_rat.collision_layer = FACTORY_RAT_MINION_COLLISION_LAYER
	_lower_deck_spark_rat.collision_mask = FACTORY_RAT_MINION_COLLISION_MASK
	_set_lower_deck_spark_rat_attack_target(_player)


func _sync_lower_deck_pressure_hazard_state() -> void:
	if _lower_deck_steam_vent == null:
		return
	var active: bool = _is_lower_deck_skirmish_active()
	_lower_deck_steam_vent.visible = active
	_lower_deck_steam_vent.monitoring = active
	_lower_deck_steam_vent.collision_layer = (
		CollisionComponent.COLLISION_LAYER_ENVIRONMENT if active else 0
	)
	_lower_deck_steam_vent.collision_mask = (
		CollisionComponent.COLLISION_MASK_ENVIRONMENT if active else 0
	)
	var collision_shape := (
		_lower_deck_steam_vent.get_node_or_null("CollisionShape2D")
		as CollisionShape2D
	)
	if collision_shape != null:
		collision_shape.disabled = not active


func _sync_return_patrol_reward_cache_state() -> void:
	if _return_patrol_reward_cache == null:
		return
	_return_patrol_reward_cache.visible = _return_patrol_activated or _return_patrol_defeated
	if _return_patrol_reward_cache.has_method("set_available"):
		_return_patrol_reward_cache.call("set_available", _return_patrol_defeated)
	if _return_patrol_reward_cache.has_method("set_claimed"):
		_return_patrol_reward_cache.call("set_claimed", _return_patrol_reward_cache_claimed)


func _sync_checkpoint_overdrive_reward_cache_state() -> void:
	if _checkpoint_overdrive_reward_cache == null:
		return
	_checkpoint_overdrive_reward_cache.visible = (
		_checkpoint_overdrive_duo_activated
		or _is_checkpoint_overdrive_duo_cleared()
		or _checkpoint_overdrive_reward_cache_claimed
	)
	if _checkpoint_overdrive_reward_cache.has_method("set_available"):
		_checkpoint_overdrive_reward_cache.call(
			"set_available",
			_is_checkpoint_overdrive_duo_cleared()
		)
	if _checkpoint_overdrive_reward_cache.has_method("set_claimed"):
		_checkpoint_overdrive_reward_cache.call(
			"set_claimed",
			_checkpoint_overdrive_reward_cache_claimed
		)


func _sync_lower_deck_reward_cache_state() -> void:
	if _lower_deck_reward_cache == null:
		return
	_lower_deck_reward_cache.visible = (
		_lower_deck_skirmish_defeated
		or _lower_deck_reward_cache_claimed
	)
	if _lower_deck_reward_cache.has_method("set_available"):
		_lower_deck_reward_cache.call("set_available", _lower_deck_skirmish_defeated)
	if _lower_deck_reward_cache.has_method("set_claimed"):
		_lower_deck_reward_cache.call("set_claimed", _lower_deck_reward_cache_claimed)


func _sync_lower_deck_shortcut_reward_cache_state() -> void:
	if _lower_deck_shortcut_reward_cache == null:
		return
	_lower_deck_shortcut_reward_cache.visible = (
		_lower_deck_shortcut_unlocked
		or _lower_deck_shortcut_reward_cache_claimed
	)
	if _lower_deck_shortcut_reward_cache.has_method("set_available"):
		_lower_deck_shortcut_reward_cache.call(
			"set_available",
			_lower_deck_shortcut_unlocked
		)
	if _lower_deck_shortcut_reward_cache.has_method("set_claimed"):
		_lower_deck_shortcut_reward_cache.call(
			"set_claimed",
			_lower_deck_shortcut_reward_cache_claimed
		)


func _sync_lower_deck_relay_forward_reward_cache_state() -> void:
	if _lower_deck_relay_forward_reward_cache == null:
		return
	_lower_deck_relay_forward_reward_cache.visible = (
		_lower_deck_post_relay_trial_defeated
		or _lower_deck_relay_forward_reward_cache_claimed
	)
	if _lower_deck_relay_forward_reward_cache.has_method("set_available"):
		_lower_deck_relay_forward_reward_cache.call(
			"set_available",
			_lower_deck_post_relay_trial_defeated
		)
	if _lower_deck_relay_forward_reward_cache.has_method("set_claimed"):
		_lower_deck_relay_forward_reward_cache.call(
			"set_claimed",
			_lower_deck_relay_forward_reward_cache_claimed
		)


func _sync_lower_deck_forward_pressure_reward_cache_state() -> void:
	if _lower_deck_forward_pressure_reward_cache == null:
		return
	_lower_deck_forward_pressure_reward_cache.visible = (
		_lower_deck_forward_pressure_counter_ambush_defeated
		or _lower_deck_forward_pressure_reward_cache_claimed
	)
	if _lower_deck_forward_pressure_reward_cache.has_method("set_available"):
		_lower_deck_forward_pressure_reward_cache.call(
			"set_available",
			_lower_deck_forward_pressure_counter_ambush_defeated
		)
	if _lower_deck_forward_pressure_reward_cache.has_method("set_claimed"):
		_lower_deck_forward_pressure_reward_cache.call(
			"set_claimed",
			_lower_deck_forward_pressure_reward_cache_claimed
		)


func _sync_lower_deck_forward_pressure_aftershock_reward_cache_state() -> void:
	if _lower_deck_forward_pressure_aftershock_reward_cache == null:
		return
	_lower_deck_forward_pressure_aftershock_reward_cache.visible = (
		_lower_deck_forward_pressure_coil_aftershock_defeated
		or _lower_deck_forward_pressure_aftershock_reward_cache_claimed
	)
	if _lower_deck_forward_pressure_aftershock_reward_cache.has_method("set_available"):
		_lower_deck_forward_pressure_aftershock_reward_cache.call(
			"set_available",
			_lower_deck_forward_pressure_coil_aftershock_defeated
		)
	if _lower_deck_forward_pressure_aftershock_reward_cache.has_method("set_claimed"):
		_lower_deck_forward_pressure_aftershock_reward_cache.call(
			"set_claimed",
			_lower_deck_forward_pressure_aftershock_reward_cache_claimed
		)


func _sync_lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache_state(
) -> void:
	var cache: Node = _lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache
	if cache == null:
		return
	cache.visible = (
		_lower_deck_forward_pressure_aftershock_exhaust_pursuer_defeated
		or _lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache_claimed
	)
	if cache.has_method("set_available"):
		cache.call(
			"set_available",
			_lower_deck_forward_pressure_aftershock_exhaust_pursuer_defeated
		)
	if cache.has_method("set_claimed"):
		cache.call(
			"set_claimed",
			_lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache_claimed
		)


func _sync_lower_deck_breach_relay_state() -> void:
	if _lower_deck_breach_relay == null:
		return
	var available: bool = _is_lower_deck_breach_relay_available()
	_lower_deck_breach_relay.visible = available or _lower_deck_breach_relay_activated
	var interaction_area := (
		_lower_deck_breach_relay.get_node_or_null("InteractionArea") as Area2D
	)
	if interaction_area != null:
		if interaction_area.monitoring != available:
			interaction_area.monitoring = available
		if interaction_area.monitorable != available:
			interaction_area.monitorable = available
	var collision_shape := (
		_lower_deck_breach_relay.get_node_or_null("InteractionArea/CollisionShape2D")
		as CollisionShape2D
	)
	if collision_shape != null:
		var should_disable: bool = not available
		if collision_shape.disabled != should_disable:
			collision_shape.disabled = should_disable


func _sync_lower_deck_shortcut_pursuer_state() -> void:
	if _lower_deck_shortcut_pursuer_spark_rat == null:
		return
	if not _is_lower_deck_shortcut_pursuer_active():
		_lower_deck_shortcut_pursuer_spark_rat.visible = false
		_lower_deck_shortcut_pursuer_spark_rat.set_physics_process(false)
		_lower_deck_shortcut_pursuer_spark_rat.set_process(false)
		_lower_deck_shortcut_pursuer_spark_rat.collision_layer = 0
		_lower_deck_shortcut_pursuer_spark_rat.collision_mask = 0
		_set_lower_deck_shortcut_pursuer_attack_target(null)
		return
	_lower_deck_shortcut_pursuer_spark_rat.visible = true
	_lower_deck_shortcut_pursuer_spark_rat.set_physics_process(true)
	_lower_deck_shortcut_pursuer_spark_rat.set_process(true)
	_lower_deck_shortcut_pursuer_spark_rat.collision_layer = FACTORY_RAT_MINION_COLLISION_LAYER
	_lower_deck_shortcut_pursuer_spark_rat.collision_mask = FACTORY_RAT_MINION_COLLISION_MASK
	_set_lower_deck_shortcut_pursuer_attack_target(_player)


func _sync_lower_deck_pressure_valve_state() -> void:
	if _lower_deck_pressure_guard_spark_rat != null:
		if not _is_lower_deck_pressure_guard_active():
			_lower_deck_pressure_guard_spark_rat.visible = false
			_lower_deck_pressure_guard_spark_rat.set_physics_process(false)
			_lower_deck_pressure_guard_spark_rat.set_process(false)
			_lower_deck_pressure_guard_spark_rat.collision_layer = 0
			_lower_deck_pressure_guard_spark_rat.collision_mask = 0
			_set_lower_deck_pressure_guard_attack_target(null)
		else:
			_lower_deck_pressure_guard_spark_rat.visible = true
			_lower_deck_pressure_guard_spark_rat.set_physics_process(true)
			_lower_deck_pressure_guard_spark_rat.set_process(true)
			_lower_deck_pressure_guard_spark_rat.collision_layer = (
				FACTORY_RAT_MINION_COLLISION_LAYER
			)
			_lower_deck_pressure_guard_spark_rat.collision_mask = (
				FACTORY_RAT_MINION_COLLISION_MASK
			)
			_set_lower_deck_pressure_guard_attack_target(_player)
	if _lower_deck_pressure_valve == null:
		return
	var valve_visible: bool = (
		_lower_deck_shortcut_pursuer_defeated
		or _lower_deck_pressure_guard_defeated
		or _lower_deck_pressure_valve_opened
	)
	_lower_deck_pressure_valve.visible = valve_visible
	if _lower_deck_pressure_valve.has_method("set_available"):
		_lower_deck_pressure_valve.call(
			"set_available",
			_is_lower_deck_pressure_valve_available()
		)
	if _lower_deck_pressure_valve.has_method("set_activated"):
		_lower_deck_pressure_valve.call("set_activated", _lower_deck_pressure_valve_opened)


func _sync_lower_deck_steam_sluice_state() -> void:
	if _lower_deck_steam_sluice_spark_rat != null:
		if not _is_lower_deck_steam_sluice_active():
			_lower_deck_steam_sluice_spark_rat.visible = false
			_lower_deck_steam_sluice_spark_rat.set_physics_process(false)
			_lower_deck_steam_sluice_spark_rat.set_process(false)
			_lower_deck_steam_sluice_spark_rat.collision_layer = 0
			_lower_deck_steam_sluice_spark_rat.collision_mask = 0
			_set_lower_deck_steam_sluice_attack_target(null)
		else:
			_lower_deck_steam_sluice_spark_rat.visible = true
			_lower_deck_steam_sluice_spark_rat.set_physics_process(true)
			_lower_deck_steam_sluice_spark_rat.set_process(true)
			_lower_deck_steam_sluice_spark_rat.collision_layer = (
				FACTORY_RAT_MINION_COLLISION_LAYER
			)
			_lower_deck_steam_sluice_spark_rat.collision_mask = (
				FACTORY_RAT_MINION_COLLISION_MASK
			)
			_set_lower_deck_steam_sluice_attack_target(_player)
	if _lower_deck_steam_sluice_hazard == null:
		return
	var hazard_active: bool = _is_lower_deck_steam_sluice_active()
	_lower_deck_steam_sluice_hazard.visible = hazard_active
	_lower_deck_steam_sluice_hazard.monitoring = hazard_active
	_lower_deck_steam_sluice_hazard.collision_layer = (
		CollisionComponent.COLLISION_LAYER_ENVIRONMENT if hazard_active else 0
	)
	_lower_deck_steam_sluice_hazard.collision_mask = (
		CollisionComponent.COLLISION_MASK_ENVIRONMENT if hazard_active else 0
	)
	var collision_shape := (
		_lower_deck_steam_sluice_hazard.get_node_or_null("CollisionShape2D")
		as CollisionShape2D
	)
	if collision_shape != null:
		collision_shape.disabled = not hazard_active


func _sync_lower_deck_deep_bulkhead_state() -> void:
	if _lower_deck_deep_bulkhead_spark_rat != null:
		if not _is_lower_deck_deep_bulkhead_guard_active():
			_lower_deck_deep_bulkhead_spark_rat.visible = false
			_lower_deck_deep_bulkhead_spark_rat.set_physics_process(false)
			_lower_deck_deep_bulkhead_spark_rat.set_process(false)
			_lower_deck_deep_bulkhead_spark_rat.collision_layer = 0
			_lower_deck_deep_bulkhead_spark_rat.collision_mask = 0
			_set_lower_deck_deep_bulkhead_guard_attack_target(null)
		else:
			_lower_deck_deep_bulkhead_spark_rat.visible = true
			_lower_deck_deep_bulkhead_spark_rat.set_physics_process(true)
			_lower_deck_deep_bulkhead_spark_rat.set_process(true)
			_lower_deck_deep_bulkhead_spark_rat.collision_layer = (
				FACTORY_RAT_MINION_COLLISION_LAYER
			)
			_lower_deck_deep_bulkhead_spark_rat.collision_mask = (
				FACTORY_RAT_MINION_COLLISION_MASK
			)
			_set_lower_deck_deep_bulkhead_guard_attack_target(_player)
	if _lower_deck_deep_bulkhead == null:
		return
	var bulkhead_visible: bool = (
		_lower_deck_steam_sluice_defeated
		or _lower_deck_deep_bulkhead_guard_defeated
		or _lower_deck_deep_bulkhead_opened
	)
	_lower_deck_deep_bulkhead.visible = bulkhead_visible
	if _lower_deck_deep_bulkhead.has_method("set_available"):
		_lower_deck_deep_bulkhead.call(
			"set_available",
			_is_lower_deck_deep_bulkhead_available()
		)
	if _lower_deck_deep_bulkhead.has_method("set_activated"):
		_lower_deck_deep_bulkhead.call("set_activated", _lower_deck_deep_bulkhead_opened)
	_set_lower_deck_deep_bulkhead_collision_blocking(
		bulkhead_visible and not _lower_deck_deep_bulkhead_opened
	)


func _sync_lower_deck_breach_corridor_state() -> void:
	var front_active: bool = _is_lower_deck_breach_front_active()
	if _lower_deck_breach_front_spark_rat != null:
		_lower_deck_breach_front_spark_rat.visible = front_active
		_lower_deck_breach_front_spark_rat.set_physics_process(front_active)
		_lower_deck_breach_front_spark_rat.set_process(front_active)
		_lower_deck_breach_front_spark_rat.collision_layer = (
			FACTORY_RAT_MINION_COLLISION_LAYER if front_active else 0
		)
		_lower_deck_breach_front_spark_rat.collision_mask = (
			FACTORY_RAT_MINION_COLLISION_MASK if front_active else 0
		)
		_set_lower_deck_breach_front_attack_target(_player if front_active else null)

	var rear_active: bool = _is_lower_deck_breach_rear_active()
	if _lower_deck_breach_rear_spark_rat != null:
		_lower_deck_breach_rear_spark_rat.visible = rear_active
		_lower_deck_breach_rear_spark_rat.set_physics_process(rear_active)
		_lower_deck_breach_rear_spark_rat.set_process(rear_active)
		_lower_deck_breach_rear_spark_rat.collision_layer = (
			FACTORY_RAT_MINION_COLLISION_LAYER if rear_active else 0
		)
		_lower_deck_breach_rear_spark_rat.collision_mask = (
			FACTORY_RAT_MINION_COLLISION_MASK if rear_active else 0
		)
		_set_lower_deck_breach_rear_attack_target(_player if rear_active else null)

	var hazard_active: bool = _is_lower_deck_breach_corridor_active()
	if _lower_deck_breach_steam_hazard != null:
		_lower_deck_breach_steam_hazard.visible = hazard_active
		_lower_deck_breach_steam_hazard.monitoring = hazard_active
		_lower_deck_breach_steam_hazard.monitorable = hazard_active
		_lower_deck_breach_steam_hazard.collision_layer = (
			CollisionComponent.COLLISION_LAYER_ENVIRONMENT if hazard_active else 0
		)
		_lower_deck_breach_steam_hazard.collision_mask = (
			CollisionComponent.COLLISION_MASK_ENVIRONMENT if hazard_active else 0
		)
		var collision_shape := (
			_lower_deck_breach_steam_hazard.get_node_or_null("CollisionShape2D")
			as CollisionShape2D
		)
		if collision_shape != null:
			collision_shape.disabled = not hazard_active

	if _post_bulkhead_background != null:
		_post_bulkhead_background.visible = (
			_lower_deck_deep_bulkhead_opened
			or _lower_deck_breach_corridor_activated
			or _lower_deck_breach_corridor_secured
		)


func _sync_lower_deck_post_relay_trial_state() -> void:
	var trial_active: bool = _is_lower_deck_post_relay_trial_active()
	if _lower_deck_post_relay_spark_rat != null:
		_lower_deck_post_relay_spark_rat.visible = trial_active
		_lower_deck_post_relay_spark_rat.set_physics_process(trial_active)
		_lower_deck_post_relay_spark_rat.set_process(trial_active)
		_lower_deck_post_relay_spark_rat.collision_layer = (
			FACTORY_RAT_MINION_COLLISION_LAYER if trial_active else 0
		)
		_lower_deck_post_relay_spark_rat.collision_mask = (
			FACTORY_RAT_MINION_COLLISION_MASK if trial_active else 0
		)
		_set_lower_deck_post_relay_trial_attack_target(_player if trial_active else null)
	if _lower_deck_post_relay_steam_hazard == null:
		return
	_lower_deck_post_relay_steam_hazard.visible = trial_active
	_lower_deck_post_relay_steam_hazard.monitoring = trial_active
	_lower_deck_post_relay_steam_hazard.monitorable = trial_active
	_lower_deck_post_relay_steam_hazard.collision_layer = (
		CollisionComponent.COLLISION_LAYER_ENVIRONMENT if trial_active else 0
	)
	_lower_deck_post_relay_steam_hazard.collision_mask = (
		CollisionComponent.COLLISION_MASK_ENVIRONMENT if trial_active else 0
	)
	var collision_shape := (
		_lower_deck_post_relay_steam_hazard.get_node_or_null("CollisionShape2D")
		as CollisionShape2D
	)
	if collision_shape != null:
		collision_shape.disabled = not trial_active


func _sync_lower_deck_forward_hatch_state() -> void:
	if _lower_deck_forward_hatch == null:
		return
	var hatch_visible: bool = (
		_lower_deck_post_relay_trial_defeated
		or _lower_deck_relay_forward_reward_cache_claimed
		or _lower_deck_forward_hatch_opened
	)
	_lower_deck_forward_hatch.visible = hatch_visible
	if _lower_deck_forward_hatch.has_method("set_available"):
		_lower_deck_forward_hatch.call(
			"set_available",
			_is_lower_deck_forward_hatch_available()
		)
	if _lower_deck_forward_hatch.has_method("set_activated"):
		_lower_deck_forward_hatch.call("set_activated", _lower_deck_forward_hatch_opened)
	_set_lower_deck_forward_hatch_collision_blocking(
		hatch_visible and not _lower_deck_forward_hatch_opened
	)


func _sync_lower_deck_forward_conduit_state() -> void:
	var conduit_active: bool = _is_lower_deck_forward_conduit_active()
	if _lower_deck_forward_conduit_spark_rat != null:
		_lower_deck_forward_conduit_spark_rat.visible = conduit_active
		_lower_deck_forward_conduit_spark_rat.set_physics_process(conduit_active)
		_lower_deck_forward_conduit_spark_rat.set_process(conduit_active)
		_lower_deck_forward_conduit_spark_rat.collision_layer = (
			FACTORY_RAT_MINION_COLLISION_LAYER if conduit_active else 0
		)
		_lower_deck_forward_conduit_spark_rat.collision_mask = (
			FACTORY_RAT_MINION_COLLISION_MASK if conduit_active else 0
		)
		_set_lower_deck_forward_conduit_attack_target(_player if conduit_active else null)

	if _lower_deck_forward_conduit_steam_hazard == null:
		return
	_lower_deck_forward_conduit_steam_hazard.visible = conduit_active
	_lower_deck_forward_conduit_steam_hazard.monitoring = conduit_active
	_lower_deck_forward_conduit_steam_hazard.monitorable = conduit_active
	_lower_deck_forward_conduit_steam_hazard.collision_layer = (
		CollisionComponent.COLLISION_LAYER_ENVIRONMENT if conduit_active else 0
	)
	_lower_deck_forward_conduit_steam_hazard.collision_mask = (
		CollisionComponent.COLLISION_MASK_ENVIRONMENT if conduit_active else 0
	)
	var collision_shape := (
		_lower_deck_forward_conduit_steam_hazard.get_node_or_null("CollisionShape2D")
		as CollisionShape2D
	)
	if collision_shape != null:
		collision_shape.disabled = not conduit_active


func _sync_lower_deck_forward_pressure_traverse_state() -> void:
	if _lower_deck_forward_pressure_vent == null:
		return
	var available: bool = _is_lower_deck_forward_pressure_traverse_available()
	var contact_active: bool = _is_lower_deck_forward_pressure_contact_active()
	_lower_deck_forward_pressure_vent.visible = available or _lower_deck_forward_pressure_traverse_active
	_lower_deck_forward_pressure_vent.monitoring = contact_active
	_lower_deck_forward_pressure_vent.monitorable = contact_active
	_lower_deck_forward_pressure_vent.collision_layer = (
		CollisionComponent.COLLISION_LAYER_ENVIRONMENT if contact_active else 0
	)
	_lower_deck_forward_pressure_vent.collision_mask = (
		CollisionComponent.COLLISION_MASK_ENVIRONMENT if contact_active else 0
	)
	var collision_shape := (
		_lower_deck_forward_pressure_vent.get_node_or_null("CollisionShape2D")
		as CollisionShape2D
	)
	if collision_shape != null:
		collision_shape.disabled = not contact_active


func _sync_lower_deck_forward_pressure_counter_ambush_state() -> void:
	var counter_active: bool = _is_lower_deck_forward_pressure_counter_ambush_active()
	if _lower_deck_forward_counter_spark_rat != null:
		_lower_deck_forward_counter_spark_rat.visible = counter_active
		_lower_deck_forward_counter_spark_rat.set_physics_process(counter_active)
		_lower_deck_forward_counter_spark_rat.set_process(counter_active)
		_lower_deck_forward_counter_spark_rat.collision_layer = (
			FACTORY_RAT_MINION_COLLISION_LAYER if counter_active else 0
		)
		_lower_deck_forward_counter_spark_rat.collision_mask = (
			FACTORY_RAT_MINION_COLLISION_MASK if counter_active else 0
		)
		_set_lower_deck_forward_counter_ambush_attack_target(
			_player if counter_active else null
		)

	if _lower_deck_forward_counter_pressure_vent == null:
		return
	_lower_deck_forward_counter_pressure_vent.visible = counter_active
	_lower_deck_forward_counter_pressure_vent.monitoring = counter_active
	_lower_deck_forward_counter_pressure_vent.monitorable = counter_active
	_lower_deck_forward_counter_pressure_vent.collision_layer = (
		CollisionComponent.COLLISION_LAYER_ENVIRONMENT if counter_active else 0
	)
	_lower_deck_forward_counter_pressure_vent.collision_mask = (
		CollisionComponent.COLLISION_MASK_ENVIRONMENT if counter_active else 0
	)
	var collision_shape := (
		_lower_deck_forward_counter_pressure_vent.get_node_or_null("CollisionShape2D")
		as CollisionShape2D
	)
	if collision_shape != null:
		collision_shape.disabled = not counter_active


func _sync_lower_deck_forward_pressure_exit_guard_state() -> void:
	var guard_active: bool = _is_lower_deck_forward_pressure_exit_guard_active()
	if _lower_deck_forward_exit_guard_spark_rat != null:
		_lower_deck_forward_exit_guard_spark_rat.visible = guard_active
		_lower_deck_forward_exit_guard_spark_rat.set_physics_process(guard_active)
		_lower_deck_forward_exit_guard_spark_rat.set_process(guard_active)
		_lower_deck_forward_exit_guard_spark_rat.collision_layer = (
			FACTORY_RAT_MINION_COLLISION_LAYER if guard_active else 0
		)
		_lower_deck_forward_exit_guard_spark_rat.collision_mask = (
			FACTORY_RAT_MINION_COLLISION_MASK if guard_active else 0
		)
		_set_lower_deck_forward_exit_guard_attack_target(_player if guard_active else null)

	if _lower_deck_forward_exit_guard_pressure_vent == null:
		return
	_lower_deck_forward_exit_guard_pressure_vent.visible = guard_active
	_lower_deck_forward_exit_guard_pressure_vent.monitoring = guard_active
	_lower_deck_forward_exit_guard_pressure_vent.monitorable = guard_active
	_lower_deck_forward_exit_guard_pressure_vent.collision_layer = (
		CollisionComponent.COLLISION_LAYER_ENVIRONMENT if guard_active else 0
	)
	_lower_deck_forward_exit_guard_pressure_vent.collision_mask = (
		CollisionComponent.COLLISION_MASK_ENVIRONMENT if guard_active else 0
	)
	var collision_shape := (
		_lower_deck_forward_exit_guard_pressure_vent.get_node_or_null("CollisionShape2D")
		as CollisionShape2D
	)
	if collision_shape != null:
		collision_shape.disabled = not guard_active


func _sync_lower_deck_forward_pressure_beacon_ambush_state() -> void:
	var ambush_active: bool = _is_lower_deck_forward_pressure_beacon_ambush_active()
	if _lower_deck_forward_beacon_ambush_spark_rat != null:
		_lower_deck_forward_beacon_ambush_spark_rat.visible = ambush_active
		_lower_deck_forward_beacon_ambush_spark_rat.set_physics_process(ambush_active)
		_lower_deck_forward_beacon_ambush_spark_rat.set_process(ambush_active)
		_lower_deck_forward_beacon_ambush_spark_rat.collision_layer = (
			FACTORY_RAT_MINION_COLLISION_LAYER if ambush_active else 0
		)
		_lower_deck_forward_beacon_ambush_spark_rat.collision_mask = (
			FACTORY_RAT_MINION_COLLISION_MASK if ambush_active else 0
		)
		_set_lower_deck_forward_beacon_ambush_attack_target(
			_player if ambush_active else null
		)

	if _lower_deck_forward_beacon_ambush_pressure_vent == null:
		return
	_lower_deck_forward_beacon_ambush_pressure_vent.visible = ambush_active
	_lower_deck_forward_beacon_ambush_pressure_vent.monitoring = ambush_active
	_lower_deck_forward_beacon_ambush_pressure_vent.monitorable = ambush_active
	_lower_deck_forward_beacon_ambush_pressure_vent.collision_layer = (
		CollisionComponent.COLLISION_LAYER_ENVIRONMENT if ambush_active else 0
	)
	_lower_deck_forward_beacon_ambush_pressure_vent.collision_mask = (
		CollisionComponent.COLLISION_MASK_ENVIRONMENT if ambush_active else 0
	)
	var collision_shape := (
		_lower_deck_forward_beacon_ambush_pressure_vent.get_node_or_null(
			"CollisionShape2D"
		) as CollisionShape2D
	)
	if collision_shape != null:
		collision_shape.disabled = not ambush_active


func _sync_lower_deck_forward_pressure_overrun_state() -> void:
	var overrun_active: bool = _is_lower_deck_forward_pressure_overrun_active()
	if _lower_deck_forward_overrun_spark_rat != null:
		_lower_deck_forward_overrun_spark_rat.visible = overrun_active
		_lower_deck_forward_overrun_spark_rat.set_physics_process(overrun_active)
		_lower_deck_forward_overrun_spark_rat.set_process(overrun_active)
		_lower_deck_forward_overrun_spark_rat.collision_layer = (
			FACTORY_RAT_MINION_COLLISION_LAYER if overrun_active else 0
		)
		_lower_deck_forward_overrun_spark_rat.collision_mask = (
			FACTORY_RAT_MINION_COLLISION_MASK if overrun_active else 0
		)
		_set_lower_deck_forward_overrun_attack_target(_player if overrun_active else null)

	if _lower_deck_forward_overrun_pressure_vent == null:
		return
	_lower_deck_forward_overrun_pressure_vent.visible = overrun_active
	_lower_deck_forward_overrun_pressure_vent.monitoring = overrun_active
	_lower_deck_forward_overrun_pressure_vent.monitorable = overrun_active
	_lower_deck_forward_overrun_pressure_vent.collision_layer = (
		CollisionComponent.COLLISION_LAYER_ENVIRONMENT if overrun_active else 0
	)
	_lower_deck_forward_overrun_pressure_vent.collision_mask = (
		CollisionComponent.COLLISION_MASK_ENVIRONMENT if overrun_active else 0
	)
	var collision_shape := (
		_lower_deck_forward_overrun_pressure_vent.get_node_or_null("CollisionShape2D")
		as CollisionShape2D
	)
	if collision_shape != null:
		collision_shape.disabled = not overrun_active


func _sync_lower_deck_forward_pressure_breaker_state() -> void:
	var breaker_active: bool = _is_lower_deck_forward_pressure_breaker_stand_active()
	if _lower_deck_forward_breaker_spark_rat != null:
		_lower_deck_forward_breaker_spark_rat.visible = breaker_active
		_lower_deck_forward_breaker_spark_rat.set_physics_process(breaker_active)
		_lower_deck_forward_breaker_spark_rat.set_process(breaker_active)
		_lower_deck_forward_breaker_spark_rat.collision_layer = (
			FACTORY_RAT_MINION_COLLISION_LAYER if breaker_active else 0
		)
		_lower_deck_forward_breaker_spark_rat.collision_mask = (
			FACTORY_RAT_MINION_COLLISION_MASK if breaker_active else 0
		)
		_set_lower_deck_forward_breaker_attack_target(
			_player if breaker_active else null
		)

	if _lower_deck_forward_breaker_pressure_vent != null:
		_lower_deck_forward_breaker_pressure_vent.visible = breaker_active
		_lower_deck_forward_breaker_pressure_vent.monitoring = breaker_active
		_lower_deck_forward_breaker_pressure_vent.monitorable = breaker_active
		_lower_deck_forward_breaker_pressure_vent.collision_layer = (
			CollisionComponent.COLLISION_LAYER_ENVIRONMENT if breaker_active else 0
		)
		_lower_deck_forward_breaker_pressure_vent.collision_mask = (
			CollisionComponent.COLLISION_MASK_ENVIRONMENT if breaker_active else 0
		)
		var collision_shape := (
			_lower_deck_forward_breaker_pressure_vent.get_node_or_null(
				"CollisionShape2D"
			) as CollisionShape2D
		)
		if collision_shape != null:
			collision_shape.disabled = not breaker_active


func _sync_lower_deck_forward_pressure_breaker_endpoint_state() -> void:
	if _lower_deck_forward_pressure_breaker == null:
		return
	_lower_deck_forward_pressure_breaker.visible = (
		_lower_deck_forward_pressure_breaker_secured
		or _lower_deck_forward_pressure_breaker_cut
	)
	if _lower_deck_forward_pressure_breaker.has_method("set_available"):
		_lower_deck_forward_pressure_breaker.call(
			"set_available",
			_is_lower_deck_forward_pressure_breaker_available()
		)
	if _lower_deck_forward_pressure_breaker.has_method("set_activated"):
		_lower_deck_forward_pressure_breaker.call(
			"set_activated",
			_lower_deck_forward_pressure_breaker_cut
		)


func _sync_lower_deck_forward_pressure_relief_ambush_state() -> void:
	var relief_active: bool = _is_lower_deck_forward_pressure_relief_ambush_active()
	if _lower_deck_forward_relief_ambush_spark_rat != null:
		_lower_deck_forward_relief_ambush_spark_rat.visible = relief_active
		_lower_deck_forward_relief_ambush_spark_rat.set_physics_process(relief_active)
		_lower_deck_forward_relief_ambush_spark_rat.set_process(relief_active)
		_lower_deck_forward_relief_ambush_spark_rat.collision_layer = (
			FACTORY_RAT_MINION_COLLISION_LAYER if relief_active else 0
		)
		_lower_deck_forward_relief_ambush_spark_rat.collision_mask = (
			FACTORY_RAT_MINION_COLLISION_MASK if relief_active else 0
		)
		_set_lower_deck_forward_relief_ambush_attack_target(
			_player if relief_active else null
		)

	if _lower_deck_forward_relief_ambush_pressure_vent == null:
		return
	_lower_deck_forward_relief_ambush_pressure_vent.visible = relief_active
	_lower_deck_forward_relief_ambush_pressure_vent.monitoring = relief_active
	_lower_deck_forward_relief_ambush_pressure_vent.monitorable = relief_active
	_lower_deck_forward_relief_ambush_pressure_vent.collision_layer = (
		CollisionComponent.COLLISION_LAYER_ENVIRONMENT if relief_active else 0
	)
	_lower_deck_forward_relief_ambush_pressure_vent.collision_mask = (
		CollisionComponent.COLLISION_MASK_ENVIRONMENT if relief_active else 0
	)
	var collision_shape := (
		_lower_deck_forward_relief_ambush_pressure_vent.get_node_or_null(
			"CollisionShape2D"
		) as CollisionShape2D
	)
	if collision_shape != null:
		collision_shape.disabled = not relief_active


func _sync_lower_deck_forward_pressure_coil_rat_state() -> void:
	var coil_active: bool = _is_lower_deck_forward_pressure_coil_rat_active()
	if _lower_deck_forward_pressure_coil_rat == null:
		return
	_lower_deck_forward_pressure_coil_rat.visible = coil_active
	_lower_deck_forward_pressure_coil_rat.set_physics_process(coil_active)
	_lower_deck_forward_pressure_coil_rat.set_process(coil_active)
	_lower_deck_forward_pressure_coil_rat.collision_layer = (
		FACTORY_RAT_MINION_COLLISION_LAYER if coil_active else 0
	)
	_lower_deck_forward_pressure_coil_rat.collision_mask = (
		FACTORY_RAT_MINION_COLLISION_MASK if coil_active else 0
	)
	_set_lower_deck_forward_pressure_coil_rat_attack_target(
		_player if coil_active else null
	)


func _sync_lower_deck_forward_pressure_coil_pincer_state() -> void:
	var pincer_active: bool = _is_lower_deck_forward_pressure_coil_pincer_active()
	_sync_lower_deck_forward_pressure_coil_pincer_enemy_state(
		_lower_deck_forward_pressure_coil_pincer_spark_rat,
		pincer_active and not _lower_deck_forward_pressure_coil_pincer_spark_rat_defeated
	)
	_sync_lower_deck_forward_pressure_coil_pincer_enemy_state(
		_lower_deck_forward_pressure_coil_pincer_coil_rat,
		pincer_active and not _lower_deck_forward_pressure_coil_pincer_coil_rat_defeated
	)


func _sync_lower_deck_forward_pressure_coil_pincer_enemy_state(
		enemy: Node2D,
		enemy_active: bool
) -> void:
	if enemy == null:
		return
	enemy.visible = enemy_active
	enemy.set_physics_process(enemy_active)
	enemy.set_process(enemy_active)
	enemy.collision_layer = FACTORY_RAT_MINION_COLLISION_LAYER if enemy_active else 0
	enemy.collision_mask = FACTORY_RAT_MINION_COLLISION_MASK if enemy_active else 0
	if enemy.has_method("set_attack_target"):
		enemy.call("set_attack_target", _player if enemy_active else null)


func _sync_lower_deck_forward_pressure_coil_aftershock_state() -> void:
	var aftershock_active: bool = _is_lower_deck_forward_pressure_coil_aftershock_active()
	if _lower_deck_forward_pressure_coil_aftershock_coil_rat == null:
		return
	_lower_deck_forward_pressure_coil_aftershock_coil_rat.visible = aftershock_active
	_lower_deck_forward_pressure_coil_aftershock_coil_rat.set_physics_process(
		aftershock_active
	)
	_lower_deck_forward_pressure_coil_aftershock_coil_rat.set_process(aftershock_active)
	_lower_deck_forward_pressure_coil_aftershock_coil_rat.collision_layer = (
		FACTORY_RAT_MINION_COLLISION_LAYER if aftershock_active else 0
	)
	_lower_deck_forward_pressure_coil_aftershock_coil_rat.collision_mask = (
		FACTORY_RAT_MINION_COLLISION_MASK if aftershock_active else 0
	)
	_set_lower_deck_forward_pressure_coil_aftershock_attack_target(
		_player if aftershock_active else null
	)


func _sync_lower_deck_forward_pressure_aftershock_exit_skirmish_state() -> void:
	var skirmish_active: bool = (
		_is_lower_deck_forward_pressure_aftershock_exit_skirmish_active()
	)
	_sync_lower_deck_forward_pressure_aftershock_exit_enemy_state(
		_lower_deck_forward_pressure_aftershock_exit_spark_rat,
		skirmish_active
			and not _lower_deck_forward_pressure_aftershock_exit_spark_rat_defeated
	)
	_sync_lower_deck_forward_pressure_aftershock_exit_enemy_state(
		_lower_deck_forward_pressure_aftershock_exit_coil_rat,
		skirmish_active
			and not _lower_deck_forward_pressure_aftershock_exit_coil_rat_defeated
	)
	_sync_lower_deck_forward_pressure_aftershock_exhaust_state()


func _sync_lower_deck_forward_pressure_aftershock_exhaust_state() -> void:
	if _lower_deck_forward_pressure_aftershock_exhaust_vent == null:
		return
	var should_show_exhaust: bool = (
		_is_lower_deck_forward_pressure_aftershock_exhaust_available()
		or _is_lower_deck_forward_pressure_aftershock_exhaust_active()
	)
	var contact_active: bool = (
		_is_lower_deck_forward_pressure_aftershock_exhaust_contact_active()
	)
	_lower_deck_forward_pressure_aftershock_exhaust_vent.visible = should_show_exhaust
	_lower_deck_forward_pressure_aftershock_exhaust_vent.monitoring = contact_active
	_lower_deck_forward_pressure_aftershock_exhaust_vent.monitorable = contact_active
	_lower_deck_forward_pressure_aftershock_exhaust_vent.collision_layer = (
		CollisionComponent.COLLISION_LAYER_ENVIRONMENT if contact_active else 0
	)
	_lower_deck_forward_pressure_aftershock_exhaust_vent.collision_mask = (
		CollisionComponent.COLLISION_MASK_ENVIRONMENT if contact_active else 0
	)
	var collision_shape := (
		_lower_deck_forward_pressure_aftershock_exhaust_vent.get_node_or_null(
			"CollisionShape2D"
		) as CollisionShape2D
	)
	if collision_shape != null:
		collision_shape.disabled = not contact_active


func _sync_lower_deck_forward_pressure_aftershock_exhaust_pursuer_state() -> void:
	var pursuer_active: bool = (
		_is_lower_deck_forward_pressure_aftershock_exhaust_pursuer_active()
	)
	if _lower_deck_forward_pressure_aftershock_exhaust_pursuer_coil_rat == null:
		return
	_lower_deck_forward_pressure_aftershock_exhaust_pursuer_coil_rat.visible = (
		pursuer_active
	)
	_lower_deck_forward_pressure_aftershock_exhaust_pursuer_coil_rat.set_physics_process(
		pursuer_active
	)
	_lower_deck_forward_pressure_aftershock_exhaust_pursuer_coil_rat.set_process(
		pursuer_active
	)
	_lower_deck_forward_pressure_aftershock_exhaust_pursuer_coil_rat.collision_layer = (
		FACTORY_RAT_MINION_COLLISION_LAYER if pursuer_active else 0
	)
	_lower_deck_forward_pressure_aftershock_exhaust_pursuer_coil_rat.collision_mask = (
		FACTORY_RAT_MINION_COLLISION_MASK if pursuer_active else 0
	)
	_set_lower_deck_forward_pressure_aftershock_exhaust_pursuer_attack_target(
		_player if pursuer_active else null
	)


func _sync_lower_deck_forward_pressure_aftershock_exhaust_flank_state() -> void:
	var flank_active: bool = (
		_is_lower_deck_forward_pressure_aftershock_exhaust_flank_active()
	)
	if not is_instance_valid(
		_lower_deck_forward_pressure_aftershock_exhaust_flank_spark_rat
	):
		_lower_deck_forward_pressure_aftershock_exhaust_flank_spark_rat = null
	if _lower_deck_forward_pressure_aftershock_exhaust_flank_spark_rat != null:
		_lower_deck_forward_pressure_aftershock_exhaust_flank_spark_rat.visible = (
			flank_active
		)
		_lower_deck_forward_pressure_aftershock_exhaust_flank_spark_rat.set_physics_process(
			flank_active
		)
		_lower_deck_forward_pressure_aftershock_exhaust_flank_spark_rat.set_process(
			flank_active
		)
		_lower_deck_forward_pressure_aftershock_exhaust_flank_spark_rat.collision_layer = (
			FACTORY_RAT_MINION_COLLISION_LAYER if flank_active else 0
		)
		_lower_deck_forward_pressure_aftershock_exhaust_flank_spark_rat.collision_mask = (
			FACTORY_RAT_MINION_COLLISION_MASK if flank_active else 0
		)
		_set_lower_deck_forward_pressure_aftershock_exhaust_flank_attack_target(
			_player if flank_active else null
		)
	if _lower_deck_forward_pressure_aftershock_exhaust_flank_vent == null:
		return
	_lower_deck_forward_pressure_aftershock_exhaust_flank_vent.visible = flank_active
	_lower_deck_forward_pressure_aftershock_exhaust_flank_vent.monitoring = flank_active
	_lower_deck_forward_pressure_aftershock_exhaust_flank_vent.monitorable = flank_active
	_lower_deck_forward_pressure_aftershock_exhaust_flank_vent.collision_layer = (
		CollisionComponent.COLLISION_LAYER_ENVIRONMENT if flank_active else 0
	)
	_lower_deck_forward_pressure_aftershock_exhaust_flank_vent.collision_mask = (
		CollisionComponent.COLLISION_MASK_ENVIRONMENT if flank_active else 0
	)
	var collision_shape := (
		_lower_deck_forward_pressure_aftershock_exhaust_flank_vent.get_node_or_null(
			"CollisionShape2D"
		) as CollisionShape2D
	)
	if collision_shape != null:
		collision_shape.disabled = not flank_active


func _sync_lower_deck_forward_pressure_aftershock_exhaust_breaker_state() -> void:
	var breaker_active: bool = (
		_is_lower_deck_forward_pressure_aftershock_exhaust_breaker_stand_active()
	)
	if _lower_deck_forward_pressure_aftershock_exhaust_breaker_coil_rat != null:
		_lower_deck_forward_pressure_aftershock_exhaust_breaker_coil_rat.visible = (
			breaker_active
		)
		_lower_deck_forward_pressure_aftershock_exhaust_breaker_coil_rat.set_physics_process(
			breaker_active
		)
		_lower_deck_forward_pressure_aftershock_exhaust_breaker_coil_rat.set_process(
			breaker_active
		)
		_lower_deck_forward_pressure_aftershock_exhaust_breaker_coil_rat.collision_layer = (
			FACTORY_RAT_MINION_COLLISION_LAYER if breaker_active else 0
		)
		_lower_deck_forward_pressure_aftershock_exhaust_breaker_coil_rat.collision_mask = (
			FACTORY_RAT_MINION_COLLISION_MASK if breaker_active else 0
		)
		_set_lower_deck_forward_pressure_aftershock_exhaust_breaker_attack_target(
			_player if breaker_active else null
		)
	if _lower_deck_forward_pressure_aftershock_exhaust_breaker_vent == null:
		return
	_lower_deck_forward_pressure_aftershock_exhaust_breaker_vent.visible = breaker_active
	_lower_deck_forward_pressure_aftershock_exhaust_breaker_vent.monitoring = (
		breaker_active
	)
	_lower_deck_forward_pressure_aftershock_exhaust_breaker_vent.monitorable = (
		breaker_active
	)
	_lower_deck_forward_pressure_aftershock_exhaust_breaker_vent.collision_layer = (
		CollisionComponent.COLLISION_LAYER_ENVIRONMENT if breaker_active else 0
	)
	_lower_deck_forward_pressure_aftershock_exhaust_breaker_vent.collision_mask = (
		CollisionComponent.COLLISION_MASK_ENVIRONMENT if breaker_active else 0
	)
	var collision_shape := (
		_lower_deck_forward_pressure_aftershock_exhaust_breaker_vent.get_node_or_null(
			"CollisionShape2D"
		) as CollisionShape2D
	)
	if collision_shape != null:
		collision_shape.disabled = not breaker_active


func _sync_lower_deck_forward_pressure_aftershock_exhaust_breaker_endpoint_state(
) -> void:
	if _lower_deck_forward_pressure_aftershock_exhaust_breaker == null:
		return
	_lower_deck_forward_pressure_aftershock_exhaust_breaker.visible = (
		_lower_deck_forward_pressure_aftershock_exhaust_breaker_secured
		or _lower_deck_forward_pressure_aftershock_exhaust_breaker_cut
	)
	if _lower_deck_forward_pressure_aftershock_exhaust_breaker.has_method(
		"set_available"
	):
		_lower_deck_forward_pressure_aftershock_exhaust_breaker.call(
			"set_available",
			_is_lower_deck_forward_pressure_aftershock_exhaust_breaker_available()
		)
	if _lower_deck_forward_pressure_aftershock_exhaust_breaker.has_method(
		"set_activated"
	):
		_lower_deck_forward_pressure_aftershock_exhaust_breaker.call(
			"set_activated",
			_lower_deck_forward_pressure_aftershock_exhaust_breaker_cut
		)


func _sync_lower_deck_forward_pressure_aftershock_exhaust_escape_skirmish_state(
) -> void:
	var skirmish_active: bool = (
		_is_lower_deck_forward_pressure_aftershock_exhaust_escape_skirmish_active()
	)
	_sync_lower_deck_forward_pressure_aftershock_exit_enemy_state(
		_lower_deck_forward_pressure_aftershock_exhaust_escape_spark_rat,
		skirmish_active
			and not _lower_deck_forward_pressure_aftershock_exhaust_escape_spark_rat_defeated
	)
	_sync_lower_deck_forward_pressure_aftershock_exit_enemy_state(
		_lower_deck_forward_pressure_aftershock_exhaust_escape_coil_rat,
		skirmish_active
			and not _lower_deck_forward_pressure_aftershock_exhaust_escape_coil_rat_defeated
	)


func _sync_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch_state() -> void:
	if _lower_deck_forward_pressure_aftershock_exhaust_exit_hatch == null:
		return
	var hatch_visible: bool = (
		_is_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch_available()
		or _lower_deck_forward_pressure_aftershock_exhaust_exit_hatch_opened
	)
	_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch.visible = hatch_visible
	if _lower_deck_forward_pressure_aftershock_exhaust_exit_hatch.has_method(
		"set_available"
	):
		_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch.call(
			"set_available",
			_is_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch_available()
		)
	if _lower_deck_forward_pressure_aftershock_exhaust_exit_hatch.has_method(
		"set_activated"
	):
		_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch.call(
			"set_activated",
			_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch_opened
		)
	_set_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch_collision_blocking(
		hatch_visible
			and not _lower_deck_forward_pressure_aftershock_exhaust_exit_hatch_opened
	)
	_sync_lower_deck_forward_pressure_aftershock_cooling_duct_state()


func _sync_lower_deck_forward_pressure_aftershock_cooling_duct_state() -> void:
	var should_show_duct: bool = (
		_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch_opened
	)
	if _lower_deck_forward_pressure_aftershock_cooling_duct != null:
		_lower_deck_forward_pressure_aftershock_cooling_duct.visible = should_show_duct
	if _lower_deck_forward_pressure_aftershock_cooling_duct_vent == null:
		_sync_lower_deck_forward_pressure_aftershock_condenser_valve_state()
		return
	var contact_active: bool = (
		_is_lower_deck_forward_pressure_aftershock_cooling_duct_contact_active()
	)
	_lower_deck_forward_pressure_aftershock_cooling_duct_vent.visible = should_show_duct
	_lower_deck_forward_pressure_aftershock_cooling_duct_vent.monitoring = contact_active
	_lower_deck_forward_pressure_aftershock_cooling_duct_vent.monitorable = contact_active
	_lower_deck_forward_pressure_aftershock_cooling_duct_vent.collision_layer = (
		CollisionComponent.COLLISION_LAYER_ENVIRONMENT if contact_active else 0
	)
	_lower_deck_forward_pressure_aftershock_cooling_duct_vent.collision_mask = (
		CollisionComponent.COLLISION_MASK_ENVIRONMENT if contact_active else 0
	)
	var collision_shape := (
		_lower_deck_forward_pressure_aftershock_cooling_duct_vent.get_node_or_null(
			"CollisionShape2D"
		) as CollisionShape2D
	)
	if collision_shape != null:
		collision_shape.disabled = not contact_active
	_sync_lower_deck_forward_pressure_aftershock_condenser_valve_state()


func _sync_lower_deck_forward_pressure_aftershock_condenser_valve_state() -> void:
	var should_show_valve: bool = _lower_deck_forward_pressure_aftershock_cooling_duct_crossed
	if _lower_deck_forward_pressure_aftershock_condenser_valve != null:
		_lower_deck_forward_pressure_aftershock_condenser_valve.visible = should_show_valve
	var ambush_active: bool = _is_lower_deck_forward_pressure_aftershock_condenser_valve_active()
	_sync_lower_deck_forward_pressure_aftershock_exit_enemy_state(
		_lower_deck_forward_pressure_aftershock_condenser_spark_rat,
		ambush_active
			and not _lower_deck_forward_pressure_aftershock_condenser_valve_spark_rat_defeated
	)
	_sync_lower_deck_forward_pressure_aftershock_exit_enemy_state(
		_lower_deck_forward_pressure_aftershock_condenser_coil_rat,
		ambush_active
			and not _lower_deck_forward_pressure_aftershock_condenser_valve_coil_rat_defeated
	)
	_sync_lower_deck_forward_pressure_aftershock_condenser_savepoint_state()


func _sync_lower_deck_forward_pressure_aftershock_exit_enemy_state(
		enemy: Variant,
		enemy_active: bool
) -> void:
	var enemy_node: Node2D = _get_valid_node2d(enemy)
	if enemy_node == null:
		return
	enemy_node.visible = enemy_active
	enemy_node.set_physics_process(enemy_active)
	enemy_node.set_process(enemy_active)
	enemy_node.collision_layer = FACTORY_RAT_MINION_COLLISION_LAYER if enemy_active else 0
	enemy_node.collision_mask = FACTORY_RAT_MINION_COLLISION_MASK if enemy_active else 0
	if enemy_node.has_method("set_attack_target"):
		enemy_node.call("set_attack_target", _player if enemy_active else null)


func _sync_lower_deck_parry_gate_state() -> void:
	if _lower_deck_parry_gate == null:
		return
	var available: bool = _is_lower_deck_parry_gate_available()
	_lower_deck_parry_gate.visible = available or _lower_deck_parry_gate_unlocked
	if _lower_deck_parry_gate.has_method("set_gate_unlocked"):
		_lower_deck_parry_gate.call("set_gate_unlocked", _lower_deck_parry_gate_unlocked)
	if not available and not _lower_deck_parry_gate_unlocked:
		_set_lower_deck_parry_gate_collision_enabled(false)
	elif _lower_deck_parry_gate_unlocked:
		_set_lower_deck_parry_gate_collision_enabled(false)


func _sync_lower_deck_exit_ambush_state() -> void:
	if _lower_deck_exit_spark_rat == null:
		return
	if not _is_lower_deck_exit_ambush_active():
		_lower_deck_exit_spark_rat.visible = false
		_lower_deck_exit_spark_rat.set_physics_process(false)
		_lower_deck_exit_spark_rat.set_process(false)
		_lower_deck_exit_spark_rat.collision_layer = 0
		_lower_deck_exit_spark_rat.collision_mask = 0
		_set_lower_deck_exit_spark_rat_attack_target(null)
		return
	_lower_deck_exit_spark_rat.visible = true
	_lower_deck_exit_spark_rat.set_physics_process(true)
	_lower_deck_exit_spark_rat.set_process(true)
	_lower_deck_exit_spark_rat.collision_layer = FACTORY_RAT_MINION_COLLISION_LAYER
	_lower_deck_exit_spark_rat.collision_mask = FACTORY_RAT_MINION_COLLISION_MASK
	_set_lower_deck_exit_spark_rat_attack_target(_player)


func _sync_lower_deck_shortcut_state() -> void:
	if _lower_deck_shortcut_spark_rat != null:
		if not _is_lower_deck_shortcut_active():
			_lower_deck_shortcut_spark_rat.visible = false
			_lower_deck_shortcut_spark_rat.set_physics_process(false)
			_lower_deck_shortcut_spark_rat.set_process(false)
			_lower_deck_shortcut_spark_rat.collision_layer = 0
			_lower_deck_shortcut_spark_rat.collision_mask = 0
			_set_lower_deck_shortcut_spark_rat_attack_target(null)
		else:
			_lower_deck_shortcut_spark_rat.visible = true
			_lower_deck_shortcut_spark_rat.set_physics_process(true)
			_lower_deck_shortcut_spark_rat.set_process(true)
			_lower_deck_shortcut_spark_rat.collision_layer = FACTORY_RAT_MINION_COLLISION_LAYER
			_lower_deck_shortcut_spark_rat.collision_mask = FACTORY_RAT_MINION_COLLISION_MASK
			_set_lower_deck_shortcut_spark_rat_attack_target(_player)
	if _lower_deck_shortcut_seal == null:
		return
	var seal_visible: bool = _lower_deck_exit_ambush_defeated or _lower_deck_shortcut_unlocked
	_lower_deck_shortcut_seal.visible = seal_visible
	if _lower_deck_shortcut_seal.has_method("set_available"):
		_lower_deck_shortcut_seal.call(
			"set_available",
			_is_lower_deck_shortcut_seal_unlockable()
		)
	if _lower_deck_shortcut_seal.has_method("set_activated"):
		_lower_deck_shortcut_seal.call("set_activated", _lower_deck_shortcut_unlocked)
	_set_lower_deck_shortcut_collision_enabled(not _lower_deck_shortcut_unlocked and seal_visible)


func _sync_return_checkpoint_state() -> void:
	if _return_checkpoint == null:
		return
	var available: bool = _return_patrol_defeated
	_return_checkpoint.visible = available or _return_checkpoint_activated
	var interaction_area := _return_checkpoint.get_node_or_null("InteractionArea") as Area2D
	if interaction_area != null:
		if interaction_area.monitoring != available:
			interaction_area.monitoring = available
		if interaction_area.monitorable != available:
			interaction_area.monitorable = available
	var collision_shape := (
		_return_checkpoint.get_node_or_null("InteractionArea/CollisionShape2D")
		as CollisionShape2D
	)
	if collision_shape != null:
		var should_disable: bool = not available
		if collision_shape.disabled != should_disable:
			collision_shape.disabled = should_disable


func _sync_lower_deck_forward_pressure_exit_relay_state(
	defer_interaction_changes: bool = false
) -> void:
	if _lower_deck_forward_pressure_exit_relay == null:
		return
	var available: bool = _is_lower_deck_forward_pressure_exit_relay_available()
	_lower_deck_forward_pressure_exit_relay.visible = (
		available or _lower_deck_forward_pressure_exit_relay_activated
	)
	var interaction_area := (
		_lower_deck_forward_pressure_exit_relay.get_node_or_null("InteractionArea")
		as Area2D
	)
	if interaction_area != null:
		if interaction_area.monitoring != available:
			if defer_interaction_changes:
				interaction_area.set_deferred("monitoring", available)
			else:
				interaction_area.monitoring = available
		if interaction_area.monitorable != available:
			if defer_interaction_changes:
				interaction_area.set_deferred("monitorable", available)
			else:
				interaction_area.monitorable = available
	var collision_shape := (
		_lower_deck_forward_pressure_exit_relay.get_node_or_null(
			"InteractionArea/CollisionShape2D"
		) as CollisionShape2D
	)
	if collision_shape != null:
		var should_disable: bool = not available
		if collision_shape.disabled != should_disable:
			if defer_interaction_changes:
				collision_shape.set_deferred("disabled", should_disable)
			else:
				collision_shape.disabled = should_disable


func _sync_lower_deck_forward_pressure_aftershock_condenser_savepoint_state(
	defer_interaction_changes: bool = false
) -> void:
	if _lower_deck_forward_pressure_aftershock_condenser_savepoint == null:
		return
	var available: bool = (
		_is_lower_deck_forward_pressure_aftershock_condenser_savepoint_available()
	)
	_lower_deck_forward_pressure_aftershock_condenser_savepoint.visible = (
		available or _lower_deck_forward_pressure_aftershock_condenser_savepoint_activated
	)
	var interaction_area := (
		_lower_deck_forward_pressure_aftershock_condenser_savepoint.get_node_or_null(
			"InteractionArea"
		) as Area2D
	)
	if interaction_area != null:
		if interaction_area.monitoring != available:
			if defer_interaction_changes:
				interaction_area.set_deferred("monitoring", available)
			else:
				interaction_area.monitoring = available
		if interaction_area.monitorable != available:
			if defer_interaction_changes:
				interaction_area.set_deferred("monitorable", available)
			else:
				interaction_area.monitorable = available
	var collision_shape := (
		_lower_deck_forward_pressure_aftershock_condenser_savepoint.get_node_or_null(
			"InteractionArea/CollisionShape2D"
		) as CollisionShape2D
	)
	if collision_shape != null:
		var should_disable: bool = not available
		if collision_shape.disabled != should_disable:
			if defer_interaction_changes:
				collision_shape.set_deferred("disabled", should_disable)
			else:
				collision_shape.disabled = should_disable
	_sync_lower_deck_forward_pressure_aftershock_condenser_outlet_state()


func _sync_lower_deck_forward_pressure_aftershock_condenser_outlet_state() -> void:
	var should_show_outlet: bool = (
		_lower_deck_forward_pressure_aftershock_condenser_savepoint_activated
	)
	if _lower_deck_forward_pressure_aftershock_condenser_outlet != null:
		_lower_deck_forward_pressure_aftershock_condenser_outlet.visible = should_show_outlet
	if _lower_deck_forward_pressure_aftershock_condenser_outlet_vent == null:
		_sync_outlet_clamp_ambush_state()
		return
	var contact_active: bool = (
		_is_lower_deck_forward_pressure_aftershock_condenser_outlet_contact_active()
	)
	_lower_deck_forward_pressure_aftershock_condenser_outlet_vent.visible = should_show_outlet
	_lower_deck_forward_pressure_aftershock_condenser_outlet_vent.monitoring = contact_active
	_lower_deck_forward_pressure_aftershock_condenser_outlet_vent.monitorable = contact_active
	_lower_deck_forward_pressure_aftershock_condenser_outlet_vent.collision_layer = (
		CollisionComponent.COLLISION_LAYER_ENVIRONMENT if contact_active else 0
	)
	_lower_deck_forward_pressure_aftershock_condenser_outlet_vent.collision_mask = (
		CollisionComponent.COLLISION_MASK_ENVIRONMENT if contact_active else 0
	)
	var collision_shape := (
		_lower_deck_forward_pressure_aftershock_condenser_outlet_vent.get_node_or_null(
			"CollisionShape2D"
		) as CollisionShape2D
	)
	if collision_shape != null:
		collision_shape.disabled = not contact_active
	_sync_outlet_clamp_ambush_state()


func _sync_outlet_clamp_ambush_state() -> void:
	var should_show_clamp: bool = (
		_lower_deck_forward_pressure_aftershock_condenser_outlet_crossed
		or _is_outlet_clamp_ambush_cleared()
	)
	if _lower_deck_forward_pressure_aftershock_condenser_outlet_clamp != null:
		_lower_deck_forward_pressure_aftershock_condenser_outlet_clamp.visible = (
			should_show_clamp
		)
	var ambush_active: bool = _is_outlet_clamp_ambush_active()
	_sync_lower_deck_forward_pressure_aftershock_exit_enemy_state(
		_lower_deck_forward_pressure_aftershock_condenser_outlet_clamp_spark_rat,
		ambush_active
			and not _lower_deck_forward_pressure_aftershock_condenser_outlet_clamp_spark_rat_defeated
	)
	_sync_outlet_drip_vent_state()


func _sync_outlet_drip_vent_state() -> void:
	var should_show_drip_vent: bool = (
		_is_outlet_clamp_ambush_cleared()
		or _lower_deck_forward_pressure_aftershock_condenser_drip_vent_crossed
	)
	if _lower_deck_forward_pressure_aftershock_condenser_drain_gantry != null:
		_lower_deck_forward_pressure_aftershock_condenser_drain_gantry.visible = (
			should_show_drip_vent
		)
	if _lower_deck_forward_pressure_aftershock_condenser_drip_vent == null:
		return
	var contact_active: bool = _is_outlet_drip_vent_contact_active()
	_lower_deck_forward_pressure_aftershock_condenser_drip_vent.visible = (
		should_show_drip_vent
	)
	_lower_deck_forward_pressure_aftershock_condenser_drip_vent.monitoring = (
		contact_active
	)
	_lower_deck_forward_pressure_aftershock_condenser_drip_vent.monitorable = (
		contact_active
	)
	_lower_deck_forward_pressure_aftershock_condenser_drip_vent.collision_layer = (
		CollisionComponent.COLLISION_LAYER_ENVIRONMENT if contact_active else 0
	)
	_lower_deck_forward_pressure_aftershock_condenser_drip_vent.collision_mask = (
		CollisionComponent.COLLISION_MASK_ENVIRONMENT if contact_active else 0
	)
	var collision_shape := (
		_lower_deck_forward_pressure_aftershock_condenser_drip_vent.get_node_or_null(
			"CollisionShape2D"
		) as CollisionShape2D
	)
	if collision_shape != null:
		collision_shape.disabled = not contact_active
	_sync_overflow_pump_state()


func _sync_overflow_pump_state() -> void:
	var should_show_pump: bool = (
		_lower_deck_forward_pressure_aftershock_condenser_drip_vent_crossed
		or _is_overflow_pump_cleared()
	)
	if _lower_deck_forward_pressure_aftershock_condenser_overflow_pump != null:
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump.visible = (
			should_show_pump
		)
	var skirmish_active: bool = _is_overflow_pump_active()
	_sync_lower_deck_forward_pressure_aftershock_exit_enemy_state(
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_coil_rat,
		skirmish_active
			and not _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_coil_rat_defeated
	)
	_sync_overflow_pump_reward_cache_state()
	_sync_overflow_pump_exit_hatch_state()


func _sync_overflow_pump_reward_cache_state() -> void:
	var cache: Node = (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_reward_cache
	)
	if cache == null:
		return
	cache.visible = (
		_is_overflow_pump_cleared()
		or _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_reward_cache_claimed
	)
	if cache.has_method("set_available"):
		cache.call("set_available", _is_overflow_pump_cleared())
	if cache.has_method("set_claimed"):
		cache.call(
			"set_claimed",
			_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_reward_cache_claimed
		)


func _sync_overflow_pump_exit_hatch_state() -> void:
	var hatch: Node = (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_exit_hatch
	)
	if hatch == null:
		return
	var hatch_visible: bool = (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_reward_cache_claimed
		or _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_exit_hatch_opened
	)
	hatch.visible = hatch_visible
	if hatch.has_method("set_available"):
		hatch.call("set_available", _is_overflow_pump_exit_hatch_available())
	if hatch.has_method("set_activated"):
		hatch.call(
			"set_activated",
			_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_exit_hatch_opened
		)
	_set_overflow_pump_exit_hatch_collision_blocking(
		hatch_visible
			and not _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_exit_hatch_opened
	)
	_sync_overflow_pump_runoff_duct_state()


func _sync_overflow_pump_runoff_duct_state() -> void:
	var should_show_duct: bool = (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_exit_hatch_opened
		or _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_duct_crossed
	)
	if _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_duct != null:
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_duct.visible = (
			should_show_duct
		)
	_sync_overflow_pump_runoff_exit_skirmish_state()
	if _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_duct_vent == null:
		return
	var contact_active: bool = _is_overflow_pump_runoff_duct_contact_active()
	_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_duct_vent.visible = (
		should_show_duct
	)
	_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_duct_vent.monitoring = (
		contact_active
	)
	_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_duct_vent.monitorable = (
		contact_active
	)
	_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_duct_vent.collision_layer = (
		CollisionComponent.COLLISION_LAYER_ENVIRONMENT if contact_active else 0
	)
	_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_duct_vent.collision_mask = (
		CollisionComponent.COLLISION_MASK_ENVIRONMENT if contact_active else 0
	)
	var collision_shape := (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_duct_vent.get_node_or_null(
			"CollisionShape2D"
		) as CollisionShape2D
	)
	if collision_shape != null:
		collision_shape.disabled = not contact_active


func _sync_overflow_pump_runoff_exit_skirmish_state() -> void:
	var skirmish_active: bool = _is_overflow_pump_runoff_exit_skirmish_active()
	_sync_lower_deck_forward_pressure_aftershock_exit_enemy_state(
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_coil_rat,
		skirmish_active
			and not _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_coil_rat_defeated
	)
	_sync_overflow_pump_runoff_exit_reward_cache_state()
	_sync_overflow_pump_runoff_exit_gate_state()


func _sync_overflow_pump_runoff_exit_reward_cache_state() -> void:
	var cache: Node = (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_reward_cache
	)
	if cache == null:
		return
	cache.visible = (
		_is_overflow_pump_runoff_exit_skirmish_cleared()
		or _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_reward_cache_claimed
	)
	if cache.has_method("set_available"):
		cache.call("set_available", _is_overflow_pump_runoff_exit_reward_cache_available())
	if cache.has_method("set_claimed"):
		cache.call(
			"set_claimed",
			_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_reward_cache_claimed
		)


func _sync_overflow_pump_runoff_exit_gate_state() -> void:
	var gate: Node = (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_gate
	)
	if gate == null:
		return
	var gate_visible: bool = (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_reward_cache_claimed
		or _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_gate_opened
	)
	gate.visible = gate_visible
	if gate.has_method("set_available"):
		gate.call("set_available", _is_overflow_pump_runoff_exit_gate_available())
	if gate.has_method("set_activated"):
		gate.call(
			"set_activated",
			_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_gate_opened
		)
	_set_overflow_pump_runoff_exit_gate_collision_blocking(
		gate_visible
			and not _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_gate_opened
	)
	_sync_overflow_pump_runoff_outlet_state()


func _sync_overflow_pump_runoff_outlet_state() -> void:
	var should_show_outlet: bool = (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_gate_opened
		or _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_crossed
	)
	if (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_duct
		!= null
		):
			_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_duct.visible = (
				should_show_outlet
			)
	_sync_overflow_pump_runoff_outlet_skirmish_state()
	if (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_vent
		== null
	):
		return
	var contact_active: bool = _is_overflow_pump_runoff_outlet_contact_active()
	_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_vent.visible = (
		should_show_outlet
	)
	_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_vent.monitoring = (
		contact_active
	)
	_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_vent.monitorable = (
		contact_active
	)
	_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_vent.collision_layer = (
		CollisionComponent.COLLISION_LAYER_ENVIRONMENT if contact_active else 0
	)
	_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_vent.collision_mask = (
		CollisionComponent.COLLISION_MASK_ENVIRONMENT if contact_active else 0
	)
	var collision_shape := (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_vent.get_node_or_null(
			"CollisionShape2D"
		) as CollisionShape2D
	)
	if collision_shape != null:
		collision_shape.disabled = not contact_active


func _sync_overflow_pump_runoff_outlet_skirmish_state() -> void:
	var skirmish_active: bool = _is_overflow_pump_runoff_outlet_skirmish_active()
	_sync_lower_deck_forward_pressure_aftershock_exit_enemy_state(
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_spark_rat,
		skirmish_active
			and not _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_spark_rat_defeated
	)
	_sync_overflow_pump_runoff_outlet_reward_cache_state()
	_sync_overflow_pump_runoff_outlet_service_hatch_state()


func _sync_overflow_pump_runoff_outlet_reward_cache_state() -> void:
	var cache: Node = (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_reward_cache
	)
	if cache == null:
		return
	cache.visible = (
		_is_overflow_pump_runoff_outlet_skirmish_cleared()
		or _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_reward_cache_claimed
	)
	if cache.has_method("set_available"):
		cache.call(
			"set_available",
			_is_overflow_pump_runoff_outlet_reward_cache_available()
		)
	if cache.has_method("set_claimed"):
		cache.call(
			"set_claimed",
			_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_reward_cache_claimed
		)


func _sync_overflow_pump_runoff_outlet_service_hatch_state() -> void:
	var hatch: Node = (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_hatch
	)
	if hatch == null:
		return
	var hatch_visible: bool = (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_reward_cache_claimed
		or _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_hatch_opened
	)
	hatch.visible = hatch_visible
	if hatch.has_method("set_available"):
		hatch.call(
			"set_available",
			_is_overflow_pump_runoff_outlet_service_hatch_available()
		)
	if hatch.has_method("set_activated"):
		hatch.call(
			"set_activated",
			_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_hatch_opened
		)
	_set_overflow_pump_runoff_outlet_service_hatch_collision_blocking(
		hatch_visible
			and not _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_hatch_opened
	)
	_sync_overflow_pump_runoff_outlet_service_sluice_state()


func _sync_overflow_pump_runoff_outlet_service_sluice_state() -> void:
	var should_show_sluice: bool = (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_hatch_opened
		or _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_crossed
	)
	if (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_duct
		!= null
	):
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_duct.visible = (
			should_show_sluice
		)
	var hazard: Area2D = (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_vent
			as Area2D
	)
	if hazard == null:
		return
	var contact_active: bool = (
		_is_overflow_pump_runoff_outlet_service_sluice_contact_active()
	)
	hazard.visible = should_show_sluice
	hazard.monitoring = contact_active
	hazard.monitorable = contact_active
	hazard.collision_layer = (
		CollisionComponent.COLLISION_LAYER_ENVIRONMENT if contact_active else 0
	)
	hazard.collision_mask = (
		CollisionComponent.COLLISION_MASK_ENVIRONMENT if contact_active else 0
	)
	var collision_shape := hazard.get_node_or_null("CollisionShape2D") as CollisionShape2D
	if collision_shape != null:
		collision_shape.disabled = not contact_active
	_sync_overflow_pump_runoff_outlet_service_sluice_skirmish_state()


func _sync_overflow_pump_runoff_outlet_service_sluice_skirmish_state() -> void:
	var skirmish_active: bool = (
		_is_overflow_pump_runoff_outlet_service_sluice_skirmish_active()
	)
	_sync_lower_deck_forward_pressure_aftershock_exit_enemy_state(
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_spark_rat,
		skirmish_active
			and not _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_spark_rat_defeated
	)


func _sync_lower_deck_forward_pressure_exit_gate_state() -> void:
	if _lower_deck_forward_pressure_exit_gate == null:
		return
	var gate_visible: bool = (
		_lower_deck_forward_pressure_exit_relay_activated
		or _lower_deck_forward_pressure_exit_gate_opened
	)
	_lower_deck_forward_pressure_exit_gate.visible = gate_visible
	if _lower_deck_forward_pressure_exit_gate.has_method("set_available"):
		_lower_deck_forward_pressure_exit_gate.call(
			"set_available",
			_is_lower_deck_forward_pressure_exit_gate_available()
		)
	if _lower_deck_forward_pressure_exit_gate.has_method("set_activated"):
		_lower_deck_forward_pressure_exit_gate.call(
			"set_activated",
			_lower_deck_forward_pressure_exit_gate_opened
		)
	_set_lower_deck_forward_pressure_exit_gate_collision_blocking(
		gate_visible and not _lower_deck_forward_pressure_exit_gate_opened
	)


func _sync_lower_deck_forward_pressure_route_handoff_marker_state() -> void:
	if _lower_deck_forward_pressure_route_handoff_marker == null:
		return
	var marker_visible: bool = (
		_lower_deck_forward_pressure_exit_gate_opened
		or _lower_deck_forward_pressure_route_handoff_marker_lit
	)
	_lower_deck_forward_pressure_route_handoff_marker.visible = marker_visible
	if _lower_deck_forward_pressure_route_handoff_marker.has_method("set_available"):
		_lower_deck_forward_pressure_route_handoff_marker.call(
			"set_available",
			_is_lower_deck_forward_pressure_route_handoff_marker_available()
		)
	if _lower_deck_forward_pressure_route_handoff_marker.has_method("set_activated"):
		_lower_deck_forward_pressure_route_handoff_marker.call(
			"set_activated",
			_lower_deck_forward_pressure_route_handoff_marker_lit
		)


func _sync_service_lift_state() -> void:
	if _service_lift == null:
		return
	if _service_lift.has_method("set"):
		if _is_checkpoint_overdrive_duo_blocking_service_lift():
			_service_lift.set("locked_prompt_text", "Clear overdrive duo")
		elif _is_checkpoint_rear_ambush_blocking_service_lift():
			_service_lift.set("locked_prompt_text", "Clear rear ambush")
		elif _is_checkpoint_forward_patrol_blocking_service_lift():
			_service_lift.set("locked_prompt_text", "Clear forward patrol")
		else:
			_service_lift.set("locked_prompt_text", "Clear patrol")
	if _service_lift.has_method("set_available"):
		_service_lift.call("set_available", (
			_spark_rat_defeated
			and not _is_return_patrol_blocking_service_lift()
			and not _is_checkpoint_forward_patrol_blocking_service_lift()
			and not _is_checkpoint_rear_ambush_blocking_service_lift()
			and not _is_checkpoint_overdrive_duo_blocking_service_lift()
		))
	if _service_lift.has_method("set_activated"):
		_service_lift.call("set_activated", _service_lift_activated)


func _update_route_label(text_value: String) -> void:
	var route_label := get_node_or_null("RouteLabel") as Label
	if route_label == null:
		return
	route_label.text = text_value
	route_label.visible = true


func _refresh_factory_route_objective() -> void:
	var objective_id: StringName = _get_factory_route_objective_id()
	_update_route_label(_get_factory_route_objective_text(objective_id))


func _get_factory_route_objective_id() -> StringName:
	if _lower_deck_forward_conduit_activated and not _lower_deck_forward_conduit_defeated:
		return FACTORY_OBJECTIVE_CLEAR_FORWARD_CONDUIT_AMBUSH
	if _lower_deck_forward_pressure_exit_guard_activated \
			and not _lower_deck_forward_pressure_exit_guard_defeated:
		return FACTORY_OBJECTIVE_CLEAR_FORWARD_PRESSURE_EXIT_GUARD
	if _lower_deck_forward_pressure_beacon_ambush_activated \
			and not _lower_deck_forward_pressure_beacon_ambush_defeated:
		return FACTORY_OBJECTIVE_CLEAR_FORWARD_PRESSURE_BEACON_AMBUSH
	if _lower_deck_forward_pressure_overrun_activated \
			and not _lower_deck_forward_pressure_overrun_defeated:
		return FACTORY_OBJECTIVE_SURVIVE_FORWARD_PRESSURE_OVERRUN
	if _lower_deck_forward_pressure_breaker_activated \
			and not _lower_deck_forward_pressure_breaker_secured:
		return FACTORY_OBJECTIVE_SECURE_FORWARD_PRESSURE_BREAKER
	if _lower_deck_forward_pressure_relief_ambush_activated \
			and not _lower_deck_forward_pressure_relief_ambush_defeated:
		return FACTORY_OBJECTIVE_SURVIVE_FORWARD_PRESSURE_RELIEF_AMBUSH
	if _lower_deck_forward_pressure_coil_rat_activated \
			and not _lower_deck_forward_pressure_coil_rat_defeated:
		return FACTORY_OBJECTIVE_FACE_FORWARD_PRESSURE_COIL_RAT
	if _is_lower_deck_forward_pressure_coil_pincer_active():
		return FACTORY_OBJECTIVE_BREAK_FORWARD_PRESSURE_COIL_PINCER
	if _is_lower_deck_forward_pressure_coil_aftershock_active():
		return FACTORY_OBJECTIVE_CONTAIN_FORWARD_PRESSURE_COIL_AFTERSHOCK
	if _is_lower_deck_forward_pressure_aftershock_exit_skirmish_active():
		return FACTORY_OBJECTIVE_BREAK_FORWARD_PRESSURE_AFTERSHOCK_EXIT_SKIRMISH
	if _is_lower_deck_forward_pressure_aftershock_exhaust_active():
		return FACTORY_OBJECTIVE_CROSS_FORWARD_PRESSURE_AFTERSHOCK_EXHAUST
	if _is_lower_deck_forward_pressure_aftershock_exhaust_pursuer_active():
		return FACTORY_OBJECTIVE_PURGE_FORWARD_PRESSURE_AFTERSHOCK_EXHAUST_PURSUER
	if _is_lower_deck_forward_pressure_aftershock_exhaust_flank_active():
		return FACTORY_OBJECTIVE_BREAK_FORWARD_PRESSURE_AFTERSHOCK_EXHAUST_FLANK
	if _is_lower_deck_forward_pressure_aftershock_exhaust_breaker_stand_active():
		return FACTORY_OBJECTIVE_SECURE_FORWARD_PRESSURE_AFTERSHOCK_EXHAUST_BREAKER
	if _is_lower_deck_forward_pressure_aftershock_exhaust_escape_skirmish_active():
		return FACTORY_OBJECTIVE_BREAK_FORWARD_PRESSURE_AFTERSHOCK_EXHAUST_ESCAPE
	if _is_lower_deck_forward_pressure_aftershock_cooling_duct_active():
		return FACTORY_OBJECTIVE_CROSS_FORWARD_PRESSURE_AFTERSHOCK_COOLING_DUCT
	if _is_lower_deck_forward_pressure_aftershock_condenser_valve_active():
		return FACTORY_OBJECTIVE_SECURE_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER
	if _is_lower_deck_forward_pressure_aftershock_condenser_outlet_active():
		return FACTORY_OBJECTIVE_CROSS_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_OUTLET
	if _is_outlet_clamp_ambush_active():
		return FACTORY_OBJECTIVE_CLEAR_FORWARD_PRESSURE_AFTERSHOCK_OUTLET_CLAMP_AMBUSH
	if _is_outlet_drip_vent_active():
		return FACTORY_OBJECTIVE_CROSS_FORWARD_PRESSURE_AFTERSHOCK_OUTLET_DRIP_VENT
	if _is_overflow_pump_active():
		return FACTORY_OBJECTIVE_CLEAR_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP
	if _is_overflow_pump_runoff_duct_active():
		return (
			FACTORY_OBJECTIVE_CROSS_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_RUNOFF_DUCT
		)
	if _is_overflow_pump_runoff_exit_skirmish_active():
		return (
			FACTORY_OBJECTIVE_CLEAR_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_RUNOFF_EXIT
		)
	if _is_overflow_pump_runoff_outlet_service_sluice_active():
		return (
			FACTORY_OBJECTIVE_CROSS_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_RUNOFF_OUTLET_SERVICE_SLUICE
		)
	if _is_overflow_pump_runoff_outlet_service_sluice_skirmish_active():
		return (
			FACTORY_OBJECTIVE_CLEAR_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_RUNOFF_OUTLET_SERVICE_SLUICE_SKIRMISH
		)
	if _is_overflow_pump_runoff_outlet_service_sluice_skirmish_cleared():
		return (
			FACTORY_OBJECTIVE_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_RUNOFF_OUTLET_SERVICE_SLUICE_SKIRMISH_CLEARED
		)
	if _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_crossed:
		return (
			FACTORY_OBJECTIVE_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_RUNOFF_OUTLET_SERVICE_SLUICE_CROSSED
		)
	if _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_hatch_opened:
		return (
			FACTORY_OBJECTIVE_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_RUNOFF_OUTLET_SERVICE_HATCH_OPENED
		)
	if _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_reward_cache_claimed:
		return (
			FACTORY_OBJECTIVE_OPEN_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_RUNOFF_OUTLET_SERVICE_HATCH
		)
	if _is_overflow_pump_runoff_outlet_skirmish_active():
		return (
			FACTORY_OBJECTIVE_CLEAR_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_RUNOFF_OUTLET_SKIRMISH
		)
	if _is_overflow_pump_runoff_outlet_active():
		return (
			FACTORY_OBJECTIVE_CROSS_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_RUNOFF_OUTLET
		)
	if _is_overflow_pump_runoff_outlet_skirmish_cleared():
		return (
			FACTORY_OBJECTIVE_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_RUNOFF_OUTLET_SKIRMISH_CLEARED
		)
	if _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_crossed:
		return (
			FACTORY_OBJECTIVE_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_RUNOFF_OUTLET_CROSSED
		)
	if _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_gate_opened:
		return (
			FACTORY_OBJECTIVE_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_RUNOFF_EXIT_GATE_OPENED
		)
	if _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_reward_cache_claimed:
		return (
			FACTORY_OBJECTIVE_OPEN_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_RUNOFF_EXIT_GATE
		)
	if _is_overflow_pump_runoff_exit_skirmish_cleared():
		return (
			FACTORY_OBJECTIVE_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_RUNOFF_EXIT_CLEARED
		)
	if _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_duct_crossed:
		return (
			FACTORY_OBJECTIVE_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_RUNOFF_DUCT_CROSSED
		)
	if _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_exit_hatch_opened:
		return FACTORY_OBJECTIVE_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_EXIT_HATCH_OPENED
	if _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_reward_cache_claimed:
		return FACTORY_OBJECTIVE_OPEN_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_EXIT_HATCH
	if _is_overflow_pump_cleared():
		return FACTORY_OBJECTIVE_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_CLEARED
	if _lower_deck_forward_pressure_aftershock_condenser_drip_vent_crossed:
		return FACTORY_OBJECTIVE_FORWARD_PRESSURE_AFTERSHOCK_OUTLET_DRIP_VENT_CROSSED
	if _is_outlet_clamp_ambush_cleared():
		return FACTORY_OBJECTIVE_FORWARD_PRESSURE_AFTERSHOCK_OUTLET_CLAMP_AMBUSH_CLEARED
	if _lower_deck_forward_pressure_aftershock_condenser_outlet_crossed:
		return FACTORY_OBJECTIVE_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_OUTLET_CROSSED
	if _lower_deck_forward_pressure_aftershock_condenser_savepoint_activated:
		return FACTORY_OBJECTIVE_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_SAVEPOINT_SECURED
	if _is_lower_deck_forward_pressure_aftershock_condenser_valve_cleared():
		return FACTORY_OBJECTIVE_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_SECURED
	if _lower_deck_forward_pressure_aftershock_cooling_duct_crossed:
		return FACTORY_OBJECTIVE_FORWARD_PRESSURE_AFTERSHOCK_COOLING_DUCT_CROSSED
	if _lower_deck_forward_pressure_aftershock_exhaust_exit_hatch_opened:
		return FACTORY_OBJECTIVE_FORWARD_PRESSURE_AFTERSHOCK_EXHAUST_EXIT_OPENED
	if _is_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch_available():
		return FACTORY_OBJECTIVE_OPEN_FORWARD_PRESSURE_AFTERSHOCK_EXHAUST_EXIT_HATCH
	if _is_lower_deck_forward_pressure_aftershock_exhaust_escape_skirmish_cleared():
		return FACTORY_OBJECTIVE_FORWARD_PRESSURE_AFTERSHOCK_EXHAUST_ESCAPE_SECURED
	if _lower_deck_forward_pressure_aftershock_exhaust_breaker_cut:
		return FACTORY_OBJECTIVE_FORWARD_PRESSURE_AFTERSHOCK_EXHAUST_BREAKER_CUT
	if _lower_deck_forward_pressure_aftershock_exhaust_breaker_secured:
		return FACTORY_OBJECTIVE_CUT_FORWARD_PRESSURE_AFTERSHOCK_EXHAUST
	if _lower_deck_forward_pressure_aftershock_exhaust_flank_spark_rat_defeated:
		return FACTORY_OBJECTIVE_FORWARD_PRESSURE_AFTERSHOCK_EXHAUST_FLANK_CLEARED
	if _lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache_claimed:
		return FACTORY_OBJECTIVE_FORWARD_PRESSURE_AFTERSHOCK_EXHAUST_PURSUER_CACHE_CLAIMED
	if _lower_deck_forward_pressure_aftershock_exhaust_pursuer_defeated:
		return FACTORY_OBJECTIVE_FORWARD_PRESSURE_AFTERSHOCK_EXHAUST_PURSUER_CLEARED
	if _lower_deck_forward_pressure_aftershock_exhaust_crossed:
		return FACTORY_OBJECTIVE_FORWARD_PRESSURE_AFTERSHOCK_EXHAUST_CROSSED
	if _is_lower_deck_forward_pressure_aftershock_exit_skirmish_cleared():
		return FACTORY_OBJECTIVE_FORWARD_PRESSURE_AFTERSHOCK_EXIT_SKIRMISH_CLEARED
	if _lower_deck_forward_pressure_aftershock_reward_cache_claimed:
		return FACTORY_OBJECTIVE_FORWARD_PRESSURE_AFTERSHOCK_CACHE_CLAIMED
	if _lower_deck_forward_pressure_coil_aftershock_defeated:
		return FACTORY_OBJECTIVE_FORWARD_PRESSURE_COIL_AFTERSHOCK_CLEARED
	if _is_lower_deck_forward_pressure_coil_pincer_cleared():
		return FACTORY_OBJECTIVE_FORWARD_PRESSURE_COIL_PINCER_CLEARED
	if _lower_deck_forward_pressure_coil_rat_defeated:
		return FACTORY_OBJECTIVE_FORWARD_PRESSURE_COIL_RAT_CLEARED
	if _lower_deck_forward_pressure_relief_ambush_defeated:
		return FACTORY_OBJECTIVE_FORWARD_PRESSURE_RELIEF_AMBUSH_CLEARED
	if _lower_deck_forward_pressure_breaker_cut:
		return FACTORY_OBJECTIVE_FORWARD_PRESSURE_BREAKER_CUT
	if _lower_deck_forward_pressure_breaker_secured:
		return FACTORY_OBJECTIVE_CUT_FORWARD_PRESSURE
	if _lower_deck_forward_pressure_overrun_defeated:
		return FACTORY_OBJECTIVE_FORWARD_PRESSURE_OVERRUN_CLEARED
	if _lower_deck_forward_pressure_beacon_ambush_defeated:
		return FACTORY_OBJECTIVE_FORWARD_PRESSURE_BEACON_AMBUSH_CLEARED
	if _lower_deck_forward_pressure_route_handoff_marker_lit:
		return FACTORY_OBJECTIVE_FORWARD_PRESSURE_ROUTE_BEACON_LIT
	if _lower_deck_forward_pressure_exit_gate_opened:
		return FACTORY_OBJECTIVE_FORWARD_PRESSURE_EXIT_GATE_OPENED
	if _lower_deck_forward_pressure_exit_relay_activated:
		return FACTORY_OBJECTIVE_FORWARD_PRESSURE_EXIT_RELAY_SECURED
	if _lower_deck_forward_pressure_exit_guard_defeated:
		return FACTORY_OBJECTIVE_FORWARD_PRESSURE_EXIT_SECURED
	if _lower_deck_forward_pressure_counter_ambush_activated \
			and not _lower_deck_forward_pressure_counter_ambush_defeated:
		return FACTORY_OBJECTIVE_SURVIVE_FORWARD_PRESSURE_AMBUSH
	if _lower_deck_forward_pressure_counter_ambush_defeated:
		return FACTORY_OBJECTIVE_FORWARD_PRESSURE_AMBUSH_CLEARED
	if _lower_deck_forward_pressure_traverse_crossed:
		return FACTORY_OBJECTIVE_FORWARD_PRESSURE_TRAVERSE_CROSSED
	if _lower_deck_forward_pressure_traverse_active:
		return FACTORY_OBJECTIVE_CROSS_FORWARD_PRESSURE_LEAK
	if _lower_deck_forward_conduit_defeated:
		return FACTORY_OBJECTIVE_FORWARD_CONDUIT_SECURED
	if _lower_deck_forward_hatch_opened:
		return FACTORY_OBJECTIVE_FORWARD_HATCH_OPENED
	if _lower_deck_relay_forward_reward_cache_claimed:
		return FACTORY_OBJECTIVE_OPEN_FORWARD_HATCH
	if _lower_deck_post_relay_trial_activated and not _lower_deck_post_relay_trial_defeated:
		return FACTORY_OBJECTIVE_CLEAR_POST_RELAY_TRIAL
	if _lower_deck_post_relay_trial_defeated:
		return FACTORY_OBJECTIVE_POST_RELAY_TRIAL_SECURED
	if _lower_deck_breach_relay_activated:
		return FACTORY_OBJECTIVE_BREACH_RELAY_SECURED
	if _return_patrol_activated and not _return_patrol_defeated:
		return FACTORY_OBJECTIVE_CLEAR_RETURN_PATROL
	if _checkpoint_forward_patrol_activated and not _checkpoint_forward_patrol_defeated:
		return FACTORY_OBJECTIVE_CLEAR_CHECKPOINT_FORWARD_PATROL
	if _lower_deck_skirmish_activated and not _lower_deck_skirmish_defeated:
		return FACTORY_OBJECTIVE_CLEAR_LOWER_DECK_SKIRMISH
	if _lower_deck_exit_ambush_activated and not _lower_deck_exit_ambush_defeated:
		return FACTORY_OBJECTIVE_CLEAR_LOWER_DECK_EXIT_AMBUSH
	if _lower_deck_shortcut_activated and not _lower_deck_shortcut_guard_defeated:
		return FACTORY_OBJECTIVE_CLEAR_LOWER_DECK_SHORTCUT_GUARD
	if _lower_deck_shortcut_guard_defeated and not _lower_deck_shortcut_unlocked:
		return FACTORY_OBJECTIVE_OPEN_LOWER_DECK_SHORTCUT
	if (
		_lower_deck_shortcut_pursuer_activated
		and not _lower_deck_shortcut_pursuer_defeated
	):
		return FACTORY_OBJECTIVE_CLEAR_SHORTCUT_PURSUER
	if _lower_deck_pressure_guard_activated and not _lower_deck_pressure_guard_defeated:
		return FACTORY_OBJECTIVE_CLEAR_PRESSURE_VALVE_GUARD
	if _lower_deck_pressure_guard_defeated and not _lower_deck_pressure_valve_opened:
		return FACTORY_OBJECTIVE_OPEN_PRESSURE_VALVE
	if _lower_deck_steam_sluice_activated and not _lower_deck_steam_sluice_defeated:
		return FACTORY_OBJECTIVE_CLEAR_STEAM_SLUICE_AMBUSH
	if (
		_lower_deck_deep_bulkhead_guard_activated
		and not _lower_deck_deep_bulkhead_guard_defeated
	):
		return FACTORY_OBJECTIVE_CLEAR_DEEP_BULKHEAD_GUARD
	if (
		_lower_deck_deep_bulkhead_guard_defeated
		and not _lower_deck_deep_bulkhead_opened
	):
		return FACTORY_OBJECTIVE_OPEN_DEEP_BULKHEAD
	if _lower_deck_breach_corridor_secured:
		return FACTORY_OBJECTIVE_BREACH_CORRIDOR_SECURED
	if (
		_lower_deck_breach_rear_ambusher_activated
		and not _lower_deck_breach_rear_ambusher_defeated
	):
		return FACTORY_OBJECTIVE_SURVIVE_BREACH_PINCER
	if (
		_lower_deck_breach_corridor_activated
		and _lower_deck_breach_front_guard_defeated
		and not _lower_deck_breach_rear_ambusher_defeated
	):
		return FACTORY_OBJECTIVE_SURVIVE_BREACH_PINCER
	if _lower_deck_breach_corridor_activated and not _lower_deck_breach_front_guard_defeated:
		return FACTORY_OBJECTIVE_CLEAR_BREACH_CORRIDOR_AMBUSH
	if _lower_deck_deep_bulkhead_opened:
		return FACTORY_OBJECTIVE_DEEP_BULKHEAD_OPENED
	if _lower_deck_steam_sluice_defeated:
		return FACTORY_OBJECTIVE_STEAM_SLUICE_CLEARED
	if _lower_deck_pressure_valve_opened:
		return FACTORY_OBJECTIVE_PRESSURE_VALVE_OPENED
	if _lower_deck_shortcut_pursuer_defeated:
		return FACTORY_OBJECTIVE_SHORTCUT_PURSUER_CLEARED
	if _lower_deck_shortcut_unlocked:
		return FACTORY_OBJECTIVE_LOWER_DECK_SHORTCUT_OPENED
	if _lower_deck_exit_ambush_defeated:
		return FACTORY_OBJECTIVE_LOWER_DECK_EXIT_CLEARED
	if _lower_deck_skirmish_defeated:
		return FACTORY_OBJECTIVE_LOWER_DECK_CLEARED
	if _is_checkpoint_overdrive_duo_cleared():
		return FACTORY_OBJECTIVE_CHECKPOINT_OVERDRIVE_DUO_CLEARED
	if _checkpoint_overdrive_duo_activated and not _is_checkpoint_overdrive_duo_cleared():
		return FACTORY_OBJECTIVE_CLEAR_CHECKPOINT_OVERDRIVE_DUO
	if _checkpoint_rear_ambush_defeated:
		return FACTORY_OBJECTIVE_CLEAR_CHECKPOINT_OVERDRIVE_DUO
	if _checkpoint_forward_patrol_defeated:
		return FACTORY_OBJECTIVE_CLEAR_CHECKPOINT_REAR_AMBUSH
	if _return_patrol_defeated:
		return FACTORY_OBJECTIVE_RETURN_PATROL_CLEARED
	if _spark_rat_defeated:
		return FACTORY_OBJECTIVE_ROUTE_CLEARED
	if _deep_route_cleared:
		return FACTORY_OBJECTIVE_DEFEAT_SPARK_RAT
	if _deep_guard_defeated:
		return FACTORY_OBJECTIVE_OPEN_DEEP_ROUTE
	if _encounter_cleared:
		return FACTORY_OBJECTIVE_REACH_DEEP_GUARD
	return FACTORY_OBJECTIVE_CLEAR_ENTRANCE


func _get_factory_route_objective_text(objective_id: StringName) -> String:
	match objective_id:
		FACTORY_OBJECTIVE_CLEAR_ENTRANCE:
			return "Clear Factory Entrance"
		FACTORY_OBJECTIVE_REACH_DEEP_GUARD:
			return "Reach Deep Guard"
		FACTORY_OBJECTIVE_OPEN_DEEP_ROUTE:
			return "Open Deep Route Endpoint"
		FACTORY_OBJECTIVE_DEFEAT_SPARK_RAT:
			return "Defeat Spark Rat Patrol"
		FACTORY_OBJECTIVE_ROUTE_CLEARED:
			return "Factory Route Cleared"
		FACTORY_OBJECTIVE_CLEAR_RETURN_PATROL:
			return "Clear Return Patrol"
		FACTORY_OBJECTIVE_RETURN_PATROL_CLEARED:
			return "Return Patrol Cleared"
		FACTORY_OBJECTIVE_CLEAR_CHECKPOINT_FORWARD_PATROL:
			return "Clear Forward Patrol"
		FACTORY_OBJECTIVE_CHECKPOINT_FORWARD_ROUTE_OPENED:
			return "Deeper Factory Route Opened"
		FACTORY_OBJECTIVE_CLEAR_CHECKPOINT_REAR_AMBUSH:
			return "Clear Rear Ambush"
		FACTORY_OBJECTIVE_CHECKPOINT_REAR_AMBUSH_CLEARED:
			return "Vent Gauntlet Cleared"
		FACTORY_OBJECTIVE_CLEAR_CHECKPOINT_OVERDRIVE_DUO:
			return "Clear Overdrive Duo"
		FACTORY_OBJECTIVE_CHECKPOINT_OVERDRIVE_DUO_CLEARED:
			return "Factory Lift Secured"
		FACTORY_OBJECTIVE_CLEAR_LOWER_DECK_SKIRMISH:
			return "Clear Lower Deck Skirmish"
		FACTORY_OBJECTIVE_LOWER_DECK_CLEARED:
			return "Lower Deck Cleared"
		FACTORY_OBJECTIVE_CLEAR_LOWER_DECK_EXIT_AMBUSH:
			return "Clear Lower Deck Exit"
		FACTORY_OBJECTIVE_LOWER_DECK_EXIT_CLEARED:
			return "Lower Deck Exit Cleared"
		FACTORY_OBJECTIVE_CLEAR_LOWER_DECK_SHORTCUT_GUARD:
			return "Clear Shortcut Guard"
		FACTORY_OBJECTIVE_OPEN_LOWER_DECK_SHORTCUT:
			return "Open Lower Deck Shortcut"
		FACTORY_OBJECTIVE_LOWER_DECK_SHORTCUT_OPENED:
			return "Lower Deck Shortcut Opened"
		FACTORY_OBJECTIVE_CLEAR_SHORTCUT_PURSUER:
			return "Clear Shortcut Pursuer"
		FACTORY_OBJECTIVE_SHORTCUT_PURSUER_CLEARED:
			return "Shortcut Pursuer Cleared"
		FACTORY_OBJECTIVE_CLEAR_PRESSURE_VALVE_GUARD:
			return "Clear Pressure Valve Guard"
		FACTORY_OBJECTIVE_OPEN_PRESSURE_VALVE:
			return "Open Pressure Valve"
		FACTORY_OBJECTIVE_PRESSURE_VALVE_OPENED:
			return "Pressure Valve Opened"
		FACTORY_OBJECTIVE_CLEAR_STEAM_SLUICE_AMBUSH:
			return "Clear Steam Sluice Ambush"
		FACTORY_OBJECTIVE_STEAM_SLUICE_CLEARED:
			return "Steam Sluice Cleared"
		FACTORY_OBJECTIVE_CLEAR_DEEP_BULKHEAD_GUARD:
			return "Clear Deep Bulkhead Guard"
		FACTORY_OBJECTIVE_OPEN_DEEP_BULKHEAD:
			return "Open Deep Bulkhead"
		FACTORY_OBJECTIVE_DEEP_BULKHEAD_OPENED:
			return "Deep Bulkhead Opened"
		FACTORY_OBJECTIVE_CLEAR_BREACH_CORRIDOR_AMBUSH:
			return "Clear Breach Corridor Ambush"
		FACTORY_OBJECTIVE_SURVIVE_BREACH_PINCER:
			return "Survive Breach Pincer"
		FACTORY_OBJECTIVE_BREACH_CORRIDOR_SECURED:
			return "Breach Corridor Secured"
		FACTORY_OBJECTIVE_BREACH_RELAY_SECURED:
			return "Lower Deck Relay Secured"
		FACTORY_OBJECTIVE_CLEAR_POST_RELAY_TRIAL:
			return "Clear Relay Forward Trial"
		FACTORY_OBJECTIVE_POST_RELAY_TRIAL_SECURED:
			return "Relay Forward Secured"
		FACTORY_OBJECTIVE_CLAIM_RELAY_FORWARD_CACHE:
			return "Claim Relay Forward Cache"
		FACTORY_OBJECTIVE_OPEN_FORWARD_HATCH:
			return "Open Forward Hatch"
		FACTORY_OBJECTIVE_FORWARD_HATCH_OPENED:
			return "Lower Deck Forward Hatch Opened"
		FACTORY_OBJECTIVE_CLEAR_FORWARD_CONDUIT_AMBUSH:
			return "Clear Forward Conduit Ambush"
		FACTORY_OBJECTIVE_FORWARD_CONDUIT_SECURED:
			return "Forward Conduit Secured"
		FACTORY_OBJECTIVE_CROSS_FORWARD_PRESSURE_LEAK:
			return "Cross Forward Pressure Leak"
		FACTORY_OBJECTIVE_FORWARD_PRESSURE_TRAVERSE_CROSSED:
			return "Forward Pressure Traverse Crossed"
		FACTORY_OBJECTIVE_SURVIVE_FORWARD_PRESSURE_AMBUSH:
			return "Survive Forward Pressure Ambush"
		FACTORY_OBJECTIVE_FORWARD_PRESSURE_AMBUSH_CLEARED:
			return "Forward Pressure Ambush Cleared"
		FACTORY_OBJECTIVE_CLEAR_FORWARD_PRESSURE_EXIT_GUARD:
			return "Clear Forward Pressure Exit Guard"
		FACTORY_OBJECTIVE_FORWARD_PRESSURE_EXIT_SECURED:
			return "Forward Pressure Exit Secured"
		FACTORY_OBJECTIVE_FORWARD_PRESSURE_EXIT_RELAY_SECURED:
			return "Forward Pressure Exit Relay Secured"
		FACTORY_OBJECTIVE_FORWARD_PRESSURE_EXIT_GATE_OPENED:
			return "Forward Pressure Exit Gate Opened"
		FACTORY_OBJECTIVE_FORWARD_PRESSURE_ROUTE_BEACON_LIT:
			return "Forward Pressure Route Beacon Lit"
		FACTORY_OBJECTIVE_CLEAR_FORWARD_PRESSURE_BEACON_AMBUSH:
			return "Clear Forward Pressure Beacon Ambush"
		FACTORY_OBJECTIVE_FORWARD_PRESSURE_BEACON_AMBUSH_CLEARED:
			return "Forward Pressure Beacon Ambush Cleared"
		FACTORY_OBJECTIVE_SURVIVE_FORWARD_PRESSURE_OVERRUN:
			return "Survive Forward Pressure Overrun"
		FACTORY_OBJECTIVE_FORWARD_PRESSURE_OVERRUN_CLEARED:
			return "Forward Pressure Overrun Cleared"
		FACTORY_OBJECTIVE_SECURE_FORWARD_PRESSURE_BREAKER:
			return "Secure Forward Pressure Breaker"
		FACTORY_OBJECTIVE_CUT_FORWARD_PRESSURE:
			return "Cut Forward Pressure"
		FACTORY_OBJECTIVE_FORWARD_PRESSURE_BREAKER_CUT:
			return "Forward Pressure Breaker Cut"
		FACTORY_OBJECTIVE_SURVIVE_FORWARD_PRESSURE_RELIEF_AMBUSH:
			return "Survive Forward Pressure Relief Ambush"
		FACTORY_OBJECTIVE_FORWARD_PRESSURE_RELIEF_AMBUSH_CLEARED:
			return "Forward Pressure Relief Ambush Cleared"
		FACTORY_OBJECTIVE_FACE_FORWARD_PRESSURE_COIL_RAT:
			return "Face Coil Rat Breakthrough"
		FACTORY_OBJECTIVE_FORWARD_PRESSURE_COIL_RAT_CLEARED:
			return "Forward Pressure Coil Rat Breakthrough Cleared"
		FACTORY_OBJECTIVE_BREAK_FORWARD_PRESSURE_COIL_PINCER:
			return "Break Coil Pincer"
		FACTORY_OBJECTIVE_FORWARD_PRESSURE_COIL_PINCER_CLEARED:
			return "Forward Pressure Coil Pincer Cleared"
		FACTORY_OBJECTIVE_CONTAIN_FORWARD_PRESSURE_COIL_AFTERSHOCK:
			return "Contain Coil Aftershock"
		FACTORY_OBJECTIVE_FORWARD_PRESSURE_COIL_AFTERSHOCK_CLEARED:
			return "Forward Pressure Coil Aftershock Cleared"
		FACTORY_OBJECTIVE_FORWARD_PRESSURE_AFTERSHOCK_CACHE_CLAIMED:
			return "Forward Pressure Aftershock Cache Claimed +20 Gears"
		FACTORY_OBJECTIVE_BREAK_FORWARD_PRESSURE_AFTERSHOCK_EXIT_SKIRMISH:
			return "Break Aftershock Exit Skirmish"
		FACTORY_OBJECTIVE_FORWARD_PRESSURE_AFTERSHOCK_EXIT_SKIRMISH_CLEARED:
			return "Forward Pressure Aftershock Exit Skirmish Cleared"
		FACTORY_OBJECTIVE_CROSS_FORWARD_PRESSURE_AFTERSHOCK_EXHAUST:
			return "Cross Aftershock Exhaust"
		FACTORY_OBJECTIVE_FORWARD_PRESSURE_AFTERSHOCK_EXHAUST_CROSSED:
			return "Forward Pressure Aftershock Exhaust Crossed"
		FACTORY_OBJECTIVE_PURGE_FORWARD_PRESSURE_AFTERSHOCK_EXHAUST_PURSUER:
			return "Purge Aftershock Exhaust Pursuer"
		FACTORY_OBJECTIVE_FORWARD_PRESSURE_AFTERSHOCK_EXHAUST_PURSUER_CLEARED:
			return "Forward Pressure Exhaust Pursuer Cleared"
		FACTORY_OBJECTIVE_FORWARD_PRESSURE_AFTERSHOCK_EXHAUST_PURSUER_CACHE_CLAIMED:
			return "Forward Pressure Exhaust Pursuer Cache Claimed +20 Gears"
		FACTORY_OBJECTIVE_BREAK_FORWARD_PRESSURE_AFTERSHOCK_EXHAUST_FLANK:
			return "Break Aftershock Exhaust Flank"
		FACTORY_OBJECTIVE_FORWARD_PRESSURE_AFTERSHOCK_EXHAUST_FLANK_CLEARED:
			return "Forward Pressure Exhaust Flank Cleared"
		FACTORY_OBJECTIVE_SECURE_FORWARD_PRESSURE_AFTERSHOCK_EXHAUST_BREAKER:
			return "Secure Aftershock Exhaust Breaker"
		FACTORY_OBJECTIVE_CUT_FORWARD_PRESSURE_AFTERSHOCK_EXHAUST:
			return "Cut Aftershock Exhaust"
		FACTORY_OBJECTIVE_FORWARD_PRESSURE_AFTERSHOCK_EXHAUST_BREAKER_CUT:
			return "Aftershock Exhaust Pressure Cut"
		FACTORY_OBJECTIVE_BREAK_FORWARD_PRESSURE_AFTERSHOCK_EXHAUST_ESCAPE:
			return "Break Aftershock Exhaust Escape"
		FACTORY_OBJECTIVE_FORWARD_PRESSURE_AFTERSHOCK_EXHAUST_ESCAPE_SECURED:
			return "Aftershock Exhaust Escape Secured"
		FACTORY_OBJECTIVE_OPEN_FORWARD_PRESSURE_AFTERSHOCK_EXHAUST_EXIT_HATCH:
			return "Open Aftershock Exhaust Hatch"
		FACTORY_OBJECTIVE_FORWARD_PRESSURE_AFTERSHOCK_EXHAUST_EXIT_OPENED:
			return "Aftershock Exhaust Exit Opened"
		FACTORY_OBJECTIVE_CROSS_FORWARD_PRESSURE_AFTERSHOCK_COOLING_DUCT:
			return "Cross Aftershock Cooling Duct"
		FACTORY_OBJECTIVE_FORWARD_PRESSURE_AFTERSHOCK_COOLING_DUCT_CROSSED:
			return "Aftershock Cooling Duct Crossed"
		FACTORY_OBJECTIVE_SECURE_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER:
			return "Secure Aftershock Condenser Landing"
		FACTORY_OBJECTIVE_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_SECURED:
			return "Aftershock Condenser Landing Secured"
		FACTORY_OBJECTIVE_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_SAVEPOINT_SECURED:
			return "Aftershock Condenser Savepoint Secured"
		FACTORY_OBJECTIVE_CROSS_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_OUTLET:
			return "Cross Aftershock Condenser Outlet"
		FACTORY_OBJECTIVE_CLEAR_FORWARD_PRESSURE_AFTERSHOCK_OUTLET_CLAMP_AMBUSH:
			return "Clear Outlet Clamp Ambush"
		FACTORY_OBJECTIVE_FORWARD_PRESSURE_AFTERSHOCK_OUTLET_CLAMP_AMBUSH_CLEARED:
			return "Outlet Clamp Ambush Cleared"
		FACTORY_OBJECTIVE_CROSS_FORWARD_PRESSURE_AFTERSHOCK_OUTLET_DRIP_VENT:
			return "Cross Outlet Drip Vent"
		FACTORY_OBJECTIVE_FORWARD_PRESSURE_AFTERSHOCK_OUTLET_DRIP_VENT_CROSSED:
			return "Outlet Drip Vent Crossed"
		FACTORY_OBJECTIVE_CLEAR_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP:
			return "Clear Overflow Pump Skirmish"
		FACTORY_OBJECTIVE_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_CLEARED:
			return "Overflow Pump Cleared"
		FACTORY_OBJECTIVE_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_CACHE_CLAIMED:
			return "Overflow Pump Cache Claimed +20 Gears"
		FACTORY_OBJECTIVE_OPEN_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_EXIT_HATCH:
			return "Open Overflow Pump Runoff Hatch"
		FACTORY_OBJECTIVE_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_EXIT_HATCH_OPENED:
			return "Overflow Pump Runoff Hatch Open"
		FACTORY_OBJECTIVE_CROSS_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_RUNOFF_DUCT:
			return "Cross Overflow Pump Runoff Duct"
		FACTORY_OBJECTIVE_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_RUNOFF_DUCT_CROSSED:
			return "Overflow Pump Runoff Duct Crossed"
		FACTORY_OBJECTIVE_CLEAR_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_RUNOFF_EXIT:
			return "Clear Overflow Pump Runoff Exit"
		FACTORY_OBJECTIVE_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_RUNOFF_EXIT_CLEARED:
			return "Overflow Pump Runoff Exit Cleared"
		FACTORY_OBJECTIVE_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_RUNOFF_EXIT_CACHE_CLAIMED:
			return "Runoff Exit Cache Claimed +20 Gears"
		FACTORY_OBJECTIVE_OPEN_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_RUNOFF_EXIT_GATE:
			return "Open Runoff Exit Gate"
		FACTORY_OBJECTIVE_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_RUNOFF_EXIT_GATE_OPENED:
			return "Overflow Pump Runoff Exit Gate Open"
		FACTORY_OBJECTIVE_CROSS_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_RUNOFF_OUTLET:
			return "Cross Overflow Pump Runoff Outlet"
		FACTORY_OBJECTIVE_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_RUNOFF_OUTLET_CROSSED:
			return "Overflow Pump Runoff Outlet Crossed"
		FACTORY_OBJECTIVE_CLEAR_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_RUNOFF_OUTLET_SKIRMISH:
			return "Clear Runoff Outlet Spark Rat"
		FACTORY_OBJECTIVE_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_RUNOFF_OUTLET_SKIRMISH_CLEARED:
			return "Runoff Outlet Spark Rat Cleared"
		FACTORY_OBJECTIVE_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_RUNOFF_OUTLET_CACHE_CLAIMED:
			return "Runoff Outlet Cache Claimed +20 Gears"
		FACTORY_OBJECTIVE_OPEN_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_RUNOFF_OUTLET_SERVICE_HATCH:
			return "Open Runoff Outlet Service Hatch"
		FACTORY_OBJECTIVE_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_RUNOFF_OUTLET_SERVICE_HATCH_OPENED:
			return "Runoff Outlet Service Hatch Open"
		FACTORY_OBJECTIVE_CROSS_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_RUNOFF_OUTLET_SERVICE_SLUICE:
			return "Cross Runoff Outlet Service Sluice"
		FACTORY_OBJECTIVE_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_RUNOFF_OUTLET_SERVICE_SLUICE_CROSSED:
			return "Runoff Outlet Service Sluice Crossed"
		FACTORY_OBJECTIVE_CLEAR_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_RUNOFF_OUTLET_SERVICE_SLUICE_SKIRMISH:
			return "Clear Service Sluice Spark Rat"
		FACTORY_OBJECTIVE_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_RUNOFF_OUTLET_SERVICE_SLUICE_SKIRMISH_CLEARED:
			return "Service Sluice Spark Rat Cleared"
		FACTORY_OBJECTIVE_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_OUTLET_CROSSED:
			return "Aftershock Condenser Outlet Crossed"
		_:
			return "Clear Factory Entrance"


func _get_cache_reward_payload() -> Dictionary:
	if _cache == null or not _cache.has_method("get_reward_payload"):
		return {}
	var reward_variant: Variant = _cache.call("get_reward_payload")
	if reward_variant is Dictionary:
		return (reward_variant as Dictionary).duplicate(true)
	return {}


func _get_return_patrol_reward_cache_payload() -> Dictionary:
	if (
		_return_patrol_reward_cache == null
		or not _return_patrol_reward_cache.has_method("get_reward_payload")
	):
		return {}
	var reward_variant: Variant = _return_patrol_reward_cache.call("get_reward_payload")
	if reward_variant is Dictionary:
		return (reward_variant as Dictionary).duplicate(true)
	return {}


func _get_checkpoint_overdrive_reward_cache_payload() -> Dictionary:
	if (
		_checkpoint_overdrive_reward_cache == null
		or not _checkpoint_overdrive_reward_cache.has_method("get_reward_payload")
	):
		return {}
	var reward_variant: Variant = _checkpoint_overdrive_reward_cache.call("get_reward_payload")
	if reward_variant is Dictionary:
		return (reward_variant as Dictionary).duplicate(true)
	return {}


func _get_lower_deck_reward_cache_payload() -> Dictionary:
	if (
		_lower_deck_reward_cache == null
		or not _lower_deck_reward_cache.has_method("get_reward_payload")
	):
		return {}
	var reward_variant: Variant = _lower_deck_reward_cache.call("get_reward_payload")
	if reward_variant is Dictionary:
		return (reward_variant as Dictionary).duplicate(true)
	return {}


func _get_lower_deck_shortcut_reward_cache_payload() -> Dictionary:
	if (
		_lower_deck_shortcut_reward_cache == null
		or not _lower_deck_shortcut_reward_cache.has_method("get_reward_payload")
	):
		return {}
	var reward_variant: Variant = _lower_deck_shortcut_reward_cache.call("get_reward_payload")
	if reward_variant is Dictionary:
		return (reward_variant as Dictionary).duplicate(true)
	return {}


func _get_lower_deck_relay_forward_reward_cache_payload() -> Dictionary:
	if (
		_lower_deck_relay_forward_reward_cache == null
		or not _lower_deck_relay_forward_reward_cache.has_method("get_reward_payload")
	):
		return {}
	var reward_variant: Variant = _lower_deck_relay_forward_reward_cache.call(
		"get_reward_payload"
	)
	if reward_variant is Dictionary:
		return (reward_variant as Dictionary).duplicate(true)
	return {}


func _get_lower_deck_forward_pressure_reward_cache_payload() -> Dictionary:
	if (
		_lower_deck_forward_pressure_reward_cache == null
		or not _lower_deck_forward_pressure_reward_cache.has_method("get_reward_payload")
	):
		return {}
	var reward_variant: Variant = _lower_deck_forward_pressure_reward_cache.call(
		"get_reward_payload"
	)
	if reward_variant is Dictionary:
		return (reward_variant as Dictionary).duplicate(true)
	return {}


func _get_lower_deck_forward_pressure_aftershock_reward_cache_payload() -> Dictionary:
	if (
		_lower_deck_forward_pressure_aftershock_reward_cache == null
		or not _lower_deck_forward_pressure_aftershock_reward_cache.has_method(
			"get_reward_payload"
		)
	):
		return {}
	var reward_variant: Variant = _lower_deck_forward_pressure_aftershock_reward_cache.call(
		"get_reward_payload"
	)
	if reward_variant is Dictionary:
		return (reward_variant as Dictionary).duplicate(true)
	return {}


func _get_lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache_payload(
) -> Dictionary:
	var cache: Node = _lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache
	if cache == null or not cache.has_method("get_reward_payload"):
		return {}
	var reward_variant: Variant = cache.call("get_reward_payload")
	if reward_variant is Dictionary:
		return (reward_variant as Dictionary).duplicate(true)
	return {}


func _get_overflow_pump_reward_cache_payload() -> Dictionary:
	var cache: Node = (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_reward_cache
	)
	if cache == null or not cache.has_method("get_reward_payload"):
		return {}
	var reward_variant: Variant = cache.call("get_reward_payload")
	if reward_variant is Dictionary:
		return (reward_variant as Dictionary).duplicate(true)
	return {}


func _get_overflow_pump_runoff_exit_reward_cache_payload() -> Dictionary:
	var cache: Node = (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_reward_cache
	)
	if cache == null or not cache.has_method("get_reward_payload"):
		return {}
	var reward_variant: Variant = cache.call("get_reward_payload")
	if reward_variant is Dictionary:
		return (reward_variant as Dictionary).duplicate(true)
	return {}


func _get_overflow_pump_runoff_outlet_reward_cache_payload() -> Dictionary:
	var cache: Node = (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_reward_cache
	)
	if cache == null or not cache.has_method("get_reward_payload"):
		return {}
	var reward_variant: Variant = cache.call("get_reward_payload")
	if reward_variant is Dictionary:
		return (reward_variant as Dictionary).duplicate(true)
	return {}


func _record_cache_claim_feedback(reward: Dictionary, label_prefix: String) -> void:
	_last_cache_claim_feedback = _build_cache_claim_feedback(reward, label_prefix)
	_update_route_label(String(_last_cache_claim_feedback.get("text", "")))


func _record_return_patrol_reward_cache_claim_feedback(
	reward: Dictionary,
	label_prefix: String
) -> void:
	_last_return_patrol_reward_cache_claim_feedback = _build_cache_claim_feedback(
		reward,
		label_prefix
	)
	_update_route_label(String(
		_last_return_patrol_reward_cache_claim_feedback.get("text", "")
	))


func _record_checkpoint_overdrive_reward_cache_claim_feedback(
	reward: Dictionary,
	label_prefix: String
) -> void:
	_last_checkpoint_overdrive_reward_cache_claim_feedback = _build_cache_claim_feedback(
		reward,
		label_prefix
	)
	_update_route_label(String(
		_last_checkpoint_overdrive_reward_cache_claim_feedback.get("text", "")
	))


func _record_lower_deck_reward_cache_claim_feedback(
	reward: Dictionary,
	label_prefix: String
) -> void:
	_last_lower_deck_reward_cache_claim_feedback = _build_cache_claim_feedback(
		reward,
		label_prefix
	)
	_update_route_label(String(
		_last_lower_deck_reward_cache_claim_feedback.get("text", "")
	))


func _record_lower_deck_shortcut_reward_cache_claim_feedback(
	reward: Dictionary,
	label_prefix: String
) -> void:
	_last_lower_deck_shortcut_reward_cache_claim_feedback = _build_cache_claim_feedback(
		reward,
		label_prefix
	)
	_update_route_label(String(
		_last_lower_deck_shortcut_reward_cache_claim_feedback.get("text", "")
	))


func _record_lower_deck_relay_forward_reward_cache_claim_feedback(
	reward: Dictionary,
	label_prefix: String
) -> void:
	_last_lower_deck_relay_forward_reward_cache_claim_feedback = _build_cache_claim_feedback(
		reward,
		label_prefix
	)
	_update_route_label(String(
		_last_lower_deck_relay_forward_reward_cache_claim_feedback.get("text", "")
	))


func _record_lower_deck_forward_pressure_reward_cache_claim_feedback(
	reward: Dictionary,
	label_prefix: String
) -> void:
	_last_lower_deck_forward_pressure_reward_cache_claim_feedback = (
		_build_cache_claim_feedback(reward, label_prefix)
	)
	_update_route_label(String(
		_last_lower_deck_forward_pressure_reward_cache_claim_feedback.get("text", "")
	))


func _record_lower_deck_forward_pressure_aftershock_reward_cache_claim_feedback(
	reward: Dictionary,
	label_prefix: String
) -> void:
	_last_lower_deck_forward_pressure_aftershock_reward_cache_claim_feedback = (
		_build_cache_claim_feedback(reward, label_prefix)
	)
	_update_route_label(String(
		_last_lower_deck_forward_pressure_aftershock_reward_cache_claim_feedback.get(
			"text",
			""
		)
	))


func _record_lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache_claim_feedback(
	reward: Dictionary,
	label_prefix: String
) -> void:
	_last_lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache_claim_feedback = (
		_build_cache_claim_feedback(reward, label_prefix)
	)
	_update_route_label(String(
		_last_lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache_claim_feedback
		.get(
			"text",
			""
		)
	))


func _record_overflow_pump_reward_cache_claim_feedback(
	reward: Dictionary,
	label_prefix: String
) -> void:
	_last_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_reward_cache_claim_feedback = (
		_build_cache_claim_feedback(reward, label_prefix)
	)
	_update_route_label(String(
		_last_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_reward_cache_claim_feedback
		.get(
			"text",
			""
		)
	))


func _record_overflow_pump_runoff_exit_reward_cache_claim_feedback(
	reward: Dictionary,
	label_prefix: String
) -> void:
	_last_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_reward_cache_claim_feedback = (
		_build_cache_claim_feedback(reward, label_prefix)
	)
	_update_route_label(String(
		_last_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_reward_cache_claim_feedback
		.get(
			"text",
			""
		)
	))


func _record_overflow_pump_runoff_outlet_reward_cache_claim_feedback(
	reward: Dictionary,
	label_prefix: String
) -> void:
	_last_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_reward_cache_claim_feedback = (
		_build_cache_claim_feedback(reward, label_prefix)
	)
	_update_route_label(String(
		_last_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_reward_cache_claim_feedback
		.get(
			"text",
			""
		)
	))


func _build_cache_claim_feedback(reward: Dictionary, label_prefix: String) -> Dictionary:
	var gears: int = int(reward.get("gears", 0))
	var text: String = "%s +%d Gears" % [label_prefix, gears]
	return {
		"cache_id": String(reward.get("cache_id", "")),
		"gears": gears,
		"source": String(reward.get("source", "")),
		"text": text,
	}


func _get_return_patrol_reward_cache_prompt_text() -> String:
	var prompt_label := (
		_return_patrol_reward_cache.get_node_or_null("PromptLabel") as Label
		if _return_patrol_reward_cache != null
		else null
	)
	return prompt_label.text if prompt_label != null else ""


func _get_checkpoint_overdrive_reward_cache_prompt_text() -> String:
	var prompt_label := (
		_checkpoint_overdrive_reward_cache.get_node_or_null("PromptLabel") as Label
		if _checkpoint_overdrive_reward_cache != null
		else null
	)
	return prompt_label.text if prompt_label != null else ""


func _get_lower_deck_reward_cache_prompt_text() -> String:
	var prompt_label := (
		_lower_deck_reward_cache.get_node_or_null("PromptLabel") as Label
		if _lower_deck_reward_cache != null
		else null
	)
	return prompt_label.text if prompt_label != null else ""


func _get_lower_deck_shortcut_reward_cache_prompt_text() -> String:
	var prompt_label := (
		_lower_deck_shortcut_reward_cache.get_node_or_null("PromptLabel") as Label
		if _lower_deck_shortcut_reward_cache != null
		else null
	)
	return prompt_label.text if prompt_label != null else ""


func _get_lower_deck_relay_forward_reward_cache_prompt_text() -> String:
	var prompt_label := (
		_lower_deck_relay_forward_reward_cache.get_node_or_null("PromptLabel") as Label
		if _lower_deck_relay_forward_reward_cache != null
		else null
	)
	return prompt_label.text if prompt_label != null else ""


func _get_lower_deck_parry_gate_id() -> String:
	if _lower_deck_parry_gate != null and _lower_deck_parry_gate.has_method("get_gate_id"):
		return String(_lower_deck_parry_gate.call("get_gate_id"))
	return String(FACTORY_LOWER_DECK_PARRY_GATE_ID)


func _get_lower_deck_parry_gate_required_ability() -> String:
	if (
		_lower_deck_parry_gate != null
		and _lower_deck_parry_gate.has_method("get_required_ability")
	):
		return String(_lower_deck_parry_gate.call("get_required_ability"))
	return "parry"


func _get_lower_deck_parry_gate_state() -> String:
	if _lower_deck_parry_gate != null and _lower_deck_parry_gate.has_method("get_gate_state"):
		return String(_lower_deck_parry_gate.call("get_gate_state"))
	return "unlocked" if _lower_deck_parry_gate_unlocked else "locked"


func _is_lower_deck_parry_gate_collision_blocking() -> bool:
	if (
		_lower_deck_parry_gate != null
		and _lower_deck_parry_gate.has_method("is_collision_blocking")
	):
		return bool(_lower_deck_parry_gate.call("is_collision_blocking"))
	var collision_shape := _get_lower_deck_parry_gate_collision_shape()
	return collision_shape != null and not collision_shape.disabled


func _get_lower_deck_parry_gate_visual_texture_path() -> String:
	var visual := (
		_lower_deck_parry_gate.get_node_or_null("Visual") as Sprite2D
		if _lower_deck_parry_gate != null
		else null
	)
	if visual == null or visual.texture == null:
		return ""
	return visual.texture.resource_path


func _get_lower_deck_parry_gate_prompt_text() -> String:
	var prompt_label := (
		_lower_deck_parry_gate.get_node_or_null("PromptLabel") as Label
		if _lower_deck_parry_gate != null
		else null
	)
	return prompt_label.text if prompt_label != null else ""


func _get_lower_deck_parry_gate_collision_shape() -> CollisionShape2D:
	return (
		_lower_deck_parry_gate.find_child("CollisionShape2D", true, false) as CollisionShape2D
		if _lower_deck_parry_gate != null
		else null
	)


func _set_lower_deck_parry_gate_collision_enabled(enabled: bool) -> void:
	var collision_shape := _get_lower_deck_parry_gate_collision_shape()
	if collision_shape != null:
		collision_shape.disabled = not enabled


func _get_lower_deck_shortcut_seal_id() -> String:
	if (
		_lower_deck_shortcut_seal != null
		and _lower_deck_shortcut_seal.has_method("get_endpoint_id")
	):
		return String(_lower_deck_shortcut_seal.call("get_endpoint_id"))
	return String(FACTORY_LOWER_DECK_SHORTCUT_SEAL_ID)


func _get_lower_deck_shortcut_visual_texture_path() -> String:
	if (
		_lower_deck_shortcut_seal != null
		and _lower_deck_shortcut_seal.has_method("get_visual_texture_path")
	):
		return String(_lower_deck_shortcut_seal.call("get_visual_texture_path"))
	var visual := (
		_lower_deck_shortcut_seal.get_node_or_null("Visual") as Sprite2D
		if _lower_deck_shortcut_seal != null
		else null
	)
	if visual == null or visual.texture == null:
		return ""
	return visual.texture.resource_path


func _get_lower_deck_shortcut_prompt_text() -> String:
	var prompt_label := (
		_lower_deck_shortcut_seal.get_node_or_null("PromptLabel") as Label
		if _lower_deck_shortcut_seal != null
		else null
	)
	return prompt_label.text if prompt_label != null else ""


func _get_lower_deck_shortcut_position() -> Vector2:
	return (
		(_lower_deck_shortcut_seal as Node2D).global_position
		if _lower_deck_shortcut_seal != null and _lower_deck_shortcut_seal is Node2D
		else Vector2.ZERO
	)


func _get_lower_deck_pressure_valve_id() -> String:
	if (
		_lower_deck_pressure_valve != null
		and _lower_deck_pressure_valve.has_method("get_endpoint_id")
	):
		return String(_lower_deck_pressure_valve.call("get_endpoint_id"))
	return String(FACTORY_LOWER_DECK_PRESSURE_VALVE_ID)


func _get_lower_deck_pressure_valve_visual_texture_path() -> String:
	if (
		_lower_deck_pressure_valve != null
		and _lower_deck_pressure_valve.has_method("get_visual_texture_path")
	):
		return String(_lower_deck_pressure_valve.call("get_visual_texture_path"))
	var visual := (
		_lower_deck_pressure_valve.get_node_or_null("Visual") as Sprite2D
		if _lower_deck_pressure_valve != null
		else null
	)
	if visual == null or visual.texture == null:
		return ""
	return visual.texture.resource_path


func _get_lower_deck_pressure_valve_prompt_text() -> String:
	var prompt_label := (
		_lower_deck_pressure_valve.get_node_or_null("PromptLabel") as Label
		if _lower_deck_pressure_valve != null
		else null
	)
	return prompt_label.text if prompt_label != null else ""


func _get_lower_deck_pressure_valve_position() -> Vector2:
	return (
		(_lower_deck_pressure_valve as Node2D).global_position
		if _lower_deck_pressure_valve != null and _lower_deck_pressure_valve is Node2D
		else Vector2.ZERO
	)


func _get_lower_deck_deep_bulkhead_id() -> String:
	if (
		_lower_deck_deep_bulkhead != null
		and _lower_deck_deep_bulkhead.has_method("get_endpoint_id")
	):
		return String(_lower_deck_deep_bulkhead.call("get_endpoint_id"))
	return String(FACTORY_LOWER_DECK_DEEP_BULKHEAD_ID)


func _get_lower_deck_deep_bulkhead_visual_texture_path() -> String:
	if (
		_lower_deck_deep_bulkhead != null
		and _lower_deck_deep_bulkhead.has_method("get_visual_texture_path")
	):
		return String(_lower_deck_deep_bulkhead.call("get_visual_texture_path"))
	var visual := (
		_lower_deck_deep_bulkhead.get_node_or_null("Visual") as Sprite2D
		if _lower_deck_deep_bulkhead != null
		else null
	)
	if visual == null or visual.texture == null:
		return ""
	return visual.texture.resource_path


func _get_lower_deck_deep_bulkhead_prompt_text() -> String:
	var prompt_label := (
		_lower_deck_deep_bulkhead.get_node_or_null("PromptLabel") as Label
		if _lower_deck_deep_bulkhead != null
		else null
	)
	return prompt_label.text if prompt_label != null else ""


func _get_lower_deck_deep_bulkhead_position() -> Vector2:
	return (
		(_lower_deck_deep_bulkhead as Node2D).global_position
		if _lower_deck_deep_bulkhead != null and _lower_deck_deep_bulkhead is Node2D
		else Vector2.ZERO
	)


func _get_lower_deck_forward_hatch_id() -> String:
	if (
		_lower_deck_forward_hatch != null
		and _lower_deck_forward_hatch.has_method("get_endpoint_id")
	):
		return String(_lower_deck_forward_hatch.call("get_endpoint_id"))
	return String(FACTORY_LOWER_DECK_FORWARD_HATCH_ID)


func _get_lower_deck_forward_hatch_visual_texture_path() -> String:
	if (
		_lower_deck_forward_hatch != null
		and _lower_deck_forward_hatch.has_method("get_visual_texture_path")
	):
		return String(_lower_deck_forward_hatch.call("get_visual_texture_path"))
	var visual := (
		_lower_deck_forward_hatch.get_node_or_null("Visual") as Sprite2D
		if _lower_deck_forward_hatch != null
		else null
	)
	if visual == null or visual.texture == null:
		return ""
	return visual.texture.resource_path


func _get_lower_deck_forward_hatch_prompt_text() -> String:
	var prompt_label := (
		_lower_deck_forward_hatch.get_node_or_null("PromptLabel") as Label
		if _lower_deck_forward_hatch != null
		else null
	)
	return prompt_label.text if prompt_label != null else ""


func _get_lower_deck_forward_pressure_reward_cache_prompt_text() -> String:
	var prompt_label := (
		_lower_deck_forward_pressure_reward_cache.get_node_or_null("PromptLabel") as Label
		if _lower_deck_forward_pressure_reward_cache != null
		else null
	)
	return prompt_label.text if prompt_label != null else ""


func _get_lower_deck_forward_pressure_aftershock_reward_cache_prompt_text() -> String:
	var prompt_label: Label = (
		_lower_deck_forward_pressure_aftershock_reward_cache.get_node_or_null(
			"PromptLabel"
		) as Label
		if _lower_deck_forward_pressure_aftershock_reward_cache != null
		else null
	)
	return prompt_label.text if prompt_label != null else ""


func _get_lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache_prompt_text(
) -> String:
	var cache: Node = _lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache
	var prompt_label: Label = (
		cache.get_node_or_null("PromptLabel") as Label
		if cache != null
		else null
	)
	return prompt_label.text if prompt_label != null else ""


func _get_overflow_pump_reward_cache_prompt_text() -> String:
	var cache: Node = (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_reward_cache
	)
	var prompt_label: Label = (
		cache.get_node_or_null("PromptLabel") as Label
		if cache != null
		else null
	)
	return prompt_label.text if prompt_label != null else ""


func _get_overflow_pump_reward_cache_texture_path() -> String:
	var cache: Node = (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_reward_cache
	)
	if cache != null and cache.has_method("get_visual_texture_path"):
		return String(cache.call("get_visual_texture_path"))
	return ""


func _get_overflow_pump_reward_cache_position() -> Vector2:
	return (
		(
			_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_reward_cache
			as Node2D
		).global_position
		if (
			_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_reward_cache
			!= null
			and _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_reward_cache
			is Node2D
		)
		else Vector2.ZERO
	)


func _get_overflow_pump_runoff_exit_reward_cache_prompt_text() -> String:
	var cache: Node = (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_reward_cache
	)
	var prompt_label: Label = (
		cache.get_node_or_null("PromptLabel") as Label
		if cache != null
		else null
	)
	return prompt_label.text if prompt_label != null else ""


func _get_overflow_pump_runoff_exit_reward_cache_texture_path() -> String:
	var cache: Node = (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_reward_cache
	)
	if cache != null and cache.has_method("get_visual_texture_path"):
		return String(cache.call("get_visual_texture_path"))
	return ""


func _get_overflow_pump_runoff_exit_reward_cache_position() -> Vector2:
	return (
		(
			_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_reward_cache
			as Node2D
		).global_position
		if (
			_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_reward_cache
			!= null
			and _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_reward_cache
			is Node2D
		)
		else Vector2.ZERO
	)


func _get_lower_deck_forward_hatch_position() -> Vector2:
	return (
		(_lower_deck_forward_hatch as Node2D).global_position
		if _lower_deck_forward_hatch != null and _lower_deck_forward_hatch is Node2D
		else Vector2.ZERO
	)


func _get_lower_deck_forward_pressure_exit_gate_id() -> String:
	if (
		_lower_deck_forward_pressure_exit_gate != null
		and _lower_deck_forward_pressure_exit_gate.has_method("get_endpoint_id")
	):
		return String(_lower_deck_forward_pressure_exit_gate.call("get_endpoint_id"))
	return String(FACTORY_LOWER_DECK_FORWARD_PRESSURE_EXIT_GATE_ID)


func _get_lower_deck_forward_pressure_exit_gate_texture_path() -> String:
	if (
		_lower_deck_forward_pressure_exit_gate != null
		and _lower_deck_forward_pressure_exit_gate.has_method("get_visual_texture_path")
	):
		return String(_lower_deck_forward_pressure_exit_gate.call("get_visual_texture_path"))
	var visual := (
		_lower_deck_forward_pressure_exit_gate.get_node_or_null("Visual") as Sprite2D
		if _lower_deck_forward_pressure_exit_gate != null
		else null
	)
	if visual == null or visual.texture == null:
		return ""
	return visual.texture.resource_path


func _get_lower_deck_forward_pressure_exit_gate_prompt_text() -> String:
	var prompt_label := (
		_lower_deck_forward_pressure_exit_gate.get_node_or_null("PromptLabel") as Label
		if _lower_deck_forward_pressure_exit_gate != null
		else null
	)
	return prompt_label.text if prompt_label != null else ""


func _get_lower_deck_forward_pressure_exit_gate_position() -> Vector2:
	return (
		(_lower_deck_forward_pressure_exit_gate as Node2D).global_position
		if (
			_lower_deck_forward_pressure_exit_gate != null
			and _lower_deck_forward_pressure_exit_gate is Node2D
		)
		else Vector2.ZERO
	)


func _get_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch_id() -> String:
	if (
		_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch != null
		and _lower_deck_forward_pressure_aftershock_exhaust_exit_hatch.has_method(
			"get_endpoint_id"
		)
	):
		return String(_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch.call(
			"get_endpoint_id"
		))
	return String(FACTORY_LOWER_DECK_FORWARD_PRESSURE_AFTERSHOCK_EXHAUST_EXIT_HATCH_ID)


func _get_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch_texture_path(
) -> String:
	if (
		_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch != null
		and _lower_deck_forward_pressure_aftershock_exhaust_exit_hatch.has_method(
			"get_visual_texture_path"
		)
	):
		return String(_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch.call(
			"get_visual_texture_path"
		))
	var visual := (
		_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch.get_node_or_null(
			"Visual"
		) as Sprite2D
		if _lower_deck_forward_pressure_aftershock_exhaust_exit_hatch != null
		else null
	)
	if visual == null or visual.texture == null:
		return ""
	return visual.texture.resource_path


func _get_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch_prompt_text(
) -> String:
	var prompt_label := (
		_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch.get_node_or_null(
			"PromptLabel"
		) as Label
		if _lower_deck_forward_pressure_aftershock_exhaust_exit_hatch != null
		else null
	)
	return prompt_label.text if prompt_label != null else ""


func _get_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch_position(
) -> Vector2:
	return (
		(_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch as Node2D).global_position
		if (
			_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch != null
			and _lower_deck_forward_pressure_aftershock_exhaust_exit_hatch is Node2D
		)
		else Vector2.ZERO
	)


func _get_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch_unlock_vfx_snapshot(
) -> Dictionary:
	if (
		_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch == null
		or not _lower_deck_forward_pressure_aftershock_exhaust_exit_hatch.has_method(
			"get_unlock_vfx_snapshot"
		)
	):
		return {}
	var snapshot_variant: Variant = (
		_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch.call(
			"get_unlock_vfx_snapshot"
		)
	)
	if snapshot_variant is Dictionary:
		return (snapshot_variant as Dictionary).duplicate(true)
	return {}


func _get_overflow_pump_exit_hatch_id() -> String:
	if (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_exit_hatch != null
		and _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_exit_hatch.has_method(
			"get_endpoint_id"
		)
	):
		return String(
			_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_exit_hatch.call(
				"get_endpoint_id"
			)
		)
	return String(
		FACTORY_LOWER_DECK_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_EXIT_HATCH_ID
	)


func _get_overflow_pump_exit_hatch_texture_path() -> String:
	var hatch: Node = (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_exit_hatch
	)
	if hatch != null and hatch.has_method("get_visual_texture_path"):
		return String(hatch.call("get_visual_texture_path"))
	var visual: Sprite2D = (
		hatch.get_node_or_null("Visual") as Sprite2D
		if hatch != null
		else null
	)
	if visual == null or visual.texture == null:
		return ""
	return visual.texture.resource_path


func _get_overflow_pump_exit_hatch_prompt_text() -> String:
	var hatch: Node = (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_exit_hatch
	)
	var prompt_label: Label = (
		hatch.get_node_or_null("PromptLabel") as Label
		if hatch != null
		else null
	)
	return prompt_label.text if prompt_label != null else ""


func _get_overflow_pump_exit_hatch_position() -> Vector2:
	return (
		(
			_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_exit_hatch
			as Node2D
		).global_position
		if (
			_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_exit_hatch
			!= null
			and _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_exit_hatch
			is Node2D
		)
		else Vector2.ZERO
	)


func _get_overflow_pump_runoff_outlet_reward_cache_prompt_text() -> String:
	var cache: Node = (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_reward_cache
	)
	var prompt_label: Label = (
		cache.get_node_or_null("PromptLabel") as Label
		if cache != null
		else null
	)
	return prompt_label.text if prompt_label != null else ""


func _get_overflow_pump_runoff_outlet_reward_cache_texture_path() -> String:
	var cache: Node = (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_reward_cache
	)
	if cache != null and cache.has_method("get_visual_texture_path"):
		return String(cache.call("get_visual_texture_path"))
	return ""


func _get_overflow_pump_runoff_outlet_reward_cache_position() -> Vector2:
	return (
		(
			_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_reward_cache
			as Node2D
		).global_position
		if (
			_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_reward_cache
			!= null
			and _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_reward_cache
			is Node2D
		)
		else Vector2.ZERO
	)


func _get_overflow_pump_runoff_exit_gate_id() -> String:
	if (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_gate != null
		and _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_gate.has_method(
			"get_endpoint_id"
		)
	):
		return String(
			_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_gate.call(
				"get_endpoint_id"
			)
		)
	return String(
		FACTORY_LOWER_DECK_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_RUNOFF_EXIT_GATE_ID
	)


func _get_overflow_pump_runoff_exit_gate_texture_path() -> String:
	var gate: Node = (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_gate
	)
	if gate != null and gate.has_method("get_visual_texture_path"):
		return String(gate.call("get_visual_texture_path"))
	var visual: Sprite2D = (
		gate.get_node_or_null("Visual") as Sprite2D
		if gate != null
		else null
	)
	if visual == null or visual.texture == null:
		return ""
	return visual.texture.resource_path


func _get_overflow_pump_runoff_exit_gate_prompt_text() -> String:
	var gate: Node = (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_gate
	)
	var prompt_label: Label = (
		gate.get_node_or_null("PromptLabel") as Label
		if gate != null
		else null
	)
	return prompt_label.text if prompt_label != null else ""


func _get_overflow_pump_runoff_exit_gate_position() -> Vector2:
	return (
		(
			_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_gate
			as Node2D
		).global_position
		if (
			_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_gate
			!= null
			and _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_gate
			is Node2D
		)
		else Vector2.ZERO
	)


func _get_overflow_pump_runoff_outlet_service_hatch_id() -> String:
	if (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_hatch != null
		and _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_hatch.has_method(
			"get_endpoint_id"
		)
	):
		return String(
			_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_hatch.call(
				"get_endpoint_id"
			)
		)
	return String(
		FACTORY_LOWER_DECK_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_RUNOFF_OUTLET_SERVICE_HATCH_ID
	)


func _get_overflow_pump_runoff_outlet_service_hatch_texture_path() -> String:
	var hatch: Node = (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_hatch
	)
	if hatch != null and hatch.has_method("get_visual_texture_path"):
		return String(hatch.call("get_visual_texture_path"))
	var visual: Sprite2D = (
		hatch.get_node_or_null("Visual") as Sprite2D
		if hatch != null
		else null
	)
	if visual == null or visual.texture == null:
		return ""
	return visual.texture.resource_path


func _get_overflow_pump_runoff_outlet_service_hatch_prompt_text() -> String:
	var hatch: Node = (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_hatch
	)
	var prompt_label: Label = (
		hatch.get_node_or_null("PromptLabel") as Label
		if hatch != null
		else null
	)
	return prompt_label.text if prompt_label != null else ""


func _get_overflow_pump_runoff_outlet_service_hatch_position() -> Vector2:
	return (
		(
			_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_hatch
			as Node2D
		).global_position
		if (
			_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_hatch
			!= null
			and _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_hatch
			is Node2D
		)
		else Vector2.ZERO
	)


func _get_lower_deck_forward_pressure_route_handoff_marker_id() -> String:
	if (
		_lower_deck_forward_pressure_route_handoff_marker != null
		and _lower_deck_forward_pressure_route_handoff_marker.has_method("get_endpoint_id")
	):
		return String(_lower_deck_forward_pressure_route_handoff_marker.call(
			"get_endpoint_id"
		))
	return String(FACTORY_LOWER_DECK_FORWARD_PRESSURE_ROUTE_HANDOFF_MARKER_ID)


func _get_lower_deck_forward_pressure_route_handoff_marker_texture_path() -> String:
	if (
		_lower_deck_forward_pressure_route_handoff_marker != null
		and _lower_deck_forward_pressure_route_handoff_marker.has_method(
			"get_visual_texture_path"
		)
	):
		return String(_lower_deck_forward_pressure_route_handoff_marker.call(
			"get_visual_texture_path"
		))
	var visual := (
		_lower_deck_forward_pressure_route_handoff_marker.get_node_or_null("Visual")
		as Sprite2D
		if _lower_deck_forward_pressure_route_handoff_marker != null
		else null
	)
	if visual == null or visual.texture == null:
		return ""
	return visual.texture.resource_path


func _get_lower_deck_forward_pressure_route_handoff_marker_prompt_text() -> String:
	var prompt_label := (
		_lower_deck_forward_pressure_route_handoff_marker.get_node_or_null(
			"PromptLabel"
		) as Label
		if _lower_deck_forward_pressure_route_handoff_marker != null
		else null
	)
	return prompt_label.text if prompt_label != null else ""


func _get_lower_deck_forward_pressure_route_handoff_marker_position() -> Vector2:
	return (
		(_lower_deck_forward_pressure_route_handoff_marker as Node2D).global_position
		if (
			_lower_deck_forward_pressure_route_handoff_marker != null
			and _lower_deck_forward_pressure_route_handoff_marker is Node2D
		)
		else Vector2.ZERO
	)


func _get_lower_deck_forward_pressure_route_handoff_marker_unlock_vfx_snapshot(
) -> Dictionary:
	if (
		_lower_deck_forward_pressure_route_handoff_marker == null
		or not _lower_deck_forward_pressure_route_handoff_marker.has_method(
			"get_unlock_vfx_snapshot"
		)
	):
		return {}
	var snapshot_variant: Variant = _lower_deck_forward_pressure_route_handoff_marker.call(
		"get_unlock_vfx_snapshot"
	)
	if snapshot_variant is Dictionary:
		return (snapshot_variant as Dictionary).duplicate(true)
	return {}


func _get_lower_deck_forward_pressure_breaker_id() -> String:
	if (
		_lower_deck_forward_pressure_breaker != null
		and _lower_deck_forward_pressure_breaker.has_method("get_endpoint_id")
	):
		return String(_lower_deck_forward_pressure_breaker.call("get_endpoint_id"))
	return String(FACTORY_LOWER_DECK_FORWARD_PRESSURE_BREAKER_ID)


func _get_lower_deck_forward_pressure_breaker_texture_path() -> String:
	if (
		_lower_deck_forward_pressure_breaker != null
		and _lower_deck_forward_pressure_breaker.has_method("get_visual_texture_path")
	):
		return String(_lower_deck_forward_pressure_breaker.call(
			"get_visual_texture_path"
		))
	var visual := (
		_lower_deck_forward_pressure_breaker.get_node_or_null("Visual")
		as Sprite2D
		if _lower_deck_forward_pressure_breaker != null
		else null
	)
	if visual == null or visual.texture == null:
		return ""
	return visual.texture.resource_path


func _get_lower_deck_forward_pressure_breaker_prompt_text() -> String:
	var prompt_label := (
		_lower_deck_forward_pressure_breaker.get_node_or_null("PromptLabel") as Label
		if _lower_deck_forward_pressure_breaker != null
		else null
	)
	return prompt_label.text if prompt_label != null else ""


func _get_lower_deck_forward_pressure_breaker_position() -> Vector2:
	return (
		(_lower_deck_forward_pressure_breaker as Node2D).global_position
		if (
			_lower_deck_forward_pressure_breaker != null
			and _lower_deck_forward_pressure_breaker is Node2D
		)
		else Vector2.ZERO
	)


func _get_lower_deck_forward_pressure_breaker_unlock_vfx_snapshot() -> Dictionary:
	if (
		_lower_deck_forward_pressure_breaker == null
		or not _lower_deck_forward_pressure_breaker.has_method(
			"get_unlock_vfx_snapshot"
		)
	):
		return {}
	var snapshot_variant: Variant = _lower_deck_forward_pressure_breaker.call(
		"get_unlock_vfx_snapshot"
	)
	if snapshot_variant is Dictionary:
		return (snapshot_variant as Dictionary).duplicate(true)
	return {}


func _get_post_bulkhead_background_texture_path() -> String:
	return (
		_post_bulkhead_background.texture.resource_path
		if (
			_post_bulkhead_background != null
			and _post_bulkhead_background.texture != null
		)
		else ""
	)


func _is_lower_deck_deep_bulkhead_collision_blocking() -> bool:
	var collision_shape := _get_lower_deck_deep_bulkhead_collision_shape()
	return collision_shape != null and not collision_shape.disabled


func _set_lower_deck_deep_bulkhead_collision_blocking(blocking: bool) -> void:
	var collision_shape := _get_lower_deck_deep_bulkhead_collision_shape()
	if collision_shape != null:
		collision_shape.disabled = not blocking


func _get_lower_deck_deep_bulkhead_collision_shape() -> CollisionShape2D:
	return (
		_lower_deck_deep_bulkhead.get_node_or_null("StaticBody2D/CollisionShape2D")
		as CollisionShape2D
		if _lower_deck_deep_bulkhead != null
		else null
	)


func _is_lower_deck_forward_hatch_collision_blocking() -> bool:
	var collision_shape := _get_lower_deck_forward_hatch_collision_shape()
	return collision_shape != null and not collision_shape.disabled


func _set_lower_deck_forward_hatch_collision_blocking(blocking: bool) -> void:
	var collision_shape := _get_lower_deck_forward_hatch_collision_shape()
	if collision_shape != null:
		collision_shape.disabled = not blocking


func _get_lower_deck_forward_hatch_collision_shape() -> CollisionShape2D:
	return (
		_lower_deck_forward_hatch.get_node_or_null("StaticBody2D/CollisionShape2D")
		as CollisionShape2D
		if _lower_deck_forward_hatch != null
		else null
	)


func _is_lower_deck_forward_pressure_exit_gate_collision_blocking() -> bool:
	var collision_shape := _get_lower_deck_forward_pressure_exit_gate_collision_shape()
	return collision_shape != null and not collision_shape.disabled


func _set_lower_deck_forward_pressure_exit_gate_collision_blocking(blocking: bool) -> void:
	var collision_shape := _get_lower_deck_forward_pressure_exit_gate_collision_shape()
	if collision_shape != null:
		collision_shape.disabled = not blocking


func _get_lower_deck_forward_pressure_exit_gate_collision_shape() -> CollisionShape2D:
	return (
		_lower_deck_forward_pressure_exit_gate.get_node_or_null(
			"StaticBody2D/CollisionShape2D"
		) as CollisionShape2D
		if _lower_deck_forward_pressure_exit_gate != null
		else null
	)


func _is_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch_collision_blocking(
) -> bool:
	var collision_shape := (
		_get_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch_collision_shape()
	)
	return collision_shape != null and not collision_shape.disabled


func _set_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch_collision_blocking(
	blocking: bool
) -> void:
	var collision_shape := (
		_get_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch_collision_shape()
	)
	if collision_shape != null:
		collision_shape.disabled = not blocking


func _get_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch_collision_shape(
) -> CollisionShape2D:
	return (
		_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch.get_node_or_null(
			"StaticBody2D/CollisionShape2D"
		) as CollisionShape2D
		if _lower_deck_forward_pressure_aftershock_exhaust_exit_hatch != null
		else null
	)


func _is_overflow_pump_exit_hatch_collision_blocking() -> bool:
	var collision_shape := _get_overflow_pump_exit_hatch_collision_shape()
	return collision_shape != null and not collision_shape.disabled


func _set_overflow_pump_exit_hatch_collision_blocking(blocking: bool) -> void:
	var collision_shape := _get_overflow_pump_exit_hatch_collision_shape()
	if collision_shape != null:
		collision_shape.disabled = not blocking


func _get_overflow_pump_exit_hatch_collision_shape() -> CollisionShape2D:
	return (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_exit_hatch.get_node_or_null(
			"StaticBody2D/CollisionShape2D"
		) as CollisionShape2D
		if _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_exit_hatch != null
		else null
	)


func _is_overflow_pump_runoff_exit_gate_collision_blocking() -> bool:
	var collision_shape := _get_overflow_pump_runoff_exit_gate_collision_shape()
	return collision_shape != null and not collision_shape.disabled


func _set_overflow_pump_runoff_exit_gate_collision_blocking(blocking: bool) -> void:
	var collision_shape := _get_overflow_pump_runoff_exit_gate_collision_shape()
	if collision_shape != null:
		collision_shape.disabled = not blocking


func _get_overflow_pump_runoff_exit_gate_collision_shape() -> CollisionShape2D:
	return (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_gate.get_node_or_null(
			"StaticBody2D/CollisionShape2D"
		) as CollisionShape2D
		if _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_gate != null
		else null
	)


func _is_overflow_pump_runoff_outlet_service_hatch_collision_blocking() -> bool:
	var collision_shape := _get_overflow_pump_runoff_outlet_service_hatch_collision_shape()
	return collision_shape != null and not collision_shape.disabled


func _set_overflow_pump_runoff_outlet_service_hatch_collision_blocking(
	blocking: bool
) -> void:
	var collision_shape := _get_overflow_pump_runoff_outlet_service_hatch_collision_shape()
	if collision_shape != null:
		collision_shape.disabled = not blocking


func _get_overflow_pump_runoff_outlet_service_hatch_collision_shape() -> CollisionShape2D:
	return (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_hatch.get_node_or_null(
			"StaticBody2D/CollisionShape2D"
		) as CollisionShape2D
		if _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_hatch != null
		else null
	)


func _is_lower_deck_shortcut_collision_blocking() -> bool:
	var collision_shape := _get_lower_deck_shortcut_collision_shape()
	return collision_shape != null and not collision_shape.disabled


func _get_lower_deck_shortcut_collision_shape() -> CollisionShape2D:
	return (
		_lower_deck_shortcut_seal.find_child("CollisionShape2D", true, false) as CollisionShape2D
		if _lower_deck_shortcut_seal != null
		else null
	)


func _set_lower_deck_shortcut_collision_enabled(enabled: bool) -> void:
	var collision_shape := _get_lower_deck_shortcut_collision_shape()
	if collision_shape != null:
		collision_shape.disabled = not enabled


func _show_checkpoint_overdrive_defeat_burst(side: StringName, spark_rat: Node2D) -> void:
	var burst: Sprite2D = null
	match side:
		&"left":
			burst = _checkpoint_overdrive_left_defeat_burst
		&"right":
			burst = _checkpoint_overdrive_right_defeat_burst
		_:
			return
	if burst == null:
		return
	if spark_rat != null:
		burst.global_position = spark_rat.global_position
	burst.visible = true
	_last_checkpoint_overdrive_defeat_burst_side = side


func _show_lower_deck_forward_conduit_clear_feedback() -> void:
	if (
		_lower_deck_forward_conduit_clear_burst == null
		or _lower_deck_forward_conduit_clear_feedback_played
	):
		return
	var feedback_position: Vector2 = (
		_lower_deck_forward_conduit_spark_rat.global_position
		if _lower_deck_forward_conduit_spark_rat != null
		else Vector2.ZERO
	)
	_lower_deck_forward_conduit_clear_burst.global_position = feedback_position
	_lower_deck_forward_conduit_clear_burst.visible = true
	_last_lower_deck_forward_conduit_clear_feedback_position = feedback_position
	_lower_deck_forward_conduit_clear_feedback_played = true
	_lower_deck_forward_conduit_clear_feedback_spawn_count += 1


func _reset_lower_deck_forward_conduit_clear_feedback() -> void:
	_lower_deck_forward_conduit_clear_feedback_played = false
	_lower_deck_forward_conduit_clear_feedback_spawn_count = 0
	_last_lower_deck_forward_conduit_clear_feedback_position = Vector2.ZERO
	if _lower_deck_forward_conduit_clear_burst != null:
		_lower_deck_forward_conduit_clear_burst.visible = false


func _get_lower_deck_forward_conduit_clear_feedback_texture_path() -> String:
	if (
		_lower_deck_forward_conduit_clear_burst == null
		or _lower_deck_forward_conduit_clear_burst.texture == null
	):
		return ""
	return _lower_deck_forward_conduit_clear_burst.texture.resource_path


func _get_checkpoint_overdrive_defeat_burst_texture_path() -> String:
	var burst: Sprite2D = (
		_checkpoint_overdrive_left_defeat_burst
		if _checkpoint_overdrive_left_defeat_burst != null
		else _checkpoint_overdrive_right_defeat_burst
	)
	if burst == null or burst.texture == null:
		return ""
	return burst.texture.resource_path


func _get_return_checkpoint_savepoint_id() -> String:
	if _return_checkpoint != null and _return_checkpoint.has_method("get_savepoint_id"):
		return String(_return_checkpoint.call("get_savepoint_id"))
	return String(FACTORY_RETURN_CHECKPOINT_ID)


func _get_return_checkpoint_scene_id() -> String:
	if _return_checkpoint != null and _return_checkpoint.has_method("get_scene_id"):
		return String(_return_checkpoint.call("get_scene_id"))
	return String(FACTORY_SCENE_ID)


func _get_return_checkpoint_spawn_point() -> String:
	if _return_checkpoint != null and _return_checkpoint.has_method("get_spawn_point"):
		return String(_return_checkpoint.call("get_spawn_point"))
	return String(FACTORY_RETURN_CHECKPOINT_SPAWN_POINT)


func _get_return_checkpoint_display_name() -> String:
	if _return_checkpoint != null and _return_checkpoint.has_method("get_display_name"):
		return String(_return_checkpoint.call("get_display_name"))
	return "Factory Repair Station"


func _get_return_checkpoint_texture_path() -> String:
	if _return_checkpoint != null and _return_checkpoint.has_method("get_visual_texture_path"):
		return String(_return_checkpoint.call("get_visual_texture_path"))
	return ""


func _get_return_checkpoint_prompt_text() -> String:
	var prompt_label := (
		_return_checkpoint.get_node_or_null("PromptLabel") as Label
		if _return_checkpoint != null
		else null
	)
	return prompt_label.text if prompt_label != null else ""


func _get_lower_deck_breach_relay_savepoint_id() -> String:
	if _lower_deck_breach_relay != null and _lower_deck_breach_relay.has_method("get_savepoint_id"):
		return String(_lower_deck_breach_relay.call("get_savepoint_id"))
	return String(FACTORY_LOWER_DECK_BREACH_RELAY_ID)


func _get_lower_deck_breach_relay_scene_id() -> String:
	if _lower_deck_breach_relay != null and _lower_deck_breach_relay.has_method("get_scene_id"):
		return String(_lower_deck_breach_relay.call("get_scene_id"))
	return String(FACTORY_SCENE_ID)


func _get_lower_deck_breach_relay_spawn_point() -> String:
	if _lower_deck_breach_relay != null and _lower_deck_breach_relay.has_method("get_spawn_point"):
		return String(_lower_deck_breach_relay.call("get_spawn_point"))
	return String(FACTORY_LOWER_DECK_BREACH_RELAY_SPAWN_POINT)


func _get_lower_deck_breach_relay_display_name() -> String:
	if _lower_deck_breach_relay != null and _lower_deck_breach_relay.has_method("get_display_name"):
		return String(_lower_deck_breach_relay.call("get_display_name"))
	return "Lower Deck Breach Relay"


func _get_lower_deck_breach_relay_texture_path() -> String:
	if (
		_lower_deck_breach_relay != null
		and _lower_deck_breach_relay.has_method("get_visual_texture_path")
	):
		return String(_lower_deck_breach_relay.call("get_visual_texture_path"))
	return ""


func _get_lower_deck_breach_relay_prompt_text() -> String:
	var prompt_label := (
		_lower_deck_breach_relay.get_node_or_null("PromptLabel") as Label
		if _lower_deck_breach_relay != null
		else null
	)
	return prompt_label.text if prompt_label != null else ""


func _get_lower_deck_forward_pressure_exit_relay_savepoint_id() -> String:
	if (
		_lower_deck_forward_pressure_exit_relay != null
		and _lower_deck_forward_pressure_exit_relay.has_method("get_savepoint_id")
	):
		return String(_lower_deck_forward_pressure_exit_relay.call("get_savepoint_id"))
	return String(FACTORY_LOWER_DECK_FORWARD_PRESSURE_EXIT_RELAY_ID)


func _get_lower_deck_forward_pressure_exit_relay_scene_id() -> String:
	if (
		_lower_deck_forward_pressure_exit_relay != null
		and _lower_deck_forward_pressure_exit_relay.has_method("get_scene_id")
	):
		return String(_lower_deck_forward_pressure_exit_relay.call("get_scene_id"))
	return String(FACTORY_SCENE_ID)


func _get_lower_deck_forward_pressure_exit_relay_spawn_point() -> String:
	if (
		_lower_deck_forward_pressure_exit_relay != null
		and _lower_deck_forward_pressure_exit_relay.has_method("get_spawn_point")
	):
		return String(_lower_deck_forward_pressure_exit_relay.call("get_spawn_point"))
	return String(FACTORY_LOWER_DECK_FORWARD_PRESSURE_EXIT_RELAY_SPAWN_POINT)


func _get_lower_deck_forward_pressure_exit_relay_display_name() -> String:
	if (
		_lower_deck_forward_pressure_exit_relay != null
		and _lower_deck_forward_pressure_exit_relay.has_method("get_display_name")
	):
		return String(_lower_deck_forward_pressure_exit_relay.call("get_display_name"))
	return "Forward Pressure Exit Relay"


func _get_lower_deck_forward_pressure_exit_relay_texture_path() -> String:
	if (
		_lower_deck_forward_pressure_exit_relay != null
		and _lower_deck_forward_pressure_exit_relay.has_method("get_visual_texture_path")
	):
		return String(_lower_deck_forward_pressure_exit_relay.call("get_visual_texture_path"))
	return ""


func _get_lower_deck_forward_pressure_exit_relay_prompt_text() -> String:
	var prompt_label := (
		_lower_deck_forward_pressure_exit_relay.get_node_or_null("PromptLabel") as Label
		if _lower_deck_forward_pressure_exit_relay != null
		else null
	)
	return prompt_label.text if prompt_label != null else ""


func _build_forward_pressure_exit_relay_checkpoint_snapshot() -> Dictionary:
	var world_position := Vector2.ZERO
	if _lower_deck_forward_pressure_exit_relay is Node2D:
		world_position = (_lower_deck_forward_pressure_exit_relay as Node2D).global_position
	return _build_return_checkpoint_snapshot(
		FACTORY_LOWER_DECK_FORWARD_PRESSURE_EXIT_RELAY_ID,
		FACTORY_SCENE_ID,
		FACTORY_LOWER_DECK_FORWARD_PRESSURE_EXIT_RELAY_SPAWN_POINT,
		world_position,
		{
			"display_name": _get_lower_deck_forward_pressure_exit_relay_display_name(),
		}
	)


func _get_lower_deck_forward_pressure_aftershock_condenser_savepoint_id() -> String:
	if (
		_lower_deck_forward_pressure_aftershock_condenser_savepoint != null
		and _lower_deck_forward_pressure_aftershock_condenser_savepoint.has_method(
			"get_savepoint_id"
		)
	):
		return String(_lower_deck_forward_pressure_aftershock_condenser_savepoint.call(
			"get_savepoint_id"
		))
	return String(FACTORY_LOWER_DECK_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_SAVEPOINT_ID)


func _get_lower_deck_forward_pressure_aftershock_condenser_savepoint_scene_id() -> String:
	if (
		_lower_deck_forward_pressure_aftershock_condenser_savepoint != null
		and _lower_deck_forward_pressure_aftershock_condenser_savepoint.has_method(
			"get_scene_id"
		)
	):
		return String(_lower_deck_forward_pressure_aftershock_condenser_savepoint.call(
			"get_scene_id"
		))
	return String(FACTORY_SCENE_ID)


func _get_lower_deck_forward_pressure_aftershock_condenser_savepoint_spawn_point(
) -> String:
	if (
		_lower_deck_forward_pressure_aftershock_condenser_savepoint != null
		and _lower_deck_forward_pressure_aftershock_condenser_savepoint.has_method(
			"get_spawn_point"
		)
	):
		return String(_lower_deck_forward_pressure_aftershock_condenser_savepoint.call(
			"get_spawn_point"
		))
	return String(
		FACTORY_LOWER_DECK_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_SAVEPOINT_SPAWN_POINT
	)


func _get_lower_deck_forward_pressure_aftershock_condenser_savepoint_display_name(
) -> String:
	if (
		_lower_deck_forward_pressure_aftershock_condenser_savepoint != null
		and _lower_deck_forward_pressure_aftershock_condenser_savepoint.has_method(
			"get_display_name"
		)
	):
		return String(_lower_deck_forward_pressure_aftershock_condenser_savepoint.call(
			"get_display_name"
		))
	return "Aftershock Condenser Savepoint"


func _get_lower_deck_forward_pressure_aftershock_condenser_savepoint_texture_path(
) -> String:
	if (
		_lower_deck_forward_pressure_aftershock_condenser_savepoint != null
		and _lower_deck_forward_pressure_aftershock_condenser_savepoint.has_method(
			"get_visual_texture_path"
		)
	):
		return String(_lower_deck_forward_pressure_aftershock_condenser_savepoint.call(
			"get_visual_texture_path"
		))
	return ""


func _get_lower_deck_forward_pressure_aftershock_condenser_savepoint_prompt_text(
) -> String:
	var prompt_label := (
		_lower_deck_forward_pressure_aftershock_condenser_savepoint.get_node_or_null(
			"PromptLabel"
		) as Label
		if _lower_deck_forward_pressure_aftershock_condenser_savepoint != null
		else null
	)
	return prompt_label.text if prompt_label != null else ""


func _build_aftershock_condenser_savepoint_checkpoint_snapshot() -> Dictionary:
	var world_position := Vector2.ZERO
	if _lower_deck_forward_pressure_aftershock_condenser_savepoint is Node2D:
		world_position = (
			_lower_deck_forward_pressure_aftershock_condenser_savepoint as Node2D
		).global_position
	return _build_return_checkpoint_snapshot(
		FACTORY_LOWER_DECK_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_SAVEPOINT_ID,
		FACTORY_SCENE_ID,
		FACTORY_LOWER_DECK_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_SAVEPOINT_SPAWN_POINT,
		world_position,
		{
			"display_name": (
				_get_lower_deck_forward_pressure_aftershock_condenser_savepoint_display_name()
			),
		}
	)


func _build_return_checkpoint_snapshot(
	savepoint_id: StringName,
	scene_id: StringName,
	spawn_point: StringName,
	world_position: Vector2,
	context: Dictionary
) -> Dictionary:
	var snapshot: Dictionary = context.duplicate(true)
	snapshot["id"] = String(savepoint_id)
	snapshot["savepoint_id"] = String(savepoint_id)
	snapshot["scene_id"] = String(scene_id)
	snapshot["spawn_point"] = String(spawn_point)
	if not snapshot.has("display_name") or String(snapshot["display_name"]).strip_edges().is_empty():
		snapshot["display_name"] = _get_return_checkpoint_display_name()
	snapshot["position"] = {
		"x": world_position.x,
		"y": world_position.y,
	}
	return snapshot


func _process_factory_hazard_overlaps() -> void:
	for hazard: Area2D in _get_factory_hazards():
		if not _is_hazard_contact_active(hazard):
			continue
		for area: Area2D in hazard.get_overlapping_areas():
			var target: Node = _resolve_factory_hazard_target_from_area(area)
			if target != null:
				apply_factory_steam_vent_contact(hazard, target)
		for body: Node2D in hazard.get_overlapping_bodies():
			if body == _player:
				apply_factory_steam_vent_contact(hazard, _player)


func _get_factory_hazards() -> Array[Area2D]:
	var hazards: Array[Area2D] = []
	if _steam_vent != null:
		hazards.append(_steam_vent)
	if _checkpoint_steam_vent != null:
		hazards.append(_checkpoint_steam_vent)
	if _lower_deck_steam_vent != null:
		hazards.append(_lower_deck_steam_vent)
	if _lower_deck_steam_sluice_hazard != null:
		hazards.append(_lower_deck_steam_sluice_hazard)
	if _lower_deck_breach_steam_hazard != null:
		hazards.append(_lower_deck_breach_steam_hazard)
	if _lower_deck_post_relay_steam_hazard != null:
		hazards.append(_lower_deck_post_relay_steam_hazard)
	if _lower_deck_forward_conduit_steam_hazard != null:
		hazards.append(_lower_deck_forward_conduit_steam_hazard)
	if _lower_deck_forward_pressure_vent != null:
		hazards.append(_lower_deck_forward_pressure_vent)
	if _lower_deck_forward_counter_pressure_vent != null:
		hazards.append(_lower_deck_forward_counter_pressure_vent)
	if _lower_deck_forward_exit_guard_pressure_vent != null:
		hazards.append(_lower_deck_forward_exit_guard_pressure_vent)
	if _lower_deck_forward_beacon_ambush_pressure_vent != null:
		hazards.append(_lower_deck_forward_beacon_ambush_pressure_vent)
	if _lower_deck_forward_overrun_pressure_vent != null:
		hazards.append(_lower_deck_forward_overrun_pressure_vent)
	if _lower_deck_forward_breaker_pressure_vent != null:
		hazards.append(_lower_deck_forward_breaker_pressure_vent)
	if _lower_deck_forward_relief_ambush_pressure_vent != null:
		hazards.append(_lower_deck_forward_relief_ambush_pressure_vent)
	if _lower_deck_forward_pressure_aftershock_exhaust_vent != null:
		hazards.append(_lower_deck_forward_pressure_aftershock_exhaust_vent)
	if _lower_deck_forward_pressure_aftershock_exhaust_flank_vent != null:
		hazards.append(_lower_deck_forward_pressure_aftershock_exhaust_flank_vent)
	if _lower_deck_forward_pressure_aftershock_exhaust_breaker_vent != null:
		hazards.append(_lower_deck_forward_pressure_aftershock_exhaust_breaker_vent)
	if _lower_deck_forward_pressure_aftershock_cooling_duct_vent != null:
		hazards.append(_lower_deck_forward_pressure_aftershock_cooling_duct_vent)
	if _lower_deck_forward_pressure_aftershock_condenser_outlet_vent != null:
		hazards.append(_lower_deck_forward_pressure_aftershock_condenser_outlet_vent)
	if _lower_deck_forward_pressure_aftershock_condenser_drip_vent != null:
		hazards.append(_lower_deck_forward_pressure_aftershock_condenser_drip_vent)
	if _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_duct_vent != null:
		hazards.append(
			_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_duct_vent
		)
	if (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_vent
		!= null
	):
		hazards.append(
			_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_vent
		)
	return hazards


func _is_hazard_contact_active(hazard: Area2D) -> bool:
	return (
		hazard != null
		and hazard.visible
		and hazard.monitoring
		and hazard.collision_layer != 0
		and hazard.collision_mask != 0
	)


func _resolve_factory_hazard_target_from_area(area: Area2D) -> Node:
	if area == null:
		return null
	var parent: Node = area.get_parent()
	if parent == _player:
		return _player
	if parent != null and parent.has_method("get_entity_id") \
			and int(parent.call("get_entity_id")) == PlayerController.PLAYER_ENTITY_ID:
		return _player
	return null


func _get_hazard_id(hazard: Area2D) -> StringName:
	if hazard != null and hazard.has_method("get_hazard_id"):
		return StringName(String(hazard.call("get_hazard_id")))
	return &""


func _is_factory_steam_hazard_id(hazard_id: StringName) -> bool:
	return (
		hazard_id == &"old_factory_steam_vent"
			or hazard_id == &"old_factory_checkpoint_steam_vent"
			or hazard_id == &"old_factory_lower_deck_steam_vent"
			or hazard_id == &"old_factory_lower_deck_steam_sluice"
			or hazard_id == &"old_factory_lower_deck_breach_corridor"
			or hazard_id == &"old_factory_lower_deck_post_relay_trial"
			or hazard_id == &"old_factory_lower_deck_forward_conduit"
			or hazard_id == &"old_factory_lower_deck_forward_pressure_traverse"
			or hazard_id == FACTORY_LOWER_DECK_FORWARD_EXIT_GUARD_HAZARD_ID
			or hazard_id == FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_EXHAUST_HAZARD_ID
			or hazard_id == FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_EXHAUST_FLANK_HAZARD_ID
			or hazard_id == FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_EXHAUST_BREAKER_HAZARD_ID
			or hazard_id == FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_COOLING_DUCT_HAZARD_ID
			or hazard_id == FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_CONDENSER_OUTLET_HAZARD_ID
			or hazard_id == FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_CONDENSER_DRIP_VENT_HAZARD_ID
				or hazard_id == FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_RUNOFF_DUCT_HAZARD_ID
				or hazard_id == FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_RUNOFF_OUTLET_HAZARD_ID
				or hazard_id == FACTORY_LOWER_DECK_FORWARD_PRESSURE_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_RUNOFF_OUTLET_SERVICE_SLUICE_HAZARD_ID
		)


func _get_hazard_damage(hazard: Area2D) -> int:
	if hazard != null and hazard.has_method("get_damage"):
		return int(hazard.call("get_damage"))
	return FACTORY_STEAM_DAMAGE_FALLBACK


func _get_hazard_cooldown_sec(hazard: Area2D) -> float:
	if hazard != null and hazard.has_method("get_contact_cooldown_sec"):
		return float(hazard.call("get_contact_cooldown_sec"))
	return FACTORY_STEAM_CONTACT_COOLDOWN_FALLBACK_SEC


func _record_spark_rat_counter_result(result: Dictionary) -> void:
	_last_spark_rat_counter_diagnostics = {
		"last_bite_resolved": bool(result.get("resolved", false)),
		"last_bite_dodged": bool(result.get("dodged", false)),
		"last_bite_damage_applied": bool(result.get("damage_applied", false)),
		"last_bite_damage": int(result.get("damage", 0)),
		"last_bite_weapon_id": String(result.get("weapon_id", "")),
		"last_bite_source": String(result.get("source", "")),
		"last_bite_attack_active": bool(result.get("attack_active", false)),
		"last_bite_already_resolved": bool(result.get("already_resolved", false)),
		"last_bite_attack_sequence_id": int(result.get("attack_sequence_id", 0)),
		"last_player_hp_before": int(result.get("player_hp_before", _get_player_hp())),
		"last_player_hp_after": int(result.get("player_hp_after", _get_player_hp())),
	}


func _get_spark_rat_bite_metadata() -> Dictionary:
	var metadata: Dictionary = {}
	if _spark_rat != null and _spark_rat.has_method("get_current_enemy_attack_metadata"):
		var metadata_variant: Variant = _spark_rat.call("get_current_enemy_attack_metadata")
		if metadata_variant is Dictionary:
			metadata = (metadata_variant as Dictionary).duplicate(true)
	if metadata.is_empty():
		metadata = {
			"source": &"factory_spark_rat",
			"weapon_id": &"factory_spark_rat_bite",
			"attack_type": &"light",
		}
	metadata["attacker_id"] = FACTORY_SPARK_RAT_ENTITY_ID
	metadata["target_id"] = PlayerController.PLAYER_ENTITY_ID
	metadata["hit_position"] = _spark_rat.global_position if _spark_rat != null else Vector2.ZERO
	metadata["scene_id"] = FACTORY_SCENE_ID
	metadata["final_damage"] = _get_spark_rat_bite_damage(metadata)
	metadata["damage"] = int(metadata["final_damage"])
	return metadata


func _get_spark_rat_bite_damage(metadata: Dictionary) -> int:
	var weapon_id: String = String(metadata.get("weapon_id", "factory_spark_rat_bite"))
	var damage_params: Dictionary = _dictionary_from_variant(metadata.get("injected_damage_params", {}))
	var entries: Dictionary = _dictionary_from_variant(damage_params.get("entries", {}))
	var bite_entry: Dictionary = _dictionary_from_variant(entries.get(weapon_id, {}))
	return int(bite_entry.get("weapon_base", FACTORY_SPARK_RAT_BITE_DAMAGE_FALLBACK))


func _dictionary_from_variant(value: Variant) -> Dictionary:
	return (value as Dictionary).duplicate(true) if value is Dictionary else {}


func _get_player_hp() -> int:
	if _player != null and _player.has_method("get_current_hp"):
		return int(_player.call("get_current_hp"))
	return 0


func _is_player_dodge_iframe_active() -> bool:
	if _player != null and _player.has_method("is_dodge_iframe_active"):
		return bool(_player.call("is_dodge_iframe_active"))
	var combat: CombatComponent = _get_player_combat_component()
	return combat != null and combat.is_dodge_iframe_active()


func _get_player_dodge_counter_window() -> int:
	if _player != null and _player.has_method("get_dodge_counter_window"):
		return int(_player.call("get_dodge_counter_window"))
	var combat: CombatComponent = _get_player_combat_component()
	return combat.get_dodge_counter_window() if combat != null else 0


func _get_player_combat_component() -> CombatComponent:
	if _player == null or not _player.has_method("get_combat_component"):
		return null
	return _player.call("get_combat_component") as CombatComponent


func _is_spark_rat_attack_active() -> bool:
	if _spark_rat != null and _spark_rat.has_method("is_enemy_attack_active"):
		return bool(_spark_rat.call("is_enemy_attack_active"))
	return false


func _get_spark_rat_attack_sequence_id() -> int:
	if _spark_rat != null and _spark_rat.has_method("get_current_attack_sequence_id"):
		return int(_spark_rat.call("get_current_attack_sequence_id"))
	return 0


func _factory_hazard_cooldown_key(hazard_id: StringName, target_id: int) -> String:
	return "%s:%d" % [String(hazard_id), target_id]


func _grant_factory_hazard_respawn_grace() -> void:
	_factory_hazard_respawn_grace_frames = FACTORY_RESPAWN_HAZARD_GRACE_FRAMES
	var target_id: int = PlayerController.PLAYER_ENTITY_ID
	for hazard: Area2D in _get_factory_hazards():
		var hazard_id: StringName = _get_hazard_id(hazard)
		if not _is_factory_steam_hazard_id(hazard_id):
			continue
		_factory_hazard_contact_cooldowns[_factory_hazard_cooldown_key(hazard_id, target_id)] = (
			_factory_hazard_elapsed_sec + _get_hazard_cooldown_sec(hazard)
		)


func _bind_factory_guard(
	guard: Node,
	owner_id: StringName,
	entity_id: int,
	summon_id: StringName,
	defeated_callback: Callable,
	attack_target: Node = null
) -> void:
	if guard == null:
		return
	if guard.has_method("set_attack_target"):
		guard.call("set_attack_target", attack_target)
	if guard.has_method("configure_summon"):
		guard.call("configure_summon", owner_id, entity_id, summon_id)
	if guard.has_signal("enemy_defeated"):
		var defeated_signal: Signal = guard.get("enemy_defeated")
		if not defeated_signal.is_connected(defeated_callback):
			defeated_signal.connect(defeated_callback)


func _set_deep_guard_attack_target(attack_target: Node) -> void:
	if _deep_guard != null and _deep_guard.has_method("set_attack_target"):
		_deep_guard.call("set_attack_target", attack_target)


func _set_spark_rat_attack_target(attack_target: Node) -> void:
	if _spark_rat != null and _spark_rat.has_method("set_attack_target"):
		_spark_rat.call("set_attack_target", attack_target)


func _set_return_spark_rat_attack_target(attack_target: Node) -> void:
	if _return_spark_rat != null and _return_spark_rat.has_method("set_attack_target"):
		_return_spark_rat.call("set_attack_target", attack_target)


func _set_checkpoint_forward_spark_rat_attack_target(attack_target: Node) -> void:
	if (
		_checkpoint_forward_spark_rat != null
		and _checkpoint_forward_spark_rat.has_method("set_attack_target")
	):
		_checkpoint_forward_spark_rat.call("set_attack_target", attack_target)


func _set_checkpoint_rear_spark_rat_attack_target(attack_target: Node) -> void:
	if (
		_checkpoint_rear_spark_rat != null
		and _checkpoint_rear_spark_rat.has_method("set_attack_target")
	):
		_checkpoint_rear_spark_rat.call("set_attack_target", attack_target)


func _set_checkpoint_overdrive_spark_rat_attack_targets(attack_target: Node) -> void:
	if (
		_checkpoint_overdrive_left_spark_rat != null
		and _checkpoint_overdrive_left_spark_rat.has_method("set_attack_target")
	):
		_checkpoint_overdrive_left_spark_rat.call("set_attack_target", attack_target)
	if (
		_checkpoint_overdrive_right_spark_rat != null
		and _checkpoint_overdrive_right_spark_rat.has_method("set_attack_target")
	):
			_checkpoint_overdrive_right_spark_rat.call("set_attack_target", attack_target)


func _set_lower_deck_spark_rat_attack_target(attack_target: Node) -> void:
	if (
		_lower_deck_spark_rat != null
		and _lower_deck_spark_rat.has_method("set_attack_target")
	):
		_lower_deck_spark_rat.call("set_attack_target", attack_target)


func _set_lower_deck_exit_spark_rat_attack_target(attack_target: Node) -> void:
	if (
		_lower_deck_exit_spark_rat != null
		and _lower_deck_exit_spark_rat.has_method("set_attack_target")
	):
		_lower_deck_exit_spark_rat.call("set_attack_target", attack_target)


func _set_lower_deck_shortcut_spark_rat_attack_target(attack_target: Node) -> void:
	if (
		_lower_deck_shortcut_spark_rat != null
		and _lower_deck_shortcut_spark_rat.has_method("set_attack_target")
	):
		_lower_deck_shortcut_spark_rat.call("set_attack_target", attack_target)


func _set_lower_deck_shortcut_pursuer_attack_target(attack_target: Node) -> void:
	if (
		_lower_deck_shortcut_pursuer_spark_rat != null
		and _lower_deck_shortcut_pursuer_spark_rat.has_method("set_attack_target")
	):
		_lower_deck_shortcut_pursuer_spark_rat.call("set_attack_target", attack_target)


func _set_lower_deck_pressure_guard_attack_target(attack_target: Node) -> void:
	if (
		_lower_deck_pressure_guard_spark_rat != null
		and _lower_deck_pressure_guard_spark_rat.has_method("set_attack_target")
	):
		_lower_deck_pressure_guard_spark_rat.call("set_attack_target", attack_target)


func _set_lower_deck_steam_sluice_attack_target(attack_target: Node) -> void:
	if (
		_lower_deck_steam_sluice_spark_rat != null
		and _lower_deck_steam_sluice_spark_rat.has_method("set_attack_target")
	):
		_lower_deck_steam_sluice_spark_rat.call("set_attack_target", attack_target)


func _set_lower_deck_deep_bulkhead_guard_attack_target(attack_target: Node) -> void:
	if (
		_lower_deck_deep_bulkhead_spark_rat != null
		and _lower_deck_deep_bulkhead_spark_rat.has_method("set_attack_target")
	):
		_lower_deck_deep_bulkhead_spark_rat.call("set_attack_target", attack_target)


func _set_lower_deck_breach_front_attack_target(attack_target: Node) -> void:
	if (
		_lower_deck_breach_front_spark_rat != null
		and _lower_deck_breach_front_spark_rat.has_method("set_attack_target")
	):
		_lower_deck_breach_front_spark_rat.call("set_attack_target", attack_target)


func _set_lower_deck_breach_rear_attack_target(attack_target: Node) -> void:
	if (
		_lower_deck_breach_rear_spark_rat != null
		and _lower_deck_breach_rear_spark_rat.has_method("set_attack_target")
	):
		_lower_deck_breach_rear_spark_rat.call("set_attack_target", attack_target)


func _set_lower_deck_post_relay_trial_attack_target(attack_target: Node) -> void:
	if (
		_lower_deck_post_relay_spark_rat != null
		and _lower_deck_post_relay_spark_rat.has_method("set_attack_target")
	):
		_lower_deck_post_relay_spark_rat.call("set_attack_target", attack_target)


func _set_lower_deck_forward_conduit_attack_target(attack_target: Node) -> void:
	if (
		_lower_deck_forward_conduit_spark_rat != null
		and _lower_deck_forward_conduit_spark_rat.has_method("set_attack_target")
	):
		_lower_deck_forward_conduit_spark_rat.call("set_attack_target", attack_target)


func _set_lower_deck_forward_counter_ambush_attack_target(attack_target: Node) -> void:
	if (
		_lower_deck_forward_counter_spark_rat != null
		and _lower_deck_forward_counter_spark_rat.has_method("set_attack_target")
	):
		_lower_deck_forward_counter_spark_rat.call("set_attack_target", attack_target)


func _set_lower_deck_forward_exit_guard_attack_target(attack_target: Node) -> void:
	if (
		_lower_deck_forward_exit_guard_spark_rat != null
		and _lower_deck_forward_exit_guard_spark_rat.has_method("set_attack_target")
	):
		_lower_deck_forward_exit_guard_spark_rat.call("set_attack_target", attack_target)


func _set_lower_deck_forward_beacon_ambush_attack_target(attack_target: Node) -> void:
	if (
		_lower_deck_forward_beacon_ambush_spark_rat != null
		and _lower_deck_forward_beacon_ambush_spark_rat.has_method("set_attack_target")
	):
		_lower_deck_forward_beacon_ambush_spark_rat.call(
			"set_attack_target",
			attack_target
		)


func _set_lower_deck_forward_overrun_attack_target(attack_target: Node) -> void:
	if (
		_lower_deck_forward_overrun_spark_rat != null
		and _lower_deck_forward_overrun_spark_rat.has_method("set_attack_target")
	):
		_lower_deck_forward_overrun_spark_rat.call("set_attack_target", attack_target)


func _set_lower_deck_forward_breaker_attack_target(attack_target: Node) -> void:
	if (
		_lower_deck_forward_breaker_spark_rat != null
		and _lower_deck_forward_breaker_spark_rat.has_method("set_attack_target")
	):
		_lower_deck_forward_breaker_spark_rat.call("set_attack_target", attack_target)


func _set_lower_deck_forward_relief_ambush_attack_target(attack_target: Node) -> void:
	if (
		_lower_deck_forward_relief_ambush_spark_rat != null
		and _lower_deck_forward_relief_ambush_spark_rat.has_method(
			"set_attack_target"
		)
	):
		_lower_deck_forward_relief_ambush_spark_rat.call(
			"set_attack_target",
			attack_target
		)


func _set_lower_deck_forward_pressure_coil_rat_attack_target(attack_target: Node) -> void:
	if (
		_lower_deck_forward_pressure_coil_rat != null
		and _lower_deck_forward_pressure_coil_rat.has_method("set_attack_target")
	):
		_lower_deck_forward_pressure_coil_rat.call("set_attack_target", attack_target)


func _set_lower_deck_forward_pressure_coil_pincer_attack_targets(attack_target: Node) -> void:
	if (
		_lower_deck_forward_pressure_coil_pincer_spark_rat != null
		and _lower_deck_forward_pressure_coil_pincer_spark_rat.has_method(
			"set_attack_target"
		)
	):
		_lower_deck_forward_pressure_coil_pincer_spark_rat.call(
			"set_attack_target",
			attack_target
		)
	if (
		_lower_deck_forward_pressure_coil_pincer_coil_rat != null
		and _lower_deck_forward_pressure_coil_pincer_coil_rat.has_method(
			"set_attack_target"
		)
	):
		_lower_deck_forward_pressure_coil_pincer_coil_rat.call(
			"set_attack_target",
			attack_target
		)


func _set_lower_deck_forward_pressure_coil_aftershock_attack_target(
	attack_target: Node
) -> void:
	if (
		_lower_deck_forward_pressure_coil_aftershock_coil_rat != null
		and _lower_deck_forward_pressure_coil_aftershock_coil_rat.has_method(
			"set_attack_target"
		)
	):
		_lower_deck_forward_pressure_coil_aftershock_coil_rat.call(
			"set_attack_target",
			attack_target
		)


func _set_lower_deck_forward_pressure_aftershock_exit_skirmish_attack_targets(
	attack_target: Node
) -> void:
	if (
		_lower_deck_forward_pressure_aftershock_exit_spark_rat != null
		and _lower_deck_forward_pressure_aftershock_exit_spark_rat.has_method(
			"set_attack_target"
		)
	):
		_lower_deck_forward_pressure_aftershock_exit_spark_rat.call(
			"set_attack_target",
			attack_target
		)
	if (
		_lower_deck_forward_pressure_aftershock_exit_coil_rat != null
		and _lower_deck_forward_pressure_aftershock_exit_coil_rat.has_method(
			"set_attack_target"
		)
	):
		_lower_deck_forward_pressure_aftershock_exit_coil_rat.call(
			"set_attack_target",
			attack_target
		)


func _set_lower_deck_forward_pressure_aftershock_exhaust_pursuer_attack_target(
	attack_target: Node
) -> void:
	if (
		_lower_deck_forward_pressure_aftershock_exhaust_pursuer_coil_rat != null
		and _lower_deck_forward_pressure_aftershock_exhaust_pursuer_coil_rat.has_method(
			"set_attack_target"
		)
	):
		_lower_deck_forward_pressure_aftershock_exhaust_pursuer_coil_rat.call(
			"set_attack_target",
			attack_target
		)


func _set_lower_deck_forward_pressure_aftershock_exhaust_flank_attack_target(
	attack_target: Node
) -> void:
	if (
		_lower_deck_forward_pressure_aftershock_exhaust_flank_spark_rat != null
		and _lower_deck_forward_pressure_aftershock_exhaust_flank_spark_rat.has_method(
			"set_attack_target"
		)
	):
		_lower_deck_forward_pressure_aftershock_exhaust_flank_spark_rat.call(
			"set_attack_target",
			attack_target
		)


func _set_lower_deck_forward_pressure_aftershock_exhaust_breaker_attack_target(
	attack_target: Node
) -> void:
	if (
		_lower_deck_forward_pressure_aftershock_exhaust_breaker_coil_rat != null
		and _lower_deck_forward_pressure_aftershock_exhaust_breaker_coil_rat.has_method(
			"set_attack_target"
		)
	):
		_lower_deck_forward_pressure_aftershock_exhaust_breaker_coil_rat.call(
			"set_attack_target",
			attack_target
		)


func _set_lower_deck_forward_pressure_aftershock_exhaust_escape_skirmish_attack_targets(
	attack_target: Node
) -> void:
	if (
		_lower_deck_forward_pressure_aftershock_exhaust_escape_spark_rat != null
		and _lower_deck_forward_pressure_aftershock_exhaust_escape_spark_rat.has_method(
			"set_attack_target"
		)
	):
		_lower_deck_forward_pressure_aftershock_exhaust_escape_spark_rat.call(
			"set_attack_target",
			attack_target
		)
	if (
		_lower_deck_forward_pressure_aftershock_exhaust_escape_coil_rat != null
		and _lower_deck_forward_pressure_aftershock_exhaust_escape_coil_rat.has_method(
			"set_attack_target"
		)
	):
		_lower_deck_forward_pressure_aftershock_exhaust_escape_coil_rat.call(
			"set_attack_target",
			attack_target
		)


func _set_lower_deck_forward_pressure_aftershock_condenser_valve_attack_targets(
	attack_target: Node
) -> void:
	if (
		_lower_deck_forward_pressure_aftershock_condenser_spark_rat != null
		and _lower_deck_forward_pressure_aftershock_condenser_spark_rat.has_method(
			"set_attack_target"
		)
	):
		_lower_deck_forward_pressure_aftershock_condenser_spark_rat.call(
			"set_attack_target",
			attack_target
		)
	if (
		_lower_deck_forward_pressure_aftershock_condenser_coil_rat != null
		and _lower_deck_forward_pressure_aftershock_condenser_coil_rat.has_method(
			"set_attack_target"
		)
	):
		_lower_deck_forward_pressure_aftershock_condenser_coil_rat.call(
			"set_attack_target",
			attack_target
		)


func _set_outlet_clamp_ambush_attack_target(attack_target: Node) -> void:
	if (
		_lower_deck_forward_pressure_aftershock_condenser_outlet_clamp_spark_rat != null
		and _lower_deck_forward_pressure_aftershock_condenser_outlet_clamp_spark_rat.has_method(
			"set_attack_target"
		)
	):
		_lower_deck_forward_pressure_aftershock_condenser_outlet_clamp_spark_rat.call(
			"set_attack_target",
			attack_target
		)


func _set_overflow_pump_attack_target(attack_target: Node) -> void:
	if (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_coil_rat != null
		and _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_coil_rat.has_method(
			"set_attack_target"
		)
	):
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_coil_rat.call(
			"set_attack_target",
			attack_target
		)


func _set_overflow_pump_runoff_exit_attack_target(attack_target: Node) -> void:
	if (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_coil_rat != null
		and _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_coil_rat.has_method(
			"set_attack_target"
		)
	):
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_coil_rat.call(
			"set_attack_target",
			attack_target
		)


func _set_overflow_pump_runoff_outlet_spark_rat_attack_target(attack_target: Node) -> void:
	if (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_spark_rat != null
		and _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_spark_rat.has_method(
			"set_attack_target"
		)
	):
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_spark_rat.call(
			"set_attack_target",
			attack_target
		)


func _set_overflow_pump_runoff_outlet_service_sluice_spark_rat_attack_target(
	attack_target: Node
) -> void:
	if (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_spark_rat != null
		and _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_spark_rat.has_method(
			"set_attack_target"
		)
	):
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_spark_rat.call(
			"set_attack_target",
			attack_target
		)


func _begin_spark_rat_pacing(opening_grace_frames: int) -> void:
	if _spark_rat != null and _spark_rat.has_method("begin_pacing"):
		_spark_rat.call("begin_pacing", maxi(0, opening_grace_frames))


func _begin_return_spark_rat_pacing(opening_grace_frames: int) -> void:
	if _return_spark_rat != null and _return_spark_rat.has_method("begin_pacing"):
		_return_spark_rat.call("begin_pacing", maxi(0, opening_grace_frames))


func _begin_checkpoint_forward_spark_rat_pacing(opening_grace_frames: int) -> void:
	if (
		_checkpoint_forward_spark_rat != null
		and _checkpoint_forward_spark_rat.has_method("begin_pacing")
	):
		_checkpoint_forward_spark_rat.call("begin_pacing", maxi(0, opening_grace_frames))


func _begin_checkpoint_rear_spark_rat_pacing(opening_grace_frames: int) -> void:
	if (
		_checkpoint_rear_spark_rat != null
		and _checkpoint_rear_spark_rat.has_method("begin_pacing")
	):
		_checkpoint_rear_spark_rat.call("begin_pacing", maxi(0, opening_grace_frames))


func _begin_checkpoint_overdrive_spark_rat_pacing(
	left_opening_grace_frames: int,
	right_opening_grace_frames: int = -1
) -> void:
	var left_grace_frames: int = maxi(0, left_opening_grace_frames)
	var right_grace_frames: int = (
		left_grace_frames
		if right_opening_grace_frames < 0
		else maxi(0, right_opening_grace_frames)
	)
	if (
		_checkpoint_overdrive_left_spark_rat != null
		and _checkpoint_overdrive_left_spark_rat.has_method("begin_pacing")
		and not _checkpoint_overdrive_left_defeated
	):
		_checkpoint_overdrive_left_spark_rat.call("begin_pacing", left_grace_frames)
	if (
		_checkpoint_overdrive_right_spark_rat != null
		and _checkpoint_overdrive_right_spark_rat.has_method("begin_pacing")
		and not _checkpoint_overdrive_right_defeated
	):
			_checkpoint_overdrive_right_spark_rat.call("begin_pacing", right_grace_frames)


func _begin_lower_deck_spark_rat_pacing(opening_grace_frames: int) -> void:
	if (
		_lower_deck_spark_rat != null
		and _lower_deck_spark_rat.has_method("begin_pacing")
		and not _lower_deck_skirmish_defeated
	):
		_lower_deck_spark_rat.call("begin_pacing", maxi(0, opening_grace_frames))


func _begin_lower_deck_exit_spark_rat_pacing(opening_grace_frames: int) -> void:
	if (
		_lower_deck_exit_spark_rat != null
		and _lower_deck_exit_spark_rat.has_method("begin_pacing")
		and not _lower_deck_exit_ambush_defeated
	):
		_lower_deck_exit_spark_rat.call("begin_pacing", maxi(0, opening_grace_frames))


func _begin_lower_deck_shortcut_spark_rat_pacing(opening_grace_frames: int) -> void:
	if (
		_lower_deck_shortcut_spark_rat != null
		and _lower_deck_shortcut_spark_rat.has_method("begin_pacing")
		and not _lower_deck_shortcut_guard_defeated
	):
		_lower_deck_shortcut_spark_rat.call("begin_pacing", maxi(0, opening_grace_frames))


func _begin_lower_deck_shortcut_pursuer_pacing(opening_grace_frames: int) -> void:
	if (
		_lower_deck_shortcut_pursuer_spark_rat != null
		and _lower_deck_shortcut_pursuer_spark_rat.has_method("begin_pacing")
		and not _lower_deck_shortcut_pursuer_defeated
	):
		_lower_deck_shortcut_pursuer_spark_rat.call(
			"begin_pacing",
			maxi(0, opening_grace_frames)
		)


func _begin_lower_deck_pressure_guard_pacing(opening_grace_frames: int) -> void:
	if (
		_lower_deck_pressure_guard_spark_rat != null
		and _lower_deck_pressure_guard_spark_rat.has_method("begin_pacing")
		and not _lower_deck_pressure_guard_defeated
	):
		_lower_deck_pressure_guard_spark_rat.call(
			"begin_pacing",
			maxi(0, opening_grace_frames)
		)


func _begin_lower_deck_steam_sluice_pacing(opening_grace_frames: int) -> void:
	if (
		_lower_deck_steam_sluice_spark_rat != null
		and _lower_deck_steam_sluice_spark_rat.has_method("begin_pacing")
		and not _lower_deck_steam_sluice_defeated
	):
		_lower_deck_steam_sluice_spark_rat.call(
			"begin_pacing",
			maxi(0, opening_grace_frames)
		)


func _begin_lower_deck_deep_bulkhead_guard_pacing(opening_grace_frames: int) -> void:
	if (
		_lower_deck_deep_bulkhead_spark_rat != null
		and _lower_deck_deep_bulkhead_spark_rat.has_method("begin_pacing")
		and not _lower_deck_deep_bulkhead_guard_defeated
	):
		_lower_deck_deep_bulkhead_spark_rat.call(
			"begin_pacing",
			maxi(0, opening_grace_frames)
		)


func _begin_lower_deck_post_relay_trial_pacing(opening_grace_frames: int) -> void:
	if (
		_lower_deck_post_relay_spark_rat != null
		and _lower_deck_post_relay_spark_rat.has_method("begin_pacing")
		and not _lower_deck_post_relay_trial_defeated
	):
		_lower_deck_post_relay_spark_rat.call(
			"begin_pacing",
			maxi(0, opening_grace_frames)
		)


func _begin_lower_deck_forward_conduit_pacing(opening_grace_frames: int) -> void:
	if (
		_lower_deck_forward_conduit_spark_rat != null
		and _lower_deck_forward_conduit_spark_rat.has_method("begin_pacing")
		and not _lower_deck_forward_conduit_defeated
	):
		_lower_deck_forward_conduit_spark_rat.call(
			"begin_pacing",
			maxi(0, opening_grace_frames)
		)


func _begin_lower_deck_forward_counter_ambush_pacing(opening_grace_frames: int) -> void:
	if (
		_lower_deck_forward_counter_spark_rat != null
		and _lower_deck_forward_counter_spark_rat.has_method("begin_pacing")
		and not _lower_deck_forward_pressure_counter_ambush_defeated
	):
		_lower_deck_forward_counter_spark_rat.call(
			"begin_pacing",
			maxi(0, opening_grace_frames)
		)


func _begin_lower_deck_forward_exit_guard_pacing(opening_grace_frames: int) -> void:
	if (
		_lower_deck_forward_exit_guard_spark_rat != null
		and _lower_deck_forward_exit_guard_spark_rat.has_method("begin_pacing")
		and not _lower_deck_forward_pressure_exit_guard_defeated
	):
		_lower_deck_forward_exit_guard_spark_rat.call(
			"begin_pacing",
			maxi(0, opening_grace_frames)
		)


func _begin_lower_deck_forward_beacon_ambush_pacing(opening_grace_frames: int) -> void:
	if (
		_lower_deck_forward_beacon_ambush_spark_rat != null
		and _lower_deck_forward_beacon_ambush_spark_rat.has_method("begin_pacing")
		and not _lower_deck_forward_pressure_beacon_ambush_defeated
	):
		_lower_deck_forward_beacon_ambush_spark_rat.call(
			"begin_pacing",
			maxi(0, opening_grace_frames)
		)


func _begin_lower_deck_forward_overrun_pacing(opening_grace_frames: int) -> void:
	if (
		_lower_deck_forward_overrun_spark_rat != null
		and _lower_deck_forward_overrun_spark_rat.has_method("begin_pacing")
		and not _lower_deck_forward_pressure_overrun_defeated
	):
		_lower_deck_forward_overrun_spark_rat.call(
			"begin_pacing",
			maxi(0, opening_grace_frames)
		)


func _begin_lower_deck_forward_breaker_pacing(opening_grace_frames: int) -> void:
	if (
		_lower_deck_forward_breaker_spark_rat != null
		and _lower_deck_forward_breaker_spark_rat.has_method("begin_pacing")
		and not _lower_deck_forward_pressure_breaker_secured
	):
		_lower_deck_forward_breaker_spark_rat.call(
			"begin_pacing",
			maxi(0, opening_grace_frames)
		)


func _begin_lower_deck_forward_relief_ambush_pacing(opening_grace_frames: int) -> void:
	if (
		_lower_deck_forward_relief_ambush_spark_rat != null
		and _lower_deck_forward_relief_ambush_spark_rat.has_method("begin_pacing")
		and not _lower_deck_forward_pressure_relief_ambush_defeated
	):
		_lower_deck_forward_relief_ambush_spark_rat.call(
			"begin_pacing",
			maxi(0, opening_grace_frames)
		)


func _begin_lower_deck_forward_pressure_coil_rat_pacing(opening_grace_frames: int) -> void:
	if (
		_lower_deck_forward_pressure_coil_rat != null
		and _lower_deck_forward_pressure_coil_rat.has_method("begin_pacing")
		and not _lower_deck_forward_pressure_coil_rat_defeated
	):
		_lower_deck_forward_pressure_coil_rat.call(
			"begin_pacing",
			maxi(0, opening_grace_frames)
		)


func _begin_lower_deck_forward_pressure_coil_pincer_pacing(
	spark_opening_grace_frames: int,
	coil_opening_grace_frames: int
) -> void:
	if (
		_lower_deck_forward_pressure_coil_pincer_spark_rat != null
		and _lower_deck_forward_pressure_coil_pincer_spark_rat.has_method(
			"begin_pacing"
		)
		and not _lower_deck_forward_pressure_coil_pincer_spark_rat_defeated
	):
		_lower_deck_forward_pressure_coil_pincer_spark_rat.call(
			"begin_pacing",
			maxi(0, spark_opening_grace_frames)
		)
	if (
		_lower_deck_forward_pressure_coil_pincer_coil_rat != null
		and _lower_deck_forward_pressure_coil_pincer_coil_rat.has_method(
			"begin_pacing"
		)
		and not _lower_deck_forward_pressure_coil_pincer_coil_rat_defeated
	):
		_lower_deck_forward_pressure_coil_pincer_coil_rat.call(
			"begin_pacing",
			maxi(0, coil_opening_grace_frames)
		)


func _begin_lower_deck_forward_pressure_coil_aftershock_pacing(
	opening_grace_frames: int
) -> void:
	if (
		_lower_deck_forward_pressure_coil_aftershock_coil_rat != null
		and _lower_deck_forward_pressure_coil_aftershock_coil_rat.has_method(
			"begin_pacing"
		)
		and not _lower_deck_forward_pressure_coil_aftershock_defeated
	):
		_lower_deck_forward_pressure_coil_aftershock_coil_rat.call(
			"begin_pacing",
			maxi(0, opening_grace_frames)
		)


func _begin_lower_deck_forward_pressure_aftershock_exit_skirmish_pacing(
	spark_opening_grace_frames: int,
	coil_opening_grace_frames: int
) -> void:
	if (
		_lower_deck_forward_pressure_aftershock_exit_spark_rat != null
		and _lower_deck_forward_pressure_aftershock_exit_spark_rat.has_method(
			"begin_pacing"
		)
		and not _lower_deck_forward_pressure_aftershock_exit_spark_rat_defeated
	):
		_lower_deck_forward_pressure_aftershock_exit_spark_rat.call(
			"begin_pacing",
			maxi(0, spark_opening_grace_frames)
		)
	if (
		_lower_deck_forward_pressure_aftershock_exit_coil_rat != null
		and _lower_deck_forward_pressure_aftershock_exit_coil_rat.has_method(
			"begin_pacing"
		)
		and not _lower_deck_forward_pressure_aftershock_exit_coil_rat_defeated
	):
		_lower_deck_forward_pressure_aftershock_exit_coil_rat.call(
			"begin_pacing",
			maxi(0, coil_opening_grace_frames)
		)


func _begin_lower_deck_forward_pressure_aftershock_exhaust_pursuer_pacing(
	opening_grace_frames: int
) -> void:
	if (
		_lower_deck_forward_pressure_aftershock_exhaust_pursuer_coil_rat != null
		and _lower_deck_forward_pressure_aftershock_exhaust_pursuer_coil_rat.has_method(
			"begin_pacing"
		)
		and not _lower_deck_forward_pressure_aftershock_exhaust_pursuer_defeated
	):
		_lower_deck_forward_pressure_aftershock_exhaust_pursuer_coil_rat.call(
			"begin_pacing",
			maxi(0, opening_grace_frames)
		)


func _begin_lower_deck_forward_pressure_aftershock_exhaust_flank_pacing(
	opening_grace_frames: int
) -> void:
	if (
		_lower_deck_forward_pressure_aftershock_exhaust_flank_spark_rat != null
		and _lower_deck_forward_pressure_aftershock_exhaust_flank_spark_rat.has_method(
			"begin_pacing"
		)
		and not _lower_deck_forward_pressure_aftershock_exhaust_flank_spark_rat_defeated
	):
		_lower_deck_forward_pressure_aftershock_exhaust_flank_spark_rat.call(
			"begin_pacing",
			maxi(0, opening_grace_frames)
		)


func _begin_lower_deck_forward_pressure_aftershock_exhaust_breaker_pacing(
	opening_grace_frames: int
) -> void:
	if (
		_lower_deck_forward_pressure_aftershock_exhaust_breaker_coil_rat != null
		and _lower_deck_forward_pressure_aftershock_exhaust_breaker_coil_rat.has_method(
			"begin_pacing"
		)
		and not _lower_deck_forward_pressure_aftershock_exhaust_breaker_coil_rat_defeated
	):
		_lower_deck_forward_pressure_aftershock_exhaust_breaker_coil_rat.call(
			"begin_pacing",
			maxi(0, opening_grace_frames)
		)


func _begin_lower_deck_forward_pressure_aftershock_exhaust_escape_skirmish_pacing(
	spark_opening_grace_frames: int,
	coil_opening_grace_frames: int
) -> void:
	if (
		_lower_deck_forward_pressure_aftershock_exhaust_escape_spark_rat != null
		and _lower_deck_forward_pressure_aftershock_exhaust_escape_spark_rat.has_method(
			"begin_pacing"
		)
		and not _lower_deck_forward_pressure_aftershock_exhaust_escape_spark_rat_defeated
	):
		_lower_deck_forward_pressure_aftershock_exhaust_escape_spark_rat.call(
			"begin_pacing",
			maxi(0, spark_opening_grace_frames)
		)
	if (
		_lower_deck_forward_pressure_aftershock_exhaust_escape_coil_rat != null
		and _lower_deck_forward_pressure_aftershock_exhaust_escape_coil_rat.has_method(
			"begin_pacing"
		)
		and not _lower_deck_forward_pressure_aftershock_exhaust_escape_coil_rat_defeated
	):
		_lower_deck_forward_pressure_aftershock_exhaust_escape_coil_rat.call(
			"begin_pacing",
			maxi(0, coil_opening_grace_frames)
		)


func _begin_lower_deck_forward_pressure_aftershock_condenser_valve_pacing() -> void:
	if (
		_lower_deck_forward_pressure_aftershock_condenser_spark_rat != null
		and _lower_deck_forward_pressure_aftershock_condenser_spark_rat.has_method(
			"begin_pacing"
		)
		and not _lower_deck_forward_pressure_aftershock_condenser_valve_spark_rat_defeated
	):
		_lower_deck_forward_pressure_aftershock_condenser_spark_rat.call(
			"begin_pacing",
			10
		)
	if (
		_lower_deck_forward_pressure_aftershock_condenser_coil_rat != null
		and _lower_deck_forward_pressure_aftershock_condenser_coil_rat.has_method(
			"begin_pacing"
		)
		and not _lower_deck_forward_pressure_aftershock_condenser_valve_coil_rat_defeated
	):
		_lower_deck_forward_pressure_aftershock_condenser_coil_rat.call(
			"begin_pacing",
			22
		)


func _begin_outlet_clamp_ambush_pacing() -> void:
	if (
		_lower_deck_forward_pressure_aftershock_condenser_outlet_clamp_spark_rat != null
		and _lower_deck_forward_pressure_aftershock_condenser_outlet_clamp_spark_rat.has_method(
			"begin_pacing"
		)
		and not _lower_deck_forward_pressure_aftershock_condenser_outlet_clamp_spark_rat_defeated
	):
		_lower_deck_forward_pressure_aftershock_condenser_outlet_clamp_spark_rat.call(
			"begin_pacing",
			FACTORY_SPARK_RAT_OPENING_GRACE_FRAMES
		)


func _begin_overflow_pump_pacing(opening_grace_frames: int) -> void:
	if (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_coil_rat != null
		and _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_coil_rat.has_method(
			"begin_pacing"
		)
		and not _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_coil_rat_defeated
	):
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_coil_rat.call(
			"begin_pacing",
			maxi(0, opening_grace_frames)
		)


func _begin_overflow_pump_runoff_exit_pacing(opening_grace_frames: int) -> void:
	if (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_coil_rat != null
		and _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_coil_rat.has_method(
			"begin_pacing"
		)
		and not _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_coil_rat_defeated
	):
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_coil_rat.call(
			"begin_pacing",
			maxi(0, opening_grace_frames)
		)


func _begin_overflow_pump_runoff_outlet_skirmish_pacing(opening_grace_frames: int) -> void:
	if (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_spark_rat != null
		and _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_spark_rat.has_method(
			"begin_pacing"
		)
		and not _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_spark_rat_defeated
	):
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_spark_rat.call(
			"begin_pacing",
			maxi(0, opening_grace_frames)
		)


func _begin_overflow_pump_runoff_outlet_service_sluice_skirmish_pacing(
	opening_grace_frames: int
) -> void:
	if (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_spark_rat != null
		and _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_spark_rat.has_method(
			"begin_pacing"
		)
		and not _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_spark_rat_defeated
	):
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_spark_rat.call(
			"begin_pacing",
			maxi(0, opening_grace_frames)
		)


func _begin_lower_deck_breach_front_pacing(opening_grace_frames: int) -> void:
	if (
		_lower_deck_breach_front_spark_rat != null
		and _lower_deck_breach_front_spark_rat.has_method("begin_pacing")
		and not _lower_deck_breach_front_guard_defeated
	):
		_lower_deck_breach_front_spark_rat.call(
			"begin_pacing",
			maxi(0, opening_grace_frames)
		)


func _begin_lower_deck_breach_rear_pacing(opening_grace_frames: int) -> void:
	if (
		_lower_deck_breach_rear_spark_rat != null
		and _lower_deck_breach_rear_spark_rat.has_method("begin_pacing")
		and not _lower_deck_breach_rear_ambusher_defeated
	):
		_lower_deck_breach_rear_spark_rat.call(
			"begin_pacing",
			maxi(0, opening_grace_frames)
		)


func _get_spark_rat_pacing_diagnostics() -> Dictionary:
	if _spark_rat != null and _spark_rat.has_method("get_pacing_diagnostics"):
		var pacing_variant: Variant = _spark_rat.call("get_pacing_diagnostics")
		if pacing_variant is Dictionary:
			return (pacing_variant as Dictionary).duplicate(true)
	return {
		"pacing_state": "inactive",
		"opening_grace_frames": 0,
		"opening_grace_total_frames": FACTORY_SPARK_RAT_OPENING_GRACE_FRAMES,
		"alert_radius_px": 0.0,
		"target_distance": _get_spark_rat_distance_to_provider(_player),
		"target_in_alert_radius": false,
		"patrol_center_x": _spark_rat.global_position.x if _spark_rat != null else 0.0,
		"patrol_left_x": _spark_rat.global_position.x if _spark_rat != null else 0.0,
		"patrol_right_x": _spark_rat.global_position.x if _spark_rat != null else 0.0,
		"attack_startup_frames": (
			int(_spark_rat.call("get_attack_startup_frames"))
			if _spark_rat != null and _spark_rat.has_method("get_attack_startup_frames")
			else 0
		),
		"attack_sequence_id": _get_spark_rat_attack_sequence_id(),
		"attack_active": _is_spark_rat_attack_active(),
		"current_animation": "",
	}


func _get_spark_rat_opening_grace_frames() -> int:
	var pacing: Dictionary = _get_spark_rat_pacing_diagnostics()
	return int(pacing.get("opening_grace_frames", 0))


func _get_checkpoint_forward_patrol_pacing_diagnostics() -> Dictionary:
	if (
		_checkpoint_forward_spark_rat != null
		and _checkpoint_forward_spark_rat.has_method("get_pacing_diagnostics")
	):
		var pacing_variant: Variant = _checkpoint_forward_spark_rat.call("get_pacing_diagnostics")
		if pacing_variant is Dictionary:
			return (pacing_variant as Dictionary).duplicate(true)
	return {
		"pacing_state": "inactive",
		"opening_grace_frames": 0,
		"opening_grace_total_frames": FACTORY_SPARK_RAT_OPENING_GRACE_FRAMES,
	}


func _get_checkpoint_forward_patrol_opening_grace_frames() -> int:
	var pacing: Dictionary = _get_checkpoint_forward_patrol_pacing_diagnostics()
	return int(pacing.get("opening_grace_frames", 0))


func _get_checkpoint_rear_ambush_pacing_diagnostics() -> Dictionary:
	if (
		_checkpoint_rear_spark_rat != null
		and _checkpoint_rear_spark_rat.has_method("get_pacing_diagnostics")
	):
		var pacing_variant: Variant = _checkpoint_rear_spark_rat.call("get_pacing_diagnostics")
		if pacing_variant is Dictionary:
			return (pacing_variant as Dictionary).duplicate(true)
	return {
		"pacing_state": "inactive",
		"opening_grace_frames": 0,
		"opening_grace_total_frames": FACTORY_SPARK_RAT_OPENING_GRACE_FRAMES,
	}


func _get_checkpoint_rear_ambush_opening_grace_frames() -> int:
	var pacing: Dictionary = _get_checkpoint_rear_ambush_pacing_diagnostics()
	return int(pacing.get("opening_grace_frames", 0))


func _get_checkpoint_overdrive_duo_pacing_diagnostics() -> Dictionary:
	var left_pacing: Dictionary = _get_checkpoint_overdrive_spark_rat_pacing_diagnostics(
		_checkpoint_overdrive_left_spark_rat
	)
	var right_pacing: Dictionary = _get_checkpoint_overdrive_spark_rat_pacing_diagnostics(
		_checkpoint_overdrive_right_spark_rat
	)
	return {
		"left": left_pacing,
		"right": right_pacing,
		"opening_grace_frames": _get_checkpoint_overdrive_duo_opening_grace_frames(),
		"opening_grace_total_frames": maxi(
			int(left_pacing.get("opening_grace_total_frames", 0)),
			int(right_pacing.get("opening_grace_total_frames", 0))
		),
	}


func _get_checkpoint_overdrive_spark_rat_pacing_diagnostics(spark_rat: Node2D) -> Dictionary:
	if spark_rat != null and spark_rat.has_method("get_pacing_diagnostics"):
		var pacing_variant: Variant = spark_rat.call("get_pacing_diagnostics")
		if pacing_variant is Dictionary:
			return (pacing_variant as Dictionary).duplicate(true)
	return {
		"pacing_state": "inactive",
		"opening_grace_frames": 0,
		"opening_grace_total_frames": FACTORY_SPARK_RAT_OPENING_GRACE_FRAMES,
	}


func _get_checkpoint_overdrive_duo_opening_grace_frames() -> int:
	var left_pacing: Dictionary = _get_checkpoint_overdrive_spark_rat_pacing_diagnostics(
		_checkpoint_overdrive_left_spark_rat
	)
	var right_pacing: Dictionary = _get_checkpoint_overdrive_spark_rat_pacing_diagnostics(
		_checkpoint_overdrive_right_spark_rat
	)
	return maxi(
		int(left_pacing.get("opening_grace_frames", 0)),
		int(right_pacing.get("opening_grace_frames", 0))
	)


func _get_checkpoint_overdrive_left_opening_grace_frames() -> int:
	var pacing: Dictionary = _get_checkpoint_overdrive_spark_rat_pacing_diagnostics(
		_checkpoint_overdrive_left_spark_rat
	)
	return int(pacing.get("opening_grace_frames", 0))


func _get_checkpoint_overdrive_right_opening_grace_frames() -> int:
	var pacing: Dictionary = _get_checkpoint_overdrive_spark_rat_pacing_diagnostics(
		_checkpoint_overdrive_right_spark_rat
	)
	return int(pacing.get("opening_grace_frames", 0))


func _get_lower_deck_skirmish_pacing_diagnostics() -> Dictionary:
	if (
		_lower_deck_spark_rat != null
		and _lower_deck_spark_rat.has_method("get_pacing_diagnostics")
	):
		var pacing_variant: Variant = _lower_deck_spark_rat.call("get_pacing_diagnostics")
		if pacing_variant is Dictionary:
			return (pacing_variant as Dictionary).duplicate(true)
	return {
		"pacing_state": "inactive",
		"opening_grace_frames": 0,
		"opening_grace_total_frames": FACTORY_SPARK_RAT_OPENING_GRACE_FRAMES,
	}


func _get_lower_deck_skirmish_opening_grace_frames() -> int:
	var pacing: Dictionary = _get_lower_deck_skirmish_pacing_diagnostics()
	return int(pacing.get("opening_grace_frames", 0))


func _get_lower_deck_exit_ambush_pacing_diagnostics() -> Dictionary:
	if (
		_lower_deck_exit_spark_rat != null
		and _lower_deck_exit_spark_rat.has_method("get_pacing_diagnostics")
	):
		var pacing_variant: Variant = _lower_deck_exit_spark_rat.call("get_pacing_diagnostics")
		if pacing_variant is Dictionary:
			return (pacing_variant as Dictionary).duplicate(true)
	return {
		"pacing_state": "inactive",
		"opening_grace_frames": 0,
		"opening_grace_total_frames": FACTORY_SPARK_RAT_OPENING_GRACE_FRAMES,
	}


func _get_lower_deck_exit_ambush_opening_grace_frames() -> int:
	var pacing: Dictionary = _get_lower_deck_exit_ambush_pacing_diagnostics()
	return int(pacing.get("opening_grace_frames", 0))


func _get_lower_deck_shortcut_pacing_diagnostics() -> Dictionary:
	if (
		_lower_deck_shortcut_spark_rat != null
		and _lower_deck_shortcut_spark_rat.has_method("get_pacing_diagnostics")
	):
		var pacing_variant: Variant = _lower_deck_shortcut_spark_rat.call(
			"get_pacing_diagnostics"
		)
		if pacing_variant is Dictionary:
			return (pacing_variant as Dictionary).duplicate(true)
	return {
		"pacing_state": "inactive",
		"opening_grace_frames": 0,
		"opening_grace_total_frames": FACTORY_SPARK_RAT_OPENING_GRACE_FRAMES,
	}


func _get_lower_deck_shortcut_opening_grace_frames() -> int:
	var pacing: Dictionary = _get_lower_deck_shortcut_pacing_diagnostics()
	return int(pacing.get("opening_grace_frames", 0))


func _get_lower_deck_shortcut_pursuer_pacing_diagnostics() -> Dictionary:
	if (
		_lower_deck_shortcut_pursuer_spark_rat != null
		and _lower_deck_shortcut_pursuer_spark_rat.has_method("get_pacing_diagnostics")
	):
		var pacing_variant: Variant = _lower_deck_shortcut_pursuer_spark_rat.call(
			"get_pacing_diagnostics"
		)
		if pacing_variant is Dictionary:
			return (pacing_variant as Dictionary).duplicate(true)
	return {
		"pacing_state": "inactive",
		"opening_grace_frames": 0,
		"opening_grace_total_frames": FACTORY_SPARK_RAT_OPENING_GRACE_FRAMES,
	}


func _get_lower_deck_pressure_guard_pacing_diagnostics() -> Dictionary:
	if (
		_lower_deck_pressure_guard_spark_rat != null
		and _lower_deck_pressure_guard_spark_rat.has_method("get_pacing_diagnostics")
	):
		var pacing_variant: Variant = _lower_deck_pressure_guard_spark_rat.call(
			"get_pacing_diagnostics"
		)
		if pacing_variant is Dictionary:
			return (pacing_variant as Dictionary).duplicate(true)
	return {
		"pacing_state": "inactive",
		"opening_grace_frames": 0,
		"opening_grace_total_frames": FACTORY_SPARK_RAT_OPENING_GRACE_FRAMES,
	}


func _get_lower_deck_steam_sluice_pacing_diagnostics() -> Dictionary:
	if (
		_lower_deck_steam_sluice_spark_rat != null
		and _lower_deck_steam_sluice_spark_rat.has_method("get_pacing_diagnostics")
	):
		var pacing_variant: Variant = _lower_deck_steam_sluice_spark_rat.call(
			"get_pacing_diagnostics"
		)
		if pacing_variant is Dictionary:
			return (pacing_variant as Dictionary).duplicate(true)
	return {
		"pacing_state": "inactive",
		"opening_grace_frames": 0,
		"opening_grace_total_frames": FACTORY_SPARK_RAT_OPENING_GRACE_FRAMES,
	}


func _get_lower_deck_deep_bulkhead_guard_pacing_diagnostics() -> Dictionary:
	if (
		_lower_deck_deep_bulkhead_spark_rat != null
		and _lower_deck_deep_bulkhead_spark_rat.has_method("get_pacing_diagnostics")
	):
		var pacing_variant: Variant = _lower_deck_deep_bulkhead_spark_rat.call(
			"get_pacing_diagnostics"
		)
		if pacing_variant is Dictionary:
			return (pacing_variant as Dictionary).duplicate(true)
	return {
		"pacing_state": "inactive",
		"opening_grace_frames": 0,
		"opening_grace_total_frames": FACTORY_SPARK_RAT_OPENING_GRACE_FRAMES,
	}


func _get_lower_deck_breach_front_pacing_diagnostics() -> Dictionary:
	if (
		_lower_deck_breach_front_spark_rat != null
		and _lower_deck_breach_front_spark_rat.has_method("get_pacing_diagnostics")
	):
		var pacing_variant: Variant = _lower_deck_breach_front_spark_rat.call(
			"get_pacing_diagnostics"
		)
		if pacing_variant is Dictionary:
			return (pacing_variant as Dictionary).duplicate(true)
	return {
		"pacing_state": "inactive",
		"opening_grace_frames": 0,
		"opening_grace_total_frames": FACTORY_SPARK_RAT_OPENING_GRACE_FRAMES,
	}


func _get_lower_deck_breach_rear_pacing_diagnostics() -> Dictionary:
	if (
		_lower_deck_breach_rear_spark_rat != null
		and _lower_deck_breach_rear_spark_rat.has_method("get_pacing_diagnostics")
	):
		var pacing_variant: Variant = _lower_deck_breach_rear_spark_rat.call(
			"get_pacing_diagnostics"
		)
		if pacing_variant is Dictionary:
			return (pacing_variant as Dictionary).duplicate(true)
	return {
		"pacing_state": "inactive",
		"opening_grace_frames": 0,
		"opening_grace_total_frames": FACTORY_SPARK_RAT_OPENING_GRACE_FRAMES,
	}


func _get_lower_deck_post_relay_trial_pacing_diagnostics() -> Dictionary:
	if (
		_lower_deck_post_relay_spark_rat != null
		and _lower_deck_post_relay_spark_rat.has_method("get_pacing_diagnostics")
	):
		var pacing_variant: Variant = _lower_deck_post_relay_spark_rat.call(
			"get_pacing_diagnostics"
		)
		if pacing_variant is Dictionary:
			return (pacing_variant as Dictionary).duplicate(true)
	return {
		"pacing_state": "inactive",
		"opening_grace_frames": 0,
		"opening_grace_total_frames": FACTORY_SPARK_RAT_OPENING_GRACE_FRAMES,
	}


func _get_lower_deck_forward_conduit_pacing_diagnostics() -> Dictionary:
	if (
		_lower_deck_forward_conduit_spark_rat != null
		and _lower_deck_forward_conduit_spark_rat.has_method("get_pacing_diagnostics")
	):
		var pacing_variant: Variant = _lower_deck_forward_conduit_spark_rat.call(
			"get_pacing_diagnostics"
		)
		if pacing_variant is Dictionary:
			return (pacing_variant as Dictionary).duplicate(true)
	return {
		"pacing_state": "inactive",
		"opening_grace_frames": 0,
		"opening_grace_total_frames": FACTORY_SPARK_RAT_OPENING_GRACE_FRAMES,
	}


func _get_lower_deck_forward_counter_ambush_pacing_diagnostics() -> Dictionary:
	if (
		_lower_deck_forward_counter_spark_rat != null
		and _lower_deck_forward_counter_spark_rat.has_method("get_pacing_diagnostics")
	):
		var pacing_variant: Variant = _lower_deck_forward_counter_spark_rat.call(
			"get_pacing_diagnostics"
		)
		if pacing_variant is Dictionary:
			return (pacing_variant as Dictionary).duplicate(true)
	return {
		"pacing_state": "inactive",
		"opening_grace_frames": 0,
		"opening_grace_total_frames": FACTORY_SPARK_RAT_OPENING_GRACE_FRAMES,
	}


func _get_lower_deck_forward_exit_guard_pacing_diagnostics() -> Dictionary:
	if (
		_lower_deck_forward_exit_guard_spark_rat != null
		and _lower_deck_forward_exit_guard_spark_rat.has_method("get_pacing_diagnostics")
	):
		var pacing_variant: Variant = _lower_deck_forward_exit_guard_spark_rat.call(
			"get_pacing_diagnostics"
		)
		if pacing_variant is Dictionary:
			return (pacing_variant as Dictionary).duplicate(true)
	return {
		"pacing_state": "inactive",
		"opening_grace_frames": 0,
		"opening_grace_total_frames": FACTORY_SPARK_RAT_OPENING_GRACE_FRAMES,
	}


func _get_lower_deck_forward_beacon_ambush_pacing_diagnostics() -> Dictionary:
	if (
		_lower_deck_forward_beacon_ambush_spark_rat != null
		and _lower_deck_forward_beacon_ambush_spark_rat.has_method(
			"get_pacing_diagnostics"
		)
	):
		var pacing_variant: Variant = _lower_deck_forward_beacon_ambush_spark_rat.call(
			"get_pacing_diagnostics"
		)
		if pacing_variant is Dictionary:
			return (pacing_variant as Dictionary).duplicate(true)
	return {
		"pacing_state": "inactive",
		"opening_grace_frames": 0,
		"opening_grace_total_frames": FACTORY_SPARK_RAT_OPENING_GRACE_FRAMES,
	}


func _get_lower_deck_forward_overrun_pacing_diagnostics() -> Dictionary:
	if (
		_lower_deck_forward_overrun_spark_rat != null
		and _lower_deck_forward_overrun_spark_rat.has_method(
			"get_pacing_diagnostics"
		)
	):
		var pacing_variant: Variant = _lower_deck_forward_overrun_spark_rat.call(
			"get_pacing_diagnostics"
		)
		if pacing_variant is Dictionary:
			return (pacing_variant as Dictionary).duplicate(true)
	return {
		"pacing_state": "inactive",
		"opening_grace_frames": 0,
		"opening_grace_total_frames": FACTORY_SPARK_RAT_OPENING_GRACE_FRAMES,
	}


func _get_lower_deck_forward_breaker_pacing_diagnostics() -> Dictionary:
	if (
		_lower_deck_forward_breaker_spark_rat != null
		and _lower_deck_forward_breaker_spark_rat.has_method(
			"get_pacing_diagnostics"
		)
	):
		var pacing_variant: Variant = _lower_deck_forward_breaker_spark_rat.call(
			"get_pacing_diagnostics"
		)
		if pacing_variant is Dictionary:
			return (pacing_variant as Dictionary).duplicate(true)
	return {
		"pacing_state": "inactive",
		"opening_grace_frames": 0,
		"opening_grace_total_frames": FACTORY_SPARK_RAT_OPENING_GRACE_FRAMES,
	}


func _get_lower_deck_forward_relief_ambush_pacing_diagnostics() -> Dictionary:
	if (
		_lower_deck_forward_relief_ambush_spark_rat != null
		and _lower_deck_forward_relief_ambush_spark_rat.has_method(
			"get_pacing_diagnostics"
		)
	):
		var pacing_variant: Variant = _lower_deck_forward_relief_ambush_spark_rat.call(
			"get_pacing_diagnostics"
		)
		if pacing_variant is Dictionary:
			return (pacing_variant as Dictionary).duplicate(true)
	return {
		"pacing_state": "inactive",
		"opening_grace_frames": 0,
		"opening_grace_total_frames": FACTORY_SPARK_RAT_OPENING_GRACE_FRAMES,
	}


func _get_lower_deck_forward_pressure_coil_rat_pacing_diagnostics() -> Dictionary:
	if (
		_lower_deck_forward_pressure_coil_rat != null
		and _lower_deck_forward_pressure_coil_rat.has_method(
			"get_pacing_diagnostics"
		)
	):
		var pacing_variant: Variant = _lower_deck_forward_pressure_coil_rat.call(
			"get_pacing_diagnostics"
		)
		if pacing_variant is Dictionary:
			return (pacing_variant as Dictionary).duplicate(true)
	return {
		"pacing_state": "inactive",
		"opening_grace_frames": 0,
		"opening_grace_total_frames": FACTORY_SPARK_RAT_OPENING_GRACE_FRAMES,
	}


func _get_lower_deck_forward_pressure_coil_pincer_pacing_diagnostics() -> Dictionary:
	return {
		"spark": _get_lower_deck_forward_pressure_coil_pincer_enemy_pacing_diagnostics(
			_lower_deck_forward_pressure_coil_pincer_spark_rat,
			FACTORY_COIL_PINCER_SPARK_RAT_OPENING_GRACE_FRAMES
		),
		"coil": _get_lower_deck_forward_pressure_coil_pincer_enemy_pacing_diagnostics(
			_lower_deck_forward_pressure_coil_pincer_coil_rat,
			FACTORY_COIL_PINCER_COIL_RAT_OPENING_GRACE_FRAMES
		),
	}


func _get_lower_deck_forward_pressure_coil_pincer_enemy_pacing_diagnostics(
		enemy: Variant,
		default_grace_frames: int
) -> Dictionary:
	var enemy_node: Node2D = _get_valid_node2d(enemy)
	if enemy_node != null and enemy_node.has_method("get_pacing_diagnostics"):
		var pacing_variant: Variant = enemy_node.call("get_pacing_diagnostics")
		if pacing_variant is Dictionary:
			return (pacing_variant as Dictionary).duplicate(true)
	return {
		"pacing_state": "inactive",
		"opening_grace_frames": 0,
		"opening_grace_total_frames": default_grace_frames,
	}


func _get_lower_deck_forward_pressure_coil_aftershock_pacing_diagnostics() -> Dictionary:
	if (
		_lower_deck_forward_pressure_coil_aftershock_coil_rat != null
		and _lower_deck_forward_pressure_coil_aftershock_coil_rat.has_method(
			"get_pacing_diagnostics"
		)
	):
		var pacing_variant: Variant = (
			_lower_deck_forward_pressure_coil_aftershock_coil_rat.call(
				"get_pacing_diagnostics"
			)
		)
		if pacing_variant is Dictionary:
			return (pacing_variant as Dictionary).duplicate(true)
	return {
		"pacing_state": "inactive",
		"opening_grace_frames": 0,
		"opening_grace_total_frames": FACTORY_COIL_AFTERSHOCK_COIL_RAT_OPENING_GRACE_FRAMES,
	}


func _get_overflow_pump_pacing_diagnostics() -> Dictionary:
	var pacing: Dictionary = (
		_get_lower_deck_forward_pressure_coil_pincer_enemy_pacing_diagnostics(
			_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_coil_rat,
			FACTORY_AFTERSHOCK_CONDENSER_OVERFLOW_COIL_OPENING_GRACE_FRAMES
		)
	)
	pacing["active"] = _is_overflow_pump_active()
	return pacing


func _get_overflow_pump_runoff_exit_pacing_diagnostics() -> Dictionary:
	var pacing: Dictionary = (
		_get_lower_deck_forward_pressure_coil_pincer_enemy_pacing_diagnostics(
			_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_coil_rat,
			FACTORY_AFTERSHOCK_CONDENSER_OVERFLOW_RUNOFF_EXIT_COIL_OPENING_GRACE_FRAMES
		)
	)
	pacing["active"] = _is_overflow_pump_runoff_exit_skirmish_active()
	return pacing


func _get_overflow_pump_runoff_outlet_skirmish_pacing_diagnostics() -> Dictionary:
	var pacing: Dictionary = (
		_get_lower_deck_forward_pressure_coil_pincer_enemy_pacing_diagnostics(
			_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_spark_rat,
			FACTORY_AFTERSHOCK_CONDENSER_OVERFLOW_RUNOFF_OUTLET_SPARK_OPENING_GRACE_FRAMES
		)
	)
	pacing["active"] = _is_overflow_pump_runoff_outlet_skirmish_active()
	return pacing


func _get_overflow_pump_runoff_outlet_service_sluice_skirmish_pacing_diagnostics(
) -> Dictionary:
	var pacing: Dictionary = (
		_get_lower_deck_forward_pressure_coil_pincer_enemy_pacing_diagnostics(
			_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_spark_rat,
			FACTORY_AFTERSHOCK_CONDENSER_OVERFLOW_RUNOFF_OUTLET_SERVICE_SLUICE_SPARK_OPENING_GRACE_FRAMES
		)
	)
	pacing["active"] = _is_overflow_pump_runoff_outlet_service_sluice_skirmish_active()
	return pacing


func _get_lower_deck_forward_pressure_aftershock_exit_skirmish_pacing_diagnostics(
) -> Dictionary:
	return {
		"spark": _get_lower_deck_forward_pressure_coil_pincer_enemy_pacing_diagnostics(
			_lower_deck_forward_pressure_aftershock_exit_spark_rat,
			FACTORY_AFTERSHOCK_EXIT_SPARK_RAT_OPENING_GRACE_FRAMES
		),
		"coil": _get_lower_deck_forward_pressure_coil_pincer_enemy_pacing_diagnostics(
			_lower_deck_forward_pressure_aftershock_exit_coil_rat,
			FACTORY_AFTERSHOCK_EXIT_COIL_RAT_OPENING_GRACE_FRAMES
		),
	}


func _get_lower_deck_forward_pressure_aftershock_exhaust_pursuer_pacing_diagnostics(
) -> Dictionary:
	var pacing: Dictionary = {
		"pacing_state": "inactive",
		"opening_grace_frames": 0,
		"opening_grace_total_frames": (
			FACTORY_AFTERSHOCK_EXHAUST_PURSUER_OPENING_GRACE_FRAMES
		),
	}
	if (
		_lower_deck_forward_pressure_aftershock_exhaust_pursuer_coil_rat != null
		and _lower_deck_forward_pressure_aftershock_exhaust_pursuer_coil_rat.has_method(
			"get_pacing_diagnostics"
		)
	):
		var pacing_variant: Variant = (
			_lower_deck_forward_pressure_aftershock_exhaust_pursuer_coil_rat.call(
				"get_pacing_diagnostics"
			)
		)
		if pacing_variant is Dictionary:
			pacing = (pacing_variant as Dictionary).duplicate(true)
	pacing["active"] = _is_lower_deck_forward_pressure_aftershock_exhaust_pursuer_active()
	pacing["coil_opening_grace_frames"] = int(pacing.get(
		"opening_grace_total_frames",
		FACTORY_AFTERSHOCK_EXHAUST_PURSUER_OPENING_GRACE_FRAMES
	))
	return pacing


func _get_lower_deck_forward_pressure_aftershock_exhaust_flank_pacing_diagnostics(
) -> Dictionary:
	var pacing: Dictionary = {
		"pacing_state": "inactive",
		"opening_grace_frames": 0,
		"opening_grace_total_frames": (
			FACTORY_AFTERSHOCK_EXHAUST_FLANK_OPENING_GRACE_FRAMES
		),
	}
	var spark_rat: Node2D = (
		_lower_deck_forward_pressure_aftershock_exhaust_flank_spark_rat
		if is_instance_valid(
			_lower_deck_forward_pressure_aftershock_exhaust_flank_spark_rat
		)
		else null
	)
	if (
		spark_rat != null
		and spark_rat.has_method("get_pacing_diagnostics")
	):
		var pacing_variant: Variant = (
			spark_rat.call("get_pacing_diagnostics")
		)
		if pacing_variant is Dictionary:
			pacing = (pacing_variant as Dictionary).duplicate(true)
	pacing["active"] = _is_lower_deck_forward_pressure_aftershock_exhaust_flank_active()
	pacing["remaining_opening_grace_frames"] = int(pacing.get(
		"opening_grace_frames",
		0
	))
	pacing["opening_grace_frames"] = int(pacing.get(
		"opening_grace_total_frames",
		FACTORY_AFTERSHOCK_EXHAUST_FLANK_OPENING_GRACE_FRAMES
	))
	return pacing


func _get_lower_deck_forward_pressure_aftershock_exhaust_breaker_pacing_diagnostics(
) -> Dictionary:
	var pacing: Dictionary = {
		"pacing_state": "inactive",
		"opening_grace_frames": 0,
		"opening_grace_total_frames": (
			FACTORY_AFTERSHOCK_EXHAUST_BREAKER_OPENING_GRACE_FRAMES
		),
	}
	if (
		_lower_deck_forward_pressure_aftershock_exhaust_breaker_coil_rat != null
		and _lower_deck_forward_pressure_aftershock_exhaust_breaker_coil_rat.has_method(
			"get_pacing_diagnostics"
		)
	):
		var pacing_variant: Variant = (
			_lower_deck_forward_pressure_aftershock_exhaust_breaker_coil_rat.call(
				"get_pacing_diagnostics"
			)
		)
		if pacing_variant is Dictionary:
			pacing = (pacing_variant as Dictionary).duplicate(true)
	pacing["active"] = _is_lower_deck_forward_pressure_aftershock_exhaust_breaker_stand_active()
	pacing["coil_opening_grace_frames"] = int(pacing.get(
		"opening_grace_total_frames",
		FACTORY_AFTERSHOCK_EXHAUST_BREAKER_OPENING_GRACE_FRAMES
	))
	return pacing


func _get_lower_deck_forward_pressure_aftershock_exhaust_escape_skirmish_pacing_diagnostics(
) -> Dictionary:
	return {
		"active": (
			_is_lower_deck_forward_pressure_aftershock_exhaust_escape_skirmish_active()
		),
		"spark": _get_lower_deck_forward_pressure_coil_pincer_enemy_pacing_diagnostics(
			_lower_deck_forward_pressure_aftershock_exhaust_escape_spark_rat,
			FACTORY_AFTERSHOCK_EXHAUST_ESCAPE_SPARK_OPENING_GRACE_FRAMES
		),
		"coil": _get_lower_deck_forward_pressure_coil_pincer_enemy_pacing_diagnostics(
			_lower_deck_forward_pressure_aftershock_exhaust_escape_coil_rat,
			FACTORY_AFTERSHOCK_EXHAUST_ESCAPE_COIL_OPENING_GRACE_FRAMES
		),
		"spark_opening_grace_frames": (
			FACTORY_AFTERSHOCK_EXHAUST_ESCAPE_SPARK_OPENING_GRACE_FRAMES
		),
		"coil_opening_grace_frames": (
			FACTORY_AFTERSHOCK_EXHAUST_ESCAPE_COIL_OPENING_GRACE_FRAMES
		),
	}


func _get_lower_deck_forward_exit_guard_opening_grace_frames() -> int:
	var pacing: Dictionary = _get_lower_deck_forward_exit_guard_pacing_diagnostics()
	return int(pacing.get("opening_grace_frames", 0))


func _does_deep_guard_have_target() -> bool:
	if _deep_guard == null:
		return false
	if _deep_guard.has_method("has_attack_target"):
		return bool(_deep_guard.call("has_attack_target"))
	return _deep_guard_activated and not _deep_guard_defeated


func _does_spark_rat_have_target() -> bool:
	if _spark_rat == null:
		return false
	if _spark_rat.has_method("has_attack_target"):
		return bool(_spark_rat.call("has_attack_target"))
	return _spark_rat_activated and not _spark_rat_defeated


func _does_return_spark_rat_have_target() -> bool:
	if _return_spark_rat == null:
		return false
	if _return_spark_rat.has_method("has_attack_target"):
		return bool(_return_spark_rat.call("has_attack_target"))
	return _return_patrol_activated and not _return_patrol_defeated


func _does_checkpoint_forward_spark_rat_have_target() -> bool:
	if _checkpoint_forward_spark_rat == null:
		return false
	if _checkpoint_forward_spark_rat.has_method("has_attack_target"):
		return bool(_checkpoint_forward_spark_rat.call("has_attack_target"))
	return _checkpoint_forward_patrol_activated and not _checkpoint_forward_patrol_defeated


func _does_checkpoint_rear_spark_rat_have_target() -> bool:
	if _checkpoint_rear_spark_rat == null:
		return false
	if _checkpoint_rear_spark_rat.has_method("has_attack_target"):
		return bool(_checkpoint_rear_spark_rat.call("has_attack_target"))
	return _checkpoint_rear_ambush_activated and not _checkpoint_rear_ambush_defeated


func _does_checkpoint_overdrive_left_spark_rat_have_target() -> bool:
	return _does_checkpoint_overdrive_spark_rat_have_target(
		_checkpoint_overdrive_left_spark_rat,
		_checkpoint_overdrive_left_defeated
	)


func _does_checkpoint_overdrive_right_spark_rat_have_target() -> bool:
	return _does_checkpoint_overdrive_spark_rat_have_target(
		_checkpoint_overdrive_right_spark_rat,
		_checkpoint_overdrive_right_defeated
	)


func _does_checkpoint_overdrive_spark_rat_have_target(
	spark_rat: Node2D,
	defeated: bool
) -> bool:
	if spark_rat == null:
		return false
	if spark_rat.has_method("has_attack_target"):
		return bool(spark_rat.call("has_attack_target"))
	return _checkpoint_overdrive_duo_activated and not defeated


func _does_lower_deck_spark_rat_have_target() -> bool:
	if _lower_deck_spark_rat == null:
		return false
	if _lower_deck_spark_rat.has_method("has_attack_target"):
		return bool(_lower_deck_spark_rat.call("has_attack_target"))
	return _lower_deck_skirmish_activated and not _lower_deck_skirmish_defeated


func _does_lower_deck_exit_spark_rat_have_target() -> bool:
	if _lower_deck_exit_spark_rat == null:
		return false
	if _lower_deck_exit_spark_rat.has_method("has_attack_target"):
		return bool(_lower_deck_exit_spark_rat.call("has_attack_target"))
	return _lower_deck_exit_ambush_activated and not _lower_deck_exit_ambush_defeated


func _does_lower_deck_shortcut_spark_rat_have_target() -> bool:
	if _lower_deck_shortcut_spark_rat == null:
		return false
	if _lower_deck_shortcut_spark_rat.has_method("has_attack_target"):
		return bool(_lower_deck_shortcut_spark_rat.call("has_attack_target"))
	return _lower_deck_shortcut_activated and not _lower_deck_shortcut_guard_defeated


func _does_lower_deck_shortcut_pursuer_have_target() -> bool:
	if _lower_deck_shortcut_pursuer_spark_rat == null:
		return false
	if _lower_deck_shortcut_pursuer_spark_rat.has_method("has_attack_target"):
		return bool(_lower_deck_shortcut_pursuer_spark_rat.call("has_attack_target"))
	return _is_lower_deck_shortcut_pursuer_active()


func _does_lower_deck_pressure_guard_have_target() -> bool:
	if _lower_deck_pressure_guard_spark_rat == null:
		return false
	if _lower_deck_pressure_guard_spark_rat.has_method("has_attack_target"):
		return bool(_lower_deck_pressure_guard_spark_rat.call("has_attack_target"))
	return _is_lower_deck_pressure_guard_active()


func _does_lower_deck_steam_sluice_have_target() -> bool:
	if _lower_deck_steam_sluice_spark_rat == null:
		return false
	if _lower_deck_steam_sluice_spark_rat.has_method("has_attack_target"):
		return bool(_lower_deck_steam_sluice_spark_rat.call("has_attack_target"))
	return _is_lower_deck_steam_sluice_active()


func _does_lower_deck_deep_bulkhead_guard_have_target() -> bool:
	if _lower_deck_deep_bulkhead_spark_rat == null:
		return false
	if _lower_deck_deep_bulkhead_spark_rat.has_method("has_attack_target"):
		return bool(_lower_deck_deep_bulkhead_spark_rat.call("has_attack_target"))
	return _is_lower_deck_deep_bulkhead_guard_active()


func _does_lower_deck_post_relay_trial_have_target() -> bool:
	if _lower_deck_post_relay_spark_rat == null:
		return false
	if _lower_deck_post_relay_spark_rat.has_method("has_attack_target"):
		return bool(_lower_deck_post_relay_spark_rat.call("has_attack_target"))
	return _is_lower_deck_post_relay_trial_active()


func _does_lower_deck_forward_conduit_have_target() -> bool:
	if _lower_deck_forward_conduit_spark_rat == null:
		return false
	if _lower_deck_forward_conduit_spark_rat.has_method("has_attack_target"):
		return bool(_lower_deck_forward_conduit_spark_rat.call("has_attack_target"))
	return _is_lower_deck_forward_conduit_active()


func _does_lower_deck_forward_counter_ambush_have_target() -> bool:
	if _lower_deck_forward_counter_spark_rat == null:
		return false
	if _lower_deck_forward_counter_spark_rat.has_method("has_attack_target"):
		return bool(_lower_deck_forward_counter_spark_rat.call("has_attack_target"))
	return _is_lower_deck_forward_pressure_counter_ambush_active()


func _does_lower_deck_forward_exit_guard_have_target() -> bool:
	if _lower_deck_forward_exit_guard_spark_rat == null:
		return false
	if _lower_deck_forward_exit_guard_spark_rat.has_method("has_attack_target"):
		return bool(_lower_deck_forward_exit_guard_spark_rat.call("has_attack_target"))
	return _is_lower_deck_forward_pressure_exit_guard_active()


func _does_lower_deck_forward_beacon_ambush_have_target() -> bool:
	if _lower_deck_forward_beacon_ambush_spark_rat == null:
		return false
	if _lower_deck_forward_beacon_ambush_spark_rat.has_method("has_attack_target"):
		return bool(_lower_deck_forward_beacon_ambush_spark_rat.call("has_attack_target"))
	return _is_lower_deck_forward_pressure_beacon_ambush_active()


func _does_lower_deck_forward_overrun_have_target() -> bool:
	if _lower_deck_forward_overrun_spark_rat == null:
		return false
	if _lower_deck_forward_overrun_spark_rat.has_method("has_attack_target"):
		return bool(_lower_deck_forward_overrun_spark_rat.call("has_attack_target"))
	return _is_lower_deck_forward_pressure_overrun_active()


func _does_lower_deck_forward_breaker_have_target() -> bool:
	if _lower_deck_forward_breaker_spark_rat == null:
		return false
	if _lower_deck_forward_breaker_spark_rat.has_method("has_attack_target"):
		return bool(_lower_deck_forward_breaker_spark_rat.call("has_attack_target"))
	return _is_lower_deck_forward_pressure_breaker_stand_active()


func _does_lower_deck_forward_relief_ambush_have_target() -> bool:
	if _lower_deck_forward_relief_ambush_spark_rat == null:
		return false
	if _lower_deck_forward_relief_ambush_spark_rat.has_method("has_attack_target"):
		return bool(_lower_deck_forward_relief_ambush_spark_rat.call(
			"has_attack_target"
		))
	return _is_lower_deck_forward_pressure_relief_ambush_active()


func _does_lower_deck_forward_pressure_coil_rat_have_target() -> bool:
	if _lower_deck_forward_pressure_coil_rat == null:
		return false
	if _lower_deck_forward_pressure_coil_rat.has_method("has_attack_target"):
		return bool(_lower_deck_forward_pressure_coil_rat.call("has_attack_target"))
	return _is_lower_deck_forward_pressure_coil_rat_active()


func _does_lower_deck_forward_pressure_coil_pincer_spark_rat_have_target() -> bool:
	if _lower_deck_forward_pressure_coil_pincer_spark_rat == null:
		return false
	if _lower_deck_forward_pressure_coil_pincer_spark_rat.has_method("has_attack_target"):
		return bool(_lower_deck_forward_pressure_coil_pincer_spark_rat.call(
			"has_attack_target"
		))
	return _is_lower_deck_forward_pressure_coil_pincer_active()


func _does_lower_deck_forward_pressure_coil_pincer_coil_rat_have_target() -> bool:
	if _lower_deck_forward_pressure_coil_pincer_coil_rat == null:
		return false
	if _lower_deck_forward_pressure_coil_pincer_coil_rat.has_method("has_attack_target"):
		return bool(_lower_deck_forward_pressure_coil_pincer_coil_rat.call(
			"has_attack_target"
		))
	return _is_lower_deck_forward_pressure_coil_pincer_active()


func _does_lower_deck_forward_pressure_coil_aftershock_coil_rat_have_target() -> bool:
	if _lower_deck_forward_pressure_coil_aftershock_coil_rat == null:
		return false
	if _lower_deck_forward_pressure_coil_aftershock_coil_rat.has_method(
		"has_attack_target"
	):
		return bool(_lower_deck_forward_pressure_coil_aftershock_coil_rat.call(
			"has_attack_target"
			))
	return _is_lower_deck_forward_pressure_coil_aftershock_active()


func _does_lower_deck_forward_pressure_aftershock_exit_spark_rat_have_target() -> bool:
	if _lower_deck_forward_pressure_aftershock_exit_spark_rat == null:
		return false
	if _lower_deck_forward_pressure_aftershock_exit_spark_rat.has_method(
		"has_attack_target"
	):
		return bool(_lower_deck_forward_pressure_aftershock_exit_spark_rat.call(
			"has_attack_target"
		))
	return _is_lower_deck_forward_pressure_aftershock_exit_skirmish_active()


func _does_lower_deck_forward_pressure_aftershock_exit_coil_rat_have_target() -> bool:
	if _lower_deck_forward_pressure_aftershock_exit_coil_rat == null:
		return false
	if _lower_deck_forward_pressure_aftershock_exit_coil_rat.has_method(
		"has_attack_target"
	):
		return bool(_lower_deck_forward_pressure_aftershock_exit_coil_rat.call(
			"has_attack_target"
		))
	return _is_lower_deck_forward_pressure_aftershock_exit_skirmish_active()


func _does_lower_deck_forward_pressure_aftershock_exhaust_pursuer_coil_rat_have_target(
) -> bool:
	if _lower_deck_forward_pressure_aftershock_exhaust_pursuer_coil_rat == null:
		return false
	if _lower_deck_forward_pressure_aftershock_exhaust_pursuer_coil_rat.has_method(
		"has_attack_target"
	):
		return bool(_lower_deck_forward_pressure_aftershock_exhaust_pursuer_coil_rat.call(
			"has_attack_target"
		))
	return _is_lower_deck_forward_pressure_aftershock_exhaust_pursuer_active()


func _does_lower_deck_forward_pressure_aftershock_exhaust_flank_spark_rat_have_target(
) -> bool:
	var spark_rat: Node2D = (
		_lower_deck_forward_pressure_aftershock_exhaust_flank_spark_rat
		if is_instance_valid(
			_lower_deck_forward_pressure_aftershock_exhaust_flank_spark_rat
		)
		else null
	)
	if spark_rat == null:
		return false
	if spark_rat.has_method("has_attack_target"):
		return bool(spark_rat.call("has_attack_target"))
	return _is_lower_deck_forward_pressure_aftershock_exhaust_flank_active()


func _does_lower_deck_forward_pressure_aftershock_exhaust_breaker_coil_rat_have_target(
) -> bool:
	if _lower_deck_forward_pressure_aftershock_exhaust_breaker_coil_rat == null:
		return false
	if _lower_deck_forward_pressure_aftershock_exhaust_breaker_coil_rat.has_method(
		"has_attack_target"
	):
		return bool(_lower_deck_forward_pressure_aftershock_exhaust_breaker_coil_rat.call(
			"has_attack_target"
		))
	return _is_lower_deck_forward_pressure_aftershock_exhaust_breaker_stand_active()


func _does_lower_deck_forward_pressure_aftershock_exhaust_escape_spark_rat_have_target(
) -> bool:
	var spark_rat: Node2D = _get_valid_node2d(
		_lower_deck_forward_pressure_aftershock_exhaust_escape_spark_rat
	)
	if spark_rat == null:
		return false
	if spark_rat.has_method("has_attack_target"):
		return bool(spark_rat.call("has_attack_target"))
	return _is_lower_deck_forward_pressure_aftershock_exhaust_escape_skirmish_active()


func _does_lower_deck_forward_pressure_aftershock_exhaust_escape_coil_rat_have_target(
) -> bool:
	var coil_rat: Node2D = _get_valid_node2d(
		_lower_deck_forward_pressure_aftershock_exhaust_escape_coil_rat
	)
	if coil_rat == null:
		return false
	if coil_rat.has_method("has_attack_target"):
		return bool(coil_rat.call("has_attack_target"))
	return _is_lower_deck_forward_pressure_aftershock_exhaust_escape_skirmish_active()


func _does_lower_deck_forward_pressure_aftershock_condenser_spark_rat_have_target(
) -> bool:
	var spark_rat: Node2D = _get_valid_node2d(
		_lower_deck_forward_pressure_aftershock_condenser_spark_rat
	)
	if spark_rat == null:
		return false
	if spark_rat.has_method("has_attack_target"):
		return bool(spark_rat.call("has_attack_target"))
	return _is_lower_deck_forward_pressure_aftershock_condenser_valve_active()


func _does_lower_deck_forward_pressure_aftershock_condenser_coil_rat_have_target(
) -> bool:
	var coil_rat: Node2D = _get_valid_node2d(
		_lower_deck_forward_pressure_aftershock_condenser_coil_rat
	)
	if coil_rat == null:
		return false
	if coil_rat.has_method("has_attack_target"):
		return bool(coil_rat.call("has_attack_target"))
	return _is_lower_deck_forward_pressure_aftershock_condenser_valve_active()


func _does_outlet_clamp_spark_rat_have_target() -> bool:
	var spark_rat: Node2D = _get_valid_node2d(
		_lower_deck_forward_pressure_aftershock_condenser_outlet_clamp_spark_rat
	)
	if spark_rat == null:
		return false
	if spark_rat.has_method("has_attack_target"):
		return bool(spark_rat.call("has_attack_target"))
	return _is_outlet_clamp_ambush_active()


func _does_overflow_pump_coil_rat_have_target() -> bool:
	var coil_rat: Node2D = _get_valid_node2d(
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_coil_rat
	)
	if coil_rat == null:
		return false
	if coil_rat.has_method("has_attack_target"):
		return bool(coil_rat.call("has_attack_target"))
	return _is_overflow_pump_active()


func _does_overflow_pump_runoff_exit_coil_rat_have_target() -> bool:
	var coil_rat: Node2D = _get_valid_node2d(
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_coil_rat
	)
	if coil_rat == null:
		return false
	if coil_rat.has_method("has_attack_target"):
		return bool(coil_rat.call("has_attack_target"))
	return _is_overflow_pump_runoff_exit_skirmish_active()


func _does_overflow_pump_runoff_outlet_spark_rat_have_target() -> bool:
	var spark_rat: Node2D = _get_valid_node2d(
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_spark_rat
	)
	if spark_rat == null:
		return false
	if spark_rat.has_method("has_attack_target"):
		return bool(spark_rat.call("has_attack_target"))
	return _is_overflow_pump_runoff_outlet_skirmish_active()


func _does_overflow_pump_runoff_outlet_service_sluice_spark_rat_have_target() -> bool:
	var spark_rat: Node2D = _get_valid_node2d(
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_spark_rat
	)
	if spark_rat == null:
		return false
	if spark_rat.has_method("has_attack_target"):
		return bool(spark_rat.call("has_attack_target"))
	return _is_overflow_pump_runoff_outlet_service_sluice_skirmish_active()


func _does_lower_deck_breach_front_have_target() -> bool:
	if _lower_deck_breach_front_spark_rat == null:
		return false
	if _lower_deck_breach_front_spark_rat.has_method("has_attack_target"):
		return bool(_lower_deck_breach_front_spark_rat.call("has_attack_target"))
	return _is_lower_deck_breach_front_active()


func _does_lower_deck_breach_rear_have_target() -> bool:
	if _lower_deck_breach_rear_spark_rat == null:
		return false
	if _lower_deck_breach_rear_spark_rat.has_method("has_attack_target"):
		return bool(_lower_deck_breach_rear_spark_rat.call("has_attack_target"))
	return _is_lower_deck_breach_rear_active()


func _sync_factory_damage_target_defeat(target_id: int, damage_target: Node) -> void:
	if not _is_factory_damage_target_defeated(damage_target):
		return
	match target_id:
		FACTORY_ENTRY_GUARD_ENTITY_ID:
			if not _encounter_cleared:
				_on_factory_enemy_defeated()
		FACTORY_DEEP_GUARD_ENTITY_ID:
			if not _deep_guard_defeated:
				_on_factory_deep_guard_defeated()
		FACTORY_SPARK_RAT_ENTITY_ID:
			if not _spark_rat_defeated:
				_on_factory_spark_rat_defeated()
		FACTORY_RETURN_SPARK_RAT_ENTITY_ID:
			if not _return_patrol_defeated:
				_on_factory_return_spark_rat_defeated()
		FACTORY_CHECKPOINT_FORWARD_SPARK_RAT_ENTITY_ID:
			if not _checkpoint_forward_patrol_defeated:
				_on_factory_checkpoint_forward_spark_rat_defeated()
		FACTORY_CHECKPOINT_REAR_SPARK_RAT_ENTITY_ID:
			if not _checkpoint_rear_ambush_defeated:
				_on_factory_checkpoint_rear_spark_rat_defeated()
		FACTORY_CHECKPOINT_OVERDRIVE_LEFT_SPARK_RAT_ENTITY_ID:
			if not _checkpoint_overdrive_left_defeated:
				_on_factory_checkpoint_overdrive_left_spark_rat_defeated()
		FACTORY_CHECKPOINT_OVERDRIVE_RIGHT_SPARK_RAT_ENTITY_ID:
			if not _checkpoint_overdrive_right_defeated:
				_on_factory_checkpoint_overdrive_right_spark_rat_defeated()
		FACTORY_LOWER_DECK_SPARK_RAT_ENTITY_ID:
			if not _lower_deck_skirmish_defeated:
				_on_factory_lower_deck_spark_rat_defeated()
		FACTORY_LOWER_DECK_EXIT_SPARK_RAT_ENTITY_ID:
			if not _lower_deck_exit_ambush_defeated:
				_on_factory_lower_deck_exit_spark_rat_defeated()
		FACTORY_LOWER_DECK_SHORTCUT_SPARK_RAT_ENTITY_ID:
			if not _lower_deck_shortcut_guard_defeated:
				_on_factory_lower_deck_shortcut_spark_rat_defeated()
		FACTORY_LOWER_DECK_SHORTCUT_PURSUER_ENTITY_ID:
			if not _lower_deck_shortcut_pursuer_defeated:
				_on_factory_lower_deck_shortcut_pursuer_defeated()
		FACTORY_LOWER_DECK_PRESSURE_GUARD_ENTITY_ID:
			if not _lower_deck_pressure_guard_defeated:
				_on_factory_lower_deck_pressure_guard_defeated()
		FACTORY_LOWER_DECK_STEAM_SLUICE_ENTITY_ID:
			if not _lower_deck_steam_sluice_defeated:
				_on_factory_lower_deck_steam_sluice_defeated()
		FACTORY_LOWER_DECK_DEEP_BULKHEAD_ENTITY_ID:
			if not _lower_deck_deep_bulkhead_guard_defeated:
				_on_factory_lower_deck_deep_bulkhead_guard_defeated()
		FACTORY_LOWER_DECK_BREACH_FRONT_ENTITY_ID:
			if not _lower_deck_breach_front_guard_defeated:
				_on_factory_lower_deck_breach_front_guard_defeated()
		FACTORY_LOWER_DECK_BREACH_REAR_ENTITY_ID:
			if not _lower_deck_breach_rear_ambusher_defeated:
				_on_factory_lower_deck_breach_rear_ambusher_defeated()
		FACTORY_LOWER_DECK_POST_RELAY_ENTITY_ID:
			if not _lower_deck_post_relay_trial_defeated:
				_on_factory_lower_deck_post_relay_trial_defeated()
		FACTORY_LOWER_DECK_FORWARD_CONDUIT_ENTITY_ID:
			if not _lower_deck_forward_conduit_defeated:
				_on_factory_lower_deck_forward_conduit_defeated()
		FACTORY_LOWER_DECK_FORWARD_COUNTER_AMBUSH_ENTITY_ID:
			if not _lower_deck_forward_pressure_counter_ambush_defeated:
				_on_factory_lower_deck_forward_pressure_counter_ambush_defeated()
		FACTORY_LOWER_DECK_FORWARD_EXIT_GUARD_ENTITY_ID:
			if not _lower_deck_forward_pressure_exit_guard_defeated:
				_on_factory_lower_deck_forward_pressure_exit_guard_defeated()
		FACTORY_LOWER_DECK_FORWARD_BEACON_AMBUSH_ENTITY_ID:
			if not _lower_deck_forward_pressure_beacon_ambush_defeated:
				_on_factory_lower_deck_forward_pressure_beacon_ambush_defeated()
		FACTORY_LOWER_DECK_FORWARD_OVERRUN_ENTITY_ID:
			if not _lower_deck_forward_pressure_overrun_defeated:
				_on_factory_lower_deck_forward_pressure_overrun_defeated()
		FACTORY_LOWER_DECK_FORWARD_BREAKER_ENTITY_ID:
			if not _lower_deck_forward_pressure_breaker_secured:
				_on_factory_lower_deck_forward_pressure_breaker_defeated()
		FACTORY_LOWER_DECK_FORWARD_RELIEF_AMBUSH_ENTITY_ID:
			if not _lower_deck_forward_pressure_relief_ambush_defeated:
				_on_factory_lower_deck_forward_pressure_relief_ambush_defeated()
		FACTORY_LOWER_DECK_FORWARD_COIL_RAT_ENTITY_ID:
			if not _lower_deck_forward_pressure_coil_rat_defeated:
				_on_factory_lower_deck_forward_pressure_coil_rat_defeated()
		FACTORY_LOWER_DECK_FORWARD_COIL_PINCER_SPARK_RAT_ENTITY_ID:
			if not _lower_deck_forward_pressure_coil_pincer_spark_rat_defeated:
				_on_factory_lower_deck_forward_pressure_coil_pincer_spark_rat_defeated()
		FACTORY_LOWER_DECK_FORWARD_COIL_PINCER_COIL_RAT_ENTITY_ID:
			if not _lower_deck_forward_pressure_coil_pincer_coil_rat_defeated:
				_on_factory_lower_deck_forward_pressure_coil_pincer_coil_rat_defeated()
		FACTORY_LOWER_DECK_FORWARD_COIL_AFTERSHOCK_COIL_RAT_ENTITY_ID:
			if not _lower_deck_forward_pressure_coil_aftershock_defeated:
				_on_factory_lower_deck_forward_pressure_coil_aftershock_defeated()
		FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_EXIT_SPARK_RAT_ENTITY_ID:
			if not _lower_deck_forward_pressure_aftershock_exit_spark_rat_defeated:
				_on_factory_lower_deck_forward_pressure_aftershock_exit_spark_rat_defeated()
		FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_EXIT_COIL_RAT_ENTITY_ID:
			if not _lower_deck_forward_pressure_aftershock_exit_coil_rat_defeated:
				_on_factory_lower_deck_forward_pressure_aftershock_exit_coil_rat_defeated()
		FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_EXHAUST_PURSUER_ENTITY_ID:
			if not _lower_deck_forward_pressure_aftershock_exhaust_pursuer_defeated:
				_on_factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_defeated()
		FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_EXHAUST_FLANK_ENTITY_ID:
			if (
				not _lower_deck_forward_pressure_aftershock_exhaust_flank_spark_rat_defeated
			):
				_on_factory_lower_deck_forward_pressure_aftershock_exhaust_flank_defeated()
		FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_EXHAUST_BREAKER_ENTITY_ID:
			if (
				not _lower_deck_forward_pressure_aftershock_exhaust_breaker_coil_rat_defeated
			):
				_on_factory_lower_deck_forward_pressure_aftershock_exhaust_breaker_defeated()
		FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_EXHAUST_ESCAPE_SPARK_ENTITY_ID:
			if (
				not _lower_deck_forward_pressure_aftershock_exhaust_escape_spark_rat_defeated
			):
				_on_factory_lower_deck_forward_pressure_aftershock_exhaust_escape_spark_rat_defeated()
		FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_EXHAUST_ESCAPE_COIL_ENTITY_ID:
			if (
				not _lower_deck_forward_pressure_aftershock_exhaust_escape_coil_rat_defeated
			):
				_on_factory_lower_deck_forward_pressure_aftershock_exhaust_escape_coil_rat_defeated()
		FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_CONDENSER_SPARK_ENTITY_ID:
			if (
				not _lower_deck_forward_pressure_aftershock_condenser_valve_spark_rat_defeated
			):
				_on_factory_lower_deck_forward_pressure_aftershock_condenser_spark_rat_defeated()
		FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_CONDENSER_COIL_ENTITY_ID:
			if (
				not _lower_deck_forward_pressure_aftershock_condenser_valve_coil_rat_defeated
			):
				_on_factory_lower_deck_forward_pressure_aftershock_condenser_coil_rat_defeated()
		FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_CONDENSER_CLAMP_SPARK_ENTITY_ID:
			if (
				not _lower_deck_forward_pressure_aftershock_condenser_outlet_clamp_spark_rat_defeated
			):
				_on_outlet_clamp_spark_rat_defeated()
		FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_CONDENSER_OVERFLOW_COIL_ENTITY_ID:
			if (
				not _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_coil_rat_defeated
			):
				_on_overflow_pump_coil_rat_defeated()
		FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_CONDENSER_OVERFLOW_RUNOFF_EXIT_COIL_ENTITY_ID:
			if (
				not _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_coil_rat_defeated
			):
				_on_overflow_pump_runoff_exit_coil_rat_defeated()
		FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_CONDENSER_OVERFLOW_RUNOFF_OUTLET_SPARK_ENTITY_ID:
			if (
				not _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_spark_rat_defeated
			):
				_on_overflow_pump_runoff_outlet_spark_rat_defeated()
		FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_CONDENSER_OVERFLOW_RUNOFF_OUTLET_SERVICE_SLUICE_SPARK_ENTITY_ID:
			if (
				not _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_spark_rat_defeated
			):
				_on_overflow_pump_runoff_outlet_service_sluice_spark_rat_defeated()


func _is_factory_damage_target_defeated(damage_target: Node) -> bool:
	if damage_target == null or not damage_target.has_method("get_current_hp"):
		return false
	return int(damage_target.call("get_current_hp")) <= 0


func _is_deep_guard_activation_provider_in_range(provider: Node) -> bool:
	if provider == null or not provider is Node2D:
		return false
	return (provider as Node2D).global_position.x >= FACTORY_DEEP_GUARD_ACTIVATION_X


func _is_spark_rat_activation_provider_in_range(provider: Node) -> bool:
	if provider == null or not provider is Node2D:
		return false
	return (provider as Node2D).global_position.x >= FACTORY_SPARK_RAT_ACTIVATION_X


func _is_checkpoint_forward_patrol_activation_provider_in_range(provider: Node) -> bool:
	if provider == null or not provider is Node2D:
		return false
	return (provider as Node2D).global_position.x >= FACTORY_CHECKPOINT_FORWARD_PATROL_ACTIVATION_X


func _is_checkpoint_rear_ambush_activation_provider_in_range(provider: Node) -> bool:
	if provider == null or not provider is Node2D:
		return false
	return (provider as Node2D).global_position.x >= FACTORY_CHECKPOINT_REAR_AMBUSH_ACTIVATION_X


func _is_checkpoint_overdrive_duo_activation_provider_in_range(provider: Node) -> bool:
	if provider == null or not provider is Node2D:
		return false
	return (provider as Node2D).global_position.x >= FACTORY_CHECKPOINT_OVERDRIVE_DUO_ACTIVATION_X


func _is_lower_deck_skirmish_activation_provider_in_range(provider: Node) -> bool:
	if provider == null or not provider is Node2D:
		return false
	return (provider as Node2D).global_position.x >= FACTORY_LOWER_DECK_SKIRMISH_ACTIVATION_X


func _is_lower_deck_shortcut_activation_provider_in_range(provider: Node) -> bool:
	if provider == null or not provider is Node2D:
		return false
	return (provider as Node2D).global_position.x >= FACTORY_LOWER_DECK_SHORTCUT_ACTIVATION_X


func _is_lower_deck_shortcut_pursuer_activation_provider_in_range(provider: Node) -> bool:
	if provider == null or not provider is Node2D:
		return false
	return (
		(provider as Node2D).global_position.x
		>= FACTORY_LOWER_DECK_SHORTCUT_PURSUER_ACTIVATION_X
	)


func _is_lower_deck_pressure_guard_activation_provider_in_range(provider: Node) -> bool:
	if provider == null or not provider is Node2D:
		return false
	return (
		(provider as Node2D).global_position.x
		>= FACTORY_LOWER_DECK_PRESSURE_VALVE_ACTIVATION_X
	)


func _is_lower_deck_steam_sluice_activation_provider_in_range(provider: Node) -> bool:
	if provider == null or not provider is Node2D:
		return false
	return (
		(provider as Node2D).global_position.x
		>= FACTORY_LOWER_DECK_STEAM_SLUICE_ACTIVATION_X
	)


func _is_lower_deck_deep_bulkhead_guard_activation_provider_in_range(provider: Node) -> bool:
	if provider == null or not provider is Node2D:
		return false
	return (
		(provider as Node2D).global_position.x
		>= FACTORY_LOWER_DECK_DEEP_BULKHEAD_ACTIVATION_X
	)


func _is_lower_deck_breach_corridor_activation_provider_in_range(provider: Node) -> bool:
	if provider == null or not provider is Node2D:
		return false
	return (
		(provider as Node2D).global_position.x
		>= FACTORY_LOWER_DECK_BREACH_CORRIDOR_ACTIVATION_X
	)


func _is_lower_deck_breach_rear_activation_provider_in_range(provider: Node) -> bool:
	if provider == null or not provider is Node2D:
		return false
	return (
		(provider as Node2D).global_position.x
		>= FACTORY_LOWER_DECK_BREACH_PINCER_MIDPOINT_X
	)


func _is_lower_deck_breach_relay_provider_in_range(provider: Node) -> bool:
	if provider == null or not provider is Node2D:
		return false
	if _lower_deck_breach_relay == null or not _lower_deck_breach_relay is Node2D:
		return false
	return (
		(provider as Node2D).global_position.distance_to(
			(_lower_deck_breach_relay as Node2D).global_position
		)
		<= FACTORY_RETURN_CHECKPOINT_ACTIVATION_RADIUS
	)


func _is_lower_deck_forward_pressure_exit_relay_provider_in_range(provider: Node) -> bool:
	if provider == null or not provider is Node2D:
		return false
	if (
		_lower_deck_forward_pressure_exit_relay == null
		or not _lower_deck_forward_pressure_exit_relay is Node2D
	):
		return false
	return (
		(provider as Node2D).global_position.distance_to(
			(_lower_deck_forward_pressure_exit_relay as Node2D).global_position
		)
		<= FACTORY_RETURN_CHECKPOINT_ACTIVATION_RADIUS
	)


func _is_lower_deck_forward_pressure_aftershock_condenser_savepoint_provider_in_range(
	provider: Node
) -> bool:
	if provider == null or not provider is Node2D:
		return false
	if (
		_lower_deck_forward_pressure_aftershock_condenser_savepoint == null
		or not _lower_deck_forward_pressure_aftershock_condenser_savepoint is Node2D
	):
		return false
	return (
		(provider as Node2D).global_position.distance_to(
			(
				_lower_deck_forward_pressure_aftershock_condenser_savepoint
				as Node2D
			).global_position
		)
		<= FACTORY_RETURN_CHECKPOINT_ACTIVATION_RADIUS
	)


func _is_lower_deck_forward_pressure_exit_gate_provider_in_range(provider: Node) -> bool:
	if provider == null or not provider is Node2D:
		return false
	if _lower_deck_forward_pressure_exit_gate == null:
		return false
	if _lower_deck_forward_pressure_exit_gate.has_method("is_provider_in_activation_range"):
		return bool(_lower_deck_forward_pressure_exit_gate.call(
			"is_provider_in_activation_range",
			provider
		))
	if not _lower_deck_forward_pressure_exit_gate is Node2D:
		return false
	return (
		(provider as Node2D).global_position.distance_to(
			(_lower_deck_forward_pressure_exit_gate as Node2D).global_position
		)
		<= FACTORY_RETURN_CHECKPOINT_ACTIVATION_RADIUS
	)


func _is_lower_deck_forward_pressure_route_handoff_marker_provider_in_range(
	provider: Node
) -> bool:
	if provider == null or not provider is Node2D:
		return false
	if _lower_deck_forward_pressure_route_handoff_marker == null:
		return false
	if _lower_deck_forward_pressure_route_handoff_marker.has_method(
		"is_provider_in_activation_range"
	):
		return bool(_lower_deck_forward_pressure_route_handoff_marker.call(
			"is_provider_in_activation_range",
			provider
		))
	if not _lower_deck_forward_pressure_route_handoff_marker is Node2D:
		return false
	return (
		(provider as Node2D).global_position.distance_to(
			(_lower_deck_forward_pressure_route_handoff_marker as Node2D).global_position
		)
		<= FACTORY_RETURN_CHECKPOINT_ACTIVATION_RADIUS
	)


func _is_lower_deck_post_relay_trial_provider_in_range(provider: Node) -> bool:
	if provider == null or not provider is Node2D:
		return false
	return (
		(provider as Node2D).global_position.x
		>= FACTORY_LOWER_DECK_POST_RELAY_TRIAL_ACTIVATION_X
	)


func _is_lower_deck_forward_conduit_provider_in_range(provider: Node) -> bool:
	if provider == null or not provider is Node2D:
		return false
	return (
		(provider as Node2D).global_position.x
		>= FACTORY_LOWER_DECK_FORWARD_CONDUIT_ACTIVATION_X
	)


func _is_lower_deck_forward_pressure_provider_at_activation(provider: Node) -> bool:
	if provider == null or not provider is Node2D:
		return false
	return (
		(provider as Node2D).global_position.x
		>= FACTORY_LOWER_DECK_FORWARD_PRESSURE_ACTIVATION_X
	)


func _is_lower_deck_forward_pressure_provider_at_exit(provider: Node) -> bool:
	if provider == null or not provider is Node2D:
		return false
	return (
		(provider as Node2D).global_position.x
		>= FACTORY_LOWER_DECK_FORWARD_PRESSURE_EXIT_X
	)


func _is_lower_deck_forward_counter_ambush_provider_in_range(provider: Node) -> bool:
	if provider == null or not provider is Node2D:
		return false
	return (
		(provider as Node2D).global_position.x
		>= FACTORY_LOWER_DECK_FORWARD_COUNTER_AMBUSH_ACTIVATION_X
	)


func _is_lower_deck_forward_exit_guard_provider_in_range(provider: Node) -> bool:
	if provider == null or not provider is Node2D:
		return false
	return (
		(provider as Node2D).global_position.x
		>= FACTORY_LOWER_DECK_FORWARD_EXIT_GUARD_ACTIVATION_X
	)


func _is_lower_deck_forward_beacon_ambush_provider_in_range(provider: Node) -> bool:
	if provider == null or not provider is Node2D:
		return false
	return (
		(provider as Node2D).global_position.x
		>= FACTORY_LOWER_DECK_FORWARD_BEACON_AMBUSH_ACTIVATION_X
	)


func _is_lower_deck_forward_overrun_provider_in_range(provider: Node) -> bool:
	if provider == null or not provider is Node2D:
		return false
	return (
		(provider as Node2D).global_position.x
		>= FACTORY_LOWER_DECK_FORWARD_OVERRUN_ACTIVATION_X
	)


func _is_lower_deck_forward_breaker_provider_in_range(provider: Node) -> bool:
	if provider == null or not provider is Node2D:
		return false
	return (
		(provider as Node2D).global_position.x
		>= FACTORY_LOWER_DECK_FORWARD_BREAKER_ACTIVATION_X
	)


func _is_lower_deck_forward_relief_ambush_provider_in_range(provider: Node) -> bool:
	if provider == null or not provider is Node2D:
		return false
	return (
		(provider as Node2D).global_position.x
		>= FACTORY_LOWER_DECK_FORWARD_RELIEF_AMBUSH_ACTIVATION_X
	)


func _is_lower_deck_forward_pressure_coil_rat_provider_in_range(provider: Node) -> bool:
	if provider == null or not provider is Node2D:
		return false
	return (
		(provider as Node2D).global_position.x
		>= FACTORY_LOWER_DECK_FORWARD_COIL_RAT_ACTIVATION_X
	)


func _is_lower_deck_forward_pressure_coil_pincer_provider_in_range(provider: Node) -> bool:
	if provider == null or not provider is Node2D:
		return false
	return (
		(provider as Node2D).global_position.x
		>= FACTORY_LOWER_DECK_FORWARD_COIL_PINCER_ACTIVATION_X
	)


func _is_lower_deck_forward_pressure_coil_aftershock_provider_in_range(
	provider: Node
) -> bool:
	if provider == null or not provider is Node2D:
		return false
	return (
		(provider as Node2D).global_position.x
			>= FACTORY_LOWER_DECK_FORWARD_COIL_AFTERSHOCK_ACTIVATION_X
		)


func _is_lower_deck_forward_pressure_aftershock_exit_skirmish_provider_in_range(
	provider: Node
) -> bool:
	if provider == null or not provider is Node2D:
		return false
	return (
		(provider as Node2D).global_position.x
		>= FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_EXIT_SKIRMISH_ACTIVATION_X
	)


func _is_lower_deck_forward_pressure_aftershock_exhaust_provider_at_activation(
	provider: Node
) -> bool:
	if provider == null or not provider is Node2D:
		return false
	return (
		(provider as Node2D).global_position.x
		>= FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_EXHAUST_ACTIVATION_X
	)


func _is_lower_deck_forward_pressure_aftershock_exhaust_provider_at_exit(
	provider: Node
) -> bool:
	if provider == null or not provider is Node2D:
		return false
	return (
		(provider as Node2D).global_position.x
		>= FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_EXHAUST_EXIT_X
	)


func _is_lower_deck_forward_pressure_aftershock_exhaust_pursuer_provider_in_range(
	provider: Node
) -> bool:
	if provider == null or not provider is Node2D:
		return false
	return (
		(provider as Node2D).global_position.x
		>= FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_EXHAUST_PURSUER_ACTIVATION_X
	)


func _is_lower_deck_forward_pressure_aftershock_exhaust_flank_provider_in_range(
	provider: Node
) -> bool:
	if provider == null or not provider is Node2D:
		return false
	return (
		(provider as Node2D).global_position.x
		>= FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_EXHAUST_FLANK_ACTIVATION_X
	)


func _is_lower_deck_forward_pressure_aftershock_exhaust_breaker_provider_in_range(
	provider: Node
) -> bool:
	if provider == null or not provider is Node2D:
		return false
	return (
		(provider as Node2D).global_position.x
		>= FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_EXHAUST_BREAKER_ACTIVATION_X
	)


func _is_lower_deck_forward_pressure_aftershock_exhaust_escape_skirmish_provider_in_range(
	provider: Node
) -> bool:
	if provider == null or not provider is Node2D:
		return false
	return (
		(provider as Node2D).global_position.x
		>= FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_EXHAUST_ESCAPE_ACTIVATION_X
	)


func _is_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch_provider_in_range(
	provider: Node
) -> bool:
	if provider == null or not provider is Node2D:
		return false
	if _lower_deck_forward_pressure_aftershock_exhaust_exit_hatch == null:
		return false
	if _lower_deck_forward_pressure_aftershock_exhaust_exit_hatch.has_method(
		"is_provider_in_activation_range"
	):
		return bool(_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch.call(
			"is_provider_in_activation_range",
			provider
		))
	if not _lower_deck_forward_pressure_aftershock_exhaust_exit_hatch is Node2D:
		return false
	return (
		(provider as Node2D).global_position.distance_to(
			(_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch as Node2D).global_position
		)
		<= FACTORY_RETURN_CHECKPOINT_ACTIVATION_RADIUS
	)


func _is_overflow_pump_exit_hatch_provider_in_range(provider: Node) -> bool:
	if provider == null or not provider is Node2D:
		return false
	var hatch: Node = (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_exit_hatch
	)
	if hatch == null:
		return false
	if hatch.has_method("is_provider_in_activation_range"):
		return bool(hatch.call("is_provider_in_activation_range", provider))
	if not hatch is Node2D:
		return false
	return (
		(provider as Node2D).global_position.distance_to((hatch as Node2D).global_position)
		<= FACTORY_RETURN_CHECKPOINT_ACTIVATION_RADIUS
	)


func _is_lower_deck_forward_pressure_aftershock_cooling_duct_provider_at_activation(
	provider: Node
) -> bool:
	if provider == null or not provider is Node2D:
		return false
	return (
		(provider as Node2D).global_position.x
		>= FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_COOLING_DUCT_ACTIVATION_X
	)


func _is_lower_deck_forward_pressure_aftershock_cooling_duct_provider_at_exit(
	provider: Node
) -> bool:
	if provider == null or not provider is Node2D:
		return false
	return (
		(provider as Node2D).global_position.x
		>= FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_COOLING_DUCT_EXIT_X
	)


func _is_lower_deck_forward_pressure_aftershock_condenser_valve_provider_in_range(
	provider: Node
) -> bool:
	if provider == null or not provider is Node2D:
		return false
	return (
		(provider as Node2D).global_position.x
		>= FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_CONDENSER_ACTIVATION_X
	)


func _is_lower_deck_forward_pressure_aftershock_condenser_outlet_provider_at_activation(
	provider: Node
) -> bool:
	if provider == null or not provider is Node2D:
		return false
	return (
		(provider as Node2D).global_position.x
		>= FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_CONDENSER_OUTLET_ACTIVATION_X
	)


func _is_lower_deck_forward_pressure_aftershock_condenser_outlet_provider_at_exit(
	provider: Node
) -> bool:
	if provider == null or not provider is Node2D:
		return false
	return (
		(provider as Node2D).global_position.x
		>= FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_CONDENSER_OUTLET_EXIT_X
	)


func _is_outlet_clamp_ambush_provider_in_range(provider: Node) -> bool:
	if provider == null or not provider is Node2D:
		return false
	return (
		(provider as Node2D).global_position.x
		>= FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_CONDENSER_OUTLET_CLAMP_ACTIVATION_X
	)


func _is_outlet_drip_vent_provider_at_activation(provider: Node) -> bool:
	if provider == null or not provider is Node2D:
		return false
	return (
		(provider as Node2D).global_position.x
		>= FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_CONDENSER_DRIP_VENT_ACTIVATION_X
	)


func _is_outlet_drip_vent_provider_at_exit(provider: Node) -> bool:
	if provider == null or not provider is Node2D:
		return false
	return (
		(provider as Node2D).global_position.x
		>= FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_CONDENSER_DRIP_VENT_EXIT_X
	)


func _is_overflow_pump_provider_in_range(provider: Node) -> bool:
	if provider == null or not provider is Node2D:
		return false
	return (
		(provider as Node2D).global_position.x
		>= FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_ACTIVATION_X
	)


func _is_overflow_pump_runoff_duct_provider_at_activation(provider: Node) -> bool:
	if provider == null or not provider is Node2D:
		return false
	return (
		(provider as Node2D).global_position.x
		>= FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_RUNOFF_DUCT_ACTIVATION_X
	)


func _is_overflow_pump_runoff_duct_provider_at_exit(provider: Node) -> bool:
	if provider == null or not provider is Node2D:
		return false
	return (
		(provider as Node2D).global_position.x
		>= FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_RUNOFF_DUCT_EXIT_X
	)


func _is_overflow_pump_runoff_outlet_provider_at_activation(provider: Node) -> bool:
	if provider == null or not provider is Node2D:
		return false
	return (
		(provider as Node2D).global_position.x
		>= FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_RUNOFF_OUTLET_ACTIVATION_X
	)


func _is_overflow_pump_runoff_outlet_provider_at_exit(provider: Node) -> bool:
	if provider == null or not provider is Node2D:
		return false
	return (
		(provider as Node2D).global_position.x
		>= FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_RUNOFF_OUTLET_EXIT_X
	)


func _is_overflow_pump_runoff_outlet_skirmish_provider_in_range(provider: Node) -> bool:
	if provider == null or not provider is Node2D:
		return false
	return (
		(provider as Node2D).global_position.x
		>= FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_RUNOFF_OUTLET_SKIRMISH_ACTIVATION_X
	)


func _is_overflow_pump_runoff_outlet_service_sluice_skirmish_provider_in_range(
	provider: Node
) -> bool:
	if provider == null or not provider is Node2D:
		return false
	return (
		(provider as Node2D).global_position.x
		>= FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_RUNOFF_OUTLET_SERVICE_SLUICE_SKIRMISH_ACTIVATION_X
	)


func _is_overflow_pump_runoff_exit_skirmish_provider_in_range(provider: Node) -> bool:
	if provider == null or not provider is Node2D:
		return false
	return (
		(provider as Node2D).global_position.x
		>= FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_RUNOFF_EXIT_ACTIVATION_X
	)


func _is_overflow_pump_runoff_exit_gate_provider_in_range(provider: Node) -> bool:
	if provider == null or not provider is Node2D:
		return false
	var gate: Node = (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_gate
	)
	if gate == null:
		return false
	if gate.has_method("is_provider_in_activation_range"):
		return bool(gate.call("is_provider_in_activation_range", provider))
	if not gate is Node2D:
		return false
	return (
		(provider as Node2D).global_position.distance_to((gate as Node2D).global_position)
		<= FACTORY_RETURN_CHECKPOINT_ACTIVATION_RADIUS
	)


func _is_overflow_pump_runoff_outlet_service_hatch_provider_in_range(
	provider: Node
) -> bool:
	if provider == null or not provider is Node2D:
		return false
	var hatch: Node = (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_hatch
	)
	if hatch == null:
		return false
	if hatch.has_method("is_provider_in_activation_range"):
		return bool(hatch.call("is_provider_in_activation_range", provider))
	if not hatch is Node2D:
		return false
	return (
		(provider as Node2D).global_position.distance_to((hatch as Node2D).global_position)
		<= FACTORY_RETURN_CHECKPOINT_ACTIVATION_RADIUS
	)


func _is_overflow_pump_runoff_outlet_service_sluice_provider_at_activation(
	provider: Node
) -> bool:
	if provider == null or not provider is Node2D:
		return false
	return (
		(provider as Node2D).global_position.x
		>= FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_RUNOFF_OUTLET_SERVICE_SLUICE_ACTIVATION_X
	)


func _is_overflow_pump_runoff_outlet_service_sluice_provider_at_exit(
	provider: Node
) -> bool:
	if provider == null or not provider is Node2D:
		return false
	return (
		(provider as Node2D).global_position.x
		>= FACTORY_LOWER_DECK_FORWARD_AFTERSHOCK_CONDENSER_OVERFLOW_PUMP_RUNOFF_OUTLET_SERVICE_SLUICE_EXIT_X
	)


func _is_lower_deck_forward_pressure_breaker_provider_in_range(provider: Node) -> bool:
	if provider == null or not provider is Node2D:
		return false
	if _lower_deck_forward_pressure_breaker == null:
		return false
	if _lower_deck_forward_pressure_breaker.has_method("is_provider_in_activation_range"):
		return bool(_lower_deck_forward_pressure_breaker.call(
			"is_provider_in_activation_range",
			provider
		))
	if not _lower_deck_forward_pressure_breaker is Node2D:
		return false
	return (
		(provider as Node2D).global_position.distance_to(
			(_lower_deck_forward_pressure_breaker as Node2D).global_position
		)
		<= FACTORY_RETURN_CHECKPOINT_ACTIVATION_RADIUS
	)


func _is_return_checkpoint_provider_in_range(provider: Node) -> bool:
	if provider == null or not provider is Node2D:
		return false
	if _return_checkpoint == null or not _return_checkpoint is Node2D:
		return false
	return (
		(provider as Node2D).global_position.distance_to(
			(_return_checkpoint as Node2D).global_position
		)
		<= FACTORY_RETURN_CHECKPOINT_ACTIVATION_RADIUS
	)


func _get_spark_rat_distance_to_provider(provider: Node) -> float:
	if _spark_rat == null or provider == null or not provider is Node2D:
		return INF
	return _spark_rat.global_position.distance_to((provider as Node2D).global_position)


func _get_factory_enemy_by_entity_id(target_id: int) -> Node:
	for guard: Node in [
		_enemy,
		_deep_guard,
		_spark_rat,
		_return_spark_rat,
		_checkpoint_forward_spark_rat,
		_checkpoint_rear_spark_rat,
		_checkpoint_overdrive_left_spark_rat,
		_checkpoint_overdrive_right_spark_rat,
		_lower_deck_spark_rat,
		_lower_deck_exit_spark_rat,
		_lower_deck_shortcut_spark_rat,
		_lower_deck_shortcut_pursuer_spark_rat,
		_lower_deck_pressure_guard_spark_rat,
		_lower_deck_steam_sluice_spark_rat,
		_lower_deck_deep_bulkhead_spark_rat,
			_lower_deck_breach_front_spark_rat,
			_lower_deck_breach_rear_spark_rat,
			_lower_deck_post_relay_spark_rat,
			_lower_deck_forward_conduit_spark_rat,
			_lower_deck_forward_counter_spark_rat,
			_lower_deck_forward_exit_guard_spark_rat,
			_lower_deck_forward_beacon_ambush_spark_rat,
			_lower_deck_forward_overrun_spark_rat,
			_lower_deck_forward_breaker_spark_rat,
			_lower_deck_forward_relief_ambush_spark_rat,
			_lower_deck_forward_pressure_coil_rat,
				_lower_deck_forward_pressure_coil_pincer_spark_rat,
				_lower_deck_forward_pressure_coil_pincer_coil_rat,
				_lower_deck_forward_pressure_coil_aftershock_coil_rat,
				_lower_deck_forward_pressure_aftershock_exit_spark_rat,
				_lower_deck_forward_pressure_aftershock_exit_coil_rat,
				_lower_deck_forward_pressure_aftershock_exhaust_pursuer_coil_rat,
				_lower_deck_forward_pressure_aftershock_exhaust_flank_spark_rat,
				_lower_deck_forward_pressure_aftershock_exhaust_breaker_coil_rat,
				_lower_deck_forward_pressure_aftershock_exhaust_escape_spark_rat,
				_lower_deck_forward_pressure_aftershock_exhaust_escape_coil_rat,
					_lower_deck_forward_pressure_aftershock_condenser_spark_rat,
					_lower_deck_forward_pressure_aftershock_condenser_coil_rat,
						_lower_deck_forward_pressure_aftershock_condenser_outlet_clamp_spark_rat,
						_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_coil_rat,
						_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_coil_rat,
						_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_spark_rat,
						_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_spark_rat,
					]:
		if (
			guard == null
			or not is_instance_valid(guard)
			or not guard.has_method("get_entity_id")
		):
			continue
		if int(guard.call("get_entity_id")) == target_id:
			return guard
	return null


func _get_enemy_entity_id(enemy: Variant) -> int:
	if enemy != null and is_instance_valid(enemy) and enemy is Node:
		var enemy_node: Node = enemy as Node
		if enemy_node.has_method("get_entity_id"):
			return int(enemy_node.call("get_entity_id"))
	return 0


func _get_enemy_family_id(enemy: Variant) -> String:
	if enemy != null and is_instance_valid(enemy) and enemy is Node:
		var enemy_node: Node = enemy as Node
		if enemy_node.has_method("get_enemy_family_id"):
			return String(enemy_node.call("get_enemy_family_id"))
	return ""


func _get_valid_node2d(node: Variant) -> Node2D:
	if node == null or not is_instance_valid(node) or not (node is Node2D):
		return null
	return node as Node2D


func _get_sprite_animation_frame_counts(sprite: AnimatedSprite2D) -> Dictionary:
	if sprite == null or sprite.sprite_frames == null:
		return {}
	var frame_counts: Dictionary = {}
	for animation_name: StringName in sprite.sprite_frames.get_animation_names():
		var frame_count: int = sprite.sprite_frames.get_frame_count(animation_name)
		frame_counts[animation_name] = frame_count
		frame_counts[String(animation_name)] = frame_count
	return frame_counts


func _is_return_patrol_blocking_service_lift() -> bool:
	return _return_patrol_activated and not _return_patrol_defeated


func _is_checkpoint_forward_patrol_blocking_service_lift() -> bool:
	return _checkpoint_forward_patrol_activated and not _checkpoint_forward_patrol_defeated


func _is_checkpoint_rear_ambush_blocking_service_lift() -> bool:
	return _checkpoint_forward_patrol_defeated and not _checkpoint_rear_ambush_defeated


func _is_checkpoint_overdrive_duo_blocking_service_lift() -> bool:
	return _checkpoint_rear_ambush_defeated and not _is_checkpoint_overdrive_duo_cleared()


func _is_checkpoint_overdrive_duo_active() -> bool:
	return (
		_checkpoint_overdrive_duo_activated
		and _checkpoint_rear_ambush_defeated
		and not _is_checkpoint_overdrive_duo_cleared()
	)


func _is_lower_deck_skirmish_active() -> bool:
	return (
		_lower_deck_skirmish_activated
		and _is_checkpoint_overdrive_duo_cleared()
		and not _lower_deck_skirmish_defeated
	)


func _is_lower_deck_parry_gate_available() -> bool:
	return _lower_deck_reward_cache_claimed and not _lower_deck_parry_gate_unlocked


func _is_lower_deck_exit_ambush_active() -> bool:
	return (
		_lower_deck_exit_ambush_activated
		and _lower_deck_parry_gate_unlocked
		and not _lower_deck_exit_ambush_defeated
	)


func _is_lower_deck_shortcut_available() -> bool:
	return _lower_deck_exit_ambush_defeated and not _lower_deck_shortcut_unlocked


func _is_lower_deck_shortcut_active() -> bool:
	return (
		_lower_deck_shortcut_activated
		and _lower_deck_exit_ambush_defeated
		and not _lower_deck_shortcut_guard_defeated
		and not _lower_deck_shortcut_unlocked
	)


func _is_lower_deck_shortcut_seal_unlockable() -> bool:
	return _lower_deck_shortcut_guard_defeated and not _lower_deck_shortcut_unlocked


func _is_lower_deck_shortcut_seal_activated() -> bool:
	if _lower_deck_shortcut_seal != null and _lower_deck_shortcut_seal.has_method("is_activated"):
		return bool(_lower_deck_shortcut_seal.call("is_activated"))
	return _lower_deck_shortcut_unlocked


func _is_lower_deck_shortcut_pursuer_available() -> bool:
	return (
		_lower_deck_shortcut_reward_cache_claimed
		and not _lower_deck_shortcut_pursuer_defeated
	)


func _is_lower_deck_shortcut_pursuer_active() -> bool:
	return (
		_lower_deck_shortcut_pursuer_activated
		and not _lower_deck_shortcut_pursuer_defeated
	)


func _is_lower_deck_pressure_guard_available() -> bool:
	return (
		_lower_deck_shortcut_pursuer_defeated
		and not _lower_deck_pressure_guard_defeated
		and not _lower_deck_pressure_valve_opened
	)


func _is_lower_deck_pressure_guard_active() -> bool:
	return (
		_lower_deck_pressure_guard_activated
		and not _lower_deck_pressure_guard_defeated
		and not _lower_deck_pressure_valve_opened
	)


func _is_lower_deck_pressure_valve_available() -> bool:
	return _lower_deck_pressure_guard_defeated and not _lower_deck_pressure_valve_opened


func _is_lower_deck_steam_sluice_available() -> bool:
	return _lower_deck_pressure_valve_opened and not _lower_deck_steam_sluice_defeated


func _is_lower_deck_steam_sluice_active() -> bool:
	return (
		_lower_deck_steam_sluice_activated
		and _lower_deck_pressure_valve_opened
		and not _lower_deck_steam_sluice_defeated
	)


func _is_lower_deck_deep_bulkhead_guard_available() -> bool:
	return (
		_lower_deck_steam_sluice_defeated
		and not _lower_deck_deep_bulkhead_guard_defeated
		and not _lower_deck_deep_bulkhead_opened
	)


func _is_lower_deck_deep_bulkhead_guard_active() -> bool:
	return (
		_lower_deck_deep_bulkhead_guard_activated
		and _lower_deck_steam_sluice_defeated
		and not _lower_deck_deep_bulkhead_guard_defeated
		and not _lower_deck_deep_bulkhead_opened
	)


func _is_lower_deck_deep_bulkhead_available() -> bool:
	return _lower_deck_deep_bulkhead_guard_defeated and not _lower_deck_deep_bulkhead_opened


func _is_lower_deck_breach_corridor_available() -> bool:
	return (
		_lower_deck_deep_bulkhead_opened
		and not _lower_deck_breach_corridor_secured
	)


func _is_lower_deck_breach_front_active() -> bool:
	return (
		_lower_deck_breach_corridor_activated
		and _lower_deck_deep_bulkhead_opened
		and not _lower_deck_breach_front_guard_defeated
		and not _lower_deck_breach_corridor_secured
	)


func _is_lower_deck_breach_rear_active() -> bool:
	return (
		_lower_deck_breach_rear_ambusher_activated
		and _lower_deck_deep_bulkhead_opened
		and not _lower_deck_breach_rear_ambusher_defeated
		and not _lower_deck_breach_corridor_secured
	)


func _is_lower_deck_breach_corridor_active() -> bool:
	return (
		_lower_deck_breach_corridor_activated
		and _lower_deck_deep_bulkhead_opened
		and not _lower_deck_breach_corridor_secured
		and (
			not _lower_deck_breach_front_guard_defeated
			or not _lower_deck_breach_rear_ambusher_defeated
		)
	)


func _is_lower_deck_breach_corridor_secured() -> bool:
	return (
		_lower_deck_breach_corridor_secured
		or (
			_lower_deck_breach_front_guard_defeated
			and _lower_deck_breach_rear_ambusher_defeated
		)
	)


func _is_lower_deck_breach_relay_available() -> bool:
	return _is_lower_deck_breach_corridor_secured()


func _is_lower_deck_post_relay_trial_available() -> bool:
	return _lower_deck_breach_relay_activated and not _lower_deck_post_relay_trial_defeated


func _is_lower_deck_post_relay_trial_active() -> bool:
	return (
		_lower_deck_post_relay_trial_activated
		and _lower_deck_breach_relay_activated
		and not _lower_deck_post_relay_trial_defeated
	)


func _is_lower_deck_forward_hatch_available() -> bool:
	return (
		_lower_deck_post_relay_trial_defeated
		and _lower_deck_relay_forward_reward_cache_claimed
		and not _lower_deck_forward_hatch_opened
	)


func _is_lower_deck_forward_conduit_available() -> bool:
	return _lower_deck_forward_hatch_opened and not _lower_deck_forward_conduit_defeated


func _is_lower_deck_forward_conduit_active() -> bool:
	return (
		_lower_deck_forward_conduit_activated
		and _lower_deck_forward_hatch_opened
		and not _lower_deck_forward_conduit_defeated
	)


func _is_lower_deck_forward_pressure_traverse_available() -> bool:
	return (
		_lower_deck_forward_conduit_defeated
		and not _lower_deck_forward_pressure_traverse_crossed
	)


func _is_lower_deck_forward_pressure_counter_ambush_available() -> bool:
	return (
		_lower_deck_forward_pressure_traverse_crossed
		and not _lower_deck_forward_pressure_counter_ambush_defeated
	)


func _is_lower_deck_forward_pressure_counter_ambush_active() -> bool:
	return (
		_lower_deck_forward_pressure_counter_ambush_activated
		and _lower_deck_forward_pressure_traverse_crossed
		and not _lower_deck_forward_pressure_counter_ambush_defeated
	)


func _is_lower_deck_forward_pressure_exit_guard_available() -> bool:
	return (
		_lower_deck_forward_pressure_reward_cache_claimed
		and not _lower_deck_forward_pressure_exit_guard_defeated
	)


func _is_lower_deck_forward_pressure_exit_guard_active() -> bool:
	return (
		_lower_deck_forward_pressure_exit_guard_activated
		and _lower_deck_forward_pressure_reward_cache_claimed
		and not _lower_deck_forward_pressure_exit_guard_defeated
	)


func _is_lower_deck_forward_pressure_exit_relay_available() -> bool:
	return (
		_lower_deck_forward_pressure_exit_guard_defeated
		and not _lower_deck_forward_pressure_exit_relay_activated
	)


func _is_lower_deck_forward_pressure_exit_gate_available() -> bool:
	return (
		_lower_deck_forward_pressure_exit_relay_activated
		and not _lower_deck_forward_pressure_exit_gate_opened
	)


func _is_lower_deck_forward_pressure_route_handoff_marker_available() -> bool:
	return (
		_lower_deck_forward_pressure_exit_gate_opened
		and not _lower_deck_forward_pressure_route_handoff_marker_lit
	)


func _is_lower_deck_forward_pressure_beacon_ambush_available() -> bool:
	return (
		_lower_deck_forward_pressure_route_handoff_marker_lit
		and not _lower_deck_forward_pressure_beacon_ambush_defeated
	)


func _is_lower_deck_forward_pressure_beacon_ambush_active() -> bool:
	return (
		_lower_deck_forward_pressure_beacon_ambush_activated
		and _lower_deck_forward_pressure_route_handoff_marker_lit
		and not _lower_deck_forward_pressure_beacon_ambush_defeated
	)


func _is_lower_deck_forward_pressure_overrun_available() -> bool:
	return (
		_lower_deck_forward_pressure_beacon_ambush_defeated
		and not _lower_deck_forward_pressure_overrun_defeated
	)


func _is_lower_deck_forward_pressure_overrun_active() -> bool:
	return (
		_lower_deck_forward_pressure_overrun_activated
		and _lower_deck_forward_pressure_beacon_ambush_defeated
		and not _lower_deck_forward_pressure_overrun_defeated
	)


func _is_lower_deck_forward_pressure_breaker_stand_available() -> bool:
	return (
		_lower_deck_forward_pressure_overrun_defeated
		and not _lower_deck_forward_pressure_breaker_secured
	)


func _is_lower_deck_forward_pressure_breaker_stand_active() -> bool:
	return (
		_lower_deck_forward_pressure_breaker_activated
		and _lower_deck_forward_pressure_overrun_defeated
		and not _lower_deck_forward_pressure_breaker_secured
	)


func _is_lower_deck_forward_pressure_breaker_available() -> bool:
	return (
		_lower_deck_forward_pressure_breaker_secured
		and not _lower_deck_forward_pressure_breaker_cut
	)


func _is_lower_deck_forward_pressure_relief_ambush_available() -> bool:
	return (
		_lower_deck_forward_pressure_breaker_cut
		and not _lower_deck_forward_pressure_relief_ambush_defeated
	)


func _is_lower_deck_forward_pressure_relief_ambush_active() -> bool:
	return (
		_lower_deck_forward_pressure_relief_ambush_activated
		and _lower_deck_forward_pressure_breaker_cut
		and not _lower_deck_forward_pressure_relief_ambush_defeated
	)


func _is_lower_deck_forward_pressure_coil_rat_available() -> bool:
	return (
		_lower_deck_forward_pressure_relief_ambush_defeated
		and not _lower_deck_forward_pressure_coil_rat_defeated
	)


func _is_lower_deck_forward_pressure_coil_rat_active() -> bool:
	return (
		_lower_deck_forward_pressure_coil_rat_activated
		and _lower_deck_forward_pressure_relief_ambush_defeated
		and not _lower_deck_forward_pressure_coil_rat_defeated
	)


func _is_lower_deck_forward_pressure_coil_pincer_available() -> bool:
	return (
		_lower_deck_forward_pressure_coil_rat_defeated
		and not _is_lower_deck_forward_pressure_coil_pincer_cleared()
	)


func _is_lower_deck_forward_pressure_coil_pincer_active() -> bool:
	return (
		_lower_deck_forward_pressure_coil_pincer_activated
		and _lower_deck_forward_pressure_coil_rat_defeated
		and not _is_lower_deck_forward_pressure_coil_pincer_cleared()
	)


func _is_lower_deck_forward_pressure_coil_pincer_cleared() -> bool:
	return (
		_lower_deck_forward_pressure_coil_pincer_spark_rat_defeated
		and _lower_deck_forward_pressure_coil_pincer_coil_rat_defeated
	)


func _is_lower_deck_forward_pressure_coil_aftershock_available() -> bool:
	return (
		_is_lower_deck_forward_pressure_coil_pincer_cleared()
		and not _lower_deck_forward_pressure_coil_aftershock_defeated
	)


func _is_lower_deck_forward_pressure_coil_aftershock_active() -> bool:
	return (
		_lower_deck_forward_pressure_coil_aftershock_activated
		and _is_lower_deck_forward_pressure_coil_pincer_cleared()
		and not _lower_deck_forward_pressure_coil_aftershock_defeated
	)


func _is_lower_deck_forward_pressure_aftershock_exit_skirmish_available() -> bool:
	return (
		_lower_deck_forward_pressure_aftershock_reward_cache_claimed
		and not _is_lower_deck_forward_pressure_aftershock_exit_skirmish_cleared()
	)


func _is_lower_deck_forward_pressure_aftershock_exit_skirmish_active() -> bool:
	return (
		_lower_deck_forward_pressure_aftershock_exit_skirmish_activated
		and _lower_deck_forward_pressure_aftershock_reward_cache_claimed
		and not _is_lower_deck_forward_pressure_aftershock_exit_skirmish_cleared()
	)


func _is_lower_deck_forward_pressure_aftershock_exit_skirmish_cleared() -> bool:
	return (
		_lower_deck_forward_pressure_aftershock_exit_spark_rat_defeated
		and _lower_deck_forward_pressure_aftershock_exit_coil_rat_defeated
	)


func _is_lower_deck_forward_pressure_aftershock_exhaust_available() -> bool:
	return (
		_is_lower_deck_forward_pressure_aftershock_exit_skirmish_cleared()
		and not _lower_deck_forward_pressure_aftershock_exhaust_crossed
	)


func _is_lower_deck_forward_pressure_aftershock_exhaust_active() -> bool:
	return (
		_lower_deck_forward_pressure_aftershock_exhaust_activated
		and _is_lower_deck_forward_pressure_aftershock_exit_skirmish_cleared()
		and not _lower_deck_forward_pressure_aftershock_exhaust_crossed
	)


func _is_lower_deck_forward_pressure_aftershock_exhaust_pursuer_available() -> bool:
	return (
		_lower_deck_forward_pressure_aftershock_exhaust_crossed
		and not _lower_deck_forward_pressure_aftershock_exhaust_pursuer_defeated
	)


func _is_lower_deck_forward_pressure_aftershock_exhaust_pursuer_active() -> bool:
	return (
		_lower_deck_forward_pressure_aftershock_exhaust_pursuer_activated
		and _lower_deck_forward_pressure_aftershock_exhaust_crossed
		and not _lower_deck_forward_pressure_aftershock_exhaust_pursuer_defeated
	)


func _is_lower_deck_forward_pressure_aftershock_exhaust_flank_available() -> bool:
	return (
		_lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache_claimed
		and not _lower_deck_forward_pressure_aftershock_exhaust_flank_spark_rat_defeated
	)


func _is_lower_deck_forward_pressure_aftershock_exhaust_flank_active() -> bool:
	return (
		_lower_deck_forward_pressure_aftershock_exhaust_flank_activated
		and _lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache_claimed
		and not _lower_deck_forward_pressure_aftershock_exhaust_flank_spark_rat_defeated
	)


func _is_lower_deck_forward_pressure_aftershock_exhaust_breaker_stand_available(
) -> bool:
	return (
		_lower_deck_forward_pressure_aftershock_exhaust_flank_spark_rat_defeated
		and not _lower_deck_forward_pressure_aftershock_exhaust_breaker_secured
		and not _lower_deck_forward_pressure_aftershock_exhaust_breaker_cut
	)


func _is_lower_deck_forward_pressure_aftershock_exhaust_breaker_stand_active(
) -> bool:
	return (
		_lower_deck_forward_pressure_aftershock_exhaust_breaker_activated
		and _lower_deck_forward_pressure_aftershock_exhaust_flank_spark_rat_defeated
		and not _lower_deck_forward_pressure_aftershock_exhaust_breaker_secured
		and not _lower_deck_forward_pressure_aftershock_exhaust_breaker_cut
	)


func _is_lower_deck_forward_pressure_aftershock_exhaust_breaker_available() -> bool:
	return (
		_lower_deck_forward_pressure_aftershock_exhaust_breaker_secured
		and not _lower_deck_forward_pressure_aftershock_exhaust_breaker_cut
	)


func _is_lower_deck_forward_pressure_aftershock_exhaust_escape_skirmish_available(
) -> bool:
	return (
		_lower_deck_forward_pressure_aftershock_exhaust_breaker_cut
		and not _is_lower_deck_forward_pressure_aftershock_exhaust_escape_skirmish_cleared()
	)


func _is_lower_deck_forward_pressure_aftershock_exhaust_escape_skirmish_active(
) -> bool:
	return (
		_lower_deck_forward_pressure_aftershock_exhaust_escape_skirmish_activated
		and _lower_deck_forward_pressure_aftershock_exhaust_breaker_cut
		and not _is_lower_deck_forward_pressure_aftershock_exhaust_escape_skirmish_cleared()
	)


func _is_lower_deck_forward_pressure_aftershock_exhaust_escape_skirmish_cleared(
) -> bool:
	return (
		_lower_deck_forward_pressure_aftershock_exhaust_escape_spark_rat_defeated
		and _lower_deck_forward_pressure_aftershock_exhaust_escape_coil_rat_defeated
	)


func _is_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch_available(
) -> bool:
	return (
		_is_lower_deck_forward_pressure_aftershock_exhaust_escape_skirmish_cleared()
		and not _lower_deck_forward_pressure_aftershock_exhaust_exit_hatch_opened
	)


func _is_lower_deck_forward_pressure_aftershock_cooling_duct_available() -> bool:
	return (
		_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch_opened
		and not _lower_deck_forward_pressure_aftershock_cooling_duct_crossed
	)


func _is_lower_deck_forward_pressure_aftershock_cooling_duct_active() -> bool:
	return (
		_lower_deck_forward_pressure_aftershock_cooling_duct_activated
		and _lower_deck_forward_pressure_aftershock_exhaust_exit_hatch_opened
		and not _lower_deck_forward_pressure_aftershock_cooling_duct_crossed
	)


func _is_lower_deck_forward_pressure_aftershock_condenser_valve_available() -> bool:
	return (
		_lower_deck_forward_pressure_aftershock_cooling_duct_crossed
		and not _lower_deck_forward_pressure_aftershock_condenser_valve_activated
		and not _is_lower_deck_forward_pressure_aftershock_condenser_valve_cleared()
	)


func _is_lower_deck_forward_pressure_aftershock_condenser_valve_active() -> bool:
	return (
		_lower_deck_forward_pressure_aftershock_condenser_valve_activated
		and _lower_deck_forward_pressure_aftershock_cooling_duct_crossed
		and not _is_lower_deck_forward_pressure_aftershock_condenser_valve_cleared()
	)


func _is_lower_deck_forward_pressure_aftershock_condenser_valve_cleared() -> bool:
	return (
		_lower_deck_forward_pressure_aftershock_condenser_valve_spark_rat_defeated
		and _lower_deck_forward_pressure_aftershock_condenser_valve_coil_rat_defeated
	)


func _is_lower_deck_forward_pressure_aftershock_condenser_savepoint_available() -> bool:
	return (
		_is_lower_deck_forward_pressure_aftershock_condenser_valve_cleared()
		and not _lower_deck_forward_pressure_aftershock_condenser_savepoint_activated
	)


func _is_lower_deck_forward_pressure_aftershock_condenser_outlet_available() -> bool:
	return (
		_lower_deck_forward_pressure_aftershock_condenser_savepoint_activated
		and not _lower_deck_forward_pressure_aftershock_condenser_outlet_crossed
	)


func _is_lower_deck_forward_pressure_aftershock_condenser_outlet_active() -> bool:
	return (
		_lower_deck_forward_pressure_aftershock_condenser_outlet_activated
		and _lower_deck_forward_pressure_aftershock_condenser_savepoint_activated
		and not _lower_deck_forward_pressure_aftershock_condenser_outlet_crossed
	)


func _is_outlet_clamp_ambush_available() -> bool:
	return (
		_lower_deck_forward_pressure_aftershock_condenser_outlet_crossed
		and not _lower_deck_forward_pressure_aftershock_condenser_outlet_clamp_ambush_activated
		and not _is_outlet_clamp_ambush_cleared()
	)


func _is_outlet_clamp_ambush_active() -> bool:
	return (
		_lower_deck_forward_pressure_aftershock_condenser_outlet_clamp_ambush_activated
		and _lower_deck_forward_pressure_aftershock_condenser_outlet_crossed
		and not _is_outlet_clamp_ambush_cleared()
	)


func _is_outlet_clamp_ambush_cleared() -> bool:
	return (
		_lower_deck_forward_pressure_aftershock_condenser_outlet_clamp_spark_rat_defeated
	)


func _is_outlet_drip_vent_available() -> bool:
	return (
		_is_outlet_clamp_ambush_cleared()
		and not _lower_deck_forward_pressure_aftershock_condenser_drip_vent_activated
		and not _lower_deck_forward_pressure_aftershock_condenser_drip_vent_crossed
	)


func _is_outlet_drip_vent_active() -> bool:
	return (
		_lower_deck_forward_pressure_aftershock_condenser_drip_vent_activated
		and _is_outlet_clamp_ambush_cleared()
		and not _lower_deck_forward_pressure_aftershock_condenser_drip_vent_crossed
	)


func _is_overflow_pump_available() -> bool:
	return (
		_lower_deck_forward_pressure_aftershock_condenser_drip_vent_crossed
		and not _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_activated
		and not _is_overflow_pump_cleared()
	)


func _is_overflow_pump_active() -> bool:
	return (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_activated
		and _lower_deck_forward_pressure_aftershock_condenser_drip_vent_crossed
		and not _is_overflow_pump_cleared()
	)


func _is_overflow_pump_cleared() -> bool:
	return (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_coil_rat_defeated
	)


func _is_overflow_pump_reward_cache_available() -> bool:
	return (
		_is_overflow_pump_cleared()
		and not _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_reward_cache_claimed
	)


func _is_overflow_pump_exit_hatch_available() -> bool:
	return (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_reward_cache_claimed
		and not _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_exit_hatch_opened
	)


func _is_overflow_pump_runoff_duct_available() -> bool:
	return (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_exit_hatch_opened
		and not _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_duct_crossed
	)


func _is_overflow_pump_runoff_duct_active() -> bool:
	return (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_duct_activated
		and _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_exit_hatch_opened
		and not _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_duct_crossed
	)


func _is_overflow_pump_runoff_exit_skirmish_available() -> bool:
	return (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_duct_crossed
		and not _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_skirmish_activated
		and not _is_overflow_pump_runoff_exit_skirmish_cleared()
	)


func _is_overflow_pump_runoff_exit_skirmish_active() -> bool:
	return (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_skirmish_activated
		and _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_duct_crossed
		and not _is_overflow_pump_runoff_exit_skirmish_cleared()
	)


func _is_overflow_pump_runoff_exit_skirmish_cleared() -> bool:
	return (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_coil_rat_defeated
	)


func _is_overflow_pump_runoff_exit_reward_cache_available() -> bool:
	return (
		_is_overflow_pump_runoff_exit_skirmish_cleared()
		and not _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_reward_cache_claimed
	)


func _is_overflow_pump_runoff_exit_gate_available() -> bool:
	return (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_reward_cache_claimed
		and not _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_gate_opened
	)


func _is_overflow_pump_runoff_outlet_available() -> bool:
	return (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_gate_opened
		and not _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_activated
		and not _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_crossed
	)


func _is_overflow_pump_runoff_outlet_active() -> bool:
	return (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_activated
		and _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_gate_opened
		and not _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_crossed
	)


func _is_overflow_pump_runoff_outlet_skirmish_available() -> bool:
	return (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_crossed
		and not _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_skirmish_activated
		and not _is_overflow_pump_runoff_outlet_skirmish_cleared()
	)


func _is_overflow_pump_runoff_outlet_skirmish_active() -> bool:
	return (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_skirmish_activated
		and _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_crossed
		and not _is_overflow_pump_runoff_outlet_skirmish_cleared()
	)


func _is_overflow_pump_runoff_outlet_skirmish_cleared() -> bool:
	return (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_spark_rat_defeated
	)


func _is_overflow_pump_runoff_outlet_reward_cache_available() -> bool:
	return (
		_is_overflow_pump_runoff_outlet_skirmish_cleared()
		and not _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_reward_cache_claimed
	)


func _is_overflow_pump_runoff_outlet_service_hatch_available() -> bool:
	return (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_reward_cache_claimed
		and not _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_hatch_opened
	)


func _is_overflow_pump_runoff_outlet_service_sluice_available() -> bool:
	return (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_hatch_opened
		and not _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_activated
		and not _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_crossed
	)


func _is_overflow_pump_runoff_outlet_service_sluice_active() -> bool:
	return (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_activated
		and _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_hatch_opened
		and not _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_crossed
	)


func _is_overflow_pump_runoff_outlet_service_sluice_skirmish_available() -> bool:
	return (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_crossed
		and not _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_skirmish_activated
		and not _is_overflow_pump_runoff_outlet_service_sluice_skirmish_cleared()
	)


func _is_overflow_pump_runoff_outlet_service_sluice_skirmish_active() -> bool:
	return (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_skirmish_activated
		and _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_crossed
		and not _is_overflow_pump_runoff_outlet_service_sluice_skirmish_cleared()
	)


func _is_overflow_pump_runoff_outlet_service_sluice_skirmish_cleared() -> bool:
	return (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_spark_rat_defeated
	)


func _is_lower_deck_forward_pressure_contact_active() -> bool:
	return (
		_lower_deck_forward_pressure_traverse_active
		and _get_lower_deck_forward_pressure_phase() == &"active"
	)


func _is_lower_deck_forward_pressure_aftershock_exhaust_contact_active() -> bool:
	return (
		_is_lower_deck_forward_pressure_aftershock_exhaust_active()
		and _get_lower_deck_forward_pressure_aftershock_exhaust_phase() == &"active"
	)


func _is_lower_deck_forward_pressure_aftershock_exhaust_flank_contact_active() -> bool:
	return _is_lower_deck_forward_pressure_aftershock_exhaust_flank_active()


func _is_lower_deck_forward_pressure_aftershock_cooling_duct_contact_active() -> bool:
	return (
		_is_lower_deck_forward_pressure_aftershock_cooling_duct_active()
		and _get_lower_deck_forward_pressure_aftershock_cooling_duct_phase() == &"active"
	)


func _is_lower_deck_forward_pressure_aftershock_condenser_outlet_contact_active() -> bool:
	return (
		_is_lower_deck_forward_pressure_aftershock_condenser_outlet_active()
		and _get_condenser_outlet_phase() == &"active"
	)


func _is_outlet_drip_vent_contact_active() -> bool:
	return (
		_is_outlet_drip_vent_active()
		and _get_outlet_drip_vent_phase() == &"active"
	)


func _is_overflow_pump_runoff_duct_contact_active() -> bool:
	return (
		_is_overflow_pump_runoff_duct_active()
		and _get_overflow_pump_runoff_duct_phase() == &"active"
	)


func _is_overflow_pump_runoff_outlet_contact_active() -> bool:
	return (
		_is_overflow_pump_runoff_outlet_active()
		and _get_overflow_pump_runoff_outlet_phase() == &"active"
	)


func _is_overflow_pump_runoff_outlet_service_sluice_contact_active() -> bool:
	return (
		_is_overflow_pump_runoff_outlet_service_sluice_active()
		and _get_overflow_pump_runoff_outlet_service_sluice_phase() == &"active"
	)


func _get_lower_deck_forward_pressure_phase() -> StringName:
	if _lower_deck_forward_pressure_traverse_crossed:
		return &"crossed"
	if not _lower_deck_forward_pressure_traverse_active:
		return &"idle"
	var elapsed_sec: float = _lower_deck_forward_pressure_traverse_elapsed_sec
	if elapsed_sec < FACTORY_LOWER_DECK_FORWARD_PRESSURE_INITIAL_GRACE_SEC:
		return &"grace"
	var cycle_sec: float = (
		FACTORY_LOWER_DECK_FORWARD_PRESSURE_WARNING_SEC
		+ FACTORY_LOWER_DECK_FORWARD_PRESSURE_ACTIVE_SEC
		+ FACTORY_LOWER_DECK_FORWARD_PRESSURE_SAFE_SEC
	)
	var phase_sec: float = fmod(
		elapsed_sec - FACTORY_LOWER_DECK_FORWARD_PRESSURE_INITIAL_GRACE_SEC,
		cycle_sec
	)
	if phase_sec < FACTORY_LOWER_DECK_FORWARD_PRESSURE_WARNING_SEC:
		return &"warning"
	if (
		phase_sec
		< (
			FACTORY_LOWER_DECK_FORWARD_PRESSURE_WARNING_SEC
			+ FACTORY_LOWER_DECK_FORWARD_PRESSURE_ACTIVE_SEC
		)
	):
		return &"active"
	return &"safe"


func _get_lower_deck_forward_pressure_aftershock_exhaust_phase() -> StringName:
	if _lower_deck_forward_pressure_aftershock_exhaust_crossed:
		return &"crossed"
	if not _is_lower_deck_forward_pressure_aftershock_exhaust_active():
		return &"idle"
	var elapsed_sec: float = _lower_deck_forward_pressure_aftershock_exhaust_elapsed_sec
	if elapsed_sec < FACTORY_LOWER_DECK_FORWARD_PRESSURE_INITIAL_GRACE_SEC:
		return &"grace"
	var cycle_sec: float = (
		FACTORY_LOWER_DECK_FORWARD_PRESSURE_WARNING_SEC
		+ FACTORY_LOWER_DECK_FORWARD_PRESSURE_ACTIVE_SEC
		+ FACTORY_LOWER_DECK_FORWARD_PRESSURE_SAFE_SEC
	)
	var phase_sec: float = fmod(
		elapsed_sec - FACTORY_LOWER_DECK_FORWARD_PRESSURE_INITIAL_GRACE_SEC,
		cycle_sec
	)
	if phase_sec < FACTORY_LOWER_DECK_FORWARD_PRESSURE_WARNING_SEC:
		return &"warning"
	if (
		phase_sec
		< (
			FACTORY_LOWER_DECK_FORWARD_PRESSURE_WARNING_SEC
			+ FACTORY_LOWER_DECK_FORWARD_PRESSURE_ACTIVE_SEC
		)
	):
		return &"active"
	return &"safe"


func _get_lower_deck_forward_pressure_aftershock_cooling_duct_phase() -> StringName:
	if _lower_deck_forward_pressure_aftershock_cooling_duct_crossed:
		return &"crossed"
	if not _is_lower_deck_forward_pressure_aftershock_cooling_duct_active():
		return &"idle"
	var elapsed_sec: float = (
		_lower_deck_forward_pressure_aftershock_cooling_duct_elapsed_sec
	)
	if elapsed_sec < FACTORY_LOWER_DECK_FORWARD_PRESSURE_INITIAL_GRACE_SEC:
		return &"grace"
	var cycle_sec: float = (
		FACTORY_LOWER_DECK_FORWARD_PRESSURE_WARNING_SEC
		+ FACTORY_LOWER_DECK_FORWARD_PRESSURE_ACTIVE_SEC
		+ FACTORY_LOWER_DECK_FORWARD_PRESSURE_SAFE_SEC
	)
	var phase_sec: float = fmod(
		elapsed_sec - FACTORY_LOWER_DECK_FORWARD_PRESSURE_INITIAL_GRACE_SEC,
		cycle_sec
	)
	if phase_sec < FACTORY_LOWER_DECK_FORWARD_PRESSURE_WARNING_SEC:
		return &"warning"
	if (
		phase_sec
		< (
			FACTORY_LOWER_DECK_FORWARD_PRESSURE_WARNING_SEC
			+ FACTORY_LOWER_DECK_FORWARD_PRESSURE_ACTIVE_SEC
		)
	):
		return &"active"
	return &"safe"


func _get_condenser_outlet_phase() -> StringName:
	if _lower_deck_forward_pressure_aftershock_condenser_outlet_crossed:
		return &"crossed"
	if not _is_lower_deck_forward_pressure_aftershock_condenser_outlet_active():
		return &"idle"
	var elapsed_sec: float = (
		_lower_deck_forward_pressure_aftershock_condenser_outlet_elapsed_sec
	)
	if elapsed_sec < FACTORY_LOWER_DECK_FORWARD_PRESSURE_INITIAL_GRACE_SEC:
		return &"grace"
	var cycle_sec: float = (
		FACTORY_LOWER_DECK_FORWARD_PRESSURE_WARNING_SEC
		+ FACTORY_LOWER_DECK_FORWARD_PRESSURE_ACTIVE_SEC
		+ FACTORY_LOWER_DECK_FORWARD_PRESSURE_SAFE_SEC
	)
	var phase_sec: float = fmod(
		elapsed_sec - FACTORY_LOWER_DECK_FORWARD_PRESSURE_INITIAL_GRACE_SEC,
		cycle_sec
	)
	if phase_sec < FACTORY_LOWER_DECK_FORWARD_PRESSURE_WARNING_SEC:
		return &"warning"
	if (
		phase_sec
		< (
			FACTORY_LOWER_DECK_FORWARD_PRESSURE_WARNING_SEC
			+ FACTORY_LOWER_DECK_FORWARD_PRESSURE_ACTIVE_SEC
		)
	):
		return &"active"
	return &"safe"


func _get_outlet_drip_vent_phase() -> StringName:
	if _lower_deck_forward_pressure_aftershock_condenser_drip_vent_crossed:
		return &"crossed"
	if not _is_outlet_drip_vent_active():
		return &"idle"
	var elapsed_sec: float = (
		_lower_deck_forward_pressure_aftershock_condenser_drip_vent_elapsed_sec
	)
	if elapsed_sec < FACTORY_LOWER_DECK_FORWARD_PRESSURE_INITIAL_GRACE_SEC:
		return &"grace"
	var cycle_sec: float = (
		FACTORY_LOWER_DECK_FORWARD_PRESSURE_WARNING_SEC
		+ FACTORY_LOWER_DECK_FORWARD_PRESSURE_ACTIVE_SEC
		+ FACTORY_LOWER_DECK_FORWARD_PRESSURE_SAFE_SEC
	)
	var phase_sec: float = fmod(
		elapsed_sec - FACTORY_LOWER_DECK_FORWARD_PRESSURE_INITIAL_GRACE_SEC,
		cycle_sec
	)
	if phase_sec < FACTORY_LOWER_DECK_FORWARD_PRESSURE_WARNING_SEC:
		return &"warning"
	if (
		phase_sec
		< (
			FACTORY_LOWER_DECK_FORWARD_PRESSURE_WARNING_SEC
			+ FACTORY_LOWER_DECK_FORWARD_PRESSURE_ACTIVE_SEC
		)
	):
		return &"active"
	return &"safe"


func _get_overflow_pump_runoff_duct_phase() -> StringName:
	if _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_duct_crossed:
		return &"crossed"
	if not _is_overflow_pump_runoff_duct_active():
		return &"idle"
	var elapsed_sec: float = (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_duct_elapsed_sec
	)
	if elapsed_sec < FACTORY_LOWER_DECK_FORWARD_PRESSURE_INITIAL_GRACE_SEC:
		return &"grace"
	var cycle_sec: float = (
		FACTORY_LOWER_DECK_FORWARD_PRESSURE_WARNING_SEC
		+ FACTORY_LOWER_DECK_FORWARD_PRESSURE_ACTIVE_SEC
		+ FACTORY_LOWER_DECK_FORWARD_PRESSURE_SAFE_SEC
	)
	var phase_sec: float = fmod(
		elapsed_sec - FACTORY_LOWER_DECK_FORWARD_PRESSURE_INITIAL_GRACE_SEC,
		cycle_sec
	)
	if phase_sec < FACTORY_LOWER_DECK_FORWARD_PRESSURE_WARNING_SEC:
		return &"warning"
	if (
		phase_sec
		< (
			FACTORY_LOWER_DECK_FORWARD_PRESSURE_WARNING_SEC
			+ FACTORY_LOWER_DECK_FORWARD_PRESSURE_ACTIVE_SEC
		)
	):
		return &"active"
	return &"safe"


func _get_overflow_pump_runoff_outlet_phase() -> StringName:
	if _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_crossed:
		return &"crossed"
	if not _is_overflow_pump_runoff_outlet_active():
		return &"idle"
	var elapsed_sec: float = (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_elapsed_sec
	)
	if elapsed_sec < FACTORY_LOWER_DECK_FORWARD_PRESSURE_INITIAL_GRACE_SEC:
		return &"grace"
	var cycle_sec: float = (
		FACTORY_LOWER_DECK_FORWARD_PRESSURE_WARNING_SEC
		+ FACTORY_LOWER_DECK_FORWARD_PRESSURE_ACTIVE_SEC
		+ FACTORY_LOWER_DECK_FORWARD_PRESSURE_SAFE_SEC
	)
	var phase_sec: float = fmod(
		elapsed_sec - FACTORY_LOWER_DECK_FORWARD_PRESSURE_INITIAL_GRACE_SEC,
		cycle_sec
	)
	if phase_sec < FACTORY_LOWER_DECK_FORWARD_PRESSURE_WARNING_SEC:
		return &"warning"
	if (
		phase_sec
		< (
			FACTORY_LOWER_DECK_FORWARD_PRESSURE_WARNING_SEC
			+ FACTORY_LOWER_DECK_FORWARD_PRESSURE_ACTIVE_SEC
		)
		):
			return &"active"
	return &"safe"


func _get_overflow_pump_runoff_outlet_service_sluice_phase() -> StringName:
	if _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_crossed:
		return &"crossed"
	if not _is_overflow_pump_runoff_outlet_service_sluice_active():
		return &"idle"
	var elapsed_sec: float = (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_elapsed_sec
	)
	if elapsed_sec < FACTORY_LOWER_DECK_FORWARD_PRESSURE_INITIAL_GRACE_SEC:
		return &"grace"
	var cycle_sec: float = (
		FACTORY_LOWER_DECK_FORWARD_PRESSURE_WARNING_SEC
		+ FACTORY_LOWER_DECK_FORWARD_PRESSURE_ACTIVE_SEC
		+ FACTORY_LOWER_DECK_FORWARD_PRESSURE_SAFE_SEC
	)
	var phase_sec: float = fmod(
		elapsed_sec - FACTORY_LOWER_DECK_FORWARD_PRESSURE_INITIAL_GRACE_SEC,
		cycle_sec
	)
	if phase_sec < FACTORY_LOWER_DECK_FORWARD_PRESSURE_WARNING_SEC:
		return &"warning"
	if (
		phase_sec
		< (
			FACTORY_LOWER_DECK_FORWARD_PRESSURE_WARNING_SEC
			+ FACTORY_LOWER_DECK_FORWARD_PRESSURE_ACTIVE_SEC
		)
	):
		return &"active"
	return &"safe"


func _is_checkpoint_overdrive_duo_cleared() -> bool:
	return _checkpoint_overdrive_left_defeated and _checkpoint_overdrive_right_defeated


func _is_checkpoint_route_chain_started() -> bool:
	return (
		_checkpoint_forward_patrol_activated
		or _checkpoint_forward_patrol_defeated
		or _checkpoint_rear_ambush_activated
		or _checkpoint_rear_ambush_defeated
		or _checkpoint_overdrive_duo_activated
		or _checkpoint_overdrive_left_defeated
		or _checkpoint_overdrive_right_defeated
	)


func _try_auto_activate_checkpoint_forward_patrol() -> void:
	if _checkpoint_forward_patrol_activated or _checkpoint_forward_patrol_defeated:
		return
	if not _return_checkpoint_activated:
		return
	try_activate_factory_checkpoint_forward_patrol(_player)


func _try_auto_activate_checkpoint_rear_ambush() -> void:
	if _checkpoint_rear_ambush_activated or _checkpoint_rear_ambush_defeated:
		return
	if not _checkpoint_forward_patrol_defeated:
		return
	try_activate_factory_checkpoint_rear_ambush(_player)


func _try_auto_activate_checkpoint_overdrive_duo() -> void:
	if _checkpoint_overdrive_duo_activated or _is_checkpoint_overdrive_duo_cleared():
		return
	if not _checkpoint_rear_ambush_defeated:
		return
	try_activate_factory_checkpoint_overdrive_duo(_player)


func _try_auto_activate_forward_pressure_beacon_ambush() -> void:
	if (
		_lower_deck_forward_pressure_beacon_ambush_activated
		or _lower_deck_forward_pressure_beacon_ambush_defeated
	):
		return
	if not _lower_deck_forward_pressure_route_handoff_marker_lit:
		return
	try_activate_factory_lower_deck_forward_pressure_beacon_ambush(_player)


func _try_auto_activate_forward_pressure_overrun() -> void:
	if (
		_lower_deck_forward_pressure_overrun_activated
		or _lower_deck_forward_pressure_overrun_defeated
	):
		return
	if not _lower_deck_forward_pressure_beacon_ambush_defeated:
		return
	try_activate_factory_lower_deck_forward_pressure_overrun(_player)


func _try_auto_activate_forward_pressure_breaker() -> void:
	if (
		_lower_deck_forward_pressure_breaker_activated
		or _lower_deck_forward_pressure_breaker_secured
	):
		return
	if not _lower_deck_forward_pressure_overrun_defeated:
		return
	try_activate_factory_lower_deck_forward_pressure_breaker_stand(_player)


func _try_auto_activate_forward_pressure_relief_ambush() -> void:
	if (
		_lower_deck_forward_pressure_relief_ambush_activated
		or _lower_deck_forward_pressure_relief_ambush_defeated
	):
		return
	if not _lower_deck_forward_pressure_breaker_cut:
		return
	try_activate_factory_lower_deck_forward_pressure_relief_ambush(_player)


func _try_auto_activate_forward_pressure_coil_rat_breakthrough() -> void:
	if (
		_lower_deck_forward_pressure_coil_rat_activated
		or _lower_deck_forward_pressure_coil_rat_defeated
	):
		return
	if not _lower_deck_forward_pressure_relief_ambush_defeated:
		return
	try_activate_factory_lower_deck_forward_pressure_coil_rat_breakthrough(_player)


func _try_auto_activate_forward_pressure_coil_pincer() -> void:
	if (
		_lower_deck_forward_pressure_coil_pincer_activated
		or _is_lower_deck_forward_pressure_coil_pincer_cleared()
	):
		return
	if not _lower_deck_forward_pressure_coil_rat_defeated:
		return
	try_activate_factory_lower_deck_forward_pressure_coil_pincer(_player)


func _try_auto_activate_forward_pressure_coil_aftershock() -> void:
	if (
		_lower_deck_forward_pressure_coil_aftershock_activated
		or _lower_deck_forward_pressure_coil_aftershock_defeated
	):
		return
	if not _is_lower_deck_forward_pressure_coil_pincer_cleared():
		return
	try_activate_factory_lower_deck_forward_pressure_coil_aftershock(_player)


func _try_auto_activate_forward_pressure_aftershock_exit_skirmish() -> void:
	if (
		_lower_deck_forward_pressure_aftershock_exit_skirmish_activated
		or _is_lower_deck_forward_pressure_aftershock_exit_skirmish_cleared()
	):
		return
	if not _lower_deck_forward_pressure_aftershock_reward_cache_claimed:
		return
	try_activate_factory_lower_deck_forward_pressure_aftershock_exit_skirmish(_player)


func _try_auto_activate_forward_pressure_aftershock_exhaust() -> void:
	if (
		_lower_deck_forward_pressure_aftershock_exhaust_activated
		or _lower_deck_forward_pressure_aftershock_exhaust_crossed
	):
		return
	if not _is_lower_deck_forward_pressure_aftershock_exit_skirmish_cleared():
		return
	try_activate_factory_lower_deck_forward_pressure_aftershock_exhaust(_player)


func _try_auto_activate_forward_pressure_aftershock_exhaust_pursuer() -> void:
	if (
		_lower_deck_forward_pressure_aftershock_exhaust_pursuer_activated
		or _lower_deck_forward_pressure_aftershock_exhaust_pursuer_defeated
	):
		return
	if not _lower_deck_forward_pressure_aftershock_exhaust_crossed:
		return
	try_activate_factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer(_player)


func _try_auto_activate_forward_pressure_aftershock_exhaust_flank() -> void:
	if (
		_lower_deck_forward_pressure_aftershock_exhaust_flank_activated
		or _lower_deck_forward_pressure_aftershock_exhaust_flank_spark_rat_defeated
	):
		return
	if not _lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache_claimed:
		return
	try_activate_factory_lower_deck_forward_pressure_aftershock_exhaust_flank_ambush(
		_player
	)


func _try_auto_activate_forward_pressure_aftershock_exhaust_breaker() -> void:
	if (
		_lower_deck_forward_pressure_aftershock_exhaust_breaker_activated
		or _lower_deck_forward_pressure_aftershock_exhaust_breaker_secured
		or _lower_deck_forward_pressure_aftershock_exhaust_breaker_cut
	):
		return
	if not _lower_deck_forward_pressure_aftershock_exhaust_flank_spark_rat_defeated:
		return
	try_activate_factory_lower_deck_forward_pressure_aftershock_exhaust_breaker_stand(
		_player
	)


func _try_auto_activate_forward_pressure_aftershock_exhaust_escape_skirmish() -> void:
	if (
		_lower_deck_forward_pressure_aftershock_exhaust_escape_skirmish_activated
		or _is_lower_deck_forward_pressure_aftershock_exhaust_escape_skirmish_cleared()
	):
		return
	if not _lower_deck_forward_pressure_aftershock_exhaust_breaker_cut:
		return
	try_activate_factory_lower_deck_forward_pressure_aftershock_exhaust_escape_skirmish(
		_player
	)


func _try_auto_activate_forward_pressure_aftershock_cooling_duct() -> void:
	if (
		_lower_deck_forward_pressure_aftershock_cooling_duct_activated
		or _lower_deck_forward_pressure_aftershock_cooling_duct_crossed
	):
		return
	if not _lower_deck_forward_pressure_aftershock_exhaust_exit_hatch_opened:
		return
	try_activate_factory_lower_deck_forward_pressure_aftershock_cooling_duct(_player)


func _try_auto_complete_forward_pressure_aftershock_cooling_duct() -> void:
	if not _is_lower_deck_forward_pressure_aftershock_cooling_duct_active():
		return
	try_complete_factory_lower_deck_forward_pressure_aftershock_cooling_duct(_player)


func _try_auto_activate_forward_pressure_aftershock_condenser_valve() -> void:
	if (
		_lower_deck_forward_pressure_aftershock_condenser_valve_activated
		or _is_lower_deck_forward_pressure_aftershock_condenser_valve_cleared()
	):
		return
	if not _lower_deck_forward_pressure_aftershock_cooling_duct_crossed:
		return
	try_activate_factory_lower_deck_forward_pressure_aftershock_condenser_valve(_player)


func _auto_activate_condenser_outlet() -> void:
	if (
		_lower_deck_forward_pressure_aftershock_condenser_outlet_activated
		or _lower_deck_forward_pressure_aftershock_condenser_outlet_crossed
	):
		return
	if not _lower_deck_forward_pressure_aftershock_condenser_savepoint_activated:
		return
	try_activate_factory_lower_deck_forward_pressure_aftershock_condenser_outlet(
		_player
	)


func _auto_complete_condenser_outlet() -> void:
	if not _is_lower_deck_forward_pressure_aftershock_condenser_outlet_active():
		return
	try_complete_factory_lower_deck_forward_pressure_aftershock_condenser_outlet(_player)


func _auto_activate_outlet_clamp_ambush() -> void:
	if (
		_lower_deck_forward_pressure_aftershock_condenser_outlet_clamp_ambush_activated
		or _is_outlet_clamp_ambush_cleared()
	):
		return
	if not _lower_deck_forward_pressure_aftershock_condenser_outlet_crossed:
		return
	try_activate_factory_lower_deck_forward_pressure_aftershock_condenser_outlet_clamp_ambush(
		_player
	)


func _auto_activate_outlet_drip_vent() -> void:
	if (
		_lower_deck_forward_pressure_aftershock_condenser_drip_vent_activated
		or _lower_deck_forward_pressure_aftershock_condenser_drip_vent_crossed
	):
		return
	if not _is_outlet_clamp_ambush_cleared():
		return
	try_activate_factory_lower_deck_forward_pressure_aftershock_condenser_outlet_drip_vent(
		_player
	)


func _auto_complete_outlet_drip_vent() -> void:
	if not _is_outlet_drip_vent_active():
		return
	try_complete_factory_lower_deck_forward_pressure_aftershock_condenser_outlet_drip_vent(
		_player
	)


func _auto_activate_overflow_pump() -> void:
	if (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_activated
		or _is_overflow_pump_cleared()
	):
		return
	if not _lower_deck_forward_pressure_aftershock_condenser_drip_vent_crossed:
		return
	try_activate_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump(
		_player
	)


func _auto_activate_overflow_pump_runoff_exit_skirmish() -> void:
	if (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_skirmish_activated
		or _is_overflow_pump_runoff_exit_skirmish_cleared()
	):
		return
	if not _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_duct_crossed:
		return
	try_activate_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_skirmish(
		_player
	)


func _auto_activate_overflow_pump_runoff_outlet() -> void:
	if (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_activated
		or _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_crossed
	):
		return
	if not _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_gate_opened:
		return
	try_activate_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet(
		_player
	)


func _auto_complete_overflow_pump_runoff_outlet() -> void:
	if not _is_overflow_pump_runoff_outlet_active():
		return
	try_complete_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet(
		_player
	)


func _auto_activate_overflow_pump_runoff_outlet_skirmish() -> void:
	if (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_skirmish_activated
		or _is_overflow_pump_runoff_outlet_skirmish_cleared()
	):
		return
	if not _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_crossed:
		return
	try_activate_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_skirmish(
		_player
	)


func _auto_activate_overflow_pump_runoff_outlet_service_sluice() -> void:
	if (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_activated
		or _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_crossed
	):
		return
	if not _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_hatch_opened:
		return
	try_activate_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice(
		_player
	)


func _auto_complete_overflow_pump_runoff_outlet_service_sluice() -> void:
	if not _is_overflow_pump_runoff_outlet_service_sluice_active():
		return
	try_complete_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice(
		_player
	)


func _auto_activate_overflow_pump_runoff_outlet_service_sluice_skirmish() -> void:
	if (
		_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_skirmish_activated
		or _is_overflow_pump_runoff_outlet_service_sluice_skirmish_cleared()
	):
		return
	if (
		not _lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_crossed
	):
		return
	try_activate_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_skirmish(
		_player
	)


func _is_service_lift_return_contract_in_state(state: Dictionary) -> bool:
	return (
		bool(state.get("factory_service_lift_exit_requested", false))
		and String(state.get("factory_service_lift_exit_scene_id", ""))
			== String(FACTORY_SERVICE_LIFT_EXIT_SCENE_ID)
		and String(state.get("factory_service_lift_exit_spawn_point", ""))
			== String(FACTORY_SERVICE_LIFT_EXIT_SPAWN_POINT)
	)
