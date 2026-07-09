## Runtime contract for Dash-required exploration gates in the main scene.
extends GdUnitTestSuite

const GATE_SCRIPT_PATH: String = "res://src/feature/exploration_gate.gd"
const PLAYER_SCENE: PackedScene = preload("res://scenes/player.tscn")
const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")
const DASH_ABILITY: StringName = &"dash"
const GATE_ID: StringName = &"dash_gate_commercial_street"
const STATE_LOCKED: StringName = &"locked"
const STATE_UNLOCKABLE: StringName = &"unlockable"
const STATE_UNLOCKED: StringName = &"unlocked"
const GATE_UNLOCK_RADIUS: float = 96.0

var _nodes_to_free: Array[Node] = []


func after_test() -> void:
	for node: Node in _nodes_to_free:
		if is_instance_valid(node):
			if node.get_parent() != null:
				node.get_parent().remove_child(node)
			node.free()
	_nodes_to_free.clear()


func test_exploration_gate_requires_dash_then_unlocks_on_dash_activation() -> void:
	assert_bool(ResourceLoader.exists(GATE_SCRIPT_PATH)).is_true()
	if not ResourceLoader.exists(GATE_SCRIPT_PATH):
		return

	var player := PLAYER_SCENE.instantiate() as PlayerController
	var gate := _create_gate_fixture()
	add_child(player)
	add_child(gate)
	_nodes_to_free.append(player)
	_nodes_to_free.append(gate)
	player.global_position = gate.global_position + Vector2(-240, 0)

	gate.call("set_ability_provider", player)
	var prompt := gate.get_node("PromptLabel") as Label
	gate.call("refresh_gate_state")
	assert_str(String(gate.call("get_gate_state"))).is_equal(String(STATE_LOCKED))
	assert_bool(bool(gate.call("is_collision_blocking"))).is_true()
	assert_bool(bool(gate.call("is_unlocked"))).is_false()
	assert_str(prompt.text).is_equal("Requires Dash")
	assert_bool(prompt.visible).is_false()

	assert_bool(player.unlock_ability(DASH_ABILITY)).is_true()
	assert_str(String(gate.call("get_gate_state"))).is_equal(String(STATE_UNLOCKABLE))
	assert_bool(bool(gate.call("is_collision_blocking"))).is_true()
	assert_str(prompt.text).is_equal("Dash through")
	assert_bool(bool(gate.call("is_provider_in_unlock_range"))).is_false()
	assert_bool(prompt.visible).is_false()

	player.global_position = gate.global_position + Vector2(-160, 0)
	gate.call("refresh_gate_state")
	assert_bool(bool(gate.call("is_provider_in_unlock_range"))).is_false()
	assert_bool(prompt.visible).is_true()

	player.global_position = gate.global_position + Vector2(-48, 0)
	assert_bool(bool(gate.call("is_provider_in_unlock_range"))).is_true()
	assert_bool(player.request_dash()).is_true()
	assert_str(String(gate.call("get_gate_state"))).is_equal(String(STATE_UNLOCKED))
	assert_bool(bool(gate.call("is_collision_blocking"))).is_false()
	assert_bool(bool(gate.call("is_unlocked"))).is_true()
	assert_bool(prompt.visible).is_false()


func test_main_scene_dash_gate_uses_runtime_dash_reward_and_persists_unlock() -> void:
	var scene := MAIN_SCENE.instantiate() as Node2D
	add_child(scene)
	_nodes_to_free.append(scene)

	var gate: Node = scene.get_node_or_null("DashExplorationGate")
	assert_that(gate).is_not_null()
	if gate == null:
		return
	assert_str(String(gate.call("get_gate_id"))).is_equal(String(GATE_ID))
	assert_str(String(gate.call("get_required_ability"))).is_equal(String(DASH_ABILITY))
	assert_str(String(gate.call("get_gate_state"))).is_equal(String(STATE_LOCKED))
	assert_bool(bool(gate.call("is_collision_blocking"))).is_true()
	assert_bool(bool(gate.call("is_prompt_visible"))).is_false()

	scene.call("unlock_ability", DASH_ABILITY)
	assert_str(String(gate.call("get_gate_state"))).is_equal(String(STATE_UNLOCKABLE))
	assert_bool(bool(gate.call("is_collision_blocking"))).is_true()
	assert_bool(bool(gate.call("is_prompt_visible"))).is_false()

	var player := scene.get_node("Player") as PlayerController
	player.global_position = (gate as Node2D).global_position + Vector2(-160, 0)
	gate.call("refresh_gate_state")
	assert_bool(bool(gate.call("is_provider_in_unlock_range"))).is_false()
	assert_bool(bool(gate.call("is_prompt_visible"))).is_true()

	player.global_position = (gate as Node2D).global_position + Vector2(-48, 0)
	assert_bool(player.request_dash()).is_true()
	assert_str(String(gate.call("get_gate_state"))).is_equal(String(STATE_UNLOCKED))
	assert_bool(bool(gate.call("is_collision_blocking"))).is_false()

	var snapshot: Dictionary = scene.call("capture_save_snapshot")
	var world_state: Dictionary = Dictionary(snapshot.get("world_state", {}))
	var gate_state: Dictionary = Dictionary(world_state.get("exploration_gates", {}))
	assert_array(Array(gate_state.get("unlocked", []))).contains(String(GATE_ID))
	var world_flags: Dictionary = Dictionary(world_state.get("world_flags", {}))
	assert_bool(bool(world_flags.get("gate_%s_unlocked" % String(GATE_ID), false))).is_true()
	assert_bool(bool(world_flags.get("area_02_sewer_unlocked", false))).is_true()

	var restored_scene := MAIN_SCENE.instantiate() as Node2D
	add_child(restored_scene)
	_nodes_to_free.append(restored_scene)
	restored_scene.call("restore_save_snapshot", snapshot)
	var restored_gate: Node = restored_scene.get_node_or_null("DashExplorationGate")
	assert_that(restored_gate).is_not_null()
	if restored_gate == null:
		return
	assert_str(String(restored_gate.call("get_gate_state"))).is_equal(String(STATE_UNLOCKED))
	assert_bool(bool(restored_gate.call("is_collision_blocking"))).is_false()


func _create_gate_fixture() -> Node2D:
	var script := load(GATE_SCRIPT_PATH) as Script
	var gate := Node2D.new()
	gate.name = "DashExplorationGate"
	gate.set_script(script)
	gate.set("gate_id", String(GATE_ID))
	gate.set("required_ability", String(DASH_ABILITY))
	gate.set("target_area_id", "area_02_sewer")
	gate.set("unlock_radius_px", GATE_UNLOCK_RADIUS)

	var body := StaticBody2D.new()
	body.name = "StaticBody2D"
	var collision := CollisionShape2D.new()
	collision.name = "CollisionShape2D"
	var shape := RectangleShape2D.new()
	shape.size = Vector2(48, 96)
	collision.shape = shape
	body.add_child(collision)
	gate.add_child(body)

	var visual := ColorRect.new()
	visual.name = "Visual"
	visual.size = Vector2(48, 96)
	gate.add_child(visual)

	var prompt := Label.new()
	prompt.name = "PromptLabel"
	gate.add_child(prompt)
	return gate
