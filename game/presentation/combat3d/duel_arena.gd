class_name DuelArena
extends RefCounted
## Arena do duelo (ADR-0050, IDENTIDADE-VISUAL §C.1): um canto de nave gótica arruinada atrás do
## inimigo, feito com as peças modulares do Kenney (paredes de 4 m de altura e arco), piso escuro
## com poças, um prop narrativo por tipo de luta e um portão com brilho âmbar ao fundo (a
## promessa de luz). Composição fixa por tipo: nada de espalhar peças ao acaso. Só apresentação.

const K_MOD: String = "res://assets/kenney/modular_dungeon/"
const K_GRAVE: String = "res://assets/kenney/graveyard/"
const FLOOR_Y: float = 0.9
## Cores de kit multiplicadas pela paleta da IDENTIDADE-VISUAL §B.1 (nunca a cor original).
const TINT_WALL: Color = Color(0.62, 0.65, 0.78)
const TINT_FLOOR: Color = Color(0.36, 0.37, 0.42)
const TINT_DARK_STONE: Color = Color(0.3, 0.32, 0.37)
const TINT_WOOD: Color = Color(0.227, 0.192, 0.157)
const TINT_IRON: Color = Color(0.34, 0.35, 0.40)
const AMBER: Color = Color("E08A30")


## Monta a arena de `kind` ("combat_common", "combat_elite" ou "combat_boss") sob `parent`.
static func build(parent: Node3D, kind: String) -> void:
	build_base(parent, kind)
	match kind:
		"combat_boss":
			_boss_props(parent)
		"combat_elite":
			_elite_props(parent)
		_:
			_common_props(parent)
	_foreground(parent)


## Só o palco (piso, canto de paredes com portão, poças): base comum dos dioramas de fogueira e loja.
static func build_base(parent: Node3D, kind: String = "") -> void:
	_floor(parent)
	_back_walls(parent, kind)
	_puddles(parent)


static func _floor(parent: Node3D) -> void:
	for tz: int in range(-1, 2):
		for tx: int in range(-1, 2):
			var variant: String = "template-floor-detail.glb" if (tx + tz) % 2 == 0 else "template-floor-detail-a.glb"
			StageKit.place(parent, K_MOD + variant, Vector3(float(tx) * 4.0, FLOOR_Y - 0.2, float(tz) * 4.0), 0.0, 1.0, TINT_FLOOR)


## Duas paredes altas em canto atrás do inimigo (a câmera olha de +X,+Z), uma com o portão.
static func _back_walls(parent: Node3D, kind: String) -> void:
	FocalSet.gothic_nave(parent, FLOOR_Y)
	if kind == "combat_boss":
		# Vitral de catedral atrás da arcada: promessa de luz, a 25% (não é uma segunda fonte).
		FocalSet.box(parent, Vector3(-1.2, FLOOR_Y + 2.7, -4.3), Vector3(1.3, 3.4, 0.05), Color(0.62, 0.34, 0.1), Vector3.ZERO, true)
		for i: int in 3:
			FocalSet.box(parent, Vector3(-1.2 + (float(i) - 1.0) * 0.4, FLOOR_Y + 2.7, -4.25), Vector3(0.07, 3.4, 0.06), Color(0.03, 0.03, 0.04))
		FocalSet.box(parent, Vector3(-1.2, FLOOR_Y + 3.4, -4.25), Vector3(1.3, 0.07, 0.06), Color(0.03, 0.03, 0.04))


static func _puddles(parent: Node3D) -> void:
	var spots: Array[Vector3] = [Vector3(0.2, 0.0, 0.4), Vector3(-1.7, 0.0, 1.1), Vector3(1.6, 0.0, -0.6)]
	var sizes: Array[Vector2] = [Vector2(1.4, 0.9), Vector2(0.9, 0.6), Vector2(0.8, 0.5)]
	for i: int in spots.size():
		var quad: QuadMesh = QuadMesh.new()
		quad.size = sizes[i]
		var mat: StandardMaterial3D = StandardMaterial3D.new()
		mat.albedo_color = Color(0.02, 0.03, 0.045)
		mat.metallic = 0.9
		mat.roughness = 0.08
		quad.material = mat
		var puddle: MeshInstance3D = MeshInstance3D.new()
		puddle.mesh = quad
		puddle.rotation_degrees = Vector3(-90, 20.0 * float(i), 0)
		puddle.position = Vector3(spots[i].x, FLOOR_Y + 0.012, spots[i].z)
		puddle.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		parent.add_child(puddle)


