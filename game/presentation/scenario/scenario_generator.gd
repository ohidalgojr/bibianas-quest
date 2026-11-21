class_name ScenarioGenerator
extends RefCounted
## Algoritmo próprio de geração coerente de cenários 3D: Terrace-Grammar-Constraint em 7 estágios
## (ADR-0041, TASK-053). Gera tanto o tabuleiro completo do mapa quanto os 11 dioramas focais
## (combate, fogueira, loja, baú, evento, recompensa, menu, vitória, derrota), mantendo 100% de
## determinismo e respeitando a regra de não-oclusão da câmera isométrica.

const LAYER_STEP: int = 5
const COLUMN_STEP: int = 4
const MARGIN: int = 8
const FOCAL_SIZE: int = 13
const FOCAL_OFFSET: Vector2i = Vector2i(-6, -6)


static func generate_map(graph: MapGraph, seed_value: int) -> ScenarioBlueprint:
	var bp: ScenarioBlueprint = ScenarioBlueprint.new()
	bp.layer_count = graph.layer_count
	bp.layer_step = LAYER_STEP
	bp.column_step = COLUMN_STEP
	bp.margin = MARGIN
	var layer_total: int = graph.layer_count + 2
	var cols: int = (graph.width - 1) * COLUMN_STEP + MARGIN * 2 + 1
	var rows: int = (layer_total - 1) * LAYER_STEP + MARGIN * 2 + 1
	bp.configure(cols, rows, seed_value)

	for node: MapNode in graph.nodes:
		bp.node_cells[node.id] = _cell_of_node(node, graph)

	_assign_node_levels(bp, graph)
	_sculpt_map_silhouette(bp, graph)
	_fill_smooth_terrain(bp, graph)
	_stamp_plazas(bp, graph)
	_route_roads_astar(bp, graph)
	_smooth_roads_and_promote_landings(bp)
	_place_stairs(bp)
	_level_interstitial_spikes(bp)
	_carve_water_and_bridges(bp)
	_place_map_compounds(bp, graph)
	_build_retaining_wall_runs(bp)
	_place_lamps(bp)
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
	var x: int = MARGIN + int(round(column * COLUMN_STEP))
	var z: int = MARGIN + (layer_total - 1 - node.layer) * LAYER_STEP
	return Vector2i(x, z)


static func _hash(seed_value: int, cell: Vector2i, salt: int = 0) -> int:
	var h: int = (cell.x * 73856093) ^ (cell.y * 19349663) ^ ((seed_value + salt) * 83492791)
	h = (h ^ (h >> 13)) * 1274126177
	return absi(h ^ (h >> 16))


