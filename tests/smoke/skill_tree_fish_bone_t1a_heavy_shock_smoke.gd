extends SceneTree

const MAIN_SCENE_PATH: String = "res://scenes/main.tscn"
const FISH_BONE_T1A_SKILL_ID: StringName = &"fish_bone_t1a"
const FISH_BONE_WEAPON_ID: StringName = &"fish_bone"
const FISH_BONE_HEAVY_HITBOX_ID: StringName = &"fish_bone_heavy"
const RAT_KING_BOSS_ID: StringName = &"boss_01_rat_king"
const RAT_MINION_SUMMON_ID: StringName = &"summon_minion"
const MIN_CHARGE_SEC: float = 0.5
const EXPECTED_KNOCKBACK_PX: float = 8.0
const TARGET_TEST_HP: int = 100


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_disable_runtime_audio_playback()
	var packed: PackedScene = load(MAIN_SCENE_PATH) as PackedScene
	if packed == null:
		_fail("main_scene_missing")
		return
	var main: Node2D = packed.instantiate() as Node2D
	root.add_child(main)
	await process_frame

	main.call("grant_skill_points", 1)
	if not bool(main.call("try_unlock_skill", FISH_BONE_T1A_SKILL_ID)):
		_fail("skill_purchase_failed")
		return
	if not bool(main.call("request_summon", RAT_KING_BOSS_ID, RAT_MINION_SUMMON_ID)):
		_fail("rat_minion_spawn_failed")
		return
	var minions: Array = main.call("get_summoned_minion_nodes")
	if minions.size() != 1:
		_fail("rat_minion_count_mismatch")
		return
	var minion: CharacterBody2D = minions[0] as CharacterBody2D
	var player: Node = main.get_node_or_null("Player")
	var presentation: Node = main.get_node_or_null("CombatPresentation")
	if minion == null or player == null or presentation == null:
		_fail("runtime_nodes_missing")
		return
	var minion_health: HealthComponent = minion.get_node_or_null("HealthComponent") as HealthComponent
	if minion_health == null:
		_fail("rat_minion_health_missing")
		return
	minion_health.configure(
		int(minion.call("get_entity_id")),
		TARGET_TEST_HP,
		TARGET_TEST_HP,
		0,
		0,
		false
	)
	minion.set_physics_process(false)
	main.call("set_current_weapon_id", FISH_BONE_WEAPON_ID)
	var player_collision: CollisionComponent = player.call("get_collision_component")
	var minion_collision: CollisionComponent = minion.call("get_collision_component")
	var start_x: float = minion.global_position.x

	if not bool(player.call("request_heavy_attack_press")):
		_fail("heavy_charge_start_failed")
		return
	player.call("advance_heavy_charge_time", MIN_CHARGE_SEC)
	if not bool(player.call("request_heavy_attack_release")):
		_fail("heavy_release_failed")
		return
	var hitbox: Area2D = player_collision.call("get_hitbox", FISH_BONE_HEAVY_HITBOX_ID)
	var attack_metadata: Dictionary = hitbox.call("get_attack_metadata")
	if not is_equal_approx(
		float(attack_metadata.get("skill_knockback_px", 0.0)),
		EXPECTED_KNOCKBACK_PX
	):
		_fail("heavy_skill_metadata_missing")
		return

	var overlaps: Dictionary = {
		FISH_BONE_HEAVY_HITBOX_ID: [minion_collision.call("get_hurtbox")],
	}
	player_collision.call("process_detection_frame", overlaps)
	var first_displacement: float = minion.global_position.x - start_x
	player_collision.call("process_detection_frame", overlaps)
	var duplicate_displacement: float = minion.global_position.x - start_x
	var hit_metadata: Dictionary = main.call("get_last_player_hit_metadata")
	var fish_vfx: Dictionary = presentation.call("get_weapon_vfx_snapshot", FISH_BONE_WEAPON_ID)
	var snapshot: Dictionary = main.call("capture_save_snapshot")
	var player_state: Dictionary = Dictionary(snapshot.get("player_state", {}))
	var unlocked: Array = Array(player_state.get("unlocked_skills", []))

	print("story150_attack_metadata=", JSON.stringify(attack_metadata))
	print("story150_hit_metadata=", JSON.stringify(hit_metadata))
	print("story150_displacement=", first_displacement)
	if (
		not is_equal_approx(first_displacement, EXPECTED_KNOCKBACK_PX)
		or not is_equal_approx(duplicate_displacement, EXPECTED_KNOCKBACK_PX)
		or not bool(hit_metadata.get("knockback_applied", false))
		or not is_equal_approx(
			float(hit_metadata.get("knockback_applied_px", 0.0)),
			EXPECTED_KNOCKBACK_PX
		)
		or int(minion.call("get_current_hp")) <= 0
		or int(fish_vfx.get("count", 0)) != 2
		or not unlocked.has(String(FISH_BONE_T1A_SKILL_ID))
	):
		_fail("runtime_contract_failed")
		return

	_stop_runtime_audio_players()
	hitbox = null
	player_collision = null
	minion_collision = null
	minion = null
	player = null
	presentation = null
	main.get_parent().remove_child(main)
	main.free()
	main = null
	packed = null
	await process_frame
	await create_timer(0.12).timeout
	print("skill_tree_fish_bone_t1a_heavy_shock_smoke=passed")
	quit(0)


func _disable_runtime_audio_playback() -> void:
	var audio_system: Node = root.get_node_or_null("AudioSystem")
	if (
		audio_system == null
		or not audio_system.has_method("get_registered_audio_stream_ids")
		or not audio_system.has_method("unregister_audio_stream")
	):
		return
	var audio_ids: Array = audio_system.call("get_registered_audio_stream_ids")
	for audio_id: Variant in audio_ids:
		audio_system.call("unregister_audio_stream", StringName(audio_id))


func _stop_runtime_audio_players() -> void:
	var audio_system: Node = root.get_node_or_null("AudioSystem")
	if audio_system == null:
		return
	if audio_system.has_method("stop_music"):
		audio_system.call("stop_music", 0.0)
	if audio_system.has_method("stop_ambient"):
		audio_system.call("stop_ambient", 0.0)
	for child: Node in audio_system.get_children():
		if child is AudioStreamPlayer:
			var audio_player := child as AudioStreamPlayer
			audio_player.stop()
			audio_player.stream = null
		elif child is AudioStreamPlayer2D:
			var positional_audio_player := child as AudioStreamPlayer2D
			positional_audio_player.stop()
			positional_audio_player.stream = null


func _fail(reason: String) -> void:
	push_error("skill_tree_fish_bone_t1a_heavy_shock_smoke=" + reason)
	quit(1)
