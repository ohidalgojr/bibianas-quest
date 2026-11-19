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
	add_child(weather)
	_add_vignette()


func _build_environment() -> void:
	var cold: bool = kind == "defeat"
	var env: Environment = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.02, 0.022, 0.035)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.24, 0.3, 0.45) if cold else Color(0.28, 0.32, 0.44)
	env.ambient_light_energy = 1.0
	env.adjustment_enabled = true
	env.adjustment_saturation = 0.58
	env.adjustment_contrast = 1.18
	env.adjustment_brightness = 0.9
	env.glow_enabled = true
	env.glow_intensity = 0.65
	env.glow_bloom = 0.1
	var holder: WorldEnvironment = WorldEnvironment.new()
	holder.environment = env
	_world.add_child(holder)
	var moon: DirectionalLight3D = DirectionalLight3D.new()
	moon.light_color = Color(0.55, 0.64, 0.92)
	moon.light_energy = 0.8
	moon.rotation_degrees = Vector3(-50, 30, 0)
	moon.shadow_enabled = true
	_world.add_child(moon)


func _aim(target: Vector3, size: float) -> void:
	_camera.size = size * (2.1 if kind == "shop" else (1.9 if kind == "home" else 1.5))
	# O assunto fica na metade de cima da tela (o painel ocupa a de baixo): mira abaixo dele.
	target += Vector3(1.0, 0.0, 1.0) * 2.4
	_camera.position = target + Vector3(1.0, 0.8, 1.0) * 16.0
	_camera.look_at(target)


func _build_scene() -> void:
	_floor(4)
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


func _floor(half: int) -> void:
	var blocks: Array[Transform3D] = []
	var tiles: Array[Transform3D] = []
	for z: int in range(-half - 2, half + 3):
		for x: int in range(-half - 2, half + 3):
			blocks.append(Transform3D(Basis.IDENTITY, Vector3(x, 0.0, z)))
			if absi(x) <= half and absi(z) <= half:
				tiles.append(Transform3D(Basis.IDENTITY, Vector3(x, 0.93, z)))
	StageKit.multimesh_from(_world, K_MINI + "dirt.glb", blocks)
	StageKit.multimesh_from(_world, K_MINI + "floor-detail.glb", tiles, Color(0.55, 0.53, 0.6))


func _walls(boundary: int, tall: bool = false) -> void:
	for i: int in range(-boundary, boundary + 1):
		StageKit.place(_world, K_GRAVE + ("brick-wall.glb" if tall else "stone-wall.glb"), Vector3(i, 0.9, -boundary), 0.0, 1.5 if tall else 1.2)
		StageKit.place(_world, K_GRAVE + ("brick-wall.glb" if tall else "stone-wall.glb"), Vector3(-boundary, 0.9, i), 90.0, 1.5 if tall else 1.2)


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


## Fogueira (referência Darkest Dungeon): a Bibiana sentada junto ao fogo, luz quente oscilando.
func _build_campfire() -> void:
	_walls(5, true)
	var center: Vector3 = Vector3(0, 0.93, 0)
	StageKit.place(_world, K_GRAVE + "fire-basket.glb", center, 0.0, 3.0)
	_warm(Vector3(0, 1.5, 0), 6.5, Color(1.0, 0.45, 0.15), 8.0)
	_embers(Vector3(0, 1.3, 0))
	_flame(Vector3(0, 1.0, 0), 1.0)
	_hero(Vector3(0.1, 0.93, 2.0), 180.0, "Sit_Floor_Idle", 2.0)
	StageKit.place(_world, K_GRAVE + "gravestone-cross.glb", Vector3(-2.5, 0.93, -2.0), 0.0, 1.6)
	StageKit.place(_world, K_GRAVE + "crypt-small.glb", Vector3(-3.4, 0.9, 0.5), 90.0, 1.4)
	StageKit.place(_world, K_GRAVE + "pine-crooked.glb", Vector3(2.8, 0.93, -2.6), 0.0, 1.6)
	StageKit.place(_world, K_GRAVE + "coffin-old.glb", Vector3(-1.2, 0.93, 2.8), 40.0, 1.4)
	_aim(Vector3(0.3, 1.3, 0.3), 6.2)


## Loja: o comerciante atrás de uma mesa de mercadorias, sob um lampião.
func _build_shop() -> void:
	_walls(5)
	StageKit.place(_world, K_MINI + "table.glb", Vector3(-1.0, 0.93, -1.0), 45.0, 2.4)
	var merchant: Node3D = ModelRegistry.spawn("gravedigger")
	merchant.position = Vector3(-2.2, 0.93, -2.2)
	merchant.rotation_degrees.y = 45.0
	merchant.scale = Vector3.ONE * 2.0
	_world.add_child(merchant)
	ModelRegistry.play(merchant, "gravedigger", "idle")
	StageKit.place(_world, K_MINI + "potion.glb", Vector3(-0.6, 1.5, -1.3), 0.0, 2.4)
	StageKit.place(_world, K_MINI + "shield-round.glb", Vector3(-1.4, 1.5, -0.7), 30.0, 2.0)
	StageKit.place(_world, K_MINI + "barrel.glb", Vector3(-3.2, 0.93, 0.2), 0.0, 2.2)
	StageKit.place(_world, K_MINI + "chest.glb", Vector3(-3.0, 0.93, -2.8), 20.0, 2.2)
	StageKit.place(_world, K_GRAVE + "lightpost-double.glb", Vector3(1.2, 0.93, -2.6), 0.0, 2.4)
	_warm(Vector3(0.0, 2.2, -1.2), 3.8, Color(1.0, 0.7, 0.35), 7.0)
	_hero(Vector3(1.4, 0.93, 1.4), 225.0)
	_aim(Vector3(-0.2, 1.6, -0.2), 6.4)


