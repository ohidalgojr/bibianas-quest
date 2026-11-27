class_name ScenarioRenderer
extends RefCounted
## Constrói a cena 3D a partir de uma [ScenarioBlueprint] (ADR-0041, TASK-053).
## Agrupa terreno, pontes, escadas, muros, cercas, compostos, postes e props em MultiMeshes
## por (asset, tint, sombra), mantendo poucas chamadas de desenho e orçamento abaixo de 60 mil
## primitivas (GDD §18).

const K_MINI: String = "res://assets/kenney/mini_dungeon/"
const K_GRAVE: String = "res://assets/kenney/graveyard/"
const K_SCENERY: String = "res://assets/bibiana/scenery/"

const TINT_CLIFF: Color = Color(0.36, 0.36, 0.4)
const TINT_MOSS: Color = Color(0.78, 0.72, 0.68)
const TINT_STONE_BASE: Color = Color(0.5, 0.5, 0.55)
const TINT_PLAZA_TILE: Color = Color(1.22, 1.14, 1.02)
const TINT_COURT_TILE: Color = Color(0.66, 0.64, 0.66)
const TINT_ROAD: Color = Color(1.0, 0.98, 1.0)
const TINT_STAIR: Color = Color(0.42, 0.4, 0.4)
const TINT_WALL: Color = Color(0.42, 0.39, 0.38)
const TINT_ROOF: Color = Color(0.16, 0.17, 0.2)
const PROP_DARKEN: Color = Color(0.55, 0.55, 0.62)
const TINT_FENCE: Color = Color(0.18, 0.19, 0.23)

## Assets com múltiplos MeshInstance3D internos devem ser colocados como Node3D e não em MultiMesh.
## Chave reservada em `batches` para as janelas acesas das casas (quads emissivos).
const WINDOWS_KEY: String = "_windows"
## Linhas de Z por pedaço de MultiMesh: o mapa é grande e a câmera vê uma faixa dele; em pedaços
## o Godot descarta o que está fora da tela (orçamento de primitivas, GDD §18).
const CHUNK_ROWS: float = 12.0
const TINT_ROAD_MAIN: Color = Color(1.12, 1.08, 1.08)
const TINT_HOUSE: Color = Color(0.46, 0.42, 0.4)
const TINT_HOUSE_ROOF: Color = Color(0.15, 0.16, 0.19)

const MULTI_MESH_EXCEPTIONS: Array[String] = ["urn-round.glb", "urn-square.glb", "coffin.glb", "chest.glb"]


static func render(parent: Node3D, bp: ScenarioBlueprint, include_focal_lights: bool = true) -> void:
	var batches: Dictionary = {}
	_render_terrain_and_water(parent, bp, batches)
	_render_bridges(bp, batches)
	_render_stairs(bp, batches)
	_render_wall_runs(bp, batches)
	_render_compounds(parent, bp, batches, include_focal_lights)
	_render_lamps(parent, bp, batches, include_focal_lights)
	_render_dress(bp, batches)
	_render_props(parent, bp, batches)
	_flush_batches(parent, batches)
	if batches.has(WINDOWS_KEY):
		_build_window_quads(parent, batches[WINDOWS_KEY] as Array[Transform3D])
	if include_focal_lights:
		for light_def: Dictionary in bp.focal_lights:
			_spawn_light(
				parent,
				light_def["pos"] as Vector3,
				light_def["color"] as Color,
				float(light_def["energy"]),
				float(light_def["range_"])
			)


static func _batch_add(batches: Dictionary, path: String, pos: Vector3, yaw: float, scale_vec: Vector3, tint: Color, shadows: bool) -> void:
	var key: String = "%s|%s|%s|%d" % [path, tint.to_html(true), "1" if shadows else "0", int(floor(pos.z / CHUNK_ROWS))]
	if not batches.has(key):
		var list: Array[Transform3D] = []
		batches[key] = {"path": path, "tint": tint, "shadows": shadows, "transforms": list}
	var basis: Basis = Basis(Vector3.UP, deg_to_rad(yaw)).scaled(scale_vec)
	(batches[key]["transforms"] as Array[Transform3D]).append(Transform3D(basis, pos))


static func _flush_batches(parent: Node3D, batches: Dictionary) -> void:
	for key: Variant in batches.keys():
		if str(key) == WINDOWS_KEY:
			continue
		var bucket: Dictionary = batches[key]
		_build_multimesh(
			parent,
			str(bucket["path"]),
			bucket["transforms"] as Array[Transform3D],
			bucket["tint"] as Color,
			bool(bucket["shadows"])
		)


