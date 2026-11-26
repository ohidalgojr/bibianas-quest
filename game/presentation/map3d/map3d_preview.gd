class_name Map3DPreview
extends Control
## Cena de conferência da TASK-036: monta uma Descida com a semente 7, avança `passos` nós
## (vence as lutas na hora) e mostra o tabuleiro 3D. Serve ao `tools/screenshot.ps1`; passe
## `passos=N` depois de `--` para escolher o momento (início, meio, perto do chefe).

var steps: int = 0
var run_seed: int = 7


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("passos="):
			steps = int(arg.trim_prefix("passos="))
		elif arg.begins_with("semente="):
			run_seed = int(arg.trim_prefix("semente="))
	var data: GameData = DataLoader.load_all()
	var run: RunState = RunState.new(data, run_seed, "warrior", [], 0, null, true, [])
	var taken: int = 0
	while taken < steps and not run.is_over() and run.phase == RunState.Phase.CHOOSING:
		run.choose_node(run.options()[0].id)
		taken += 1
		_settle(run)
	var screen: Map3DScreen = Map3DScreen.new()
	screen.view = MapView.new(run)
	screen.time_scale = 0.0
	add_child(screen)


## Resolve o que o nó pediu (luta, loja, fogueira, evento) para voltar ao mapa.
func _settle(run: RunState) -> void:
	var guard: int = 0
	while run.phase != RunState.Phase.CHOOSING and not run.is_over() and guard < 12:
		guard += 1
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
