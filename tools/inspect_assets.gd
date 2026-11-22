extends SceneTree
## Imprime a caixa (tamanho e base) de cada peça dos kits, para compor cenas sem adivinhar.
## Uso: godot --headless --path . -s tools/inspect_assets.gd -- <pasta> [<pasta>...]
## Ex.: res://assets/kenney/graveyard


func _initialize() -> void:
	for dir_path: String in OS.get_cmdline_user_args():
		for file: String in DirAccess.get_files_at(dir_path):
			if not file.ends_with(".glb"):
				continue
			var scene: PackedScene = load(dir_path.path_join(file)) as PackedScene
			if scene == null:
				continue
			var node: Node3D = scene.instantiate() as Node3D
			var box: AABB = AABB()
			var first: bool = true
			for found: Node in node.find_children("*", "MeshInstance3D", true, false):
				var mesh: MeshInstance3D = found as MeshInstance3D
				var chain: Transform3D = mesh.transform
				var parent: Node = mesh.get_parent()
				while parent != null and parent != node:
					if parent is Node3D:
						chain = (parent as Node3D).transform * chain
					parent = parent.get_parent()
				var part: AABB = chain * mesh.get_aabb()
				box = part if first else box.merge(part)
				first = false
			print("%s  size(%.2f, %.2f, %.2f)  min(%.2f, %.2f, %.2f)" % [file, box.size.x, box.size.y, box.size.z, box.position.x, box.position.y, box.position.z])
			node.free()
	quit()
