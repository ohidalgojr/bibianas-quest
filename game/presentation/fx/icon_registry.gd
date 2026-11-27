class_name IconRegistry
extends RefCounted
## Ícones (34x34, CC0, pacote "496 RPG Icons" de gnola14, `assets/LICENSES.md`) por id do jogo:
## itens, skills, efeitos de combate, doenças e tipos de nó do mapa (TASK-043, ADR-0036).
## `texture_for` devolve a textura, ou null se o id não tem ícone (o teste cobre todos os ids).

const DIR: String = "res://assets/gnola14/rpg_icons/"

const ITEMS: Dictionary = {
	"murky_potion": "P_Green01", "lucky_coin": "I_GoldCoin", "firewood": "E_Wood01", "dirty_ether": "P_Blue01",
	"sword_and_shield": "W_Sword001", "old_chainmail": "A_Armour01", "worn_longsword": "W_Sword005",
	"dented_plate": "A_Armour03", "bone_dagger": "W_Dagger003", "rusty_axe": "W_Axe001", "spiked_mace": "W_Mace003",
	"leather_vest": "A_Clothing01", "reinforced_mail": "A_Armor05", "warden_plate": "A_Armour02",
	"rotting_bread": "I_C_Bread", "rancid_elixir": "P_Red03", "sage_smoke": "P_Yellow03", "reaper_sickle": "W_Dagger010",
	"bellringer_blade": "W_Sword012", "executioner_axe": "W_Axe008", "blood_stiletto": "W_Dagger015", "soaked_cloak": "A_Clothing02",
	"bone_cuirass": "A_Armor04", "penitent_armor": "A_Armour02", "plague_hood": "C_Hat01", "bellringer_helm": "C_Elm01",
	"thorn_crown": "C_Hat02", "rotten_shield": "E_Metal03", "traveler_lantern": "I_Bottle03", "torn_prayer_book": "W_Book03",
	"giant_rat_tooth": "I_ScorpionClaw", "glass_eye": "I_Eye", "hanged_rope": "Ac_Necklace03", "penitent_medal": "Ac_Medal02",
	"worn_charm": "Ac_Necklace01", "iron_ring": "Ac_Ring01", "sharp_claw": "I_Fang", "grave_bell": "Ac_Medal01",
}
const SKILLS: Dictionary = {
	"shield_bash": "S_Sword01", "charge": "S_Sword03", "bulwark": "S_Buff01", "whirlwind": "S_Axe01",
	"war_cry": "S_Buff05", "second_wind": "S_Holy01", "sharpen_blade": "S_Sword05", "reinforce_shield": "S_Buff03",
	"sharpen_edge": "S_Dagger02",
}
## Chaves em minúsculas, na ordem de [enum CombatEffect.Kind].
const EFFECTS: Dictionary = {
	"defending": "S_Buff02", "bulwark": "S_Buff01", "armor_down": "S_Shadow01", "slowed": "S_Ice01",
	"poison": "S_Poison01", "weakened": "S_Shadow03", "empowered": "S_Fire01", "blinded": "S_Shadow05",
	"cursed": "S_Shadow07",
}
const DISEASES: Dictionary = {"leptospirosis": "S_Poison05"}
## Índice de [enum MapNode.Kind]: START, BATTLE, AMBUSH, ELITE, CHEST, EVENT, BONFIRE, MINI_BOSS, BOSS.
const NODES: Array[String] = [
	"I_Key01", "S_Sword02", "S_Shadow08", "S_Axe03", "I_Chest01", "I_Scroll", "S_Fire03", "S_Shadow10", "S_Shadow12",
]
const UI: Dictionary = {
	"gold": "I_GoldCoin", "embers": "S_Fire05", "firewood": "E_Wood01", "luck": "I_Clover", "potion": "P_Green01",
	"echoes": "I_Eye", "power": "S_Buff04", "attack": "S_Sword02", "defend": "S_Buff02", "flee": "S_Wind01", "ether": "P_Blue01",
}

## Ícones pintados 96x96 do Gemini (`tools/make_icons.py`), preferidos sobre o pacote CC0 (TASK-072).
const PAINTED_DIR: String = "res://assets/bibiana/icons/"
## Nome do ícone de cada tipo de nó, na ordem de [enum MapNode.Kind].
const NODE_NAMES: Array[String] = ["start", "battle", "ambush", "elite", "chest", "event", "bonfire", "mini_boss", "boss"]
## Ids de `ui` que moram em `action/` ou `item/` na folha pintada.
const UI_ACTION: Array[String] = ["attack", "defend", "flee"]
const UI_ITEM: Dictionary = {"potion": "murky_potion", "ether": "dirty_ether"}

static var _cache: Dictionary = {}


## Caminho do ícone pintado para a categoria e o id, ou "" se não houver.
static func painted_path(category: String, id: String) -> String:
	var folder: String = category
	var name_id: String = id
	match category:
		"effect":
			folder = "status"
		"disease":
			folder = "status"
			name_id = "disease"
		"node":
			folder = "node"
			var index: int = int(id)
			name_id = NODE_NAMES[index] if index >= 0 and index < NODE_NAMES.size() else ""
		"ui":
			if UI_ACTION.has(id):
				folder = "action"
			elif UI_ITEM.has(id):
				folder = "item"
				name_id = str(UI_ITEM[id])
	if name_id.is_empty():
		return ""
	var path: String = "%s%s/%s.png" % [PAINTED_DIR, folder, name_id]
	return path if ResourceLoader.exists(path) else ""


static func texture_for(category: String, id: String) -> Texture2D:
	var painted: String = painted_path(category, id)
	if not painted.is_empty():
		if not _cache.has(painted):
			_cache[painted] = load(painted) as Texture2D
		return _cache[painted]
	var table: Dictionary = {"item": ITEMS, "skill": SKILLS, "effect": EFFECTS, "disease": DISEASES, "ui": UI}
	var file_name: String = ""
	if category == "node":
		var index: int = int(id)
		file_name = NODES[index] if index >= 0 and index < NODES.size() else ""
	elif table.has(category):
		file_name = str((table[category] as Dictionary).get(id, ""))
	if file_name.is_empty():
		return null
	return _load(file_name)


static func _load(file_name: String) -> Texture2D:
	if _cache.has(file_name):
		return _cache[file_name]
	var path: String = DIR + file_name + ".png"
	var tex: Texture2D = load(path) as Texture2D if ResourceLoader.exists(path) else null
	_cache[file_name] = tex
	return tex


## Todos os arquivos citados nas tabelas (para o teste conferir que existem).
static func all_files() -> PackedStringArray:
	var found: PackedStringArray = PackedStringArray()
	for table: Dictionary in [ITEMS, SKILLS, EFFECTS, DISEASES, UI]:
		for key: String in table:
			found.append(str(table[key]))
	found.append_array(PackedStringArray(NODES))
	return found
