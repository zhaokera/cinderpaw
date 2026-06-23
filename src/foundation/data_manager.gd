## DataManager Autoload — JSON 域加载/缓存全局单例。(v4)
##
## Autoload 初始化顺序 #1（最先）。负责读取 manifest.json、加载 preload 域、
## 维护 4 状态机（BOOTING→READY/ERROR，READY→RELOADING→READY）。
##
## ADR-0001: Autoload 架构
## ADR-0003: 数据管理架构
extends Node

## 状态机枚举：BOOTING→READY/ERROR，READY→RELOADING→READY
enum State {
	BOOTING,
	READY,
	RELOADING,
	ERROR,
}

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------

## manifest 文件相对于 res:// 的路径
const MANIFEST_RELATIVE_PATH: String = "manifest.json"

## 数据根目录
const DATA_DIR: String = "res://data/"

## Schema 文件目录（相对于 DATA_DIR）
const SCHEMA_DIR: String = "schemas"

## Schema 文件后缀
const SCHEMA_EXTENSION: String = ".schema.json"

## Debug 热重载轮询间隔（秒）
const HOT_RELOAD_INTERVAL_SEC: float = 1.0

## 默认数据域版本（MAJOR.MINOR）
const DEFAULT_DATA_VERSION: String = "1.0"

## 全局旋钮域名
const TUNING_KNOBS_DOMAIN: StringName = &"tuning_knobs"

## 旋钮条目数据类
const TUNING_KNOB_ENTRY_SCRIPT: Script = preload("res://src/foundation/tuning_knob_entry.gd")

# ---------------------------------------------------------------------------
# Signals (Story 004+: on_domain_changed, on_knob_changed)
# ---------------------------------------------------------------------------

signal on_domain_changed(domain_name: StringName)
signal on_knob_changed(knob_id: StringName, new_value: Variant)

# ---------------------------------------------------------------------------
# Private Variables
# ---------------------------------------------------------------------------

## 当前状态机状态
var _state: State = State.BOOTING

## 域缓存：domain_name -> entries Dictionary
## Story 003 (DomainCache) 将扩展此结构
var _cache: Dictionary = {}

## manifest 中注册的域信息：domain_name -> {"path": String, "preload": bool}
var _domain_registry: Dictionary = {}

## 域文件最后修改时间：domain_name -> Unix timestamp
var _domain_modified_times: Dictionary = {}

## 当前处于 FALLBACK 状态的域集合：domain_name -> true
var _fallback_domains: Dictionary = {}

## Debug 构建热重载轮询 Timer；Release 构建保持 null
var _hot_reload_timer: Timer = null

## 已注册旋钮：knob_id -> TuningKnobEntry
var _tuning_knobs: Dictionary = {}

## 数据迁移链：from_version -> {"to_version": String, "migration": Callable}
var _migration_chain: Dictionary = {}

# ---------------------------------------------------------------------------
# Built-in Virtual Methods
# ---------------------------------------------------------------------------

func _ready() -> void:
	_load_pipeline(DATA_DIR.path_join(MANIFEST_RELATIVE_PATH))
	_configure_hot_reloader(OS.is_debug_build())


# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------

## 获取当前 DataManager 状态。
func get_state() -> State:
	return _state


## 查询指定域中的单条数据条目。
##
## BOOTING / ERROR 状态下返回 null，不抛出异常。
## 若域未加载但已在 manifest 注册（preload=false），自动触发懒加载。
##
## Parameters:
##   domain - 域名（如 "damage_params"）
##   entry_id - 条目 ID（如 "cat_claw"）
##
## Returns: 条目数据（Dictionary），不存在或非 READY 状态返回 null
func get_entry(domain: StringName, entry_id: StringName) -> Variant:
	if _state != State.READY:
		return null
	# 懒加载：域未缓存但在 manifest 中已注册
	if not _cache.has(domain):
		if _domain_registry.has(domain):
			if not _load_domain(domain):
				return null
		else:
			return null
	var entries: Dictionary = _cache[domain]
	if not entries.has(entry_id):
		return null
	return entries[entry_id]


## 查询指定域是否已加载到缓存中。
##
## 注意：preload=false 域在首次 get_entry() 前不在缓存中，返回 false。
##
## Parameters:
##   domain - 域名
##
## Returns: 域是否在缓存中
func has_domain(domain: StringName) -> bool:
	return _cache.has(domain)


