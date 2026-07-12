## Story136 destination: a bounded Neon Rooftops wall-climb entry slice.
class_name NeonRooftopsEntryScene
extends Node2D

const SCENE_ID: StringName = &"area_05_neon_rooftops"
const ARRIVAL_SPAWN_POINT: StringName = &"factory_rooftop_arrival"
const FACTORY_SCENE_ID: StringName = &"area_03_factory_upper_altar"
const FACTORY_RETURN_SPAWN: StringName = &"neon_rooftops_return"
const WALL_CLIMB_ABILITY_ID: StringName = &"wall_climb"
const PROOF_RADIUS_PX: float = 150.0
const ROOFTOP_MUSIC_ID: StringName = &"mus_rooftop"
const ROOFTOP_AMBIENT_ID: StringName = &"amb_rooftop"
const ROOFTOP_AUDIO_FADE_SEC: float = 1.2
const ROOFTOP_PLAYER_LIGHT_DAMAGE: int = 12
const WEAPON_COMPONENT_SCRIPT: Script = preload(
	"res://src/core/weapon_component.gd"
)
const BACKGROUND_TEXTURE_PATH: String = (
	"res://assets/environment/neon_rooftops/"
	+ "env_neon_rooftops_entry_1280x720.png"
)
const MAGNETIC_TOWER_TEXTURE_PATH: String = (
	"res://assets/environment/neon_rooftops/"
	+ "prop_neon_magnetic_tower_256x512.png"
)
const FACTORY_BRIDGE_TEXTURE_PATH: String = (
	"res://assets/environment/neon_rooftops/"
	+ "prop_neon_factory_bridge_beacon_256x384.png"
)
const CONTACT_GLOW_TEXTURE_PATH: String = (
	"res://assets/environment/factory_upper_altar/"
	+ "vfx_wall_climb_contact_glow_192x192.png"
)

@onready var _background: Sprite2D = get_node_or_null("Background") as Sprite2D
@onready var _arrival_spawn: Marker2D = (
	get_node_or_null("FactoryRooftopArrival") as Marker2D
)
@onready var _player: Node2D = get_node_or_null("Player") as Node2D
@onready var _camera: Camera2D = get_node_or_null("Player/Camera2D") as Camera2D
@onready var _magnetic_tower_visual: Sprite2D = (
	get_node_or_null("MagneticTower/Visual") as Sprite2D
)
@onready var _wall_contact_glow: Sprite2D = (
	get_node_or_null("MagneticTower/ContactGlow") as Sprite2D
)
@onready var _proof_area: Area2D = (
	get_node_or_null("RooftopProofArea") as Area2D
)
@onready var _return_route: Node2D = (
	get_node_or_null("FactoryReturnRoute") as Node2D
)
@onready var _return_visual: Sprite2D = (
	get_node_or_null("FactoryReturnRoute/Visual") as Sprite2D
)
@onready var _return_prompt: Label = (
	get_node_or_null("FactoryReturnRoute/PromptLabel") as Label
)
@onready var _objective_label: Label = (
	get_node_or_null("ObjectiveLabel") as Label
)
@onready var _hud: HUDManager = get_node_or_null("HUD") as HUDManager
@onready var _signal_roof_encounter: NeonSignalRoofEncounterController = (
	get_node_or_null("SignalRoofEncounter")
	as NeonSignalRoofEncounterController
)
@onready var _relay_spire: NeonRelaySpireController = (
	get_node_or_null("RelaySpireController") as NeonRelaySpireController
)
@onready var _tower_parry_trial: NeonTowerParryTrialController = (
	get_node_or_null("TowerParryTrialController")
	as NeonTowerParryTrialController
)

var _scene_manager: Object = null
var _weapon_component: WeaponComponent = null
var _entry_arrived: bool = false
var _entry_traversed: bool = false
var _entry_feedback_count: int = 0
var _wall_contact_feedback_count: int = 0
var _wall_contact_tween: Tween = null
var _return_transition_requested: bool = false
var _last_return_rejected_reason: StringName = &""
var _last_return_request: Dictionary = {}
var _audio_request_count: int = 0
var _last_signal_roof_player_hit: Dictionary = {}


