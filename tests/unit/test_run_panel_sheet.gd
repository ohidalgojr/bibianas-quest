extends GutTest
## TASK-059 (ADR-0047): bottom sheet dos painéis da Descida.


func _screen(mode: String) -> RunPanelScreen:
	var run: RunState = RunState.new(DataLoader.load_all(), 4, "warrior", [], 0, null, true, [])
	var screen: RunPanelScreen = RunPanelScreen.new()
	screen.panels = RunPanels.new(run)
	screen.backdrop_kind = mode
	screen.time_scale = 0.0
	add_child_autofree(screen)
	return screen


func test_footer_lives_outside_the_scroll_and_holds_the_exit_button() -> void:
	var screen: RunPanelScreen = _screen("campfire")
	screen.show_campfire()
	var scroll: ScrollContainer = screen.find_children("*", "ScrollContainer", true, false)[0]
	var exit: Button = null
	for node: Node in screen.find_children("*", "Button", true, false):
		if (node as Button).text == "Seguir":
			exit = node
	assert_not_null(exit)
	assert_false(scroll.is_ancestor_of(exit), "Seguir fica fora da rolagem")
	assert_eq(exit.get_parent(), screen._footer)


func test_shop_offers_cards_in_a_two_column_grid() -> void:
	var screen: RunPanelScreen = _screen("shop")
	screen.panels.run.gold = 500
	screen.show_shop()
	var grids: Array[Node] = screen.find_children("*", "GridContainer", true, false)
	assert_eq(grids.size(), 1)
	assert_eq((grids[0] as GridContainer).columns, 2)
	var card: Button = screen._card(grids[0], "Item
Efeito
10 ouro", func() -> void: pass)
	assert_eq(card.get_parent(), grids[0])
	assert_gte(card.custom_minimum_size.y, 140.0, "cartão alto o bastante para o toque")


func test_ember_pins_show_lit_and_spent_embers() -> void:
	assert_eq(RunPanelScreen._ember_pins(3), "●●●○○○   3/6 Brasas")
	assert_eq(RunPanelScreen._ember_pins(0), "○○○○○○   0/6 Brasas")
