extends Control
## Cena inicial provisória (TASK-001).
##
## Só prova que o projeto abre em retrato e que a apresentação enxerga o núcleo.
## Será substituída pela interface cinza da Fase 1.

@onready var _title: Label = $Title


func _ready() -> void:
	var game_name: String = ProjectSettings.get_setting("application/config/name")
	_title.text = "%s\nregras v%d" % [game_name, CoreVersion.RULES_VERSION]
