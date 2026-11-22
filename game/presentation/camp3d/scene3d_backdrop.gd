class_name Scene3DBackdrop
extends Control
## Cenário 3D de fundo das telas fora do mapa e do combate (TASK-038, ADR-0036, docs/ART-DIRECTION.md
## §5): fogueira (Darkest Dungeon), loja, baú, evento, recompensa, menu e fim da Descida. A
## Bibiana e os objetos vêm dos kits CC0; as telas de painel ficam por cima. Só apresentação.

const K_MINI: String = "res://assets/kenney/mini_dungeon/"
const K_GRAVE: String = "res://assets/kenney/graveyard/"
const SHRINK: int = 2
const KINDS: Array[String] = ["campfire", "shop", "chest", "event", "reward", "home", "victory", "defeat"]

var kind: String = "home"
## 0 deixa tudo parado (testes); 1 é a velocidade normal.
var time_scale: float = 1.0
var hero: Node3D

var _viewport: SubViewport
var _world: Node3D
var _camera: Camera3D
var _lights: Array[OmniLight3D] = []
var _bases: Array[float] = []
var _flicker_time: float = 0.0

var _hero_power: float = 1.0
## Fogueira acesa (D-UI-5): apagada, só brasa fraca; acesa, chama, faíscas e luz forte.
var fire_lit: bool = true
var _fire_parts: Array[Node3D] = []
var _fire_light: OmniLight3D


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var container: SubViewportContainer = SubViewportContainer.new()
	container.stretch = true
	container.stretch_shrink = SHRINK
	container.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(container)
	PostFx.apply(container)
	_viewport = SubViewport.new()
	_viewport.size = Vector2i(270, 480)
	_viewport.msaa_3d = Viewport.MSAA_DISABLED
	container.add_child(_viewport)
	_world = Node3D.new()
	_viewport.add_child(_world)
	_build_environment()
	_camera = Camera3D.new()
	_camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	_camera.near = 0.1
	_camera.far = 80.0
	_world.add_child(_camera)
	_build_scene()
	var weather: WeatherLayer = WeatherLayer.new()
	weather.rain = kind == "home" or kind == "victory" or kind == "defeat"
	weather.embers = kind == "campfire" or kind == "victory"
	add_child(weather)
	_add_vignette()


func _build_environment() -> void:
	var cold: bool = kind == "defeat"
	var env: Environment = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.02, 0.024, 0.038)
	Atmosphere.apply(env)
	if cold:
		env.ambient_light_color = Color(0.15, 0.2, 0.3)
	env.adjustment_enabled = true
	env.adjustment_saturation = 0.56
	env.adjustment_contrast = 1.2
	env.adjustment_brightness = 0.9
	env.glow_enabled = true
	env.glow_intensity = 0.62
	env.glow_bloom = 0.09
	var holder: WorldEnvironment = WorldEnvironment.new()
	holder.environment = env
	_world.add_child(holder)
	env.ambient_light_color = Color("1B2029")
	env.ambient_light_energy = 2.8
	var moon: DirectionalLight3D = DirectionalLight3D.new()
	moon.light_color = Color("7E8FA8")
	moon.light_energy = 0.6
	moon.rotation_degrees = Vector3(-28, -140, 0)
	moon.shadow_enabled = true
	moon.directional_shadow_mode = DirectionalLight3D.SHADOW_ORTHOGONAL
	moon.directional_shadow_max_distance = 35.0
	_world.add_child(moon)
	var fill: DirectionalLight3D = DirectionalLight3D.new()
	fill.light_color = Color("7E8FA8")
	fill.light_energy = 0.85
	fill.rotation_degrees = Vector3(-42, 25, 0)
	_world.add_child(fill)


func _aim(target: Vector3, size: float, lift: float = 0.8, drop: float = 2.4, zoom: float = -1.0) -> void:
	var factor: float = 2.1 if kind == "shop" else (1.95 if kind == "home" else 1.55)
	_camera.size = size * factor if zoom < 0.0 else zoom
	# O assunto fica na metade de cima da tela (o painel ocupa a de baixo): mira abaixo dele.
	target += Vector3(1.0, 0.0, 1.0) * drop
	_camera.position = target + Vector3(1.0, lift, 1.0) * 16.0
	_camera.look_at(target)