## 获取指定域的完整 entries Dictionary。
##
## 若域已注册但尚未加载，自动触发懒加载；失败或非 READY 状态返回空 Dictionary。
func get_domain(domain: StringName) -> Dictionary:
	if _state != State.READY:
		return {}
	if not _cache.has(domain):
		if _domain_registry.has(domain):
			if not _load_domain(domain):
				return {}
		else:
			return {}
	return _cache.get(domain, {})


## 查询指定域中是否存在指定条目。
##
## 若域未加载但已注册，自动触发懒加载。
##
## Parameters:
##   domain - 域名
##   entry_id - 条目 ID
##
## Returns: 条目是否存在
func has_entry(domain: StringName, entry_id: StringName) -> bool:
	var entry: Variant = get_entry(domain, entry_id)
	return entry != null


## 获取 input_config 域的完整配置数据。
##
## 返回包含 "entries" 字段的完整域数据 Dictionary（区别于 _cache 中仅存 entries）。
## 若域文件不存在或未注册，返回空 Dictionary。
## _path 参数保留给早期 Story/API 调用兼容；当前实现以 manifest 注册路径为准。
##
## Returns: input_config 域的完整数据（含 "_meta" 和 "entries" 字段）
func load_input_config(_path: String = "") -> Dictionary:
	if _state != State.READY:
		return {}
	if not _domain_registry.has(&"input_config"):
		return {}
	var info: Dictionary = _domain_registry[&"input_config"]
	var file_path: String = DATA_DIR.path_join(info.get("path", ""))
	if not FileAccess.file_exists(file_path):
		return {}
	var text: String = FileAccess.get_file_as_string(file_path)
	var parsed: Variant = JSON.parse_string(text)
	if parsed == null or not (parsed is Dictionary):
		return {}
	return parsed as Dictionary


## 从 ERROR 状态重新执行加载管道。
##
## 仅在 ERROR 状态下有效。调用后状态经历 BOOTING→READY（或再次 ERROR）。
## 用于 manifest 缺失/损坏后修复数据文件的手动恢复。
func retry() -> void:
	if _state != State.ERROR:
		push_warning("DataManager.retry() called in non-ERROR state: %s" % State.keys()[_state])
		return
	_load_pipeline(DATA_DIR.path_join(MANIFEST_RELATIVE_PATH))
	_configure_hot_reloader(OS.is_debug_build())


## 手动触发指定域热重载。
##
## 热重载验证失败时返回 false，并保留旧缓存不变。
## 域文件被删除时进入 FALLBACK 状态（空 Dictionary）并返回 true。
func reload_domain(domain_name: StringName) -> bool:
	if _state != State.READY:
		return false
	if not _domain_registry.has(domain_name):
		push_error("DataManager ERROR: reload requested for unregistered domain '%s'" % domain_name)
		return false
	return _reload_changed_domains([domain_name])


## 查询域是否处于 FALLBACK 状态。
func is_domain_fallback(domain_name: StringName) -> bool:
	return _fallback_domains.has(domain_name)


## 注册可运行时调节的旋钮。
func register_tuning(
	knob_id: StringName,
	knob_type: StringName,
	default_value: Variant,
	min_value: Variant,
	max_value: Variant,
	domain: StringName
) -> void:
	var entry: RefCounted = TUNING_KNOB_ENTRY_SCRIPT.new()
	entry.id = knob_id
	entry.type = knob_type
	entry.default_value = default_value
	entry.min_value = min_value
	entry.max_value = max_value
	entry.domain = domain
	entry.current_value = _clamp_tuning_value(default_value, entry)
	_tuning_knobs[knob_id] = entry
	_apply_tuning_cache_to_entry(entry, false)


## 获取旋钮当前值；未注册时返回 fallback。
func get_tuning(knob_id: StringName, fallback: Variant) -> Variant:
	if not _tuning_knobs.has(knob_id):
		push_warning("DataManager WARNING: tuning knob not registered '%s'" % knob_id)
		return fallback
	var entry: RefCounted = _tuning_knobs[knob_id]
	return entry.current_value


## 设置调试面板运行时旋钮值。
func set_tuning(knob_id: StringName, value: Variant) -> bool:
	if not _tuning_knobs.has(knob_id):
		push_warning("DataManager WARNING: tuning knob not registered '%s'" % knob_id)
		return false
	var entry: RefCounted = _tuning_knobs[knob_id]
	entry.debug_override = _clamp_tuning_value(value, entry)
	entry.has_debug_override = true
	entry.current_value = entry.debug_override
	on_knob_changed.emit(knob_id, entry.current_value)
	return true


