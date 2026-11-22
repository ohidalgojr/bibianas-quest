class_name RunPanelScreen
extends Control
## Painel de recompensa, loja ou fogueira por cima do mapa (TASK-010, ADR-0015). Desenha
## o que o [RunPanels] entrega e se refaz a cada compra ou ação. [signal closed] sai
## quando o jogador aperta o botão final.

signal closed

var panels: RunPanels
var forced_coin: int = -1
## Cenário 3D de fundo (ADR-0036); vazio mantém o painel de depuração sobre o mapa.
var backdrop_kind: String = ""
var time_scale: float = 1.0

## Altura em que o bottom sheet começa (o diorama 3D fica com o resto, D-UI-3).
const SHEET_TOP: float = 0.46
## Fogueira e loja deixam mais cena à mostra (IDENTIDADE-VISUAL §C.3: painel até ~38%/50%).
const SHEET_TOP_BY_KIND: Dictionary = {"campfire": 0.6, "shop": 0.5}

var _box: VBoxContainer
var _footer: HBoxContainer
var _mode: String = ""
var _backdrop: Scene3DBackdrop


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	if not backdrop_kind.is_empty():
		var backdrop: Scene3DBackdrop = Scene3DBackdrop.new()
		backdrop.kind = backdrop_kind
		backdrop.time_scale = time_scale
		backdrop.fire_lit = false
		_backdrop = backdrop
		add_child(backdrop)
	var dim: ColorRect = ColorRect.new()
	dim.color = Color(0.0, 0.0, 0.0, 0.0 if not backdrop_kind.is_empty() else 0.55)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(dim)
	var panel: PanelContainer = PanelContainer.new()
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.06, 0.065, 0.09, 0.98 if backdrop_kind.is_empty() else 0.9)
	style.border_color = VisualTheme.COLOR_BORDER_BRONZE
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	style.set_content_margin_all(16)
	panel.add_theme_stylebox_override("panel", style)
	panel.anchor_left = 0.04
	panel.anchor_right = 0.96
	panel.anchor_top = 0.1 if backdrop_kind.is_empty() else float(SHEET_TOP_BY_KIND.get(backdrop_kind, SHEET_TOP))
	panel.anchor_bottom = 0.9 if backdrop_kind.is_empty() else 0.98
	add_child(panel)
	_box = VBoxContainer.new()
	_box.add_theme_constant_override("separation", 10)
	if backdrop_kind.is_empty():
		panel.add_child(_box)
	else:
		# Bottom sheet (ADR-0047): alça, conteúdo rolável e rodapé fixo com a ação principal.
		var sheet: VBoxContainer = VBoxContainer.new()
		sheet.add_theme_constant_override("separation", 8)
		panel.add_child(sheet)
		var handle_row: CenterContainer = CenterContainer.new()
		sheet.add_child(handle_row)
		var handle: ColorRect = ColorRect.new()
		handle.color = VisualTheme.COLOR_BORDER_BRONZE
		handle.custom_minimum_size = Vector2(56, 5)
		handle_row.add_child(handle)
		var scroll: ScrollContainer = ScrollContainer.new()
		scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
		_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		scroll.add_child(_box)
		sheet.add_child(scroll)
		_footer = HBoxContainer.new()
		_footer.add_theme_constant_override("separation", 8)
		sheet.add_child(_footer)
	_render()


func show_reward() -> void:
	_mode = "reward"
	if _box != null:
		_render()


func show_chest() -> void:
	_mode = "chest"
	if _box != null:
		_render()


func show_shop() -> void:
	_mode = "shop"
	if _box != null:
		_render()


func show_campfire() -> void:
	_mode = "campfire"
	if _box != null:
		_render()


func show_event() -> void:
	_mode = "event"
	if _box != null:
		_render()


func _render() -> void:
	for container: Container in [_box, _footer]:
		if container == null:
			continue
		for child: Node in container.get_children():
			container.remove_child(child)
			child.queue_free()
	match _mode:
		"reward":
			_render_reward()
		"shop":
			_render_shop()
		"chest":
			_render_chest()
		"campfire":
			_render_campfire()
		"event":
			_render_event()


func _render_reward() -> void:
	var view: Dictionary = panels.reward_view()
	_title(str(view["title"]))
	for line: Variant in view["lines"]:
		_text(str(line))
	var drop: Dictionary = view["drop"]
	if not drop.is_empty():
		_render_drop(drop)
	_footer_button("Continuar (vende o drop)" if not drop.is_empty() else "Continuar", func() -> void: closed.emit())