func _ready() -> void:
	_entry_arrived = true
	_align_player_to_arrival()
	_setup_weapon_component()
	_bind_player_combat_to_room()
	_setup_player_hud()
	_setup_wall_climb_runtime()
	_setup_signal_roof_encounter()
	_setup_relay_spire()
	_setup_tower_parry_trial()
	_sync_return_route()
	_refresh_objective_text()
	_sync_objective_position()
	_request_rooftop_audio()
	var root_scene_manager: Node = get_node_or_null("/root/SceneManager")
	if _is_valid_scene_manager(root_scene_manager):
		configure_scene_manager_runtime(root_scene_manager)


func _process(_delta: float) -> void:
	if not _entry_traversed and _is_provider_near_proof(_player):
		try_prove_neon_rooftop_entry(_player)
	_sync_prompt_visibility()
	_refresh_objective_text()
	_sync_objective_position()
	if not _return_transition_requested and Input.is_action_just_pressed(
		&"interact"
	):
		if _is_provider_near_return(_player):
			try_request_factory_return(_player)
		else:
			try_claim_signal_cache(_player)


func configure_scene_manager_runtime(scene_manager: Object) -> bool:
	_scene_manager = scene_manager
	if not _is_valid_scene_manager(_scene_manager):
		return false
	_entry_arrived = true
	_apply_current_scene_manager_spawn_point()
	return true


## Configures Story138 autosave through a SaveSystem-like adapter.
func configure_neon_relay_spire_save_system_runtime(
	save_system: Object
) -> bool:
	if _relay_spire == null:
		return false
	return _relay_spire.configure_save_system_runtime(save_system)


## Attempts the nearby one-shot Story138 roost activation.
func try_activate_neon_relay_spire_roost(provider: Node = null) -> bool:
	if _relay_spire == null:
		return false
	return _relay_spire.try_activate_roost(provider)


## Routes Story138's lethal gap through the dedicated controller.
func apply_neon_relay_spire_fall(target: Node = null) -> bool:
	if _relay_spire == null:
		return false
	return _relay_spire.apply_fall(target)


## Advances Story138's deterministic death and revive timers.
func advance_neon_relay_spire_respawn_flow(delta_sec: float) -> void:
	if _relay_spire != null:
		_relay_spire.advance_respawn_flow(delta_sec)


## Attempts the far-side Story138 Tower Approach endpoint.
func try_activate_neon_relay_spire_endpoint(
	provider: Node = null
) -> bool:
	if _relay_spire == null:
		return false
	return _relay_spire.try_activate_endpoint(provider)


## Attempts to start Story139's nearby Central Tower laser timing trial.
func try_activate_central_tower_parry_trial(
	provider: Node = null
) -> bool:
	if _tower_parry_trial == null:
		return false
	return _tower_parry_trial.try_activate(provider)


## Advances Story139 pulse timing for focused tests and deterministic smoke.
func advance_central_tower_parry_trial(delta_sec: float) -> void:
	if _tower_parry_trial != null:
		_tower_parry_trial.advance_time(delta_sec)


## Attempts the one-shot Story139 Central Tower outer threshold endpoint.
func try_activate_central_tower_threshold(
	provider: Node = null
) -> bool:
	if _tower_parry_trial == null:
		return false
	return _tower_parry_trial.try_activate_threshold(provider)


## Captures the JSON-safe rooftop snapshot used by roost autosave.
func capture_save_snapshot() -> Dictionary:
	var last_savepoint: Dictionary = {}
	if _relay_spire != null:
		last_savepoint = _relay_spire.get_last_discovered_savepoint()
	return {
		"player_state": {
			"current_hp": int(_player.call("get_current_hp")) if (
				_player != null and _player.has_method("get_current_hp")
			) else 0,
			"max_hp": int(_player.call("get_max_hp")) if (
				_player != null and _player.has_method("get_max_hp")
			) else 0,
			"unlocked_abilities": _get_player_unlocked_ability_strings(),
		},
		"world_state": {
			"scene_id": String(SCENE_ID),
			"scene_states": {
				String(SCENE_ID): get_local_state(),
			},
			"last_savepoint": last_savepoint,
		},
		"settings": {},
	}


