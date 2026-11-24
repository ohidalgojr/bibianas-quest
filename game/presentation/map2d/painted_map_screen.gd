class_name PaintedMapScreen
extends Control
## Mapa pintado (TASK-067, ADR-0054, GDD §5 e §17, crítica do diretor): rua gótica vertical montada com as
## arenas pintadas, estradas desenhadas, sprites HD-2D de inimigos e props com contorno de luz e sombra de
## contato, e o herói a cerca de 70% da altura. A câmera rola na vertical acompanhando a Bibiana.
## Só apresentação: lê o [MapView]. Mesma interface pública do [Map3DScreen] (que fica como reserva).

signal node_chosen(node_id: int)

const WIDTH: float = 540.0
const VIEW_HEIGHT: float = 960.0
const LAYER_STEP: float = 150.0
const TOP_PAD: float = 230.0
const BOTTOM_PAD: float = 210.0
## Altura da tela (px) em que o herói fica parado.
const HERO_SCREEN_Y: float = 670.0
const SIDE_MARGIN: float = 8.0
const SPRITES: String = "res://assets/bibiana/sprites/"
## Do chão ao topo da Descida (cada imagem 1024x1835 vira 540 de largura).
const ARENAS: Array[String] = [
	"res://assets/bibiana/arenas/arena-cidade-rua.jpg",
	"res://assets/bibiana/arenas/arena-cidade-praca.jpg",
	"res://assets/bibiana/arenas/arena-home-santuario.jpg",
]
const WALK_SECONDS: float = 0.7
## Altura em pixels do sprite na tela por tipo de nó (crítica do diretor, (c) 3).
const HEIGHT_COMMON: float = 132.0
const HEIGHT_ELITE: float = 168.0
const HEIGHT_MINI: float = 188.0
const HEIGHT_BOSS: float = 226.0
const HEIGHT_HERO: float = 150.0
const MAX_WIDTH_RATIO: float = 1.15
const REWARD_HINT: Dictionary = {
	MapNode.Kind.BATTLE: "ouro", MapNode.Kind.AMBUSH: "emboscada", MapNode.Kind.ELITE: "equip. raro",
	MapNode.Kind.CHEST: "baú", MapNode.Kind.EVENT: "evento", MapNode.Kind.BONFIRE: "fogueira",
	MapNode.Kind.MINI_BOSS: "raro garantido", MapNode.Kind.BOSS: "chefe",
}
const RIM_SHADER: String = """shader_type canvas_item;
uniform float brightness = 1.28;
uniform vec4 rim_color : source_color = vec4(0.62, 0.70, 0.84, 1.0);
void fragment() {
	vec4 c = texture(TEXTURE, UV);
	vec2 px = TEXTURE_PIXEL_SIZE * 1.5;
	float lo = min(min(texture(TEXTURE, UV + vec2(px.x, 0.0)).a, texture(TEXTURE, UV - vec2(px.x, 0.0)).a),
		min(texture(TEXTURE, UV + vec2(0.0, px.y)).a, texture(TEXTURE, UV - vec2(0.0, px.y)).a));
	vec3 col = c.rgb * brightness;
	if (c.a > 0.5 && lo < 0.5) {
		col = mix(col, rim_color.rgb, 0.6);
	}
	COLOR = vec4(col, c.a);
}
"""

var view: MapView
var time_scale: float = 1.0
var preview_enabled: bool = DisplayServer.get_name() != "headless"

var _world: Control
var _roads: RoadLayer
var _actors: Control
var _overlay: Control
var _hero: Control
var _positions: Dictionary = {}
## Topo do sprite (y no mundo) de cada nó desenhado, para ancorar seta e pílulas.
var _tops: Dictionary = {}
var _world_height: float = 1500.0
var _taps: Dictionary = {}
var _bubbles: Dictionary = {}
var _glows: Array[Control] = []
var _walking: bool = false
var _previewed: int = -1
var _preview_card: PanelContainer
var _marker: Control
var _gear_row: HBoxContainer
var _hud_hp: ProgressBar
var _hud_mp: ProgressBar
var _hud_gold: Label
var _rim_material: ShaderMaterial
var _pulse_time: float = 0.0


