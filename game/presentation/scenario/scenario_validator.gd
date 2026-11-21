class_name ScenarioValidator
extends RefCounted
## Auditor determinístico de coerência espacial e arquitetônica (ADR-0041, TASK-053).
## Verifica os 12 invariantes estruturais de uma [ScenarioBlueprint] antes de renderizar e nos
## testes automatizados. Retorna uma lista de violações legíveis (vazia = cenário 100% coerente).


static func validate(bp: ScenarioBlueprint, graph: MapGraph = null) -> Array[String]:
	var errors: Array[String] = []
	if bp == null or bp.cols <= 0 or bp.rows <= 0:
		errors.append("planta nula ou com dimensões inválidas")
		return errors
	if bp.heights.size() != bp.cols * bp.rows or bp.zones.size() != bp.cols * bp.rows:
		errors.append("tamanhos de heights/zones incompatíveis com cols*rows")
		return errors

	_check_plazas(bp, graph, errors)
	_check_edge_paths(bp, graph, errors)
	_check_walkable_steps_and_stairs(bp, errors)
	_check_water_and_bridges(bp, errors)
	_check_compounds_and_occlusion(bp, errors)
	_check_wall_runs(bp, errors)
	_check_lamps(bp, errors)
	_check_props_and_destinations(bp, errors)
	return errors


static func summary(bp: ScenarioBlueprint) -> Dictionary:
	return {
		"cols": bp.cols,
		"rows": bp.rows,
		"plazas": bp.plaza_cells.size(),
		"roads": bp.road_cells.size(),
		"bridges": bp.bridge_cells.size(),
		"stairs": bp.stairs.size(),
		"water": bp.water_cells.size(),
		"compounds": bp.compounds.size(),
		"wall_runs": bp.wall_runs.size(),
		"lamps": bp.lamps.size(),
		"props": bp.typed_props.size(),
	}


static func _check_plazas(bp: ScenarioBlueprint, graph: MapGraph, errors: Array[String]) -> void:
	if graph != null:
		for node: MapNode in graph.nodes:
			if not bp.node_cells.has(node.id):
				errors.append("nó %d sem node_cells" % node.id)
				continue
			var center: Vector2i = bp.node_cells[node.id]
			if not bp.plaza_cells.has(center):
				errors.append("nó %d fora de plaza_cells em %s" % [node.id, center])
				continue
			var expected_h: int = int(bp.node_levels.get(node.id, -99))
			if not bp.is_focal:
				for dz: int in range(-1, 2):
					for dx: int in range(-1, 2):
						var cell: Vector2i = Vector2i(center.x + dx, center.y + dz)
						if not bp.plaza_cells.has(cell) or bp.zone_at(cell) != ScenarioBlueprint.ZONE_PLAZA:
							errors.append("praça incompleta do nó %d em %s" % [node.id, cell])
						elif bp.height_at(cell) != expected_h:
							errors.append("desnível na praça do nó %d em %s" % [node.id, cell])
	if not bp.is_focal:
		for node_id: int in bp.node_cells.keys():
			var c: Vector2i = bp.node_cells[node_id]
			if bp.water_cells.has(c) or bp.zone_at(c) == ScenarioBlueprint.ZONE_VOID:
				errors.append("nó %d sobre água ou vazio" % node_id)


static func _check_edge_paths(bp: ScenarioBlueprint, graph: MapGraph, errors: Array[String]) -> void:
	if graph == null:
		return
	var reachable: PackedInt32Array = graph.reachable_ids()
	for node: MapNode in graph.nodes:
		if not reachable.has(node.id):
			continue
		for next_id: int in node.next_ids:
			var key: String = "%d:%d" % [node.id, next_id]
			if not bp.edge_paths.has(key):
				errors.append("aresta %s sem caminho em edge_paths" % key)
				continue
			var path: Array = bp.edge_paths[key]
			if path.size() < 2:
				errors.append("aresta %s com caminho curto demais" % key)
				continue
			if (path[0] as Vector2i) != (bp.node_cells[node.id] as Vector2i) or (path[path.size() - 1] as Vector2i) != (bp.node_cells[next_id] as Vector2i):
				errors.append("aresta %s não liga os centros exatos dos nós" % key)
				continue
			for i: int in path.size():
				var cell: Vector2i = path[i] as Vector2i
				if not bp.is_walkable(cell) or bp.water_cells.has(cell) or bp.zone_at(cell) == ScenarioBlueprint.ZONE_VOID:
					errors.append("aresta %s passa por célula não caminhável %s" % [key, cell])
					break
				if i > 0:
					var prev: Vector2i = path[i - 1] as Vector2i
					var manh: int = absi(cell.x - prev.x) + absi(cell.y - prev.y)
					if manh != 1:
						errors.append("aresta %s tem salto não ortogonal %s -> %s" % [key, prev, cell])
						break


