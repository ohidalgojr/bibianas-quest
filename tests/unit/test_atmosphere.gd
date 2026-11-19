extends GutTest
## TASK-042: contratos da atmosfera. O tema carrega fontes e estiliza os controles, os sons
## ambientes sintetizam buffers válidos (laços onde for o caso), o ambiente acompanha a situação
## e o relâmpago respeita a opção de reduzir flashes. A estética é julgada no print.


func test_dark_theme_loads_fonts_and_styles_the_controls() -> void:
	var theme: Theme = DarkTheme.build()
	assert_not_null(theme.default_font)
	assert_not_null(DarkTheme.title_font())
	assert_true(theme.has_stylebox("normal", "Button"))
	assert_true(theme.has_stylebox("panel", "PanelContainer"))
	assert_true(theme.has_stylebox("fill", "ProgressBar"))
	assert_eq(DarkTheme.build(), theme, "o tema é criado uma vez")


func test_ambient_sounds_synthesize_and_loop_where_expected() -> void:
	for cue: String in ["rain_loop", "fire_loop", "thunder"]:
		var wav: AudioStreamWAV = SoundFx.stream_for(cue)
		assert_not_null(wav, cue)
		assert_gt(wav.data.size(), 10000, "%s tem amostras" % cue)
	assert_eq(SoundFx.stream_for("rain_loop").loop_mode, AudioStreamWAV.LOOP_FORWARD)
	assert_eq(SoundFx.stream_for("fire_loop").loop_mode, AudioStreamWAV.LOOP_FORWARD)
	assert_ne(SoundFx.stream_for("thunder").loop_mode, AudioStreamWAV.LOOP_FORWARD)


func test_ambience_follows_the_mood_and_strike_emits_lightning() -> void:
	var ambience: Ambience = Ambience.new()
	ambience.enabled = false
	add_child_autofree(ambience)
	ambience.set_mood("camp")
	assert_eq(ambience.mood, "camp")
	ambience.set_mood("map")
	assert_eq(ambience.mood, "map")
	watch_signals(ambience)
	ambience.strike()
	assert_signal_emitted(ambience, "lightning")


func test_lightning_flash_respects_the_reduce_flashes_option() -> void:
	var flash: LightningFlash = LightningFlash.new()
	add_child_autofree(flash)
	GfxSettings.flashes = false
	flash.strike()
	assert_eq(flash.color.a, 0.0, "sem flash quando a opção está desligada")
	GfxSettings.flashes = true
	assert_eq(flash.mouse_filter, Control.MOUSE_FILTER_IGNORE)


func test_game_screen_has_ambience_flash_and_fade_layers() -> void:
	var game: GameScreen = GameScreen.new()
	game.save_enabled = false
	game.telemetry_enabled = false
	game.time_scale = 0.0
	game.debug_enabled = false
	add_child_autofree(game)
	assert_not_null(game.ambience)
	assert_eq(game.find_children("*", "LightningFlash", true, false).size(), 1)
