class_name SanctuaryRules
extends RefCounted
## Regras puras do Santuário e do meta-progresso entre Descidas (GDD §9, TASK-030, ADR-0034):
## catálogo da Biblioteca e do Arsenal (respeitando o teto de +10% de bônus numérico permanente)
## e consolidação do Códice (Bestiário) a partir dos inimigos derrotados e quedas da Bibiana.

const MAX_PERMANENT_BONUS_PERCENT: int = 10
const IRON_SKIN_HP_PERCENT: int = 8
const IRON_SKIN_DEF_PERCENT: int = 8
const PROVISIONS_STARTING_GOLD: int = 35
const PROVISIONS_STARTING_ITEM: String = "dirty_ether"
const FURY_STARTING_SKILL: String = "war_cry"
const EDGE_CAMPFIRE_BUFF: String = "sharpen_edge"
const EDGE_CAMPFIRE_COMBATS: int = 2

const UPGRADES: Array[Dictionary] = [
	{
		"id": "tome_of_fury",
		"wing": "library",
		"name": "Tomo do Grito de Guerra",
		"cost": 12,
		"description": "Bibiana inicia toda Descida com Grito de Guerra já aprendido no grimório.",
	},
	{
		"id": "tome_of_edge",
		"wing": "library",
		"name": "Manual do Fio Afiado",
		"cost": 16,
		"description": "Acender uma fogueira concede também Afiar o Fio (+10 de CRIT por 2 lutas).",
	},
	{
		"id": "blessing_iron_skin",
		"wing": "arsenal",
		"name": "Bênção da Malha Antiga",
		"cost": 15,
		"description": "Bônus permanente de +8% no HP máximo e +8% na DEF base (teto do GDD §9: +10%).",
	},
	{
		"id": "pack_of_provisions",
		"wing": "arsenal",
		"name": "Fardo do Viajante",
		"cost": 18,
		"description": "Bibiana inicia toda Descida com +35 moedas de ouro e 1 Éter Sujo extra.",
	},
]

const ENEMY_ORDER: Array[String] = [
	"infected_citizen",
	"giant_rat",
	"carrion_crow",
	"plague_hound",
	"bell_ghost",
	"wandering_bones",
	"sewer_slime",
	"alley_leech",
	"hanged_man",
	"stitched_horror",
	"blind_censer_bearer",
	"rotten_executioner",
	"rat_mother",
	"bell_warden",
	"gravedigger",
]


static func catalog() -> Array[Dictionary]:
	var copy: Array[Dictionary] = []
	for entry: Dictionary in UPGRADES:
		copy.append(entry.duplicate(true))
	return copy


static func wing_catalog(wing: String) -> Array[Dictionary]:
	var found: Array[Dictionary] = []
	for entry: Dictionary in UPGRADES:
		if str(entry["wing"]) == wing:
			found.append(entry.duplicate(true))
	return found


static func find_upgrade(upgrade_id: String) -> Dictionary:
	for entry: Dictionary in UPGRADES:
		if str(entry["id"]) == upgrade_id:
			return entry.duplicate(true)
	return {}


static func can_buy(upgrade_id: String, echoes: int, unlocked: Array) -> bool:
	if unlocked.has(upgrade_id):
		return false
	var entry: Dictionary = find_upgrade(upgrade_id)
	if entry.is_empty():
		return false
	return echoes >= int(entry["cost"])


static func buy(upgrade_id: String, echoes: int, unlocked: Array) -> Dictionary:
	var next_unlocks: Array[String] = []
	for id: Variant in unlocked:
		next_unlocks.append(str(id))
	if not can_buy(upgrade_id, echoes, next_unlocks):
		return {"ok": false, "echoes": echoes, "unlocks": next_unlocks}
	var entry: Dictionary = find_upgrade(upgrade_id)
	next_unlocks.append(upgrade_id)
	return {
		"ok": true,
		"echoes": echoes - int(entry["cost"]),
		"unlocks": next_unlocks,
	}


