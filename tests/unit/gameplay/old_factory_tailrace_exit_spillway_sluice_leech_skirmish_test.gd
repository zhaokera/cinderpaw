## Player Abilities Story126: Tailrace Exit Spillway Sluice Leech skirmish.
extends GdUnitTestSuite

const FACTORY_SCENE_PATH: String = "res://scenes/factory_route_transition_shell.tscn"
const CHARACTER_SCENE_PATH: String = "res://scenes/characters/factory_sluice_leech.tscn"
const RUNTIME_SCENE_PATH: String = "res://src/gameplay/factory_sluice_leech.tscn"
const SPRITE_FRAMES_PATH: String = (
	"res://assets/characters/factory_sluice_leech/"
	+ "factory_sluice_leech_sprite_frames.tres"
)
const FACTORY_PLAYER_NAME: String = "Player"
const SLUICE_LEECH_NODE_NAME: String = "FactoryTailraceExitSluiceLeech"
const SLUICE_LEECH_ENTITY_ID: int = 2146
const SLUICE_LEECH_ACTIVATION_X: float = 17360.0
const SLUICE_LEECH_POSITION: Vector2 = Vector2(17760.0, 482.0)
const SLUICE_LEECH_OPENING_GRACE_FRAMES: int = 18
const SLUICE_LEECH_ATTACK_STARTUP_FRAMES: int = 18
const REQUIRED_ANIMATIONS: Array[StringName] = [
	&"idle",
	&"run",
	&"attack_tell",
	&"attack",
	&"hurt",
	&"death",
]
const REQUIRED_FRAME_COUNT: int = 3
const REQUIRED_FRAME_SIZE: Vector2i = Vector2i(96, 96)
const FACTORY_SCENE_ID: StringName = &"area_03_factory"
const TAILRACE_RELAY_ID: String = (
	"old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_"
	+ "runoff_outlet_service_sluice_tailrace_relay"
)
const TAILRACE_RELAY_SPAWN_POINT: String = (
	"lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_"
	+ "outlet_service_sluice_tailrace_relay"
)
const DIAGNOSTICS_METHOD: StringName = (
	&"get_factory_tailrace_exit_sluice_leech_skirmish_diagnostics"
)
const ACTIVATE_METHOD: StringName = (
	&"try_activate_factory_tailrace_exit_sluice_leech_skirmish"
)
const STORY124_CROSSED_KEY: String = (
	"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_"
	+ "runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_"
	+ "spillway_crossed"
)
const STORY126_ACTIVATED_KEY: String = (
	"factory_tailrace_exit_sluice_leech_skirmish_activated"
)
const STORY126_DEFEATED_KEY: String = "factory_tailrace_exit_sluice_leech_defeated"
const STORY126_CLEARED_KEY: String = "factory_tailrace_exit_sluice_leech_skirmish_cleared"

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