static func _render_terrain_and_water(parent: Node3D, bp: ScenarioBlueprint, batches: Dictionary) -> void:
	var cliff_blocks: Array[Transform3D] = []
	var moss_tops: Array[Transform3D] = []
	var stone_tops: Array[Transform3D] = []
	var plaza_tiles: Array[Transform3D] = []
	var court_tiles: Array[Transform3D] = []
	var road_tiles: Array[Transform3D] = []
	var main_road_tiles: Array[Transform3D] = []
	var water_transforms: Array[Transform3D] = []

	for z: int in bp.rows:
		for x: int in bp.cols:
			var cell: Vector2i = Vector2i(x, z)
			var zone: int = bp.zone_at(cell)
			if zone == ScenarioBlueprint.ZONE_VOID:
				continue
			var wx: float = float(x + bp.origin_offset.x)
			var wz: float = float(z + bp.origin_offset.y)

			if zone == ScenarioBlueprint.ZONE_WATER or zone == ScenarioBlueprint.ZONE_BRIDGE:
				for level: int in range(bp.base_cliff_level, 0):
					cliff_blocks.append(Transform3D(Basis.IDENTITY, Vector3(wx, float(level) * ScenarioBlueprint.BLOCK_H, wz)))
				var bed_basis: Basis = Basis.IDENTITY.scaled(Vector3(1.0, 0.5, 1.0))
				cliff_blocks.append(Transform3D(bed_basis, Vector3(wx, 0.0, wz)))
				water_transforms.append(Transform3D(Basis.IDENTITY, Vector3(wx, 0.72, wz)))
				if zone == ScenarioBlueprint.ZONE_WATER:
					continue

			var h: int = bp.height_at(cell)
			var low: int = h
			if zone != ScenarioBlueprint.ZONE_BRIDGE:
				for d: int in ScenarioBlueprint.CARDINAL_DIRS:
					var nb: Vector2i = cell + ScenarioBlueprint.dir_vec(d)
					if not bp.is_solid(nb):
						low = mini(low, bp.base_cliff_level)
					else:
						low = mini(low, bp.height_at(nb))
				for level: int in range(low, h):
					cliff_blocks.append(Transform3D(Basis.IDENTITY, Vector3(wx, float(level) * ScenarioBlueprint.BLOCK_H, wz)))
				var top_xf: Transform3D = Transform3D(Basis.IDENTITY, Vector3(wx, float(h) * ScenarioBlueprint.BLOCK_H, wz))
				if zone == ScenarioBlueprint.ZONE_TERRACE or zone == ScenarioBlueprint.ZONE_EMBANKMENT:
					moss_tops.append(top_xf)
				else:
					stone_tops.append(top_xf)

			var surface_y: float = float(h + 1) * ScenarioBlueprint.BLOCK_H + 0.02
			if zone == ScenarioBlueprint.ZONE_PLAZA or zone == ScenarioBlueprint.ZONE_BRIDGE or zone == ScenarioBlueprint.ZONE_FORECOURT:
				plaza_tiles.append(Transform3D(Basis.IDENTITY, Vector3(wx, surface_y, wz)))
			elif zone == ScenarioBlueprint.ZONE_BUILDING or zone == ScenarioBlueprint.ZONE_COURTYARD:
				court_tiles.append(Transform3D(Basis.IDENTITY, Vector3(wx, surface_y, wz)))
			elif zone == ScenarioBlueprint.ZONE_ROAD and not bp.stairs.has(cell):
				var road_xf: Transform3D = Transform3D(Basis.IDENTITY.scaled(Vector3(0.86, 1.0, 0.86)), Vector3(wx, surface_y, wz))
				if bp.main_road.has(cell):
					main_road_tiles.append(road_xf)
				else:
					road_tiles.append(road_xf)

	_build_chunked(parent, K_MINI + "dirt.glb", cliff_blocks, TINT_CLIFF, false, true)
	_build_chunked(parent, K_MINI + "dirt.glb", moss_tops, TINT_MOSS, bp.is_focal, true)
	_build_chunked(parent, K_MINI + "dirt.glb", stone_tops, TINT_STONE_BASE, bp.is_focal, true)
	_build_chunked(parent, K_MINI + "floor.glb", plaza_tiles, TINT_PLAZA_TILE, false, true)
	_build_chunked(parent, K_MINI + "floor.glb", court_tiles, TINT_COURT_TILE, false, true)
	_build_chunked(parent, K_MINI + "floor.glb", road_tiles, TINT_ROAD, false, true)
	_build_chunked(parent, K_MINI + "floor.glb", main_road_tiles, TINT_ROAD_MAIN, false, true)
	_build_water_multimesh(parent, water_transforms)
	var _b: Dictionary = batches


const STONE_TEXTURE: String = "res://assets/bibiana/textures/stone_cobble.jpg"


static func _stone() -> Texture2D:
	return load(STONE_TEXTURE) as Texture2D if ResourceLoader.exists(STONE_TEXTURE) else null


## Divide as instâncias em faixas de Z (um MultiMesh por faixa) para o corte por tela funcionar.
static func _build_chunked(parent: Node3D, path: String, transforms: Array[Transform3D], tint: Color, shadows: bool, textured: bool = false) -> void:
	var chunks: Dictionary = {}
	for xf: Transform3D in transforms:
		var chunk_id: int = int(floor(xf.origin.z / CHUNK_ROWS))
		if not chunks.has(chunk_id):
			var list: Array[Transform3D] = []
			chunks[chunk_id] = list
		(chunks[chunk_id] as Array[Transform3D]).append(xf)
	for chunk_id: Variant in chunks.keys():
		_build_multimesh(parent, path, chunks[chunk_id] as Array[Transform3D], tint, shadows, textured)


## Texturas pintadas do Gemini por tipo de peça, escolhidas pelo tom da peça (TASK-077): reboco com
## madeira nas casas, ardósia nos telhados, pedra de arrimo nos muros e entulho nos pátios.
const TEX_DIR: String = "res://assets/bibiana/textures/"


## {textura, tom, repetições por unidade} da peça com este tom, ou vazio se ela fica com a cor do kit.
static func _piece_texture(tint: Color) -> Dictionary:
	var file_name: String = ""
	var paint: Color = Color(0.92, 0.9, 0.9)
	var scale_f: float = 0.3
	if tint == TINT_HOUSE:
		file_name = "wall_plaster_timber.jpg"
		paint = Color(0.82, 0.78, 0.76)
		scale_f = 0.34
	elif tint == TINT_HOUSE_ROOF or tint == TINT_ROOF:
		file_name = "roof_slate.jpg"
		paint = Color(0.78, 0.8, 0.88)
		scale_f = 0.55
	elif tint == TINT_WALL:
		file_name = "stone_retaining_wall.jpg"
		paint = Color(0.86, 0.84, 0.86)
		scale_f = 0.36
	elif tint == TINT_COURT_TILE:
		file_name = "ground_rubble.jpg"
		paint = Color(0.8, 0.78, 0.82)
		scale_f = 0.26
	if file_name.is_empty() or not ResourceLoader.exists(TEX_DIR + file_name):
		return {}
	return {"texture": load(TEX_DIR + file_name) as Texture2D, "tint": paint, "scale": scale_f}