## Estradas e pedras sob os nós (desenho 2D simples, sem texturas).
class RoadLayer extends Control:
	var edges: Array[Array] = []
	var positions: Dictionary = {}
	var discs: Array[Dictionary] = []
	## Trecho escolhido para a prévia: [de, para] ou vazio.
	var selected: Array[int] = []

	func _draw() -> void:
		for edge: Array in edges:
			var a: Vector2 = positions[int(edge[0])]
			var b: Vector2 = positions[int(edge[1])]
			var pts: PackedVector2Array = PaintedMapScreen.road_points(a, b)
			var lit: bool = bool(edge[2])
			if not lit:
				# Ramo adiante: trilha fina e apagada, só para mostrar a estrutura.
				draw_polyline(pts, Color(0.04, 0.045, 0.06, 0.55), 9.0, true)
				draw_polyline(pts, Color(0.30, 0.32, 0.38, 0.45), 4.0, true)
				continue
			draw_polyline(pts, Color(0.03, 0.035, 0.05, 0.9), 22.0, true)
			draw_polyline(pts, Color(0.20, 0.22, 0.27, 0.9), 16.0, true)
			if lit:
				draw_polyline(pts, Color(0.93, 0.68, 0.30, 0.85), 3.0, true)
		if selected.size() == 2:
			var sel: PackedVector2Array = PaintedMapScreen.road_points(positions[selected[0]], positions[selected[1]])
			draw_polyline(sel, Color(1.0, 0.75, 0.3, 0.35), 34.0, true)
			draw_polyline(sel, Color(1.0, 0.85, 0.45, 1.0), 6.0, true)
			var i: int = 1
			while i < sel.size() - 1:
				draw_circle(sel[i], 5.0, Color(1.0, 0.92, 0.6, 1.0))
				i += 2
		for disc: Dictionary in discs:
			var c: Vector2 = disc["pos"]
			var r: float = float(disc["radius"])
			draw_set_transform(c, 0.0, Vector2(1.0, 0.42))
			draw_circle(Vector2.ZERO, r + 5.0, Color(0.02, 0.025, 0.04, 0.85))
			draw_circle(Vector2.ZERO, r, disc["color"])
			draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


## Curva em S entre dois nós (quadrática com controle deslocado).
static func road_points(a: Vector2, b: Vector2) -> PackedVector2Array:
	var mid: Vector2 = (a + b) * 0.5
	var control: Vector2 = mid + Vector2((b.x - a.x) * 0.0 + (14.0 if int(a.y / 10.0) % 2 == 0 else -14.0), 0.0)
	var pts: PackedVector2Array = PackedVector2Array()
	for i: int in 13:
		var t: float = float(i) / 12.0
		pts.append(a.lerp(control, t).lerp(control.lerp(b, t), t))
	return pts


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	clip_contents = true
	var layers: int = view.run.map.layer_count
	_world_height = maxf(TOP_PAD + float(layers + 1) * LAYER_STEP + BOTTOM_PAD, VIEW_HEIGHT * 1.4)
	_rim_material = ShaderMaterial.new()
	var shader: Shader = Shader.new()
	shader.code = RIM_SHADER
	_rim_material.shader = shader
	_compute_positions()
	_world = Control.new()
	_world.size = Vector2(WIDTH, _world_height)
	_world.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_world)
	_build_backdrop()
	_roads = RoadLayer.new()
	_roads.size = _world.size
	_roads.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_world.add_child(_roads)
	_actors = Control.new()
	_actors.size = _world.size
	_actors.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_world.add_child(_actors)
	_overlay = Control.new()
	_overlay.size = _world.size
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_world.add_child(_overlay)
	add_child(WeatherLayer.new())
	_add_vignette()
	_build_top_strip()
	_build_hud()
	_gear_row = HBoxContainer.new()
	_gear_row.position = Vector2(10, 26)
	_gear_row.add_theme_constant_override("separation", 6)
	_gear_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_gear_row)
	refresh()
	_focus_on(view.run.current_node_id, 0.0)


func _process(delta: float) -> void:
	_pulse_time += delta
	var k: float = 0.55 + 0.35 * sin(_pulse_time * 2.4)
	for glow: Control in _glows:
		if is_instance_valid(glow):
			glow.modulate.a = k


