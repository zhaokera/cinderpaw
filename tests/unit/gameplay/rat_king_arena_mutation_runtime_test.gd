## Rat King boss arena mutation runtime integration.
extends GdUnitTestSuite

const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")
const RAT_KING_BOSS_ID: StringName = &"boss_01_rat_king"
const PHASE_TWO_DAMAGE: int = 120
const PHASE_THREE_DAMAGE: int = 120
const PHASE_TRANSITION_BUFFER_SEC: float = 3.0
const ARENA_MUTATION_TEXTURE_PATHS: Dictionary = {
	"garbage_pile": "res://assets/environment/rat_king_arena/garbage_pile.png",
	"overturned_trash_can": "res://assets/environment/rat_king_arena/overturned_trash_can.png",
	"electric_leak": "res://assets/environment/rat_king_arena/electric_leak.png",
}

var scene: Node2D


func after_test() -> void:
	if is_instance_valid(scene):
		if scene.get_parent() != null:
			scene.get_parent().remove_child(scene)
		scene.free()
	scene = null


func test_main_scene_exposes_boss_arena_mutation_adapter_contract() -> void:
	scene = MAIN_SCENE.instantiate() as Node2D
	add_child(scene)

	assert_bool(scene.has_method("apply_arena_changes")).is_true()
	assert_bool(scene.has_method("get_arena_mutation_nodes")).is_true()
	assert_bool(scene.has_method("cleanup_arena_mutations")).is_true()
	assert_object(scene.get_node_or_null("ArenaMutations")).is_not_null()


func test_phase_two_creates_garbage_pile_obstacle_runtime_node() -> void:
	scene = MAIN_SCENE.instantiate() as Node2D
	add_child(scene)
	_assert_arena_mutation_contract(scene)

	var enemy := scene.get_node("Enemy")
	_enter_phase_two(enemy)

	var mutations: Array = scene.call("get_arena_mutation_nodes")
	assert_int(mutations.size()).is_equal(1)
	var garbage_pile := _find_mutation(mutations, &"garbage_pile")
	_assert_mutation_node(
		garbage_pile,
		&"garbage_pile",
		&"obstacle",
		2,
		StaticBody2D
	)


func test_phase_three_creates_overturned_trash_and_electric_leak_once() -> void:
	scene = MAIN_SCENE.instantiate() as Node2D
	add_child(scene)
	_assert_arena_mutation_contract(scene)

	var enemy := scene.get_node("Enemy")
	_enter_phase_two(enemy)
	_enter_phase_three(enemy)
	enemy.call("advance_boss_runtime", PHASE_TRANSITION_BUFFER_SEC)

	var mutations: Array = scene.call("get_arena_mutation_nodes")
	assert_int(mutations.size()).is_equal(3)
	_assert_mutation_node(
		_find_mutation(mutations, &"garbage_pile"),
		&"garbage_pile",
		&"obstacle",
		2,
		StaticBody2D
	)
	_assert_mutation_node(
		_find_mutation(mutations, &"overturned_trash_can"),
		&"overturned_trash_can",
		&"obstacle",
		3,
		StaticBody2D
	)
	_assert_mutation_node(
		_find_mutation(mutations, &"electric_leak"),
		&"electric_leak",
		&"damage_zone",
		3,
		Area2D
	)


func test_boss_death_and_arena_reset_clear_arena_mutations() -> void:
	scene = MAIN_SCENE.instantiate() as Node2D
	add_child(scene)
	_assert_arena_mutation_contract(scene)

	var enemy := scene.get_node("Enemy")
	var snapshot: Dictionary = scene.call("capture_boss_arena_snapshot")
	_enter_phase_two(enemy)
	_enter_phase_three(enemy)
	assert_int((scene.call("get_arena_mutation_nodes") as Array).size()).is_equal(3)

	scene.call("reset_boss_arena_to_snapshot", snapshot)
	assert_int((scene.call("get_arena_mutation_nodes") as Array).size()).is_equal(0)

	enemy = scene.get_node("Enemy")
	_enter_phase_two(enemy)
	assert_int((scene.call("get_arena_mutation_nodes") as Array).size()).is_equal(1)

	var health: HealthComponent = enemy.call("get_health_component") as HealthComponent
	assert_object(health).is_not_null()
	if health == null:
		return
	health.apply_damage(999, {"source": &"arena_mutation_cleanup_test"})
	assert_int((scene.call("get_arena_mutation_nodes") as Array).size()).is_equal(0)


func _assert_arena_mutation_contract(main_scene: Node) -> void:
	assert_bool(main_scene.has_method("apply_arena_changes")).is_true()
	assert_bool(main_scene.has_method("get_arena_mutation_nodes")).is_true()
	assert_bool(main_scene.has_method("cleanup_arena_mutations")).is_true()


func _enter_phase_two(enemy: Node) -> void:
	_damage_boss_and_advance(enemy, PHASE_TWO_DAMAGE)


func _enter_phase_three(enemy: Node) -> void:
	_damage_boss_and_advance(enemy, PHASE_THREE_DAMAGE)


func _damage_boss_and_advance(enemy: Node, damage: int) -> void:
	var health: HealthComponent = enemy.call("get_health_component") as HealthComponent
	assert_object(health).is_not_null()
	if health == null:
		return
	health.apply_damage(damage, {"source": &"arena_mutation_test"})
	enemy.call("advance_boss_runtime", 0.0)
	enemy.call("advance_boss_runtime", PHASE_TRANSITION_BUFFER_SEC)


func _find_mutation(mutations: Array, change_id: StringName) -> Node:
	for mutation: Node in mutations:
		if StringName(String(mutation.get_meta(&"change_id", &""))) == change_id:
			return mutation
	return null


func _assert_mutation_node(
	mutation: Node,
	change_id: StringName,
	change_type: StringName,
	phase: int,
	expected_class: Variant
) -> void:
	assert_object(mutation).is_not_null()
	if mutation == null:
		return
	assert_bool(is_instance_of(mutation, expected_class)).is_true()
	assert_bool(mutation.is_visible_in_tree()).is_true()
	assert_str(String(mutation.get_meta(&"boss_id", &""))).is_equal(String(RAT_KING_BOSS_ID))
	assert_str(String(mutation.get_meta(&"change_id", &""))).is_equal(String(change_id))
	assert_str(String(mutation.get_meta(&"change_type", &""))).is_equal(String(change_type))
	assert_int(int(mutation.get_meta(&"phase", 0))).is_equal(phase)
	assert_object(mutation.get_node_or_null("CollisionShape2D")).is_not_null()
	var sprite: Node = mutation.get_node_or_null("Sprite")
	assert_bool(sprite is Sprite2D).is_true()
	if sprite is Sprite2D:
		var texture: Texture2D = (sprite as Sprite2D).texture
		assert_object(texture).is_not_null()
		if texture != null:
			assert_str(texture.resource_path).is_equal(
				String(ARENA_MUTATION_TEXTURE_PATHS[String(change_id)])
			)
	_assert_no_visible_placeholder_visual(mutation)


func _assert_no_visible_placeholder_visual(mutation: Node) -> void:
	for child: Node in mutation.get_children():
		if child is Polygon2D or child is ColorRect:
			assert_bool((child as CanvasItem).visible).is_false()