static func _build_multimesh(parent: Node3D, path: String, transforms: Array[Transform3D], tint: Color, shadows: bool, textured: bool = false) -> void:
	if transforms.is_empty():
		return
	var before_count: int = parent.get_child_count()
	var piece: Dictionary = _piece_texture(tint)
	if not piece.is_empty():
		StageKit.multimesh_from(parent, path, transforms, piece["tint"] as Color, piece["texture"] as Texture2D, float(piece["scale"]))
	else:
		StageKit.multimesh_from(parent, path, transforms, tint, _stone() if textured else null)
	if not shadows and parent.get_child_count() > before_count:
		var holder: Node = parent.get_child(parent.get_child_count() - 1)
		if holder is GeometryInstance3D:
			(holder as GeometryInstance3D).cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF


static func _build_water_multimesh(parent: Node3D, transforms: Array[Transform3D]) -> void:
	if transforms.is_empty():
		return
	var plane: PlaneMesh = PlaneMesh.new()
	plane.size = Vector2(1.02, 1.02)
	var shader: Shader = Shader.new()
	shader.code = "shader_type spatial;\nrender_mode blend_mix, cull_disabled, depth_draw_never;\nvoid fragment() {\n\tvec2 p = UV * 6.0;\n\tfloat ripple = sin(p.x * 3.0 + TIME * 1.4) * sin(p.y * 3.0 - TIME * 1.1);\n\tvec3 deep = vec3(0.015, 0.025, 0.04);\n\tvec3 light = vec3(0.06, 0.1, 0.15);\n\tALBEDO = mix(deep, light, 0.5 + 0.5 * ripple);\n\tALPHA = 0.90;\n\tROUGHNESS = 0.6;\n\tMETALLIC = 0.0;
	SPECULAR = 0.0;\n}\n"
	var material: ShaderMaterial = ShaderMaterial.new()
	material.shader = shader
	plane.material = material
	var multi: MultiMesh = MultiMesh.new()
	multi.transform_format = MultiMesh.TRANSFORM_3D
	multi.mesh = plane
	multi.instance_count = transforms.size()
	for i: int in transforms.size():
		multi.set_instance_transform(i, transforms[i])
	var holder: MultiMeshInstance3D = MultiMeshInstance3D.new()
	holder.multimesh = multi
	holder.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(holder)


static func _render_bridges(bp: ScenarioBlueprint, batches: Dictionary) -> void:
	if bp.bridge_cells.is_empty():
		return
	for cell: Vector2i in bp.bridge_cells.keys():
		var h: int = bp.height_at(cell)
		var top: Vector3 = bp.world_of(cell)
		var deck_y: float = float(h) * ScenarioBlueprint.BLOCK_H + 0.65
		_batch_add(batches, K_MINI + "dirt.glb", Vector3(top.x, deck_y, top.z), 0.0, Vector3(1.0, 0.30, 1.0), TINT_STONE_BASE, true)
		var deck_bottom_y: float = float(h) * ScenarioBlueprint.BLOCK_H + 0.68
		var foot_y: float = float(bp.base_cliff_level) * ScenarioBlueprint.BLOCK_H + 0.35
		var pillar_h: float = maxf(deck_bottom_y - foot_y, 0.8)
		for corner: Vector2 in [Vector2(-0.36, -0.36), Vector2(0.36, 0.36)]:
			_batch_add(batches, K_MINI + "column.glb", Vector3(top.x + corner.x, foot_y, top.z + corner.y), 0.0, Vector3(0.65, pillar_h / 1.1, 0.65), TINT_STONE_BASE, false)
		var travel_dir: int = int(bp.bridge_cells[cell])
		var left_dir: int = (travel_dir + 1) % 4
		var right_dir: int = (travel_dir + 3) % 4
		_batch_add(batches, K_GRAVE + "stone-wall.glb", top, ScenarioBlueprint.dir_yaw(left_dir), Vector3.ONE, TINT_WALL, true)
		_batch_add(batches, K_GRAVE + "stone-wall.glb", top, ScenarioBlueprint.dir_yaw(right_dir), Vector3.ONE, TINT_WALL, true)


static func _render_stairs(bp: ScenarioBlueprint, batches: Dictionary) -> void:
	for cell: Vector2i in bp.stairs.keys():
		_batch_add(batches, K_MINI + "stairs.glb", bp.world_of(cell), float(bp.stairs[cell]), Vector3.ONE, TINT_STAIR, true)


