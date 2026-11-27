class_name ScenarioGenerator
extends RefCounted
## Algoritmo próprio de geração coerente de cenários 3D (ADR-0041, ADR-0060, TASK-053, TASK-073).
## O tabuleiro do mapa é uma **cidade gótica** que sobe até a igreja: a rua principal avança na
## diagonal da câmera (a igreja pintada fica sempre no topo da tela), praças de nó viram lugares
## (abrigo da fogueira, campo-santo do evento, casa em ruínas do baú), casas de empena ficam com a
## porta voltada para a rua, escadas ligam os níveis e o chefe fica no ponto mais alto, no adro,
## diante do portão da igreja. Também gera os 11 dioramas focais (combate, fogueira, loja, baú,
## evento, recompensa, menu, vitória, derrota), tudo 100% determinístico por semente.

const LAYER_STEP: int = 8
const COLUMN_STEP: int = 6
const MARGIN: int = 8
## A cada camada o tabuleiro avança LAYER_STEP em -Z e NORTH_SHEAR em -X: na câmera isométrica
## (olhando de +X +Z para -X -Z) isso é "reto para cima", rumo à igreja pintada do horizonte.
const NORTH_SHEAR: int = LAYER_STEP
## Meia largura (em células) da cidade ao redor de cada camada e do adro do chefe.
const CITY_HALF_WIDTH: int = 6
const PRECINCT_HALF_WIDTH: int = 9
const FOCAL_SIZE: int = 13
const FOCAL_OFFSET: Vector2i = Vector2i(-6, -6)
## Altura (em unidades de mundo) abaixo da qual uma parede não esconde a rua atrás dela na
## câmera isométrica (cada passo diagonal sobe 0,82 do raio da câmera).
const LOW_WALL_H: float = 0.72
const TALL_WALL_H: float = 2.2


static func generate_map(graph: MapGraph, seed_value: int) -> ScenarioBlueprint:
	var bp: ScenarioBlueprint = ScenarioBlueprint.new()
	bp.layer_count = graph.layer_count
	bp.layer_step = LAYER_STEP
	bp.column_step = COLUMN_STEP
	bp.margin = MARGIN
	var layer_total: int = graph.layer_count + 2
	var cols: int = (graph.width - 1) * COLUMN_STEP + (layer_total - 1) * NORTH_SHEAR + MARGIN * 2 + 1
	var rows: int = (layer_total - 1) * LAYER_STEP + MARGIN * 2 + 1
	bp.configure(cols, rows, seed_value)

	for node: MapNode in graph.nodes:
		bp.node_cells[node.id] = _cell_of_node(node, graph)
	bp.boss_cell = bp.node_cells[graph.boss_id] as Vector2i

	_assign_node_levels(bp, graph)
	_sculpt_map_silhouette(bp, graph)
	_stamp_plazas(bp, graph)
	_prepare_boss_approach(bp, graph)
	_route_streets(bp, graph)
	_mark_main_road(bp, graph)
	_smooth_roads_and_promote_landings(bp)
	_place_stairs(bp)
	_shape_terrain_from_streets(bp)
	_carve_canal_and_bridges(bp)
	_build_boss_precinct(bp)
	_place_lamps(bp, true)
	var reserved: Dictionary = _reserve_existing(bp)
	_dress_node_plazas(bp, graph, reserved)
	_place_city_gate(bp, graph, reserved)
	_place_street_houses(bp, reserved)
	_place_lamps(bp, false, true)
	_build_retaining_wall_runs(bp)
	_place_contextual_props(bp)
	return bp


static func generate_focal_diorama(kind: String, seed_value: int = 7) -> ScenarioBlueprint:
	var bp: ScenarioBlueprint = ScenarioBlueprint.new()
	bp.is_focal = true
	bp.origin_offset = FOCAL_OFFSET
	bp.base_cliff_level = -2
	bp.configure(FOCAL_SIZE, FOCAL_SIZE, seed_value)

	# Estágio 0: silhueta orgânica recortada de diorama isométrico (cantos removidos).
	for gz: int in FOCAL_SIZE:
		for gx: int in FOCAL_SIZE:
			var cell: Vector2i = Vector2i(gx, gz)
			var lx: int = gx + FOCAL_OFFSET.x
			var lz: int = gz + FOCAL_OFFSET.y
			var corner_dist: int = absi(lx) + absi(lz)
			if corner_dist > 10 or (lx == 6 and lz >= 5) or (lz == 6 and lx >= 5):
				bp.set_zone(cell, ScenarioBlueprint.ZONE_VOID)
				bp.set_height(cell, -2)
			else:
				bp.set_zone(cell, ScenarioBlueprint.ZONE_TERRACE)
				bp.set_height(cell, 0)

	# Arena / pátio principal em x in [-2..3], z in [-2..3] no nível 0 (y_top = 0.9).
	for lz: int in range(-2, 4):
		for lx: int in range(-2, 4):
			var c: Vector2i = _fcell(lx, lz)
			if bp.in_bounds(c) and bp.zone_at(c) != ScenarioBlueprint.ZONE_VOID:
				bp.set_height(c, 0)
				bp.set_zone(c, ScenarioBlueprint.ZONE_PLAZA)
				bp.plaza_cells[c] = true

	# Terraço traseiro elevado ao fundo (-Z e -X), enquadrando sem bloquear a câmera (+X, +Z).
	for lz: int in range(-6, -2):
		for lx: int in range(-6, 5):
			var c: Vector2i = _fcell(lx, lz)
			if bp.zone_at(c) != ScenarioBlueprint.ZONE_VOID and not bp.plaza_cells.has(c):
				var elev: int = 2 if lz <= -5 and lx <= 1 else 1
				bp.set_height(c, elev)
	for lz: int in range(-2, 4):
		for lx: int in range(-6, -2):
			var c: Vector2i = _fcell(lx, lz)
			if bp.zone_at(c) != ScenarioBlueprint.ZONE_VOID and not bp.plaza_cells.has(c):
				bp.set_height(c, 1)

	# Escada real ligando o terraço norte (z = -3, nível 1) ao pátio (z = -2, nível 0) em lx = 3,
	# deixando [-4..1] × [-4..-3] totalmente livre para compostos enquadrados na câmera de combate.
	var stair_top: Vector2i = _fcell(3, -3)
	if kind != "combat_elite" and kind != "shop":
		bp.set_zone(stair_top, ScenarioBlueprint.ZONE_ROAD)
		bp.set_height(stair_top, 0)
		bp.road_cells[stair_top] = true
		bp.stairs[stair_top] = ScenarioBlueprint.dir_yaw(ScenarioBlueprint.DIR_N)
		var terrace_path: Vector2i = _fcell(3, -4)
		if bp.zone_at(terrace_path) != ScenarioBlueprint.ZONE_VOID:
			bp.set_zone(terrace_path, ScenarioBlueprint.ZONE_ROAD)
			bp.set_height(terrace_path, 1)
			bp.road_cells[terrace_path] = true

	_populate_focal_kind(bp, kind)
	_build_retaining_wall_runs(bp, false)
	return bp


static func _fcell(lx: int, lz: int) -> Vector2i:
	return Vector2i(lx - FOCAL_OFFSET.x, lz - FOCAL_OFFSET.y)


