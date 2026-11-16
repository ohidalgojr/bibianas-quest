class_name CombatTexts
extends RefCounted
## Textos da tela de combate em português. Os números das consequências da moeda vêm
## das constantes do núcleo (GDD §7), nunca repetidos aqui.

const MOVE_NAMES: Dictionary = {
	EnemyMove.Kind.ATTACK: "Ataque",
	EnemyMove.Kind.STRONG: "Ataque forte",
	EnemyMove.Kind.HEAVY: "Golpe Pesado",
	EnemyMove.Kind.CRUEL: "Golpe Cruel",
	EnemyMove.Kind.MORTAL: "Golpe Mortal",
	EnemyMove.Kind.HEAL: "Cura",
}
const INTENT_ICONS: Dictionary = {
	EnemyMove.Intent.ATTACK: "ATAQUE",
	EnemyMove.Intent.STRONG: "FORTE",
	EnemyMove.Intent.COIN: "MOEDA",
	EnemyMove.Intent.HEAL: "CURA",
}
const EFFECT_NAMES: Dictionary = {
	"defending": "Defendendo",
	"bulwark": "Muralha",
	"armor_down": "Guarda aberta",
	"slowed": "Lentidão",
	"stunned": "Atordoado",
}
const PLAYER_ACTIONS: Dictionary = {
	"attack": "Ataque",
	"defend": "Defesa",
	"flee": "Fuga",
	"reflect": "reflexo da Muralha",
}
const OUTCOMES: Dictionary = {
	Combat.Outcome.ONGOING: "A luta continua.",
	Combat.Outcome.VICTORY: "Vitória!",
	Combat.Outcome.DEFEAT: "Derrota.",
	Combat.Outcome.FLED: "Você fugiu.",
}


static func move_name(kind: EnemyMove.Kind) -> String:
	return str(MOVE_NAMES.get(kind, "Golpe"))


static func intent_icon(intent: EnemyMove.Intent) -> String:
	return str(INTENT_ICONS.get(intent, "?"))


static func effect_name(label: String) -> String:
	return str(EFFECT_NAMES.get(label, label))


static func outcome(result: int) -> String:
	return str(OUTCOMES.get(result, ""))


## Consequência de Cara e Coroa do golpe de moeda (GDD §7, "Onde a moeda aparece").
static func coin_stakes(kind: EnemyMove.Kind) -> String:
	match kind:
		EnemyMove.Kind.HEAVY:
			return "Coroa: dano +%d%%" % _percent(CombatFormulas.HEAVY_FAIL)
		EnemyMove.Kind.CRUEL:
			return "Cara: dano -%d%%. Coroa: dano +%d%%" % [
				-_percent(CombatFormulas.CRUEL_SUCCESS), _percent(CombatFormulas.CRUEL_FAIL)]
		EnemyMove.Kind.MORTAL:
			return "Coroa: dano +%d%%" % _percent(CombatFormulas.MORTAL_FAIL)
	return ""


static func coin_result(success: bool) -> String:
	return "Cara (sucesso)" if success else "Coroa (falha)"


static func _percent(multiplier: float) -> int:
	return roundi((multiplier - 1.0) * 100.0)
