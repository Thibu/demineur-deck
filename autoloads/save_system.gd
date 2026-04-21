extends Node

const SAVE_DIR := "user://saves/"
const SAVE_FILE := "save_data.json"

func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(SAVE_DIR)

func save_game(data: Dictionary) -> bool:
	var file := FileAccess.open(SAVE_DIR + SAVE_FILE, FileAccess.WRITE)
	if file == null:
		push_error("SaveSystem: Failed to open save file.")
		return false
	var json := JSON.new()
	file.store_string(json.stringify(data, "\t"))
	file.close()
	return true

func load_game() -> Dictionary:
	if not FileAccess.file_exists(SAVE_DIR + SAVE_FILE):
		return {}
	var file := FileAccess.open(SAVE_DIR + SAVE_FILE, FileAccess.READ)
	if file == null:
		return {}
	var content := file.get_as_text()
	file.close()
	var json := JSON.new()
	var result := json.parse(content)
	if result != OK:
		push_error("SaveSystem: Failed to parse save file.")
		return {}
	return json.data

func delete_save() -> void:
	if FileAccess.file_exists(SAVE_DIR + SAVE_FILE):
		DirAccess.remove_absolute(SAVE_DIR + SAVE_FILE)

func has_save() -> bool:
	return FileAccess.file_exists(SAVE_DIR + SAVE_FILE)
