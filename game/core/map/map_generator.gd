class_name MapGenerator
extends RefCounted
## Gera o mapa de um cenário a partir de uma configuração e do fluxo de sorteio do mapa
## (GDD §5 e §12; interpretações no ADR-0007). O mesmo fluxo no mesmo estado dá sempre
## o mesmo mapa. As regras são cumpridas por construção; [MapRules] confere depois.
##
## Fora daqui por enquanto: mini boss, nível e mutação dos inimigos, e a prova de
## vencibilidade com o bot (TASK-008, que usa [method MapGraph.safest_route]).


## Devolve o mapa, ou null se [method MapConfig.problems] apontar algum problema.
static func generate(config: MapConfig, rng: Pcg32) -> MapGraph:
	if not config.problems().is_empty():
		return null
	var last_window: int = config.width - MapGraph.OPTIONS
	var graph: MapGraph = MapGraph.build(config.layer_count, config.width, rng.draw_int(0, last_window))
	_place_bonfires(graph, config, rng)
	for layer: int in range(1, config.layer_count + 1):
		var elites: int = 0
		for node: MapNode in graph.layer_nodes(layer):
			if node.kind == MapNode.Kind.BONFIRE:
				continue
			node.kind = _draw_kind(graph, config, node, elites, rng)
			if node.kind == MapNode.Kind.ELITE:
				elites += 1
	return graph


## A penúltima camada recebe uma fogueira em uma coluna que aparece nas 3 opções de
## qualquer nó anterior. Mapas de 6 camadas ou mais ganham outra, a no máximo 3 camadas do
## fim e longe da primeira, para as duas nunca ficarem ligadas.
static func _place_bonfires(graph: MapGraph, config: MapConfig, rng: Pcg32) -> void:
	var layers: int = config.layer_count
	var shared_column: int = rng.draw_int(config.width - MapGraph.OPTIONS, MapGraph.OPTIONS - 1)
	graph.node_at(layers - 1, shared_column).kind = MapNode.Kind.BONFIRE
	if config.bonfire_count() >= 2:
		@warning_ignore("integer_division")
		var extra_layer: int = rng.draw_int(mini(layers / 2 + 1, layers - 3), layers - 3)
		var extra_column: int = rng.draw_int(0, config.width - 1)
		graph.node_at(extra_layer, extra_column).kind = MapNode.Kind.BONFIRE


static func _draw_kind(graph: MapGraph, config: MapConfig, node: MapNode, elites_in_layer: int, rng: Pcg32) -> MapNode.Kind:
	var elite: int = config.weight_elite
	if node.layer <= config.elite_free_layers() or elites_in_layer >= config.max_elites_per_layer:
		elite = 0
	var chest: int = config.weight_chest
	for previous: MapNode in graph.predecessors(node.id):
		if previous.kind == MapNode.Kind.CHEST:
			chest = 0
	var total: int = config.weight_battle + elite + chest + config.weight_event + config.weight_ambush
	var roll: int = rng.draw_int(1, total)
	roll -= config.weight_battle
	if roll <= 0:
		return MapNode.Kind.BATTLE
	roll -= elite
	if roll <= 0:
		return MapNode.Kind.ELITE
	roll -= chest
	if roll <= 0:
		return MapNode.Kind.CHEST
	roll -= config.weight_event
	if roll <= 0:
		return MapNode.Kind.EVENT
	return MapNode.Kind.AMBUSH