## Records the first high-roof arrival only for a Wall Climb-capable provider.
func try_prove_neon_rooftop_entry(provider: Node = null) -> bool:
	if _entry_traversed:
		return false
	var proof_provider: Node = _player if provider == null else provider
	if (
		not _is_provider_near_proof(proof_provider)
		or not _provider_has_ability(proof_provider, WALL_CLIMB_ABILITY_ID)
	):
		return false
	_entry_traversed = true
	_entry_feedback_count += 1
	if _signal_roof_encounter != null:
		_signal_roof_encounter.set_route_unlocked(true)
	_refresh_objective_text()
	if _is_valid_scene_manager(_scene_manager):
		_persist_progress()
	return true


## Attempts the Story137 Signal Roof ambush activation.
func try_activate_signal_roof_encounter(provider: Node = null) -> bool:
	if _signal_roof_encounter == null:
		return false
	return _signal_roof_encounter.try_activate(provider)


## Requests the Signal Rat attack for deterministic smoke and MCP probes.
func request_signal_rat_attack() -> bool:
	if _signal_roof_encounter == null:
		return false
	return _signal_roof_encounter.request_signal_rat_attack()


## Attempts the once-only post-combat rooftop cache claim.
func try_claim_signal_cache(provider: Node = null) -> bool:
	if _signal_roof_encounter == null:
		return false
	return _signal_roof_encounter.try_claim_cache(provider)


## Routes player hit-confirm damage to the Story137 enemy adapter.
func apply_damage(
	target_id: int,
	final_damage: int,
	metadata: Dictionary = {}
) -> bool:
	if (
		_signal_roof_encounter == null
		or not _signal_roof_encounter.handles_target_id(target_id)
	):
		return false
	return _signal_roof_encounter.apply_damage(
		target_id,
		final_damage,
		metadata
	)


## Supplies deterministic player light damage through the shared combat chain.
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
		"final_damage": ROOFTOP_PLAYER_LIGHT_DAMAGE,
		"base_damage": ROOFTOP_PLAYER_LIGHT_DAMAGE,
		"attack_damage": float(ROOFTOP_PLAYER_LIGHT_DAMAGE),
		"reduction_factor": 1.0,
		"damage_multiplier": 1.0,
		"is_crit": false,
		"crit_type": &"none",
		"parry_type": &"none",
		"combo_stage": combo_index,
		"damage_category": &"scratch",
	}


## Returns the most recent Signal Roof player hit-confirm payload.
func get_last_signal_roof_player_hit() -> Dictionary:
	return _last_signal_roof_player_hit.duplicate(true)


## Persists the latest Story137 state when a SceneManager is available.
func persist_signal_roof_progress() -> bool:
	_sync_relay_spire_route()
	_refresh_objective_text()
	if not _is_valid_scene_manager(_scene_manager):
		return true
	return _persist_progress()


## Persists the latest Story138 state when SceneManager is available.
func persist_neon_relay_spire_progress() -> bool:
	_sync_tower_parry_trial_route()
	_refresh_objective_text()
	if not _is_valid_scene_manager(_scene_manager):
		return true
	return _persist_progress()


## Persists the latest Story139 trial and threshold progress.
func persist_central_tower_parry_trial_progress() -> bool:
	_refresh_objective_text()
	if not _is_valid_scene_manager(_scene_manager):
		return true
	return _persist_progress()


## Returns the dedicated Story137 diagnostics surface.
func get_signal_roof_diagnostics() -> Dictionary:
	if _signal_roof_encounter == null:
		return {
			"route_width_px": 2560,
			"controller_present": false,
		}
	return _signal_roof_encounter.get_diagnostics()


## Returns the dedicated Story138 diagnostics surface.
func get_neon_relay_spire_diagnostics() -> Dictionary:
	if _relay_spire == null:
		return {
			"route_width_px": 3840,
			"controller_present": false,
		}
	return _relay_spire.get_diagnostics()


