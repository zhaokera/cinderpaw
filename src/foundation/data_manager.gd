## DataManager Autoload — JSON 域加载/缓存全局单例。
##
## Autoload 初始化顺序 #1（最先）。负责读取 manifest.json、加载 preload 域、
## 维护 4 状态机（BOOTING→READY/ERROR，READY→RELOADING→READY）。
##
## ADR-0001: Autoload 架构
## ADR-0003: 数据管理架构
class_name DataManager
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

# ---------------------------------------------------------------------------
# Signals (Story 004+: on_domain_changed, on_knob_changed)
# ---------------------------------------------------------------------------

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

# ---------------------------------------------------------------------------
# Built-in Virtual Methods
# ---------------------------------------------------------------------------

func _ready() -> void:
	_load_pipeline(DATA_DIR.path_join(MANIFEST_RELATIVE_PATH))


# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------

## 获取当前 DataManager 状态。
func get_state() -> State:
	return _state


## 查询指定域中的单条数据条目。
##
## BOOTING / ERROR 状态下返回 null，不抛出异常。
## Story 003 (DomainCache) 将实现完整查询逻辑（含懒加载）。
##
## Parameters:
##   domain - 域名（如 "damage_params"）
##   entry_id - 条目 ID（如 "cat_claw"）
##
## Returns: 条目数据（Dictionary），不存在或非 READY 状态返回 null
func get_entry(domain: StringName, entry_id: StringName) -> Variant:
	if _state != State.READY:
		return null
	if not _cache.has(domain):
		return null
	var entries: Dictionary = _cache[domain]
	if not entries.has(entry_id):
		return null
	return entries[entry_id]


## 从 ERROR 状态重新执行加载管道。
##
## 仅在 ERROR 状态下有效。调用后状态经历 BOOTING→READY（或再次 ERROR）。
## 用于 manifest 缺失/损坏后修复数据文件的手动恢复。
func retry() -> void:
	if _state != State.ERROR:
		push_warning("DataManager.retry() called in non-ERROR state: %s" % State.keys()[_state])
		return
	_load_pipeline(DATA_DIR.path_join(MANIFEST_RELATIVE_PATH))


# ---------------------------------------------------------------------------
# Private Methods — Loading Pipeline
# ---------------------------------------------------------------------------

## 完整加载管道：manifest → preload domains → READY / ERROR。
func _load_pipeline(manifest_path: String) -> void:
	_state = State.BOOTING
	_cache.clear()
	_domain_registry.clear()

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

	var text: String = FileAccess.get_file_as_text(manifest_path)
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
		var preload: bool = def.get("preload", false)
		if name.is_empty() or path.is_empty():
			push_warning("DataManager WARNING: skipping invalid domain definition in manifest")
			continue
		_domain_registry[name] = {"path": path, "preload": preload}

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
	var info: Dictionary = _domain_registry.get(domain_name, {})
	var file_path: String = DATA_DIR.path_join(info.get("path", ""))

	if not FileAccess.file_exists(file_path):
		push_error("DataManager ERROR: domain file not found '%s'" % file_path)
		return false

	var text: String = FileAccess.get_file_as_text(file_path)
	var parsed: Variant = JSON.parse_string(text)

	if parsed == null:
		push_error("DataManager ERROR: domain JSON parse failed '%s'" % file_path)
		return false

	var domain_data: Dictionary = parsed as Dictionary
	if domain_data == null:
		push_error("DataManager ERROR: domain root is not a Dictionary '%s'" % file_path)
		return false

	# Story 002: Schema 验证
	var schema_path: String = DATA_DIR.path_join(SCHEMA_DIR).path_join(
		domain_name + SCHEMA_EXTENSION)
	if FileAccess.file_exists(schema_path):
		var schema_text: String = FileAccess.get_file_as_text(schema_path)
		var schema_parsed: Variant = JSON.parse_string(schema_text)
		if schema_parsed != null and schema_parsed is Dictionary:
			var validation_result: ValidationResult = SchemaValidator.validate(
				domain_name, domain_data, schema_parsed as Dictionary)
			if not validation_result.is_valid:
				for err_msg: String in validation_result.errors:
					push_error("DataManager schema validation ERROR: %s" % err_msg)
				_cache[domain_name] = {}
				print("DataManager: domain '%s' loaded with validation errors (empty cache)" % domain_name)
				return true
		else:
			push_warning("DataManager WARNING: schema parse failed for domain '%s', skipping validation" % domain_name)
	else:
		push_warning("DataManager WARNING: no schema for domain '%s', skipping validation" % domain_name)

	if domain_data.has("entries"):
		_cache[domain_name] = domain_data["entries"]
	else:
		_cache[domain_name] = {}

	print("DataManager: domain '%s' loaded" % domain_name)
	return true


# ---------------------------------------------------------------------------
# Stubs for Future Stories
# ---------------------------------------------------------------------------

# Story 002 — SchemaValidator ✅ (implemented in src/foundation/schema_validator.gd)

# Story 003 — DomainCache full query (lazy loading for preload=false domains)
# func has_domain(domain_name: StringName) -> bool
# func get_domain(domain_name: StringName) -> Dictionary

# Story 004 — HotReloader (Debug build _process polling)
# func _process(delta: float) -> void
# signal on_domain_changed(domain_name: StringName)

# Story 005 — TuningKnobRegistry
# func get_tuning(knob_id: StringName, default: Variant) -> Variant
# signal on_knob_changed(knob_id: StringName, new_value: Variant)

# Story 006 — VersionMigrator
# func _migrate_version(domain_data: Dictionary, from_version: String) -> Dictionary
