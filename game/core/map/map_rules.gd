class_name MapRules
extends RefCounted
## Confere as regras de justiça e de estrutura do mapa (GDD §5 e §12). Cada violação
## começa com um código fixo, para testes e relatórios. Lista vazia é mapa válido.
##
## Ainda não confere o que depende de nível de inimigo (opção "segura" por nível e
## caminho vencível pelo bot): isso chega com a TASK-008.

const LINKS: String = "LINKS"
const KINDS: String = "KINDS"
const BOSS_UNREACHABLE: String = "BOSS_UNREACHABLE"
const ELITE_EARLY: String = "ELITE_EARLY"
const ELITE_CROWD: String = "ELITE_CROWD"
const NO_SAFE_OPTION: String = "NO_SAFE_OPTION"
const CHEST_CHAIN: String = "CHEST_CHAIN"
const BONFIRE_CHAIN: String = "BONFIRE_CHAIN"
const BONFIRE_NOT_OFFERED: String = "BONFIRE_NOT_OFFERED"
const BONFIRE_COUNT: String = "BONFIRE_COUNT"


static func find_violations(graph: MapGraph, config: MapConfig) -> PackedStringArray:
	var found: PackedStringArray = PackedStringArray()
	var layers: int = graph.layer_count
	if graph.nodes.size() != layers * graph.width + 2:
		found.append("%s: número de nós não bate com camadas e largura" % LINKS)
		return found
	_check_links_and_kinds(graph, found)
	if not found.is_empty():
		return found
	if not graph.reachable_ids().has(graph.boss_id):
		found.append("%s: o chefe não é alcançável" % BOSS_UNREACHABLE)
	_check_elites(graph, config, found)
	_check_chains(graph, found)
	_check_bonfires(graph, config, found)
	return found


static func _check_links_and_kinds(graph: MapGraph, found: PackedStringArray) -> void:
	var layers: int = graph.layer_count
	for node: MapNode in graph.nodes:
		var is_start: bool = node.layer == 0
		var is_boss: bool = node.layer == layers + 1
		if (node.kind == MapNode.Kind.START) != is_start or (node.kind == MapNode.Kind.BOSS) != is_boss:
			found.append("%s: nó %d tem tipo %s fora do lugar" % [KINDS, node.id, node.letter()])
		if node.kind == MapNode.Kind.MINI_BOSS:
			found.append("%s: nó %d é mini boss, que o gerador ainda não coloca" % [KINDS, node.id])
		if is_boss:
			if not node.next_ids.is_empty():
				found.append("%s: o chefe não pode ter saída" % LINKS)
		elif node.layer == layers:
			if node.next_ids.size() != 1 or node.next_ids[0] != graph.boss_id:
				found.append("%s: nó %d da última camada não leva só ao chefe" % [LINKS, node.id])
		else:
			_check_window(graph, node, found)


static func _check_window(graph: MapGraph, node: MapNode, found: PackedStringArray) -> void:
	if node.next_ids.size() != MapGraph.OPTIONS:
		found.append("%s: nó %d tem %d destinos, não 3" % [LINKS, node.id, node.next_ids.size()])
		return
	var first: MapNode = graph.node_by_id(node.next_ids[0])
	if first == null or first.layer != node.layer + 1 or first.column + MapGraph.OPTIONS > graph.width:
		found.append("%s: nó %d aponta para fora da camada seguinte" % [LINKS, node.id])
		return
	for offset: int in MapGraph.OPTIONS:
		if node.next_ids[offset] != first.id + offset:
			found.append("%s: destinos do nó %d não são colunas vizinhas" % [LINKS, node.id])
			return


static func _check_elites(graph: MapGraph, config: MapConfig, found: PackedStringArray) -> void:
	for layer: int in range(1, graph.layer_count + 1):
		var elites: int = 0
		for node: MapNode in graph.layer_nodes(layer):
			if node.kind == MapNode.Kind.ELITE:
				elites += 1
		if elites > 0 and layer <= config.elite_free_layers():
			found.append("%s: elite na camada %d" % [ELITE_EARLY, layer])
		if elites > config.max_elites_per_layer:
			found.append("%s: %d elites na camada %d" % [ELITE_CROWD, elites, layer])
	for node: MapNode in graph.nodes:
		if node.layer >= graph.layer_count:
			continue
		var calm: int = 0
		for option: MapNode in graph.options_from(node.id):
			if option.kind != MapNode.Kind.ELITE:
				calm += 1
		if calm == 0:
			found.append("%s: as 3 opções do nó %d são elites" % [NO_SAFE_OPTION, node.id])


static func _check_chains(graph: MapGraph, found: PackedStringArray) -> void:
	for node: MapNode in graph.nodes:
		for option: MapNode in graph.options_from(node.id):
			if node.kind == MapNode.Kind.CHEST and option.kind == MapNode.Kind.CHEST:
				found.append("%s: baú %d leva ao baú %d" % [CHEST_CHAIN, node.id, option.id])
			if node.kind == MapNode.Kind.BONFIRE and option.kind == MapNode.Kind.BONFIRE:
				found.append("%s: fogueira %d leva à fogueira %d" % [BONFIRE_CHAIN, node.id, option.id])


static func _check_bonfires(graph: MapGraph, config: MapConfig, found: PackedStringArray) -> void:
	var layers: int = graph.layer_count
	var total: int = 0
	var in_second_half: int = 0
	for node: MapNode in graph.nodes:
		if node.kind == MapNode.Kind.BONFIRE:
			total += 1
			if node.layer * 2 > layers:
				in_second_half += 1
	if total < config.bonfire_count() or in_second_half < 1:
		found.append("%s: %d fogueiras (%d na segunda metade), esperado ao menos %d" % [BONFIRE_COUNT, total, in_second_half, config.bonfire_count()])
	for node: MapNode in graph.layer_nodes(layers - 2):
		var offered: bool = false
		for option: MapNode in graph.options_from(node.id):
			if option.kind == MapNode.Kind.BONFIRE:
				offered = true
		if not offered:
			found.append("%s: nó %d não vê fogueira na penúltima camada" % [BONFIRE_NOT_OFFERED, node.id])
