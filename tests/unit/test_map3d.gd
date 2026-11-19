extends GutTest
## TASK-036: contratos do tabuleiro 3D. A planta é determinística, os destinos ficam livres, a névoa
## esconde o que vem depois e o toque num destino avança a Descida. A estética é julgada no print.

var _data: GameData


func before_all() -> void:
	_data = DataLoader.load_all()


func _run(seed_value: int) -> RunState:
	return RunState.new(_data, seed_value, "warrior", [], 0, null, true, [])


func test_layout_is_deterministic_by_seed() -> void:
	var run: RunState = _run(11)
	var a: Map3DLayout = Map3DLayout.new(run.map, 11)
	var b: Map3DLayout = Map3DLayout.new(run.map, 11)
	assert_eq(a.props, b.props)
	assert_eq(a.road_cells, b.road_cells)
	assert_eq(a.heights, b.heights)
	var other: Map3DLayout = Map3DLayout.new(run.map, 12)
	assert_ne(a.props, other.props, "semente diferente muda o enfeite")


func test_every_node_has_a_plaza_and_the_destinations_stay_free_of_props() -> void:
	for seed_value: int in [1, 2, 3, 4, 5]:
		var run: RunState = _run(seed_value)
		var layout: Map3DLayout = Map3DLayout.new(run.map, seed_value)
		for node: MapNode in run.map.nodes:
			var cell: Vector2i = layout.node_cells[node.id]
			assert_true(layout.plaza_cells.has(cell), "praça do nó %d" % node.id)
			for dz: int in range(-2, 3):
				for dx: int in range(-2, 3):
					assert_false(layout.props.has(Vector2i(cell.x + dx, cell.y + dz)), "prop perto do nó %d (semente %d)" % [node.id, seed_value])


func test_terrain_rises_with_the_layers_and_roads_connect_the_plazas() -> void:
	var run: RunState = _run(3)
	var layout: Map3DLayout = Map3DLayout.new(run.map, 3)
	var start_h: int = layout.height_at(layout.node_cells[run.map.start_id])
	var boss: MapNode = run.map.nodes[run.map.nodes.size() - 1]
	for node: MapNode in run.map.nodes:
		if node.kind == MapNode.Kind.BOSS:
			boss = node
	assert_gt(layout.height_at(layout.node_cells[boss.id]), start_h, "o chefe fica no ponto mais alto")
	assert_gt(layout.road_cells.size(), 10)
	assert_gt(layout.stairs.size(), 0, "há degraus onde a altura muda")


func test_fog_hides_what_comes_after_the_destinations() -> void:
	var run: RunState = _run(3)
	var screen: Map3DScreen = Map3DScreen.new()
	screen.view = MapView.new(run)
	screen.time_scale = 0.0
	add_child_autofree(screen)
	var layout: Map3DLayout = screen.layout
	var option: MapNode = run.options()[0]
	var option_cell: Vector2i = layout.node_cells[option.id]
	var alphas: PackedFloat32Array = screen._fog_alphas(run.current_node().layer, screen.view.visible_layer())
	assert_eq(alphas[option_cell.y * layout.cols + option_cell.x], 0.0, "o destino aparece limpo")
	var far_z: int = option_cell.y - Map3DLayout.LAYER_STEP * 2
	assert_gt(alphas[far_z * layout.cols + option_cell.x], 0.6, "duas camadas adiante estão sob névoa")


func test_tapping_a_destination_emits_the_choice() -> void:
	var run: RunState = _run(3)
	var screen: Map3DScreen = Map3DScreen.new()
	screen.view = MapView.new(run)
	screen.time_scale = 0.0
	add_child_autofree(screen)
	var chosen: Array[int] = []
	screen.node_chosen.connect(func(id: int) -> void: chosen.append(id))
	var target: int = run.options()[0].id
	var tap: Button = screen.button_for(target)
	assert_not_null(tap, "o destino tem área de toque")
	tap.pressed.emit()
	assert_eq(chosen, [target])
	assert_true(tap.size.x >= 48.0 and tap.size.y >= 48.0, "toque mínimo de 48 px")


func test_game_screen_uses_the_3d_map_when_enabled() -> void:
	var game: GameScreen = GameScreen.new()
	game.map_check_runs = 0
	game.use_thread = false
	game.save_enabled = false
	game.telemetry_enabled = false
	game.debug_enabled = false
	game.time_scale = 0.0
	game.use_3d_map = true
	add_child_autofree(game)
	game.new_run(5)
	assert_not_null(game._map3d, "o mapa 3D está na tela")


func test_walk_animation_reaches_the_destination_then_emits() -> void:
	var run: RunState = _run(3)
	var screen: Map3DScreen = Map3DScreen.new()
	screen.view = MapView.new(run)
	screen.time_scale = 8.0
	add_child_autofree(screen)
	var target: int = run.options()[0].id
	watch_signals(screen)
	screen.button_for(target).pressed.emit()
	await wait_for_signal(screen.node_chosen, 6.0)
	assert_signal_emitted_with_parameters(screen, "node_chosen", [target])
	var goal: Vector3 = screen.layout.node_world(target)
	assert_lt(screen._hero.position.distance_to(goal), 0.05, "a Bibiana chegou à praça")
