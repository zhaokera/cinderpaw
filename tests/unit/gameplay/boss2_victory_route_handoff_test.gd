## Player Abilities Story 033: Boss2 victory route handoff.
extends GdUnitTestSuite

const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")
const BOSS_NODE_NAME: String = "Boss2EchoGuardian"
const REWARD_NODE_NAME: String = "Boss2DoubleJumpRewardSource"
const DOUBLE_JUMP_GATE_NAME: String = "DoubleJumpExplorationGate"
const FACTORY_ROUTE_TRIGGER_NAME: String = "FactoryRouteTransitionShell"
const BOSS2_ENTITY_ID: int = 2200
const DOUBLE_JUMP_ABILITY: StringName = &"double_jump"
const FACTORY_SCENE_ID: StringName = &"area_03_factory"
const FACTORY_SPAWN_POINT: StringName = &"factory_gate_entry"
const FACTORY_DISPLAY_NAME: String = "Factory Route"
const STATE_UNLOCKABLE: StringName = &"unlockable"
const STATE_UNLOCKED: StringName = &"unlocked"
const RAT_KING_DEFEATED_FLAG: StringName = &"boss_rat_king_defeated"

var _scene: Node2D


class FakeFactorySceneManager:
	extends RefCounted

	signal on_scene_load_started(scene_id: StringName, spawn_point: StringName, metadata: Dictionary)
	signal on_scene_changed(old_scene: StringName, new_scene: StringName)
	signal on_scene_load_failed(scene_id: StringName, reason: StringName)

	var request_calls: Array[Dictionary] = []
	var loading: bool = false
	var runtime_root_configured: bool = false
	var current_scene_node: Node = null
	var known_scenes: Dictionary = {
		"main": true,
		"area_03_factory": true,
	}

	func has_scene(scene_id: StringName) -> bool:
		return bool(known_scenes.get(String(scene_id), false))

	func get_scene_config(scene_id: StringName) -> Dictionary:
		if scene_id == FACTORY_SCENE_ID:
			return {
				"scene_id": String(FACTORY_SCENE_ID),
				"default_spawn": String(FACTORY_SPAWN_POINT),
				"display_name": FACTORY_DISPLAY_NAME,
			}
		return {
			"scene_id": String(scene_id),
			"default_spawn": "default",
			"display_name": "Scrap Alley",
		}

	func get_current_scene() -> StringName:
		return &"main"

	func is_loading() -> bool:
		return loading

	func is_runtime_scene_swap_enabled() -> bool:
		return runtime_root_configured

	func configure_runtime_scene_root(root: Node, current_scene: Node = null) -> bool:
		runtime_root_configured = root != null and current_scene != null
		current_scene_node = current_scene
		return runtime_root_configured

	func request_scene_change(scene_id: StringName, spawn_point: StringName = &"default") -> bool:
		if loading or not has_scene(scene_id):
			return false
		request_calls.append({
			"scene_id": String(scene_id),
			"spawn_point": String(spawn_point),
		})
		loading = true
		var metadata: Dictionary = get_scene_config(scene_id)
		metadata["transition_duration_sec"] = 1.5
		on_scene_load_started.emit(scene_id, spawn_point, metadata)
		return true


func before_test() -> void:
	_scene = MAIN_SCENE.instantiate() as Node2D
	add_child(_scene)
	_scene.call("set_world_progress_flag", RAT_KING_DEFEATED_FLAG, true)


func after_test() -> void:
	if is_instance_valid(_scene):
		if _scene.get_parent() != null:
			_scene.get_parent().remove_child(_scene)
		_scene.free()
	_scene = null


