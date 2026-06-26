## Runtime feedback contract for ExplorationGate unlock VFX and SFX.
extends GdUnitTestSuite

const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")
const VFX_TEXTURE_PATH: String = "res://assets/environment/ability_gate/vfx/vfx_ability_gate_unlock_dissolve_burst_256.png"
const DASH_ABILITY: StringName = &"dash"
const DOUBLE_JUMP_ABILITY: StringName = &"double_jump"
const DASH_GATE_ID: StringName = &"dash_gate_commercial_street"
const DOUBLE_JUMP_GATE_ID: StringName = &"double_jump_high_platform"
const DASH_TARGET_AREA_ID: StringName = &"area_02_sewer"
const DOUBLE_JUMP_TARGET_AREA_ID: StringName = &"area_03_factory"
const STATE_UNLOCKABLE: StringName = &"unlockable"
const STATE_UNLOCKED: StringName = &"unlocked"

var _nodes_to_free: Array[Node] = []


class FakeGateAudioSystem:
	extends RefCounted

	var load_started_calls: Array[Dictionary] = []
	var gate_unlock_events: Array[Dictionary] = []

	func on_scene_load_started(
		scene_id: StringName,
		spawn_point: StringName,
		metadata: Dictionary
	) -> void:
		load_started_calls.append({
			"scene_id": scene_id,
			"spawn_point": spawn_point,
			"metadata": metadata.duplicate(true),
		})

	func on_exploration_gate_unlocked(
		gate_id: StringName,
		required_ability: StringName,
		target_area_id: StringName,
		world_position: Vector2,
		metadata: Dictionary
	) -> bool:
		gate_unlock_events.append({
			"gate_id": gate_id,
			"required_ability": required_ability,
			"target_area_id": target_area_id,
			"world_position": world_position,
			"metadata": metadata.duplicate(true),
		})
		return true


func after_test() -> void:
	for node: Node in _nodes_to_free:
		if is_instance_valid(node):
			if node.get_parent() != null:
				node.get_parent().remove_child(node)
			node.free()
	_nodes_to_free.clear()


func test_dash_gate_unlock_spawns_generated_vfx_and_routes_audio_once() -> void:
	assert_bool(FileAccess.file_exists(VFX_TEXTURE_PATH)).is_true()
	var scene := _create_main_scene()
	var audio_system := FakeGateAudioSystem.new()
	assert_bool(bool(scene.call("configure_audio_system_runtime", audio_system))).is_true()

	var gate: Node = scene.get_node_or_null("DashExplorationGate")
	assert_that(gate).is_not_null()
	assert_gate_feedback_api(gate)
	if gate == null or not gate.has_method("get_unlock_feedback_snapshot"):
		return

	scene.call("unlock_ability", DASH_ABILITY)
	assert_str(String(gate.call("get_gate_state"))).is_equal(String(STATE_UNLOCKABLE))
	var player := scene.get_node("Player") as PlayerController
	player.global_position = (gate as Node2D).global_position + Vector2(-48, 0)
	assert_bool(player.request_dash()).is_true()

	assert_str(String(gate.call("get_gate_state"))).is_equal(String(STATE_UNLOCKED))
	assert_bool(bool(gate.call("is_collision_blocking"))).is_false()
	var snapshot: Dictionary = Dictionary(gate.call("get_unlock_feedback_snapshot"))
	assert_unlock_feedback_snapshot(
		snapshot,
		DASH_GATE_ID,
		DASH_ABILITY,
		DASH_TARGET_AREA_ID,
		1,
		1
	)
	_assert_unlock_vfx_node_is_generated_sprite(gate)
	assert_int(audio_system.gate_unlock_events.size()).is_equal(1)
	assert_gate_audio_event(
		audio_system.gate_unlock_events[0],
		DASH_GATE_ID,
		DASH_ABILITY,
		DASH_TARGET_AREA_ID,
		(gate as Node2D).global_position
	)

	gate.call("refresh_gate_state")
	gate.call("unlock_gate")
	assert_unlock_feedback_snapshot(
		Dictionary(gate.call("get_unlock_feedback_snapshot")),
		DASH_GATE_ID,
		DASH_ABILITY,
		DASH_TARGET_AREA_ID,
		1,
		1
	)
	assert_int(audio_system.gate_unlock_events.size()).is_equal(1)

	gate.call("advance_unlock_feedback_time", 0.6)
	var expired_snapshot: Dictionary = Dictionary(gate.call("get_unlock_feedback_snapshot"))
	assert_int(int(expired_snapshot.get("active_count", -1))).is_equal(0)
	assert_int(int(expired_snapshot.get("spawn_count", -1))).is_equal(1)


