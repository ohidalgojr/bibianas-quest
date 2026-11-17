class_name DataValidator
extends RefCounted
## Confere os documentos de dados já lidos (ADR-0009). Não lê arquivos: recebe um
## dicionário nome do documento -> conteúdo e devolve a lista de erros, cada um com o
## caminho do problema. Lista vazia é dado válido.

const FORMAT: int = 1
const DOCUMENTS: PackedStringArray = ["classes", "skills", "enemies", "items", "scenarios"]

const STAT_KEYS: PackedStringArray = ["hp", "mp", "strength", "mind", "defense", "resistance",
	"speed", "precision", "evasion", "crit", "luck"]
const ENEMY_TYPES: PackedStringArray = ["common", "elite", "mini_boss", "boss"]
const MOVE_KINDS: PackedStringArray = ["attack", "strong", "heavy", "cruel", "mortal", "heal", "debuff"]
const DEBUFF_EFFECT_IDS: PackedStringArray = ["poison", "weakened"]
const ELEMENTS: PackedStringArray = ["physical", "fire", "lightning", "holy", "shadow"]
const ITEM_SLOTS: PackedStringArray = ["consumable", "weapon", "offhand", "armor", "head", "relic"]
const RARITIES: PackedStringArray = ["worn", "common", "uncommon", "rare", "cursed", "soul", "rival"]
const SKILL_EFFECTS: PackedStringArray = ["shield_bash", "charge", "bulwark", "power_strike", "war_cry", "mend"]
const CAMPFIRE_EFFECTS: PackedStringArray = ["damage_up", "defense_up"]
const PASSIVES: PackedStringArray = ["veteran"]

## GDD §6: cada inimigo tem de 3 a 5 movimentos no ciclo.
const MIN_MOVES: int = 3
const MAX_MOVES: int = 5
## GDD §13: chefes têm de 2 a 3 fases.
const BOSS_MIN_PHASES: int = 2
const BOSS_MAX_PHASES: int = 3

var _errors: PackedStringArray = PackedStringArray()


static func validate(documents: Dictionary) -> PackedStringArray:
	var validator: DataValidator = DataValidator.new()
	validator._run(documents)
	return validator._errors


func _run(documents: Dictionary) -> void:
	for doc_name: String in DOCUMENTS:
		if not documents.has(doc_name):
			_error(doc_name, "documento ausente")
			continue
		var doc: Variant = documents[doc_name]
		if typeof(doc) != TYPE_DICTIONARY:
			_error(doc_name, "o documento precisa ser um objeto")
			continue
		var doc_data: Dictionary = doc
		if _int_field(doc_data, "format", doc_name) != FORMAT and doc_data.has("format") \
				and typeof(doc_data["format"]) in [TYPE_INT, TYPE_FLOAT]:
			_error(doc_name, "format %s não suportado (esperado %d)" % [str(doc_data["format"]), FORMAT])
	if not _errors.is_empty():
		return
	var classes: Array = _list(documents["classes"], "classes", "classes")
	var combat_skills: Array = _list(documents["skills"], "combat", "skills")
	var campfire_skills: Array = _list(documents["skills"], "campfire", "skills")
	var enemies: Array = _list(documents["enemies"], "enemies", "enemies")
	var items: Array = _list(documents["items"], "items", "items")
	var scenarios: Array = _list(documents["scenarios"], "scenarios", "scenarios")

	var combat_ids: Dictionary = _ids(combat_skills, "skills.combat")
	var campfire_ids: Dictionary = _ids(campfire_skills, "skills.campfire")
	var enemy_ids: Dictionary = _ids(enemies, "enemies")
	var item_ids: Dictionary = _ids(items, "items")
	var class_ids: Dictionary = _ids(classes, "classes")
	_ids(scenarios, "scenarios")

	for entry: Variant in combat_skills:
		_check_combat_skill(entry, class_ids)
	for entry: Variant in campfire_skills:
		_check_campfire_skill(entry, class_ids)
	for entry: Variant in items:
		_check_item(entry)
	for entry: Variant in enemies:
		_check_enemy(entry)
	for entry: Variant in classes:
		_check_class(entry, combat_ids, campfire_ids, item_ids)
	for entry: Variant in scenarios:
		_check_scenario(entry, enemy_ids)


