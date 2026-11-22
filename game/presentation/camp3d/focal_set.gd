class_name FocalSet
extends RefCounted
## Peças de cenário compartilhadas pelos dioramas focais e pelo mapa (ADR-0050, IDENTIDADE-VISUAL
## §C.3): lajes quebradas, paredes góticas do kit modular, disco de luz no chão e chama. Só
## apresentação. Toda cor de kit passa pela paleta (nunca a cor original).

const K_MOD: String = "res://assets/kenney/modular_dungeon/"
const K_GRAVE: String = "res://assets/kenney/graveyard/"
const K_MINI: String = "res://assets/kenney/mini_dungeon/"
const FLOOR_Y: float = 0.9
const TINT_WALL: Color = Color(0.5, 0.52, 0.58)
const TINT_FLOOR: Color = Color(0.36, 0.37, 0.42)
const TINT_STONE: Color = Color(0.42, 0.44, 0.52)
const TINT_WOOD: Color = Color(0.5, 0.38, 0.3)
const TINT_IRON: Color = Color(0.3, 0.31, 0.36)
const AMBER: Color = Color("E08A30")

const _GLOW_SHADER: String = "shader_type spatial;\nrender_mode unshaded, blend_add, cull_disabled, depth_draw_never;\nuniform vec4 tint : source_color = vec4(1.0, 0.5, 0.15, 1.0);\nuniform float strength = 0.4;\nvoid fragment() {\n\tfloat d = length(UV - vec2(0.5)) * 2.0;\n\tfloat a = clamp(1.0 - d, 0.0, 1.0);\n\tALBEDO = tint.rgb * a * a * strength;\n}\n"
const _FLAME_SHADER: String = "shader_type spatial;\nrender_mode unshaded, blend_add, cull_disabled, depth_draw_never;\nuniform float phase = 0.0;\nvoid vertex() {\n\tMODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0], INV_VIEW_MATRIX[1], INV_VIEW_MATRIX[2], MODEL_MATRIX[3]);\n}\nvoid fragment() {\n\tvec2 uv = UV;\n\tfloat h = 1.0 - uv.y;\n\tfloat sway = sin(TIME * 7.0 + phase + h * 5.0) * 0.1 * h;\n\tfloat d = abs(uv.x - 0.5 + sway) * 2.0;\n\tfloat width = pow(clamp(uv.y, 0.0, 1.0), 0.8) * (0.9 + 0.1 * sin(TIME * 11.0 + phase));\n\tfloat mask = smoothstep(width, width - 0.3, d) * smoothstep(0.0, 0.1, h);\n\tvec3 hot = vec3(1.0, 0.78, 0.3);\n\tvec3 cool = vec3(0.95, 0.3, 0.05);\n\tALBEDO = mix(cool, hot, uv.y * uv.y) * mask * 1.5;\n}\n"


## Piso de lajes escuras (grade `half`x`half` de blocos de 4 m) com um bloco recortado em cada canto.
static func floor_slabs(parent: Node3D, half: int = 1) -> void:
	for tz: int in range(-half, half + 1):
		for tx: int in range(-half, half + 1):
			var variant: String = "template-floor-detail.glb" if (tx + tz) % 2 == 0 else "template-floor-detail-a.glb"
			StageKit.place(parent, K_MOD + variant, Vector3(float(tx) * 4.0, FLOOR_Y - 0.2, float(tz) * 4.0), 0.0, 1.0, TINT_FLOOR)


## Parede de 4 m do kit modular em `pos`; `yaw` 0 = voltada para +Z, 90 = voltada para +X.
static func wall(parent: Node3D, pos: Vector3, yaw: float, piece: String = "template-wall.glb", tint: Color = TINT_WALL, factor: float = 1.0) -> Node3D:
	return StageKit.place(parent, K_MOD + piece, pos, yaw, factor, tint)


## Disco de luz aditivo no chão (mancha quente em volta da fonte de luz).
static func glow_disc(parent: Node3D, pos: Vector3, radius: float, color: Color, strength: float) -> MeshInstance3D:
	var quad: QuadMesh = QuadMesh.new()
	quad.size = Vector2(radius * 2.0, radius * 2.0)
	var mat: ShaderMaterial = ShaderMaterial.new()
	var shader: Shader = Shader.new()
	shader.code = _GLOW_SHADER
	mat.shader = shader
	mat.set_shader_parameter("tint", color)
	mat.set_shader_parameter("strength", strength)
	quad.material = mat
	var disc: MeshInstance3D = MeshInstance3D.new()
	disc.mesh = quad
	disc.rotation_degrees = Vector3(-90, 0, 0)
	disc.position = pos + Vector3(0, 0.03, 0)
	disc.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(disc)
	return disc


