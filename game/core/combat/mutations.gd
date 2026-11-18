class_name Mutations
extends RefCounted
## Mutações de inimigos comuns (GDD §5 e §11, ADR-0032). Sempre visíveis no mapa antes da
## luta; deixam o inimigo mais forte e rendem Poder ×1,5, melhores drops e mais chance de
## Moeda da Sorte. A mutação de cada inimigo sai de game/data/enemies.json.

const BLOATED: String = "bloated"
const VORACIOUS: String = "voracious"
const PHANTOM: String = "phantom"
const THORNY: String = "thorny"

const BLOATED_HP_MULT: float = 1.5
const BLOATED_SPEED_DELTA: int = -2
const VORACIOUS_HEAL_PERCENT: int = 25
const PHANTOM_EVASION_BONUS: int = 15
const THORNY_REFLECT_PERCENT: int = 15

const DEFS: Dictionary = {
	BLOATED: {"name": "Inchado", "summary": "+50% HP, VEL -2"},
	VORACIOUS: {"name": "Voraz", "summary": "cura 25% do dano causado"},
	PHANTOM: {"name": "Fantasma", "summary": "ESQ +15"},
	THORNY: {"name": "Espinhoso", "summary": "reflete 15% do dano físico"},
}


static func is_known(mutation_id: String) -> bool:
	return DEFS.has(mutation_id)


static func display_name(mutation_id: String) -> String:
	return str(DEFS[mutation_id]["name"]) if DEFS.has(mutation_id) else mutation_id


static func summary(mutation_id: String) -> String:
	return str(DEFS[mutation_id]["summary"]) if DEFS.has(mutation_id) else ""


## Aplica os modificadores da mutação ao inimigo antes do combate começar.
static func apply_to(unit: Combatant, mutation_id: String) -> void:
	if mutation_id.is_empty() or not is_known(mutation_id):
		return
	unit.mutation = mutation_id
	unit.display_name = "%s (%s)" % [unit.display_name, display_name(mutation_id)]
	match mutation_id:
		BLOATED:
			unit.stats.max_hp = maxi(roundi(unit.stats.max_hp * BLOATED_HP_MULT), 1)
			unit.hp = unit.stats.max_hp
			unit.stats.speed = maxi(unit.stats.speed + BLOATED_SPEED_DELTA, 1)
		PHANTOM:
			unit.stats.evasion += PHANTOM_EVASION_BONUS
