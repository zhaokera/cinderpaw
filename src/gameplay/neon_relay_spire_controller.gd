## Owns Story138 route access, savepoint, fall, respawn, and endpoint state.
class_name NeonRelaySpireController
extends Node2D

signal objective_changed(objective_text: String)

const ROUTE_WIDTH_PX: int = 3840
const ACCESS_SEAL_X: float = 2580.0
const GAP_START_X: float = 2860.0
const GAP_END_X: float = 3460.0
const MAGNETIC_SPIRE_X: float = 3180.0
const RIGHT_WALL_X: float = 3820.0
const ROOST_ID: StringName = &"neon_rooftops_relay_spire_roost"
const ROOST_SCENE_ID: StringName = &"area_05_neon_rooftops"
const ROOST_SPAWN_POINT: StringName = &"relay_spire_roost"
const BACKGROUND_TEXTURE_PATH: String = (
	"res://assets/environment/neon_rooftops/"
	+ "env_neon_relay_spire_1280x720.png"
)
const ROOST_TEXTURE_PATH: String = (
	"res://assets/environment/neon_rooftops/"
	+ "prop_neon_relay_spire_roost_256x256.png"
)
const SPIRE_TEXTURE_PATH: String = (
	"res://assets/environment/neon_rooftops/"
	+ "prop_neon_magnetic_relay_spire_256x512.png"
)
const ENDPOINT_TEXTURE_PATH: String = (
	"res://assets/environment/neon_rooftops/"
	+ "prop_neon_tower_approach_beacon_256x384.png"
)
const SAVE_TRIGGER_ADAPTER_SCRIPT: Script = preload(
	"res://src/feature/save_trigger_adapter.gd"
)
const GAME_FLOW_SCRIPT: Script = preload(
	"res://src/gameplay/game_flow_controller.gd"
)

@onready var _background: Sprite2D = (
	get_node_or_null("../RelaySpireBackground") as Sprite2D
)
@onready var _access_seal: StaticBody2D = (
	get_node_or_null("AccessSeal") as StaticBody2D
)
@onready var _roost: Node2D = get_node_or_null("RelaySpireRoost") as Node2D
@onready var _endpoint: Node2D = (
	get_node_or_null("TowerApproachEndpoint") as Node2D
)
@onready var _fall_zone: Area2D = get_node_or_null("FallZone") as Area2D
@onready var _spire_visual: Sprite2D = (
	get_node_or_null("../RelaySpireMagneticWall/Visual") as Sprite2D
)
@onready var _roost_prompt: Label = (
	get_node_or_null("RelaySpireRoost/PromptLabel") as Label
)
@onready var _endpoint_prompt: Label = (
	get_node_or_null("TowerApproachEndpoint/PromptLabel") as Label
)

var _route_unlocked: bool = false
var _roost_activated: bool = false
var _traversed: bool = false
var _player: Node2D = null
var _scene_owner: Object = null
var _save_trigger_adapter: SaveTriggerAdapter = null
var _game_flow: GameFlowController = null
var _last_savepoint: Dictionary = {}
var _autosave_request_count: int = 0
var _audio_request_count: int = 0
var _fall_accept_count: int = 0
var _endpoint_feedback_count: int = 0
var _last_autosave_context: Dictionary = {}
var _last_audio_event: Dictionary = {}
var _last_emitted_objective_text: String = ""


func _ready() -> void:
	_connect_roost_signal()
	_connect_route_triggers()
	_sync_state()


func _process(delta: float) -> void:
	advance_respawn_flow(delta)
	_sync_prompt_visibility()


## Injects the player, parent scene, and optional SaveSystem adapter.
func configure_runtime(
	player: Node2D,
	scene_owner: Object,
	save_system: Object = null
) -> bool:
	_player = player
	_scene_owner = scene_owner
	_connect_roost_signal()
	_connect_route_triggers()
	_ensure_game_flow()
	if save_system != null:
		configure_save_system_runtime(save_system)
	_sync_state()
	return _player != null and _scene_owner != null


