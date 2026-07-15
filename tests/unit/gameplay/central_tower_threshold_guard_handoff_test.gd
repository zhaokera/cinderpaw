## Player Abilities Story140: Central Tower threshold guard and scene handoff.
extends GdUnitTestSuite

const ROOFTOPS_SCENE_PATH: String = "res://scenes/areas/neon_rooftops_entry.tscn"
const TOWER_SCENE_PATH: String = "res://scenes/areas/central_tower_threshold.tscn"
const TOWER_SCENE_SCRIPT_PATH: String = (
	"res://src/gameplay/central_tower_threshold_scene.gd"
)
const GUARD_CONTROLLER_SCRIPT_PATH: String = (
	"res://src/gameplay/central_tower_threshold_guard_controller.gd"
)
const GUARD_GAMEPLAY_SCRIPT_PATH: String = (
	"res://src/gameplay/central_tower_threshold_guard.gd"
)
const GUARD_GAMEPLAY_SCENE_PATH: String = (
	"res://src/gameplay/central_tower_threshold_guard.tscn"
)
const GUARD_CHARACTER_SCRIPT_PATH: String = (
	"res://src/characters/central_tower_threshold_guard.gd"
)
const GUARD_CHARACTER_SCENE_PATH: String = (
	"res://scenes/characters/central_tower_threshold_guard.tscn"
)
const GUARD_FRAMES_PATH: String = (
	"res://assets/characters/central_tower_threshold_guard/"
	+ "central_tower_threshold_guard_sprite_frames.tres"
)
const BACKGROUND_PATH: String = (
	"res://assets/environment/central_tower/"
	+ "env_central_tower_threshold_1280x720.png"
)
const SEAL_PATH: String = (
	"res://assets/environment/central_tower/"
	+ "prop_central_tower_inner_seal_384x512.png"
)
const GUARD_DOCK_PATH: String = (
	"res://assets/environment/central_tower/"
	+ "prop_central_tower_guard_dock_256x256.png"
)
const THRESHOLD_ROOST_PATH: String = (
	"res://assets/environment/central_tower/"
	+ "prop_central_tower_threshold_roost_256x256.png"
)
const REGISTRY_PATH: String = "res://data/scene_registry.json"
const REGISTRY_SCHEMA_PATH: String = "res://data/schemas/scene_registry.schema.json"
const ENEMY_STATS_PATH: String = "res://data/combat/enemy_stats.json"
const ENEMY_STATS_SCHEMA_PATH: String = "res://data/schemas/enemy_stats.schema.json"

const ROOFTOPS_SCENE_ID: StringName = &"area_05_neon_rooftops"
const TOWER_SCENE_ID: StringName = &"area_05_central_tower"
const TOWER_ENTRY_SPAWN: StringName = &"neon_rooftops_threshold_arrival"
const ROOFTOPS_RETURN_SPAWN: StringName = &"central_tower_threshold_return"
const GUARD_CONFIG_ID: StringName = &"central_tower_threshold_guard"
const GUARD_ENTITY_ID: int = 2701
const GUARD_ATTACK_HITBOX_ID: StringName = &"central_tower_guard_latch_thrust"
const GUARD_ACTIVATION_X: float = 420.0
const EXPECTED_GUARD_HP: int = 48
const EXPECTED_GUARD_DAMAGE: int = 14
const EXPECTED_STARTUP_FRAMES: int = 24
const REQUIRED_ANIMATIONS: Array[StringName] = [
	&"idle",
	&"run",
	&"attack_tell",
	&"attack",
	&"hurt",
	&"death",
]

var _spawned_nodes: Array[Node] = []


