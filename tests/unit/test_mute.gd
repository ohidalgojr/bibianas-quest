extends GutTest
## TASK-050: o botão de mudo liga e desliga todo o som e lembra a escolha.

const DIR: String = "user://test_mute_"


func after_each() -> void:
	AudioSettings.muted = false
	AudioSettings.apply()
	DirAccess.remove_absolute(DIR + AudioSettings.FILE_NAME)


func test_set_muted_silences_the_master_bus_and_sound_fx() -> void:
	AudioSettings.set_muted(true, DIR)
	assert_true(AudioServer.is_bus_mute(AudioServer.get_bus_index("Master")))
	assert_true(SoundFx.muted)
	AudioSettings.set_muted(false, DIR)
	assert_false(AudioServer.is_bus_mute(AudioServer.get_bus_index("Master")))
	assert_false(SoundFx.muted)


func test_the_choice_is_saved_and_loaded() -> void:
	AudioSettings.set_muted(true, DIR)
	AudioSettings.muted = false
	AudioSettings.load_and_apply(DIR)
	assert_true(AudioSettings.muted, "a escolha voltou do arquivo")


func test_button_toggles_and_changes_its_icon() -> void:
	var button: MuteButton = MuteButton.new()
	button.settings_dir = DIR
	add_child_autofree(button)
	var on_icon: Texture2D = button.icon
	button.pressed.emit()
	assert_true(AudioSettings.muted)
	assert_ne(button.icon, on_icon, "o ícone mudou")
	button.pressed.emit()
	assert_false(AudioSettings.muted)


func test_game_screen_has_the_mute_button_on_top() -> void:
	var game: GameScreen = GameScreen.new()
	game.save_enabled = false
	game.telemetry_enabled = false
	game.time_scale = 0.0
	game.debug_enabled = false
	add_child_autofree(game)
	assert_eq(game.find_children("*", "MuteButton", true, false).size(), 1)
	assert_eq(game.get_child(game.get_child_count() - 1) is MuteButton, true, "por cima de tudo")
