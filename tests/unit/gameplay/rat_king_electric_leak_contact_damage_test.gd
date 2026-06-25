## Rat King electric leak contact damage integration.
extends GdUnitTestSuite

const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")
const RAT_KING_BOSS_ID: StringName = &"boss_01_rat_king"
const PHASE_TWO_DAMAGE: int = 120
const PHASE_THREE_DAMAGE: int = 120
const PHASE_TRANSITION_BUFFER_SEC: float = 3.0
const EXPECTED_ELECTRIC_LEAK_DAMAGE: int = 8
const EXPECTED_CONTACT_COOLDOWN_SEC: float = 1.0

var scene: Node2D


class FakeAudioSystem:
	extends RefCounted

	var load_started_calls: Array[Dictionary] = []
	var damage_taken_events: Array[Dictionary] = []

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

	func on_damage_taken_event(damage_data: Dictionary) -> bool:
		damage_taken_events.append(damage_data.duplicate(true))
		return false


func before_test() -> void:
	scene = MAIN_SCENE.instantiate() as Node2D
	add_child(scene)


func after_test() -> void:
	if is_instance_valid(scene):
		if scene.get_parent() != null:
			scene.get_parent().remove_child(scene)
		scene.free()
	scene = null


func test_electric_leak_uses_environment_collision_contract() -> void:
	var electric_leak: Area2D = _spawn_electric_leak()

	assert_int(electric_leak.collision_layer).is_equal(CollisionComponent.COLLISION_LAYER_ENVIRONMENT)
	assert_int(electric_leak.collision_mask).is_equal(
		CollisionComponent.COLLISION_MASK_ENVIRONMENT
	)
	assert_bool(electric_leak.monitoring).is_true()
	assert_bool(electric_leak.monitorable).is_false()
	assert_bool(electric_leak.area_entered.get_connections().size() > 0).is_true()
	assert_bool(electric_leak.body_entered.get_connections().size() > 0).is_true()


func test_electric_leak_contact_damages_player_and_routes_feedback() -> void:
	var audio_system := FakeAudioSystem.new()
	assert_bool(bool(scene.call("configure_audio_system_runtime", audio_system))).is_true()
	assert_bool(scene.has_method("apply_arena_damage_zone_contact")).is_true()
	if not scene.has_method("apply_arena_damage_zone_contact"):
		return

	var electric_leak: Area2D = _spawn_electric_leak()
	var player: Node = scene.get_node("Player")
	var start_hp: int = int(player.call("get_current_hp"))

	assert_bool(bool(scene.call("apply_arena_damage_zone_contact", electric_leak, player))).is_true()
	var hp_after_first_contact: int = int(player.call("get_current_hp"))
	assert_int(start_hp - hp_after_first_contact).is_equal(EXPECTED_ELECTRIC_LEAK_DAMAGE)
	assert_int(audio_system.damage_taken_events.size()).is_equal(1)
	if audio_system.damage_taken_events.size() != 1:
		return
	var damage_event: Dictionary = audio_system.damage_taken_events[0]
	assert_int(int(damage_event.get("damage", 0))).is_equal(EXPECTED_ELECTRIC_LEAK_DAMAGE)
	assert_str(String(damage_event.get("source", &""))).is_equal("electric_leak")
	assert_str(String(damage_event.get("damage_type", &""))).is_equal("electric")
	assert_str(String(damage_event.get("boss_id", &""))).is_equal(String(RAT_KING_BOSS_ID))
	assert_int(int(damage_event.get("phase", 0))).is_equal(3)
	assert_bool(damage_event.has("hit_position")).is_true()

	assert_bool(bool(scene.call("apply_arena_damage_zone_contact", electric_leak, player))).is_false()
	assert_int(int(player.call("get_current_hp"))).is_equal(hp_after_first_contact)
	assert_int(audio_system.damage_taken_events.size()).is_equal(1)


func test_electric_leak_contact_cooldown_allows_repeated_damage_after_elapsed_time() -> void:
	assert_bool(scene.has_method("apply_arena_damage_zone_contact")).is_true()
	assert_bool(scene.has_method("advance_arena_hazard_time")).is_true()
	if not scene.has_method("apply_arena_damage_zone_contact") \
			or not scene.has_method("advance_arena_hazard_time"):
		return

	var electric_leak: Area2D = _spawn_electric_leak()
	var player: Node = scene.get_node("Player")
	var start_hp: int = int(player.call("get_current_hp"))

	assert_bool(bool(scene.call("apply_arena_damage_zone_contact", electric_leak, player))).is_true()
	scene.call("advance_arena_hazard_time", EXPECTED_CONTACT_COOLDOWN_SEC - 0.1)
	assert_bool(bool(scene.call("apply_arena_damage_zone_contact", electric_leak, player))).is_false()
	scene.call("advance_arena_hazard_time", 0.1)
	assert_bool(bool(scene.call("apply_arena_damage_zone_contact", electric_leak, player))).is_true()

	assert_int(start_hp - int(player.call("get_current_hp"))).is_equal(
		EXPECTED_ELECTRIC_LEAK_DAMAGE * 2
	)


