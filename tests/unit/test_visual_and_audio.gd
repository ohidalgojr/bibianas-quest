extends GutTest
## TASK-031 (ADR-0035): Apresentação Dark Fantasy (mecha colorida removida em F-024),
## retratos vetoriais (PortraitCanvas), medalhão da moeda (CoinMedallion), tabuleiro visual
## com estradas curvas (MapScreen) e sintetizador de áudio procedural (SoundFx).


func test_sound_fx_synthesizes_valid_wav_streams_for_all_cues() -> void:
	assert_eq(SoundFx.CUES.size(), 14)
	for cue: String in SoundFx.CUES:
		var stream: AudioStreamWAV = SoundFx.stream_for(cue)
		assert_not_null(stream, "stream gerado para %s" % cue)
		assert_eq(stream.format, AudioStreamWAV.FORMAT_16_BITS)
		assert_eq(stream.mix_rate, SoundFx.SAMPLE_RATE)
		assert_gt(stream.data.size(), 1000, "PCM não vazio para %s" % cue)
	var dummy: Control = Control.new()
	add_child_autofree(dummy)
	# Em headless não instancia AudioStreamPlayer para evitar nós órfãos.
	assert_false(SoundFx.play(dummy, "coin_tick"))
	assert_eq(dummy.get_child_count(), 0)


func test_portrait_canvas_and_coin_medallion_configure_and_draw_all_subjects() -> void:
	var portrait: VisualTheme.PortraitCanvas = VisualTheme.PortraitCanvas.new()
	portrait.size = Vector2(120, 120)
	add_child_autofree(portrait)
	portrait.configure_player(12.5)
	assert_eq(portrait.subject_id, "bibiana")
	assert_almost_eq(portrait.power_level, 12.5, 0.001)

	for enemy_id: String in ["infected_citizen", "giant_rat", "carrion_crow", "plague_hound", "rotten_executioner", "bell_warden", "gravedigger"]:
		portrait.configure_enemy(enemy_id, "bloated" if enemy_id == "infected_citizen" else "")
		assert_eq(portrait.subject_id, enemy_id)

	var coin: VisualTheme.CoinMedallion = VisualTheme.CoinMedallion.new()
	coin.size = Vector2(96, 96)
	add_child_autofree(coin)
	coin.set_side(CoinRules.HEADS)
	assert_eq(coin.shown_side, CoinRules.HEADS)
	coin.set_side(CoinRules.TAILS)
	assert_eq(coin.shown_side, CoinRules.TAILS)


func test_map_screen_and_combat_screen_use_visual_theme_components() -> void:
	var data: GameData = DataLoader.load_all()
	var run: RunState = RunState.new(data, 42)
	run.power = 5.4
	var map_screen: MapScreen = MapScreen.new()
	map_screen.view = MapView.new(run)
	add_child_autofree(map_screen)
	var pts: PackedVector2Array = map_screen._board._road_points(Vector2(20, 200), Vector2(120, 100))
	assert_gt(pts.size(), 5, "estrada curva tem pontos intermediários")

	var combat_screen: CombatScreen = CombatScreen.new()
	combat_screen.time_scale = 0.0
	add_child_autofree(combat_screen)
	combat_screen.start_fight("bell_warden", 4, 8.2, 11)
	assert_true(combat_screen._enemy_shape is VisualTheme.PortraitCanvas)
	assert_true(combat_screen._player_shape is VisualTheme.PortraitCanvas)
	assert_eq(combat_screen._enemy_shape.subject_id, "bell_warden")
	assert_almost_eq(combat_screen._player_shape.power_level, 8.2, 0.001)
	assert_not_null(combat_screen._coin_medallion)