static func _render_wall_runs(bp: ScenarioBlueprint, batches: Dictionary) -> void:
	for run: Dictionary in bp.wall_runs:
		var cells: Array = run.get("cells", [])
		if cells.size() < ScenarioBlueprint.MIN_WALL_RUN_LEN:
			continue
		var edge_dir: int = int(run["edge_dir"])
		var yaw: float = ScenarioBlueprint.dir_yaw(edge_dir)
		var asset: String = K_GRAVE + ("brick-wall.glb" if str(run.get("style", "stone")) == "brick" else "stone-wall.glb")
		for raw_c: Variant in cells:
			var cell: Vector2i = raw_c as Vector2i
			_batch_add(batches, asset, bp.world_of(cell), yaw, Vector3.ONE, TINT_WALL, true)
		var first_cell: Vector2i = cells[0] as Vector2i
		var last_cell: Vector2i = cells[cells.size() - 1] as Vector2i
		var tangent: Vector3 = Vector3(1.0, 0.0, 0.0) if (edge_dir == ScenarioBlueprint.DIR_N or edge_dir == ScenarioBlueprint.DIR_S) else Vector3(0.0, 0.0, 1.0)
		var normal_offset: Vector3 = Vector3(float(ScenarioBlueprint.dir_vec(edge_dir).x) * 0.40, 0.0, float(ScenarioBlueprint.dir_vec(edge_dir).y) * 0.40)
		_batch_add(batches, K_GRAVE + "pillar-square.glb", bp.world_of(first_cell) + normal_offset - tangent * 0.45, 0.0, Vector3.ONE * 0.85, TINT_WALL, true)
		_batch_add(batches, K_GRAVE + "pillar-square.glb", bp.world_of(last_cell) + normal_offset + tangent * 0.45, 0.0, Vector3.ONE * 0.85, TINT_WALL, true)


static func _render_compounds(parent: Node3D, bp: ScenarioBlueprint, batches: Dictionary, with_lights: bool) -> void:
	for comp: Dictionary in bp.compounds:
		var kind: int = int(comp["kind"])
		var origin: Vector2i = comp["origin"] as Vector2i
		var sz: Vector2i = comp["size"] as Vector2i
		var door_dir: int = int(comp["door_dir"])
		var center_pos: Vector3 = _pad_world_center(bp, origin, sz)
		var face_yaw: float = ScenarioBlueprint.dir_yaw(ScenarioBlueprint.dir_opposite(door_dir))
		match kind:
			ScenarioBlueprint.COMPOUND_CHAPEL:
				_render_chapel(batches, bp, origin, sz, center_pos, face_yaw)
			ScenarioBlueprint.COMPOUND_WATCHTOWER:
				_render_watchtower(batches, center_pos, face_yaw, sz)
			ScenarioBlueprint.COMPOUND_CEMETERY:
				_render_cemetery(batches, bp, origin, sz, door_dir, face_yaw)
			ScenarioBlueprint.COMPOUND_COURTYARD_RUIN:
				_render_courtyard_ruin(batches, bp, origin, sz, door_dir, center_pos, face_yaw)
			ScenarioBlueprint.COMPOUND_SHRINE:
				_render_shrine(batches, center_pos, face_yaw)
			ScenarioBlueprint.COMPOUND_BOSS_MAUSOLEUM:
				_render_boss_mausoleum(parent, batches, bp, origin, sz, center_pos, face_yaw, with_lights)
			ScenarioBlueprint.COMPOUND_HOUSE, ScenarioBlueprint.COMPOUND_COTTAGE:
				_render_house(batches, bp, comp, center_pos, face_yaw)
			ScenarioBlueprint.COMPOUND_RUIN_HOUSE:
				_render_courtyard_ruin(batches, bp, origin, sz, door_dir, center_pos, face_yaw, "stone-wall.glb", 0.6)
			ScenarioBlueprint.COMPOUND_CHURCH_GATE:
				_render_church_gate(batches, bp, origin, sz)
			ScenarioBlueprint.COMPOUND_CITY_GATE:
				_render_city_gate(batches, bp, comp)


static func _pad_world_center(bp: ScenarioBlueprint, origin: Vector2i, sz: Vector2i) -> Vector3:
	var min_w: Vector3 = bp.world_of(origin)
	var max_w: Vector3 = bp.world_of(origin + sz - Vector2i.ONE)
	return (min_w + max_w) * 0.5


static func _render_chapel(batches: Dictionary, bp: ScenarioBlueprint, origin: Vector2i, sz: Vector2i, center: Vector3, face_yaw: float) -> void:
	var use_large: bool = (sz.x >= 4 or sz.y >= 4) and sz.y >= 3
	var body_asset: String = K_GRAVE + ("crypt-large.glb" if use_large else "crypt-small.glb")
	var roof_asset: String = K_GRAVE + ("crypt-large-roof.glb" if use_large else "crypt-small-roof.glb")
	var scale_f: float = 1.22 if use_large else (1.28 if sz.y >= 3 else 1.18)
	var back_shift: Vector3 = ScenarioBlueprint.rotate_offset_deg(Vector3(0.0, 0.0, -0.22), face_yaw)
	_batch_add(batches, body_asset, center + back_shift, face_yaw, Vector3.ONE * scale_f, TINT_WALL, true)
	_batch_add(batches, roof_asset, center + back_shift + Vector3(0.0, 1.0 * scale_f, 0.0), face_yaw, Vector3.ONE * scale_f, TINT_ROOF, true)
	var belfry_off: Vector3 = ScenarioBlueprint.rotate_offset_deg(Vector3(-0.98, 0.0, -0.58), face_yaw)
	_batch_add(batches, K_MINI + "wall.glb", center + belfry_off, face_yaw, Vector3.ONE * 0.85, TINT_WALL, true)
	_batch_add(batches, K_GRAVE + "cross-column.glb", center + belfry_off + Vector3(0.0, 0.85 * 1.1, 0.0), face_yaw, Vector3.ONE * 0.85, TINT_WALL, false)
	for dx: int in sz.x:
		var back_c: Vector2i = Vector2i(origin.x + dx, origin.y)
		_batch_add(batches, K_GRAVE + "stone-wall.glb", bp.world_of(back_c), 0.0, Vector3.ONE, TINT_WALL, true)


