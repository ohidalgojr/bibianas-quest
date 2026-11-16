extends GutTest
## GDD §5 e §12: o conferidor de regras do mapa precisa enxergar cada violação,
## senão o teste de propriedade do gerador não prova nada.


func _valid(layers: int = 5) -> MapGraph:
	var config: MapConfig = MapConfig.for_layers(layers)
	var graph: MapGraph = MapGraph.build(layers, config.width, 0)
	graph.node_at(layers - 1, 2).kind = MapNode.Kind.BONFIRE
	if layers >= 8:
		graph.node_at(5, 0).kind = MapNode.Kind.BONFIRE
	return graph


func _codes(graph: MapGraph, layers: int = 5) -> String:
	return " | ".join(MapRules.find_violations(graph, MapConfig.for_layers(layers)))


func test_hand_built_maps_are_valid() -> void:
	assert_eq(_codes(_valid()), "")
	assert_eq(_codes(_valid(9), 9), "")


func test_elite_in_the_first_layers_is_flagged() -> void:
	var graph: MapGraph = _valid()
	graph.node_at(2, 0).kind = MapNode.Kind.ELITE
	assert_string_contains(_codes(graph), MapRules.ELITE_EARLY)
	var late: MapGraph = _valid()
	late.node_at(3, 0).kind = MapNode.Kind.ELITE
	assert_eq(_codes(late), "", "a camada 3 de 5 já aceita elite")


func test_three_elites_in_a_layer_are_flagged() -> void:
	var graph: MapGraph = _valid()
	for column: int in 3:
		graph.node_at(3, column).kind = MapNode.Kind.ELITE
	var codes: String = _codes(graph)
	assert_string_contains(codes, MapRules.ELITE_CROWD)
	assert_string_contains(codes, MapRules.NO_SAFE_OPTION)
	var two: MapGraph = _valid()
	two.node_at(3, 0).kind = MapNode.Kind.ELITE
	two.node_at(3, 1).kind = MapNode.Kind.ELITE
	assert_eq(_codes(two), "", "duas elites na camada são permitidas")


func test_chest_leading_to_chest_is_flagged() -> void:
	var graph: MapGraph = _valid()
	graph.node_at(1, 0).kind = MapNode.Kind.CHEST
	graph.node_at(2, 1).kind = MapNode.Kind.CHEST
	assert_string_contains(_codes(graph), MapRules.CHEST_CHAIN)
	var apart: MapGraph = _valid()
	apart.node_at(1, 0).kind = MapNode.Kind.CHEST
	apart.node_at(2, 3).kind = MapNode.Kind.CHEST
	assert_eq(_codes(apart), "", "baús sem ligação entre si são permitidos")


func test_linked_bonfires_are_flagged() -> void:
	var graph: MapGraph = _valid()
	graph.node_at(5, 1).kind = MapNode.Kind.BONFIRE
	assert_string_contains(_codes(graph), MapRules.BONFIRE_CHAIN)


func test_missing_bonfire_is_flagged() -> void:
	var graph: MapGraph = _valid()
	graph.node_at(4, 2).kind = MapNode.Kind.BATTLE
	var codes: String = _codes(graph)
	assert_string_contains(codes, MapRules.BONFIRE_COUNT)
	assert_string_contains(codes, MapRules.BONFIRE_NOT_OFFERED)


func test_bonfire_out_of_sight_of_some_node_is_flagged() -> void:
	var graph: MapGraph = _valid()
	graph.node_at(4, 2).kind = MapNode.Kind.BATTLE
	graph.node_at(4, 0).kind = MapNode.Kind.BONFIRE
	var codes: String = _codes(graph)
	assert_string_contains(codes, MapRules.BONFIRE_NOT_OFFERED)
	assert_eq(codes.find(MapRules.BONFIRE_COUNT), -1, "a quantidade está certa; o problema é a posição")


func test_long_maps_need_two_bonfires() -> void:
	var graph: MapGraph = _valid(9)
	graph.node_at(5, 0).kind = MapNode.Kind.BATTLE
	assert_string_contains(_codes(graph, 9), MapRules.BONFIRE_COUNT)


func test_broken_links_are_flagged() -> void:
	var missing: MapGraph = _valid()
	missing.node_at(2, 0).next_ids.remove_at(2)
	assert_string_contains(_codes(missing), MapRules.LINKS)
	var gap: MapGraph = _valid()
	gap.node_at(2, 0).next_ids[2] = gap.node_at(3, 3).id
	assert_string_contains(_codes(gap), MapRules.LINKS)
	var skip: MapGraph = _valid()
	skip.node_at(5, 0).next_ids[0] = skip.node_at(5, 1).id
	assert_string_contains(_codes(skip), MapRules.LINKS)
	var short: MapGraph = _valid()
	short.nodes.remove_at(3)
	assert_string_contains(_codes(short), MapRules.LINKS)


func test_misplaced_kinds_are_flagged() -> void:
	var boss: MapGraph = _valid()
	boss.node_at(2, 0).kind = MapNode.Kind.BOSS
	assert_string_contains(_codes(boss), MapRules.KINDS)
	var start: MapGraph = _valid()
	start.start_node().kind = MapNode.Kind.BATTLE
	assert_string_contains(_codes(start), MapRules.KINDS)
	var mini: MapGraph = _valid()
	mini.node_at(3, 0).kind = MapNode.Kind.MINI_BOSS
	assert_string_contains(_codes(mini), MapRules.KINDS)
