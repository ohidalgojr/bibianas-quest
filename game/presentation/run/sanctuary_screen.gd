class_name SanctuaryScreen
extends Control
## Tela do Santuário entre Descidas (GDD §9, TASK-030, ADR-0034): Biblioteca, Arsenal e
## Códice (Bestiário), permitindo gastar Ecos acumulados e consultar os hábitos, golpes de
## moeda e histórico contra os 7 inimigos.

signal upgrade_purchased(upgrade_id: String)
signal closed

const COLOR_BG: Color = Color(0.06, 0.06, 0.08, 1.0)
const COLOR_CARD: Color = Color(0.11, 0.11, 0.14, 1.0)
const COLOR_GOLD: Color = Color(0.88, 0.72, 0.28, 1.0)
const COLOR_MUTED: Color = Color(0.68, 0.68, 0.72, 1.0)

var data: GameData
var echoes: int = 0
var unlocks: Array[String] = []
var bestiary: Dictionary = {}
var active_tab: String = "library"

var echoes_label: Label
var tab_buttons: Dictionary = {}
var upgrade_buttons: Dictionary = {}
var close_button: Button
var _body_box: VBoxContainer


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_rebuild()


func show_tab(tab_id: String) -> void:
	active_tab = tab_id
	_rebuild()


func buy_upgrade(upgrade_id: String) -> bool:
	var result: Dictionary = SanctuaryRules.buy(upgrade_id, echoes, unlocks)
	if not bool(result["ok"]):
		return false
	echoes = int(result["echoes"])
	unlocks.clear()
	for id: Variant in result["unlocks"]:
		unlocks.append(str(id))
	upgrade_purchased.emit(upgrade_id)
	_rebuild()
	return true


func _rebuild() -> void:
	for child: Node in get_children():
		remove_child(child)
		child.queue_free()
	tab_buttons.clear()
	upgrade_buttons.clear()

	var bg: ColorRect = ColorRect.new()
	bg.color = COLOR_BG
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	# Interior pintado do Santuário, escurecido atrás das abas (TASK-072).
	var art_path: String = "res://assets/bibiana/arenas/sanctuary-interior.jpg"
	if ResourceLoader.exists(art_path):
		var art: TextureRect = TextureRect.new()
		art.texture = load(art_path) as Texture2D
		art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		art.modulate = Color(0.55, 0.58, 0.68)
		art.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		art.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(art)

	var margin: MarginContainer = MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side: String in ["margin_left", "margin_right", "margin_top", "margin_bottom"]:
		margin.add_theme_constant_override(side, 18)
	add_child(margin)

	var root: VBoxContainer = VBoxContainer.new()
	root.add_theme_constant_override("separation", 10)
	margin.add_child(root)

	var title: Label = _label("Santuário das Cinzas", 26, HORIZONTAL_ALIGNMENT_CENTER)
	title.add_theme_color_override("font_color", COLOR_GOLD)
	root.add_child(title)

	echoes_label = _label("Ecos disponíveis: %d  |  Desbloqueios: %d/%d" % [
		echoes, unlocks.size(), SanctuaryRules.UPGRADES.size()], 17, HORIZONTAL_ALIGNMENT_CENTER)
	root.add_child(echoes_label)

	var tabs: HBoxContainer = HBoxContainer.new()
	tabs.add_theme_constant_override("separation", 8)
	root.add_child(tabs)
	_add_tab_button(tabs, "library", "Biblioteca")
	_add_tab_button(tabs, "arsenal", "Arsenal")
	_add_tab_button(tabs, "codex", "Códice")

	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	root.add_child(scroll)

	_body_box = VBoxContainer.new()
	_body_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_body_box.add_theme_constant_override("separation", 10)
	scroll.add_child(_body_box)

	if active_tab == "codex":
		_build_codex()
	else:
		_build_wing(active_tab)

	close_button = Button.new()
	close_button.text = "Voltar ao Acampamento"
	close_button.custom_minimum_size = Vector2(0, 54)
	close_button.pressed.connect(func() -> void: closed.emit())
	root.add_child(close_button)