## Estágio 1A: níveis por caminhada suave, diferença entre camadas ligada por |Δh| <= 2,
## garantindo descidas intermediárias e o chefe no platô mais alto.
static func _assign_node_levels(bp: ScenarioBlueprint, graph: MapGraph) -> void:
	var layer_total: int = graph.layer_count + 2
	var by_layer: Array[int] = []
	var base: int = 3
	for layer: int in layer_total:
		if layer == layer_total - 1:
			base = ScenarioBlueprint.MAX_PLAZA_LEVEL
		elif layer > 0:
			var roll: int = _hash(bp.map_seed, Vector2i(layer, 11), 5) % 100
			if roll < 38:
				base -= 1
			elif roll > 64:
				base += 1
			base = clampi(base, ScenarioBlueprint.MIN_PLAZA_LEVEL, ScenarioBlueprint.MAX_PLAZA_LEVEL - 1)
		by_layer.append(base)

	# Garante ao menos uma descida entre camadas iniciais/intermediárias.
	if layer_total >= 4:
		var has_dip: bool = false
		for layer: int in range(1, layer_total - 1):
			if by_layer[layer] < by_layer[layer - 1]:
				has_dip = true
				break
		if not has_dip:
			by_layer[1] = maxi(ScenarioBlueprint.MIN_PLAZA_LEVEL, by_layer[0] - 1)

	# Mantém transição de no máximo 2 blocos até o platô do chefe.
	for layer: int in range(layer_total - 2, -1, -1):
		if by_layer[layer + 1] - by_layer[layer] > 2:
			by_layer[layer] = clampi(by_layer[layer + 1] - 2, ScenarioBlueprint.MIN_PLAZA_LEVEL, ScenarioBlueprint.MAX_PLAZA_LEVEL)
		elif by_layer[layer] - by_layer[layer + 1] > 2:
			by_layer[layer] = clampi(by_layer[layer + 1] + 2, ScenarioBlueprint.MIN_PLAZA_LEVEL, ScenarioBlueprint.MAX_PLAZA_LEVEL)

	for node: MapNode in graph.nodes:
		var level: int = by_layer[node.layer]
		if node.layer > 0 and node.layer < layer_total - 1:
			# Variação dentro da mesma camada limitada a 0 ou +1 para nunca conflitar vizinhos em X.
			var delta: int = _hash(bp.map_seed, bp.node_cells[node.id] as Vector2i, 9) % 2
			level = clampi(level + delta, ScenarioBlueprint.MIN_PLAZA_LEVEL, ScenarioBlueprint.MAX_PLAZA_LEVEL - 1)
		elif node.layer == layer_total - 1:
			level = ScenarioBlueprint.MAX_PLAZA_LEVEL
		bp.node_levels[node.id] = level

	# Passo de garantia por aresta: |node_levels[v] - node_levels[u]| <= 2 sempre.
	for _pass: int in 4:
		for node: MapNode in graph.nodes:
			for next_id: int in node.next_ids:
				var ha: int = int(bp.node_levels[node.id])
				var hb: int = int(bp.node_levels[next_id])
				if absi(hb - ha) > 2:
					var next_node: MapNode = graph.node_by_id(next_id)
					if next_node != null and next_node.kind != MapNode.Kind.BOSS:
						bp.node_levels[next_id] = clampi(ha + signi(hb - ha) * 2, ScenarioBlueprint.MIN_PLAZA_LEVEL, ScenarioBlueprint.MAX_PLAZA_LEVEL - 1)
					elif node.kind != MapNode.Kind.START:
						bp.node_levels[node.id] = clampi(hb + signi(ha - hb) * 2, ScenarioBlueprint.MIN_PLAZA_LEVEL, ScenarioBlueprint.MAX_PLAZA_LEVEL - 1)

	# Garante ao menos uma aresta descendente (test_map3d.gd e variedade FFT).
	var descents: int = 0
	for node: MapNode in graph.nodes:
		for next_id: int in node.next_ids:
			if int(bp.node_levels[next_id]) < int(bp.node_levels[node.id]):
				descents += 1
	if descents == 0:
		for node: MapNode in graph.nodes:
			if node.layer == 0 and not node.next_ids.is_empty():
				var first_next: int = int(node.next_ids[0])
				bp.node_levels[first_next] = clampi(int(bp.node_levels[node.id]) - 1, ScenarioBlueprint.MIN_PLAZA_LEVEL, ScenarioBlueprint.MAX_PLAZA_LEVEL - 1)
				break


## Estágio 0B: recorta a silhueta externa em formato orgânico de diorama isométrico,
## preservando todo o corredor dos nós, área 5×3 do Mausoléu do Chefe e margens das praças.
static func _sculpt_map_silhouette(bp: ScenarioBlueprint, graph: MapGraph) -> void:
	var row_min_x: PackedInt32Array = PackedInt32Array()
	var row_max_x: PackedInt32Array = PackedInt32Array()
	row_min_x.resize(bp.rows)
	row_max_x.resize(bp.rows)
	for z: int in bp.rows:
		row_min_x[z] = bp.cols - 1
		row_max_x[z] = 0

	var reachable: PackedInt32Array = graph.reachable_ids()
	for node: MapNode in graph.nodes:
		if not reachable.has(node.id) and node.kind != MapNode.Kind.BOSS and node.kind != MapNode.Kind.START:
			continue
		var c: Vector2i = bp.node_cells[node.id]
		var span_z: int = 6 if node.kind == MapNode.Kind.BOSS else 5
		var span_x: int = 6 if node.kind == MapNode.Kind.BOSS else 5
		for dz: int in range(-span_z, span_z + 1):
			var rz: int = clampi(c.y + dz, 0, bp.rows - 1)
			row_min_x[rz] = mini(row_min_x[rz], maxi(1, c.x - span_x))
			row_max_x[rz] = maxi(row_max_x[rz], mini(bp.cols - 2, c.x + span_x))

	# Enche intervalos intermediários entre camadas para nunca cortar corredores verticais.
	for _pass: int in 4:
		for z: int in range(1, bp.rows - 1):
			row_min_x[z] = mini(row_min_x[z], mini(row_min_x[z - 1], row_min_x[z + 1]))
			row_max_x[z] = maxi(row_max_x[z], maxi(row_max_x[z - 1], row_max_x[z + 1]))

	var min_valid_z: int = bp.rows - 1
	var max_valid_z: int = 0
	for node: MapNode in graph.nodes:
		var nc: Vector2i = bp.node_cells[node.id]
		min_valid_z = mini(min_valid_z, nc.y - 6)
		max_valid_z = maxi(max_valid_z, nc.y + 4)

	for z: int in bp.rows:
		var jitter_l: int = (_hash(bp.map_seed, Vector2i(0, z / 3), 71) % 3) - 1
		var jitter_r: int = (_hash(bp.map_seed, Vector2i(1, z / 3), 73) % 3) - 1
		var left_x: int = maxi(1, row_min_x[z] + jitter_l)
		var right_x: int = mini(bp.cols - 2, row_max_x[z] + jitter_r)
		for x: int in bp.cols:
			var cell: Vector2i = Vector2i(x, z)
			if z < maxi(1, min_valid_z) or z > mini(bp.rows - 2, max_valid_z) or x < left_x or x > right_x:
				bp.set_zone(cell, ScenarioBlueprint.ZONE_VOID)
			else:
				bp.set_zone(cell, ScenarioBlueprint.ZONE_TERRACE)

	# Proteção absoluta: toda área 4 células em volta de qualquer nó (e 5×4 atrás do Chefe) nunca é VOID.
	for node: MapNode in graph.nodes:
		var nc: Vector2i = bp.node_cells[node.id]
		for dz: int in range(-4, 5):
			for dx: int in range(-4, 5):
				var c: Vector2i = nc + Vector2i(dx, dz)
				if bp.in_bounds(c):
					bp.set_zone(c, ScenarioBlueprint.ZONE_TERRACE)
		if node.kind == MapNode.Kind.BOSS:
			for dz: int in range(-6, 3):
				for dx: int in range(-4, 5):
					var c: Vector2i = nc + Vector2i(dx, dz)
					if bp.in_bounds(c):
						bp.set_zone(c, ScenarioBlueprint.ZONE_TERRACE)


