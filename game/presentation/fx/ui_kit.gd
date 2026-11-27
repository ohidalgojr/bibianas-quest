class_name UiKit
extends RefCounted
## Peças de UI pintadas (TASK-072, ADR-0059): painel de pedra com friso de bronze, molduras de slot,
## divisor, fita de título e moldura de ilustração. Todas em `assets/bibiana/ui/` (`tools` não gera: vêm
## das pranchas do Gemini com o fundo removido). Só apresentação.

const DIR: String = "res://assets/bibiana/ui/"
const PANEL_MARGIN: int = 38
const SLOT_MARGIN: int = 22
const FRAME_MARGIN: int = 34

static var _cache: Dictionary = {}


static func texture(file_name: String) -> Texture2D:
	var path: String = DIR + file_name
	if not _cache.has(path):
		_cache[path] = load(path) as Texture2D if ResourceLoader.exists(path) else null
	return _cache[path]


static func _box(file_name: String, margin: int, content: int) -> StyleBox:
	var tex: Texture2D = texture(file_name)
	if tex == null:
		var flat: StyleBoxFlat = StyleBoxFlat.new()
		flat.bg_color = Color(0.07, 0.075, 0.1, 0.96)
		flat.border_color = VisualTheme.COLOR_BORDER_BRONZE
		flat.set_border_width_all(2)
		flat.set_corner_radius_all(8)
		flat.set_content_margin_all(content)
		return flat
	var box: StyleBoxTexture = StyleBoxTexture.new()
	box.texture = tex
	box.set_texture_margin_all(margin)
	box.set_content_margin_all(content)
	box.axis_stretch_horizontal = StyleBoxTexture.AXIS_STRETCH_MODE_STRETCH
	box.axis_stretch_vertical = StyleBoxTexture.AXIS_STRETCH_MODE_STRETCH
	return box


## Painel de pedra com friso de bronze e rebites (fundo dos painéis, folhas e cartões).
static func panel(content: int = 26) -> StyleBox:
	return _box("panel_stone.png", PANEL_MARGIN, content)


## Moldura de slot: "bronze" (comum), "steel" (selecionado), "gold" (raro) ou "blood" (perigo).
static func slot(kind: String = "bronze", content: int = 6) -> StyleBox:
	return _box("slot_%s.png" % kind, SLOT_MARGIN, content)


## Moldura gótica de ilustração (cartão de evento).
static func illustration_frame(content: int = 30) -> StyleBox:
	return _box("frame_illustration.png", FRAME_MARGIN, content)


## Divisor de lança e losango, para separar título de corpo.
static func divider(width: float = 360.0) -> TextureRect:
	var rect: TextureRect = TextureRect.new()
	rect.texture = texture("divider.png")
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	rect.custom_minimum_size = Vector2(width, 22.0)
	rect.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	return rect


## Fita de título (bronze com pergaminho de ardósia) com o texto em marfim.
static func banner(text: String, font_size: int = 26) -> Control:
	var holder: Control = Control.new()
	holder.custom_minimum_size = Vector2(380.0, 74.0)
	holder.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var art: TextureRect = TextureRect.new()
	art.texture = texture("banner_ribbon.png")
	art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art.stretch_mode = TextureRect.STRETCH_SCALE
	art.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	art.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	holder.add_child(art)
	var label: Label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", Color(0.93, 0.88, 0.74))
	label.add_theme_color_override("font_outline_color", Color(0.05, 0.04, 0.03))
	label.add_theme_constant_override("outline_size", 4)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.add_child(label)
	return holder
