class_name Map3DScreen
extends Control
## Tabuleiro isométrico 3D com visão parcial (TASK-036, ADR-0036, GDD §5 e §17,
## docs/ART-DIRECTION.md §3). Mostra o nó atual, os três destinos iluminados com estrada e
## bolhas de número, o que vem depois sob névoa e o chefe de longe. A câmera acompanha a
## Bibiana e a névoa recua em volta do novo destino. Só apresentação: lê o [MapView].

signal node_chosen(node_id: int)

const K_MINI: String = "res://assets/kenney/mini_dungeon/"
const K_GRAVE: String = "res://assets/kenney/graveyard/"
const SHRINK: int = 2
const CAM_SIZE: float = 25.0
const CAM_OFFSET: Vector3 = Vector3(1.0, 0.82, 1.0) * 22.0
## A câmera mira um pouco à frente da Bibiana, para mostrar o que vem pela névoa.
const CAM_LOOKAHEAD: Vector3 = Vector3(0.0, 0.0, -2.5)
const FOG_SHEET_LIFT: float = 1.7
const FOG_SPEED: float = 1.6
const STEP_SECONDS: float = 0.2
## Neblina por situação da camada da célula (ART-DIRECTION §3, item 3).
const FOG_BEHIND: float = 0.5
const FOG_AHEAD_BASE: float = 0.72
const FOG_AHEAD_MAX: float = 0.94
const FOG_BOSS: float = 0.55
const DECOR_PROPS: Array[String] = [
	"gravestone-cross.glb", "gravestone-round.glb", "gravestone-broken.glb", "pine-crooked.glb",
	"iron-fence-damaged.glb", "stone-wall-damaged.glb", "candle-multiple.glb",
	"pine-fall.glb", "lightpost-single.glb", "grave.glb",
]
const REWARD_HINT: Dictionary = {
	MapNode.Kind.BATTLE: "ouro", MapNode.Kind.AMBUSH: "emboscada", MapNode.Kind.ELITE: "equip. raro",
	MapNode.Kind.CHEST: "baú", MapNode.Kind.EVENT: "evento", MapNode.Kind.BONFIRE: "fogueira",
	MapNode.Kind.MINI_BOSS: "raro garantido", MapNode.Kind.BOSS: "chefe",
}

var view: MapView
## 0 deixa tudo instantâneo (testes); 1 é a velocidade normal.
var time_scale: float = 1.0
var layout: Map3DLayout
var camera: Camera3D

var _viewport: SubViewport
var _world: Node3D
var _node_root: Node3D
var _hero: Node3D
var _hero_cell: Vector2i
var _fog: MultiMeshInstance3D
var _fog_now: PackedFloat32Array = PackedFloat32Array()
var _fog_goal: PackedFloat32Array = PackedFloat32Array()
var _cam_target: Vector3 = Vector3.ZERO
var _walking: bool = false
var _overlay: Control
var _header: Label
var _taps: Dictionary = {}
var _bubbles: Dictionary = {}


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layout = Map3DLayout.new(view.run.map, view.run.streams.run_seed)
	var container: SubViewportContainer = SubViewportContainer.new()
	container.stretch = true
	container.stretch_shrink = SHRINK
	container.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(container)
	_viewport = SubViewport.new()
	_viewport.size = Vector2i(270, 480)
	_viewport.msaa_3d = Viewport.MSAA_DISABLED
	container.add_child(_viewport)
	_world = Node3D.new()
	_viewport.add_child(_world)
	_build_environment()
	_build_camera()
	_build_terrain()
	_node_root = Node3D.new()
	_world.add_child(_node_root)
	_build_fog()
	_overlay = Control.new()
	_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_overlay)
	_add_vignette()
	_header = Label.new()
	_header.add_theme_font_size_override("font_size", 13)
	_header.add_theme_color_override("font_color", VisualTheme.COLOR_PARCHMENT)
	_header.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.9))
	_header.position = Vector2(10, 6)
	_header.size = Vector2(500, 90)
	_header.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_header.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_header)
	refresh()
	_start_reveal()


