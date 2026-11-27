class_name Map3DScreen
extends Control
## Tabuleiro isométrico 3D com visão parcial (TASK-036, ADR-0036, GDD §5 e §17,
## docs/ART-DIRECTION.md §3). Mostra o nó atual, os três destinos iluminados com estrada e
## bolhas de número, o que vem depois sob névoa e o chefe de longe. A câmera acompanha a
## Bibiana e a névoa recua em volta do novo destino. Só apresentação: lê o [MapView].

signal node_chosen(node_id: int)

const K_MINI: String = "res://assets/kenney/mini_dungeon/"
const K_GRAVE: String = "res://assets/kenney/graveyard/"
## Mapa em resolução cheia (TASK-070): a miniatura 2x deixava sprites e pedra borrados.
const SHRINK: int = 1
## Desloca a vista para a Bibiana ficar na metade de baixo, com o caminho à frente em cima.
const CAM_V_OFFSET: float = 3.2
const SKYLINE: String = "res://assets/bibiana/arenas/map-strip-02-praca.jpg"
const CAM_SIZE: float = 24.0
const CAM_OFFSET: Vector3 = Vector3(1.0, 0.82, 1.0) * 22.0
## A câmera mira um pouco à frente da Bibiana, para mostrar o que vem pela névoa.
const CAM_LOOKAHEAD: Vector3 = Vector3(0.0, 0.0, -2.5)
const FOG_SHEET_LIFT: float = 1.7
const FOG_SPEED: float = 1.6
const STEP_SECONDS: float = 0.2
## Neblina por situação da camada da célula (ART-DIRECTION §3, item 3).
const FOG_BEHIND: float = 0.25
const FOG_AHEAD_BASE: float = 0.38
const FOG_AHEAD_MAX: float = 0.7
const FOG_BOSS: float = 0.4
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
var _hero_sprite: Sprite3D
var _hero_cell: Vector2i
var _fog: MultiMeshInstance3D
var _fog_now: PackedFloat32Array = PackedFloat32Array()
var _fog_goal: PackedFloat32Array = PackedFloat32Array()
## Índice da folha de névoa de cada célula da grade (-1 no vazio).
var _fog_slot: PackedInt32Array = PackedInt32Array()
var _cam_target: Vector3 = Vector3.ZERO
var _walking: bool = false
## Primeiro toque abre a prévia do destino, o segundo (ou "Caminhar") confirma (ADR-0048, D-UI-3).
var preview_enabled: bool = DisplayServer.get_name() != "headless"
var _previewed: int = -1
var _preview_card: PanelContainer
var _overlay: Control
var _header: Label
var _taps: Dictionary = {}
var _bubbles: Dictionary = {}
var _gear_row: HBoxContainer
var _pulse_lights: Array[OmniLight3D] = []
var _pulse_time: float = 0.0
var _diamonds: Array[MeshInstance3D] = []
var _bonfire_flames: Array[Sprite3D] = []
## Seta e trilha da prévia do destino escolhido.
var _selection: Array[Node] = []
var _arrow: Label3D
var _arrow_base_y: float = 0.0
var _mist: TextureRect
var _pursuer_banner: PanelContainer
var _pursuer_text: Label
var _last_pursuer_distance: int = -1


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layout = Map3DLayout.new(view.run.map, view.run.streams.run_seed)
	# Horizonte pintado atrás do tabuleiro (gótico, escurecido): o céu e as torres distantes (ADR-0057).
	if ResourceLoader.exists(SKYLINE):
		var sky: TextureRect = TextureRect.new()
		sky.texture = load(SKYLINE) as Texture2D
		sky.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		sky.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		sky.modulate = Color(0.6, 0.65, 0.8)
		sky.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		sky.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(sky)
	var container: SubViewportContainer = SubViewportContainer.new()
	container.stretch = true
	container.stretch_shrink = SHRINK
	container.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(container)
	_viewport = SubViewport.new()
	_viewport.transparent_bg = true
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
	add_child(WeatherLayer.new())
	_overlay = Control.new()
	_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_overlay)
	_add_foreground()
	_add_vignette()
	_header = Label.new()
	_header.add_theme_font_size_override("font_size", 13)
	_header.add_theme_color_override("font_color", VisualTheme.COLOR_PARCHMENT)
	_header.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.9))
	_header.position = Vector2(10, 6)
	_header.size = Vector2(450, 90)
	_header.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_header.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_header.visible = false
	add_child(_header)
	_build_hud()
	_gear_row = HBoxContainer.new()
	_gear_row.position = Vector2(10, 24)
	_gear_row.add_theme_constant_override("separation", 6)
	_gear_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_gear_row)
	refresh()
	_start_reveal()