## Returns the dedicated Story139 diagnostics surface.
func get_central_tower_parry_trial_diagnostics() -> Dictionary:
	if _tower_parry_trial == null:
		return {
			"route_width_px": 5120,
			"controller_present": false,
		}
	return _tower_parry_trial.get_diagnostics()


## Captures durable rooftop progress across the no-loss death loop.
func capture_no_loss_state() -> Dictionary:
	return get_local_state()


## Restores durable rooftop progress across the no-loss death loop.
func restore_no_loss_state(snapshot: Dictionary) -> void:
	set_local_state(snapshot)


## Returns to the permanent high-perch spawn in Factory Upper Altar.
func try_request_factory_return(provider: Node = null) -> bool:
	if _return_route == null or _return_transition_requested:
		_record_return_rejection(&"transition_already_requested")
		return false
	var request_provider: Node = _player if provider == null else provider
	if (
		not _return_route.has_method("can_request_transition")
		or not bool(_return_route.call(
			"can_request_transition",
			request_provider
		))
	):
		_record_return_rejection(&"provider_out_of_range")
		return false
	if not _can_use_scene_manager_for(FACTORY_SCENE_ID):
		return false
	if not _ensure_runtime_scene_root():
		_record_return_rejection(&"runtime_root_unavailable")
		return false
	if not _persist_progress():
		_record_return_rejection(&"state_persist_failed")
		return false
	if not _request_scene_change(FACTORY_SCENE_ID, FACTORY_RETURN_SPAWN):
		_record_return_rejection(&"request_rejected")
		return false

	_return_transition_requested = true
	_last_return_rejected_reason = &""
	_last_return_request = {
		"scene_id": String(FACTORY_SCENE_ID),
		"spawn_point": String(FACTORY_RETURN_SPAWN),
		"pending_scene": _get_pending_scene(),
		"pending_spawn_point": _get_pending_spawn_point(),
	}
	_sync_return_route()
	_refresh_objective_text()
	return true


func get_local_state() -> Dictionary:
	var state: Dictionary = {
		"neon_rooftops_entry_arrived": _entry_arrived,
		"neon_rooftops_entry_traversed": _entry_traversed,
		"unlocked_abilities": _get_player_unlocked_ability_strings(),
	}
	if _signal_roof_encounter != null:
		state.merge(_signal_roof_encounter.get_local_state(), true)
	if _relay_spire != null:
		state.merge(_relay_spire.get_local_state(), true)
	if _tower_parry_trial != null:
		state.merge(_tower_parry_trial.get_local_state(), true)
	return state


func set_local_state(state: Dictionary) -> void:
	_entry_arrived = bool(state.get(
		"neon_rooftops_entry_arrived",
		_entry_arrived
	)) or _entry_arrived
	_entry_traversed = bool(state.get(
		"neon_rooftops_entry_traversed",
		false
	))
	_restore_player_unlocked_abilities(state)
	if _signal_roof_encounter != null:
		_signal_roof_encounter.set_route_unlocked(_entry_traversed)
		_signal_roof_encounter.set_local_state(state)
	if _relay_spire != null:
		_relay_spire.set_route_unlocked(_is_signal_cache_claimed())
		_relay_spire.set_local_state(state)
	if _tower_parry_trial != null:
		_tower_parry_trial.set_route_unlocked(_is_relay_spire_traversed())
		_tower_parry_trial.set_local_state(state)
	_entry_feedback_count = 0
	_wall_contact_feedback_count = 0
	_return_transition_requested = false
	_last_return_rejected_reason = &""
	_last_return_request.clear()
	_last_signal_roof_player_hit.clear()
	_sync_return_route()
	_refresh_objective_text()
	_apply_current_scene_manager_spawn_point()