func _build_environment() -> void:
	var env: Environment = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.03, 0.035, 0.055)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.3, 0.35, 0.48)
	env.ambient_light_energy = 1.1
	env.adjustment_enabled = true
	env.adjustment_saturation = 0.55
	env.adjustment_contrast = 1.15
	env.adjustment_brightness = 0.92
	env.glow_enabled = true
	env.glow_intensity = 0.6
	env.glow_bloom = 0.08
	var holder: WorldEnvironment = WorldEnvironment.new()
	holder.environment = env
	_world.add_child(holder)
	var moon: DirectionalLight3D = DirectionalLight3D.new()
	moon.light_color = Color(0.62, 0.7, 0.95)
	moon.light_energy = 1.2
	moon.rotation_degrees = Vector3(-55, 35, 0)
	moon.shadow_enabled = true
	_world.add_child(moon)


func _build_camera() -> void:
	camera = Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = CAM_SIZE
	camera.near = 0.1
	camera.far = 120.0
	_world.add_child(camera)
	var here: Vector3 = layout.node_world(view.run.current_node_id)
	_set_camera_target(_aim_point(view.run.current_node_id))


func _set_camera_target(target: Vector3) -> void:
	_cam_target = target
	camera.position = target + CAM_OFFSET
	camera.look_at(target)


## Blocos de terreno e lajes de estrada e de praça, cada tipo numa única `MultiMesh`.
func _build_terrain() -> void:
	var blocks: Array[Transform3D] = []
	var plaza_tiles: Array[Transform3D] = []
	var road_tiles: Array[Transform3D] = []
	for z: int in layout.rows:
		for x: int in layout.cols:
			var cell: Vector2i = Vector2i(x, z)
			var h: int = layout.height_at(cell)
			var low: int = h
			for offset: Vector2i in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
				low = mini(low, layout.height_at(cell + offset))
			if x == 0 or z == 0 or x == layout.cols - 1 or z == layout.rows - 1:
				low = 0
			for level: int in range(low, h + 1):
				blocks.append(Transform3D(Basis.IDENTITY, Vector3(x, level * Map3DLayout.BLOCK_H, z)))
			var top: Vector3 = Vector3(x, (h + 1) * Map3DLayout.BLOCK_H + 0.03, z)
			if layout.plaza_cells.has(cell):
				plaza_tiles.append(Transform3D(Basis.IDENTITY, top))
			elif layout.road_cells.has(cell) and not layout.stairs.has(cell):
				road_tiles.append(Transform3D(Basis.IDENTITY.scaled(Vector3.ONE * 1.25), top))
	_multimesh_from(K_MINI + "dirt.glb", blocks)
	_multimesh_from(K_MINI + "floor-detail.glb", plaza_tiles, Color(0.62, 0.6, 0.66))
	_multimesh_from(K_GRAVE + "road.glb", road_tiles, Color(0.46, 0.42, 0.4))
	for cell: Vector2i in layout.stairs.keys():
		_place(K_MINI + "stairs.glb", layout.world_of(cell) + Vector3(0, 0.0, 0), float(layout.stairs[cell]))
	var keys: Array = layout.props.keys()
	for cell: Vector2i in keys:
		var pick: int = int(layout.props[cell]) % DECOR_PROPS.size()
		var yaw: float = float((int(layout.props[cell]) * 37) % 4) * 90.0
		_place(K_GRAVE + DECOR_PROPS[pick], layout.world_of(cell), yaw, 1.3)


func _multimesh_from(path: String, transforms: Array[Transform3D], tint: Color = Color.WHITE) -> void:
	if transforms.is_empty():
		return
	var source: Node = (load(path) as PackedScene).instantiate()
	var mesh_node: MeshInstance3D = source.find_children("*", "MeshInstance3D", true, false)[0] as MeshInstance3D
	var multi: MultiMesh = MultiMesh.new()
	multi.transform_format = MultiMesh.TRANSFORM_3D
	var mesh: Mesh = mesh_node.mesh
	if tint != Color.WHITE:
		mesh = mesh.duplicate() as Mesh
		var base: Material = mesh.surface_get_material(0)
		if base is StandardMaterial3D:
			var dark: StandardMaterial3D = (base as StandardMaterial3D).duplicate() as StandardMaterial3D
			dark.albedo_color = tint
			mesh.surface_set_material(0, dark)
	multi.mesh = mesh
	multi.instance_count = transforms.size()
	for i: int in transforms.size():
		multi.set_instance_transform(i, transforms[i] * mesh_node.transform)
	var holder: MultiMeshInstance3D = MultiMeshInstance3D.new()
	holder.multimesh = multi
	_world.add_child(holder)
	source.free()


