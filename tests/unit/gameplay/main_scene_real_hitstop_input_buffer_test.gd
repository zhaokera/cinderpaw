## Story 021: hitstop freezes gameplay ticks and releases one buffered attack.
extends GdUnitTestSuite

const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")


class PhysicsProbe extends Node:
	var physics_ticks: int = 0


	func _physics_process(_delta: float) -> void:
		physics_ticks += 1


var scene: Node
var player: PlayerController
var presentation: CombatPresentation
var input_manager: Node


func before_test() -> void:
	Input.action_release(&"attack")
	get_tree().paused = false
	input_manager = get_node("/root/InputManager")
	input_manager.call("clear_buffer")
	input_manager.call("notify_animation_lock", 0)
	scene = MAIN_SCENE.instantiate()
	add_child(scene)
	player = scene.get_node("Player") as PlayerController
	presentation = scene.get_node("CombatPresentation") as CombatPresentation


func after_test() -> void:
	get_tree().paused = false
	Input.action_release(&"attack")
	if input_manager != null:
		input_manager.call("clear_buffer")
		input_manager.call("notify_animation_lock", 0)
	_stop_runtime_audio_players()
	if is_instance_valid(scene):
		if scene.get_parent() != null:
			scene.get_parent().remove_child(scene)
		scene.free()
	scene = null
	player = null
	presentation = null
	input_manager = null


func test_three_frame_hitstop_freezes_gameplay_and_releases_one_buffered_attack() -> void:
	var probe := PhysicsProbe.new()
	probe.name = "HitstopPhysicsProbe"
	probe.process_mode = Node.PROCESS_MODE_PAUSABLE
	scene.add_child(probe)
	var attack_events: Array[Dictionary] = []
	var finish_snapshots: Array[Dictionary] = []
	var released_input_events: Array[Dictionary] = []
	player.attack_started.connect(func(metadata: Dictionary) -> void:
		attack_events.append(metadata.duplicate(true))
	)
	presentation.hitstop_finished.connect(func(consume_buffered_input: bool) -> void:
		finish_snapshots.append({
			"consume_buffered_input": consume_buffered_input,
			"probe_ticks": probe.physics_ticks,
		})
	)
	input_manager.action_triggered.connect(func(action_id: StringName, metadata: Dictionary) -> void:
		released_input_events.append({
			"action_id": action_id,
			"metadata": metadata.duplicate(true),
		})
	, CONNECT_ONE_SHOT)
	var ticks_before_hitstop: int = probe.physics_ticks

	presentation.play_hitstop(3)

	assert_bool(get_tree().paused).is_true()
	assert_str(String(input_manager.call("get_input_state"))).is_equal("buffering")
	assert_bool(bool(input_manager.call(
		"accept_action",
		&"attack",
		Time.get_ticks_msec() - 1,
		&"kbm"
	))).is_true()
	assert_int(int(input_manager.call("get_buffered_action_count"))).is_equal(1)
	assert_int(attack_events.size()).is_equal(0)

	while presentation.is_gameplay_hitstop_active():
		await get_tree().process_frame

	assert_bool(get_tree().paused).is_false()
	assert_int(presentation.get_last_completed_hitstop_frames()).is_equal(3)
	assert_int(finish_snapshots.size()).is_equal(1)
	if not finish_snapshots.is_empty():
		assert_bool(bool(finish_snapshots[0].get("consume_buffered_input", false))).is_true()
		assert_int(int(finish_snapshots[0].get("probe_ticks", -1))).is_equal(
			ticks_before_hitstop
		)
	assert_str(String(input_manager.call("get_input_state"))).is_equal("direct")
	assert_int(int(input_manager.call("get_buffered_action_count"))).is_equal(0)
	assert_int(released_input_events.size()).is_equal(1)
	if not released_input_events.is_empty():
		assert_str(String(released_input_events[0].get("action_id", &""))).is_equal("attack")
		var released_metadata: Dictionary = released_input_events[0].get("metadata", {})
		assert_int(int(released_metadata.get("buffer_delay_ms", -1))).is_greater(0)
	var buffered_result: Dictionary = scene.call("get_last_buffered_input_result")
	assert_str(String(buffered_result.get("action_id", &""))).is_equal("attack")
	assert_int(int(buffered_result.get("dispatch_count", 0))).is_equal(1)
	assert_bool(bool(buffered_result.get("player_attack_active_before", true))).is_false()
	assert_int(int(buffered_result.get("combat_state_before", -1))).is_equal(
		CombatComponent.CombatState.IDLE
	)
	assert_bool(bool(buffered_result.get("accepted", false))).is_true()
	assert_bool(bool(player.get("_control_locked"))).is_false()
	assert_int(int(player.get("_state"))).is_equal(PlayerController.State.ATTACKING)
	assert_int(player.get_combat_component().get_current_state()).is_equal(
		CombatComponent.CombatState.ATTACKING
	)
	assert_int(attack_events.size()).is_equal(1)
	if not attack_events.is_empty():
		assert_int(int(attack_events[0].get("combo_index", -1))).is_equal(0)

	await get_tree().physics_frame
	await get_tree().process_frame
	assert_int(probe.physics_ticks).is_greater(ticks_before_hitstop)


func _stop_runtime_audio_players() -> void:
	var audio_system: Node = get_node_or_null("/root/AudioSystem")
	if audio_system == null:
		return
	for child: Node in audio_system.get_children():
		if child is AudioStreamPlayer2D:
			var audio_player := child as AudioStreamPlayer2D
			audio_player.stop()
			audio_player.stream = null
