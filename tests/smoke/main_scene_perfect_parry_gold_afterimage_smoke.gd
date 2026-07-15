## Headless Story016 smoke for the real Main perfect-parry gold silhouette.
extends SceneTree

const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var main := MAIN_SCENE.instantiate() as Node2D
	root.add_child(main)
	await process_frame

	var player: PlayerController = main.get_node("Player") as PlayerController
	var presentation: Node = main.get_node("CombatPresentation")
	var audio_system: Node = root.get_node_or_null("AudioSystem")
	if player == null or presentation == null:
		_fail("runtime_nodes_missing")
		return

	presentation.set_process(false)
	var combat: CombatComponent = player.get_combat_component()
	var sprite: AnimatedSprite2D = player.get_node("Sprite") as AnimatedSprite2D
	if combat == null or sprite == null or not player.request_parry():
		_fail("player_parry_start_failed")
		return
	var metadata: Dictionary = combat.resolve_parry_result()
	var diagnostics: Dictionary = Dictionary(
		presentation.call("get_last_perfect_parry_afterimage_diagnostics")
	)
	var afterimage: Sprite2D = presentation.get_node_or_null(
		"PerfectParryGoldAfterimage"
	) as Sprite2D
	if (
		String(metadata.get("parry_type", &"")) != "perfect"
		or String(sprite.animation) != "parry"
		or not sprite.sprite_frames.has_animation(&"parry")
		or sprite.sprite_frames.get_frame_count(&"parry") < 3
		or int(presentation.call("get_active_perfect_parry_afterimage_count")) != 1
		or afterimage == null
		or afterimage.texture == null
		or afterimage.texture != sprite.sprite_frames.get_frame_texture(
			sprite.animation,
			sprite.frame
		)
		or not afterimage.material is ShaderMaterial
		or String(diagnostics.get("color_hex", "")) != "ecc94b"
		or diagnostics.get("source_position", Vector2.ZERO) != sprite.global_position
		or diagnostics.get("position", Vector2.ZERO)
		!= sprite.global_position - Vector2(12.0, 0.0)
		or int(presentation.call("get_active_flash_count")) != 1
		or int(presentation.call("get_active_parry_spark_count")) < 20
	):
		_fail("perfect_parry_feedback_contract_failed")
		return

	presentation.call("advance_time", 0.35)
	if int(presentation.call("get_active_perfect_parry_afterimage_count")) != 0:
		_fail("perfect_parry_afterimage_expiry_failed")
		return

	print(
		"main_scene_perfect_parry_gold_afterimage_diagnostics=",
		JSON.stringify(diagnostics)
	)
	print("main_scene_perfect_parry_gold_afterimage_smoke=passed")
	_stop_runtime_audio_players(audio_system)
	if main.get_parent() != null:
		main.get_parent().remove_child(main)
	main.free()
	await process_frame
	quit(0)


func _stop_runtime_audio_players(audio_system: Node) -> void:
	if audio_system == null:
		return
	for child: Node in audio_system.get_children():
		if child is AudioStreamPlayer:
			var player := child as AudioStreamPlayer
			player.stop()
			player.stream = null
		elif child is AudioStreamPlayer2D:
			var player_2d := child as AudioStreamPlayer2D
			player_2d.stop()
			player_2d.stream = null


func _fail(reason: String) -> void:
	push_error("main_scene_perfect_parry_gold_afterimage_smoke=" + reason)
	quit(1)
