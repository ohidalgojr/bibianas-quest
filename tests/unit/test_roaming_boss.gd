extends GutTest
## TASK-080 (ADR-0066): roaming boss Nemesis do GDD §13: medidor de alarme, perseguição determinística,
## parada em fogueira, encontro forçado sem fuga e recompensa. Núcleo puro, sem sorteio.

var _data: GameData


func before_all() -> void:
	_data = DataLoader.load_all()


func _run(seed_value: int = 5) -> RunState:
	var run: RunState = RunState.new(_data, seed_value, "warrior", [], 0, null, false, [])
	run.roaming_override = true
	return run


func test_scenario_one_has_no_roaming_boss_without_the_flag() -> void:
	var run: RunState = RunState.new(_data, 5, "warrior", [], 0, null, false, [])
	assert_false(run.roaming_enabled(), "o primeiro mapa (tutorial) fica sem o Perseguidor")
	run._raise_alarm(10)
	assert_eq(run.alarm, 0)
	assert_false(run.pursuer_active())


func test_alarm_rises_and_pursuer_enters_three_nodes_behind() -> void:
	var run: RunState = _run()
	run.choose_node(run.options()[0].id)
	# força a camada 2 e enche o medidor (fugir +2, descansar +1, elite +1 = 4)
	var node: MapNode = run.current_node()
	node.layer = maxi(node.layer, RoamingRules.MIN_LAYER)
	run._raise_alarm(RoamingRules.ALARM_FLEE)
	assert_eq(run.alarm, 2)
	assert_false(run.pursuer_active())
	run._raise_alarm(RoamingRules.ALARM_REST)
	run._raise_alarm(RoamingRules.ALARM_ELITE)
	assert_true(run.pursuer_active())
	assert_eq(run.pursuer_distance, RoamingRules.START_DISTANCE)
	assert_eq(run.alarm, 0, "o medidor zera ao chamar o Perseguidor")


func test_pursuer_advances_one_node_per_choice_and_skips_bonfires() -> void:
	var run: RunState = _run()
	run.pursuer_distance = 3
	var plain: MapNode = MapNode.new(90, 2, 0, MapNode.Kind.BATTLE)
	var bonfire: MapNode = MapNode.new(91, 2, 1, MapNode.Kind.BONFIRE)
	run._advance_pursuer(bonfire)
	assert_eq(run.pursuer_distance, 3, "nunca entra em fogueira")
	run._advance_pursuer(plain)
	assert_eq(run.pursuer_distance, 2)
	run._advance_pursuer(plain)
	run._advance_pursuer(plain)
	assert_true(run.pursuer_pending, "ao chegar a 0 o encontro fica pendente")
	assert_eq(run.pursuer_distance, -1)


func test_pending_encounter_intercepts_the_next_move_with_a_forced_fight() -> void:
	var run: RunState = _run()
	run.pursuer_pending = true
	var before: int = run.current_node_id
	assert_true(run.choose_node(run.options()[0].id))
	assert_eq(run.phase, RunState.Phase.FIGHT)
	assert_true(run.roaming_fight)
	assert_eq(run.current_node_id, before, "a Bibiana não saiu do lugar")
	assert_eq(run.combat.enemy.display_name, "O Perseguidor Coroado")
	assert_false(run.combat.enemy.can_flee, "sem fuga (GDD §13)")
	assert_false(run.combat.enemy.is_boss)


func test_victory_rewards_and_the_pursuer_does_not_return() -> void:
	var run: RunState = _run()
	run.pursuer_pending = true
	run.choose_node(run.options()[0].id)
	var power_before: float = run.power
	run.combat.debug_kill_enemy()
	assert_true(run.finish_fight())
	assert_true(run.pursuer_defeated)
	assert_false(run.roaming_fight)
	assert_gt(run.power, power_before, "Poder ×3 do roaming boss")
	assert_eq(run.phase, RunState.Phase.SHOP, "a loja vem depois da luta")
	assert_true(run.defeated_enemy_ids.has(RoamingRules.ENEMY_ID))
	run._raise_alarm(10)
	assert_false(run.pursuer_active(), "derrotado, não volta nesta Descida")


func test_defeat_by_the_pursuer_ends_the_run_with_its_name() -> void:
	var run: RunState = _run()
	run.pursuer_pending = true
	run.choose_node(run.options()[0].id)
	run.combat.outcome = Combat.Outcome.DEFEAT
	assert_true(run.finish_fight())
	assert_eq(run.phase, RunState.Phase.DEFEAT)
	assert_eq(run.defeated_by_id, RoamingRules.ENEMY_ID)


func test_pursuit_is_deterministic_by_seed() -> void:
	var traces: Array[String] = []
	for attempt: int in 2:
		var run: RunState = _run(21)
		run.current_node().layer = 2
		run._raise_alarm(4)
		var trace: String = str(run.pursuer_distance)
		for i: int in 3:
			run._advance_pursuer(MapNode.new(100 + i, 3 + i, 0, MapNode.Kind.BATTLE))
			trace += ",%d,%s" % [run.pursuer_distance, str(run.pursuer_pending)]
		traces.append(trace)
	assert_eq(traces[0], traces[1])


func test_save_round_trip_keeps_the_pursuit() -> void:
	var run: RunState = _run(9)
	run.alarm = 2
	run.pursuer_distance = 2
	run.pursuer_pending = false
	run.pursuer_defeated = false
	var restored: RunState = RunSave.from_dict(_data, RunSave.to_dict(run))
	assert_not_null(restored)
	assert_eq(restored.alarm, 2)
	assert_eq(restored.pursuer_distance, 2)
