class_name Winnability
extends RefCounted
## Garantia de vencibilidade do mapa (GDD §5, ADR-0012). Escolhe o caminho mais seguro,
## simula o bot de referência nele e, se a vitória ficar abaixo da meta do cenário,
## suaviza o caminho (baixa o nível dos inimigos e troca uma batalha por baú) até
## [constant MAX_SMOOTHING] vezes. As simulações usam sementes derivadas da Descida e
## não gastam os fluxos dela.

## GDD §5: simula o bot 200 vezes no caminho mais seguro.
const DEFAULT_RUNS: int = 200
## GDD §5: até 5 tentativas de suavizar antes de descartar o mapa.
const MAX_SMOOTHING: int = 5
## Mapas novos antes de desistir e ficar com o último (ADR-0012).
const MAX_MAPS: int = 10
## Sal das sementes das simulações, longe dos índices dos quatro fluxos.
const PROBE_SALT: int = 1000

## Resultado da última checagem, para relatório e testes.
var win_rate: float = 0.0
var smoothing_steps: int = 0
var maps_discarded: int = 0
var passed: bool = false


## Custo de um nó na rota: nível do inimigo, elite pesando o dobro; baú e fogueira
## custam zero.
static func node_cost(node: MapNode) -> float:
	if not node.is_fight():
		return 0.0
	if node.kind == MapNode.Kind.ELITE:
		return 2.0 * node.level
	return float(node.level)


static func safest_route(graph: MapGraph) -> PackedInt32Array:
	return graph.safest_route(func(node: MapNode) -> float: return Winnability.node_cost(node))


## Vitória (%) do bot de referência seguindo [param route] a partir do estado de
## [param run], em até [param runs] simulações. Com [param target] (%), para assim que o
## resultado contra a meta estiver decidido: vitórias suficientes, ou derrotas demais
## para alcançá-la mesmo vencendo o resto. A decisão é a mesma das [param runs] inteiras.
static func route_win_rate(run: RunState, route: PackedInt32Array, runs: int, salt: int, target: float = -1.0) -> float:
	var wins: int = 0
	var played: int = 0
	var needed: int = ceili(target * runs / 100.0)
	for index: int in runs:
		var probe_seed: int = RngStreams.derive_seed(run.streams.run_seed, PROBE_SALT + salt * runs + index)
		var probe: RunState = probe_from(run, probe_seed)
		RunBot.play_route(probe, route, probe_seed, RunBot.Profile.MEDIAN)
		played += 1
		if probe.phase == RunState.Phase.VICTORY:
			wins += 1
		if target >= 0.0 and (wins >= needed or wins + runs - played < needed):
			break
	return 100.0 * wins / maxi(played, 1)


## Cópia do estado de [param run] no começo do cenário atual, com o mesmo mapa e fluxos
## próprios. O cenário do teste é só o atual: vencer o chefe encerra a simulação.
static func probe_from(run: RunState, probe_seed: int) -> RunState:
	var scenarios: Array[String] = [run.scenario_ids[run.scenario_index]]
	var probe: RunState = RunState.new(run.data, probe_seed, run.class_id, scenarios, 0, run.map, run.first_run)
	probe.map = run.map
	probe.current_node_id = run.map.start_id
	probe.power = run.power
	probe.hp = run.hp
	probe.mp = run.mp
	probe.consumables = run.consumables.duplicate()
	probe.equipment = run.equipment.duplicate()
	probe.buffs = run.buffs.duplicate()
	probe.first_chest_opened = run.first_chest_opened
	return probe


## Confere o mapa atual de [param run] e suaviza o caminho mais seguro se preciso.
## Devolve true se a meta foi atingida.
func check(run: RunState, config: MapConfig, runs: int, target: float, attempt: int) -> bool:
	var entry: Dictionary = run.scenario()
	for step: int in MAX_SMOOTHING + 1:
		var route: PackedInt32Array = safest_route(run.map)
		win_rate = route_win_rate(run, route, runs, attempt * (MAX_SMOOTHING + 1) + step, target)
		if win_rate >= target:
			passed = true
			return true
		if step == MAX_SMOOTHING:
			break
		smooth(run.map, config, route, int(entry["min_level"]))
		smoothing_steps += 1
	passed = false
	return false


## Suavização (GDD §5): baixa em 1 o nível dos inimigos do caminho (menos o chefe, sem
## passar do mínimo do cenário) e troca a batalha de maior nível por um baú, se isso
## não quebrar as regras do mapa.
static func smooth(graph: MapGraph, config: MapConfig, route: PackedInt32Array, min_level: int) -> void:
	var swap: MapNode = null
	for node_id: int in route:
		var node: MapNode = graph.node_by_id(node_id)
		if not node.is_fight() or node.kind == MapNode.Kind.BOSS:
			continue
		node.level = maxi(node.level - 1, min_level)
		if node.layer >= 2 and (node.kind == MapNode.Kind.BATTLE or node.kind == MapNode.Kind.AMBUSH) \
				and (swap == null or node.level > swap.level):
			swap = node
	if swap == null:
		return
	var old_kind: MapNode.Kind = swap.kind
	var old_enemy: String = swap.enemy_id
	var old_level: int = swap.level
	swap.kind = MapNode.Kind.CHEST
	swap.enemy_id = ""
	if not MapRules.find_violations(graph, config).is_empty():
		swap.kind = old_kind
		swap.enemy_id = old_enemy
		swap.level = old_level