func test_sluice_leech_character_assets_and_forward_lunge_contract() -> void:
	assert_bool(FileAccess.file_exists(CHARACTER_SCENE_PATH)).is_true()
	assert_bool(FileAccess.file_exists(RUNTIME_SCENE_PATH)).is_true()
	assert_bool(FileAccess.file_exists(SPRITE_FRAMES_PATH)).is_true()
	if (
		not FileAccess.file_exists(CHARACTER_SCENE_PATH)
		or not FileAccess.file_exists(RUNTIME_SCENE_PATH)
		or not FileAccess.file_exists(SPRITE_FRAMES_PATH)
	):
		return

	var frames: SpriteFrames = load(SPRITE_FRAMES_PATH) as SpriteFrames
	assert_that(frames).is_not_null()
	if frames == null:
		return
	for animation_name: StringName in REQUIRED_ANIMATIONS:
		assert_bool(frames.has_animation(animation_name)).is_true()
		if not frames.has_animation(animation_name):
			continue
		assert_int(frames.get_frame_count(animation_name)).is_equal(REQUIRED_FRAME_COUNT)
		for frame_index: int in range(REQUIRED_FRAME_COUNT):
			var frame_path: String = _frame_path(animation_name, frame_index)
			assert_bool(FileAccess.file_exists(frame_path)).is_true()
			if not FileAccess.file_exists(frame_path):
				continue
			var frame_image: Image = Image.new()
			var load_error: Error = frame_image.load_png_from_buffer(
				FileAccess.get_file_as_bytes(frame_path)
			)
			assert_int(load_error).is_equal(OK)
			if load_error != OK:
				continue
			assert_int(frame_image.get_width()).is_equal(REQUIRED_FRAME_SIZE.x)
			assert_int(frame_image.get_height()).is_equal(REQUIRED_FRAME_SIZE.y)
			assert_float(frame_image.get_pixel(0, 0).a).is_less_equal(0.01)
			assert_float(frame_image.get_pixel(95, 95).a).is_less_equal(0.01)

	var runtime_packed: PackedScene = load(RUNTIME_SCENE_PATH) as PackedScene
	assert_that(runtime_packed).is_not_null()
	if runtime_packed == null:
		return
	var enemy: CharacterBody2D = runtime_packed.instantiate() as CharacterBody2D
	assert_that(enemy).is_not_null()
	if enemy == null:
		return
	add_child(enemy)
	_spawned_nodes.append(enemy)
	enemy.set_physics_process(false)
	var sprite: AnimatedSprite2D = enemy.get_node_or_null("Sprite") as AnimatedSprite2D
	assert_that(sprite).is_not_null()
	assert_bool(enemy.has_method("get_enemy_family_id")).is_true()
	assert_bool(enemy.has_method("set_attack_target")).is_true()
	assert_bool(enemy.has_method("request_attack")).is_true()
	assert_bool(enemy.has_method("advance_attack_frames")).is_true()
	assert_bool(enemy.has_method("get_attack_startup_frames")).is_true()
	assert_bool(enemy.has_method("is_enemy_attack_active")).is_true()
	assert_bool(enemy.has_method("get_current_enemy_attack_metadata")).is_true()
	assert_bool(enemy.has_method("get_collision_component")).is_true()
	if (
		sprite == null
		or not enemy.has_method("set_attack_target")
		or not enemy.has_method("request_attack")
		or not enemy.has_method("advance_attack_frames")
		or not enemy.has_method("get_attack_startup_frames")
		or not enemy.has_method("is_enemy_attack_active")
	):
		return

	assert_str(String(enemy.call("get_enemy_family_id"))).is_equal(
		"factory_sluice_leech"
	)
	assert_int(int(enemy.call("get_attack_startup_frames"))).is_equal(
		SLUICE_LEECH_ATTACK_STARTUP_FRAMES
	)
	var attack_metadata: Dictionary = enemy.call("get_current_enemy_attack_metadata")
	assert_str(String(attack_metadata.get("weapon_id", ""))).is_equal(
		"factory_sluice_leech_lunge"
	)
	assert_that(enemy.call("get_collision_component")).is_not_null()
	var target: Node2D = Node2D.new()
	add_child(target)
	_spawned_nodes.append(target)
	target.global_position = enemy.global_position + Vector2(48.0, 0.0)
	enemy.call("set_attack_target", target)
	assert_bool(bool(enemy.call("request_attack"))).is_true()
	assert_str(String(sprite.animation)).is_equal("attack_tell")
	var before_lunge_x: float = enemy.global_position.x
	enemy.call("advance_attack_frames", SLUICE_LEECH_ATTACK_STARTUP_FRAMES - 1)
	assert_bool(bool(enemy.call("is_enemy_attack_active"))).is_false()
	assert_float(enemy.global_position.x).is_equal(before_lunge_x)
	enemy.call("advance_attack_frames", 1)
	assert_bool(bool(enemy.call("is_enemy_attack_active"))).is_true()
	enemy.call("advance_attack_frames", 1)
	assert_float(enemy.global_position.x).is_greater(before_lunge_x)
	assert_str(String(sprite.animation)).is_equal("attack")


