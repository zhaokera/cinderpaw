extends SceneTree

const MAIN_SCENE_PATH: String = "res://scenes/main.tscn"
const ELECTRO_BELL_T1A_SKILL_ID: StringName = &"electro_bell_t1a"
const ELECTRO_BELL_WEAPON_ID: StringName = &"electro_bell"
const ELECTRO_BELL_HITBOX_ID: StringName = &"electro_bell_light"
const BASE_SLOW_DURATION_SEC: float = 2.0
const PULSE_DURATION_SEC: float = 0.5


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
	if not bool(main.call("try_unlock_skill", ELECTRO_BELL_T1A_SKILL_ID)):
		_fail("skill_purchase_failed")
		return
	main.call("set_current_weapon_id", ELECTRO_BELL_WEAPON_ID)
	var player: Node = main.get_node_or_null("Player")
	var enemy: Node = main.get_node_or_null("Enemy")
	var weapons: WeaponComponent = main.get_node_or_null("WeaponComponent") as WeaponComponent
	var presentation: Node = main.get_node_or_null("CombatPresentation")
	if player == null or enemy == null or weapons == null or presentation == null:
		_fail("runtime_nodes_missing")
		return
	var player_collision: CollisionComponent = player.call("get_collision_component")
	var enemy_collision: CollisionComponent = enemy.call("get_collision_component")
	var status: StatusEffectComponent = enemy.call("get_status_effect_component")
	if player_collision == null or enemy_collision == null or status == null:
		_fail("runtime_components_missing")
		return

	if not bool(player.call("request_attack")):
		_fail("light_attack_start_failed")
		return
	var hitbox: Area2D = player_collision.call("get_hitbox", ELECTRO_BELL_HITBOX_ID)
	var attack_metadata: Dictionary = hitbox.call("get_attack_metadata")
	player_collision.call("process_detection_frame", {
		ELECTRO_BELL_HITBOX_ID: [enemy_collision.call("get_hurtbox")],
	})
	var first_hit: Dictionary = main.call("get_last_player_hit_metadata")
	var first_effects: Array = status.get_active_effects()
	var bell_vfx: Dictionary = presentation.call(
		"get_weapon_vfx_snapshot",
		ELECTRO_BELL_WEAPON_ID
	)
	if (
		not bool(first_hit.get("slow_pulse_applied", false))
		or not is_equal_approx(status.get_movement_modifier(), 0.55)
		or first_effects.size() != 1
		or int(bell_vfx.get("count", 0)) != 9
	):
		_fail("first_hit_contract_failed")
		return

	status.advance_time(0.3)
	var target_id: int = int(enemy.call("get_entity_id"))
	var baseline_refresh: Dictionary = weapons.apply_confirmed_hit_effects(enemy, {
		"attacker_id": 1,
		"target_id": target_id,
		"attack_type": &"light",
		"combo_index": 1,
		"skill_modifiers": {},
	})
	var refreshed_effect: Dictionary = status.get_active_effects()[0]
	if (
		bool(baseline_refresh.get("slow_pulse_applied", false))
		or not is_equal_approx(status.get_movement_modifier(), 0.55)
		or not is_equal_approx(status.get_remaining_duration(&"slow"), BASE_SLOW_DURATION_SEC)
		or not is_equal_approx(
			float(refreshed_effect.get("pulse_remaining_duration_sec", 0.0)),
			0.2
		)
	):
		_fail("baseline_refresh_cancelled_pulse")
		return

	status.advance_time(0.21)
	if not is_equal_approx(status.get_movement_modifier(), 0.70):
		_fail("pulse_did_not_return_to_baseline")
		return
	var repeated_metadata: Dictionary = attack_metadata.duplicate(true)
	repeated_metadata["attacker_id"] = 1
	repeated_metadata["target_id"] = target_id
	var repeated_first_hit: Dictionary = weapons.apply_confirmed_hit_effects(
		enemy,
		repeated_metadata
	)
	var repeated_effects: Array = status.get_active_effects()
	var repeated_effect: Dictionary = repeated_effects[0] if repeated_effects.size() == 1 else {}
	var snapshot: Dictionary = main.call("capture_save_snapshot")
	var player_state: Dictionary = Dictionary(snapshot.get("player_state", {}))
	var unlocked: Array = Array(player_state.get("unlocked_skills", []))

	print("story151_first_hit=", JSON.stringify(first_hit))
	print("story151_baseline_refresh=", JSON.stringify(baseline_refresh))
	print("story151_repeated_first_hit=", JSON.stringify(repeated_first_hit))
	if (
		not bool(repeated_first_hit.get("slow_pulse_applied", false))
		or repeated_effects.size() != 1
		or not is_equal_approx(status.get_movement_modifier(), 0.55)
		or not is_equal_approx(status.get_remaining_duration(&"slow"), BASE_SLOW_DURATION_SEC)
		or not is_equal_approx(
			float(repeated_effect.get("pulse_remaining_duration_sec", 0.0)),
			PULSE_DURATION_SEC
		)
		or not unlocked.has(String(ELECTRO_BELL_T1A_SKILL_ID))
	):
		_fail("repeat_refresh_or_save_contract_failed")
		return

	_stop_runtime_audio_players()
	hitbox = null
	player_collision = null
	enemy_collision = null
	status = null
	weapons = null
	enemy = null
	player = null
	presentation = null
	main.get_parent().remove_child(main)
	main.free()
	main = null
	packed = null
	await process_frame
	await create_timer(0.12).timeout
	print("skill_tree_electro_bell_t1a_pulse_touch_smoke=passed")
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
	push_error("skill_tree_electro_bell_t1a_pulse_touch_smoke=" + reason)
	quit(1)
