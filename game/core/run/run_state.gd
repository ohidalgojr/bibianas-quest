class_name RunState
extends RefCounted
## Estado de uma Descida (GDD §4): semente, cenário e mapa, nó atual, Poder, ouro, HP
## e MP, inventário, equipamento e buffs de fogueira. Cada ação pública só vale na fase
## certa; ação inválida devolve false e não muda nada. Cada mudança vira um [RunEvent]
## em [member history]. Leituras no ADR-0011.

enum Phase { CHOOSING, FIGHT, SHOP, CAMPFIRE, VICTORY, DEFEAT }

const PLAYER_NAME: String = "Bibiana"

var data: GameData
var streams: RngStreams
var coin: CoinState = CoinState.new()
var class_id: String = "warrior"
var scenario_ids: Array[String] = []
var scenario_index: int = 0
var map: MapGraph
var current_node_id: int = 0
var phase: Phase = Phase.CHOOSING
var power: float = RunRules.STARTING_POWER
var gold: int = 0
var hp: int = 1
var mp: int = 0
## Id do consumível -> quantidade.
var consumables: Dictionary = {}
## Slot -> id do item equipado.
var equipment: Dictionary = {}
## Id da skill de fogueira -> lutas restantes.
var buffs: Dictionary = {}
var embers: int = 0
var shop_offer: Array[String] = []
var shop_rerolls: int = 0
var combat: Combat
var nodes_cleared: int = 0
## Inimigos derrotados na Descida e o que a última vitória rendeu (ADR-0021): quem, nível,
## Poder, ouro e os atributos antes e depois. Só para a apresentação.
var enemies_defeated: int = 0
var last_reward: Dictionary = {}
## Equipamento caído na última vitória, à espera de Equipar ou Vender (ADR-0022).
var pending_drop: String = ""
## Quem derrotou a Bibiana (id do inimigo e nível), para a tela de morte (GDD §26).
var defeated_by_id: String = ""
var defeated_by_level: int = 0
var history: Array[RunEvent] = []
## Simulações da checagem de vencibilidade de cada mapa (GDD §5; 0 desliga).
var winnability_runs: int = 0
## Resultado da checagem do mapa do cenário atual.
var map_check: Winnability


func _init(game_data: GameData, run_seed: int, run_class: String = "warrior", run_scenarios: Array[String] = [],
		map_check_runs: int = 0, given_map: MapGraph = null) -> void:
	data = game_data
	winnability_runs = map_check_runs
	streams = RngStreams.new(run_seed)
	class_id = run_class
	scenario_ids = run_scenarios.duplicate()
	if scenario_ids.is_empty():
		for scenario_id: String in data.scenarios:
			scenario_ids.append(scenario_id)
	var entry: Dictionary = data.classes[class_id]
	equipment["weapon"] = str(entry["starting_weapon"])
	equipment["armor"] = str(entry["starting_armor"])
	for item_id: String in RunRules.STARTING_ITEMS:
		consumables[item_id] = int(RunRules.STARTING_ITEMS[item_id])
	var stats: Stats = player_stats()
	hp = stats.max_hp
	mp = stats.max_mp
	if given_map != null:
		# Simulação da checagem de vencibilidade: usa o mapa dado, sem gerar outro.
		map = given_map
		current_node_id = map.start_id
		map_check = Winnability.new()
	else:
		_enter_scenario(0)


# --- Consultas -------------------------------------------------------------------

func is_over() -> bool:
	return phase == Phase.VICTORY or phase == Phase.DEFEAT


func scenario() -> Dictionary:
	return data.scenario(scenario_ids[scenario_index])


func current_node() -> MapNode:
	return map.node_by_id(current_node_id)


## Os destinos que o jogador vê agora (GDD §5).
func options() -> Array[MapNode]:
	if phase != Phase.CHOOSING:
		return []
	return map.options_from(current_node_id)


## Atributos da Bibiana agora: classe e Poder (GDD §8 e §9), mais equipamento e buffs
## de fogueira ativos (ADR-0011).
func player_stats() -> Stats:
	return _stats_for(equipment)


## Atributos se [param item_id] fosse equipado no lugar do que está no espaço dele.
func stats_with(item_id: String) -> Stats:
	var trial: Dictionary = equipment.duplicate()
	trial[str(data.items[item_id]["slot"])] = item_id
	return _stats_for(trial)