func test_spillway_crossed_gates_sluice_leech_skirmish_and_restores_clear() -> void:
	var locked_scene: Node = _factory_scene_with_sluice_leech_state(false, false)
	assert_that(locked_scene).is_not_null()
	if locked_scene == null:
		return
	assert_bool(locked_scene.has_method(DIAGNOSTICS_METHOD)).is_true()
	assert_bool(locked_scene.has_method(ACTIVATE_METHOD)).is_true()
	if (
		not locked_scene.has_method(DIAGNOSTICS_METHOD)
		or not locked_scene.has_method(ACTIVATE_METHOD)
	):
		return
	var locked: Dictionary = locked_scene.call(DIAGNOSTICS_METHOD)
	assert_bool(bool(locked.get("present", false))).is_true()
	assert_bool(bool(locked.get("spillway_crossed", true))).is_false()
	assert_bool(bool(locked.get("available", true))).is_false()
	assert_bool(bool(locked.get("active", true))).is_false()
	assert_bool(bool(locked.get("enemy_visible", true))).is_false()
	assert_bool(bool(locked_scene.call(ACTIVATE_METHOD))).is_false()

	var ready_scene: Node = _factory_scene_with_sluice_leech_state(true, false)
	assert_that(ready_scene).is_not_null()
	if ready_scene == null:
		return
	var player: Node2D = ready_scene.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	assert_that(player).is_not_null()
	if player == null:
		return
	var ready: Dictionary = ready_scene.call(DIAGNOSTICS_METHOD)
	assert_bool(bool(ready.get("spillway_crossed", false))).is_true()
	assert_bool(bool(ready.get("available", false))).is_true()
	assert_bool(bool(ready.get("active", true))).is_false()
	assert_bool(bool(ready.get("cleared", true))).is_false()
	assert_bool(bool(ready.get("enemy_visible", true))).is_false()
	assert_str(String(ready.get("enemy_node_name", ""))).is_equal(SLUICE_LEECH_NODE_NAME)
	assert_int(int(ready.get("enemy_entity_id", 0))).is_equal(SLUICE_LEECH_ENTITY_ID)
	assert_float(float(ready.get("activation_x", 0.0))).is_equal(
		SLUICE_LEECH_ACTIVATION_X
	)
	assert_float(float(ready.get("right_wall_x", 0.0))).is_greater_equal(18120.0)
	assert_int(int(ready.get("camera_limit_right", 0))).is_greater_equal(18140)
	assert_float(float(ready.get("background_width", 0.0))).is_greater_equal(18140.0)
	assert_float(float(ready.get("ground_right_edge_x", 0.0))).is_greater_equal(18240.0)
	assert_int(int(ready.get("floor_tile_count", 0))).is_greater_equal(72)
	assert_str(String(ready.get("route_label_text", ""))).is_equal(
		"Tailrace Exit Spillway Crossed"
	)

	player.global_position.x = SLUICE_LEECH_ACTIVATION_X - 4.0
	assert_bool(bool(ready_scene.call(ACTIVATE_METHOD, player))).is_false()
	player.global_position.x = SLUICE_LEECH_ACTIVATION_X + 4.0
	assert_bool(bool(ready_scene.call(ACTIVATE_METHOD, player))).is_true()
	assert_bool(bool(ready_scene.call(ACTIVATE_METHOD, player))).is_false()
	var active: Dictionary = ready_scene.call(DIAGNOSTICS_METHOD)
	assert_bool(bool(active.get("active", false))).is_true()
	assert_bool(bool(active.get("enemy_visible", false))).is_true()
	assert_bool(bool(active.get("enemy_has_target", false))).is_true()
	assert_bool(bool(active.get("enemy_process_enabled", false))).is_true()
	assert_bool(bool(active.get("enemy_physics_enabled", false))).is_true()
	assert_int(int(active.get("enemy_entity_id", 0))).is_equal(SLUICE_LEECH_ENTITY_ID)
	assert_str(String(active.get("enemy_family_id", ""))).is_equal(
		"factory_sluice_leech"
	)
	assert_str(String(active.get("sprite_frames_path", ""))).is_equal(
		SPRITE_FRAMES_PATH
	)
	assert_int(int(active.get("opening_grace_frames", 0))).is_equal(
		SLUICE_LEECH_OPENING_GRACE_FRAMES
	)
	assert_str(String(active.get("route_label_text", ""))).is_equal(
		"Break Tailrace Sluice Leech"
	)
	_assert_animation_contract(active)
	var enemy_position: Vector2 = Vector2(active.get("enemy_position", Vector2.ZERO))
	assert_float(enemy_position.x).is_equal(SLUICE_LEECH_POSITION.x)
	assert_float(enemy_position.y).is_equal(SLUICE_LEECH_POSITION.y)

	assert_bool(bool(ready_scene.call("apply_damage", SLUICE_LEECH_ENTITY_ID, 999, {
		"source": &"unit_test_story126_sluice_leech",
	}))).is_true()
	await get_tree().process_frame
	var cleared: Dictionary = ready_scene.call(DIAGNOSTICS_METHOD)
	assert_bool(bool(cleared.get("active", true))).is_false()
	assert_bool(bool(cleared.get("cleared", false))).is_true()
	assert_bool(bool(cleared.get("enemy_visible", true))).is_false()
	assert_bool(bool(cleared.get("enemy_process_enabled", true))).is_false()
	assert_bool(bool(cleared.get("enemy_physics_enabled", true))).is_false()
	assert_str(String(cleared.get("route_label_text", ""))).is_equal(
		"Tailrace Sluice Leech Cleared"
	)
	var local_state: Dictionary = ready_scene.call("get_local_state")
	assert_bool(bool(local_state.get(STORY126_ACTIVATED_KEY, false))).is_true()
	assert_bool(bool(local_state.get(STORY126_DEFEATED_KEY, false))).is_true()
	assert_bool(bool(local_state.get(STORY126_CLEARED_KEY, false))).is_true()

	var restored: Node = _factory_scene_with_sluice_leech_state(false, true)
	assert_that(restored).is_not_null()
	if restored == null:
		return
	var restored_diagnostics: Dictionary = restored.call(DIAGNOSTICS_METHOD)
	assert_bool(bool(restored_diagnostics.get("spillway_crossed", false))).is_true()
	assert_bool(bool(restored_diagnostics.get("active", true))).is_false()
	assert_bool(bool(restored_diagnostics.get("cleared", false))).is_true()
	assert_bool(bool(restored_diagnostics.get("enemy_visible", true))).is_false()
	assert_str(String(restored_diagnostics.get("route_label_text", ""))).is_equal(
		"Tailrace Sluice Leech Cleared"
	)
	var spillway: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_"
		+ "runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_spillway_"
		+ "diagnostics"
	)
	assert_bool(bool(spillway.get("crossed", false))).is_true()
	assert_bool(bool(spillway.get("hazard_contact_active", true))).is_false()
	var last_savepoint: Dictionary = Dictionary(restored_diagnostics.get("last_savepoint", {}))
	assert_str(String(last_savepoint.get("id", ""))).is_equal(TAILRACE_RELAY_ID)
	assert_str(String(last_savepoint.get("scene_id", ""))).is_equal(String(FACTORY_SCENE_ID))
	assert_str(String(last_savepoint.get("spawn_point", ""))).is_equal(
		TAILRACE_RELAY_SPAWN_POINT
	)