## 注册一个数据版本迁移步骤。
func register_migration(from_version: String, to_version: String, migration: Callable) -> void:
	_migration_chain[from_version] = {
		"to_version": to_version,
		"migration": migration,
	}


## 返回版本兼容公式结果。
func get_version_flags(file_version: String, expected_version: String) -> Dictionary:
	var file_parts: Vector2i = _parse_version(file_version)
	var expected_parts: Vector2i = _parse_version(expected_version)
	if file_parts.x < 0 or expected_parts.x < 0:
		return {"compatible": false, "needs_migration": false}

	var same_major: bool = file_parts.x == expected_parts.x
	return {
		"compatible": same_major and file_parts.y >= expected_parts.y,
		"needs_migration": same_major and file_parts.y < expected_parts.y,
	}


## 检查数据域版本并按需执行链式迁移。
func check_and_migrate(domain_data: Dictionary, expected_version: String) -> Variant:
	if not domain_data.has("_meta") or not (domain_data["_meta"] is Dictionary):
		push_error("DataManager ERROR: domain data missing _meta version")
		return null

	var meta: Dictionary = domain_data["_meta"]
	var file_version: String = String(meta.get("version", ""))
	var flags: Dictionary = get_version_flags(file_version, expected_version)
	if flags["compatible"]:
		return domain_data.duplicate(true)
	if not flags["needs_migration"]:
		push_error("DataManager ERROR: incompatible data version '%s', expected '%s'" % [
			file_version,
			expected_version,
		])
		return null

	return _apply_migration_chain(domain_data, file_version, expected_version)


## 重置 DataManager 到初始状态（用于测试）。
##
## 清空缓存和注册表，状态回到 BOOTING。调用后需手动调用 _ready() 或 load_pipeline()。
func reset() -> void:
	_stop_hot_reloader()
	_state = State.BOOTING
	_cache.clear()
	_domain_registry.clear()
	_domain_modified_times.clear()
	_fallback_domains.clear()
	_tuning_knobs.clear()
	_migration_chain.clear()


# ---------------------------------------------------------------------------
# Private Methods — Loading Pipeline
# ---------------------------------------------------------------------------

## 完整加载管道：manifest → preload domains → READY / ERROR。
func _load_pipeline(manifest_path: String) -> void:
	_state = State.BOOTING
	_cache.clear()
	_domain_registry.clear()
	_domain_modified_times.clear()
	_fallback_domains.clear()

	# Step 1: 加载 manifest
	if not _load_manifest(manifest_path):
		_state = State.ERROR
		return

	# Step 2: 加载 preload=true 的域
	_load_preload_domains()

	# Step 3: 进入 READY
	_state = State.READY


## 加载并解析 manifest.json，填充 _domain_registry。
func _load_manifest(manifest_path: String) -> bool:
	if not FileAccess.file_exists(manifest_path):
		push_error("DataManager ERROR: manifest not found at '%s'" % manifest_path)
		return false

	var text: String = FileAccess.get_file_as_string(manifest_path)
	var parsed: Variant = JSON.parse_string(text)

	if parsed == null:
		push_error("DataManager ERROR: manifest JSON parse failed at '%s'" % manifest_path)
		return false

	var manifest: Dictionary = parsed as Dictionary
	if manifest == null:
		push_error("DataManager ERROR: manifest root is not a Dictionary")
		return false

	if not manifest.has("domains"):
		push_error("DataManager ERROR: manifest missing 'domains' field")
		return false

	var domains: Array = manifest["domains"]
	for domain_def: Variant in domains:
		var def: Dictionary = domain_def as Dictionary
		if def == null:
			continue
		var name: String = def.get("name", "")
		var path: String = def.get("path", "")
		var is_preload: bool = def.get("preload", false)
		if name.is_empty() or path.is_empty():
			push_warning("DataManager WARNING: skipping invalid domain definition in manifest")
			continue
		_domain_registry[name] = {"path": path, "preload": is_preload}

	print("DataManager: manifest loaded, %d domain(s) registered" % _domain_registry.size())
	return true


## 逐个加载 preload=true 的域文件到 _cache。
func _load_preload_domains() -> void:
	for domain_name: String in _domain_registry:
		var info: Dictionary = _domain_registry[domain_name]
		if info["preload"]:
			_load_domain(domain_name)


