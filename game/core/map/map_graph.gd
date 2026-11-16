class_name MapGraph
extends RefCounted
## Grafo em camadas de um cenário (GDD §5): ponto de partida, N camadas de largura W e
## o chefe. De qualquer nó antes da última camada saem exatamente 3 destinos, colunas
## vizinhas da camada seguinte (janela deslizante limitada às bordas). A última camada
## converge para o chefe.
##
## Ids: 0 é a partida; o nó da camada L (1 a N), coluna C, é 1 + (L - 1) * W + C; o
## chefe é 1 + N * W. Os ids crescem com a camada.

const OPTIONS: int = 3

var layer_count: int = 0
var width: int = 0
var nodes: Array[MapNode] = []
var start_id: int = 0
var boss_id: int = 0


## Monta a estrutura, com todos os nós das camadas como batalha comum.
## [param start_window] é a primeira coluna das 3 opções oferecidas na partida.
static func build(layers: int, map_width: int, start_window: int) -> MapGraph:
	var graph: MapGraph = MapGraph.new()
	graph.layer_count = layers
	graph.width = map_width
	graph.boss_id = 1 + layers * map_width
	var last_window: int = maxi(map_width - OPTIONS, 0)
	var start: MapNode = MapNode.new(0, 0, 0, MapNode.Kind.START)
	graph.nodes.append(start)
	for layer: int in range(1, layers + 1):
		for column: int in map_width:
			var node: MapNode = MapNode.new(graph.id_at(layer, column), layer, column)
			if layer < layers:
				graph._link_window(node, layer + 1, clampi(column - 1, 0, last_window))
			else:
				node.next_ids.append(graph.boss_id)
			graph.nodes.append(node)
	graph.nodes.append(MapNode.new(graph.boss_id, layers + 1, 0, MapNode.Kind.BOSS))
	graph._link_window(start, 1, clampi(start_window, 0, last_window))
	return graph


func id_at(layer: int, column: int) -> int:
	return 1 + (layer - 1) * width + column


func node_by_id(node_id: int) -> MapNode:
	if node_id < 0 or node_id >= nodes.size():
		return null
	return nodes[node_id]


## Nó de uma camada (1 a N) e coluna, ou null fora do mapa.
func node_at(layer: int, column: int) -> MapNode:
	if layer < 1 or layer > layer_count or column < 0 or column >= width:
		return null
	return nodes[id_at(layer, column)]


func start_node() -> MapNode:
	return nodes[start_id]


func boss_node() -> MapNode:
	return nodes[boss_id]


## Nós de uma camada: 0 devolve a partida, N + 1 devolve o chefe.
func layer_nodes(layer: int) -> Array[MapNode]:
	var found: Array[MapNode] = []
	if layer == 0:
		found.append(start_node())
	elif layer == layer_count + 1:
		found.append(boss_node())
	else:
		for column: int in width:
			var node: MapNode = node_at(layer, column)
			if node != null:
				found.append(node)
	return found


## Destinos que o jogador vê a partir de um nó.
func options_from(node_id: int) -> Array[MapNode]:
	var found: Array[MapNode] = []
	var node: MapNode = node_by_id(node_id)
	if node != null:
		for next_id: int in node.next_ids:
			found.append(nodes[next_id])
	return found


## Nós da camada anterior que levam a este.
func predecessors(node_id: int) -> Array[MapNode]:
	var found: Array[MapNode] = []
	var node: MapNode = node_by_id(node_id)
	if node == null or node.layer == 0:
		return found
	for candidate: MapNode in layer_nodes(node.layer - 1):
		if candidate.next_ids.has(node_id):
			found.append(candidate)
	return found


## Ids alcançáveis a partir da partida, em ordem crescente (inclui a partida).
func reachable_ids() -> PackedInt32Array:
	var seen: PackedByteArray = PackedByteArray()
	seen.resize(nodes.size())
	seen[start_id] = 1
	var found: PackedInt32Array = PackedInt32Array()
	for node: MapNode in nodes:
		if seen[node.id] == 0:
			continue
		found.append(node.id)
		for next_id: int in node.next_ids:
			seen[next_id] = 1
	return found


## Rota da partida ao chefe com a menor soma de custo, sem incluir a partida.
## [param cost] recebe um [MapNode] e devolve um número (perigo esperado do nó).
## No empate vence a menor coluna. É o "caminho mais seguro" do GDD §5; o custo de
## verdade (nível esperado dos inimigos) chega com o bot de vencibilidade (TASK-008).
func safest_route(cost: Callable) -> PackedInt32Array:
	var best: PackedFloat64Array = PackedFloat64Array()
	var choice: PackedInt32Array = PackedInt32Array()
	best.resize(nodes.size())
	choice.resize(nodes.size())
	for node_id: int in range(nodes.size() - 1, -1, -1):
		var node: MapNode = nodes[node_id]
		var own: float = 0.0
		if node.kind != MapNode.Kind.START:
			own = cost.call(node)
		var chosen: int = -1
		var chosen_total: float = 0.0
		for next_id: int in node.next_ids:
			if chosen == -1 or best[next_id] < chosen_total:
				chosen = next_id
				chosen_total = best[next_id]
		best[node_id] = own + chosen_total
		choice[node_id] = chosen
	var route: PackedInt32Array = PackedInt32Array()
	var current: int = choice[start_id]
	while current != -1:
		route.append(current)
		current = choice[current]
	return route


## Texto curto que identifica o mapa: "NxW@janela/camada1/.../camadaN", uma letra por
## nó ([constant MapNode.KIND_LETTERS]). Dois mapas iguais têm a mesma assinatura.
func signature() -> String:
	var first_option: MapNode = nodes[start_node().next_ids[0]]
	var text: String = "%dx%d@%d" % [layer_count, width, first_option.column]
	for layer: int in range(1, layer_count + 1):
		text += "/"
		for node: MapNode in layer_nodes(layer):
			text += node.letter()
	return text


func _link_window(node: MapNode, target_layer: int, first_column: int) -> void:
	for offset: int in mini(OPTIONS, width):
		node.next_ids.append(id_at(target_layer, first_column + offset))