func get_neon_rooftops_entry_diagnostics() -> Dictionary:
	return {
		"scene_id": String(SCENE_ID),
		"scene_size_px": Vector2i(5120, 720),
		"background_texture_path": _get_texture_path(_background),
		"background_expected_path": BACKGROUND_TEXTURE_PATH,
		"magnetic_tower_texture_path": _get_texture_path(
			_magnetic_tower_visual
		),
		"magnetic_tower_expected_path": MAGNETIC_TOWER_TEXTURE_PATH,
		"factory_bridge_texture_path": _get_texture_path(_return_visual),
		"factory_bridge_expected_path": FACTORY_BRIDGE_TEXTURE_PATH,
		"wall_contact_glow_texture_path": _get_texture_path(
			_wall_contact_glow
		),
		"wall_contact_glow_expected_path": CONTACT_GLOW_TEXTURE_PATH,
		"arrival_spawn_position": (
			_arrival_spawn.global_position
			if _arrival_spawn != null
			else Vector2.ZERO
		),
		"player_position": (
			_player.global_position if _player != null else Vector2.ZERO
		),
		"proof_position": (
			_proof_area.global_position if _proof_area != null else Vector2.ZERO
		),
		"entry_arrived": _entry_arrived,
		"entry_traversed": _entry_traversed,
		"entry_feedback_count": _entry_feedback_count,
		"wall_contact_feedback_count": _wall_contact_feedback_count,
		"wall_contact_glow_visible": (
			_wall_contact_glow != null and _wall_contact_glow.visible
		),
		"return_route_available": _is_return_route_available(),
		"return_target_scene_id": String(FACTORY_SCENE_ID),
		"return_spawn_point": String(FACTORY_RETURN_SPAWN),
		"return_transition_requested": _return_transition_requested,
		"last_return_rejected_reason": String(_last_return_rejected_reason),
		"last_return_request": _last_return_request.duplicate(true),
		"objective_text": _objective_label.text if _objective_label != null else "",
		"music_id": String(ROOFTOP_MUSIC_ID),
		"ambient_id": String(ROOFTOP_AMBIENT_ID),
		"audio_request_count": _audio_request_count,
		"unlocked_abilities": _get_player_unlocked_ability_strings(),
	}


func _setup_weapon_component() -> void:
	_weapon_component = get_node_or_null("WeaponComponent") as WeaponComponent
	if _weapon_component == null:
		_weapon_component = WEAPON_COMPONENT_SCRIPT.new() as WeaponComponent
		_weapon_component.name = "WeaponComponent"
		add_child(_weapon_component)
	var data_manager: Node = get_node_or_null("/root/DataManager")
	if data_manager != null:
		_weapon_component.set_data_manager(data_manager)


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
			_weapon_component.set_combat_adapter(
				_player.call("get_combat_component")
			)
		if _player.has_method("get_collision_component"):
			_weapon_component.set_collision_adapter(
				_player.call("get_collision_component")
			)
	if _player.has_signal("attack_landed"):
		var attack_signal: Signal = _player.get("attack_landed")
		if not attack_signal.is_connected(_on_player_attack_landed):
			attack_signal.connect(_on_player_attack_landed)


func _on_player_attack_landed(metadata: Dictionary) -> void:
	_last_signal_roof_player_hit = metadata.duplicate(true)


func _setup_signal_roof_encounter() -> void:
	if _signal_roof_encounter == null:
		return
	if not _signal_roof_encounter.objective_changed.is_connected(
		_on_signal_roof_objective_changed
	):
		_signal_roof_encounter.objective_changed.connect(
			_on_signal_roof_objective_changed
		)
	_signal_roof_encounter.configure_runtime(_player, self)
	_signal_roof_encounter.set_route_unlocked(_entry_traversed)


func _on_signal_roof_objective_changed(_objective_text: String) -> void:
	_sync_relay_spire_route()
	_refresh_objective_text()


func _setup_relay_spire() -> void:
	if _relay_spire == null:
		return
	if not _relay_spire.objective_changed.is_connected(
		_on_relay_spire_objective_changed
	):
		_relay_spire.objective_changed.connect(
			_on_relay_spire_objective_changed
		)
	_relay_spire.configure_runtime(
		_player,
		self,
		get_node_or_null("/root/SaveSystem")
	)
	_sync_relay_spire_route()


func _sync_relay_spire_route() -> void:
	if _relay_spire != null:
		_relay_spire.set_route_unlocked(_is_signal_cache_claimed())