# --- Entidades -------------------------------------------------------------------

func _check_class(entry: Variant, combat_ids: Dictionary, campfire_ids: Dictionary, item_ids: Dictionary) -> void:
	if typeof(entry) != TYPE_DICTIONARY:
		return
	var data: Dictionary = entry
	var path: String = _path("classes", data)
	_string_field(data, "name", path)
	_check_stats(data, path, true)
	var passive: String = _string_field(data, "passive", path)
	if not passive.is_empty() and not PASSIVES.has(passive):
		_error(path, "passiva desconhecida: %s" % passive)
	var class_id: String = str(data.get("id", ""))
	for skill_id: String in _string_list(data, "skills", path):
		if not combat_ids.has(skill_id):
			_error(path, "skill de combate inexistente: %s" % skill_id)
		elif str((combat_ids[skill_id] as Dictionary).get("class", "")) != class_id:
			_error(path, "a skill %s é de outra classe" % skill_id)
	for skill_id: String in _string_list(data, "campfire_skills", path):
		if not campfire_ids.has(skill_id):
			_error(path, "skill de fogueira inexistente: %s" % skill_id)
	_check_item_ref(data, "starting_weapon", "weapon", path, item_ids)
	_check_item_ref(data, "starting_armor", "armor", path, item_ids)


func _check_item_ref(data: Dictionary, key: String, slot: String, path: String, item_ids: Dictionary) -> void:
	var item_id: String = _string_field(data, key, path)
	if item_id.is_empty():
		return
	if not item_ids.has(item_id):
		_error(path, "%s inexistente: %s" % [key, item_id])
	elif str((item_ids[item_id] as Dictionary).get("slot", "")) != slot:
		_error(path, "%s precisa ser do slot %s: %s" % [key, slot, item_id])


func _check_combat_skill(entry: Variant, class_ids: Dictionary) -> void:
	if typeof(entry) != TYPE_DICTIONARY:
		return
	var data: Dictionary = entry
	var path: String = _path("skills.combat", data)
	_string_field(data, "name", path)
	_check_owner(data, path, class_ids)
	_check_min(_int_field(data, "cost", path), 0, path, "cost")
	_check_choice(_string_field(data, "effect", path), SKILL_EFFECTS, path, "effect")
	if _number_field(data, "power", path) < 0.0:
		_error(path, "power não pode ser negativo")
	_bool_field(data, "coin", path)
	_check_min(_int_field(data, "price", path), 0, path, "price")


func _check_campfire_skill(entry: Variant, class_ids: Dictionary) -> void:
	if typeof(entry) != TYPE_DICTIONARY:
		return
	var data: Dictionary = entry
	var path: String = _path("skills.campfire", data)
	_string_field(data, "name", path)
	_check_owner(data, path, class_ids)
	_check_choice(_string_field(data, "effect", path), CAMPFIRE_EFFECTS, path, "effect")
	_check_min(_int_field(data, "percent", path), 1, path, "percent")
	_check_min(_int_field(data, "combats", path), 1, path, "combats")


func _check_owner(data: Dictionary, path: String, class_ids: Dictionary) -> void:
	var owner: String = _string_field(data, "class", path)
	if not owner.is_empty() and not class_ids.has(owner):
		_error(path, "classe inexistente: %s" % owner)


func _check_item(entry: Variant) -> void:
	if typeof(entry) != TYPE_DICTIONARY:
		return
	var data: Dictionary = entry
	var path: String = _path("items", data)
	_string_field(data, "name", path)
	var slot: String = _string_field(data, "slot", path)
	_check_choice(slot, ITEM_SLOTS, path, "slot")
	_check_choice(_string_field(data, "rarity", path), RARITIES, path, "rarity")
	_check_min(_int_field(data, "price", path), 0, path, "price")
	if slot == "consumable":
		var hp: int = _int_field(data, "heal_hp_percent", path)
		var mp: int = _int_field(data, "heal_mp_percent", path)
		_check_range(hp, 0, 100, path, "heal_hp_percent")
		_check_range(mp, 0, 100, path, "heal_mp_percent")
		if hp == 0 and mp == 0 and not bool(data.get("reroll", false)):
			_error(path, "consumível sem efeito")
	elif not slot.is_empty():
		_check_stat_mods(data, path)


