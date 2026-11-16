class_name RunPanels
extends RefCounted
## Controlador das telas de recompensa, loja e fogueira (TASK-010, ADR-0015). Lê o
## [RunState], entrega textos e estados dos botões e repassa as ações. Não tem nós, como
## o [CombatSession]; nenhuma regra é calculada aqui.

const STAT_LABELS: Dictionary = {
	"hp": "HP", "mp": "MP", "strength": "FOR", "mind": "MEN", "defense": "DEF", "resistance": "RES",
	"speed": "VEL", "accuracy": "PRE", "evasion": "ESQ", "crit": "CRIT", "luck": "SORTE",
}
const SLOT_NAMES: Dictionary = {"weapon": "Arma", "armor": "Armadura", "consumable": "Consumível"}

var run: RunState


func _init(run_state: RunState) -> void:
	run = run_state


# --- Recompensa (GDD §9 e §15) ------------------------------------------------------

## O que a última luta rendeu, lido dos eventos depois do último fim de luta.
func reward_view() -> Dictionary:
	var power: float = 0.0
	var gold: int = 0
	var max_hp: int = run.player_stats().max_hp
	for index: int in range(run.history.size() - 1, -1, -1):
		var event: RunEvent = run.history[index]
		if event.type == RunEvent.Type.FIGHT_ENDED:
			break
		if event.type == RunEvent.Type.POWER:
			power += event.amount
		elif event.type == RunEvent.Type.GOLD:
			gold += event.value
	return {
		"title": "Vitória!",
		"power": power,
		"gold": gold,
		"lines": [
			"Poder +%.2f (agora %.2f). HP máximo %d." % [power, run.power, max_hp],
			"Ouro +%d (total %d)." % [gold, run.gold],
		],
	}


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
	}


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
