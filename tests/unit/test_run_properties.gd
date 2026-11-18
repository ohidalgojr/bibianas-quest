extends GutTest
## Descidas inteiras jogadas pelo bot de regras (ADR-0011): toda Descida termina, o
## estado nunca fica inválido e a mesma semente reproduz a mesma Descida. Amostra enxuta
## enquanto o foco está no MVP jogável com gráficos e som.

const RUNS: int = 20

var _data: GameData


func before_all() -> void:
	_data = DataLoader.load_all()


func _problems(run: RunState) -> PackedStringArray:
	var found: PackedStringArray = PackedStringArray()
	if not run.is_over():
		found.append("não terminou na fase %s" % RunState.Phase.keys()[run.phase])
	var max_hp: int = run.player_stats().max_hp
	if run.hp < 0 or run.hp > max_hp:
		found.append("HP fora dos limites: %d de %d" % [run.hp, max_hp])
	if run.mp < 0 or run.mp > run.player_stats().max_mp:
		found.append("MP fora dos limites: %d" % run.mp)
	if run.gold < 0:
		found.append("ouro negativo")
	if run.power < 1.0:
		found.append("Poder abaixo de 1")
	if run.total_consumables() > RunRules.MAX_CONSUMABLES:
		found.append("consumíveis acima do limite")
	for item_id: String in run.consumables:
		if run.consumable_count(item_id) < 0:
			found.append("%s negativo" % item_id)
	if run.phase == RunState.Phase.VICTORY and run.current_node_id != run.map.boss_id:
		found.append("vitória fora do chefe")
	if run.phase == RunState.Phase.DEFEAT and run.hp != 0:
		found.append("derrota com vida")
	return found


func test_property_bot_runs_always_end_in_valid_state() -> void:
	for profile: int in [RunBot.Profile.MEDIAN, RunBot.Profile.CAREFUL]:
		_check_profile(profile)


func _check_profile(profile: RunBot.Profile) -> void:
	var problems: PackedStringArray = PackedStringArray()
	var wins: int = 0
	var power_total: float = 0.0
	var gold_total: int = 0
	var nodes_total: int = 0
	for run_seed: int in RUNS:
		var run: RunState = RunBot.play(_data, run_seed, profile)
		var found: PackedStringArray = _problems(run)
		if not found.is_empty() and problems.size() < 5:
			problems.append("semente %d: %s" % [run_seed, " | ".join(found)])
		if run.phase == RunState.Phase.VICTORY:
			wins += 1
		power_total += run.power
		gold_total += run.gold
		nodes_total += run.nodes_cleared
	assert_eq(" || ".join(problems), "")
	gut.p("bot %s, cenário 1: %d%% de vitórias, Poder médio %.2f, ouro médio %d, %.1f nós por Descida" % [
		RunBot.PROFILE_NAMES[profile], roundi(100.0 * wins / RUNS), power_total / RUNS, gold_total / RUNS,
		float(nodes_total) / RUNS])
	assert_gt(wins, 0, "o bot vence às vezes")
	assert_lt(wins, RUNS, "o bot perde às vezes")


func test_same_seed_same_run() -> void:
	for run_seed: int in 5:
		var first: String = RunBot.summary(RunBot.play(_data, run_seed))
		assert_eq(RunBot.summary(RunBot.play(_data, run_seed)), first, "semente %d" % run_seed)
	assert_ne(RunBot.summary(RunBot.play(_data, 1)), RunBot.summary(RunBot.play(_data, 2)), "sementes diferentes variam")
