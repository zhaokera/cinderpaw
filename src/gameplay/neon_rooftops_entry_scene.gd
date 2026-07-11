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

var _scene_manager: Object = null
var _entry_arrived: bool = false
var _entry_traversed: bool = false
var _entry_feedback_count: int = 0
var _wall_contact_feedback_count: int = 0
var _wall_contact_tween: Tween = null
var _return_transition_requested: bool = false
var _last_return_rejected_reason: StringName = &""
var _last_return_request: Dictionary = {}
var _audio_request_count: int = 0


func _ready() -> void:
	_entry_arrived = true
	_align_player_to_arrival()
	_setup_player_hud()
	_setup_wall_climb_runtime()
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
	_sync_objective_position()
	if (
		not _return_transition_requested
		and Input.is_action_just_pressed(&"interact")
		and _is_provider_near_return(_player)
	):
		try_request_factory_return(_player)


func configure_scene_manager_runtime(scene_manager: Object) -> bool:
	_scene_manager = scene_manager
	if not _is_valid_scene_manager(_scene_manager):
		return false
	_entry_arrived = true
	_apply_current_scene_manager_spawn_point()
	return true


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
	_refresh_objective_text()
	if _is_valid_scene_manager(_scene_manager):
		_persist_progress()
	return true


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
	return {
		"neon_rooftops_entry_arrived": _entry_arrived,
		"neon_rooftops_entry_traversed": _entry_traversed,
		"unlocked_abilities": _get_player_unlocked_ability_strings(),
	}


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
	_entry_feedback_count = 0
	_wall_contact_feedback_count = 0
	_return_transition_requested = false
	_last_return_rejected_reason = &""
	_last_return_request.clear()
	_sync_return_route()
	_refresh_objective_text()
	_apply_current_scene_manager_spawn_point()


func get_neon_rooftops_entry_diagnostics() -> Dictionary:
	return {
		"scene_id": String(SCENE_ID),
		"scene_size_px": Vector2i(1280, 720),
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
	elif _entry_traversed:
		_objective_label.text = "Neon Rooftops Reached"
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
	if not _scene_manager.has_method("set_scene_state"):
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
