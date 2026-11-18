extends GutTest
## TASK-009 (ADR-0013): o modelo da tela do mapa segue a névoa do GDD §5. Só os três
## destinos mostram tipo, inimigo e nível; à frente, silhuetas; o caminho feito marcado.

var _data: GameData


func before_all() -> void:
	_data = DataLoader.load_all()


func _view(run_seed: int = 1) -> MapView:
	return MapView.new(RunState.new(_data, run_seed))


func test_only_the_three_options_show_their_kind() -> void:
	var view: MapView = _view()
	var options: int = 0
	for node: Dictionary in view.nodes():
		var state: MapView.State = node["state"]
		if state == MapView.State.OPTION:
			options += 1
			assert_true(node["clickable"])
			assert_ne(str(node["title"]), "?")
			assert_eq(int(node["layer"]), 1)
		elif state == MapView.State.FOG:
			assert_false(node["clickable"])
			assert_eq(str(node["title"]), "?", "silhueta sem tipo")
			assert_eq(int(node["kind"]), -1)
			assert_eq(str(node["detail"]), "")
		elif state == MapView.State.BOSS:
			assert_eq(str(node["title"]), "Chefe", "o chefe sempre aparece")
	assert_eq(options, 3, "três destinos (GDD §5)")


func test_fight_options_show_enemy_and_level() -> void:
	var view: MapView = _view(2)
	for option: MapNode in view.run.options():
		var node: Dictionary = view.node_view(option)
		if option.is_fight():
			var name: String = str(_data.enemies[option.enemy_id]["name"])
			assert_eq(str(node["detail"]), "%s, nv %d" % [name, option.level])


func test_path_and_past_layers_after_moving() -> void:
	var view: MapView = _view(3)
	var run: RunState = view.run
	var first: MapNode = run.options()[0]
	first.kind = MapNode.Kind.CHEST
	first.enemy_id = ""
	var skipped: MapNode = run.options()[1]
	run.choose_node(first.id)
	assert_eq(view.state_of(first), MapView.State.CURRENT)
	assert_eq(view.state_of(skipped), MapView.State.PAST, "não visitado em camada passada")
	assert_eq(int(view.node_view(skipped)["kind"]), -1, "passado não revela o tipo")
	assert_eq(view.visited_ids(), PackedInt32Array([first.id]))
	for option: MapNode in run.options():
		assert_eq(view.state_of(option), MapView.State.OPTION)
		assert_eq(option.layer, 2)
	var lit: int = 0
	for edge: Array in view.edges():
		if bool(edge[2]):
			lit += 1
	assert_eq(lit, 4, "partida até o nó atual, e o nó atual até os três destinos")


func test_header_shows_run_numbers() -> void:
	var view: MapView = _view()
	var header: String = view.header()
	assert_string_contains(header, "Cidade Abandonada, camada 0 de 6")
	assert_string_contains(header, "Nível 1 (Poder 1.00)   Ouro 0   Derrotados 0")
	assert_string_contains(header, "FOR 14")
	assert_string_contains(header, "HP 130/130   MP 20/20   Poções 2")
