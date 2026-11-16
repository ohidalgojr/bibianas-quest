class_name SaveStore
extends RefCounted
## Lê e grava os dois arquivos de save (GDD §20, ADR-0017): o da Descida em andamento
## (apagado ao terminar) e o de meta, com Ecos e Descidas jogadas, separado e com versão
## de formato própria. Grava num arquivo temporário e renomeia, para um corte no meio não
## estragar o save. Qualquer arquivo ilegível vale como "sem save".

const META_FORMAT: int = 1
const RUN_FILE: String = "run.json"
const META_FILE: String = "meta.json"

var dir: String


func _init(save_dir: String = "user://") -> void:
	dir = save_dir
	if not dir.ends_with("/"):
		dir += "/"
	DirAccess.make_dir_recursive_absolute(dir)


func has_run() -> bool:
	return FileAccess.file_exists(dir + RUN_FILE)


func save_run(run: RunState) -> bool:
	return _write(RUN_FILE, RunSave.to_dict(run))


## A Descida salva, ou null se não há save ou ele não serve mais.
func load_run(data: GameData) -> RunState:
	var saved: Dictionary = _read(RUN_FILE)
	if saved.is_empty():
		return null
	return RunSave.from_dict(data, saved)


func clear_run() -> void:
	if has_run():
		DirAccess.remove_absolute(dir + RUN_FILE)


func save_meta(echoes: int, runs_played: int) -> bool:
	return _write(META_FILE, {"format": META_FORMAT, "echoes": echoes, "runs_played": runs_played})


## {echoes, runs_played}; zeros se não há meta ou o formato não bate.
func load_meta() -> Dictionary:
	var saved: Dictionary = _read(META_FILE)
	if int(saved.get("format", -1)) != META_FORMAT:
		return {"echoes": 0, "runs_played": 0}
	return {"echoes": int(saved.get("echoes", 0)), "runs_played": int(saved.get("runs_played", 0))}


func _write(file_name: String, content: Dictionary) -> bool:
	var temp: String = dir + file_name + ".tmp"
	var file: FileAccess = FileAccess.open(temp, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(content))
	file.close()
	return DirAccess.rename_absolute(temp, dir + file_name) == OK


func _read(file_name: String) -> Dictionary:
	var path: String = dir + file_name
	if not FileAccess.file_exists(path):
		return {}
	var json: JSON = JSON.new()
	if json.parse(FileAccess.get_file_as_string(path)) != OK or not json.data is Dictionary:
		return {}
	return json.data