func _build_environment() -> void:
	var env: Environment = Environment.new()
	env.background_mode = Environment.BG_CLEAR_COLOR
	env.background_color = Color(0.024, 0.028, 0.044)
	Atmosphere.apply(env, false)
	env.ambient_light_color = Color("56606F")
	env.ambient_light_energy = 1.55
	env.adjustment_enabled = true
	env.adjustment_saturation = 0.72
	env.adjustment_contrast = 1.12
	env.adjustment_brightness = 1.05
	env.glow_enabled = true
	env.glow_intensity = 0.6
	env.glow_bloom = 0.08
	var holder: WorldEnvironment = WorldEnvironment.new()
	holder.environment = env
	_world.add_child(holder)
	var moon: DirectionalLight3D = DirectionalLight3D.new()
	moon.light_color = Color("A9B8D8")
	moon.light_energy = 1.6
	moon.rotation_degrees = Vector3(-55, 35, 0)
	moon.shadow_enabled = true
	moon.directional_shadow_mode = DirectionalLight3D.SHADOW_ORTHOGONAL
	moon.directional_shadow_max_distance = 45.0
	_world.add_child(moon)


func _build_camera() -> void:
	camera = Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = CAM_SIZE
	camera.near = 0.1
	camera.far = 120.0
	camera.v_offset = CAM_V_OFFSET
	_world.add_child(camera)
	var here: Vector3 = layout.node_world(view.run.current_node_id)
	_set_camera_target(_aim_point(view.run.current_node_id))


func _set_camera_target(target: Vector3) -> void:
	_cam_target = target
	camera.position = target + CAM_OFFSET
	camera.look_at(target)


## Constrói o cenário 3D coerente (terreno estratificado, estradas, canais, pontes, compostos,
## muros contínuos, postes aterrados e props) a partir da [ScenarioBlueprint] do mapa.
func _build_terrain() -> void:
	ScenarioRenderer.render(_world, layout.blueprint, true)


func _place(path: String, pos: Vector3, yaw: float = 0.0, factor: float = 1.0, parent: Node3D = null) -> Node3D:
	return StageKit.place(parent if parent != null else _world, path, pos, yaw, factor)


## Lençol de névoa por célula: uma `MultiMesh` de quadrados escuros com alfa por instância.
func _build_fog() -> void:
	var sheet: PlaneMesh = PlaneMesh.new()
	sheet.size = Vector2(1.0, 1.0)
	var shader: Shader = Shader.new()
	shader.code = "shader_type spatial;\nrender_mode unshaded, blend_mix, depth_draw_never, cull_disabled;\nvoid fragment() {\n\tALBEDO = vec3(0.05, 0.065, 0.1);\n\tALPHA = COLOR.a;\n}\n"
	var material: ShaderMaterial = ShaderMaterial.new()
	material.shader = shader
	sheet.material = material
	var multi: MultiMesh = MultiMesh.new()
	multi.transform_format = MultiMesh.TRANSFORM_3D
	multi.use_colors = true
	multi.mesh = sheet
	# Só as células sólidas ganham folha de névoa (o vazio não gasta primitivas, ADR-0060).
	_fog_slot.resize(layout.cols * layout.rows)
	var solid: int = 0
	for z: int in layout.rows:
		for x: int in layout.cols:
			if layout.blueprint.zone_at(Vector2i(x, z)) == ScenarioBlueprint.ZONE_VOID:
				_fog_slot[z * layout.cols + x] = -1
			else:
				_fog_slot[z * layout.cols + x] = solid
				solid += 1
	multi.instance_count = solid
	for z: int in layout.rows:
		for x: int in layout.cols:
			var slot: int = _fog_slot[z * layout.cols + x]
			if slot < 0:
				continue
			var cell: Vector2i = Vector2i(x, z)
			var lift: float = (layout.height_at(cell) + 1) * Map3DLayout.BLOCK_H + FOG_SHEET_LIFT
			multi.set_instance_transform(slot, Transform3D(Basis.IDENTITY, Vector3(x, lift, z)))
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
			alpha = minf(FOG_AHEAD_BASE + 0.14 * float(layer - visible_layer - 1), FOG_AHEAD_MAX)
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
		if _fog_slot[i] >= 0 and (all or not is_equal_approx(_fog_now[i], _fog_goal[i])):
			multi.set_instance_color(_fog_slot[i], Color(1, 1, 1, _fog_now[i]))


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
	_pulse_time += delta
	for light: OmniLight3D in _pulse_lights:
		if is_instance_valid(light):
			light.light_energy = 2.4 * (0.7 + 0.3 * sin(_pulse_time * 3.2))
	var beat: float = 0.75 + 0.25 * sin(_pulse_time * 3.0)
	for diamond: MeshInstance3D in _diamonds:
		if is_instance_valid(diamond):
			((diamond.mesh as QuadMesh).material as ShaderMaterial).set_shader_parameter("pulse", beat)
	if _mist != null:
		_mist.position.x = -110.0 + 70.0 * sin(_pulse_time * 0.12)
	var flame_frame: int = int(_pulse_time * 10.0) % 8
	for flame: Sprite3D in _bonfire_flames:
		if is_instance_valid(flame):
			flame.frame = flame_frame
	if _arrow != null and is_instance_valid(_arrow):
		_arrow.position.y = _arrow_base_y + 0.35 * sin(_pulse_time * 5.0)
	_update_overlay()