## Estágio 1B: ruído bilinear contínuo (sem blocos 4×4 quebrados) + platôs escalonados estilo FFT.
static func _fill_smooth_terrain(bp: ScenarioBlueprint, graph: MapGraph) -> void:
	for z: int in bp.rows:
		for x: int in bp.cols:
			var cell: Vector2i = Vector2i(x, z)
			if bp.zone_at(cell) == ScenarioBlueprint.ZONE_VOID:
				bp.set_height(cell, 0)
				continue
			var w_sum: float = 0.0
			var l_sum: float = 0.0
			for node: MapNode in graph.nodes:
				var nc: Vector2i = bp.node_cells[node.id]
				var dx: float = float(nc.x - x)
				var dz: float = float(nc.y - z)
				var w: float = 1.0 / (dx * dx + dz * dz + 4.0)
				w_sum += w
				l_sum += w * float(int(bp.node_levels[node.id]))
			var base: float = l_sum / maxf(w_sum, 0.0001)
			var hill: float = _smooth_noise(bp.map_seed, float(x) * 0.22, float(z) * 0.22, 21) * 2.2 - 1.1
			var h: int = clampi(int(round(base + hill)), 1, ScenarioBlueprint.MAX_PLAZA_LEVEL)
			bp.set_height(cell, h)

	# 2 passes celulares de platô para formar terraços limpos em vez de picos avulsos.
	for _pass: int in 2:
		var next_h: PackedInt32Array = bp.heights.duplicate()
		for z: int in range(1, bp.rows - 1):
			for x: int in range(1, bp.cols - 1):
				var cell: Vector2i = Vector2i(x, z)
				if bp.zone_at(cell) == ScenarioBlueprint.ZONE_VOID:
					continue
				var total: int = 0
				var count: int = 0
				for dz: int in range(-1, 2):
					for dx: int in range(-1, 2):
						var nb: Vector2i = Vector2i(x + dx, z + dz)
						if bp.zone_at(nb) != ScenarioBlueprint.ZONE_VOID:
							total += bp.height_at(nb)
							count += 1
				if count > 0:
					next_h[bp.idx(cell)] = int(round(float(total) / float(count)))
		bp.heights = next_h

	# Rebaixamento suave das bordas coladas ao VOID para criar degraus de falésia.
	for z: int in bp.rows:
		for x: int in bp.cols:
			var cell: Vector2i = Vector2i(x, z)
			if bp.zone_at(cell) == ScenarioBlueprint.ZONE_VOID:
				continue
			if _touches_void(bp, cell):
				bp.set_height(cell, maxi(1, bp.height_at(cell) - 1))


static func _touches_void(bp: ScenarioBlueprint, cell: Vector2i) -> bool:
	for d: int in ScenarioBlueprint.CARDINAL_DIRS:
		if bp.zone_at(cell + ScenarioBlueprint.dir_vec(d)) == ScenarioBlueprint.ZONE_VOID:
			return true
	return false


