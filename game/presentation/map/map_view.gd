class_name MapView
extends RefCounted
## O que a tela do mapa mostra, montado a partir do [RunState] (ADR-0013). Sem nós e sem
## regra própria: destinos, névoa e caminho feito saem do estado do núcleo.
##
## Estados de um nó na tela:
## - OPTION: um dos 3 destinos; mostra tipo, inimigo e nível e aceita toque (GDD §5).
## - CURRENT: onde a Bibiana está.
## - VISITED: já passou por ele.
## - FOG: camada à frente dos destinos; silhueta sem tipo.
## - PAST: camada já passada, nó não visitado; esmaecido e sem tipo.
## - BOSS: o chefe, sempre visível.

enum State { OPTION, CURRENT, VISITED, FOG, PAST, BOSS }

const KIND_NAMES: Dictionary = {
	MapNode.Kind.START: "Partida",
	MapNode.Kind.BATTLE: "Luta",
	MapNode.Kind.AMBUSH: "Emboscada",
	MapNode.Kind.ELITE: "Elite",
	MapNode.Kind.CHEST: "Baú",
	MapNode.Kind.EVENT: "Evento",
	MapNode.Kind.BONFIRE: "Fogueira",
	MapNode.Kind.MINI_BOSS: "Mini boss",
	MapNode.Kind.BOSS: "Chefe",
}

var run: RunState


func _init(run_state: RunState) -> void:
	run = run_state


static func kind_name(kind: MapNode.Kind) -> String:
	return str(KIND_NAMES.get(kind, "?"))


## Ids dos nós por onde a Bibiana passou, na ordem (eventos NODE da Descida, no
## cenário atual).
func visited_ids() -> PackedInt32Array:
	var found: PackedInt32Array = PackedInt32Array()
	for event: RunEvent in run.history:
		if event.type == RunEvent.Type.SCENARIO:
			found.clear()
		elif event.type == RunEvent.Type.NODE:
			found.append(event.value)
	return found


func option_ids() -> PackedInt32Array:
	var found: PackedInt32Array = PackedInt32Array()
	for option: MapNode in run.options():
		found.append(option.id)
	return found


## Camada mais alta que o jogador enxerga com tipo: a dos destinos, ou a atual.
func visible_layer() -> int:
	var options: Array[MapNode] = run.options()
	if not options.is_empty():
		return options[0].layer
	return run.current_node().layer


func state_of(node: MapNode) -> State:
	if node.id == run.current_node_id:
		return State.CURRENT
	if option_ids().has(node.id):
		return State.OPTION
	if node.kind == MapNode.Kind.BOSS:
		return State.BOSS
	if node.kind == MapNode.Kind.START or visited_ids().has(node.id):
		return State.VISITED
	if node.layer > visible_layer():
		return State.FOG
	return State.PAST


## Texto do nó na tela: tipo e detalhe só onde o jogador pode ver (GDD §5).
func node_view(node: MapNode) -> Dictionary:
	var state: State = state_of(node)
	var shows_kind: bool = state != State.FOG and state != State.PAST
	var detail: String = ""
	if shows_kind and node.is_fight() and not node.enemy_id.is_empty():
		var enemy_name: String = str(run.data.enemies[node.enemy_id]["name"])
		if state == State.BOSS:
			detail = "%s te espera, nv %d" % [enemy_name, node.level]
		else:
			detail = "%s, nv %d" % [enemy_name, node.level]
	return {
		"id": node.id,
		"layer": node.layer,
		"column": node.column,
		"state": state,
		"kind": node.kind if shows_kind else -1,
		"title": kind_name(node.kind) if shows_kind else ("?" if state == State.FOG else ""),
		"detail": detail,
		"clickable": state == State.OPTION,
	}


func nodes() -> Array[Dictionary]:
	var found: Array[Dictionary] = []
	for node: MapNode in run.map.nodes:
		found.append(node_view(node))
	return found


## Ligações [de, para, destaque]. Destaque nas que saem do nó atual para os destinos e
## nas do caminho feito. Nós fora do alcance da partida (ADR-0007) não ligam nada.
func edges() -> Array[Array]:
	var found: Array[Array] = []
	var path: PackedInt32Array = PackedInt32Array([run.map.start_id])
	path.append_array(visited_ids())
	var options: PackedInt32Array = option_ids()
	var reachable: PackedInt32Array = run.map.reachable_ids()
	for node: MapNode in run.map.nodes:
		if not reachable.has(node.id):
			continue
		for next_id: int in node.next_ids:
			var walked: bool = path.has(node.id) and path.has(next_id)
			var offered: bool = node.id == run.current_node_id and options.has(next_id)
			found.append([node.id, next_id, walked or offered])
	return found


## Linha de doenças ativas, vazia se não há (ADR-0030).
func _disease_line() -> String:
	if run.diseases.is_empty():
		return ""
	var names: PackedStringArray = PackedStringArray()
	for disease_id: String in run.diseases:
		names.append(Diseases.display_name(disease_id))
	return "\nDoença: " + ", ".join(names)


## Cabeçalho do mapa: cenário, Poder, ouro, HP, MP e poções.
func header() -> String:
	var stats: Stats = run.player_stats()
	return "%s, camada %d de %d\nNível %d (Poder %.2f)   Ouro %d   Derrotados %d\nHP %d/%d   MP %d/%d   Poções %d   Galhos %d\nFOR %d   DEF %d   VEL %d%s" % [
		str(run.scenario()["name"]), maxi(run.current_node().layer, 0), run.map.layer_count,
		run.level(), run.power, run.gold, run.enemies_defeated, run.hp, stats.max_hp, run.mp, stats.max_mp,
		run.consumable_count("murky_potion"), run.consumable_count(RunRules.FIREWOOD_ID), stats.strength, stats.defense, stats.speed, _disease_line()]