static func _check_walkable_steps_and_stairs(bp: ScenarioBlueprint, errors: Array[String]) -> void:
	for cell: Vector2i in bp.road_cells.keys():
		if bp.plaza_cells.has(cell):
			errors.append("célula %s está em road_cells e plaza_cells ao mesmo tempo" % cell)
		if bp.zone_at(cell) != ScenarioBlueprint.ZONE_ROAD and bp.zone_at(cell) != ScenarioBlueprint.ZONE_BRIDGE:
			errors.append("estrada %s com zona inconsistente %d" % [cell, bp.zone_at(cell)])
		var h: int = bp.height_at(cell)
		for d: int in ScenarioBlueprint.CARDINAL_DIRS:
			var near: Vector2i = cell + ScenarioBlueprint.dir_vec(d)
			if bp.is_walkable(near) and absi(h - bp.height_at(near)) > 1:
				errors.append("degrau > 1 entre células caminháveis %s (%d) e %s (%d)" % [cell, h, near, bp.height_at(near)])

	for cell: Vector2i in bp.stairs.keys():
		if not bp.road_cells.has(cell) or bp.plaza_cells.has(cell):
			errors.append("degrau %s fora de estrada" % cell)
			continue
		if bp.bridge_cells.has(cell):
			errors.append("degrau %s sobre ponte" % cell)
			continue
		var h: int = bp.height_at(cell)
		var higher: Array[int] = []
		for d: int in ScenarioBlueprint.CARDINAL_DIRS:
			var near: Vector2i = cell + ScenarioBlueprint.dir_vec(d)
			if bp.is_walkable(near) and bp.height_at(near) == h + 1:
				higher.append(d)
		if higher.size() != 1:
			errors.append("degrau %s com %d vizinhos mais altos (esperado 1)" % [cell, higher.size()])
			continue
		var expected_yaw: float = ScenarioBlueprint.dir_yaw(higher[0])
		if not is_equal_approx(float(bp.stairs[cell]), expected_yaw):
			errors.append("degrau %s com yaw %.0f (esperado %.0f)" % [cell, float(bp.stairs[cell]), expected_yaw])


static func _check_water_and_bridges(bp: ScenarioBlueprint, errors: Array[String]) -> void:
	for cell: Vector2i in bp.water_cells.keys():
		if bp.zone_at(cell) != ScenarioBlueprint.ZONE_WATER:
			errors.append("água %s com zona %d" % [cell, bp.zone_at(cell)])
		if bp.road_cells.has(cell) or bp.plaza_cells.has(cell):
			errors.append("água %s invade estrada ou praça" % cell)
		if bp.zone_at(cell) == ScenarioBlueprint.ZONE_BUILDING or bp.zone_at(cell) == ScenarioBlueprint.ZONE_COURTYARD:
			errors.append("água %s invade composto" % cell)

	# Conectividade por BFS: nenhuma poça isolada menor que MIN_WATER_COMPONENT.
	var visited: Dictionary = {}
	for start: Vector2i in bp.water_cells.keys():
		if visited.has(start):
			continue
		var queue: Array[Vector2i] = [start]
		visited[start] = true
		var comp_size: int = 0
		var head: int = 0
		while head < queue.size():
			var cur: Vector2i = queue[head]
			head += 1
			comp_size += 1
			for d: int in ScenarioBlueprint.CARDINAL_DIRS:
				var near: Vector2i = cur + ScenarioBlueprint.dir_vec(d)
				if bp.water_cells.has(near) and not visited.has(near):
					visited[near] = true
					queue.append(near)
		if comp_size < ScenarioBlueprint.MIN_WATER_COMPONENT:
			errors.append("poça d'água isolada em %s com %d células (< %d)" % [start, comp_size, ScenarioBlueprint.MIN_WATER_COMPONENT])

	for cell: Vector2i in bp.bridge_cells.keys():
		if not bp.road_cells.has(cell) or bp.zone_at(cell) != ScenarioBlueprint.ZONE_BRIDGE:
			errors.append("ponte %s não registrada como estrada/ponte" % cell)
		if bp.water_cells.has(cell):
			errors.append("ponte %s em water_cells" % cell)


