class_name Simulator
extends RefCounted
## Simulador headless de balanceamento (GDD §23). Joga Descidas com um bot de
## referência e junta as métricas das metas de partida: vitória do cenário 1, turnos
## por combate comum, parcela de mortes por moeda e onde a Bibiana morre. Não escreve
## arquivo: o relatório sai como texto e quem grava é tools/simulate.gd.

var data: GameData
var profile: RunBot.Profile = RunBot.Profile.MEDIAN
var winnability_runs: int = 0
var first_run: bool = false

var runs: int = 0
var wins: int = 0
var deaths: int = 0
var coin_deaths: int = 0
## "camada N tipo" -> mortes.
var death_places: Dictionary = {}
## Tipo de inimigo -> [lutas, turnos do jogador, vitórias].
var fight_stats: Dictionary = {}
var boss_reached: int = 0
var boss_power_total: float = 0.0
var boss_hp_percent_total: int = 0
var boss_potions_total: int = 0
var power_total: float = 0.0
var gold_total: int = 0
var nodes_total: int = 0


func _init(game_data: GameData, bot_profile: RunBot.Profile = RunBot.Profile.MEDIAN, map_check_runs: int = 0, is_first_run: bool = false) -> void:
	data = game_data
	profile = bot_profile
	winnability_runs = map_check_runs
	first_run = is_first_run


func run_many(first_seed: int, count: int) -> void:
	for offset: int in count:
		run_one(first_seed + offset)


func run_one(run_seed: int) -> RunState:
	var run: RunState = RunState.new(data, run_seed, "warrior", [], winnability_runs, null, first_run)
	var bot: Pcg32 = Pcg32.new(run_seed, 7)
	var steps: int = 0
	while not run.is_over() and steps < RunBot.MAX_STEPS:
		steps += 1
		match run.phase:
			RunState.Phase.CHOOSING:
				run.choose_node(RunBot.pick_node(run, profile))
			RunState.Phase.FIGHT:
				_before_fight(run)
				RunBot.fight(run, bot, profile)
				_after_fight(run)
				run.finish_fight()
			RunState.Phase.SHOP:
				RunBot.shop(run, profile)
			RunState.Phase.CAMPFIRE:
				RunBot.campfire(run, profile)
	runs += 1
	power_total += run.power
	gold_total += run.gold
	nodes_total += run.nodes_cleared
	if run.phase == RunState.Phase.VICTORY:
		wins += 1
	elif run.phase == RunState.Phase.DEFEAT:
		deaths += 1
		var node: MapNode = run.current_node()
		var place: String = "camada %d %s" % [node.layer, MapNode.KIND_LETTERS[node.kind]]
		death_places[place] = int(death_places.get(place, 0)) + 1
	return run


func _before_fight(run: RunState) -> void:
	if run.current_node().kind != MapNode.Kind.BOSS:
		return
	boss_reached += 1
	boss_power_total += run.power
	boss_hp_percent_total += RunBot.hp_percent(run)
	boss_potions_total += run.consumable_count(RunBot.POTION_ID)


func _after_fight(run: RunState) -> void:
	var combat: Combat = run.combat
	var enemy_type: String = RunRules.enemy_type_for(run.current_node().kind, run.current_node().is_mutated())
	var row: Array = fight_stats.get(enemy_type, [0, 0, 0])
	row[0] = int(row[0]) + 1
	row[1] = int(row[1]) + player_turns(combat)
	if combat.outcome == Combat.Outcome.VICTORY:
		row[2] = int(row[2]) + 1
	fight_stats[enemy_type] = row
	if combat.outcome == Combat.Outcome.DEFEAT and killed_by_coin(combat):
		coin_deaths += 1


static func player_turns(combat: Combat) -> int:
	var turns: int = 0
	for event: CombatEvent in combat.history:
		if event.type == CombatEvent.Type.TURN and event.side == Combatant.PLAYER:
			turns += 1
	return turns