func test_boss2_victory_reward_handoff_opens_factory_route_transition() -> void:
	var scene_manager := FakeFactorySceneManager.new()
	assert_bool(bool(_scene.call("configure_scene_manager_runtime", scene_manager))).is_true()
	assert_bool(_scene.has_method("get_boss2_victory_route_handoff_diagnostics")).is_true()

	var boss: Node = _scene.get_node_or_null(BOSS_NODE_NAME)
	var reward: Node2D = _scene.get_node_or_null(REWARD_NODE_NAME) as Node2D
	var gate: Node2D = _scene.get_node_or_null(DOUBLE_JUMP_GATE_NAME) as Node2D
	var route_shell: Node2D = _scene.get_node_or_null(FACTORY_ROUTE_TRIGGER_NAME) as Node2D
	var player := _scene.get_node("Player") as PlayerController
	assert_that(boss).is_not_null()
	assert_that(reward).is_not_null()
	assert_that(gate).is_not_null()
	assert_that(route_shell).is_not_null()
	if boss == null or reward == null or gate == null or route_shell == null:
		return

	var initial: Dictionary = _scene.call("get_boss2_victory_route_handoff_diagnostics")
	assert_bool(bool(initial.get("boss_defeated", true))).is_false()
	assert_bool(bool(initial.get("reward_claim_available", true))).is_false()
	assert_str(String(initial.get("reward_prompt_text", ""))).is_equal("Defeat Echo Guardian")
	assert_bool(bool(initial.get("reward_prompt_visible", true))).is_false()
	assert_bool(bool(initial.get("factory_route_available", true))).is_false()

	assert_bool(_scene.call("apply_damage", BOSS2_ENTITY_ID, int(boss.call("get_current_hp")), {
		"source": &"unit_test_boss2_victory_handoff",
	})).is_true()
	assert_bool(bool(_scene.call("advance_boss2_death_presentation", 2.0))).is_true()
	await get_tree().process_frame

	var defeated: Dictionary = _scene.call("get_boss2_victory_route_handoff_diagnostics")
	assert_bool(bool(defeated.get("boss_defeated", false))).is_true()
	assert_bool(bool(defeated.get("room_seals_enabled", true))).is_false()
	assert_bool(bool(defeated.get("reward_claim_available", false))).is_true()
	assert_str(String(defeated.get("reward_prompt_text", ""))).is_equal("Claim Double Jump")
	assert_bool(bool(defeated.get("reward_prompt_visible", true))).is_false()
	assert_bool(String(defeated.get("hud_notification_text", "")).contains("Claim Double Jump")).is_true()

	player.global_position = reward.global_position + Vector2(-160, 0)
	await get_tree().process_frame
	var approached_reward: Dictionary = _scene.call("get_boss2_victory_route_handoff_diagnostics")
	assert_bool(bool(approached_reward.get("reward_prompt_visible", false))).is_true()
	assert_bool(bool(reward.call("is_provider_in_reward_range", player))).is_false()

	player.global_position = reward.global_position
	assert_bool(bool(reward.call("is_provider_in_reward_range", player))).is_true()
	assert_bool(bool(_scene.call("claim_boss2_double_jump_reward_source", player))).is_true()
	assert_bool(player.has_ability(DOUBLE_JUMP_ABILITY)).is_true()

	var claimed: Dictionary = _scene.call("get_boss2_victory_route_handoff_diagnostics")
	assert_bool(bool(claimed.get("reward_claimed", false))).is_true()
	assert_str(String(claimed.get("gate_state", ""))).is_equal(String(STATE_UNLOCKABLE))
	assert_bool(bool(claimed.get("factory_route_available", true))).is_false()

	player.global_position = gate.global_position + Vector2(-48, 0)
	player.call("set_airborne", true)
	assert_bool(bool(player.call("request_double_jump"))).is_true()
	assert_str(String(gate.call("get_gate_state"))).is_equal(String(STATE_UNLOCKED))

	var unlocked: Dictionary = _scene.call("get_boss2_victory_route_handoff_diagnostics")
	assert_bool(bool(unlocked.get("factory_route_available", false))).is_true()
	assert_str(String(unlocked.get("factory_route_prompt_text", ""))).is_equal("Enter Factory Route")

	player.global_position = route_shell.global_position
	assert_bool(bool(_scene.call("request_factory_route_transition", player))).is_true()
	assert_bool(scene_manager.runtime_root_configured).is_true()
	assert_that(scene_manager.current_scene_node).is_same(_scene)
	assert_int(scene_manager.request_calls.size()).is_equal(1)
	assert_str(String(scene_manager.request_calls[0].get("scene_id", ""))).is_equal(String(FACTORY_SCENE_ID))
	assert_str(String(scene_manager.request_calls[0].get("spawn_point", ""))).is_equal(String(FACTORY_SPAWN_POINT))

	var transitioned: Dictionary = _scene.call("get_boss2_victory_route_handoff_diagnostics")
	assert_bool(bool(transitioned.get("factory_route_transition_requested", false))).is_true()
	assert_bool(bool(_scene.get_node("HUD").call("is_scene_transition_visible"))).is_true()
	assert_str(String(_scene.get_node("HUD").call("get_scene_transition_label_text"))).is_equal(
		FACTORY_DISPLAY_NAME
	)
	assert_bool(bool(_scene.call("request_factory_route_transition", player))).is_false()
	assert_int(scene_manager.request_calls.size()).is_equal(1)
