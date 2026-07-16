## Player Abilities Story168: four-Boss ACT completion at Scrap Roost.
extends GdUnitTestSuite

const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")
const ARENA_SCENE_ID: StringName = &"boss_04_crown_warden_arena"
const MAIN_SCENE_ID: StringName = &"main"
const MAIN_SPAWN: StringName = &"scrap_roost"
const DEFEATED_KEY: String = "boss_04_crown_warden_defeated"
const REWARD_KEY: String = "boss_04_wall_climb_reward_claimed"
const RECALL_KEY: String = "boss_04_victory_recall_requested"
const COMPLETION_FLAG: String = "four_boss_act_completion_seen"
const BACKGROUND_PATH: String = "res://assets/ui/act_complete/act_complete_scrap_roost_1280x720.png"

var _spawned_nodes: Array[Node] = []


class ActCompleteSceneManager:
	extends RefCounted

	signal on_scene_load_failed(scene_id: StringName, reason: StringName)
	signal on_scene_changed(old_scene: StringName, new_scene: StringName)
	signal on_scene_load_started(
		scene_id: StringName,
		spawn_point: StringName,
		metadata: Dictionary
	)

	var current_scene: StringName = MAIN_SCENE_ID
	var current_spawn: StringName = MAIN_SPAWN
	var states: Dictionary = {
		String(ARENA_SCENE_ID): {
			DEFEATED_KEY: true,
			REWARD_KEY: true,
			RECALL_KEY: true,
		},
	}

	func request_scene_change(_scene_id: StringName, _spawn_point: StringName) -> bool:
		return true

	func get_current_scene() -> StringName:
		return current_scene

	func get_current_spawn_point() -> StringName:
		return current_spawn

	func get_scene_state(scene_id: StringName) -> Dictionary:
		return Dictionary(states.get(String(scene_id), {})).duplicate(true)

	func configure_runtime_scene_root(_root: Node, _current: Node = null) -> bool:
		return true


class ImmediateSaveSystem:
	extends Node

	var autosave_calls: Array[Dictionary] = []

	func manual_save(
		_slot: int,
		_player_state: Dictionary = {},
		_world_state: Dictionary = {},
		_settings: Dictionary = {}
	) -> bool:
		return true

	func auto_save(
		_player_state: Dictionary = {},
		world_state: Dictionary = {},
		_settings: Dictionary = {}
	) -> bool:
		autosave_calls.append(world_state.duplicate(true))
		return true


func after_test() -> void:
	for node: Node in _spawned_nodes:
		if not is_instance_valid(node):
			continue
		if node.get_parent() != null:
			node.get_parent().remove_child(node)
		node.free()
	_spawned_nodes.clear()


func test_full_boss4_proof_presents_once_and_persists_act_completion() -> void:
	var main: Node = MAIN_SCENE.instantiate()
	add_child(main)
	_spawned_nodes.append(main)
	var save_system := ImmediateSaveSystem.new()
	add_child(save_system)
	_spawned_nodes.append(save_system)
	assert_bool(bool(main.call("configure_save_system_runtime", save_system))).is_true()

	main.call("set_local_state", {
		"unlocked_abilities": [
			"basic_attack", "jump", "dodge", "dash", "double_jump",
			"aerial_attack", "parry", "wall_climb",
		],
		"world_flags": {
			"boss_rat_king_defeated": true,
			"boss_02_echo_guardian_defeated": true,
			"boss_02_double_jump_claimed": true,
		},
	})
	var scene_manager := ActCompleteSceneManager.new()
	assert_bool(bool(main.call("configure_scene_manager_runtime", scene_manager))).is_true()

	assert_bool(main.has_method("get_act_completion_diagnostics")).override_failure_message(
		"Story168 must expose the ACT completion presentation contract"
	).is_true()
	assert_bool(main.has_method("advance_act_completion")).is_true()
	if (
		not main.has_method("get_act_completion_diagnostics")
		or not main.has_method("advance_act_completion")
	):
		return

	var pending: Dictionary = Dictionary(main.call("get_act_completion_diagnostics"))
	assert_str(String(pending.get("state", ""))).is_equal("pending")
	assert_bool(bool(pending.get("panel_visible", true))).is_false()
	assert_bool(bool(main.call("advance_act_completion", 2.5))).is_true()

	var presented: Dictionary = Dictionary(main.call("get_act_completion_diagnostics"))
	assert_str(String(presented.get("state", ""))).is_equal("presented")
	assert_bool(bool(presented.get("panel_visible", false))).is_true()
	assert_bool(bool(presented.get("player_control_locked", false))).is_true()
	assert_str(String(presented.get("menu_mode", ""))).is_equal("act_complete")
	assert_str(String(presented.get("background_texture_path", ""))).is_equal(BACKGROUND_PATH)
	assert_bool(FileAccess.file_exists(BACKGROUND_PATH)).is_true()
	assert_int(save_system.autosave_calls.size()).is_equal(1)
	var saved_flags: Dictionary = Dictionary(
		Dictionary(save_system.autosave_calls[0]).get("world_flags", {})
	)
	assert_bool(bool(saved_flags.get(COMPLETION_FLAG, false))).is_true()

	main.call("configure_scene_manager_runtime", scene_manager)
	main.call("advance_act_completion", 3.0)
	assert_int(save_system.autosave_calls.size()).is_equal(1)
	var hud: Node = main.get_node("HUD")
	hud.emit_signal("menu_resume_requested")
	var acknowledged: Dictionary = Dictionary(main.call("get_act_completion_diagnostics"))
	assert_str(String(acknowledged.get("state", ""))).is_equal("acknowledged")
	assert_bool(bool(acknowledged.get("panel_visible", true))).is_false()
	assert_bool(bool(acknowledged.get("player_control_locked", true))).is_false()


