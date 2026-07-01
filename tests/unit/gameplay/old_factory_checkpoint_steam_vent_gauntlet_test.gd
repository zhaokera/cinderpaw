## Player Abilities Story 047: Old Factory checkpoint steam vent gauntlet.
extends GdUnitTestSuite

const FACTORY_SCENE_PATH: String = "res://scenes/factory_route_transition_shell.tscn"
const FACTORY_PLAYER_NAME: String = "Player"
const FACTORY_CHECKPOINT_STEAM_VENT_NAME: String = "FactoryCheckpointSteamVentHazard"
const FACTORY_SERVICE_LIFT_NAME: String = "FactoryServiceLift"
const CHECKPOINT_STEAM_VENT_ID: String = "old_factory_checkpoint_steam_vent"
const STEAM_VENT_TEXTURE_PATH: String = (
	"res://assets/environment/old_factory_steam_vent/factory_steam_vent_hazard.png"
)
const EXPECTED_STEAM_DAMAGE: int = 8
const EXPECTED_STEAM_COOLDOWN_SEC: float = 1.0

var _spawned_nodes: Array[Node] = []


func after_test() -> void:
	_stop_runtime_audio_players()
	for node: Node in _spawned_nodes:
		if not is_instance_valid(node):
			continue
		if node.get_parent() != null:
			node.get_parent().remove_child(node)
		node.free()
	_spawned_nodes.clear()


func test_checkpoint_steam_vent_stays_inactive_until_forward_patrol_is_cleared() -> void:
	var destination: Node = _instantiate_factory_scene()
	assert_that(destination).is_not_null()
	if destination == null:
		return

	assert_bool(destination.has_method("get_factory_hazard_diagnostics")).is_true()
	var vent: Area2D = destination.get_node_or_null(FACTORY_CHECKPOINT_STEAM_VENT_NAME) as Area2D
	assert_that(vent).is_not_null()
	if vent == null:
		return

	destination.call("set_local_state", _return_checkpoint_state().merged({
		"factory_checkpoint_forward_patrol_activated": true,
		"factory_checkpoint_forward_patrol_defeated": false,
	}, true))

	var diagnostics: Dictionary = destination.call("get_factory_hazard_diagnostics")
	assert_bool(bool(diagnostics.get("checkpoint_steam_vent_present", false))).is_true()
	assert_bool(bool(diagnostics.get("checkpoint_steam_vent_visible", true))).is_false()
	assert_bool(bool(diagnostics.get("checkpoint_steam_vent_active", true))).is_false()
	assert_str(String(diagnostics.get("checkpoint_steam_vent_id", ""))).is_equal(
		CHECKPOINT_STEAM_VENT_ID
	)
	assert_str(String(diagnostics.get("checkpoint_steam_vent_texture_path", ""))).is_equal(
		STEAM_VENT_TEXTURE_PATH
	)
	assert_bool(vent.monitoring).is_false()
	assert_int(vent.collision_layer).is_equal(0)
	assert_int(vent.collision_mask).is_equal(0)


