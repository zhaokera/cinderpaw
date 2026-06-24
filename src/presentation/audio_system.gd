## Presentation-layer audio bus, pool, and playback request coordinator.
##
## ADR-0001 defines AudioSystem as Autoload #3, after InputManager and before
## SaveSystem. Missing streams fail silently so gameplay never depends on asset
## readiness.
extends Node

signal sfx_requested(sfx_id: StringName, metadata: Dictionary)
signal music_requested(music_id: StringName, metadata: Dictionary)
signal ambient_requested(ambient_id: StringName, metadata: Dictionary)
signal bus_volume_changed(bus_name: StringName, volume_percent: int)
signal scene_transition_audio_started(scene_id: StringName, metadata: Dictionary)
signal scene_transition_audio_completed(scene_id: StringName, metadata: Dictionary)
signal scene_transition_audio_failed(scene_id: StringName, reason: StringName)

const BUS_NAMES: Array[StringName] = [&"Master", &"Music", &"SFX", &"Ambient", &"UI"]
const BUS_VOLUME_DEFAULTS: Dictionary = {
	&"Master": 80,
	&"Music": 60,
	&"SFX": 80,
	&"Ambient": 50,
	&"UI": 70,
}
const MAX_CONCURRENT_SFX: int = 16
const MAX_SFX_DISTANCE_PX: float = 600.0
const SCENE_TRANSITION_FORCE_FADE_SEC: float = 2.0
const DEFAULT_SCENE_CROSSFADE_SEC: float = 3.0
const DEFAULT_SCENE_AUDIO_CUES: Dictionary = {
	"hub": {
		"music_id": &"mus_hub",
		"ambient_id": &"amb_hub",
		"crossfade_sec": DEFAULT_SCENE_CROSSFADE_SEC,
	},
	"main": {
		"music_id": &"mus_street",
		"ambient_id": &"amb_street",
		"crossfade_sec": DEFAULT_SCENE_CROSSFADE_SEC,
	},
}

var _bus_volume_percent: Dictionary = {}
var _audio_streams: Dictionary = {}
var _scene_audio_cues: Dictionary = {}
var _sfx_players: Array[AudioStreamPlayer2D] = []
var _music_player: AudioStreamPlayer
var _ambient_player: AudioStreamPlayer
var _active_sfx_requests: Array[Dictionary] = []
var _last_sfx_request: Dictionary = {}
var _dropped_sfx_count: int = 0
var _current_music_id: StringName = &""
var _current_ambient_id: StringName = &""
var _music_fade_in_sec: float = 0.0
var _music_fade_out_sec: float = 0.0
var _ambient_fade_in_sec: float = 0.0
var _ambient_fade_out_sec: float = 0.0
var _scene_transition_audio_active: bool = false
var _scene_transition_target_scene_id: StringName = &""
var _scene_transition_spawn_point: StringName = &""
var _scene_transition_metadata: Dictionary = {}
var _scene_transition_failed_scene_id: StringName = &""
var _scene_transition_failed_reason: StringName = &""


func _ready() -> void:
	configure_scene_audio_cues(DEFAULT_SCENE_AUDIO_CUES)
	_initialize_buses()
	_initialize_audio_players()


func _exit_tree() -> void:
	for player: AudioStreamPlayer2D in _sfx_players:
		if is_instance_valid(player):
			player.stop()
	if is_instance_valid(_music_player):
		_music_player.stop()
	if is_instance_valid(_ambient_player):
		_ambient_player.stop()


## Returns the managed audio bus names in architecture order.
func get_bus_names() -> Array[StringName]:
	return BUS_NAMES.duplicate()


## Returns the current logical volume percentage for a managed bus.
func get_bus_volume_percent(bus_name: StringName) -> int:
	if not _is_managed_bus(bus_name):
		return -1
	return int(_bus_volume_percent.get(bus_name, BUS_VOLUME_DEFAULTS[bus_name]))


## Sets a managed bus volume in percent, clamped to 0..100.
func set_bus_volume(bus_name: StringName, volume_percent: int) -> bool:
	if not _is_managed_bus(bus_name):
		return false
	var clamped_volume: int = clampi(volume_percent, 0, 100)
	_bus_volume_percent[bus_name] = clamped_volume
	_apply_bus_volume(bus_name, clamped_volume)
	bus_volume_changed.emit(bus_name, clamped_volume)
	return true