## Configures slot-zero autosave through the shared SaveTriggerAdapter.
func configure_save_system_runtime(save_system: Object) -> bool:
	if (
		save_system == null
		or not is_instance_valid(save_system)
		or not save_system.has_method("auto_save")
	):
		return false
	if _save_trigger_adapter == null or not is_instance_valid(
		_save_trigger_adapter
	):
		_save_trigger_adapter = (
			SAVE_TRIGGER_ADAPTER_SCRIPT.new() as SaveTriggerAdapter
		)
		_save_trigger_adapter.name = "NeonRelaySpireSaveTriggerAdapter"
		add_child(_save_trigger_adapter)
	var snapshot_provider := Callable()
	if _scene_owner != null and _scene_owner.has_method("capture_save_snapshot"):
		snapshot_provider = Callable(_scene_owner, "capture_save_snapshot")
	_save_trigger_adapter.configure(save_system, snapshot_provider)
	return true


## Story137's claimed cache is the only route prerequisite.
func set_route_unlocked(unlocked: bool) -> void:
	_route_unlocked = unlocked
	_sync_state()


## Attempts the nearby one-shot Relay Spire Roost activation.
func try_activate_roost(provider: Node = null) -> bool:
	if not _route_unlocked or _roost_activated or _roost == null:
		return false
	var activation_provider: Node = _player if provider == null else provider
	if not _is_provider_near(_roost, activation_provider, 104.0):
		return false
	if (
		not _roost.has_method("try_activate")
		or not bool(_roost.call("try_activate", activation_provider))
	):
		return false
	return _roost_activated


## Returns the latest valid savepoint for GameFlow selection.
func get_last_discovered_savepoint() -> Dictionary:
	return _last_savepoint.duplicate(true)


## Applies lethal fall damage only after the roost is active.
func apply_fall(target: Node = null) -> bool:
	var fall_target: Node = _player if target == null else target
	if (
		not _route_unlocked
		or not _roost_activated
		or fall_target == null
		or fall_target != _player
		or not fall_target.has_method("apply_damage")
		or not fall_target.has_method("get_current_hp")
		or int(fall_target.call("get_current_hp")) <= 0
	):
		return false
	var lethal_damage: int = (
		int(fall_target.call("get_max_hp"))
		if fall_target.has_method("get_max_hp")
		else int(fall_target.call("get_current_hp"))
	)
	fall_target.call("apply_damage", lethal_damage, {
		"source": &"neon_relay_spire_fall",
		"damage_type": &"fall",
		"scene_id": ROOST_SCENE_ID,
	})
	if int(fall_target.call("get_current_hp")) > 0:
		return false
	_fall_accept_count += 1
	return true


## Advances the existing deterministic death/revive timers.
func advance_respawn_flow(delta_sec: float) -> void:
	if _game_flow == null or not is_instance_valid(_game_flow):
		return
	_game_flow.advance_time(delta_sec)
	_sync_player_control_lock()


## Records the far-side endpoint exactly once after roost activation.
func try_activate_endpoint(provider: Node = null) -> bool:
	if not _route_unlocked or not _roost_activated or _traversed:
		return false
	var activation_provider: Node = _player if provider == null else provider
	if not _is_provider_near(_endpoint, activation_provider, 112.0):
		return false
	_traversed = true
	_endpoint_feedback_count += 1
	_sync_state()
	_persist_owner_state()
	return true


## Captures only durable Story138 state.
func get_local_state() -> Dictionary:
	return {
		"neon_rooftops_relay_spire_roost_activated": _roost_activated,
		"neon_rooftops_relay_spire_traversed": _traversed,
		"neon_rooftops_relay_spire_last_savepoint": (
			_last_savepoint.duplicate(true)
		),
	}


## Restores Story138 state without replaying one-shot feedback.
func set_local_state(state: Dictionary) -> void:
	_roost_activated = bool(state.get(
		"neon_rooftops_relay_spire_roost_activated",
		false
	))
	_traversed = bool(state.get(
		"neon_rooftops_relay_spire_traversed",
		false
	))
	_last_savepoint = Dictionary(state.get(
		"neon_rooftops_relay_spire_last_savepoint",
		{}
	)).duplicate(true)
	if _roost_activated and _last_savepoint.is_empty():
		_last_savepoint = _build_roost_snapshot()
	_sync_state()


## Aligns the player to the authored Relay Spire Roost marker.
func align_player_to_roost() -> bool:
	if _player == null:
		return false
	var marker: Marker2D = get_node_or_null("RelaySpireRoostSpawn") as Marker2D
	if marker == null:
		return false
	_player.global_position = marker.global_position
	if _player is CharacterBody2D:
		(_player as CharacterBody2D).velocity = Vector2.ZERO
	return true