## Baú: grande, no centro, abrindo, com luz dourada.
func _build_chest() -> void:
	_walls(5)
	var chest: Node3D = StageKit.place(_world, K_MINI + "chest.glb", Vector3(0, 0.93, 0), 45.0, 4.0)
	_play_named(chest, "open", false)
	_warm(Vector3(0, 1.8, 0), 5.0, Color(1.0, 0.8, 0.3), 6.5)
	for i: int in 5:
		var angle: float = float(i) * 1.26
		StageKit.place(_world, K_MINI + "coin.glb", Vector3(cos(angle) * 1.3, 0.95, sin(angle) * 1.3), angle * 40.0, 1.6)
	StageKit.place(_world, K_GRAVE + "candle-multiple.glb", Vector3(-2.2, 0.93, 1.6), 0.0, 2.0)
	_hero(Vector3(1.8, 0.93, 1.8), 225.0, "Interact")
	_aim(Vector3(0.3, 1.2, 0.3), 6.0)


## Evento: um altar de pedra à luz de velas.
func _build_event() -> void:
	_walls(5, true)
	StageKit.place(_world, K_GRAVE + "altar-stone.glb", Vector3(-0.5, 0.93, -0.5), 45.0, 3.0)
	StageKit.place(_world, K_GRAVE + "candle-multiple.glb", Vector3(-0.1, 2.0, -0.9), 0.0, 2.0)
	StageKit.place(_world, K_GRAVE + "cross.glb", Vector3(-2.6, 0.93, -2.2), 0.0, 2.0)
	StageKit.place(_world, K_GRAVE + "pillar-obelisk.glb", Vector3(2.4, 0.93, -2.6), 0.0, 1.8)
	_warm(Vector3(-0.3, 2.2, -0.7), 3.6, Color(1.0, 0.6, 0.3), 6.0)
	_hero(Vector3(1.7, 0.93, 1.7), 225.0)
	_aim(Vector3(0.0, 1.3, 0.0), 6.2)


## Recompensa depois da luta: a Bibiana de pé, com o butim a seus pés.
func _build_reward() -> void:
	_walls(5)
	_hero(Vector3(0.5, 0.93, 0.5), 225.0, "Cheer", 2.2)
	StageKit.place(_world, K_MINI + "coin.glb", Vector3(-0.8, 0.95, 0.8), 20.0, 1.8)
	StageKit.place(_world, K_MINI + "potion.glb", Vector3(1.4, 0.95, -0.4), 0.0, 2.0)
	StageKit.place(_world, K_GRAVE + "lightpost-single.glb", Vector3(-2.8, 0.93, -2.0), 0.0, 2.4)
	_warm(Vector3(0.0, 2.2, 0.2), 3.6, Color(1.0, 0.75, 0.35), 6.0)
	_aim(Vector3(0.2, 1.3, 0.2), 6.0)


## Menu inicial: panorama da Cidade Abandonada com a Bibiana em destaque.
func _build_home() -> void:
	_walls(6)
	_hero(Vector3(0.0, 0.93, 0.6), 225.0, "idle", 2.4)
	StageKit.place(_world, K_GRAVE + "lightpost-double.glb", Vector3(-2.4, 0.93, -0.8), 0.0, 2.6)
	StageKit.place(_world, K_GRAVE + "crypt-large.glb", Vector3(-3.4, 0.9, -3.8), 45.0, 1.6)
	StageKit.place(_world, K_GRAVE + "pine-crooked.glb", Vector3(3.2, 0.93, -2.4), 0.0, 1.8)
	StageKit.place(_world, K_GRAVE + "gravestone-round.glb", Vector3(2.4, 0.93, 1.0), 0.0, 1.6)
	StageKit.place(_world, K_GRAVE + "iron-fence-damaged.glb", Vector3(-3.2, 0.93, 2.0), 90.0, 1.4)
	_warm(Vector3(-1.8, 2.4, -0.4), 3.4, Color(1.0, 0.68, 0.32), 7.0)
	_aim(Vector3(0.0, 1.5, -0.2), 6.6)


func _build_victory() -> void:
	_walls(5)
	StageKit.place(_world, K_GRAVE + "fire-basket.glb", Vector3(-1.6, 0.93, -1.2), 0.0, 2.4)
	_warm(Vector3(-1.6, 1.4, -1.2), 5.0, Color(1.0, 0.7, 0.3), 7.0)
	_embers(Vector3(-1.6, 1.3, -1.2))
	_hero(Vector3(0.6, 0.93, 0.8), 225.0, "Cheer", 2.4)
	_aim(Vector3(0.0, 1.5, 0.0), 6.2)


func _build_defeat() -> void:
	_walls(5, true)
	_hero(Vector3(0.2, 0.93, 0.4), 225.0, "Death_A_Pose", 2.2)
	StageKit.place(_world, K_GRAVE + "gravestone-cross-large.glb", Vector3(-1.4, 0.93, -1.4), 0.0, 2.0)
	StageKit.place(_world, K_GRAVE + "candle.glb", Vector3(-0.4, 0.93, -0.9), 0.0, 2.0)
	_warm(Vector3(-0.6, 1.4, -0.9), 1.6, Color(0.7, 0.8, 1.0), 5.0)
	_aim(Vector3(0.0, 1.0, 0.0), 6.0)


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
