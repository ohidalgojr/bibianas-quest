class_name Combat3DStage
extends Control
## Palco 3D da luta (TASK-037, ADR-0036, GDD §6 e §17, docs/ART-DIRECTION.md §4): o fundo vem do
## tipo do nó (praça, passagem de elite, sala do chefe), escurecido e com vinheta, com o inimigo
## grande e central, a Bibiana de costas embaixo à esquerda e luz quente no chão. Só
## apresentação: a tela de combate manda tocar as animações a partir dos eventos do núcleo.

const K_MINI: String = "res://assets/kenney/mini_dungeon/"
const K_GRAVE: String = "res://assets/kenney/graveyard/"
const SHRINK: int = 2
## Câmera de duelo (ADR-0050, IDENTIDADE-VISUAL §C.1): perto e baixa, o inimigo é o herói do quadro.
const CAM_SIZE: float = 3.9
const CAM_OFFSET: Vector3 = Vector3(1.0, 0.62, 1.0) * 16.0
const CAM_TARGET: Vector3 = Vector3(-0.5, 1.75, -0.4)
const ENEMY_POS: Vector3 = Vector3(-0.9, 0.9, -1.0)
const PLAYER_POS: Vector3 = Vector3(0.9, 0.9, 2.8)
## Alturas de pé em unidades (inimigo comum, elite, chefe e Bibiana).
const HEIGHT_COMMON: float = 2.5
const HEIGHT_ELITE: float = 3.0
const HEIGHT_BOSS: float = 3.6
const HEIGHT_PLAYER: float = 1.45
const ENEMY_YAW: float = 45.0
const PLAYER_YAW: float = 225.0
const ARENA_HALF: int = 5

var time_scale: float = 1.0
var camera: Camera3D
var player_node: Node3D
var enemy_node: Node3D

var _viewport: SubViewport
var _world: Node3D
var _scene_root: Node3D
var _enemy_id: String = ""
var _enemy_scale: float = 2.4
var _shake: float = 0.0
var _dim: ColorRect
var _portraits: Dictionary = {}


func _ready() -> void:
	var container: SubViewportContainer = SubViewportContainer.new()
	container.stretch = true
	container.stretch_shrink = SHRINK
	container.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(container)
	PostFx.apply(container, PostFx.COMBAT_BLUR)
	_viewport = SubViewport.new()
	_viewport.size = Vector2i(270, 300)
	_viewport.msaa_3d = Viewport.MSAA_DISABLED
	container.add_child(_viewport)
	_world = Node3D.new()
	_viewport.add_child(_world)
	_build_environment()
	camera = Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = CAM_SIZE
	camera.near = 0.1
	camera.far = 80.0
	_world.add_child(camera)
	_aim_camera(Vector3.ZERO)
	_scene_root = Node3D.new()
	_world.add_child(_scene_root)
	_add_vignette()
	add_child(WeatherLayer.new())
	_dim = ColorRect.new()
	_dim.color = Color(0, 0, 0.02, 0.0)
	_dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_dim)


func _aim_camera(shake: Vector3) -> void:
	camera.position = CAM_TARGET + CAM_OFFSET + shake
	camera.look_at(CAM_TARGET + shake)


func _build_environment() -> void:
	var env: Environment = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.02, 0.024, 0.038)
	Atmosphere.apply(env)
	# O duelo precisa de mais ambiente que as outras cenas: o palco é fechado e as peças vêm tingidas.
	env.ambient_light_energy = 0.62
	env.fog_density = 0.007
	env.adjustment_enabled = true
	env.adjustment_saturation = 0.56
	env.adjustment_contrast = 1.2
	env.adjustment_brightness = 0.9
	env.glow_enabled = true
	env.glow_intensity = 0.58
	env.glow_bloom = 0.08
	var holder: WorldEnvironment = WorldEnvironment.new()
	holder.environment = env
	_world.add_child(holder)
	var moon: DirectionalLight3D = DirectionalLight3D.new()
	# Luar de aço rasante vindo de trás do inimigo: recorta a silhueta (IDENTIDADE-VISUAL §B.2).
	moon.light_color = Color("7E8FA8")
	moon.light_energy = 0.7
	moon.rotation_degrees = Vector3(-35, 225, 0)
	moon.shadow_enabled = true
	moon.directional_shadow_mode = DirectionalLight3D.SHADOW_ORTHOGONAL
	moon.directional_shadow_max_distance = 35.0
	_world.add_child(moon)
	# Preenchimento frio vindo da câmera, sem sombra: as paredes do fundo ainda se leem.
	var fill: DirectionalLight3D = DirectionalLight3D.new()
	fill.light_color = Color("7E8FA8")
	fill.light_energy = 0.55
	fill.rotation_degrees = Vector3(-30, 45, 0)
	_world.add_child(fill)
	_world.add_child(Atmosphere.make_focus_spot(ENEMY_POS + Vector3(0.0, 1.6, 0.0), 7.0))


