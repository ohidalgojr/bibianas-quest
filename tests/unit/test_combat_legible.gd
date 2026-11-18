extends GutTest
## TASK-024 (ADR-0029): previsão de dano e acerto, descrição das skills, atacar devolve MP,
## Éter Sujo em combate e crítico manipulável por item e skill de fogueira.

var _data: GameData


func before_all() -> void:
	_data = DataLoader.load_all()


func _session(enemy_id: String = "giant_rat", level: int = 1, fight_seed: int = 1) -> CombatSession:
	var session: CombatSession = CombatSession.new(_data, enemy_id, level, 1.0, fight_seed)
	session.start()
	return session


## A previsão vale para os golpes de verdade: sem crítico, todo dano real fica entre mínimo e
## máximo; com crítico, até o máximo crítico.
func test_preview_bounds_every_real_strike() -> void:
	for fight_seed: int in 40:
		var session: CombatSession = _session("plague_hound", 2, fight_seed)
		var preview: Dictionary = session.combat.preview_player_strike(1.0)
		var hp_before: int = session.combat.enemy.hp
		session.attack()
		for event: CombatEvent in session.combat.history:
			if event.type == CombatEvent.Type.DAMAGE and event.side == Combatant.ENEMY and event.label == "attack":
				var limit: int = int(preview["crit_max"]) if event.flag else int(preview["max"])
				assert_between(event.value, 1, limit, "semente %d" % fight_seed)
				if not event.flag:
					assert_gte(event.value, int(preview["min"]), "semente %d" % fight_seed)
		assert_lte(session.combat.enemy.hp, hp_before)
		break


func test_preview_reports_hit_and_crit_chances() -> void:
	var session: CombatSession = _session()
	var preview: Dictionary = session.combat.preview_player_strike(1.0)
	assert_eq(preview["hit"], CombatFormulas.hit_chance(session.combat.player.stats.precision_bonus(), session.combat.enemy.stats.evasion))
	assert_eq(preview["crit"], session.combat.player.stats.crit)
	assert_gt(int(preview["crit_max"]), int(preview["max"]))
	assert_lte(int(preview["min"]), int(preview["max"]))


func test_buttons_show_preview_and_every_skill_has_a_description() -> void:
	var session: CombatSession = _session()
	assert_string_contains(session.attack_hint(), "dano ")
	assert_string_contains(session.attack_hint(), "acerto ")
	assert_string_contains(session.attack_hint(), "crít 5%")
	assert_string_contains(session.attack_hint(), "+2 MP")
	for index: int in session.skills.size():
		assert_ne(session.skill_hint(index), "", "skill %d tem texto" % index)
		assert_string_contains(session.skill_tip(index), session.skills[index].display_name)
	assert_string_contains(session.skill_tip(0), "atordoa")
	assert_string_contains(session.skill_hint(2), "DEF +50%")


func test_attack_returns_ten_percent_of_max_mp() -> void:
	var session: CombatSession = _session()
	session.combat.player.mp = 4
	var before: int = session.combat.player.mp
	session.attack()
	assert_between(session.combat.player.mp, before, before + 2, "atacar devolve até 2 de MP (10% de 20)")
	var gained: int = 0
	for event: CombatEvent in session.combat.history:
		if event.type == CombatEvent.Type.HEAL and event.side == Combatant.PLAYER and event.extra > 0:
			gained += event.extra
	assert_gte(gained, 2)


func test_ether_is_usable_in_a_run_fight_and_consumed() -> void:
	var run: RunState = RunState.new(_data, 5)
	run.consumables["dirty_ether"] = 2
	var option: MapNode = run.options()[0]
	option.kind = MapNode.Kind.BATTLE
	option.enemy_id = "giant_rat"
	option.level = 1
	run.choose_node(option.id)
	var session: CombatSession = CombatSession.for_run(run)
	session.combat.player.mp = 2
	assert_true(session.can_use_ether())
	session.use_ether()
	assert_eq(session.combat.player.mp, 12, "50% de 20 de MP")
	assert_eq(session.ethers_count(), 1)
	var guard: int = 0
	while run.combat.outcome == Combat.Outcome.ONGOING and guard < 200:
		guard += 1
		run.combat.act(Combat.Action.ATTACK)
	if run.combat.outcome == Combat.Outcome.VICTORY:
		run.finish_fight()
		assert_between(run.consumable_count("dirty_ether"), 1, 2, "usou um; um drop pode ter vindo")


func test_crit_comes_from_items_and_campfire_skill() -> void:
	var run: RunState = RunState.new(_data, 5)
	var base: int = run.player_stats().crit
	assert_eq(base, 5)
	run.equipment["relic"] = "sharp_claw"
	assert_eq(run.player_stats().crit, base + 8, "Garra Afiada")
	run.buffs["sharpen_edge"] = 3
	assert_eq(run.player_stats().crit, base + 8 + 10, "Afiar o Fio")
	var panels: RunPanels = RunPanels.new(run)
	run.phase = RunState.Phase.CAMPFIRE
	run.embers = RunRules.EMBERS
	var skills: Array = panels.campfire_view()["skills"]
	assert_eq(skills.size(), 3)
	assert_eq(skills[2]["description"], "CRIT +10 pontos por 3 lutas")
	var session: CombatSession = _session()
	session.combat.player.stats.crit = 23
	assert_string_contains(session.attack_hint(), "crít 23%")