static func _smooth_noise(seed_value: int, fx: float, fz: float, salt: int) -> float:
	var x0: int = int(floor(fx))
	var z0: int = int(floor(fz))
	var tx: float = fx - float(x0)
	var tz: float = fz - float(z0)
	tx = tx * tx * (3.0 - 2.0 * tx)
	tz = tz * tz * (3.0 - 2.0 * tz)
	var n00: float = float(_hash(seed_value, Vector2i(x0, z0), salt) % 1000) / 1000.0
	var n10: float = float(_hash(seed_value, Vector2i(x0 + 1, z0), salt) % 1000) / 1000.0
	var n01: float = float(_hash(seed_value, Vector2i(x0, z0 + 1), salt) % 1000) / 1000.0
	var n11: float = float(_hash(seed_value, Vector2i(x0 + 1, z0 + 1), salt) % 1000) / 1000.0
	var nx0: float = lerpf(n00, n10, tx)
	var nx1: float = lerpf(n01, n11, tx)
	return lerpf(nx0, nx1, tz)


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
		# Platô elevado do Chefe expandido no anel externo atrás (deixa frente livre).
		if node.kind == MapNode.Kind.BOSS:
			for dz: int in range(-5, -1):
				for dx: int in range(-2, 3):
					var c: Vector2i = Vector2i(nc.x + dx, nc.y + dz)
					if bp.in_bounds(c) and not bp.plaza_cells.has(c):
						bp.set_zone(c, ScenarioBlueprint.ZONE_TERRACE)
						bp.set_height(c, level)


## Estágio 2A: A* determinístico conectando cada aresta alcançável com reaproveitamento de estradas
## já abertas para formar bifurcações reais em Y sem invadir praças alheias.
static func _route_roads_astar(bp: ScenarioBlueprint, graph: MapGraph) -> void:
	var owner_of_plaza: Dictionary = {}
	for node: MapNode in graph.nodes:
		var nc: Vector2i = bp.node_cells[node.id]
		for dz: int in range(-1, 2):
			for dx: int in range(-1, 2):
				owner_of_plaza[Vector2i(nc.x + dx, nc.y + dz)] = node.id

	var reachable: PackedInt32Array = graph.reachable_ids()
	var edges: Array[Vector2i] = []
	for node: MapNode in graph.nodes:
		if not reachable.has(node.id):
			continue
		for next_id: int in node.next_ids:
			edges.append(Vector2i(node.id, next_id))

	for edge: Vector2i in edges:
		var from_id: int = edge.x
		var to_id: int = edge.y
		var start: Vector2i = bp.node_cells[from_id]
		var goal: Vector2i = bp.node_cells[to_id]
		var path: Array[Vector2i] = _astar_edge(bp, start, goal, from_id, to_id, owner_of_plaza)
		if path.is_empty():
			path = _fallback_manhattan_path(start, goal)
		bp.edge_paths["%d:%d" % [from_id, to_id]] = path
		var ha: int = int(bp.node_levels[from_id])
		var hb: int = int(bp.node_levels[to_id])
		for i: int in path.size():
			var cell: Vector2i = path[i]
			if bp.plaza_cells.has(cell):
				continue
			if not bp.road_cells.has(cell):
				bp.road_cells[cell] = true
				bp.set_zone(cell, ScenarioBlueprint.ZONE_ROAD)
				var t: float = float(i) / float(maxi(path.size() - 1, 1))
				bp.set_height(cell, clampi(int(round(lerpf(float(ha), float(hb), smoothstep(0.15, 0.85, t)))), ScenarioBlueprint.MIN_PLAZA_LEVEL, ScenarioBlueprint.MAX_PLAZA_LEVEL))


static func _astar_edge(bp: ScenarioBlueprint, start: Vector2i, goal: Vector2i, from_id: int, to_id: int, owner_of_plaza: Dictionary) -> Array[Vector2i]:
	var open: Array[Vector2i] = [start]
	var in_open: Dictionary = {start: true}
	var closed: Dictionary = {}
	var came_from: Dictionary = {}
	var g_score: Dictionary = {start: 0.0}
	var f_score: Dictionary = {start: float(absi(goal.x - start.x) + absi(goal.y - start.y))}

	while not open.is_empty():
		var best_idx: int = 0
		var best_f: float = float(f_score.get(open[0], 1e9))
		for i: int in range(1, open.size()):
			var fi: float = float(f_score.get(open[i], 1e9))
			if fi < best_f:
				best_f = fi
				best_idx = i
		var current: Vector2i = open[best_idx]
		open.remove_at(best_idx)
		in_open.erase(current)
		if current == goal:
			return _reconstruct_path(came_from, current)
		closed[current] = true

		var cur_h: int = bp.height_at(current)
		var prev_dir: Vector2i = Vector2i.ZERO
		if came_from.has(current):
			prev_dir = current - (came_from[current] as Vector2i)

		for d: int in ScenarioBlueprint.CARDINAL_DIRS:
			var step_vec: Vector2i = ScenarioBlueprint.dir_vec(d)
			var nb: Vector2i = current + step_vec
			if closed.has(nb) or not bp.in_bounds(nb) or bp.zone_at(nb) == ScenarioBlueprint.ZONE_VOID:
				continue
			if owner_of_plaza.has(nb):
				var pid: int = int(owner_of_plaza[nb])
				if pid != from_id and pid != to_id:
					continue
			var step_cost: float = 0.45 if bp.road_cells.has(nb) else 1.0
			if bp.plaza_cells.has(nb):
				step_cost = 0.5
			var dh: int = absi(bp.height_at(nb) - cur_h)
			step_cost += float(dh) * 0.75 + (4.0 if dh > 1 else 0.0)
			if prev_dir != Vector2i.ZERO and step_vec != prev_dir:
				step_cost += 0.25
			if _touches_other_plaza(nb, from_id, to_id, owner_of_plaza):
				step_cost += 3.5

			var tentative_g: float = float(g_score[current]) + step_cost
			if tentative_g < float(g_score.get(nb, 1e9)):
				came_from[nb] = current
				g_score[nb] = tentative_g
				var h_est: float = float(absi(goal.x - nb.x) + absi(goal.y - nb.y)) * 0.9
				f_score[nb] = tentative_g + h_est
				if not in_open.has(nb):
					open.append(nb)
					in_open[nb] = true

	return []


