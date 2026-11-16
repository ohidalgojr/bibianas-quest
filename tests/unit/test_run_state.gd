extends GutTest
## Transições do estado da Descida (GDD §4, §9, §12 e §15; ADR-0011). Os testes forçam o
## tipo de uma das opções para chegar direto ao caso.

var _data: GameData


func before_all() -> void:
	_data = DataLoader.load_all()


func _run(run_seed: int = 1) -> RunState:
	return RunState.new(_data, run_seed)


func _force_option(run: RunState, kind: MapNode.Kind, enemy_id: String = "giant_rat", level: int = 1) -> MapNode:
	var node: MapNode = run.options()[0]
	node.kind = kind
	node.enemy_id = enemy_id if node.is_fight() else ""
	node.level = level
	return node


## Ganha a luta em andamento: o inimigo fica com 1 de vida.
func _win(run: RunState) -> void:
	run.combat.enemy.hp = 1
	var guard: int = 0
	while run.combat.outcome == Combat.Outcome.ONGOING and guard < 100:
		guard += 1
		run.combat.act(Combat.Action.ATTACK)


func test_run_starts_on_the_map() -> void:
	var run: RunState = _run()
	assert_eq(run.phase, RunState.Phase.CHOOSING)
	assert_almost_eq(run.power, 1.0, 0.0001)
	assert_eq(run.gold, 0)
	assert_eq(run.hp, 130, "Guerreiro com HP cheio (GDD §8)")
	assert_eq(run.mp, 20)
	assert_eq(run.consumable_count("murky_potion"), 2)
	assert_eq(run.options().size(), 3, "três destinos (GDD §5)")
	assert_eq(run.map.layer_count, 5, "cenário 1 com 5 camadas (GDD §17)")
	assert_eq(run.map.boss_node().enemy_id, "gravedigger")
	assert_eq(run.map.boss_node().level, 6)
	for node: MapNode in run.map.nodes:
		if node.is_fight():
			assert_ne(node.enemy_id, "", "nó %d com inimigo" % node.id)
			assert_between(node.level, 1, 6)
		assert_ne(node.kind, MapNode.Kind.EVENT, "eventos fora do protótipo (ADR-0011)")


func test_invalid_actions_are_rejected_without_change() -> void:
	var run: RunState = _run()
	var events: int = run.history.size()
	assert_false(run.finish_fight())
	assert_false(run.choose_node(run.map.boss_id), "o chefe não está entre as opções")
	assert_false(run.rest())
	assert_false(run.use_campfire_skill("sharpen_blade"))
	assert_false(run.buy("murky_potion"))
	assert_false(run.reroll_shop())
	assert_false(run.leave_shop())
	assert_false(run.leave_campfire())
	assert_eq(run.phase, RunState.Phase.CHOOSING)
	assert_eq(run.current_node_id, run.map.start_id)
	assert_eq(run.history.size(), events)


## GDD §9 e §15: vitória dá Poder e ouro e abre a loja.
func test_victory_gives_power_gold_and_opens_shop() -> void:
	var run: RunState = _run()
	var node: MapNode = _force_option(run, MapNode.Kind.BATTLE, "giant_rat", 3)
	assert_true(run.choose_node(node.id))
	assert_eq(run.phase, RunState.Phase.FIGHT)
	assert_false(run.choose_node(node.id), "em luta não se escolhe nó")
	assert_false(run.finish_fight(), "a luta ainda não acabou")
	_win(run)
	var hp_after_fight: int = run.combat.player.hp
	var old_max: int = run.player_stats().max_hp
	assert_true(run.finish_fight())
	assert_almost_eq(run.power, 1.0 + 0.15 * 3, 0.0001)
	assert_between(run.gold, 14, 22, "6 × 3 × U(0,8; 1,2)")
	var new_max: int = run.player_stats().max_hp
	assert_eq(run.hp, hp_after_fight + new_max - old_max, "o crescimento não cura nem fere (ADR-0011)")
	assert_eq(run.phase, RunState.Phase.SHOP)
	assert_eq(run.shop_offer.size(), 4, "2 equipamentos e 2 consumíveis")
	assert_true(run.leave_shop())
	assert_eq(run.phase, RunState.Phase.CHOOSING)
	assert_eq(run.options()[0].layer, 2, "segue para a próxima camada")


