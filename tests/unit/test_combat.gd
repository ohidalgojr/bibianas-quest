extends GutTest
## GDD §6, §7 e §8: mecânicas do motor de combate, pela interface pública. Quando um
## caso depende da sorte (acerto, Cara), o teste procura uma semente em que ele ocorre.

const SEARCH: int = 400


func _combat(run_seed: int, enemy_unit: Combatant, power: float = 1.0) -> Combat:
	var combat: Combat = Combat.new(CombatFixtures.warrior(power), enemy_unit, RngStreams.new(run_seed), CoinState.new())
	combat.start()
	return combat


func _find(events: Array[CombatEvent], type: CombatEvent.Type, label: String = "") -> int:
	for index: int in events.size():
		if events[index].type == type and (label == "" or events[index].label == label):
			return index
	return -1


func test_start_shows_the_intent_before_any_turn() -> void:
	var combat: Combat = _combat(1, CombatFixtures.grunt())
	assert_eq(combat.history[0].type, CombatEvent.Type.STARTED)
	assert_eq(combat.history[1].type, CombatEvent.Type.INTENT)
	assert_true(combat.is_player_turn() or combat.outcome != Combat.Outcome.ONGOING)
	assert_eq(combat.start().size(), 0, "start duas vezes não faz nada")


func test_turn_order_follows_speed() -> void:
	var sprint: Combat = Combat.new(CombatFixtures.warrior(), CombatFixtures.sprinter(), RngStreams.new(1), CoinState.new())
	var order: Array[int] = sprint.preview_turn_order(20)
	assert_eq(order.count(Combatant.ENEMY), 14, "VEL 15 contra 7")
	var even: Combat = Combat.new(CombatFixtures.warrior(), CombatFixtures.grunt(), RngStreams.new(1), CoinState.new())
	assert_eq(even.preview_turn_order(6), [1, 0, 1, 0, 1, 0] as Array[int], "VEL 8 contra 7")


func test_fast_enemy_never_opens_with_a_dangerous_move() -> void:
	for run_seed: int in 200:
		var combat: Combat = _combat(run_seed, CombatFixtures.sprinter())
		var first: CombatEvent = combat.history[1]
		assert_eq(first.value, EnemyMove.Intent.ATTACK, "semente %d: o cão age antes do jogador ver o aviso" % run_seed)


func test_invalid_actions_change_nothing() -> void:
	var combat: Combat = _combat(3, CombatFixtures.grunt())
	assert_true(combat.is_player_turn())
	combat.player.mp = 3
	var size: int = combat.history.size()
	assert_eq(combat.act(Combat.Action.SKILL, CombatFixtures.skill("shield_bash")).size(), 0, "MP insuficiente")
	assert_eq(combat.act(Combat.Action.SKILL).size(), 0, "skill nula")
	assert_eq(combat.act(Combat.Action.ITEM).size(), 0, "item nulo")
	assert_eq(combat.history.size(), size)
	assert_eq(combat.player.mp, 3)
	assert_true(combat.is_player_turn())


func test_bosses_do_not_allow_fleeing() -> void:
	var combat: Combat = _combat(3, CombatFixtures.boss())
	assert_false(combat.can_act(Combat.Action.FLEE))
	assert_eq(combat.act(Combat.Action.FLEE).size(), 0)


func test_defend_returns_10_percent_mp_and_ends_at_the_next_turn() -> void:
	for run_seed: int in SEARCH:
		var combat: Combat = _combat(run_seed, CombatFixtures.grunt())
		combat.player.mp = 10
		var events: Array[CombatEvent] = combat.act(Combat.Action.DEFEND)
		if combat.outcome != Combat.Outcome.ONGOING:
			continue
		var heal: int = _find(events, CombatEvent.Type.HEAL)
		assert_eq(events[heal].extra, 2, "10% de 20 de MP")
		assert_ne(_find(events, CombatEvent.Type.EFFECT_ON, "defending"), -1)
		assert_ne(_find(events, CombatEvent.Type.EFFECT_OFF, "defending"), -1, "sai no início do próximo turno")
		assert_false(combat.player.has_effect(CombatEffect.Kind.DEFENDING))
		return
	fail_test("nenhuma semente terminou o turno com a luta em andamento")