static func _touches_other_plaza(cell: Vector2i, from_id: int, to_id: int, owner_of_plaza: Dictionary) -> bool:
	for d: int in ScenarioBlueprint.CARDINAL_DIRS:
		var nb: Vector2i = cell + ScenarioBlueprint.dir_vec(d)
		if owner_of_plaza.has(nb):
			var pid: int = int(owner_of_plaza[nb])
			if pid != from_id and pid != to_id:
				return true
	return false


static func _reconstruct_path(came_from: Dictionary, current: Vector2i) -> Array[Vector2i]:
	var rev: Array[Vector2i] = [current]
	var cur: Vector2i = current
	while came_from.has(cur):
		cur = came_from[cur] as Vector2i
		rev.append(cur)
	rev.reverse()
	return rev


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


## Achata cristas isoladas entre praças/estradas e impede que o terraço no cone frontal
## sudeste dos nós suba acima da praça, garantindo leitura limpa das rotas e personagens.
static func _level_interstitial_spikes(bp: ScenarioBlueprint) -> void:
	for z: int in range(1, bp.rows - 1):
		for x: int in range(1, bp.cols - 1):
			var cell: Vector2i = Vector2i(x, z)
			if bp.zone_at(cell) != ScenarioBlueprint.ZONE_TERRACE:
				continue
			var h: int = bp.height_at(cell)
			for node_id: int in bp.node_cells.keys():
				var nc: Vector2i = bp.node_cells[node_id]
				var dx: int = cell.x - nc.x
				var dz: int = cell.y - nc.y
				if dx >= 0 and dz >= 0 and dx <= 2 and dz <= 2:
					var nl: int = int(bp.node_levels[node_id])
					if h > nl:
						h = nl
						bp.set_height(cell, h)

			var walk_nbs: int = 0
			var min_walk_h: int = 99
			for dz_o: int in range(-1, 2):
				for dx_o: int in range(-1, 2):
					if dx_o == 0 and dz_o == 0:
						continue
					var nb: Vector2i = Vector2i(x + dx_o, z + dz_o)
					if bp.is_walkable(nb):
						walk_nbs += 1
						min_walk_h = mini(min_walk_h, bp.height_at(nb))
			if walk_nbs >= 2 and h > min_walk_h:
				bp.set_height(cell, min_walk_h)