## Monta o palco de uma luta. `kind` é o [enum MapNode.Kind] do nó (usa -1 para a luta de teste).
func setup(enemy_id: String, kind: int, mutation: String = "") -> void:
	_enemy_id = enemy_id
	for child: Node in _scene_root.get_children():
		child.queue_free()
	player_node = null
	enemy_node = null
	_build_arena(kind)
	_spawn_actors(kind)
	_apply_mutation(mutation)
	_portraits.clear()


func _build_arena(kind: int) -> void:
	var boss: bool = kind == MapNode.Kind.BOSS or kind == MapNode.Kind.MINI_BOSS
	var focal_kind: String = "combat_boss" if boss else ("combat_elite" if kind == MapNode.Kind.ELITE else "combat_common")
	# Arena de duelo composta (ADR-0050): canto de nave gótica, não o diorama procedural.
	DuelArena.build(_scene_root, focal_kind)


func _spawn_actors(kind: int) -> void:
	player_node = ModelRegistry.spawn("bibiana")
	player_node.position = PLAYER_POS
	player_node.rotation_degrees.y = PLAYER_YAW
	_scene_root.add_child(player_node)
	player_node.scale = Vector3.ONE * _scale_to_height(player_node, HEIGHT_PLAYER, 1.0)
	ModelRegistry.play(player_node, "bibiana", "idle")
	if not ModelRegistry.has_model(_enemy_id):
		return
	enemy_node = ModelRegistry.spawn(_enemy_id)
	enemy_node.position = ENEMY_POS
	enemy_node.rotation_degrees.y = ENEMY_YAW + ModelRegistry.yaw_offset(_enemy_id)
	var boss: bool = kind == MapNode.Kind.BOSS or kind == MapNode.Kind.MINI_BOSS
	# Escala pela altura de pé (a criatura alta lê alta), com teto para as largas (cão, rato).
	var target: float = HEIGHT_BOSS if boss else (HEIGHT_ELITE if kind == MapNode.Kind.ELITE else HEIGHT_COMMON)
	_scene_root.add_child(enemy_node)
	_enemy_scale = _scale_to_height(enemy_node, target, 1.7)
	enemy_node.scale = Vector3.ONE * _enemy_scale
	ModelRegistry.play(enemy_node, _enemy_id, "idle")


## Fator de escala que leva a altura do modelo a [param height], sem deixar a maior dimensão passar de
## [param max_ratio] vezes essa altura.
func _scale_to_height(node: Node3D, height: float, max_ratio: float) -> float:
	var box: AABB = _aabb(node)
	var longest: float = maxf(box.size.x, maxf(box.size.y, box.size.z))
	if box.size.y < 0.05 or longest < 0.05:
		return 2.0
	return minf(height / box.size.y, height * max_ratio / longest)


## Posição de tela (coordenadas deste `Control`) do alvo, para números de dano e ícones.
func screen_pos(on_enemy: bool) -> Vector2:
	var node: Node3D = enemy_node if on_enemy else player_node
	if node == null or camera == null or not camera.is_inside_tree():
		return size * 0.5
	var head: float = 1.6 if on_enemy else 1.2
	return camera.unproject_position(node.position + Vector3(0, head, 0)) * float(SHRINK)


## Toca uma animação do modelo: "attack", "hit", "death" ou "idle". `on_enemy` escolhe o lado.
func play(on_enemy: bool, key: String) -> void:
	var node: Node3D = enemy_node if on_enemy else player_node
	if node == null:
		return
	var id: String = _enemy_id if on_enemy else "bibiana"
	ModelRegistry.play(node, id, key)
	if time_scale <= 0.0 or not is_inside_tree():
		return
	var home: Vector3 = ENEMY_POS if on_enemy else PLAYER_POS
	var toward: Vector3 = (PLAYER_POS - ENEMY_POS).normalized() * (1.0 if on_enemy else -1.0)
	var tween: Tween = create_tween()
	match key:
		"attack":
			tween.tween_property(node, "position", home + toward * 0.9, 0.12 * time_scale)
			tween.tween_property(node, "position", home, 0.22 * time_scale)
		"hit":
			_shake = 0.18
			tween.tween_property(node, "position", home - toward * 0.35, 0.07 * time_scale)
			tween.tween_property(node, "position", home, 0.2 * time_scale)
		"death":
			tween.tween_property(node, "scale", node.scale * 0.01, 0.7 * time_scale).set_delay(0.3 * time_scale)
	tween.finished.connect(func() -> void:
		if key != "death":
			ModelRegistry.play(node, id, "idle"))


func _process(delta: float) -> void:
	if camera == null:
		return
	if _shake > 0.0:
		_shake = maxf(_shake - delta, 0.0)
		_aim_camera(Vector3(sin(_shake * 90.0), 0.0, cos(_shake * 70.0)) * _shake)
	else:
		_aim_camera(Vector3.ZERO)


func _add_vignette() -> void:
	var rect: ColorRect = ColorRect.new()
	rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var shader: Shader = Shader.new()
	shader.code = "shader_type canvas_item;\nvoid fragment() {\n\tvec2 uv = UV - vec2(0.5);\n\tfloat d = dot(uv, uv) * 2.6;\n\tCOLOR = vec4(0.0, 0.0, 0.02, clamp(d * d * 1.6, 0.0, 0.92));\n}\n"
	var mat: ShaderMaterial = ShaderMaterial.new()
	mat.shader = shader
	rect.material = mat
	add_child(rect)


