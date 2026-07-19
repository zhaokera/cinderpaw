## Scene Management Story 023: staged Old Factory first-arrival encounter.
extends GdUnitTestSuite

const FACTORY_SCENE: PackedScene = preload(
	"res://scenes/factory_route_transition_shell.tscn"
)
const ENTRY_GUARD_NAME: String = "FactoryRatMinion"
const DEEP_GUARD_NAME: String = "FactoryDeepGuardRatMinion"
const DEEP_ENDPOINT_NAME: String = "FactoryDeepRouteEndpoint"
const SPARK_RAT_NAME: String = "FactorySparkRat"
const SERVICE_LIFT_NAME: String = "FactoryServiceLift"

var _destination: Node = null


func after_test() -> void:
	_stop_runtime_audio_players()
	if is_instance_valid(_destination):
		if _destination.get_parent() != null:
			_destination.get_parent().remove_child(_destination)
		_destination.free()
	_destination = null


func test_factory_first_arrival_stages_one_readable_encounter_before_deep_route() -> void:
	_destination = FACTORY_SCENE.instantiate()
	add_child(_destination)
	assert_bool(_destination.has_method("get_factory_arrival_staging_diagnostics")).is_true()
	assert_bool(_destination.has_method("try_activate_factory_entry_guard")).is_true()
	if not _destination.has_method("get_factory_arrival_staging_diagnostics"):
		return

	var initial: Dictionary = _destination.call("get_factory_arrival_staging_diagnostics")
	assert_bool(bool(initial.get("entry_guard_visible", false))).is_true()
	assert_bool(bool(initial.get("entry_guard_activated", true))).is_false()
	assert_bool(bool(initial.get("entry_guard_has_target", true))).is_false()
	assert_bool(bool(initial.get("entry_guard_physics_enabled", true))).is_false()
	assert_int(int(initial.get("entry_guard_collision_layer", -1))).is_equal(0)
	assert_bool(bool(initial.get("cache_visible", true))).is_false()
	assert_bool(bool(initial.get("cache_prompt_visible", true))).is_false()
	assert_bool(bool(initial.get("deep_guard_visible", true))).is_false()
	assert_bool(bool(initial.get("deep_endpoint_visible", true))).is_false()
	assert_bool(bool(initial.get("deep_endpoint_prompt_visible", true))).is_false()
	assert_bool(bool(initial.get("spark_rat_visible", true))).is_false()
	assert_bool(bool(initial.get("service_lift_visible", true))).is_false()
	assert_bool(bool(initial.get("service_lift_prompt_visible", true))).is_false()
	assert_str(_get_hurtbox_state(_destination.get_node(ENTRY_GUARD_NAME))).is_equal("gone")
	assert_str(_get_hurtbox_state(_destination.get_node(DEEP_GUARD_NAME))).is_equal("gone")
	assert_str(_get_hurtbox_state(_destination.get_node(SPARK_RAT_NAME))).is_equal("gone")
	assert_str(String(initial.get("route_label_text", ""))).is_equal(
		"Clear Factory Entrance"
	)

	var player := _destination.get_node("Player") as CharacterBody2D
	var spawn := _destination.get_node("FactoryGateEntrySpawn") as Marker2D
	assert_float(player.global_position.x).is_greater(spawn.global_position.x - 1.0)
	assert_float(player.global_position.x).is_greater_equal(200.0)
	assert_bool(bool(_destination.call("try_activate_factory_entry_guard", player))).is_false()

	var activation_x: float = float(initial.get("entry_guard_activation_x", 0.0))
	player.global_position.x = activation_x + 1.0
	assert_bool(bool(_destination.call("try_activate_factory_entry_guard", player))).is_true()
	assert_bool(bool(_destination.call("try_activate_factory_entry_guard", player))).is_false()
	var active: Dictionary = _destination.call("get_factory_arrival_staging_diagnostics")
	assert_bool(bool(active.get("entry_guard_activated", false))).is_true()
	assert_bool(bool(active.get("entry_guard_has_target", false))).is_true()
	assert_bool(bool(active.get("entry_guard_physics_enabled", false))).is_true()
	assert_int(int(active.get("entry_guard_collision_layer", 0))).is_greater(0)
	assert_str(_get_hurtbox_state(_destination.get_node(ENTRY_GUARD_NAME))).is_equal("normal")
	var activated_state: Dictionary = _destination.call("get_local_state")
	assert_bool(bool(activated_state.get("factory_entry_guard_activated", false))).is_true()
	_destination.call("set_local_state", activated_state)
	assert_bool(bool(
		_destination.call("get_factory_arrival_staging_diagnostics").get(
			"entry_guard_activated",
			false
		)
	)).is_true()

	var vent := _destination.get_node("FactorySteamVentHazard") as Area2D
	player.global_position = vent.global_position
	assert_bool(bool(_destination.call("apply_factory_steam_vent_contact", vent, player))).is_true()
	var after_steam: Dictionary = _destination.call("get_factory_arrival_staging_diagnostics")
	assert_str(String(after_steam.get("route_label_text", ""))).is_equal(
		"Clear Factory Entrance"
	)

	var entry_guard: Node = _destination.get_node(ENTRY_GUARD_NAME)
	entry_guard.call("kill_summon", &"story_023_entry_clear")
	await get_tree().process_frame
	var entrance_clear: Dictionary = _destination.call(
		"get_factory_arrival_staging_diagnostics"
	)
	assert_bool(bool(entrance_clear.get("cache_visible", false))).is_true()
	assert_bool(bool(entrance_clear.get("deep_guard_visible", false))).is_true()
	assert_bool(bool(entrance_clear.get("deep_endpoint_visible", true))).is_false()
	assert_bool(bool(entrance_clear.get("spark_rat_visible", true))).is_false()
	assert_bool(bool(entrance_clear.get("service_lift_visible", true))).is_false()
	assert_str(_get_hurtbox_state(entry_guard)).is_equal("gone")
	assert_str(_get_hurtbox_state(_destination.get_node(DEEP_GUARD_NAME))).is_equal("gone")
	assert_str(String(entrance_clear.get("route_label_text", ""))).is_equal(
		"Reach Deep Guard"
	)

	var deep_diagnostics: Dictionary = _destination.call("get_factory_deep_route_diagnostics")
	player.global_position.x = float(deep_diagnostics.get("deep_guard_activation_x", 0.0)) + 1.0
	assert_bool(bool(_destination.call("try_activate_factory_deep_guard", player))).is_true()
	var deep_guard: Node = _destination.get_node(DEEP_GUARD_NAME)
	assert_str(_get_hurtbox_state(deep_guard)).is_equal("normal")
	deep_guard.call("kill_summon", &"story_023_deep_guard_clear")
	await get_tree().process_frame
	var guard_clear: Dictionary = _destination.call("get_factory_arrival_staging_diagnostics")
	assert_bool(bool(guard_clear.get("deep_endpoint_visible", false))).is_true()

	var endpoint := _destination.get_node(DEEP_ENDPOINT_NAME) as Node2D
	player.global_position = endpoint.global_position
	assert_bool(bool(_destination.call("try_activate_factory_deep_route_endpoint", player))).is_true()
	var route_open: Dictionary = _destination.call("get_factory_arrival_staging_diagnostics")
	assert_bool(bool(route_open.get("spark_rat_visible", false))).is_true()
	assert_bool(bool(route_open.get("service_lift_visible", true))).is_false()
	assert_str(_get_hurtbox_state(_destination.get_node(SPARK_RAT_NAME))).is_equal("gone")

	var spark_rat: Node = _destination.get_node(SPARK_RAT_NAME)
	var spark_diagnostics: Dictionary = _destination.call("get_factory_spark_rat_diagnostics")
	player.global_position.x = float(spark_diagnostics.get("activation_x", 0.0)) + 1.0
	assert_bool(bool(_destination.call("try_activate_factory_spark_rat", player))).is_true()
	assert_str(_get_hurtbox_state(spark_rat)).is_equal("normal")
	_destination.call("apply_damage", int(spark_rat.call("get_entity_id")), 999, {
		"source": &"story_023_spark_clear",
	})
	await get_tree().process_frame
	var route_clear: Dictionary = _destination.call("get_factory_arrival_staging_diagnostics")
	assert_bool(bool(route_clear.get("service_lift_visible", false))).is_true()
	assert_bool((_destination.get_node(SERVICE_LIFT_NAME) as Node2D).visible).is_true()

	await get_tree().create_timer(0.5).timeout
	var after_entry_guard_free: Dictionary = _destination.call(
		"get_factory_arrival_staging_diagnostics"
	)
	assert_bool(bool(after_entry_guard_free.get("entry_guard_instance_valid", true))).is_false()


func _get_hurtbox_state(enemy: Node) -> String:
	if enemy == null or not is_instance_valid(enemy) or not enemy.has_method("get_collision_component"):
		return "missing"
	var collision: Node = enemy.call("get_collision_component") as Node
	if collision == null or not collision.has_method("get_hurtbox_state"):
		return "missing"
	return String(collision.call("get_hurtbox_state"))


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