class FakeSceneManager:
	extends RefCounted

	signal on_scene_load_failed(scene_id: StringName, reason: StringName)

	var request_calls: Array[Dictionary] = []
	var scene_states: Dictionary = {}
	var loading: bool = false
	var locked: bool = false
	var tower_known: bool = true
	var current_scene: StringName = ROOFTOPS_SCENE_ID
	var current_spawn: StringName = &"factory_rooftop_arrival"

	func has_scene(scene_id: StringName) -> bool:
		if scene_id == TOWER_SCENE_ID:
			return tower_known
		return scene_id in [ROOFTOPS_SCENE_ID, &"area_03_factory_upper_altar"]

	func get_current_scene() -> StringName:
		return current_scene

	func get_current_spawn_point() -> StringName:
		return current_spawn

	func is_loading() -> bool:
		return loading

	func is_scene_locked() -> bool:
		return locked

	func get_pending_scene() -> StringName:
		if request_calls.is_empty():
			return &""
		return StringName(String(request_calls[-1].get("scene_id", "")))

	func get_pending_spawn_point() -> StringName:
		if request_calls.is_empty():
			return &""
		return StringName(String(request_calls[-1].get("spawn_point", "")))

	func get_scene_state(scene_id: StringName) -> Dictionary:
		return Dictionary(scene_states.get(String(scene_id), {})).duplicate(true)

	func set_scene_state(scene_id: StringName, state: Dictionary) -> bool:
		scene_states[String(scene_id)] = state.duplicate(true)
		return true

	func request_scene_change(
		scene_id: StringName,
		spawn_point: StringName = &"default"
	) -> bool:
		if loading or locked or not has_scene(scene_id):
			return false
		request_calls.append({
			"scene_id": String(scene_id),
			"spawn_point": String(spawn_point),
		})
		loading = true
		return true

	func reset_for_scene(scene_id: StringName, spawn_point: StringName) -> void:
		request_calls.clear()
		loading = false
		locked = false
		current_scene = scene_id
		current_spawn = spawn_point

	func fail_pending(scene_id: StringName, reason: StringName) -> void:
		loading = false
		on_scene_load_failed.emit(scene_id, reason)


func after_test() -> void:
	_stop_runtime_audio_players()
	for node: Node in _spawned_nodes:
		if not is_instance_valid(node):
			continue
		if node.get_parent() != null:
			node.get_parent().remove_child(node)
		node.free()
	_spawned_nodes.clear()


