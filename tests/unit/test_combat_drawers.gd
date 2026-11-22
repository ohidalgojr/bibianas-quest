extends GutTest
## TASK-056 (ADR-0044): gavetas do combate e confirmação em dois toques (D-UI-1, D-UI-2).

var _screen: CombatScreen


func before_each() -> void:
	_screen = CombatScreen.new()
	_screen.time_scale = 0.0
	add_child_autofree(_screen)
	_screen.start_fight("infected_citizen", 3, 2.0, 11)


func _button(action: String) -> Button:
	return _screen._buttons[action]


func test_attack_and_defend_stay_outside_the_drawers() -> void:
	for action: String in ["attack", "defend"]:
		for drawer: GridContainer in _screen._drawers.values():
			assert_false(_button(action).get_parent() == drawer, "%s fixo, fora das gavetas" % action)


func test_every_other_action_lives_in_exactly_one_drawer() -> void:
	for action: String in _screen._buttons.keys():
		if action == "attack" or action == "defend":
			continue
		var holders: int = 0
		for drawer: GridContainer in _screen._drawers.values():
			if _button(action).get_parent() == drawer:
				holders += 1
		assert_eq(holders, 1, "%s em uma só gaveta" % action)


func test_only_one_drawer_is_open_and_tapping_again_collapses_it() -> void:
	_screen._select_drawer("items")
	assert_true(_screen._drawers["items"].visible)
	assert_false(_screen._drawers["skills"].visible)
	_screen._select_drawer("items")
	for drawer: GridContainer in _screen._drawers.values():
		assert_false(drawer.visible, "recolhida devolve altura ao palco")


func test_skill_needs_a_second_tap_when_confirm_is_on() -> void:
	_screen.confirm_taps = true
	var mp_before: int = _screen.session.combat.player.mp
	_button("skill_0").pressed.emit()
	assert_eq(_screen.session.combat.player.mp, mp_before, "primeiro toque só seleciona")
	assert_eq(_screen._selected_action, "skill_0")
	_button("skill_0").pressed.emit()
	assert_ne(_screen._selected_action, "skill_0", "segundo toque executa e limpa")
	assert_ne(_screen.session.combat.player.mp, mp_before, "gastou MP")


func test_attack_is_one_tap_even_with_confirm_on() -> void:
	_screen.confirm_taps = true
	var hp_before: int = _screen.session.combat.enemy.hp
	_button("attack").pressed.emit()
	assert_ne(_screen.session.combat.enemy.hp, hp_before, "atacar executa em um toque")


func test_selecting_another_action_moves_the_selection() -> void:
	_screen.confirm_taps = true
	_button("skill_0").pressed.emit()
	_button("potion").pressed.emit()
	assert_eq(_screen._selected_action, "potion")
	assert_eq(_button("skill_0").modulate, Color.WHITE)