static func _render_watchtower(batches: Dictionary, center: Vector3, face_yaw: float, sz: Vector2i) -> void:
	var compact: bool = sz.y <= 2
	var tower_scale: float = 0.86 if compact else 0.96
	var half_x: float = 0.43 if compact else 0.48
	var half_z: float = 0.36 if compact else 0.48
	var offsets: Array[Dictionary] = [
		{"off": Vector3(-half_x, 0.0, -half_z), "asset": "wall.glb"},
		{"off": Vector3(half_x, 0.0, -half_z), "asset": "wall.glb"},
		{"off": Vector3(-half_x, 0.0, half_z), "asset": "wall-opening.glb"},
		{"off": Vector3(half_x, 0.0, half_z), "asset": "wall.glb"},
	]
	for item: Dictionary in offsets:
		var pos: Vector3 = center + ScenarioBlueprint.rotate_offset_deg(item["off"] as Vector3, face_yaw)
		_batch_add(batches, K_MINI + str(item["asset"]), pos, face_yaw, Vector3.ONE * tower_scale, TINT_WALL, true)
		_batch_add(batches, K_MINI + "wall-half.glb", pos + Vector3(0.0, tower_scale, 0.0), face_yaw, Vector3.ONE * tower_scale, TINT_WALL, true)
	_batch_add(batches, K_GRAVE + "crypt-small-roof.glb", center + Vector3(0.0, tower_scale * 2.0, 0.0), face_yaw, Vector3.ONE * (1.24 if compact else 1.38), TINT_ROOF, true)
	var brazier_pos: Vector3 = center + ScenarioBlueprint.rotate_offset_deg(Vector3(-0.85, 0.0, 0.88 if compact else 1.05), face_yaw)
	_batch_add(batches, K_GRAVE + "candle-multiple.glb", brazier_pos, 0.0, Vector3.ONE * 1.4, Color.WHITE, false)


static func _render_cemetery(batches: Dictionary, bp: ScenarioBlueprint, origin: Vector2i, sz: Vector2i, door_dir: int, face_yaw: float) -> void:
	var mid_x: int = origin.x + sz.x / 2
	var mid_z: int = origin.y + sz.y / 2
	for dx: int in sz.x:
		var x: int = origin.x + dx
		var n_cell: Vector2i = Vector2i(x, origin.y)
		var s_cell: Vector2i = Vector2i(x, origin.y + sz.y - 1)
		var n_piece: String = "iron-fence-border-gate.glb" if (door_dir == ScenarioBlueprint.DIR_N and x == mid_x) else "iron-fence-border.glb"
		var s_piece: String = "iron-fence-border-gate.glb" if (door_dir == ScenarioBlueprint.DIR_S and x == mid_x) else "iron-fence-border.glb"
		_batch_add(batches, K_GRAVE + n_piece, bp.world_of(n_cell), ScenarioBlueprint.dir_yaw(ScenarioBlueprint.DIR_N), Vector3.ONE, TINT_FENCE, false)
		_batch_add(batches, K_GRAVE + s_piece, bp.world_of(s_cell), ScenarioBlueprint.dir_yaw(ScenarioBlueprint.DIR_S), Vector3.ONE, TINT_FENCE, false)

	for dz: int in sz.y:
		var z: int = origin.y + dz
		var w_cell: Vector2i = Vector2i(origin.x, z)
		var e_cell: Vector2i = Vector2i(origin.x + sz.x - 1, z)
		var w_piece: String = "iron-fence-border-gate.glb" if (door_dir == ScenarioBlueprint.DIR_W and z == mid_z) else "iron-fence-border.glb"
		var e_piece: String = "iron-fence-border-gate.glb" if (door_dir == ScenarioBlueprint.DIR_E and z == mid_z) else "iron-fence-border.glb"
		_batch_add(batches, K_GRAVE + w_piece, bp.world_of(w_cell), ScenarioBlueprint.dir_yaw(ScenarioBlueprint.DIR_W), Vector3.ONE, TINT_FENCE, false)
		_batch_add(batches, K_GRAVE + e_piece, bp.world_of(e_cell), ScenarioBlueprint.dir_yaw(ScenarioBlueprint.DIR_E), Vector3.ONE, TINT_FENCE, false)

	var nw: Vector3 = bp.world_of(origin) + Vector3(-0.36, 0.0, -0.36)
	var ne: Vector3 = bp.world_of(Vector2i(origin.x + sz.x - 1, origin.y)) + Vector3(0.36, 0.0, -0.36)
	var sw: Vector3 = bp.world_of(Vector2i(origin.x, origin.y + sz.y - 1)) + Vector3(-0.36, 0.0, 0.36)
	var se: Vector3 = bp.world_of(origin + sz - Vector2i.ONE) + Vector3(0.36, 0.0, 0.36)
	for corner_pos: Vector3 in [nw, ne, sw, se]:
		_batch_add(batches, K_GRAVE + "pillar-square.glb", corner_pos, 0.0, Vector3.ONE * 0.85, TINT_WALL, true)

	var pad_mid: Vector3 = _pad_world_center(bp, origin, sz)
	var z_cross: float = -0.32 if sz.y <= 2 else -0.55
	var cross_pos: Vector3 = pad_mid + ScenarioBlueprint.rotate_offset_deg(Vector3(0.0, 0.0, z_cross), face_yaw)
	_batch_add(batches, K_GRAVE + "gravestone-cross-large.glb", cross_pos, face_yaw, Vector3.ONE * (1.18 if sz.y <= 2 else 1.35), TINT_WALL, false)
	var stones: Array[String] = ["gravestone-round.glb", "gravestone-bevel.glb"]
	for i: int in 2:
		var side_x: float = -0.78 if i == 0 else 0.78
		var st_pos: Vector3 = pad_mid + ScenarioBlueprint.rotate_offset_deg(Vector3(side_x, 0.0, 0.05 if sz.y <= 2 else 0.15), face_yaw)
		_batch_add(batches, K_GRAVE + stones[i], st_pos, face_yaw, Vector3.ONE * 1.12, TINT_WALL, false)