func _place(path: String, pos: Vector3, yaw: float = 0.0, factor: float = 1.0, parent: Node3D = null) -> Node3D:
	var node: Node3D = (load(path) as PackedScene).instantiate() as Node3D
	node.position = pos
	node.rotation_degrees.y = yaw
	node.scale = Vector3.ONE * factor
	(parent if parent != null else _world).add_child(node)
	return node


## Lençol de névoa por célula: uma `MultiMesh` de quadrados escuros com alfa por instância.
func _build_fog() -> void:
	var sheet: PlaneMesh = PlaneMesh.new()
	sheet.size = Vector2(1.0, 1.0)
	var shader: Shader = Shader.new()
	shader.code = "shader_type spatial;\nrender_mode unshaded, blend_mix, depth_draw_never, cull_disabled;\nvoid fragment() {\n\tALBEDO = vec3(0.02, 0.028, 0.06);\n\tALPHA = COLOR.a;\n}\n"
	var material: ShaderMaterial = ShaderMaterial.new()
	material.shader = shader
	sheet.material = material
	var multi: MultiMesh = MultiMesh.new()
	multi.transform_format = MultiMesh.TRANSFORM_3D
	multi.use_colors = true
	multi.mesh = sheet
	multi.instance_count = layout.cols * layout.rows
	for z: int in layout.rows:
		for x: int in layout.cols:
			var cell: Vector2i = Vector2i(x, z)
			var lift: float = (layout.height_at(cell) + 1) * Map3DLayout.BLOCK_H + FOG_SHEET_LIFT
			multi.set_instance_transform(z * layout.cols + x, Transform3D(Basis.IDENTITY, Vector3(x, lift, z)))
	_fog = MultiMeshInstance3D.new()
	_fog.multimesh = multi
	_world.add_child(_fog)
	_fog_now.resize(layout.cols * layout.rows)
	_fog_goal.resize(layout.cols * layout.rows)
	var current_layer: int = view.run.current_node().layer
	var visible_layer: int = view.visible_layer()
	_fog_goal = _fog_alphas(current_layer, visible_layer)
	_fog_now = _fog_goal.duplicate()
	_apply_fog(true)


## Alfa da névoa de cada célula para um nó atual e uma camada visível (ART-DIRECTION §3).
func _fog_alphas(current_layer: int, visible_layer: int) -> PackedFloat32Array:
	var alphas: PackedFloat32Array = PackedFloat32Array()
	alphas.resize(layout.cols * layout.rows)
	var last_layer: int = view.run.map.layer_count + 1
	for z: int in layout.rows:
		var layer: int = layout.layer_at_row(z)
		var alpha: float = 0.0
		if layer > visible_layer:
			alpha = minf(FOG_AHEAD_BASE + 0.05 * float(layer - visible_layer - 1), FOG_AHEAD_MAX)
			if layer == last_layer:
				alpha = FOG_BOSS
		elif layer < current_layer - 1:
			alpha = FOG_BEHIND
		for x: int in layout.cols:
			alphas[z * layout.cols + x] = alpha
	return alphas


func _apply_fog(all: bool = false) -> void:
	var multi: MultiMesh = _fog.multimesh
	for i: int in _fog_now.size():
		if all or not is_equal_approx(_fog_now[i], _fog_goal[i]):
			multi.set_instance_color(i, Color(1, 1, 1, _fog_now[i]))


## Ao voltar ao mapa a névoa recua em volta do novo destino (0,6 a 1 s) e a câmera desliza.
func _start_reveal() -> void:
	var before: Dictionary = _previous_state()
	if before.is_empty() or time_scale <= 0.0:
		return
	var previous_layer: int = int(before["layer"])
	_fog_now = _fog_alphas(previous_layer, previous_layer + 1)
	_apply_fog(true)
	var from_pos: Vector3 = _aim_point(int(before["id"]))
	var to_pos: Vector3 = _cam_target
	_set_camera_target(from_pos)
	var tween: Tween = create_tween()
	tween.tween_method(func(t: float) -> void: _set_camera_target(from_pos.lerp(to_pos, t)), 0.0, 1.0, 0.8 / time_scale)


