extends GutTest
## ADR-0009: o validador rejeita dado inválido e diz onde está o problema. Cada teste
## parte de uma cópia dos dados de verdade e estraga uma coisa só.

var _base: Dictionary = {}


func before_all() -> void:
	var read_errors: PackedStringArray = PackedStringArray()
	for doc_name: String in DataValidator.DOCUMENTS:
		_base[doc_name] = DataLoader.read_json(DataLoader.DATA_DIR.path_join(doc_name + ".json"), read_errors)
	assert_eq(read_errors.size(), 0, "\n".join(read_errors))


func _docs() -> Dictionary:
	return _base.duplicate(true)


func _enemy(docs: Dictionary, enemy_id: String) -> Dictionary:
	for entry: Dictionary in docs["enemies"]["enemies"]:
		if entry["id"] == enemy_id:
			return entry
	return {}


## Confere que há erro e que algum deles contém o trecho esperado.
func _assert_rejects(docs: Dictionary, expected: String) -> void:
	var errors: PackedStringArray = DataValidator.validate(docs)
	assert_gt(errors.size(), 0, "deveria rejeitar: " + expected)
	var matched: bool = false
	for message: String in errors:
		if message.contains(expected):
			matched = true
	assert_true(matched, "esperava '%s' em: %s" % [expected, " | ".join(errors)])


func test_real_data_is_valid() -> void:
	var errors: PackedStringArray = DataValidator.validate(_docs())
	assert_eq(errors.size(), 0, "\n".join(errors))


func test_rejects_missing_document() -> void:
	var docs: Dictionary = _docs()
	docs.erase("items")
	_assert_rejects(docs, "items: documento ausente")


func test_rejects_unsupported_format() -> void:
	var docs: Dictionary = _docs()
	docs["skills"]["format"] = 2
	_assert_rejects(docs, "skills: format 2 não suportado")


func test_rejects_missing_field() -> void:
	var docs: Dictionary = _docs()
	_enemy(docs, "giant_rat").erase("name")
	_assert_rejects(docs, "enemies[giant_rat]: campo faltando: name")


func test_rejects_wrong_type() -> void:
	var docs: Dictionary = _docs()
	_enemy(docs, "giant_rat")["stats"]["hp"] = "muito"
	_assert_rejects(docs, "enemies[giant_rat]: atributo hp precisa ser número")


func test_rejects_incomplete_class_stats() -> void:
	var docs: Dictionary = _docs()
	(docs["classes"]["classes"][0]["stats"] as Dictionary).erase("luck")
	_assert_rejects(docs, "classes[warrior]: atributo faltando: luck")


func test_rejects_duplicate_id() -> void:
	var docs: Dictionary = _docs()
	var items: Array = docs["items"]["items"]
	items.append((items[0] as Dictionary).duplicate(true))
	_assert_rejects(docs, "items: id repetido: murky_potion")


func test_rejects_broken_skill_reference() -> void:
	var docs: Dictionary = _docs()
	(docs["classes"]["classes"][0]["skills"] as Array).append("fireball")
	_assert_rejects(docs, "classes[warrior]: skill de combate inexistente: fireball")


func test_rejects_starting_item_in_wrong_slot() -> void:
	var docs: Dictionary = _docs()
	docs["classes"]["classes"][0]["starting_armor"] = "worn_longsword"
	_assert_rejects(docs, "starting_armor precisa ser do slot armor")


func test_rejects_scenario_boss_that_is_not_a_boss() -> void:
	var docs: Dictionary = _docs()
	docs["scenarios"]["scenarios"][0]["boss"] = "giant_rat"
	_assert_rejects(docs, "scenarios[abandoned_city]: giant_rat precisa ser do tipo boss")


func test_rejects_missing_scenario_enemy() -> void:
	var docs: Dictionary = _docs()
	(docs["scenarios"]["scenarios"][0]["common_enemies"] as Array).append("dragon")
	_assert_rejects(docs, "inimigo inexistente: dragon")


