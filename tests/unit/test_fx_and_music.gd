extends GutTest
## TASK-039: contratos do estilo, do clima e da música. O pós-processamento compila e desliga, o
## clima monta, as faixas existem e têm licença registrada. A estética é julgada no print.


func test_post_fx_shader_compiles_and_can_be_switched_off() -> void:
	GfxSettings.post_fx = true
	var mat: ShaderMaterial = PostFx.material()
	assert_not_null(mat)
	assert_true(mat.shader.code.contains("posterize") or mat.shader.code.contains("levels"))
	GfxSettings.post_fx = false
	assert_null(PostFx.material(), "interruptor desliga o efeito")
	GfxSettings.post_fx = true


func test_every_music_track_exists_and_is_licensed() -> void:
	var licenses: String = FileAccess.get_file_as_string("res://assets/LICENSES.md")
	assert_true(licenses.contains("assets/opengameart/ambient_music/"))
	for track: String in MusicBox.TRACKS:
		assert_true(FileAccess.file_exists(MusicBox.TRACKS[track] as String), "faixa %s existe" % track)


func test_music_box_tracks_the_current_track_and_ducking() -> void:
	var box: MusicBox = MusicBox.new()
	box.enabled = false
	add_child_autofree(box)
	box.play_track("map")
	assert_eq(box.current, "map")
	box.play_track("combat")
	assert_eq(box.current, "combat")
	box.duck(true)
	assert_true(box.ducked)
	box.duck(false)
	assert_false(box.ducked)


func test_weather_layer_builds_without_blocking_touch() -> void:
	var layer: WeatherLayer = WeatherLayer.new()
	add_child_autofree(layer)
	assert_eq(layer.mouse_filter, Control.MOUSE_FILTER_IGNORE)