## Returns whether Story138 owns the shared rooftop objective.
func should_own_objective(provider: Node = null) -> bool:
	if not _route_unlocked:
		return false
	if _roost_activated or _traversed:
		return true
	var objective_provider: Node = _player if provider == null else provider
	return (
		objective_provider is Node2D
		and (objective_provider as Node2D).global_position.x >= 2480.0
	)


func get_objective_text() -> String:
	if _traversed:
		return "Tower Approach Reached"
	if _roost_activated:
		return "Climb Relay Spire"
	return "Reach Relay Spire Roost"


## Returns authored geometry, assets, savepoint, and respawn diagnostics.
func get_diagnostics() -> Dictionary:
	return {
		"route_width_px": ROUTE_WIDTH_PX,
		"controller_present": true,
		"controller_script_path": get_script().resource_path,
		"background_texture_path": _get_sprite_texture_path(_background),
		"roost_texture_path": _get_child_sprite_texture_path(_roost, "Visual"),
		"spire_texture_path": _get_sprite_texture_path(_spire_visual),
		"endpoint_texture_path": _get_child_sprite_texture_path(
			_endpoint,
			"Visual"
		),
		"background_expected_path": BACKGROUND_TEXTURE_PATH,
		"roost_expected_path": ROOST_TEXTURE_PATH,
		"spire_expected_path": SPIRE_TEXTURE_PATH,
		"endpoint_expected_path": ENDPOINT_TEXTURE_PATH,
		"access_seal_x": _get_node_x(_access_seal, ACCESS_SEAL_X),
		"access_seal_blocking": _is_access_seal_blocking(),
		"gap_start_x": GAP_START_X,
		"gap_end_x": GAP_END_X,
		"magnetic_spire_x": MAGNETIC_SPIRE_X,
		"right_wall_x": RIGHT_WALL_X,
		"fall_zone_present": _fall_zone != null,
		"route_unlocked": _route_unlocked,
		"roost_id": String(ROOST_ID),
		"roost_scene_id": String(ROOST_SCENE_ID),
		"roost_spawn_point": String(ROOST_SPAWN_POINT),
		"roost_activated": _roost_activated,
		"traversed": _traversed,
		"objective_text": get_objective_text(),
		"last_savepoint": _last_savepoint.duplicate(true),
		"autosave_request_count": _autosave_request_count,
		"audio_request_count": _audio_request_count,
		"fall_accept_count": _fall_accept_count,
		"endpoint_feedback_count": _endpoint_feedback_count,
		"last_autosave_context": _last_autosave_context.duplicate(true),
		"last_audio_event": _last_audio_event.duplicate(true),
		"roost_vfx": _get_roost_vfx_snapshot(),
		"respawn_state": (
			String(_game_flow.get_flow_state())
			if _game_flow != null and is_instance_valid(_game_flow)
			else ""
		),
		"player_control_locked": (
			_game_flow.is_player_control_locked()
			if _game_flow != null and is_instance_valid(_game_flow)
			else false
		),
		"invincibility_remaining_sec": (
			_game_flow.get_invincibility_remaining()
			if _game_flow != null and is_instance_valid(_game_flow)
			else 0.0
		),
		"last_selected_respawn_point": (
			_game_flow.get_last_selected_respawn_point()
			if _game_flow != null and is_instance_valid(_game_flow)
			else {}
		),
	}


func _sync_state() -> void:
	_set_access_seal_blocking(not _route_unlocked)
	if _roost != null:
		_roost.visible = _route_unlocked
		_set_interaction_enabled(
			_roost,
			_route_unlocked and not _roost_activated
		)
	if _endpoint != null:
		_endpoint.visible = _route_unlocked
		_set_interaction_enabled(
			_endpoint,
			_route_unlocked and _roost_activated and not _traversed
		)
	if _fall_zone != null:
		_set_area_monitoring(
			_fall_zone,
			_route_unlocked and _roost_activated
		)
	_sync_prompt_visibility()
	_emit_objective_if_changed()


func _sync_prompt_visibility() -> void:
	if _roost_prompt != null:
		_roost_prompt.text = (
			"Relay Spire Roost Online"
			if _roost_activated
			else "Activate Relay Spire Roost"
		)
		_roost_prompt.visible = (
			_route_unlocked
			and _is_provider_near(_roost, _player, 192.0)
		)
	if _endpoint_prompt != null:
		_endpoint_prompt.text = (
			"Tower Approach Reached"
			if _traversed
			else (
				"Secure Tower Approach"
				if _roost_activated
				else "Activate Relay Spire Roost"
			)
		)
		_endpoint_prompt.visible = (
			_route_unlocked
			and _is_provider_near(_endpoint, _player, 192.0)
		)