## 加载单个域 JSON 文件到缓存。
## Story 002 (SchemaValidator) 将在解析后增加验证步骤。
func _load_domain(domain_name: String) -> bool:
	var result: Dictionary = _read_domain_entries(domain_name, false, false)
	if not result["ok"]:
		return false

	_commit_domain_reload(domain_name, result["entries"], result["fallback"])
	if result["validation_failed"]:
		print("DataManager: domain '%s' loaded with validation errors (empty cache)" % domain_name)
		return true
	print("DataManager: domain '%s' loaded" % domain_name)
	return true


func _read_domain_entries(
	domain_name: StringName, allow_missing_fallback: bool, keep_cache_on_validation_failure: bool
) -> Dictionary:
	var info: Dictionary = _domain_registry.get(domain_name, {})
	var file_path: String = DATA_DIR.path_join(info.get("path", ""))
	if not FileAccess.file_exists(file_path):
		if allow_missing_fallback:
			push_warning("DataManager WARNING: domain file deleted, fallback enabled '%s'" % file_path)
			return _domain_result(true, {}, true, false)
		push_error("DataManager ERROR: domain file not found '%s'" % file_path)
		return _domain_result(false, {}, false, false)

	var text: String = FileAccess.get_file_as_string(file_path)
	var parsed: Variant = JSON.parse_string(text)
	if parsed == null:
		push_error("DataManager ERROR: domain JSON parse failed '%s'" % file_path)
		return _domain_result(false, {}, false, false)

	var domain_data: Dictionary = parsed as Dictionary
	if domain_data == null:
		push_error("DataManager ERROR: domain root is not a Dictionary '%s'" % file_path)
		return _domain_result(false, {}, false, false)
	var migrated_domain_data: Variant = _migrate_domain_data(info, domain_data)
	if migrated_domain_data == null:
		return _domain_result(false, {}, false, false)
	domain_data = migrated_domain_data as Dictionary
	var validation: Dictionary = _validate_domain_data(
		domain_name, domain_data, keep_cache_on_validation_failure)
	if not validation["ok"] or validation["validation_failed"]:
		return validation
	var entries: Dictionary = {}
	if domain_data.has("entries") and domain_data["entries"] is Dictionary:
		entries = domain_data["entries"] as Dictionary
	return _domain_result(true, entries, false, false)


func _migrate_domain_data(domain_info: Dictionary, domain_data: Dictionary) -> Variant:
	var expected_version: String = domain_info.get("version", DEFAULT_DATA_VERSION)
	return check_and_migrate(domain_data, expected_version)


func _validate_domain_data(
	domain_name: StringName,
	domain_data: Dictionary,
	keep_cache_on_validation_failure: bool
) -> Dictionary:
	var schema_path: String = DATA_DIR.path_join(SCHEMA_DIR).path_join(
		String(domain_name) + SCHEMA_EXTENSION)
	if FileAccess.file_exists(schema_path):
		var schema_text: String = FileAccess.get_file_as_string(schema_path)
		var schema_parsed: Variant = JSON.parse_string(schema_text)
		if schema_parsed != null and schema_parsed is Dictionary:
			var validation_result: ValidationResult = SchemaValidator.validate(
				domain_name, domain_data, schema_parsed as Dictionary)
			if not validation_result.is_valid:
				for err_msg: String in validation_result.errors:
					push_error("DataManager schema validation ERROR: %s" % err_msg)
				if keep_cache_on_validation_failure:
					return _domain_result(false, {}, false, true)
				return _domain_result(true, {}, false, true)
		else:
			push_warning("DataManager WARNING: schema parse failed for domain '%s', skipping validation" % domain_name)
	else:
		push_warning("DataManager WARNING: no schema for domain '%s', skipping validation" % domain_name)
	return _domain_result(true, {}, false, false)


func _domain_result(ok: bool, entries: Dictionary, fallback: bool, validation_failed: bool) -> Dictionary:
	return {
		"ok": ok,
		"entries": entries,
		"fallback": fallback,
		"validation_failed": validation_failed,
	}