func _check_enemy(entry: Variant) -> void:
	if typeof(entry) != TYPE_DICTIONARY:
		return
	var data: Dictionary = entry
	var path: String = _path("enemies", data)
	_string_field(data, "name", path)
	var enemy_type: String = _string_field(data, "type", path)
	_check_choice(enemy_type, ENEMY_TYPES, path, "type")
	_check_min(_int_field(data, "base_level", path), 1, path, "base_level")
	_check_stats(data, path, false)
	_string_list(data, "tags", path)
	if not data.has("element_mults"):
		_error(path, "campo faltando: element_mults")
	elif typeof(data["element_mults"]) != TYPE_DICTIONARY:
		_error(path, "element_mults precisa ser um objeto")
	else:
		var mults: Dictionary = data["element_mults"]
		for element: Variant in mults:
			_check_choice(str(element), ELEMENTS, path, "element_mults")
			if typeof(mults[element]) not in [TYPE_INT, TYPE_FLOAT] or float(mults[element]) <= 0.0:
				_error(path, "multiplicador de %s precisa ser número positivo" % str(element))
	_check_phases(data, path, enemy_type == "boss")


func _check_phases(data: Dictionary, path: String, boss: bool) -> void:
	if not data.has("phases") or typeof(data["phases"]) != TYPE_ARRAY:
		_error(path, "campo faltando ou não é lista: phases")
		return
	var phases: Array = data["phases"]
	if phases.is_empty():
		_error(path, "precisa de pelo menos uma fase")
		return
	if boss and (phases.size() < BOSS_MIN_PHASES or phases.size() > BOSS_MAX_PHASES):
		_error(path, "chefe precisa de %d a %d fases (GDD §13), tem %d" % [BOSS_MIN_PHASES, BOSS_MAX_PHASES, phases.size()])
	var previous_threshold: int = 101
	var has_cruel: bool = false
	for index: int in phases.size():
		var phase_path: String = "%s.phases[%d]" % [path, index]
		if typeof(phases[index]) != TYPE_DICTIONARY:
			_error(phase_path, "a fase precisa ser um objeto")
			continue
		var phase: Dictionary = phases[index]
		var threshold: int = _int_field(phase, "below_hp_percent", phase_path)
		if index == 0 and threshold != 100:
			_error(phase_path, "a primeira fase começa em 100")
		elif threshold >= previous_threshold or threshold < 1:
			_error(phase_path, "below_hp_percent precisa descer a cada fase e ficar entre 1 e 100")
		previous_threshold = threshold
		if not phase.has("moves") or typeof(phase["moves"]) != TYPE_ARRAY:
			_error(phase_path, "campo faltando ou não é lista: moves")
			continue
		var moves: Array = phase["moves"]
		if moves.size() < MIN_MOVES or moves.size() > MAX_MOVES:
			_error(phase_path, "precisa de %d a %d golpes (GDD §6), tem %d" % [MIN_MOVES, MAX_MOVES, moves.size()])
		var has_mortal: bool = false
		for move_index: int in moves.size():
			var kind: String = _check_move(moves[move_index], "%s.moves[%d]" % [phase_path, move_index])
			has_cruel = has_cruel or kind == "cruel"
			has_mortal = has_mortal or kind == "mortal"
			if kind == "mortal" and not boss:
				_error(phase_path, "Golpe Mortal só em chefes (GDD §7)")
		if boss and index == phases.size() - 1 and not has_mortal:
			_error(phase_path, "a fase final do chefe precisa de um Golpe Mortal (GDD §13)")
	if boss and not has_cruel:
		_error(path, "chefe precisa de pelo menos um golpe Cruel (GDD §13)")


