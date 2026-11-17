extends GutTest
## GDD §7 e ADR-0026: a moeda é cara ou coroa, 50% fixo; a Maré de azar liga depois de 3
## perdas; SORTE e Maré de azar mexem nos drops e baús; a Moeda da Sorte rejoga um erro.

var _data: GameData


func before_all() -> void:
	_data = DataLoader.load_all()


func test_chance_is_always_fifty() -> void:
	assert_eq(CoinRules.chance(), 50)
	assert_eq(CoinRules.CHANCE, 50)


func test_bad_luck_streak() -> void:
	var state: CoinState = CoinState.new()
	for loss: int in 2:
		state.record(false)
	assert_false(state.bad_luck())
	state.record(false)
	assert_true(state.bad_luck(), "depois de 3 perdidos")
	state.record(false)
	assert_true(state.bad_luck(), "continua enquanto perder")
	state.record(true)
	assert_false(state.bad_luck(), "zera ao ganhar")
	assert_eq([state.flips, state.heads], [5, 1])


func test_flips_land_near_half() -> void:
	var rng: Pcg32 = Pcg32.new(31337, 4)
	var heads: int = 0
	for flip: int in 10000:
		if rng.draw_percent(CoinRules.chance()):
			heads += 1
	assert_between(heads, 4800, 5200)


# --- SORTE e Maré de azar nos drops (ADR-0026)

func test_luck_raises_equipment_drop_chance_up_to_the_cap() -> void:
	var plain: int = 0
	var lucky: int = 0
	var capped: int = 0
	var loot: Pcg32 = RngStreams.new(5).loot()
	for draw: int in 4000:
		plain += 1 if RunRules.equipment_drops("common", loot, 0) else 0
		lucky += 1 if RunRules.equipment_drops("common", loot, 8) else 0
		capped += 1 if RunRules.equipment_drops("common", loot, 99) else 0
	assert_between(plain, 4000 * 10 / 100, 4000 * 14 / 100, "12% sem SORTE")
	assert_between(lucky, 4000 * 18 / 100, 4000 * 22 / 100, "20% com SORTE 8")
	assert_between(capped, 4000 * 25 / 100, 4000 * 29 / 100, "27% no teto de +15")


func test_luck_shifts_rarity_weights_toward_the_rare() -> void:
	var loot: Pcg32 = RngStreams.new(8).loot()
	var plain_rare: int = 0
	var lucky_rare: int = 0
	for draw: int in 3000:
		plain_rare += 1 if RunRules.drop_rarity("elite", loot, 0) == "rare" else 0
		lucky_rare += 1 if RunRules.drop_rarity("elite", loot, 10) == "rare" else 0
	assert_gt(lucky_rare, plain_rare, "SORTE 10 torna o raro mais comum")
	var worn: int = 0
	var uncommon: int = 0
	for draw: int in 1000:
		var rarity: String = RunRules.drop_rarity("common", loot, 15, 10)
		worn += 1 if rarity == "worn" else 0
		uncommon += 1 if rarity == "uncommon" else 0
	assert_eq(worn, 0, "com muita SORTE e Maré de azar o gasto some")
	assert_between(uncommon, 400, 500, "e o incomum sobe de 15% para 45%")


func test_chest_gold_grows_with_luck() -> void:
	var plain: int = RunRules.chest_gold(3, RngStreams.new(2).loot(), 0)
	var lucky: int = RunRules.chest_gold(3, RngStreams.new(2).loot(), 10)
	assert_gte(lucky, plain)
	assert_eq(lucky, roundi(plain * 1.3))


func _won_fight(run: RunState, kind: MapNode.Kind = MapNode.Kind.BATTLE, enemy: String = "giant_rat") -> void:
	run.phase = RunState.Phase.CHOOSING
	run.current_node_id = run.map.start_id
	var option: MapNode = run.options()[0]
	option.kind = kind
	option.enemy_id = enemy
	option.level = 1
	run.choose_node(option.id)
	run.combat.enemy.hp = 1
	var guard: int = 0
	while run.combat.outcome == Combat.Outcome.ONGOING and guard < 200:
		guard += 1
		run.combat.act(Combat.Action.ATTACK)
	run.finish_fight()


