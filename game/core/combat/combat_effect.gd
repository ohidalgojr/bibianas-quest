class_name CombatEffect
extends RefCounted
## Efeito temporário em uma unidade. A duração conta turnos de quem tem o efeito e cai
## no início de cada turno dela (ADR-0008).

enum Kind { DEFENDING, BULWARK, ARMOR_DOWN, SLOWED, POISON, WEAKENED }

## Muralha: DEF +50% e reflete 20% do dano físico (GDD §8).
const BULWARK_DEFENSE: float = 0.5
const BULWARK_REFLECT: float = 0.2
## Investida: DEF -20% (GDD §8).
const ARMOR_DOWN_DEFENSE: float = 0.2
## Lentidão: VEL -30% por 3 turnos (GDD §11).
const SLOW_SPEED: float = 0.3
const SLOW_TURNS: int = 3

## Veneno: 5% do HP máximo por turno, 4 turnos (GDD §11).
const POISON_PERCENT: int = 5
const POISON_TURNS: int = 4
## Fraqueza: ATK (FOR e MEN) -25% por 3 turnos (GDD §11).
const WEAK_ATTACK: float = 0.25
const WEAK_TURNS: int = 3
## Defender corta pela metade a chance de um debuff de golpe (ADR-0020).
const DEFEND_CHANCE_FACTOR: float = 0.5

const LABELS: Array[String] = ["defending", "bulwark", "armor_down", "slowed", "poison", "weakened"]

## Duração padrão do efeito de debuff de um golpe.
static func debuff_turns(effect_kind: Kind) -> int:
	return POISON_TURNS if effect_kind == Kind.POISON else WEAK_TURNS



var kind: Kind = Kind.DEFENDING
var turns_left: int = 1


static func make(effect_kind: Kind, turns: int) -> CombatEffect:
	var effect: CombatEffect = CombatEffect.new()
	effect.kind = effect_kind
	effect.turns_left = turns
	return effect


func label() -> String:
	return LABELS[kind]