func _on_relay_spire_objective_changed(_objective_text: String) -> void:
	_sync_tower_parry_trial_route()
	_refresh_objective_text()


func _setup_tower_parry_trial() -> void:
	if _tower_parry_trial == null:
		return
	if not _tower_parry_trial.objective_changed.is_connected(
		_on_tower_parry_trial_objective_changed
	):
		_tower_parry_trial.objective_changed.connect(
			_on_tower_parry_trial_objective_changed
		)
	_tower_parry_trial.configure_runtime(_player, self)
	_sync_tower_parry_trial_route()


func _sync_tower_parry_trial_route() -> void:
	if _tower_parry_trial != null:
		_tower_parry_trial.set_route_unlocked(_is_relay_spire_traversed())


func _on_tower_parry_trial_objective_changed(
	_objective_text: String
) -> void:
	_refresh_objective_text()


func _setup_player_hud() -> void:
	if _player == null or _hud == null:
		return
	if _player.has_signal("player_health_changed"):
		var health_signal: Signal = _player.get("player_health_changed")
		if not health_signal.is_connected(_on_player_health_changed):
			health_signal.connect(_on_player_health_changed)
	if _player.has_method("get_current_hp") and _player.has_method("get_max_hp"):
		_hud.update_hp(
			int(_player.call("get_current_hp")),
			int(_player.call("get_max_hp"))
		)


func _on_player_health_changed(current_hp: int, max_hp: int) -> void:
	if _hud != null:
		_hud.update_hp(current_hp, max_hp)


func _setup_wall_climb_runtime() -> void:
	if _player != null and _player.has_signal("wall_climb_started"):
		var climb_signal: Signal = _player.get("wall_climb_started")
		if not climb_signal.is_connected(_on_player_wall_climb_started):
			climb_signal.connect(_on_player_wall_climb_started)
	if (
		_proof_area != null
		and not _proof_area.body_entered.is_connected(
			_on_rooftop_proof_body_entered
		)
	):
		_proof_area.body_entered.connect(_on_rooftop_proof_body_entered)


func _on_player_wall_climb_started(
	_texture: Texture2D,
	world_position: Vector2,
	wall_normal: Vector2
) -> void:
	if _wall_contact_glow == null:
		return
	_wall_contact_feedback_count += 1
	if _wall_contact_tween != null and _wall_contact_tween.is_valid():
		_wall_contact_tween.kill()
	_wall_contact_glow.global_position = world_position - wall_normal * 22.0
	_wall_contact_glow.visible = true
	_wall_contact_glow.scale = Vector2(0.34, 0.34)
	_wall_contact_glow.modulate = Color(1.0, 1.0, 1.0, 0.92)
	_wall_contact_tween = create_tween()
	_wall_contact_tween.set_parallel(true)
	_wall_contact_tween.tween_property(
		_wall_contact_glow,
		"scale",
		Vector2(0.52, 0.52),
		0.28
	)
	_wall_contact_tween.tween_property(
		_wall_contact_glow,
		"modulate:a",
		0.0,
		0.34
	)
	_wall_contact_tween.chain().tween_callback(func() -> void:
		if is_instance_valid(_wall_contact_glow):
			_wall_contact_glow.visible = false
	)


func _on_rooftop_proof_body_entered(body: Node2D) -> void:
	try_prove_neon_rooftop_entry(body)


func _sync_return_route() -> void:
	if _return_route == null:
		return
	if _return_route.has_method("set_route_available"):
		_return_route.call("set_route_available", true)
	if _return_route.has_method("set_transition_requested"):
		_return_route.call(
			"set_transition_requested",
			_return_transition_requested
		)
	_sync_prompt_visibility()


func _sync_prompt_visibility() -> void:
	if _return_prompt != null:
		_return_prompt.visible = (
			not _return_transition_requested
			and _is_provider_near_return(_player)
		)