func _stats_for(worn: Dictionary) -> Stats:
	var stats: Stats = data.class_stats(class_id).scaled_for_power(power)
	for slot: String in worn:
		var mods: Dictionary = data.items[worn[slot]].get("stats", {})
		for key: String in mods:
			var field: String = _stat_field(key)
			stats.set(field, int(stats.get(field)) + int(mods[key]))
	for skill_id: String in buffs:
		var skill: Dictionary = data.campfire_skills[skill_id]
		var factor: float = 1.0 + int(skill["percent"]) / 100.0
		match str(skill["effect"]):
			"damage_up":
				stats.strength = roundi(stats.strength * factor)
				stats.mind = roundi(stats.mind * factor)
			"defense_up":
				stats.defense = roundi(stats.defense * factor)
	stats.max_hp = maxi(stats.max_hp, 1)
	stats.speed = maxi(stats.speed, 1)
	return stats


## Chefes derrotados até agora: os cenários já vencidos, mais o último se a Descida foi vencida.
func bosses_defeated() -> int:
	return scenario_index + (1 if phase == Phase.VICTORY else 0)


## Nível da Bibiana agora (ADR-0023).
func level() -> int:
	return RunRules.level_of(power)


## Ecos desta Descida; só valem depois do fim (ADR-0016).
func echoes_earned() -> int:
	if not is_over():
		return 0
	return RunRules.echoes(nodes_cleared, bosses_defeated())


func consumable_count(item_id: String) -> int:
	return int(consumables.get(item_id, 0))


func total_consumables() -> int:
	var total: int = 0
	for item_id: String in consumables:
		total += int(consumables[item_id])
	return total


## Quantos ainda podem ser usados na luta em andamento.
func available_in_fight(item_id: String) -> int:
	if combat == null:
		return consumable_count(item_id)
	return consumable_count(item_id) - _used_in_fight(item_id)


func campfire_skills() -> Array[String]:
	var found: Array[String] = []
	for skill_id: Variant in data.classes[class_id]["campfire_skills"]:
		found.append(str(skill_id))
	return found


func item_price(item_id: String) -> int:
	return int(data.items[item_id]["price"])


# --- Mapa ------------------------------------------------------------------------

func choose_node(node_id: int) -> bool:
	if phase != Phase.CHOOSING:
		return false
	var chosen: MapNode = null
	for option: MapNode in options():
		if option.id == node_id:
			chosen = option
	if chosen == null:
		return false
	current_node_id = node_id
	_emit(RunEvent.Type.NODE, MapNode.KIND_LETTERS[chosen.kind], node_id)
	if chosen.is_fight():
		_begin_fight(chosen)
	elif chosen.kind == MapNode.Kind.CHEST:
		var level: int = RunRules.layer_level(chosen.layer, map.layer_count,
			int(scenario()["min_level"]), int(scenario()["max_level"]))
		_gain_gold(RunRules.chest_gold(level, streams.loot()), "chest")
		nodes_cleared += 1
	elif chosen.kind == MapNode.Kind.BONFIRE:
		embers = RunRules.EMBERS
		phase = Phase.CAMPFIRE
		_emit(RunEvent.Type.CAMPFIRE, "open", embers)
	else:
		nodes_cleared += 1
	return true


# --- Luta ------------------------------------------------------------------------