## Cor da luz de um destino alcançável: brasa (fogueira), âmbar (evento), ouro (baú), vermelho (luta).
func _destination_color(kind: int) -> Color:
	match kind:
		MapNode.Kind.BONFIRE:
			return Color(1.0, 0.45, 0.14)
		MapNode.Kind.EVENT:
			return Color(0.9, 0.55, 0.22)
		MapNode.Kind.CHEST:
			return Color(0.95, 0.75, 0.22)
	return Color(0.85, 0.16, 0.1)


func _is_hostile(kind: int) -> bool:
	return kind != MapNode.Kind.BONFIRE and kind != MapNode.Kind.EVENT and kind != MapNode.Kind.CHEST


## Redesenha props dos nós, Bibiana, destinos e bolhas a partir do estado atual da Descida.
func refresh() -> void:
	if view == null or _node_root == null:
		return
	for child: Node in _node_root.get_children():
		child.queue_free()
	_pulse_lights.clear()
	_diamonds.clear()
	_bonfire_flames.clear()
	_header.text = view.header()
	_refresh_hud()
	_fill_gear()
	for node_view: Dictionary in view.nodes():
		_build_node(node_view)
	_build_hero()
	_build_pursuer()
	_fog_goal = _fog_alphas(view.run.current_node().layer, view.visible_layer())
	if time_scale <= 0.0:
		_fog_now = _fog_goal.duplicate()
		_apply_fog(true)
	_rebuild_overlay()