func _previous_state() -> Dictionary:
	var visited: PackedInt32Array = view.visited_ids()
	if visited.size() < 1:
		return {}
	var previous_id: int = view.run.map.start_id if visited.size() == 1 else visited[visited.size() - 2]
	var node: MapNode = view.run.map.node_by_id(previous_id)
	if node == null or node.layer >= view.run.current_node().layer:
		return {}
	return {"id": previous_id, "layer": node.layer}


func _process(delta: float) -> void:
	if _fog == null:
		return
	var changed: bool = false
	for i: int in _fog_now.size():
		if not is_equal_approx(_fog_now[i], _fog_goal[i]):
			_fog_now[i] = move_toward(_fog_now[i], _fog_goal[i], FOG_SPEED * delta * maxf(time_scale, 1.0))
			changed = true
	if changed:
		_apply_fog()
	_update_overlay()


## Redesenha props dos nós, Bibiana, destinos e bolhas a partir do estado atual da Descida.
func refresh() -> void:
	if view == null or _node_root == null:
		return
	for child: Node in _node_root.get_children():
		child.queue_free()
	_header.text = view.header()
	for node_view: Dictionary in view.nodes():
		_build_node(node_view)
	_build_hero()
	_fog_goal = _fog_alphas(view.run.current_node().layer, view.visible_layer())
	if time_scale <= 0.0:
		_fog_now = _fog_goal.duplicate()
		_apply_fog(true)
	_rebuild_overlay()


func _build_node(info: Dictionary) -> void:
	var state: MapView.State = info["state"]
	if state == MapView.State.FOG or state == MapView.State.PAST:
		return
	var node: MapNode = view.run.map.node_by_id(int(info["id"]))
	var at: Vector3 = layout.node_world(node.id)
	var kind: int = int(info["kind"])
	if state == MapView.State.OPTION:
		var glow: OmniLight3D = OmniLight3D.new()
		glow.light_color = VisualTheme.COLOR_DANGER if bool(info.get("mini_boss", false)) else Color(1.0, 0.72, 0.3)
		glow.light_energy = 2.6
		glow.omni_range = 4.2
		glow.position = at + Vector3(0, 1.6, 0)
		_node_root.add_child(glow)
	if state == MapView.State.CURRENT or kind == MapNode.Kind.START:
		return
	if node.is_fight() and not node.enemy_id.is_empty() and ModelRegistry.has_model(node.enemy_id):
		var foe: Node3D = ModelRegistry.spawn(node.enemy_id)
		foe.position = at
		foe.rotation_degrees.y = 0.0
		var factor: float = 1.7
		if node.kind == MapNode.Kind.ELITE:
			factor = 2.8
		elif node.kind == MapNode.Kind.MINI_BOSS or node.kind == MapNode.Kind.BOSS:
			factor = 2.8
		foe.scale = Vector3.ONE * factor
		_node_root.add_child(foe)
		ModelRegistry.play(foe, node.enemy_id, "idle")
		return
	match node.kind:
		MapNode.Kind.CHEST:
			_place(K_MINI + "chest.glb", at, 20.0, 1.7, _node_root)
		MapNode.Kind.BONFIRE:
			_place(K_GRAVE + "fire-basket.glb", at, 0.0, 2.0, _node_root)
			var fire: OmniLight3D = OmniLight3D.new()
			fire.light_color = Color(1.0, 0.5, 0.18)
			fire.light_energy = 3.2
			fire.omni_range = 4.0
			fire.position = at + Vector3(0, 1.0, 0)
			_node_root.add_child(fire)
		MapNode.Kind.EVENT:
			_place(K_GRAVE + "altar-stone.glb", at, 0.0, 1.5, _node_root)
		_:
			pass


func _build_hero() -> void:
	if _hero != null:
		_hero.queue_free()
	_hero_cell = layout.node_cells[view.run.current_node_id]
	_hero = ModelRegistry.spawn("bibiana")
	_hero.position = layout.world_of(_hero_cell)
	_hero.rotation_degrees.y = 180.0
	_hero.scale = Vector3.ONE * 1.5
	_world.add_child(_hero)
	ModelRegistry.play(_hero, "bibiana", "idle")