func test_hp_and_mp_persist_between_fights() -> void:
	var run: RunState = _run()
	_force_option(run, MapNode.Kind.BATTLE)
	run.choose_node(run.options()[0].id)
	run.combat.player.hp = 70
	run.combat.player.mp = 4
	_win(run)
	var hp_end: int = run.combat.player.hp
	run.finish_fight()
	run.leave_shop()
	assert_between(run.hp, hp_end, hp_end + 2, "a mesma vida da luta anterior, mais o crescimento do Poder")
	var carried_hp: int = run.hp
	var carried_mp: int = run.mp
	var next: MapNode = _force_option(run, MapNode.Kind.BATTLE)
	run.choose_node(next.id)
	# O inimigo pode agir antes do primeiro turno da Bibiana: desconta pelos eventos.
	var expected: int = carried_hp
	for event: CombatEvent in run.combat.history:
		if event.type == CombatEvent.Type.DAMAGE and event.side == Combatant.PLAYER:
			expected -= event.value
	assert_eq(run.combat.player.hp, expected, "a luta começa com a vida que sobrou")
	assert_lt(carried_hp, run.combat.player.stats.max_hp)
	assert_eq(run.combat.player.mp, carried_mp)


## GDD §9: fugir não dá Poder.
func test_flee_gives_nothing() -> void:
	var run: RunState = _run(3)
	_force_option(run, MapNode.Kind.BATTLE)
	run.choose_node(run.options()[0].id)
	var guard: int = 0
	while run.combat.outcome == Combat.Outcome.ONGOING and guard < 60:
		guard += 1
		run.combat.player.hp = run.combat.player.stats.max_hp
		run.combat.act(Combat.Action.FLEE)
	assert_eq(run.combat.outcome, Combat.Outcome.FLED)
	run.finish_fight()
	assert_almost_eq(run.power, 1.0, 0.0001)
	assert_eq(run.gold, 0)
	assert_eq(run.phase, RunState.Phase.CHOOSING, "sem loja depois da fuga")


## GDD §4: morrer encerra a Descida.
func test_defeat_ends_the_run() -> void:
	var run: RunState = _run()
	_force_option(run, MapNode.Kind.BATTLE, "infected_citizen", 1)
	run.choose_node(run.options()[0].id)
	run.combat.enemy.hp = 99999
	var guard: int = 0
	while run.combat.outcome == Combat.Outcome.ONGOING and guard < 500:
		guard += 1
		run.combat.act(Combat.Action.ATTACK)
	assert_eq(run.combat.outcome, Combat.Outcome.DEFEAT)
	assert_true(run.finish_fight())
	assert_eq(run.phase, RunState.Phase.DEFEAT)
	assert_true(run.is_over())
	assert_eq(run.options().size(), 0)
	assert_eq(run.history.back().type, RunEvent.Type.ENDED)


func test_items_used_in_fight_leave_inventory() -> void:
	var run: RunState = _run()
	_force_option(run, MapNode.Kind.BATTLE)
	run.choose_node(run.options()[0].id)
	run.combat.player.hp = 40
	run.combat.act(Combat.Action.ITEM, null, _data.combat_item("murky_potion"))
	assert_eq(run.available_in_fight("murky_potion"), 1)
	assert_eq(run.consumable_count("murky_potion"), 2, "só sai ao fechar a luta")
	_win(run)
	run.finish_fight()
	assert_eq(run.consumable_count("murky_potion"), 1)


func test_chest_gives_gold() -> void:
	var run: RunState = _run()
	var node: MapNode = _force_option(run, MapNode.Kind.CHEST)
	assert_true(run.choose_node(node.id))
	assert_between(run.gold, 5, 21, "1 a 3 vezes o ouro de uma batalha de nível 1")
	assert_eq(run.phase, RunState.Phase.CHOOSING)
	assert_eq(run.current_node_id, node.id)


## GDD §12: 6 Brasas; Descansar custa 3 e recupera 40%; skill custa 2 (ADR-0011).
func test_campfire() -> void:
	var run: RunState = _run()
	var node: MapNode = _force_option(run, MapNode.Kind.BONFIRE)
	assert_true(run.choose_node(node.id))
	assert_eq(run.phase, RunState.Phase.CAMPFIRE)
	assert_eq(run.embers, 6)
	run.hp = 50
	run.mp = 0
	assert_true(run.rest())
	assert_eq(run.hp, 50 + 52, "40% de 130")
	assert_eq(run.mp, 8, "40% de 20")
	assert_eq(run.embers, 3)
	assert_false(run.use_campfire_skill("fireball"), "skill de outra classe ou inexistente")
	assert_true(run.use_campfire_skill("sharpen_blade"))
	assert_eq(run.embers, 1)
	assert_eq(int(run.buffs["sharpen_blade"]), 3, "dura 3 combates (GDD §8)")
	assert_false(run.use_campfire_skill("reinforce_shield"), "falta Brasa")
	assert_false(run.rest(), "falta Brasa")
	assert_true(run.leave_campfire())
	assert_eq(run.phase, RunState.Phase.CHOOSING)


