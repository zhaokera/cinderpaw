## Player Abilities Story 109: Old Factory runoff exit reward cache and gate.
extends GdUnitTestSuite

const FACTORY_SCENE_PATH: String = "res://scenes/factory_route_transition_shell.tscn"
const FACTORY_PLAYER_NAME: String = "Player"
const RUNOFF_EXIT_REWARD_CACHE_ID: String = (
	"old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_reward_cache"
)
const RUNOFF_EXIT_GATE_ID: String = (
	"old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_gate"
)
const RUNOFF_EXIT_REWARD_CACHE_TEXTURE: String = (
	"res://assets/environment/old_factory_lower_deck_skirmish_cache/"
	+ "env_old_factory_lower_deck_skirmish_cache_claimable_256.png"
)
const RUNOFF_EXIT_GATE_TEXTURE: String = (
	"res://assets/environment/old_factory_lower_deck_deep_bulkhead/"
	+ "env_old_factory_lower_deck_deep_bulkhead_closed_256.png"
)

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


func test_runoff_exit_reward_cache_requires_skirmish_clear_and_opens_gate_once(
) -> void:
	assert_bool(FileAccess.file_exists(RUNOFF_EXIT_REWARD_CACHE_TEXTURE)).is_true()
	assert_bool(FileAccess.file_exists(RUNOFF_EXIT_GATE_TEXTURE)).is_true()

	var locked_scene: Node = _factory_scene_with_runoff_exit_reward_state(false, false, false)
	assert_that(locked_scene).is_not_null()
	if locked_scene == null:
		return

	assert_bool(locked_scene.has_method(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_reward_cache_diagnostics"
	)).is_true()
	assert_bool(locked_scene.has_method(
		"try_claim_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_reward_cache"
	)).is_true()
	assert_bool(locked_scene.has_method(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_gate_diagnostics"
	)).is_true()
	assert_bool(locked_scene.has_method(
		"try_open_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_gate"
	)).is_true()
	if (
		not locked_scene.has_method(
			"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_reward_cache_diagnostics"
		)
		or not locked_scene.has_method(
			"try_claim_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_reward_cache"
		)
		or not locked_scene.has_method(
			"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_gate_diagnostics"
		)
		or not locked_scene.has_method(
			"try_open_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_gate"
		)
	):
		return

	var locked_cache: Dictionary = locked_scene.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_reward_cache_diagnostics"
	)
	var locked_gate: Dictionary = locked_scene.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_gate_diagnostics"
	)
	assert_bool(bool(locked_cache.get("present", false))).is_true()
	assert_bool(bool(locked_cache.get("runoff_exit_skirmish_cleared", true))).is_false()
	assert_bool(bool(locked_cache.get("available", true))).is_false()
	assert_bool(bool(locked_cache.get("visible", true))).is_false()
	assert_bool(bool(locked_cache.get("claim_available", true))).is_false()
	assert_bool(bool(locked_gate.get("present", false))).is_true()
	assert_bool(bool(locked_gate.get("cache_claimed", true))).is_false()
	assert_bool(bool(locked_gate.get("available", true))).is_false()
	assert_bool(bool(locked_gate.get("visible", true))).is_false()
	assert_bool(bool(locked_scene.call(
		"try_claim_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_reward_cache"
	))).is_false()
	assert_bool(bool(locked_scene.call(
		"try_open_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_gate"
	))).is_false()

	var destination: Node = _factory_scene_with_runoff_exit_reward_state(true, false, false)
	assert_that(destination).is_not_null()
	if destination == null:
		return
	var player: Node2D = destination.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	assert_that(player).is_not_null()
	if player == null:
		return

	var available_cache: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_reward_cache_diagnostics"
	)
	var gated_gate: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_gate_diagnostics"
	)
	assert_bool(bool(available_cache.get("runoff_exit_skirmish_cleared", false))).is_true()
	assert_bool(bool(available_cache.get("available", false))).is_true()
	assert_bool(bool(available_cache.get("visible", false))).is_true()
	assert_bool(bool(available_cache.get("claim_available", false))).is_true()
	assert_bool(bool(available_cache.get("claimed", true))).is_false()
	assert_str(String(available_cache.get("cache_id", ""))).is_equal(
		RUNOFF_EXIT_REWARD_CACHE_ID
	)
	assert_str(String(available_cache.get("texture_path", ""))).is_equal(
		RUNOFF_EXIT_REWARD_CACHE_TEXTURE
	)
	assert_str(String(available_cache.get("prompt_text", ""))).is_equal("+20 Gears")
	assert_str(String(available_cache.get("route_label_text", ""))).is_equal(
		"Overflow Pump Runoff Exit Cleared"
	)
	assert_bool(bool(gated_gate.get("available", true))).is_false()
	assert_bool(bool(gated_gate.get("visible", true))).is_false()

	player.global_position = available_cache.get("position", Vector2.ZERO) as Vector2
	assert_bool(bool(destination.call(
		"try_claim_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_reward_cache",
		player
	))).is_true()
	assert_bool(bool(destination.call(
		"try_claim_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_reward_cache",
		player
	))).is_false()

	var claimed_cache: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_reward_cache_diagnostics"
	)
	var unlocked_gate: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_gate_diagnostics"
	)
	var reward: Dictionary = claimed_cache.get("last_reward", {}) as Dictionary
	var feedback: Dictionary = claimed_cache.get("last_claim_feedback", {}) as Dictionary
	assert_bool(bool(claimed_cache.get("claimed", false))).is_true()
	assert_bool(bool(claimed_cache.get("claim_available", true))).is_false()
	assert_str(String(reward.get("cache_id", ""))).is_equal(RUNOFF_EXIT_REWARD_CACHE_ID)
	assert_int(int(reward.get("gears", 0))).is_equal(20)
	assert_str(String(reward.get("source", ""))).is_equal(RUNOFF_EXIT_REWARD_CACHE_ID)
	assert_str(String(feedback.get("text", ""))).is_equal(
		"Runoff Exit Cache Claimed +20 Gears"
	)
	assert_bool(bool(unlocked_gate.get("available", false))).is_true()
	assert_bool(bool(unlocked_gate.get("visible", false))).is_true()
	assert_bool(bool(unlocked_gate.get("opened", true))).is_false()
	assert_str(String(unlocked_gate.get("gate_id", ""))).is_equal(RUNOFF_EXIT_GATE_ID)
	assert_str(String(unlocked_gate.get("texture_path", ""))).is_equal(
		RUNOFF_EXIT_GATE_TEXTURE
	)
	assert_str(String(unlocked_gate.get("prompt_text", ""))).is_equal(
		"Open Runoff Exit Gate"
	)

	player.global_position = unlocked_gate.get("position", Vector2.ZERO) as Vector2
	assert_bool(bool(destination.call(
		"try_open_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_gate",
		player
	))).is_true()
	assert_bool(bool(destination.call(
		"try_open_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_gate",
		player
	))).is_false()

	var opened_gate: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_gate_diagnostics"
	)
	assert_bool(bool(opened_gate.get("opened", false))).is_true()
	assert_bool(bool(opened_gate.get("available", true))).is_false()
	assert_bool(bool(opened_gate.get("visible", false))).is_true()
	assert_bool(bool(opened_gate.get("collision_blocking", true))).is_false()
	assert_str(String(opened_gate.get("route_label_text", ""))).is_equal(
		"Overflow Pump Runoff Exit Gate Open"
	)

	var local_state: Dictionary = destination.call("get_local_state")
	assert_bool(bool(local_state.get(
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_reward_cache_claimed",
		false
	))).is_true()
	assert_bool(bool(local_state.get(
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_gate_opened",
		false
	))).is_true()