## Bolhas de número (nível em vermelho, recompensa em dourado) e áreas de toque dos destinos.
func _rebuild_overlay() -> void:
	for child: Node in _overlay.get_children():
		child.queue_free()
	_taps.clear()
	_bubbles.clear()
	for info: Dictionary in view.nodes():
		var state: MapView.State = info["state"]
		if state != MapView.State.OPTION and state != MapView.State.BOSS:
			continue
		var node: MapNode = view.run.map.node_by_id(int(info["id"]))
		var bubble: HBoxContainer = _make_bubble(node, info)
		_overlay.add_child(bubble)
		_bubbles[node.id] = bubble
		if state == MapView.State.OPTION:
			var tap: Button = Button.new()
			tap.flat = true
			tap.focus_mode = Control.FOCUS_NONE
			tap.size = Vector2(120, 120)
			tap.custom_minimum_size = Vector2(120, 120)
			tap.text = ""
			tap.pressed.connect(_on_pick.bind(node.id))
			_overlay.add_child(tap)
			_taps[node.id] = tap
	_update_overlay()


func _make_bubble(node: MapNode, info: Dictionary) -> HBoxContainer:
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
	return row


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


func _screen_of(world_pos: Vector3) -> Vector2:
	return camera.unproject_position(world_pos) * float(SHRINK)


func _update_overlay() -> void:
	if camera == null or _overlay == null:
		return
	for node_id: int in _bubbles.keys():
		var bubble: Control = _bubbles[node_id]
		var p: Vector2 = _screen_of(layout.node_world(node_id) + Vector3(0, 2.4, 0))
		bubble.position = p - Vector2(bubble.size.x * 0.5, bubble.size.y)
	for node_id: int in _taps.keys():
		var tap: Control = _taps[node_id]
		tap.position = _screen_of(layout.node_world(node_id) + Vector3(0, 0.9, 0)) - tap.size * 0.5


func button_for(node_id: int) -> Button:
	return _taps.get(node_id)


## Toque num destino: a Bibiana caminha pela estrada, a câmera desliza junto e só então a Descida avança.
func _on_pick(node_id: int) -> void:
	if _walking:
		return
	SoundFx.play(self, "step")
	var from_cell: Vector2i = layout.node_cells[view.run.current_node_id]
	var to_cell: Vector2i = layout.node_cells[node_id]
	if time_scale <= 0.0:
		node_chosen.emit(node_id)
		return
	_walking = true
	var cells: Array[Vector2i] = layout.path_cells(from_cell, to_cell)
	ModelRegistry.play(_hero, "bibiana", "walk")
	var duration: float = STEP_SECONDS * float(cells.size()) / time_scale
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	var last: Vector3 = _hero.position
	for i: int in range(1, cells.size()):
		var target: Vector3 = layout.world_of(cells[i])
		tween.tween_property(_hero, "position", target, STEP_SECONDS / time_scale).set_delay(STEP_SECONDS / time_scale * float(i - 1))
		last = target
	var start: Vector3 = _cam_target
	var finish: Vector3 = _aim_point(node_id)
	tween.tween_method(func(t: float) -> void: _set_camera_target(start.lerp(finish, t)), 0.0, 1.0, duration)
	tween.chain().tween_callback(func() -> void:
		_walking = false
		node_chosen.emit(node_id))


func _add_vignette() -> void:
	var rect: ColorRect = ColorRect.new()
	rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var shader: Shader = Shader.new()
	shader.code = "shader_type canvas_item;\nvoid fragment() {\n\tvec2 uv = UV - vec2(0.5);\n\tfloat d = dot(uv, uv) * 2.2;\n\tCOLOR = vec4(0.0, 0.0, 0.02, clamp(d * d * 1.4, 0.0, 0.85));\n}\n"
	var mat: ShaderMaterial = ShaderMaterial.new()
	mat.shader = shader
	rect.material = mat
	add_child(rect)


## Ponto que a câmera mira: entre a Bibiana e o centro dos destinos, para mostrar os três caminhos.
func _aim_point(from_node_id: int) -> Vector3:
	var here: Vector3 = layout.node_world(from_node_id)
	var next_ids: PackedInt32Array = view.run.map.node_by_id(from_node_id).next_ids
	if next_ids.is_empty():
		return here + CAM_LOOKAHEAD
	var sum: Vector3 = Vector3.ZERO
	for id: int in next_ids:
		sum += layout.node_world(id)
	return here.lerp(sum / float(next_ids.size()), 0.6)