static func _render_courtyard_ruin(batches: Dictionary, bp: ScenarioBlueprint, origin: Vector2i, sz: Vector2i, door_dir: int, center: Vector3, face_yaw: float, wall_name: String = "brick-wall.glb", pillar_scale: float = 0.85) -> void:
	for dx: int in sz.x:
		var x: int = origin.x + dx
		if door_dir != ScenarioBlueprint.DIR_N:
			_batch_add(batches, K_GRAVE + wall_name, bp.world_of(Vector2i(x, origin.y)), ScenarioBlueprint.dir_yaw(ScenarioBlueprint.DIR_N), Vector3.ONE, TINT_WALL, true)
		if door_dir != ScenarioBlueprint.DIR_S:
			_batch_add(batches, K_GRAVE + wall_name, bp.world_of(Vector2i(x, origin.y + sz.y - 1)), ScenarioBlueprint.dir_yaw(ScenarioBlueprint.DIR_S), Vector3.ONE, TINT_WALL, true)
	for dz: int in sz.y:
		var z: int = origin.y + dz
		if door_dir != ScenarioBlueprint.DIR_W:
			_batch_add(batches, K_GRAVE + wall_name, bp.world_of(Vector2i(origin.x, z)), ScenarioBlueprint.dir_yaw(ScenarioBlueprint.DIR_W), Vector3.ONE, TINT_WALL, true)
		if door_dir != ScenarioBlueprint.DIR_E:
			_batch_add(batches, K_GRAVE + wall_name, bp.world_of(Vector2i(origin.x + sz.x - 1, z)), ScenarioBlueprint.dir_yaw(ScenarioBlueprint.DIR_E), Vector3.ONE, TINT_WALL, true)

	var nw: Vector3 = bp.world_of(origin) + Vector3(-0.36, 0.0, -0.36)
	var ne: Vector3 = bp.world_of(Vector2i(origin.x + sz.x - 1, origin.y)) + Vector3(0.36, 0.0, -0.36)
	var sw: Vector3 = bp.world_of(Vector2i(origin.x, origin.y + sz.y - 1)) + Vector3(-0.36, 0.0, 0.36)
	var se: Vector3 = bp.world_of(origin + sz - Vector2i.ONE) + Vector3(0.36, 0.0, 0.36)
	for corner_pos: Vector3 in [nw, ne, sw, se]:
		_batch_add(batches, K_GRAVE + "pillar-square.glb", corner_pos, 0.0, Vector3.ONE * pillar_scale, TINT_WALL, true)

	var bench_pos: Vector3 = center + ScenarioBlueprint.rotate_offset_deg(Vector3(0.0, 0.0, -0.32 if sz.y <= 2 else -0.45), face_yaw)
	var barrel_pos: Vector3 = center + ScenarioBlueprint.rotate_offset_deg(Vector3(-0.62, 0.0, 0.22 if sz.y <= 2 else 0.35), face_yaw)
	_batch_add(batches, K_GRAVE + "bench-damaged.glb", bench_pos, face_yaw, Vector3.ONE * 1.1, Color(0.4, 0.34, 0.3), false)
	_batch_add(batches, K_MINI + "barrel.glb", barrel_pos, 0.0, Vector3.ONE * 1.3, Color(0.3, 0.24, 0.2), false)


static func _render_shrine(batches: Dictionary, center: Vector3, face_yaw: float) -> void:
	_batch_add(batches, K_GRAVE + "altar-stone.glb", center, face_yaw, Vector3.ONE * 1.25, TINT_WALL, false)
	var ob_pos: Vector3 = center + ScenarioBlueprint.rotate_offset_deg(Vector3(0.0, 0.0, -0.58), face_yaw)
	_batch_add(batches, K_GRAVE + "cross-column.glb", ob_pos, face_yaw, Vector3.ONE * 1.15, TINT_WALL, false)
	for side: float in [-0.58, 0.58]:
		var cpos: Vector3 = center + ScenarioBlueprint.rotate_offset_deg(Vector3(side, 0.0, 0.25), face_yaw)
		_batch_add(batches, K_GRAVE + "candle-multiple.glb", cpos, 0.0, Vector3.ONE * 1.45, Color.WHITE, false)