static func _check_compounds_and_occlusion(bp: ScenarioBlueprint, errors: Array[String]) -> void:
	var occupied: Dictionary = {}
	for comp: Dictionary in bp.compounds:
		var cid: String = str(comp.get("id", "?"))
		var kind: int = int(comp.get("kind", -1))
		var h: int = int(comp.get("height", -99))
		var door_dir: int = int(comp.get("door_dir", -1))
		var cells: Array = comp.get("cells", [])
		if cells.is_empty():
			errors.append("composto %s vazio" % cid)
			continue
		for raw_c: Variant in cells:
			var cell: Vector2i = raw_c as Vector2i
			if not bp.in_bounds(cell) or bp.zone_at(cell) == ScenarioBlueprint.ZONE_VOID:
				errors.append("composto %s fora da planta em %s" % [cid, cell])
			if occupied.has(cell):
				errors.append("compostos sobrepostos em %s (%s e %s)" % [cell, cid, occupied[cell]])
			occupied[cell] = cid
			if bp.plaza_cells.has(cell) or bp.road_cells.has(cell) or bp.water_cells.has(cell):
				errors.append("composto %s sobre praça/estrada/água em %s" % [cid, cell])
			if bp.height_at(cell) != h:
				errors.append("composto %s desnivelado em %s (%d != %d)" % [cid, cell, bp.height_at(cell), h])
			if ScenarioBlueprint.is_tall_compound(kind):
				for node_id: int in bp.node_cells.keys():
					var nc: Vector2i = bp.node_cells[node_id]
					var dx: int = cell.x - nc.x
					var dz: int = cell.y - nc.y
					if dx >= 0 and dz >= 0 and dx <= 2 and dz <= 2:
						errors.append("composto alto %s oclui nó %d em %s" % [cid, node_id, cell])
		if door_dir >= 0:
			var front: Vector2i = _door_front_cell(comp)
			if bp.in_bounds(front):
				var fz: int = bp.zone_at(front)
				if fz == ScenarioBlueprint.ZONE_WATER or fz == ScenarioBlueprint.ZONE_BUILDING:
					errors.append("porta do composto %s abre para água ou parede em %s" % [cid, front])
				if bp.height_at(front) > h + 1:
					errors.append("porta do composto %s bloqueada por muro/penhasco alto em %s" % [cid, front])


static func _door_front_cell(comp: Dictionary) -> Vector2i:
	var origin: Vector2i = comp["origin"] as Vector2i
	var sz: Vector2i = comp["size"] as Vector2i
	var door_dir: int = int(comp["door_dir"])
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


static func _check_wall_runs(bp: ScenarioBlueprint, errors: Array[String]) -> void:
	for run: Dictionary in bp.wall_runs:
		var cells: Array = run.get("cells", [])
		var h: int = int(run.get("height", -99))
		if cells.size() < ScenarioBlueprint.MIN_WALL_RUN_LEN:
			errors.append("muro isolado com %d célula(s)" % cells.size())
			continue
		for raw_c: Variant in cells:
			var cell: Vector2i = raw_c as Vector2i
			if not bp.is_solid(cell):
				errors.append("muro sobre vazio em %s" % cell)
			elif bp.height_at(cell) != h:
				errors.append("muro desnivelado em %s" % cell)
			elif bp.plaza_cells.has(cell) or bp.road_cells.has(cell) or bp.water_cells.has(cell):
				errors.append("muro invade praça/estrada/água em %s" % cell)