## Posição dos pés de cada nó no mundo: a partida embaixo e o chefe no alto, colunas espalhadas em S.
func _compute_positions() -> void:
	_positions.clear()
	var graph: MapGraph = view.run.map
	var width: int = maxi(graph.width, 2)
	var last_layer: int = graph.layer_count + 1
	for node: MapNode in graph.nodes:
		var y: float = _world_height - BOTTOM_PAD - float(node.layer) * LAYER_STEP
		var x: float = WIDTH * 0.5
		if node.layer > 0 and node.layer < last_layer:
			x = 78.0 + float(node.column) * (WIDTH - 156.0) / float(width - 1)
			x += sin(float(node.layer) * 1.3 + float(node.column) * 0.7) * 12.0
		_positions[node.id] = Vector2(x, y)


func world_pos(node_id: int) -> Vector2:
	return _positions[node_id]


## Fundo contínuo: arenas pintadas empilhadas do chão ao topo, com faixas de névoa nas emendas.
func _build_backdrop() -> void:
	var piece_h: float = WIDTH * 1835.0 / 1024.0
	var count: int = int(ceil(_world_height / piece_h))
	for i: int in count:
		var tex: Texture2D = load(ARENAS[mini(i, ARENAS.size() - 1)]) as Texture2D
		var rect: TextureRect = TextureRect.new()
		rect.texture = tex
		rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		rect.stretch_mode = TextureRect.STRETCH_SCALE
		rect.size = Vector2(WIDTH, piece_h)
		rect.position = Vector2(0.0, _world_height - piece_h * float(i + 1))
		rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_world.add_child(rect)
		if i > 0:
			_world.add_child(_mist_band(rect.position.y + piece_h - 110.0, 220.0))
	var dim: ColorRect = ColorRect.new()
	dim.color = Color(0.02, 0.025, 0.04, 0.22)
	dim.size = _world.size
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_world.add_child(dim)


func _mist_band(y: float, height: float) -> TextureRect:
	var gradient: Gradient = Gradient.new()
	gradient.colors = PackedColorArray([Color(0.05, 0.06, 0.09, 0.0), Color(0.06, 0.075, 0.11, 0.92), Color(0.05, 0.06, 0.09, 0.0)])
	gradient.offsets = PackedFloat32Array([0.0, 0.5, 1.0])
	var tex: GradientTexture2D = GradientTexture2D.new()
	tex.gradient = gradient
	tex.fill_from = Vector2(0.0, 0.0)
	tex.fill_to = Vector2(0.0, 1.0)
	tex.width = 8
	tex.height = 64
	var band: TextureRect = TextureRect.new()
	band.texture = tex
	band.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	band.stretch_mode = TextureRect.STRETCH_SCALE
	band.size = Vector2(WIDTH, height)
	band.position = Vector2(0.0, y)
	band.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return band


func _build_top_strip() -> void:
	var strip: TextureRect = _mist_band(0.0, 120.0)
	strip.modulate = Color(0.02, 0.025, 0.04, 1.0)
	var gradient: Gradient = Gradient.new()
	gradient.colors = PackedColorArray([Color(0.02, 0.025, 0.04, 0.9), Color(0.02, 0.025, 0.04, 0.0)])
	gradient.offsets = PackedFloat32Array([0.0, 1.0])
	var tex: GradientTexture2D = GradientTexture2D.new()
	tex.gradient = gradient
	tex.fill_from = Vector2(0.0, 0.0)
	tex.fill_to = Vector2(0.0, 1.0)
	tex.width = 8
	tex.height = 64
	strip.texture = tex
	strip.modulate = Color.WHITE
	add_child(strip)


func _add_vignette() -> void:
	var rect: ColorRect = ColorRect.new()
	rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var shader: Shader = Shader.new()
	shader.code = "shader_type canvas_item;\nvoid fragment() {\n\tvec2 uv = UV - vec2(0.5);\n\tfloat d = dot(uv, uv) * 2.0;\n\tCOLOR = vec4(0.0, 0.0, 0.02, clamp(d * d * 1.1, 0.0, 0.7));\n}\n"
	var mat: ShaderMaterial = ShaderMaterial.new()
	mat.shader = shader
	rect.material = mat
	add_child(rect)