## Aviso do Perseguidor (GDD §13): "está a N nós", sino duas vezes ao entrar e sprite no caminho atrás da
## Bibiana, a N camadas do nó atual (ADR-0066). Sem Perseguidor ativo, nada aparece.
func _build_pursuer() -> void:
	var run: RunState = view.run
	if _pursuer_banner == null:
		_pursuer_banner = PanelContainer.new()
		var box: StyleBoxFlat = StyleBoxFlat.new()
		box.bg_color = Color(0.16, 0.04, 0.05, 0.92)
		box.border_color = Color(0.72, 0.16, 0.14)
		box.set_border_width_all(2)
		box.set_corner_radius_all(6)
		box.set_content_margin_all(6)
		_pursuer_banner.add_theme_stylebox_override("panel", box)
		_pursuer_banner.position = Vector2(10, 82)
		_pursuer_banner.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var row: HBoxContainer = HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)
		_pursuer_banner.add_child(row)
		var icon: TextureRect = TextureRect.new()
		icon.texture = load("res://assets/bibiana/icons/node/danger.png") as Texture2D
		icon.custom_minimum_size = Vector2(30, 30)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		row.add_child(icon)
		_pursuer_text = Label.new()
		_pursuer_text.add_theme_font_size_override("font_size", 17)
		_pursuer_text.add_theme_color_override("font_color", Color(0.96, 0.82, 0.78))
		row.add_child(_pursuer_text)
		add_child(_pursuer_banner)
	var active: bool = run.pursuer_active()
	_pursuer_banner.visible = active
	if not active:
		_last_pursuer_distance = -1
		return
	if run.pursuer_pending:
		_pursuer_text.text = "O Perseguidor alcançou você!"
	else:
		_pursuer_text.text = "O Perseguidor está a %d nós" % run.pursuer_distance
	if run.pursuer_distance == RoamingRules.START_DISTANCE and _last_pursuer_distance != run.pursuer_distance and time_scale > 0.0:
		SoundFx.play(self, "bell")
		get_tree().create_timer(0.9).timeout.connect(func() -> void: SoundFx.play(self, "bell"))
	_last_pursuer_distance = run.pursuer_distance
	# Sprite no caminho percorrido, a `distance` camadas atrás do nó atual.
	var layer_back: int = run.current_node().layer - maxi(run.pursuer_distance, 0)
	var spot: int = run.map.start_id
	for id: int in view.visited_ids():
		if run.map.node_by_id(id).layer == layer_back:
			spot = id
	_place_sprite("crowned_pursuer", layout.node_world(spot), 3.4)
	var glow: OmniLight3D = OmniLight3D.new()
	glow.light_color = Color(0.9, 0.2, 0.15)
	glow.light_energy = 3.0
	glow.omni_range = 5.0
	glow.position = layout.node_world(spot) + Vector3(0, 1.8, 0)
	_node_root.add_child(glow)


func _build_node(info: Dictionary) -> void:
	var state: MapView.State = info["state"]
	# Nó já percorrido, abandonado ou ainda na névoa não mostra ator (o inimigo derrotado não volta).
	if state == MapView.State.FOG or state == MapView.State.PAST or state == MapView.State.VISITED:
		return
	var node: MapNode = view.run.map.node_by_id(int(info["id"]))
	var at: Vector3 = layout.node_world(node.id)
	var kind: int = int(info["kind"])
	if state == MapView.State.OPTION or state == MapView.State.BOSS:
		var disc_path: String = "res://assets/bibiana/ui/node_disc_%d.png" % (node.id % 5)
		if ResourceLoader.exists(disc_path):
			var disc: Sprite3D = Sprite3D.new()
			var dtex: Texture2D = load(disc_path) as Texture2D
			disc.texture = dtex
			disc.axis = Vector3.AXIS_Y
			disc.pixel_size = 2.6 / float(maxi(dtex.get_width(), 1))
			disc.shaded = false
			disc.transparent = true
			disc.position = at + Vector3(0.0, 0.04, 0.0)
			_node_root.add_child(disc)
	if state == MapView.State.OPTION:
		var diamond_color: Color = VisualTheme.COLOR_DANGER if bool(info.get("mini_boss", false)) else Color(1.0, 0.72, 0.28)
		_diamonds.append(_add_diamond(at, diamond_color, 2.3))
		var glow_color: Color = VisualTheme.COLOR_DANGER if bool(info.get("mini_boss", false)) else Color(1.0, 0.72, 0.3)
		var glow: OmniLight3D = OmniLight3D.new()
		glow.light_color = glow_color
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
		# Sprites HD-2D do tabuleiro (TASK-070): maiores que o modelo 3D antigo para ler a 540 px.
		var factor: float = 2.8
		if node.kind == MapNode.Kind.ELITE:
			factor = 3.2
		elif node.kind == MapNode.Kind.MINI_BOSS or node.kind == MapNode.Kind.BOSS:
			factor = 3.5
		foe.scale = Vector3.ONE * factor
		_node_root.add_child(foe)
		ModelRegistry.play(foe, node.enemy_id, "idle")
		return
	match node.kind:
		MapNode.Kind.CHEST:
			_place_sprite("iron_chest", at, 1.9)
		MapNode.Kind.BONFIRE:
			_place_sprite("campfire", at, 1.9)
			var flame_path: String = "res://assets/bibiana/fx/flame.png"
			if ResourceLoader.exists(flame_path):
				var flame: Sprite3D = Sprite3D.new()
				flame.texture = load(flame_path) as Texture2D
				flame.hframes = 8
				flame.frame = 0
				flame.pixel_size = 1.05 / 256.0
				flame.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
				flame.shaded = false
				flame.transparent = true
				flame.modulate = Color(1.0, 0.94, 0.82, 0.92)
				flame.position = at + Vector3(0.0, 0.52, 0.0)
				_node_root.add_child(flame)
				_bonfire_flames.append(flame)
			var fire: OmniLight3D = OmniLight3D.new()
			fire.light_color = Color(1.0, 0.5, 0.18)
			fire.light_energy = 3.6
			fire.omni_range = 5.0
			fire.position = at + Vector3(0, 1.0, 0)
			_node_root.add_child(fire)
		MapNode.Kind.EVENT:
			# Cada evento ganha um lugar: poço, forca de três cordas ou lápide (TASK-077).
			var spot: Array[String] = ["well_stone", "gallows_post_3ropes", "gothic_tombstone"]
			_place_sprite(spot[node.id % spot.size()], at, 2.5)
		_:
			pass


