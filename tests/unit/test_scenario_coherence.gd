extends GutTest
## TASK-053: contratos do algoritmo próprio Terrace-Grammar-Constraint (ADR-0041).
## Garante os 12 invariantes de coerência espacial, hidráulica, arquitetônica e de não-oclusão
## em 15 sementes de mapa e nos 11 dioramas focais.

const FOCAL_KINDS: Array[String] = [
	"combat_common", "combat_elite", "combat_boss",
	"campfire", "shop", "chest", "event", "reward", "home", "victory", "defeat",
]

var _data: GameData


func before_all() -> void:
	_data = DataLoader.load_all()


func test_map_scenarios_validate_all_12_invariants_across_seeds() -> void:
	for seed_value: int in range(1, 16):
		var run: RunState = RunState.new(_data, seed_value, "warrior", [], 0, null, true, [])
		var layout: Map3DLayout = Map3DLayout.new(run.map, seed_value)
		var violations: Array[String] = ScenarioValidator.validate(layout.blueprint, run.map)
		assert_eq(violations, [], "semente %d sem violações: %s" % [seed_value, ", ".join(violations)])
		assert_gt(layout.ruins.size(), 1, "semente %d tem compostos arquitetônicos" % seed_value)
		assert_gt(layout.water_cells.size(), 5, "semente %d tem canal contínuo >= 6 células" % seed_value)
		var cemeteries: int = 0
		for comp: Dictionary in layout.blueprint.compounds:
			if int(comp["kind"]) == ScenarioBlueprint.COMPOUND_CEMETERY:
				cemeteries += 1
		assert_lte(cemeteries, 2, "semente %d limita cemitérios para manter diversidade arquitetônica" % seed_value)
		for cell: Vector2i in layout.blueprint.typed_props.keys():
			var info: Dictionary = layout.blueprint.typed_props[cell]
			if str(info.get("context", "")) == "courtyard_edge":
				assert_false(str(info["asset"]).contains("barrel"), "sem barril colado fora de cemitério")


func test_focal_dioramas_all_validate_and_are_deterministic() -> void:
	for kind: String in FOCAL_KINDS:
		var a: ScenarioBlueprint = ScenarioGenerator.generate_focal_diorama(kind, 7)
		var b: ScenarioBlueprint = ScenarioGenerator.generate_focal_diorama(kind, 7)
		var violations: Array[String] = ScenarioValidator.validate(a, null)
		assert_eq(violations, [], "diorama focal '%s' coerente: %s" % [kind, ", ".join(violations)])
		assert_eq(a.heights, b.heights, "diorama '%s' determinístico em alturas" % kind)
		assert_eq(a.compounds, b.compounds, "diorama '%s' determinístico em compostos" % kind)


func test_no_tall_compound_occludes_any_destination_and_lamps_are_spaced() -> void:
	for seed_value: int in range(1, 10):
		var run: RunState = RunState.new(_data, seed_value, "warrior", [], 0, null, true, [])
		var layout: Map3DLayout = Map3DLayout.new(run.map, seed_value)
		var bp: ScenarioBlueprint = layout.blueprint
		for comp: Dictionary in bp.compounds:
			if bool(comp.get("tall", false)):
				for raw_c: Variant in comp["cells"]:
					var c: Vector2i = raw_c as Vector2i
					for node_id: int in bp.node_cells.keys():
						var nc: Vector2i = bp.node_cells[node_id]
						var dx: int = c.x - nc.x
						var dz: int = c.y - nc.y
						assert_false(dx >= 0 and dz >= 0 and dx <= 2 and dz <= 2, "composto alto não oclui nó %d" % node_id)
		for i: int in bp.lamps.size():
			var li: Dictionary = bp.lamps[i]
			var ci: Vector2i = li["cell"] as Vector2i
			var ri: Vector2i = li["road_cell"] as Vector2i
			assert_eq(bp.height_at(ci), bp.height_at(ri), "poste aterrado na altura da via")
			for j: int in range(i + 1, bp.lamps.size()):
				var cj: Vector2i = bp.lamps[j]["cell"] as Vector2i
				assert_gte(absi(ci.x - cj.x) + absi(ci.y - cj.y), ScenarioBlueprint.MIN_LAMP_SPACING, "postes espaçados >= 5")


