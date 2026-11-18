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
	EnemyMove.Kind.DEBUFF: "Debilitar",
}
## Nome de golpes de debuff por id (ADR-0020).
const MOVE_ID_NAMES: Dictionary = {
	"rot": "Toque Podre",
	"curse": "Maldição do Coveiro",
	"feverish_hug": "Abraço Febril",
	"filthy_bite": "Mordida Imunda",
	"eye_peck": "Bicada nos Olhos",
	"unrelenting_fangs": "Presas que Não Soltam",
	"guillotine": "Guilhotina",
	"shovel": "Pá",
	"grave": "Cova Rasa",
	"lunge": "Bote",
	"frenzy": "Frenesi",
	"dive": "Mergulho",
	"maul": "Estraçalhar",
	"beheading": "Decapitação",
	"sweep": "Varredura",
}
## Por que o inimigo reagiu, pelo código do evento de intenção (ADR-0030).
const REACTION_TEXTS: Dictionary = {
	1: "Viu que você está ferido",
	2: "Está acuado",
	3: "Cansou de esperar sua guarda",
	4: "Não tolera quem se fortalece",
}
const INTENT_ICONS: Dictionary = {
	EnemyMove.Intent.ATTACK: "ATAQUE",
	EnemyMove.Intent.STRONG: "FORTE",
	EnemyMove.Intent.COIN: "MOEDA",
	EnemyMove.Intent.HEAL: "CURA",
	EnemyMove.Intent.DEBUFF: "DEBILITA",
}
const EFFECT_NAMES: Dictionary = {
	"defending": "Defendendo",
	"bulwark": "Muralha",
	"armor_down": "Guarda aberta",
	"slowed": "Lentidão",
	"stunned": "Atordoado",
	"poison": "Veneno",
	"weakened": "Fraqueza",
	"empowered": "Fúria",
	"blinded": "Cegueira",
	"cursed": "Maldição",
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


static func move_name(kind: EnemyMove.Kind, move_id: String = "") -> String:
	if MOVE_ID_NAMES.has(move_id):
		return str(MOVE_ID_NAMES[move_id])
	return str(MOVE_NAMES.get(kind, "Golpe"))


static func intent_icon(intent: EnemyMove.Intent) -> String:
	return str(INTENT_ICONS.get(intent, "?"))


static func effect_name(label: String) -> String:
	return str(EFFECT_NAMES.get(label, label))


static func outcome(result: int) -> String:
	return str(OUTCOMES.get(result, ""))


## Consequência de acertar e de errar o lado do golpe de moeda (GDD §7, "Onde a moeda
## aparece").
static func coin_stakes(kind: EnemyMove.Kind) -> String:
	match kind:
		EnemyMove.Kind.HEAVY:
			return "Errar: dano +%d%%" % _percent(CombatFormulas.HEAVY_FAIL)
		EnemyMove.Kind.CRUEL:
			return "Acertar: dano -%d%%. Errar: dano +%d%%" % [
				-_percent(CombatFormulas.CRUEL_SUCCESS), _percent(CombatFormulas.CRUEL_FAIL)]
		EnemyMove.Kind.MORTAL:
			return "Errar: dano +%d%%" % _percent(CombatFormulas.MORTAL_FAIL)
	return ""


## Consequência extra de errar o lado em um golpe de moeda temático (ADR-0030), em texto.
static func fail_text(move: EnemyMove) -> String:
	var parts: PackedStringArray = PackedStringArray()
	if move.fail_effect_kind >= 0:
		parts.append("%s por %d turnos" % [effect_label(move.fail_effect_kind as CombatEffect.Kind), CombatEffect.debuff_turns(move.fail_effect_kind as CombatEffect.Kind)])
	if not move.fail_disease.is_empty():
		var def: Dictionary = Diseases.DEFS[move.fail_disease]
		parts.append("%s (%d%% de HP máx. até a fogueira)" % [str(def["name"]), int(def["max_hp_percent"])])
	if parts.is_empty():
		return ""
	return " e " + " e ".join(parts)


static func side_name(side: int) -> String:
	return "Cara" if side == CoinRules.HEADS else "Coroa"


## Lado em que a moeda cai (ADR-0014): o escolhido se o lance dá sucesso, o outro se falha.
static func landed_side(called: int, success: bool) -> int:
	if success:
		return called
	return CoinRules.TAILS if called == CoinRules.HEADS else CoinRules.HEADS


static func effect_label(kind: CombatEffect.Kind) -> String:
	return effect_name(CombatEffect.LABELS[kind])


static func coin_result(called: int, success: bool) -> String:
	return "Saiu %s: %s" % [side_name(landed_side(called, success)), "acertou!" if success else "errou."]


static func _percent(multiplier: float) -> int:
	return roundi((multiplier - 1.0) * 100.0)