## Devolve o tipo do golpe, ou "" se inválido.
func _check_move(entry: Variant, path: String) -> String:
	if typeof(entry) != TYPE_DICTIONARY:
		_error(path, "o golpe precisa ser um objeto")
		return ""
	var move: Dictionary = entry
	_string_field(move, "id", path)
	var kind: String = _string_field(move, "kind", path)
	if not _check_choice(kind, MOVE_KINDS, path, "kind"):
		return ""
	if move.has("power") and (typeof(move["power"]) not in [TYPE_INT, TYPE_FLOAT] or float(move["power"]) <= 0.0):
		_error(path, "power precisa ser número positivo")
	if kind == "heal":
		_check_range(_int_field(move, "heal_percent", path), 1, 100, path, "heal_percent")
	if kind == "debuff":
		var effect: String = _string_field(move, "effect", path)
		_check_choice(effect, DEBUFF_EFFECT_IDS, path, "effect")
		_check_range(_int_field(move, "effect_chance", path), 1, 100, path, "effect_chance")
	return kind


func _check_scenario(entry: Variant, enemy_ids: Dictionary) -> void:
	if typeof(entry) != TYPE_DICTIONARY:
		return
	var data: Dictionary = entry
	var path: String = _path("scenarios", data)
	_string_field(data, "name", path)
	_check_min(_int_field(data, "layers", path), 2, path, "layers")
	var low: int = _int_field(data, "min_level", path)
	var high: int = _int_field(data, "max_level", path)
	_check_min(low, 1, path, "min_level")
	if high < low:
		_error(path, "max_level menor que min_level")
	_check_range(_int_field(data, "winnable_target", path), 1, 100, path, "winnable_target")
	_check_enemy_refs(data, "common_enemies", "common", path, enemy_ids)
	_check_enemy_refs(data, "elite_enemies", "elite", path, enemy_ids)
	var boss_id: String = _string_field(data, "boss", path)
	if not boss_id.is_empty():
		_check_enemy_ref(boss_id, "boss", path, enemy_ids)
	_string_list(data, "weather", path)


func _check_enemy_refs(data: Dictionary, key: String, enemy_type: String, path: String, enemy_ids: Dictionary) -> void:
	var refs: PackedStringArray = _string_list(data, key, path)
	if refs.is_empty() and data.has(key):
		_error(path, "%s não pode ser vazio" % key)
	for enemy_id: String in refs:
		_check_enemy_ref(enemy_id, enemy_type, path, enemy_ids)


func _check_enemy_ref(enemy_id: String, enemy_type: String, path: String, enemy_ids: Dictionary) -> void:
	if not enemy_ids.has(enemy_id):
		_error(path, "inimigo inexistente: %s" % enemy_id)
	elif str((enemy_ids[enemy_id] as Dictionary).get("type", "")) != enemy_type:
		_error(path, "%s precisa ser do tipo %s" % [enemy_id, enemy_type])


func _check_stats(data: Dictionary, path: String, complete: bool) -> void:
	if not data.has("stats") or typeof(data["stats"]) != TYPE_DICTIONARY:
		_error(path, "campo faltando ou não é objeto: stats")
		return
	var stats: Dictionary = data["stats"]
	for key: Variant in stats:
		if not STAT_KEYS.has(str(key)):
			_error(path, "atributo desconhecido: %s" % str(key))
		elif typeof(stats[key]) != TYPE_INT and typeof(stats[key]) != TYPE_FLOAT:
			_error(path, "atributo %s precisa ser número" % str(key))
	if complete:
		for key: String in STAT_KEYS:
			if not stats.has(key):
				_error(path, "atributo faltando: %s" % key)
	for key: String in ["hp", "speed"]:
		if not stats.has(key):
			if not complete:
				_error(path, "atributo faltando: %s" % key)
		elif typeof(stats[key]) in [TYPE_INT, TYPE_FLOAT] and int(stats[key]) < 1:
			_error(path, "%s precisa ser pelo menos 1" % key)


func _check_stat_mods(data: Dictionary, path: String) -> void:
	if not data.has("stats") or typeof(data["stats"]) != TYPE_DICTIONARY:
		_error(path, "campo faltando ou não é objeto: stats")
		return
	var stats: Dictionary = data["stats"]
	for key: Variant in stats:
		if not STAT_KEYS.has(str(key)):
			_error(path, "atributo desconhecido: %s" % str(key))
		elif typeof(stats[key]) != TYPE_INT and typeof(stats[key]) != TYPE_FLOAT:
			_error(path, "atributo %s precisa ser número" % str(key))