func _build_scene() -> void:
	if kind == "campfire" or kind == "shop":
		# Diorama composto da identidade visual (ADR-0050): lajes escuras, ruína gótica, uma luz.
		FocalSet.floor_slabs(_world, 2)
	else:
		var bp: ScenarioBlueprint = ScenarioGenerator.generate_focal_diorama(kind, 7)
		ScenarioRenderer.render(_world, bp, false)
	match kind:
		"campfire":
			_build_campfire()
		"shop":
			_build_shop()
		"chest":
			_build_chest()
		"event":
			_build_event()
		"reward":
			_build_reward()
		"victory":
			_build_victory()
		"defeat":
			_build_defeat()
		_:
			_build_home()


func _warm(pos: Vector3, energy: float = 4.0, color: Color = Color(1.0, 0.5, 0.18), range_: float = 6.0) -> OmniLight3D:
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = color
	light.light_energy = energy
	light.omni_range = range_
	light.position = pos
	_world.add_child(light)
	_lights.append(light)
	_bases.append(energy)
	return light


func _hero(pos: Vector3, yaw: float, anim_key: String = "idle", factor: float = 1.9) -> Node3D:
	hero = ModelRegistry.spawn("bibiana")
	hero.position = pos
	hero.rotation_degrees.y = yaw
	hero.scale = Vector3.ONE * factor
	_world.add_child(hero)
	if anim_key == "idle":
		ModelRegistry.play(hero, "bibiana", "idle")
	else:
		_play_named(hero, anim_key)
	return hero


func _play_named(root: Node, anim_name: String, loop: bool = true) -> void:
	for found: Node in root.find_children("*", "AnimationPlayer", true, false):
		var player: AnimationPlayer = found as AnimationPlayer
		if player.has_animation(anim_name):
			if loop:
				player.get_animation(anim_name).loop_mode = Animation.LOOP_LINEAR
			player.play(anim_name)
		return


func _embers(pos: Vector3) -> void:
	var particles: CPUParticles3D = CPUParticles3D.new()
	var spark: BoxMesh = BoxMesh.new()
	spark.size = Vector3(0.05, 0.05, 0.05)
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color(1.0, 0.55, 0.15)
	spark.material = material
	particles.mesh = spark
	particles.amount = 28
	particles.lifetime = 2.2
	particles.direction = Vector3(0, 1, 0)
	particles.spread = 25.0
	particles.initial_velocity_min = 0.6
	particles.initial_velocity_max = 1.4
	particles.gravity = Vector3(0, 0.2, 0)
	particles.emission_shape = CPUParticles3D.EMISSION_SHAPE_SPHERE
	particles.emission_sphere_radius = 0.25
	particles.position = pos
	_world.add_child(particles)
	_fire_parts.append(particles)


const FIRE_LIT_ENERGY: float = 5.5
const FIRE_COLD_ENERGY: float = 0.45
var _cold_parts: Array[Node3D] = []


