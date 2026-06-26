## Player Abilities Story 015: Old Factory spark rat dodge-counter readability.
extends GdUnitTestSuite

const FACTORY_SCENE_PATH: String = "res://scenes/factory_route_transition_shell.tscn"
const FACTORY_PLAYER_NAME: String = "Player"
const FACTORY_ENTRY_GUARD_NAME: String = "FactoryRatMinion"
const FACTORY_DEEP_GUARD_NAME: String = "FactoryDeepGuardRatMinion"
const FACTORY_DEEP_ENDPOINT_NAME: String = "FactoryDeepRouteEndpoint"
const FACTORY_SPARK_RAT_NAME: String = "FactorySparkRat"
const FACTORY_SPARK_RAT_ENTITY_ID: int = 2102
const SPARK_RAT_BITE_DAMAGE: int = 9
const DODGE_IFRAME_ENTRY_FRAMES: int = 3
const DODGE_REMAINING_FRAMES_AFTER_IFRAME_ENTRY: int = 9
const EXPECTED_COUNTER_WINDOW_FRAMES: int = 30
const EXPECTED_CLAW_COUNTER_BONUS_FRAMES: int = 3

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


func test_spark_rat_bite_dodged_during_iframe_opens_cat_claw_counter_window() -> void:
	var destination: Node = _instantiate_factory_scene()
	assert_that(destination).is_not_null()
	if destination == null:
		return

	if not _assert_dodge_counter_api(destination):
		return

	var player: Node = destination.get_node_or_null(FACTORY_PLAYER_NAME)
	var spark_rat: Node = await _activate_spark_rat(destination)
	assert_that(player).is_not_null()
	assert_that(spark_rat).is_not_null()
	if player == null or spark_rat == null:
		return

	var hp_before: int = int(player.call("get_current_hp"))
	assert_bool(bool(player.call("request_dodge"))).is_true()
	var combat: CombatComponent = player.call("get_combat_component") as CombatComponent
	assert_that(combat).is_not_null()
	if combat == null:
		return
	combat.advance_dodge_frames(DODGE_IFRAME_ENTRY_FRAMES)
	assert_bool(combat.is_dodge_iframe_active()).is_true()

	var bite_result: Dictionary = destination.call("resolve_factory_spark_rat_bite_against_player")
	assert_bool(bool(bite_result.get("resolved", false))).is_true()
	assert_bool(bool(bite_result.get("dodged", false))).is_true()
	assert_bool(bool(bite_result.get("damage_applied", true))).is_false()
	assert_int(int(player.call("get_current_hp"))).is_equal(hp_before)

	combat.advance_dodge_frames(DODGE_REMAINING_FRAMES_AFTER_IFRAME_ENTRY)
	var diagnostics: Dictionary = destination.call("get_factory_spark_rat_counter_diagnostics")
	assert_bool(bool(diagnostics.get("last_bite_dodged", false))).is_true()
	assert_int(int(diagnostics.get("counter_window_frames", 0))).is_equal(
		EXPECTED_COUNTER_WINDOW_FRAMES
	)
	assert_str(String(diagnostics.get("last_bite_weapon_id", ""))).is_equal(
		"factory_spark_rat_bite"
	)
	assert_int(PlayerController.DODGE_DURATION_FRAMES).is_equal(CombatComponent.DODGE_TOTAL_FRAMES)


func test_spark_rat_bite_during_visible_dodge_before_iframe_still_damages_player() -> void:
	var destination: Node = _instantiate_factory_scene()
	assert_that(destination).is_not_null()
	if destination == null:
		return
	if not _assert_dodge_counter_api(destination):
		return

	var player: Node = destination.get_node_or_null(FACTORY_PLAYER_NAME)
	assert_that(player).is_not_null()
	assert_that(await _activate_spark_rat(destination)).is_not_null()
	if player == null:
		return

	var hp_before: int = int(player.call("get_current_hp"))
	assert_bool(bool(player.call("request_dodge"))).is_true()
	var combat: CombatComponent = player.call("get_combat_component") as CombatComponent
	assert_that(combat).is_not_null()
	if combat == null:
		return
	assert_bool(combat.is_dodge_iframe_active()).is_false()

	var bite_result: Dictionary = destination.call("resolve_factory_spark_rat_bite_against_player")

	assert_bool(bool(bite_result.get("resolved", false))).is_true()
	assert_bool(bool(bite_result.get("dodged", true))).is_false()
	assert_bool(bool(bite_result.get("damage_applied", false))).is_true()
	assert_int(int(player.call("get_current_hp"))).is_equal(hp_before - SPARK_RAT_BITE_DAMAGE)


