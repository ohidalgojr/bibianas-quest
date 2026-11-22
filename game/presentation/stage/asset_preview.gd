class_name AssetPreview
extends Control
## Cena de conferência de peças: mostra uma ou mais peças `.glb` lado a lado com a luz do jogo,
## para escolher e posicionar kits antes de compor um cenário. Uso com `tools/screenshot.ps1`:
##   -Extra pecas=a.glb;b.glb,tamanho=8 (separe peças com ponto e vírgula)


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var paths: PackedStringArray = PackedStringArray()
	var size_units: float = 6.0
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("pecas="):
			paths = arg.trim_prefix("pecas=").split(";")
		elif arg.begins_with("tamanho="):
			size_units = float(arg.trim_prefix("tamanho="))
	var viewport: SubViewport = SubViewport.new()
	viewport.size = Vector2i(540, 960)
	add_child(viewport)
	var container: SubViewportContainer = SubViewportContainer.new()
	container.stretch = true
	container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	remove_child(viewport)
	container.add_child(viewport)
	add_child(container)
	var world: Node3D = Node3D.new()
	viewport.add_child(world)
	var env: Environment = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.03, 0.035, 0.05)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.5, 0.55, 0.65)
	env.ambient_light_energy = 0.7
	var holder: WorldEnvironment = WorldEnvironment.new()
	holder.environment = env
	world.add_child(holder)
	var sun: DirectionalLight3D = DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-45, 30, 0)
	sun.light_energy = 1.1
	world.add_child(sun)
	var x: float = 0.0
	for path: String in paths:
		var packed: PackedScene = load(path) as PackedScene
		if packed == null:
			continue
		var node: Node3D = packed.instantiate() as Node3D
		node.position = Vector3(x, 0, 0)
		world.add_child(node)
		x += size_units * 0.5
	var cam: Camera3D = Camera3D.new()
	cam.projection = Camera3D.PROJECTION_ORTHOGONAL
	cam.size = size_units
	world.add_child(cam)
	var center: Vector3 = Vector3(x * 0.5 - size_units * 0.25, size_units * 0.2, 0)
	cam.position = center + Vector3(1.0, 0.7, 1.0) * 20.0
	cam.look_at(center)
