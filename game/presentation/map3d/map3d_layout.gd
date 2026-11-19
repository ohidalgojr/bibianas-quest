class_name Map3DLayout
extends RefCounted
## Planta do tabuleiro isométrico (TASK-036 e TASK-046, ADR-0036, ADR-0037, GDD §17 "Geração do
## tabuleiro"). Transforma o grafo do mapa numa grade de células com altura: praça por nó, ruas em S
## com degraus nos dois sentidos, relevo que sobe e desce, canais de água nos baixos, ruínas e
## casas em áreas livres, postes ao longo das ruas e enfeites. Só dados de apresentação (RefCounted,
## sem nós): o núcleo não conhece posição. Determinística: mesmo mapa e mesma semente dão a mesma
## planta, sem sorteio global (tudo sai de um hash das coordenadas).

## Células entre uma camada e a seguinte (praça de 3 células mais 2 de estrada).
const LAYER_STEP: int = 5
## Células entre colunas vizinhas.
const COLUMN_STEP: int = 4
const MARGIN: int = 9
## Altura de um bloco, igual à do `dirt.glb` do Mini Dungeon.
const BLOCK_H: float = 0.9
## Faixa de alturas das praças (em blocos); abaixo disso o terreno vira canal de água.
const MIN_PLAZA_LEVEL: int = 2
const MAX_PLAZA_LEVEL: int = 5
## Chance de enfeite por célula livre, em 1/100 (props do bioma, GDD §17 passo 4).
const PROP_CHANCE: int = 18
## Chance de uma ruína por clareira livre de 5x5, em 1/100.
const RUIN_CHANCE: int = 75
## A cada quantas células de estrada fica um poste.
const LAMP_EVERY: int = 4

var map: MapGraph
var map_seed: int = 0
var cols: int = 0
var rows: int = 0
## Altura (em blocos) de cada célula, índice `z * cols + x`.
var heights: PackedInt32Array = PackedInt32Array()
## Células de estrada e de praça (célula -> true).
var road_cells: Dictionary = {}
var plaza_cells: Dictionary = {}
## Degraus: célula (a mais baixa) -> yaw em graus; a subida aponta para o vizinho mais alto.
var stairs: Dictionary = {}
## Células de água (canais) e margens.
var water_cells: Dictionary = {}
## Enfeites: célula -> índice do prop na lista do bioma.
var props: Dictionary = {}
## Ruínas: lista de {cell: Vector2i (centro 5x5), kind: int}.
var ruins: Array[Dictionary] = []
## Postes ao longo das ruas: células.
var lamps: Array[Vector2i] = []
## Célula central de cada nó (id -> Vector2i).
var node_cells: Dictionary = {}
## Nível (altura em blocos) da praça de cada nó (id -> int).
var node_levels: Dictionary = {}


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
	_assign_node_levels()
	_fill_terrain()
	for node: MapNode in map.nodes:
		var c: Vector2i = node_cells[node.id]
		for dz: int in range(-1, 2):
			for dx: int in range(-1, 2):
				var cell: Vector2i = Vector2i(c.x + dx, c.y + dz)
				plaza_cells[cell] = true
				heights[cell.y * cols + cell.x] = int(node_levels[node.id])
	var reachable: PackedInt32Array = map.reachable_ids()
	for node: MapNode in map.nodes:
		if not reachable.has(node.id):
			continue
		for next_id: int in node.next_ids:
			_lay_road(node.id, next_id)
	_smooth_roads()
	_carve_water()
	_place_stairs()
	_place_lamps()
	_place_ruins()
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


func _hash(cell: Vector2i, salt: int = 0) -> int:
	var h: int = (cell.x * 73856093) ^ (cell.y * 19349663) ^ ((map_seed + salt) * 83492791)
	return absi(h)


## Alturas das praças por caminhada: cada camada sobe, desce ou mantém em relação à anterior, e
## cada nó ainda varia 0 ou 1 bloco. O chefe fica num platô alto.
func _assign_node_levels() -> void:
	var layer_total: int = map.layer_count + 2
	var base: int = 3
	var by_layer: Array[int] = []
	for layer: int in layer_total:
		if layer > 0:
			var roll: int = _hash(Vector2i(layer, 11), 5) % 100
			base += -1 if roll < 34 else (0 if roll < 56 else 1)
			base = clampi(base, MIN_PLAZA_LEVEL, MAX_PLAZA_LEVEL - 1)
		by_layer.append(base)
	for node: MapNode in map.nodes:
		var level: int = by_layer[node.layer]
		if node.layer > 0 and node.layer < layer_total - 1:
			level += _hash(node_cells[node.id] as Vector2i, 9) % 2
		if node.layer == layer_total - 1:
			level = MAX_PLAZA_LEVEL
		node_levels[node.id] = clampi(level, MIN_PLAZA_LEVEL, MAX_PLAZA_LEVEL)


