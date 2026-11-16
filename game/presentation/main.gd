extends Control
## Cena inicial. Na Fase 1 abre o fluxo provisório da Descida (TASK-009, ADR-0013); o
## menu de verdade entra na TASK-011.

@onready var _title: Label = $Title


func _ready() -> void:
	var game_name: String = ProjectSettings.get_setting("application/config/name")
	_title.text = "%s\nregras v%d" % [game_name, CoreVersion.RULES_VERSION]
	_title.visible = false
	add_child(GameScreen.new())
