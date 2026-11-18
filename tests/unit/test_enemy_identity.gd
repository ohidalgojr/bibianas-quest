extends GutTest
## TASK-025 (ADR-0030): golpes de moeda temáticos, doença persistente, efeitos novos e IA
## reativa dos seis inimigos do cenário 1, sempre dentro das regras de justiça.

var _data: GameData


func before_all() -> void:
	_data = DataLoader.load_all()


func _combat(enemy_id: String, level: int = 1, fight_seed: int = 1) -> Combat:
	var combat: Combat = Combat.new(_data.make_player("warrior", 1.0), _data.make_enemy(enemy_id, level), RngStreams.new(fight_seed), CoinState.new())
	combat.start()
	return combat


func _coin_move(enemy_id: String, move_id: String) -> EnemyMove:
	for phase: EnemyPhase in _data.make_enemy(enemy_id, 1).phases:
		for move: EnemyMove in phase.moves:
			if move.id == move_id:
				return move
	return null


func test_every_enemy_has_a_themed_coin_move_and_a_reaction() -> void:
	var themes: Dictionary = {
		"infected_citizen": "feverish_hug", "giant_rat": "filthy_bite", "carrion_crow": "eye_peck",
		"plague_hound": "unrelenting_fangs", "rotten_executioner": "guillotine", "gravedigger": "shovel",
	}
	for enemy_id: String in themes:
		var move: EnemyMove = _coin_move(enemy_id, themes[enemy_id])
		assert_not_null(move, enemy_id)
		assert_true(move.is_coin(), "%s: golpe de moeda" % enemy_id)
		assert_true(move.fail_effect_kind >= 0 or not move.fail_disease.is_empty(), "%s: consequência temática" % enemy_id)
		assert_false(_data.make_enemy(enemy_id, 1).reactions.is_empty(), "%s: tem reação" % enemy_id)


func test_fail_text_tells_the_consequence_before_the_flip() -> void:
	assert_eq(CombatTexts.fail_text(_coin_move("carrion_crow", "eye_peck")), " e Cegueira por 3 turnos")
	assert_string_contains(CombatTexts.fail_text(_coin_move("giant_rat", "filthy_bite")), "Leptospirose (-15% de HP máx. até a fogueira)")
	var session: CombatSession = CombatSession.new(_data, "giant_rat", 1, 1.0, 3)
	session.start()
	assert_string_contains(str(session.intent_view("filthy_bite")["detail"]), "Leptospirose")


func test_blindness_lowers_hit_chance() -> void:
	var unit: Combatant = _data.make_player("warrior", 1.0)
	var plain: int = CombatFormulas.hit_chance(unit.effective_precision_bonus(), 8)
	unit.effects.append(CombatEffect.make(CombatEffect.Kind.BLINDED, 3))
	var blind: int = CombatFormulas.hit_chance(unit.effective_precision_bonus(), 8)
	assert_lt(blind, plain, "Cegueira: PRE -30")
	assert_eq(unit.effective_precision_bonus(), unit.stats.precision_bonus() - 30)


func test_curse_raises_damage_taken() -> void:
	var damages: Array[int] = []
	for cursed: bool in [false, true]:
		var combat: Combat = _combat("rotten_executioner", 2, 4)
		combat.player.hp = 500
		combat.player.stats.max_hp = 500
		if cursed:
			combat.player.effects.append(CombatEffect.make(CombatEffect.Kind.CURSED, 3))
		for turn: int in 3:
			combat.act(Combat.Action.DEFEND)
		var total: int = 0
		for event: CombatEvent in combat.history:
			if event.type == CombatEvent.Type.DAMAGE and event.side == Combatant.PLAYER:
				total += event.value
		damages.append(total)
	assert_gte(damages[1], damages[0], "amaldiçoada, a Bibiana sofre ao menos o mesmo dano")


