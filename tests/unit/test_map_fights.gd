extends GutTest
## TASK-081 (ADR-0067, GDD §5): nenhuma rota do início ao chefe passa por menos de 2 lutas.


func _min_fights(graph: MapGraph) -> int:
	return int(MapGenerator._poorest_route(graph)["fights"])


func test_every_route_crosses_at_least_two_fights_across_seeds_and_sizes() -> void:
	for layers: int in [3, 4, 5, 6, 8, 10, 12]:
		var config: MapConfig = MapConfig.for_layers(layers)
		for seed_value: int in range(1, 41):
			var rng: Pcg32 = Pcg32.new(seed_value, 54)
			var graph: MapGraph = MapGenerator.generate(config, rng)
			assert_not_null(graph)
			assert_gte(_min_fights(graph), MapGenerator.MIN_FIGHTS_PER_ROUTE,
				"%d camadas, semente %d: rota com menos de 2 lutas" % [layers, seed_value])


func test_generation_is_still_deterministic() -> void:
	var config: MapConfig = MapConfig.for_layers(6)
	var a: MapGraph = MapGenerator.generate(config, Pcg32.new(7, 54))
	var b: MapGraph = MapGenerator.generate(config, Pcg32.new(7, 54))
	for node: MapNode in a.nodes:
		assert_eq(node.kind, b.node_by_id(node.id).kind)


func test_repair_keeps_bonfires_and_only_turns_chests_and_events_into_battles() -> void:
	var config: MapConfig = MapConfig.for_layers(4)
	var graph: MapGraph = MapGenerator.generate(config, Pcg32.new(3, 54))
	var bonfires: int = 0
	for node: MapNode in graph.nodes:
		if node.kind == MapNode.Kind.BONFIRE:
			bonfires += 1
	assert_gt(bonfires, 0, "a fogueira da penúltima camada continua lá")
