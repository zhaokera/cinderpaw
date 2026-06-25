## Rat King arena mutation save-state persistence.
extends GdUnitTestSuite

const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")
const SAVE_SYSTEM_SCRIPT: Script = preload("res://src/feature/save_system.gd")
const TEST_SAVE_DIR: String = "user://cinderpaw_arena_mutation_save_state/"
const RAT_KING_BOSS_ID: StringName = &"boss_01_rat_king"

var scene: Node2D
var save_system: Node
var fake_audio_system: Node
var fake_scene_manager: Node


class FakeAudioSystem:
	extends Node

	func on_scene_load_started(
		_scene_id: StringName,
		_spawn_point: StringName,
		_metadata: Dictionary
	) -> void:
		pass

	func on_boss_encounter_started(_boss_id: StringName, _metadata: Dictionary) -> void:
		pass

	func on_boss_encounter_ended(_boss_id: StringName, _metadata: Dictionary) -> void:
		pass

	func on_enemy_defeated(_metadata: Dictionary) -> bool:
		return true


class FakeSceneManager:
	extends Node

	var locked: bool = false
	var change_calls: Array[Dictionary] = []

	func has_scene(scene_id: StringName) -> bool:
		return String(scene_id) == "main"

	func get_current_scene() -> StringName:
		return &"main"

	func is_scene_locked() -> bool:
		return locked

	func lock_scene() -> void:
		locked = true

	func unlock_scene() -> void:
		locked = false

	func change_scene(scene_id: StringName, spawn_point: StringName = &"default") -> bool:
		change_calls.append({
			"scene_id": String(scene_id),
			"spawn_point": String(spawn_point),
		})
		return has_scene(scene_id) and not locked


func before_test() -> void:
	_cleanup_test_save_dir()
	scene = MAIN_SCENE.instantiate() as Node2D
	add_child(scene)
	fake_scene_manager = FakeSceneManager.new()
	add_child(fake_scene_manager)
	scene.call("configure_scene_manager_runtime", fake_scene_manager)
	fake_audio_system = FakeAudioSystem.new()
	add_child(fake_audio_system)
	scene.call("configure_audio_system_runtime", fake_audio_system)


func after_test() -> void:
	_stop_runtime_audio_players()
	if is_instance_valid(scene):
		scene.call("configure_save_system_runtime", null)
		if scene.get_parent() != null:
			scene.get_parent().remove_child(scene)
		scene.free()
	scene = null
	if is_instance_valid(fake_scene_manager):
		if fake_scene_manager.get_parent() != null:
			fake_scene_manager.get_parent().remove_child(fake_scene_manager)
		fake_scene_manager.free()
	fake_scene_manager = null
	if is_instance_valid(fake_audio_system):
		if fake_audio_system.get_parent() != null:
			fake_audio_system.get_parent().remove_child(fake_audio_system)
		fake_audio_system.free()
	fake_audio_system = null
	if is_instance_valid(save_system):
		if save_system.get_parent() != null:
			save_system.get_parent().remove_child(save_system)
		save_system.free()
	save_system = null
	_cleanup_test_save_dir()


func test_save_snapshot_captures_active_arena_mutations_json_safe() -> void:
	_spawn_all_arena_mutations()

	var snapshot: Dictionary = scene.call("capture_save_snapshot")
	var world_state: Dictionary = Dictionary(snapshot.get("world_state", {}))

	assert_bool(world_state.has("arena_mutations")).is_true()
	var saved_mutations: Array = Array(world_state.get("arena_mutations", []))
	assert_int(saved_mutations.size()).is_equal(3)
	_assert_saved_mutation_entry(saved_mutations, &"garbage_pile", &"obstacle", 2)
	_assert_saved_mutation_entry(saved_mutations, &"overturned_trash_can", &"obstacle", 3)
	_assert_saved_mutation_entry(saved_mutations, &"electric_leak", &"damage_zone", 3)

	var encoded: String = JSON.stringify(world_state)
	assert_bool(encoded.contains("Vector2")).is_false()
	assert_bool(encoded.contains("Object(")).is_false()