static func _render_boss_mausoleum(parent: Node3D, batches: Dictionary, bp: ScenarioBlueprint, origin: Vector2i, sz: Vector2i, center: Vector3, face_yaw: float, with_lights: bool) -> void:
	var scale_f: float = 1.12 if sz.y <= 2 else 1.32
	var body_pos: Vector3 = center + Vector3(0.0, 0.0, -0.15 if sz.y <= 2 else -0.2)
	_batch_add(batches, K_GRAVE + "crypt-large.glb", body_pos, face_yaw, Vector3.ONE * scale_f, TINT_WALL, true)
	_batch_add(batches, K_GRAVE + "crypt-large-roof.glb", body_pos + Vector3(0.0, 1.0 * scale_f, 0.0), face_yaw, Vector3.ONE * scale_f, TINT_ROOF, true)
	for dx: int in sz.x:
		var back_c: Vector2i = Vector2i(origin.x + dx, origin.y)
		_batch_add(batches, K_GRAVE + "brick-wall.glb", bp.world_of(back_c), 0.0, Vector3.ONE * 1.1, TINT_WALL, true)
	var wing_z: float = 0.45 if sz.y <= 2 else 0.75
	for side_x: float in [-1.75, 1.75]:
		_batch_add(batches, K_GRAVE + "pillar-obelisk.glb", center + Vector3(side_x, 0.0, wing_z - 0.35), 0.0, Vector3.ONE * 1.35, TINT_WALL, true)
		var brazier: Vector3 = center + Vector3(side_x, 0.0, wing_z + 0.15)
		_batch_add(batches, K_GRAVE + "fire-basket.glb", brazier, 0.0, Vector3.ONE * 1.7, Color.WHITE, false)
		if with_lights:
			_spawn_light(parent, brazier + Vector3(0.0, 1.1, 0.0), Color(1.0, 0.36, 0.16), 3.0, 5.5)


static func _render_lamps(parent: Node3D, bp: ScenarioBlueprint, batches: Dictionary, with_lights: bool) -> void:
	for lamp: Dictionary in bp.lamps:
		var cell: Vector2i = lamp["cell"] as Vector2i
		var pos: Vector3 = bp.world_of(cell)
		var yaw: float = float(lamp["yaw"])
		_batch_add(batches, K_GRAVE + "lightpost-single.glb", pos, yaw, Vector3.ONE * 1.45, Color(0.2, 0.21, 0.25), false)
		if with_lights and bool(lamp.get("lit", false)):
			var arm_off: Vector3 = ScenarioBlueprint.rotate_offset_deg(Vector3(0.0, 1.85, 0.35), yaw)
			_spawn_light(parent, pos + arm_off, Color(1.0, 0.72, 0.36), 1.5, 4.2)


static func _render_props(parent: Node3D, bp: ScenarioBlueprint, batches: Dictionary) -> void:
	for cell: Vector2i in bp.typed_props.keys():
		var info: Dictionary = bp.typed_props[cell]
		var rel: String = str(info["asset"])
		var asset: String = "res://assets/kenney/" + rel
		var pos: Vector3 = bp.world_of(cell)
		var yaw: float = float(info["yaw"])
		var scale_f: float = float(info["scale"])
		var tint: Color = (info.get("tint", Color.WHITE) as Color) * PROP_DARKEN
		var is_multi: bool = false
		for exc: String in MULTI_MESH_EXCEPTIONS:
			if rel.ends_with(exc):
				is_multi = true
				break
		if is_multi:
			StageKit.place(parent, asset, pos, yaw, scale_f, tint)
		else:
			_batch_add(batches, asset, pos, yaw, Vector3.ONE * scale_f, tint, false)


static func _spawn_light(parent: Node3D, pos: Vector3, color: Color, energy: float, range_: float) -> void:
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = color
	light.light_energy = energy
	light.omni_range = range_
	light.position = pos
	parent.add_child(light)


const WINDOW_COLOR: Color = Color(0.62, 0.34, 0.12)


## Casa de empena (ADR-0060): corpo e telhado de duas águas (kit de cripta, escalado à planta), porta
## em arco voltada para a rua e janelas acesas na fachada. Planta larga (4) vira duas casas geminadas.
static func _render_house(batches: Dictionary, _bp: ScenarioBlueprint, comp: Dictionary, center: Vector3, face_yaw: float) -> void:
	var sz: Vector2i = comp["size"] as Vector2i
	var door_dir: int = int(comp["door_dir"])
	var along_x: bool = door_dir == ScenarioBlueprint.DIR_S or door_dir == ScenarioBlueprint.DIR_N
	var width: int = sz.x if along_x else sz.y
	var depth: int = sz.y if along_x else sz.x
	var variant: int = int(comp.get("variant", 0))
	var modules: int = 2 if width >= 4 else 1
	var module_w: float = float(width) / float(modules)
	var sx: float = module_w / 1.85
	var sz_depth: float = float(depth) / 2.4
	var cottage: bool = int(comp["kind"]) == ScenarioBlueprint.COMPOUND_COTTAGE
	var sy: float = 0.78 + 0.04 * float(variant % 3) if cottage else 1.3 + 0.06 * float(variant % 3)
	var windows: Array[Transform3D] = []
	if batches.has(WINDOWS_KEY):
		windows = batches[WINDOWS_KEY] as Array[Transform3D]
	for m: int in modules:
		var local_x: float = (float(m) - float(modules - 1) * 0.5) * module_w
		var pos: Vector3 = center + ScenarioBlueprint.rotate_offset_deg(Vector3(local_x, 0.0, 0.0), face_yaw)
		var scale_vec: Vector3 = Vector3(sx, sy, sz_depth)
		_batch_add(batches, K_GRAVE + "crypt-large.glb", pos, face_yaw, scale_vec, TINT_HOUSE, true)
		_batch_add(batches, K_GRAVE + "crypt-large-roof.glb", pos + Vector3(0.0, sy, 0.0), face_yaw, scale_vec, TINT_HOUSE_ROOF, true)
		var facade_z: float = float(depth) * 0.5 + 0.02
		for side: float in [-0.62, 0.62]:
			var wpos: Vector3 = pos + ScenarioBlueprint.rotate_offset_deg(Vector3(side * module_w * 0.5, 0.95, facade_z), face_yaw)
			windows.append(Transform3D(Basis(Vector3.UP, deg_to_rad(face_yaw)).scaled(Vector3(1.0, 1.15, 1.0)), wpos))
	batches[WINDOWS_KEY] = windows
	if variant % 3 == 0 and not cottage:
		var top: Vector3 = center + ScenarioBlueprint.rotate_offset_deg(Vector3(0.0, sy + 0.8, float(depth) * -0.25), face_yaw)
		_batch_add(batches, K_SCENERY + "spire.glb", top, 0.0, Vector3(0.18, 0.2, 0.18), TINT_HOUSE_ROOF, false)


