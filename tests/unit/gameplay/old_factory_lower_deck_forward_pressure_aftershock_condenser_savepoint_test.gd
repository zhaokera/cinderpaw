## Player Abilities Story 095: Old Factory aftershock condenser savepoint.
extends GdUnitTestSuite

const FACTORY_SCENE_PATH: String = "res://scenes/factory_route_transition_shell.tscn"
const FACTORY_PLAYER_NAME: String = "Player"
const FACTORY_SCENE_ID: StringName = &"area_03_factory"
const FACTORY_GATE_ENTRY_SPAWN_POINT: StringName = &"factory_gate_entry"
const CONDENSER_SAVEPOINT_NODE_NAME: String = (
	"FactoryLowerDeckForwardPressureAftershockCondenserSavepoint"
)
const CONDENSER_SAVEPOINT_ID: String = (
	"old_factory_lower_deck_forward_pressure_aftershock_condenser_savepoint"
)
const CONDENSER_SAVEPOINT_SPAWN_POINT: String = (
	"lower_deck_forward_pressure_aftershock_condenser_savepoint"
)
const CONDENSER_SAVEPOINT_TEXTURE: String = (
	"res://assets/environment/old_factory_aftershock_condenser_savepoint/"
	+ "env_old_factory_aftershock_condenser_savepoint_256.png"
)

var _spawned_nodes: Array[Node] = []


class FakeFactoryRequestSceneManager:
	extends RefCounted

	var current_scene: StringName = FACTORY_SCENE_ID
	var current_spawn_point: StringName = FACTORY_GATE_ENTRY_SPAWN_POINT
	var request_calls: Array[Dictionary] = []

	func has_scene(scene_id: StringName) -> bool:
		return scene_id == FACTORY_SCENE_ID or scene_id == &"main"

	func request_scene_change(scene_id: StringName, spawn_point: StringName = &"default") -> bool:
		request_calls.append({
			"scene_id": String(scene_id),
			"spawn_point": String(spawn_point),
		})
		var known: bool = has_scene(scene_id)
		if known:
			current_scene = scene_id
			current_spawn_point = spawn_point
		return known

	func get_current_scene() -> StringName:
		return current_scene

	func get_current_spawn_point() -> StringName:
		return current_spawn_point


func after_test() -> void:
	_stop_runtime_audio_players()
	for node: Node in _spawned_nodes:
		if not is_instance_valid(node):
			continue
		if node.get_parent() != null:
			node.get_parent().remove_child(node)
		node.free()
	_spawned_nodes.clear()


