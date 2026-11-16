extends Control
## Cena inicial. Na Fase 1 abre direto a luta de teste (TASK-006); o menu e a Descida
## entram na TASK-011.

@onready var _title: Label = $Title


func _ready() -> void:
	var game_name: String = ProjectSettings.get_setting("application/config/name")
	_title.text = "%s\nregras v%d" % [game_name, CoreVersion.RULES_VERSION]
	_title.visible = false
	add_child(CombatScreen.new())