func test_spark_rat_bite_only_resolves_during_active_frames_and_once_per_attack() -> void:
	var destination: Node = _instantiate_factory_scene()
	assert_that(destination).is_not_null()
	if destination == null:
		return
	if not _assert_dodge_counter_api(destination):
		return

	var player: Node = destination.get_node_or_null(FACTORY_PLAYER_NAME)
	var spark_rat: Node = await _open_and_activate_spark_rat(destination)
	assert_that(player).is_not_null()
	assert_that(spark_rat).is_not_null()
	if player == null or spark_rat == null:
		return

	var hp_before: int = int(player.call("get_current_hp"))
	assert_bool(bool(spark_rat.call("request_attack"))).is_true()

	var tell_result: Dictionary = destination.call("resolve_factory_spark_rat_bite_against_player")
	assert_bool(bool(tell_result.get("resolved", true))).is_false()
	assert_bool(bool(tell_result.get("damage_applied", true))).is_false()
	assert_int(int(player.call("get_current_hp"))).is_equal(hp_before)

	spark_rat.call("advance_attack_frames", 7)
	var active_result: Dictionary = destination.call("resolve_factory_spark_rat_bite_against_player")
	assert_bool(bool(active_result.get("resolved", false))).is_true()
	assert_bool(bool(active_result.get("damage_applied", false))).is_true()
	assert_int(int(player.call("get_current_hp"))).is_equal(hp_before - SPARK_RAT_BITE_DAMAGE)

	var hp_after_first_bite: int = int(player.call("get_current_hp"))
	var repeated_result: Dictionary = destination.call("resolve_factory_spark_rat_bite_against_player")
	assert_bool(bool(repeated_result.get("resolved", true))).is_false()
	assert_bool(bool(repeated_result.get("already_resolved", false))).is_true()
	assert_int(int(player.call("get_current_hp"))).is_equal(hp_after_first_bite)

	var diagnostics: Dictionary = destination.call("get_factory_spark_rat_counter_diagnostics")
	assert_bool(bool(diagnostics.get("last_bite_resolved", false))).is_true()
	assert_bool(bool(diagnostics.get("last_bite_damage_applied", false))).is_true()
	assert_bool(bool(diagnostics.get("last_bite_already_resolved", false))).is_true()
	assert_int(int(diagnostics.get("last_bite_damage", 0))).is_equal(SPARK_RAT_BITE_DAMAGE)


func test_cat_claw_hit_during_spark_rat_counter_window_consumes_bonus_once() -> void:
	var destination: Node = _instantiate_factory_scene()
	assert_that(destination).is_not_null()
	if destination == null:
		return
	if not _assert_dodge_counter_api(destination):
		return

	var player: Node = destination.get_node_or_null(FACTORY_PLAYER_NAME)
	var spark_rat: Node = await _activate_spark_rat(destination)
	assert_that(player).is_not_null()
	assert_that(spark_rat).is_not_null()
	if player == null or spark_rat == null:
		return

	assert_bool(bool(player.call("request_dodge"))).is_true()
	var combat: CombatComponent = player.call("get_combat_component") as CombatComponent
	assert_that(combat).is_not_null()
	if combat == null:
		return
	combat.advance_dodge_frames(DODGE_IFRAME_ENTRY_FRAMES)
	assert_bool(bool(destination.call("resolve_factory_spark_rat_bite_against_player").get(
		"dodged",
		false
	))).is_true()
	combat.advance_dodge_frames(DODGE_REMAINING_FRAMES_AFTER_IFRAME_ENTRY)

	var spark_hp_before: int = int(spark_rat.call("get_current_hp"))
	combat.on_hit_confirmed({
		"target_id": FACTORY_SPARK_RAT_ENTITY_ID,
		"hit_frame": 4,
		"attack_metadata": {
			"attack_type": &"light",
			"weapon_id": &"cat_claw",
		},
	})

	var first_hit: Dictionary = destination.call("get_last_player_hit_metadata")
	assert_int(int(first_hit.get("crit_window_bonus", 0))).is_equal(
		EXPECTED_CLAW_COUNTER_BONUS_FRAMES
	)
	assert_int(int(first_hit.get("skill_modifiers", {}).get(
		"claw_counter_crit_window_bonus_frames",
		0
	))).is_equal(EXPECTED_CLAW_COUNTER_BONUS_FRAMES)
	assert_int(int(spark_rat.call("get_current_hp"))).is_less(spark_hp_before)
	assert_int(combat.get_dodge_counter_window()).is_equal(0)

	combat.on_hit_confirmed({
		"target_id": FACTORY_SPARK_RAT_ENTITY_ID,
		"hit_frame": 4,
		"attack_metadata": {
			"attack_type": &"light",
			"weapon_id": &"cat_claw",
		},
	})
	var second_hit: Dictionary = destination.call("get_last_player_hit_metadata")
	assert_int(int(second_hit.get("crit_window_bonus", 0))).is_equal(0)


