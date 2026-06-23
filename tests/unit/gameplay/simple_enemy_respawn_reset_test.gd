## SimpleEnemy respawn snapshot and restore tests.
extends GdUnitTestSuite

const SIMPLE_ENEMY_SCENE: PackedScene = preload("res://src/gameplay/simple_enemy.tscn")

var enemy: SimpleEnemy


func before_test() -> void:
	enemy = SIMPLE_ENEMY_SCENE.instantiate()
	add_child(enemy)
	enemy.global_position = Vector2(400, 220)


func after_test() -> void:
	if is_instance_valid(enemy):
		if enemy.get_parent() != null:
			enemy.get_parent().remove_child(enemy)
		enemy.free()
	enemy = null


func test_restore_respawn_snapshot_resets_hp_position_and_collision() -> void:
	var entry_snapshot: Dictionary = enemy.capture_respawn_snapshot()

	enemy.take_damage()
	enemy.take_damage()
	enemy.global_position = Vector2(520, 180)
	enemy.collision_layer = 0
	enemy.collision_mask = 0

	enemy.restore_respawn_snapshot(entry_snapshot)

	assert_int(enemy.get_current_hp()).is_equal(enemy.get_max_hp())
	assert_vector(enemy.global_position).is_equal(Vector2(400, 220))
	assert_int(enemy.collision_layer).is_equal(2)
	assert_int(enemy.collision_mask).is_equal(17)