## Chama de três línguas (quadrados que olham para a câmera) de altura `height` com os pés em `pos`.
## Devolve os nós para o chamador ligar e desligar.
static func flame(parent: Node3D, pos: Vector3, height: float) -> Array[Node3D]:
	var shader: Shader = Shader.new()
	shader.code = _FLAME_SHADER
	var parts: Array[Node3D] = []
	var heights: Array[float] = [1.0, 0.72, 0.52]
	var offsets: Array[Vector2] = [Vector2(0.0, 0.0), Vector2(0.16, -0.08), Vector2(-0.14, 0.1)]
	for i: int in 3:
		var quad: QuadMesh = QuadMesh.new()
		var h: float = height * heights[i]
		quad.size = Vector2(h * 0.62, h)
		quad.center_offset = Vector3(0, h * 0.5, 0)
		var material: ShaderMaterial = ShaderMaterial.new()
		material.shader = shader
		material.set_shader_parameter("phase", float(i) * 2.1)
		quad.material = material
		var tongue: MeshInstance3D = MeshInstance3D.new()
		tongue.mesh = quad
		tongue.position = pos + Vector3(offsets[i].x, 0, offsets[i].y)
		tongue.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		parent.add_child(tongue)
		parts.append(tongue)
	return parts


## Faíscas subindo (cada uma um cubo pequeno e aceso).
static func sparks(parent: Node3D, pos: Vector3, amount: int = 22, color: Color = Color(1.0, 0.55, 0.15)) -> CPUParticles3D:
	var particles: CPUParticles3D = CPUParticles3D.new()
	var spark: BoxMesh = BoxMesh.new()
	spark.size = Vector3(0.06, 0.06, 0.06)
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color
	spark.material = material
	particles.mesh = spark
	particles.amount = amount
	particles.lifetime = 2.4
	particles.direction = Vector3(0, 1, 0)
	particles.spread = 22.0
	particles.initial_velocity_min = 0.6
	particles.initial_velocity_max = 1.5
	particles.gravity = Vector3(0, 0.15, 0)
	particles.emission_shape = CPUParticles3D.EMISSION_SHAPE_SPHERE
	particles.emission_sphere_radius = 0.22
	particles.position = pos
	parent.add_child(particles)
	return particles


## Peça inclinada (lenha, cruz caída): `lean` em graus em torno de X e Z depois do giro `yaw`.
static func tilted(parent: Node3D, path: String, pos: Vector3, yaw: float, lean: Vector3, factor: float, tint: Color) -> Node3D:
	var node: Node3D = StageKit.place(parent, path, pos, yaw, factor, tint)
	node.rotation_degrees = Vector3(lean.x, yaw, lean.z)
	return node


## Mancha escura no piso (poça, cinza, sangue seco): quadrado achatado de cor `color`.
static func stain(parent: Node3D, pos: Vector3, size: Vector2, color: Color, rough: float = 0.9, metal: float = 0.0, yaw: float = 0.0) -> void:
	var quad: QuadMesh = QuadMesh.new()
	quad.size = size
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = rough
	mat.metallic = metal
	quad.material = mat
	var patch: MeshInstance3D = MeshInstance3D.new()
	patch.mesh = quad
	patch.rotation_degrees = Vector3(-90, yaw, 0)
	patch.position = pos + Vector3(0, 0.025, 0)
	patch.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(patch)


## Caixa pintada (tábua, poste, olho aceso) como filha de `parent`. `glow` liga o material sem luz.
static func box(parent: Node3D, pos: Vector3, size: Vector3, color: Color, rot: Vector3 = Vector3.ZERO, glow: bool = false) -> MeshInstance3D:
	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = size
	mesh.material = _paint(color, glow)
	var item: MeshInstance3D = MeshInstance3D.new()
	item.mesh = mesh
	item.position = pos
	item.rotation_degrees = rot
	parent.add_child(item)
	return item


static func _paint(color: Color, glow: bool) -> StandardMaterial3D:
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 1.0
	if glow:
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	return mat