static func _populate_focal_kind(bp: ScenarioBlueprint, kind: String) -> void:
	match kind:
		"combat_boss":
			_add_focal_compound(bp, "focal_boss", ScenarioBlueprint.COMPOUND_BOSS_MAUSOLEUM, Vector2i(-4, -4), Vector2i(5, 2), 1, ScenarioBlueprint.DIR_S)
			_add_focal_lamp(bp, Vector2i(-3, -2), Vector2i(-2, -2), true)
			_add_focal_prop(bp, Vector2i(-3, 2), ScenarioBlueprint.PROP_BRAZIER, "graveyard/fire-basket.glb", 0.0, 2.0, "focal_stage")
			_add_focal_prop(bp, Vector2i(4, -2), ScenarioBlueprint.PROP_OBELISK, "graveyard/pillar-obelisk.glb", 0.0, 1.35, "focal_terrace")
			_add_focal_prop(bp, Vector2i(4, 1), ScenarioBlueprint.PROP_ROCK, "graveyard/rocks.glb", 90.0, 1.15, "focal_terrace")
			bp.focal_lights.append({"pos": Vector3(0.0, 2.2, 0.2), "color": Color(1.0, 0.34, 0.16), "energy": 3.4, "range_": 7.5})
		"combat_elite":
			_add_focal_compound(bp, "focal_elite_cem", ScenarioBlueprint.COMPOUND_CEMETERY, Vector2i(-3, -4), Vector2i(4, 2), 1, ScenarioBlueprint.DIR_S)
			_add_focal_lamp(bp, Vector2i(-3, 0), Vector2i(-2, 0), true)
			_add_focal_prop(bp, Vector2i(4, -2), ScenarioBlueprint.PROP_TRUNK, "graveyard/trunk-long.glb", 35.0, 1.25, "focal_terrace", Color(0.36, 0.34, 0.35))
			_add_focal_prop(bp, Vector2i(4, 1), ScenarioBlueprint.PROP_ROCK_TALL, "graveyard/rocks-tall.glb", 0.0, 1.15, "focal_terrace")
			_add_focal_prop(bp, Vector2i(-3, 3), ScenarioBlueprint.PROP_STONES, "mini_dungeon/stones.glb", 90.0, 1.2, "focal_terrace")
			bp.focal_lights.append({"pos": Vector3(0.2, 2.0, 0.2), "color": Color(1.0, 0.56, 0.24), "energy": 2.9, "range_": 7.0})
		"combat_common":
			_add_focal_compound(bp, "focal_common_ruin", ScenarioBlueprint.COMPOUND_WATCHTOWER, Vector2i(-2, -4), Vector2i(3, 2), 1, ScenarioBlueprint.DIR_S)
			_add_focal_lamp(bp, Vector2i(-3, 1), Vector2i(-2, 1), true)
			_add_focal_prop(bp, Vector2i(-3, -4), ScenarioBlueprint.PROP_BARREL, "mini_dungeon/barrel.glb", 20.0, 1.3, "focal_building")
			_add_focal_prop(bp, Vector2i(4, -2), ScenarioBlueprint.PROP_TRUNK, "graveyard/trunk-long.glb", 15.0, 1.2, "focal_terrace", Color(0.36, 0.34, 0.35))
			_add_focal_prop(bp, Vector2i(4, 1), ScenarioBlueprint.PROP_ROCK, "graveyard/rocks.glb", 180.0, 1.15, "focal_terrace")
			_add_focal_prop(bp, Vector2i(-3, 3), ScenarioBlueprint.PROP_DEBRIS, "graveyard/debris.glb", 45.0, 1.3, "focal_terrace")
			bp.focal_lights.append({"pos": Vector3(0.2, 1.8, 0.4), "color": Color(1.0, 0.58, 0.25), "energy": 2.8, "range_": 6.8})
		"home":
			_add_focal_compound(bp, "focal_home_chapel", ScenarioBlueprint.COMPOUND_CHAPEL, Vector2i(-3, -6), Vector2i(4, 3), 1, ScenarioBlueprint.DIR_S)
			_add_focal_lamp(bp, Vector2i(4, 0), Vector2i(3, 0), true)
			_add_focal_prop(bp, Vector2i(-4, -2), ScenarioBlueprint.PROP_TRUNK, "graveyard/trunk-long.glb", 20.0, 1.25, "focal_terrace", Color(0.36, 0.34, 0.35))
			_add_focal_prop(bp, Vector2i(-5, -2), ScenarioBlueprint.PROP_ROCK, "graveyard/rocks.glb", 40.0, 1.15, "focal_terrace")
			_add_focal_prop(bp, Vector2i(4, -2), ScenarioBlueprint.PROP_ROCK_TALL, "graveyard/rocks-tall.glb", 0.0, 1.15, "focal_terrace")
			_add_focal_prop(bp, Vector2i(4, 2), ScenarioBlueprint.PROP_STONES, "mini_dungeon/stones.glb", 90.0, 1.2, "focal_terrace")
			_add_focal_prop(bp, Vector2i(-4, 2), ScenarioBlueprint.PROP_BENCH, "graveyard/bench-damaged.glb", 90.0, 1.25, "focal_terrace")
			bp.focal_lights.append({"pos": Vector3(0.5, 2.3, -1.0), "color": Color(1.0, 0.68, 0.32), "energy": 3.4, "range_": 7.5})
		"campfire":
			_add_focal_compound(bp, "focal_camp_shelter", ScenarioBlueprint.COMPOUND_COURTYARD_RUIN, Vector2i(-3, -4), Vector2i(3, 2), 1, ScenarioBlueprint.DIR_S)
			_add_focal_prop(bp, Vector2i(-4, 0), ScenarioBlueprint.PROP_BENCH, "graveyard/bench.glb", 90.0, 1.35, "focal_terrace")
			_add_focal_prop(bp, Vector2i(-4, -1), ScenarioBlueprint.PROP_BARREL, "mini_dungeon/barrel.glb", 0.0, 1.4, "focal_terrace")
			_add_focal_prop(bp, Vector2i(4, -2), ScenarioBlueprint.PROP_TRUNK, "graveyard/trunk.glb", 45.0, 1.25, "focal_terrace", Color(0.36, 0.34, 0.35))
			_add_focal_prop(bp, Vector2i(4, 1), ScenarioBlueprint.PROP_ROCK, "graveyard/rocks.glb", 0.0, 1.2, "focal_terrace")
			bp.focal_lights.append({"pos": Vector3(0.0, 1.5, 0.0), "color": Color(1.0, 0.45, 0.15), "energy": 6.2, "range_": 8.0})
		"shop":
			_add_focal_compound(bp, "focal_shop_stall", ScenarioBlueprint.COMPOUND_WATCHTOWER, Vector2i(-4, -5), Vector2i(3, 3), 1, ScenarioBlueprint.DIR_S)
			_add_focal_lamp(bp, Vector2i(4, -2), Vector2i(3, -2), true)
			_add_focal_prop(bp, Vector2i(-3, 0), ScenarioBlueprint.PROP_BARREL, "mini_dungeon/barrel.glb", 15.0, 1.8, "focal_shop")
			_add_focal_prop(bp, Vector2i(-4, 1), ScenarioBlueprint.PROP_DEBRIS_WOOD, "graveyard/debris-wood.glb", 0.0, 1.4, "focal_shop")
			_add_focal_prop(bp, Vector2i(4, 1), ScenarioBlueprint.PROP_ROCK, "graveyard/rocks.glb", 90.0, 1.15, "focal_terrace")
			bp.focal_lights.append({"pos": Vector3(0.0, 2.2, -1.2), "color": Color(1.0, 0.72, 0.36), "energy": 3.8, "range_": 7.0})
		"chest":
			_add_focal_compound(bp, "focal_chest_vault", ScenarioBlueprint.COMPOUND_WATCHTOWER, Vector2i(-3, -6), Vector2i(3, 3), 1, ScenarioBlueprint.DIR_S)
			_add_focal_lamp(bp, Vector2i(4, 0), Vector2i(3, 0), true)
			_add_focal_prop(bp, Vector2i(-3, 2), ScenarioBlueprint.PROP_CANDLE, "graveyard/candle-multiple.glb", 0.0, 1.8, "focal_plaza_edge")
			_add_focal_prop(bp, Vector2i(4, 0), ScenarioBlueprint.PROP_STONES, "mini_dungeon/stones.glb", 0.0, 1.2, "focal_terrace")
			bp.focal_lights.append({"pos": Vector3(0.0, 1.9, 0.0), "color": Color(1.0, 0.8, 0.3), "energy": 5.0, "range_": 6.5})
		"event":
			_add_focal_compound(bp, "focal_event_shrine", ScenarioBlueprint.COMPOUND_SHRINE, Vector2i(-2, -5), Vector2i(2, 2), 1, ScenarioBlueprint.DIR_S)
			_add_focal_prop(bp, Vector2i(-4, -2), ScenarioBlueprint.PROP_OBELISK, "graveyard/pillar-obelisk.glb", 0.0, 1.6, "focal_terrace")
			_add_focal_prop(bp, Vector2i(4, -2), ScenarioBlueprint.PROP_OBELISK, "graveyard/pillar-obelisk.glb", 0.0, 1.6, "focal_terrace")
			_add_focal_prop(bp, Vector2i(-4, 2), ScenarioBlueprint.PROP_ROCK, "graveyard/rocks.glb", 90.0, 1.15, "focal_terrace")
			bp.focal_lights.append({"pos": Vector3(-0.3, 2.2, -0.7), "color": Color(1.0, 0.6, 0.3), "energy": 3.8, "range_": 6.5})
		"reward", "victory":
			_add_focal_compound(bp, "focal_reward_shrine", ScenarioBlueprint.COMPOUND_SHRINE, Vector2i(-3, -5), Vector2i(2, 2), 1, ScenarioBlueprint.DIR_S)
			_add_focal_lamp(bp, Vector2i(-3, 0), Vector2i(-2, 0), true)
			_add_focal_prop(bp, Vector2i(4, -1), ScenarioBlueprint.PROP_STONES, "mini_dungeon/stones.glb", 90.0, 1.2, "focal_terrace")
			bp.focal_lights.append({"pos": Vector3(0.0, 2.2, 0.2), "color": Color(1.0, 0.74, 0.34), "energy": 4.2, "range_": 6.8})
		"defeat":
			_add_focal_compound(bp, "focal_defeat_cem", ScenarioBlueprint.COMPOUND_CEMETERY, Vector2i(-3, -4), Vector2i(4, 2), 1, ScenarioBlueprint.DIR_S)
			_add_focal_prop(bp, Vector2i(-3, 2), ScenarioBlueprint.PROP_DEBRIS, "graveyard/debris.glb", 0.0, 1.3, "focal_terrace")
			_add_focal_prop(bp, Vector2i(4, 0), ScenarioBlueprint.PROP_TRUNK, "graveyard/trunk-long.glb", 0.0, 1.25, "focal_terrace", Color(0.36, 0.34, 0.35))
			bp.focal_lights.append({"pos": Vector3(-0.6, 1.5, -0.9), "color": Color(0.7, 0.8, 1.0), "energy": 1.8, "range_": 5.5})
		_:
			pass


static func _add_focal_compound(bp: ScenarioBlueprint, cid: String, kind: int, local_origin: Vector2i, sz: Vector2i, pad_h: int, door_dir: int) -> void:
	var origin: Vector2i = _fcell(local_origin.x, local_origin.y)
	var cells: Array[Vector2i] = []
	var zone_type: int = ScenarioBlueprint.ZONE_COURTYARD if kind == ScenarioBlueprint.COMPOUND_CEMETERY or kind == ScenarioBlueprint.COMPOUND_COURTYARD_RUIN else ScenarioBlueprint.ZONE_BUILDING
	for dz: int in sz.y:
		for dx: int in sz.x:
			var cell: Vector2i = origin + Vector2i(dx, dz)
			if not bp.in_bounds(cell) or bp.zone_at(cell) == ScenarioBlueprint.ZONE_VOID or bp.is_walkable(cell):
				return
			cells.append(cell)
	for cell: Vector2i in cells:
		bp.set_height(cell, pad_h)
		bp.set_zone(cell, zone_type)
	bp.compounds.append({
		"id": cid,
		"kind": kind,
		"origin": origin,
		"size": sz,
		"center": origin + Vector2i(sz.x / 2, sz.y / 2),
		"height": pad_h,
		"door_dir": door_dir,
		"cells": cells,
		"tall": ScenarioBlueprint.is_tall_compound(kind),
	})


