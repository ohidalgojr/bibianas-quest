extends GutTest
## TASK-006: a tela de combate abre em headless e uma luta inteira é jogada pelos
## botões, com animação instantânea.

var _screen: CombatScreen


func before_each() -> void:
	_screen = CombatScreen.new()
	_screen.time_scale = 0.0
	add_child_autofree(_screen)


func _button(action: String) -> Button:
	return _screen._buttons[action]


func test_opens_with_debug_menu() -> void:
	assert_true(_screen.data.is_valid())
	assert_true(_screen._menu.visible, "começa no seletor de luta")
	assert_eq(_screen._menu_enemies.get_child_count(), 13, "10 comuns, 2 elites e o chefe")
	assert_true(_button("attack").disabled, "sem luta, sem ação")


func test_fight_is_played_through_buttons_until_the_end() -> void:
	var finished: Array[int] = []
	_screen.fight_finished.connect(func(outcome: int) -> void: finished.append(outcome))
	_screen.start_fight("infected_citizen", 1, 1.0, 5)
	assert_false(_screen._menu.visible)
	assert_string_contains(_screen._enemy_name.text, "Cidadão Infectado")
	var presses: int = 0
	while finished.is_empty() and presses < 200:
		presses += 1
		var potion: Button = _button("potion")
		if not potion.disabled and _screen._player_hp * 100 < _screen._player_hp_bar.max_value * 35:
			potion.pressed.emit()
		else:
			_button("attack").pressed.emit()
	assert_eq(finished.size(), 1, "a luta terminou")
	assert_true(_screen._menu.visible, "o resultado aparece com o seletor para lutar de novo")
	assert_eq(_screen._menu_title.text, _screen.session.outcome_text())
	assert_eq(_screen._player_hp, _screen.session.combat.player.hp, "a barra seguiu os eventos")
	assert_eq(_screen._enemy_hp, _screen.session.combat.enemy.hp, "a barra seguiu os eventos")


func test_flee_button_is_disabled_against_boss() -> void:
	_screen.start_fight("gravedigger", 6, 1.0, 9)
	assert_true(_button("flee").disabled)
	assert_false(_button("attack").disabled)


func test_coin_intent_turns_panel_gold() -> void:
	_screen.start_fight("gravedigger", 6, 1.0, 9)
	_screen._show_intent("shovel")
	assert_eq(_screen._intent_panel.self_modulate, CombatScreen.COLOR_COIN)
	assert_string_contains(_screen._intent_icon.text, "MOEDA")
	assert_string_contains(_screen._intent_detail.text, "Escolha Cara ou Coroa")


## ADR-0014: com tempo normal o lance espera o botão e devolve o lado apertado.
func test_coin_waits_for_the_player_to_pick_a_side() -> void:
	_screen.time_scale = 1.0
	var picked: Array[int] = []
	var ask: Callable = func() -> void:
		picked.append(await _screen._ask_call(55))
	ask.call()
	assert_true(_screen._call_row.visible, "os botões Cara e Coroa aparecem")
	assert_true(picked.is_empty(), "sem escolha, a moeda não gira")
	_screen._call_buttons[1].pressed.emit()
	assert_eq(picked, [CoinRules.TAILS] as Array[int])
	assert_false(_screen._call_row.visible)


func test_coin_uses_auto_call_without_time() -> void:
	_screen.auto_call = CoinRules.TAILS
	var picked: int = await _screen._ask_call(55)
	assert_eq(picked, CoinRules.TAILS)


## ADR-0021: o abate do inimigo apaga a forma dele na tela e a vitória mostra o resultado.
func test_enemy_fades_when_defeated_and_resets_on_next_fight() -> void:
	_screen.start_fight("giant_rat", 1, 1.0, 5)
	var guard: int = 0
	while not _screen.session.is_over() and guard < 100:
		guard += 1
		_button("attack").pressed.emit()
	if _screen.session.combat.outcome == Combat.Outcome.VICTORY:
		assert_lt(_screen._enemy_shape.modulate.a, 1.0, "o inimigo derrotado some")
	_screen.start_fight("giant_rat", 1, 1.0, 6)
	assert_eq(_screen._enemy_shape.modulate.a, 1.0, "a próxima luta começa com o inimigo visível")
