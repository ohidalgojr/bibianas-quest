class_name DarkTheme
extends RefCounted
## Tema de interface dark fantasy (TASK-042, GDD §18 e §19): fontes Cinzel (títulos e botões) e
## Alegreya (texto), botões e painéis de pedra escura com moldura de bronze, brilho dourado no
## toque e barras finas. Um único [Theme] vale para todas as telas.

const CINZEL: String = "res://assets/google_fonts/cinzel/Cinzel.ttf"
const ALEGREYA: String = "res://assets/google_fonts/alegreya/Alegreya.ttf"
const GOLD: Color = Color(0.92, 0.75, 0.26)
const BRONZE: Color = Color(0.42, 0.35, 0.24)
const BRONZE_DARK: Color = Color(0.26, 0.21, 0.15)
const STONE: Color = Color(0.085, 0.09, 0.115)
const STONE_LIGHT: Color = Color(0.14, 0.145, 0.18)
const PARCHMENT: Color = Color(0.9, 0.86, 0.76)

## Tokens da paleta fechada (docs/design/IDENTIDADE-VISUAL.md §B.1, ADR-0050).
const ABYSS: Color = Color("07080B")
const SLATE_DEAD: Color = Color("1B2029")
const STONE_WET: Color = Color("4A4E54")
const STEEL_MOON: Color = Color("7E8FA8")
const MUD: Color = Color("3A3128")
const AMBER_LAMP: Color = Color("E08A30")
const DANGER: Color = Color("B82824")
const COIN_GOLD: Color = Color("D9AA32")
## Botão com até esta quantidade de palavras usa Cinzel; o resto usa Alegreya (D-UI-4).
const MAX_WORDS_DISPLAY_FONT: int = 3
const PRESS_SCALE: float = 0.96
## Alvo mínimo de toque em pixels (Estudo §2.3, Lei 7).
const MIN_TOUCH: float = 48.0
## Vibração curta ao tocar; desligável em [GfxSettings].
const HAPTIC_MS: int = 12

static var _theme: Theme


## Fonte de títulos (Cinzel em peso variável).
static func title_font(weight: int = 700) -> Font:
	var base: Font = load(CINZEL) as Font
	var variation: FontVariation = FontVariation.new()
	variation.base_font = base
	variation.variation_opentype = {"wght": weight}
	return variation


## Fonte de texto corrido (Alegreya).
static func body_font(weight: int = 500) -> Font:
	var base: Font = load(ALEGREYA) as Font
	var variation: FontVariation = FontVariation.new()
	variation.base_font = base
	variation.variation_opentype = {"wght": weight}
	return variation


## O tema compartilhado (criado uma vez). Aplique com `control.theme = DarkTheme.build()`.
static func build() -> Theme:
	if _theme != null:
		return _theme
	var theme: Theme = Theme.new()
	theme.default_font = body_font()
	theme.default_font_size = 20
	_style_labels(theme)
	_style_buttons(theme)
	_style_variations(theme)
	_style_panels(theme)
	_style_bars(theme)
	_style_scroll(theme)
	_theme = theme
	return theme


static func _box(bg: Color, border: Color, border_width: int = 1, radius: int = 5, margin: int = 10) -> StyleBoxFlat:
	var box: StyleBoxFlat = StyleBoxFlat.new()
	box.bg_color = bg
	box.border_color = border
	box.set_border_width_all(border_width)
	box.set_corner_radius_all(radius)
	box.content_margin_left = margin
	box.content_margin_right = margin
	box.content_margin_top = 8
	box.content_margin_bottom = 8
	box.shadow_color = Color(0, 0, 0, 0.45)
	box.shadow_size = 4
	return box


static func _style_labels(theme: Theme) -> void:
	theme.set_color("font_color", "Label", PARCHMENT)
	theme.set_color("font_shadow_color", "Label", Color(0, 0, 0, 0.7))
	theme.set_constant("shadow_offset_x", "Label", 1)
	theme.set_constant("shadow_offset_y", "Label", 1)
	theme.add_type("TitleLabel")
	theme.set_type_variation("TitleLabel", "Label")
	theme.set_font("font", "TitleLabel", title_font(700))
	theme.set_font_size("font_size", "TitleLabel", 30)
	theme.set_color("font_color", "TitleLabel", GOLD)


