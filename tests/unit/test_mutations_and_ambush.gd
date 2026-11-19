extends GutTest
## TASK-027 (ADR-0032): inimigos mutados (GDD §11), emboscadas com ataque inicial e
## vulnerabilidade de 1 turno (GDD §5), e influência de SORTE e Maré de azar na frequência
## de mutados, emboscadas e raridade de drops (D1, GDD §5, §7 e §11).

var _data: GameData


func before_all() -> void:
	_data = DataLoader.load_all()


func test_each_common_enemy_has_configured_mutation_in_data() -> void:
	assert_eq(_data.enemy_mutation("infected_citizen"), Mutations.BLOATED)
	assert_eq(_data.enemy_mutation("giant_rat"), Mutations.VORACIOUS)
	assert_eq(_data.enemy_mutation("carrion_crow"), Mutations.PHANTOM)
	assert_eq(_data.enemy_mutation("plague_hound"), Mutations.THORNY)
	assert_eq(_data.enemy_mutation("rotten_executioner"), "")
	assert_eq(_data.enemy_mutation("gravedigger"), "")


func test_bloated_and_phantom_modify_enemy_stats() -> void:
	var normal_citizen: Combatant = _data.make_enemy("infected_citizen", 3)
	var mutated_citizen: Combatant = _data.make_enemy("infected_citizen", 3, Mutations.BLOATED)
	assert_eq(mutated_citizen.mutation, Mutations.BLOATED)
	assert_string_contains(mutated_citizen.display_name, "(Inchado)")
	assert_gt(mutated_citizen.stats.max_hp, normal_citizen.stats.max_hp, "Inchado: +50% HP")
	assert_lt(mutated_citizen.stats.speed, normal_citizen.stats.speed, "Inchado: VEL -2")

	var normal_crow: Combatant = _data.make_enemy("carrion_crow", 3)
	var mutated_crow: Combatant = _data.make_enemy("carrion_crow", 3, Mutations.PHANTOM)
	assert_eq(mutated_crow.mutation, Mutations.PHANTOM)
	assert_eq(mutated_crow.stats.evasion, normal_crow.stats.evasion + Mutations.PHANTOM_EVASION_BONUS, "Fantasma: ESQ +15")


func test_voracious_heals_from_damage_and_thorny_reflects_damage() -> void:
	var player: Combatant = Combatant.player("Bibiana", _data.class_stats("warrior"), true)
	player.stats.evasion = 0
	var rat: Combatant = _data.make_enemy("giant_rat", 3, Mutations.VORACIOUS)
	rat.hp = rat.stats.max_hp - 20
	var hp_before: int = rat.hp
	var combat: Combat = Combat.new(player, rat, RngStreams.new(10), CoinState.new())
	combat.start()
	# Avança até o Rato atacar.
	var steps: int = 0
	while combat.outcome == Combat.Outcome.ONGOING and steps < 6:
		steps += 1
		combat.act(Combat.Action.DEFEND)
	var saw_voracious_heal: bool = false
	for event: CombatEvent in combat.history:
		if event.type == CombatEvent.Type.HEAL and event.side == Combatant.ENEMY and event.label == Mutations.VORACIOUS:
			saw_voracious_heal = true
	assert_true(saw_voracious_heal, "Voraz cura 25% do dano causado")
	assert_gt(rat.hp, hp_before, "HP do Rato subiu após morder")

	var player2: Combatant = Combatant.player("Bibiana", _data.class_stats("warrior"), true)
	player2.stats.precision = 200
	var hound: Combatant = _data.make_enemy("plague_hound", 3, Mutations.THORNY)
	hound.stats.evasion = 0
	var combat2: Combat = Combat.new(player2, hound, RngStreams.new(11), CoinState.new())
	combat2.start()
	var player_hp_before: int = player2.hp
	combat2.act(Combat.Action.ATTACK)
	var saw_thorny: bool = false
	for event: CombatEvent in combat2.history:
		if event.type == CombatEvent.Type.DAMAGE and event.side == Combatant.PLAYER and event.label == Mutations.THORNY:
			saw_thorny = true
	assert_true(saw_thorny, "Espinhoso reflete 15% do dano físico")
	assert_lt(player2.hp, player_hp_before, "Bibiana perdeu HP pelo reflexo de Espinhoso")


func test_ambush_gives_enemy_first_strike_and_player_armor_down_without_coin_surprise() -> void:
	var player: Combatant = Combatant.player("Bibiana", _data.class_stats("warrior"), true)
	player.stats.evasion = 0
	var enemy: Combatant = _data.make_enemy("infected_citizen", 2)
	var combat: Combat = Combat.new(player, enemy, RngStreams.new(7), CoinState.new())
	combat.ambushed = true
	combat.start()
	assert_lt(player.hp, player.stats.max_hp, "na emboscada o inimigo age antes do 1º turno da Bibiana")
	var saw_armor_down: bool = false
	var first_enemy_action: CombatEvent = null
	for event: CombatEvent in combat.history:
		if event.type == CombatEvent.Type.EFFECT_ON and event.side == Combatant.PLAYER and event.label == "armor_down":
			saw_armor_down = true
		if first_enemy_action == null and event.type == CombatEvent.Type.ACTION and event.side == Combatant.ENEMY:
			first_enemy_action = event
	assert_true(saw_armor_down, "Bibiana sofre Guarda aberta no bote da emboscada")
	assert_not_null(first_enemy_action, "inimigo agiu na abertura da emboscada")
	assert_ne(first_enemy_action.value, EnemyMove.Intent.COIN, "golpe inicial da emboscada nunca é de moeda sem aviso")


