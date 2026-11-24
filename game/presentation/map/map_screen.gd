class_name MapScreen
extends Control
## Tabuleiro visual da Cidade Abandonada (TASK-009, TASK-031, ADR-0013, ADR-0035):
## estradas curvas de calçamento, praças de pedra com brasões vetoriais por tipo de nó,
## neblina/vinheta nas camadas sob névoa, brilho quente nos 3 destinos disponíveis (GDD §17)
## e peão da Bibiana com a realce neutro do nó atual (mecha colorida removida, F-024).

signal node_chosen(node_id: int)

const NODE_SIZE: Vector2 = Vector2(108, 66)
const COLOR_BG: Color = VisualTheme.COLOR_BG_DEEP
const COLOR_EDGE: Color = Color(0.24, 0.25, 0.30, 0.85)
const COLOR_EDGE_LIT: Color = VisualTheme.COLOR_GOLD
const KIND_COLORS: Dictionary = {
	MapNode.Kind.START: Color(0.24, 0.36, 0.54),
	MapNode.Kind.BATTLE: Color(0.38, 0.22, 0.22),
	MapNode.Kind.AMBUSH: Color(0.42, 0.18, 0.30),
	MapNode.Kind.ELITE: Color(0.56, 0.16, 0.16),
	MapNode.Kind.CHEST: Color(0.50, 0.42, 0.18),
	MapNode.Kind.EVENT: Color(0.28, 0.28, 0.44),
	MapNode.Kind.BONFIRE: Color(0.62, 0.34, 0.12),
	MapNode.Kind.MINI_BOSS: Color(0.48, 0.12, 0.24),
	MapNode.Kind.BOSS: Color(0.36, 0.09, 0.13),
}
const COLOR_FOG: Color = Color(0.13, 0.14, 0.17)

var view: MapView
var _header: Label
var _board: Board
var _buttons: Dictionary = {}


## Área do tabuleiro: desenha calçamento, névoa, estradas curvas, praças, brasões e o peão da Bibiana.
class Board extends Control:
	var edges: Array[Array] = []
	var centers: Dictionary = {}
	var nodes_meta: Array[Dictionary] = []
	var current_id: int = -1
	var current_color: Color = VisualTheme.COLOR_CURRENT_NODE

	func _draw() -> void:
		if size.x <= 4.0 or size.y <= 4.0:
			return
		# Fundo de ardósia do diorama com vinheta de névoa no topo (camadas distantes)
		draw_rect(Rect2(Vector2.ZERO, size), Color(0.07, 0.075, 0.095, 1.0), true)
		draw_rect(Rect2(Vector2.ZERO, Vector2(size.x, size.y * 0.35)), Color(0.11, 0.12, 0.16, 0.28), true)
		draw_rect(Rect2(Vector2(1, 1), size - Vector2(2, 2)), VisualTheme.COLOR_BORDER_BRONZE.darkened(0.25), false, 1.5)

		# Estradas curvas entre nós (GDD §17.2)
		for edge: Array in edges:
			if not centers.has(edge[0]) or not centers.has(edge[1]):
				continue
			var p0: Vector2 = centers[edge[0]]
			var p1: Vector2 = centers[edge[1]]
			var lit: bool = bool(edge[2])
			var curve_pts: PackedVector2Array = _road_points(p0, p1)
			draw_polyline(curve_pts, Color(0.04, 0.04, 0.06, 0.9), 8.0 if lit else 5.0, true)
			draw_polyline(curve_pts, MapScreen.COLOR_EDGE_LIT if lit else MapScreen.COLOR_EDGE,
				4.0 if lit else 2.2, true)

		# Praças de pedra, halo nos 3 caminhos disponíveis e brasão vetorial de cada nó (GDD §17.3 e §17.5)
		for node: Dictionary in nodes_meta:
			var nid: int = int(node["id"])
			if not centers.has(nid):
				continue
			var c: Vector2 = centers[nid]
			var state: MapView.State = node["state"]
			var kind: int = int(node["kind"])
			if state == MapView.State.OPTION:
				var glow: Color = VisualTheme.COLOR_DANGER if bool(node.get("mini_boss", false)) else VisualTheme.COLOR_GOLD
				draw_circle(c, 44.0, Color(glow.r, glow.g, glow.b, 0.14))
			elif state == MapView.State.CURRENT:
				draw_circle(c, 46.0, Color(current_color.r, current_color.g, current_color.b, 0.24))
				draw_arc(c, 42.0, 0.0, TAU, 28, current_color, 2.5)
			var emblem_pos: Vector2 = c + Vector2(0, -MapScreen.NODE_SIZE.y * 0.56)
			if emblem_pos.y >= 10.0 and state != MapView.State.PAST:
				var emblem_tint: Color = VisualTheme.COLOR_GOLD if state == MapView.State.OPTION else Color(0.65, 0.66, 0.72)
				if state != MapView.State.FOG or kind == MapNode.Kind.BOSS or bool(node.get("mini_boss", false)):
					VisualTheme.draw_node_emblem(self, emblem_pos, kind, 9.5, emblem_tint)

	func _road_points(p0: Vector2, p1: Vector2) -> PackedVector2Array:
		var mid: Vector2 = (p0 + p1) * 0.5
		var dx: float = p1.x - p0.x
		var bend: float = clampf(dx * 0.18, -22.0, 22.0)
		var ctrl: Vector2 = mid + Vector2(bend, 0.0)
		var pts: PackedVector2Array = PackedVector2Array()
		var steps: int = 10
		for i: int in range(steps + 1):
			var t: float = float(i) / float(steps)
			var inv: float = 1.0 - t
			var p: Vector2 = (inv * inv) * p0 + (2.0 * inv * t) * ctrl + (t * t) * p1
			pts.append(p)
		return pts


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
	column.add_theme_constant_override("separation", 8)
	margin.add_child(column)

	var header_panel: PanelContainer = PanelContainer.new()
	header_panel.add_theme_stylebox_override("panel", VisualTheme.styled_panel())
	column.add_child(header_panel)
	var header_box: VBoxContainer = VBoxContainer.new()
	header_box.add_theme_constant_override("separation", 4)
	header_panel.add_child(header_box)

	_header = Label.new()
	_header.add_theme_font_size_override("font_size", 16)
	_header.add_theme_color_override("font_color", VisualTheme.COLOR_PARCHMENT)
	_header.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	header_box.add_child(_header)

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
	_board.current_id = view.run.current_node_id

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
	var all_nodes: Array[Dictionary] = view.nodes()
	_board.nodes_meta = all_nodes
	for node: Dictionary in all_nodes:
		var layer: int = int(node["layer"])
		var x: float = step_x * int(node["column"])
		if layer == 0 or layer == rows - 1:
			x = (area.x - NODE_SIZE.x) / 2.0
		var y: float = step_y * (rows - 1 - layer)
		var button: Button = _node_button(node, VisualTheme.COLOR_CURRENT_NODE)
		button.position = Vector2(x, y)
		_board.add_child(button)
		_buttons[int(node["id"])] = button
		_board.centers[int(node["id"])] = Vector2(x, y) + NODE_SIZE / 2.0
	_board.edges = view.edges()
	_board.queue_redraw()


