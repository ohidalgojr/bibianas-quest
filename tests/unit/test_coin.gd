extends GutTest
## GDD §7: chance da moeda, limites, Maré de azar e teto da trapaça.


func test_base_chance_and_luck() -> void:
	assert_eq(CoinRules.chance(0, 0), 50)
	assert_eq(CoinRules.chance(3, 0), 53, "Clérigo com SORTE 3")
	assert_eq(CoinRules.chance(30, 0), 65, "SORTE conta até +15")


func test_clamp_15_to_85() -> void:
	assert_eq(CoinRules.chance(0, -60), 15)
	assert_eq(CoinRules.chance(0, 60), 85)
	assert_eq(CoinRules.chance(15, 30), 85)


func test_streak_bonus_counts_before_the_clamp() -> void:
	assert_eq(CoinRules.chance(0, 0, 10), 60)
	assert_eq(CoinRules.chance(15, 20, 10), 85)


func test_cheat_adds_after_clamp_and_caps_at_90() -> void:
	assert_eq(CoinRules.chance(0, 0, 0, 20), 70, "anúncio +20")
	assert_eq(CoinRules.chance(0, 0, 0, 35), 85, "Moeda Viciada +35")
	assert_eq(CoinRules.chance(15, 20, 0, 35), 90, "nunca 100%")


func test_bad_luck_streak() -> void:
	var state: CoinState = CoinState.new()
	for loss: int in 2:
		state.record(false)
	assert_eq(state.streak_bonus(), 0)
	state.record(false)
	assert_eq(state.streak_bonus(), 10, "depois de 3 perdidos")
	state.record(false)
	assert_eq(state.streak_bonus(), 10, "continua enquanto perder")
	state.record(true)
	assert_eq(state.streak_bonus(), 0, "zera ao ganhar")
	assert_eq([state.flips, state.heads], [5, 1])


func test_flips_follow_the_chance() -> void:
	var rng: Pcg32 = Pcg32.new(31337, 4)
	var heads_at_50: int = 0
	var heads_at_15: int = 0
	for flip: int in 10000:
		if rng.draw_percent(CoinRules.chance(0, 0)):
			heads_at_50 += 1
		if rng.draw_percent(CoinRules.chance(0, -99)):
			heads_at_15 += 1
	assert_between(heads_at_50, 4800, 5200)
	assert_between(heads_at_15, 1350, 1650)