func _connect_roost_signal() -> void:
	if _roost == null or not _roost.has_signal("savepoint_activated"):
		return
	var activated_signal: Signal = _roost.get("savepoint_activated")
	if not activated_signal.is_connected(_on_roost_activated):
		activated_signal.connect(_on_roost_activated)


func _connect_route_triggers() -> void:
	if _fall_zone != null and not _fall_zone.body_entered.is_connected(
		_on_fall_zone_body_entered
	):
		_fall_zone.body_entered.connect(_on_fall_zone_body_entered)
	if _endpoint == null:
		return
	var endpoint_area: Area2D = (
		_endpoint.get_node_or_null("InteractionArea") as Area2D
	)
	if endpoint_area != null and not endpoint_area.body_entered.is_connected(
		_on_endpoint_body_entered
	):
		endpoint_area.body_entered.connect(_on_endpoint_body_entered)


func _ensure_game_flow() -> void:
	if _game_flow == null or not is_instance_valid(_game_flow):
		_game_flow = GAME_FLOW_SCRIPT.new() as GameFlowController
		_game_flow.name = "NeonRelaySpireGameFlowController"
		_game_flow.set_process(false)
		add_child(_game_flow)
		_game_flow.start_encounter(
			_player.global_position if _player != null else Vector2.ZERO
		)
	_game_flow.set_savepoint_adapter(self)
	if _scene_owner != null and _scene_owner.has_method("capture_no_loss_state"):
		_game_flow.set_no_loss_state_adapter(_scene_owner)
	if _player != null and _player.has_signal("player_died"):
		var death_callback := Callable(self, "_on_player_died")
		if not _player.is_connected("player_died", death_callback):
			_player.connect("player_died", death_callback)
	var respawn_callback := Callable(self, "_on_respawn_requested")
	if not _game_flow.respawn_requested.is_connected(respawn_callback):
		_game_flow.respawn_requested.connect(respawn_callback)


func _on_player_died(_metadata: Dictionary) -> void:
	if _game_flow == null or not is_instance_valid(_game_flow):
		return
	_game_flow.handle_player_death()
	_sync_player_control_lock()


func _on_respawn_requested(
	respawn_position: Vector2,
	revive_hp_percentage: float
) -> void:
	if _player != null and _player.has_method("respawn_at"):
		_player.call("respawn_at", respawn_position, revive_hp_percentage)
	_sync_player_control_lock()


func _sync_player_control_lock() -> void:
	if (
		_game_flow == null
		or not is_instance_valid(_game_flow)
		or _player == null
		or not _player.has_method("set_control_locked")
	):
		return
	_player.call("set_control_locked", _game_flow.is_player_control_locked())


func _on_fall_zone_body_entered(body: Node2D) -> void:
	if body == _player:
		apply_fall(body)


func _on_endpoint_body_entered(body: Node2D) -> void:
	if body == _player:
		try_activate_endpoint(body)


func _on_roost_activated(
	savepoint_id: StringName,
	scene_id: StringName,
	spawn_point: StringName,
	world_position: Vector2,
	context: Dictionary
) -> void:
	if (
		not _route_unlocked
		or _roost_activated
		or savepoint_id != ROOST_ID
		or scene_id != ROOST_SCENE_ID
		or spawn_point != ROOST_SPAWN_POINT
	):
		return
	_roost_activated = true
	_last_savepoint = context.duplicate(true)
	_last_savepoint["id"] = String(savepoint_id)
	_last_savepoint["savepoint_id"] = String(savepoint_id)
	_last_savepoint["scene_id"] = String(scene_id)
	_last_savepoint["spawn_point"] = String(spawn_point)
	_last_savepoint["position"] = {
		"x": world_position.x,
		"y": world_position.y,
	}
	if _player != null and _player.has_method("restore_at_savepoint"):
		_player.call("restore_at_savepoint")
	_request_savepoint_audio(world_position, context)
	_trigger_savepoint_autosave(context)
	_sync_state()
	_persist_owner_state()


func _trigger_savepoint_autosave(context: Dictionary) -> void:
	if _save_trigger_adapter == null or not is_instance_valid(
		_save_trigger_adapter
	):
		return
	var save_context: Dictionary = context.duplicate(true)
	save_context["savepoint_id"] = String(ROOST_ID)
	save_context["scene_id"] = String(ROOST_SCENE_ID)
	save_context["spawn_point"] = String(ROOST_SPAWN_POINT)
	if not _save_trigger_adapter.trigger_auto_save(&"savepoint", save_context):
		return
	_autosave_request_count += 1
	_last_autosave_context = save_context


