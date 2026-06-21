## Story 001: ManifestLoader + 4 状态机 + 重试 — 单元测试
##
## 覆盖全部 5 条验收标准 (AC-01 ~ AC-05) + 1 个补充测试。
## 测试框架: GdUnit4
extends GdUnitTestSuite

const TEST_DIR: String = "res://data/"
const TEST_COMBAT_DIR: String = "res://data/combat/"

var data_manager: DataManager


func before_test() -> void:
	data_manager = DataManager.new()


func after_test() -> void:
	if is_instance_valid(data_manager):
		data_manager.queue_free()
	_remove_file(TEST_DIR.path_join("manifest.json"))
	_remove_file(TEST_COMBAT_DIR.path_join("damage_params.json"))


# ---------------------------------------------------------------------------
# Test Helpers
# ---------------------------------------------------------------------------

func _write_file(path: String, content: String) -> bool:
	var dir_path: String = path.get_base_dir()
	if not DirAccess.dir_exists_absolute(dir_path):
		DirAccess.make_dir_recursive_absolute(dir_path)
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(content)
	file.close()
	return true


func _remove_file(path: String) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)


func _create_valid_manifest() -> void:
	var manifest: String = """{
	"_meta": {"version": "1.0", "domain": "manifest"},
	"domains": [
		{"name": "damage_params", "path": "combat/damage_params.json", "preload": true}
	]
}"""
	_write_file(TEST_DIR.path_join("manifest.json"), manifest)


func _create_valid_domain_file() -> void:
	var domain: String = """{
	"_meta": {"version": "1.0", "domain": "damage_params"},
	"entries": {
		"cat_claw": {"weapon_base": 10, "scaling_factor": 1.2}
	}
}"""
	_write_file(TEST_COMBAT_DIR.path_join("damage_params.json"), domain)


# ---------------------------------------------------------------------------
# AC-01: manifest 存在且格式正确 → READY + preload 域可用
# ---------------------------------------------------------------------------

func test_valid_manifest_enters_ready_state() -> void:
	_create_valid_manifest()
	_create_valid_domain_file()
	add_child(data_manager)
	assert_int(data_manager.get_state()).is_equal(DataManager.State.READY)
	var entry: Variant = data_manager.get_entry(&"damage_params", &"cat_claw")
	assert_object(entry).is_not_null()


# ---------------------------------------------------------------------------
# AC-02: manifest 不存在 → ERROR + get_entry() 返回 null
# ---------------------------------------------------------------------------

func test_missing_manifest_enters_error_state() -> void:
	add_child(data_manager)
	assert_int(data_manager.get_state()).is_equal(DataManager.State.ERROR)
	assert_object(data_manager.get_entry(&"damage_params", &"cat_claw")).is_null()


# ---------------------------------------------------------------------------
# AC-03: manifest JSON 格式损坏 → ERROR + ERROR 日志
# ---------------------------------------------------------------------------

func test_corrupt_manifest_enters_error_state() -> void:
	_write_file(TEST_DIR.path_join("manifest.json"), "{this is not valid json")
	add_child(data_manager)
	assert_int(data_manager.get_state()).is_equal(DataManager.State.ERROR)
	assert_object(data_manager.get_entry(&"damage_params", &"cat_claw")).is_null()


# ---------------------------------------------------------------------------
# AC-04: BOOTING / ERROR 状态调用 get_entry() → null，不抛出异常
# ---------------------------------------------------------------------------

func test_get_entry_returns_null_in_non_ready_state() -> void:
	add_child(data_manager)
	assert_int(data_manager.get_state()).is_equal(DataManager.State.ERROR)
	var result: Variant = data_manager.get_entry(&"damage_params", &"cat_claw")
	assert_object(result).is_null()


# ---------------------------------------------------------------------------
# AC-05: ERROR→retry()→BOOTING→READY（manifest 此时已修复）
# ---------------------------------------------------------------------------

func test_retry_when_manifest_fixed_transitions_to_ready() -> void:
	add_child(data_manager)
	assert_int(data_manager.get_state()).is_equal(DataManager.State.ERROR)
	_create_valid_manifest()
	_create_valid_domain_file()
	data_manager.retry()
	assert_int(data_manager.get_state()).is_equal(DataManager.State.READY)
	var entry: Variant = data_manager.get_entry(&"damage_params", &"cat_claw")
	assert_object(entry).is_not_null()


# ---------------------------------------------------------------------------
# 补充测试：retry() 在非 ERROR 状态下无效
# ---------------------------------------------------------------------------

func test_retry_in_ready_state_is_noop() -> void:
	_create_valid_manifest()
	_create_valid_domain_file()
	add_child(data_manager)
	assert_int(data_manager.get_state()).is_equal(DataManager.State.READY)
	data_manager.retry()
	assert_int(data_manager.get_state()).is_equal(DataManager.State.READY)