static func _add_focal_lamp(bp: ScenarioBlueprint, local_cell: Vector2i, local_road_cell: Vector2i, lit: bool) -> void:
	var cell: Vector2i = _fcell(local_cell.x, local_cell.y)
	var road_cell: Vector2i = _fcell(local_road_cell.x, local_road_cell.y)
	if not bp.is_solid(cell) or not bp.is_walkable(road_cell):
		return
	var h: int = bp.height_at(road_cell)
	bp.set_height(cell, h)
	bp.set_zone(cell, ScenarioBlueprint.ZONE_EMBANKMENT)
	var d: int = ScenarioBlueprint.dir_from_vec(road_cell - cell)
	if d < 0:
		return
	var yaw: float = ScenarioBlueprint.dir_yaw(ScenarioBlueprint.dir_opposite(d))
	bp.lamps.append({"cell": cell, "road_cell": road_cell, "yaw": yaw, "height": h, "lit": lit})


static func _add_focal_prop(bp: ScenarioBlueprint, local_cell: Vector2i, kind: int, asset: String, yaw: float, scale_f: float, context: String, tint: Color = Color(0.80, 0.78, 0.76)) -> void:
	var cell: Vector2i = _fcell(local_cell.x, local_cell.y)
	if not bp.is_solid(cell) or bp.is_walkable(cell):
		return
	var z: int = bp.zone_at(cell)
	if z == ScenarioBlueprint.ZONE_BUILDING or z == ScenarioBlueprint.ZONE_COURTYARD or z == ScenarioBlueprint.ZONE_WATER:
		return
	for lamp: Dictionary in bp.lamps:
		if (lamp["cell"] as Vector2i) == cell:
			return
	bp.typed_props[cell] = {
		"kind": kind,
		"asset": asset,
		"yaw": yaw,
		"scale": scale_f,
		"tint": tint,
		"context": context,
	}


static func _cell_of_node(node: MapNode, graph: MapGraph) -> Vector2i:
	var layer_total: int = graph.layer_count + 2
	var column: float = float(node.column)
	if node.layer == 0 or node.layer == layer_total - 1:
		column = float(graph.width - 1) / 2.0
	var behind: int = layer_total - 1 - node.layer
	var x: int = MARGIN + behind * NORTH_SHEAR + int(round(column * float(COLUMN_STEP)))
	var z: int = MARGIN + behind * LAYER_STEP
	return Vector2i(x, z)


## Linha (em Z) de uma camada do grafo.
static func layer_row(bp: ScenarioBlueprint, layer: int) -> int:
	return bp.margin + (bp.layer_count + 1 - layer) * bp.layer_step


## Estágio 1: níveis por camada. A cidade sobe em rampa até o adro do chefe (nível 5) e há um
## único desnível para baixo (`canal_layer`), onde o canal corta a cidade e as ruas descem até a
## ponte. Todos os nós de uma camada ficam no mesmo socalco.
static func _assign_node_levels(bp: ScenarioBlueprint, graph: MapGraph) -> void:
	var layer_total: int = graph.layer_count + 2
	var real_last: int = layer_total - 2
	var lv: Array[int] = []
	for layer: int in layer_total:
		var ramp: float = 2.0 + 2.0 * float(layer) / float(maxi(real_last, 1))
		lv.append(clampi(int(round(ramp)), ScenarioBlueprint.MIN_PLAZA_LEVEL, ScenarioBlueprint.MAX_PLAZA_LEVEL - 1))
	lv[real_last] = ScenarioBlueprint.MAX_PLAZA_LEVEL - 1
	lv[layer_total - 1] = ScenarioBlueprint.MAX_PLAZA_LEVEL

	# Desnível único: o canal. Nunca na primeira camada nem na última antes do chefe.
	var candidates: Array[int] = []
	for layer: int in range(2, layer_total - 2):
		candidates.append(layer)
	var dip: int = candidates[_hash(bp.map_seed, Vector2i(layer_total, 3), 5) % candidates.size()]
	lv[dip - 1] = maxi(lv[dip - 1], ScenarioBlueprint.MIN_PLAZA_LEVEL + 1)
	lv[dip] = lv[dip - 1] - 1
	# Nenhum degrau entre camadas maior que 2 (a escada dupla já é o limite legível).
	for _pass: int in 3:
		for layer: int in range(1, layer_total - 1):
			if layer == dip:
				continue
			lv[layer] = clampi(lv[layer], lv[layer - 1] - 2, lv[layer - 1] + 2)
		for layer: int in range(layer_total - 3, 0, -1):
			if layer == dip:
				continue
			lv[layer] = clampi(lv[layer], lv[layer + 1] - 2, lv[layer + 1] + 2)
	lv[dip] = mini(lv[dip], lv[dip - 1] - 1)
	bp.canal_layer = dip
	for node: MapNode in graph.nodes:
		bp.node_levels[node.id] = lv[node.layer]


## Estágio 0: a silhueta da cidade é uma faixa diagonal que acompanha a rua principal (camada a
## camada, em degraus de LAYER_STEP). O resto é VOID. O adro do chefe é mais largo e comprido, e a
## partida tem um trecho extra ao sul para a estrada de chegada.
static func _sculpt_map_silhouette(bp: ScenarioBlueprint, graph: MapGraph) -> void:
	var row_min: PackedInt32Array = PackedInt32Array()
	var row_max: PackedInt32Array = PackedInt32Array()
	row_min.resize(bp.rows)
	row_max.resize(bp.rows)
	row_min.fill(bp.cols)
	row_max.fill(-1)
	for node: MapNode in graph.nodes:
		var c: Vector2i = bp.node_cells[node.id]
		var half: int = CITY_HALF_WIDTH
		var up: int = LAYER_STEP / 2
		var down: int = LAYER_STEP / 2 - 1
		if node.kind == MapNode.Kind.BOSS:
			half = PRECINCT_HALF_WIDTH
			up = 10
		elif node.kind == MapNode.Kind.START:
			down = 6
		for z: int in range(c.y - up, c.y + down + 1):
			if z < 1 or z > bp.rows - 2:
				continue
			row_min[z] = mini(row_min[z], maxi(1, c.x - half))
			row_max[z] = maxi(row_max[z], mini(bp.cols - 2, c.x + half))
	for z: int in bp.rows:
		for x: int in bp.cols:
			var cell: Vector2i = Vector2i(x, z)
			if x < row_min[z] or x > row_max[z]:
				bp.set_zone(cell, ScenarioBlueprint.ZONE_VOID)
				bp.set_height(cell, 0)
			else:
				bp.set_zone(cell, ScenarioBlueprint.ZONE_TERRACE)
				bp.set_height(cell, ScenarioBlueprint.MIN_PLAZA_LEVEL)


static func _stamp_plazas(bp: ScenarioBlueprint, graph: MapGraph) -> void:
	for node: MapNode in graph.nodes:
		var nc: Vector2i = bp.node_cells[node.id]
		var level: int = int(bp.node_levels[node.id])
		for dz: int in range(-1, 2):
			for dx: int in range(-1, 2):
				var cell: Vector2i = Vector2i(nc.x + dx, nc.y + dz)
				bp.set_zone(cell, ScenarioBlueprint.ZONE_PLAZA)
				bp.set_height(cell, level)
				bp.plaza_cells[cell] = true


## A escadaria monumental do chefe: 3 células de largura, patamar de duas linhas e um degrau até a
## praça do chefe (nível 5). Todas as ruas que chegam ao chefe desembocam nela.
static func _prepare_boss_approach(bp: ScenarioBlueprint, _graph: MapGraph) -> void:
	var b: Vector2i = bp.boss_cell
	var landing: int = ScenarioBlueprint.MAX_PLAZA_LEVEL - 1
	for dz: int in range(2, 5):
		for dx: int in range(-1, 2):
			var cell: Vector2i = Vector2i(b.x + dx, b.y + dz)
			if not bp.is_solid(cell):
				continue
			bp.road_cells[cell] = true
			bp.set_zone(cell, ScenarioBlueprint.ZONE_ROAD)
			bp.set_height(cell, landing)


## Linha da rua transversal ("travessa") de cada intervalo entre camadas: uma por intervalo, para
## que as ruas formem pentes limpos. O intervalo do canal usa a linha junto à praça de saída.
static func _bus_offset(bp: ScenarioBlueprint, from_layer: int) -> int:
	if from_layer == bp.canal_layer - 1:
		return -2
	var options: Array[int] = [-2, -3, -4]
	return options[_hash(bp.map_seed, Vector2i(from_layer, 17), 19) % options.size()]


## Rua em Z: sobe da praça de origem até a travessa, corre ao longo dela até a coluna da praça de
## destino e sobe de novo. Ruas que saem do mesmo nó dividem o tronco e viram bifurcações em T.
static func _street_path(start: Vector2i, goal: Vector2i, bus_z: int) -> Array[Vector2i]:
	var path: Array[Vector2i] = [start]
	var cur: Vector2i = start
	while cur.y != bus_z:
		cur.y += signi(bus_z - cur.y)
		path.append(cur)
	while cur.x != goal.x:
		cur.x += signi(goal.x - cur.x)
		path.append(cur)
	while cur.y != goal.y:
		cur.y += signi(goal.y - cur.y)
		path.append(cur)
	return path