## Fecha a luta já terminada e aplica o resultado: Poder e ouro na vitória (GDD §9 e
## §15), nada na fuga, fim da Descida na derrota.
func finish_fight() -> bool:
	if phase != Phase.FIGHT or combat == null or combat.outcome == Combat.Outcome.ONGOING:
		return false
	var node: MapNode = current_node()
	for item_id: String in consumables.keys():
		var used: int = _used_in_fight(item_id)
		if used > 0:
			consumables[item_id] = consumable_count(item_id) - used
			_emit(RunEvent.Type.ITEM_USED, item_id, used)
	hp = combat.player.hp
	mp = combat.player.mp
	var outcome: Combat.Outcome = combat.outcome
	combat = null
	_emit(RunEvent.Type.FIGHT_ENDED, "", outcome)
	nodes_cleared += 1
	match outcome:
		Combat.Outcome.DEFEAT:
			defeated_by_id = node.enemy_id
			defeated_by_level = node.level
			_end(false)
		Combat.Outcome.FLED:
			phase = Phase.CHOOSING
		Combat.Outcome.VICTORY:
			var enemy_type: String = RunRules.enemy_type_for(node.kind)
			var stats_before: Stats = player_stats()
			var gold_before: int = gold
			var power_gain: float = RunRules.power_gain(node.level, enemy_type)
			_gain_power(power_gain)
			_gain_gold(RunRules.gold_drop(node.level, enemy_type, streams.loot()), "fight")
			enemies_defeated += 1
			last_reward = {"enemy_id": node.enemy_id, "level": node.level, "power": power_gain,
				"gold": gold - gold_before, "before": stats_before, "after": player_stats()}
			_roll_drops(enemy_type)
			if node.kind == MapNode.Kind.BOSS:
				if scenario_index + 1 < scenario_ids.size():
					_enter_scenario(scenario_index + 1)
				else:
					_end(true)
			else:
				_open_shop()
	return true


func _begin_fight(node: MapNode) -> void:
	var veteran: bool = str(data.classes[class_id]["passive"]) == "veteran"
	var unit: Combatant = Combatant.player(PLAYER_NAME, player_stats(), veteran)
	unit.hp = clampi(hp, 1, unit.stats.max_hp)
	unit.mp = clampi(mp, 0, unit.stats.max_mp)
	# Os buffs valem nesta luta e contam ao começar (ADR-0011).
	for skill_id: String in buffs.keys():
		buffs[skill_id] = int(buffs[skill_id]) - 1
		if int(buffs[skill_id]) <= 0:
			buffs.erase(skill_id)
	combat = Combat.new(unit, data.make_enemy(node.enemy_id, node.level), streams, coin)
	phase = Phase.FIGHT
	_emit(RunEvent.Type.FIGHT_STARTED, node.enemy_id, node.level)
	combat.start()


func _used_in_fight(item_id: String) -> int:
	if combat == null:
		return 0
	var used: int = 0
	for event: CombatEvent in combat.history:
		if event.type == CombatEvent.Type.ACTION and event.side == Combatant.PLAYER and event.label == item_id:
			used += 1
	return used


# --- Fogueira (GDD §12) ------------------------------------------------------------

func rest() -> bool:
	if phase != Phase.CAMPFIRE or embers < RunRules.REST_COST:
		return false
	embers -= RunRules.REST_COST
	var stats: Stats = player_stats()
	hp = mini(stats.max_hp, hp + roundi(stats.max_hp * RunRules.REST_PERCENT / 100.0))
	mp = mini(stats.max_mp, mp + roundi(stats.max_mp * RunRules.REST_PERCENT / 100.0))
	_emit(RunEvent.Type.CAMPFIRE, "rest", embers)
	return true


func use_campfire_skill(skill_id: String) -> bool:
	if phase != Phase.CAMPFIRE or embers < RunRules.CAMPFIRE_SKILL_COST or not campfire_skills().has(skill_id):
		return false
	var old_max: int = player_stats().max_hp
	embers -= RunRules.CAMPFIRE_SKILL_COST
	buffs[skill_id] = int(data.campfire_skills[skill_id]["combats"])
	_adjust_hp(old_max)
	_emit(RunEvent.Type.CAMPFIRE, skill_id, embers)
	return true


func leave_campfire() -> bool:
	if phase != Phase.CAMPFIRE:
		return false
	phase = Phase.CHOOSING
	nodes_cleared += 1
	_emit(RunEvent.Type.CAMPFIRE, "leave", embers)
	return true


# --- Loja (GDD §15) --------------------------------------------------------------------

func can_buy(item_id: String) -> bool:
	if phase != Phase.SHOP or not shop_offer.has(item_id) or gold < item_price(item_id):
		return false
	if str(data.items[item_id]["slot"]) == "consumable" and total_consumables() >= RunRules.MAX_CONSUMABLES:
		return false
	return true