## GDD §8: +15% de dano e +15% de DEF por 3 combates; contam ao começar a luta.
func test_campfire_buffs_change_fight_stats() -> void:
	var run: RunState = _run()
	run.buffs["sharpen_blade"] = 3
	run.buffs["reinforce_shield"] = 1
	assert_eq(run.player_stats().strength, roundi(14 * 1.15))
	assert_eq(run.player_stats().defense, roundi(12 * 1.15))
	_force_option(run, MapNode.Kind.BATTLE)
	run.choose_node(run.options()[0].id)
	assert_eq(run.combat.player.stats.strength, 16)
	assert_eq(run.combat.player.stats.defense, 14)
	assert_eq(int(run.buffs["sharpen_blade"]), 2)
	assert_false(run.buffs.has("reinforce_shield"), "a última luta do buff já começou")


## GDD §15: loja, compra e atualização; equipamento muda os atributos (ADR-0011).
func test_shop_buy_equip_and_reroll() -> void:
	var run: RunState = _run()
	run.gold = 500
	run._open_shop()
	assert_true(run.shop_offer.has("worn_longsword"))
	assert_true(run.shop_offer.has("dented_plate"))
	assert_true(run.buy("worn_longsword"))
	assert_eq(run.gold, 410)
	assert_eq(run.equipment["weapon"], "worn_longsword")
	assert_eq(run.player_stats().strength, 14 + 3)
	assert_false(run.buy("worn_longsword"), "já saiu da loja")
	assert_true(run.buy("dented_plate"))
	assert_eq(run.player_stats().defense, 12 + 5)
	assert_eq(run.player_stats().speed, 7 - 2, "placa: VEL -2 (GDD §10)")
	assert_true(run.reroll_shop())
	assert_eq(run.gold, 290 - 15)
	assert_eq(run.shop_offer.size(), 4)
	assert_true(run.reroll_shop())
	assert_eq(run.gold, 275 - 25)
	run.gold = 10
	assert_false(run.reroll_shop(), "sem ouro")
	assert_false(run.buy("murky_potion"), "sem ouro")


## GDD §10: até 8 consumíveis.
func test_consumable_limit() -> void:
	var run: RunState = _run()
	run.gold = 500
	run._open_shop()
	run.consumables["murky_potion"] = 8
	assert_false(run.can_buy("murky_potion"))
	run.consumables["murky_potion"] = 7
	assert_true(run.buy("murky_potion"))
	assert_eq(run.total_consumables(), 8)


## Com um cenário só, vencer o chefe é vencer a Descida (ADR-0011).
func test_beating_the_boss_wins_the_run() -> void:
	var run: RunState = _run()
	run.current_node_id = run.map.node_at(run.map.layer_count, 0).id
	assert_eq(run.options().size(), 1)
	assert_true(run.choose_node(run.map.boss_id))
	assert_eq(run.combat.enemy.display_name, "O Coveiro")
	assert_false(run.combat.enemy.can_flee)
	_win(run)
	run.finish_fight()
	assert_eq(run.phase, RunState.Phase.VICTORY)
	assert_almost_eq(run.power, 1.0 + 0.15 * 6 * 4, 0.0001, "Poder ×4 do chefe (GDD §9)")


func test_two_scenarios_move_to_the_next_map() -> void:
	var scenarios: Array[String] = ["abandoned_city", "abandoned_city"]
	var run: RunState = RunState.new(_data, 1, "warrior", scenarios)
	var first_map: MapGraph = run.map
	run.current_node_id = run.map.node_at(run.map.layer_count, 0).id
	run.choose_node(run.map.boss_id)
	_win(run)
	run.finish_fight()
	assert_eq(run.phase, RunState.Phase.CHOOSING)
	assert_eq(run.scenario_index, 1)
	assert_ne(run.map, first_map)
	assert_eq(run.current_node_id, run.map.start_id)