## A morte veio de um golpe de moeda: a última ação do inimigo antes do golpe final.
static func killed_by_coin(combat: Combat) -> bool:
	for index: int in range(combat.history.size() - 1, -1, -1):
		var event: CombatEvent = combat.history[index]
		if event.type == CombatEvent.Type.ACTION and event.side == Combatant.ENEMY:
			return event.value == EnemyMove.Intent.COIN
	return false


# --- Métricas ----------------------------------------------------------------------

func win_rate() -> float:
	return 100.0 * wins / maxi(runs, 1)


func coin_death_share() -> float:
	return 100.0 * coin_deaths / maxi(deaths, 1)


func turns_per_fight(enemy_type: String) -> float:
	var row: Array = fight_stats.get(enemy_type, [0, 0, 0])
	return float(row[1]) / maxi(int(row[0]), 1)


func fight_win_rate(enemy_type: String) -> float:
	var row: Array = fight_stats.get(enemy_type, [0, 0, 0])
	return 100.0 * int(row[2]) / maxi(int(row[0]), 1)


## Relatório em Markdown, com a meta do GDD §23 ao lado de cada métrica.
func report(title: String) -> String:
	var lines: PackedStringArray = PackedStringArray()
	lines.append("## %s" % title)
	lines.append("")
	lines.append("Bot %s, %d Descidas, regras v%d, dados format %d, checagem de mapa com %d simulações." % [
		RunBot.PROFILE_NAMES[profile], runs, CoreVersion.RULES_VERSION, DataValidator.FORMAT, winnability_runs])
	lines.append("")
	var win_target: String = "35% a 55% (1ª Descida, ADR-0031)" if first_run else "55% a 65% (jogador mediano)"
	lines.append("| Métrica | Valor | Meta (GDD §23) |")
	lines.append("| --- | --- | --- |")
	lines.append("| Vitória do cenário 1 | %.1f%% | %s |" % [win_rate(), win_target])
	lines.append("| Turnos por combate comum | %.1f | 6 a 10 |" % turns_per_fight("common"))
	lines.append("| Mortes causadas por moeda | %.1f%% (%d de %d) | 25%% ou menos |" % [coin_death_share(), coin_deaths, deaths])
	lines.append("| Chegou ao chefe | %.1f%% | |" % (100.0 * boss_reached / maxi(runs, 1)))
	lines.append("| Poder ao chegar no chefe | %.2f | |" % (boss_power_total / maxi(boss_reached, 1)))
	lines.append("| Vida ao chegar no chefe | %d%% | |" % (boss_hp_percent_total / maxi(boss_reached, 1)))
	lines.append("| Poções ao chegar no chefe | %.1f | |" % (float(boss_potions_total) / maxi(boss_reached, 1)))
	lines.append("| Poder médio no fim | %.2f | |" % (power_total / maxi(runs, 1)))
	lines.append("| Ouro médio no fim | %d | |" % (gold_total / maxi(runs, 1)))
	lines.append("")
	lines.append("| Inimigo | Lutas | Turnos por luta | Vitórias |")
	lines.append("| --- | --- | --- | --- |")
	for enemy_type: String in ["common", "mutated", "elite", "boss"]:
		if fight_stats.has(enemy_type):
			lines.append("| %s | %d | %.1f | %.1f%% |" % [enemy_type, int(fight_stats[enemy_type][0]),
				turns_per_fight(enemy_type), fight_win_rate(enemy_type)])
	lines.append("")
	lines.append("Mortes por lugar: %s" % _places_text())
	return "\n".join(lines)


func _places_text() -> String:
	var keys: Array = death_places.keys()
	keys.sort()
	var parts: PackedStringArray = PackedStringArray()
	for key: Variant in keys:
		parts.append("%s: %d" % [key, int(death_places[key])])
	return ", ".join(parts) if not parts.is_empty() else "nenhuma"
