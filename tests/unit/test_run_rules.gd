extends GutTest
## Fórmulas da Descida: Poder (GDD §9), ouro (§15), baú e nível por camada (ADR-0011).


## GDD §9: delta de Poder = 0,4 × N × m_tipo (ADR-0023).
func test_power_gain_formula_gdd_section_9() -> void:
	assert_almost_eq(RunRules.power_gain(1, "common"), 0.4, 0.0001)
	assert_almost_eq(RunRules.power_gain(4, "common"), 1.6, 0.0001)
	assert_almost_eq(RunRules.power_gain(4, "elite"), 2.4, 0.0001)
	assert_almost_eq(RunRules.power_gain(6, "boss"), 9.6, 0.0001)
	assert_almost_eq(RunRules.power_gain(2, "mini_boss"), 2.0, 0.0001)
	assert_almost_eq(RunRules.power_gain(2, "roaming_boss"), 2.4, 0.0001)


## GDD §15: moedas = round(6 × N × U(0,8; 1,2) × m_tipo).
func test_gold_formula_gdd_section_15() -> void:
	assert_eq(RunRules.gold_for(1, "common", 1.0), 6)
	assert_eq(RunRules.gold_for(5, "common", 0.8), 24)
	assert_eq(RunRules.gold_for(5, "common", 1.2), 36)
	assert_eq(RunRules.gold_for(3, "elite", 1.0), 27)
	assert_eq(RunRules.gold_for(6, "boss", 1.0), 144)


func test_gold_drop_stays_in_range_and_uses_loot_stream() -> void:
	var loot: Pcg32 = RngStreams.new(42).loot()
	var low: int = 1000
	var high: int = 0
	for draw: int in 2000:
		var gold: int = RunRules.gold_drop(5, "common", loot)
		low = mini(low, gold)
		high = maxi(high, gold)
	assert_between(low, 24, 26, "perto de 6 × 5 × 0,8")
	assert_between(high, 34, 36, "perto de 6 × 5 × 1,2")
	var first: int = RunRules.gold_drop(3, "common", RngStreams.new(9).loot())
	assert_eq(RunRules.gold_drop(3, "common", RngStreams.new(9).loot()), first, "mesma semente, mesmo ouro")


## GDD §15: baús dão de 1 a 3 vezes o ouro de uma batalha comum.
func test_chest_gold_is_one_to_three_battles() -> void:
	var loot: Pcg32 = RngStreams.new(5).loot()
	for draw: int in 500:
		assert_between(RunRules.chest_gold(2, loot), 10, 3 * 14)


## ADR-0011: nível interpolado pela camada; o chefe no máximo.
func test_layer_level() -> void:
	var levels: Array[int] = []
	for layer: int in range(1, 7):
		levels.append(RunRules.layer_level(layer, 5, 1, 6))
	assert_eq(levels, [1, 2, 3, 4, 5, 6] as Array[int])


## GDD §15: atualizar a loja custa 15, depois mais 10 a cada vez.
func test_reroll_cost() -> void:
	assert_eq(RunRules.reroll_cost(0), 15)
	assert_eq(RunRules.reroll_cost(1), 25)
	assert_eq(RunRules.reroll_cost(2), 35)


func test_enemy_type_for_node_kind() -> void:
	assert_eq(RunRules.enemy_type_for(MapNode.Kind.BATTLE), "common")
	assert_eq(RunRules.enemy_type_for(MapNode.Kind.AMBUSH), "common")
	assert_eq(RunRules.enemy_type_for(MapNode.Kind.ELITE), "elite")
	assert_eq(RunRules.enemy_type_for(MapNode.Kind.BOSS), "boss")


## ADR-0016: Ecos pela profundidade e pelos chefes, sempre creditados.
func test_echoes_by_depth_and_bosses() -> void:
	assert_eq(RunRules.echoes(0, 0), 0)
	assert_eq(RunRules.echoes(6, 0), 6 * RunRules.ECHOES_PER_NODE)
	assert_eq(RunRules.echoes(10, 2), 10 * RunRules.ECHOES_PER_NODE + 2 * RunRules.ECHOES_PER_BOSS)


## ADR-0023: o nível é a parte inteira do Poder.
func test_level_is_the_integer_part_of_power() -> void:
	assert_eq(RunRules.level_of(1.0), 1)
	assert_eq(RunRules.level_of(1.99), 1)
	assert_eq(RunRules.level_of(2.0), 2)
	assert_eq(RunRules.level_of(3.4), 3)
