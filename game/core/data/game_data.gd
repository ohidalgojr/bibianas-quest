class_name GameData
extends RefCounted
## Catálogo dos dados do jogo (ADR-0009). Recebe os documentos já lidos, valida com
## [DataValidator] e monta as unidades de combate. Não lê arquivos: isso é do
## [code]DataLoader[/code] em game/services.

const MOVE_KINDS: Dictionary = {
	"attack": EnemyMove.Kind.ATTACK,
	"strong": EnemyMove.Kind.STRONG,
	"heavy": EnemyMove.Kind.HEAVY,
	"cruel": EnemyMove.Kind.CRUEL,
	"mortal": EnemyMove.Kind.MORTAL,
	"heal": EnemyMove.Kind.HEAL,
}
const ELEMENTS: Dictionary = {
	"physical": CombatFormulas.Element.PHYSICAL,
	"fire": CombatFormulas.Element.FIRE,
	"lightning": CombatFormulas.Element.LIGHTNING,
	"holy": CombatFormulas.Element.HOLY,
	"shadow": CombatFormulas.Element.SHADOW,
}
const SKILL_EFFECTS: Dictionary = {
	"shield_bash": CombatSkill.Effect.SHIELD_BASH,
	"charge": CombatSkill.Effect.CHARGE,
	"bulwark": CombatSkill.Effect.BULWARK,
}

var errors: PackedStringArray = PackedStringArray()
var classes: Dictionary = {}
var combat_skills: Dictionary = {}
var campfire_skills: Dictionary = {}
var enemies: Dictionary = {}
var items: Dictionary = {}
var scenarios: Dictionary = {}


## Valida e indexa por id. Com erro, o catálogo fica vazio e [member errors] diz o motivo.
static func from_documents(documents: Dictionary) -> GameData:
	var data: GameData = GameData.new()
	data.errors = DataValidator.validate(documents)
	if not data.errors.is_empty():
		return data
	data.classes = _index(documents["classes"]["classes"])
	data.combat_skills = _index(documents["skills"]["combat"])
	data.campfire_skills = _index(documents["skills"]["campfire"])
	data.enemies = _index(documents["enemies"]["enemies"])
	data.items = _index(documents["items"]["items"])
	data.scenarios = _index(documents["scenarios"]["scenarios"])
	return data


static func _index(entries: Array) -> Dictionary:
	var found: Dictionary = {}
	for entry: Dictionary in entries:
		found[str(entry["id"])] = entry
	return found


func is_valid() -> bool:
	return errors.is_empty()


# --- Classe e skills -------------------------------------------------------------

func class_stats(class_id: String) -> Stats:
	return Stats.make(_entry(classes, class_id)["stats"])


## A Bibiana com a classe, no Poder dado (GDD §8 e §9).
func make_player(class_id: String, power: float = 1.0, unit_name: String = "Bibiana") -> Combatant:
	var entry: Dictionary = _entry(classes, class_id)
	var veteran: bool = str(entry["passive"]) == "veteran"
	return Combatant.player(unit_name, class_stats(class_id).scaled_for_power(power), veteran)


func class_skills(class_id: String) -> Array[CombatSkill]:
	var skills: Array[CombatSkill] = []
	for skill_id: Variant in _entry(classes, class_id)["skills"]:
		skills.append(combat_skill(str(skill_id)))
	return skills


func combat_skill(skill_id: String) -> CombatSkill:
	var entry: Dictionary = _entry(combat_skills, skill_id)
	return CombatSkill.make(skill_id, str(entry["name"]), int(entry["cost"]),
		SKILL_EFFECTS[str(entry["effect"])], float(entry["power"]))


# --- Itens -----------------------------------------------------------------------

## Consumível pronto para o combate. Devolve null se o item não for consumível.
func combat_item(item_id: String) -> CombatItem:
	var entry: Dictionary = _entry(items, item_id)
	if str(entry["slot"]) != "consumable":
		return null
	return CombatItem.make(item_id, int(entry["heal_hp_percent"]), int(entry["heal_mp_percent"]))


# --- Inimigos --------------------------------------------------------------------

## Atributos no nível pedido (ADR-0009): mesmas taxas do Poder (GDD §9), com
## 1 + (nível - nível base) como Poder equivalente. Abaixo do nível base não encolhe.
func enemy_stats(enemy_id: String, level: int) -> Stats:
	var entry: Dictionary = _entry(enemies, enemy_id)
	var stats: Stats = Stats.make(entry["stats"])
	return stats.scaled_for_power(level_power(level, int(entry["base_level"])))


static func level_power(level: int, base_level: int) -> float:
	return 1.0 + float(maxi(level - base_level, 0))


func make_enemy(enemy_id: String, level: int) -> Combatant:
	var entry: Dictionary = _entry(enemies, enemy_id)
	var phases: Array[EnemyPhase] = []
	for phase: Dictionary in entry["phases"]:
		var moves: Array[EnemyMove] = []
		for move: Dictionary in phase["moves"]:
			moves.append(EnemyMove.make(str(move["id"]), MOVE_KINDS[str(move["kind"])],
				float(move.get("power", 1.0)), int(move.get("heal_percent", 0))))
		phases.append(EnemyPhase.make(int(phase["below_hp_percent"]), moves))
	var boss: bool = str(entry["type"]) == "boss"
	var unit: Combatant = Combatant.enemy(str(entry["name"]), enemy_stats(enemy_id, level), phases, boss)
	var mults: Dictionary = entry["element_mults"]
	for element: Variant in mults:
		unit.element_mults[ELEMENTS[str(element)]] = float(mults[element])
	return unit


func enemy_type(enemy_id: String) -> String:
	return str(_entry(enemies, enemy_id)["type"])


func scenario(scenario_id: String) -> Dictionary:
	return _entry(scenarios, scenario_id)


func _entry(table: Dictionary, entry_id: String) -> Dictionary:
	assert(table.has(entry_id), "id inexistente nos dados: %s" % entry_id)
	return table[entry_id]