static func _style_buttons(theme: Theme) -> void:
	# Corpo em Alegreya (legível em 540x960); Cinzel só nas variações de botão curto.
	theme.set_font("font", "Button", body_font(700))
	theme.set_font_size("font_size", "Button", 18)
	theme.set_color("font_color", "Button", PARCHMENT)
	theme.set_color("font_hover_color", "Button", Color(1.0, 0.93, 0.7))
	theme.set_color("font_pressed_color", "Button", GOLD)
	theme.set_color("font_disabled_color", "Button", Color(0.5, 0.48, 0.45, 0.8))
	theme.set_color("font_outline_color", "Button", Color(0, 0, 0, 0.9))
	theme.set_constant("outline_size", "Button", 2)
	theme.set_stylebox("normal", "Button", _box(STONE_LIGHT, BRONZE))
	theme.set_stylebox("hover", "Button", _box(Color(0.19, 0.18, 0.17), GOLD, 2))
	theme.set_stylebox("pressed", "Button", _box(Color(0.07, 0.065, 0.06), GOLD, 2))
	theme.set_stylebox("disabled", "Button", _box(STONE, BRONZE_DARK))
	var focus: StyleBoxFlat = _box(Color(0, 0, 0, 0), GOLD, 2)
	focus.shadow_size = 0
	theme.set_stylebox("focus", "Button", focus)


## Variações do design system (Estudo §3.3): botão de ação curto, primário, perigo, risco, cartão.
static func _style_variations(theme: Theme) -> void:
	for variation: String in ["ActionButton", "PrimaryButton", "DangerButton", "RiskButton"]:
		theme.add_type(variation)
		theme.set_type_variation(variation, "Button")
		theme.set_font("font", variation, title_font(650))
		theme.set_font_size("font_size", variation, 19)
	theme.set_font_size("font_size", "PrimaryButton", 24)
	theme.set_color("font_color", "PrimaryButton", COIN_GOLD)
	theme.set_stylebox("normal", "PrimaryButton", _box(STONE_LIGHT, COIN_GOLD, 2, 6, 14))
	theme.set_stylebox("hover", "PrimaryButton", _box(Color(0.19, 0.18, 0.17), COIN_GOLD, 3, 6, 14))
	theme.set_stylebox("pressed", "PrimaryButton", _box(Color(0.07, 0.065, 0.06), COIN_GOLD, 3, 6, 14))
	theme.set_color("font_color", "DangerButton", Color(0.95, 0.78, 0.74))
	theme.set_stylebox("normal", "DangerButton", _box(Color(0.12, 0.06, 0.06), DANGER, 2, 6, 12))
	theme.set_stylebox("hover", "DangerButton", _box(Color(0.18, 0.08, 0.08), DANGER, 3, 6, 12))
	theme.set_stylebox("pressed", "DangerButton", _box(Color(0.07, 0.03, 0.03), DANGER, 3, 6, 12))
	theme.set_color("font_color", "RiskButton", Color(0.98, 0.86, 0.62))
	theme.set_stylebox("normal", "RiskButton", _box(Color(0.12, 0.09, 0.05), AMBER_LAMP, 2, 6, 12))
	theme.set_stylebox("hover", "RiskButton", _box(Color(0.18, 0.12, 0.06), AMBER_LAMP, 3, 6, 12))
	theme.set_stylebox("pressed", "RiskButton", _box(Color(0.07, 0.05, 0.03), AMBER_LAMP, 3, 6, 12))
	# Cartão: painel de pedra escura sem sombra pesada, para grades de itens e skills.
	theme.add_type("CardPanel")
	theme.set_type_variation("CardPanel", "PanelContainer")
	var card: StyleBoxFlat = _box(Color(0.043, 0.047, 0.063, 0.94), BRONZE, 2, 6, 10)
	card.shadow_size = 0
	theme.set_stylebox("panel", "CardPanel", card)
	# Folha de baixo (bottom sheet): vidro escuro do Estudo §3.3.
	theme.add_type("SheetPanel")
	theme.set_type_variation("SheetPanel", "PanelContainer")
	var sheet: StyleBoxFlat = _box(Color(0.043, 0.047, 0.063, 0.92), BRONZE, 2, 10, 14)
	sheet.shadow_size = 0
	theme.set_stylebox("panel", "SheetPanel", sheet)
	theme.add_type("MutedLabel")
	theme.set_type_variation("MutedLabel", "Label")
	theme.set_color("font_color", "MutedLabel", Color(0.62, 0.64, 0.7))
	theme.add_type("DeltaUpLabel")
	theme.set_type_variation("DeltaUpLabel", "Label")
	theme.set_color("font_color", "DeltaUpLabel", COIN_GOLD)
	theme.add_type("DeltaDownLabel")
	theme.set_type_variation("DeltaDownLabel", "Label")
	theme.set_color("font_color", "DeltaDownLabel", DANGER.lightened(0.15))