func test_double_jump_gate_unlock_uses_same_generated_feedback_contract() -> void:
	assert_bool(FileAccess.file_exists(VFX_TEXTURE_PATH)).is_true()
	var scene := _create_main_scene()
	var audio_system := FakeGateAudioSystem.new()
	assert_bool(bool(scene.call("configure_audio_system_runtime", audio_system))).is_true()

	var gate: Node = scene.get_node_or_null("DoubleJumpExplorationGate")
	assert_that(gate).is_not_null()
	assert_gate_feedback_api(gate)
	if gate == null or not gate.has_method("get_unlock_feedback_snapshot"):
		return

	scene.call("unlock_ability", DOUBLE_JUMP_ABILITY)
	var player := scene.get_node("Player") as PlayerController
	player.global_position = (gate as Node2D).global_position + Vector2(-48, 0)
	player.call("set_airborne", true)
	assert_bool(bool(player.call("request_double_jump"))).is_true()

	assert_str(String(gate.call("get_gate_state"))).is_equal(String(STATE_UNLOCKED))
	assert_bool(bool(gate.call("is_collision_blocking"))).is_false()
	var snapshot: Dictionary = Dictionary(gate.call("get_unlock_feedback_snapshot"))
	assert_unlock_feedback_snapshot(
		snapshot,
		DOUBLE_JUMP_GATE_ID,
		DOUBLE_JUMP_ABILITY,
		DOUBLE_JUMP_TARGET_AREA_ID,
		1,
		1
	)
	_assert_unlock_vfx_node_is_generated_sprite(gate)
	assert_int(audio_system.gate_unlock_events.size()).is_equal(1)
	assert_gate_audio_event(
		audio_system.gate_unlock_events[0],
		DOUBLE_JUMP_GATE_ID,
		DOUBLE_JUMP_ABILITY,
		DOUBLE_JUMP_TARGET_AREA_ID,
		(gate as Node2D).global_position
	)


func test_restored_unlocked_gates_do_not_replay_vfx_or_sfx() -> void:
	var scene := _create_main_scene()
	scene.call("unlock_ability", DASH_ABILITY)
	scene.call("unlock_ability", DOUBLE_JUMP_ABILITY)
	var player := scene.get_node("Player") as PlayerController
	var dash_gate: Node = scene.get_node("DashExplorationGate")
	var double_jump_gate: Node = scene.get_node("DoubleJumpExplorationGate")

	player.global_position = (dash_gate as Node2D).global_position + Vector2(-48, 0)
	assert_bool(player.request_dash()).is_true()
	double_jump_gate.call("unlock_gate")

	var snapshot: Dictionary = scene.call("capture_save_snapshot")
	var restored_scene := _create_main_scene()
	var audio_system := FakeGateAudioSystem.new()
	assert_bool(bool(restored_scene.call("configure_audio_system_runtime", audio_system))).is_true()
	restored_scene.call("restore_save_snapshot", snapshot)

	for gate_name: String in ["DashExplorationGate", "DoubleJumpExplorationGate"]:
		var restored_gate: Node = restored_scene.get_node_or_null(gate_name)
		assert_that(restored_gate).is_not_null()
		assert_gate_feedback_api(restored_gate)
		if restored_gate == null or not restored_gate.has_method("get_unlock_feedback_snapshot"):
			return
		assert_str(String(restored_gate.call("get_gate_state"))).is_equal(String(STATE_UNLOCKED))
		assert_bool(bool(restored_gate.call("is_collision_blocking"))).is_false()
		var gate_snapshot: Dictionary = Dictionary(restored_gate.call("get_unlock_feedback_snapshot"))
		assert_int(int(gate_snapshot.get("active_count", -1))).is_equal(0)
		assert_int(int(gate_snapshot.get("spawn_count", -1))).is_equal(0)
	assert_int(audio_system.gate_unlock_events.size()).is_equal(0)