func test_runoff_exit_reward_cache_restore_preserves_exit_chain(
) -> void:
	var restored: Node = _factory_scene_with_runoff_exit_reward_state(true, true, true)
	assert_that(restored).is_not_null()
	if restored == null:
		return
	assert_bool(restored.has_method(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_reward_cache_diagnostics"
	)).is_true()
	assert_bool(restored.has_method(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_gate_diagnostics"
	)).is_true()
	if (
		not restored.has_method(
			"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_reward_cache_diagnostics"
		)
		or not restored.has_method(
			"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_gate_diagnostics"
		)
	):
		return

	var restored_cache: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_reward_cache_diagnostics"
	)
	var restored_gate: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_gate_diagnostics"
	)
	assert_bool(bool(restored_cache.get("claimed", false))).is_true()
	assert_bool(bool(restored_cache.get("claim_available", true))).is_false()
	assert_bool(bool(restored_gate.get("opened", false))).is_true()
	assert_bool(bool(restored_gate.get("collision_blocking", true))).is_false()
	assert_str(String(restored_gate.get("route_label_text", ""))).is_equal(
		"Overflow Pump Runoff Exit Gate Open"
	)

	var restored_exit: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_skirmish_diagnostics"
	)
	assert_bool(bool(restored_exit.get("cleared", false))).is_true()
	var restored_runoff_duct: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_duct_diagnostics"
	)
	assert_bool(bool(restored_runoff_duct.get("crossed", false))).is_true()
	assert_bool(bool(restored_runoff_duct.get("hazard_contact_active", true))).is_false()
	var restored_hatch: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_exit_hatch_diagnostics"
	)
	assert_bool(bool(restored_hatch.get("opened", false))).is_true()
	assert_bool(bool(restored_hatch.get("collision_blocking", true))).is_false()


func _factory_scene_with_runoff_exit_reward_state(
		runoff_exit_cleared: bool,
		cache_claimed: bool,
		gate_opened: bool
) -> Node:
	var destination: Node = _instantiate_factory_scene()
	if destination == null:
		return null
	destination.call("set_local_state", {
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_skirmish_activated": (
			runoff_exit_cleared
		),
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_coil_rat_defeated": (
			runoff_exit_cleared
		),
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_skirmish_cleared": (
			runoff_exit_cleared
		),
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_reward_cache_claimed": (
			cache_claimed
		),
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_gate_opened": (
			gate_opened
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
			(child as AudioStreamPlayer).stop()
