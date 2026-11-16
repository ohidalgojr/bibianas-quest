class_name MapNode
extends RefCounted
## Um nó do mapa de um cenário (GDD §5). Só guarda dados; quem liga e sorteia é o
## [MapGraph] e o [MapGenerator]. Inimigo, nível, mutação e recompensa entram quando
## os dados do cenário existirem (TASK-005 em diante).

enum Kind { START, BATTLE, AMBUSH, ELITE, CHEST, EVENT, BONFIRE, MINI_BOSS, BOSS }

## Uma letra por tipo, na ordem de [enum Kind]; usada na assinatura do mapa.
const KIND_LETTERS: String = "SBAECVFMX"

var id: int = 0
## 0 é o ponto de partida, 1 a N são as camadas e N + 1 é o chefe.
var layer: int = 0
var column: int = 0
var kind: Kind = Kind.BATTLE
## Ids dos destinos na camada seguinte, em ordem crescente de coluna.
var next_ids: PackedInt32Array = PackedInt32Array()


func _init(node_id: int = 0, node_layer: int = 0, node_column: int = 0, node_kind: Kind = Kind.BATTLE) -> void:
	id = node_id
	layer = node_layer
	column = node_column
	kind = node_kind


func letter() -> String:
	return KIND_LETTERS[kind]


## Verdadeiro para os nós em que há combate.
func is_fight() -> bool:
	return kind == Kind.BATTLE or kind == Kind.AMBUSH or kind == Kind.ELITE \
		or kind == Kind.MINI_BOSS or kind == Kind.BOSS