## Mutação visível no modelo (GDD §11, ADR-0032): tamanho, transparência ou luz própria.
func _apply_mutation(mutation: String) -> void:
	if enemy_node == null or mutation.is_empty():
		return
	match mutation:
		"bloated":
			enemy_node.scale *= Vector3(1.3, 1.0, 1.3)
		"voracious":
			var red: OmniLight3D = OmniLight3D.new()
			red.light_color = Color(1.0, 0.18, 0.12)
			red.light_energy = 3.0
			red.omni_range = 4.0
			red.position = Vector3(0, 1.4, 0)
			enemy_node.add_child(red)
		"phantom":
			for mesh: Node in enemy_node.find_children("*", "MeshInstance3D", true, false):
				(mesh as MeshInstance3D).transparency = 0.5
		"thorny":
			enemy_node.scale *= 1.15
			var thorn: OmniLight3D = OmniLight3D.new()
			thorn.light_color = Color(0.7, 0.2, 0.5)
			thorn.light_energy = 2.0
			thorn.omni_range = 3.0
			thorn.position = Vector3(0, 1.0, 0)
			enemy_node.add_child(thorn)


## Retrato do personagem (cabeça e ombros) para a linha do tempo. Cada um tem a própria
## `SubViewport` com o modelo e uma câmera de frente, desenhada uma vez por luta.
func portrait(on_enemy: bool) -> Texture2D:
	var key: String = "enemy" if on_enemy else "player"
	if _portraits.has(key):
		return _portraits[key]
	var id: String = _enemy_id if on_enemy else "bibiana"
	if not ModelRegistry.has_model(id):
		return null
	var port: SubViewport = SubViewport.new()
	port.size = Vector2i(64, 64)
	port.own_world_3d = true
	port.transparent_bg = true
	port.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(port)
	var model: Node3D = ModelRegistry.spawn(id)
	port.add_child(model)
	ModelRegistry.play(model, id, "idle")
	var height: float = 1.0
	var top: float = 1.0
	var box: AABB = _aabb(model)
	if box.size.y > 0.01:
		height = box.size.y
		top = box.position.y + box.size.y
	var cam: Camera3D = Camera3D.new()
	cam.projection = Camera3D.PROJECTION_ORTHOGONAL
	cam.size = height * 0.5
	port.add_child(cam)
	cam.position = Vector3(0, top - height * 0.2, 4.0)
	var light: DirectionalLight3D = DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-25, 20, 0)
	light.light_energy = 1.4
	port.add_child(light)
	var env: Environment = Environment.new()
	env.background_mode = Environment.BG_CLEAR_COLOR
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.6, 0.62, 0.7)
	var holder: WorldEnvironment = WorldEnvironment.new()
	holder.environment = env
	port.add_child(holder)
	var tex: Texture2D = port.get_texture()
	_portraits[key] = tex
	return tex


## Caixa do modelo no espaço do próprio `node` (acumula as transformações da malha até ele).
func _aabb(node: Node3D) -> AABB:
	var out: AABB = AABB()
	var first: bool = true
	for found: Node in node.find_children("*", "MeshInstance3D", true, false):
		var mesh: MeshInstance3D = found as MeshInstance3D
		var chain: Transform3D = mesh.transform
		var parent: Node = mesh.get_parent()
		while parent != null and parent != node:
			if parent is Node3D:
				chain = (parent as Node3D).transform * chain
			parent = parent.get_parent()
		var box: AABB = chain * mesh.get_aabb()
		out = box if first else out.merge(box)
		first = false
	return out


## Foco da moeda (GDD §7, §19): a cena escurece, a câmera se aproxima do centro e tudo fica
## em silêncio; `false` devolve a cena ao normal.
func set_focus(on: bool) -> void:
	if time_scale <= 0.0 or not is_inside_tree():
		return
	var tween: Tween = create_tween().set_parallel(true)
	tween.tween_property(_dim, "color:a", 0.6 if on else 0.0, 0.35 * time_scale)
	tween.tween_property(camera, "size", CAM_SIZE * (0.8 if on else 1.0), 0.35 * time_scale)


## Hit-stop (GDD §19): congela as animações por um instante no acerto, para dar peso.
func hit_stop(seconds: float = 0.08) -> void:
	if time_scale <= 0.0 or not is_inside_tree():
		return
	var players: Array[AnimationPlayer] = []
	for node: Node3D in [player_node, enemy_node]:
		if node == null:
			continue
		for found: Node in node.find_children("*", "AnimationPlayer", true, false):
			var player: AnimationPlayer = found as AnimationPlayer
			players.append(player)
			player.speed_scale = 0.0
	await get_tree().create_timer(seconds, true, false, true).timeout
	for player: AnimationPlayer in players:
		if is_instance_valid(player):
			player.speed_scale = 1.0
