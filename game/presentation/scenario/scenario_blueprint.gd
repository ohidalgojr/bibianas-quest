class_name ScenarioBlueprint
extends RefCounted
## Planta declarativa de cenário 3D (ADR-0041, TASK-053): reúne relevo, zonas funcionais,
## rotas exatas de estrada, degraus, canais/pontes, compostos arquitetônicos completos, muros de
## contenção, postes e micro-props contextuais. Puro em dados (sem nós Godot).

const BLOCK_H: float = 0.9
const MIN_PLAZA_LEVEL: int = 2
const MAX_PLAZA_LEVEL: int = 5
const MIN_WATER_COMPONENT: int = 6
const MIN_WALL_RUN_LEN: int = 2
const MIN_LAMP_SPACING: int = 7

const ZONE_VOID: int = 0
const ZONE_PLAZA: int = 1
const ZONE_ROAD: int = 2
const ZONE_BRIDGE: int = 3
const ZONE_WATER: int = 4
const ZONE_BUILDING: int = 5
const ZONE_COURTYARD: int = 6
const ZONE_TERRACE: int = 7
const ZONE_EMBANKMENT: int = 8
## Adro (pátio de pedra diante da igreja, só no mapa; ADR-0060).
const ZONE_FORECOURT: int = 9

## Direções cardinais alinhadas ao yaw do Godot (+Y para cima): 0=-Z, 90=-X, 180=+Z, 270=+X.
const DIR_N: int = 0
const DIR_W: int = 1
const DIR_S: int = 2
const DIR_E: int = 3

const COMPOUND_CHAPEL: int = 0
const COMPOUND_WATCHTOWER: int = 1
const COMPOUND_CEMETERY: int = 2
const COMPOUND_COURTYARD_RUIN: int = 3
const COMPOUND_SHRINE: int = 4
const COMPOUND_BOSS_MAUSOLEUM: int = 5
## Gramática da cidade gótica (ADR-0060): casa de empena com porta para a rua, ruína baixa
## (pátio com muros caídos), muro-portal do adro da igreja e portão em ruína da entrada.
const COMPOUND_HOUSE: int = 6
const COMPOUND_RUIN_HOUSE: int = 7
const COMPOUND_CHURCH_GATE: int = 8
const COMPOUND_CITY_GATE: int = 9
## Casa baixa de empena (cerca de 1,5 de altura): só esconde o primeiro passo diagonal da câmera.
const COMPOUND_COTTAGE: int = 10

const PROP_ROCK: int = 0
const PROP_ROCK_TALL: int = 1
const PROP_STONES: int = 2
const PROP_DEBRIS: int = 3
const PROP_DEBRIS_WOOD: int = 4
const PROP_BARREL: int = 5
const PROP_BENCH: int = 6
const PROP_TRUNK: int = 7
const PROP_URN: int = 8
const PROP_CANDLE: int = 9
const PROP_BRAZIER: int = 10
const PROP_OBELISK: int = 11

const CARDINAL_DIRS: Array[int] = [DIR_N, DIR_W, DIR_S, DIR_E]

var cols: int = 0
var rows: int = 0
var layer_count: int = 0
var layer_step: int = 5
var column_step: int = 4
var margin: int = 8
var map_seed: int = 0
var origin_offset: Vector2i = Vector2i.ZERO
var base_cliff_level: int = 0
var is_focal: bool = false

## Altura (em blocos) e zona funcional por célula (`z * cols + x`).
var heights: PackedInt32Array = PackedInt32Array()
var zones: PackedInt32Array = PackedInt32Array()

## Conjuntos rápidos indexados por `Vector2i`.
var node_cells: Dictionary = {}
var node_levels: Dictionary = {}
var plaza_cells: Dictionary = {}
var road_cells: Dictionary = {}
var bridge_cells: Dictionary = {}
var water_cells: Dictionary = {}
var stairs: Dictionary = {}

## Rotas por aresta do grafo (`"from_id:to_id"` -> `Array[Vector2i]`).
var edge_paths: Dictionary = {}

## Estruturas arquitetônicas coerentes, muros contínuos, postes e props tipados.
var compounds: Array[Dictionary] = []
var wall_runs: Array[Dictionary] = []
var lamps: Array[Dictionary] = []
var typed_props: Dictionary = {}
var focal_lights: Array[Dictionary] = []

