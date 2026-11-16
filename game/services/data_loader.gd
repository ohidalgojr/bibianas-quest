class_name DataLoader
extends RefCounted
## Lê os arquivos JSON de game/data e monta o [GameData] (ADR-0009). Erros de arquivo,
## de JSON e de validação vão juntos para [member GameData.errors] e para o console
## com push_error: o jogo não deve seguir com dado inválido.

const DATA_DIR: String = "res://game/data"


static func load_all(dir_path: String = DATA_DIR, report: bool = true) -> GameData:
	var documents: Dictionary = {}
	var read_errors: PackedStringArray = PackedStringArray()
	for doc_name: String in DataValidator.DOCUMENTS:
		var path: String = dir_path.path_join(doc_name + ".json")
		var parsed: Variant = read_json(path, read_errors)
		if parsed != null:
			documents[doc_name] = parsed
	var data: GameData
	if read_errors.is_empty():
		data = GameData.from_documents(documents)
	else:
		data = GameData.new()
		data.errors = read_errors
	if report:
		for message: String in data.errors:
			push_error("Dados inválidos: " + message)
	return data


## Devolve o conteúdo do arquivo, ou null com o motivo em [param errors].
static func read_json(path: String, errors: PackedStringArray) -> Variant:
	if not FileAccess.file_exists(path):
		errors.append("%s: arquivo não encontrado" % path)
		return null
	var text: String = FileAccess.get_file_as_string(path)
	var json: JSON = JSON.new()
	if json.parse(text) != OK:
		errors.append("%s: JSON inválido na linha %d: %s" % [path, json.get_error_line(), json.get_error_message()])
		return null
	return json.data