## Fogueira (IDENTIDADE-VISUAL §C.3): pira de lenha torta com espada fincada e chama, a Bibiana
## sentada de perfil diante dela, capela em ruína atrás. Apagada: só cinza e brasa fria.
func _build_campfire() -> void:
	var c: Vector3 = Vector3(0.0, FocalSet.FLOOR_Y, 0.0)
	FocalSet.gothic_nave(_world, c.y)
	FocalSet.foreground(_world, c.y, Vector3(5.2, c.y, 0.4))
	StageKit.place(_world, K_GRAVE + "debris.glb", Vector3(1.9, c.y, -1.2), 40.0, 2.2, FocalSet.STONE_DARK)
	FocalSet.tilted(_world, K_GRAVE + "cross.glb", Vector3(-2.6, c.y + 0.1, -2.4), 20.0, Vector3(0, 0, 24), 2.4, FocalSet.STONE_TINT)
	StageKit.place(_world, K_GRAVE + "gravestone-broken.glb", Vector3(2.6, c.y, 0.8), 70.0, 2.2, FocalSet.STONE_DARK)
	# Pira torta: toras apoiadas umas nas outras, espada fincada no meio.
	var log_path: String = K_GRAVE + "trunk-long.glb"
	var leans: Array[Vector3] = [Vector3(0, 0, 33), Vector3(0, 0, 30), Vector3(0, 0, 40), Vector3(0, 0, 27)]
	var yaws: Array[float] = [0.0, 180.0, -90.0, 90.0]
	var lengths: Array[float] = [1.5, 1.35, 1.2, 1.1]
	for i: int in 4:
		var foot: Vector3 = Vector3(sin(deg_to_rad(yaws[i])), 0.0, cos(deg_to_rad(yaws[i]))) * 0.0
		var pole: Node3D = FocalSet.tilted(_world, log_path, c + Vector3(0.0, 0.0, 0.0) + foot, yaws[i], leans[i], 1.0, FocalSet.TINT_WOOD)
		pole.scale = Vector3(0.5, lengths[i], 0.5)
		pole.position += Vector3(cos(deg_to_rad(yaws[i])), 0.0, -sin(deg_to_rad(yaws[i]))) * 0.45
	FocalSet.tilted(_world, K_MINI + "weapon-sword.glb", c + Vector3(0.0, 0.05, 0.0), 30.0, Vector3(0, 0, 8), 3.6, Color(0.66, 0.7, 0.82))
	for i: int in 7:
		var a: float = float(i) / 7.0 * TAU + 0.3
		StageKit.place(_world, K_MINI + "stones.glb", c + Vector3(cos(a) * 1.15, 0.0, sin(a) * 1.15), float(i) * 70.0, 0.55 + 0.1 * float(i % 3), Color(0.2, 0.22, 0.27))
	# Cinza e brasa fria (visíveis só com a fogueira apagada).
	FocalSet.stain(_world, c, Vector2(1.9, 1.9), Color(0.05, 0.05, 0.06), 1.0, 0.0, 15.0)
	for i: int in 5:
		var spot: MeshInstance3D = MeshInstance3D.new()
		var box: BoxMesh = BoxMesh.new()
		box.size = Vector3(0.14, 0.07, 0.14)
		var cold: StandardMaterial3D = StandardMaterial3D.new()
		cold.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		cold.albedo_color = Color(0.95, 0.28, 0.08)
		box.material = cold
		spot.mesh = box
		spot.position = c + Vector3(cos(float(i) * 1.7) * 0.4, 0.22, sin(float(i) * 1.7) * 0.4)
		_world.add_child(spot)
		_cold_parts.append(spot)
	# Chama, faíscas, luz quente única e mancha de luz nas lajes.
	_fire_parts.append_array(FocalSet.flame(_world, c + Vector3(0, 0.35, 0), 2.1))
	_fire_parts.append(FocalSet.sparks(_world, c + Vector3(0, 1.3, 0), 26))
	_fire_parts.append(FocalSet.glow_disc(_world, c, 3.4, Color(1.0, 0.5, 0.15), 0.55))
	_fire_light = _warm(c + Vector3(0.7, 1.1, 0.7), FIRE_LIT_ENERGY, Color(1.0, 0.5, 0.16), 6.5)
	_fire_light.shadow_enabled = true
	set_fire_lit(fire_lit)
	_hero(c + Vector3(-1.5, 0.0, 1.3), 125.0, "Sit_Floor_Idle", 2.15)
	_aim(c + Vector3(-0.2, 1.2, -0.2), 6.3, 0.62, 1.2, 19.0)


