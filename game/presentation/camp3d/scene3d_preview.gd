class_name Scene3DPreview
extends Control
## Cena de conferência da TASK-038: mostra um cenário de fundo (`tipo=campfire|shop|chest|event|
## reward|home|victory|defeat` depois de `--`) para o `tools/screenshot.ps1`.


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var kind: String = "campfire"
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("tipo="):
			kind = arg.trim_prefix("tipo=")
	var backdrop: Scene3DBackdrop = Scene3DBackdrop.new()
	backdrop.kind = kind
	add_child(backdrop)
