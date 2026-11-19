class_name Combat3DPreview
extends Control
## Cena de conferência da TASK-037: abre uma luta no palco 3D para o `tools/screenshot.ps1`.
## Argumentos depois de `--`: `inimigo=<id>` (padrão infected_citizen), `no=<tipo>` (índice de
## `MapNode.Kind`, padrão -1 = praça comum) e `nivel=<n>`.


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var enemy_id: String = "infected_citizen"
	var kind: int = -1
	var level: int = 3
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("inimigo="):
			enemy_id = arg.trim_prefix("inimigo=")
		elif arg.begins_with("no="):
			kind = int(arg.trim_prefix("no="))
		elif arg.begins_with("nivel="):
			level = int(arg.trim_prefix("nivel="))
	var screen: CombatScreen = CombatScreen.new()
	screen.data = DataLoader.load_all()
	screen.stage_kind = kind
	add_child(screen)
	screen.start_fight(enemy_id, level, float(level), 42)