func test_condenser_savepoint_requires_landing_secured_and_records_respawn() -> void:
	assert_bool(FileAccess.file_exists(CONDENSER_SAVEPOINT_TEXTURE)).is_true()

	var locked_scene: Node = _factory_scene_with_condenser_savepoint_state(false, false)
	assert_that(locked_scene).is_not_null()
	if locked_scene == null:
		return

	assert_bool(locked_scene.has_method(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_savepoint_diagnostics"
	)).is_true()
	assert_bool(locked_scene.has_method(
		"try_activate_factory_lower_deck_forward_pressure_aftershock_condenser_savepoint"
	)).is_true()
	if (
		not locked_scene.has_method(
			"get_factory_lower_deck_forward_pressure_aftershock_condenser_savepoint_diagnostics"
		)
		or not locked_scene.has_method(
			"try_activate_factory_lower_deck_forward_pressure_aftershock_condenser_savepoint"
		)
	):
		return

	var locked: Dictionary = locked_scene.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_savepoint_diagnostics"
	)
	assert_bool(bool(locked.get("present", false))).is_true()
	assert_bool(bool(locked.get("condenser_landing_secured", true))).is_false()
	assert_bool(bool(locked.get("available", true))).is_false()
	assert_bool(bool(locked.get("visible", true))).is_false()
	assert_bool(bool(locked.get("interaction_monitoring", true))).is_false()
	assert_bool(bool(locked.get("interaction_monitorable", true))).is_false()
	assert_bool(bool(locked.get("collision_disabled", false))).is_true()
	assert_bool(bool(locked_scene.call(
		"try_activate_factory_lower_deck_forward_pressure_aftershock_condenser_savepoint"
	))).is_false()

	var ready_scene: Node = _factory_scene_with_condenser_savepoint_state(true, false)
	assert_that(ready_scene).is_not_null()
	if ready_scene == null:
		return
	var player: Node2D = ready_scene.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	var savepoint: Node2D = ready_scene.get_node_or_null(
		CONDENSER_SAVEPOINT_NODE_NAME
	) as Node2D
	assert_that(player).is_not_null()
	assert_that(savepoint).is_not_null()
	if player == null or savepoint == null:
		return

	var ready: Dictionary = ready_scene.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_savepoint_diagnostics"
	)
	assert_bool(bool(ready.get("present", false))).is_true()
	assert_bool(bool(ready.get("condenser_landing_secured", false))).is_true()
	assert_bool(bool(ready.get("available", false))).is_true()
	assert_bool(bool(ready.get("visible", false))).is_true()
	assert_bool(bool(ready.get("activated", true))).is_false()
	assert_str(String(ready.get("prompt_text", ""))).is_equal("Repair Condenser Relay")
	assert_str(String(ready.get("texture_path", ""))).is_equal(CONDENSER_SAVEPOINT_TEXTURE)
	assert_str(String(ready.get("savepoint_id", ""))).is_equal(CONDENSER_SAVEPOINT_ID)
	assert_str(String(ready.get("scene_id", ""))).is_equal(String(FACTORY_SCENE_ID))
	assert_str(String(ready.get("spawn_point", ""))).is_equal(CONDENSER_SAVEPOINT_SPAWN_POINT)

	player.global_position = savepoint.global_position
	assert_bool(bool(ready_scene.call(
		"try_activate_factory_lower_deck_forward_pressure_aftershock_condenser_savepoint",
		player
	))).is_true()
	assert_bool(bool(ready_scene.call(
		"try_activate_factory_lower_deck_forward_pressure_aftershock_condenser_savepoint",
		player
	))).is_false()

	var activated: Dictionary = ready_scene.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_savepoint_diagnostics"
	)
	assert_bool(bool(activated.get("activated", false))).is_true()
	assert_str(String(activated.get("route_label_text", ""))).is_equal(
		"Aftershock Condenser Savepoint Secured"
	)
	var last_savepoint: Dictionary = Dictionary(activated.get("last_savepoint", {}))
	assert_str(String(last_savepoint.get("id", ""))).is_equal(CONDENSER_SAVEPOINT_ID)
	assert_str(String(last_savepoint.get("scene_id", ""))).is_equal(String(FACTORY_SCENE_ID))
	assert_str(String(last_savepoint.get("spawn_point", ""))).is_equal(
		CONDENSER_SAVEPOINT_SPAWN_POINT
	)

	var local_state: Dictionary = ready_scene.call("get_local_state")
	assert_bool(bool(local_state.get(
		"factory_lower_deck_forward_pressure_aftershock_condenser_savepoint_activated",
		false
	))).is_true()


