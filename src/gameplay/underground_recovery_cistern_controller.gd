## Owns the Underground recovery-cistern route, relay, fall, and endpoint slice.
class_name UndergroundRecoveryCisternController
extends Node2D

signal objective_changed(objective_text: String)

const ROUTE_WIDTH_PX: int = 3840
const GAP_START_X: float = 2860.0
const GAP_END_X: float = 3340.0
const RIGHT_WALL_X: float = 3820.0
const RELAY_ID: StringName = &"underground_recovery_cistern_relay"
const RELAY_SCENE_ID: StringName = &"area_04_underground_passage"
const RELAY_SPAWN_POINT: StringName = &"recovery_cistern_relay"
const SAVE_TRIGGER_ADAPTER_SCRIPT: Script = preload(
	"res://src/feature/save_trigger_adapter.gd"
)
const GAME_FLOW_SCRIPT: Script = preload(
	"res://src/gameplay/game_flow_controller.gd"
)

@onready var _background: Sprite2D = (
	get_node_or_null("../RecoveryCisternBackground") as Sprite2D
)
@onready var _relay: Node2D = get_node_or_null("RecoveryRelay") as Node2D
@onready var _endpoint: Node2D = get_node_or_null("DeepRouteEndpoint") as Node2D
@onready var _fall_zone: Area2D = get_node_or_null("FallZone") as Area2D
@onready var _endpoint_prompt: Label = (
	get_node_or_null("DeepRouteEndpoint/PromptLabel") as Label
)
@onready var _relay_prompt: Label = (
	get_node_or_null("RecoveryRelay/PromptLabel") as Label
)

var _route_unlocked: bool = false
var _relay_activated: bool = false
var _player: Node2D = null
var _scene_owner: Object = null
var _save_trigger_adapter: SaveTriggerAdapter = null
var _last_savepoint: Dictionary = {}
var _autosave_request_count: int = 0
var _audio_request_count: int = 0
var _last_autosave_context: Dictionary = {}
var _last_audio_event: Dictionary = {}
var _game_flow: GameFlowController = null
var _traversed: bool = false
var _fall_accept_count: int = 0
var _last_emitted_objective_text: String = ""


func _ready() -> void:
	_connect_relay_signal()
	_connect_route_triggers()
	_sync_authored_state()


func _process(delta: float) -> void:
	advance_respawn_flow(delta)


## Injects the player, scene owner, and optional SaveSystem runtime adapters.
func configure_runtime(
	player: Node2D,
	scene_owner: Object,
	save_system: Object = null
) -> bool:
	_player = player
	_scene_owner = scene_owner
	_connect_relay_signal()
	_connect_route_triggers()
	_ensure_game_flow()
	if save_system != null:
		configure_save_system_runtime(save_system)
	_sync_authored_state()
	return _player != null and _scene_owner != null


## Configures slot-zero autosave through the shared SaveTriggerAdapter.
func configure_save_system_runtime(save_system: Object) -> bool:
	if (
		save_system == null
		or not is_instance_valid(save_system)
		or not save_system.has_method("auto_save")
	):
		return false
	if _save_trigger_adapter == null or not is_instance_valid(_save_trigger_adapter):
		_save_trigger_adapter = SAVE_TRIGGER_ADAPTER_SCRIPT.new() as SaveTriggerAdapter
		_save_trigger_adapter.name = "RecoveryCisternSaveTriggerAdapter"
		add_child(_save_trigger_adapter)
	var snapshot_provider := Callable()
	if _scene_owner != null and _scene_owner.has_method("capture_save_snapshot"):
		snapshot_provider = Callable(_scene_owner, "capture_save_snapshot")
	_save_trigger_adapter.configure(save_system, snapshot_provider)
	return true


## Sets whether the Story131 clear allows access to the recovery route.
func set_route_unlocked(unlocked: bool) -> void:
	_route_unlocked = unlocked
	_sync_authored_state()


## Attempts the one-shot recovery relay activation for a nearby provider.
func try_activate_relay(provider: Node = null) -> bool:
	if not _route_unlocked or _relay_activated or _relay == null:
		return false
	var activation_provider: Node = _player if provider == null else provider
	if not _is_provider_near(_relay, activation_provider, 104.0):
		return false
	if (
		not _relay.has_method("try_activate")
		or not bool(_relay.call("try_activate", activation_provider))
	):
		return false
	return _relay_activated


## Returns the last discovered recovery savepoint for GameFlow selection.
func get_last_discovered_savepoint() -> Dictionary:
	return _last_savepoint.duplicate(true)


