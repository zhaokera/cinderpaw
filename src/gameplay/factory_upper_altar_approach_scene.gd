## Story134 destination: a short upper-Factory traversal to the dormant altar.
class_name FactoryUpperAltarApproachScene
extends Node2D

const SCENE_ID: StringName = &"area_03_factory_upper_altar"
const ARRIVAL_SPAWN_POINT: StringName = &"cistern_ascender_arrival"
const UNDERGROUND_SCENE_ID: StringName = &"area_04_underground_passage"
const UNDERGROUND_RETURN_SPAWN: StringName = &"deep_cistern_ascender_return"
const DISCOVERY_RADIUS_PX: float = 112.0
const BACKGROUND_TEXTURE_PATH: String = (
	"res://assets/environment/factory_upper_altar/"
	+ "env_factory_upper_altar_approach_1280x720.png"
)
const ASCENDER_TEXTURE_PATH: String = (
	"res://assets/environment/factory_upper_altar/"
	+ "prop_deep_cistern_ascender_384x512.png"
)
const ALTAR_TEXTURE_PATH: String = (
	"res://assets/environment/factory_upper_altar/"
	+ "prop_factory_hidden_altar_dormant_384x384.png"
)

@onready var _background: Sprite2D = get_node_or_null("Background") as Sprite2D
@onready var _arrival_spawn: Marker2D = (
	get_node_or_null("CisternAscenderArrival") as Marker2D
)
@onready var _player: Node2D = get_node_or_null("Player") as Node2D
@onready var _camera: Camera2D = get_node_or_null("Player/Camera2D") as Camera2D
@onready var _return_route: Node2D = (
	get_node_or_null("UndergroundReturnRoute") as Node2D
)
@onready var _return_prompt: Label = (
	get_node_or_null("UndergroundReturnRoute/PromptLabel") as Label
)
@onready var _altar: Node2D = get_node_or_null("DormantHiddenAltar") as Node2D
@onready var _altar_visual: Sprite2D = (
	get_node_or_null("DormantHiddenAltar/Visual") as Sprite2D
)
@onready var _altar_pulse: Sprite2D = (
	get_node_or_null("DormantHiddenAltar/DiscoveryPulse") as Sprite2D
)
@onready var _altar_prompt: Label = (
	get_node_or_null("DormantHiddenAltar/PromptLabel") as Label
)
@onready var _objective_label: Label = (
	get_node_or_null("ObjectiveLabel") as Label
)
@onready var _hud: HUDManager = get_node_or_null("HUD") as HUDManager

var _scene_manager: Object = null
var _altar_discovered: bool = false
var _discovery_feedback_count: int = 0
var _return_transition_requested: bool = false
var _last_return_rejected_reason: StringName = &""
var _last_return_request: Dictionary = {}


func _ready() -> void:
	_align_player_to_arrival()
	_setup_player_hud()
	_sync_return_route()
	_sync_altar_state(false)
	_sync_objective_position()
	var root_scene_manager: Node = get_node_or_null("/root/SceneManager")
	if _is_valid_scene_manager(root_scene_manager):
		configure_scene_manager_runtime(root_scene_manager)


func _process(_delta: float) -> void:
	if not _altar_discovered and _is_provider_near_altar(_player):
		try_discover_hidden_altar(_player)
	_sync_prompt_visibility()
	_sync_objective_position()
	if (
		not _return_transition_requested
		and Input.is_action_just_pressed(&"interact")
		and _is_provider_near_return(_player)
	):
		try_request_underground_return(_player)


func configure_scene_manager_runtime(scene_manager: Object) -> bool:
	_scene_manager = scene_manager
	if not _is_valid_scene_manager(_scene_manager):
		return false
	_apply_current_scene_manager_spawn_point()
	return true


## Records discovery once without granting the next Story's ability reward.
func try_discover_hidden_altar(provider: Node = null) -> bool:
	if _altar_discovered:
		return false
	var discovery_provider: Node = _player if provider == null else provider
	if not _is_provider_near_altar(discovery_provider):
		return false
	_altar_discovered = true
	_discovery_feedback_count += 1
	_sync_altar_state(true)
	return true


## Requests the bidirectional return to the cleared deep-cistern arena.
func try_request_underground_return(provider: Node = null) -> bool:
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
		_scene_manager.call("has_scene", UNDERGROUND_SCENE_ID)
	):
		_record_return_rejection(&"unknown_scene")
		return false
	if not _ensure_runtime_scene_root():
		_record_return_rejection(&"runtime_root_unavailable")
		return false
	if not _persist_progress():
		_record_return_rejection(&"state_persist_failed")
		return false
	if not _request_scene_change(
		UNDERGROUND_SCENE_ID,
		UNDERGROUND_RETURN_SPAWN
	):
		_record_return_rejection(&"request_rejected")
		return false

	_return_transition_requested = true
	_last_return_rejected_reason = &""
	_last_return_request = {
		"scene_id": String(UNDERGROUND_SCENE_ID),
		"spawn_point": String(UNDERGROUND_RETURN_SPAWN),
		"pending_scene": _get_pending_scene(),
		"pending_spawn_point": _get_pending_spawn_point(),
	}
	_sync_return_route()
	_refresh_objective_text()
	return true


func get_local_state() -> Dictionary:
	return {
		"factory_upper_hidden_altar_discovered": _altar_discovered,
		"unlocked_abilities": _get_player_unlocked_ability_strings(),
	}


