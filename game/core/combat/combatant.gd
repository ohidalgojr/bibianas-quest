class_name Combatant
extends RefCounted
## Uma unidade no combate 1 contra 1: a Bibiana ou o inimigo.

## Lados do combate. Constantes inteiras em vez de enum: o Godot 4.7 confunde o tipo
## de um enum usado dentro e fora da própria classe quando há dependência cíclica.
const PLAYER: int = 0
const ENEMY: int = 1

var display_name: String = ""
var side: int = PLAYER
var stats: Stats = Stats.new()
var hp: int = 1
var mp: int = 0
## Carga de turno (GDD §6): soma a VEL a cada tick e age ao chegar a 100.
var charge: int = 0
## Guerreiro: passiva Veterano (GDD §8).
var veteran: bool = false
var is_boss: bool = false
var can_flee: bool = true
## Elemento -> multiplicador (fraqueza 1,5; resistência 0,5).
var element_mults: Dictionary = {}
var effects: Array[CombatEffect] = []
var stunned: bool = false
var phases: Array[EnemyPhase] = []
var phase_index: int = 0
var cycle_index: int = 0
var intent: EnemyMove = null
var last_move: EnemyMove = null


static func player(unit_name: String, unit_stats: Stats, has_veteran: bool = false) -> Combatant:
	var unit: Combatant = Combatant.new()
	unit.display_name = unit_name
	unit.side = PLAYER
	unit.stats = unit_stats
	unit.hp = unit_stats.max_hp
	unit.mp = unit_stats.max_mp
	unit.veteran = has_veteran
	return unit


## Chefes não permitem fuga (GDD §6) e viram Lentidão em vez de atordoamento.
static func enemy(unit_name: String, unit_stats: Stats, unit_phases: Array[EnemyPhase], boss: bool = false) -> Combatant:
	var unit: Combatant = Combatant.new()
	unit.display_name = unit_name
	unit.side = ENEMY
	unit.stats = unit_stats
	unit.hp = unit_stats.max_hp
	unit.mp = unit_stats.max_mp
	unit.phases = unit_phases
	unit.is_boss = boss
	unit.can_flee = not boss
	return unit


func is_alive() -> bool:
	return hp > 0


func hp_percent() -> int:
	return roundi(100.0 * hp / stats.max_hp)


func effect_of(kind: CombatEffect.Kind) -> CombatEffect:
	for effect: CombatEffect in effects:
		if effect.kind == kind:
			return effect
	return null


func has_effect(kind: CombatEffect.Kind) -> bool:
	return effect_of(kind) != null


func effective_defense() -> float:
	var value: float = float(stats.defense)
	if has_effect(CombatEffect.Kind.BULWARK):
		value *= 1.0 + CombatEffect.BULWARK_DEFENSE
	if has_effect(CombatEffect.Kind.ARMOR_DOWN):
		value *= 1.0 - CombatEffect.ARMOR_DOWN_DEFENSE
	return value


## FOR com Fraqueza (GDD §11).
func effective_strength() -> float:
	return _weakened(stats.strength)


func effective_mind() -> float:
	return _weakened(stats.mind)


func _weakened(value: int) -> float:
	if has_effect(CombatEffect.Kind.WEAKENED):
		return value * (1.0 - CombatEffect.WEAK_ATTACK)
	return float(value)


func effective_resistance() -> float:
	return float(stats.resistance)


func effective_speed() -> int:
	if has_effect(CombatEffect.Kind.SLOWED):
		return maxi(1, roundi(stats.speed * (1.0 - CombatEffect.SLOW_SPEED)))
	return stats.speed


func element_multiplier(element: CombatFormulas.Element) -> float:
	return float(element_mults.get(element, 1.0))


## Fase de chefe com mais de uma fase, na última: libera golpes de moeda seguidos.
func in_final_phase() -> bool:
	return is_boss and phases.size() > 1 and phase_index == phases.size() - 1