func _request_savepoint_audio(
	world_position: Vector2,
	context: Dictionary
) -> void:
	var metadata: Dictionary = context.duplicate(true)
	metadata["feedback_role"] = &"savepoint_activation"
	metadata["source"] = ROOST_ID
	metadata["world_position"] = world_position
	_audio_request_count += 1
	_last_audio_event = {
		"event_id": &"savepoint_activated",
		"sfx_id": &"sfx_door_unlock",
		"position": world_position,
		"priority": 90,
		"metadata": metadata.duplicate(true),
	}
	var audio_system: Node = get_node_or_null("/root/AudioSystem")
	if audio_system == null or not audio_system.has_method(
		"on_savepoint_activated"
	):
		return
	audio_system.call(
		"on_savepoint_activated",
		ROOST_ID,
		ROOST_SCENE_ID,
		ROOST_SPAWN_POINT,
		world_position,
		metadata
	)


func _persist_owner_state() -> void:
	if (
		_scene_owner != null
		and _scene_owner.has_method("persist_neon_relay_spire_progress")
	):
		_scene_owner.call("persist_neon_relay_spire_progress")


func _emit_objective_if_changed() -> void:
	var objective_text: String = get_objective_text()
	if objective_text == _last_emitted_objective_text:
		return
	_last_emitted_objective_text = objective_text
	objective_changed.emit(objective_text)


func _build_roost_snapshot() -> Dictionary:
	var roost_position: Vector2 = (
		_roost.global_position if _roost != null else Vector2.ZERO
	)
	return {
		"id": String(ROOST_ID),
		"savepoint_id": String(ROOST_ID),
		"scene_id": String(ROOST_SCENE_ID),
		"spawn_point": String(ROOST_SPAWN_POINT),
		"display_name": "Relay Spire Roost",
		"position": {
			"x": roost_position.x,
			"y": roost_position.y,
		},
	}


func _get_roost_vfx_snapshot() -> Dictionary:
	if _roost != null and _roost.has_method("get_activation_vfx_snapshot"):
		return Dictionary(_roost.call(
			"get_activation_vfx_snapshot"
		)).duplicate(true)
	return {}


func _set_access_seal_blocking(blocking: bool) -> void:
	if _access_seal == null:
		return
	_access_seal.visible = blocking
	_access_seal.collision_layer = 16 if blocking else 0
	_access_seal.collision_mask = 0
	var shape: CollisionShape2D = _access_seal.get_node_or_null(
		"CollisionShape2D"
	) as CollisionShape2D
	if shape != null:
		shape.set_deferred("disabled", not blocking)


func _is_access_seal_blocking() -> bool:
	return (
		_access_seal != null
		and _access_seal.visible
		and _access_seal.collision_layer == 16
	)


func _set_interaction_enabled(owner: Node, enabled: bool) -> void:
	if owner == null:
		return
	var area: Area2D = owner.get_node_or_null("InteractionArea") as Area2D
	if area != null:
		_set_area_monitoring(area, enabled)
	var shape: CollisionShape2D = owner.get_node_or_null(
		"InteractionArea/CollisionShape2D"
	) as CollisionShape2D
	if shape != null:
		shape.set_deferred("disabled", not enabled)


func _set_area_monitoring(area: Area2D, enabled: bool) -> void:
	if area == null:
		return
	area.set_deferred("monitoring", enabled)
	area.set_deferred("monitorable", enabled)


func _is_provider_near(
	target: Node2D,
	provider: Node,
	radius_px: float
) -> bool:
	return (
		target != null
		and provider != null
		and provider is Node2D
		and target.global_position.distance_to(
			(provider as Node2D).global_position
		) <= radius_px
	)


func _get_child_sprite_texture_path(owner: Node, path: String) -> String:
	if owner == null:
		return ""
	return _get_sprite_texture_path(owner.get_node_or_null(path) as Sprite2D)


func _get_sprite_texture_path(sprite: Sprite2D) -> String:
	return (
		sprite.texture.resource_path
		if sprite != null and sprite.texture != null
		else ""
	)


func _get_node_x(node: Node2D, fallback: float) -> float:
	return node.global_position.x if node != null else fallback