## Muro e portão do adro, atrás do chefe: o portão de ferro fica no eixo da escadaria e da igreja.
static func _render_church_gate(batches: Dictionary, bp: ScenarioBlueprint, origin: Vector2i, sz: Vector2i) -> void:
	var mid_x: int = origin.x + sz.x / 2
	for dx: int in sz.x:
		var cell: Vector2i = origin + Vector2i(dx, 0)
		var pos: Vector3 = bp.world_of(cell)
		var off: int = absi(cell.x - mid_x)
		if off == 0:
			_batch_add(batches, K_GRAVE + "iron-fence-border-gate.glb", pos, 0.0, Vector3(1.0, 1.9, 1.7), TINT_FENCE, false)
		elif off == 1:
			_batch_add(batches, K_GRAVE + "iron-fence-border.glb", pos, 0.0, Vector3(1.0, 1.9, 1.7), TINT_FENCE, false)
		elif off == 2:
			_batch_add(batches, K_GRAVE + "pillar-square.glb", pos, 0.0, Vector3(1.7, 1.9, 1.7), TINT_WALL, true)
		else:
			_batch_add(batches, K_GRAVE + "stone-wall.glb", pos, 0.0, Vector3(1.0, 1.8, 1.6), TINT_WALL, true)
			_batch_add(batches, K_GRAVE + "iron-fence-border.glb", pos + Vector3(0.0, 1.3, 0.0), 0.0, Vector3(1.0, 1.2, 1.0), TINT_FENCE, false)
	var brazier_l: Vector3 = bp.world_of(Vector2i(mid_x - 3, origin.y + 2))
	var brazier_r: Vector3 = bp.world_of(Vector2i(mid_x + 3, origin.y + 2))
	_add_brazier(batches, brazier_l)
	_add_brazier(batches, brazier_r)


## Portão em ruína da entrada: dois pilares baixos e restos de muro (nada acima da altura que
## esconderia a Bibiana na câmera).
static func _render_city_gate(batches: Dictionary, bp: ScenarioBlueprint, comp: Dictionary) -> void:
	var origin: Vector2i = comp["origin"] as Vector2i
	for raw: Variant in comp["cells"]:
		var cell: Vector2i = raw as Vector2i
		var dx: int = cell.x - origin.x
		var pos: Vector3 = bp.world_of(cell)
		if dx == 2 or dx == 4:
			_batch_add(batches, K_GRAVE + "pillar-square.glb", pos, 0.0, Vector3(1.5, 0.62, 1.5), TINT_WALL, true)
		elif dx == 1 or dx == 5:
			_batch_add(batches, K_GRAVE + "stone-wall-damaged.glb", pos, 0.0, Vector3.ONE, TINT_WALL, true)
		else:
			_batch_add(batches, K_GRAVE + "debris.glb", pos, float(dx * 50), Vector3.ONE * 1.3, Color(0.5, 0.5, 0.55), false)


## Braseiro: cesto de ferro escuro com chama âmbar (dois quads cruzados, sem luz dinâmica).
static func _add_brazier(batches: Dictionary, pos: Vector3) -> void:
	_batch_add(batches, K_GRAVE + "fire-basket.glb", pos, 0.0, Vector3.ONE * 1.7, Color(0.2, 0.2, 0.24), false)
	var windows: Array[Transform3D] = []
	if batches.has(WINDOWS_KEY):
		windows = batches[WINDOWS_KEY] as Array[Transform3D]
	for yaw: float in [45.0, -45.0]:
		windows.append(Transform3D(Basis(Vector3.UP, deg_to_rad(yaw)).scaled(Vector3(1.3, 1.3, 1.0)), pos + Vector3(0.0, 0.5, 0.0)))
	batches[WINDOWS_KEY] = windows


## Cenografia dos lugares (abrigo, sala em ruínas, campo-santo, grade da praça de armas...).
static func _render_dress(bp: ScenarioBlueprint, batches: Dictionary) -> void:
	for piece: Dictionary in bp.plaza_dress:
		var cell: Vector2i = piece["cell"] as Vector2i
		var pos: Vector3 = bp.world_of(cell) + Vector3(0.0, float(piece.get("lift", 0.0)), 0.0)
		var rel: String = str(piece["asset"])
		var big: bool = rel.contains("stone-wall") or rel.contains("iron-fence")
		if rel.contains("fire-basket"):
			_add_brazier(batches, pos)
			continue
		_batch_add(batches, "res://assets/kenney/" + rel, pos, float(piece["yaw"]), piece["scale"] as Vector3, piece["tint"] as Color, big)


static func _build_window_quads(parent: Node3D, windows: Array[Transform3D]) -> void:
	if windows.is_empty():
		return
	var quad: QuadMesh = QuadMesh.new()
	quad.size = Vector2(0.26, 0.5)
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = WINDOW_COLOR
	quad.material = mat
	var multi: MultiMesh = MultiMesh.new()
	multi.transform_format = MultiMesh.TRANSFORM_3D
	multi.mesh = quad
	multi.instance_count = windows.size()
	for i: int in windows.size():
		multi.set_instance_transform(i, windows[i])
	var holder: MultiMeshInstance3D = MultiMeshInstance3D.new()
	holder.multimesh = multi
	holder.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(holder)