func _assert_animation_contract(diagnostics: Dictionary) -> void:
	var animation_frames: Dictionary = Dictionary(diagnostics.get("animation_frames", {}))
	for animation_name: StringName in REQUIRED_ANIMATIONS:
		assert_int(int(animation_frames.get(String(animation_name), 0))).is_equal(
			REQUIRED_FRAME_COUNT
		)


func _factory_scene_with_sluice_leech_state(
	spillway_crossed: bool,
	story126_cleared: bool
) -> Node:
	var destination: Node = _instantiate_factory_scene()
	if destination == null:
		return null
	var state: Dictionary = {
		"last_return_checkpoint": _tailrace_relay_checkpoint_snapshot(),
	}
	if spillway_crossed:
		state[STORY124_CROSSED_KEY] = true
	if story126_cleared:
		state[STORY126_CLEARED_KEY] = true
	destination.call("set_local_state", state)
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


func _frame_path(animation_name: StringName, frame_index: int) -> String:
	return (
		"res://assets/characters/factory_sluice_leech/%s/"
		% String(animation_name)
		+ "factory_sluice_leech_%s_%03d.png" % [String(animation_name), frame_index]
	)


func _tailrace_relay_checkpoint_snapshot() -> Dictionary:
	return {
		"id": TAILRACE_RELAY_ID,
		"scene_id": String(FACTORY_SCENE_ID),
		"spawn_point": TAILRACE_RELAY_SPAWN_POINT,
		"position": Vector2(13480.0, 382.0),
	}


func _stop_runtime_audio_players() -> void:
	var audio_system: Node = get_node_or_null("/root/AudioSystem")
	if audio_system == null:
		return
	for child: Node in audio_system.get_children():
		if child is AudioStreamPlayer:
			(child as AudioStreamPlayer).stop()
