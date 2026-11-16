extends GutTest
## GDD §8 (atributos iniciais) e §9 (crescimento com o Poder).


func test_make_reads_every_field_and_defaults() -> void:
	var stats: Stats = CombatFixtures.warrior_stats()
	assert_eq([stats.max_hp, stats.max_mp, stats.strength, stats.mind, stats.defense, stats.resistance],
		[130, 20, 14, 5, 12, 6])
	assert_eq([stats.speed, stats.precision, stats.evasion, stats.crit, stats.luck], [7, 90, 3, 5, 0])
	assert_eq(stats.precision_bonus(), 0)
	var empty: Stats = Stats.make({})
	assert_eq([empty.max_hp, empty.speed, empty.precision, empty.crit], [1, 1, 90, 5])


func test_power_1_changes_nothing() -> void:
	var base: Stats = CombatFixtures.warrior_stats()
	var same: Stats = base.scaled_for_power(1.0)
	assert_eq([same.max_hp, same.strength, same.defense, same.speed], [130, 14, 12, 7])
	var below: Stats = base.scaled_for_power(0.5)
	assert_eq(below.max_hp, 130, "Poder abaixo de 1 conta como 1")


func test_power_2_follows_gdd_growth() -> void:
	var grown: Stats = CombatFixtures.warrior_stats().scaled_for_power(2.0)
	assert_eq(grown.max_hp, 143, "HP +10%")
	assert_eq(grown.strength, 15, "FOR +8% (15,12)")
	assert_eq(grown.mind, 5, "MEN +8% (5,4)")
	assert_eq(grown.defense, 13, "DEF +6% (12,72)")
	assert_eq(grown.resistance, 6, "RES +6% (6,36)")
	assert_eq(grown.speed, 7, "VEL +2% (7,14)")
	assert_eq(grown.max_mp, 20, "MP não cresce com o Poder")
	assert_eq([grown.precision, grown.evasion, grown.crit, grown.luck], [90, 3, 5, 0], "vêm de equipamento e clima")


func test_power_45_end_of_a_descent() -> void:
	var grown: Stats = CombatFixtures.warrior_stats().scaled_for_power(45.0)
	assert_eq(grown.max_hp, 702)
	assert_eq(grown.strength, 63)
	assert_eq(grown.defense, 44)
	assert_eq(grown.speed, 13)


func test_scaling_does_not_touch_the_original() -> void:
	var base: Stats = CombatFixtures.warrior_stats()
	base.scaled_for_power(10.0)
	assert_eq(base.max_hp, 130)
