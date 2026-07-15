## Audio System Story010: low-HP focus damage damped final mix asset contract.
extends GdUnitTestSuite

const NORMAL_DAMAGE_PATH: String = "res://assets/audio/sfx/sfx_damage_taken.wav"
const LOW_HP_DAMAGE_PATH: String = "res://assets/audio/sfx/sfx_damage_taken_lowhp.wav"
const SOURCE_MANIFEST_PATH: String = (
	"res://assets/audio/source/focus_damage_lowhp_final_mix_20260714.json"
)
const STORY005_LOW_HP_BASELINE_SHA256: String = (
	"4c4ad0579a6edb60402ae91ca1c59ef257b69a2c0936cfe1e5779c6e615d1397"
)


func test_low_hp_damage_cue_uses_traced_damped_final_mix_asset() -> void:
	assert_bool(FileAccess.file_exists(NORMAL_DAMAGE_PATH)).is_true()
	assert_bool(FileAccess.file_exists(LOW_HP_DAMAGE_PATH)).is_true()
	if (
		not FileAccess.file_exists(NORMAL_DAMAGE_PATH)
		or not FileAccess.file_exists(LOW_HP_DAMAGE_PATH)
	):
		return

	var normal: Dictionary = _read_pcm16_mono_wav(NORMAL_DAMAGE_PATH)
	var low_hp: Dictionary = _read_pcm16_mono_wav(LOW_HP_DAMAGE_PATH)
	assert_bool(not normal.is_empty()).is_true()
	assert_bool(not low_hp.is_empty()).is_true()
	if normal.is_empty() or low_hp.is_empty():
		return

	assert_int(int(low_hp["audio_format"])).is_equal(1)
	assert_int(int(low_hp["channels"])).is_equal(1)
	assert_int(int(low_hp["sample_rate_hz"])).is_equal(44100)
	assert_int(int(low_hp["bits_per_sample"])).is_equal(16)

	var normal_hash: String = _sha256_file(NORMAL_DAMAGE_PATH)
	var low_hp_hash: String = _sha256_file(LOW_HP_DAMAGE_PATH)
	assert_str(low_hp_hash).is_not_equal(normal_hash)
	assert_str(low_hp_hash).override_failure_message(
		"Story010 must replace the known Story005 low-HP procedural baseline."
	).is_not_equal(STORY005_LOW_HP_BASELINE_SHA256)

	var normal_samples: PackedFloat32Array = normal["samples"]
	var low_hp_samples: PackedFloat32Array = low_hp["samples"]
	var sample_rate: int = int(low_hp["sample_rate_hz"])
	var duration_sec: float = float(low_hp_samples.size()) / float(sample_rate)
	var normal_rms_db: float = _rms_db(normal_samples, 0, normal_samples.size())
	var low_hp_rms_db: float = _rms_db(low_hp_samples, 0, low_hp_samples.size())
	var tail_start: int = int(round(0.16 * sample_rate))
	var final_start: int = maxi(0, low_hp_samples.size() - int(round(0.01 * sample_rate)))
	var tail_rms_db: float = _rms_db(low_hp_samples, tail_start, low_hp_samples.size())
	var final_rms_db: float = _rms_db(low_hp_samples, final_start, low_hp_samples.size())
	var normal_roughness: float = _difference_rms_ratio(normal_samples)
	var low_hp_roughness: float = _difference_rms_ratio(low_hp_samples)

	assert_float(duration_sec).is_between(0.32, 0.42)
	assert_float(_peak_db(low_hp_samples)).is_between(-8.0, -3.0)
	assert_bool(low_hp_rms_db <= normal_rms_db + 1.5).override_failure_message(
		"Low-HP mix must not create its weight by being more than 1.5 dB louder than the normal cue."
	).is_true()
	assert_float(tail_rms_db).override_failure_message(
		"The damped reverb tail after 160 ms must remain audible without staying louder than -14 dBFS."
	).is_between(-26.0, -14.0)
	assert_bool(final_rms_db <= -30.0).override_failure_message(
		"The final 10 ms must decay below -30 dBFS."
	).is_true()
	assert_bool(low_hp_roughness <= normal_roughness * 0.75).override_failure_message(
		"Low-HP damage must be observably darker than the normal cue after level-independent roughness analysis."
	).is_true()

	assert_bool(FileAccess.file_exists(SOURCE_MANIFEST_PATH)).override_failure_message(
		"Story010 final-mix provenance manifest is required."
	).is_true()
	if not FileAccess.file_exists(SOURCE_MANIFEST_PATH):
		return

	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(SOURCE_MANIFEST_PATH))
	assert_bool(parsed is Dictionary).is_true()
	if not (parsed is Dictionary):
		return
	var manifest: Dictionary = parsed
	assert_str(String(manifest.get("story_id", ""))).is_equal("audio-system-story-010")
	assert_str(String(manifest.get("status", ""))).is_equal("story_final_mix")
	assert_str(String(manifest.get("source_dry_path", ""))).is_equal(NORMAL_DAMAGE_PATH)
	assert_str(String(manifest.get("output_path", ""))).is_equal(LOW_HP_DAMAGE_PATH)
	assert_str(String(manifest.get("replaces_sha256", ""))).is_equal(
		STORY005_LOW_HP_BASELINE_SHA256
	)
	assert_str(String(manifest.get("output_sha256", ""))).is_equal(low_hp_hash)
	assert_bool(String(manifest.get("recipe", "")).length() >= 40).is_true()