func test_path_cells_tracks_actual_walkable_roads_between_linked_nodes() -> void:
	var run: RunState = RunState.new(_data, 7, "warrior", [], 0, null, true, [])
	var layout: Map3DLayout = Map3DLayout.new(run.map, 7)
	var bp: ScenarioBlueprint = layout.blueprint
	var start: MapNode = run.map.node_by_id(run.map.start_id)
	for next_id: int in start.next_ids:
		var path: Array[Vector2i] = layout.path_cells(bp.node_cells[start.id] as Vector2i, bp.node_cells[next_id] as Vector2i)
		assert_gt(path.size(), 2)
		for i: int in path.size():
			assert_true(bp.is_walkable(path[i]), "passo %s caminhável" % path[i])
			if i > 0:
				assert_eq(absi(path[i].x - path[i - 1].x) + absi(path[i].y - path[i - 1].y), 1, "passo ortogonal")
				assert_lte(absi(bp.height_at(path[i]) - bp.height_at(path[i - 1])), 1, "degrau máximo de 1 bloco no trajeto")


func test_shop_uses_the_merchant_sprite_and_never_the_gravedigger() -> void:
	var backdrop: Scene3DBackdrop = Scene3DBackdrop.new()
	backdrop.kind = "shop"
	backdrop.time_scale = 0.0
	add_child_autofree(backdrop)
	# TASK-068: a loja é a alcova pintada com o sprite do mercador; o diorama 3D só vale sem a textura.
	assert_true(backdrop._painted, "loja usa a arena pintada")
	assert_eq(str((Scene3DBackdrop.PAINTED["shop"] as Dictionary)["npc"]), "shop_keeper")
	assert_true(ModelRegistry.has_sprite("shop_keeper"))
	assert_ne(str((Scene3DBackdrop.PAINTED["shop"] as Dictionary)["npc"]), "gravedigger", "loja não reutiliza o chefe O Coveiro")


## TASK-073 (ADR-0060): gramática da cidade gótica. A planta do mapa precisa ser uma cidade que sobe
## até a igreja: rua principal contínua, chefe no ponto mais alto, portão do adro, casas com porta
## para a rua e nenhuma parede alta escondendo ruas na câmera isométrica.
func _generated(layers: int, seed_value: int) -> Array:
	var graph: MapGraph = MapGenerator.generate(MapConfig.for_layers(layers), RngStreams.new(seed_value).map())
	return [graph, ScenarioGenerator.generate_map(graph, seed_value)]


func test_city_grammar_validates_for_every_map_size() -> void:
	for layers: int in [3, 4, 6, 8]:
		for seed_value: int in range(1, 9):
			var made: Array = _generated(layers, seed_value)
			var graph: MapGraph = made[0] as MapGraph
			var bp: ScenarioBlueprint = made[1] as ScenarioBlueprint
			var violations: Array[String] = ScenarioValidator.validate(bp, graph)
			assert_eq(violations, [], "%d camadas, semente %d: %s" % [layers, seed_value, ", ".join(violations)])


func test_board_advances_along_the_camera_diagonal_toward_the_church() -> void:
	# A câmera olha de +X +Z para -X -Z: avançar uma camada tira LAYER_STEP de Z e NORTH_SHEAR de X,
	# então a rua principal sobe reto na tela, rumo à igreja pintada do horizonte (ADR-0060).
	var made: Array = _generated(4, 5)
	var graph: MapGraph = made[0] as MapGraph
	var bp: ScenarioBlueprint = made[1] as ScenarioBlueprint
	var start: Vector2i = bp.node_cells[graph.start_id] as Vector2i
	var boss: Vector2i = bp.node_cells[graph.boss_id] as Vector2i
	var layers_apart: int = graph.layer_count + 1
	assert_eq(start.y - boss.y, layers_apart * ScenarioGenerator.LAYER_STEP, "o chefe fica ao norte")
	assert_eq(start.x - boss.x, layers_apart * ScenarioGenerator.NORTH_SHEAR, "e deslocado na diagonal da câmera")
	for node: MapNode in graph.nodes:
		var cell: Vector2i = bp.node_cells[node.id] as Vector2i
		assert_eq(bp.layer_at_row(cell.y), node.layer, "a camada do nó %d bate com a linha (névoa por linha)" % node.id)


