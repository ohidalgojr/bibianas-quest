extends Control
## Cena inicial: abre o fluxo da Descida (GameScreen: menu, Descida, fim; TASK-009 e
## TASK-011).

@onready var _title: Label = $Title


func _ready() -> void:
	var game_name: String = ProjectSettings.get_setting("application/config/name")
	_title.text = "%s\nregras v%d" % [game_name, CoreVersion.RULES_VERSION]
	_title.visible = false
	add_child(GameScreen.new())
