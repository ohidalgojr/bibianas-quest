extends GutTest
## TASK-009: uma Descida inteira jogada pelos botões das telas, com animação instantânea
## e sem checagem de mapa (para caber na suíte).

var _game: GameScreen


func before_each() -> void:
	_game = GameScreen.new()
	_game.map_check_runs = 0
	_game.use_thread = false
	_game.time_scale = 0.0
	add_child_autofree(_game)


## Aperta o primeiro botão habilitado de [param root] cujo texto começa com [param text].
func _press(root: Node, text: String) -> bool:
	for child: Node in root.find_children("*", "Button", true, false):
		var button: Button = child
		if button.visible and not button.disabled and button.text.begins_with(text):
			button.pressed.emit()
			return true
	return false


func test_home_offers_new_run_and_test_fight() -> void:
	assert_true(_game.find_children("*", "Button", true, false).size() >= 2)
	assert_true(_press(_game, "Luta de teste"))
	assert_eq(_game.find_children("*", "CombatScreen", true, false).size(), 1)


func test_full_run_through_the_screens() -> void:
	var ended: Array[bool] = []
	_game.run_ended.connect(func(victory: bool) -> void: ended.append(victory))
	_game.new_run(11)
	var run: RunState = _game.run
	assert_not_null(run)
	var steps: int = 0
	var fights: int = 0
	var rewards: int = 0
	while ended.is_empty() and steps < 400:
		steps += 1
		match run.phase:
			RunState.Phase.CHOOSING:
				var target: int = run.options()[0].id
				var button: Button = _game._map.button_for(target)
				assert_not_null(button, "o destino tem botão")
				assert_false(button.disabled)
				button.pressed.emit()
			RunState.Phase.FIGHT:
				var screen: CombatScreen = _game._combat
				if screen._menu.visible:
					fights += 1
					assert_true(screen._continue.visible, "na Descida, o fim da luta mostra Continuar")
					screen._continue.pressed.emit()
				elif not screen._buttons["potion"].disabled and screen._player_hp * 100 < screen._player_hp_bar.max_value * 35:
					screen._buttons["potion"].pressed.emit()
				else:
					screen._buttons["attack"].pressed.emit()
			RunState.Phase.SHOP:
				# A recompensa vem antes da loja (TASK-010).
				if _press(_game, "Continuar"):
					rewards += 1
				assert_true(_press(_game, "Seguir"))
			RunState.Phase.CAMPFIRE:
				_press(_game, "Descansar")
				assert_true(_press(_game, "Seguir"))
			_:
				break
	assert_eq(ended.size(), 1, "a Descida terminou pelas telas")
	assert_gt(fights, 0)
	assert_gt(rewards, 0, "a recompensa apareceu antes da loja")
	assert_true(run.is_over())
	assert_true(_press(_game, "Outra Descida"), "o resultado oferece nova Descida")


## A luta da Descida começa com a vida que a Bibiana tinha no mapa.
func test_run_fight_uses_run_hp() -> void:
	_game.new_run(5)
	var run: RunState = _game.run
	var option: MapNode = run.options()[0]
	option.kind = MapNode.Kind.BATTLE
	option.enemy_id = "giant_rat"
	option.level = 1
	run.hp = 77
	_game.choose_node(option.id)
	var screen: CombatScreen = _game._combat
	var expected: int = 77
	for event: CombatEvent in run.combat.history:
		if event.type == CombatEvent.Type.DAMAGE and event.side == Combatant.PLAYER:
			expected = event.extra
	assert_eq(screen._player_hp, expected)
	assert_eq(screen.session.potions_count(), run.consumable_count("murky_potion"))


## TASK-011: o menu mostra Ecos e classe, e três Descidas seguidas rodam sem reiniciar,
## com os Ecos acumulando.
func test_three_runs_in_a_row_accumulate_echoes() -> void:
	assert_true(_game.echoes == 0)
	var labels: PackedStringArray = PackedStringArray()
	for label: Node in _game.find_children("*", "Label", true, false):
		labels.append((label as Label).text)
	assert_string_contains("\n".join(labels), "Ecos: 0")
	assert_string_contains("\n".join(labels), "Classe: Guerreiro")
	var total: int = 0
	for index: int in 3:
		var ended: Array[bool] = []
		_game.run_ended.connect(func(victory: bool) -> void: ended.append(victory))
		if index == 0:
			assert_true(_press(_game, "Nova Descida"))
		else:
			assert_true(_press(_game, "Outra Descida"))
		var steps: int = 0
		while ended.is_empty() and steps < 600:
			steps += 1
			_play_step(_game.run)
		assert_eq(ended.size(), 1, "a Descida %d terminou" % (index + 1))
		total += _game.run.echoes_earned()
		assert_eq(_game.echoes, total)
	assert_eq(_game.runs_played, 3)
	assert_gt(_game.echoes, 0)


## Um passo de jogador automático pelos botões.
func _play_step(run: RunState) -> void:
	match run.phase:
		RunState.Phase.CHOOSING:
			_game._map.button_for(run.options()[0].id).pressed.emit()
		RunState.Phase.FIGHT:
			var screen: CombatScreen = _game._combat
			if screen._menu.visible:
				screen._continue.pressed.emit()
			elif not screen._buttons["potion"].disabled and screen._player_hp * 100 < screen._player_hp_bar.max_value * 35:
				screen._buttons["potion"].pressed.emit()
			else:
				screen._buttons["attack"].pressed.emit()
		RunState.Phase.SHOP:
			_press(_game, "Continuar")
			_press(_game, "Seguir")
		RunState.Phase.CAMPFIRE:
			_press(_game, "Descansar")
			_press(_game, "Seguir")
