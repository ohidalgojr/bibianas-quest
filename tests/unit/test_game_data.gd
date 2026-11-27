extends GutTest
## Os dados do cenário 1 batem com o GDD e montam unidades de combate que respeitam as
## regras de justiça (GDD §7). Escala de nível no ADR-0009.

## Lutas por inimigo no teste de justiça com os inimigos de verdade.
const FIGHTS_PER_ENEMY: int = 150

var _data: GameData


func before_all() -> void:
	_data = DataLoader.load_all()


func test_data_is_valid() -> void:
	assert_true(_data.is_valid(), "\n".join(_data.errors))


## GDD §8, atributos iniciais do Guerreiro (Poder 1,0).
func test_warrior_stats_match_gdd_section_8() -> void:
	var stats: Stats = _data.class_stats("warrior")
	var expected: Dictionary = {"max_hp": 130, "max_mp": 20, "strength": 14, "mind": 5, "defense": 12,
		"resistance": 6, "speed": 7, "precision": 90, "evasion": 3, "crit": 5, "luck": 0}
	for key: String in expected:
		assert_eq(stats.get(key), expected[key], "Guerreiro, %s" % key)
	var player: Combatant = _data.make_player("warrior")
	assert_true(player.veteran, "passiva Veterano")
	assert_eq(player.hp, 130)


## GDD §8, skills de combate do Guerreiro, iguais às do motor (TASK-004).
func test_warrior_skills_match_gdd_section_8() -> void:
	var skills: Array[CombatSkill] = _data.class_skills("warrior")
	var reference: Array[CombatSkill] = CombatSkill.warrior_set()
	assert_eq(skills.size(), reference.size())
	for index: int in reference.size():
		assert_eq(skills[index].id, reference[index].id)
		assert_eq(skills[index].display_name, reference[index].display_name)
		assert_eq(skills[index].cost, reference[index].cost, skills[index].id)
		assert_eq(skills[index].effect, reference[index].effect, skills[index].id)
		assert_almost_eq(skills[index].power, reference[index].power, 0.0001, skills[index].id)


## GDD §17: Cidade Abandonada, 4 camadas (ADR-0049), inimigos de nível 1 a 6, O Coveiro.
func test_scenario_one_matches_gdd_section_17() -> void:
	var scenario: Dictionary = _data.scenario("abandoned_city")
	assert_eq(scenario["name"], "Cidade Abandonada")
	assert_eq(int(scenario["layers"]), 4)
	assert_eq(int(scenario["min_level"]), 1)
	assert_eq(int(scenario["max_level"]), 6)
	assert_eq(scenario["boss"], "gravedigger")
	assert_between((scenario["common_enemies"] as Array).size(), 4, 15, "4 a 15 comuns (ADR-0038, ADR-0039, ADR-0045, ADR-0046, ADR-0065)")
	assert_between((scenario["elite_enemies"] as Array).size(), 1, 3, "1 a 3 elites (ADR-0039)")


## GDD §15: consumível de 20 a 60; equipamento comum de 60 a 150.
func test_prices_follow_gdd_section_15() -> void:
	for item_id: String in _data.items:
		var item: Dictionary = _data.items[item_id]
		var price: int = int(item["price"])
		if item["slot"] == "consumable" and price > 0 and item_id != "firewood":
			assert_between(price, 20, 60, item_id)
		elif item["rarity"] == "common":
			assert_between(price, 60, 150, item_id)


func test_consumables_become_combat_items() -> void:
	var potion: CombatItem = _data.combat_item("murky_potion")
	assert_eq(potion.heal_hp_percent, 30)
	assert_eq(_data.combat_item("dirty_ether").heal_mp_percent, 50)
	assert_null(_data.combat_item("worn_longsword"), "equipamento não é consumível")


## ADR-0009: nível acima do base cresce como o Poder (GDD §9); abaixo não encolhe.
func test_enemy_level_scaling() -> void:
	assert_almost_eq(GameData.level_power(1, 1), 1.0, 0.0001)
	assert_almost_eq(GameData.level_power(6, 1), 6.0, 0.0001)
	assert_almost_eq(GameData.level_power(1, 2), 1.0, 0.0001)
	var base: Stats = _data.enemy_stats("infected_citizen", 1)
	assert_eq(base.max_hp, 48)
	var high: Stats = _data.enemy_stats("infected_citizen", 6)
	assert_eq(high.max_hp, roundi(48 * 1.5), "HP +10% por nível")
	assert_eq(high.strength, roundi(10 * 1.4), "FOR +8% por nível")
	assert_eq(high.defense, roundi(4 * 1.3), "DEF +6% por nível")
	assert_eq(high.evasion, base.evasion, "ESQ não cresce")


func test_boss_is_built_from_data() -> void:
	var boss: Combatant = _data.make_enemy("gravedigger", 6)
	assert_eq(boss.display_name, "O Coveiro")
	assert_true(boss.is_boss)
	assert_false(boss.can_flee, "chefe não permite fuga (GDD §13)")
	assert_eq(boss.phases.size(), 2)
	assert_eq(boss.phases[1].below_hp_percent, 50)
	assert_eq(boss.phases[1].moves[0].kind, EnemyMove.Kind.MORTAL)
	assert_almost_eq(boss.element_multiplier(CombatFormulas.Element.HOLY), 1.5, 0.0001)
	assert_almost_eq(boss.element_multiplier(CombatFormulas.Element.SHADOW), 0.5, 0.0001)
	assert_almost_eq(boss.element_multiplier(CombatFormulas.Element.FIRE), 1.0, 0.0001)
	var rat: Combatant = _data.make_enemy("giant_rat", 3)
	assert_false(rat.is_boss)
	assert_true(rat.can_flee)


## GDD §7, limites de justiça, com os inimigos de verdade nos níveis do cenário 1. O
## Poder da Bibiana acompanha o nível, como numa Descida sem tropeços.
func test_property_real_enemies_respect_fairness_rules() -> void:
	var scenario: Dictionary = _data.scenario("abandoned_city")
	var low: int = int(scenario["min_level"])
	var high: int = int(scenario["max_level"])
	var enemy_ids: Array = []
	enemy_ids.append_array(scenario["common_enemies"])
	enemy_ids.append_array(scenario["elite_enemies"])
	enemy_ids.append(scenario["boss"])
	var problems: PackedStringArray = PackedStringArray()
	for enemy_id: Variant in enemy_ids:
		var turns: int = 0
		var wins: int = 0
		for fight: int in FIGHTS_PER_ENEMY:
			var level: int = high if _data.enemy_type(str(enemy_id)) == "boss" else low + fight % (high - low + 1)
			var power: float = 1.0 + 0.5 * float(level - 1)
			var combat: Combat = CombatFixtures.play(fight * 7919 + 13, _data.make_enemy(str(enemy_id), level), power)
			var found: PackedStringArray = CombatFixtures.audit(combat)
			if not found.is_empty() and problems.size() < 5:
				problems.append("%s nível %d, luta %d: %s" % [enemy_id, level, fight, " | ".join(found)])
			if combat.outcome == Combat.Outcome.VICTORY:
				wins += 1
			for event: CombatEvent in combat.history:
				if event.type == CombatEvent.Type.TURN and event.side == Combatant.PLAYER:
					turns += 1
		gut.p("%s: %.1f turnos do jogador por luta, %d%% de vitórias" % [
			enemy_id, float(turns) / FIGHTS_PER_ENEMY, roundi(100.0 * wins / FIGHTS_PER_ENEMY)])
	assert_eq(" || ".join(problems), "")
