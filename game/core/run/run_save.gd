class_name RunSave
extends RefCounted
## Foto do estado de uma Descida em dados simples (GDD §20, TASK-012, ADR-0017), sem I/O:
## quem grava e lê arquivo é o [SaveStore]. Salva-se com a Bibiana no mapa (fase de
## escolha), então não há luta, loja nem fogueira em andamento. O mapa vai inteiro, para
## o retomar não refazer a checagem de vencibilidade.

const FORMAT: int = 1


static func to_dict(run: RunState) -> Dictionary:
	var nodes: Array[Array] = []
	for node: MapNode in run.map.nodes:
		nodes.append([node.id, node.layer, node.column, int(node.kind), Array(node.next_ids), node.enemy_id, node.level])
	return {
		"format": FORMAT,
		"rules_version": CoreVersion.RULES_VERSION,
		"class_id": run.class_id,
		"scenario_ids": run.scenario_ids,
		"scenario_index": run.scenario_index,
		"map": {"layers": run.map.layer_count, "width": run.map.width, "start_id": run.map.start_id,
			"boss_id": run.map.boss_id, "nodes": nodes},
		"current_node_id": run.current_node_id,
		"power": run.power,
		"gold": run.gold,
		"hp": run.hp,
		"mp": run.mp,
		"consumables": run.consumables,
		"equipment": run.equipment,
		"buffs": run.buffs,
		"embers": run.embers,
		"nodes_cleared": run.nodes_cleared,
		"enemies_defeated": run.enemies_defeated,
		"streams": run.streams.snapshot(),
		"coin": {"losses_in_row": run.coin.losses_in_row, "flips": run.coin.flips, "heads": run.coin.heads},
	}


## Reconstrói a Descida, ou devolve null se o formato, a versão das regras ou algum
## campo não bater (um save antigo não é reproduzido com regras novas sem aviso).
static func from_dict(data: GameData, saved: Dictionary) -> RunState:
	if int(saved.get("format", -1)) != FORMAT or int(saved.get("rules_version", -1)) != CoreVersion.RULES_VERSION:
		return null
	for key: String in ["class_id", "scenario_ids", "scenario_index", "map", "current_node_id", "power", "gold", "hp", "mp",
			"consumables", "equipment", "buffs", "embers", "nodes_cleared", "streams", "coin"]:
		if not saved.has(key):
			return null
	var map: MapGraph = _map_from(saved["map"])
	if map == null or not data.classes.has(str(saved["class_id"])):
		return null
	var streams: RngStreams = RngStreams.new(0)
	if not streams.restore(saved["streams"]):
		return null
	var scenarios: Array[String] = []
	for scenario_id: Variant in saved["scenario_ids"]:
		scenarios.append(str(scenario_id))
	var run: RunState = RunState.new(data, streams.run_seed, str(saved["class_id"]), scenarios, 0, map)
	run.streams = streams
	run.scenario_index = int(saved["scenario_index"])
	run.current_node_id = int(saved["current_node_id"])
	run.power = float(saved["power"])
	run.gold = int(saved["gold"])
	run.hp = int(saved["hp"])
	run.mp = int(saved["mp"])
	run.embers = int(saved["embers"])
	run.nodes_cleared = int(saved["nodes_cleared"])
	run.enemies_defeated = int(saved.get("enemies_defeated", 0))
	run.consumables = _int_dictionary(saved["consumables"])
	run.buffs = _int_dictionary(saved["buffs"])
	run.equipment = {}
	for slot: String in saved["equipment"]:
		run.equipment[slot] = str(saved["equipment"][slot])
	var coin: Dictionary = saved["coin"]
	run.coin.losses_in_row = int(coin["losses_in_row"])
	run.coin.flips = int(coin["flips"])
	run.coin.heads = int(coin["heads"])
	return run


static func _map_from(raw: Variant) -> MapGraph:
	if not raw is Dictionary or not (raw as Dictionary).has("nodes"):
		return null
	var entry: Dictionary = raw
	var graph: MapGraph = MapGraph.new()
	graph.layer_count = int(entry["layers"])
	graph.width = int(entry["width"])
	graph.start_id = int(entry["start_id"])
	graph.boss_id = int(entry["boss_id"])
	for row: Variant in entry["nodes"]:
		if not row is Array or (row as Array).size() != 7:
			return null
		var fields: Array = row
		var node: MapNode = MapNode.new(int(fields[0]), int(fields[1]), int(fields[2]), int(fields[3]) as MapNode.Kind)
		for next_id: Variant in fields[4]:
			node.next_ids.append(int(next_id))
		node.enemy_id = str(fields[5])
		node.level = int(fields[6])
		graph.nodes.append(node)
	if graph.node_by_id(graph.start_id) == null or graph.node_by_id(graph.boss_id) == null:
		return null
	return graph


static func _int_dictionary(source: Dictionary) -> Dictionary:
	var result: Dictionary = {}
	for key: String in source:
		result[key] = int(source[key])
	return result