func button_for(node_id: int) -> Button:
	return _buttons.get(node_id)


func _node_button(node: Dictionary, current_color: Color) -> Button:
	var button: Button = Button.new()
	button.size = NODE_SIZE
	button.custom_minimum_size = NODE_SIZE
	button.add_theme_font_size_override("font_size", 14)
	var title: String = str(node["title"])
	var detail: String = str(node["detail"])
	button.text = title if detail.is_empty() else "%s\n%s" % [title, detail.replace(", ", "\n")]
	if not detail.is_empty():
		button.add_theme_font_size_override("font_size", 11)
	var state: MapView.State = node["state"]
	var kind: int = int(node["kind"])
	var color: Color = KIND_COLORS.get(kind, COLOR_FOG)
	match state:
		MapView.State.FOG, MapView.State.PAST:
			color = COLOR_FOG
		MapView.State.VISITED:
			color = color.darkened(0.45)
		MapView.State.CURRENT:
			color = Color(0.16, 0.22, 0.32)
	var box: StyleBoxFlat = StyleBoxFlat.new()
	box.bg_color = color
	box.set_corner_radius_all(10)
	box.border_color = VisualTheme.COLOR_BORDER_BRONZE.darkened(0.2)
	box.set_border_width_all(1)
	if state == MapView.State.CURRENT:
		box.border_color = current_color
		box.set_border_width_all(3)
	elif state == MapView.State.OPTION:
		box.border_color = VisualTheme.COLOR_DANGER if bool(node.get("mini_boss", false)) else COLOR_EDGE_LIT
		box.set_border_width_all(3)
	elif bool(node.get("mini_boss", false)) and state == MapView.State.FOG:
		box.border_color = VisualTheme.COLOR_DANGER
		box.set_border_width_all(2)
	for style: String in ["normal", "hover", "pressed", "disabled", "focus"]:
		button.add_theme_stylebox_override(style, box)
	if state == MapView.State.PAST:
		button.modulate = Color(1, 1, 1, 0.4)
	button.disabled = not bool(node["clickable"])
	button.add_theme_color_override("font_disabled_color", VisualTheme.COLOR_PARCHMENT)
	button.add_theme_color_override("font_color", Color.WHITE)
	button.pressed.connect(_on_pressed.bind(int(node["id"])))
	return button


func _on_pressed(node_id: int) -> void:
	SoundFx.play(self, "step")
	node_chosen.emit(node_id)