static func record_run_in_bestiary(bestiary: Dictionary, defeated_ids: Array[String], killer_id: String) -> Dictionary:
	var updated: Dictionary = bestiary.duplicate(true)
	for enemy_id: String in defeated_ids:
		if enemy_id.is_empty():
			continue
		var entry: Dictionary = updated.get(enemy_id, {"kills": 0, "deaths": 0}).duplicate()
		entry["kills"] = int(entry.get("kills", 0)) + 1
		updated[enemy_id] = entry
	if not killer_id.is_empty():
		var k_entry: Dictionary = updated.get(killer_id, {"kills": 0, "deaths": 0}).duplicate()
		k_entry["deaths"] = int(k_entry.get("deaths", 0)) + 1
		updated[killer_id] = k_entry
	return updated


static func bestiary_entries(data: GameData, bestiary: Dictionary) -> Array[Dictionary]:
	var entries: Array[Dictionary] = []
	var ids: Array[String] = []
	for ordered_id: String in ENEMY_ORDER:
		if data.enemies.has(ordered_id):
			ids.append(ordered_id)
	for enemy_id: String in data.enemies:
		if not ids.has(enemy_id):
			ids.append(enemy_id)
	for enemy_id: String in ids:
		var raw: Dictionary = data.enemies[enemy_id]
		var record: Dictionary = bestiary.get(enemy_id, {})
		entries.append({
			"id": enemy_id,
			"name": str(raw["name"]),
			"type": str(raw["type"]),
			"type_label": _type_label(str(raw["type"])),
			"base_level": int(raw["base_level"]),
			"coin_move": _coin_move_summary(raw),
			"reaction": _reaction_summary(raw),
			"kills": int(record.get("kills", 0)),
			"deaths": int(record.get("deaths", 0)),
		})
	return entries


static func _type_label(enemy_type: String) -> String:
	match enemy_type:
		"common":
			return "Comum"
		"elite":
			return "Elite"
		"mini_boss":
			return "Mini Boss"
		"boss":
			return "Chefe"
		_:
			return enemy_type


static func _coin_move_summary(raw: Dictionary) -> String:
	var names: Dictionary = {
		"feverish_hug": "Abraço Febril",
		"filthy_bite": "Mordida Imunda",
		"eye_peck": "Bicada no Olho",
		"unrelenting_fangs": "Presas Incansáveis",
		"guillotine": "Guilhotina",
		"knell_wail": "Lamento do Sino",
		"bone_rattle": "Chacoalhar de Ossos",
		"engulf": "Engolir",
		"blood_kiss": "Beijo de Sangue",
		"hood_drop": "Capuz na Cabeça",
		"sulfur_smoke": "Defumação de Enxofre",
		"wrecking_arm": "Braço Remendado",
		"swarm_bite": "Mordida do Enxame",
		"deafening_toll": "Badalo Ensurdecedor",
		"shovel": "Pazada",
		"grave": "Enterro",
	}
	var effects: Dictionary = {
		"weakened": "Fraqueza",
		"blinded": "Cegueira",
		"slowed": "Lentidão",
		"cursed": "Maldição",
		"poison": "Veneno",
		"leptospirosis": "Leptospirose",
	}
	for phase: Dictionary in raw.get("phases", []):
		for move: Dictionary in phase.get("moves", []):
			var kind: String = str(move.get("kind", ""))
			if kind in ["heavy", "cruel", "mortal"]:
				var move_id: String = str(move.get("id", ""))
				var label: String = str(names.get(move_id, str(move.get("name", move_id))))
				var fail: String = str(move.get("fail_effect", move.get("fail_disease", "")))
				if fail.is_empty():
					return "%s (dano extra na Coroa)" % label
				var fail_label: String = str(effects.get(fail, fail))
				return "%s (Coroa: %s)" % [label, fail_label]
	return "Sem golpe de moeda"


static func _reaction_summary(raw: Dictionary) -> String:
	for phase: Dictionary in raw.get("phases", []):
		var reactions: Array = phase.get("reactions", [])
		if not reactions.is_empty():
			var first: Dictionary = reactions[0]
			return "%s → %s" % [str(first.get("reason", "Reage")), str(first.get("move", ""))]
	return "Ciclo fixo"
