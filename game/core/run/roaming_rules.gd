class_name RoamingRules
extends RefCounted
## Roaming boss do tipo Nemesis (GDD §13, ADR-0066, TASK-080). Números do medidor de alarme e da
## perseguição, sem nós e sem sorteio: tudo é contagem determinística. Mudar qualquer número daqui
## exige ADR e subir [constant CoreVersion.RULES_VERSION].

## Id do roaming boss nos dados (`game/data/enemies.json`, ficha `ENEMY-20`).
const ENEMY_ID: String = "crowned_pursuer"
## GDD §13, item 1: o medidor enche com fugir (+2), descansar na fogueira (+1) e derrotar elite (+1).
const ALARM_THRESHOLD: int = 4
const ALARM_FLEE: int = 2
const ALARM_REST: int = 1
const ALARM_ELITE: int = 1
## GDD §13, item 1: entra "em uma camada atrás da Bibiana"; aqui, a 3 nós de distância.
const START_DISTANCE: int = 3
## Só a partir da camada 2, para o primeiro movimento da Descida ficar livre.
const MIN_LAYER: int = 2
## Nível extra sobre o da camada (ameaça acima de um elite, GDD §13).
const LEVEL_BONUS: int = 1


## Verdadeiro se o cenário libera o roaming boss (flag `roaming_boss` nos dados; o cenário 1,
## o primeiro mapa curto e tutorial, fica de fora, ADR-0066).
static func enabled_for(scenario: Dictionary) -> bool:
	return bool(scenario.get("roaming_boss", false))