func test_shield_bash_heads_stuns_and_skips_the_enemy_turn() -> void:
	for run_seed: int in SEARCH:
		var combat: Combat = _combat(run_seed, CombatFixtures.grunt())
		var events: Array[CombatEvent] = combat.act(Combat.Action.SKILL, CombatFixtures.skill("shield_bash"))
		var stun: int = _find(events, CombatEvent.Type.EFFECT_ON, "stunned")
		if stun == -1:
			continue
		var skip: int = _find(events, CombatEvent.Type.STUN_SKIP)
		assert_gt(skip, stun, "o inimigo perde o turno seguinte")
		assert_false(combat.enemy.stunned)
		assert_eq(combat.player.mp, 14, "Golpe de Escudo custa 6")
		return
	fail_test("nenhuma semente deu Cara no Golpe de Escudo")


func test_shield_bash_tails_only_damages() -> void:
	for run_seed: int in SEARCH:
		var combat: Combat = _combat(run_seed, CombatFixtures.grunt())
		var events: Array[CombatEvent] = combat.act(Combat.Action.SKILL, CombatFixtures.skill("shield_bash"))
		var coin: int = _find(events, CombatEvent.Type.COIN, "shield_bash")
		if coin == -1 or events[coin].flag:
			continue
		assert_eq(_find(events, CombatEvent.Type.EFFECT_ON, "stunned"), -1)
		assert_ne(_find(events, CombatEvent.Type.DAMAGE, "shield_bash"), -1)
		return
	fail_test("nenhuma semente deu Coroa no Golpe de Escudo")


func test_shield_bash_slows_bosses_instead_of_stunning() -> void:
	for run_seed: int in SEARCH:
		var combat: Combat = _combat(run_seed, CombatFixtures.boss())
		var events: Array[CombatEvent] = combat.act(Combat.Action.SKILL, CombatFixtures.skill("shield_bash"))
		var slow: int = _find(events, CombatEvent.Type.EFFECT_ON, "slowed")
		if slow == -1:
			continue
		assert_eq(events[slow].value, 3, "Lentidão dura 3 turnos")
		assert_eq(_find(events, CombatEvent.Type.EFFECT_ON, "stunned"), -1)
		assert_true(combat.enemy.has_effect(CombatEffect.Kind.SLOWED))
		assert_eq(combat.enemy.effective_speed(), 4, "VEL 6 com -30%")
		return
	fail_test("nenhuma semente deu Cara contra o chefe")


func test_charge_costs_8_and_lowers_own_defense_for_one_turn() -> void:
	for run_seed: int in SEARCH:
		var combat: Combat = _combat(run_seed, CombatFixtures.brute())
		var events: Array[CombatEvent] = combat.act(Combat.Action.SKILL, CombatFixtures.skill("charge"))
		if combat.outcome != Combat.Outcome.ONGOING:
			continue
		assert_eq(combat.player.mp, 12)
		assert_ne(_find(events, CombatEvent.Type.EFFECT_ON, "armor_down"), -1)
		assert_ne(_find(events, CombatEvent.Type.EFFECT_OFF, "armor_down"), -1)
		assert_eq(combat.player.effective_defense(), 12.0)
		return
	fail_test("nenhuma semente seguiu em andamento")


func test_bulwark_reflects_20_percent_of_physical_damage() -> void:
	for run_seed: int in SEARCH:
		var combat: Combat = _combat(run_seed, CombatFixtures.brute())
		var events: Array[CombatEvent] = combat.act(Combat.Action.SKILL, CombatFixtures.skill("bulwark"))
		var reflect: int = _find(events, CombatEvent.Type.DAMAGE, "reflect")
		if reflect == -1:
			continue
		var taken: CombatEvent = events[reflect - 1]
		assert_eq(taken.type, CombatEvent.Type.DAMAGE)
		assert_eq(taken.side, Combatant.PLAYER)
		assert_eq(events[reflect].value, roundi(taken.value * 0.2))
		assert_eq(events[reflect].side, Combatant.ENEMY)
		return
	fail_test("nenhuma semente refletiu dano")


func test_item_heals_a_percentage_capped_at_max() -> void:
	var potion: CombatItem = CombatItem.make("potion", 30)
	var combat: Combat = _combat(5, CombatFixtures.grunt())
	combat.player.hp = 50
	var events: Array[CombatEvent] = combat.act(Combat.Action.ITEM, null, potion)
	assert_eq(events[_find(events, CombatEvent.Type.HEAL)].value, 39, "30% de 130")
	var full: Combat = _combat(5, CombatFixtures.grunt())
	full.player.hp = full.player.stats.max_hp - 5
	events = full.act(Combat.Action.ITEM, null, potion)
	assert_eq(events[_find(events, CombatEvent.Type.HEAL)].value, 5)