## Estágio 2A: ruas de cada aresta do grafo. A altura da rua é o patamar de origem até o último
## trecho junto à praça mais alta (a escada fica colada na praça: "degrau diante da praça").
static func _route_streets(bp: ScenarioBlueprint, graph: MapGraph) -> void:
	# Todas as arestas viram rua, inclusive as de praças que a partida não alcança: elas são "praças
	# de bairro" ligadas à travessa, nunca ilhas soltas.
	for node: MapNode in graph.nodes:
		for next_id: int in node.next_ids:
			var start: Vector2i = bp.node_cells[node.id]
			var goal: Vector2i = bp.node_cells[next_id]
			var path: Array[Vector2i] = _street_path(start, goal, start.y + _bus_offset(bp, node.layer))
			bp.edge_paths["%d:%d" % [node.id, next_id]] = path
			var ha: int = int(bp.node_levels[node.id])
			var hb: int = int(bp.node_levels[next_id])
			var road_total: int = 0
			for cell: Vector2i in path:
				if not bp.plaza_cells.has(cell):
					road_total += 1
			var road_idx: int = 0
			for cell: Vector2i in path:
				if bp.plaza_cells.has(cell):
					continue
				var h: int = ha
				if hb > ha:
					h = maxi(ha, hb - 1 - (road_total - 1 - road_idx))
				elif ha > hb:
					h = maxi(hb, ha - 1 - road_idx)
				road_idx += 1
				if not bp.road_cells.has(cell):
					bp.road_cells[cell] = true
					bp.set_zone(cell, ScenarioBlueprint.ZONE_ROAD)
					bp.set_height(cell, clampi(h, ScenarioBlueprint.MIN_PLAZA_LEVEL, ScenarioBlueprint.MAX_PLAZA_LEVEL))


## A rua principal liga a partida ao chefe pelas colunas mais centrais (a "via sacra" da cidade):
## recebe os postes primeiro e o lajeado mais claro.
static func _mark_main_road(bp: ScenarioBlueprint, graph: MapGraph) -> void:
	bp.main_road.clear()
	var middle: float = float(graph.width - 1) / 2.0
	var id: int = graph.start_id
	var guard: int = 0
	while id != graph.boss_id and guard < 64:
		guard += 1
		var node: MapNode = graph.node_by_id(id)
		var best: int = -1
		var best_dist: float = 99.0
		for next_id: int in node.next_ids:
			var other: MapNode = graph.node_by_id(next_id)
			var dist: float = absf(float(other.column) - middle)
			if other.kind == MapNode.Kind.BOSS:
				dist = 0.0
			if dist < best_dist:
				best_dist = dist
				best = next_id
		if best < 0:
			break
		var key: String = "%d:%d" % [id, best]
		if bp.edge_paths.has(key):
			for raw: Variant in bp.edge_paths[key]:
				bp.main_road[raw as Vector2i] = true
		id = best


## Estágio 1B: o terreno nasce das ruas. Cada lote tem a altura da rua mais próxima (casa rente à
## rua, sem degrau), os fundos descem e a borda da cidade cai em arrimo. Nada acima da rua fica
## na diagonal da câmera (esconderia a rua), como na regra do cone de oclusão.
static func _shape_terrain_from_streets(bp: ScenarioBlueprint) -> void:
	var dist: Dictionary = {}
	var source_h: Dictionary = {}
	var queue: Array[Vector2i] = []
	for cell: Vector2i in _sorted_cells(bp.road_cells):
		dist[cell] = 0
		source_h[cell] = bp.height_at(cell)
		queue.append(cell)
	for cell: Vector2i in _sorted_cells(bp.plaza_cells):
		dist[cell] = 0
		source_h[cell] = bp.height_at(cell)
		queue.append(cell)
	var head: int = 0
	while head < queue.size():
		var cur: Vector2i = queue[head]
		head += 1
		for d: int in ScenarioBlueprint.CARDINAL_DIRS:
			var nb: Vector2i = cur + ScenarioBlueprint.dir_vec(d)
			if not bp.is_solid(nb) or dist.has(nb):
				continue
			dist[nb] = int(dist[cur]) + 1
			source_h[nb] = source_h[cur]
			queue.append(nb)
	for z: int in bp.rows:
		for x: int in bp.cols:
			var cell: Vector2i = Vector2i(x, z)
			if bp.zone_at(cell) != ScenarioBlueprint.ZONE_TERRACE:
				continue
			var h: int = int(source_h.get(cell, ScenarioBlueprint.MIN_PLAZA_LEVEL))
			if int(dist.get(cell, 0)) >= 6:
				h -= 1
			if _touches_void(bp, cell):
				h -= 1
			bp.set_height(cell, clampi(h, 1, ScenarioBlueprint.MAX_PLAZA_LEVEL))
	for source: Dictionary in [bp.road_cells, bp.plaza_cells]:
		for w: Vector2i in _sorted_cells(source):
			var wh: int = bp.height_at(w)
			for k: int in range(1, 3):
				var c: Vector2i = w + Vector2i(k, k)
				if bp.zone_at(c) == ScenarioBlueprint.ZONE_TERRACE and bp.height_at(c) > wh + k - 1:
					bp.set_height(c, wh + k - 1)


## Células que uma parede alta esconderia na câmera isométrica: a diagonal sudeste (+X +Z) de
## qualquer célula caminhável (2 passos: o raio da câmera sobe 0,82 por passo e a casa alta tem
## cerca de 2,3). Paredes altas só ficam fora desse conjunto; a casa baixa (cerca de 1,5) só esconde
## o primeiro passo (`max_k` = 1) e as ruínas (0,72) cabem em qualquer lugar.
static func occluding_cells(bp: ScenarioBlueprint, max_k: int = 2) -> Dictionary:
	var hidden: Dictionary = {}
	for source: Dictionary in [bp.road_cells, bp.plaza_cells]:
		for w: Vector2i in source.keys():
			for k: int in range(1, max_k + 1):
				hidden[w + Vector2i(k, k)] = true
	return hidden


## Estágio 3: o canal. Corta a cidade de lado a lado no intervalo em que as ruas descem, e cada
## rua que o cruza vira ponte (2 células). Margens em arrimo (EMBANKMENT), nada de poças soltas.
static func _carve_canal_and_bridges(bp: ScenarioBlueprint) -> void:
	bp.water_cells.clear()
	bp.bridge_cells.clear()
	if bp.canal_layer < 1:
		return
	var base_z: int = layer_row(bp, bp.canal_layer)
	for z: int in [base_z + 3, base_z + 4]:
		for x: int in range(1, bp.cols - 1):
			var c: Vector2i = Vector2i(x, z)
			if bp.zone_at(c) == ScenarioBlueprint.ZONE_VOID or bp.plaza_cells.has(c):
				continue
			if bp.road_cells.has(c):
				if _is_clean_bridge_candidate(bp, c):
					bp.bridge_cells[c] = ScenarioBlueprint.DIR_N
					bp.set_zone(c, ScenarioBlueprint.ZONE_BRIDGE)
			else:
				bp.water_cells[c] = true
				bp.set_zone(c, ScenarioBlueprint.ZONE_WATER)
				bp.set_height(c, 0)
	_prune_small_water_components(bp)
	var bridges_to_drop: Array[Vector2i] = []
	for bcell: Vector2i in bp.bridge_cells.keys():
		if not bp.water_cells.has(bcell + Vector2i(-1, 0)) and not bp.water_cells.has(bcell + Vector2i(1, 0)):
			bridges_to_drop.append(bcell)
	for bcell: Vector2i in bridges_to_drop:
		bp.bridge_cells.erase(bcell)
		bp.set_zone(bcell, ScenarioBlueprint.ZONE_ROAD)
	for wcell: Vector2i in _sorted_cells(bp.water_cells):
		for d: int in ScenarioBlueprint.CARDINAL_DIRS:
			var nb: Vector2i = wcell + ScenarioBlueprint.dir_vec(d)
			if bp.in_bounds(nb) and bp.zone_at(nb) == ScenarioBlueprint.ZONE_TERRACE:
				bp.set_zone(nb, ScenarioBlueprint.ZONE_EMBANKMENT)


## O adro: pátio de pedra diante do portão da igreja, com campo-santo dos dois lados e o muro com
## portão ao fundo (a igreja pintada do horizonte fica logo atrás). O chefe está no ponto mais alto.
static func _build_boss_precinct(bp: ScenarioBlueprint) -> void:
	var b: Vector2i = bp.boss_cell
	var lvl: int = ScenarioBlueprint.MAX_PLAZA_LEVEL
	for dz: int in range(-5, -1):
		for dx: int in range(-4, 5):
			var cell: Vector2i = b + Vector2i(dx, dz)
			if bp.is_solid(cell) and bp.zone_at(cell) == ScenarioBlueprint.ZONE_TERRACE:
				bp.set_zone(cell, ScenarioBlueprint.ZONE_FORECOURT)
				bp.set_height(cell, lvl)
	var reserved: Dictionary = {}
	_try_register_compound(bp, reserved, "church_gate", ScenarioBlueprint.COMPOUND_CHURCH_GATE, Vector2i(b.x - 4, b.y - 6), Vector2i(9, 1), ScenarioBlueprint.DIR_S, lvl)
	_try_register_compound(bp, reserved, "adro_cem_w", ScenarioBlueprint.COMPOUND_CEMETERY, Vector2i(b.x - 8, b.y - 3), Vector2i(4, 3), ScenarioBlueprint.DIR_E, lvl)
	_try_register_compound(bp, reserved, "adro_cem_e", ScenarioBlueprint.COMPOUND_CEMETERY, Vector2i(b.x + 5, b.y - 3), Vector2i(4, 3), ScenarioBlueprint.DIR_W, lvl)
	# Balaustradas dos dois lados da escadaria.
	for dz: int in range(2, 5):
		for side: int in [-2, 2]:
			var cell: Vector2i = b + Vector2i(side, dz)
			if bp.zone_at(cell) == ScenarioBlueprint.ZONE_TERRACE:
				bp.set_height(cell, ScenarioBlueprint.MAX_PLAZA_LEVEL - 1)
				_add_dress(bp, cell, "graveyard/stone-wall.glb", 90.0, Vector3.ONE, Color(0.36, 0.38, 0.46), "stair_rail")