## Aplica o comportamento do botão (D-UI-6): fonte por tamanho do texto, alvo mínimo de 48 px,
## escala 0,96 ao apertar e vibração curta. Idempotente; ignora botões planos (áreas de toque).
static func polish_button(button: Button) -> void:
	if button == null or button.flat or button.has_meta("polished"):
		return
	button.set_meta("polished", true)
	if button.theme_type_variation == &"" and _word_count(button.text) <= MAX_WORDS_DISPLAY_FONT and not button.text.is_empty():
		button.theme_type_variation = &"ActionButton"
	if button.custom_minimum_size.y < MIN_TOUCH:
		button.custom_minimum_size.y = MIN_TOUCH
	button.button_down.connect(func() -> void:
		button.pivot_offset = button.size * 0.5
		button.scale = Vector2.ONE * PRESS_SCALE
		if GfxSettings.haptics and not Engine.is_editor_hint():
			Input.vibrate_handheld(HAPTIC_MS))
	button.button_up.connect(func() -> void: button.scale = Vector2.ONE)


static func _word_count(text: String) -> int:
	return text.strip_edges().split(" ", false).size()


static func _style_panels(theme: Theme) -> void:
	theme.set_stylebox("panel", "PanelContainer", _box(STONE, BRONZE, 2, 8, 14))
	theme.set_stylebox("panel", "Panel", _box(STONE, BRONZE, 2, 8, 14))
	theme.set_stylebox("normal", "LineEdit", _box(Color(0.05, 0.055, 0.07), BRONZE, 1, 4, 8))


static func _style_bars(theme: Theme) -> void:
	var back: StyleBoxFlat = _box(Color(0.03, 0.03, 0.04), BRONZE_DARK, 1, 3, 2)
	back.shadow_size = 0
	back.content_margin_top = 2
	back.content_margin_bottom = 2
	theme.set_stylebox("background", "ProgressBar", back)
	var fill: StyleBoxFlat = _box(GOLD, GOLD.darkened(0.4), 0, 3, 0)
	fill.shadow_size = 0
	theme.set_stylebox("fill", "ProgressBar", fill)
	theme.set_font_size("font_size", "ProgressBar", 12)


static func _style_scroll(theme: Theme) -> void:
	var grabber: StyleBoxFlat = _box(BRONZE, BRONZE, 0, 3, 0)
	grabber.shadow_size = 0
	theme.set_stylebox("grabber", "VScrollBar", grabber)
	theme.set_stylebox("grabber_highlight", "VScrollBar", grabber)
	theme.set_stylebox("grabber_pressed", "VScrollBar", grabber)
	var track: StyleBoxFlat = _box(Color(0.04, 0.04, 0.055), Color(0, 0, 0, 0), 0, 3, 0)
	track.shadow_size = 0
	theme.set_stylebox("scroll", "VScrollBar", track)
