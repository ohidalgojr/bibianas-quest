extends GutTest
## GDD §5 e §12: parâmetros de partida do mapa.


func test_defaults_are_the_gdd_starting_values() -> void:
	var config: MapConfig = MapConfig.new()
	assert_eq(config.layer_count, 5)
	assert_eq(config.width, 4)
	assert_eq(config.weight_battle, 49)
	assert_eq(config.weight_elite, 10)
	assert_eq(config.weight_chest, 14)
	assert_eq(config.weight_event, 9)
	assert_eq(config.weight_ambush, 18, "emboscada é o restante")
	assert_eq(config.weight_battle + config.weight_elite + config.weight_chest + config.weight_event + config.weight_ambush, 100)
	assert_eq(config.problems().size(), 0)


func test_width_follows_layer_count() -> void:
	assert_eq(MapConfig.for_layers(5).width, 4)
	assert_eq(MapConfig.for_layers(6).width, 4)
	assert_eq(MapConfig.for_layers(7).width, 5)
	assert_eq(MapConfig.for_layers(9).width, 5)


func test_scenarios_grow_from_4_to_10_layers() -> void:
	var expected: Array[int] = [4, 6, 7, 8, 10]
	for scenario: int in range(1, 6):
		assert_eq(MapConfig.for_scenario(scenario).layer_count, expected[scenario - 1])
	assert_eq(MapConfig.for_scenario(0).layer_count, 4)
	assert_eq(MapConfig.for_scenario(99).layer_count, 10)


func test_elite_free_layers_round_up_30_percent() -> void:
	var expected: Dictionary = {5: 2, 6: 2, 7: 3, 8: 3, 9: 3, 10: 3}
	for layers: int in expected:
		assert_eq(MapConfig.for_layers(layers).elite_free_layers(), expected[layers], "%d camadas" % layers)


func test_bonfire_count() -> void:
	assert_eq(MapConfig.for_layers(5).bonfire_count(), 1)
	assert_eq(MapConfig.for_layers(6).bonfire_count(), 2, "ADR-0027: a partir de 6 camadas")
	assert_eq(MapConfig.for_layers(7).bonfire_count(), 2)
	assert_eq(MapConfig.for_layers(8).bonfire_count(), 3, "uma fogueira a cada 3 camadas (ADR-0028)")
	assert_eq(MapConfig.for_layers(9).bonfire_count(), 3)
	assert_eq(MapConfig.for_layers(10).bonfire_count(), 3)
	assert_eq(MapConfig.for_layers(12).bonfire_count(), 4)


func test_problems_catch_bad_values() -> void:
	var config: MapConfig = MapConfig.new()
	config.layer_count = 2
	config.width = 6
	config.weight_chest = -1
	config.max_elites_per_layer = 3
	assert_eq(config.problems().size(), 4)
	var empty: MapConfig = MapConfig.new()
	empty.weight_battle = 0
	empty.weight_event = 0
	empty.weight_ambush = 0
	assert_eq(empty.problems().size(), 1)
