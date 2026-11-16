class_name EnemyMove
extends RefCounted
## Um movimento do ciclo de um inimigo (GDD §6 "IA dos inimigos" e §7).

enum Kind { ATTACK, STRONG, HEAVY, CRUEL, MORTAL, HEAL }
## Ícone mostrado sobre a cabeça do inimigo um turno antes (GDD §6).
enum Intent { ATTACK, STRONG, COIN, HEAL }

var id: String = "attack"
var kind: Kind = Kind.ATTACK
var power: float = 1.0
var heal_percent: int = 0


static func make(move_id: String, move_kind: Kind, move_power: float = 1.0, heal: int = 0) -> EnemyMove:
	var move: EnemyMove = EnemyMove.new()
	move.id = move_id
	move.kind = move_kind
	move.power = move_power
	move.heal_percent = heal
	return move


static func basic_attack() -> EnemyMove:
	return make("attack", Kind.ATTACK)


func intent() -> Intent:
	match kind:
		Kind.STRONG:
			return Intent.STRONG
		Kind.HEAVY, Kind.CRUEL, Kind.MORTAL:
			return Intent.COIN
		Kind.HEAL:
			return Intent.HEAL
	return Intent.ATTACK


func is_coin() -> bool:
	return intent() == Intent.COIN


## Ataque forte ou golpe de moeda: precisa ser avisado antes de o jogador agir.
func is_dangerous() -> bool:
	return kind == Kind.STRONG or is_coin()