func test_condenser_savepoint_persists_and_respawns_without_replaying_landing() -> void:
	var destination: Node = _factory_scene_with_condenser_savepoint_state(true, false)
	assert_that(destination).is_not_null()
	if destination == null:
		return

	var player: Node2D = destination.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	var savepoint: Node2D = destination.get_node_or_null(
		CONDENSER_SAVEPOINT_NODE_NAME
	) as Node2D
	assert_that(player).is_not_null()
	assert_that(savepoint).is_not_null()
	if player == null or savepoint == null:
		return

	player.global_position = savepoint.global_position
	assert_bool(bool(destination.call(
		"try_activate_factory_lower_deck_forward_pressure_aftershock_condenser_savepoint",
		player
	))).is_true()

	var scene_manager := FakeFactoryRequestSceneManager.new()
	assert_bool(bool(destination.call("configure_scene_manager_runtime", scene_manager))).is_true()

	var max_hp: int = int(player.call("get_max_hp"))
	player.global_position = savepoint.global_position + Vector2(220.0, 0.0)
	player.call("apply_damage", max_hp, {
		"source": "unit_test_aftershock_condenser_savepoint",
		"damage_type": "lethal_probe",
	})
	destination.call("advance_factory_respawn_flow", 1.51)

	assert_int(scene_manager.request_calls.size()).is_equal(1)
	assert_str(String(scene_manager.request_calls[0]["scene_id"])).is_equal(
		String(FACTORY_SCENE_ID)
	)
	assert_str(String(scene_manager.request_calls[0]["spawn_point"])).is_equal(
		CONDENSER_SAVEPOINT_SPAWN_POINT
	)
	assert_float(player.global_position.distance_to(savepoint.global_position)).is_less_equal(1.0)
	assert_int(int(player.call("get_current_hp"))).is_equal(maxi(1, int(round(max_hp * 0.5))))
	assert_bool(bool(player.call("is_respawn_visual_active"))).is_true()
	assert_str(String(
		destination.call("get_factory_route_objective_diagnostics").get("route_label_text", "")
	)).is_equal("Returned to Aftershock Condenser Savepoint")

	var restored: Node = _factory_scene_with_condenser_savepoint_state(true, true)
	assert_that(restored).is_not_null()
	if restored == null:
		return
	var restored_savepoint: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_savepoint_diagnostics"
	)
	assert_bool(bool(restored_savepoint.get("activated", false))).is_true()
	assert_str(String(restored_savepoint.get("savepoint_id", ""))).is_equal(
		CONDENSER_SAVEPOINT_ID
	)
	assert_str(String(restored_savepoint.get("route_label_text", ""))).is_equal(
		"Aftershock Condenser Savepoint Secured"
	)
	var restored_landing: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_valve_diagnostics"
	)
	assert_bool(bool(restored_landing.get("active", true))).is_false()
	assert_bool(bool(restored_landing.get("cleared", false))).is_true()
	assert_bool(bool(restored_landing.get("spark_visible", true))).is_false()
	assert_bool(bool(restored_landing.get("coil_visible", true))).is_false()


func _factory_scene_with_condenser_savepoint_state(
		condenser_landing_secured: bool,
		savepoint_activated: bool
) -> Node:
	var destination: Node = _instantiate_factory_scene()
	if destination == null:
		return null
	destination.call("set_local_state", {
		"factory_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch_opened": true,
		"factory_lower_deck_forward_pressure_aftershock_cooling_duct_activated": true,
		"factory_lower_deck_forward_pressure_aftershock_cooling_duct_crossed": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_valve_activated": (
			condenser_landing_secured
		),
		"factory_lower_deck_forward_pressure_aftershock_condenser_valve_spark_rat_defeated": (
			condenser_landing_secured
		),
		"factory_lower_deck_forward_pressure_aftershock_condenser_valve_coil_rat_defeated": (
			condenser_landing_secured
		),
		"factory_lower_deck_forward_pressure_aftershock_condenser_valve_cleared": (
			condenser_landing_secured
		),
		"factory_lower_deck_forward_pressure_aftershock_condenser_savepoint_activated": (
			savepoint_activated
		),
	})
	return destination


func _instantiate_factory_scene() -> Node:
	assert_bool(FileAccess.file_exists(FACTORY_SCENE_PATH)).is_true()
	var packed: PackedScene = load(FACTORY_SCENE_PATH) as PackedScene
	assert_that(packed).is_not_null()
	if packed == null:
		return null
	var destination: Node = packed.instantiate()
	add_child(destination)
	_spawned_nodes.append(destination)
	return destination


func _stop_runtime_audio_players() -> void:
	var audio_system := get_node_or_null("/root/AudioSystem")
	if audio_system == null:
		return
	for child: Node in audio_system.get_children():
		if child is AudioStreamPlayer:
			var audio_player := child as AudioStreamPlayer
			audio_player.stop()
			audio_player.stream = null
		if child is AudioStreamPlayer2D:
			var spatial_player := child as AudioStreamPlayer2D
			spatial_player.stop()
			spatial_player.stream = null