func test_bad_luck_guarantees_a_better_drop_and_resets() -> void:
	var run: RunState = RunState.new(_data, 14)
	run.coin.losses_in_row = 3
	_won_fight(run)
	assert_ne(run.pending_drop, "", "a Maré de azar garante o equipamento")
	assert_true(bool(run.last_reward.get("bad_luck", false)))
	assert_eq(run.coin.losses_in_row, 0, "a Maré é gasta")


func test_boss_always_drops_a_lucky_coin() -> void:
	var run: RunState = RunState.new(_data, 14)
	_won_fight(run, MapNode.Kind.BOSS, "gravedigger")
	assert_eq(run.consumable_count(RunRules.LUCKY_COIN_ID), 1)
	assert_true(bool(run.last_reward.get("lucky_coin", false)))


func test_lucky_coin_is_an_item_outside_the_shop() -> void:
	assert_true(_data.items.has(RunRules.LUCKY_COIN_ID))
	assert_eq(int(_data.items[RunRules.LUCKY_COIN_ID]["price"]), 0)
	for run_seed: int in 30:
		var run: RunState = RunState.new(_data, run_seed)
		run._open_shop()
		assert_false(run.shop_offer.has(RunRules.LUCKY_COIN_ID))


# --- Moeda da Sorte no combate

func _lucky_combat(coins: int, forced_seed: int) -> Combat:
	var moves: Array[EnemyMove] = [EnemyMove.make("heavy", EnemyMove.Kind.HEAVY)]
	var stats: Stats = Stats.make({"hp": 300, "strength": 5, "defense": 4, "resistance": 2, "speed": 6, "evasion": 0})
	var enemy: Combatant = Combatant.enemy("Teste", stats, CombatFixtures.single_phase(moves))
	var combat: Combat = Combat.new(CombatFixtures.warrior(), enemy, RngStreams.new(forced_seed), CoinState.new())
	combat.lucky_coins = coins
	return combat


func test_lucky_coin_cannot_be_armed_without_coins() -> void:
	var combat: Combat = _lucky_combat(0, 1)
	assert_false(combat.arm_reroll(true))
	assert_false(combat.is_reroll_armed())


func test_lucky_coin_rerolls_only_a_missed_flip_and_is_spent_then() -> void:
	var rerolled_seen: int = 0
	var kept_when_first_wins: int = 0
	for fight_seed: int in 60:
		var combat: Combat = _lucky_combat(1, fight_seed)
		assert_true(combat.arm_reroll(true))
		combat.start()
		var guard: int = 0
		while combat.outcome == Combat.Outcome.ONGOING and guard < 30 and combat.lucky_coins_left() == 1:
			guard += 1
			combat.act(Combat.Action.DEFEND)
		if combat.lucky_coins_left() == 0:
			rerolled_seen += 1
			var coins: int = 0
			for event: CombatEvent in combat.history:
				if event.type == CombatEvent.Type.COIN and event.extra == 1:
					coins += 1
			assert_eq(coins, 1, "uma re-jogada, uma moeda gasta")
			assert_false(combat.is_reroll_armed(), "a moeda armada some depois de usada")
		else:
			kept_when_first_wins += 1
	assert_gt(rerolled_seen, 0, "em 60 lutas, algum primeiro lance caiu errado")
	assert_gt(kept_when_first_wins + rerolled_seen, 0)


func test_run_consumes_the_lucky_coin_spent_in_the_fight() -> void:
	var run: RunState = RunState.new(_data, 6)
	run.consumables[RunRules.LUCKY_COIN_ID] = 2
	var option: MapNode = run.options()[0]
	option.kind = MapNode.Kind.BATTLE
	option.enemy_id = "giant_rat"
	option.level = 1
	run.choose_node(option.id)
	assert_eq(run.combat.lucky_coins, 2)
	assert_eq(run.available_in_fight(RunRules.LUCKY_COIN_ID), 2)
