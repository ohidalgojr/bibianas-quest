class_name RunPanelScreen
extends Control
## Painel de recompensa, loja ou fogueira por cima do mapa (TASK-010, ADR-0015). Desenha
## o que o [RunPanels] entrega e se refaz a cada compra ou ação. [signal closed] sai
## quando o jogador aperta o botão final.

signal closed

var panels: RunPanels

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


func show_shop() -> void:
	_mode = "shop"
	if _box != null:
		_render()


func show_campfire() -> void:
	_mode = "campfire"
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
		"campfire":
			_render_campfire()


func _render_reward() -> void:
	var view: Dictionary = panels.reward_view()
	_title(str(view["title"]))
	for line: Variant in view["lines"]:
		_text(str(line))
	_button("Continuar", func() -> void: closed.emit())


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
	var reroll: Button = _button("Atualizar loja: %d ouro" % int(view["reroll_cost"]), func() -> void:
		panels.reroll()
		_render())
	reroll.disabled = not bool(view["can_reroll"])
	_button("Seguir", func() -> void: closed.emit())


func _render_campfire() -> void:
	var view: Dictionary = panels.campfire_view()
	_title("Fogueira")
	_text("Brasas: %d. %s" % [int(view["embers"]), str(view["status"])])
	var rest: Button = _button("Descansar (%d Brasas)" % int(view["rest_cost"]), func() -> void:
		panels.rest()
		_render())
	rest.disabled = not bool(view["can_rest"])
	_text(str(view["rest_text"]), 16)
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
	button.pressed.connect(action)
	_box.add_child(button)
	return button
