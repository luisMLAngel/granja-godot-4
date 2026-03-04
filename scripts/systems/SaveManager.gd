extends Node

const SAVE_PATH = "user://savegame.json"

func guardar() -> void:
	var data: Dictionary = {}

	# Cada sistema expone su propio estado para guardar
	if GameManager.day_night_system:
		data["day_night"] = GameManager.day_night_system.get_save_data()
	if GameManager.inventory_system:
		data["inventory"] = GameManager.inventory_system.get_save_data()
	if GameManager.tile_system:
		data["tiles"] = GameManager.tile_system.get_save_data()
	if GameManager.zone_system:
		data["zones"] = GameManager.zone_system.get_save_data()
	if GameManager.lore_system:
		data["lore"] = GameManager.lore_system.get_save_data()

	data["meta"] = {
		"version": "0.1",
		"timestamp": Time.get_datetime_string_from_system()
	}

	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data, "\t"))
		file.close()

func cargar() -> bool:
	if not existe_guardado():
		return false

	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return false

	var data = JSON.parse_string(file.get_as_text())
	file.close()

	if data == null:
		return false

	# Cada sistema recibe su propio bloque y lo aplica
	if GameManager.day_night_system and data.has("day_night"):
		GameManager.day_night_system.load_save_data(data["day_night"])
	if GameManager.inventory_system and data.has("inventory"):
		GameManager.inventory_system.load_save_data(data["inventory"])
	if GameManager.tile_system and data.has("tiles"):
		GameManager.tile_system.load_save_data(data["tiles"])
	if GameManager.zone_system and data.has("zones"):
		GameManager.zone_system.load_save_data(data["zones"])
	if GameManager.lore_system and data.has("lore"):
		GameManager.lore_system.load_save_data(data["lore"])

	return true

func existe_guardado() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

func borrar_guardado() -> void:
	if existe_guardado():
		DirAccess.remove_absolute(SAVE_PATH)