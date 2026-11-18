class_name RunPanels
extends RefCounted
## Controlador das telas de recompensa, loja e fogueira (TASK-010, ADR-0015). Lê o
## [RunState], entrega textos e estados dos botões e repassa as ações. Não tem nós, como
## o [CombatSession]; nenhuma regra é calculada aqui.

const STAT_LABELS: Dictionary = {
	"hp": "HP", "mp": "MP", "strength": "FOR", "mind": "MEN", "defense": "DEF", "resistance": "RES",
	"speed": "VEL", "accuracy": "PRE", "evasion": "ESQ", "crit": "CRIT", "luck": "SORTE",
}
## Campo de [Stats] e rótulo, na ordem em que a recompensa lista as mudanças.
const STAT_FIELDS: Array[Array] = [
	["max_hp", "HP"], ["max_mp", "MP"], ["strength", "FOR"], ["mind", "MEN"], ["defense", "DEF"],
	["resistance", "RES"], ["speed", "VEL"], ["precision", "PRE"], ["evasion", "ESQ"], ["crit", "CRIT"],
	["luck", "SORTE"],
]
const RARITY_NAMES: Dictionary = {"worn": "Gasto", "common": "Comum", "uncommon": "Incomum", "rare": "Raro"}
const SLOT_NAMES: Dictionary = {"weapon": "Arma", "armor": "Armadura", "consumable": "Consumível"}

var run: RunState


func _init(run_state: RunState) -> void:
	run = run_state


# --- Recompensa (GDD §9 e §15) ------------------------------------------------------

## O que a última vitória rendeu (ADR-0021), lido do [member RunState.last_reward]: quem
## caiu, Poder, ouro e cada atributo que mudou, no formato "FOR 14 → 15".
func reward_view() -> Dictionary:
	var reward: Dictionary = run.last_reward
	var lines: Array[String] = []
	var title: String = "Vitória!"
	var power: float = float(reward.get("power", 0.0))
	var gold: int = int(reward.get("gold", 0))
	if not reward.is_empty():
		var enemy_name: String = str(run.data.enemies[reward["enemy_id"]]["name"])
		lines.append("%s (nível %d) foi derrotado. Inimigos derrotados: %d." % [
			enemy_name, int(reward["level"]), run.enemies_defeated])
		lines.append("Poder %.2f → %.2f" % [run.power - power, run.power])
		var level_before: int = RunRules.level_of(run.power - power)
		if run.level() > level_before:
			title = "Subiu de nível! %d → %d" % [level_before, run.level()]
		lines.append_array(stat_changes(reward["before"], reward["after"]))
	lines.append("Ouro +%d (total %d)." % [gold, run.gold])
	if bool(reward.get("bad_luck", false)):
		lines.append("Maré de azar: o achado veio melhor.")
	if bool(reward.get("lucky_coin", false)):
		lines.append("Encontrou: Moeda da Sorte.")
	var consumable: String = str(reward.get("consumable", ""))
	if not consumable.is_empty():
		lines.append("Encontrou: %s." % str(run.data.items[consumable]["name"]))
	return {"title": title, "power": power, "gold": gold, "lines": lines, "drop": drop_view()}


## O equipamento caído, à espera de decisão; vazio se não há ([constant RunRules]).
func drop_view() -> Dictionary:
	if run.pending_drop.is_empty():
		return {}
	var item_id: String = run.pending_drop
	var item: Dictionary = run.data.items[item_id]
	var slot: String = str(item["slot"])
	var old_id: String = str(run.equipment.get(slot, ""))
	var changes: Array[String] = stat_changes(run.player_stats(), run.stats_with(item_id))
	return {
		"id": item_id,
		"name": str(item["name"]),
		"rarity": str(RARITY_NAMES.get(str(item["rarity"]), "")),
		"slot": str(SLOT_NAMES.get(slot, slot)),
		"effect": stats_text(item.get("stats", {})),
		"replaces": str(run.data.items[old_id]["name"]) if not old_id.is_empty() else "",
		"changes": changes,
		"sell_value": RunRules.sell_value(run.item_price(item_id)),
	}


func equip_drop() -> bool:
	return run.take_drop()


func sell_drop() -> bool:
	return run.sell_drop()


## Uma linha por atributo que mudou entre [param before] e [param after].
static func stat_changes(before: Stats, after: Stats) -> Array[String]:
	var found: Array[String] = []
	for entry: Array in STAT_FIELDS:
		var field: String = str(entry[0])
		var old_value: int = int(before.get(field))
		var new_value: int = int(after.get(field))
		if old_value != new_value:
			found.append("%s %d → %d" % [str(entry[1]), old_value, new_value])
	return found


# --- Baú (D5, ADR-0027) ---------------------------------------------------------------

## O baú aberto, com o que ele deu e as formas de multiplicar (uma vez).
func chest_view() -> Dictionary:
	var chest: Dictionary = run.last_chest
	if chest.is_empty():
		return {}
	var boosted: bool = bool(chest["boosted"])
	var lines: Array[String] = ["Baú: +%d de ouro (total %d)." % [int(chest["gold"]), run.gold]]
	if boosted:
		lines.append("Multiplicador ×%.2f: +%d de ouro%s." % [int(chest["multiplier"]) / 100.0, int(chest["bonus"]),
			" e uma Poção Turva" if bool(chest.get("potion", false)) else ""])
	return {
		"title": "Baú",
		"lines": lines,
		"boosted": boosted,
		"lucky_coins": run.consumable_count(RunRules.LUCKY_COIN_ID),
		"can_lucky": run.can_boost_chest("lucky_coin"),
		"can_ad": run.can_boost_chest("ad"),
	}


func boost_chest(source: String) -> bool:
	return run.boost_chest(source)


