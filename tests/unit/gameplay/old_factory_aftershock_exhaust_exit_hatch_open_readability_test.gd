## Story212: opened hatch silhouette, prompt cleanup and player readability.
extends GdUnitTestSuite

const FACTORY_SCENE := preload("res://scenes/factory_route_transition_shell.tscn")
const HATCH_NODE: NodePath = (
	^"FactoryLowerDeckForwardPressureAftershockExhaustExitHatch"
)
const BREAKER_NODE: NodePath = (
	^"FactoryLowerDeckForwardPressureAftershockExhaustBreaker"
)
const DUCT_NODE: NodePath = (
	^"FactoryLowerDeckForwardPressureAftershockCoolingDuct"
)
const MINIMUM_RETRACTION_PX: float = 120.0

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


func test_exit_hatch_visual_state_contract() -> void:
	var factory: Node = FACTORY_SCENE.instantiate()
	add_child(factory)
	_spawned_nodes.append(factory)
	await _wait_process_frames(2)
	factory.call("set_local_state", _hatch_state(false))

	var player := factory.get_node_or_null("Player") as CharacterBody2D
	var hatch := factory.get_node_or_null(HATCH_NODE) as Node2D
	var breaker := factory.get_node_or_null(BREAKER_NODE) as Node2D
	var duct_node := factory.get_node_or_null(DUCT_NODE) as Node2D
	assert_that(player).is_not_null()
	assert_that(hatch).is_not_null()
	assert_that(breaker).is_not_null()
	assert_that(duct_node).is_not_null()
	if player == null or hatch == null or breaker == null or duct_node == null:
		return

	var hatch_visual := hatch.get_node_or_null("Visual") as Sprite2D
	var hatch_prompt := hatch.get_node_or_null("PromptLabel") as Label
	var breaker_prompt := breaker.get_node_or_null("PromptLabel") as Label
	assert_that(hatch_visual).is_not_null()
	assert_that(hatch_prompt).is_not_null()
	assert_that(breaker_prompt).is_not_null()
	if hatch_visual == null or hatch_prompt == null or breaker_prompt == null:
		return

	var hatch_root_position: Vector2 = hatch.position
	var closed_visual_position: Vector2 = hatch_visual.position
	var hatch_texture: Texture2D = hatch_visual.texture
	assert_bool(hatch_prompt.visible).override_failure_message(
		"The available closed hatch must keep its interaction prompt"
	).is_true()
	assert_int(hatch.z_index).override_failure_message(
		"The hatch panel must render behind Cinderpaw at the threshold"
	).is_less(player.z_index)
	assert_bool(breaker_prompt.visible).override_failure_message(
		"The already-cut breaker prompt must not overlap the active hatch objective"
	).is_false()
	assert_str(breaker_prompt.text).is_equal("Exhaust Cut")

	player.global_position = hatch.global_position
	assert_bool(bool(factory.call(
		"try_open_factory_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch",
		player
	))).is_true()

	var opened: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch_diagnostics"
	)
	var duct: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_cooling_duct_diagnostics"
	)
	assert_float(hatch_visual.position.y).override_failure_message(
		"Opening Story092 must visibly retract the existing hatch panel"
	).is_less_equal(closed_visual_position.y - MINIMUM_RETRACTION_PX)
	assert_that(hatch.position).is_equal(hatch_root_position)
	assert_that(hatch_visual.texture).is_same(hatch_texture)
	assert_int(hatch.z_index + hatch_visual.z_index).override_failure_message(
		"The retracted panel must sit behind the cooling-duct shell"
	).is_less(duct_node.z_index)
	assert_bool(hatch_prompt.visible).override_failure_message(
		"The completed hatch prompt must not overlap the active duct objective"
	).is_false()
	assert_str(String(opened.get("prompt_text", ""))).is_equal("Exhaust Hatch Open")
	assert_bool(bool(opened.get("collision_blocking", true))).is_false()
	assert_bool(bool(opened.get("interaction_monitoring", true))).is_false()
	assert_bool(bool(opened.get("interaction_monitorable", true))).is_false()
	assert_int(int(opened.get("unlock_feedback_spawn_count", 0))).is_equal(1)
	assert_bool(bool(duct.get("available", false))).is_true()
	assert_bool(bool(duct.get("visible", false))).is_true()
	assert_bool(bool(duct.get("active", true))).is_false()

	var restored: Node = FACTORY_SCENE.instantiate()
	add_child(restored)
	_spawned_nodes.append(restored)
	await _wait_process_frames(2)
	restored.call("set_local_state", _hatch_state(true))
	var restored_hatch := restored.get_node_or_null(HATCH_NODE) as Node2D
	assert_that(restored_hatch).is_not_null()
	if restored_hatch == null:
		return
	var restored_visual := restored_hatch.get_node_or_null("Visual") as Sprite2D
	var restored_prompt := restored_hatch.get_node_or_null("PromptLabel") as Label
	assert_that(restored_visual).is_not_null()
	assert_that(restored_prompt).is_not_null()
	if restored_visual == null or restored_prompt == null:
		return
	var restored_state: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch_diagnostics"
	)
	assert_float(restored_visual.position.y).is_less_equal(
		closed_visual_position.y - MINIMUM_RETRACTION_PX
	)
	assert_that(restored_hatch.position).is_equal(hatch_root_position)
	assert_that(restored_visual.texture).is_same(hatch_texture)
	assert_bool(restored_prompt.visible).is_false()
	assert_int(int(restored_state.get("unlock_feedback_spawn_count", -1))).is_equal(0)
	assert_bool(bool(restored_state.get("collision_blocking", true))).is_false()
	assert_bool(bool(restored_state.get("interaction_monitoring", true))).is_false()
	assert_bool(bool(restored_state.get("interaction_monitorable", true))).is_false()
	var restored_duct: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_aftershock_cooling_duct_diagnostics"
	)
	assert_bool(bool(restored_duct.get("available", false))).is_true()
	assert_bool(bool(restored_duct.get("visible", false))).is_true()
	assert_bool(bool(restored_duct.get("active", true))).is_false()


