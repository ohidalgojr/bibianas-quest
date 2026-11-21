class_name Map3DLayout
extends RefCounted
## Planta do tabuleiro isométrico (TASK-036, TASK-046, TASK-053; ADR-0037, ADR-0041; GDD §5 e
## §17). Delega ao algoritmo Terrace-Grammar-Constraint ([ScenarioGenerator]) e expõe os conjuntos e
## auxiliares compatíveis com [Map3DScreen] e os testes de contrato.

const LAYER_STEP: int = ScenarioGenerator.LAYER_STEP
const COLUMN_STEP: int = ScenarioGenerator.COLUMN_STEP
const MARGIN: int = ScenarioGenerator.MARGIN
const BLOCK_H: float = ScenarioBlueprint.BLOCK_H
const MIN_PLAZA_LEVEL: int = ScenarioBlueprint.MIN_PLAZA_LEVEL
const MAX_PLAZA_LEVEL: int = ScenarioBlueprint.MAX_PLAZA_LEVEL

var map: MapGraph
var map_seed: int = 0
var cols: int = 0
var rows: int = 0
var blueprint: ScenarioBlueprint

## Altura (em blocos) de cada célula, índice `z * cols + x`.
var heights: PackedInt32Array = PackedInt32Array()
var road_cells: Dictionary = {}
var plaza_cells: Dictionary = {}
var stairs: Dictionary = {}
var water_cells: Dictionary = {}
var bridge_cells: Dictionary = {}
var props: Dictionary = {}
var ruins: Array[Dictionary] = []
var lamps: Array[Vector2i] = []
var node_cells: Dictionary = {}
var node_levels: Dictionary = {}


func _init(graph: MapGraph, seed_value: int) -> void:
	map = graph
	map_seed = seed_value
	_build()


func _build() -> void:
	blueprint = ScenarioGenerator.generate_map(map, map_seed)
	cols = blueprint.cols
	rows = blueprint.rows
	heights = blueprint.heights
	road_cells = blueprint.road_cells
	plaza_cells = blueprint.plaza_cells
	stairs = blueprint.stairs
	water_cells = blueprint.water_cells
	bridge_cells = blueprint.bridge_cells
	node_cells = blueprint.node_cells
	node_levels = blueprint.node_levels
	ruins = blueprint.compounds.duplicate()
	lamps = blueprint.legacy_lamp_cells()
	props = blueprint.legacy_props_dict()


func height_at(cell: Vector2i) -> int:
	return blueprint.height_at(cell)


func layer_at_row(z: int) -> int:
	return blueprint.layer_at_row(z)


func world_of(cell: Vector2i) -> Vector3:
	return blueprint.world_of(cell)


func node_world(node_id: int) -> Vector3:
	return blueprint.node_world(node_id)


## Retorna o caminho exato pela estrada gerada entre duas praças (com BFS sobre células
## caminháveis como fallback). Garante que a heroína caminhe sobre estradas, pontes e escadas.
func path_cells(from_cell: Vector2i, to_cell: Vector2i) -> Array[Vector2i]:
	for raw_path: Variant in blueprint.edge_paths.values():
		var path: Array = raw_path as Array
		if path.size() >= 2 and (path[0] as Vector2i) == from_cell and (path[path.size() - 1] as Vector2i) == to_cell:
			var out: Array[Vector2i] = []
			for raw_c: Variant in path:
				out.append(raw_c as Vector2i)
			return out
	var bfs: Array[Vector2i] = _walkable_bfs(from_cell, to_cell)
	if not bfs.is_empty():
		return bfs
	return ScenarioGenerator._fallback_manhattan_path(from_cell, to_cell)


func _walkable_bfs(from_cell: Vector2i, to_cell: Vector2i) -> Array[Vector2i]:
	if not blueprint.is_walkable(from_cell) or not blueprint.is_walkable(to_cell):
		return []
	var queue: Array[Vector2i] = [from_cell]
	var came_from: Dictionary = {from_cell: from_cell}
	var head: int = 0
	while head < queue.size():
		var cur: Vector2i = queue[head]
		head += 1
		if cur == to_cell:
			var rev: Array[Vector2i] = [cur]
			var step: Vector2i = cur
			while step != from_cell:
				step = came_from[step] as Vector2i
				rev.append(step)
			rev.reverse()
			return rev
		for d: int in ScenarioBlueprint.CARDINAL_DIRS:
			var nb: Vector2i = cur + ScenarioBlueprint.dir_vec(d)
			if blueprint.is_walkable(nb) and not came_from.has(nb):
				came_from[nb] = cur
				queue.append(nb)
	return []


func is_free_for_props(cell: Vector2i) -> bool:
	var zone: int = blueprint.zone_at(cell)
	if zone != ScenarioBlueprint.ZONE_TERRACE and zone != ScenarioBlueprint.ZONE_EMBANKMENT:
		return false
	if lamps.has(cell):
		return false
	for node_id: int in node_cells.keys():
		var nc: Vector2i = node_cells[node_id]
		if absi(nc.x - cell.x) <= 2 and absi(nc.y - cell.y) <= 2:
			return false
	return true
