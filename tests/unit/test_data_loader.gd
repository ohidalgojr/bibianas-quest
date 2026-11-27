extends GutTest
## ADR-0009: o carregador lê os arquivos de game/data e transforma falhas de leitura em
## erros, sem seguir com dado pela metade.

const TEMP_DIR: String = "user://test_data_loader"


func after_each() -> void:
	var dir: DirAccess = DirAccess.open("user://")
	if dir != null and dir.dir_exists("test_data_loader"):
		for file: String in DirAccess.get_files_at(TEMP_DIR):
			DirAccess.remove_absolute(TEMP_DIR.path_join(file))
		DirAccess.remove_absolute(TEMP_DIR)


func _copy_real_data() -> void:
	DirAccess.make_dir_recursive_absolute(TEMP_DIR)
	for doc_name: String in DataValidator.DOCUMENTS:
		var text: String = FileAccess.get_file_as_string(DataLoader.DATA_DIR.path_join(doc_name + ".json"))
		var file: FileAccess = FileAccess.open(TEMP_DIR.path_join(doc_name + ".json"), FileAccess.WRITE)
		file.store_string(text)
		file.close()


func test_real_data_loads_without_errors() -> void:
	var data: GameData = DataLoader.load_all()
	assert_true(data.is_valid(), "\n".join(data.errors))
	assert_eq(data.classes.size(), 1)
	assert_eq(data.enemies.size(), 19)
	assert_eq(data.events.size(), 6)
	assert_eq(data.scenarios.size(), 1)


func test_missing_file_is_an_error() -> void:
	_copy_real_data()
	DirAccess.remove_absolute(TEMP_DIR.path_join("items.json"))
	var data: GameData = DataLoader.load_all(TEMP_DIR, false)
	assert_false(data.is_valid())
	assert_string_contains(" | ".join(data.errors), "items.json: arquivo não encontrado")


func test_broken_json_is_an_error() -> void:
	_copy_real_data()
	var file: FileAccess = FileAccess.open(TEMP_DIR.path_join("enemies.json"), FileAccess.WRITE)
	file.store_string("{\"format\": 1, \"enemies\": [")
	file.close()
	var data: GameData = DataLoader.load_all(TEMP_DIR, false)
	assert_false(data.is_valid())
	assert_string_contains(" | ".join(data.errors), "enemies.json: JSON inválido")
	assert_eq(data.enemies.size(), 0)