func _read_pcm16_mono_wav(path: String) -> Dictionary:
	var bytes: PackedByteArray = FileAccess.get_file_as_bytes(path)
	if bytes.size() < 44:
		return {}
	if (
		bytes.slice(0, 4).get_string_from_ascii() != "RIFF"
		or bytes.slice(8, 12).get_string_from_ascii() != "WAVE"
	):
		return {}

	var result: Dictionary = {}
	var data_offset: int = -1
	var data_size: int = 0
	var offset: int = 12
	while offset + 8 <= bytes.size():
		var chunk_id: String = bytes.slice(offset, offset + 4).get_string_from_ascii()
		var chunk_size: int = int(bytes.decode_u32(offset + 4))
		var chunk_data_offset: int = offset + 8
		if chunk_data_offset + chunk_size > bytes.size():
			return {}
		if chunk_id == "fmt " and chunk_size >= 16:
			result["audio_format"] = int(bytes.decode_u16(chunk_data_offset))
			result["channels"] = int(bytes.decode_u16(chunk_data_offset + 2))
			result["sample_rate_hz"] = int(bytes.decode_u32(chunk_data_offset + 4))
			result["bits_per_sample"] = int(bytes.decode_u16(chunk_data_offset + 14))
		elif chunk_id == "data":
			data_offset = chunk_data_offset
			data_size = chunk_size
		offset = chunk_data_offset + chunk_size + (chunk_size % 2)

	if (
		data_offset < 0
		or data_size <= 0
		or int(result.get("audio_format", 0)) != 1
		or int(result.get("channels", 0)) != 1
		or int(result.get("bits_per_sample", 0)) != 16
	):
		return {}

	var samples := PackedFloat32Array()
	var sample_count: int = data_size / 2
	samples.resize(sample_count)
	for index: int in range(sample_count):
		samples[index] = float(bytes.decode_s16(data_offset + index * 2)) / 32768.0
	result["samples"] = samples
	return result


func _sha256_file(path: String) -> String:
	var context := HashingContext.new()
	if context.start(HashingContext.HASH_SHA256) != OK:
		return ""
	if context.update(FileAccess.get_file_as_bytes(path)) != OK:
		return ""
	return context.finish().hex_encode()


func _rms_db(samples: PackedFloat32Array, start_index: int, end_index: int) -> float:
	var start: int = clampi(start_index, 0, samples.size())
	var finish: int = clampi(end_index, start, samples.size())
	if finish <= start:
		return -120.0
	var sum_squares: float = 0.0
	for index: int in range(start, finish):
		sum_squares += samples[index] * samples[index]
	var rms: float = sqrt(sum_squares / float(finish - start))
	return linear_to_db(maxf(rms, 0.000001))


func _peak_db(samples: PackedFloat32Array) -> float:
	var peak: float = 0.0
	for sample: float in samples:
		peak = maxf(peak, absf(sample))
	return linear_to_db(maxf(peak, 0.000001))


func _difference_rms_ratio(samples: PackedFloat32Array) -> float:
	if samples.size() < 2:
		return 0.0
	var sample_sum_squares: float = 0.0
	var difference_sum_squares: float = 0.0
	for index: int in range(samples.size()):
		sample_sum_squares += samples[index] * samples[index]
		if index > 0:
			var difference: float = samples[index] - samples[index - 1]
			difference_sum_squares += difference * difference
	var sample_rms: float = sqrt(sample_sum_squares / float(samples.size()))
	var difference_rms: float = sqrt(
		difference_sum_squares / float(samples.size() - 1)
	)
	return difference_rms / maxf(sample_rms, 0.000001)