func test_registry_scene_assets_and_guard_frame_contract() -> void:
	for path: String in [
		TOWER_SCENE_PATH,
		TOWER_SCENE_SCRIPT_PATH,
		GUARD_CONTROLLER_SCRIPT_PATH,
		GUARD_GAMEPLAY_SCRIPT_PATH,
		GUARD_GAMEPLAY_SCENE_PATH,
		GUARD_CHARACTER_SCRIPT_PATH,
		GUARD_CHARACTER_SCENE_PATH,
		GUARD_FRAMES_PATH,
		BACKGROUND_PATH,
		SEAL_PATH,
		GUARD_DOCK_PATH,
		THRESHOLD_ROOST_PATH,
	]:
		assert_bool(FileAccess.file_exists(path)).override_failure_message(
			"Story140 authored contract is missing: %s" % path
		).is_true()

	var registry: Dictionary = _read_json_dictionary(REGISTRY_PATH)
	var entries: Dictionary = Dictionary(registry.get("entries", {}))
	assert_bool(entries.has(String(TOWER_SCENE_ID))).is_true()
	var entry: Dictionary = Dictionary(entries.get(String(TOWER_SCENE_ID), {}))
	assert_str(String(entry.get("scene_id", ""))).is_equal(String(TOWER_SCENE_ID))
	assert_str(String(entry.get("path", ""))).is_equal(TOWER_SCENE_PATH)
	assert_str(String(entry.get("type", ""))).is_equal("area")
	assert_bool(bool(entry.get("preload", true))).is_false()
	assert_str(String(entry.get("default_spawn", ""))).is_equal(
		String(TOWER_ENTRY_SPAWN)
	)
	var registry_schema: Dictionary = _read_json_dictionary(REGISTRY_SCHEMA_PATH)
	assert_bool(Dictionary(registry_schema.get("entries", {})).has(
		String(TOWER_SCENE_ID)
	)).is_true()

	var enemy_stats: Dictionary = _read_json_dictionary(ENEMY_STATS_PATH)
	var enemy_entries: Dictionary = Dictionary(enemy_stats.get("entries", {}))
	assert_bool(enemy_entries.has(String(GUARD_CONFIG_ID))).is_true()
	var guard_entry: Dictionary = Dictionary(enemy_entries.get(
		String(GUARD_CONFIG_ID),
		{}
	))
	assert_int(int(guard_entry.get("max_hp", 0))).is_equal(EXPECTED_GUARD_HP)
	var patterns: Array = Array(guard_entry.get("attack_patterns", []))
	assert_int(patterns.size()).is_equal(1)
	if not patterns.is_empty() and patterns[0] is Dictionary:
		var pattern: Dictionary = Dictionary(patterns[0])
		assert_str(String(pattern.get("pattern_id", ""))).is_equal("latch_thrust")
		assert_int(int(pattern.get("startup_frames", 0))).is_equal(
			EXPECTED_STARTUP_FRAMES
		)
		assert_int(int(pattern.get("damage", 0))).is_equal(EXPECTED_GUARD_DAMAGE)
	var enemy_schema: Dictionary = _read_json_dictionary(ENEMY_STATS_SCHEMA_PATH)
	assert_bool(Dictionary(enemy_schema.get("entries", {})).has(
		String(GUARD_CONFIG_ID)
	)).is_true()

	_assert_png_contract(BACKGROUND_PATH, Vector2i(1280, 720), false)
	_assert_png_contract(SEAL_PATH, Vector2i(384, 512), true)
	_assert_png_contract(GUARD_DOCK_PATH, Vector2i(256, 256), true)
	_assert_png_contract(THRESHOLD_ROOST_PATH, Vector2i(256, 256), true)
	var common_frame_bottom: int = -1
	for animation_name: StringName in REQUIRED_ANIMATIONS:
		for frame_index: int in range(3):
			var frame_path: String = _frame_path(animation_name, frame_index)
			_assert_png_contract(
				frame_path,
				Vector2i(96, 96),
				true
			)
			var frame_bottom: int = _get_used_image_bottom(frame_path)
			if common_frame_bottom < 0:
				common_frame_bottom = frame_bottom
			assert_int(frame_bottom).is_equal(common_frame_bottom)

	if FileAccess.file_exists(GUARD_FRAMES_PATH):
		var frames: SpriteFrames = load(GUARD_FRAMES_PATH) as SpriteFrames
		assert_that(frames).is_not_null()
		if frames != null:
			for animation_name: StringName in REQUIRED_ANIMATIONS:
				assert_bool(frames.has_animation(animation_name)).is_true()
				assert_int(frames.get_frame_count(animation_name)).is_equal(3)

	var tower: Node = _instantiate_scene(TOWER_SCENE_PATH)
	assert_that(tower).is_not_null()
	if tower == null:
		return
	assert_str(String(tower.get_meta("scene_id", ""))).is_equal(String(TOWER_SCENE_ID))
	for node_path: String in [
		"Background",
		"Ground/CollisionShape2D",
		"TopBoundary/CollisionShape2D",
		"LeftBoundary/CollisionShape2D",
		"RightBoundary/CollisionShape2D",
		"NeonRooftopsThresholdArrival",
		"ThresholdRoost/InteractionArea/CollisionShape2D",
		"Player/Camera2D",
		"NeonRooftopsReturnRoute/InteractionArea/CollisionShape2D",
		"ThresholdGuardController/RearSeal/CollisionShape2D",
		"ThresholdGuardController/InnerSeal/CollisionShape2D",
		"ThresholdGuardController/CentralTowerThresholdGuard/Sprite",
		"HUD",
		"ObjectiveLabel",
	]:
		assert_that(tower.get_node_or_null(node_path)).is_not_null()
	assert_bool(
		tower.get_node_or_null("ThresholdRoost") is SavepointRuntime
	).is_true()
	var tower_scene_source: String = FileAccess.get_file_as_string(TOWER_SCENE_PATH)
	assert_bool(tower_scene_source.contains('type="ColorRect"')).is_false()
	assert_bool(tower_scene_source.contains('type="Polygon2D"')).is_false()
	assert_bool(tower_scene_source.contains('[node name="Boss')).is_false()
	assert_bool(tower_scene_source.contains('[node name="Reward')).is_false()
	assert_bool(tower_scene_source.contains("Boss4")).is_false()
	var sprite: AnimatedSprite2D = tower.get_node_or_null(
		"ThresholdGuardController/CentralTowerThresholdGuard/Sprite"
	) as AnimatedSprite2D
	assert_that(sprite).is_not_null()
	if sprite != null and sprite.sprite_frames != null:
		assert_str(sprite.sprite_frames.resource_path).is_equal(GUARD_FRAMES_PATH)


