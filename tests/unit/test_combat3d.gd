extends GutTest
## TASK-037: contratos do palco 3D do combate. O palco monta para cada tipo de nó e inimigo, as
## animações tocam sem erro e a tela de combate com palco termina uma luta. A estética é julgada
## no print.

var _data: GameData


func before_all() -> void:
	_data = DataLoader.load_all()


func _stage() -> Combat3DStage:
	var stage: Combat3DStage = Combat3DStage.new()
	stage.time_scale = 0.0
	stage.size = Vector2(540, 330)
	add_child_autofree(stage)
	return stage


func test_stage_builds_for_every_node_kind_and_enemy() -> void:
	var stage: Combat3DStage = _stage()
	var kinds: Array[int] = [-1, MapNode.Kind.BATTLE, MapNode.Kind.ELITE, MapNode.Kind.MINI_BOSS, MapNode.Kind.BOSS]
	for enemy_id: String in _data.enemies:
		for kind: int in kinds:
			stage.setup(enemy_id, kind)
			assert_not_null(stage.player_node, "Bibiana no palco")
			assert_not_null(stage.enemy_node, "%s no palco" % enemy_id)


func test_animations_play_without_error_and_screen_pos_is_inside_the_stage() -> void:
	var stage: Combat3DStage = _stage()
	stage.setup("infected_citizen", MapNode.Kind.BATTLE)
	for key: String in ["attack", "hit", "death", "idle"]:
		stage.play(true, key)
		stage.play(false, key)
	var pos: Vector2 = stage.screen_pos(true)
	assert_true(pos.x > -50.0 and pos.x < 600.0, "posição do inimigo na tela")


func test_combat_screen_with_stage_plays_a_fight_to_the_end() -> void:
	var screen: CombatScreen = CombatScreen.new()
	screen.data = _data
	screen.time_scale = 0.0
	screen.use_stage = true
	add_child_autofree(screen)
	await screen.start_fight("giant_rat", 1, 1.0, 5)
	assert_not_null(screen._stage, "o palco 3D está na tela")
	screen.debug_kill()
	await wait_frames(3)
	assert_true(screen.session.is_over())
