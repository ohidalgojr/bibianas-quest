extends GutTest
## GDD §5 (Estrutura): grafo em camadas com janela deslizante de 3 destinos.


func _ids(found: Array[MapNode]) -> Array[int]:
	var ids: Array[int] = []
	for node: MapNode in found:
		ids.append(node.id)
	return ids


func _columns(found: Array[MapNode]) -> Array[int]:
	var columns: Array[int] = []
	for node: MapNode in found:
		columns.append(node.column)
	return columns


func test_build_creates_start_layers_and_boss() -> void:
	var graph: MapGraph = MapGraph.build(5, 4, 0)
	assert_eq(graph.nodes.size(), 22, "partida + 5 x 4 + chefe")
	assert_eq(graph.start_node().kind, MapNode.Kind.START)
	assert_eq(graph.boss_node().kind, MapNode.Kind.BOSS)
	assert_eq(graph.boss_id, 21)
	assert_eq(graph.boss_node().layer, 6)
	for node_id: int in graph.nodes.size():
		assert_eq(graph.nodes[node_id].id, node_id, "o id é a posição na lista")
	assert_eq(graph.node_at(3, 2).id, 11)
	assert_eq(graph.node_at(3, 2).kind, MapNode.Kind.BATTLE)


func test_node_lookups_outside_the_map_return_null() -> void:
	var graph: MapGraph = MapGraph.build(5, 4, 0)
	assert_null(graph.node_at(0, 0))
	assert_null(graph.node_at(6, 0))
	assert_null(graph.node_at(1, 4))
	assert_null(graph.node_by_id(-1))
	assert_null(graph.node_by_id(99))
	assert_eq(graph.options_from(99).size(), 0)


func test_sliding_window_width_4() -> void:
	var graph: MapGraph = MapGraph.build(5, 4, 0)
	assert_eq(_columns(graph.options_from(graph.node_at(1, 0).id)), [0, 1, 2] as Array[int])
	assert_eq(_columns(graph.options_from(graph.node_at(1, 1).id)), [0, 1, 2] as Array[int])
	assert_eq(_columns(graph.options_from(graph.node_at(1, 2).id)), [1, 2, 3] as Array[int])
	assert_eq(_columns(graph.options_from(graph.node_at(1, 3).id)), [1, 2, 3] as Array[int])


func test_sliding_window_width_5() -> void:
	var graph: MapGraph = MapGraph.build(9, 5, 2)
	assert_eq(_columns(graph.options_from(graph.node_at(4, 0).id)), [0, 1, 2] as Array[int])
	assert_eq(_columns(graph.options_from(graph.node_at(4, 2).id)), [1, 2, 3] as Array[int])
	assert_eq(_columns(graph.options_from(graph.node_at(4, 4).id)), [2, 3, 4] as Array[int])
	assert_eq(_columns(graph.options_from(graph.start_id)), [2, 3, 4] as Array[int])


func test_every_node_before_the_last_layer_offers_exactly_three() -> void:
	var graph: MapGraph = MapGraph.build(9, 5, 1)
	for node: MapNode in graph.nodes:
		if node.layer < 9:
			var options: Array[MapNode] = graph.options_from(node.id)
			assert_eq(options.size(), 3, "nó %d" % node.id)
			for option: MapNode in options:
				assert_eq(option.layer, node.layer + 1)


func test_last_layer_converges_to_the_boss() -> void:
	var graph: MapGraph = MapGraph.build(5, 4, 1)
	for node: MapNode in graph.layer_nodes(5):
		assert_eq(_ids(graph.options_from(node.id)), [graph.boss_id] as Array[int])
	assert_eq(graph.options_from(graph.boss_id).size(), 0)


func test_start_window_is_clamped() -> void:
	assert_eq(_columns(MapGraph.build(5, 4, 9).options_from(0)), [1, 2, 3] as Array[int])
	assert_eq(_columns(MapGraph.build(5, 4, -4).options_from(0)), [0, 1, 2] as Array[int])