## Relevo de fundo: média dos níveis das praças vizinhas (inverso da distância) mais ruído de
## baixa frequência, de 0 a 5 blocos. Cantos e margens afundam para virar canal.
func _fill_terrain() -> void:
	for z: int in rows:
		for x: int in cols:
			var weight_sum: float = 0.0
			var level_sum: float = 0.0
			for node: MapNode in map.nodes:
				var c: Vector2i = node_cells[node.id]
				var d: float = float(absi(c.x - x) + absi(c.y - z)) + 1.0
				var w: float = 1.0 / (d * d)
				weight_sum += w
				level_sum += w * float(int(node_levels[node.id]))
			var base: float = level_sum / weight_sum
			var coarse: Vector2i = Vector2i(x / 4, z / 4)
			var noise: int = _hash(coarse, 21) % 100
			var lift: float = -1.6 if noise < 22 else (1.0 if noise > 80 else 0.0)
			heights[z * cols + x] = clampi(int(round(base + lift)), 0, MAX_PLAZA_LEVEL + 1)


func height_at(cell: Vector2i) -> int:
	if cell.x < 0 or cell.y < 0 or cell.x >= cols or cell.y >= rows:
		return 0
	return heights[cell.y * cols + cell.x]


func _set_height(cell: Vector2i, level: int) -> void:
	heights[cell.y * cols + cell.x] = level


## Camada do mapa mais próxima da linha `z` (para a névoa por célula).
func layer_at_row(z: int) -> int:
	var layer_total: int = map.layer_count + 2
	return clampi(int(round(float(MARGIN + (layer_total - 1) * LAYER_STEP - z) / float(LAYER_STEP))), 0, layer_total - 1)


## Posição 3D do topo da célula (centro).
func world_of(cell: Vector2i) -> Vector3:
	return Vector3(float(cell.x), float(height_at(cell) + 1) * BLOCK_H, float(cell.y))


func node_world(node_id: int) -> Vector3:
	return world_of(node_cells[node_id])


## Células da estrada entre duas praças, em passos de uma célula e só em Z ou X (rua em S):
## sobe em Z até o meio, anda em X até a coluna do destino e termina em Z.
func path_cells(from_cell: Vector2i, to_cell: Vector2i) -> Array[Vector2i]:
	var found: Array[Vector2i] = [from_cell]
	var current: Vector2i = from_cell
	var mid_z: int = (from_cell.y + to_cell.y) / 2
	while current.y != mid_z:
		current.y += signi(mid_z - current.y)
		found.append(current)
	while current.x != to_cell.x:
		current.x += signi(to_cell.x - current.x)
		found.append(current)
	while current.y != to_cell.y:
		current.y += signi(to_cell.y - current.y)
		found.append(current)
	return found


func _lay_road(from_id: int, to_id: int) -> void:
	var cells: Array[Vector2i] = path_cells(node_cells[from_id], node_cells[to_id])
	var ha: int = int(node_levels[from_id])
	var hb: int = int(node_levels[to_id])
	for i: int in cells.size():
		var cell: Vector2i = cells[i]
		if plaza_cells.has(cell) or _is_inside_any_plaza(cell):
			continue
		road_cells[cell] = true
		var t: float = float(i) / float(maxi(cells.size() - 1, 1))
		_set_height(cell, int(round(lerpf(float(ha), float(hb), smoothstep(0.15, 0.85, t)))))


func _is_inside_any_plaza(cell: Vector2i) -> bool:
	for node: MapNode in map.nodes:
		var c: Vector2i = node_cells[node.id]
		if absi(c.x - cell.x) <= 1 and absi(c.y - cell.y) <= 1:
			return true
	return false


## Garante que duas células de estrada ou praça vizinhas nunca diferem mais de 1 bloco (a escada
## só vence um degrau): ajusta as estradas por passes de relaxamento.
func _smooth_roads() -> void:
	for _pass: int in 6:
		var changed: bool = false
		for cell: Vector2i in road_cells.keys():
			var h: int = height_at(cell)
			for offset: Vector2i in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
				var near: Vector2i = cell + offset
				if not (road_cells.has(near) or plaza_cells.has(near)):
					continue
				var hn: int = height_at(near)
				if h - hn > 1:
					h = hn + 1
					changed = true
				elif hn - h > 1:
					h = hn - 1
					changed = true
			_set_height(cell, h)
		if not changed:
			break


