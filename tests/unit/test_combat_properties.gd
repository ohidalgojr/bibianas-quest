extends GutTest
## GDD §6 e §7, limites de justiça: em milhares de lutas jogadas por um bot, nenhum
## golpe perigoso sem aviso, nenhuma morte imediata acima de 60% de vida, nenhum golpe
## de moeda seguido (fora da fase final de chefes) e toda luta termina.

const FIGHTS: int = 2000


func test_property_fairness_rules_hold_in_thousands_of_fights() -> void:
	var problems: PackedStringArray = PackedStringArray()
	var outcomes: Dictionary = {}
	var coin_actions: int = 0
	var player_turns: Dictionary = {}
	for run_seed: int in FIGHTS:
		var power: float = 1.0 + float(run_seed % 5) * 0.5
		var combat: Combat = CombatFixtures.play(run_seed, CombatFixtures.enemy_by_index(run_seed), power)
		var found: PackedStringArray = CombatFixtures.audit(combat)
		if not found.is_empty():
			problems.append("semente %d contra %s: %s" % [run_seed, combat.enemy.display_name, " | ".join(found)])
			if problems.size() >= 5:
				break
		outcomes[combat.outcome] = int(outcomes.get(combat.outcome, 0)) + 1
		var turns: int = 0
		for event: CombatEvent in combat.history:
			if event.type == CombatEvent.Type.TURN and event.side == Combatant.PLAYER:
				turns += 1
			if event.type == CombatEvent.Type.ACTION and event.side == Combatant.ENEMY and event.value == EnemyMove.Intent.COIN:
				coin_actions += 1
		var key: String = combat.enemy.display_name
		player_turns[key] = int(player_turns.get(key, 0)) + turns
	assert_eq(" || ".join(problems), "", "%d lutas" % FIGHTS)
	var per_enemy: float = float(FIGHTS) / float(CombatFixtures.ENEMY_COUNT)
	for key: String in player_turns:
		gut.p("%s: %.1f turnos do jogador por luta" % [key, float(player_turns[key]) / per_enemy])
	gut.p("vitórias %d, derrotas %d, fugas %d, golpes de moeda do inimigo %d" % [
		int(outcomes.get(Combat.Outcome.VICTORY, 0)), int(outcomes.get(Combat.Outcome.DEFEAT, 0)),
		int(outcomes.get(Combat.Outcome.FLED, 0)), coin_actions])
	assert_gt(int(outcomes.get(Combat.Outcome.VICTORY, 0)), 0)
	assert_gt(int(outcomes.get(Combat.Outcome.DEFEAT, 0)), 0)
	assert_gt(coin_actions, FIGHTS, "a moeda precisa aparecer de verdade")


func test_audit_catches_each_kind_of_violation() -> void:
	var combat: Combat = Combat.new(CombatFixtures.warrior(), CombatFixtures.grunt(), RngStreams.new(1), CoinState.new())
	combat.outcome = Combat.Outcome.VICTORY
	var e: int = Combatant.ENEMY
	var p: int = Combatant.PLAYER
	combat.history = [
		CombatEvent.make(CombatEvent.Type.INTENT, e, "heavy", EnemyMove.Intent.COIN),
		CombatEvent.make(CombatEvent.Type.ACTION, e, "heavy", EnemyMove.Intent.COIN),
		CombatEvent.make(CombatEvent.Type.TURN, p),
		CombatEvent.make(CombatEvent.Type.ACTION, e, "cruel", EnemyMove.Intent.COIN),
		CombatEvent.make(CombatEvent.Type.ACTION, e, "strong", EnemyMove.Intent.STRONG),
		CombatEvent.make(CombatEvent.Type.ACTION, e, "strong", EnemyMove.Intent.STRONG),
		CombatEvent.make(CombatEvent.Type.ACTION, e, "grave", EnemyMove.Intent.COIN),
		CombatEvent.make(CombatEvent.Type.DAMAGE, p, "attack", 130, false, 0),
	]
	var found: String = " | ".join(CombatFixtures.audit(combat))
	assert_string_contains(found, "sem turno do jogador")
	assert_string_contains(found, "dois golpes de moeda")
	assert_string_contains(found, "mesmo golpe forte")
	assert_string_contains(found, "golpe mortal fora de chefe")
	assert_string_contains(found, "morte imediata")