## Equipamento caído: raridade, efeito, mudança de atributos e Equipar ou Vender.
func _render_drop(drop: Dictionary) -> void:
	var title: Label = _text("Caiu: %s (%s, %s)" % [str(drop["name"]), str(drop["rarity"]), str(drop["slot"])], 22)
	title.add_theme_color_override("font_color", Color(0.55, 0.8, 0.95))
	_text(str(drop["effect"]), 16)
	var changes: Array = drop["changes"]
	_text("Equipando: " + (", ".join(changes) if not changes.is_empty() else "sem mudança"), 16)
	var equip_label: String = "Equipar %s" % str(drop["name"])
	if str(drop["replaces"]) != "":
		equip_label += " (vende %s)" % str(drop["replaces"])
	_button(equip_label, func() -> void:
		panels.equip_drop()
		_render(), IconRegistry.texture_for("item", str(drop["id"])))
	_button("Vender por %d ouro" % int(drop["sell_value"]), func() -> void:
		panels.sell_drop()
		_render(), IconRegistry.texture_for("ui", "gold"))


func _render_chest() -> void:
	var view: Dictionary = panels.chest_view()
	_title(str(view["title"]))
	if bool(view["boosted"]):
		var mult: Label = _text("×%.2f" % (float(view.get("multiplier", 100)) / 100.0), 64)
		mult.theme_type_variation = "TitleLabel"
		mult.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		mult.add_theme_font_size_override("font_size", 64)
	for line: Variant in view["lines"]:
		_text(str(line))
	if not bool(view["boosted"]):
		_text("Multiplicar o baú (sorteio de ×1,25 a ×2, uma vez):", 16)
		var lucky: Button = _button("Usar Moeda da Sorte (%d)" % int(view["lucky_coins"]), func() -> void:
			panels.boost_chest("lucky_coin")
			_render(), IconRegistry.texture_for("ui", "luck"))
		lucky.disabled = not bool(view["can_lucky"])
		var ad: Button = _button("Assistir anúncio opcional (simulado)", func() -> void:
			panels.boost_chest("ad")
			_render(), IconRegistry.texture_for("ui", "gold"))
		ad.disabled = not bool(view["can_ad"])
	_footer_button("Seguir", func() -> void: closed.emit())


func _render_shop() -> void:
	var view: Dictionary = panels.shop_view()
	_title("Loja")
	_text("Ouro: %d    %s" % [int(view["gold"]), str(view["bag"])])
	var offer: Array = view["offer"]
	if offer.is_empty():
		_text("Nada mais à venda.")
	var grid: GridContainer = _card_grid()
	for entry: Dictionary in offer:
		var label: String = "%s
%s
%s
%d ouro" % [str(entry["name"]), str(entry["slot"]), str(entry["description"]), int(entry["price"])]
		if not bool(entry["can_buy"]):
			label += "
(%s)" % str(entry["reason"])
		var item_id: String = str(entry["id"])
		var buy: Button = _card(grid, label, func() -> void:
			panels.buy(item_id)
			_render(), IconRegistry.texture_for("item", item_id))
		buy.disabled = not bool(entry["can_buy"])
	var skill: Dictionary = view["skill"]
	if not skill.is_empty():
		var learn_label: String = "%s (%d MP)
%s
%s
%d ouro" % [str(skill["name"]), int(skill["cost"]), str(skill["description"]), str(skill["slots"]), int(skill["price"])]
		if not bool(skill["can_buy"]):
			learn_label += "
(%s)" % str(skill["reason"])
		var learn: Button = _card(grid, learn_label, func() -> void:
			panels.buy_skill()
			_render(), IconRegistry.texture_for("skill", str(skill["id"])))
		learn.disabled = not bool(skill["can_buy"])
	var reroll: Button = _footer_button("Atualizar: %d ouro" % int(view["reroll_cost"]), func() -> void:
		panels.reroll()
		_render())
	reroll.disabled = not bool(view["can_reroll"])
	_footer_button("Seguir", func() -> void: closed.emit())


func _render_campfire() -> void:
	var view: Dictionary = panels.campfire_view()
	if _backdrop != null:
		_backdrop.set_fire_lit(bool(view["lit"]))
	_title("Fogueira")
	if not bool(view["lit"]):
		_text("A fogueira está apagada. %s" % str(view["status"]), 18)
		var light: Button = _button("Acender a fogueira (gasta 1 Galho Seco; você tem %d)" % int(view["firewood"]), func() -> void:
			panels.light_campfire()
			_render(), IconRegistry.texture_for("ui", "firewood"))
		light.disabled = not bool(view["can_light"])
		if not bool(view["can_light"]):
			_text("Sem Galhos Secos não dá para acender. Eles caem raro de inimigos, baús e chefes, ou se compram na loja.", 16)
		_footer_button("Seguir", func() -> void: closed.emit())
		return
	_text(_ember_pins(int(view["embers"])), 26)
	_text(str(view["status"]), 16)
	var rest: Button = _button("Descansar (%d Brasas)" % int(view["rest_cost"]), func() -> void:
		panels.rest()
		_render(), IconRegistry.texture_for("ui", "embers"))
	rest.disabled = not bool(view["can_rest"])
	_text(str(view["rest_text"]), 16)
	var sick: Array = view["diseases"]
	if not sick.is_empty():
		var treat: Button = _button("Tratar %s (%d Brasa)" % [str(sick[0]), int(view["treat_cost"])], func() -> void:
			panels.treat_disease()
			_render(), IconRegistry.texture_for("disease", Diseases.LEPTOSPIROSIS))
		treat.disabled = not bool(view["can_treat"])
		_text("Doença: -15% de HP máximo até tratar.", 16)
	for entry: Dictionary in view["skills"]:
		var skill_id: String = str(entry["id"])
		var label: String = "%s (%d Brasas)