## Loja (IDENTIDADE-VISUAL §C.3): vulto encapuzado de manto Lama atrás de uma carroça escura com
## três mercadorias sob um lampião pendurado (a única luz quente), arcada ogival ao fundo.
func _build_shop() -> void:
	var y: float = FocalSet.FLOOR_Y
	FocalSet.gothic_nave(_world, y)
	FocalSet.foreground(_world, y, Vector3(5.2, y, 0.4))
	StageKit.place(_world, K_GRAVE + "debris.glb", Vector3(2.8, y, -1.6), 20.0, 2.2, FocalSet.STONE_DARK)
	var cart: Node3D = Node3D.new()
	cart.position = Vector3(-0.3, y, -0.3)
	cart.rotation_degrees.y = 45.0
	_world.add_child(cart)
	var wood: Color = Color(0.17, 0.14, 0.11)
	var top_y: float = 1.0
	FocalSet.box(cart, Vector3(0, 0.5, 0.0), Vector3(2.5, 1.0, 1.4), wood)
	FocalSet.box(cart, Vector3(0, top_y + 0.04, 0.0), Vector3(2.7, 0.09, 1.6), Color(0.13, 0.105, 0.085))
	for side: float in [-1.0, 1.0]:
		var wheel: CylinderMesh = CylinderMesh.new()
		wheel.top_radius = 0.34
		wheel.bottom_radius = 0.34
		wheel.height = 0.1
		wheel.radial_segments = 6
		wheel.material = FocalSet._paint(Color(0.1, 0.085, 0.07), false)
		var wheel_node: MeshInstance3D = MeshInstance3D.new()
		wheel_node.mesh = wheel
		wheel_node.rotation_degrees = Vector3(90, 0, 0)
		wheel_node.position = Vector3(side * 0.95, 0.34, 0.75)
		cart.add_child(wheel_node)
		FocalSet.box(cart, Vector3(side * 1.9, 0.55, 0.1), Vector3(1.5, 0.09, 0.09), wood, Vector3(0, 0, side * -4.0))
	# Mercadorias: frasco escuro, lâmina deitada, relicário quadrado (pequenos).
	FocalSet.box(cart, Vector3(-0.8, top_y + 0.24, 0.1), Vector3(0.16, 0.34, 0.16), Color(0.2, 0.26, 0.3))
	FocalSet.tilted(cart, K_MINI + "weapon-sword.glb", Vector3(0.0, top_y + 0.14, 0.2), 0.0, Vector3(0, 0, 82), 3.2, Color(0.5, 0.55, 0.66))
	FocalSet.box(cart, Vector3(0.8, top_y + 0.16, 0.0), Vector3(0.26, 0.2, 0.18), Color(0.34, 0.27, 0.12))
	# Lampião pendurado num poste torto.
	var post: Vector3 = Vector3(0.9, 0.0, 0.0)
	FocalSet.box(cart, post + Vector3(0, 1.45, -0.6), Vector3(0.12, 2.9, 0.12), wood, Vector3(0, 0, -4))
	FocalSet.box(cart, post + Vector3(-0.55, 2.88, -0.6), Vector3(1.2, 0.1, 0.1), wood)
	FocalSet.box(cart, post + Vector3(-1.1, 2.62, -0.6), Vector3(0.03, 0.4, 0.03), FocalSet.TINT_IRON)
	var lamp: Vector3 = post + Vector3(-1.1, 2.25, -0.6)
	FocalSet.box(cart, lamp, Vector3(0.24, 0.36, 0.24), Color(1.0, 0.62, 0.2), Vector3.ZERO, true)
	FocalSet.box(cart, lamp + Vector3(0, 0.23, 0), Vector3(0.34, 0.07, 0.34), FocalSet.TINT_IRON)
	FocalSet.box(cart, lamp + Vector3(0, -0.21, 0), Vector3(0.32, 0.06, 0.32), FocalSet.TINT_IRON)
	_warm(cart.to_global(lamp + Vector3(0.2, -0.3, 0.6)), 5.0, Color(0.88, 0.54, 0.19), 5.0).shadow_enabled = true
	FocalSet.glow_disc(_world, cart.position, 2.2, Color(0.88, 0.54, 0.19), 0.3)
	FocalSet.hooded_figure(_world, Vector3(-1.2, y, -1.3), 45.0, 2.5).name = "Merchant"
	_hero(Vector3(-1.5, y, 1.2), 125.0, "idle", 1.9)
	_aim(Vector3(-0.3, 1.6, -0.3), 6.4, 0.62, 3.4, 16.5)


