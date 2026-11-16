extends GutTest
## TASK-016 (ADR-0020): golpes de debuff por chance própria, Veneno e Fraqueza do GDD §11
## e intervalo mínimo entre golpes de moeda (GDD §7).


## Inimigo que só faz o golpe de debuff dado, com o efeito, a chance e a defesa da Bibiana.
func _fight(effect: CombatEffect.Kind, chance: int, fight_seed: int = 1, enemy_hp: int = 500) -> Combat:
	var moves: Array[EnemyMove] = [EnemyMove.make("hex", EnemyMove.Kind.DEBUFF, 0.5, 0, effect, chance)]
	var stats: Stats = Stats.make({"hp": enemy_hp, "strength": 8, "defense": 4, "resistance": 2, "speed": 7, "evasion": 0})
	var enemy: Combatant = Combatant.enemy("Teste", stats, CombatFixtures.single_phase(moves))
	var combat: Combat = Combat.new(CombatFixtures.warrior(), enemy, RngStreams.new(fight_seed), CoinState.new())
	combat.start()
	return combat


func _effect_events(combat: Combat, label: String) -> int:
	var found: int = 0
	for event: CombatEvent in combat.history:
		if event.type == CombatEvent.Type.EFFECT_ON and event.side == Combatant.PLAYER and event.label == label:
			found += 1
	return found


func test_debuff_with_full_chance_always_applies_on_hit() -> void:
	var combat: Combat = _fight(CombatEffect.Kind.WEAKENED, 100)
	for turn: int in 6:
		combat.act(Combat.Action.ATTACK)
	assert_gt(_effect_events(combat, "weakened"), 0)


func test_debuff_with_zero_chance_never_applies() -> void:
	var combat: Combat = _fight(CombatEffect.Kind.WEAKENED, 0)
	for turn: int in 12:
		combat.act(Combat.Action.ATTACK)
	assert_eq(_effect_events(combat, "weakened"), 0)
	assert_false(combat.player.has_effect(CombatEffect.Kind.WEAKENED))


## Defender corta a chance pela metade: com 50% base vira 25%, e a frequência observada
## em muitas lutas fica claramente abaixo.
func test_defend_halves_the_debuff_chance() -> void:
	var plain: int = 0
	var guarded: int = 0
	var hits_plain: int = 0
	var hits_guarded: int = 0
	for fight_seed: int in 60:
		for defend: bool in [false, true]:
			var combat: Combat = _fight(CombatEffect.Kind.POISON, 50, fight_seed)
			for turn: int in 4:
				combat.act(Combat.Action.DEFEND if defend else Combat.Action.ATTACK)
			var applied: int = _effect_events(combat, "poison")
			if defend:
				guarded += 1
				hits_guarded += applied
			else:
				plain += 1
				hits_plain += applied
	assert_gt(hits_plain, hits_guarded, "defender reduz as aplicações (%d contra %d)" % [hits_plain, hits_guarded])
	assert_eq(plain, guarded)


## GDD §11: Veneno tira 5% do HP máximo por turno e dura 4 turnos.
func test_poison_ticks_five_percent_for_four_turns() -> void:
	var combat: Combat = _fight(CombatEffect.Kind.POISON, 100)
	var expected: int = roundi(combat.player.stats.max_hp * 5 / 100.0)
	var ticks: Array[int] = []
	for turn: int in 12:
		if combat.outcome != Combat.Outcome.ONGOING:
			break
		combat.act(Combat.Action.DEFEND)
	for event: CombatEvent in combat.history:
		if event.type == CombatEvent.Type.DAMAGE and event.label == "poison":
			ticks.append(event.value)
	assert_gt(ticks.size(), 0, "o veneno causou dano")
	for damage: int in ticks:
		assert_eq(damage, expected)
	assert_eq(CombatEffect.POISON_TURNS, 4)


## GDD §11: Fraqueza reduz FOR em 25%.
func test_weakened_reduces_strength() -> void:
	var unit: Combatant = CombatFixtures.warrior()
	var base: float = unit.effective_strength()
	unit.effects.append(CombatEffect.make(CombatEffect.Kind.WEAKENED, 3))
	assert_almost_eq(unit.effective_strength(), base * 0.75, 0.0001)
	assert_almost_eq(unit.effective_mind(), unit.stats.mind * 0.75, 0.0001)


## GDD §7 e ADR-0020: ao menos 2 golpes entre dois golpes de moeda, chefes inclusive.
func test_coin_strikes_keep_a_gap_in_every_fight() -> void:
	for fight_seed: int in 60:
		var combat: Combat = CombatFixtures.play(fight_seed, CombatFixtures.enemy_by_index(fight_seed), 1.0)
		var problems: PackedStringArray = CombatFixtures.audit(combat)
		assert_eq(problems.size(), 0, "semente %d: %s" % [fight_seed, "; ".join(problems)])


func test_intent_of_debuff_shows_effect_and_chance() -> void:
	var data: GameData = DataLoader.load_all()
	var session: CombatSession = CombatSession.new(data, "gravedigger", 6, 1.0, 1)
	session.start()
	var view: Dictionary = session.intent_view("rot")
	assert_eq(view["icon"], "DEBILITA")
	assert_true(view["debuff"])
	assert_false(view["coin"])
	assert_string_contains(str(view["detail"]), "Veneno com 60% de chance (30% se você Defender)")
	assert_string_contains(str(session.intent_view("curse")["detail"]), "Fraqueza com 70%")
	assert_eq(view["name"], "Toque Podre")


func test_gravedigger_data_has_debuff_moves_and_less_coin() -> void:
	var data: GameData = DataLoader.load_all()
	var boss: Combatant = data.make_enemy("gravedigger", 6)
	for phase: EnemyPhase in boss.phases:
		var coin: int = 0
		var debuff: int = 0
		for move: EnemyMove in phase.moves:
			coin += 1 if move.is_coin() else 0
			debuff += 1 if move.kind == EnemyMove.Kind.DEBUFF else 0
		assert_gt(debuff, 0, "toda fase do Coveiro tem golpe de debuff")
		assert_lte(coin * 5, phase.moves.size() * 2, "moeda em no máximo 2 de cada 5 golpes")