## Recria tudo a partir do estado atual da Descida.
func refresh() -> void:
	if view == null or _actors == null:
		return
	for child: Node in _actors.get_children():
		child.queue_free()
	for child: Node in _overlay.get_children():
		child.queue_free()
	_glows.clear()
	_tops.clear()
	_taps.clear()
	_bubbles.clear()
	_refresh_hud()
	_fill_gear()
	_roads.positions = _positions
	_roads.edges = _visible_edges()
	_roads.discs = []
	_build_decor()
	var infos: Array[Dictionary] = view.nodes()
	infos.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return world_pos(int(a["id"])).y < world_pos(int(b["id"])).y)
	for info: Dictionary in infos:
		_build_node(info)
	_build_hero()
	_roads.queue_redraw()


## Ligações que aparecem: o caminho feito, as ofertas e os ramos que saem dos destinos.
func _visible_edges() -> Array[Array]:
	var shown: Array[Array] = []
	var options: PackedInt32Array = view.option_ids()
	for edge: Array in view.edges():
		if bool(edge[2]) or options.has(int(edge[0])):
			shown.append(edge)
	return shown


## Postes e lápides nas bordas, a cada duas camadas, para dar escala e luz de rua.
func _build_decor() -> void:
	var layers: int = view.run.map.layer_count
	for layer: int in range(1, layers + 1):
		var y: float = _world_height - BOTTOM_PAD - float(layer) * LAYER_STEP + 40.0
		if layer % 2 == 1:
			var left: bool = (layer / 2) % 2 == 0
			var x: float = 30.0 if left else WIDTH - 30.0
			_add_glow(Vector2(x, y - 110.0), 90.0, Color(1.0, 0.7, 0.32), 0.5)
			_add_sprite("plague_lamppost", Vector2(x, y), 150.0, 64.0, false)
		elif layer % 4 == 0:
			_add_sprite("gothic_tombstone", Vector2(WIDTH - 34.0, y), 78.0, 60.0, false)


func _build_node(info: Dictionary) -> void:
	var state: MapView.State = info["state"]
	var node: MapNode = view.run.map.node_by_id(int(info["id"]))
	var at: Vector2 = world_pos(node.id)
	if state == MapView.State.PAST:
		return
	if state == MapView.State.FOG:
		if node.layer > view.run.current_node().layer + 2:
			return
		_roads.discs.append({"pos": at, "radius": 26.0, "color": Color(0.12, 0.13, 0.17, 0.4)})
		var mark: Label = Label.new()
		mark.text = "?"
		mark.add_theme_font_size_override("font_size", 28)
		mark.add_theme_color_override("font_color", Color(0.55, 0.58, 0.66, 0.7))
		mark.position = at + Vector2(-8.0, -48.0)
		mark.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_actors.add_child(mark)
		return
	var offered: bool = state == MapView.State.OPTION
	_roads.discs.append({"pos": at, "radius": 44.0 if offered or state == MapView.State.BOSS else 36.0,
		"color": Color(0.30, 0.27, 0.22, 0.95) if offered else Color(0.16, 0.17, 0.21, 0.9)})
	if offered:
		var warm: Color = VisualTheme.COLOR_DANGER if bool(info.get("mini_boss", false)) else Color(1.0, 0.72, 0.32)
		_add_glow(at + Vector2(0.0, -4.0), 84.0, warm, 0.55)
	if state == MapView.State.BOSS:
		_add_glow(at + Vector2(0.0, -80.0), 120.0, Color(0.9, 0.18, 0.14), 0.5)
	if state == MapView.State.CURRENT or node.kind == MapNode.Kind.START or state == MapView.State.VISITED:
		return
	var holder: Control = null
	if node.is_fight() and not node.enemy_id.is_empty() and ModelRegistry.has_sprite(node.enemy_id):
		var height: float = HEIGHT_COMMON
		if node.kind == MapNode.Kind.ELITE:
			height = HEIGHT_ELITE
		elif node.kind == MapNode.Kind.MINI_BOSS:
			height = HEIGHT_MINI
		elif node.kind == MapNode.Kind.BOSS:
			height = HEIGHT_BOSS
		holder = _add_sprite(node.enemy_id, at + Vector2(0.0, 6.0), height, height * MAX_WIDTH_RATIO, true)
	else:
		match node.kind:
			MapNode.Kind.CHEST:
				holder = _add_sprite("iron_chest", at + Vector2(0.0, 6.0), 84.0, 110.0, true)
			MapNode.Kind.BONFIRE:
				holder = _add_sprite("campfire", at + Vector2(0.0, 12.0), 96.0, 150.0, false)
				_add_glow(at + Vector2(0.0, -20.0), 110.0, Color(1.0, 0.55, 0.2), 0.7)
			MapNode.Kind.EVENT:
				holder = _add_sprite("gothic_tombstone", at + Vector2(0.0, 6.0), 96.0, 100.0, true)
	if holder != null:
		_tops[node.id] = float(holder.get_meta("top"))
	if offered or state == MapView.State.BOSS:
		_add_bubble(node, info, at, holder)
	if offered:
		_add_tap(node.id, at)


