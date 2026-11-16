extends GutTest
## TASK-012 (ADR-0017): a Descida salva e retomada continua igual, o save ruim é
## recusado e o meta fica em arquivo separado.

const DIR: String = "user://test_saves/"

var _data: GameData
var _store: SaveStore


func before_all() -> void:
	_data = DataLoader.load_all()


func before_each() -> void:
	_store = SaveStore.new(DIR)
	_store.clear_run()
	DirAccess.remove_absolute(DIR + SaveStore.META_FILE)


func after_all() -> void:
	DirAccess.remove_absolute(DIR + SaveStore.META_FILE)
	DirAccess.remove_absolute(DIR + SaveStore.RUN_FILE)


## Joga algumas lutas e coloca a Descida no mapa, com estado variado.
func _played_run() -> RunState:
	var run: RunState = RunState.new(_data, 33)
	for step: int in 3:
		var option: MapNode = run.options()[0]
		run.choose_node(option.id)
		if run.phase == RunState.Phase.FIGHT:
			var guard: int = 0
			while run.combat.outcome == Combat.Outcome.ONGOING and guard < 300:
				guard += 1
				run.combat.act(Combat.Action.ATTACK if guard % 5 != 0 else Combat.Action.DEFEND)
			run.finish_fight()
		if run.phase == RunState.Phase.SHOP:
			run.leave_shop()
		if run.phase == RunState.Phase.CAMPFIRE:
			run.use_campfire_skill("sharpen_blade")
			run.leave_campfire()
		if run.is_over():
			break
	return run


func test_roundtrip_keeps_state_and_future() -> void:
	var run: RunState = _played_run()
	assert_eq(run.phase, RunState.Phase.CHOOSING, "o teste precisa de uma Descida no mapa")
	assert_true(_store.save_run(run))
	var loaded: RunState = _store.load_run(_data)
	assert_not_null(loaded)
	assert_eq(loaded.streams.run_seed, run.streams.run_seed)
	assert_eq(loaded.map.signature(), run.map.signature())
	assert_eq(loaded.current_node_id, run.current_node_id)
	assert_almost_eq(loaded.power, run.power, 0.0001)
	for field: String in ["gold", "hp", "mp", "embers", "nodes_cleared", "scenario_index"]:
		assert_eq(loaded.get(field), run.get(field), field)
	assert_eq(loaded.consumables, run.consumables)
	assert_eq(loaded.equipment, run.equipment)
	assert_eq(loaded.buffs, run.buffs)
	assert_eq(loaded.coin.flips, run.coin.flips)
	assert_eq(loaded.options().size(), run.options().size())
	# O futuro é igual: os mesmos sorteios saem dos fluxos restaurados.
	assert_eq(loaded.streams.combat().draw_int(0, 1000000), run.streams.combat().draw_int(0, 1000000))
	assert_eq(loaded.streams.loot().draw_int(0, 1000000), run.streams.loot().draw_int(0, 1000000))


func test_bad_files_are_rejected() -> void:
	assert_null(_store.load_run(_data), "sem arquivo")
	var run: RunState = _played_run()
	var saved: Dictionary = RunSave.to_dict(run)
	var old: Dictionary = saved.duplicate(true)
	old["rules_version"] = CoreVersion.RULES_VERSION + 1
	assert_null(RunSave.from_dict(_data, old), "versão de regras diferente")
	var broken: Dictionary = saved.duplicate(true)
	broken.erase("map")
	assert_null(RunSave.from_dict(_data, broken), "campo faltando")
	var file: FileAccess = FileAccess.open(DIR + SaveStore.RUN_FILE, FileAccess.WRITE)
	file.store_string("{ isto não é json")
	file.close()
	assert_null(_store.load_run(_data), "JSON quebrado")


func test_clear_run_and_meta_are_separate() -> void:
	var run: RunState = _played_run()
	_store.save_run(run)
	assert_true(_store.has_run())
	assert_true(_store.save_meta(42, 3))
	_store.clear_run()
	assert_false(_store.has_run())
	var meta: Dictionary = _store.load_meta()
	assert_eq(meta["echoes"], 42)
	assert_eq(meta["runs_played"], 3)
	assert_true(_store.save_meta(50, 4), "regravar sobre o arquivo existente")
	assert_eq(_store.load_meta()["echoes"], 50)


func test_game_screen_autosaves_resumes_and_keeps_echoes() -> void:
	var game: GameScreen = GameScreen.new()
	game.map_check_runs = 0
	game.use_thread = false
	game.time_scale = 0.0
	game.save_dir = DIR
	game.telemetry_enabled = false
	game.debug_enabled = false
	add_child_autofree(game)
	game.new_run(7)
	assert_true(_store.has_run(), "o mapa inicial já grava")
	var saved_node: int = game.run.current_node_id
	var chest: MapNode = game.run.options()[0]
	chest.kind = MapNode.Kind.CHEST
	chest.enemy_id = ""
	game.choose_node(chest.id)
	assert_eq(game.run.phase, RunState.Phase.CHOOSING)
	var second: GameScreen = GameScreen.new()
	second.map_check_runs = 0
	second.use_thread = false
	second.time_scale = 0.0
	second.save_dir = DIR
	second.telemetry_enabled = false
	second.debug_enabled = false
	add_child_autofree(second)
	second.resume_run()
	assert_not_null(second.run)
	assert_eq(second.run.streams.run_seed, 7)
	assert_ne(second.run.current_node_id, saved_node, "retomou do último nó salvo, não do início")
	assert_eq(second.run.current_node_id, chest.id)
	assert_gt(second.run.gold, 0, "o ouro do baú foi salvo")
