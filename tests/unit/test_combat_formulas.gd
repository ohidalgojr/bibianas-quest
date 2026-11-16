extends GutTest
## GDD §6 (fórmulas de dano e acerto, Defender) e §7 (multiplicadores da moeda e
## limite de morte imediata). Leituras no ADR-0008.


func test_damage_formula_neutral_case() -> void:
	# 14 x 1 x 100 / 112 = 12,5
	assert_almost_eq(CombatFormulas.raw_damage(14.0, 1.0, 12.0, 1.0, 1.0, 1.0, 1.0), 12.5, 0.0001)
	assert_eq(CombatFormulas.final_damage(12.5), 13)


func test_damage_formula_multiplies_every_factor() -> void:
	var raw: float = CombatFormulas.raw_damage(20.0, 0.8, 0.0, 1.1, CombatFormulas.CRIT_MULTIPLIER,
		CombatFormulas.WEAKNESS, 1.0)
	assert_almost_eq(raw, 20.0 * 0.8 * 1.1 * 1.5 * 1.5, 0.0001)
	var resisted: float = CombatFormulas.raw_damage(20.0, 1.0, 100.0, 0.9, 1.0, CombatFormulas.RESISTANT, 1.0)
	assert_almost_eq(resisted, 20.0 * 0.5 * 0.9 * 0.5, 0.0001)


func test_constants_match_the_gdd() -> void:
	assert_eq(CombatFormulas.CRIT_MULTIPLIER, 1.5)
	assert_eq(CombatFormulas.WEAKNESS, 1.5)
	assert_eq(CombatFormulas.RESISTANT, 0.5)
	assert_eq([CombatFormulas.VARIANCE_LOW, CombatFormulas.VARIANCE_HIGH], [0.9, 1.1])
	assert_eq(CombatFormulas.DEFEND_REDUCTION, 0.5)
	assert_eq(CombatFormulas.DEFEND_MP_RETURN, 0.1)


func test_final_damage_rounds_and_never_goes_below_1() -> void:
	assert_eq(CombatFormulas.final_damage(0.2), 1)
	assert_eq(CombatFormulas.final_damage(7.4), 7)
	assert_eq(CombatFormulas.final_damage(7.6), 8)


func test_hit_chance_clamp() -> void:
	assert_eq(CombatFormulas.hit_chance(0, 0), 90)
	assert_eq(CombatFormulas.hit_chance(0, 3), 87, "Guerreiro contra ESQ 3")
	assert_eq(CombatFormulas.hit_chance(0, 12), 78, "contra o Ladino (ESQ 12)")
	assert_eq(CombatFormulas.hit_chance(50, 0), 98, "teto 98")
	assert_eq(CombatFormulas.hit_chance(-100, 0), 10, "piso 10")


func test_defend_reduction() -> void:
	assert_eq(CombatFormulas.defend_reduction(false), 0.5)
	assert_eq(CombatFormulas.defend_reduction(true), 0.65, "Veterano protege 30% a mais")


func test_coin_multipliers_without_defending() -> void:
	var heavy: EnemyMove.Kind = EnemyMove.Kind.HEAVY
	var cruel: EnemyMove.Kind = EnemyMove.Kind.CRUEL
	var mortal: EnemyMove.Kind = EnemyMove.Kind.MORTAL
	assert_eq(CombatFormulas.coin_damage_multiplier(heavy, true, false, false), 1.0)
	assert_eq(CombatFormulas.coin_damage_multiplier(heavy, false, false, false), 1.5)
	assert_eq(CombatFormulas.coin_damage_multiplier(cruel, true, false, false), 0.5)
	assert_eq(CombatFormulas.coin_damage_multiplier(cruel, false, false, false), 2.0)
	assert_eq(CombatFormulas.coin_damage_multiplier(mortal, true, false, false), 1.0)
	assert_eq(CombatFormulas.coin_damage_multiplier(mortal, false, false, false), 2.5)
	assert_eq(CombatFormulas.coin_damage_multiplier(EnemyMove.Kind.ATTACK, false, false, false), 1.0)


func test_defending_halves_the_penalty_and_veteran_cancels_it() -> void:
	var heavy: EnemyMove.Kind = EnemyMove.Kind.HEAVY
	var cruel: EnemyMove.Kind = EnemyMove.Kind.CRUEL
	var mortal: EnemyMove.Kind = EnemyMove.Kind.MORTAL
	assert_eq(CombatFormulas.coin_damage_multiplier(heavy, false, true, false), 1.25)
	assert_eq(CombatFormulas.coin_damage_multiplier(cruel, false, true, false), 1.5)
	assert_eq(CombatFormulas.coin_damage_multiplier(mortal, false, true, false), 1.75)
	assert_eq(CombatFormulas.coin_damage_multiplier(heavy, false, true, true), 1.0)
	assert_eq(CombatFormulas.coin_damage_multiplier(mortal, false, true, true), 1.0)
	assert_eq(CombatFormulas.coin_damage_multiplier(cruel, true, true, true), 0.5, "o bônus de Cara não muda")
	assert_eq(CombatFormulas.coin_damage_multiplier(heavy, false, false, true), 1.5, "Veterano só vale defendendo")


func test_lethal_guard() -> void:
	assert_eq(CombatFormulas.cap_lethal(200, 130, 130), 129)
	assert_eq(CombatFormulas.cap_lethal(100, 79, 130), 78, "79 de 130 é mais de 60%")
	assert_eq(CombatFormulas.cap_lethal(100, 78, 130), 100, "78 de 130 é exatamente 60%: pode morrer")
	assert_eq(CombatFormulas.cap_lethal(10, 130, 130), 10, "golpe que não mata passa inteiro")