# --- Utilidades ------------------------------------------------------------------

func _list(doc: Variant, key: String, doc_name: String) -> Array:
	var data: Dictionary = doc
	if not data.has(key) or typeof(data[key]) != TYPE_ARRAY:
		_error(doc_name, "campo faltando ou não é lista: %s" % key)
		return []
	var entries: Array = data[key]
	for index: int in entries.size():
		if typeof(entries[index]) != TYPE_DICTIONARY:
			_error("%s.%s[%d]" % [doc_name, key, index], "a entrada precisa ser um objeto")
	return entries


## Id -> entrada, acusando id faltando ou repetido.
func _ids(entries: Array, where: String) -> Dictionary:
	var found: Dictionary = {}
	for index: int in entries.size():
		if typeof(entries[index]) != TYPE_DICTIONARY:
			continue
		var entry: Dictionary = entries[index]
		var entry_id: String = _string_field(entry, "id", "%s[%d]" % [where, index])
		if entry_id.is_empty():
			continue
		if found.has(entry_id):
			_error(where, "id repetido: %s" % entry_id)
		else:
			found[entry_id] = entry
	return found


func _path(where: String, data: Dictionary) -> String:
	return "%s[%s]" % [where, str(data.get("id", "?"))]


func _string_field(data: Dictionary, key: String, path: String) -> String:
	if not data.has(key):
		_error(path, "campo faltando: %s" % key)
		return ""
	if typeof(data[key]) != TYPE_STRING or str(data[key]).is_empty():
		_error(path, "%s precisa ser texto não vazio" % key)
		return ""
	return str(data[key])


func _int_field(data: Dictionary, key: String, path: String) -> int:
	if not data.has(key):
		_error(path, "campo faltando: %s" % key)
		return 0
	var value: Variant = data[key]
	if typeof(value) == TYPE_INT:
		return int(value)
	if typeof(value) == TYPE_FLOAT and float(value) == floorf(float(value)):
		return int(value)
	_error(path, "%s precisa ser inteiro" % key)
	return 0


func _number_field(data: Dictionary, key: String, path: String) -> float:
	if not data.has(key):
		_error(path, "campo faltando: %s" % key)
		return 0.0
	if typeof(data[key]) != TYPE_INT and typeof(data[key]) != TYPE_FLOAT:
		_error(path, "%s precisa ser número" % key)
		return 0.0
	return float(data[key])


func _bool_field(data: Dictionary, key: String, path: String) -> bool:
	if not data.has(key):
		_error(path, "campo faltando: %s" % key)
		return false
	if typeof(data[key]) != TYPE_BOOL:
		_error(path, "%s precisa ser verdadeiro ou falso" % key)
		return false
	return bool(data[key])


func _string_list(data: Dictionary, key: String, path: String) -> PackedStringArray:
	var found: PackedStringArray = PackedStringArray()
	if not data.has(key):
		_error(path, "campo faltando: %s" % key)
		return found
	if typeof(data[key]) != TYPE_ARRAY:
		_error(path, "%s precisa ser lista" % key)
		return found
	for value: Variant in data[key]:
		if typeof(value) != TYPE_STRING:
			_error(path, "%s só aceita texto" % key)
		else:
			found.append(str(value))
	return found


func _check_choice(value: String, choices: PackedStringArray, path: String, key: String) -> bool:
	if value.is_empty():
		return false
	if not choices.has(value):
		_error(path, "%s desconhecido: %s" % [key, value])
		return false
	return true


func _check_min(value: int, minimum: int, path: String, key: String) -> void:
	if value < minimum:
		_error(path, "%s precisa ser pelo menos %d" % [key, minimum])


func _check_range(value: int, low: int, high: int, path: String, key: String) -> void:
	if value < low or value > high:
		_error(path, "%s precisa ficar entre %d e %d" % [key, low, high])


func _error(path: String, message: String) -> void:
	_errors.append("%s: %s" % [path, message])