## Baú: grande, no centro, abrindo, com moedas de ouro e cofre abobadado atrás.
func _build_chest() -> void:
	var chest: Node3D = StageKit.place(_world, K_MINI + "chest.glb", Vector3(0, 0.93, 0), 45.0, 3.8)
	_play_named(chest, "open", false)
	_warm(Vector3(0, 1.8, 0), 5.0, Color(1.0, 0.8, 0.3), 6.5)
	for i: int in 5:
		var angle: float = float(i) * 1.26
		StageKit.place(_world, K_MINI + "coin.glb", Vector3(cos(angle) * 1.3, 0.95, sin(angle) * 1.3), angle * 40.0, 1.6)
	_hero(Vector3(1.8, 0.93, 1.8), 225.0, "Interact")
	_aim(Vector3(0.2, 1.2, 0.2), 6.0)


## Evento: altar de pedra à luz de velas diante de obeliscos no terraço superior.
func _build_event() -> void:
	var altar_scale: float = 2.4
	StageKit.place(_world, K_GRAVE + "altar-stone.glb", Vector3(-0.4, 0.93, -0.4), 45.0, altar_scale, Color(0.75, 0.74, 0.78))
	var altar_top_y: float = 0.93 + 0.49 * altar_scale - 0.02
	StageKit.place(_world, K_GRAVE + "candle-multiple.glb", Vector3(-0.35, altar_top_y, -0.45), 0.0, 1.8)
	_warm(Vector3(-0.3, 2.3, -0.6), 3.8, Color(1.0, 0.6, 0.3), 6.5)
	_hero(Vector3(1.7, 0.93, 1.7), 225.0)
	_aim(Vector3(-0.1, 1.3, -0.1), 6.2)


## Recompensa depois da luta: a Bibiana de pé, com o butim a seus pés.
func _build_reward() -> void:
	_hero(Vector3(0.5, 0.93, 0.5), 225.0, "Cheer", 2.2)
	StageKit.place(_world, K_MINI + "coin.glb", Vector3(-0.8, 0.95, 0.8), 20.0, 1.8)
	StageKit.place(_world, K_MINI + "potion.glb", Vector3(1.4, 0.95, -0.4), 0.0, 2.0)
	_warm(Vector3(0.0, 2.2, 0.2), 3.6, Color(1.0, 0.75, 0.35), 6.5)
	_aim(Vector3(0.1, 1.3, 0.1), 6.0)


## Menu inicial: panorama da Cidade Abandonada com capela em terraço elevado e escadaria até a Bibiana.
func _build_home() -> void:
	_hero(Vector3(0.0, 0.93, 1.1), 225.0, "idle", 2.3)
	_warm(Vector3(-1.4, 2.6, -1.6), 3.6, Color(1.0, 0.68, 0.32), 8.0)
	_aim(Vector3(-0.2, 1.6, -0.6), 6.6)


func _build_victory() -> void:
	StageKit.place(_world, K_GRAVE + "fire-basket.glb", Vector3(-1.4, 0.93, -1.0), 0.0, 2.4)
	_warm(Vector3(-1.4, 1.4, -1.0), 5.0, Color(1.0, 0.7, 0.3), 7.0)
	_embers(Vector3(-1.4, 1.3, -1.0))
	_hero(Vector3(0.6, 0.93, 0.8), 225.0, "Cheer", 2.4)
	_aim(Vector3(0.0, 1.5, 0.0), 6.2)