## Prop do nó como sprite HD-2D em pé na praça (altura em unidades de mundo).
func _place_sprite(id: String, at: Vector3, height: float) -> void:
	var prop: Node3D = ModelRegistry.spawn(id)
	prop.position = at
	prop.scale = Vector3.ONE * height
	_node_root.add_child(prop)


## Losango de luz no chão da praça (destino disponível ou nó atual), como na tática isométrica.
func _add_diamond(at: Vector3, color: Color, size: float, filled_only: bool = false) -> MeshInstance3D:
	var quad: QuadMesh = QuadMesh.new()
	quad.size = Vector2(size, size)
	quad.orientation = PlaneMesh.FACE_Y
	var shader: Shader = Shader.new()
	shader.code = "shader_type spatial;\nrender_mode unshaded, blend_add, depth_draw_never, cull_disabled;\nuniform vec4 tint : source_color = vec4(1.0, 0.75, 0.3, 1.0);\nuniform float pulse = 1.0;\nuniform float border_on = 1.0;\nvoid fragment() {\n\tvec2 d = abs(UV - 0.5) * 2.0;\n\tfloat m = max(d.x, d.y);\n\tfloat border = smoothstep(0.80, 0.86, m) * (1.0 - smoothstep(0.93, 0.98, m)) * border_on;\n\tfloat fill = 0.22 * (1.0 - smoothstep(0.0, 0.95, m));\n\tALBEDO = tint.rgb * (border * 1.6 + fill) * pulse;\n}\n"
	var material: ShaderMaterial = ShaderMaterial.new()
	material.shader = shader
	material.set_shader_parameter("tint", color)
	material.set_shader_parameter("border_on", 0.0 if filled_only else 1.0)
	quad.material = material
	var mesh: MeshInstance3D = MeshInstance3D.new()
	mesh.mesh = quad
	mesh.position = at + Vector3(0.0, 0.06, 0.0)
	mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_node_root.add_child(mesh)
	return mesh


func _build_hero() -> void:
	if _hero != null:
		_hero.queue_free()
	_hero_sprite = null
	_hero_cell = layout.node_cells[view.run.current_node_id]
	_hero = ModelRegistry.spawn(ModelRegistry.hero_id())
	_hero.position = layout.world_of(_hero_cell)
	_hero.rotation_degrees.y = 180.0
	_hero.scale = Vector3.ONE * 2.9
	_world.add_child(_hero)
	for found: Node in _hero.find_children("*", "Sprite3D", true, false):
		_hero_sprite = found as Sprite3D
		break
	ModelRegistry.play(_hero, ModelRegistry.hero_id(), "idle")


func _set_hero_pose(pose: String) -> void:
	if _hero_sprite == null:
		return
	var id: String = ModelRegistry.hero_id() if pose == "back" else "bibiana_warrior_%s" % pose
	if not ModelRegistry.has_sprite(id):
		return
	var tex: Texture2D = ModelRegistry.sprite_texture(id)
	_hero_sprite.texture = tex
	_hero_sprite.pixel_size = 1.0 / 240.0
	_hero_sprite.offset = Vector2(0.0, float(tex.get_height()) * 0.5)


