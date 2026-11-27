class_name IconsPreview
extends Control
## Folha de contato dos ícones por id, para conferir no print (`tools/screenshot.ps1`).


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	theme = DarkTheme.build()
	var bg: ColorRect = ColorRect.new()
	bg.color = Color(0.06, 0.065, 0.09)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var scroll: VBoxContainer = VBoxContainer.new()
	scroll.position = Vector2(8, 8)
	scroll.add_theme_constant_override("separation", 2)
	add_child(scroll)
	for entry: Array in [["item", IconRegistry.ITEMS], ["skill", IconRegistry.SKILLS], ["effect", IconRegistry.EFFECTS], ["disease", IconRegistry.DISEASES], ["ui", IconRegistry.UI]]:
		for id: String in entry[1]:
			_row(scroll, "%s %s" % [entry[0], id], IconRegistry.texture_for(entry[0], id))
	for index: int in IconRegistry.NODES.size():
		_row(scroll, "node %s" % MapView.kind_name(index), IconRegistry.texture_for("node", str(index)))


func _row(parent: Control, text: String, tex: Texture2D) -> void:
	var row: HBoxContainer = HBoxContainer.new()
	var rect: TextureRect = TextureRect.new()
	rect.texture = tex
	rect.custom_minimum_size = Vector2(26, 26)
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	row.add_child(rect)
	var label: Label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 12)
	row.add_child(label)
	parent.add_child(row)