## Vulto encapuzado e curvado (capuz Lama, rosto vazio, olhos âmbar, mãos longas) de ~`height` m,
## com os pés em `pos`, de frente para `yaw`. Feito de primitivas grossas.
static func hooded_figure(parent: Node3D, pos: Vector3, yaw: float, height: float = 2.0) -> Node3D:
	var root: Node3D = Node3D.new()
	root.position = pos
	root.rotation_degrees = Vector3(0, yaw, 0)
	parent.add_child(root)
	var body: Node3D = Node3D.new()
	body.scale = Vector3.ONE * (height / 2.0)
	body.rotation_degrees = Vector3(13, 0, 0)
	root.add_child(body)
	var cloth: Color = Color(0.227, 0.192, 0.157)
	var cloak: CylinderMesh = CylinderMesh.new()
	cloak.top_radius = 0.2
	cloak.bottom_radius = 0.52
	cloak.height = 1.5
	cloak.radial_segments = 8
	cloak.material = _paint(cloth, false)
	var cloak_node: MeshInstance3D = MeshInstance3D.new()
	cloak_node.mesh = cloak
	cloak_node.position = Vector3(0, 0.75, 0)
	body.add_child(cloak_node)
	var hump: SphereMesh = SphereMesh.new()
	hump.radius = 0.34
	hump.height = 0.6
	hump.radial_segments = 8
	hump.rings = 4
	hump.material = _paint(cloth.lightened(0.05), false)
	var hump_node: MeshInstance3D = MeshInstance3D.new()
	hump_node.mesh = hump
	hump_node.position = Vector3(0, 1.42, -0.06)
	body.add_child(hump_node)
	var hood: SphereMesh = SphereMesh.new()
	hood.radius = 0.27
	hood.height = 0.62
	hood.radial_segments = 8
	hood.rings = 4
	hood.material = _paint(cloth.lightened(0.08), false)
	var hood_node: MeshInstance3D = MeshInstance3D.new()
	hood_node.mesh = hood
	hood_node.position = Vector3(0, 1.74, 0.1)
	body.add_child(hood_node)
	var hollow: SphereMesh = SphereMesh.new()
	hollow.radius = 0.17
	hollow.height = 0.3
	hollow.radial_segments = 8
	hollow.rings = 4
	hollow.material = _paint(Color(0.01, 0.01, 0.015), false)
	var hollow_node: MeshInstance3D = MeshInstance3D.new()
	hollow_node.mesh = hollow
	hollow_node.position = Vector3(0, 1.7, 0.27)
	body.add_child(hollow_node)
	box(body, Vector3(0.05, 1.73, 0.4), Vector3(0.07, 0.05, 0.04), AMBER, Vector3.ZERO, true)
	for side: float in [-1.0, 1.0]:
		var arm: Node3D = Node3D.new()
		arm.position = Vector3(side * 0.34, 1.3, 0.05)
		arm.rotation_degrees = Vector3(-62, 0, side * -6)
		body.add_child(arm)
		box(arm, Vector3(0, 0, 0.42), Vector3(0.15, 0.15, 0.84), cloth, Vector3.ZERO)
		box(arm, Vector3(0, -0.02, 0.9), Vector3(0.11, 0.06, 0.3), Color(0.42, 0.4, 0.38), Vector3.ZERO)
	return root


const K_SCENERY: String = "res://assets/bibiana/scenery/"
const STONE_TINT: Color = Color(0.4, 0.42, 0.48)
const STONE_DARK: Color = Color(0.24, 0.26, 0.31)
const MUD: Color = Color(0.227, 0.192, 0.157)
const STEEL: Color = Color("7E8FA8")


## Canto de nave gótica arruinada: arcada ogival no fundo, arco alto na lateral, contrafortes e
## agulhas que sobem para fora do quadro. Tudo da malha própria (tools/blender/make_scenery.py)
## tingida pela paleta. `x0` desloca a composição (o arco principal fica atrás do assunto).
static func gothic_nave(parent: Node3D, y: float, lit_arch: bool = false) -> void:
	var back: Array[Vector3] = [Vector3(-3.4, y, -3.4), Vector3(4.4, y, -3.4)]
	for pos: Vector3 in back:
		var arcade: Node3D = StageKit.place(parent, K_SCENERY + "ogive_arcade.glb", pos, 0.0, 1.0, STONE_TINT)
		arcade.scale = Vector3(1.0, 1.35, 1.0)
	var left: Node3D = StageKit.place(parent, K_SCENERY + "ogive_arch.glb", Vector3(-4.6, y, -0.6), 90.0, 1.0, STONE_TINT)
	left.scale = Vector3(1.0, 1.5, 1.0)
	var wall: Node3D = StageKit.place(parent, K_SCENERY + "ogive_wall.glb", Vector3(-4.6, y, 3.4), 90.0, 1.0, STONE_DARK)
	wall.scale = Vector3(1.0, 1.7, 1.0)
	for pos: Vector3 in [Vector3(-4.6, y, -3.6), Vector3(0.6, y, -3.6), Vector3(8.0, y, -3.6)]:
		var bt: Node3D = StageKit.place(parent, K_SCENERY + "buttress.glb", pos, 0.0, 1.0, STONE_TINT)
		bt.scale = Vector3(1.0, 1.3, 1.0)
	# agulhas distantes: sobem para o nevoeiro, no escuro
	for pos: Vector3 in [Vector3(-2.0, y, -6.4), Vector3(3.6, y, -6.8), Vector3(-6.4, y, -4.6)]:
		var sp: Node3D = StageKit.place(parent, K_SCENERY + "spire.glb", pos, 0.0, 1.0, STONE_DARK)
		sp.scale = Vector3(1.2, 1.6, 1.2)


## Primeiro plano escuro no canto inferior direito da câmera: grade e cruz quebrada, quase preto.
static func foreground(parent: Node3D, y: float, at: Vector3) -> void:
	var dark: Color = Color(0.045, 0.05, 0.06)
	for i: int in 3:
		StageKit.place(parent, K_GRAVE + "iron-fence-damaged.glb", at + Vector3(float(i) * 0.9, 0.0, -float(i) * 0.9), 45.0, 2.6, dark)
	tilted(parent, K_GRAVE + "cross.glb", at + Vector3(-0.2, 0.0, 1.6), 30.0, Vector3(0, 0, 14), 2.4, dark)
