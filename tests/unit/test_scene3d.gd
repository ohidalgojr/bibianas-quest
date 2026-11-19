extends GutTest
## TASK-038: contratos dos cenários 3D de fundo. Todo tipo monta com a Bibiana e as telas de painel
## carregam o cenário. A estética é julgada no print.


func test_every_backdrop_kind_builds_with_the_hero() -> void:
	for kind: String in Scene3DBackdrop.KINDS:
		var backdrop: Scene3DBackdrop = Scene3DBackdrop.new()
		backdrop.kind = kind
		backdrop.time_scale = 0.0
		add_child_autofree(backdrop)
		assert_not_null(backdrop.hero, "%s: Bibiana no cenário" % kind)
		assert_gt(backdrop.find_children("*", "MeshInstance3D", true, false).size(), 10, "%s: peças 3D" % kind)


func test_run_panel_uses_the_backdrop_and_a_scroll_when_enabled() -> void:
	var run: RunState = RunState.new(DataLoader.load_all(), 4, "warrior", [], 0, null, true, [])
	var screen: RunPanelScreen = RunPanelScreen.new()
	screen.panels = RunPanels.new(run)
	screen.backdrop_kind = "campfire"
	screen.time_scale = 0.0
	add_child_autofree(screen)
	screen.show_campfire()
	assert_eq(screen.find_children("*", "Scene3DBackdrop", true, false).size(), 1)
	assert_eq(screen.find_children("*", "ScrollContainer", true, false).size(), 1)


func test_game_screen_home_and_result_use_the_3d_scene() -> void:
	var game: GameScreen = GameScreen.new()
	game.save_enabled = false
	game.telemetry_enabled = false
	game.time_scale = 0.0
	game.use_3d_map = true
	game.debug_enabled = false
	add_child_autofree(game)
	assert_eq(game.find_children("*", "Scene3DBackdrop", true, false).size(), 1, "menu com cenário")