func test_secured_rooftop_threshold_requests_tower_once_and_restores_return() -> void:
	var rooftops: Node = _instantiate_scene(ROOFTOPS_SCENE_PATH)
	assert_that(rooftops).is_not_null()
	if rooftops == null:
		return
	assert_bool(rooftops.has_method("try_request_central_tower_entry")).is_true()
	assert_bool(rooftops.has_method("get_neon_rooftops_entry_diagnostics")).is_true()
	if not rooftops.has_method("try_request_central_tower_entry"):
		return

	var manager := FakeSceneManager.new()
	manager.reset_for_scene(ROOFTOPS_SCENE_ID, &"factory_rooftop_arrival")
	assert_bool(bool(rooftops.call("configure_scene_manager_runtime", manager))).is_true()
	var player: Node2D = rooftops.get_node_or_null("Player") as Node2D
	var route: Node2D = rooftops.get_node_or_null("CentralTowerRoute") as Node2D
	assert_that(player).is_not_null()
	assert_that(route).is_not_null()
	if player == null or route == null:
		return

	rooftops.call("set_local_state", _story139_state(false))
	player.global_position = route.global_position
	assert_bool(bool(rooftops.call(
		"try_request_central_tower_entry",
		player
	))).is_false()
	assert_int(manager.request_calls.size()).is_equal(0)

	var secured_state: Dictionary = _story139_state(true)
	rooftops.call("set_local_state", secured_state)
	player.global_position = route.global_position + Vector2(200.0, 0.0)
	assert_bool(bool(rooftops.call(
		"try_request_central_tower_entry",
		player
	))).is_false()
	player.global_position = route.global_position
	var state_before_rejections: Dictionary = rooftops.call("get_local_state")
	manager.loading = true
	assert_bool(bool(rooftops.call(
		"try_request_central_tower_entry",
		player
	))).is_false()
	manager.loading = false
	manager.locked = true
	assert_bool(bool(rooftops.call(
		"try_request_central_tower_entry",
		player
	))).is_false()
	manager.locked = false
	manager.tower_known = false
	assert_bool(bool(rooftops.call(
		"try_request_central_tower_entry",
		player
	))).is_false()
	manager.tower_known = true
	assert_int(manager.request_calls.size()).is_equal(0)
	assert_dict(Dictionary(rooftops.call("get_local_state"))).is_equal(
		state_before_rejections
	)
	var rejected_diagnostics: Dictionary = rooftops.call(
		"get_neon_rooftops_entry_diagnostics"
	)
	assert_bool(bool(rejected_diagnostics.get(
		"central_tower_transition_requested",
		true
	))).is_false()
	assert_str(String(rejected_diagnostics.get(
		"last_central_tower_rejected_reason",
		""
	))).is_equal("unknown_scene")

	assert_bool(bool(rooftops.call(
		"try_request_central_tower_entry",
		player
	))).is_true()
	assert_bool(bool(rooftops.call(
		"try_request_central_tower_entry",
		player
	))).is_false()
	assert_int(manager.request_calls.size()).is_equal(1)
	assert_str(String(manager.request_calls[0].get("scene_id", ""))).is_equal(
		String(TOWER_SCENE_ID)
	)
	assert_str(String(manager.request_calls[0].get("spawn_point", ""))).is_equal(
		String(TOWER_ENTRY_SPAWN)
	)
	manager.fail_pending(TOWER_SCENE_ID, &"load_failed")
	var retry_ready: Dictionary = rooftops.call(
		"get_neon_rooftops_entry_diagnostics"
	)
	assert_bool(bool(retry_ready.get(
		"central_tower_transition_requested",
		true
	))).is_false()
	assert_bool(bool(rooftops.call(
		"try_request_central_tower_entry",
		player
	))).is_true()
	assert_int(manager.request_calls.size()).is_equal(2)
	var persisted: Dictionary = manager.get_scene_state(ROOFTOPS_SCENE_ID)
	assert_bool(bool(persisted.get(
		"neon_rooftops_central_tower_threshold_secured",
		false
	))).is_true()
	assert_int(int(persisted.get(
		"neon_rooftops_central_tower_parry_count",
		0
	))).is_equal(3)
	for state_key_value: Variant in secured_state.keys():
		var state_key: String = String(state_key_value)
		if state_key == "unlocked_abilities":
			assert_array(Array(persisted.get(state_key, []))).contains(
				Array(secured_state.get(state_key, []))
			)
		else:
			assert_that(persisted.get(state_key)).is_equal(secured_state.get(state_key))
	var target_state: Dictionary = manager.get_scene_state(TOWER_SCENE_ID)
	assert_array(Array(target_state.get("unlocked_abilities", []))).contains([
		"parry", "wall_climb",
	])

	var restored: Node = _instantiate_scene(ROOFTOPS_SCENE_PATH)
	assert_that(restored).is_not_null()
	if restored == null:
		return
	manager.reset_for_scene(ROOFTOPS_SCENE_ID, ROOFTOPS_RETURN_SPAWN)
	assert_bool(bool(restored.call("configure_scene_manager_runtime", manager))).is_true()
	restored.call("set_local_state", persisted)
	var restored_player: Node2D = restored.get_node_or_null("Player") as Node2D
	var return_marker: Marker2D = restored.get_node_or_null(
		"CentralTowerThresholdReturn"
	) as Marker2D
	assert_that(restored_player).is_not_null()
	assert_that(return_marker).is_not_null()
	if restored_player != null and return_marker != null:
		assert_vector(restored_player.global_position).is_equal(
			return_marker.global_position
		)
	if restored_player != null:
		assert_array(Array(restored_player.call(
			"get_unlocked_abilities"
		))).contains(["dash", "double_jump", "aerial_attack", "wall_climb", "parry"])
	var restored_trial: Dictionary = restored.call(
		"get_central_tower_parry_trial_diagnostics"
	)
	assert_bool(bool(restored_trial.get("threshold_secured", false))).is_true()
	assert_int(int(restored_trial.get("parry_feedback_count", -1))).is_equal(0)
	assert_int(int(restored_trial.get("threshold_feedback_count", -1))).is_equal(0)