## Registra uma peça de cenografia de um lugar (poço, abrigo, muro de ruína, banco...).
static func _add_dress(bp: ScenarioBlueprint, cell: Vector2i, asset: String, yaw: float, scale_vec: Vector3, tint: Color, role: String, lift: float = 0.0) -> void:
	bp.plaza_dress.append({
		"cell": cell,
		"asset": asset,
		"yaw": yaw,
		"scale": scale_vec,
		"tint": tint,
		"role": role,
		"lift": lift,
	})


static func _hash(seed_value: int, cell: Vector2i, salt: int = 0) -> int:
	var h: int = (cell.x * 73856093) ^ (cell.y * 19349663) ^ ((seed_value + salt) * 83492791)
	h = (h ^ (h >> 13)) * 1274126177
	return absi(h ^ (h >> 16))



static func _touches_void(bp: ScenarioBlueprint, cell: Vector2i) -> bool:
	for d: int in ScenarioBlueprint.CARDINAL_DIRS:
		if bp.zone_at(cell + ScenarioBlueprint.dir_vec(d)) == ScenarioBlueprint.ZONE_VOID:
			return true
	return false



static func _fallback_manhattan_path(from_cell: Vector2i, to_cell: Vector2i) -> Array[Vector2i]:
	var found: Array[Vector2i] = [from_cell]
	var cur: Vector2i = from_cell
	var mid_z: int = (from_cell.y + to_cell.y) / 2
	while cur.y != mid_z:
		cur.y += signi(mid_z - cur.y)
		found.append(cur)
	while cur.x != to_cell.x:
		cur.x += signi(to_cell.x - cur.x)
		found.append(cur)
	while cur.y != to_cell.y:
		cur.y += signi(to_cell.y - cur.y)
		found.append(cur)
	return found


## Estágio 2B: garante |Δh| <= 1 entre todas as células caminháveis adjacentes e promove quinas
## ambíguas (com >= 2 vizinhos mais altos) em patamares planos antes de colocar escadas.
static func _smooth_roads_and_promote_landings(bp: ScenarioBlueprint) -> void:
	var road_keys: Array[Vector2i] = _sorted_cells(bp.road_cells)
	if road_keys.is_empty():
		return

	_relax_roads(bp, road_keys)

	for _iter: int in 32:
		var fixed_any: bool = false
		for cell: Vector2i in road_keys:
			var h: int = bp.height_at(cell)
			var higher: Array[Vector2i] = []
			var has_lower_plaza: bool = false
			for d: int in ScenarioBlueprint.CARDINAL_DIRS:
				var near: Vector2i = cell + ScenarioBlueprint.dir_vec(d)
				if not bp.is_walkable(near):
					continue
				var hn: int = bp.height_at(near)
				if hn == h + 1:
					higher.append(near)
				elif hn == h - 1 and bp.plaza_cells.has(near):
					has_lower_plaza = true
			if higher.size() >= 2:
				if not has_lower_plaza:
					bp.set_height(cell, clampi(h + 1, ScenarioBlueprint.MIN_PLAZA_LEVEL, ScenarioBlueprint.MAX_PLAZA_LEVEL))
					fixed_any = true
				else:
					for up_nb: Vector2i in higher:
						if not bp.plaza_cells.has(up_nb):
							bp.set_height(up_nb, h)
							fixed_any = true
		if fixed_any:
			_relax_roads(bp, road_keys)
		else:
			break

	# Passo final de segurança garantindo estritamente |Δh| <= 1 em toda a malha caminhável.
	_relax_roads(bp, road_keys)


static func _relax_roads(bp: ScenarioBlueprint, road_keys: Array[Vector2i]) -> void:
	for _pass: int in 14:
		var changed: bool = false
		for cell: Vector2i in road_keys:
			var h: int = bp.height_at(cell)
			var lo: int = ScenarioBlueprint.MIN_PLAZA_LEVEL
			var hi: int = ScenarioBlueprint.MAX_PLAZA_LEVEL
			for d: int in ScenarioBlueprint.CARDINAL_DIRS:
				var near: Vector2i = cell + ScenarioBlueprint.dir_vec(d)
				if not bp.is_walkable(near):
					continue
				var hn: int = bp.height_at(near)
				lo = maxi(lo, hn - 1)
				hi = mini(hi, hn + 1)
			if lo <= hi:
				var clamped: int = clampi(h, lo, hi)
				if clamped != h:
					bp.set_height(cell, clamped)
					changed = true
		if not changed:
			break


static func _place_stairs(bp: ScenarioBlueprint) -> void:
	bp.stairs.clear()
	for cell: Vector2i in _sorted_cells(bp.road_cells):
		if bp.bridge_cells.has(cell):
			continue
		var h: int = bp.height_at(cell)
		var higher_dirs: Array[int] = []
		for d: int in ScenarioBlueprint.CARDINAL_DIRS:
			var near: Vector2i = cell + ScenarioBlueprint.dir_vec(d)
			if bp.is_walkable(near) and bp.height_at(near) == h + 1:
				higher_dirs.append(d)
		if higher_dirs.size() == 1:
			bp.stairs[cell] = ScenarioBlueprint.dir_yaw(higher_dirs[0])



static func _is_clean_bridge_candidate(bp: ScenarioBlueprint, cell: Vector2i) -> bool:
	if not bp.road_cells.has(cell) or bp.plaza_cells.has(cell) or bp.stairs.has(cell):
		return false
	if bp.height_at(cell) < 2:
		return false
	var n: Vector2i = cell + Vector2i(0, -1)
	var s: Vector2i = cell + Vector2i(0, 1)
	var w: Vector2i = cell + Vector2i(-1, 0)
	var e: Vector2i = cell + Vector2i(1, 0)
	if not (bp.is_walkable(n) and bp.is_walkable(s)):
		return false
	if bp.is_walkable(w) or bp.is_walkable(e):
		return false
	if bp.stairs.has(n) or bp.stairs.has(s):
		return false
	return bp.height_at(n) == bp.height_at(cell) and bp.height_at(s) == bp.height_at(cell)


static func _near_stair_or_plaza(bp: ScenarioBlueprint, cell: Vector2i) -> bool:
	for dz: int in range(-1, 2):
		for dx: int in range(-1, 2):
			var nb: Vector2i = Vector2i(cell.x + dx, cell.y + dz)
			if bp.plaza_cells.has(nb) or bp.stairs.has(nb):
				return true
	return false


static func _near_walkable_any(bp: ScenarioBlueprint, cell: Vector2i) -> bool:
	for dz: int in range(-1, 2):
		for dx: int in range(-1, 2):
			if bp.is_walkable(Vector2i(cell.x + dx, cell.y + dz)):
				return true
	return false



static func _prune_small_water_components(bp: ScenarioBlueprint) -> void:
	var visited: Dictionary = {}
	var drop: Array[Vector2i] = []
	for start: Vector2i in _sorted_cells(bp.water_cells):
		if visited.has(start):
			continue
		var comp: Array[Vector2i] = [start]
		visited[start] = true
		var head: int = 0
		while head < comp.size():
			var cur: Vector2i = comp[head]
			head += 1
			for d: int in ScenarioBlueprint.CARDINAL_DIRS:
				var near: Vector2i = cur + ScenarioBlueprint.dir_vec(d)
				if bp.water_cells.has(near) and not visited.has(near):
					visited[near] = true
					comp.append(near)
		if comp.size() < ScenarioBlueprint.MIN_WATER_COMPONENT:
			for c: Vector2i in comp:
				drop.append(c)
	for c: Vector2i in drop:
		bp.water_cells.erase(c)
		bp.set_zone(c, ScenarioBlueprint.ZONE_TERRACE)
		bp.set_height(c, 1)



static func _in_any_node_occlusion_cone(bp: ScenarioBlueprint, cell: Vector2i) -> bool:
	for node_id: int in bp.node_cells.keys():
		var nc: Vector2i = bp.node_cells[node_id]
		var dx: int = cell.x - nc.x
		var dz: int = cell.y - nc.y
		if dx >= 0 and dz >= 0 and dx <= 2 and dz <= 2:
			return true
	return false


static func _front_of_pad(origin: Vector2i, sz: Vector2i, door_dir: int) -> Vector2i:
	var cx: int = origin.x + sz.x / 2
	var cz: int = origin.y + sz.y / 2
	match door_dir:
		ScenarioBlueprint.DIR_N:
			return Vector2i(cx, origin.y - 1)
		ScenarioBlueprint.DIR_S:
			return Vector2i(cx, origin.y + sz.y)
		ScenarioBlueprint.DIR_W:
			return Vector2i(origin.x - 1, cz)
		ScenarioBlueprint.DIR_E:
			return Vector2i(origin.x + sz.x, cz)
		_:
			return Vector2i(cx, cz)


static func _try_register_compound(bp: ScenarioBlueprint, reserved: Dictionary, cid: String, kind: int, origin: Vector2i, sz: Vector2i, door_dir: int, pad_h: int) -> bool:
	var cells: Array[Vector2i] = []
	for dz: int in sz.y:
		for dx: int in sz.x:
			var c: Vector2i = origin + Vector2i(dx, dz)
			if not bp.in_bounds(c) or bp.zone_at(c) == ScenarioBlueprint.ZONE_VOID or bp.is_walkable(c) or bp.water_cells.has(c) or reserved.has(c):
				return false
			if ScenarioBlueprint.is_tall_compound(kind) and _in_any_node_occlusion_cone(bp, c):
				return false
			cells.append(c)
	var zone_type: int = ScenarioBlueprint.ZONE_COURTYARD if kind == ScenarioBlueprint.COMPOUND_CEMETERY or kind == ScenarioBlueprint.COMPOUND_COURTYARD_RUIN else ScenarioBlueprint.ZONE_BUILDING
	for c: Vector2i in cells:
		bp.set_height(c, pad_h)
		bp.set_zone(c, zone_type)
		reserved[c] = true
	bp.compounds.append({
		"id": cid,
		"kind": kind,
		"origin": origin,
		"size": sz,
		"center": origin + Vector2i(sz.x / 2, sz.y / 2),
		"height": pad_h,
		"door_dir": door_dir,
		"cells": cells,
		"tall": ScenarioBlueprint.is_tall_compound(kind),
	})
	return true


