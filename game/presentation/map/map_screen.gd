class_name MapScreen
extends Control
## Tela do mapa do protótipo cinza (TASK-009, ADR-0013): grade em retrato, chefe no
## alto, partida embaixo. Desenha o que o [MapView] entrega; um toque num destino emite
## [signal node_chosen]. Não chama regras.

signal node_chosen(node_id: int)

const NODE_SIZE: Vector2 = Vector2(104, 64)
const COLOR_BG: Color = Color(0.07, 0.08, 0.1)
const COLOR_EDGE: Color = Color(0.25, 0.26, 0.3)
const COLOR_EDGE_LIT: Color = Color(0.85, 0.75, 0.45)
const KIND_COLORS: Dictionary = {
	MapNode.Kind.START: Color(0.35, 0.5, 0.75),
	MapNode.Kind.BATTLE: Color(0.55, 0.32, 0.3),
	MapNode.Kind.AMBUSH: Color(0.6, 0.25, 0.4),
	MapNode.Kind.ELITE: Color(0.75, 0.2, 0.2),
	MapNode.Kind.CHEST: Color(0.7, 0.6, 0.25),
	MapNode.Kind.EVENT: Color(0.4, 0.4, 0.6),
	MapNode.Kind.BONFIRE: Color(0.85, 0.5, 0.15),
	MapNode.Kind.MINI_BOSS: Color(0.6, 0.15, 0.3),
	MapNode.Kind.BOSS: Color(0.45, 0.1, 0.15),
}
const COLOR_FOG: Color = Color(0.16, 0.17, 0.2)

var view: MapView
var _header: Label
var _board: Board
var _buttons: Dictionary = {}


## Área do tabuleiro: desenha as ligações por baixo dos botões.
class Board extends Control:
	var edges: Array[Array] = []
	var centers: Dictionary = {}

	func _draw() -> void:
		for edge: Array in edges:
			if not centers.has(edge[0]) or not centers.has(edge[1]):
				continue
			var lit: bool = bool(edge[2])
			draw_line(centers[edge[0]], centers[edge[1]], MapScreen.COLOR_EDGE_LIT if lit else MapScreen.COLOR_EDGE,
				4.0 if lit else 2.0, true)


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var background: ColorRect = ColorRect.new()
	background.color = COLOR_BG
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	var margin: MarginContainer = MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side: String in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 16)
	add_child(margin)
	var column: VBoxContainer = VBoxContainer.new()
	column.add_theme_constant_override("separation", 12)
	margin.add_child(column)
	_header = Label.new()
	_header.add_theme_font_size_override("font_size", 18)
	column.add_child(_header)
	_board = Board.new()
	_board.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_board.resized.connect(refresh)
	column.add_child(_board)
	refresh()


## Redesenha a partir do estado atual da Descida.
func refresh() -> void:
	if view == null or _board == null:
		return
	_header.text = view.header()
	for button: Button in _buttons.values():
		_board.remove_child(button)
		button.queue_free()
	_buttons.clear()
	var rows: int = view.run.map.layer_count + 2
	var width: int = view.run.map.width
	var area: Vector2 = _board.size
	var step_y: float = maxf((area.y - NODE_SIZE.y) / maxf(rows - 1, 1), 0.0)
	var step_x: float = maxf((area.x - NODE_SIZE.x) / maxf(width - 1, 1), 0.0)
	_board.centers.clear()
	for node: Dictionary in view.nodes():
		var layer: int = int(node["layer"])
		var x: float = step_x * int(node["column"])
		if layer == 0 or layer == rows - 1:
			x = (area.x - NODE_SIZE.x) / 2.0
		var y: float = step_y * (rows - 1 - layer)
		var button: Button = _node_button(node)
		button.position = Vector2(x, y)
		_board.add_child(button)
		_buttons[int(node["id"])] = button
		_board.centers[int(node["id"])] = Vector2(x, y) + NODE_SIZE / 2.0
	_board.edges = view.edges()
	_board.queue_redraw()


func button_for(node_id: int) -> Button:
	return _buttons.get(node_id)


func _node_button(node: Dictionary) -> Button:
	var button: Button = Button.new()
	button.size = NODE_SIZE
	button.custom_minimum_size = NODE_SIZE
	button.add_theme_font_size_override("font_size", 15)
	var title: String = str(node["title"])
	var detail: String = str(node["detail"])
	button.text = title if detail.is_empty() else "%s\n%s" % [title, detail.replace(", ", "\n")]
	if not detail.is_empty():
		button.add_theme_font_size_override("font_size", 12)
	var state: MapView.State = node["state"]
	var kind: int = int(node["kind"])
	var color: Color = KIND_COLORS.get(kind, COLOR_FOG)
	match state:
		MapView.State.FOG, MapView.State.PAST:
			color = COLOR_FOG
		MapView.State.VISITED:
			color = color.darkened(0.5)
		MapView.State.CURRENT:
			color = KIND_COLORS[MapNode.Kind.START]
	var box: StyleBoxFlat = StyleBoxFlat.new()
	box.bg_color = color
	box.set_corner_radius_all(8)
	if state == MapView.State.OPTION:
		box.border_color = Color(0.85, 0.2, 0.2) if bool(node.get("mini_boss", false)) else COLOR_EDGE_LIT
		box.set_border_width_all(4)
	elif bool(node.get("mini_boss", false)) and state == MapView.State.FOG:
		box.border_color = Color(0.85, 0.2, 0.2)
		box.set_border_width_all(3)
	for style: String in ["normal", "hover", "pressed", "disabled", "focus"]:
		button.add_theme_stylebox_override(style, box)
	if state == MapView.State.PAST:
		button.modulate = Color(1, 1, 1, 0.4)
	button.disabled = not bool(node["clickable"])
	button.add_theme_color_override("font_disabled_color", Color(0.85, 0.85, 0.85))
	button.pressed.connect(_on_pressed.bind(int(node["id"])))
	return button


func _on_pressed(node_id: int) -> void:
	node_chosen.emit(node_id)
