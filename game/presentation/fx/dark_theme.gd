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
	theme.set_font("font", "Button", title_font(600))
	theme.set_font_size("font_size", "Button", 17)
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
