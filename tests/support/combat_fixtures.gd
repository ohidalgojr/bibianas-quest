class_name CombatFixtures
extends RefCounted
## Unidades de teste do combate e o auditor das regras de justiça. Os inimigos são
## inventados para exercitar o motor; os de verdade chegam com os dados (TASK-005).

const ENEMY_COUNT: int = 4


## Guerreiro com os atributos iniciais do GDD §8 (Poder 1,0).
static func warrior_stats() -> Stats:
	return Stats.make({"hp": 130, "mp": 20, "strength": 14, "mind": 5, "defense": 12, "resistance": 6,
		"speed": 7, "precision": 90, "evasion": 3, "crit": 5, "luck": 0})


static func warrior(power: float = 1.0) -> Combatant:
	return Combatant.player("Bibiana", warrior_stats().scaled_for_power(power), true)


static func single_phase(moves: Array[EnemyMove]) -> Array[EnemyPhase]:
	var phases: Array[EnemyPhase] = [EnemyPhase.make(100, moves)]
	return phases


static func grunt() -> Combatant:
	var moves: Array[EnemyMove] = [
		EnemyMove.basic_attack(),
		EnemyMove.make("heavy", EnemyMove.Kind.HEAVY),
		EnemyMove.basic_attack(),
		EnemyMove.make("strong", EnemyMove.Kind.STRONG, 1.4),
	]
	var stats: Stats = Stats.make({"hp": 45, "strength": 10, "defense": 4, "resistance": 2, "speed": 8, "evasion": 5})
	return Combatant.enemy("Rato de peste", stats, single_phase(moves))


static func brute() -> Combatant:
	var moves: Array[EnemyMove] = [
		EnemyMove.basic_attack(),
		EnemyMove.make("cruel", EnemyMove.Kind.CRUEL),
		EnemyMove.make("strong", EnemyMove.Kind.STRONG, 1.5),
		EnemyMove.make("mend", EnemyMove.Kind.HEAL, 1.0, 15),
	]
	var stats: Stats = Stats.make({"hp": 90, "strength": 15, "defense": 8, "resistance": 4, "speed": 5, "evasion": 2})
	return Combatant.enemy("Brutamontes", stats, single_phase(moves))


## Rápido: age duas vezes para cada turno da Bibiana, o caso que testa o aviso.
static func sprinter() -> Combatant:
	var moves: Array[EnemyMove] = [
		EnemyMove.make("heavy", EnemyMove.Kind.HEAVY),
		EnemyMove.make("strong", EnemyMove.Kind.STRONG, 1.3),
		EnemyMove.basic_attack(),
	]
	var stats: Stats = Stats.make({"hp": 50, "strength": 8, "defense": 3, "resistance": 3, "speed": 15, "evasion": 10})
	return Combatant.enemy("Cão de peste", stats, single_phase(moves))


static func boss() -> Combatant:
	var first: Array[EnemyMove] = [
		EnemyMove.basic_attack(),
		EnemyMove.make("shovel", EnemyMove.Kind.CRUEL),
		EnemyMove.make("sweep", EnemyMove.Kind.STRONG, 1.4),
		EnemyMove.basic_attack(),
	]
	var last_phase: Array[EnemyMove] = [
		EnemyMove.make("grave", EnemyMove.Kind.MORTAL),
		EnemyMove.make("shovel", EnemyMove.Kind.CRUEL),
		EnemyMove.make("heavy", EnemyMove.Kind.HEAVY),
		EnemyMove.basic_attack(),
	]
	var phases: Array[EnemyPhase] = [EnemyPhase.make(100, first), EnemyPhase.make(50, last_phase)]
	var stats: Stats = Stats.make({"hp": 220, "strength": 15, "defense": 10, "resistance": 8, "speed": 6, "evasion": 3})
	return Combatant.enemy("Coveiro", stats, phases, true)


static func enemy_by_index(index: int) -> Combatant:
	match index % ENEMY_COUNT:
		0:
			return grunt()
		1:
			return brute()
		2:
			return sprinter()
	return boss()


static func skill(skill_id: String) -> CombatSkill:
	for candidate: CombatSkill in CombatSkill.warrior_set():
		if candidate.id == skill_id:
			return candidate
	return null