func test_spark_rat_bite_without_dodge_damages_player_for_existing_contract() -> void:
	var destination: Node = _instantiate_factory_scene()
	assert_that(destination).is_not_null()
	if destination == null:
		return
	if not _assert_dodge_counter_api(destination):
		return

	assert_that(await _activate_spark_rat(destination)).is_not_null()
	var player: Node = destination.get_node_or_null(FACTORY_PLAYER_NAME)
	assert_that(player).is_not_null()
	if player == null:
		return

	var hp_before: int = int(player.call("get_current_hp"))
	var bite_result: Dictionary = destination.call("resolve_factory_spark_rat_bite_against_player")

	assert_bool(bool(bite_result.get("resolved", false))).is_true()
	assert_bool(bool(bite_result.get("dodged", true))).is_false()
	assert_bool(bool(bite_result.get("damage_applied", false))).is_true()
	assert_int(int(bite_result.get("damage", 0))).is_equal(SPARK_RAT_BITE_DAMAGE)
	assert_int(int(player.call("get_current_hp"))).is_equal(hp_before - SPARK_RAT_BITE_DAMAGE)

	var diagnostics: Dictionary = destination.call("get_factory_spark_rat_counter_diagnostics")
	assert_bool(bool(diagnostics.get("last_bite_dodged", true))).is_false()
	assert_int(int(diagnostics.get("counter_window_frames", -1))).is_equal(0)


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


func _assert_dodge_counter_api(destination: Node) -> bool:
	var has_resolve: bool = destination.has_method("resolve_factory_spark_rat_bite_against_player")
	var has_diagnostics: bool = destination.has_method("get_factory_spark_rat_counter_diagnostics")
	assert_bool(has_resolve).is_true()
	assert_bool(has_diagnostics).is_true()
	return has_resolve and has_diagnostics


func _activate_spark_rat(destination: Node) -> Node:
	var spark_rat: Node = await _open_and_activate_spark_rat(destination)
	if spark_rat == null:
		return null
	assert_bool(bool(spark_rat.call("request_attack"))).is_true()
	spark_rat.call("advance_attack_frames", 7)
	return spark_rat


func _open_and_activate_spark_rat(destination: Node) -> Node:
	var player: Node2D = destination.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	assert_that(player).is_not_null()
	if player == null:
		return null

	await _open_deep_route_endpoint(destination, player)
	assert_bool(bool(destination.call("try_activate_factory_spark_rat", player))).is_true()
	var spark_rat: Node = destination.get_node_or_null(FACTORY_SPARK_RAT_NAME)
	assert_that(spark_rat).is_not_null()
	if spark_rat == null:
		return null
	return spark_rat


func _open_deep_route_endpoint(destination: Node, player: Node2D) -> void:
	await _defeat_guard(destination, FACTORY_ENTRY_GUARD_NAME, &"unit_test_entry_clear")
	var route_diagnostics: Dictionary = destination.call("get_factory_deep_route_diagnostics")
	player.global_position.x = float(route_diagnostics.get("deep_guard_activation_x", 0.0)) + 8.0
	assert_bool(bool(destination.call("try_activate_factory_deep_guard", player))).is_true()
	await _defeat_guard(destination, FACTORY_DEEP_GUARD_NAME, &"unit_test_deep_guard_clear")
	var endpoint: Node2D = destination.get_node_or_null(FACTORY_DEEP_ENDPOINT_NAME) as Node2D
	assert_that(endpoint).is_not_null()
	if endpoint == null:
		return
	player.global_position = endpoint.global_position
	assert_bool(bool(destination.call("try_activate_factory_deep_route_endpoint", player))).is_true()


func _defeat_guard(root: Node, guard_name: String, reason: StringName) -> void:
	var guard: Node = root.get_node_or_null(guard_name)
	assert_that(guard).is_not_null()
	if guard == null:
		return
	if guard.has_method("kill_summon"):
		guard.call("kill_summon", reason)
	else:
		guard.call("apply_damage", int(guard.call("get_current_hp")), {})
	await get_tree().process_frame


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
