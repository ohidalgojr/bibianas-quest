extends GutTest
## TASK-067 (ADR-0054): contratos do mapa pintado. A estética é julgada no print.

var _data: GameData


func before_all() -> void:
	_data = DataLoader.load_all()


func _screen(seed_value: int, preview: bool = false) -> PaintedMapScreen:
	var run: RunState = RunState.new(_data, seed_value, "warrior", [], 0, null, true, [])
	var screen: PaintedMapScreen = PaintedMapScreen.new()
	screen.view = MapView.new(run)
	screen.time_scale = 0.0
	screen.preview_enabled = preview
	add_child_autofree(screen)
	return screen


func test_every_option_has_a_tap_area_inside_the_screen() -> void:
	var screen: PaintedMapScreen = _screen(3)
	for node: MapNode in screen.view.run.options():
		var tap: Button = screen.button_for(node.id)
		assert_not_null(tap, "destino %d tem área de toque" % node.id)
		assert_true(tap.size.x >= 48.0 and tap.size.y >= 48.0, "toque mínimo de 48 px")
		assert_true(tap.position.x >= 0.0 and tap.position.x + tap.size.x <= PaintedMapScreen.WIDTH, "toque dentro da largura")


func test_pills_never_leave_the_screen() -> void:
	for seed_value: int in [1, 3, 7, 11]:
		var screen: PaintedMapScreen = _screen(seed_value)
		for id: int in screen._bubbles.keys():
			var row: Control = screen._bubbles[id]
			assert_gte(row.position.x, 0.0, "pílula do nó %d (semente %d) cortada à esquerda" % [id, seed_value])
			assert_lte(row.position.x + row.size.x, PaintedMapScreen.WIDTH, "pílula do nó %d (semente %d) cortada à direita" % [id, seed_value])


func test_hero_stands_at_the_current_node_and_camera_puts_it_low_on_screen() -> void:
	var screen: PaintedMapScreen = _screen(5)
	var at: Vector2 = screen.world_pos(screen.view.run.current_node_id)
	assert_lt(screen._hero.position.distance_to(at + Vector2(0.0, 6.0)), 0.5)
	var on_screen: float = at.y + screen._world.position.y
	assert_gt(on_screen, 500.0, "herói na metade de baixo da tela")
	assert_lt(on_screen, 800.0)


func test_tap_emits_the_choice_without_preview() -> void:
	var screen: PaintedMapScreen = _screen(3)
	var chosen: Array[int] = []
	screen.node_chosen.connect(func(id: int) -> void: chosen.append(id))
	var target: int = screen.view.run.options()[0].id
	screen.button_for(target).pressed.emit()
	assert_eq(chosen, [target])


func test_first_tap_opens_preview_and_caminhar_confirms() -> void:
	var screen: PaintedMapScreen = _screen(5, true)
	var chosen: Array[int] = []
	screen.node_chosen.connect(func(id: int) -> void: chosen.append(id))
	var target: int = screen.view.run.options()[0].id
	screen.button_for(target).pressed.emit()
	assert_true(chosen.is_empty())
	assert_not_null(screen._preview_card)
	for node: Node in screen._preview_card.find_children("*", "Button", true, false):
		if (node as Button).text == "Caminhar":
			(node as Button).pressed.emit()
	assert_eq(chosen, [target])


func test_walk_animation_ends_at_the_destination_then_emits() -> void:
	var run: RunState = RunState.new(_data, 3, "warrior", [], 0, null, true, [])
	var screen: PaintedMapScreen = PaintedMapScreen.new()
	screen.view = MapView.new(run)
	screen.time_scale = 8.0
	screen.preview_enabled = false
	add_child_autofree(screen)
	var target: int = run.options()[0].id
	watch_signals(screen)
	screen.button_for(target).pressed.emit()
	await wait_for_signal(screen.node_chosen, 6.0)
	assert_signal_emitted_with_parameters(screen, "node_chosen", [target])
