## Scene Management Story 021: Dash-only players secure a compact Sewer fight.
extends GdUnitTestSuite

const SEWER_SCENE_PATH: String = "res://scenes/areas/sewer.tscn"
const MOVE_RIGHT_ACTION: StringName = &"move_right"
const MOVE_LEFT_ACTION: StringName = &"move_left"
const ATTACK_ACTION: StringName = &"attack"
const MAIN_SCENE_ID: StringName = &"main"
const FACTORY_SCENE_ID: StringName = &"area_03_factory"
const INITIAL_CURRENCY: int = 7
const REWARD_GEARS: int = 15
const REQUIRED_ENEMY_ANIMATIONS: Array[StringName] = [
	&"idle",
	&"run",
	&"attack_tell",
	&"attack",
	&"hurt",
	&"death",
]

var _roots: Array[Node2D] = []


class FakeSceneManager:
	extends RefCounted

	var requests: Array[Dictionary] = []
	var scene_states: Dictionary = {}

	func has_scene(scene_id: StringName) -> bool:
		return scene_id == MAIN_SCENE_ID

	func is_loading() -> bool:
		return false

	func request_scene_change(
		scene_id: StringName,
		spawn_point: StringName
	) -> bool:
		if not has_scene(scene_id):
			return false
		requests.append({
			"scene_id": String(scene_id),
			"spawn_point": String(spawn_point),
		})
		return true

	func get_scene_state(scene_id: StringName) -> Dictionary:
		return Dictionary(scene_states.get(String(scene_id), {})).duplicate(true)

	func set_scene_state(scene_id: StringName, state: Dictionary) -> void:
		scene_states[String(scene_id)] = state.duplicate(true)


func after_test() -> void:
	_release_actions()
	for root: Node2D in _roots:
		if not is_instance_valid(root):
			continue
		if root.get_parent() != null:
			root.get_parent().remove_child(root)
		root.free()
	_roots.clear()