func _configure_hot_reloader(is_debug_build: bool) -> void:
	if not is_debug_build or _state != State.READY:
		_stop_hot_reloader()
		return

	_snapshot_domain_modified_times()
	if _hot_reload_timer == null or not is_instance_valid(_hot_reload_timer):
		_hot_reload_timer = Timer.new()
		_hot_reload_timer.name = "HotReloadTimer"
		_hot_reload_timer.one_shot = false
		add_child(_hot_reload_timer)

	_hot_reload_timer.wait_time = HOT_RELOAD_INTERVAL_SEC
	if not _hot_reload_timer.timeout.is_connected(_poll_hot_reload):
		_hot_reload_timer.timeout.connect(_poll_hot_reload)
	_hot_reload_timer.start()


func _stop_hot_reloader() -> void:
	if _hot_reload_timer == null:
		return
	if is_instance_valid(_hot_reload_timer):
		_hot_reload_timer.stop()
		if _hot_reload_timer.get_parent() != null:
			_hot_reload_timer.get_parent().remove_child(_hot_reload_timer)
		_hot_reload_timer.queue_free()
	_hot_reload_timer = null


func _snapshot_domain_modified_times() -> void:
	for domain_key: Variant in _domain_registry.keys():
		var domain_name: StringName = StringName(domain_key)
		_domain_modified_times[domain_name] = _get_domain_modified_time(domain_name)


func _record_domain_modified_time(domain_name: StringName) -> void:
	_domain_modified_times[domain_name] = _get_domain_modified_time(domain_name)


func _get_domain_modified_time(domain_name: StringName) -> int:
	var info: Dictionary = _domain_registry.get(domain_name, {})
	var file_path: String = DATA_DIR.path_join(info.get("path", ""))
	if file_path.is_empty() or not FileAccess.file_exists(file_path):
		return 0
	return FileAccess.get_modified_time(file_path)


func _poll_hot_reload() -> void:
	if _state != State.READY:
		return

	var changed_domains: Array[StringName] = []
	for domain_key: Variant in _domain_registry.keys():
		var domain_name: StringName = StringName(domain_key)
		var current_modified_time: int = _get_domain_modified_time(domain_name)
		var previous_modified_time: int = _domain_modified_times.get(domain_name, -1)
		if current_modified_time != previous_modified_time:
			changed_domains.append(domain_name)

	if not changed_domains.is_empty():
		_reload_changed_domains(changed_domains)


func _reload_changed_domains(changed_domains: Array) -> bool:
	var prepared_results: Array[Dictionary] = []
	var all_successful: bool = true
	var previous_state: State = _state
	if previous_state == State.READY:
		_state = State.RELOADING

	for domain_key: Variant in changed_domains:
		var domain_name: StringName = StringName(domain_key)
		if not _domain_registry.has(domain_name):
			push_error("DataManager ERROR: changed domain is not registered '%s'" % domain_name)
			all_successful = false
			continue
		var result: Dictionary = _read_domain_entries(domain_name, true, true)
		if not result["ok"]:
			_record_domain_modified_time(domain_name)
			all_successful = false
			continue
		prepared_results.append({
			"domain_name": domain_name,
			"entries": result["entries"],
			"fallback": result["fallback"],
		})

	for result: Dictionary in prepared_results:
		_commit_domain_reload(result["domain_name"], result["entries"], result["fallback"])

	_state = previous_state
	for result: Dictionary in prepared_results:
		on_domain_changed.emit(result["domain_name"])

	return all_successful


func _commit_domain_reload(domain_name: StringName, entries: Dictionary, fallback: bool) -> void:
	_cache[domain_name] = entries
	if fallback:
		_fallback_domains[domain_name] = true
	else:
		_fallback_domains.erase(domain_name)
	_record_domain_modified_time(domain_name)
	if domain_name == TUNING_KNOBS_DOMAIN:
		_apply_tuning_cache_to_registered_knobs()


func _apply_tuning_cache_to_registered_knobs() -> void:
	for knob_key: Variant in _tuning_knobs.keys():
		var entry: RefCounted = _tuning_knobs[knob_key]
		_apply_tuning_cache_to_entry(entry, true)


func _apply_tuning_cache_to_entry(entry: RefCounted, emit_changes: bool) -> void:
	var previous_value: Variant = entry.current_value
	var tuning_entries: Dictionary = _cache.get(TUNING_KNOBS_DOMAIN, {})
	if tuning_entries.has(entry.id):
		var raw_config: Variant = tuning_entries[entry.id]
		var raw_value: Variant = raw_config.get("value", raw_config) if raw_config is Dictionary else raw_config
		entry.json_value = _clamp_tuning_value(raw_value, entry)
		entry.has_json_value = true
	else:
		entry.has_json_value = false
	entry.current_value = _resolve_tuning_value(entry)
	if emit_changes and entry.current_value != previous_value:
		on_knob_changed.emit(entry.id, entry.current_value)