func test_restore_save_snapshot_rebuilds_mutations_with_vfx_and_idempotence() -> void:
	_spawn_all_arena_mutations()
	var snapshot: Dictionary = scene.call("capture_save_snapshot")

	scene.call("cleanup_arena_mutations", RAT_KING_BOSS_ID)
	assert_int((scene.call("get_arena_mutation_nodes") as Array).size()).is_equal(0)

	scene.call("restore_save_snapshot", snapshot)
	_assert_restored_active_mutations()

	_spawn_all_arena_mutations()
	assert_int((scene.call("get_arena_mutation_nodes") as Array).size()).is_equal(3)


func test_save_system_slot_load_restores_active_arena_mutations() -> void:
	_configure_save_system()
	assert_bool(bool(scene.call("configure_save_system_runtime", save_system))).is_true()
	_spawn_all_arena_mutations()

	assert_bool(bool(scene.call("save_runtime_to_slot", 1))).is_true()
	scene.call("cleanup_arena_mutations", RAT_KING_BOSS_ID)
	assert_int((scene.call("get_arena_mutation_nodes") as Array).size()).is_equal(0)

	assert_bool(bool(scene.call("load_runtime_from_slot", 1))).is_true()
	_assert_restored_active_mutations()


func test_boss_defeat_autosave_records_empty_arena_mutations() -> void:
	_configure_save_system()
	assert_bool(bool(scene.call("configure_save_system_runtime", save_system))).is_true()
	_spawn_all_arena_mutations()
	assert_int((scene.call("get_arena_mutation_nodes") as Array).size()).is_equal(3)

	var enemy: Node = scene.get_node("Enemy")
	enemy.call("apply_damage", int(enemy.call("get_current_hp")), {
		"source": &"arena_mutation_save_state_test",
	})

	assert_bool(bool(save_system.call("has_save", 0))).is_true()
	var saved: Dictionary = _read_json(_slot_path(0))
	var world_state: Dictionary = Dictionary(saved.get("world_state", {}))
	assert_bool(world_state.has("arena_mutations")).is_true()
	assert_int(Array(world_state.get("arena_mutations", [])).size()).is_equal(0)


func test_restore_older_snapshot_without_arena_mutations_clears_stale_nodes() -> void:
	_spawn_all_arena_mutations()
	assert_int((scene.call("get_arena_mutation_nodes") as Array).size()).is_equal(3)

	scene.call("restore_save_snapshot", {
		"player_state": {},
		"world_state": {
			"scene_id": "main",
			"defeated_bosses": [],
			"world_flags": {},
			"last_savepoint": {},
		},
		"settings": {},
	})

	assert_int((scene.call("get_arena_mutation_nodes") as Array).size()).is_equal(0)


func test_restore_snapshot_with_defeated_rat_king_clears_saved_mutations() -> void:
	_spawn_all_arena_mutations()
	var snapshot: Dictionary = scene.call("capture_save_snapshot")
	var world_state: Dictionary = Dictionary(snapshot.get("world_state", {}))
	world_state["defeated_bosses"] = [String(RAT_KING_BOSS_ID)]
	snapshot["world_state"] = world_state

	scene.call("restore_save_snapshot", snapshot)

	assert_int((scene.call("get_arena_mutation_nodes") as Array).size()).is_equal(0)


func _configure_save_system() -> void:
	assert_object(SAVE_SYSTEM_SCRIPT).is_not_null()
	assert_bool(SAVE_SYSTEM_SCRIPT.can_instantiate()).is_true()
	if not SAVE_SYSTEM_SCRIPT.can_instantiate():
		return
	save_system = SAVE_SYSTEM_SCRIPT.new()
	add_child(save_system)
	save_system.call("configure_save_directory", TEST_SAVE_DIR)
	if save_system.has_method("set_async_write_enabled"):
		save_system.call("set_async_write_enabled", false)


func _spawn_all_arena_mutations() -> void:
	scene.call("apply_arena_changes", RAT_KING_BOSS_ID, 2, [{
		"id": "garbage_pile",
		"type": "obstacle",
	}])
	scene.call("apply_arena_changes", RAT_KING_BOSS_ID, 3, [{
		"id": "overturned_trash_can",
		"type": "obstacle",
	}, {
		"id": "electric_leak",
		"type": "damage_zone",
	}])