func set_local_state(state: Dictionary) -> void:
	_altar_discovered = bool(state.get(
		"factory_upper_hidden_altar_discovered",
		false
	))
	_restore_player_unlocked_abilities(state)
	_discovery_feedback_count = 0
	_return_transition_requested = false
	_last_return_rejected_reason = &""
	_last_return_request.clear()
	_sync_return_route()
	_sync_altar_state(false)
	_align_player_to_arrival()


func get_factory_upper_altar_diagnostics() -> Dictionary:
	return {
		"scene_id": String(SCENE_ID),
		"scene_size_px": Vector2i(1280, 720),
		"background_texture_path": _get_texture_path(_background),
		"background_expected_path": BACKGROUND_TEXTURE_PATH,
		"ascender_texture_path": _get_route_texture_path(),
		"ascender_expected_path": ASCENDER_TEXTURE_PATH,
		"altar_texture_path": _get_texture_path(_altar_visual),
		"altar_expected_path": ALTAR_TEXTURE_PATH,
		"arrival_spawn_position": (
			_arrival_spawn.global_position if _arrival_spawn != null else Vector2.ZERO
		),
		"player_position": _player.global_position if _player != null else Vector2.ZERO,
		"platform_count": 3,
		"return_route_available": _is_return_route_available(),
		"return_target_scene_id": String(UNDERGROUND_SCENE_ID),
		"return_spawn_point": String(UNDERGROUND_RETURN_SPAWN),
		"return_transition_requested": _return_transition_requested,
		"last_return_rejected_reason": String(_last_return_rejected_reason),
		"last_return_request": _last_return_request.duplicate(true),
		"altar_discovered": _altar_discovered,
		"discovery_feedback_count": _discovery_feedback_count,
		"altar_prompt_visible": _altar_prompt != null and _altar_prompt.visible,
		"objective_text": _objective_label.text if _objective_label != null else "",
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


func _sync_altar_state(play_feedback: bool) -> void:
	if _altar_visual != null:
		_altar_visual.modulate = (
			Color(1.0, 0.9, 1.0, 1.0)
			if _altar_discovered
			else Color(0.72, 0.76, 0.84, 0.9)
		)
	if _altar_pulse != null:
		_altar_pulse.visible = false
		_altar_pulse.modulate = Color(0.9, 0.72, 1.0, 0.0)
		_altar_pulse.scale = Vector2(0.52, 0.52)
		if play_feedback:
			_altar_pulse.visible = true
			var tween: Tween = create_tween()
			tween.set_parallel(true)
			tween.tween_property(
				_altar_pulse,
				"modulate:a",
				0.72,
				0.12
			)
			tween.tween_property(
				_altar_pulse,
				"scale",
				Vector2(0.62, 0.62),
				0.42
			)
			tween.chain().tween_property(
				_altar_pulse,
				"modulate:a",
				0.0,
				0.28
			)
			tween.tween_callback(func() -> void:
				if is_instance_valid(_altar_pulse):
					_altar_pulse.visible = false
			)
	_refresh_objective_text()
	_sync_prompt_visibility()


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
	if _altar_prompt != null:
		_altar_prompt.text = "Inspect Dormant Altar"
		_altar_prompt.visible = (
			not _altar_discovered
			and _is_provider_near_altar(_player)
		)


func _refresh_objective_text() -> void:
	if _objective_label == null:
		return
	if _return_transition_requested:
		_objective_label.text = "Descending to Deep Cistern"
	elif _altar_discovered:
		_objective_label.text = "Dormant Altar Found"
	else:
		_objective_label.text = "Reach the Dormant Altar"


func _sync_objective_position() -> void:
	if _objective_label == null or _camera == null or not _camera.is_inside_tree():
		return
	_objective_label.position = (
		_camera.get_screen_center_position() + Vector2(-220.0, -288.0)
	)


func _align_player_to_arrival() -> bool:
	if _player == null or _arrival_spawn == null:
		return false
	_player.global_position = _arrival_spawn.global_position
	if _player is CharacterBody2D:
		(_player as CharacterBody2D).velocity = Vector2.ZERO
	return true


func _apply_current_scene_manager_spawn_point() -> void:
	if not _is_valid_scene_manager(_scene_manager):
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


func _is_provider_near_altar(provider: Node) -> bool:
	return (
		provider is Node2D
		and _altar != null
		and (provider as Node2D).global_position.distance_to(
			_altar.global_position
		) <= DISCOVERY_RADIUS_PX
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
	var underground_state: Dictionary = {}
	if _scene_manager.has_method("get_scene_state"):
		underground_state = Dictionary(_scene_manager.call(
			"get_scene_state",
			UNDERGROUND_SCENE_ID
		)).duplicate(true)
	var underground_abilities: Array = Array(
		underground_state.get("unlocked_abilities", [])
	)
	for ability_id: String in _get_player_unlocked_ability_strings():
		if not underground_abilities.has(ability_id):
			underground_abilities.append(ability_id)
	underground_state["unlocked_abilities"] = underground_abilities
	return bool(_scene_manager.call(
		"set_scene_state",
		UNDERGROUND_SCENE_ID,
		underground_state
	)) and persisted


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


func _get_route_texture_path() -> String:
	if _return_route == null:
		return ""
	return _get_texture_path(
		_return_route.get_node_or_null("Visual") as Sprite2D
	)


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