## Sprite com os pés em [param feet]; altura e largura máximas em pixels (nada passa da moldura).
func _add_sprite(id: String, feet: Vector2, height: float, max_width: float, rim: bool) -> Control:
	var tex: Texture2D = ModelRegistry.sprite_texture(id) if ModelRegistry.has_sprite(id) else (load(SPRITES + id + ".png") as Texture2D)
	var scale_f: float = minf(height / float(tex.get_height()), max_width / float(tex.get_width()))
	var size_px: Vector2 = Vector2(float(tex.get_width()), float(tex.get_height())) * scale_f
	var holder: Control = Control.new()
	holder.position = feet
	holder.size = Vector2.ZERO
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_actors.add_child(holder)
	var shadow: TextureRect = TextureRect.new()
	shadow.texture = _shadow_texture()
	shadow.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	shadow.stretch_mode = TextureRect.STRETCH_SCALE
	shadow.size = Vector2(size_px.x * 0.95, maxf(size_px.y * 0.14, 14.0))
	shadow.position = Vector2(-shadow.size.x * 0.5, -shadow.size.y * 0.5)
	shadow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.add_child(shadow)
	var pic: TextureRect = TextureRect.new()
	pic.texture = tex
	pic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	pic.stretch_mode = TextureRect.STRETCH_SCALE
	pic.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	pic.size = size_px
	pic.position = Vector2(-size_px.x * 0.5, -size_px.y)
	pic.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if rim:
		pic.material = _rim_material
	holder.add_child(pic)
	holder.set_meta("top", feet.y - size_px.y)
	holder.set_meta("width", size_px.x)
	return holder


var _shadow_tex: GradientTexture2D


func _shadow_texture() -> GradientTexture2D:
	if _shadow_tex == null:
		var gradient: Gradient = Gradient.new()
		gradient.colors = PackedColorArray([Color(0, 0, 0, 0.7), Color(0, 0, 0, 0.0)])
		gradient.offsets = PackedFloat32Array([0.0, 1.0])
		_shadow_tex = GradientTexture2D.new()
		_shadow_tex.gradient = gradient
		_shadow_tex.fill = GradientTexture2D.FILL_RADIAL
		_shadow_tex.fill_from = Vector2(0.5, 0.5)
		_shadow_tex.fill_to = Vector2(1.0, 0.5)
		_shadow_tex.width = 96
		_shadow_tex.height = 96
	return _shadow_tex


## Halo de luz aditivo (nó disponível, lampião, fogueira, chefe).
func _add_glow(center: Vector2, radius: float, color: Color, alpha: float) -> void:
	var gradient: Gradient = Gradient.new()
	gradient.colors = PackedColorArray([Color(color.r, color.g, color.b, alpha), Color(color.r, color.g, color.b, 0.0)])
	gradient.offsets = PackedFloat32Array([0.0, 1.0])
	var tex: GradientTexture2D = GradientTexture2D.new()
	tex.gradient = gradient
	tex.fill = GradientTexture2D.FILL_RADIAL
	tex.fill_from = Vector2(0.5, 0.5)
	tex.fill_to = Vector2(1.0, 0.5)
	tex.width = 128
	tex.height = 128
	var glow: TextureRect = TextureRect.new()
	glow.texture = tex
	glow.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	glow.stretch_mode = TextureRect.STRETCH_SCALE
	glow.size = Vector2(radius * 2.0, radius * 2.0)
	glow.position = center - glow.size * 0.5
	glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var mat: CanvasItemMaterial = CanvasItemMaterial.new()
	mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	glow.material = mat
	_actors.add_child(glow)
	_glows.append(glow)