func test_predecessors() -> void:
	var graph: MapGraph = MapGraph.build(5, 4, 0)
	assert_eq(_columns(graph.predecessors(graph.node_at(2, 0).id)), [0, 1] as Array[int])
	assert_eq(_columns(graph.predecessors(graph.node_at(2, 1).id)), [0, 1, 2, 3] as Array[int])
	assert_eq(_ids(graph.predecessors(graph.node_at(1, 2).id)), [0] as Array[int])
	assert_eq(graph.predecessors(graph.node_at(1, 3).id).size(), 0, "fora da janela da partida")
	assert_eq(graph.predecessors(graph.boss_id).size(), 4)


func test_reachable_ids_skip_the_first_layer_node_outside_the_start_window() -> void:
	var graph: MapGraph = MapGraph.build(5, 4, 0)
	var reachable: PackedInt32Array = graph.reachable_ids()
	assert_false(reachable.has(graph.node_at(1, 3).id))
	assert_true(reachable.has(graph.boss_id))
	assert_eq(reachable.size(), 21)


func test_safest_route_follows_the_cheapest_nodes() -> void:
	var graph: MapGraph = MapGraph.build(5, 4, 0)
	var cheap: Dictionary = {}
	for layer: int in range(1, 6):
		cheap[graph.node_at(layer, 2).id] = true
	var cost: Callable = func(node: MapNode) -> float: return 0.0 if cheap.has(node.id) else 5.0
	var route: PackedInt32Array = graph.safest_route(cost)
	assert_eq(route.size(), 6, "5 camadas e o chefe")
	for step: int in 5:
		assert_eq(graph.node_by_id(route[step]).column, 2, "camada %d" % (step + 1))
	assert_eq(route[5], graph.boss_id)


func test_safest_route_minimises_the_sum_not_the_next_step() -> void:
	var graph: MapGraph = MapGraph.build(3, 4, 0)
	var costs: Dictionary = {}
	for node: MapNode in graph.nodes:
		costs[node.id] = 10.0
	costs[graph.node_at(1, 0).id] = 1.0
	costs[graph.node_at(1, 2).id] = 2.0
	costs[graph.node_at(2, 3).id] = 0.0
	var cost: Callable = func(node: MapNode) -> float: return costs[node.id]
	var route: PackedInt32Array = graph.safest_route(cost)
	assert_eq(graph.node_by_id(route[0]).column, 2, "o passo mais barato leva a um caminho mais caro")
	assert_eq(graph.node_by_id(route[1]).column, 3)


func test_safest_route_breaks_ties_by_lowest_column() -> void:
	var graph: MapGraph = MapGraph.build(5, 4, 1)
	var cost: Callable = func(_node: MapNode) -> float: return 1.0
	var route: PackedInt32Array = graph.safest_route(cost)
	assert_eq(graph.node_by_id(route[0]).column, 1)
	assert_eq(graph.node_by_id(route[1]).column, 0)
	assert_eq(route.size(), 6)


func test_signature_lists_window_and_layers() -> void:
	var graph: MapGraph = MapGraph.build(3, 4, 1)
	graph.node_at(2, 1).kind = MapNode.Kind.BONFIRE
	graph.node_at(3, 0).kind = MapNode.Kind.ELITE
	graph.node_at(1, 3).kind = MapNode.Kind.CHEST
	assert_eq(graph.signature(), "3x4@1/BBBC/BFBB/EBBB")


func test_node_kind_helpers() -> void:
	assert_eq(MapNode.new(0, 0, 0, MapNode.Kind.AMBUSH).letter(), "A")
	assert_eq(MapNode.new(0, 0, 0, MapNode.Kind.EVENT).letter(), "V")
	assert_true(MapNode.new(0, 0, 0, MapNode.Kind.ELITE).is_fight())
	assert_true(MapNode.new(0, 0, 0, MapNode.Kind.BOSS).is_fight())
	assert_false(MapNode.new(0, 0, 0, MapNode.Kind.CHEST).is_fight())
	assert_false(MapNode.new(0, 0, 0, MapNode.Kind.BONFIRE).is_fight())