func _resolve_tuning_value(entry: RefCounted) -> Variant:
	if entry.has_debug_override:
		return entry.debug_override
	if entry.has_json_value:
		return entry.json_value
	return _clamp_tuning_value(entry.default_value, entry)


func _clamp_tuning_value(value: Variant, entry: RefCounted) -> Variant:
	match entry.type:
		&"int":
			return clampi(int(value), int(entry.min_value), int(entry.max_value))
		&"float":
			return clampf(float(value), float(entry.min_value), float(entry.max_value))
		_:
			return value


func _apply_migration_chain(
	domain_data: Dictionary,
	file_version: String,
	expected_version: String
) -> Dictionary:
	var original_data: Dictionary = domain_data.duplicate(true)
	var working_data: Dictionary = domain_data.duplicate(true)
	var current_version: String = file_version

	while current_version != expected_version:
		if not _migration_chain.has(current_version):
			push_error("DataManager ERROR: missing migration step from '%s'" % current_version)
			return original_data

		var step: Dictionary = _migration_chain[current_version]
		var to_version: String = step.get("to_version", "")
		if not _is_next_migration_step(current_version, to_version, expected_version):
			push_error("DataManager ERROR: invalid migration step '%s' -> '%s'" % [
				current_version,
				to_version,
			])
			return original_data

		var migration: Callable = step.get("migration", Callable())
		var migrated: Variant = migration.call(working_data.duplicate(true))
		if not (migrated is Dictionary) or (migrated as Dictionary).is_empty():
			push_error("DataManager ERROR: migration step failed '%s' -> '%s'" % [
				current_version,
				to_version,
			])
			return original_data

		working_data = migrated as Dictionary
		working_data["_meta"]["version"] = to_version
		current_version = to_version

	return working_data


func _is_next_migration_step(from_version: String, to_version: String, expected_version: String) -> bool:
	var from_parts: Vector2i = _parse_version(from_version)
	var to_parts: Vector2i = _parse_version(to_version)
	var expected_parts: Vector2i = _parse_version(expected_version)
	if from_parts.x < 0 or to_parts.x < 0 or expected_parts.x < 0:
		return false
	if from_parts.x != to_parts.x or from_parts.x != expected_parts.x:
		return false
	if to_parts.y != from_parts.y + 1:
		return false
	return to_parts.y <= expected_parts.y


func _parse_version(version: String) -> Vector2i:
	var parts: PackedStringArray = version.split(".")
	if parts.size() != 2 or not parts[0].is_valid_int() or not parts[1].is_valid_int():
		return Vector2i(-1, -1)
	return Vector2i(int(parts[0]), int(parts[1]))


# ---------------------------------------------------------------------------
# Stubs for Future Stories
# ---------------------------------------------------------------------------

# Story 002 — SchemaValidator ✅ (implemented in src/foundation/schema_validator.gd)

# Story 003 — DomainCache ✅ (lazy loading + query helpers)
# func has_domain(domain_name: StringName) -> bool
# func get_domain(domain_name: StringName) -> Dictionary
# func has_entry(domain: StringName, entry_id: StringName) -> bool
# func load_input_config() -> Dictionary

# Story 004 — HotReloader ✅ (Debug-only Timer polling + atomic reload)
# func reload_domain(domain_name: StringName) -> bool
# signal on_domain_changed(domain_name: StringName)

# Story 005 — TuningKnobRegistry ✅ (registered defaults + JSON + debug overrides)
# func register_tuning(knob_id: StringName, knob_type: StringName, default_value: Variant, min_value: Variant, max_value: Variant, domain: StringName) -> void
# func get_tuning(knob_id: StringName, default: Variant) -> Variant
# func set_tuning(knob_id: StringName, value: Variant) -> bool
# signal on_knob_changed(knob_id: StringName, new_value: Variant)

# Story 006 — VersionMigrator ✅ (MAJOR.MINOR compatibility + chained migrations)
# func register_migration(from_version: String, to_version: String, migration: Callable) -> void
# func check_and_migrate(domain_data: Dictionary, expected_version: String) -> Variant
# func get_version_flags(file_version: String, expected_version: String) -> Dictionary