## Estágio 5: parapeitos de contenção contínuos (>= 2 células no mesmo nível), apenas nas bordas
## traseiras (-Z ou -X) de terraços sobre desnível >= 2 ou VOID, nunca bloqueando portas.
static func _build_retaining_wall_runs(bp: ScenarioBlueprint, check_drop: bool = true) -> void:
	bp.wall_runs.clear()
	var front_cells: Dictionary = {}
	for comp: Dictionary in bp.compounds:
		front_cells[_front_of_pad(comp["origin"] as Vector2i, comp["size"] as Vector2i, int(comp["door_dir"]))] = true

	# Varredura horizontal ao longo da borda Norte (-Z).
	for z: int in range(1, bp.rows - 1):
		var run: Array[Vector2i] = []
		var run_h: int = -99
		for x: int in range(1, bp.cols - 1):
			var cell: Vector2i = Vector2i(x, z)
			if _is_parapet_cell(bp, cell, ScenarioBlueprint.DIR_N, front_cells, check_drop):
				var h: int = bp.height_at(cell)
				if run.is_empty() or run_h == h:
					run.append(cell)
					run_h = h
				else:
					_flush_wall_run(bp, run, ScenarioBlueprint.DIR_N, run_h)
					run = [cell]
					run_h = h
			else:
				_flush_wall_run(bp, run, ScenarioBlueprint.DIR_N, run_h)
				run = []
		_flush_wall_run(bp, run, ScenarioBlueprint.DIR_N, run_h)

	# Varredura vertical ao longo da borda Oeste (-X).
	for x: int in range(1, bp.cols - 1):
		var run: Array[Vector2i] = []
		var run_h: int = -99
		for z: int in range(1, bp.rows - 1):
			var cell: Vector2i = Vector2i(x, z)
			if _is_parapet_cell(bp, cell, ScenarioBlueprint.DIR_W, front_cells, check_drop):
				var h: int = bp.height_at(cell)
				if run.is_empty() or run_h == h:
					run.append(cell)
					run_h = h
				else:
					_flush_wall_run(bp, run, ScenarioBlueprint.DIR_W, run_h)
					run = [cell]
					run_h = h
			else:
				_flush_wall_run(bp, run, ScenarioBlueprint.DIR_W, run_h)
				run = []
		_flush_wall_run(bp, run, ScenarioBlueprint.DIR_W, run_h)


static func _is_parapet_cell(bp: ScenarioBlueprint, cell: Vector2i, edge_dir: int, front_cells: Dictionary, check_drop: bool) -> bool:
	var z: int = bp.zone_at(cell)
	if z != ScenarioBlueprint.ZONE_TERRACE and z != ScenarioBlueprint.ZONE_EMBANKMENT:
		return false
	if front_cells.has(cell):
		return false
	for lamp: Dictionary in bp.lamps:
		if (lamp["cell"] as Vector2i) == cell:
			return false
	var h: int = bp.height_at(cell)
	var min_h: int = 1 if bp.is_focal else 2
	if h < min_h:
		return false
	var outside: Vector2i = cell + ScenarioBlueprint.dir_vec(edge_dir)
	var oz: int = bp.zone_at(outside)
	if oz == ScenarioBlueprint.ZONE_VOID:
		return true
	if check_drop and bp.height_at(outside) <= h - 2 and not bp.is_walkable(outside):
		return true
	return false


static func _flush_wall_run(bp: ScenarioBlueprint, cells: Array[Vector2i], edge_dir: int, h: int) -> void:
	if cells.size() < ScenarioBlueprint.MIN_WALL_RUN_LEN:
		return
	var style: String = "brick" if h >= ScenarioBlueprint.MAX_PLAZA_LEVEL - 1 else "stone"
	bp.wall_runs.append({
		"cells": cells.duplicate(),
		"edge_dir": edge_dir,
		"style": style,
		"height": h,
	})



## Estágio 6A: postes aterrados no exato nível da rua/praça vizinha, espaçamento Manhattan >= 5,
## braço apontado para a via e jamais no cone frontal imediato da câmera.
## Com `only_main` só a rua principal ganha postes (feito antes das casas, para acender o caminho
## até a igreja); com `keep_existing` os postes anteriores ficam e o espaçamento os respeita.
static func _place_lamps(bp: ScenarioBlueprint, only_main: bool = false, keep_existing: bool = false) -> void:
	if not keep_existing:
		bp.lamps.clear()
	var front_cells: Dictionary = {}
	for comp: Dictionary in bp.compounds:
		front_cells[_front_of_pad(comp["origin"] as Vector2i, comp["size"] as Vector2i, int(comp["door_dir"]))] = true

	var placed_cells: Array[Vector2i] = []
	var lit_count: int = 0
	for lamp_def: Dictionary in bp.lamps:
		placed_cells.append(lamp_def["cell"] as Vector2i)
		if bool(lamp_def.get("lit", false)):
			lit_count += 1
	var road_keys: Array[Vector2i] = _lamp_order(bp)

	for road_cell: Vector2i in road_keys:
		if bp.stairs.has(road_cell) or bp.bridge_cells.has(road_cell):
			continue
		if only_main and not bp.main_road.has(road_cell):
			continue
		var rh: int = bp.height_at(road_cell)
		# Preferência para lados norte/oeste primeiro para não tampar viajante nem estrada.
		for d: int in [ScenarioBlueprint.DIR_N, ScenarioBlueprint.DIR_W, ScenarioBlueprint.DIR_E, ScenarioBlueprint.DIR_S]:
			var side: Vector2i = road_cell + ScenarioBlueprint.dir_vec(d)
			if not bp.is_solid(side) or front_cells.has(side):
				continue
			var sz: int = bp.zone_at(side)
			if sz != ScenarioBlueprint.ZONE_TERRACE and sz != ScenarioBlueprint.ZONE_EMBANKMENT:
				continue
			if bp.height_at(side) != rh:
				continue
			if _in_any_node_occlusion_cone(bp, side):
				continue
			if _wall_uses_cell(bp, side) or _dress_uses_cell(bp, side):
				continue
			var too_close: bool = false
			for prev: Vector2i in placed_cells:
				if absi(prev.x - side.x) + absi(prev.y - side.y) < ScenarioBlueprint.MIN_LAMP_SPACING:
					too_close = true
					break
			if too_close:
				continue
			var road_dir: int = ScenarioBlueprint.dir_from_vec(road_cell - side)
			var yaw: float = ScenarioBlueprint.dir_yaw(ScenarioBlueprint.dir_opposite(road_dir))
			var should_lit: bool = lit_count < 10 and (placed_cells.size() % 2 == 0)
			if should_lit:
				lit_count += 1
			bp.lamps.append({
				"cell": side,
				"road_cell": road_cell,
				"yaw": yaw,
				"height": rh,
				"lit": should_lit,
			})
			placed_cells.append(side)
			break


static func _dress_uses_cell(bp: ScenarioBlueprint, cell: Vector2i) -> bool:
	for piece: Dictionary in bp.plaza_dress:
		if (piece["cell"] as Vector2i) == cell:
			return true
	return false


static func _wall_uses_cell(bp: ScenarioBlueprint, cell: Vector2i) -> bool:
	for run: Dictionary in bp.wall_runs:
		var cells: Array = run.get("cells", [])
		for rc: Variant in cells:
			if (rc as Vector2i) == cell:
				return true
	return false


## Ordem dos postes: a rua principal primeiro (acende o caminho até a igreja), depois as outras.
static func _lamp_order(bp: ScenarioBlueprint) -> Array[Vector2i]:
	var ordered: Array[Vector2i] = []
	var others: Array[Vector2i] = []
	for cell: Vector2i in _sorted_cells(bp.road_cells):
		if bp.main_road.has(cell):
			ordered.append(cell)
		else:
			others.append(cell)
	ordered.append_array(others)
	return ordered


## Células já tomadas por compostos, postes e peças de cenografia (nada se sobrepõe).
static func _reserve_existing(bp: ScenarioBlueprint) -> Dictionary:
	var reserved: Dictionary = {}
	for comp: Dictionary in bp.compounds:
		for raw: Variant in comp["cells"]:
			reserved[raw as Vector2i] = true
	for lamp: Dictionary in bp.lamps:
		reserved[lamp["cell"] as Vector2i] = true
	for piece: Dictionary in bp.plaza_dress:
		reserved[piece["cell"] as Vector2i] = true
	return reserved


static func _ring_free(bp: ScenarioBlueprint, cell: Vector2i, reserved: Dictionary) -> bool:
	return bp.is_solid(cell) and bp.zone_at(cell) == ScenarioBlueprint.ZONE_TERRACE and not reserved.has(cell) and not bp.is_walkable(cell)


## Parede de ruína rente à praça: alta se não esconder rua na câmera, senão baixa (mureta caída).
static func _ruin_wall(bp: ScenarioBlueprint, cell: Vector2i, level: int, hidden: Dictionary, reserved: Dictionary, role: String, yaw: float, tint: Color = Color(0.34, 0.36, 0.44)) -> void:
	bp.set_height(cell, level)
	bp.set_zone(cell, ScenarioBlueprint.ZONE_BUILDING)
	reserved[cell] = true
	var tall: bool = not hidden.has(cell)
	var broken: bool = _hash(bp.map_seed, cell, 233) % 100 < 22
	var wall_h: float = TALL_WALL_H * 0.85 if tall else LOW_WALL_H
	if broken:
		wall_h = LOW_WALL_H * 0.7
	_add_dress(bp, cell, "graveyard/stone-wall.glb", yaw, Vector3(1.0, wall_h / 0.73, 1.6), tint, role)
	if broken:
		_add_dress(bp, cell, "graveyard/debris.glb", yaw, Vector3.ONE * 1.5, Color(0.5, 0.5, 0.55), role + "_debris")


