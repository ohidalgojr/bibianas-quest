extends GutTest
## TASK-010 (ADR-0015): o controlador das telas de recompensa, loja e fogueira lê o
## RunState, descreve itens e repassa as ações sem calcular regra.

var _data: GameData


func before_all() -> void:
	_data = DataLoader.load_all()


## Descida com uma luta fácil já vencida: termina na fase da loja.
func _run_in_shop() -> RunState:
	var run: RunState = RunState.new(_data, 21)
	var option: MapNode = run.options()[0]
	option.kind = MapNode.Kind.BATTLE
	option.enemy_id = "giant_rat"
	option.level = 1
	run.choose_node(option.id)
	var guard: int = 0
	while run.combat.outcome == Combat.Outcome.ONGOING and guard < 300:
		guard += 1
		run.combat.act(Combat.Action.ATTACK)
	assert_eq(run.combat.outcome, Combat.Outcome.VICTORY)
	run.finish_fight()
	return run


func test_reward_shows_who_fell_power_and_attribute_changes() -> void:
	var run: RunState = _run_in_shop()
	var view: Dictionary = RunPanels.new(run).reward_view()
	assert_almost_eq(float(view["power"]), RunRules.power_gain(1, "common"), 0.0001)
	assert_gt(int(view["gold"]), 0)
	assert_eq(run.enemies_defeated, 1)
	var text: String = "
".join(view["lines"])
	assert_string_contains(text, "Rato Grande (nível 1) foi derrotado. Inimigos derrotados: 1.")
	assert_string_contains(text, "Poder 1.00 → ")
	assert_string_contains(text, "HP 130 → ")
	assert_string_contains(text, "Ouro +%d" % int(view["gold"]))


func test_stat_changes_lists_only_what_changed() -> void:
	var before: Stats = Stats.make({"hp": 100, "strength": 10, "defense": 5})
	var after: Stats = Stats.make({"hp": 105, "strength": 10, "defense": 6})
	var lines: Array[String] = RunPanels.stat_changes(before, after)
	assert_eq(lines, ["HP 100 → 105", "DEF 5 → 6"] as Array[String])


func test_shop_lists_offer_with_prices_and_reasons() -> void:
	var run: RunState = _run_in_shop()
	var panels: RunPanels = RunPanels.new(run)
	run.gold = 0
	var view: Dictionary = panels.shop_view()
	assert_eq((view["offer"] as Array).size(), RunRules.SHOP_EQUIPMENT + RunRules.SHOP_CONSUMABLES)
	for entry: Dictionary in view["offer"]:
		assert_eq(int(entry["price"]), run.item_price(str(entry["id"])))
		assert_false(bool(entry["can_buy"]))
		assert_eq(entry["reason"], "Ouro insuficiente")
	assert_false(bool(view["can_reroll"]))


func test_buy_and_reroll_go_through_the_run() -> void:
	var run: RunState = _run_in_shop()
	var panels: RunPanels = RunPanels.new(run)
	run.gold = 1000
	var first: String = run.shop_offer[0]
	var gold_before: int = run.gold
	assert_true(panels.buy(first))
	assert_eq(run.gold, gold_before - run.item_price(first))
	assert_false(panels.shop_view()["offer"].any(func(e: Dictionary) -> bool: return e["id"] == first))
	assert_true(panels.reroll())
	assert_eq(run.shop_rerolls, 1)


func test_item_descriptions() -> void:
	var panels: RunPanels = RunPanels.new(_run_in_shop())
	assert_eq(panels.item_description("murky_potion"), "Recupera 30% do HP")
	assert_eq(panels.item_description("dirty_ether"), "Recupera 50% do MP")
	assert_string_contains(panels.item_description("worn_longsword"), "FOR +3")
	assert_string_contains(panels.item_description("worn_longsword"), "equipado: Espada e Escudo")
	assert_string_contains(panels.item_description("dented_plate"), "DEF +5, VEL -2")


func test_campfire_view_and_actions() -> void:
	var run: RunState = RunState.new(_data, 4)
	run.phase = RunState.Phase.CAMPFIRE
	run.embers = RunRules.EMBERS
	run.hp = 10
	var panels: RunPanels = RunPanels.new(run)
	var view: Dictionary = panels.campfire_view()
	assert_true(bool(view["can_rest"]))
	assert_eq((view["skills"] as Array).size(), 2)
	assert_eq(view["skills"][0]["description"], "FOR e MEN +15% por 3 lutas")
	assert_true(panels.rest())
	assert_gt(run.hp, 10)
	assert_true(panels.use_skill("sharpen_blade"))
	assert_eq(int(panels.campfire_view()["skills"][0]["left"]), 3)
	assert_eq(run.embers, RunRules.EMBERS - RunRules.REST_COST - RunRules.CAMPFIRE_SKILL_COST)
	assert_false(bool(panels.campfire_view()["can_rest"]), "sobraram menos Brasas que o custo")