func test_guard_combat_respawn_clear_restore_and_rooftop_return() -> void:
	var tower: Node = _instantiate_scene(TOWER_SCENE_PATH)
	assert_that(tower).is_not_null()
	if tower == null:
		return
	for method_name: String in [
		"configure_scene_manager_runtime",
		"try_activate_threshold_guard",
		"request_threshold_guard_attack",
		"advance_central_tower_respawn_flow",
		"apply_damage",
		"get_central_tower_threshold_diagnostics",
		"try_request_neon_rooftops_return",
	]:
		assert_bool(tower.has_method(method_name)).is_true()
	if not tower.has_method("try_activate_threshold_guard"):
		return

	var manager := FakeSceneManager.new()
	manager.reset_for_scene(TOWER_SCENE_ID, TOWER_ENTRY_SPAWN)
	assert_bool(bool(tower.call("configure_scene_manager_runtime", manager))).is_true()
	tower.call("set_local_state", {
		"unlocked_abilities": [
			"dash", "double_jump", "aerial_attack", "wall_climb", "parry",
		],
	})
	var player: Node2D = tower.get_node_or_null("Player") as Node2D
	var arrival: Marker2D = tower.get_node_or_null(
		"NeonRooftopsThresholdArrival"
	) as Marker2D
	var enemy: CharacterBody2D = tower.get_node_or_null(
		"ThresholdGuardController/CentralTowerThresholdGuard"
	) as CharacterBody2D
	var enemy_sprite: AnimatedSprite2D = enemy.get_node_or_null(
		"Sprite"
	) as AnimatedSprite2D if enemy != null else null
	var player_health: HealthComponent = player.get_node_or_null(
		"HealthComponent"
	) as HealthComponent if player != null else null
	assert_that(player).is_not_null()
	assert_that(arrival).is_not_null()
	assert_that(enemy).is_not_null()
	assert_that(enemy_sprite).is_not_null()
	assert_that(player_health).is_not_null()
	if (
		player == null
		or arrival == null
		or enemy == null
		or enemy_sprite == null
		or player_health == null
	):
		return
	assert_vector(player.global_position).is_equal(arrival.global_position)
	assert_str(String(enemy_sprite.animation)).is_equal("idle")
	var guard_start_position: Vector2 = enemy.position
	var initial_tower_state: Dictionary = tower.call("get_local_state")
	var abilities_before_clear: Array = Array(initial_tower_state.get(
		"unlocked_abilities",
		[]
	)).duplicate()

	player.global_position.x = GUARD_ACTIVATION_X - 1.0
	assert_bool(bool(tower.call("try_activate_threshold_guard", player))).is_false()
	player.global_position.x = GUARD_ACTIVATION_X
	assert_bool(bool(tower.call("try_activate_threshold_guard", player))).is_true()
	assert_bool(bool(tower.call("try_activate_threshold_guard", player))).is_false()
	await get_tree().process_frame
	var active: Dictionary = tower.call("get_central_tower_threshold_diagnostics")
	assert_bool(bool(active.get("threshold_roost_activated", false))).is_true()
	assert_str(String(active.get("encounter_state", ""))).is_equal("active")
	assert_bool(bool(active.get("rear_seal_blocking", false))).is_true()
	assert_bool(bool(active.get("inner_seal_blocking", false))).is_true()
	assert_bool(bool(active.get("guard_has_target", false))).is_true()
	assert_int(int(active.get("guard_entity_id", 0))).is_equal(GUARD_ENTITY_ID)
	assert_int(int(active.get("guard_max_hp", 0))).is_equal(EXPECTED_GUARD_HP)

	enemy.set_physics_process(false)
	enemy.call("advance_pacing_frames", 25)
	assert_str(String(enemy_sprite.animation)).is_equal("run")
	assert_bool(bool(tower.call("request_threshold_guard_attack"))).is_true()
	assert_str(String(enemy_sprite.animation)).is_equal("attack_tell")
	enemy.call("advance_attack_frames", EXPECTED_STARTUP_FRAMES)
	assert_bool(bool(enemy.call("is_enemy_attack_active"))).is_true()
	assert_str(String(enemy_sprite.animation)).is_equal("attack")
	var enemy_collision: CollisionComponent = enemy.call(
		"get_collision_component"
	) as CollisionComponent
	var player_collision: CollisionComponent = player.call(
		"get_collision_component"
	) as CollisionComponent
	assert_that(enemy_collision).is_not_null()
	assert_that(player_collision).is_not_null()
	if enemy_collision == null or player_collision == null:
		return
	var hp_before: int = int(player.call("get_current_hp"))
	enemy_collision.process_detection_frame({
		GUARD_ATTACK_HITBOX_ID: [player_collision.get_hurtbox()],
	})
	assert_int(int(player.call("get_current_hp"))).is_equal(
		hp_before - EXPECTED_GUARD_DAMAGE
	)
	var presentation: CombatPresentation = tower.get_node_or_null(
		"CombatPresentation"
	) as CombatPresentation
	if presentation != null:
		while presentation.is_gameplay_hitstop_active():
			await get_tree().process_frame
	var player_combat: CombatComponent = player.call(
		"get_combat_component"
	) as CombatComponent
	assert_that(player_combat).is_not_null()
	if player_combat == null:
		return
	player_combat.advance_hit_stun_frames(12)

	var guard_hp_before: int = int(enemy.call("get_current_hp"))
	player.global_position.y = 556.0
	player.call("set_airborne", false)
	assert_bool(bool(player.call("request_attack"))).is_true()
	player_combat.advance_attack_frames(4)
	player_collision.process_detection_frame({
		&"cat_claw_light": [enemy_collision.get_hurtbox()],
	})
	assert_bool(int(enemy.call("get_current_hp")) < guard_hp_before).is_true()
	assert_str(String(enemy_sprite.animation)).is_equal("hurt")

	enemy.position += Vector2(80.0, 0.0)
	player.call("apply_damage", 999, {"source": &"story140_respawn_test"})
	tower.call("advance_central_tower_respawn_flow", 1.6)
	assert_int(int(player.call("get_current_hp"))).is_equal(50)
	assert_vector(player.global_position).is_equal(arrival.global_position)
	assert_bool(player_health.is_invincible()).is_true()
	assert_int(player_health.get_iframe_remaining()).is_equal(120)
	var reset: Dictionary = tower.call("get_central_tower_threshold_diagnostics")
	assert_str(String(reset.get("flow_state", ""))).is_equal("revived")
	assert_bool(bool(reset.get("player_control_locked", true))).is_false()
	assert_str(String(reset.get("encounter_state", ""))).is_equal("ready")
	assert_bool(bool(reset.get("guard_activated", true))).is_false()
	assert_int(int(reset.get("guard_current_hp", 0))).is_equal(EXPECTED_GUARD_HP)
	assert_vector(Vector2(reset.get(
		"guard_position",
		Vector2.ZERO
	))).is_equal(guard_start_position)
	assert_bool(bool(reset.get("rear_seal_blocking", true))).is_false()
	assert_int(enemy_collision.get_active_hitbox_count()).is_equal(0)
	tower.call("advance_central_tower_respawn_flow", 2.1)
	for _frame: int in range(120):
		player_health._physics_process(1.0 / 60.0)
	var playing: Dictionary = tower.call("get_central_tower_threshold_diagnostics")
	assert_str(String(playing.get("flow_state", ""))).is_equal("playing")
	assert_bool(bool(playing.get("player_control_locked", true))).is_false()
	assert_bool(player_health.is_invincible()).is_false()
	assert_int(player_health.get_iframe_remaining()).is_equal(0)

	player.global_position.x = GUARD_ACTIVATION_X
	assert_bool(bool(tower.call("try_activate_threshold_guard", player))).is_true()
	player.call("apply_damage", 999, {"source": &"story140_death_window_test"})
	assert_bool(bool(tower.call("apply_damage", GUARD_ENTITY_ID, 999, {
		"source": &"story140_death_window_clear_test",
	}))).is_true()
	assert_str(String(enemy_sprite.animation)).is_equal("death")
	tower.call("advance_central_tower_respawn_flow", 1.6)
	var cleared: Dictionary = tower.call("get_central_tower_threshold_diagnostics")
	assert_str(String(cleared.get("encounter_state", ""))).is_equal("cleared")
	assert_bool(bool(cleared.get("rear_seal_blocking", true))).is_false()
	assert_bool(bool(cleared.get("inner_seal_blocking", true))).is_false()
	assert_str(String(cleared.get("objective_text", ""))).is_equal(
		"Central Tower Threshold Secured"
	)

	var saved: Dictionary = tower.call("get_local_state")
	assert_bool(bool(saved.get(
		"central_tower_threshold_guard_defeated",
		false
	))).is_true()
	assert_array(Array(saved.get("unlocked_abilities", []))).is_equal(
		abilities_before_clear
	)
	var restored: Node = _instantiate_scene(TOWER_SCENE_PATH)
	assert_that(restored).is_not_null()
	if restored == null:
		return
	restored.call("set_local_state", saved)
	await get_tree().process_frame
	var restored_diagnostics: Dictionary = restored.call(
		"get_central_tower_threshold_diagnostics"
	)
	assert_str(String(restored_diagnostics.get("encounter_state", ""))).is_equal(
		"cleared"
	)
	assert_bool(bool(restored_diagnostics.get("guard_visible", true))).is_false()
	assert_int(int(restored_diagnostics.get("activation_feedback_count", -1))).is_equal(0)
	assert_int(int(restored_diagnostics.get("defeat_feedback_count", -1))).is_equal(0)

	manager.reset_for_scene(TOWER_SCENE_ID, TOWER_ENTRY_SPAWN)
	assert_bool(bool(restored.call("configure_scene_manager_runtime", manager))).is_true()
	var restored_player: Node2D = restored.get_node_or_null("Player") as Node2D
	var return_route: Node2D = restored.get_node_or_null(
		"NeonRooftopsReturnRoute"
	) as Node2D
	assert_that(restored_player).is_not_null()
	assert_that(return_route).is_not_null()
	if restored_player == null or return_route == null:
		return
	restored_player.global_position = return_route.global_position
	assert_bool(bool(restored.call(
		"try_request_neon_rooftops_return",
		restored_player
	))).is_true()
	assert_bool(bool(restored.call(
		"try_request_neon_rooftops_return",
		restored_player
	))).is_false()
	assert_int(manager.request_calls.size()).is_equal(1)
	assert_str(String(manager.request_calls[0].get("scene_id", ""))).is_equal(
		String(ROOFTOPS_SCENE_ID)
	)
	assert_str(String(manager.request_calls[0].get("spawn_point", ""))).is_equal(
		String(ROOFTOPS_RETURN_SPAWN)
	)
	var persisted_tower: Dictionary = manager.get_scene_state(TOWER_SCENE_ID)
	assert_bool(bool(persisted_tower.get(
		"central_tower_threshold_guard_defeated",
		false
	))).is_true()
	manager.fail_pending(ROOFTOPS_SCENE_ID, &"load_failed")
	var retry_ready: Dictionary = restored.call(
		"get_central_tower_threshold_diagnostics"
	)
	assert_bool(bool(retry_ready.get(
		"return_transition_requested",
		true
	))).is_false()
	assert_str(String(retry_ready.get(
		"last_return_rejected_reason",
		""
	))).is_equal("load_failed")
	assert_bool(bool(restored.call(
		"try_request_neon_rooftops_return",
		restored_player
	))).is_true()
	assert_int(manager.request_calls.size()).is_equal(2)