func test_rejects_unknown_choices() -> void:
	var docs: Dictionary = _docs()
	_enemy(docs, "giant_rat")["phases"][0]["moves"][0]["kind"] = "kick"
	_assert_rejects(docs, "kind desconhecido: kick")
	docs = _docs()
	docs["items"]["items"][0]["slot"] = "pocket"
	_assert_rejects(docs, "slot desconhecido: pocket")
	docs = _docs()
	_enemy(docs, "giant_rat")["element_mults"]["ice"] = 1.5
	_assert_rejects(docs, "element_mults desconhecido: ice")


## GDD §6: de 3 a 5 golpes no ciclo.
func test_rejects_cycle_size_outside_gdd() -> void:
	var docs: Dictionary = _docs()
	var moves: Array = _enemy(docs, "carrion_crow")["phases"][0]["moves"]
	moves.pop_back()
	_assert_rejects(docs, "precisa de 3 a 5 golpes (GDD §6), tem 2")
	docs = _docs()
	moves = _enemy(docs, "rotten_executioner")["phases"][0]["moves"]
	moves.append({"id": "attack", "kind": "attack"})
	_assert_rejects(docs, "precisa de 3 a 5 golpes (GDD §6), tem 6")


## GDD §7: Golpe Mortal só em chefes.
func test_rejects_mortal_blow_outside_boss() -> void:
	var docs: Dictionary = _docs()
	_enemy(docs, "plague_hound")["phases"][0]["moves"][1]["kind"] = "mortal"
	_assert_rejects(docs, "Golpe Mortal só em chefes (GDD §7)")


## GDD §13: chefe com 2 a 3 fases, golpe Cruel e Golpe Mortal na fase final.
func test_rejects_boss_breaking_gdd_rules() -> void:
	var docs: Dictionary = _docs()
	(_enemy(docs, "gravedigger")["phases"] as Array).pop_back()
	_assert_rejects(docs, "chefe precisa de 2 a 3 fases (GDD §13), tem 1")
	docs = _docs()
	_enemy(docs, "gravedigger")["phases"][1]["moves"][0]["kind"] = "heavy"
	_assert_rejects(docs, "a fase final do chefe precisa de um Golpe Mortal (GDD §13)")
	docs = _docs()
	for phase: Dictionary in _enemy(docs, "gravedigger")["phases"]:
		for move: Dictionary in phase["moves"]:
			if move["kind"] == "cruel":
				move["kind"] = "heavy"
	_assert_rejects(docs, "chefe precisa de pelo menos um golpe Cruel (GDD §13)")


func test_rejects_phase_thresholds_out_of_order() -> void:
	var docs: Dictionary = _docs()
	_enemy(docs, "gravedigger")["phases"][1]["below_hp_percent"] = 100
	_assert_rejects(docs, "below_hp_percent precisa descer")
	docs = _docs()
	_enemy(docs, "gravedigger")["phases"][0]["below_hp_percent"] = 90
	_assert_rejects(docs, "a primeira fase começa em 100")


func test_rejects_missing_winnable_target() -> void:
	var docs: Dictionary = _docs()
	(docs["scenarios"]["scenarios"][0] as Dictionary).erase("winnable_target")
	_assert_rejects(docs, "scenarios[abandoned_city]: campo faltando: winnable_target")


func test_rejects_consumable_without_effect() -> void:
	var docs: Dictionary = _docs()
	docs["items"]["items"][0]["heal_hp_percent"] = 0
	_assert_rejects(docs, "items[murky_potion]: consumível sem efeito")


func test_invalid_data_leaves_catalog_empty() -> void:
	var docs: Dictionary = _docs()
	docs.erase("enemies")
	var data: GameData = GameData.from_documents(docs)
	assert_false(data.is_valid())
	assert_eq(data.enemies.size(), 0)


## ADR-0020: golpe de debuff precisa de efeito conhecido e chance entre 1 e 100.
func test_debuff_move_needs_effect_and_chance() -> void:
	var docs: Dictionary = _docs()
	var move: Dictionary = _enemy(docs, "gravedigger")["phases"][0]["moves"][2]
	assert_eq(move["id"], "rot")
	move["effect_chance"] = 0
	_assert_rejects(docs, "effect_chance")
	move["effect_chance"] = 60
	move["effect"] = "inexistente"
	_assert_rejects(docs, "effect")
	move["effect"] = "poison"
	assert_eq(DataValidator.validate(docs).size(), 0)