## Canais: células baixas (0 ou 1) fora de estradas e praças e com margem de uma célula viram água.
func _carve_water() -> void:
	for z: int in range(2, rows - 2):
		for x: int in range(2, cols - 2):
			var cell: Vector2i = Vector2i(x, z)
			if height_at(cell) > 1 or road_cells.has(cell) or plaza_cells.has(cell):
				continue
			if _near_walkable(cell):
				_set_height(cell, maxi(height_at(cell), 1))
				continue
			_set_height(cell, 0)
			water_cells[cell] = true


func _near_walkable(cell: Vector2i) -> bool:
	for dz: int in range(-1, 2):
		for dx: int in range(-1, 2):
			var near: Vector2i = Vector2i(cell.x + dx, cell.y + dz)
			if road_cells.has(near) or plaza_cells.has(near):
				return true
	return false


## Degrau em toda célula de estrada com vizinho de estrada ou praça um bloco mais alto; o yaw aponta
## para o vizinho mais alto (0 sobe para -Z, 90 para -X, 180 para +Z, 270 para +X).
func _place_stairs() -> void:
	var yaws: Dictionary = {Vector2i(0, -1): 0.0, Vector2i(-1, 0): 90.0, Vector2i(0, 1): 180.0, Vector2i(1, 0): 270.0}
	for cell: Vector2i in road_cells.keys():
		var h: int = height_at(cell)
		for offset: Vector2i in yaws.keys():
			var near: Vector2i = cell + offset
			if (road_cells.has(near) or plaza_cells.has(near)) and height_at(near) == h + 1:
				stairs[cell] = yaws[offset]
				break


func _place_lamps() -> void:
	var counter: int = 0
	var keys: Array = road_cells.keys()
	keys.sort_custom(func(a: Vector2i, b: Vector2i) -> bool: return a.y < b.y or (a.y == b.y and a.x < b.x))
	for cell: Vector2i in keys:
		counter += 1
		if counter % LAMP_EVERY != 0 or stairs.has(cell):
			continue
		for offset: Vector2i in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var side: Vector2i = cell + offset
			if _is_clear_ground(side):
				lamps.append(side)
				break


## Terreno livre onde cabem poste, enfeite e ruína: nem estrada, praça, degrau nem água.
func _is_clear_ground(cell: Vector2i) -> bool:
	if cell.x < 1 or cell.y < 1 or cell.x >= cols - 1 or cell.y >= rows - 1:
		return false
	return not (road_cells.has(cell) or plaza_cells.has(cell) or stairs.has(cell) or water_cells.has(cell))


## Ruínas e casas: clareiras de 5x5 sem estrada, praça, água nem desnível maior que 1.
func _place_ruins() -> void:
	var step: int = 5
	for z: int in range(MARGIN - 2, rows - 4, step):
		for x: int in range(2, cols - 4, step):
			var center: Vector2i = Vector2i(x + 2, z + 2)
			if _hash(center, 31) % 100 >= RUIN_CHANCE:
				continue
			if _clearing_is_free(center):
				ruins.append({"cell": center, "kind": _hash(center, 33) % 3})


func _clearing_is_free(center: Vector2i) -> bool:
	var h: int = height_at(center)
	for dz: int in range(-2, 3):
		for dx: int in range(-2, 3):
			var cell: Vector2i = Vector2i(center.x + dx, center.y + dz)
			if not _is_clear_ground(cell) or absi(height_at(cell) - h) > 1:
				return false
			if _near_walkable(cell):
				return false
	return true


func is_free_for_props(cell: Vector2i) -> bool:
	if not _is_clear_ground(cell):
		return false
	# Margem de uma célula em volta de estradas e praças: os destinos ficam sempre livres.
	if _near_walkable(cell):
		return false
	for ruin: Dictionary in ruins:
		var c: Vector2i = ruin["cell"]
		if absi(c.x - cell.x) <= 2 and absi(c.y - cell.y) <= 2:
			return false
	return not lamps.has(cell)


func _scatter_props() -> void:
	for z: int in rows:
		for x: int in cols:
			var cell: Vector2i = Vector2i(x, z)
			if not is_free_for_props(cell):
				continue
			var h: int = _hash(cell)
			if h % 100 < PROP_CHANCE:
				props[cell] = (h / 100) % 1000