## Joga uma luta inteira com um bot de decisões aleatórias mas razoáveis. O bot usa seu
## próprio gerador, separado dos fluxos do jogo.
static func play(run_seed: int, enemy_unit: Combatant, power: float, max_actions: int = 400) -> Combat:
	var combat: Combat = Combat.new(warrior(power), enemy_unit, RngStreams.new(run_seed), CoinState.new())
	var bot: Pcg32 = Pcg32.new(run_seed, 99)
	var potion: CombatItem = CombatItem.make("potion", 30)
	var potions: int = 2
	var skills: Array[CombatSkill] = CombatSkill.warrior_set()
	combat.start()
	var actions: int = 0
	while combat.is_player_turn() and actions < max_actions:
		actions += 1
		var danger: bool = combat.enemy.intent != null and combat.enemy.intent.is_dangerous()
		if combat.player.hp * 100 < combat.player.stats.max_hp * 35 and potions > 0:
			potions -= 1
			combat.act(Combat.Action.ITEM, null, potion)
		elif danger and bot.draw_percent(60):
			combat.act(Combat.Action.DEFEND)
		elif combat.enemy.can_flee and bot.draw_percent(3):
			combat.act(Combat.Action.FLEE)
		else:
			var chosen: CombatSkill = skills[bot.draw_index(skills.size())]
			if bot.draw_percent(40) and combat.can_act(Combat.Action.SKILL, chosen):
				combat.act(Combat.Action.SKILL, chosen)
			else:
				combat.act(Combat.Action.ATTACK)
	return combat


## Regras de justiça verificáveis no histórico. Lista vazia é luta limpa.
static func audit(combat: Combat) -> PackedStringArray:
	var found: PackedStringArray = PackedStringArray()
	var max_hp: int = combat.player.stats.max_hp
	var warned: bool = false
	var since_coin: int = Combat.COIN_GAP
	var previous: CombatEvent = null
	for index: int in combat.history.size():
		var event: CombatEvent = combat.history[index]
		match event.type:
			CombatEvent.Type.INTENT:
				warned = false
			CombatEvent.Type.TURN:
				if event.side == Combatant.PLAYER:
					warned = true
			CombatEvent.Type.ACTION:
				if event.side == Combatant.ENEMY:
					var dangerous: bool = event.value == EnemyMove.Intent.STRONG or event.value == EnemyMove.Intent.COIN
					if dangerous and not warned:
						found.append("#%d golpe perigoso %s sem turno do jogador depois do aviso" % [index, event.label])
					if previous != null:
						if dangerous and previous.label == event.label:
							found.append("#%d mesmo golpe forte duas vezes: %s" % [index, event.label])
					if event.value == EnemyMove.Intent.COIN:
						if since_coin < Combat.COIN_GAP:
							found.append("#%d golpes de moeda com menos de %d golpes entre eles" % [index, Combat.COIN_GAP])
						since_coin = 0
					else:
						since_coin += 1
					if event.label == "grave" and not combat.enemy.is_boss:
						found.append("#%d golpe mortal fora de chefe" % index)
					previous = event
			CombatEvent.Type.DAMAGE:
				if event.side == Combatant.PLAYER:
					var before: int = event.extra + event.value
					if event.extra == 0 and before * 100 > max_hp * CombatFormulas.LETHAL_GUARD_PERCENT:
						found.append("#%d morte imediata com %d de %d de vida" % [index, before, max_hp])
				if event.extra < 0:
					found.append("#%d vida negativa" % index)
			CombatEvent.Type.HEAL:
				if event.side == Combatant.PLAYER and combat.player.hp > max_hp:
					found.append("#%d vida acima do máximo" % index)
	if combat.outcome == Combat.Outcome.ONGOING:
		found.append("a luta não terminou")
	if combat.player.mp < 0 or combat.player.mp > combat.player.stats.max_mp:
		found.append("MP fora dos limites: %d" % combat.player.mp)
	return found


static func transcript(combat: Combat) -> String:
	var lines: PackedStringArray = PackedStringArray()
	for event: CombatEvent in combat.history:
		lines.append(event.describe())
	return "\n".join(lines)