func assert_gate_feedback_api(gate: Node) -> void:
	assert_bool(gate.has_method("get_unlock_feedback_snapshot")).is_true()
	assert_bool(gate.has_method("advance_unlock_feedback_time")).is_true()


func assert_unlock_feedback_snapshot(
	snapshot: Dictionary,
	gate_id: StringName,
	required_ability: StringName,
	target_area_id: StringName,
	active_count: int,
	spawn_count: int
) -> void:
	assert_str(String(snapshot.get("texture_path", ""))).is_equal(VFX_TEXTURE_PATH)
	assert_str(String(snapshot.get("asset_source", ""))).is_equal("image_generation")
	assert_int(int(snapshot.get("active_count", -1))).is_equal(active_count)
	assert_int(int(snapshot.get("spawn_count", -1))).is_equal(spawn_count)
	var last_spawn: Dictionary = Dictionary(snapshot.get("last_spawn", {}))
	assert_str(String(last_spawn.get("gate_id", &""))).is_equal(String(gate_id))
	assert_str(String(last_spawn.get("required_ability", &""))).is_equal(String(required_ability))
	assert_str(String(last_spawn.get("target_area_id", &""))).is_equal(String(target_area_id))
	assert_str(String(last_spawn.get("asset_source", ""))).is_equal("image_generation")
	assert_bool(last_spawn.has("world_position")).is_true()


func assert_gate_audio_event(
	event: Dictionary,
	gate_id: StringName,
	required_ability: StringName,
	target_area_id: StringName,
	world_position: Vector2
) -> void:
	assert_str(String(event.get("gate_id", &""))).is_equal(String(gate_id))
	assert_str(String(event.get("required_ability", &""))).is_equal(String(required_ability))
	assert_str(String(event.get("target_area_id", &""))).is_equal(String(target_area_id))
	assert_vector(event.get("world_position", Vector2.ZERO)).is_equal(world_position)
	var metadata: Dictionary = Dictionary(event.get("metadata", {}))
	assert_str(String(metadata.get("gate_id", &""))).is_equal(String(gate_id))
	assert_str(String(metadata.get("required_ability", &""))).is_equal(String(required_ability))
	assert_str(String(metadata.get("target_area_id", &""))).is_equal(String(target_area_id))


func _assert_unlock_vfx_node_is_generated_sprite(gate: Node) -> void:
	var vfx: Node = gate.get_node_or_null("UnlockVfx")
	assert_that(vfx).is_not_null()
	assert_bool(vfx is Sprite2D).is_true()
	assert_bool(vfx is ColorRect).is_false()
	assert_bool(vfx is Polygon2D).is_false()
	if vfx is Sprite2D:
		var sprite := vfx as Sprite2D
		assert_object(sprite.texture).is_not_null()
		if sprite.texture != null:
			assert_str(sprite.texture.resource_path).is_equal(VFX_TEXTURE_PATH)
		assert_str(String(sprite.get_meta("asset_source", ""))).is_equal("image_generation")


func _create_main_scene() -> Node2D:
	var scene := MAIN_SCENE.instantiate() as Node2D
	add_child(scene)
	_nodes_to_free.append(scene)
	return scene
