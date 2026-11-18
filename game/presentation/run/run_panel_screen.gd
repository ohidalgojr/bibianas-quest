class_name RunPanelScreen
extends Control
## Painel de recompensa, loja ou fogueira por cima do mapa (TASK-010, ADR-0015). Desenha
## o que o [RunPanels] entrega e se refaz a cada compra ou ação. [signal closed] sai
## quando o jogador aperta o botão final.

signal closed

var panels: RunPanels
var forced_coin: int = -1

var _box: VBoxContainer
var _mode: String = ""


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var dim: ColorRect = ColorRect.new()
	dim.color = Color(0.0, 0.0, 0.0, 0.55)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(dim)
	var panel: PanelContainer = PanelContainer.new()
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.05, 0.05, 0.08, 0.97)
	style.set_corner_radius_all(8)
	style.set_content_margin_all(16)
	panel.add_theme_stylebox_override("panel", style)
	panel.anchor_left = 0.04
	panel.anchor_right = 0.96
	panel.anchor_top = 0.1
	panel.anchor_bottom = 0.9
	add_child(panel)
	_box = VBoxContainer.new()
	_box.add_theme_constant_override("separation", 10)
	panel.add_child(_box)
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
	for child: Node in _box.get_children():
		_box.remove_child(child)
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
	_button("Continuar (vende o drop)" if not drop.is_empty() else "Continuar", func() -> void: closed.emit())


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
		_render())
	_button("Vender por %d ouro" % int(drop["sell_value"]), func() -> void:
		panels.sell_drop()
		_render())


func _render_chest() -> void:
	var view: Dictionary = panels.chest_view()
	_title(str(view["title"]))
	for line: Variant in view["lines"]:
		_text(str(line))
	if not bool(view["boosted"]):
		_text("Multiplicar o baú (sorteio de ×1,25 a ×2, uma vez):", 16)
		var lucky: Button = _button("Usar Moeda da Sorte (%d)" % int(view["lucky_coins"]), func() -> void:
			panels.boost_chest("lucky_coin")
			_render())
		lucky.disabled = not bool(view["can_lucky"])
		var ad: Button = _button("Assistir anúncio opcional (simulado)", func() -> void:
			panels.boost_chest("ad")
			_render())
		ad.disabled = not bool(view["can_ad"])
	_button("Seguir", func() -> void: closed.emit())


func _render_shop() -> void:
	var view: Dictionary = panels.shop_view()
	_title("Loja")
	_text("Ouro: %d    %s" % [int(view["gold"]), str(view["bag"])])
	var offer: Array = view["offer"]
	if offer.is_empty():
		_text("Nada mais à venda.")
	for entry: Dictionary in offer:
		_text("%s (%s): %s" % [str(entry["name"]), str(entry["slot"]), str(entry["description"])], 16)
		var label: String = "Comprar %s: %d ouro" % [str(entry["name"]), int(entry["price"])]
		if not bool(entry["can_buy"]):
			label += " (%s)" % str(entry["reason"])
		var item_id: String = str(entry["id"])
		var buy: Button = _button(label, func() -> void:
			panels.buy(item_id)
			_render())
		buy.disabled = not bool(entry["can_buy"])
	var skill: Dictionary = view["skill"]
	if not skill.is_empty():
		var skill_title: Label = _text("Skill: %s (%d MP). %s. %s" % [str(skill["name"]), int(skill["cost"]),
			str(skill["description"]), str(skill["slots"])], 16)
		skill_title.add_theme_color_override("font_color", Color(0.75, 0.6, 0.95))
		var learn_label: String = "Aprender %s: %d ouro" % [str(skill["name"]), int(skill["price"])]
		if not bool(skill["can_buy"]):
			learn_label += " (%s)" % str(skill["reason"])
		var learn: Button = _button(learn_label, func() -> void:
			panels.buy_skill()
			_render())
		learn.disabled = not bool(skill["can_buy"])
	var reroll: Button = _button("Atualizar loja: %d ouro" % int(view["reroll_cost"]), func() -> void:
		panels.reroll()
		_render())
	reroll.disabled = not bool(view["can_reroll"])
	_button("Seguir", func() -> void: closed.emit())


func _render_campfire() -> void:
	var view: Dictionary = panels.campfire_view()
	_title("Fogueira")
	if not bool(view["lit"]):
		_text("A fogueira está apagada. %s" % str(view["status"]), 18)
		var light: Button = _button("Acender a fogueira (gasta 1 Galho Seco; você tem %d)" % int(view["firewood"]), func() -> void:
			panels.light_campfire()
			_render())
		light.disabled = not bool(view["can_light"])
		if not bool(view["can_light"]):
			_text("Sem Galhos Secos não dá para acender. Eles caem raro de inimigos, baús e chefes, ou se compram na loja.", 16)
		_button("Seguir", func() -> void: closed.emit())
		return
	_text("Brasas: %d. %s" % [int(view["embers"]), str(view["status"])])
	var rest: Button = _button("Descansar (%d Brasas)" % int(view["rest_cost"]), func() -> void:
		panels.rest()
		_render())
	rest.disabled = not bool(view["can_rest"])
	_text(str(view["rest_text"]), 16)
	var sick: Array = view["diseases"]
	if not sick.is_empty():
		var treat: Button = _button("Tratar %s (%d Brasa)" % [str(sick[0]), int(view["treat_cost"])], func() -> void:
			panels.treat_disease()
			_render())
		treat.disabled = not bool(view["can_treat"])
		_text("Doença: -15% de HP máximo até tratar.", 16)
	for entry: Dictionary in view["skills"]:
		var skill_id: String = str(entry["id"])
		var label: String = "%s (%d Brasas)" % [str(entry["name"]), int(view["skill_cost"])]
		var skill: Button = _button(label, func() -> void:
			panels.use_skill(skill_id)
			_render())
		skill.disabled = not bool(entry["can_use"])
		var detail: String = str(entry["description"])
		if int(entry["left"]) > 0:
			detail += ". Ativa por mais %d lutas" % int(entry["left"])
		_text(detail, 16)
	_button("Seguir", func() -> void: closed.emit())


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
		_button("Seguir (vende o drop)" if not drop.is_empty() else "Seguir", func() -> void: closed.emit())
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
	label.add_theme_color_override("font_color", Color(0.9, 0.75, 0.25))


func _text(text: String, size: int = 20) -> Label:
	var label: Label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", size)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_box.add_child(label)
	return label


func _button(text: String, action: Callable) -> Button:
	var button: Button = Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(0, 56)
	# Texto longo quebra de linha em vez de alargar o painel além da tela.
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	button.pressed.connect(action)
	_box.add_child(button)
	return button
