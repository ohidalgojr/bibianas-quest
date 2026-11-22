extends GutTest
## TASK-064 (ADR-0051): DarkTheme 2.0 (tokens, variações, polimento de botão) e barra com rastro.


func test_palette_tokens_match_the_identity_document() -> void:
	assert_eq(DarkTheme.AMBER_LAMP.to_html(false), "e08a30")
	assert_eq(DarkTheme.DANGER.to_html(false), "b82824")
	assert_eq(DarkTheme.COIN_GOLD.to_html(false), "d9aa32")
	assert_eq(DarkTheme.SLATE_DEAD.to_html(false), "1b2029")


func test_button_font_is_the_body_font_and_variations_exist() -> void:
	var theme: Theme = DarkTheme.build()
	assert_true(theme.has_stylebox("normal", "PrimaryButton"))
	assert_true(theme.has_stylebox("normal", "DangerButton"))
	assert_true(theme.has_stylebox("normal", "RiskButton"))
	assert_true(theme.has_stylebox("panel", "CardPanel"))
	assert_true(theme.has_stylebox("panel", "SheetPanel"))
	assert_ne(theme.get_font("font", "Button"), theme.get_font("font", "PrimaryButton"), "corpo em Alegreya, display em Cinzel")


func test_polish_uses_display_font_only_for_short_text_and_min_touch() -> void:
	var short: Button = Button.new()
	short.text = "Atacar"
	DarkTheme.polish_button(short)
	assert_eq(short.theme_type_variation, &"ActionButton")
	assert_gte(short.custom_minimum_size.y, DarkTheme.MIN_TOUCH)
	var long: Button = Button.new()
	long.text = "Golpe de Escudo (6 MP)"
	DarkTheme.polish_button(long)
	assert_eq(long.theme_type_variation, &"", "texto longo fica em Alegreya")
	var flat: Button = Button.new()
	flat.flat = true
	DarkTheme.polish_button(flat)
	assert_false(flat.has_meta("polished"), "área de toque plana é ignorada")
	short.free()
	long.free()
	flat.free()


func test_polish_is_idempotent_and_scales_on_press() -> void:
	var button: Button = Button.new()
	button.text = "Seguir"
	add_child_autofree(button)
	DarkTheme.polish_button(button)
	DarkTheme.polish_button(button)
	button.button_down.emit()
	assert_almost_eq(button.scale.x, DarkTheme.PRESS_SCALE, 0.0001)
	button.button_up.emit()
	assert_eq(button.scale, Vector2.ONE)


func test_trail_bar_keeps_a_trail_when_value_drops_and_not_when_it_rises() -> void:
	var bar: TrailBar = TrailBar.new()
	bar.max_value = 100.0
	bar.size = Vector2(200, 22)
	add_child_autofree(bar)
	bar.value = 100.0
	bar.snap()
	bar.value = 40.0
	assert_almost_eq(bar.trail_value(), 100.0, 0.001, "rastro fica no valor antigo ao cair")
	bar.value = 100.0
	assert_almost_eq(bar.trail_value(), 100.0, 0.001, "subir não deixa rastro")
