extends GutTest
## TASK-018 (ADR-0022): drops de equipamento e consumível (GDD §10), Equipar ou Vender
## (venda a 40%, GDD §15), raridade por pesos e loja sem itens raros.

var _data: GameData


func before_all() -> void:
	_data = DataLoader.load_all()


## Descida em fase de loja, com o drop pendente dado (sem passar pelo sorteio).
func _shop_with_drop(item_id: String) -> RunState:
	var run: RunState = RunState.new(_data, 3)
	run._open_shop()
	run.pending_drop = item_id
	return run


## GDD §10: 12% para comum e 35% para elite; chefe nunca.
func test_equipment_drop_chances_follow_gdd_section_10() -> void:
	var loot: Pcg32 = RngStreams.new(7).loot()
	var common: int = 0
	var elite: int = 0
	var boss: int = 0
	for draw: int in 4000:
		common += 1 if RunRules.equipment_drops("common", loot) else 0
		elite += 1 if RunRules.equipment_drops("elite", loot) else 0
		boss += 1 if RunRules.equipment_drops("boss", loot) else 0
	assert_between(common, 4000 * 10 / 100, 4000 * 14 / 100, "perto de 12%")
	assert_between(elite, 4000 * 32 / 100, 4000 * 38 / 100, "perto de 35%")
	assert_eq(boss, 0)


func test_rare_only_from_elites() -> void:
	var loot: Pcg32 = RngStreams.new(9).loot()
	var common_rare: int = 0
	var elite_rare: int = 0
	for draw: int in 2000:
		common_rare += 1 if RunRules.drop_rarity("common", loot) == "rare" else 0
		elite_rare += 1 if RunRules.drop_rarity("elite", loot) == "rare" else 0
	assert_eq(common_rare, 0, "comum não solta raro")
	assert_between(elite_rare, 2000 * 20 / 100, 2000 * 30 / 100, "elite perto de 25% de raros")


func test_equip_drop_replaces_item_and_sells_the_old_at_forty_percent() -> void:
	var run: RunState = _shop_with_drop("rusty_axe")
	run.equipment["weapon"] = "worn_longsword"
	var strength: int = run.player_stats().strength
	var gold: int = run.gold
	assert_true(run.take_drop())
	assert_eq(run.equipment["weapon"], "rusty_axe")
	assert_eq(run.player_stats().strength, strength + 1, "4 de FOR no lugar de 3")
	assert_eq(run.gold, gold + RunRules.sell_value(90), "vendeu a espada longa por 40% de 90")
	assert_eq(run.pending_drop, "")
	assert_false(run.take_drop(), "sem drop pendente")


func test_sell_drop_pays_forty_percent() -> void:
	var run: RunState = _shop_with_drop("spiked_mace")
	assert_true(run.sell_drop())
	assert_eq(run.gold, RunRules.sell_value(320))
	assert_eq(run.gold, 128)
	assert_eq(run.equipment["weapon"], "sword_and_shield", "o equipado não mudou")


func test_leaving_shop_sells_the_pending_drop() -> void:
	var run: RunState = _shop_with_drop("grave_bell")
	assert_true(run.leave_shop())
	assert_eq(run.gold, RunRules.sell_value(350))
	assert_eq(run.pending_drop, "")


func test_drop_actions_need_the_shop_phase() -> void:
	var run: RunState = RunState.new(_data, 3)
	run.pending_drop = "rusty_axe"
	assert_false(run.take_drop())
	assert_false(run.sell_drop())
	assert_eq(run.gold, 0)


func test_stats_with_previews_without_changing_anything() -> void:
	var run: RunState = _shop_with_drop("warden_plate")
	var before: int = run.player_stats().defense
	assert_eq(run.stats_with("warden_plate").defense, before + 10)
	assert_eq(run.player_stats().defense, before)
	assert_eq(run.equipment["armor"], "old_chainmail")


func test_shop_never_stocks_rare_items() -> void:
	for run_seed: int in 60:
		var run: RunState = RunState.new(_data, run_seed)
		run._open_shop()
		for item_id: String in run.shop_offer:
			assert_ne(str(_data.items[item_id]["rarity"]), "rare", "semente %d" % run_seed)


## Mesma semente, mesmos drops: o sorteio usa o fluxo de loot.
func test_drops_are_deterministic_by_seed() -> void:
	var first: Array[String] = _drops_of_seed(21)
	assert_eq(_drops_of_seed(21), first)
	assert_eq(first.size(), 8)


func _drops_of_seed(run_seed: int) -> Array[String]:
	var run: RunState = RunState.new(_data, run_seed)
	var seen: Array[String] = []
	for fight: int in 8:
		run.phase = RunState.Phase.CHOOSING
		run.current_node_id = run.map.start_id
		var option: MapNode = run.options()[0]
		option.kind = MapNode.Kind.ELITE
		option.enemy_id = "rotten_executioner"
		option.level = 1
		run.choose_node(option.id)
		run.combat.enemy.hp = 1
		var guard: int = 0
		while run.combat.outcome == Combat.Outcome.ONGOING and guard < 100:
			guard += 1
			run.combat.act(Combat.Action.ATTACK)
		run.finish_fight()
		seen.append(run.pending_drop + "|" + str(run.last_reward["consumable"]))
		run.leave_shop()
	return seen


func test_elites_drop_often_and_items_exist_in_data() -> void:
	var drops: int = 0
	var run: RunState = RunState.new(_data, 5)
	for entry: String in _drops_of_seed(5):
		if not entry.begins_with("|"):
			drops += 1
			assert_true(_data.items.has(entry.split("|")[0]))
	assert_gt(drops, 0, "em 8 elites, ao menos um equipamento")
	assert_not_null(run)


func test_drop_view_compares_stats_and_names_the_replaced_item() -> void:
	var run: RunState = _shop_with_drop("reinforced_mail")
	var view: Dictionary = RunPanels.new(run).drop_view()
	assert_eq(view["name"], "Cota Reforçada")
	assert_eq(view["rarity"], "Incomum")
	assert_eq(view["replaces"], "Cota de Malha Velha")
	assert_eq(view["sell_value"], RunRules.sell_value(190))
	assert_true((view["changes"] as Array).has("DEF 12 → 19"))
	run.pending_drop = ""
	assert_true(RunPanels.new(run).drop_view().is_empty())