## O "L" noroeste da praça (muro ao norte e a oeste), lado oposto ao da câmera: abrigo, sala em
## ruínas. Ruas que chegam à praça abrem passagem no muro.
static func _nw_ring(c: Vector2i) -> Array[Vector2i]:
	var ring: Array[Vector2i] = []
	for dx: int in range(-2, 3):
		ring.append(Vector2i(c.x + dx, c.y - 2))
	for dz: int in range(-1, 3):
		ring.append(Vector2i(c.x - 2, c.y + dz))
	return ring


## Estágio 4A: cada tipo de nó vira um lugar da cidade (peças só de apresentação, o centro da praça
## fica livre para o sprite do nó). Baú: sala em ruínas. Fogueira: abrigo com banco. Evento:
## campo-santo menor. Elite e mini boss: praça de armas com grade e braseiros. Luta: pátio com restos.
static func _dress_node_plazas(bp: ScenarioBlueprint, graph: MapGraph, reserved: Dictionary) -> void:
	var hidden: Dictionary = occluding_cells(bp)
	for node: MapNode in graph.nodes:
		if node.kind == MapNode.Kind.BOSS or node.kind == MapNode.Kind.START:
			continue
		var c: Vector2i = bp.node_cells[node.id]
		var level: int = int(bp.node_levels[node.id])
		match node.kind:
			MapNode.Kind.CHEST:
				for cell: Vector2i in _nw_ring(c):
					if _ring_free(bp, cell, reserved):
						_ruin_wall(bp, cell, level, hidden, reserved, "chest_room", 0.0 if cell.y == c.y - 2 else 90.0)
				_add_dress(bp, c + Vector2i(1, -1), "mini_dungeon/barrel.glb", 0.0, Vector3.ONE * 1.3, Color(0.5, 0.42, 0.36), "plaza_prop")
			MapNode.Kind.BONFIRE:
				for cell: Vector2i in _nw_ring(c):
					if _ring_free(bp, cell, reserved):
						_ruin_wall(bp, cell, level, hidden, reserved, "camp_shelter", 0.0 if cell.y == c.y - 2 else 90.0, Color(0.30, 0.31, 0.38))
				_add_dress(bp, c + Vector2i(-1, -1), "graveyard/bench.glb", 0.0, Vector3.ONE * 1.35, Color(0.45, 0.38, 0.32), "plaza_prop")
				_add_dress(bp, c + Vector2i(1, -1), "mini_dungeon/barrel.glb", 0.0, Vector3.ONE * 1.3, Color(0.5, 0.42, 0.36), "plaza_prop")
			MapNode.Kind.EVENT:
				var stones: Array[String] = ["graveyard/gravestone-round.glb", "graveyard/gravestone-bevel.glb", "graveyard/gravestone-cross.glb", "graveyard/gravestone-broken.glb"]
				var i: int = 0
				for cell: Vector2i in _nw_ring(c):
					if _ring_free(bp, cell, reserved):
						bp.set_height(cell, level)
						reserved[cell] = true
						_add_dress(bp, cell, stones[(i + _hash(bp.map_seed, cell, 241)) % stones.size()], float(_hash(bp.map_seed, cell, 243) % 3) * 8.0 - 8.0, Vector3.ONE * 1.25, Color(0.55, 0.56, 0.64), "campo_santo")
					i += 1
				var cross_cell: Vector2i = c + Vector2i(-2, -2)
				if _ring_free(bp, cross_cell, reserved) and not hidden.has(cross_cell):
					_add_dress(bp, cross_cell, "graveyard/cross-column.glb", 0.0, Vector3.ONE * 1.4, Color(0.5, 0.52, 0.6), "campo_santo")
			MapNode.Kind.ELITE, MapNode.Kind.MINI_BOSS:
				for cell: Vector2i in _nw_ring(c):
					if _ring_free(bp, cell, reserved):
						bp.set_height(cell, level)
						reserved[cell] = true
						var along_x: bool = cell.y == c.y - 2
						_add_dress(bp, cell, "graveyard/iron-fence-border.glb", 0.0 if along_x else 90.0, Vector3.ONE * 1.1, Color(0.2, 0.21, 0.26), "armory_fence")
				for corner: Vector2i in [c + Vector2i(-2, -2), c + Vector2i(2, -2)]:
					if bp.is_solid(corner) and not bp.is_walkable(corner):
						_add_dress(bp, corner, "graveyard/fire-basket.glb", 0.0, Vector3.ONE * 1.7, Color.WHITE, "armory_brazier", 0.0)
			MapNode.Kind.AMBUSH:
				for cell: Vector2i in [c + Vector2i(-2, -1), c + Vector2i(-2, 1), c + Vector2i(2, -2)]:
					if _ring_free(bp, cell, reserved):
						bp.set_height(cell, level)
						reserved[cell] = true
						_add_dress(bp, cell, "mini_dungeon/barrel.glb", float(_hash(bp.map_seed, cell, 251) % 4) * 90.0, Vector3.ONE * 1.3, Color(0.46, 0.4, 0.34), "ambush_cover")
			_:
				for cell: Vector2i in [c + Vector2i(-2, -2), c + Vector2i(2, 2)]:
					if _ring_free(bp, cell, reserved):
						bp.set_height(cell, level)
						reserved[cell] = true
						_add_dress(bp, cell, "graveyard/debris.glb", float(_hash(bp.map_seed, cell, 257) % 4) * 90.0, Vector3.ONE * 1.4, Color(0.55, 0.55, 0.6), "yard_debris")


## O portão em ruína da cidade: a estrada de chegada atravessa dois pilares baixos e restos de
## muro, ao sul da praça da partida (lado da câmera, por isso tudo baixo: nunca esconde a Bibiana).
static func _place_city_gate(bp: ScenarioBlueprint, graph: MapGraph, reserved: Dictionary) -> void:
	var s: Vector2i = bp.node_cells[graph.start_id]
	var level: int = int(bp.node_levels[graph.start_id])
	for dz: int in range(2, 6):
		var road: Vector2i = Vector2i(s.x, s.y + dz)
		if bp.is_solid(road) and bp.zone_at(road) == ScenarioBlueprint.ZONE_TERRACE and not reserved.has(road):
			bp.road_cells[road] = true
			bp.set_zone(road, ScenarioBlueprint.ZONE_ROAD)
			bp.set_height(road, level)
	var origin: Vector2i = Vector2i(s.x - 3, s.y + 3)
	var cells: Array[Vector2i] = []
	for dx: int in range(0, 7):
		var cell: Vector2i = origin + Vector2i(dx, 0)
		if dx == 3 or not bp.is_solid(cell) or bp.is_walkable(cell) or reserved.has(cell):
			continue
		bp.set_height(cell, level)
		bp.set_zone(cell, ScenarioBlueprint.ZONE_BUILDING)
		reserved[cell] = true
		cells.append(cell)
	if cells.is_empty():
		return
	bp.compounds.append({
		"id": "city_gate",
		"kind": ScenarioBlueprint.COMPOUND_CITY_GATE,
		"origin": origin,
		"size": Vector2i(7, 1),
		"center": origin + Vector2i(3, 0),
		"height": level,
		"door_dir": ScenarioBlueprint.DIR_N,
		"cells": cells,
		"tall": false,
	})


## Estágio 4B: casas de empena rente às ruas, porta voltada para a rua. Do lado dos fundos da câmera
## (norte e oeste da rua) a casa é alta, com telhado e janelas acesas; do lado da câmera (sul e
## leste) só cabem ruínas baixas, que não escondem a rua. Nunca há bloco sem porta nem bloco solto.
static func _place_street_houses(bp: ScenarioBlueprint, reserved: Dictionary) -> void:
	var hidden: Dictionary = occluding_cells(bp)
	var hidden_near: Dictionary = occluding_cells(bp, 1)
	var doors: Array[int] = [ScenarioBlueprint.DIR_S, ScenarioBlueprint.DIR_E, ScenarioBlueprint.DIR_N, ScenarioBlueprint.DIR_W]
	for s: Vector2i in _sorted_cells(bp.road_cells):
		if bp.bridge_cells.has(s) or bp.stairs.has(s):
			continue
		for door_dir: int in doors:
			_try_house(bp, reserved, hidden, hidden_near, s, door_dir)
	# Praças cercadas de casas: as bordas norte e oeste de cada praça também têm fachadas.
	for s: Vector2i in _sorted_cells(bp.plaza_cells):
		for door_dir: int in [ScenarioBlueprint.DIR_S, ScenarioBlueprint.DIR_E]:
			_try_house(bp, reserved, hidden, hidden_near, s, door_dir)


static func _try_house(bp: ScenarioBlueprint, reserved: Dictionary, hidden: Dictionary, hidden_near: Dictionary, s: Vector2i, door_dir: int) -> void:
	var roll: int = _hash(bp.map_seed, s, 211 + door_dir)
	var back_side: bool = door_dir == ScenarioBlueprint.DIR_S or door_dir == ScenarioBlueprint.DIR_E
	if roll % 100 < (6 if back_side else 58):
		return
	var w0: int = 2 + (roll / 7) % 3
	var d0: int = 2 + (roll / 31) % 3
	# Tenta a planta sorteada e, se não couber (rua cruzando, praça, desnível), encolhe até 2x2.
	for w: int in range(w0, 1, -1):
		for d: int in range(d0, 1, -1):
			if _house_at(bp, reserved, hidden, hidden_near, s, door_dir, w, d, roll):
				return


