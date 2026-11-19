extends SceneTree
## Abre uma cena COM janela, espera alguns quadros e salva o PNG (o modo headless não desenha).
## Uso: godot --path . -s tools/screenshot.gd -- cena=res://... saida=C:/x.png quadros=90
## A janela tem o tamanho do projeto (retrato 540x960).

var _scene_path: String = ""
var _out: String = "user://screenshot.png"
var _frames: int = 90


func _init() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("cena="):
			_scene_path = arg.trim_prefix("cena=")
		elif arg.begins_with("saida="):
			_out = arg.trim_prefix("saida=")
		elif arg.begins_with("quadros="):
			_frames = int(arg.trim_prefix("quadros="))
	var packed: PackedScene = load(_scene_path) as PackedScene
	if packed == null:
		push_error("cena não carregou: " + _scene_path)
		quit(1)
		return
	root.add_child(packed.instantiate())
	_capture()


func _capture() -> void:
	for i: int in _frames:
		await process_frame
	var info: String = "fps=%d chamadas=%d primitivas=%d" % [int(Performance.get_monitor(Performance.TIME_FPS)), int(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)), int(Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME))]
	print("DESEMPENHO ", info)
	var image: Image = root.get_texture().get_image()
	var err: int = image.save_png(_out)
	print("print salvo em ", _out, " (", image.get_size(), ") erro=", err)
	quit(0 if err == OK else 1)