## Applies the lethal cistern fall through the public player health path.
func apply_fall(target: Node = null) -> bool:
	var fall_target: Node = _player if target == null else target
	if (
		not _route_unlocked
		or not _relay_activated
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
		"source": &"underground_recovery_cistern_fall",
		"damage_type": &"fall",
		"scene_id": RELAY_SCENE_ID,
	})
	if int(fall_target.call("get_current_hp")) > 0:
		return false
	_fall_accept_count += 1
	return true


## Advances the deterministic death and revive timers for tests and MCP.
func advance_respawn_flow(delta_sec: float) -> void:
	if _game_flow == null or not is_instance_valid(_game_flow):
		return
	_game_flow.advance_time(delta_sec)
	_sync_player_control_lock()


## Attempts the one-shot far-side endpoint activation.
func try_activate_endpoint(provider: Node = null) -> bool:
	if not _relay_activated or _traversed or _endpoint == null:
		return false
	var activation_provider: Node = _player if provider == null else provider
	if not _is_provider_near(_endpoint, activation_provider, 112.0):
		return false
	_traversed = true
	_sync_authored_state()
	return true


## Captures the durable Story132 state merged by the parent scene.
func get_local_state() -> Dictionary:
	return {
		"underground_recovery_cistern_relay_activated": _relay_activated,
		"underground_recovery_cistern_traversed": _traversed,
		"underground_recovery_cistern_last_savepoint": _last_savepoint.duplicate(true),
	}


## Restores durable relay and endpoint state without replaying feedback.
func set_local_state(state: Dictionary) -> void:
	_relay_activated = bool(state.get(
		"underground_recovery_cistern_relay_activated",
		false
	))
	_traversed = bool(state.get(
		"underground_recovery_cistern_traversed",
		false
	))
	_last_savepoint = Dictionary(state.get(
		"underground_recovery_cistern_last_savepoint",
		{}
	)).duplicate(true)
	if _relay_activated and _last_savepoint.is_empty():
		_last_savepoint = _build_relay_snapshot()
	_sync_authored_state()


## Moves the configured player to the authored recovery relay spawn marker.
func align_player_to_relay() -> bool:
	if _player == null:
		return false
	var spawn_marker: Marker2D = get_node_or_null("RecoveryRelaySpawn") as Marker2D
	if spawn_marker == null:
		return false
	_player.global_position = spawn_marker.global_position
	if _player is CharacterBody2D:
		(_player as CharacterBody2D).velocity = Vector2.ZERO
	return true


## Returns whether Story132 should own the shared Underground objective label.
func should_own_objective(provider: Node = null) -> bool:
	if not _route_unlocked:
		return false
	if _relay_activated or _traversed:
		return true
	var objective_provider: Node = _player if provider == null else provider
	return (
		objective_provider is Node2D
		and (objective_provider as Node2D).global_position.x >= 2500.0
	)


## Returns the current player-facing recovery objective.
func get_objective_text() -> String:
	return _get_objective_text()


## Returns authored route and initial interaction state for tests and MCP.
func get_diagnostics() -> Dictionary:
	return {
		"route_width_px": ROUTE_WIDTH_PX,
		"stepping_platform_count": 3,
		"fall_zone_present": _fall_zone != null,
		"controller_present": true,
		"controller_script_path": get_script().resource_path,
		"background_texture_path": _get_sprite_texture_path(_background),
		"relay_texture_path": _get_child_sprite_texture_path(_relay, "Visual"),
		"endpoint_texture_path": _get_child_sprite_texture_path(_endpoint, "Visual"),
		"gap_start_x": GAP_START_X,
		"gap_end_x": GAP_END_X,
		"right_wall_x": RIGHT_WALL_X,
		"relay_id": String(RELAY_ID),
		"relay_scene_id": String(RELAY_SCENE_ID),
		"relay_spawn_point": String(RELAY_SPAWN_POINT),
		"route_unlocked": _route_unlocked,
		"relay_activated": _relay_activated,
		"traversed": _traversed,
		"objective_text": _get_objective_text(),
		"last_savepoint": _last_savepoint.duplicate(true),
		"autosave_request_count": _autosave_request_count,
		"audio_request_count": _audio_request_count,
		"last_autosave_context": _last_autosave_context.duplicate(true),
		"last_audio_event": _last_audio_event.duplicate(true),
		"relay_vfx": _get_relay_vfx_snapshot(),
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
		"fall_accept_count": _fall_accept_count,
	}