## A coroa de um golpe temático aplica a consequência (se o golpe causa dano e a Bibiana não está
## protegida pelo Veterano que defende).
func test_failed_coin_applies_fail_effect_and_disease() -> void:
	var blinded: int = 0
	var sick: int = 0
	for fight_seed: int in 80:
		var crow: Combat = _combat("carrion_crow", 1, fight_seed)
		crow.forced_coin = 0
		var rat: Combat = _combat("giant_rat", 1, fight_seed)
		rat.forced_coin = 0
		for combat: Combat in [crow, rat]:
			var guard: int = 0
			while combat.outcome == Combat.Outcome.ONGOING and guard < 12:
				guard += 1
				combat.act(Combat.Action.ATTACK)
		if crow.player.has_effect(CombatEffect.Kind.BLINDED) or _history_has(crow, CombatEvent.Type.EFFECT_ON, "blinded"):
			blinded += 1
		if rat.player.diseases.has(Diseases.LEPTOSPIROSIS):
			sick += 1
	assert_gt(blinded, 0, "o corvo cegou em algum lance perdido")
	assert_gt(sick, 0, "o rato passou Leptospirose em algum lance perdido")


func _history_has(combat: Combat, type: CombatEvent.Type, label: String) -> bool:
	for event: CombatEvent in combat.history:
		if event.type == type and event.label == label:
			return true
	return false


func test_veteran_defending_cancels_the_fail_penalty() -> void:
	var rat: Combat = _combat("giant_rat", 1, 5)
	rat.forced_coin = 0
	var guard: int = 0
	while rat.outcome == Combat.Outcome.ONGOING and guard < 30:
		guard += 1
		rat.act(Combat.Action.DEFEND)
	assert_eq(rat.player.diseases.size(), 0, "defendendo o tempo todo, o Veterano nunca pega a doença")


func test_disease_lowers_max_hp_persists_and_is_treated_at_the_fire() -> void:
	var run: RunState = RunState.new(_data, 6)
	var base: int = run.player_stats().max_hp
	run.diseases.append(Diseases.LEPTOSPIROSIS)
	assert_eq(run.player_stats().max_hp, roundi(base * 0.85), "-15% de HP máximo")
	run.phase = RunState.Phase.CAMPFIRE
	run.embers = RunRules.EMBERS
	run.campfire_lit = true
	var panels: RunPanels = RunPanels.new(run)
	assert_eq(panels.campfire_view()["diseases"], ["Leptospirose"])
	assert_true(bool(panels.campfire_view()["can_treat"]))
	assert_true(panels.treat_disease())
	assert_eq(run.diseases.size(), 0)
	assert_eq(run.player_stats().max_hp, base, "o HP máximo volta")
	assert_eq(run.embers, RunRules.EMBERS - 1, "tratar custa 1 Brasa")
	assert_false(panels.treat_disease(), "sem doença não há o que tratar")


func test_disease_contracted_in_a_fight_goes_to_the_run() -> void:
	var run: RunState = RunState.new(_data, 6)
	var option: MapNode = run.options()[0]
	option.kind = MapNode.Kind.BATTLE
	option.enemy_id = "giant_rat"
	option.level = 1
	run.choose_node(option.id)
	run.combat.player.diseases.append(Diseases.LEPTOSPIROSIS)
	run.combat.enemy.hp = 1
	var guard: int = 0
	while run.combat.outcome == Combat.Outcome.ONGOING and guard < 100:
		guard += 1
		run.combat.act(Combat.Action.ATTACK)
	run.finish_fight()
	assert_eq(run.diseases, [Diseases.LEPTOSPIROSIS] as Array[String])
	var saved: Dictionary = RunSave.to_dict(run)
	run.phase = RunState.Phase.CHOOSING
	var loaded: RunState = RunSave.from_dict(_data, saved)
	assert_not_null(loaded)
	assert_eq(loaded.diseases, [Diseases.LEPTOSPIROSIS] as Array[String])


# --- IA reativa

func _intent_after_setup(enemy_id: String, level: int, setup: Callable) -> EnemyMove:
	var combat: Combat = _combat(enemy_id, level, 2)
	setup.call(combat)
	combat.act(Combat.Action.DEFEND)
	return combat.enemy.intent