## Estágio 3: canais contínuos de água (>= 6 células por BFS), pontes sobre cruzamentos planos
## retos de estrada e poda absoluta de poças isoladas.
static func _carve_water_and_bridges(bp: ScenarioBlueprint) -> void:
	bp.water_cells.clear()
	bp.bridge_cells.clear()

	# Tenta primeiro cruzar um canal contínuo E-W numa faixa entre camadas com travessia por ponte.
	var best_z: int = -1
	var best_score: int = -999
	for layer_gap: int in range(1, bp.layer_count):
		var gz: int = bp.margin + layer_gap * bp.layer_step + 2
		if gz < 3 or gz >= bp.rows - 3:
			continue
		var score: int = 0
		for x: int in range(2, bp.cols - 2):
			var c: Vector2i = Vector2i(x, gz)
			if bp.zone_at(c) == ScenarioBlueprint.ZONE_VOID or bp.plaza_cells.has(c):
				continue
			if bp.stairs.has(c) or bp.stairs.has(c + Vector2i(0, 1)) or bp.stairs.has(c + Vector2i(0, -1)):
				score -= 4
			elif bp.road_cells.has(c):
				score += 2 if _is_clean_bridge_candidate(bp, c) else -5
			else:
				score += 1
		if score > best_score:
			best_score = score
			best_z = gz

	if best_z >= 3:
		var cur_z: int = best_z
		for x: int in range(2, bp.cols - 2):
			var drift: int = int((_hash(bp.map_seed, Vector2i(x / 4, best_z), 41) % 3) - 1)
			cur_z = clampi(best_z + drift, 3, bp.rows - 4)
			for dz: int in 2:
				var c: Vector2i = Vector2i(x, cur_z + dz)
				if not bp.in_bounds(c) or bp.zone_at(c) == ScenarioBlueprint.ZONE_VOID:
					continue
				if bp.plaza_cells.has(c) or _near_stair_or_plaza(bp, c):
					continue
				if bp.road_cells.has(c):
					if dz == 0 and _is_clean_bridge_candidate(bp, c) and not bp.bridge_cells.has(c + Vector2i(0, -1)):
						bp.bridge_cells[c] = ScenarioBlueprint.DIR_N
						bp.set_zone(c, ScenarioBlueprint.ZONE_BRIDGE)
				else:
					bp.water_cells[c] = true
					bp.set_zone(c, ScenarioBlueprint.ZONE_WATER)
					bp.set_height(c, 0)

	# Também aproveita baixios laterais longe de praças/escadas/estradas.
	for z: int in range(2, bp.rows - 2):
		for x: int in range(2, bp.cols - 2):
			var c: Vector2i = Vector2i(x, z)
			if bp.zone_at(c) != ScenarioBlueprint.ZONE_TERRACE:
				continue
			if bp.height_at(c) <= 1 and not _near_walkable_any(bp, c):
				bp.water_cells[c] = true
				bp.set_zone(c, ScenarioBlueprint.ZONE_WATER)
				bp.set_height(c, 0)

	_prune_small_water_components(bp)

	# Fallback garantido caso o mapa não tenha produzido nenhum canal >= 6 células.
	if bp.water_cells.size() < ScenarioBlueprint.MIN_WATER_COMPONENT:
		_carve_guaranteed_flank_canal(bp)
		_prune_small_water_components(bp)

	# Revalida pontes: só permanecem se houver água contínua adjacente em Leste/Oeste.
	var bridges_to_drop: Array[Vector2i] = []
	for bcell: Vector2i in bp.bridge_cells.keys():
		var w_adj: int = 0
		if bp.water_cells.has(bcell + Vector2i(-1, 0)):
			w_adj += 1
		if bp.water_cells.has(bcell + Vector2i(1, 0)):
			w_adj += 1
		if w_adj == 0:
			bridges_to_drop.append(bcell)
	for bcell: Vector2i in bridges_to_drop:
		bp.bridge_cells.erase(bcell)
		bp.set_zone(bcell, ScenarioBlueprint.ZONE_ROAD)

	# Margens secas ortogonais à água viram EMBANKMENT para transição natural.
	for wcell: Vector2i in bp.water_cells.keys():
		for d: int in ScenarioBlueprint.CARDINAL_DIRS:
			var nb: Vector2i = wcell + ScenarioBlueprint.dir_vec(d)
			if bp.in_bounds(nb) and bp.zone_at(nb) == ScenarioBlueprint.ZONE_TERRACE:
				bp.set_zone(nb, ScenarioBlueprint.ZONE_EMBANKMENT)
				bp.set_height(nb, maxi(1, bp.height_at(nb)))


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


static func _carve_guaranteed_flank_canal(bp: ScenarioBlueprint) -> void:
	# Tenta encaixar um canal contínuo 2×5 (10 células >= 6) num flanco livre.
	for start_z: int in range(2, bp.rows - 6):
		for start_x: int in range(2, bp.cols - 3):
			var cells: Array[Vector2i] = []
			var ok: bool = true
			for dz: int in 5:
				for dx: int in 2:
					var c: Vector2i = Vector2i(start_x + dx, start_z + dz)
					if bp.zone_at(c) != ScenarioBlueprint.ZONE_TERRACE or _near_walkable_any(bp, c):
						ok = false
						break
					cells.append(c)
				if not ok:
					break
			if ok:
				for c: Vector2i in cells:
					bp.water_cells[c] = true
					bp.set_zone(c, ScenarioBlueprint.ZONE_WATER)
					bp.set_height(c, 0)
				return

	# Último recurso em mapas muito compactos: 1×6 contínuo.
	for start_z: int in range(2, bp.rows - 7):
		for start_x: int in range(2, bp.cols - 2):
			var cells: Array[Vector2i] = []
			var ok: bool = true
			for dz: int in 6:
				var c: Vector2i = Vector2i(start_x, start_z + dz)
				if bp.zone_at(c) != ScenarioBlueprint.ZONE_TERRACE or _near_walkable_any(bp, c):
					ok = false
					break
				cells.append(c)
			if ok:
				for c: Vector2i in cells:
					bp.water_cells[c] = true
					bp.set_zone(c, ScenarioBlueprint.ZONE_WATER)
					bp.set_height(c, 0)
				return