static func _check_lamps(bp: ScenarioBlueprint, errors: Array[String]) -> void:
	var placed: Array[Vector2i] = []
	for lamp: Dictionary in bp.lamps:
		var cell: Vector2i = lamp["cell"] as Vector2i
		var road_cell: Vector2i = lamp["road_cell"] as Vector2i
		var h: int = int(lamp["height"])
		if not bp.is_solid(cell) or bp.is_walkable(cell) or bp.water_cells.has(cell):
			errors.append("poste %s em célula inválida" % cell)
			continue
		var z: int = bp.zone_at(cell)
		if z == ScenarioBlueprint.ZONE_BUILDING or z == ScenarioBlueprint.ZONE_COURTYARD:
			errors.append("poste %s dentro de composto" % cell)
			continue
		if not bp.is_walkable(road_cell) or absi(cell.x - road_cell.x) + absi(cell.y - road_cell.y) != 1:
			errors.append("poste %s sem via adjacente válida em %s" % [cell, road_cell])
			continue
		if bp.height_at(cell) != h or bp.height_at(road_cell) != h:
			errors.append("poste %s fora do nível da via (%d vs %d)" % [cell, bp.height_at(cell), bp.height_at(road_cell)])
		var road_dir: int = ScenarioBlueprint.dir_from_vec(road_cell - cell)
		var expected_yaw: float = ScenarioBlueprint.dir_yaw(ScenarioBlueprint.dir_opposite(road_dir))
		if not is_equal_approx(float(lamp["yaw"]), expected_yaw):
			errors.append("poste %s com yaw %.0f (esperado %.0f para via)" % [cell, float(lamp["yaw"]), expected_yaw])
		for prev: Vector2i in placed:
			if absi(prev.x - cell.x) + absi(prev.y - cell.y) < ScenarioBlueprint.MIN_LAMP_SPACING:
				errors.append("postes muito próximos em %s e %s" % [prev, cell])
		placed.append(cell)


static func _check_props_and_destinations(bp: ScenarioBlueprint, errors: Array[String]) -> void:
	var lamp_set: Dictionary = {}
	for lamp: Dictionary in bp.lamps:
		lamp_set[lamp["cell"] as Vector2i] = true

	for cell: Vector2i in bp.typed_props.keys():
		var info: Dictionary = bp.typed_props[cell]
		var asset: String = str(info.get("asset", ""))
		var ctx: String = str(info.get("context", ""))
		if not bp.is_solid(cell) or bp.is_walkable(cell) or bp.water_cells.has(cell):
			errors.append("prop em célula proibida %s" % cell)
			continue
		if lamp_set.has(cell):
			errors.append("prop sobreposte em %s" % cell)
			continue
		if asset.contains("pine") or asset.contains("wall") or asset.contains("fence") or asset.contains("lightpost") or asset.contains("gravestone"):
			errors.append("prop avulso proibido (%s) em %s" % [asset, cell])
		if ctx == "courtyard_edge" and (asset.contains("barrel") or asset.contains("bench")):
			errors.append("barril/banco fora de contexto junto a pátio/cemitério em %s" % cell)
		if ctx.is_empty():
			errors.append("prop sem contexto em %s" % cell)

	if not bp.is_focal:
		for node_id: int in bp.node_cells.keys():
			var nc: Vector2i = bp.node_cells[node_id]
			var nl: int = int(bp.node_levels.get(node_id, 99))
			for dz: int in range(-2, 3):
				for dx: int in range(-2, 3):
					var c: Vector2i = Vector2i(nc.x + dx, nc.y + dz)
					if bp.typed_props.has(c):
						errors.append("prop invade área 5x5 do nó %d em %s" % [node_id, c])
					if dx >= 0 and dz >= 0 and (bp.zone_at(c) == ScenarioBlueprint.ZONE_TERRACE or bp.zone_at(c) == ScenarioBlueprint.ZONE_EMBANKMENT):
						if bp.height_at(c) > nl:
							errors.append("terraço alto %s (%d > %d) oclui cone frontal do nó %d" % [c, bp.height_at(c), nl, node_id])