func _build_defeat() -> void:
	_hero(Vector3(0.2, 0.93, 0.6), 225.0, "Death_A_Pose", 2.2)
	StageKit.place(_world, K_GRAVE + "candle.glb", Vector3(-0.6, 0.93, -0.8), 0.0, 2.0)
	_warm(Vector3(-0.6, 1.4, -0.8), 1.8, Color(0.7, 0.8, 1.0), 5.5)
	_aim(Vector3(-0.2, 1.1, -0.2), 6.0)


## Acende ou apaga a fogueira da cena (só a de `kind == "campfire"` tem peças de fogo).
func set_fire_lit(lit: bool) -> void:
	fire_lit = lit
	if kind != "campfire":
		return
	for part: Node3D in _fire_parts:
		part.visible = lit
	for part: Node3D in _cold_parts:
		part.visible = not lit
	if _fire_light != null:
		var index: int = _lights.find(_fire_light)
		if index >= 0:
			_bases[index] = FIRE_LIT_ENERGY if lit else FIRE_COLD_ENERGY
			_fire_light.light_energy = _bases[index]
			_fire_light.light_color = Color(1.0, 0.5, 0.16) if lit else Color(0.88, 0.54, 0.19)
		_fire_light.omni_range = 6.5 if lit else 2.4


func _process(delta: float) -> void:
	if time_scale <= 0.0:
		return
	_flicker_time += delta
	for i: int in _lights.size():
		var wobble: float = 1.0 + 0.14 * sin(_flicker_time * (9.0 + float(i))) + 0.08 * sin(_flicker_time * 23.0)
		_lights[i].light_energy = _bases[i] * wobble


func _add_vignette() -> void:
	var rect: ColorRect = ColorRect.new()
	rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var shader: Shader = Shader.new()
	shader.code = "shader_type canvas_item;\nvoid fragment() {\n\tvec2 uv = UV - vec2(0.5);\n\tfloat d = dot(uv, uv) * 2.4;\n\tCOLOR = vec4(0.0, 0.0, 0.02, clamp(d * d * 1.5, 0.0, 0.9));\n}\n"
	var mat: ShaderMaterial = ShaderMaterial.new()
	mat.shader = shader
	rect.material = mat
	add_child(rect)


## Chama: três quadrados que olham para a câmera, com um shader aditivo de chama que ondula.
func _flame(pos: Vector3, factor: float) -> void:
	var shader: Shader = Shader.new()
	shader.code = "shader_type spatial;\nrender_mode unshaded, blend_add, cull_disabled, depth_draw_never;\nuniform float phase = 0.0;\nvoid vertex() {\n\tMODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0], INV_VIEW_MATRIX[1], INV_VIEW_MATRIX[2], MODEL_MATRIX[3]);\n}\nvoid fragment() {\n\tvec2 uv = UV;\n\tfloat h = 1.0 - uv.y;\n\tfloat sway = sin(TIME * 7.0 + phase + h * 5.0) * 0.08 * h;\n\tfloat d = abs(uv.x - 0.5 + sway) * 2.0;\n\tfloat width = pow(clamp(uv.y, 0.0, 1.0), 0.7) * (0.85 + 0.15 * sin(TIME * 11.0 + phase));\n\tfloat mask = smoothstep(width, width - 0.35, d) * smoothstep(0.0, 0.12, h);\n\tvec3 hot = vec3(1.0, 0.85, 0.35);\n\tvec3 cool = vec3(1.0, 0.25, 0.04);\n\tALBEDO = mix(cool, hot, uv.y) * mask * 1.6;\n}\n"
	for i: int in 3:
		var quad: QuadMesh = QuadMesh.new()
		quad.size = Vector2(1.0, 1.5)
		var material: ShaderMaterial = ShaderMaterial.new()
		material.shader = shader
		material.set_shader_parameter("phase", float(i) * 2.1)
		quad.material = material
		var flame: MeshInstance3D = MeshInstance3D.new()
		flame.mesh = quad
		flame.position = pos + Vector3(0.12 * float(i - 1), 0.6, 0.1 * float(1 - i))
		flame.scale = Vector3.ONE * factor * (1.7 - 0.25 * float(i))
		flame.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		_world.add_child(flame)
		_fire_parts.append(flame)
