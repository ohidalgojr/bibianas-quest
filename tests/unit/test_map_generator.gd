extends GutTest
## GDD §5: o mapa é determinístico por semente e nenhuma semente pode quebrar as regras
## de justiça ("um teste automatizado gera milhares de mapas por cenário").

const SEEDS_PER_CONFIG: int = 5000


func _generate(run_seed: int, config: MapConfig) -> MapGraph:
	return MapGenerator.generate(config, RngStreams.new(run_seed).map())


## Gera um mapa por semente e devolve as violações encontradas (no máximo 5).
func _broken_seeds(config: MapConfig, seeds: int) -> PackedStringArray:
	var broken: PackedStringArray = PackedStringArray()
	for run_seed: int in seeds:
		var graph: MapGraph = _generate(run_seed, config)
		if graph == null:
			broken.append("semente %d: gerador devolveu null" % run_seed)
		else:
			var violations: PackedStringArray = MapRules.find_violations(graph, config)
			if not violations.is_empty():
				broken.append("semente %d: %s" % [run_seed, " | ".join(violations)])
		if broken.size() >= 5:
			break
	return broken


func test_property_scenario_1_five_layers_width_4() -> void:
	var broken: PackedStringArray = _broken_seeds(MapConfig.for_layers(5), SEEDS_PER_CONFIG)
	assert_eq(" || ".join(broken), "", "%d sementes, 5 camadas" % SEEDS_PER_CONFIG)


func test_property_scenario_5_nine_layers_width_5() -> void:
	var broken: PackedStringArray = _broken_seeds(MapConfig.for_layers(9), SEEDS_PER_CONFIG)
	assert_eq(" || ".join(broken), "", "%d sementes, 9 camadas" % SEEDS_PER_CONFIG)


func test_property_every_scenario_and_edge_sizes() -> void:
	for scenario: int in range(1, 6):
		var broken: PackedStringArray = _broken_seeds(MapConfig.for_scenario(scenario), 1000)
		assert_eq(" || ".join(broken), "", "cenário %d" % scenario)
	for layers: int in [3, 4, 12]:
		for map_width: int in [3, 4, 5]:
			var config: MapConfig = MapConfig.for_layers(layers)
			config.width = map_width
			var broken: PackedStringArray = _broken_seeds(config, 300)
			assert_eq(" || ".join(broken), "", "%d camadas, largura %d" % [layers, map_width])


func test_property_holds_with_extreme_weights() -> void:
	var elites: MapConfig = MapConfig.for_layers(5)
	elites.weight_elite = 1000
	assert_eq(" || ".join(_broken_seeds(elites, 500)), "", "quase tudo elite")
	var chests: MapConfig = MapConfig.for_layers(9)
	chests.weight_chest = 1000
	assert_eq(" || ".join(_broken_seeds(chests, 500)), "", "quase tudo baú")


func test_same_seed_gives_the_same_map() -> void:
	var config: MapConfig = MapConfig.for_scenario(1)
	for run_seed: int in 200:
		assert_eq(_generate(run_seed, config).signature(), _generate(run_seed, config).signature())


func test_different_seeds_give_different_maps() -> void:
	var config: MapConfig = MapConfig.for_scenario(1)
	var seen: Dictionary = {}
	for run_seed: int in 1000:
		seen[_generate(run_seed, config).signature()] = true
	assert_gt(seen.size(), 950, "mil sementes devem dar quase mil mapas distintos")


func test_golden_maps_pin_the_generation() -> void:
	# Se estes textos mudarem, as Descidas gravadas mudaram: exige ADR e RULES_VERSION.
	assert_eq(_generate(12345, MapConfig.for_scenario(1)).signature(), "5x4@1/BVAB/VBAC/BBEB/BFBA/BEVB")
	assert_eq(_generate(12345, MapConfig.for_scenario(5)).signature(), "9x5@2/VABVB/ACVBC/ABBBB/EVBVE/EBFBB/CBBAA/EBABV/EAFVB/EBBAC")


func test_generation_only_spends_the_map_stream() -> void:
	var used: RngStreams = RngStreams.new(77)
	var untouched: RngStreams = RngStreams.new(77)
	MapGenerator.generate(MapConfig.for_scenario(3), used.map())
	assert_eq(used.combat().next_u32(), untouched.combat().next_u32())
	assert_eq(used.loot().next_u32(), untouched.loot().next_u32())
	assert_eq(used.coin().next_u32(), untouched.coin().next_u32())
	assert_ne(used.map().next_u32(), untouched.map().next_u32())


func test_invalid_config_returns_null() -> void:
	var config: MapConfig = MapConfig.for_layers(5)
	config.width = 9
	assert_null(MapGenerator.generate(config, RngStreams.new(1).map()))


func test_kind_frequencies_stay_near_the_gdd_starting_values() -> void:
	var config: MapConfig = MapConfig.for_scenario(1)
	var counts: Dictionary = {}
	var drawn: int = 0
	var elite_slots: int = 0
	for run_seed: int in 2000:
		var graph: MapGraph = _generate(run_seed, config)
		for layer: int in range(1, config.layer_count + 1):
			for node: MapNode in graph.layer_nodes(layer):
				if node.kind == MapNode.Kind.BONFIRE:
					continue
				counts[node.kind] = int(counts.get(node.kind, 0)) + 1
				drawn += 1
				if layer > config.elite_free_layers():
					elite_slots += 1
	var battle: float = 100.0 * float(counts.get(MapNode.Kind.BATTLE, 0)) / float(drawn)
	var ambush: float = 100.0 * float(counts.get(MapNode.Kind.AMBUSH, 0)) / float(drawn)
	var chest: float = 100.0 * float(counts.get(MapNode.Kind.CHEST, 0)) / float(drawn)
	var event: float = 100.0 * float(counts.get(MapNode.Kind.EVENT, 0)) / float(drawn)
	var elite: float = 100.0 * float(counts.get(MapNode.Kind.ELITE, 0)) / float(elite_slots)
	gut.p("batalha %.1f%%, emboscada %.1f%%, baú %.1f%%, evento %.1f%%, elite %.1f%% das camadas liberadas" % [battle, ambush, chest, event, elite])
	assert_between(battle, 52.0, 66.0, "batalha (GDD: 55%, sobe onde elite e baú são barrados)")
	assert_between(ambush, 15.0, 24.0, "emboscada (GDD: 18%)")
	assert_between(chest, 4.0, 10.0, "baú (GDD: 8%, cai por nunca vir em sequência)")
	assert_between(event, 6.0, 13.0, "evento (GDD: 9%)")
	assert_between(elite, 8.0, 13.0, "elite nas camadas liberadas (GDD: 10%)")
	assert_eq(counts.size(), 5, "só os cinco tipos sorteados aparecem")


func test_route_to_the_boss_exists_on_generated_maps() -> void:
	var cost: Callable = func(node: MapNode) -> float: return 3.0 if node.kind == MapNode.Kind.ELITE else 1.0
	for run_seed: int in 300:
		var graph: MapGraph = _generate(run_seed, MapConfig.for_scenario(5))
		var route: PackedInt32Array = graph.safest_route(cost)
		assert_eq(route.size(), 10, "9 camadas e o chefe")
		assert_eq(route[route.size() - 1], graph.boss_id)
