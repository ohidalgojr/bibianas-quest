class_name StageKit
extends RefCounted
## Utilidades de cena 3D com os kits CC0 (TASK-035 a 037): posicionar peças e juntar muitas
## cópias da mesma peça numa única `MultiMesh` (uma chamada de desenho). Usadas pelo tabuleiro
## do mapa e pelo palco do combate.


## Instancia o modelo `path` em `parent`. Quando `tint != Color.WHITE`, tinge todas as
## superfícies sem alterar o recurso original em disco.
static func place(parent: Node3D, path: String, pos: Vector3, yaw: float = 0.0, factor: float = 1.0, tint: Color = Color.WHITE) -> Node3D:
	var node: Node3D = (load(path) as PackedScene).instantiate() as Node3D
	node.position = pos
	node.rotation_degrees.y = yaw
	node.scale = Vector3.ONE * factor
	if tint != Color.WHITE:
		apply_tint(node, tint)
	parent.add_child(node)
	return node


## Aplica multiplicação de cor em todos os [StandardMaterial3D] de `root` sem mutar o recurso base.
static func apply_tint(root: Node, tint: Color) -> void:
	if tint == Color.WHITE or root == null:
		return
	var targets: Array[Node] = []
	if root is MeshInstance3D:
		targets.append(root)
	targets.append_array(root.find_children("*", "MeshInstance3D", true, false))
	for item: Node in targets:
		var mesh_inst: MeshInstance3D = item as MeshInstance3D
		if mesh_inst == null or mesh_inst.mesh == null:
			continue
		for s: int in mesh_inst.mesh.get_surface_count():
			var base: Material = mesh_inst.get_active_material(s)
			if base is StandardMaterial3D:
				var tinted: StandardMaterial3D = (base as StandardMaterial3D).duplicate() as StandardMaterial3D
				tinted.albedo_color = tinted.albedo_color * tint
				mesh_inst.set_surface_override_material(s, tinted)


## Junta todas as cópias de `path` (uma por transformação) numa `MultiMesh`. `tint` escurece todas
## as superfícies da peça (cor multiplicada), para lajes e estradas não brilharem.
## Se [param texture] vier, a malha ganha um material de pedra pintada em triplanar de mundo (sem UV),
## multiplicado por [param tint]; [param tex_scale] é quantas repetições por unidade de mundo.
static func multimesh_from(parent: Node3D, path: String, transforms: Array[Transform3D], tint: Color = Color.WHITE, texture: Texture2D = null, tex_scale: float = 0.3) -> void:
	if transforms.is_empty():
		return
	var source: Node = (load(path) as PackedScene).instantiate()
	var mesh_node: MeshInstance3D = source.find_children("*", "MeshInstance3D", true, false)[0] as MeshInstance3D
	var multi: MultiMesh = MultiMesh.new()
	multi.transform_format = MultiMesh.TRANSFORM_3D
	var mesh: Mesh = mesh_node.mesh
	if texture != null:
		mesh = mesh.duplicate() as Mesh
		var stone: StandardMaterial3D = StandardMaterial3D.new()
		stone.albedo_texture = texture
		stone.albedo_color = tint
		stone.uv1_triplanar = true
		stone.uv1_world_triplanar = true
		stone.uv1_scale = Vector3.ONE * tex_scale
		stone.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
		stone.roughness = 0.95
		stone.metallic_specular = 0.2
		for s: int in mesh.get_surface_count():
			mesh.surface_set_material(s, stone)
	elif tint != Color.WHITE:
		mesh = mesh.duplicate() as Mesh
		for s: int in mesh.get_surface_count():
			var base: Material = mesh.surface_get_material(s)
			if base is StandardMaterial3D:
				var dark: StandardMaterial3D = (base as StandardMaterial3D).duplicate() as StandardMaterial3D
				dark.albedo_color = dark.albedo_color * tint
				mesh.surface_set_material(s, dark)
	multi.mesh = mesh
	multi.instance_count = transforms.size()
	for i: int in transforms.size():
		multi.set_instance_transform(i, transforms[i] * mesh_node.transform)
	var holder: MultiMeshInstance3D = MultiMeshInstance3D.new()
	holder.multimesh = multi
	parent.add_child(holder)
	source.free()