func _refresh_objective_text() -> void:
	if _objective_label == null:
		return
	if _return_transition_requested:
		_objective_label.text = "Returning to Factory Altar"
	elif (
		_tower_parry_trial != null
		and _tower_parry_trial.should_own_objective(_player)
	):
		_objective_label.text = _tower_parry_trial.get_objective_text()
	elif (
		_relay_spire != null
		and _relay_spire.should_own_objective(_player)
	):
		_objective_label.text = _relay_spire.get_objective_text()
	elif (
		_signal_roof_encounter != null
		and _signal_roof_encounter.should_own_objective(_player)
	):
		_objective_label.text = _signal_roof_encounter.get_objective_text()
	elif _entry_traversed:
		_objective_label.text = "Reach Signal Roof"
	else:
		_objective_label.text = "Climb the Neon Magnetic Tower"


func _sync_objective_position() -> void:
	if _objective_label == null or _camera == null or not _camera.is_inside_tree():
		return
	_objective_label.position = (
		_camera.get_screen_center_position() + Vector2(-250.0, -288.0)
	)


func _request_rooftop_audio() -> void:
	var audio_system: Node = get_node_or_null("/root/AudioSystem")
	if audio_system == null:
		return
	if audio_system.has_method("play_music"):
		audio_system.call("play_music", ROOFTOP_MUSIC_ID, ROOFTOP_AUDIO_FADE_SEC)
		_audio_request_count += 1
	if audio_system.has_method("play_ambient"):
		audio_system.call(
			"play_ambient",
			ROOFTOP_AMBIENT_ID,
			ROOFTOP_AUDIO_FADE_SEC
		)
		_audio_request_count += 1


func _align_player_to_arrival() -> bool:
	if _player == null or _arrival_spawn == null:
		return false
	_player.global_position = _arrival_spawn.global_position
	if _player is CharacterBody2D:
		(_player as CharacterBody2D).velocity = Vector2.ZERO
	return true


func _apply_current_scene_manager_spawn_point() -> void:
	if not _is_valid_scene_manager(_scene_manager):
		_align_player_to_arrival()
		return
	if _scene_manager.has_method("get_current_scene") and StringName(
		_scene_manager.call("get_current_scene")
	) != SCENE_ID:
		return
	var spawn_point: StringName = ARRIVAL_SPAWN_POINT
	if _scene_manager.has_method("get_current_spawn_point"):
		spawn_point = StringName(_scene_manager.call("get_current_spawn_point"))
	if spawn_point in [ARRIVAL_SPAWN_POINT, &"default"]:
		_align_player_to_arrival()
	elif spawn_point == &"relay_spire_roost" and _relay_spire != null:
		_relay_spire.align_player_to_roost()


func _is_signal_cache_claimed() -> bool:
	if _signal_roof_encounter == null:
		return false
	return bool(_signal_roof_encounter.get_local_state().get(
		"neon_rooftops_signal_cache_claimed",
		false
	))


func _is_relay_spire_traversed() -> bool:
	if _relay_spire == null:
		return false
	return bool(_relay_spire.get_local_state().get(
		"neon_rooftops_relay_spire_traversed",
		false
	))


func _is_provider_near_proof(provider: Node) -> bool:
	return (
		provider is Node2D
		and _proof_area != null
		and (provider as Node2D).global_position.distance_to(
			_proof_area.global_position
		) <= PROOF_RADIUS_PX
	)


func _is_provider_near_return(provider: Node) -> bool:
	return (
		_return_route != null
		and provider != null
		and _return_route.has_method("is_provider_in_transition_range")
		and bool(_return_route.call(
			"is_provider_in_transition_range",
			provider
		))
	)


func _provider_has_ability(provider: Node, ability_id: StringName) -> bool:
	return (
		provider != null
		and provider.has_method("has_ability")
		and bool(provider.call("has_ability", ability_id))
	)


func _is_return_route_available() -> bool:
	return (
		_return_route != null
		and _return_route.has_method("is_route_available")
		and bool(_return_route.call("is_route_available"))
	)


func _persist_progress() -> bool:
	if (
		not _is_valid_scene_manager(_scene_manager)
		or not _scene_manager.has_method("set_scene_state")
	):
		return false
	var persisted: bool = bool(_scene_manager.call(
		"set_scene_state",
		SCENE_ID,
		get_local_state()
	))
	return _merge_player_abilities_into_scene_state(FACTORY_SCENE_ID) and persisted


