class_name MuteButton
extends Button
## Botão de som mudo no canto da tela (TASK-050). Mostra o alto-falante ligado ou riscado e guarda
## a escolha por [AudioSettings].

const ICON_ON: String = "res://assets/kenney/game_icons/audioOn.png"
const ICON_OFF: String = "res://assets/kenney/game_icons/audioOff.png"

var settings_dir: String = "user://"


func _ready() -> void:
	flat = false
	focus_mode = Control.FOCUS_NONE
	custom_minimum_size = Vector2(52, 52)
	expand_icon = true
	add_theme_constant_override("icon_max_width", 30)
	icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	offset_left = -60.0
	offset_right = -8.0
	offset_top = 8.0
	offset_bottom = 60.0
	toggle_mode = false
	pressed.connect(_on_pressed)
	_refresh()


func _on_pressed() -> void:
	AudioSettings.set_muted(not AudioSettings.muted, settings_dir)
	_refresh()


func _refresh() -> void:
	icon = load(ICON_OFF if AudioSettings.muted else ICON_ON) as Texture2D
	tooltip_text = "Som desligado" if AudioSettings.muted else "Som ligado"