func buy(item_id: String) -> bool:
	if not can_buy(item_id):
		return false
	var price: int = item_price(item_id)
	gold -= price
	shop_offer.erase(item_id)
	_emit(RunEvent.Type.SPENT, item_id, price)
	var slot: String = str(data.items[item_id]["slot"])
	if slot == "consumable":
		consumables[item_id] = consumable_count(item_id) + 1
		_emit(RunEvent.Type.ITEM_GAINED, item_id, 1)
	else:
		var old_max: int = player_stats().max_hp
		equipment[slot] = item_id
		_adjust_hp(old_max)
		_emit(RunEvent.Type.EQUIPPED, item_id)
	return true


func reroll_cost() -> int:
	return RunRules.reroll_cost(shop_rerolls)


func reroll_shop() -> bool:
	if phase != Phase.SHOP or gold < reroll_cost():
		return false
	var cost: int = reroll_cost()
	gold -= cost
	shop_rerolls += 1
	_emit(RunEvent.Type.SPENT, "reroll", cost)
	_stock_shop()
	_emit(RunEvent.Type.SHOP, "reroll", shop_offer.size())
	return true


## Equipa o drop pendente; o item que estava no espaço é vendido a 40% (ADR-0022).
func take_drop() -> bool:
	if phase != Phase.SHOP or pending_drop.is_empty():
		return false
	var slot: String = str(data.items[pending_drop]["slot"])
	var old_id: String = str(equipment.get(slot, ""))
	if not old_id.is_empty():
		var value: int = RunRules.sell_value(item_price(old_id))
		gold += value
		_emit(RunEvent.Type.SOLD, old_id, value)
	var old_max: int = player_stats().max_hp
	equipment[slot] = pending_drop
	_adjust_hp(old_max)
	_emit(RunEvent.Type.EQUIPPED, pending_drop)
	pending_drop = ""
	return true


func sell_drop() -> bool:
	if phase != Phase.SHOP or pending_drop.is_empty():
		return false
	var value: int = RunRules.sell_value(item_price(pending_drop))
	gold += value
	_emit(RunEvent.Type.SOLD, pending_drop, value)
	pending_drop = ""
	return true


func leave_shop() -> bool:
	if phase != Phase.SHOP:
		return false
	sell_drop()
	phase = Phase.CHOOSING
	shop_offer.clear()
	_emit(RunEvent.Type.SHOP, "leave", 0)
	return true


## Drops da vitória (GDD §10, ADR-0022), no fluxo de loot: equipamento com a chance do tipo
## de inimigo e, à parte, um consumível de cura. O chefe não solta.
func _roll_drops(enemy_type: String) -> void:
	pending_drop = ""
	last_reward["drop"] = ""
	last_reward["consumable"] = ""
	if enemy_type == "boss":
		return
	var loot: Pcg32 = streams.loot()
	if RunRules.equipment_drops(enemy_type, loot):
		var rarity: String = RunRules.drop_rarity(enemy_type, loot)
		var pool: Array[String] = _drop_pool(rarity, false)
		if pool.is_empty():
			pool = _drop_pool("common", false)
		pending_drop = pool[loot.draw_index(pool.size())]
		_emit(RunEvent.Type.DROP, pending_drop)
	if RunRules.consumable_drops(enemy_type, loot) and total_consumables() < RunRules.MAX_CONSUMABLES:
		var potions: Array[String] = _drop_pool("", true)
		var found: String = potions[loot.draw_index(potions.size())]
		consumables[found] = consumable_count(found) + 1
		_emit(RunEvent.Type.ITEM_GAINED, found, 1)
		last_reward["consumable"] = found
	last_reward["drop"] = pending_drop


## Ids com preço, em ordem, de uma raridade de equipamento (ou os consumíveis de cura).
func _drop_pool(rarity: String, consumable: bool) -> Array[String]:
	var pool: Array[String] = []
	var ids: Array = data.items.keys()
	ids.sort()
	for item_id: Variant in ids:
		var item: Dictionary = data.items[item_id]
		if int(item["price"]) <= 0:
			continue
		var is_consumable: bool = str(item["slot"]) == "consumable"
		if consumable:
			if is_consumable and int(item.get("heal_hp_percent", 0)) > 0:
				pool.append(str(item_id))
		elif not is_consumable and str(item["rarity"]) == rarity:
			pool.append(str(item_id))
	return pool


func _open_shop() -> void:
	phase = Phase.SHOP
	shop_rerolls = 0
	_stock_shop()
	_emit(RunEvent.Type.SHOP, "open", shop_offer.size())


