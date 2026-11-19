extends GutTest
## TASK-028 (ADR-0033): eventos de mapa (6 eventos da Cidade Abandonada, escolhas com
## custo/moeda e manipulação de CRIT do pedido D6) e mini boss anunciado (Carcereiro do
## Sino, 0 ou 1 na segunda metade, recompensa rara garantida + Galhos Secos + Moeda da Sorte).

var _data: GameData


func before_all() -> void:
	_data = DataLoader.load_all()


func _win(run: RunState) -> void:
	run.combat.enemy.hp = 1
	var guard: int = 0
	while run.combat.outcome == Combat.Outcome.ONGOING and guard < 100:
		guard += 1
		run.combat.act(Combat.Action.ATTACK)


func test_six_abandoned_city_events_and_crit_modifier_exist() -> void:
	var event_ids: Array[String] = _data.scenario_events("abandoned_city")
	assert_eq(event_ids.size(), 6, "6 eventos temáticos na Cidade Abandonada")
	var has_crit_bonus: bool = false
	var has_crit_penalty: bool = false
	var has_coin_choice: bool = false
	for event_id: String in event_ids:
		var ev: Dictionary = _data.events[event_id]
		var choices: Array = ev["choices"]
		assert_between(choices.size(), 2, 3, "2 a 3 escolhas em %s" % event_id)
		for choice: Dictionary in choices:
			if bool(choice.get("coin", false)):
				has_coin_choice = true
				for branch: String in ["heads", "tails"]:
					var c_bonus: int = int(choice[branch].get("crit_bonus", 0))
					if c_bonus > 0:
						has_crit_bonus = true
					elif c_bonus < 0:
						has_crit_penalty = true
			else:
				var c_bonus: int = int(choice["outcome"].get("crit_bonus", 0))
				if c_bonus > 0:
					has_crit_bonus = true
				elif c_bonus < 0:
					has_crit_penalty = true
	assert_true(has_coin_choice, "eventos têm escolhas com lance de moeda")
	assert_true(has_crit_bonus and has_crit_penalty, "eventos aumentam ou reduzem CRIT por alguns combates (D6)")


func test_event_node_hides_outcome_on_map_and_resolves_crit_and_coin() -> void:
	var run: RunState = RunState.new(_data, 12, "warrior", [], 0)
	var opt: MapNode = run.options()[0]
	opt.kind = MapNode.Kind.EVENT
	opt.enemy_id = ""
	var map_view: MapView = MapView.new(run)
	var nv: Dictionary = map_view.node_view(opt)
	assert_eq(nv["title"], "Evento")
	assert_eq(nv["detail"], "", "evento mostra só o tipo no mapa; resultado só ao escolher")

	assert_true(run.choose_node(opt.id))
	assert_eq(run.phase, RunState.Phase.EVENT)
	run.current_event_id = "weeping_bell"
	run.gold = 50
	var crit_before: int = run.player_stats().crit

	# Escolha 0 de weeping_bell: moeda (heads = +12 CRIT por 3 lutas, tails = -5 CRIT por 2 lutas).
	assert_true(run.choose_event_option(0, CoinRules.HEADS, 1))
	assert_eq(run.phase, RunState.Phase.CHOOSING)
	assert_eq(run.event_crit_bonus, 12)
	assert_eq(run.event_crit_combats, 3)
	assert_eq(run.player_stats().crit, crit_before + 12)
	assert_string_contains(MapView.new(run).header(), "CRIT de evento: +12 (3 lutas)")

	# O bônus de CRIT decai a cada luta iniciada.
	var fight_opt: MapNode = run.options()[0]
	fight_opt.kind = MapNode.Kind.BATTLE
	fight_opt.enemy_id = "giant_rat"
	fight_opt.level = 1
	assert_true(run.choose_node(fight_opt.id))
	assert_eq(run.combat.player.stats.crit, crit_before + 12)
	assert_eq(run.event_crit_combats, 2, "consumiu 1 luta do efeito de CRIT")
	_win(run)
	run.finish_fight()
	run.leave_shop()

	# Telemetria registra o evento, a escolha e o lance de moeda.
	var lines: Array[Dictionary] = Telemetry.run_lines(run, 0)
	var types: PackedStringArray = PackedStringArray()
	for line: Dictionary in lines:
		types.append(str(line["type"]))
	assert_true(types.has("event"))
	assert_true(types.has("event_choice"))
	assert_true(types.has("event_coin"))


func test_mini_boss_placement_announcement_and_guaranteed_rewards() -> void:
	var found_mini_boss: int = 0
	for s: int in range(1, 31):
		var r: RunState = RunState.new(_data, s, "warrior", [], 0)
		var mb_count: int = 0
		for n: MapNode in r.map.nodes:
			if n.kind == MapNode.Kind.MINI_BOSS:
				mb_count += 1
				assert_gte(n.layer, 4, "mini boss na segunda metade do mapa")
				assert_eq(n.enemy_id, "bell_warden")
		assert_lte(mb_count, 1, "0 ou 1 mini boss por mapa")
		if mb_count == 1:
			found_mini_boss += 1
		assert_eq(MapRules.find_violations(r.map, MapConfig.new()).size(), 0, "mapa continua válido em MapRules")
	assert_gt(found_mini_boss, 0, "sorteia mini boss em parte das sementes")

	# Força um mini boss e confere anúncio no MapView, proibição de fuga e drops garantidos.
	var run: RunState = RunState.new(_data, 7, "warrior", [], 0)
	var target: MapNode = run.map.node_at(4, 0)
	target.kind = MapNode.Kind.MINI_BOSS
	target.enemy_id = "bell_warden"
	target.level = 5
	var view: MapView = MapView.new(run)
	assert_eq(view.mini_boss_node(), target)
	assert_string_contains(view.header(), "Sino rachado: Carcereiro do Sino (nv 5) na camada 4")

	# Coloca o mini boss como destino imediato e vence a luta.
	var opt: MapNode = run.options()[0]
	opt.kind = MapNode.Kind.MINI_BOSS
	opt.enemy_id = "bell_warden"
	opt.level = 5
	var firewood_before: int = run.consumable_count(RunRules.FIREWOOD_ID)
	var coin_before: int = run.consumable_count(RunRules.LUCKY_COIN_ID)
	assert_true(run.choose_node(opt.id))
	assert_false(run.combat.enemy.can_flee, "não se foge de mini boss (GDD §13)")
	_win(run)
	assert_true(run.finish_fight())
	assert_ne(run.pending_drop, "", "recompensa de equipamento garantida no mini boss")
	assert_eq(str(_data.items[run.pending_drop]["rarity"]), "rare", "equipamento raro garantido")
	assert_eq(run.consumable_count(RunRules.FIREWOOD_ID), firewood_before + 1, "Galhos Secos garantidos")
	assert_eq(run.consumable_count(RunRules.LUCKY_COIN_ID), coin_before + 1, "Moeda da Sorte garantida")