func _add_tab_button(parent: HBoxContainer, tab_id: String, text: String) -> void:
	var btn: Button = Button.new()
	btn.text = ("[%s]" % text) if active_tab == tab_id else text
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.custom_minimum_size = Vector2(0, 46)
	btn.pressed.connect(func() -> void: show_tab(tab_id))
	parent.add_child(btn)
	tab_buttons[tab_id] = btn


func _build_wing(wing: String) -> void:
	var subtitle: String = (
		"Tomos e ensinamentos táticos que acompanham a Bibiana desde o início da Descida."
		if wing == "library"
		else "Bênçãos e provisões iniciais (bônus numéricos permanentes limitados a +10%, GDD §9)."
	)
	var sub: Label = _label(subtitle, 15, HORIZONTAL_ALIGNMENT_CENTER)
	sub.add_theme_color_override("font_color", COLOR_MUTED)
	_body_box.add_child(sub)

	for entry: Dictionary in SanctuaryRules.wing_catalog(wing):
		var uid: String = str(entry["id"])
		var owned: bool = unlocks.has(uid)
		var affordable: bool = SanctuaryRules.can_buy(uid, echoes, unlocks)
		var card: PanelContainer = _card()
		var box: VBoxContainer = VBoxContainer.new()
		box.add_theme_constant_override("separation", 6)
		card.add_child(box)

		var header: Label = _label("%s — %d Ecos" % [str(entry["name"]), int(entry["cost"])], 18)
		header.add_theme_color_override("font_color", COLOR_GOLD if owned else Color.WHITE)
		box.add_child(header)

		var desc: Label = _label(str(entry["description"]), 15)
		desc.add_theme_color_override("font_color", COLOR_MUTED)
		box.add_child(desc)

		var btn: Button = Button.new()
		btn.custom_minimum_size = Vector2(0, 46)
		if owned:
			btn.text = "Desbloqueado"
			btn.disabled = true
		elif affordable:
			btn.text = "Desbloquear (%d Ecos)" % int(entry["cost"])
			btn.pressed.connect(buy_upgrade.bind(uid))
		else:
			btn.text = "Faltam %d Ecos" % maxi(1, int(entry["cost"]) - echoes)
			btn.disabled = true
		box.add_child(btn)
		upgrade_buttons[uid] = btn
		_body_box.add_child(card)


func _build_codex() -> void:
	var sub: Label = _label(
		"Bestiário da Cidade Abandonada: golpes de moeda, reações e histórico de confrontos.",
		15, HORIZONTAL_ALIGNMENT_CENTER)
	sub.add_theme_color_override("font_color", COLOR_MUTED)
	_body_box.add_child(sub)

	if data == null:
		return
	for entry: Dictionary in SanctuaryRules.bestiary_entries(data, bestiary):
		var card: PanelContainer = _card()
		var box: VBoxContainer = VBoxContainer.new()
		box.add_theme_constant_override("separation", 4)
		card.add_child(box)

		var header: Label = _label("%s (%s, Nv. base %d)" % [
			str(entry["name"]), str(entry["type_label"]), int(entry["base_level"])], 17)
		header.add_theme_color_override("font_color", COLOR_GOLD)
		box.add_child(header)

		box.add_child(_label("Moeda: %s" % str(entry["coin_move"]), 14))
		box.add_child(_label("Reação: %s" % str(entry["reaction"]), 14))
		var stats_line: Label = _label("Vitórias da Bibiana: %d   |   Quedas para este inimigo: %d" % [
			int(entry["kills"]), int(entry["deaths"])], 14)
		stats_line.add_theme_color_override("font_color", COLOR_MUTED)
		box.add_child(stats_line)
		_body_box.add_child(card)


func _card() -> PanelContainer:
	var panel: PanelContainer = PanelContainer.new()
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = COLOR_CARD
	style.border_color = Color(0.28, 0.25, 0.2, 1.0)
	style.set_border_width_all(1)
	style.set_corner_radius_all(6)
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	panel.add_theme_stylebox_override("panel", style)
	return panel


func _label(text: String, size: int = 16, align: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT) -> Label:
	var label: Label = Label.new()
	label.text = text
	label.horizontal_alignment = align
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", size)
	return label