func _apply_map_walk_stride(elapsed: float) -> void:
	if _hero_sprite == null:
		return
	_set_hero_pose("walk_%d" % (int(elapsed / 0.11) % 4))
	var phase: float = elapsed / 0.11
	_hero_sprite.position = Vector3(0.0, absf(sin(phase * PI)) * 0.16, 0.0)
	_hero_sprite.rotation_degrees = Vector3(0.0, 0.0, sin(phase * PI) * 4.0)


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
	var node_icon_tex: Texture2D = IconRegistry.texture_for("node", str(node.kind))
	if node_icon_tex != null:
		var badge: TextureRect = TextureRect.new()
		badge.texture = node_icon_tex
		badge.custom_minimum_size = Vector2(18, 18)
		badge.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		badge.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		badge.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(badge)
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
	var view_w: float = size.x if size.x > 16.0 else 540.0
	var view_h: float = size.y if size.y > 16.0 else 960.0
	for node_id: int in _bubbles.keys():
		var bubble: Control = _bubbles[node_id]
		var p: Vector2 = _screen_of(layout.node_world(node_id) + Vector3(0, 2.4, 0))
		var max_x: float = maxf(8.0, view_w - bubble.size.x - 8.0)
		var max_y: float = maxf(76.0, view_h - bubble.size.y - 8.0)
		bubble.position = Vector2(
			clampf(p.x - bubble.size.x * 0.5, 8.0, max_x),
			clampf(p.y - bubble.size.y, 76.0, max_y)
		)
	for node_id: int in _taps.keys():
		var tap: Control = _taps[node_id]
		tap.position = _screen_of(layout.node_world(node_id) + Vector3(0, 0.9, 0)) - tap.size * 0.5


func button_for(node_id: int) -> Button:
	return _taps.get(node_id)


## Toque num destino: a Bibiana caminha pela estrada, a câmera desliza junto e só então a Descida avança.
func _on_pick(node_id: int) -> void:
	if _walking:
		return
	if preview_enabled and _previewed != node_id:
		_show_preview(node_id)
		return
	_close_preview(false)
	SoundFx.play(self, "step")
	var from_cell: Vector2i = layout.node_cells[view.run.current_node_id]
	var to_cell: Vector2i = layout.node_cells[node_id]
	if time_scale <= 0.0:
		node_chosen.emit(node_id)
		return
	_walking = true
	var cells: Array[Vector2i] = layout.path_cells(from_cell, to_cell)
	ModelRegistry.play(_hero, ModelRegistry.hero_id(), "walk")
	var steps: int = maxi(cells.size() - 1, 1)
	var duration: float = STEP_SECONDS * float(steps) / time_scale
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	for i: int in range(1, cells.size()):
		var target: Vector3 = layout.world_of(cells[i])
		tween.tween_property(_hero, "position", target, STEP_SECONDS / time_scale).set_delay(STEP_SECONDS / time_scale * float(i - 1))
	if _hero_sprite != null:
		tween.tween_method(func(t: float) -> void:
			_apply_map_walk_stride(t), 0.0, duration, duration)
	var start: Vector3 = _cam_target
	var finish: Vector3 = _aim_point(node_id)
	tween.tween_method(func(t: float) -> void: _set_camera_target(start.lerp(finish, t)), 0.0, 1.0, duration)
	tween.chain().tween_callback(func() -> void:
		if _hero_sprite != null:
			_hero_sprite.position = Vector3.ZERO
			_hero_sprite.rotation_degrees = Vector3.ZERO
			_set_hero_pose("back")
		_walking = false
		node_chosen.emit(node_id))


## Névoa pintada que deriva devagar e grade de ferro no primeiro plano (TASK-072): profundidade de
## camadas, como nas referências táticas. Nada disso intercepta toque.
func _add_foreground() -> void:
	var mist_path: String = "res://assets/bibiana/arenas/map-mist-band.png"
	if ResourceLoader.exists(mist_path):
		_mist = TextureRect.new()
		_mist.texture = load(mist_path) as Texture2D
		_mist.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		_mist.stretch_mode = TextureRect.STRETCH_SCALE
		_mist.size = Vector2(760.0, 300.0)
		_mist.position = Vector2(-110.0, 330.0)
		_mist.modulate = Color(1, 1, 1, 0.5)
		_mist.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(_mist)
	var fence_path: String = "res://assets/bibiana/arenas/map-fg-ironfence.png"
	if ResourceLoader.exists(fence_path):
		var fence: TextureRect = TextureRect.new()
		var tex: Texture2D = load(fence_path) as Texture2D
		fence.texture = tex
		fence.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		fence.stretch_mode = TextureRect.STRETCH_SCALE
		var h: float = 540.0 * float(tex.get_height()) / float(tex.get_width())
		fence.size = Vector2(540.0, h)
		fence.position = Vector2(0.0, 960.0 - h + 6.0)
		fence.modulate = Color(1, 1, 1, 0.92)
		fence.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(fence)


