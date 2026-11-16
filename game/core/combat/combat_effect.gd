class_name CombatEffect
extends RefCounted
## Efeito temporário em uma unidade. A duração conta turnos de quem tem o efeito e cai
## no início de cada turno dela (ADR-0008).

enum Kind { DEFENDING, BULWARK, ARMOR_DOWN, SLOWED }

## Muralha: DEF +50% e reflete 20% do dano físico (GDD §8).
const BULWARK_DEFENSE: float = 0.5
const BULWARK_REFLECT: float = 0.2
## Investida: DEF -20% (GDD §8).
const ARMOR_DOWN_DEFENSE: float = 0.2
## Lentidão: VEL -30% por 3 turnos (GDD §11).
const SLOW_SPEED: float = 0.3
const SLOW_TURNS: int = 3

const LABELS: Array[String] = ["defending", "bulwark", "armor_down", "slowed"]

var kind: Kind = Kind.DEFENDING
var turns_left: int = 1


static func make(effect_kind: Kind, turns: int) -> CombatEffect:
	var effect: CombatEffect = CombatEffect.new()
	effect.kind = effect_kind
	effect.turns_left = turns
	return effect


func label() -> String:
	return LABELS[kind]
