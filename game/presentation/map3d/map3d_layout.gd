class_name Map3DLayout
extends RefCounted
## Planta do tabuleiro isométrico (TASK-036, ADR-0036, GDD §17 "Geração do tabuleiro").
## Transforma o grafo do mapa numa grade de células com altura: praça por nó, estradas entre
## as praças, degraus onde a altura muda e props de enfeite fora das estradas. Só dados de
## apresentação (RefCounted, sem nós): o núcleo não conhece posição. Determinística: mesmo mapa e
## mesma semente dão a mesma planta, sem sorteio global (o enfeite usa um hash das coordenadas).

## Células entre uma camada e a seguinte (praça de 3 células mais 2 de estrada).
const LAYER_STEP: int = 5
## Células entre colunas vizinhas.
const COLUMN_STEP: int = 4
const MARGIN: int = 3
## Altura de um bloco, igual à do `dirt.glb` do Mini Dungeon.
const BLOCK_H: float = 0.9
## A cada quantas camadas o terreno sobe um bloco.
const LAYERS_PER_LEVEL: int = 2
## Chance de enfeite por célula livre, em 1/100 (props do bioma, GDD §17 passo 4).
const PROP_CHANCE: int = 14

var map: MapGraph
var map_seed: int = 0
var cols: int = 0
var rows: int = 0
## Altura (em blocos) de cada célula, índice `z * cols + x`.
var heights: PackedInt32Array = PackedInt32Array()
## Células de estrada e de praça (índice -> true).
var road_cells: Dictionary = {}
var plaza_cells: Dictionary = {}
## Degraus: célula -> yaw em graus; a subida aponta para as camadas seguintes.
var stairs: Dictionary = {}
## Enfeites: célula -> índice do prop na lista do bioma.
var props: Dictionary = {}
## Célula central de cada nó (id -> Vector2i).
var node_cells: Dictionary = {}


func _init(graph: MapGraph, seed_value: int) -> void:
	map = graph
	map_seed = seed_value
	_build()


func _build() -> void:
	var layer_total: int = map.layer_count + 2
	cols = (map.width - 1) * COLUMN_STEP + MARGIN * 2 + 1
	rows = (layer_total - 1) * LAYER_STEP + MARGIN * 2 + 1
	heights.resize(cols * rows)
	for node: MapNode in map.nodes:
		node_cells[node.id] = _cell_of(node)
	for z: int in rows:
		for x: int in cols:
			heights[z * cols + x] = _level_at(z)
	for node: MapNode in map.nodes:
		var c: Vector2i = node_cells[node.id]
		for dz: int in range(-1, 2):
			for dx: int in range(-1, 2):
				plaza_cells[Vector2i(c.x + dx, c.y + dz)] = true
	var reachable: PackedInt32Array = map.reachable_ids()
	for node: MapNode in map.nodes:
		if not reachable.has(node.id):
			continue
		for next_id: int in node.next_ids:
			_lay_road(node_cells[node.id], node_cells[next_id])
	_place_stairs()
	_scatter_props()


## Célula central do nó: coluna no eixo X, camada no eixo Z (a camada 0 fica no fundo da planta).
func _cell_of(node: MapNode) -> Vector2i:
	var layer_total: int = map.layer_count + 2
	var column: float = float(node.column)
	if node.layer == 0 or node.layer == layer_total - 1:
		column = float(map.width - 1) / 2.0
	var x: int = MARGIN + int(round(column * COLUMN_STEP))
	var z: int = MARGIN + (layer_total - 1 - node.layer) * LAYER_STEP
	return Vector2i(x, z)


## Altura da linha `z` da grade: a da camada mais próxima, subindo a cada LAYERS_PER_LEVEL camadas.
func _level_at(z: int) -> int:
	var layer_total: int = map.layer_count + 2
	var layer: int = clampi(int(round(float(MARGIN + (layer_total - 1) * LAYER_STEP - z) / float(LAYER_STEP))), 0, layer_total - 1)
	return layer / LAYERS_PER_LEVEL


func height_at(cell: Vector2i) -> int:
	if cell.x < 0 or cell.y < 0 or cell.x >= cols or cell.y >= rows:
		return 0
	return heights[cell.y * cols + cell.x]


## Camada do mapa mais próxima da linha `z` (para a névoa por célula).
func layer_at_row(z: int) -> int:
	var layer_total: int = map.layer_count + 2
	return clampi(int(round(float(MARGIN + (layer_total - 1) * LAYER_STEP - z) / float(LAYER_STEP))), 0, layer_total - 1)


## Posição 3D do topo da célula (centro).
func world_of(cell: Vector2i) -> Vector3:
	return Vector3(float(cell.x), float(height_at(cell) + 1) * BLOCK_H, float(cell.y))


func node_world(node_id: int) -> Vector3:
	return world_of(node_cells[node_id])


## Células da estrada entre duas praças, em passos de uma célula (diagonal quando precisa).
func path_cells(from_cell: Vector2i, to_cell: Vector2i) -> Array[Vector2i]:
	var found: Array[Vector2i] = [from_cell]
	var current: Vector2i = from_cell
	while current != to_cell:
		current.x += signi(to_cell.x - current.x)
		current.y += signi(to_cell.y - current.y)
		found.append(current)
	return found


func _lay_road(a: Vector2i, b: Vector2i) -> void:
	for cell: Vector2i in path_cells(a, b):
		if not plaza_cells.has(cell):
			road_cells[cell] = true


## Degrau onde a estrada passa de uma altura para outra (a célula mais baixa vira escada).
func _place_stairs() -> void:
	for cell: Vector2i in road_cells.keys():
		var h: int = height_at(cell)
		var up: Vector2i = Vector2i(cell.x, cell.y - 1)
		if road_cells.has(up) and height_at(up) == h + 1:
			stairs[cell] = 0.0


func is_free_for_props(cell: Vector2i) -> bool:
	if cell.x < 1 or cell.y < 1 or cell.x >= cols - 1 or cell.y >= rows - 1:
		return false
	if road_cells.has(cell) or plaza_cells.has(cell) or stairs.has(cell):
		return false
	# Margem de uma célula em volta de estradas e praças: os destinos ficam sempre livres.
	for dz: int in range(-1, 2):
		for dx: int in range(-1, 2):
			var near: Vector2i = Vector2i(cell.x + dx, cell.y + dz)
			if road_cells.has(near) or plaza_cells.has(near):
				return false
	return true


func _hash(cell: Vector2i) -> int:
	var h: int = (cell.x * 73856093) ^ (cell.y * 19349663) ^ (map_seed * 83492791)
	return absi(h)


func _scatter_props() -> void:
	for z: int in rows:
		for x: int in cols:
			var cell: Vector2i = Vector2i(x, z)
			if not is_free_for_props(cell):
				continue
			var h: int = _hash(cell)
			if h % 100 < PROP_CHANCE:
				props[cell] = (h / 100) % 1000
