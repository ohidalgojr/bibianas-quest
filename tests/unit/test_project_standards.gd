extends GutTest
## Padrões do projeto verificados por teste (CLAUDE.md, GDD §21): tarefas e ADRs com a
## estrutura exigida, numeração sem buracos, HANDOFF em dia e uma ficha por inimigo. Quem
## não seguir a pipeline vê este teste falhar.

const TASK_SECTIONS: Array[String] = ["| Status |", "## Objetivo", "## Critérios de aceite", "## Verificação", "## Revisão cruzada"]


func _read(path: String) -> String:
	return FileAccess.get_file_as_string(path)


## Nomes de arquivo `.md` da pasta que começam com [param prefix] e seguem `PREFIXO-NNNN-...`.
func _numbered(dir: String, prefix: String) -> Array[String]:
	var found: Array[String] = []
	var access: DirAccess = DirAccess.open(dir)
	assert_not_null(access, "pasta %s existe" % dir)
	if access == null:
		return found
	for file_name: String in access.get_files():
		if file_name.begins_with(prefix + "-") and file_name.ends_with(".md") and not file_name.contains("modelo"):
			found.append(file_name)
	found.sort()
	return found


func _number(file_name: String) -> int:
	var parts: PackedStringArray = file_name.split("-")
	return int(parts[1]) if parts.size() > 1 and parts[1].is_valid_int() else -1


func test_every_task_file_has_the_required_sections_and_title() -> void:
	var tasks: Array[String] = _numbered("res://docs/tasks", "TASK")
	assert_gt(tasks.size(), 25, "as tarefas existem")
	for file_name: String in tasks:
		var text: String = _read("res://docs/tasks/" + file_name)
		for section: String in TASK_SECTIONS:
			assert_true(text.contains(section), "%s sem '%s'" % [file_name, section])
		assert_true(text.begins_with("# TASK-%03d:" % _number(file_name)), "%s: o título leva o ID do arquivo" % file_name)


func test_task_numbers_are_unique_and_without_gaps() -> void:
	var seen: Array[int] = []
	for file_name: String in _numbered("res://docs/tasks", "TASK"):
		var number: int = _number(file_name)
		assert_false(seen.has(number), "TASK-%03d repetida" % number)
		seen.append(number)
	seen.sort()
	for index: int in seen.size():
		assert_eq(seen[index], index + 1, "falta a TASK-%03d" % (index + 1))


func test_finished_tasks_have_their_verification_filled() -> void:
	for file_name: String in _numbered("res://docs/tasks", "TASK"):
		var text: String = _read("res://docs/tasks/" + file_name)
		var finished: bool = text.contains("| Status | Concluída") or text.contains("| Status | Em verificação")
		if finished:
			assert_false(text.contains("(preencher)"), "%s: concluída com 'Verificação' vazia" % file_name)


func test_adr_files_have_title_status_and_are_numbered_without_gaps() -> void:
	var adrs: Array[String] = _numbered("res://docs/adr", "ADR")
	assert_gt(adrs.size(), 25)
	for index: int in adrs.size():
		var number: int = _number(adrs[index])
		assert_eq(number, index + 1, "ADR fora de sequência: %s" % adrs[index])
		var text: String = _read("res://docs/adr/" + adrs[index])
		assert_true(text.begins_with("# ADR-%04d:" % number), "%s: título com o número" % adrs[index])
		assert_true(text.contains("Status"), "%s sem Status" % adrs[index])


func test_handoff_carries_the_current_rules_version() -> void:
	var handoff: String = _read("res://docs/HANDOFF.md")
	assert_true(handoff.contains("RULES_VERSION` = %d" % CoreVersion.RULES_VERSION) or handoff.contains("RULES_VERSION = %d" % CoreVersion.RULES_VERSION),
		"o HANDOFF precisa citar RULES_VERSION = %d (atualize ao mudar regra)" % CoreVersion.RULES_VERSION)


func test_every_enemy_has_a_design_sheet() -> void:
	var data: GameData = DataLoader.load_all()
	var sheets: Array[String] = []
	var access: DirAccess = DirAccess.open("res://docs/enemies")
	assert_not_null(access)
	for file_name: String in access.get_files():
		if file_name.begins_with("ENEMY-") and file_name.ends_with(".md"):
			sheets.append(_read("res://docs/enemies/" + file_name))
	for enemy_id: String in data.enemies:
		var found: bool = false
		for sheet: String in sheets:
			if sheet.contains("`%s`" % enemy_id):
				found = true
		assert_true(found, "inimigo %s sem ficha em docs/enemies/ (GDD §21, ADR-0030)" % enemy_id)


func test_agent_entry_points_exist() -> void:
	for path: String in ["res://CLAUDE.md", "res://AGENTS.md", "res://docs/HANDOFF.md", "res://docs/REVIEW-CHECKLIST.md", "res://docs/FEEDBACK.md"]:
		assert_true(FileAccess.file_exists(path), path)
