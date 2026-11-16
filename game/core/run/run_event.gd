class_name RunEvent
extends RefCounted
## Evento da Descida para a apresentação (GDD §20), como o [CombatEvent] no combate.
##
## Campos por tipo:
## - SCENARIO: label = id do cenário; value = índice na Descida.
## - NODE: label = tipo do nó; value = id do nó.
## - FIGHT_STARTED: label = id do inimigo; value = nível.
## - FIGHT_ENDED: value = [enum Combat.Outcome].
## - POWER: amount = ganho; value = HP máximo depois.
## - GOLD: label = origem (fight, chest); value = ouro ganho.
## - SPENT: label = em quê (item, reroll); value = ouro gasto.
## - ITEM_USED, ITEM_GAINED: label = id do item; value = quantidade.
## - EQUIPPED: label = id do item; value = 0.
## - CAMPFIRE: label = ação (open, rest, id da skill, leave); value = Brasas restantes.
## - SHOP: label = open, reroll ou leave; value = quantos itens à venda.
## - ENDED: value = 1 vitória, 0 derrota.

enum Type { SCENARIO, NODE, FIGHT_STARTED, FIGHT_ENDED, POWER, GOLD, SPENT, ITEM_USED, ITEM_GAINED, EQUIPPED, CAMPFIRE, SHOP, ENDED }

var type: Type = Type.SCENARIO
var label: String = ""
var value: int = 0
var amount: float = 0.0


static func make(event_type: Type, event_label: String = "", event_value: int = 0, event_amount: float = 0.0) -> RunEvent:
	var event: RunEvent = RunEvent.new()
	event.type = event_type
	event.label = event_label
	event.value = event_value
	event.amount = event_amount
	return event