func test_electric_leak_sustained_overlap_ticks_after_cooldown() -> void:
	assert_bool(scene.has_method("apply_arena_damage_zone_contact")).is_true()
	assert_bool(scene.has_method("advance_arena_hazard_time")).is_true()
	if not scene.has_method("apply_arena_damage_zone_contact") \
			or not scene.has_method("advance_arena_hazard_time"):
		return

	var electric_leak: Area2D = _spawn_electric_leak()
	var player: Node = scene.get_node("Player")
	var collision: CollisionComponent = player.call("get_collision_component") as CollisionComponent
	assert_object(collision).is_not_null()
	if collision == null:
		return
	var hurtbox: Area2D = collision.get_hurtbox()
	assert_object(hurtbox).is_not_null()
	if hurtbox == null:
		return
	var start_hp: int = int(player.call("get_current_hp"))
	assert_bool(bool(scene.call("apply_arena_damage_zone_contact", electric_leak, player))).is_true()

	electric_leak.global_position = hurtbox.global_position
	await get_tree().physics_frame
	await get_tree().physics_frame
	scene.call("advance_arena_hazard_time", EXPECTED_CONTACT_COOLDOWN_SEC)

	assert_int(start_hp - int(player.call("get_current_hp"))).is_equal(
		EXPECTED_ELECTRIC_LEAK_DAMAGE * 2
	)


func test_electric_leak_cleanup_clears_contact_cooldown_state() -> void:
	assert_bool(scene.has_method("apply_arena_damage_zone_contact")).is_true()
	if not scene.has_method("apply_arena_damage_zone_contact"):
		return

	var electric_leak: Area2D = _spawn_electric_leak()
	var player: Node = scene.get_node("Player")
	var start_hp: int = int(player.call("get_current_hp"))

	assert_bool(bool(scene.call("apply_arena_damage_zone_contact", electric_leak, player))).is_true()
	scene.call("cleanup_arena_mutations", RAT_KING_BOSS_ID)
	assert_int((scene.call("get_arena_mutation_nodes") as Array).size()).is_equal(0)

	scene.call("apply_arena_changes", RAT_KING_BOSS_ID, 3, [{
		"id": "electric_leak",
		"type": "damage_zone",
	}])
	var reapplied_leak: Area2D = _find_mutation(&"electric_leak") as Area2D
	assert_object(reapplied_leak).is_not_null()
	if reapplied_leak == null:
		return

	assert_bool(bool(scene.call("apply_arena_damage_zone_contact", reapplied_leak, player))).is_true()
	assert_int(start_hp - int(player.call("get_current_hp"))).is_equal(
		EXPECTED_ELECTRIC_LEAK_DAMAGE * 2
	)


func _spawn_electric_leak() -> Area2D:
	var enemy := scene.get_node("Enemy")
	_damage_boss_and_advance(enemy, PHASE_TWO_DAMAGE)
	_damage_boss_and_advance(enemy, PHASE_THREE_DAMAGE)

	var electric_leak: Area2D = _find_mutation(&"electric_leak") as Area2D
	assert_object(electric_leak).is_not_null()
	if electric_leak == null:
		return null
	assert_str(String(electric_leak.get_meta(&"change_type", &""))).is_equal("damage_zone")
	return electric_leak


func _damage_boss_and_advance(enemy: Node, damage: int) -> void:
	var health: HealthComponent = enemy.call("get_health_component") as HealthComponent
	assert_object(health).is_not_null()
	if health == null:
		return
	health.apply_damage(damage, {"source": &"electric_leak_contact_test"})
	enemy.call("advance_boss_runtime", 0.0)
	enemy.call("advance_boss_runtime", PHASE_TRANSITION_BUFFER_SEC)


func _find_mutation(change_id: StringName) -> Node:
	var mutations: Array = scene.call("get_arena_mutation_nodes")
	for mutation: Node in mutations:
		if StringName(String(mutation.get_meta(&"change_id", &""))) == change_id:
			return mutation
	return null