func test_dash_only_player_secures_persistent_sewer_depth_without_unlocking_factory() -> void:
	var packed_scene: PackedScene = load(SEWER_SCENE_PATH) as PackedScene
	assert_object(packed_scene).is_not_null()
	if packed_scene == null:
		return

	var sewer: Node2D = _instantiate_sewer(packed_scene)
	assert_object(sewer).is_not_null()
	if sewer == null:
		return
	var scene_manager := FakeSceneManager.new()
	assert_bool(bool(sewer.call(
		"configure_scene_manager_runtime",
		scene_manager
	))).is_true()
	sewer.call("set_local_state", {
		"unlocked_abilities": ["dash"],
		"dash_crossed": true,
		"successful_dash_crossings": 1,
		"currency": INITIAL_CURRENCY,
	})
	await _wait_physics_frames(2)

	# Intentional RED boundary: the test fails here until Story021 exists.
	assert_bool(sewer.has_method("get_sewer_act_depth_diagnostics")).is_true()
	if not sewer.has_method("get_sewer_act_depth_diagnostics"):
		return

	var player: PlayerController = sewer.get_node_or_null("Player") as PlayerController
	assert_object(player).is_not_null()
	if player == null:
		return
	assert_bool(player.has_ability(&"dash")).is_true()
	assert_bool(player.has_ability(&"double_jump")).is_false()

	var initial: Dictionary = _depth_diagnostics(sewer)
	assert_str(String(initial.get("encounter_state", ""))).is_equal("ready")
	assert_int(int(initial.get("active_enemy_count", -1))).is_equal(0)
	assert_bool(bool(initial.get("room_seal_blocking", false))).is_true()
	assert_bool(bool(initial.get("reward_available", true))).is_false()
	assert_bool(bool(initial.get("reward_claimed", true))).is_false()
	assert_int(int(initial.get("currency", -1))).is_equal(INITIAL_CURRENCY)
	assert_bool(bool(initial.get("player_has_double_jump", true))).is_false()
	assert_str(String(initial.get("background_texture_path", ""))).is_equal(
		"res://assets/environment/sewer_pressure_chamber/"
		+ "sewer_pressure_chamber_background_1280x720.png"
	)

	assert_bool(await _move_until_encounter_active(sewer)).is_true()
	var enemy: Node2D = sewer.get_node_or_null("SewerSluiceLeech") as Node2D
	assert_object(enemy).is_not_null()
	if enemy == null:
		return
	var activated: Dictionary = _depth_diagnostics(sewer)
	assert_int(int(activated.get("active_enemy_count", 0))).is_equal(1)
	assert_bool(bool(activated.get("room_seal_blocking", false))).is_true()
	assert_bool(enemy.visible).is_true()
	_assert_enemy_frame_contract(enemy)

	assert_bool(bool(enemy.call("request_attack"))).is_true()
	await get_tree().physics_frame
	var enemy_sprite: AnimatedSprite2D = (
		enemy.get_node_or_null("Sprite") as AnimatedSprite2D
	)
	assert_object(enemy_sprite).is_not_null()
	if enemy_sprite != null:
		assert_str(String(enemy_sprite.animation)).is_equal("attack_tell")

	assert_bool(await _defeat_enemy_with_real_attack_input(player, enemy)).is_true()
	await _wait_physics_frames(2)
	var cleared: Dictionary = _depth_diagnostics(sewer)
	assert_str(String(cleared.get("encounter_state", ""))).is_equal("cleared")
	assert_int(int(cleared.get("active_enemy_count", -1))).is_equal(0)
	assert_bool(bool(cleared.get("room_seal_blocking", true))).is_false()
	assert_bool(bool(cleared.get("reward_available", false))).is_true()
	assert_int(int(cleared.get("kill_feedback_count", 0))).is_equal(1)
	assert_array(scene_manager.requests).is_empty()

	assert_bool(await _move_until_reward_claimed(sewer)).is_true()
	var claimed: Dictionary = _depth_diagnostics(sewer)
	assert_bool(bool(claimed.get("reward_claimed", false))).is_true()
	assert_int(int(claimed.get("reward_claim_count", 0))).is_equal(1)
	assert_int(int(claimed.get("currency", -1))).is_equal(
		INITIAL_CURRENCY + REWARD_GEARS
	)
	var cache: Node = sewer.get_node_or_null("SewerPressureCache")
	assert_object(cache).is_not_null()
	if cache != null:
		assert_bool(bool(cache.call("try_claim", player))).is_false()
	assert_int(int(_depth_diagnostics(sewer).get("currency", -1))).is_equal(
		INITIAL_CURRENCY + REWARD_GEARS
	)

	assert_bool(await _move_until_main_return(sewer, scene_manager)).is_true()
	assert_array(scene_manager.requests).is_equal([{
		"scene_id": "main",
		"spawn_point": "sewer_return",
	}])
	for request: Dictionary in scene_manager.requests:
		assert_str(String(request.get("scene_id", ""))).is_not_equal(
			String(FACTORY_SCENE_ID)
		)
	var main_state: Dictionary = scene_manager.get_scene_state(MAIN_SCENE_ID)
	var world_flags: Dictionary = Dictionary(main_state.get("world_flags", {}))
	assert_bool(bool(world_flags.get("sewer_pressure_ambush_cleared", false))).is_true()
	assert_bool(bool(world_flags.get("sewer_pressure_cache_claimed", false))).is_true()
	assert_bool(bool(world_flags.get("area_03_factory_unlocked", false))).is_false()
	assert_int(int(main_state.get("currency", -1))).is_equal(
		INITIAL_CURRENCY + REWARD_GEARS
	)

	var saved_state: Dictionary = Dictionary(sewer.call("get_local_state"))
	var cold_sewer: Node2D = _instantiate_sewer(packed_scene)
	assert_object(cold_sewer).is_not_null()
	if cold_sewer == null:
		return
	cold_sewer.call("set_local_state", saved_state)
	await _wait_physics_frames(2)
	var restored: Dictionary = _depth_diagnostics(cold_sewer)
	assert_str(String(restored.get("encounter_state", ""))).is_equal("cleared")
	assert_int(int(restored.get("active_enemy_count", -1))).is_equal(0)
	assert_bool(bool(restored.get("reward_claimed", false))).is_true()
	assert_int(int(restored.get("reward_claim_count", 0))).is_equal(1)
	assert_int(int(restored.get("currency", -1))).is_equal(
		INITIAL_CURRENCY + REWARD_GEARS
	)
	assert_bool(bool(restored.get("transition_requested", true))).is_false()
	assert_bool(bool(restored.get("player_has_double_jump", true))).is_false()