func _add_vignette() -> void:
	var rect: ColorRect = ColorRect.new()
	rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var shader: Shader = Shader.new()
	shader.code = "shader_type canvas_item;\nvoid fragment() {\n\tvec2 uv = UV - vec2(0.5);\n\tfloat d = dot(uv, uv) * 2.2;\n\tCOLOR = vec4(0.0, 0.0, 0.02, clamp(d * d * 1.0, 0.0, 0.6));\n}\n"
	var mat: ShaderMaterial = ShaderMaterial.new()
	mat.shader = shader
	rect.material = mat
	add_child(rect)


## Ponto que a câmera mira: entre a Bibiana e o centro dos destinos, para mostrar os três caminhos.
func _aim_point(from_node_id: int) -> Vector3:
	var here: Vector3 = layout.node_world(from_node_id)
	# Na última camada, a mira vai ao chefe: ele aparece diante da igreja pintada (ADR-0060).
	if view.run.map.node_by_id(from_node_id).layer >= view.run.map.layer_count:
		return layout.node_world(view.run.map.boss_id)
	var next_ids: PackedInt32Array = view.run.map.node_by_id(from_node_id).next_ids
	if next_ids.is_empty():
		return here + CAM_LOOKAHEAD
	var sum: Vector3 = Vector3.ZERO
	for id: int in next_ids:
		sum += layout.node_world(id)
	var centroid: Vector3 = sum / float(next_ids.size())
	# Perto do fim, o chefe entra na mira para aparecer inteiro na tela.
	var last_layer: int = view.run.map.layer_count + 1
	if view.run.map.node_by_id(from_node_id).layer >= last_layer - 2:
		for node: MapNode in view.run.map.nodes:
			if node.kind == MapNode.Kind.BOSS:
				centroid = centroid.lerp(layout.node_world(node.id), 0.5)
	return here.lerp(centroid, 0.6)


## Marcador discreto no piso da praça disponível, destacando o destino sem postes avulsos.
func _add_option_beacon(at: Vector3, color: Color) -> void:
	var disc: CylinderMesh = CylinderMesh.new()
	disc.top_radius = 1.05
	disc.bottom_radius = 1.1
	disc.height = 0.02
	disc.radial_segments = 16
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.albedo_color = Color(color.r, color.g, color.b, 0.24)
	disc.material = mat
	var mi: MeshInstance3D = MeshInstance3D.new()
	mi.mesh = disc
	mi.position = at + Vector3(0.0, 0.04, 0.0)
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_node_root.add_child(mi)


## Equipamento e mochila da Bibiana em ícones, sob o cabeçalho (TASK-043): arma, mão secundária,
## armadura, cabeça e relíquia (vazio aparece como moldura apagada), mais poções e Galhos Secos.
func _fill_gear() -> void:
	for child: Node in _gear_row.get_children():
		child.queue_free()
	var run: RunState = view.run
	for slot: String in ["weapon", "offhand", "armor", "head", "relic"]:
		var item_id: String = str(run.equipment.get(slot, ""))
		var tip: String = RunPanels.SLOT_NAMES.get(slot, slot)
		var tex: Texture2D = IconRegistry.texture_for("item", item_id) if not item_id.is_empty() else IconRegistry.texture_for("slot", slot)
		if not item_id.is_empty():
			tip = "%s: %s" % [tip, str(run.data.items[item_id]["name"])]
		_gear_row.add_child(_gear_slot(tex, tip, "", item_id.is_empty()))
	_gear_row.add_child(_gear_slot(IconRegistry.texture_for("ui", "potion"), "Poções", "x%d" % run.consumable_count("murky_potion")))
	_gear_row.add_child(_gear_slot(IconRegistry.texture_for("ui", "firewood"), "Galhos Secos", "x%d" % run.consumable_count(RunRules.FIREWOOD_ID)))


