extends GutTest
## Simulador de balanceamento (GDD §23): métricas e relatório.

var _data: GameData


func before_all() -> void:
	_data = DataLoader.load_all()


func test_simulator_collects_metrics() -> void:
	var sim: Simulator = Simulator.new(_data, RunBot.Profile.MEDIAN)
	sim.run_many(100, 40)
	assert_eq(sim.runs, 40)
	assert_eq(sim.wins + sim.deaths, 40, "toda Descida termina em vitória ou morte")
	assert_gt(int(sim.fight_stats["common"][0]), 40, "várias lutas comuns por Descida")
	assert_between(sim.turns_per_fight("common"), 3.0, 15.0)
	assert_between(sim.win_rate(), 0.0, 100.0)
	var text: String = sim.report("teste")
	assert_string_contains(text, "| Vitória do cenário 1 |")
	assert_string_contains(text, "55% a 65%")
	assert_string_contains(text, "| Mortes causadas por moeda |")
	assert_string_contains(text, "Bot mediano, 40 Descidas, regras v%d" % CoreVersion.RULES_VERSION)


func test_same_seeds_same_report() -> void:
	var first: Simulator = Simulator.new(_data, RunBot.Profile.CAREFUL)
	first.run_many(7, 15)
	var second: Simulator = Simulator.new(_data, RunBot.Profile.CAREFUL)
	second.run_many(7, 15)
	assert_eq(second.report("x"), first.report("x"))


## A morte conta como "por moeda" quando a última ação do inimigo foi golpe de moeda.
func test_killed_by_coin() -> void:
	var combat: Combat = Combat.new(CombatFixtures.warrior(), CombatFixtures.grunt(), RngStreams.new(1), CoinState.new())
	combat.history.append(CombatEvent.make(CombatEvent.Type.ACTION, Combatant.ENEMY, "heavy", EnemyMove.Intent.COIN))
	combat.history.append(CombatEvent.make(CombatEvent.Type.COIN, Combatant.PLAYER, "heavy", 50, false))
	combat.history.append(CombatEvent.make(CombatEvent.Type.DAMAGE, Combatant.PLAYER, "heavy", 30, false, 0))
	assert_true(Simulator.killed_by_coin(combat))
	combat.history.append(CombatEvent.make(CombatEvent.Type.ACTION, Combatant.ENEMY, "attack", EnemyMove.Intent.ATTACK))
	combat.history.append(CombatEvent.make(CombatEvent.Type.DAMAGE, Combatant.PLAYER, "attack", 10, false, 0))
	assert_false(Simulator.killed_by_coin(combat))


func test_careful_bot_reads_coin_intents() -> void:
	var run: RunState = RunState.new(_data, 3)
	var node: MapNode = run.options()[0]
	node.kind = MapNode.Kind.BATTLE
	node.enemy_id = "plague_hound"
	node.level = 1
	run.choose_node(node.id)
	run.combat.enemy.intent = EnemyMove.make("heavy", EnemyMove.Kind.HEAVY)
	RunBot._careful_turn(run, run.combat)
	var defended: bool = false
	for event: CombatEvent in run.combat.history:
		if event.type == CombatEvent.Type.ACTION and event.side == Combatant.PLAYER and event.label == "defend":
			defended = true
	assert_true(defended, "o cuidadoso sempre defende golpe de moeda")