func _merge_player_abilities_into_scene_state(scene_id: StringName) -> bool:
	if (
		_scene_manager.has_method("has_scene")
		and not bool(_scene_manager.call("has_scene", scene_id))
	):
		return false
	var state: Dictionary = {}
	if _scene_manager.has_method("get_scene_state"):
		state = Dictionary(_scene_manager.call(
			"get_scene_state",
			scene_id
		)).duplicate(true)
	var abilities: Array = Array(state.get("unlocked_abilities", []))
	for ability_id: String in _get_player_unlocked_ability_strings():
		if not abilities.has(ability_id):
			abilities.append(ability_id)
	state["unlocked_abilities"] = abilities
	return bool(_scene_manager.call("set_scene_state", scene_id, state))


func _can_use_scene_manager_for(scene_id: StringName) -> bool:
	if not _is_valid_scene_manager(_scene_manager):
		_record_return_rejection(&"scene_manager_missing")
		return false
	if _scene_manager.has_method("is_loading") and bool(
		_scene_manager.call("is_loading")
	):
		_record_return_rejection(&"scene_manager_loading")
		return false
	if _scene_manager.has_method("is_scene_locked") and bool(
		_scene_manager.call("is_scene_locked")
	):
		_record_return_rejection(&"scene_locked")
		return false
	if _scene_manager.has_method("has_scene") and not bool(
		_scene_manager.call("has_scene", scene_id)
	):
		_record_return_rejection(&"unknown_scene")
		return false
	return true


func _ensure_runtime_scene_root() -> bool:
	if not _scene_manager.has_method("configure_runtime_scene_root"):
		return true
	if _scene_manager.has_method("is_runtime_scene_swap_enabled") and bool(
		_scene_manager.call("is_runtime_scene_swap_enabled")
	):
		return true
	return bool(_scene_manager.call(
		"configure_runtime_scene_root",
		get_parent(),
		self
	))


func _request_scene_change(
	scene_id: StringName,
	spawn_point: StringName
) -> bool:
	if _scene_manager.has_method("request_scene_change"):
		return bool(_scene_manager.call(
			"request_scene_change",
			scene_id,
			spawn_point
		))
	if _scene_manager.has_method("change_scene"):
		return bool(_scene_manager.call("change_scene", scene_id, spawn_point))
	return false


func _get_player_unlocked_ability_strings() -> Array[String]:
	var unlocked: Array[String] = []
	if _player == null or not _player.has_method("get_unlocked_abilities"):
		return unlocked
	var values: Variant = _player.call("get_unlocked_abilities")
	if not values is Array:
		return unlocked
	for value: Variant in values:
		var ability_id: String = String(value)
		if not unlocked.has(ability_id):
			unlocked.append(ability_id)
	return unlocked


func _restore_player_unlocked_abilities(state: Dictionary) -> void:
	if _player == null or not _player.has_method("set_unlocked_abilities"):
		return
	_player.call(
		"set_unlocked_abilities",
		Array(state.get(
			"unlocked_abilities",
			_get_player_unlocked_ability_strings()
		))
	)


func _get_texture_path(sprite: Sprite2D) -> String:
	if sprite == null or sprite.texture == null:
		return ""
	return sprite.texture.resource_path


func _record_return_rejection(reason: StringName) -> void:
	_last_return_rejected_reason = reason


func _get_pending_scene() -> String:
	return (
		String(_scene_manager.call("get_pending_scene"))
		if _scene_manager.has_method("get_pending_scene")
		else ""
	)


func _get_pending_spawn_point() -> String:
	return (
		String(_scene_manager.call("get_pending_spawn_point"))
		if _scene_manager.has_method("get_pending_spawn_point")
		else ""
	)


func _is_valid_scene_manager(scene_manager: Object) -> bool:
	return (
		scene_manager != null
		and is_instance_valid(scene_manager)
		and (
			scene_manager.has_method("request_scene_change")
			or scene_manager.has_method("change_scene")
		)
	)
