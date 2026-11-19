class_name ProofScene
extends Control
## Cena de prova da TASK-035: terreno em blocos com altura, escada, luz quente e fria, vinheta,
## a Bibiana e um inimigo, vistos por câmera ortográfica isométrica em baixa resolução interna
## (GDD §17, §18; docs/ART-DIRECTION.md). Não tem regra de jogo: é só composição.

const K_MINI: String = "res://assets/kenney/mini_dungeon/"
const K_GRAVE: String = "res://assets/kenney/graveyard/"
## Resolução interna em retrato (metade de 540x960, ampliada em múltiplos inteiros).
const INTERNAL_SIZE: Vector2i = Vector2i(270, 480)
const BLOCK_H: float = 0.9

var _viewport: SubViewport
var _camera: Camera3D
var _world: Node3D


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var container: SubViewportContainer = SubViewportContainer.new()
	container.stretch = true
	container.stretch_shrink = 2
	container.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	container.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(container)
	_viewport = SubViewport.new()
	_viewport.size = INTERNAL_SIZE
	_viewport.msaa_3d = Viewport.MSAA_DISABLED
	container.add_child(_viewport)
	_world = Node3D.new()
	_viewport.add_child(_world)
	_build_environment()
	_build_camera()
	_build_terrain()
	_build_actors()
	_add_vignette()


func _build_environment() -> void:
	var env: Environment = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.05, 0.06, 0.09)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.36, 0.42, 0.55)
	env.ambient_light_energy = 1.4
	var we: WorldEnvironment = WorldEnvironment.new()
	we.environment = env
	_world.add_child(we)
	# Luz fria de cima (lua); a quente (fogo) vem do cesto de brasas, como pede o GDD §18.
	var moon: DirectionalLight3D = DirectionalLight3D.new()
	moon.light_color = Color(0.62, 0.7, 0.95)
	moon.light_energy = 1.2
	moon.rotation_degrees = Vector3(-55, 35, 0)
	moon.shadow_enabled = true
	_world.add_child(moon)


func _build_camera() -> void:
	_camera = Camera3D.new()
	_camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	_camera.size = 8.5
	_camera.near = 0.1
	_camera.far = 60.0
	_world.add_child(_camera)
	var target: Vector3 = Vector3(2.0, 1.6, 2.0)
	_camera.position = target + Vector3(1.0, 0.82, 1.0) * 14.0
	_camera.look_at(target)


func _place(path: String, pos: Vector3, yaw: float = 0.0, factor: float = 1.0) -> Node3D:
	var packed: PackedScene = load(path) as PackedScene
	var node: Node3D = packed.instantiate() as Node3D
	node.position = pos
	node.rotation_degrees.y = yaw
	node.scale = Vector3.ONE * factor
	_world.add_child(node)
	return node


## Terreno 5x5 com alturas 0, 1 e 2 (blocos "dirt" do Mini Dungeon) e uma escada.
func _build_terrain() -> void:
	var heights: Array[Array] = [
		[2, 2, 1, 1, 0],
		[2, 2, 1, 0, 0],
		[1, 1, 1, 0, 0],
		[1, 0, 0, 0, 0],
		[0, 0, 0, 0, 0],
	]
	for z: int in 5:
		for x: int in 5:
			var h: int = int((heights[z] as Array)[x])
			for level: int in h + 1:
				_place(K_MINI + "dirt.glb", Vector3(x, level * BLOCK_H, z))
			if (x + z) % 3 == 0:
				_place(K_MINI + "floor-detail.glb", Vector3(x, (h + 1) * BLOCK_H, z))
	# Props do cenário 1 (Graveyard Kit).
	_place(K_GRAVE + "lightpost-single.glb", Vector3(0.0, 3 * BLOCK_H, 0.0), 0.0, 1.4)
	_place(K_GRAVE + "fire-basket.glb", Vector3(3.0, 1 * BLOCK_H, 1.0), 0.0, 1.6)
	_place(K_GRAVE + "gravestone-cross.glb", Vector3(1.0, 3 * BLOCK_H, 0.0), 0.0, 1.2)
	_place(K_GRAVE + "crypt-small.glb", Vector3(4.0, 1 * BLOCK_H, 0.6), 270.0, 1.0)
	_place(K_MINI + "chest.glb", Vector3(3.0, 1 * BLOCK_H, 3.0), 200.0, 1.4)
	var fire: OmniLight3D = OmniLight3D.new()
	fire.light_color = Color(1.0, 0.55, 0.2)
	fire.light_energy = 3.0
	fire.omni_range = 4.5
	fire.position = Vector3(3.0, 2.0, 1.0)
	_world.add_child(fire)


func _build_actors() -> void:
	var hero: Node3D = ModelRegistry.spawn("bibiana")
	hero.position = Vector3(1.0, 3 * BLOCK_H, 1.0)
	hero.rotation_degrees.y = 135.0
	_world.add_child(hero)
	ModelRegistry.play(hero, "bibiana", "idle")
	var foe: Node3D = ModelRegistry.spawn("infected_citizen")
	foe.position = Vector3(2.0, 2 * BLOCK_H, 2.0)
	foe.rotation_degrees.y = -45.0
	foe.scale = Vector3.ONE * 1.4
	_world.add_child(foe)
	ModelRegistry.play(foe, "infected_citizen", "idle")


## Vinheta escura nas bordas (GDD §18).
func _add_vignette() -> void:
	var rect: ColorRect = ColorRect.new()
	rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var shader: Shader = Shader.new()
	shader.code = "shader_type canvas_item;\nvoid fragment() {\n\tvec2 uv = UV - vec2(0.5);\n\tfloat d = dot(uv, uv) * 2.2;\n\tCOLOR = vec4(0.0, 0.0, 0.02, clamp(d * d * 1.4, 0.0, 0.85));\n}\n"
	var mat: ShaderMaterial = ShaderMaterial.new()
	mat.shader = shader
	rect.material = mat
	add_child(rect)