func close_chest() -> void:
	run.last_chest = {}


# --- Loja (GDD §15) ------------------------------------------------------------------

func shop_view() -> Dictionary:
	var offer: Array[Dictionary] = []
	for item_id: String in run.shop_offer:
		offer.append(item_view(item_id))
	return {
		"gold": run.gold,
		"offer": offer,
		"reroll_cost": run.reroll_cost(),
		"can_reroll": run.phase == RunState.Phase.SHOP and run.gold >= run.reroll_cost(),
		"bag": "Mochila: %d/%d" % [run.total_consumables(), RunRules.MAX_CONSUMABLES],
		"skill": skill_view(),
	}


## A skill à venda (ADR-0024), ou vazio se não há.
func skill_view() -> Dictionary:
	if run.skill_offer.is_empty():
		return {}
	var skill: CombatSkill = run.data.combat_skill(run.skill_offer)
	var price: int = run.data.skill_price(run.skill_offer)
	var reason: String = ""
	if run.learned_skills.size() >= RunRules.MAX_SKILLS:
		reason = "Espaços de skill cheios"
	elif run.gold < price:
		reason = "Ouro insuficiente"
	return {
		"id": skill.id,
		"name": skill.display_name,
		"cost": skill.cost,
		"price": price,
		"description": skill_text(skill),
		"can_buy": run.can_buy_skill(),
		"reason": reason,
		"slots": "Skills: %d/%d" % [run.learned_skills.size(), RunRules.MAX_SKILLS],
	}


static func skill_text(skill: CombatSkill) -> String:
	match skill.effect:
		CombatSkill.Effect.POWER_STRIKE:
			return "Golpe de %.1f×FOR" % skill.power
		CombatSkill.Effect.WAR_CRY:
			return "FOR e MEN +%d%% por %d turnos" % [roundi(CombatEffect.EMPOWER_ATTACK * 100.0), CombatEffect.EMPOWER_TURNS]
		CombatSkill.Effect.MEND:
			return "Recupera %d%% do HP" % CombatEffect.MEND_PERCENT
	return "Skill da classe"


func buy_skill() -> bool:
	return run.buy_skill()


func item_view(item_id: String) -> Dictionary:
	var item: Dictionary = run.data.items[item_id]
	var price: int = run.item_price(item_id)
	var reason: String = ""
	if run.gold < price:
		reason = "Ouro insuficiente"
	elif not run.can_buy(item_id):
		reason = "Mochila cheia"
	return {
		"id": item_id,
		"name": str(item["name"]),
		"slot": str(SLOT_NAMES.get(str(item["slot"]), str(item["slot"]))),
		"price": price,
		"description": item_description(item_id),
		"can_buy": run.can_buy(item_id),
		"reason": reason,
	}


## Efeito do item em texto. Equipamento mostra o que está equipado no mesmo espaço.
func item_description(item_id: String) -> String:
	var item: Dictionary = run.data.items[item_id]
	var slot: String = str(item["slot"])
	if slot == "consumable":
		var parts: PackedStringArray = PackedStringArray()
		if int(item.get("heal_hp_percent", 0)) > 0:
			parts.append("recupera %d%% do HP" % int(item["heal_hp_percent"]))
		if int(item.get("heal_mp_percent", 0)) > 0:
			parts.append("recupera %d%% do MP" % int(item["heal_mp_percent"]))
		var joined: String = ", ".join(parts)
		return joined.substr(0, 1).to_upper() + joined.substr(1)
	var text: String = stats_text(item.get("stats", {}))
	var equipped: String = str(run.equipment.get(slot, ""))
	if not equipped.is_empty():
		text += " (equipado: %s)" % str(run.data.items[equipped]["name"])
	return text


static func stats_text(mods: Dictionary) -> String:
	if mods.is_empty():
		return "Sem bônus"
	var parts: PackedStringArray = PackedStringArray()
	for key: String in mods:
		parts.append("%s %+d" % [str(STAT_LABELS.get(key, key)), int(mods[key])])
	return ", ".join(parts)


func buy(item_id: String) -> bool:
	return run.buy(item_id)


func reroll() -> bool:
	return run.reroll_shop()


# --- Fogueira (GDD §12) --------------------------------------------------------------

func campfire_view() -> Dictionary:
	var stats: Stats = run.player_stats()
	var skills: Array[Dictionary] = []
	for skill_id: String in run.campfire_skills():
		var skill: Dictionary = run.data.campfire_skills[skill_id]
		skills.append({
			"id": skill_id,
			"name": str(skill["name"]),
			"description": campfire_skill_text(skill),
			"can_use": run.phase == RunState.Phase.CAMPFIRE and run.embers >= RunRules.CAMPFIRE_SKILL_COST,
			"left": int(run.buffs.get(skill_id, 0)),
		})
	return {
		"embers": run.embers,
		"status": "HP %d/%d    MP %d/%d" % [run.hp, stats.max_hp, run.mp, stats.max_mp],
		"rest_cost": RunRules.REST_COST,
		"rest_text": "Recupera %d%% do HP e do MP" % RunRules.REST_PERCENT,
		"can_rest": run.phase == RunState.Phase.CAMPFIRE and run.embers >= RunRules.REST_COST,
		"skill_cost": RunRules.CAMPFIRE_SKILL_COST,
		"skills": skills,
	}


static func campfire_skill_text(skill: Dictionary) -> String:
	var what: String = "FOR e MEN" if str(skill["effect"]) == "damage_up" else "DEF"
	return "%s +%d%% por %d lutas" % [what, int(skill["percent"]), int(skill["combats"])]


func rest() -> bool:
	return run.rest()


func use_skill(skill_id: String) -> bool:
	return run.use_campfire_skill(skill_id)