func test_mutated_nodes_follow_fairness_rules_and_show_on_map_and_rewards() -> void:
	var saw_mutated: bool = false
	for run_seed: int in range(1, 31):
		var run: RunState = RunState.new(_data, run_seed)
		var violations: PackedStringArray = MapRules.find_violations(run.map, MapConfig.for_layers(run.map.layer_count))
		assert_true(violations.is_empty(), "seed %d sem violações de MapRules: %s" % [run_seed, ", ".join(violations)])
		for layer: int in [1, 2]:
			for node: MapNode in run.map.layer_nodes(layer):
				assert_false(node.is_mutated(), "camadas 1 e 2 nunca têm mutados (seed %d)" % run_seed)
		for layer: int in range(3, run.map.layer_count + 1):
			var count: int = 0
			for node: MapNode in run.map.layer_nodes(layer):
				if node.is_mutated():
					count += 1
					saw_mutated = true
			assert_lte(count, 1, "no máximo 1 mutado por camada (seed %d, camada %d)" % [run_seed, layer])
	assert_true(saw_mutated, "mutados aparecem nas camadas 3..6 ao longo das sementes")

	# Verifica exibição no MapView e recompensa ×1,5 de Poder ao derrotar um mutado.
	var run: RunState = RunState.new(_data, 5)
	var target: MapNode = run.options()[0]
	target.kind = MapNode.Kind.AMBUSH
	target.enemy_id = "giant_rat"
	target.mutation = Mutations.VORACIOUS
	target.level = 3
	var view: MapView = MapView.new(run)
	var info: Dictionary = view.node_view(target)
	assert_eq(str(info["mutation"]), Mutations.VORACIOUS)
	assert_true(bool(info["ambush"]))
	assert_string_contains(str(info["title"]), "Emboscada Mutada")
	assert_string_contains(str(info["detail"]), "[Voraz]")

	assert_true(run.choose_node(target.id))
	assert_true(run.combat.ambushed)
	assert_eq(run.combat.enemy.mutation, Mutations.VORACIOUS)
	run.combat.enemy.hp = 1
	run.combat.enemy.stats.evasion = 0
	run.combat.act(Combat.Action.ATTACK)
	var power_before: float = run.power
	assert_true(run.finish_fight())
	assert_almost_eq(run.power - power_before, RunRules.power_gain(3, "mutated"), 0.0001, "Poder ×1,5 para inimigo mutado")
	var panels: RunPanels = RunPanels.new(run)
	var reward: Dictionary = panels.reward_view()
	assert_string_contains(str(reward["lines"][0]), "[Voraz]")


func test_luck_and_bad_luck_shift_mutation_and_ambush_rates() -> void:
	assert_gt(RunRules.mutation_chance(RunRules.MUTATION_BASE_PERCENT, -5, true),
		RunRules.mutation_chance(RunRules.MUTATION_BASE_PERCENT, 0, false),
		"Maré de azar e SORTE baixa aumentam a chance de mutação")
	assert_lt(RunRules.mutation_chance(RunRules.MUTATION_BASE_PERCENT, 5, false),
		RunRules.mutation_chance(RunRules.MUTATION_BASE_PERCENT, 0, false),
		"SORTE alta reduz a chance de mutação")
	assert_gt(RunRules.ambush_shift_chance(-5, true), 0, "azar converte lutas comuns em emboscadas")
	assert_gt(RunRules.ambush_avoid_chance(5, false), 0, "SORTE alta evita emboscadas")

	# Teste de distribuição em 60 mapas: Maré de azar gera mais mutados e mais emboscadas na camada seguinte.
	var normal_mutated: int = 0
	var normal_ambushes: int = 0
	var unlucky_mutated: int = 0
	var unlucky_ambushes: int = 0
	var lucky_ambushes: int = 0
	for run_seed: int in range(1, 61):
		var normal_run: RunState = RunState.new(_data, run_seed)
		normal_run._apply_luck_to_layer(3)
		for node: MapNode in normal_run.map.layer_nodes(3):
			if node.is_mutated():
				normal_mutated += 1
			if node.kind == MapNode.Kind.AMBUSH:
				normal_ambushes += 1

		var bad_run: RunState = RunState.new(_data, run_seed)
		bad_run.coin.losses_in_row = 3
		bad_run._apply_luck_to_layer(3)
		for node: MapNode in bad_run.map.layer_nodes(3):
			if node.is_mutated():
				unlucky_mutated += 1
			if node.kind == MapNode.Kind.AMBUSH:
				unlucky_ambushes += 1

		var good_run: RunState = RunState.new(_data, run_seed)
		good_run.equipment["relic"] = "grave_bell"
		good_run._apply_luck_to_layer(3)
		for node: MapNode in good_run.map.layer_nodes(3):
			if node.kind == MapNode.Kind.AMBUSH:
				lucky_ambushes += 1

	assert_gt(unlucky_mutated, normal_mutated, "Maré de azar aumenta o total de nós mutados na camada revelada")
	assert_gt(unlucky_ambushes, normal_ambushes, "Maré de azar aumenta o total de emboscadas na camada revelada")
	assert_lt(lucky_ambushes, normal_ambushes, "SORTE alta reduz as emboscadas na camada revelada")