## Registers an AudioStream by id for tests, tools, and later asset manifests.
func register_audio_stream(audio_id: StringName, stream: AudioStream) -> bool:
	if audio_id == &"" or stream == null:
		return false
	_audio_streams[audio_id] = stream
	return true


func unregister_audio_stream(audio_id: StringName) -> bool:
	if not _audio_streams.has(audio_id):
		return false
	_audio_streams.erase(audio_id)
	return true


func get_max_concurrent_sfx() -> int:
	return MAX_CONCURRENT_SFX


func get_sfx_pool_size() -> int:
	return _sfx_players.size()


func get_active_sfx_count() -> int:
	return _active_sfx_requests.size()


func get_dropped_sfx_count() -> int:
	return _dropped_sfx_count


func get_last_sfx_request() -> Dictionary:
	return _last_sfx_request.duplicate(true)


## Plays or records an SFX request. Missing streams return false without errors.
func play_sfx(
	sfx_id: StringName,
	position: Vector2 = Vector2.ZERO,
	volume_db: float = 0.0,
	pitch_offset: float = 0.0,
	priority: int = 0
) -> bool:
	var pitch_scale: float = _pitch_offset_to_scale(pitch_offset)
	var request: Dictionary = {
		"sfx_id": sfx_id,
		"position": position,
		"volume_db": volume_db,
		"pitch_offset": pitch_offset,
		"pitch_scale": pitch_scale,
		"priority": priority,
		"timestamp_ms": Time.get_ticks_msec(),
		"stream_found": _audio_streams.has(sfx_id),
	}
	_last_sfx_request = request.duplicate(true)
	sfx_requested.emit(sfx_id, request.duplicate(true))

	var stream: AudioStream = _audio_streams.get(sfx_id, null)
	if stream == null:
		return false

	var player_index: int = _reserve_sfx_player(priority)
	if player_index < 0:
		_dropped_sfx_count += 1
		return false

	request["player_index"] = player_index
	_active_sfx_requests.append(request.duplicate(true))
	_last_sfx_request = request.duplicate(true)
	_play_sfx_player(player_index, stream, position, volume_db, pitch_scale)
	return true


## Requests music playback and records fade metadata even when no stream exists.
func play_music(music_id: StringName, fade_in_sec: float = 1.0) -> bool:
	_current_music_id = music_id
	_music_fade_in_sec = maxf(0.0, fade_in_sec)
	_music_fade_out_sec = 0.0
	var metadata: Dictionary = {
		"music_id": music_id,
		"fade_in_sec": _music_fade_in_sec,
		"stream_found": _audio_streams.has(music_id),
	}
	music_requested.emit(music_id, metadata.duplicate(true))
	var stream: AudioStream = _audio_streams.get(music_id, null)
	if stream == null:
		return false
	_music_player.stream = stream
	_music_player.bus = "Music"
	_music_player.play()
	return true


func stop_music(fade_out_sec: float = 1.0) -> void:
	_music_fade_out_sec = maxf(0.0, fade_out_sec)
	_current_music_id = &""
	if is_instance_valid(_music_player):
		_music_player.stop()


func get_current_music_id() -> StringName:
	return _current_music_id


func get_music_fade_in_sec() -> float:
	return _music_fade_in_sec


func get_music_fade_out_sec() -> float:
	return _music_fade_out_sec


## Requests ambience playback and records fade metadata even when no stream exists.
func play_ambient(ambient_id: StringName, fade_in_sec: float = 1.0) -> bool:
	_current_ambient_id = ambient_id
	_ambient_fade_in_sec = maxf(0.0, fade_in_sec)
	_ambient_fade_out_sec = 0.0
	var metadata: Dictionary = {
		"ambient_id": ambient_id,
		"fade_in_sec": _ambient_fade_in_sec,
		"stream_found": _audio_streams.has(ambient_id),
	}
	ambient_requested.emit(ambient_id, metadata.duplicate(true))
	var stream: AudioStream = _audio_streams.get(ambient_id, null)
	if stream == null:
		return false
	_ambient_player.stream = stream
	_ambient_player.bus = "Ambient"
	_ambient_player.play()
	return true