func _build_hero() -> void:
	var at: Vector2 = world_pos(view.run.current_node_id)
	var hero_id: String = ModelRegistry.hero_id()
	_hero = _add_sprite(hero_id, at + Vector2(0.0, 6.0), HEIGHT_HERO, HEIGHT_HERO * 0.9, false)


## Pílulas de nível e recompensa acima do sprite, sempre dentro da tela.
func _add_bubble(node: MapNode, info: Dictionary, at: Vector2, holder: Control) -> void:
	var row: HBoxContainer = HBoxContainer.new()
	row.add_theme_constant_override("separation", 3)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if node.is_fight():
		row.add_child(_pill("Nv %d" % node.level, VisualTheme.COLOR_DANGER.darkened(0.15)))
	if node.is_mutated():
		row.add_child(_pill("mutado", Color(0.45, 0.2, 0.6)))
	var hint: String = str(REWARD_HINT.get(node.kind, ""))
	if not hint.is_empty():
		row.add_child(_pill(hint, Color(0.62, 0.48, 0.12)))
	_overlay.add_child(row)
	row.reset_size()
	var top: float = float(holder.get_meta("top")) if holder != null else at.y - 90.0
	var x: float = clampf(at.x - row.size.x * 0.5, SIDE_MARGIN, WIDTH - SIDE_MARGIN - row.size.x)
	row.position = Vector2(x, top - 26.0)
	_bubbles[node.id] = row


func _pill(text: String, color: Color) -> Label:
	var label: Label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 14)
	label.add_theme_color_override("font_color", Color(0.97, 0.95, 0.9))
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.8))
	label.add_theme_constant_override("outline_size", 3)
	var box: StyleBoxFlat = StyleBoxFlat.new()
	box.bg_color = color
	box.set_corner_radius_all(9)
	box.content_margin_left = 7
	box.content_margin_right = 7
	box.content_margin_top = 1
	box.content_margin_bottom = 1
	box.border_color = Color(0, 0, 0, 0.6)
	box.set_border_width_all(1)
	label.add_theme_stylebox_override("normal", box)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label


func _add_tap(node_id: int, at: Vector2) -> void:
	var tap: Button = Button.new()
	tap.flat = true
	tap.focus_mode = Control.FOCUS_NONE
	tap.size = Vector2(130, 170)
	tap.custom_minimum_size = tap.size
	tap.position = at + Vector2(-65.0, -150.0)
	tap.text = ""
	tap.pressed.connect(_on_pick.bind(node_id))
	_overlay.add_child(tap)
	_taps[node_id] = tap


func button_for(node_id: int) -> Button:
	return _taps.get(node_id)


## Move a câmera (rolagem do mundo) para que o ponto do nó fique em [constant HERO_SCREEN_Y].
func _focus_on(node_id: int, seconds: float, screen_y: float = HERO_SCREEN_Y) -> void:
	var target_y: float = clampf(screen_y - world_pos(node_id).y, VIEW_HEIGHT - _world_height, 0.0)
	if seconds <= 0.0 or time_scale <= 0.0:
		_world.position.y = target_y
		return
	var tween: Tween = create_tween()
	tween.tween_property(_world, "position:y", target_y, seconds / time_scale).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