func test_boss_stands_on_the_highest_ground_in_front_of_the_church_gate() -> void:
	for seed_value: int in range(1, 10):
		var made: Array = _generated(4, seed_value)
		var graph: MapGraph = made[0] as MapGraph
		var bp: ScenarioBlueprint = made[1] as ScenarioBlueprint
		var boss: Vector2i = bp.node_cells[graph.boss_id] as Vector2i
		var boss_h: int = bp.height_at(boss)
		for cell: Vector2i in bp.road_cells.keys():
			assert_lt(bp.height_at(cell), boss_h, "rua %s abaixo do chefe" % cell)
		for node: MapNode in graph.nodes:
			if node.id != graph.boss_id:
				assert_lt(int(bp.node_levels[node.id]), boss_h, "nó %d abaixo do chefe" % node.id)
		var gate: Dictionary = {}
		for comp: Dictionary in bp.compounds:
			if int(comp["kind"]) == ScenarioBlueprint.COMPOUND_CHURCH_GATE:
				gate = comp
		assert_false(gate.is_empty(), "portão do adro")
		assert_eq((gate["center"] as Vector2i).x, boss.x, "o portão fica no eixo do chefe")
		assert_lt((gate["center"] as Vector2i).y, boss.y - 3, "o portão fica ao norte do chefe, com o adro no meio")
		assert_true(bp.stairs.has(boss + Vector2i(0, 2)), "escadaria sobe do patamar à praça do chefe")
		assert_true(bp.main_road.has(boss + Vector2i(0, 3)), "a rua principal chega pela escadaria")


func test_main_road_is_continuous_from_start_to_boss() -> void:
	for seed_value: int in range(1, 9):
		var made: Array = _generated(6, seed_value)
		var graph: MapGraph = made[0] as MapGraph
		var bp: ScenarioBlueprint = made[1] as ScenarioBlueprint
		var from_cell: Vector2i = bp.node_cells[graph.start_id] as Vector2i
		var to_cell: Vector2i = bp.node_cells[graph.boss_id] as Vector2i
		var seen: Dictionary = {from_cell: true}
		var queue: Array[Vector2i] = [from_cell]
		var head: int = 0
		while head < queue.size():
			var cur: Vector2i = queue[head]
			head += 1
			for d: int in ScenarioBlueprint.CARDINAL_DIRS:
				var nb: Vector2i = cur + ScenarioBlueprint.dir_vec(d)
				if bp.main_road.has(nb) and not seen.has(nb):
					seen[nb] = true
					queue.append(nb)
		assert_true(seen.has(to_cell), "semente %d: a rua principal liga a partida ao chefe" % seed_value)


func test_houses_face_the_street_and_tall_walls_never_hide_it() -> void:
	var houses: int = 0
	for seed_value: int in range(1, 9):
		var made: Array = _generated(4, seed_value)
		var bp: ScenarioBlueprint = made[1] as ScenarioBlueprint
		var hidden: Dictionary = ScenarioGenerator.occluding_cells(bp)
		for comp: Dictionary in bp.compounds:
			var kind: int = int(comp["kind"])
			if kind != ScenarioBlueprint.COMPOUND_HOUSE and kind != ScenarioBlueprint.COMPOUND_COTTAGE and kind != ScenarioBlueprint.COMPOUND_RUIN_HOUSE:
				continue
			houses += 1
			var front: Vector2i = ScenarioValidator._door_front_cell(comp)
			assert_true(bp.is_walkable(front), "a porta de %s dá para a rua" % comp["id"])
			assert_eq(bp.height_at(front), int(comp["height"]), "a porta fica no nível da rua")
			if kind == ScenarioBlueprint.COMPOUND_HOUSE:
				for raw: Variant in comp["cells"]:
					assert_false(hidden.has(raw as Vector2i), "casa alta %s não esconde a rua" % comp["id"])
	assert_gt(houses, 40, "a cidade tem casas e ruínas suficientes ao longo das ruas")


func test_each_kind_of_map_node_gets_its_own_place_in_the_city() -> void:
	var roles: Dictionary = {}
	for seed_value: int in range(1, 16):
		var made: Array = _generated(6, seed_value)
		var bp: ScenarioBlueprint = made[1] as ScenarioBlueprint
		for piece: Dictionary in bp.plaza_dress:
			roles[str(piece["role"])] = int(roles.get(str(piece["role"]), 0)) + 1
	for role: String in ["chest_room", "camp_shelter", "campo_santo", "armory_fence", "plaza_prop", "stair_rail"]:
		assert_gt(int(roles.get(role, 0)), 0, "existe cenografia '%s' (baú, fogueira, evento, elite...)" % role)


func test_city_blueprint_is_deterministic_by_seed() -> void:
	var a: ScenarioBlueprint = _generated(4, 21)[1] as ScenarioBlueprint
	var b: ScenarioBlueprint = _generated(4, 21)[1] as ScenarioBlueprint
	var c: ScenarioBlueprint = _generated(4, 22)[1] as ScenarioBlueprint
	assert_eq(a.heights, b.heights)
	assert_eq(a.compounds, b.compounds)
	assert_eq(a.plaza_dress, b.plaza_dress)
	assert_eq(a.main_road, b.main_road)
	assert_ne(a.compounds, c.compounds, "semente diferente muda as casas")