%s" % [str(entry["name"]), int(view["skill_cost"]), str(entry["description"])]
		var skill: Button = _button(label, func() -> void:
			panels.use_skill(skill_id)
			_render(), IconRegistry.texture_for("skill", skill_id))
		skill.disabled = not bool(entry["can_use"])
		var detail: String = str(entry["description"])
		if int(entry["left"]) > 0:
			detail += ". Ativa por mais %d lutas" % int(entry["left"])
		_text(detail, 16)
	_footer_button("Seguir", func() -> void: closed.emit())


func _render_event() -> void:
	var view: Dictionary = panels.event_view()
	if view.is_empty():
		return
	_title(str(view["title"]))
	_text(str(view["description"]), 18)
	if bool(view["resolved"]):
		for line: Variant in view["result_lines"]:
			var eff: Label = _text(str(line), 17)
			eff.add_theme_color_override("font_color", Color(0.85, 0.8, 0.55))
		var drop: Dictionary = view["drop"]
		if not drop.is_empty():
			_render_drop(drop)
		_footer_button("Seguir (vende o drop)" if not drop.is_empty() else "Seguir", func() -> void: closed.emit())
		return
	for choice: Dictionary in view["choices"]:
		var idx: int = int(choice["index"])
		var label: String = str(choice["label"])
		var can_pick: bool = bool(choice["can_choose"])
		if not can_pick:
			label += " (%s)" % str(choice["reason"])
		var btn: Button = _button(label, func() -> void:
			panels.choose_event_option(idx, CoinRules.HEADS, forced_coin)
			_render())
		btn.disabled = not can_pick


func _title(text: String) -> void:
	var label: Label = _text(text, 30)
	label.theme_type_variation = "TitleLabel"
	label.add_theme_color_override("font_color", Color(0.9, 0.75, 0.25))


func _text(text: String, size: int = 20) -> Label:
	var label: Label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", size)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_box.add_child(label)
	return label


## Botão em forma de cartão: ícone à esquerda, texto em até duas linhas (nome e efeito).
func _button(text: String, action: Callable, icon: Texture2D = null) -> Button:
	var button: Button = Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(0, 64 if icon != null else 56)
	# Texto longo quebra de linha em vez de alargar o painel além da tela.
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if icon != null:
		button.icon = icon
		button.expand_icon = true
		button.icon_alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.add_theme_constant_override("icon_max_width", 44)
		button.add_theme_constant_override("h_separation", 12)
		button.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	button.pressed.connect(action)
	_box.add_child(button)
	return button


## Rodapé fixo do sheet (ação principal sempre à vista); sem sheet cai no fim do conteúdo.
func _footer_button(text: String, action: Callable) -> Button:
	if _footer == null:
		return _button(text, action)
	var button: Button = Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(0, 58)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	button.pressed.connect(action)
	_footer.add_child(button)
	return button


func _card_grid() -> GridContainer:
	var grid: GridContainer = GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_box.add_child(grid)
	return grid


## Cartão de item (D-UI-3, loja em grade 2x2): ícone no alto, nome, efeito e preço.
func _card(grid: GridContainer, text: String, action: Callable, icon: Texture2D = null) -> Button:
	var button: Button = Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(0, 150)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	button.add_theme_font_size_override("font_size", 15)
	# Cartão sem ouro suficiente continua legível: pergaminho claro (o botão só deixa de agir).
	button.add_theme_color_override("font_disabled_color", Color(0.78, 0.74, 0.64))
	button.add_theme_color_override("font_color", Color(0.93, 0.89, 0.78))
	if icon != null:
		button.icon = icon
		button.expand_icon = true
		button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		button.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
		button.add_theme_constant_override("icon_max_width", 40)
		button.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	button.pressed.connect(action)
	grid.add_child(button)
	return button


## Pinos de Brasas acesas e apagadas: "●●●○○○  3/6" (D-UI-4).
static func _ember_pins(embers: int) -> String:
	var total: int = maxi(RunRules.EMBERS, embers)
	return "%s%s   %d/%d Brasas" % ["●".repeat(embers), "○".repeat(total - embers), embers, total]