## Toque num destino: com a prévia ligada, o primeiro toque abre o card; depois a Bibiana caminha.
func _on_pick(node_id: int) -> void:
	if _walking:
		return
	if preview_enabled and _previewed != node_id:
		_show_preview(node_id)
		return
	_close_preview(false)
	SoundFx.play(self, "step")
	if time_scale <= 0.0:
		node_chosen.emit(node_id)
		return
	_walking = true
	var to: Vector2 = world_pos(node_id) + Vector2(0.0, 6.0)
	var pts: PackedVector2Array = road_points(world_pos(view.run.current_node_id), world_pos(node_id))
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_method(func(t: float) -> void:
		var idx: float = t * float(pts.size() - 1)
		var i: int = mini(int(idx), pts.size() - 2)
		_hero.position = pts[i].lerp(pts[i + 1], idx - float(i)) + Vector2(0.0, 6.0), 0.0, 1.0, WALK_SECONDS / time_scale)
	_focus_on(node_id, WALK_SECONDS)
	tween.chain().tween_callback(func() -> void:
		_hero.position = to
		_walking = false
		node_chosen.emit(node_id))


## Mini-card do destino (D-UI-3): diz o que espera e confirma com "Caminhar".
func _show_preview(node_id: int) -> void:
	_close_preview(false)
	_previewed = node_id
	var info: Dictionary = {}
	for entry: Dictionary in view.nodes():
		if int(entry["id"]) == node_id:
			info = entry
	_preview_card = PanelContainer.new()
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.043, 0.047, 0.063, 0.94)
	style.border_color = VisualTheme.COLOR_BORDER_BRONZE
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	style.set_content_margin_all(12)
	_preview_card.add_theme_stylebox_override("panel", style)
	_preview_card.anchor_left = 0.04
	_preview_card.anchor_right = 0.96
	_preview_card.anchor_top = 1.0
	_preview_card.anchor_bottom = 1.0
	_preview_card.offset_top = -190.0
	_preview_card.offset_bottom = -16.0
	var box: VBoxContainer = VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	_preview_card.add_child(box)
	var title: Label = Label.new()
	title.text = str(info.get("title", "Destino"))
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", Color(0.9, 0.75, 0.25))
	box.add_child(title)
	var detail: Label = Label.new()
	detail.text = str(info.get("detail", ""))
	detail.add_theme_font_size_override("font_size", 16)
	detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(detail)
	var row: HBoxContainer = HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	box.add_child(row)
	var back: Button = Button.new()
	back.text = "Voltar"
	back.custom_minimum_size = Vector2(0, 54)
	back.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	back.pressed.connect(func() -> void: _close_preview(true))
	row.add_child(back)
	var go: Button = Button.new()
	go.text = "Caminhar"
	go.custom_minimum_size = Vector2(0, 54)
	go.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	go.pressed.connect(func() -> void: _on_pick(node_id))
	row.add_child(go)
	add_child(_preview_card)
	# O card ocupa o rodapé: o destino sobe para a metade de cima, com seta e o trecho aceso.
	_roads.selected = [view.run.current_node_id, node_id]
	_roads.queue_redraw()
	_add_marker(node_id)
	_focus_on(node_id, 0.35, 440.0)


func _add_marker(node_id: int) -> void:
	if _marker != null:
		_marker.queue_free()
	_marker = Label.new()
	(_marker as Label).text = "▼"
	_marker.add_theme_font_size_override("font_size", 40)
	_marker.add_theme_color_override("font_color", Color(1.0, 0.82, 0.35))
	_marker.add_theme_color_override("font_outline_color", Color(0.1, 0.05, 0.0, 1.0))
	_marker.add_theme_constant_override("outline_size", 8)
	_marker.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var at: Vector2 = world_pos(node_id)
	var top: float = float(_tops.get(node_id, at.y - 130.0)) - 94.0
	_marker.position = Vector2(at.x - 14.0, top)
	_overlay.add_child(_marker)
	if time_scale > 0.0:
		var tween: Tween = _marker.create_tween().set_loops()
		tween.tween_property(_marker, "position:y", top + 14.0, 0.45).set_trans(Tween.TRANS_SINE)
		tween.tween_property(_marker, "position:y", top, 0.45).set_trans(Tween.TRANS_SINE)


func _close_preview(recenter: bool) -> void:
	if _marker != null:
		_marker.queue_free()
		_marker = null
	if _roads != null:
		_roads.selected = []
		_roads.queue_redraw()
	if _preview_card != null:
		_preview_card.queue_free()
		_preview_card = null
	_previewed = -1
	if recenter:
		_focus_on(view.run.current_node_id, 0.3)