func test_flee_heads_ends_the_fight_and_tails_loses_the_turn() -> void:
	var fled: bool = false
	var failed: bool = false
	for run_seed: int in SEARCH:
		var combat: Combat = _combat(run_seed, CombatFixtures.grunt())
		var events: Array[CombatEvent] = combat.act(Combat.Action.FLEE)
		var coin: int = _find(events, CombatEvent.Type.COIN, "flee")
		assert_eq(events[coin].value, 50, "fuga usa a chance da moeda (base 50%)")
		if events[coin].flag:
			fled = true
			assert_eq(combat.outcome, Combat.Outcome.FLED)
			assert_eq(events[events.size() - 1].type, CombatEvent.Type.ENDED)
			assert_false(combat.is_player_turn())
		else:
			failed = true
			assert_ne(_find(events, CombatEvent.Type.FLEE_FAILED), -1)
			assert_ne(combat.outcome, Combat.Outcome.FLED)
		if fled and failed:
			return
	fail_test("faltou um dos dois lados da fuga")


func test_victory_ends_the_fight_and_blocks_further_actions() -> void:
	var weak: Combatant = CombatFixtures.grunt()
	weak.hp = 1
	var combat: Combat = _combat(7, weak)
	for turn: int in 20:
		if not combat.is_player_turn():
			break
		combat.act(Combat.Action.ATTACK)
	assert_eq(combat.outcome, Combat.Outcome.VICTORY)
	assert_eq(combat.history[combat.history.size() - 1].type, CombatEvent.Type.ENDED)
	assert_eq(combat.act(Combat.Action.ATTACK).size(), 0)


func test_no_instant_death_above_60_percent() -> void:
	var moves: Array[EnemyMove] = [EnemyMove.basic_attack()]
	var stats: Stats = Stats.make({"hp": 500, "strength": 999, "speed": 7})
	var combat: Combat = _combat(11, Combatant.enemy("Gigante", stats, CombatFixtures.single_phase(moves)))
	for turn: int in 30:
		if not combat.is_player_turn():
			break
		combat.act(Combat.Action.ATTACK)
	var first_hit: int = -1
	for index: int in combat.history.size():
		var event: CombatEvent = combat.history[index]
		if event.type == CombatEvent.Type.DAMAGE and event.side == Combatant.PLAYER:
			first_hit = index
			break
	assert_ne(first_hit, -1)
	assert_eq(combat.history[first_hit].extra, 1, "o primeiro golpe deixa 1 de vida")
	assert_eq(combat.outcome, Combat.Outcome.DEFEAT, "abaixo de 60%, o golpe seguinte mata")


func test_boss_enters_final_phase_at_half_life() -> void:
	var boss: Combatant = CombatFixtures.boss()
	boss.hp = 110
	var combat: Combat = _combat(2, boss)
	assert_eq(combat.enemy.phase_index, 1)
	assert_ne(_find(combat.history, CombatEvent.Type.PHASE), -1)
	var healthy: Combatant = CombatFixtures.boss()
	healthy.hp = 112
	assert_eq(_combat(2, healthy).enemy.phase_index, 0)


func test_coin_chance_is_fixed_at_fifty() -> void:
	assert_eq(CoinRules.chance(), 50)


func test_same_seed_and_choices_tell_the_same_story() -> void:
	for run_seed: int in 50:
		var enemy_a: Combatant = CombatFixtures.enemy_by_index(run_seed)
		var enemy_b: Combatant = CombatFixtures.enemy_by_index(run_seed)
		var first: String = CombatFixtures.transcript(CombatFixtures.play(run_seed, enemy_a, 1.5))
		var second: String = CombatFixtures.transcript(CombatFixtures.play(run_seed, enemy_b, 1.5))
		assert_eq(first, second, "semente %d" % run_seed)
	var one: String = CombatFixtures.transcript(CombatFixtures.play(1, CombatFixtures.grunt(), 1.0))
	var two: String = CombatFixtures.transcript(CombatFixtures.play(2, CombatFixtures.grunt(), 1.0))
	assert_ne(one, two)
