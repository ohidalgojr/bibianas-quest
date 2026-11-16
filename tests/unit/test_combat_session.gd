extends GutTest
## TASK-006 (ADR-0010): o controlador da tela monta a luta pelos dados, traduz eventos e
## mostra o golpe de moeda um turno antes, com a chance real (GDD §6 e §7).

var _data: GameData


func before_all() -> void:
	_data = DataLoader.load_all()


func _session(enemy_id: String = "infected_citizen", level: int = 1, fight_seed: int = 1) -> CombatSession:
	var session: CombatSession = CombatSession.new(_data, enemy_id, level, 1.0, fight_seed)
	session.start()
	return session


func test_fight_is_built_from_data() -> void:
	var session: CombatSession = _session("giant_rat", 3)
	assert_eq(session.player_name(), "Bibiana")
	assert_eq(session.enemy_name(), "Rato Grande")
	assert_eq(session.combat.enemy.stats.max_hp, _data.enemy_stats("giant_rat", 3).max_hp)
	assert_eq(session.skills.size(), 3)
	assert_eq(session.skill_label(0), "Golpe de Escudo (6 MP)")
	assert_true(session.can_act(), "a luta começa no turno da Bibiana ou chega nele")


func test_events_become_portuguese_lines() -> void:
	var session: CombatSession = _session()
	var lines: PackedStringArray = PackedStringArray()
	for event: CombatEvent in session.combat.history:
		var line: String = session.describe(event)
		if not line.is_empty():
			lines.append(line)
	assert_string_contains(lines[0], "A luta começa: Cidadão Infectado, nível 1. Semente 1.")
	assert_string_contains(" ".join(lines), "Cidadão Infectado prepara:")
	var coin: CombatEvent = CombatEvent.make(CombatEvent.Type.COIN, Combatant.PLAYER, "heavy", 60, false, 10)
	assert_eq(session.describe(coin), "Moeda (chance de Cara 60%): Coroa (falha). Maré de azar: +10.")
	var hit: CombatEvent = CombatEvent.make(CombatEvent.Type.DAMAGE, Combatant.ENEMY, "attack", 12, true, 30)
	assert_eq(session.describe(hit), "Cidadão Infectado sofre 12 de dano, crítico!")


## GDD §7: a consequência mostrada vem das constantes do núcleo.
func test_coin_intent_shows_real_chance_and_stakes() -> void:
	var session: CombatSession = _session("gravedigger", 6)
	var cruel: Dictionary = session.intent_view("shovel")
	assert_eq(cruel["icon"], "MOEDA")
	assert_true(cruel["coin"])
	assert_string_contains(str(cruel["detail"]), "Chance de Cara: %d%%" % session.coin_chance())
	assert_string_contains(str(cruel["detail"]), "Cara: dano -50%. Coroa: dano +100%")
	assert_string_contains(str(session.intent_view("grave")["detail"]), "Coroa: dano +150%")
	var strong: Dictionary = session.intent_view("sweep")
	assert_eq(strong["icon"], "FORTE")
	assert_false(strong["coin"])
	assert_true(strong["dangerous"])
	assert_eq(session.intent_view("attack")["icon"], "ATAQUE")


## GDD §7, limites de justiça, do ponto de vista da tela: todo golpe de moeda do
## inimigo foi mostrado como MOEDA no último INTENT antes de um turno da Bibiana.
func test_coin_strike_is_shown_one_player_turn_before() -> void:
	var coin_strikes: int = 0
	for fight_seed: int in 40:
		var session: CombatSession = _session("plague_hound", 1 + fight_seed % 6, fight_seed)
		var guard: int = 0
		while not session.is_over() and guard < 200:
			guard += 1
			if session.can_use_skill(1) and fight_seed % 2 == 0:
				session.use_skill(1)
			else:
				session.attack()
		var shown_icon: String = ""
		var icon_at_player_turn: String = ""
		for event: CombatEvent in session.combat.history:
			if event.type == CombatEvent.Type.INTENT:
				shown_icon = str(session.intent_view(event.label)["icon"])
			elif event.type == CombatEvent.Type.TURN and event.side == Combatant.PLAYER:
				icon_at_player_turn = shown_icon
			elif event.type == CombatEvent.Type.ACTION and event.side == Combatant.ENEMY \
					and event.value == EnemyMove.Intent.COIN:
				coin_strikes += 1
				assert_eq(icon_at_player_turn, "MOEDA", "semente %d" % fight_seed)
		assert_true(session.is_over(), "semente %d terminou" % fight_seed)
	assert_gt(coin_strikes, 0, "houve golpes de moeda para conferir")


func test_two_potions_per_fight() -> void:
	var session: CombatSession = _session("rotten_executioner", 6, 3)
	assert_eq(session.potion_label(), "Poção Turva (2)")
	var used: int = 0
	while not session.is_over() and session.can_use_potion():
		session.use_potion()
		used += 1
	assert_eq(used, CombatSession.POTIONS_PER_FIGHT)
	assert_false(session.can_use_potion())
	assert_eq(session.use_potion().size(), 0, "sem poção, nada acontece")


func test_no_flee_against_boss() -> void:
	assert_false(_session("gravedigger", 6).can_flee(), "GDD §13: chefe não permite fuga")
	assert_true(_session("giant_rat").can_flee())


func test_same_seed_same_fight() -> void:
	var first: CombatSession = _session("carrion_crow", 2, 77)
	var second: CombatSession = _session("carrion_crow", 2, 77)
	for step: int in 6:
		if first.is_over():
			break
		first.attack()
		second.attack()
	assert_eq(first.combat.history.size(), second.combat.history.size())
	assert_eq(first.combat.enemy.hp, second.combat.enemy.hp)