func _sync_authored_state() -> void:
	if _relay != null:
		_relay.visible = _route_unlocked
		_set_interaction_enabled(
			_relay,
			_route_unlocked and not _relay_activated
		)
	if _relay_prompt != null:
		_relay_prompt.text = (
			"Recovery Relay Online"
			if _relay_activated
			else "Repair Recovery Relay"
		)
		_relay_prompt.visible = _route_unlocked
	if _endpoint != null:
		_endpoint.visible = _route_unlocked
		_set_interaction_enabled(
			_endpoint,
			_relay_activated and not _traversed
		)
	if _endpoint_prompt != null:
		_endpoint_prompt.text = (
			"Deep Route Secured"
			if _traversed
			else (
				"Secure Deep Route"
				if _relay_activated
				else "Activate Recovery Relay"
			)
		)
		_endpoint_prompt.visible = _route_unlocked
	if _fall_zone != null:
		_set_area_monitoring(
			_fall_zone,
			_route_unlocked and _relay_activated
		)
	_emit_objective_if_changed()


func _connect_relay_signal() -> void:
	if _relay == null or not _relay.has_signal("savepoint_activated"):
		return
	var activated_signal: Signal = _relay.get("savepoint_activated")
	if not activated_signal.is_connected(_on_relay_activated):
		activated_signal.connect(_on_relay_activated)


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
		_game_flow.name = "RecoveryCisternGameFlowController"
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


func _on_relay_activated(
	savepoint_id: StringName,
	scene_id: StringName,
	spawn_point: StringName,
	world_position: Vector2,
	context: Dictionary
) -> void:
	if (
		not _route_unlocked
		or _relay_activated
		or savepoint_id != RELAY_ID
		or scene_id != RELAY_SCENE_ID
		or spawn_point != RELAY_SPAWN_POINT
	):
		return
	_relay_activated = true
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
	_sync_authored_state()


func _trigger_savepoint_autosave(context: Dictionary) -> void:
	if _save_trigger_adapter == null or not is_instance_valid(_save_trigger_adapter):
		return
	var save_context: Dictionary = context.duplicate(true)
	save_context["savepoint_id"] = String(RELAY_ID)
	save_context["scene_id"] = String(RELAY_SCENE_ID)
	save_context["spawn_point"] = String(RELAY_SPAWN_POINT)
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
	metadata["source"] = RELAY_ID
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
	if audio_system == null or not audio_system.has_method("on_savepoint_activated"):
		return
	audio_system.call(
		"on_savepoint_activated",
		RELAY_ID,
		RELAY_SCENE_ID,
		RELAY_SPAWN_POINT,
		world_position,
		metadata
	)


func _get_objective_text() -> String:
	if _traversed:
		return "Recovery Cistern Secured"
	return "Cross Recovery Cistern" if _relay_activated else "Reach Recovery Relay"


func _emit_objective_if_changed() -> void:
	var objective_text: String = _get_objective_text()
	if objective_text == _last_emitted_objective_text:
		return
	_last_emitted_objective_text = objective_text
	objective_changed.emit(objective_text)


func _build_relay_snapshot() -> Dictionary:
	var relay_position: Vector2 = (
		_relay.global_position if _relay != null else Vector2.ZERO
	)
	return {
		"id": String(RELAY_ID),
		"savepoint_id": String(RELAY_ID),
		"scene_id": String(RELAY_SCENE_ID),
		"spawn_point": String(RELAY_SPAWN_POINT),
		"display_name": "Recovery Cistern Relay",
		"position": {
			"x": relay_position.x,
			"y": relay_position.y,
		},
	}


func _get_relay_vfx_snapshot() -> Dictionary:
	if _relay != null and _relay.has_method("get_activation_vfx_snapshot"):
		return Dictionary(_relay.call("get_activation_vfx_snapshot")).duplicate(true)
	return {}


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


func _set_interaction_enabled(owner: Node, enabled: bool) -> void:
	if owner == null:
		return
	var interaction_area: Area2D = owner.get_node_or_null("InteractionArea") as Area2D
	if interaction_area != null:
		_set_area_monitoring(interaction_area, enabled)
	var collision_shape: CollisionShape2D = (
		owner.get_node_or_null("InteractionArea/CollisionShape2D") as CollisionShape2D
	)
	if collision_shape != null:
		collision_shape.set_deferred("disabled", not enabled)


func _set_area_monitoring(area: Area2D, enabled: bool) -> void:
	if area == null:
		return
	area.set_deferred("monitoring", enabled)
	area.set_deferred("monitorable", enabled)


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
