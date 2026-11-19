extends GutTest
## GDD §5, garantia de vencibilidade (ADR-0012): caminho mais seguro, simulação do bot,
## suavização e descarte do mapa. Com poucas simulações por mapa, para caber na suíte;
## a prova em milhares de sementes roda em tools/simulate.gd.

const CHECK_RUNS: int = 12

var _data: GameData


func before_all() -> void:
	_data = DataLoader.load_all()


func test_node_cost() -> void:
	var battle: MapNode = MapNode.new(1, 1, 0, MapNode.Kind.BATTLE)
	battle.level = 3
	var elite: MapNode = MapNode.new(2, 1, 1, MapNode.Kind.ELITE)
	elite.level = 3
	assert_almost_eq(Winnability.node_cost(battle), 3.0, 0.0001)
	assert_almost_eq(Winnability.node_cost(elite), 6.0, 0.0001, "elite pesa o dobro")
	assert_almost_eq(Winnability.node_cost(MapNode.new(3, 1, 2, MapNode.Kind.CHEST)), 0.0, 0.0001)
	assert_almost_eq(Winnability.node_cost(MapNode.new(4, 1, 3, MapNode.Kind.BONFIRE)), 0.0, 0.0001)


## GDD §5: suavizar baixa o nível do caminho e troca uma batalha por baú, sem quebrar
## as regras do mapa.
func test_smoothing_lowers_levels_and_keeps_map_rules() -> void:
	for run_seed: int in 10:
		var run: RunState = RunState.new(_data, run_seed)
		var config: MapConfig = MapConfig.for_layers(run.map.layer_count)
		config.weight_event = RunRules.PROTOTYPE_EVENT_WEIGHT
		var route: PackedInt32Array = Winnability.safest_route(run.map)
		var before: int = 0
		for node_id: int in route:
			before += run.map.node_by_id(node_id).level
		var boss_level: int = run.map.boss_node().level
		Winnability.smooth(run.map, config, route, 1)
		var after: int = 0
		for node_id: int in route:
			after += run.map.node_by_id(node_id).level
		assert_lte(after, before, "semente %d" % run_seed)
		assert_eq(run.map.boss_node().level, boss_level, "o chefe não é suavizado")
		assert_eq(MapRules.find_violations(run.map, config).size(), 0, "semente %d" % run_seed)


## Parar cedo dá a mesma decisão (passa ou não) que as simulações inteiras.
func test_early_stop_keeps_the_decision() -> void:
	for run_seed: int in 2:
		var run: RunState = RunState.new(_data, run_seed)
		var route: PackedInt32Array = Winnability.safest_route(run.map)
		var full: float = Winnability.route_win_rate(run, route, CHECK_RUNS, 0)
		for target: float in [40.0, 60.0, 80.0]:
			var early: float = Winnability.route_win_rate(run, route, CHECK_RUNS, 0, target)
			assert_eq(early >= target, full >= target, "semente %d, meta %.0f" % [run_seed, target])


## As simulações não gastam os fluxos da Descida: com ou sem checagem, a sequência de
## sorteios de combate e de moeda é a mesma.
func test_probes_do_not_touch_run_streams() -> void:
	var run: RunState = RunState.new(_data, 4)
	var combat_state: Dictionary = run.streams.combat().snapshot()
	var coin_state: Dictionary = run.streams.coin().snapshot()
	Winnability.route_win_rate(run, Winnability.safest_route(run.map), CHECK_RUNS, 0)
	assert_eq(run.streams.combat().snapshot(), combat_state)
	assert_eq(run.streams.coin().snapshot(), coin_state)
	assert_eq(run.phase, RunState.Phase.CHOOSING)
	assert_eq(run.current_node_id, run.map.start_id)


## GDD §5: nenhum mapa entregue sem caminho vencível, e o mapa é determinístico.
func test_property_maps_have_a_winnable_route() -> void:
	var failed: PackedStringArray = PackedStringArray()
	var smoothing: int = 0
	for run_seed: int in 3:
		var run: RunState = RunState.new(_data, 2000 + run_seed, "warrior", [], CHECK_RUNS)
		smoothing += run.map_check.smoothing_steps
		if not run.map_check.passed:
			failed.append(str(2000 + run_seed))
		var config: MapConfig = MapConfig.for_layers(run.map.layer_count)
		assert_eq(MapRules.find_violations(run.map, config).size(), 0)
	assert_eq(", ".join(failed), "", "sementes sem caminho vencível")
	gut.p("suavizações em 3 mapas: %d" % smoothing)
	var first: RunState = RunState.new(_data, 77, "warrior", [], CHECK_RUNS)
	var second: RunState = RunState.new(_data, 77, "warrior", [], CHECK_RUNS)
	assert_eq(second.map.signature(), first.map.signature())
	assert_eq(second.map_check.smoothing_steps, first.map_check.smoothing_steps)
	for node: MapNode in first.map.nodes:
		assert_eq(second.map.node_by_id(node.id).level, node.level)