func test_incomplete_proof_and_seen_save_do_not_replay_completion() -> void:
	var main: Node = MAIN_SCENE.instantiate()
	add_child(main)
	_spawned_nodes.append(main)
	var save_system := ImmediateSaveSystem.new()
	add_child(save_system)
	_spawned_nodes.append(save_system)
	main.call("configure_save_system_runtime", save_system)
	var scene_manager := ActCompleteSceneManager.new()
	var incomplete_state: Dictionary = Dictionary(
		scene_manager.states.get(String(ARENA_SCENE_ID), {})
	)
	incomplete_state.erase(RECALL_KEY)
	scene_manager.states[String(ARENA_SCENE_ID)] = incomplete_state
	main.call("configure_scene_manager_runtime", scene_manager)
	var diagnostics: Dictionary = Dictionary(main.call("get_act_completion_diagnostics"))
	assert_str(String(diagnostics.get("state", ""))).is_equal("idle")
	assert_bool(bool(main.call("advance_act_completion", 3.0))).is_false()
	assert_int(save_system.autosave_calls.size()).is_equal(0)

	scene_manager.states[String(ARENA_SCENE_ID)] = {
		DEFEATED_KEY: true,
		REWARD_KEY: true,
		RECALL_KEY: true,
	}
	main.call("set_local_state", {
		"world_flags": {
			"boss_04_victory_hub_return_secured": true,
			COMPLETION_FLAG: true,
		},
	})
	main.call("configure_scene_manager_runtime", scene_manager)
	diagnostics = Dictionary(main.call("get_act_completion_diagnostics"))
	assert_str(String(diagnostics.get("state", ""))).is_equal("acknowledged")
	assert_bool(bool(diagnostics.get("panel_visible", true))).is_false()
	assert_bool(bool(main.call("advance_act_completion", 3.0))).is_false()
	assert_int(save_system.autosave_calls.size()).is_equal(0)


func test_return_to_title_keeps_gameplay_locked_until_title_choice() -> void:
	var main: Node = MAIN_SCENE.instantiate()
	add_child(main)
	_spawned_nodes.append(main)
	main.call("set_local_state", {
		"world_flags": {
			"boss_rat_king_defeated": true,
			"boss_02_echo_guardian_defeated": true,
		},
	})
	var scene_manager := ActCompleteSceneManager.new()
	main.call("configure_scene_manager_runtime", scene_manager)
	main.call("advance_act_completion", 2.5)
	var hud: Node = main.get_node("HUD")
	hud.emit_signal("menu_main_menu_requested")
	var diagnostics: Dictionary = Dictionary(main.call("get_act_completion_diagnostics"))
	assert_str(String(diagnostics.get("state", ""))).is_equal("title")
	assert_str(String(diagnostics.get("menu_mode", ""))).is_equal("main_menu")
	assert_bool(bool(diagnostics.get("panel_visible", true))).is_false()
	assert_bool(bool(diagnostics.get("player_control_locked", false))).is_true()
	hud.emit_signal("menu_resume_requested")
	diagnostics = Dictionary(main.call("get_act_completion_diagnostics"))
	assert_str(String(diagnostics.get("state", ""))).is_equal("acknowledged")
	assert_bool(bool(diagnostics.get("player_control_locked", true))).is_false()
