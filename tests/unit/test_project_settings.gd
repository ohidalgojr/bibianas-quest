extends GutTest
## TASK-001: o esqueleto do projeto segue o GDD §20 e o ADR-0001
## (retrato 540x960, toque emulado pelo mouse, renderizador Compatibility).


func _setting(path: String) -> Variant:
	return ProjectSettings.get_setting(path)


func test_base_resolution_is_portrait_540x960() -> void:
	assert_eq(_setting("display/window/size/viewport_width"), 540)
	assert_eq(_setting("display/window/size/viewport_height"), 960)


func test_handheld_orientation_is_portrait() -> void:
	assert_eq(_setting("display/window/handheld/orientation"), DisplayServer.SCREEN_PORTRAIT)


func test_stretch_scales_ui_without_distortion() -> void:
	assert_eq(_setting("display/window/stretch/mode"), "canvas_items")
	assert_eq(_setting("display/window/stretch/aspect"), "keep_width")


func test_mouse_emulates_touch_on_desktop() -> void:
	assert_true(_setting("input_devices/pointing/emulate_touch_from_mouse"))


func test_renderer_is_compatibility_on_desktop_and_mobile() -> void:
	assert_eq(_setting("rendering/renderer/rendering_method"), "gl_compatibility")
	assert_eq(_setting("rendering/renderer/rendering_method.mobile"), "gl_compatibility")


func test_untyped_declarations_are_errors() -> void:
	# 2 = erro. Garante o GDScript tipado no código do jogo (ADR-0001).
	assert_eq(_setting("debug/gdscript/warnings/untyped_declaration"), 2)