## Estágio 4: aloca Mausoléu do Chefe ao norte da sala final + compostos de distrito nivelados,
## orientados para a rua e proibidos no cone frontal sudeste de qualquer nó.
static func _place_map_compounds(bp: ScenarioBlueprint, graph: MapGraph) -> void:
	bp.compounds.clear()
	var reserved: Dictionary = {}

	# 4A: Mausoléu do Chefe imediatamente atrás (-Z) da praça do Chefe.
	var boss: MapNode = graph.boss_node()
	if boss != null and bp.node_cells.has(boss.id):
		var bc: Vector2i = bp.node_cells[boss.id]
		var boss_origin: Vector2i = Vector2i(bc.x - 2, bc.y - 5)
		var boss_sz: Vector2i = Vector2i(5, 3)
		if _try_register_compound(bp, reserved, "boss_mausoleum", ScenarioBlueprint.COMPOUND_BOSS_MAUSOLEUM, boss_origin, boss_sz, ScenarioBlueprint.DIR_S, ScenarioBlueprint.MAX_PLAZA_LEVEL):
			pass

	# 4B: Compostos de distrito (marcos arquitetônicos com telhado antes de cemitérios;
	# espaçamento >= 2 células entre compostos e máx. 2 cemitérios com distância >= 8 entre iguais).
	var shapes: Array[Dictionary] = [
		{"sz": Vector2i(4, 3), "kinds": [ScenarioBlueprint.COMPOUND_CHAPEL, ScenarioBlueprint.COMPOUND_CEMETERY]},
		{"sz": Vector2i(3, 3), "kinds": [ScenarioBlueprint.COMPOUND_CHAPEL, ScenarioBlueprint.COMPOUND_WATCHTOWER, ScenarioBlueprint.COMPOUND_COURTYARD_RUIN]},
		{"sz": Vector2i(2, 2), "kinds": [ScenarioBlueprint.COMPOUND_SHRINE]},
	]
	var max_compounds: int = 8
	var count: int = bp.compounds.size()
	var cemetery_count: int = 0

	for shape: Dictionary in shapes:
		if count >= max_compounds:
			break
		var sz: Vector2i = shape["sz"] as Vector2i
		var kinds: Array = shape["kinds"] as Array
		var step: int = 2
		for z: int in range(2, bp.rows - sz.y - 1, step):
			for x: int in range(2, bp.cols - sz.x - 1, step):
				if count >= max_compounds:
					break
				var origin: Vector2i = Vector2i(x, z)
				if (_hash(bp.map_seed, origin, 31) % 100) < 25:
					continue
				var pick_idx: int = _hash(bp.map_seed, origin, 37) % kinds.size()
				var kind: int = int(kinds[pick_idx])
				if kind == ScenarioBlueprint.COMPOUND_CEMETERY and cemetery_count >= 2:
					continue
				if _too_close_to_same_kind(bp, origin, sz, kind):
					continue
				var door_dir: int = _best_door_dir(bp, origin, sz)
				if door_dir < 0:
					continue
				if _can_place_compound(bp, reserved, origin, sz, kind, door_dir):
					var pad_h: int = _median_height(bp, origin, sz)
					var front: Vector2i = _front_of_pad(origin, sz, door_dir)
					if bp.in_bounds(front) and bp.height_at(front) > pad_h + 1:
						pad_h = clampi(bp.height_at(front), ScenarioBlueprint.MIN_PLAZA_LEVEL, ScenarioBlueprint.MAX_PLAZA_LEVEL)
					var cid: String = "cmp_%d_%d" % [origin.x, origin.y]
					if _try_register_compound(bp, reserved, cid, kind, origin, sz, door_dir, pad_h):
						count += 1
						if kind == ScenarioBlueprint.COMPOUND_CEMETERY:
							cemetery_count += 1


static func _too_close_to_same_kind(bp: ScenarioBlueprint, origin: Vector2i, sz: Vector2i, kind: int) -> bool:
	var c: Vector2i = origin + Vector2i(sz.x / 2, sz.y / 2)
	for existing: Dictionary in bp.compounds:
		if int(existing["kind"]) == kind:
			var ec: Vector2i = existing["center"] as Vector2i
			if absi(ec.x - c.x) + absi(ec.y - c.y) < 8:
				return true
	return false