func stop_ambient(fade_out_sec: float = 2.0) -> void:
	_ambient_fade_out_sec = maxf(0.0, fade_out_sec)
	_current_ambient_id = &""
	if is_instance_valid(_ambient_player):
		_ambient_player.stop()


func get_current_ambient_id() -> StringName:
	return _current_ambient_id


func get_ambient_fade_in_sec() -> float:
	return _ambient_fade_in_sec


func get_ambient_fade_out_sec() -> float:
	return _ambient_fade_out_sec


func configure_scene_audio_cues(scene_audio_cues: Dictionary) -> void:
	_scene_audio_cues.clear()
	for scene_key: Variant in scene_audio_cues.keys():
		var cue: Variant = scene_audio_cues.get(scene_key)
		if not cue is Dictionary:
			continue
		_scene_audio_cues[String(scene_key)] = _normalize_scene_audio_cue(Dictionary(cue))


func get_scene_audio_cue(scene_id: StringName) -> Dictionary:
	return Dictionary(_scene_audio_cues.get(String(scene_id), {})).duplicate(true)


func is_scene_transition_audio_active() -> bool:
	return _scene_transition_audio_active


func get_scene_transition_audio_state() -> Dictionary:
	return {
		"active": _scene_transition_audio_active,
		"target_scene_id": _scene_transition_target_scene_id,
		"spawn_point": _scene_transition_spawn_point,
		"metadata": _scene_transition_metadata.duplicate(true),
		"failed_scene_id": _scene_transition_failed_scene_id,
		"failed_reason": _scene_transition_failed_reason,
	}


func on_scene_load_started(
	scene_id: StringName,
	spawn_point: StringName,
	metadata: Dictionary
) -> void:
	_scene_transition_audio_active = true
	_scene_transition_target_scene_id = scene_id
	_scene_transition_spawn_point = spawn_point
	_scene_transition_metadata = metadata.duplicate(true)
	_scene_transition_failed_scene_id = &""
	_scene_transition_failed_reason = &""
	stop_music(SCENE_TRANSITION_FORCE_FADE_SEC)
	stop_ambient(SCENE_TRANSITION_FORCE_FADE_SEC)
	scene_transition_audio_started.emit(scene_id, get_scene_transition_audio_state())


func on_scene_changed(_old_scene: StringName, new_scene: StringName) -> void:
	_scene_transition_audio_active = false
	_scene_transition_target_scene_id = new_scene
	var cue: Dictionary = get_scene_audio_cue(new_scene)
	var crossfade_sec: float = maxf(
		0.0,
		float(cue.get("crossfade_sec", DEFAULT_SCENE_CROSSFADE_SEC))
	)
	var music_id: StringName = StringName(String(cue.get("music_id", "")))
	var ambient_id: StringName = StringName(String(cue.get("ambient_id", "")))
	if music_id != &"":
		play_music(music_id, crossfade_sec)
	if ambient_id != &"":
		play_ambient(ambient_id, crossfade_sec)
	scene_transition_audio_completed.emit(new_scene, get_scene_transition_audio_state())


func on_scene_load_failed(scene_id: StringName, reason: StringName) -> void:
	_scene_transition_audio_active = false
	_scene_transition_failed_scene_id = scene_id
	_scene_transition_failed_reason = reason
	scene_transition_audio_failed.emit(scene_id, reason)


func _initialize_buses() -> void:
	for bus_name: StringName in BUS_NAMES:
		var default_volume: int = int(BUS_VOLUME_DEFAULTS[bus_name])
		_bus_volume_percent[bus_name] = default_volume
		_ensure_bus(bus_name)
		_apply_bus_volume(bus_name, default_volume)