func _story139_state(threshold_secured: bool) -> Dictionary:
	return {
		"neon_rooftops_entry_arrived": true,
		"neon_rooftops_entry_traversed": true,
		"neon_rooftops_signal_rat_encounter_activated": true,
		"neon_rooftops_signal_rat_defeated": true,
		"neon_rooftops_signal_cache_claimed": true,
		"neon_rooftops_relay_spire_roost_activated": true,
		"neon_rooftops_relay_spire_traversed": true,
		"neon_rooftops_central_tower_trial_started": true,
		"neon_rooftops_central_tower_parry_count": 3 if threshold_secured else 2,
		"neon_rooftops_central_tower_gate_unlocked": threshold_secured,
		"neon_rooftops_central_tower_threshold_secured": threshold_secured,
		"unlocked_abilities": [
			"dash", "double_jump", "aerial_attack", "wall_climb", "parry",
		],
	}


func _frame_path(animation_name: StringName, frame_index: int) -> String:
	return (
		"res://assets/characters/central_tower_threshold_guard/%s/"
		% String(animation_name)
		+ "central_tower_threshold_guard_%s_%03d.png"
		% [String(animation_name), frame_index]
	)


func _instantiate_scene(path: String) -> Node:
	if not FileAccess.file_exists(path):
		return null
	var packed: PackedScene = load(path) as PackedScene
	if packed == null:
		return null
	var instance: Node = packed.instantiate()
	_spawned_nodes.append(instance)
	add_child(instance)
	return instance


func _read_json_dictionary(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	return parsed if parsed is Dictionary else {}


func _assert_png_contract(path: String, expected_size: Vector2i, alpha: bool) -> void:
	assert_bool(FileAccess.file_exists(path)).is_true()
	if not FileAccess.file_exists(path):
		return
	var image := Image.new()
	assert_int(image.load(path)).is_equal(OK)
	assert_int(image.get_width()).is_equal(expected_size.x)
	assert_int(image.get_height()).is_equal(expected_size.y)
	assert_int(image.detect_alpha()).is_equal(
		Image.ALPHA_BLEND if alpha else Image.ALPHA_NONE
	)
	if alpha:
		assert_float(image.get_pixel(0, 0).a).is_equal_approx(0.0, 0.01)


func _get_used_image_bottom(path: String) -> int:
	var image := Image.new()
	if image.load(path) != OK:
		return -1
	var used_rect: Rect2i = image.get_used_rect()
	return used_rect.position.y + used_rect.size.y


func _stop_runtime_audio_players() -> void:
	var audio_system: Node = get_node_or_null("/root/AudioSystem")
	if audio_system != null and audio_system.has_method("stop_all_runtime_audio"):
		audio_system.call("stop_all_runtime_audio")