func _instantiate_sewer(packed_scene: PackedScene) -> Node2D:
	var root: Node2D = packed_scene.instantiate() as Node2D
	if root == null:
		return null
	root.set("auto_configure_runtime_services", false)
	add_child(root)
	_roots.append(root)
	return root


func _move_until_encounter_active(sewer: Node) -> bool:
	Input.action_press(MOVE_RIGHT_ACTION)
	for _frame: int in range(480):
		await get_tree().physics_frame
		if int(_depth_diagnostics(sewer).get("active_enemy_count", 0)) == 1:
			Input.action_release(MOVE_RIGHT_ACTION)
			return true
	Input.action_release(MOVE_RIGHT_ACTION)
	return false


func _defeat_enemy_with_real_attack_input(
	player: PlayerController,
	enemy: Node2D
) -> bool:
	for _attempt: int in range(8):
		if not is_instance_valid(enemy) or int(enemy.call("get_current_hp")) <= 0:
			return true
		if not await _move_player_into_attack_range(player, enemy):
			return false
		Input.action_press(ATTACK_ACTION)
		await get_tree().physics_frame
		Input.action_release(ATTACK_ACTION)
		await _wait_physics_frames(16)
	return not is_instance_valid(enemy) or int(enemy.call("get_current_hp")) <= 0


func _move_player_into_attack_range(
	player: PlayerController,
	enemy: Node2D
) -> bool:
	for _frame: int in range(180):
		if not is_instance_valid(enemy):
			return false
		var delta_x: float = enemy.global_position.x - player.global_position.x
		if absf(delta_x) <= 42.0:
			_release_horizontal_actions()
			return true
		var move_action: StringName = MOVE_RIGHT_ACTION if delta_x > 0.0 else MOVE_LEFT_ACTION
		var release_action: StringName = MOVE_LEFT_ACTION if delta_x > 0.0 else MOVE_RIGHT_ACTION
		Input.action_press(move_action)
		Input.action_release(release_action)
		await get_tree().physics_frame
	_release_horizontal_actions()
	return is_instance_valid(enemy) and absf(
		enemy.global_position.x - player.global_position.x
	) <= 46.0


func _move_until_reward_claimed(sewer: Node) -> bool:
	Input.action_press(MOVE_RIGHT_ACTION)
	for _frame: int in range(360):
		await get_tree().physics_frame
		if bool(_depth_diagnostics(sewer).get("reward_claimed", false)):
			Input.action_release(MOVE_RIGHT_ACTION)
			return true
	Input.action_release(MOVE_RIGHT_ACTION)
	return false


func _move_until_main_return(
	sewer: Node,
	scene_manager: FakeSceneManager
) -> bool:
	Input.action_press(MOVE_RIGHT_ACTION)
	for _frame: int in range(360):
		await get_tree().physics_frame
		if not scene_manager.requests.is_empty():
			Input.action_release(MOVE_RIGHT_ACTION)
			return bool(_depth_diagnostics(sewer).get("transition_requested", false))
	Input.action_release(MOVE_RIGHT_ACTION)
	return false


func _assert_enemy_frame_contract(enemy: Node2D) -> void:
	var sprite: AnimatedSprite2D = enemy.get_node_or_null("Sprite") as AnimatedSprite2D
	assert_object(sprite).is_not_null()
	if sprite == null or sprite.sprite_frames == null:
		return
	for animation_name: StringName in REQUIRED_ENEMY_ANIMATIONS:
		assert_bool(sprite.sprite_frames.has_animation(animation_name)).is_true()
		assert_int(sprite.sprite_frames.get_frame_count(animation_name)).is_greater_equal(3)


func _depth_diagnostics(sewer: Node) -> Dictionary:
	return Dictionary(sewer.call("get_sewer_act_depth_diagnostics"))


func _wait_physics_frames(frame_count: int) -> void:
	for _frame: int in range(frame_count):
		await get_tree().physics_frame


func _release_horizontal_actions() -> void:
	Input.action_release(MOVE_LEFT_ACTION)
	Input.action_release(MOVE_RIGHT_ACTION)


func _release_actions() -> void:
	_release_horizontal_actions()
	Input.action_release(ATTACK_ACTION)