func _initialize_audio_players() -> void:
	if _music_player == null:
		_music_player = AudioStreamPlayer.new()
		_music_player.name = "MusicPlayer"
		_music_player.bus = "Music"
		add_child(_music_player)
	if _ambient_player == null:
		_ambient_player = AudioStreamPlayer.new()
		_ambient_player.name = "AmbientPlayer"
		_ambient_player.bus = "Ambient"
		add_child(_ambient_player)
	while _sfx_players.size() < MAX_CONCURRENT_SFX:
		var player := AudioStreamPlayer2D.new()
		player.name = "SFXPlayer%02d" % _sfx_players.size()
		player.bus = "SFX"
		player.max_distance = MAX_SFX_DISTANCE_PX
		_sfx_players.append(player)
		add_child(player)


func _ensure_bus(bus_name: StringName) -> int:
	var bus_index: int = AudioServer.get_bus_index(bus_name)
	if bus_index >= 0:
		if bus_name != &"Master":
			AudioServer.set_bus_send(bus_index, &"Master")
		return bus_index
	AudioServer.add_bus(AudioServer.get_bus_count())
	bus_index = AudioServer.get_bus_count() - 1
	AudioServer.set_bus_name(bus_index, String(bus_name))
	if bus_name != &"Master":
		AudioServer.set_bus_send(bus_index, &"Master")
	return bus_index


func _apply_bus_volume(bus_name: StringName, volume_percent: int) -> void:
	var bus_index: int = _ensure_bus(bus_name)
	if bus_index < 0:
		return
	AudioServer.set_bus_volume_linear(bus_index, float(volume_percent) / 100.0)


func _pitch_offset_to_scale(pitch_offset: float) -> float:
	return pow(2.0, pitch_offset / 12.0)


func _reserve_sfx_player(priority: int) -> int:
	_prune_finished_sfx_requests()
	for index: int in range(_sfx_players.size()):
		if not _sfx_players[index].playing:
			return index
	if _active_sfx_requests.size() < MAX_CONCURRENT_SFX:
		return _active_sfx_requests.size()

	var lowest_priority_index: int = _lowest_priority_request_index()
	if lowest_priority_index < 0:
		return -1
	var lowest_priority: int = int(_active_sfx_requests[lowest_priority_index].get("priority", 0))
	if priority < lowest_priority:
		return -1

	var player_index: int = int(_active_sfx_requests[lowest_priority_index].get("player_index", -1))
	_active_sfx_requests.remove_at(lowest_priority_index)
	_dropped_sfx_count += 1
	return player_index


func _play_sfx_player(
	player_index: int,
	stream: AudioStream,
	world_position: Vector2,
	volume_db: float,
	pitch_scale: float
) -> void:
	if player_index < 0 or player_index >= _sfx_players.size():
		return
	var player: AudioStreamPlayer2D = _sfx_players[player_index]
	player.stop()
	player.stream = stream
	player.global_position = world_position
	player.volume_db = volume_db
	player.pitch_scale = pitch_scale
	player.bus = "SFX"
	player.play()


func _prune_finished_sfx_requests() -> void:
	for index: int in range(_active_sfx_requests.size() - 1, -1, -1):
		var player_index: int = int(_active_sfx_requests[index].get("player_index", -1))
		if player_index < 0 or player_index >= _sfx_players.size():
			_active_sfx_requests.remove_at(index)
			continue
		if not _sfx_players[player_index].playing:
			_active_sfx_requests.remove_at(index)


func _lowest_priority_request_index() -> int:
	var lowest_index: int = -1
	var lowest_priority: int = 0
	for index: int in range(_active_sfx_requests.size()):
		var request_priority: int = int(_active_sfx_requests[index].get("priority", 0))
		if lowest_index < 0 or request_priority < lowest_priority:
			lowest_index = index
			lowest_priority = request_priority
	return lowest_index


func _is_managed_bus(bus_name: StringName) -> bool:
	return BUS_VOLUME_DEFAULTS.has(bus_name)


func _normalize_scene_audio_cue(cue: Dictionary) -> Dictionary:
	return {
		"music_id": StringName(String(cue.get("music_id", ""))),
		"ambient_id": StringName(String(cue.get("ambient_id", ""))),
		"crossfade_sec": maxf(
			0.0,
			float(cue.get("crossfade_sec", DEFAULT_SCENE_CROSSFADE_SEC))
		),
	}