static func _common_props(parent: Node3D) -> void:
	StageKit.place(parent, K_GRAVE + "coffin-old.glb", Vector3(-2.6, FLOOR_Y, -1.6), 35.0, 2.6, TINT_WOOD)
	StageKit.place(parent, K_GRAVE + "debris.glb", Vector3(-1.9, FLOOR_Y, -2.3), 80.0, 2.4, TINT_DARK_STONE)
	StageKit.place(parent, K_GRAVE + "lightpost-single.glb", Vector3(0.8, FLOOR_Y, -2.4), 180.0, 2.4, TINT_IRON)
	_lantern_light(parent, Vector3(0.7, FLOOR_Y + 2.7, -2.2))


static func _elite_props(parent: Node3D) -> void:
	for x: float in [-2.6, 1.4]:
		StageKit.place(parent, K_GRAVE + "column-large.glb", Vector3(x, FLOOR_Y, -2.9), 0.0, 3.4, TINT_DARK_STONE)
	StageKit.place(parent, K_GRAVE + "gravestone-cross-large.glb", Vector3(-2.7, FLOOR_Y, 0.4), 20.0, 2.6, TINT_DARK_STONE)
	StageKit.place(parent, K_GRAVE + "debris.glb", Vector3(1.9, FLOOR_Y, -1.6), 10.0, 2.4, TINT_DARK_STONE)
	StageKit.place(parent, K_GRAVE + "lightpost-single.glb", Vector3(-1.4, FLOOR_Y, -3.0), 0.0, 2.6, TINT_IRON)
	_lantern_light(parent, Vector3(-1.2, FLOOR_Y + 2.9, -2.8))


static func _boss_props(parent: Node3D) -> void:
	for x: float in [-2.8, 1.8]:
		StageKit.place(parent, K_GRAVE + "column-large.glb", Vector3(x, FLOOR_Y, -3.0), 0.0, 3.8, TINT_DARK_STONE)
	StageKit.place(parent, K_GRAVE + "altar-stone.glb", Vector3(-0.9, FLOOR_Y, -3.0), 0.0, 3.0, TINT_DARK_STONE)
	StageKit.place(parent, K_GRAVE + "coffin.glb", Vector3(-2.9, FLOOR_Y, -0.6), 70.0, 2.8, TINT_WOOD)
	StageKit.place(parent, K_GRAVE + "shovel-dirt.glb", Vector3(1.7, FLOOR_Y, -1.5), 30.0, 3.0, TINT_WOOD)
	StageKit.place(parent, K_GRAVE + "fire-basket.glb", Vector3(1.2, FLOOR_Y, -2.7), 0.0, 3.0, Color(0.12, 0.12, 0.14))
	_lantern_light(parent, Vector3(1.2, FLOOR_Y + 1.2, -2.6))


## Primeiro plano escuro e fora de foco (camada 1 do IDENTIDADE-VISUAL §C.1): grade de ferro baixa
## no canto da câmera.
static func _foreground(parent: Node3D) -> void:
	for i: int in 3:
		StageKit.place(parent, K_GRAVE + "iron-fence-damaged.glb", Vector3(3.4 + float(i) * 1.1, FLOOR_Y, 2.6 - float(i) * 1.1), 45.0, 2.4, Color(0.04, 0.045, 0.055))


## A luz âmbar única do diorama: um lampião de ferro aceso ao lado do inimigo.
static func _lantern_light(parent: Node3D, pos: Vector3) -> void:
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = AMBER
	light.light_energy = 2.6
	light.omni_range = 4.2
	light.position = pos
	parent.add_child(light)