## Sorteia no fluxo de loot 2 equipamentos e 2 consumíveis entre os itens com preço.
func _stock_shop() -> void:
	var equipment_pool: Array[String] = []
	var consumable_pool: Array[String] = []
	var ids: Array = data.items.keys()
	ids.sort()
	for item_id: Variant in ids:
		var item: Dictionary = data.items[item_id]
		if int(item["price"]) <= 0 or str(item["rarity"]) == "rare":
			continue
		if str(item["slot"]) == "consumable":
			consumable_pool.append(str(item_id))
		else:
			equipment_pool.append(str(item_id))
	shop_offer.clear()
	_pick_into(equipment_pool, RunRules.SHOP_EQUIPMENT)
	_pick_into(consumable_pool, RunRules.SHOP_CONSUMABLES)


func _pick_into(pool: Array[String], count: int) -> void:
	var shuffled: Array = streams.loot().shuffled_copy(pool)
	for index: int in mini(count, shuffled.size()):
		shop_offer.append(str(shuffled[index]))


# --- Internos --------------------------------------------------------------------------

func _enter_scenario(index: int) -> void:
	scenario_index = index
	var entry: Dictionary = scenario()
	var config: MapConfig = MapConfig.for_layers(int(entry["layers"]))
	config.weight_event = RunRules.PROTOTYPE_EVENT_WEIGHT
	phase = Phase.CHOOSING
	map_check = Winnability.new()
	for attempt: int in Winnability.MAX_MAPS:
		map = MapGenerator.generate(config, streams.map())
		_assign_enemies(entry)
		current_node_id = map.start_id
		if winnability_runs <= 0:
			break
		# GDD §5: o mapa precisa de um caminho vencível; se não der, descarta e gera outro.
		if map_check.check(self, config, winnability_runs, float(entry["winnable_target"]), attempt):
			break
		if attempt < Winnability.MAX_MAPS - 1:
			map_check.maps_discarded += 1
	_emit(RunEvent.Type.SCENARIO, scenario_ids[index], index)


## Inimigo e nível de cada nó de luta, sorteados no fluxo do mapa logo depois da geração
## (ADR-0011): o jogador vê inimigo e nível antes de escolher (GDD §5).
func _assign_enemies(entry: Dictionary) -> void:
	var low: int = int(entry["min_level"])
	var high: int = int(entry["max_level"])
	for node: MapNode in map.nodes:
		if not node.is_fight():
			continue
		node.level = RunRules.layer_level(node.layer, map.layer_count, low, high)
		match node.kind:
			MapNode.Kind.BOSS:
				node.enemy_id = str(entry["boss"])
			MapNode.Kind.ELITE:
				node.level = mini(node.level + RunRules.ELITE_LEVEL_BONUS, high)
				node.enemy_id = _draw_from(entry["elite_enemies"])
			_:
				node.enemy_id = _draw_from(entry["common_enemies"])


func _draw_from(pool: Array) -> String:
	return str(pool[streams.map().draw_index(pool.size())])


func _gain_power(amount: float) -> void:
	var old_max: int = player_stats().max_hp
	power += amount
	_adjust_hp(old_max)
	_emit(RunEvent.Type.POWER, "", player_stats().max_hp, amount)


func _gain_gold(amount: int, source: String) -> void:
	gold += amount
	_emit(RunEvent.Type.GOLD, source, amount)


## Mudou o HP máximo: o atual ganha (ou perde) a mesma diferença, sem cair abaixo de 1
## nem passar do máximo (ADR-0011).
func _adjust_hp(old_max: int) -> void:
	var stats: Stats = player_stats()
	hp = clampi(hp + stats.max_hp - old_max, 1, stats.max_hp)
	mp = mini(mp, stats.max_mp)


func _end(victory: bool) -> void:
	phase = Phase.VICTORY if victory else Phase.DEFEAT
	_emit(RunEvent.Type.ENDED, "", 1 if victory else 0)


func _emit(type: RunEvent.Type, label: String = "", value: int = 0, amount: float = 0.0) -> void:
	history.append(RunEvent.make(type, label, value, amount))


## Nome do campo em [Stats] para a chave de atributo dos dados.
static func _stat_field(key: String) -> String:
	match key:
		"hp":
			return "max_hp"
		"mp":
			return "max_mp"
	return key