static func _can_place_compound(bp: ScenarioBlueprint, reserved: Dictionary, origin: Vector2i, sz: Vector2i, kind: int, door_dir: int) -> bool:
	var tall: bool = ScenarioBlueprint.is_tall_compound(kind)
	var min_h: int = 99
	var max_h: int = -99
	for dz: int in sz.y:
		for dx: int in sz.x:
			var c: Vector2i = origin + Vector2i(dx, dz)
			if not bp.in_bounds(c):
				return false
			var z: int = bp.zone_at(c)
			if z != ScenarioBlueprint.ZONE_TERRACE and z != ScenarioBlueprint.ZONE_EMBANKMENT:
				return false
			if _near_walkable_any(bp, c):
				return false
			# Margem de 2 células entre compostos distintos e >= 1 célula da água.
			for mz: int in range(-2, 3):
				for mx: int in range(-2, 3):
					var check: Vector2i = c + Vector2i(mx, mz)
					if reserved.has(check):
						return false
					if absi(mx) <= 1 and absi(mz) <= 1 and bp.water_cells.has(check):
						return false
			if tall and _in_any_node_occlusion_cone(bp, c):
				return false
			var ch: int = bp.height_at(c)
			min_h = mini(min_h, ch)
			max_h = maxi(max_h, ch)
	if max_h - min_h > 2:
		return false
	var front: Vector2i = _front_of_pad(origin, sz, door_dir)
	if not bp.in_bounds(front):
		return false
	var fz: int = bp.zone_at(front)
	if fz == ScenarioBlueprint.ZONE_VOID or fz == ScenarioBlueprint.ZONE_WATER or reserved.has(front):
		return false
	return true


static func _in_any_node_occlusion_cone(bp: ScenarioBlueprint, cell: Vector2i) -> bool:
	for node_id: int in bp.node_cells.keys():
		var nc: Vector2i = bp.node_cells[node_id]
		var dx: int = cell.x - nc.x
		var dz: int = cell.y - nc.y
		if dx >= 0 and dz >= 0 and dx <= 2 and dz <= 2:
			return true
	return false


static func _best_door_dir(bp: ScenarioBlueprint, origin: Vector2i, sz: Vector2i) -> int:
	var best_d: int = -1
	var best_dist: int = 999
	# Prefere Sul (+Z) e Leste (+X) em empate, para a fachada olhar para a câmera.
	for d: int in [ScenarioBlueprint.DIR_S, ScenarioBlueprint.DIR_E, ScenarioBlueprint.DIR_W, ScenarioBlueprint.DIR_N]:
		var front: Vector2i = _front_of_pad(origin, sz, d)
		if not bp.in_bounds(front):
			continue
		var fz: int = bp.zone_at(front)
		if fz == ScenarioBlueprint.ZONE_VOID or fz == ScenarioBlueprint.ZONE_WATER or fz == ScenarioBlueprint.ZONE_BUILDING or fz == ScenarioBlueprint.ZONE_COURTYARD:
			continue
		var min_d: int = 999
		for cell: Vector2i in bp.road_cells.keys():
			min_d = mini(min_d, absi(front.x - cell.x) + absi(front.y - cell.y))
		for cell: Vector2i in bp.plaza_cells.keys():
			min_d = mini(min_d, absi(front.x - cell.x) + absi(front.y - cell.y))
		if min_d < best_dist:
			best_dist = min_d
			best_d = d
	return best_d


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


static func _median_height(bp: ScenarioBlueprint, origin: Vector2i, sz: Vector2i) -> int:
	var vals: Array[int] = []
	for dz: int in sz.y:
		for dx: int in sz.x:
			vals.append(bp.height_at(origin + Vector2i(dx, dz)))
	vals.sort()
	var mid: int = vals[vals.size() / 2]
	return clampi(mid, ScenarioBlueprint.MIN_PLAZA_LEVEL, ScenarioBlueprint.MAX_PLAZA_LEVEL)


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
static func _place_lamps(bp: ScenarioBlueprint) -> void:
	bp.lamps.clear()
	var front_cells: Dictionary = {}
	for comp: Dictionary in bp.compounds:
		front_cells[_front_of_pad(comp["origin"] as Vector2i, comp["size"] as Vector2i, int(comp["door_dir"]))] = true

	var placed_cells: Array[Vector2i] = []
	var road_keys: Array[Vector2i] = _sorted_cells(bp.road_cells)
	var lit_count: int = 0

	for road_cell: Vector2i in road_keys:
		if bp.stairs.has(road_cell) or bp.bridge_cells.has(road_cell):
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
			if _wall_uses_cell(bp, side):
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


static func _wall_uses_cell(bp: ScenarioBlueprint, cell: Vector2i) -> bool:
	for run: Dictionary in bp.wall_runs:
		var cells: Array = run.get("cells", [])
		for rc: Variant in cells:
			if (rc as Vector2i) == cell:
				return true
	return false


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
