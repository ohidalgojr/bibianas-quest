class_name StageKit
extends RefCounted
## Utilidades de cena 3D com os kits CC0 (TASK-035 a 037): posicionar peças e juntar muitas
## cópias da mesma peça numa única `MultiMesh` (uma chamada de desenho). Usadas pelo tabuleiro
## do mapa e pelo palco do combate.


## Instancia o modelo `path` em `parent`.
static func place(parent: Node3D, path: String, pos: Vector3, yaw: float = 0.0, factor: float = 1.0) -> Node3D:
	var node: Node3D = (load(path) as PackedScene).instantiate() as Node3D
	node.position = pos
	node.rotation_degrees.y = yaw
	node.scale = Vector3.ONE * factor
	parent.add_child(node)
	return node


## Junta todas as cópias de `path` (uma por transformação) numa `MultiMesh`. `tint` escurece o
## material da peça (cor multiplicada), para lajes e estradas não brilharem.
static func multimesh_from(parent: Node3D, path: String, transforms: Array[Transform3D], tint: Color = Color.WHITE) -> void:
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
	parent.add_child(holder)
	source.free()
