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
	ensure_fights_on_every_route(graph)
	return graph


## GDD §5 (ADR-0067): nenhuma rota do início ao chefe passa por menos de 2 lutas. Sem isso, a Descida só
## de baú, fogueira e evento chegava ao chefe sem desafio nem Poder. Reparo determinístico, sem sorteio:
## enquanto a rota mais pobre em lutas tiver menos de [constant MIN_FIGHTS_PER_ROUTE], o primeiro baú ou
## evento dela vira batalha comum (fogueiras ficam como estão).
const MIN_FIGHTS_PER_ROUTE: int = 2


static func _is_fight_kind(kind: MapNode.Kind) -> bool:
	return kind == MapNode.Kind.BATTLE or kind == MapNode.Kind.AMBUSH or kind == MapNode.Kind.ELITE \
		or kind == MapNode.Kind.MINI_BOSS


## Menor número de lutas (antes do chefe) entre as rotas do início ao chefe, e uma rota que o atinge.
static func poorest_route(graph: MapGraph) -> Dictionary:
	var best: Dictionary = {}
	var route: Dictionary = {}
	for layer: int in range(graph.layer_count, -1, -1):
		for node: MapNode in graph.layer_nodes(layer):
			var fights_here: int = 1 if (layer > 0 and _is_fight_kind(node.kind)) else 0
			if node.next_ids.is_empty() or layer == graph.layer_count:
				best[node.id] = fights_here
				route[node.id] = [node.id]
				continue
			var pick: int = -1
			var pick_fights: int = 1 << 30
			for next_id: int in node.next_ids:
				if next_id == graph.boss_id or not best.has(next_id):
					continue
				if int(best[next_id]) < pick_fights:
					pick_fights = int(best[next_id])
					pick = next_id
			if pick < 0:
				best[node.id] = fights_here
				route[node.id] = [node.id]
			else:
				best[node.id] = fights_here + pick_fights
				var chain: Array = [node.id]
				chain.append_array(route[pick] as Array)
				route[node.id] = chain
	return {"fights": int(best.get(graph.start_id, 0)), "route": route.get(graph.start_id, [])}


## Devolve os ids convertidos. Converte o ÚLTIMO baú ou evento da rota (as primeiras camadas mantêm a
## escolha e o que a 1ª Descida garante); `protected` lista nós que nunca mudam (baú garantido da 1ª Descida).
static func ensure_fights_on_every_route(graph: MapGraph, protected: PackedInt32Array = PackedInt32Array()) -> PackedInt32Array:
	var converted: PackedInt32Array = PackedInt32Array()
	for attempt: int in graph.layer_count * graph.width:
		var poorest: Dictionary = poorest_route(graph)
		if int(poorest["fights"]) >= MIN_FIGHTS_PER_ROUTE:
			return converted
		var fixed: bool = false
		var route: Array = poorest["route"] as Array
		for index: int in range(route.size() - 1, -1, -1):
			var node: MapNode = graph.node_by_id(int(route[index]))
			if node.layer > 0 and not protected.has(node.id) and (node.kind == MapNode.Kind.CHEST or node.kind == MapNode.Kind.EVENT):
				node.kind = MapNode.Kind.BATTLE
				converted.append(node.id)
				fixed = true
				break
		if not fixed:
			return converted
	return converted


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
		# Fogueiras além da segunda (mapas de 8 camadas ou mais): camadas de 2 a layers - 3, a pelo
		# menos 2 camadas de qualquer outra fogueira, para nunca ficarem ligadas (ADR-0028).
		var taken: Array[int] = [layers - 1, extra_layer]
		for extra: int in config.bonfire_count() - 2:
			var candidates: Array[int] = []
			for layer: int in range(2, layers - 2):
				var free: bool = true
				for used: int in taken:
					if absi(layer - used) < 2:
						free = false
				if free:
					candidates.append(layer)
			if candidates.is_empty():
				break
			var chosen_layer: int = candidates[rng.draw_index(candidates.size())]
			graph.node_at(chosen_layer, rng.draw_int(0, config.width - 1)).kind = MapNode.Kind.BONFIRE
			taken.append(chosen_layer)


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