func test_checkpoint_steam_vent_activates_after_forward_patrol_clear_and_damages_player() -> void:
	var destination: Node = _factory_scene_with_checkpoint_route_opened()
	assert_that(destination).is_not_null()
	if destination == null:
		return

	assert_bool(destination.has_method("apply_factory_steam_vent_contact")).is_true()
	assert_bool(destination.has_method("advance_factory_hazard_time")).is_true()
	var player: Node = destination.get_node_or_null(FACTORY_PLAYER_NAME)
	var vent: Area2D = destination.get_node_or_null(FACTORY_CHECKPOINT_STEAM_VENT_NAME) as Area2D
	assert_that(player).is_not_null()
	assert_that(vent).is_not_null()
	if player == null or vent == null:
		return

	var diagnostics: Dictionary = destination.call("get_factory_hazard_diagnostics")
	assert_bool(bool(diagnostics.get("checkpoint_steam_vent_visible", false))).is_true()
	assert_bool(bool(diagnostics.get("checkpoint_steam_vent_active", false))).is_true()
	assert_int(int(diagnostics.get("checkpoint_steam_damage", 0))).is_equal(EXPECTED_STEAM_DAMAGE)
	assert_int(vent.collision_layer).is_equal(CollisionComponent.COLLISION_LAYER_ENVIRONMENT)
	assert_int(vent.collision_mask).is_equal(CollisionComponent.COLLISION_MASK_ENVIRONMENT)
	assert_bool(vent.monitoring).is_true()

	var start_hp: int = int(player.call("get_current_hp"))
	assert_bool(bool(destination.call("apply_factory_steam_vent_contact", vent, player))).is_true()
	var hp_after_first_contact: int = int(player.call("get_current_hp"))
	assert_int(start_hp - hp_after_first_contact).is_equal(EXPECTED_STEAM_DAMAGE)

	assert_bool(bool(destination.call("apply_factory_steam_vent_contact", vent, player))).is_false()
	assert_int(int(player.call("get_current_hp"))).is_equal(hp_after_first_contact)

	destination.call("advance_factory_hazard_time", EXPECTED_STEAM_COOLDOWN_SEC)
	assert_bool(bool(destination.call("apply_factory_steam_vent_contact", vent, player))).is_true()
	assert_int(start_hp - int(player.call("get_current_hp"))).is_equal(
		EXPECTED_STEAM_DAMAGE * 2
	)


func test_checkpoint_steam_vent_does_not_relock_fully_cleared_service_lift_route() -> void:
	var destination: Node = _factory_scene_with_checkpoint_route_opened()
	assert_that(destination).is_not_null()
	if destination == null:
		return

	var service_lift: Node2D = destination.get_node_or_null(FACTORY_SERVICE_LIFT_NAME) as Node2D
	var player: Node2D = destination.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	assert_that(service_lift).is_not_null()
	assert_that(player).is_not_null()
	if service_lift == null or player == null:
		return

	var route: Dictionary = destination.call("get_factory_route_objective_diagnostics")
	var lift: Dictionary = destination.call("get_factory_service_lift_diagnostics")
	assert_str(String(route.get("objective_id", ""))).is_equal("checkpoint_overdrive_duo_cleared")
	assert_bool(bool(route.get("complete", false))).is_true()
	assert_bool(bool(lift.get("available", false))).is_true()
	assert_str(String(lift.get("prompt_text", ""))).is_equal("Call lift")

	player.global_position = service_lift.global_position
	assert_bool(bool(destination.call("try_activate_factory_service_lift", player))).is_true()


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


func _factory_scene_with_checkpoint_route_opened() -> Node:
	var destination: Node = _instantiate_factory_scene()
	if destination == null:
		return null
	destination.call("set_local_state", _return_checkpoint_state().merged({
		"factory_checkpoint_forward_patrol_activated": true,
			"factory_checkpoint_forward_patrol_defeated": true,
			"factory_checkpoint_rear_ambush_activated": true,
			"factory_checkpoint_rear_ambush_defeated": true,
			"factory_checkpoint_overdrive_duo_activated": true,
			"factory_checkpoint_overdrive_left_defeated": true,
			"factory_checkpoint_overdrive_right_defeated": true,
			"factory_checkpoint_overdrive_duo_cleared": true,
		}, true))
	return destination


func _return_checkpoint_state() -> Dictionary:
	return {
		"encounter_cleared": true,
		"factory_cache_claimed": true,
		"factory_deep_guard_activated": true,
		"factory_deep_guard_defeated": true,
		"factory_deep_route_cleared": true,
		"factory_spark_rat_activated": true,
		"factory_spark_rat_defeated": true,
		"factory_return_patrol_activated": true,
		"factory_return_patrol_defeated": true,
		"factory_return_checkpoint_activated": true,
		"factory_service_lift_activated": false,
		"factory_service_lift_exit_requested": false,
		"factory_service_lift_exit_scene_id": "main",
		"factory_service_lift_exit_spawn_point": "scrap_roost",
		"last_return_checkpoint": {
			"id": "old_factory_return_checkpoint",
			"scene_id": "area_03_factory",
			"spawn_point": "return_checkpoint",
			"position": Vector2(704, 380),
		},
	}


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