## Equipamento e mochila em ícones sob as barras do topo (TASK-043).
func _fill_gear() -> void:
	for child: Node in _gear_row.get_children():
		child.queue_free()
	var run: RunState = view.run
	for slot: String in ["weapon", "offhand", "armor", "head", "relic"]:
		var item_id: String = str(run.equipment.get(slot, ""))
		var tip: String = RunPanels.SLOT_NAMES.get(slot, slot)
		var tex: Texture2D = IconRegistry.texture_for("item", item_id) if not item_id.is_empty() else null
		if not item_id.is_empty():
			tip = "%s: %s" % [tip, str(run.data.items[item_id]["name"])]
		_gear_row.add_child(_gear_slot(tex, tip, ""))
	_gear_row.add_child(_gear_slot(IconRegistry.texture_for("ui", "potion"), "Poções", "x%d" % run.consumable_count("murky_potion")))
	_gear_row.add_child(_gear_slot(IconRegistry.texture_for("ui", "firewood"), "Galhos Secos", "x%d" % run.consumable_count(RunRules.FIREWOOD_ID)))


func _gear_slot(tex: Texture2D, tip: String, count: String) -> Control:
	var frame: PanelContainer = PanelContainer.new()
	var box: StyleBoxFlat = StyleBoxFlat.new()
	box.bg_color = Color(0.05, 0.055, 0.08, 0.85)
	box.border_color = Color(0.42, 0.35, 0.24) if tex != null else Color(0.2, 0.18, 0.15)
	box.set_border_width_all(1)
	box.set_corner_radius_all(4)
	box.set_content_margin_all(2)
	frame.add_theme_stylebox_override("panel", box)
	frame.tooltip_text = tip
	frame.mouse_filter = Control.MOUSE_FILTER_PASS
	var row: HBoxContainer = HBoxContainer.new()
	row.add_theme_constant_override("separation", 3)
	frame.add_child(row)
	var icon: TextureRect = TextureRect.new()
	icon.texture = tex
	icon.custom_minimum_size = Vector2(34, 34)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	row.add_child(icon)
	if not count.is_empty():
		var label: Label = Label.new()
		label.text = count
		label.add_theme_font_size_override("font_size", 14)
		row.add_child(label)
	return frame


func _build_hud() -> void:
	var row: HBoxContainer = HBoxContainer.new()
	row.position = Vector2(10, 6)
	row.add_theme_constant_override("separation", 8)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(row)
	_hud_hp = _thin_bar(Color(0.72, 0.16, 0.14), 150.0)
	_hud_mp = _thin_bar(Color(0.45, 0.55, 0.72), 90.0)
	row.add_child(_hud_hp)
	row.add_child(_hud_mp)
	var coin: TextureRect = TextureRect.new()
	coin.texture = IconRegistry.texture_for("ui", "gold")
	coin.custom_minimum_size = Vector2(16, 16)
	coin.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	coin.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	coin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(coin)
	_hud_gold = Label.new()
	_hud_gold.add_theme_font_size_override("font_size", 14)
	_hud_gold.add_theme_color_override("font_color", Color("D9AA32"))
	_hud_gold.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(_hud_gold)


func _thin_bar(color: Color, width: float) -> ProgressBar:
	var bar: ProgressBar = ProgressBar.new()
	bar.custom_minimum_size = Vector2(width, 10)
	bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	bar.show_percentage = false
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var fill: StyleBoxFlat = StyleBoxFlat.new()
	fill.bg_color = color
	var back: StyleBoxFlat = StyleBoxFlat.new()
	back.bg_color = Color(0.03, 0.035, 0.05, 0.85)
	back.border_color = Color(0.3, 0.25, 0.17)
	back.set_border_width_all(1)
	bar.add_theme_stylebox_override("fill", fill)
	bar.add_theme_stylebox_override("background", back)
	return bar


func _refresh_hud() -> void:
	if _hud_hp == null or view == null:
		return
	var stats: Stats = view.run.player_stats()
	_hud_hp.max_value = float(maxi(stats.max_hp, 1))
	_hud_hp.value = float(view.run.hp)
	_hud_mp.max_value = float(maxi(stats.max_mp, 1))
	_hud_mp.value = float(view.run.mp)
	_hud_gold.text = str(view.run.gold)
