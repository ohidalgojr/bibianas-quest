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
