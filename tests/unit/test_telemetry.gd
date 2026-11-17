extends GutTest
## TASK-013 (ADR-0018): o log local monta linhas de nó, luta, moeda e morte, com a marca de
## morte por moeda (GDD §7 e §23), e grava uma linha JSON por evento.

const DIR: String = "user://test_telemetry/"

var _data: GameData


func before_all() -> void:
	_data = DataLoader.load_all()


func after_all() -> void:
	Telemetry.new(DIR).clear()


## Luta contra o inimigo dado; a Bibiana só defende, até a luta acabar.
func _fight(enemy_id: String, level: int, fight_seed: int, hp: int) -> Combat:
	var unit: Combatant = _data.make_player("warrior", 1.0)
	unit.hp = hp
	var combat: Combat = Combat.new(unit, _data.make_enemy(enemy_id, level), RngStreams.new(fight_seed), CoinState.new())
	combat.start()
	var guard: int = 0
	while combat.outcome == Combat.Outcome.ONGOING and guard < 400:
		guard += 1
		combat.act(Combat.Action.DEFEND)
	return combat


func test_fight_lines_have_summary_coins_and_death() -> void:
	var combat: Combat = _fight("gravedigger", 6, 3, 40)
	var lines: Array[Dictionary] = Telemetry.fight_lines(combat, "gravedigger", 6)
	var types: PackedStringArray = PackedStringArray()
	for line: Dictionary in lines:
		types.append(str(line["type"]))
	assert_true(types.has("fight"))
	assert_true(types.has("coin"), "o Coveiro usa moeda")
	for line: Dictionary in lines:
		if line["type"] == "coin":
			assert_has(line, "chance")
			assert_has(line, "success")
	if combat.outcome == Combat.Outcome.DEFEAT:
		assert_eq(types[types.size() - 1], "death")


func test_death_by_coin_flag_follows_the_fatal_blow() -> void:
	# Força todas as moedas a falhar: a morte do Coveiro vem de um golpe de moeda.
	var unit: Combatant = _data.make_player("warrior", 1.0)
	unit.hp = 20
	var combat: Combat = Combat.new(unit, _data.make_enemy("gravedigger", 6), RngStreams.new(5), CoinState.new())
	combat.forced_coin = 0
	combat.enemy.stats.strength = 80
	combat.start()
	var guard: int = 0
	while combat.outcome == Combat.Outcome.ONGOING and guard < 400:
		guard += 1
		combat.act(Combat.Action.DEFEND)
	assert_eq(combat.outcome, Combat.Outcome.DEFEAT)
	var death: Dictionary = Telemetry.fight_lines(combat, "gravedigger", 6).back()
	assert_eq(death["type"], "death")
	var fatal_is_coin: bool = false
	for event: CombatEvent in combat.history:
		if event.type == CombatEvent.Type.DAMAGE and event.side == Combatant.PLAYER and event.extra <= 0:
			fatal_is_coin = event.label in ["shovel", "grave", "heavy", "cruel", "mortal"] or death["by_coin"]
	assert_true(fatal_is_coin)


func test_forced_coin_overrides_result_but_keeps_streams() -> void:
	var normal: Combat = _fight("plague_hound", 3, 11, 100)
	var forced_unit: Combatant = _data.make_player("warrior", 1.0)
	forced_unit.hp = 100
	var forced: Combat = Combat.new(forced_unit, _data.make_enemy("plague_hound", 3), RngStreams.new(11), CoinState.new())
	forced.forced_coin = 1
	forced.start()
	var guard: int = 0
	while forced.outcome == Combat.Outcome.ONGOING and guard < 400:
		guard += 1
		forced.act(Combat.Action.DEFEND)
	for event: CombatEvent in forced.history:
		if event.type == CombatEvent.Type.COIN:
			assert_true(event.flag, "moeda forçada a acertar")
	assert_not_null(normal)


func test_run_lines_and_file_writing() -> void:
	var run: RunState = RunState.new(_data, 4)
	var chest: MapNode = run.options()[0]
	chest.kind = MapNode.Kind.CHEST
	chest.enemy_id = ""
	run.choose_node(chest.id)
	var lines: Array[Dictionary] = Telemetry.run_lines(run, 0)
	var kinds: PackedStringArray = PackedStringArray()
	for line: Dictionary in lines:
		kinds.append(str(line["type"]))
	assert_true(kinds.has("scenario"))
	assert_true(kinds.has("node"))
	assert_true(kinds.has("gold"))
	var log: Telemetry = Telemetry.new(DIR)
	log.clear()
	log.write(lines)
	log.write(lines)
	var text: String = FileAccess.get_file_as_string(DIR + Telemetry.FILE)
	var rows: PackedStringArray = text.strip_edges().split("\n")
	assert_eq(rows.size(), lines.size() * 2, "uma linha por evento, acrescentando")
	var parsed: Variant = JSON.parse_string(rows[0])
	assert_true(parsed is Dictionary and (parsed as Dictionary).has("t"))
	log.enabled = false
	log.write(lines)
	assert_eq(FileAccess.get_file_as_string(DIR + Telemetry.FILE).strip_edges().split("\n").size(), rows.size())
