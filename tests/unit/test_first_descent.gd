extends GutTest
## TASK-026 (ADR-0031): primeira Descida chamativa quando runs_played == 0, com
## elementos garantidos, O Coveiro visível de longe, Ecos em dobro e "morte que ensina".

var _data: GameData


func before_all() -> void:
	_data = DataLoader.load_all()


func test_first_run_guarantees_infected_citizen_early_chest_and_mid_elite() -> void:
	var config: MapConfig = MapConfig.for_layers(4)
	for seed_val: int in range(1, 31):
		var run: RunState = RunState.new(_data, seed_val, "warrior", [], 0, null, true)
		assert_true(run.first_run)
		assert_true(MapRules.find_violations(run.map, config).is_empty(), "semente %d sem violação" % seed_val)
		for option: MapNode in run.options():
			assert_eq(option.kind, MapNode.Kind.BATTLE)
			assert_eq(option.enemy_id, "infected_citizen")
			assert_eq(option.level, 1)
		var early_chest: bool = false
		for node: MapNode in run.map.layer_nodes(2):
			if node.kind == MapNode.Kind.CHEST and (node.column == 1 or node.column == 2):
				early_chest = true
		assert_true(early_chest, "semente %d tem baú garantido na camada 2" % seed_val)
		var mid_elite: bool = false
		for mid_layer: int in [3, 4]:
			for node: MapNode in run.map.layer_nodes(mid_layer):
				if node.kind == MapNode.Kind.ELITE:
					mid_elite = true
		assert_true(mid_elite, "semente %d tem elite garantido no meio do mapa" % seed_val)


func test_first_chest_grants_uncommon_item_and_lucky_coin() -> void:
	var run: RunState = RunState.new(_data, 12, "warrior", [], 0, null, true)
	var option: MapNode = run.options()[0]
	option.kind = MapNode.Kind.CHEST
	option.enemy_id = ""
	var coins_before: int = run.consumable_count(RunRules.LUCKY_COIN_ID)
	assert_true(run.choose_node(option.id))
	assert_true(run.first_chest_opened)
	var item_id: String = str(run.last_chest.get("item", ""))
	assert_ne(item_id, "")
	assert_eq(str(_data.items[item_id]["rarity"]), "uncommon")
	assert_eq(run.consumable_count(RunRules.LUCKY_COIN_ID), coins_before + 1)
	var view: Dictionary = RunPanels.new(run).chest_view()
	var text: String = "\n".join(view["lines"])
	assert_string_contains(text, str(_data.items[item_id]["name"]))
	assert_string_contains(text, "Moeda da Sorte")


func test_first_run_elite_guarantees_rare_drop_and_lucky_coin() -> void:
	var run: RunState = RunState.new(_data, 18, "warrior", [], 0, null, true)
	var option: MapNode = run.options()[0]
	option.kind = MapNode.Kind.ELITE
	option.enemy_id = "rotten_executioner"
	option.level = 1
	assert_true(run.choose_node(option.id))
	run.combat.debug_kill_enemy()
	assert_true(run.finish_fight())
	assert_ne(run.pending_drop, "")
	assert_eq(str(_data.items[run.pending_drop]["rarity"]), "rare")
	assert_gt(run.consumable_count(RunRules.LUCKY_COIN_ID), 0)
	assert_true(bool(run.last_reward.get("lucky_coin", false)))


func test_map_view_shows_boss_waiting_from_afar() -> void:
	var run: RunState = RunState.new(_data, 5, "warrior", [], 0, null, true)
	var view: MapView = MapView.new(run)
	var boss_node: MapNode = run.map.node_by_id(run.map.boss_id)
	var boss_view: Dictionary = view.node_view(boss_node)
	assert_eq(boss_view["state"], MapView.State.BOSS)
	assert_string_contains(str(boss_view["detail"]), "O Coveiro te espera")


func test_double_echoes_and_teaching_death_only_when_runs_played_is_zero() -> void:
	assert_eq(RunRules.echoes(5, 0, true), 10)
	assert_eq(RunRules.echoes(5, 0, false), 5)
	assert_eq(RunRules.echoes(0, 0, true), 2, "mesmo morte imediata na 1ª Descida rende Ecos em dobro")
	var game: GameScreen = GameScreen.new()
	game.map_check_runs = 0
	game.use_thread = false
	game.time_scale = 0.0
	game.save_enabled = false
	game.telemetry_enabled = false
	game.debug_enabled = false
	add_child_autofree(game)
	assert_eq(game.runs_played, 0)
	game.new_run(41)
	assert_true(game.run.first_run, "runs_played == 0 liga a primeira Descida")
	var first_opt: MapNode = game.run.options()[0]
	game.choose_node(first_opt.id)
	game.run.combat.player.hp = 1
	var guard: int = 0
	while game.run.combat != null and game.run.combat.outcome == Combat.Outcome.ONGOING and guard < 100:
		guard += 1
		game.run.combat.act(Combat.Action.ATTACK)
	game._on_fight_done()
	assert_eq(game.run.phase, RunState.Phase.DEFEAT)
	assert_gt(game.run.defeated_by_hp_percent, 0)
	var summary: Dictionary = game.run.end_summary(game.echoes)
	assert_string_contains(str(summary["killer_line"]), "ficou com")
	assert_string_contains(str(summary["tip_line"]), "Dica:")
	assert_string_contains(str(summary["accomplished_line"]), "Conquistado:")
	assert_string_contains(str(summary["next_line"]), "em dobro na 1ª Descida")
	assert_eq(game.runs_played, 1)
	game.new_run(42)
	assert_false(game.run.first_run, "segunda Descida em diante usa as regras normais")