func _assert_saved_mutation_entry(
	entries: Array,
	change_id: StringName,
	change_type: StringName,
	phase: int
) -> void:
	var entry: Dictionary = _find_saved_entry(entries, change_id)
	assert_bool(not entry.is_empty()).is_true()
	if entry.is_empty():
		return
	assert_bool(entry.get("boss_id") is String).is_true()
	assert_bool(entry.get("id") is String).is_true()
	assert_bool(entry.get("type") is String).is_true()
	assert_bool(entry.get("phase") is float or entry.get("phase") is int).is_true()
	assert_str(String(entry.get("boss_id", ""))).is_equal(String(RAT_KING_BOSS_ID))
	assert_str(String(entry.get("id", ""))).is_equal(String(change_id))
	assert_str(String(entry.get("type", ""))).is_equal(String(change_type))
	assert_int(int(entry.get("phase", 0))).is_equal(phase)


func _assert_restored_active_mutations() -> void:
	var mutations: Array = scene.call("get_arena_mutation_nodes")
	assert_int(mutations.size()).is_equal(3)
	_assert_runtime_mutation(&"garbage_pile", &"obstacle", 2, StaticBody2D)
	_assert_runtime_mutation(&"overturned_trash_can", &"obstacle", 3, StaticBody2D)
	_assert_runtime_mutation(&"electric_leak", &"damage_zone", 3, Area2D)


func _assert_runtime_mutation(
	change_id: StringName,
	change_type: StringName,
	phase: int,
	expected_class: Variant
) -> void:
	var mutation: Node = _find_runtime_mutation(change_id)
	assert_object(mutation).is_not_null()
	if mutation == null:
		return
	assert_bool(is_instance_of(mutation, expected_class)).is_true()
	assert_str(String(mutation.get_meta(&"boss_id", &""))).is_equal(String(RAT_KING_BOSS_ID))
	assert_str(String(mutation.get_meta(&"change_id", &""))).is_equal(String(change_id))
	assert_str(String(mutation.get_meta(&"change_type", &""))).is_equal(String(change_type))
	assert_int(int(mutation.get_meta(&"phase", 0))).is_equal(phase)
	assert_object(mutation.get_node_or_null("CollisionShape2D")).is_not_null()
	assert_bool(mutation.get_node_or_null("Sprite") is Sprite2D).is_true()
	assert_bool(mutation.get_node_or_null("Visual") is Polygon2D).is_true()
	var vfx := mutation.get_node_or_null("Vfx") as Node2D
	assert_object(vfx).is_not_null()
	if change_id == &"electric_leak":
		assert_bool(mutation is Area2D).is_true()
		var damage_zone := mutation as Area2D
		if damage_zone != null:
			assert_bool(damage_zone.area_entered.get_connections().size() > 0).is_true()
			assert_bool(damage_zone.body_entered.get_connections().size() > 0).is_true()
		if vfx != null:
			assert_object(vfx.get_node_or_null("HazardGlow")).is_not_null()
			assert_object(vfx.get_node_or_null("ElectricSpark")).is_not_null()


func _find_saved_entry(entries: Array, change_id: StringName) -> Dictionary:
	for raw_entry: Variant in entries:
		if not raw_entry is Dictionary:
			continue
		var entry: Dictionary = Dictionary(raw_entry)
		if StringName(String(entry.get("id", ""))) == change_id:
			return entry
	return {}


func _find_runtime_mutation(change_id: StringName) -> Node:
	for mutation: Node in scene.call("get_arena_mutation_nodes"):
		if StringName(String(mutation.get_meta(&"change_id", &""))) == change_id:
			return mutation
	return null


func _read_json(path: String) -> Dictionary:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	assert_bool(parsed is Dictionary).is_true()
	return Dictionary(parsed)


func _slot_path(slot: int) -> String:
	return "%sslot_%d.json" % [TEST_SAVE_DIR, slot]


func _cleanup_test_save_dir() -> void:
	if not DirAccess.dir_exists_absolute(TEST_SAVE_DIR):
		return
	for file_name: String in DirAccess.get_files_at(TEST_SAVE_DIR):
		DirAccess.remove_absolute(TEST_SAVE_DIR.path_join(file_name))
	DirAccess.remove_absolute(TEST_SAVE_DIR)


func _stop_runtime_audio_players() -> void:
	var audio_system := get_node_or_null("/root/AudioSystem")
	if audio_system == null:
		return
	for child: Node in audio_system.get_children():
		if child is AudioStreamPlayer2D:
			var player := child as AudioStreamPlayer2D
			player.stop()
			player.stream = null
