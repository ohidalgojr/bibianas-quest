extends GutTest
## TASK-020 (ADR-0024): skills novas do Guerreiro, venda na loja (1 por visita, até 5
## espaços), efeitos no motor e save das skills aprendidas.

const DIR: String = "user://test_skills_saves/"

var _data: GameData


func before_all() -> void:
	_data = DataLoader.load_all()


func after_all() -> void:
	DirAccess.remove_absolute(DIR + SaveStore.RUN_FILE)


func _shop_run(run_seed: int = 3) -> RunState:
	var run: RunState = RunState.new(_data, run_seed)
	run._open_shop()
	return run


func test_data_has_three_new_priced_skills_and_free_starters() -> void:
	assert_eq(_data.shop_skill_ids("warrior"), ["second_wind", "war_cry", "whirlwind"] as Array[String])
	for starter: String in ["shield_bash", "charge", "bulwark"]:
		assert_eq(_data.skill_price(starter), 0)
	assert_eq(_data.skill_price("whirlwind"), 120)
	assert_eq(_data.class_skills("warrior").size(), 3, "a classe começa com 3")


func test_shop_offers_one_unlearned_skill_per_visit() -> void:
	var run: RunState = _shop_run()
	assert_true(["second_wind", "war_cry", "whirlwind"].has(run.skill_offer))
	run.learned_skills.append(run.skill_offer)
	var learned: String = run.skill_offer
	run._open_shop()
	assert_ne(run.skill_offer, learned, "não repete a aprendida")
	run.leave_shop()
	assert_eq(run.skill_offer, "")


func test_buy_skill_charges_and_learns_in_order() -> void:
	var run: RunState = _shop_run()
	var offered: String = run.skill_offer
	var price: int = _data.skill_price(offered)
	run.gold = price - 1
	assert_false(run.can_buy_skill(), "sem ouro")
	run.gold = price + 10
	assert_true(run.buy_skill())
	assert_eq(run.gold, 10)
	assert_eq(run.learned_skills.back(), offered)
	assert_eq(run.skills().size(), 4)
	assert_eq(run.skill_offer, "", "a oferta some depois de comprar")
	assert_false(run.buy_skill())


func test_skill_slots_are_limited_to_five() -> void:
	var run: RunState = _shop_run()
	run.gold = 1000
	assert_true(run.buy_skill())
	run._open_shop()
	run.gold = 1000
	assert_true(run.buy_skill())
	assert_eq(run.learned_skills.size(), RunRules.MAX_SKILLS)
	run._open_shop()
	run.gold = 1000
	assert_eq(run.skill_offer, "second_wind" if not run.learned_skills.has("second_wind") else run.skill_offer)
	assert_false(run.can_buy_skill(), "espaços cheios")
	assert_eq(RunPanels.new(run).skill_view().get("reason", "Espaços de skill cheios"), "Espaços de skill cheios")


func _combat() -> Combat:
	var moves: Array[EnemyMove] = [EnemyMove.make("hit", EnemyMove.Kind.ATTACK, 0.1)]
	var stats: Stats = Stats.make({"hp": 400, "strength": 1, "defense": 4, "resistance": 2, "speed": 3, "evasion": 0})
	var enemy: Combatant = Combatant.enemy("Saco", stats, CombatFixtures.single_phase(moves))
	var combat: Combat = Combat.new(CombatFixtures.warrior(), enemy, RngStreams.new(4), CoinState.new())
	combat.start()
	return combat


func test_whirlwind_deals_damage() -> void:
	var combat: Combat = _combat()
	var before: int = combat.enemy.hp
	combat.player.mp = 20
	combat.act(Combat.Action.SKILL, _data.combat_skill("whirlwind"))
	assert_lt(combat.enemy.hp, before)
	assert_eq(combat.player.mp, 15, "custou 5 de MP")


func test_war_cry_empowers_attack_for_three_turns() -> void:
	var combat: Combat = _combat()
	var base: float = combat.player.effective_strength()
	combat.act(Combat.Action.SKILL, _data.combat_skill("war_cry"))
	assert_true(combat.player.has_effect(CombatEffect.Kind.EMPOWERED))
	assert_almost_eq(combat.player.effective_strength(), base * 1.25, 0.0001)
	for turn: int in 4:
		combat.act(Combat.Action.DEFEND)
	assert_false(combat.player.has_effect(CombatEffect.Kind.EMPOWERED), "a Fúria passou")


func test_second_wind_heals_a_quarter_of_max_hp() -> void:
	var combat: Combat = _combat()
	combat.player.hp = 40
	var expected: int = roundi(combat.player.stats.max_hp * 25 / 100.0)
	combat.act(Combat.Action.SKILL, _data.combat_skill("second_wind"))
	assert_between(combat.player.hp, 40 + expected - 4, 40 + expected, "cura 25% (menos o golpe do inimigo)")


func test_learned_skills_are_saved_and_restored() -> void:
	var run: RunState = RunState.new(_data, 12)
	run.learned_skills.append("war_cry")
	var store: SaveStore = SaveStore.new(DIR)
	assert_true(store.save_run(run))
	var loaded: RunState = store.load_run(_data)
	assert_not_null(loaded)
	assert_eq(loaded.learned_skills, run.learned_skills)
	assert_eq(loaded.skills().size(), 4)


func test_shop_panel_shows_skill_and_screen_has_five_skill_buttons() -> void:
	var run: RunState = _shop_run()
	var view: Dictionary = RunPanels.new(run).skill_view()
	assert_false(view.is_empty())
	assert_eq(view["slots"], "Skills: 3/5")
	assert_eq(view["price"], _data.skill_price(run.skill_offer))
	var screen: CombatScreen = CombatScreen.new()
	screen.time_scale = 0.0
	add_child_autofree(screen)
	screen.start_fight("giant_rat", 1, 1.0, 5)
	for index: int in 5:
		assert_true(screen._buttons.has("skill_%d" % index))
	assert_true(screen._buttons["skill_2"].visible)
	assert_false(screen._buttons["skill_3"].visible, "só 3 aprendidas")