static func _house_at(bp: ScenarioBlueprint, reserved: Dictionary, hidden: Dictionary, hidden_near: Dictionary, s: Vector2i, door_dir: int, w: int, d: int, roll: int) -> bool:
	var back_side: bool = door_dir == ScenarioBlueprint.DIR_S or door_dir == ScenarioBlueprint.DIR_E
	var origin: Vector2i = s
	var sz: Vector2i = Vector2i(w, d)
	match door_dir:
		ScenarioBlueprint.DIR_S:
			origin = Vector2i(s.x, s.y - d)
		ScenarioBlueprint.DIR_N:
			origin = Vector2i(s.x, s.y + 1)
		ScenarioBlueprint.DIR_E:
			origin = Vector2i(s.x - d, s.y)
			sz = Vector2i(d, w)
		_:
			origin = Vector2i(s.x + 1, s.y)
			sz = Vector2i(d, w)
	var front: Vector2i = _front_of_pad(origin, sz, door_dir)
	if not bp.is_walkable(front) or bp.stairs.has(front) or bp.bridge_cells.has(front):
		return false
	var pad_h: int = bp.height_at(front)
	var cells: Array[Vector2i] = []
	var tall: bool = back_side
	var cottage_ok: bool = true
	for dz: int in sz.y:
		for dx: int in sz.x:
			var c: Vector2i = origin + Vector2i(dx, dz)
			if not _ring_free(bp, c, reserved) or absi(bp.height_at(c) - pad_h) > 2:
				return false
			for mz: int in range(-1, 2):
				for mx: int in range(-1, 2):
					if bp.water_cells.has(c + Vector2i(mx, mz)):
						return false
			if hidden.has(c):
				tall = false
			if hidden_near.has(c):
				cottage_ok = false
			cells.append(c)
	var kind: int = ScenarioBlueprint.COMPOUND_RUIN_HOUSE
	if tall:
		kind = ScenarioBlueprint.COMPOUND_HOUSE
	elif cottage_ok and roll % 100 < 88:
		kind = ScenarioBlueprint.COMPOUND_COTTAGE
	var zone: int = ScenarioBlueprint.ZONE_COURTYARD if kind == ScenarioBlueprint.COMPOUND_RUIN_HOUSE else ScenarioBlueprint.ZONE_BUILDING
	for c: Vector2i in cells:
		bp.set_height(c, pad_h)
		bp.set_zone(c, zone)
		reserved[c] = true
	bp.compounds.append({
		"id": "house_%d_%d_%d" % [origin.x, origin.y, door_dir],
		"kind": kind,
		"origin": origin,
		"size": sz,
		"center": origin + Vector2i(sz.x / 2, sz.y / 2),
		"height": pad_h,
		"door_dir": door_dir,
		"cells": cells,
		"tall": ScenarioBlueprint.is_tall_compound(kind),
		"variant": roll % 7,
	})
	return true


## Estágio 6B: micro-props estritamente contextuais (nunca fora de contexto, nunca 5×5 dos nós,
## zero pinheiros verdes vibrantes, zero peças de muro/cerca/lápide soltas).
static func _place_contextual_props(bp: ScenarioBlueprint) -> void:
	bp.typed_props.clear()
	var excluded: Dictionary = {}
	for lamp: Dictionary in bp.lamps:
		excluded[lamp["cell"] as Vector2i] = true
	for comp: Dictionary in bp.compounds:
		excluded[_front_of_pad(comp["origin"] as Vector2i, comp["size"] as Vector2i, int(comp["door_dir"]))] = true
	for node_id: int in bp.node_cells.keys():
		var nc: Vector2i = bp.node_cells[node_id]
		for dz: int in range(-2, 3):
			for dx: int in range(-2, 3):
				excluded[Vector2i(nc.x + dx, nc.y + dz)] = true

	for z: int in range(1, bp.rows - 1):
		for x: int in range(1, bp.cols - 1):
			var cell: Vector2i = Vector2i(x, z)
			if excluded.has(cell):
				continue
			var zone: int = bp.zone_at(cell)
			if zone != ScenarioBlueprint.ZONE_TERRACE and zone != ScenarioBlueprint.ZONE_EMBANKMENT:
				continue
			if _in_any_node_occlusion_cone(bp, cell):
				continue

			var h: int = bp.height_at(cell)
			var roll: int = _hash(bp.map_seed, cell, 89) % 100
			var yaw: float = float((_hash(bp.map_seed, cell, 97) % 4) * 90)

			if _adjacent_to_zone(bp, cell, h, ScenarioBlueprint.ZONE_BUILDING):
				if roll < 24:
					var opts: Array[Dictionary] = [
						{"kind": ScenarioBlueprint.PROP_DEBRIS, "asset": "graveyard/debris.glb", "scale": 1.25},
						{"kind": ScenarioBlueprint.PROP_DEBRIS_WOOD, "asset": "graveyard/debris-wood.glb", "scale": 1.25},
						{"kind": ScenarioBlueprint.PROP_BARREL, "asset": "mini_dungeon/barrel.glb", "scale": 1.35},
						{"kind": ScenarioBlueprint.PROP_BENCH, "asset": "graveyard/bench-damaged.glb", "scale": 1.2},
					]
					var chosen: Dictionary = opts[_hash(bp.map_seed, cell, 101) % opts.size()]
					bp.typed_props[cell] = {
						"kind": chosen["kind"],
						"asset": chosen["asset"],
						"yaw": yaw,
						"scale": chosen["scale"],
						"tint": Color(0.75, 0.72, 0.70),
						"context": "building_edge",
					}
				continue

			if _adjacent_to_zone(bp, cell, h, ScenarioBlueprint.ZONE_COURTYARD):
				if roll < 22:
					var court_opts: Array[Dictionary] = [
						{"kind": ScenarioBlueprint.PROP_DEBRIS, "asset": "graveyard/debris.glb", "scale": 1.2},
						{"kind": ScenarioBlueprint.PROP_STONES, "asset": "mini_dungeon/stones.glb", "scale": 1.15},
						{"kind": ScenarioBlueprint.PROP_URN, "asset": "graveyard/urn-square.glb", "scale": 1.3},
					]
					var chosen_c: Dictionary = court_opts[_hash(bp.map_seed, cell, 103) % court_opts.size()]
					bp.typed_props[cell] = {
						"kind": chosen_c["kind"],
						"asset": chosen_c["asset"],
						"yaw": yaw,
						"scale": chosen_c["scale"],
						"tint": Color(0.74, 0.72, 0.74),
						"context": "courtyard_edge",
					}
				continue

			if zone == ScenarioBlueprint.ZONE_EMBANKMENT or _adjacent_cliff_high(bp, cell, h):
				if roll < 18:
					var rock_opts: Array[Dictionary] = [
						{"kind": ScenarioBlueprint.PROP_ROCK, "asset": "graveyard/rocks.glb", "scale": 1.1},
						{"kind": ScenarioBlueprint.PROP_STONES, "asset": "mini_dungeon/stones.glb", "scale": 1.15},
						{"kind": ScenarioBlueprint.PROP_ROCK_TALL, "asset": "graveyard/rocks-tall.glb", "scale": 1.05},
					]
					var chosen_r: Dictionary = rock_opts[_hash(bp.map_seed, cell, 107) % rock_opts.size()]
					bp.typed_props[cell] = {
						"kind": chosen_r["kind"],
						"asset": chosen_r["asset"],
						"yaw": yaw,
						"scale": chosen_r["scale"],
						"tint": Color(0.72, 0.71, 0.74),
						"context": "embankment",
					}
				continue

			if not _near_walkable_any(bp, cell) and not _wall_uses_cell(bp, cell):
				if roll < 4:
					var wild_opts: Array[Dictionary] = [
						{"kind": ScenarioBlueprint.PROP_STONES, "asset": "mini_dungeon/stones.glb", "scale": 1.1, "tint": Color(0.70, 0.70, 0.74)},
						{"kind": ScenarioBlueprint.PROP_ROCK, "asset": "graveyard/rocks.glb", "scale": 1.05, "tint": Color(0.68, 0.68, 0.72)},
						{"kind": ScenarioBlueprint.PROP_TRUNK, "asset": "graveyard/trunk-long.glb", "scale": 1.15, "tint": Color(0.36, 0.34, 0.35)},
					]
					var chosen_w: Dictionary = wild_opts[_hash(bp.map_seed, cell, 113) % wild_opts.size()]
					bp.typed_props[cell] = {
						"kind": chosen_w["kind"],
						"asset": chosen_w["asset"],
						"yaw": yaw,
						"scale": chosen_w["scale"],
						"tint": chosen_w["tint"],
						"context": "terrace_wild",
					}


static func _adjacent_to_zone(bp: ScenarioBlueprint, cell: Vector2i, h: int, wanted_zone: int) -> bool:
	for d: int in ScenarioBlueprint.CARDINAL_DIRS:
		var nb: Vector2i = cell + ScenarioBlueprint.dir_vec(d)
		if bp.zone_at(nb) == wanted_zone and absi(bp.height_at(nb) - h) <= 1:
			return true
	return false


static func _adjacent_cliff_high(bp: ScenarioBlueprint, cell: Vector2i, h: int) -> bool:
	for d: int in ScenarioBlueprint.CARDINAL_DIRS:
		var nb: Vector2i = cell + ScenarioBlueprint.dir_vec(d)
		if bp.is_solid(nb) and bp.height_at(nb) >= h + 2:
			return true
	return false


static func _sorted_cells(dict: Dictionary) -> Array[Vector2i]:
	var keys: Array[Vector2i] = []
	for k: Variant in dict.keys():
		keys.append(k as Vector2i)
	keys.sort_custom(func(a: Vector2i, b: Vector2i) -> bool: return a.y < b.y or (a.y == b.y and a.x < b.x))
	return keys