func test_enemy_reacts_to_a_wounded_player() -> void:
	var seen: int = 0
	for fight_seed: int in 30:
		var combat: Combat = _combat("infected_citizen", 1, fight_seed)
		combat.player.hp = 20
		combat.act(Combat.Action.DEFEND)
		for event: CombatEvent in combat.history:
			if event.type == CombatEvent.Type.INTENT and event.extra == 1:
				assert_eq(event.label, "lunge")
				seen += 1
	assert_gt(seen, 0, "o Cidadão vê a Bibiana ferida e parte para o Bote")


func test_enemy_reacts_to_a_buffed_player_and_says_why() -> void:
	var reason_seen: bool = false
	for fight_seed: int in 40:
		var combat: Combat = _combat("gravedigger", 6, fight_seed)
		combat.player.stats.max_hp = 900
		combat.player.hp = 900
		combat.player.mp = 20
		combat.act(Combat.Action.SKILL, _data.combat_skill("war_cry"))
		for event: CombatEvent in combat.history:
			if event.type == CombatEvent.Type.INTENT and event.extra == 4:
				assert_true(event.label in ["curse", "rot"], "responde com debuff")
				reason_seen = true
	assert_true(reason_seen)
	var session: CombatSession = CombatSession.new(_data, "gravedigger", 6, 1.0, 1)
	session.start()
	assert_string_contains(str(session.intent_view("rot", 4)["detail"]), "Não tolera quem se fortalece")


func test_enemy_reacts_to_repeated_defending() -> void:
	var seen: bool = false
	for fight_seed: int in 40:
		var combat: Combat = _combat("carrion_crow", 1, fight_seed)
		combat.player.hp = 400
		combat.player.stats.max_hp = 400
		for turn: int in 4:
			combat.act(Combat.Action.DEFEND)
		for event: CombatEvent in combat.history:
			if event.type == CombatEvent.Type.INTENT and event.extra == 3:
				assert_eq(event.label, "dive")
				seen = true
	assert_true(seen, "defender duas vezes seguidas atrai o Mergulho")


func test_reactions_never_break_the_fairness_rules() -> void:
	for fight_seed: int in 60:
		for enemy_id: String in ["infected_citizen", "giant_rat", "carrion_crow", "plague_hound", "rotten_executioner", "gravedigger"]:
			var level: int = 6 if enemy_id == "gravedigger" else 2
			var combat: Combat = _combat(enemy_id, level, fight_seed)
			var guard: int = 0
			while combat.is_player_turn() and guard < 300:
				guard += 1
				combat.act(Combat.Action.ATTACK if guard % 3 != 0 else Combat.Action.DEFEND)
			var problems: PackedStringArray = CombatFixtures.audit(combat)
			assert_eq(problems.size(), 0, "%s semente %d: %s" % [enemy_id, fight_seed, "; ".join(problems)])


func test_data_validator_checks_fail_fields_and_reactions() -> void:
	var read_errors: PackedStringArray = PackedStringArray()
	var docs: Dictionary = {}
	for doc_name: String in DataValidator.DOCUMENTS:
		docs[doc_name] = DataLoader.read_json(DataLoader.DATA_DIR.path_join(doc_name + ".json"), read_errors)
	var rat: Dictionary = (docs["enemies"]["enemies"] as Array).filter(func(e: Dictionary) -> bool: return e["id"] == "giant_rat")[0]
	rat["phases"][0]["moves"][1]["fail_disease"] = "peste_negra"
	assert_false(DataValidator.validate(docs).is_empty(), "doença desconhecida")
	rat["phases"][0]["moves"][1]["fail_disease"] = "leptospirosis"
	rat["phases"][0]["moves"][0]["fail_effect"] = "cursed"
	assert_false(DataValidator.validate(docs).is_empty(), "efeito de falha em golpe sem moeda")
	rat["phases"][0]["moves"][0].erase("fail_effect")
	rat["reactions"][0]["move"] = "inexistente"
	assert_false(DataValidator.validate(docs).is_empty(), "reação para golpe que não existe")
	rat["reactions"][0]["move"] = "frenzy"
	rat["reactions"][0]["when"] = "lua_cheia"
	assert_false(DataValidator.validate(docs).is_empty(), "condição desconhecida")
	rat["reactions"][0]["when"] = "self_hp_below"
	assert_eq(DataValidator.validate(docs).size(), 0)