func _gear_slot(tex: Texture2D, tip: String, count: String, empty: bool = false) -> Control:
	var frame: PanelContainer = PanelContainer.new()
	frame.add_theme_stylebox_override("panel", UiKit.slot("steel" if empty else "bronze", 6))
	if empty:
		frame.modulate = Color(1, 1, 1, 0.5)
	frame.tooltip_text = tip
	frame.mouse_filter = Control.MOUSE_FILTER_PASS
	var row: HBoxContainer = HBoxContainer.new()
	row.add_theme_constant_override("separation", 3)
	frame.add_child(row)
	var icon: TextureRect = TextureRect.new()
	icon.texture = tex
	icon.custom_minimum_size = Vector2(34, 34)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	row.add_child(icon)
	if not count.is_empty():
		var label: Label = Label.new()
		label.text = count
		label.add_theme_font_size_override("font_size", 13)
		row.add_child(label)
	return frame


## Mini-card do destino (D-UI-3): a câmera desliza até ele e o card diz o que o espera, com
## "Caminhar" e "Voltar". Evita entrar sem querer numa elite ou emboscada.
func _show_preview(node_id: int) -> void:
	_close_preview(false)
	_previewed = node_id
	var info: Dictionary = {}
	for entry: Dictionary in view.nodes():
		if int(entry["id"]) == node_id:
			info = entry
	var node: MapNode = view.run.map.node_by_id(node_id)
	_preview_card = PanelContainer.new()
	_preview_card.add_theme_stylebox_override("panel", UiKit.panel(40))
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
	_mark_selection(node_id)
	if time_scale > 0.0:
		var start: Vector3 = _cam_target
		var finish: Vector3 = _aim_point(node_id)
		var tween: Tween = create_tween()
		tween.tween_method(func(t: float) -> void: _set_camera_target(start.lerp(finish, t)), 0.0, 1.0, 0.35 / time_scale)


## Seta pulsante acima do destino e trilha de losangos acesos até ele (ADR-0057).
func _mark_selection(node_id: int) -> void:
	_clear_selection()
	var from_cell: Vector2i = layout.node_cells[view.run.current_node_id]
	var to_cell: Vector2i = layout.node_cells[node_id]
	var cells: Array[Vector2i] = layout.path_cells(from_cell, to_cell)
	for i: int in range(1, cells.size() - 1):
		_selection.append(_add_diamond(layout.world_of(cells[i]) + Vector3(0.0, 0.0, 0.0), Color(1.0, 0.82, 0.4), 0.8))
	var at: Vector3 = layout.node_world(node_id)
	_arrow = Label3D.new()
	_arrow.text = "▼"
	_arrow.font_size = 200
	_arrow.pixel_size = 0.0055
	_arrow.modulate = Color(1.0, 0.82, 0.35)
	_arrow.outline_modulate = Color(0.12, 0.05, 0.0)
	_arrow.outline_size = 30
	_arrow.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_arrow.no_depth_test = true
	_arrow_base_y = at.y + 5.2
	_arrow.position = Vector3(at.x, _arrow_base_y, at.z)
	_node_root.add_child(_arrow)
	_selection.append(_arrow)


func _clear_selection() -> void:
	for node: Node in _selection:
		if is_instance_valid(node):
			node.queue_free()
	_selection.clear()
	_arrow = null


func _close_preview(recenter: bool) -> void:
	_clear_selection()
	if _preview_card != null:
		_preview_card.queue_free()
		_preview_card = null
	_previewed = -1
	if recenter and time_scale > 0.0:
		var start: Vector3 = _cam_target
		var finish: Vector3 = _aim_point(view.run.current_node_id)
		var tween: Tween = create_tween()
		tween.tween_method(func(t: float) -> void: _set_camera_target(start.lerp(finish, t)), 0.0, 1.0, 0.3 / time_scale)


var _hud_hp: ProgressBar
var _hud_mp: ProgressBar
var _hud_gold: Label


## Barras finas de HP e MP e ouro com ícone no topo (ESTUDO Parte 3.2, mapa): sem texto de depuração.
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
	coin.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	coin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(coin)
	_hud_gold = Label.new()
	_hud_gold.add_theme_font_size_override("font_size", 14)
	_hud_gold.add_theme_color_override("font_color", Color("D9AA32"))
	_hud_gold.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(_hud_gold)


func _thin_bar(color: Color, width: float) -> ProgressBar:
	var bar: ProgressBar = ProgressBar.new()
	bar.custom_minimum_size = Vector2(width, 8)
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