func _hatch_state(opened: bool) -> Dictionary:
	return {
		"factory_lower_deck_forward_pressure_aftershock_exhaust_breaker_activated": true,
		"factory_lower_deck_forward_pressure_aftershock_exhaust_breaker_coil_rat_defeated": true,
		"factory_lower_deck_forward_pressure_aftershock_exhaust_breaker_secured": true,
		"factory_lower_deck_forward_pressure_aftershock_exhaust_breaker_cut": true,
		"factory_lower_deck_forward_pressure_aftershock_exhaust_escape_skirmish_activated": true,
		"factory_lower_deck_forward_pressure_aftershock_exhaust_escape_skirmish_spark_rat_defeated": true,
		"factory_lower_deck_forward_pressure_aftershock_exhaust_escape_skirmish_coil_rat_defeated": true,
		"factory_lower_deck_forward_pressure_aftershock_exhaust_escape_skirmish_cleared": true,
		"factory_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch_opened": opened,
		"factory_lower_deck_forward_pressure_aftershock_cooling_duct_activated": false,
		"factory_lower_deck_forward_pressure_aftershock_cooling_duct_crossed": false,
		"factory_service_lift_activated": false,
		"factory_service_lift_exit_requested": false,
	}


func _wait_process_frames(frame_count: int) -> void:
	for _frame: int in range(frame_count):
		await get_tree().process_frame


func _stop_runtime_audio_players() -> void:
	for audio_player: AudioStreamPlayer in _find_nodes_of_type(
		get_tree().root,
		AudioStreamPlayer
	):
		audio_player.stop()
	for audio_player_2d: AudioStreamPlayer2D in _find_nodes_of_type(
		get_tree().root,
		AudioStreamPlayer2D
	):
		audio_player_2d.stop()


func _find_nodes_of_type(root: Node, expected_type: Variant) -> Array[Node]:
	var matches: Array[Node] = []
	if is_instance_of(root, expected_type):
		matches.append(root)
	for child: Node in root.get_children():
		matches.append_array(_find_nodes_of_type(child, expected_type))
	return matches
