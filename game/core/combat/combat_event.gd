class_name CombatEvent
extends RefCounted
## Evento que o núcleo emite para a apresentação (GDD §20): a cena anima a partir
## daqui, sem ler o estado interno do combate.
##
## Campos por tipo:
## - TURN: side = quem age.
## - INTENT: label = id do golpe; value = [enum EnemyMove.Intent]; extra = motivo da reação do inimigo, 0 se for o ciclo (ADR-0030).
## - ACTION: label = ação, skill ou golpe; value = custo de MP (jogador) ou intenção (inimigo).
## - MISS: side = atacante; label = ação.
## - DAMAGE: side = quem recebe; label = ação; value = dano; flag = crítico; extra = vida depois.
## - HEAL: side = quem cura; value = HP recuperado; extra = MP recuperado.
## - COIN: label = motivo; value = chance (%); flag = Cara; extra = bônus da Maré de azar.
## - EFFECT_ON, EFFECT_OFF: side = quem tem; label = efeito; value = turnos.
## - STUN_SKIP: side = quem perdeu o turno; label = golpe cancelado.
## - PHASE: side = inimigo; value = nova fase.
## - FLEE_FAILED: sem campos.
## - ENDED: value = [enum Combat.Outcome].
## - DISEASE: label = id da doença pega pela Bibiana (ADR-0030).

enum Type { STARTED, TURN, INTENT, ACTION, MISS, DAMAGE, HEAL, COIN, EFFECT_ON, EFFECT_OFF, STUN_SKIP, PHASE, FLEE_FAILED, ENDED, DISEASE }

const TYPE_NAMES: Array[String] = ["STARTED", "TURN", "INTENT", "ACTION", "MISS", "DAMAGE", "HEAL", "COIN", "EFFECT_ON", "EFFECT_OFF", "STUN_SKIP", "PHASE", "FLEE_FAILED", "ENDED", "DISEASE"]

var type: Type = Type.STARTED
var side: int = Combatant.PLAYER
var label: String = ""
var value: int = 0
var flag: bool = false
var extra: int = 0


static func make(event_type: Type, event_side: int, event_label: String = "", event_value: int = 0,
		event_flag: bool = false, event_extra: int = 0) -> CombatEvent:
	var event: CombatEvent = CombatEvent.new()
	event.type = event_type
	event.side = event_side
	event.label = event_label
	event.value = event_value
	event.flag = event_flag
	event.extra = event_extra
	return event


func describe() -> String:
	return "%s %s %s %d %s %d" % [TYPE_NAMES[type], "P" if side == Combatant.PLAYER else "E", label, value, "1" if flag else "0", extra]