## Cidade gótica (ADR-0060): rua principal (células do caminho central entre início e chefe),
## camada do canal (desnível), célula do chefe e peças de cenografia dos nós (poço, bancos,
## muros de abrigo). Cada peça de `plaza_dress` é um dicionário com `cell`, `asset`, `yaw`,
## `scale`, `tint`, `lift` e `role`.
var main_road: Dictionary = {}
var canal_layer: int = -1
var boss_cell: Vector2i = Vector2i(-1, -1)
var plaza_dress: Array[Dictionary] = []


func configure(p_cols: int, p_rows: int, p_seed: int) -> void:
	cols = p_cols
	rows = p_rows
	map_seed = p_seed
	heights.resize(cols * rows)
	heights.fill(0)
	zones.resize(cols * rows)
	zones.fill(ZONE_TERRACE)


func in_bounds(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.y >= 0 and cell.x < cols and cell.y < rows


func idx(cell: Vector2i) -> int:
	return cell.y * cols + cell.x


func height_at(cell: Vector2i) -> int:
	if not in_bounds(cell):
		return base_cliff_level
	return heights[cell.y * cols + cell.x]


func set_height(cell: Vector2i, level: int) -> void:
	if in_bounds(cell):
		heights[cell.y * cols + cell.x] = level


func zone_at(cell: Vector2i) -> int:
	if not in_bounds(cell):
		return ZONE_VOID
	return zones[cell.y * cols + cell.x]


func set_zone(cell: Vector2i, zone: int) -> void:
	if in_bounds(cell):
		zones[cell.y * cols + cell.x] = zone


func is_walkable(cell: Vector2i) -> bool:
	return plaza_cells.has(cell) or road_cells.has(cell)


func is_solid(cell: Vector2i) -> bool:
	return in_bounds(cell) and zone_at(cell) != ZONE_VOID


func world_of(cell: Vector2i) -> Vector3:
	return Vector3(
		float(cell.x + origin_offset.x),
		float(height_at(cell) + 1) * BLOCK_H,
		float(cell.y + origin_offset.y)
	)


func world_to_cell(pos: Vector3) -> Vector2i:
	return Vector2i(int(round(pos.x)) - origin_offset.x, int(round(pos.z)) - origin_offset.y)


func node_world(node_id: int) -> Vector3:
	return world_of(node_cells[node_id] as Vector2i)


func layer_at_row(z: int) -> int:
	var layer_total: int = layer_count + 2
	return clampi(
		int(round(float(margin + (layer_total - 1) * layer_step - z) / float(layer_step))),
		0,
		layer_total - 1
	)


func legacy_props_dict() -> Dictionary:
	var out: Dictionary = {}
	for cell: Vector2i in typed_props.keys():
		var info: Dictionary = typed_props[cell]
		out[cell] = int(info.get("kind", 0))
	return out


func legacy_lamp_cells() -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for lamp: Dictionary in lamps:
		out.append(lamp["cell"] as Vector2i)
	return out


static func dir_vec(dir: int) -> Vector2i:
	match dir:
		DIR_N:
			return Vector2i(0, -1)
		DIR_W:
			return Vector2i(-1, 0)
		DIR_S:
			return Vector2i(0, 1)
		DIR_E:
			return Vector2i(1, 0)
		_:
			return Vector2i.ZERO


static func dir_yaw(dir: int) -> float:
	match dir:
		DIR_N:
			return 0.0
		DIR_W:
			return 90.0
		DIR_S:
			return 180.0
		DIR_E:
			return 270.0
		_:
			return 0.0


static func dir_opposite(dir: int) -> int:
	return (dir + 2) % 4


static func dir_from_vec(v: Vector2i) -> int:
	if v == Vector2i(0, -1):
		return DIR_N
	if v == Vector2i(-1, 0):
		return DIR_W
	if v == Vector2i(0, 1):
		return DIR_S
	if v == Vector2i(1, 0):
		return DIR_E
	return -1


static func is_tall_compound(kind: int) -> bool:
	return kind == COMPOUND_CHAPEL or kind == COMPOUND_WATCHTOWER or kind == COMPOUND_COURTYARD_RUIN \
		or kind == COMPOUND_BOSS_MAUSOLEUM or kind == COMPOUND_HOUSE


static func rotate_offset_deg(offset: Vector3, yaw_deg: float) -> Vector3:
	return Basis(Vector3.UP, deg_to_rad(yaw_deg)) * offset
