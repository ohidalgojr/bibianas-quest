class_name GamePreview
extends Control
## Cena de conferência da TASK-038: mostra uma tela do fluxo (`tela=home|shop|campfire|chest|
## reward|event|result`) dentro do `GameScreen`, com o cenário 3D, para o `tools/screenshot.ps1`.


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var screen_name: String = "home"
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("tela="):
			screen_name = arg.trim_prefix("tela=")
	var game: GameScreen = GameScreen.new()
	game.save_enabled = false
	game.telemetry_enabled = false
	game.use_thread = false
	game.map_check_runs = 0
	game.use_3d_map = true
	game.debug_enabled = false
	add_child(game)
	if screen_name == "home":
		return
	var run: RunState = RunState.new(game.data, 7, "warrior", [], 0, null, false, [])
	game.run = run
	_advance(run, screen_name)
	if screen_name == "result":
		run.phase = RunState.Phase.VICTORY
	game._reward_pending = screen_name == "reward"
	game._after_action()


func _prefer_kind(screen_name: String) -> int:
	match screen_name:
		"campfire":
			return MapNode.Kind.BONFIRE
		"chest":
			return MapNode.Kind.CHEST
		"event":
			return MapNode.Kind.EVENT
	return MapNode.Kind.BATTLE


## Anda pelo mapa até chegar à fase que a tela pede (preferindo o tipo de nó certo).
func _advance(run: RunState, screen_name: String) -> void:
	var wanted_kind: int = _prefer_kind(screen_name)
	var guard: int = 0
	while guard < 40 and not run.is_over():
		guard += 1
		if run.phase == RunState.Phase.CHOOSING:
			if screen_name == "chest" and not run.last_chest.is_empty():
				return
			if screen_name == "event" and not run.last_event_result.is_empty():
				return
			var pick: MapNode = run.options()[0]
			for option: MapNode in run.options():
				if option.kind == wanted_kind:
					pick = option
			run.choose_node(pick.id)
			continue
		if run.phase == RunState.Phase.CAMPFIRE and screen_name == "campfire":
			return
		if run.phase == RunState.Phase.SHOP and (screen_name == "shop" or screen_name == "reward"):
			return
		if run.phase == RunState.Phase.EVENT and screen_name == "event":
			return
		match run.phase:
			RunState.Phase.FIGHT:
				run.combat.debug_kill_enemy()
				run.finish_fight()
			RunState.Phase.SHOP:
				run.leave_shop()
			RunState.Phase.CAMPFIRE:
				run.leave_campfire()
			RunState.Phase.EVENT:
				run.choose_event_option(0)
			_:
				return
