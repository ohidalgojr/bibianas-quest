class_name CombatSession
extends RefCounted
## Controlador da tela de combate (ADR-0010). Monta a luta a partir dos dados, repassa
## as ações ao núcleo e traduz os eventos em textos e ícones. Não tem nós: a cena só
## desenha o que ele entrega, e os testes rodam sem tela.

## Poções Turvas por luta no protótipo (ADR-0010); o inventário real é da TASK-007.
const POTIONS_PER_FIGHT: int = 2
const POTION_ID: String = "murky_potion"
const ETHER_ID: String = "dirty_ether"
const CLASS_ID: String = "warrior"

var data: GameData
var combat: Combat
var enemy_id: String = ""
var level: int = 1
var power: float = 1.0
var run_seed: int = 0
var potions_left: int = POTIONS_PER_FIGHT
var skills: Array[CombatSkill] = []
var potion: CombatItem
var ether: CombatItem
## Descida dona da luta, quando a luta vem do mapa (ADR-0013). Sem ela, a luta é de
## teste e tem [constant POTIONS_PER_FIGHT] poções.
var run: RunState
## Último lado escolhido pelo jogador (ADR-0014); a tela grava antes de animar o lance.
var coin_call: int = CoinRules.HEADS

## Id do golpe -> tipo, para nomear golpes a partir dos eventos.
var _move_kinds: Dictionary = {}
## Id do golpe -> golpe, para o aviso mostrar efeito e chance (ADR-0020).
var _moves: Dictionary = {}


func _init(game_data: GameData, fight_enemy: String, fight_level: int, fight_power: float, fight_seed: int,
		coin_state: CoinState = null) -> void:
	data = game_data
	enemy_id = fight_enemy
	level = fight_level
	power = fight_power
	run_seed = fight_seed
	skills = data.class_skills(CLASS_ID)
	potion = data.combat_item(POTION_ID)
	ether = data.combat_item(ETHER_ID)
	if enemy_id.is_empty():
		return
	var enemy: Combatant = data.make_enemy(enemy_id, level)
	_learn_moves(enemy)
	combat = Combat.new(data.make_player(CLASS_ID, power), enemy, RngStreams.new(run_seed),
		coin_state if coin_state != null else CoinState.new())


## Sessão da luta em andamento na Descida (já começada pelo [RunState]).
static func for_run(run_state: RunState) -> CombatSession:
	var node: MapNode = run_state.current_node()
	var session: CombatSession = CombatSession.new(run_state.data, "", node.level, run_state.power,
		run_state.streams.run_seed)
	session.run = run_state
	session.enemy_id = node.enemy_id
	session.combat = run_state.combat
	session.skills = run_state.skills()
	session._learn_moves(run_state.combat.enemy)
	return session


func _learn_moves(enemy: Combatant) -> void:
	for phase: EnemyPhase in enemy.phases:
		for move: EnemyMove in phase.moves:
			_move_kinds[move.id] = move.kind
			_moves[move.id] = move


## Eventos já emitidos. Na Descida a luta começa no [RunState]; aqui só se lê o histórico.
func start() -> Array[CombatEvent]:
	if run != null:
		return combat.history.duplicate()
	return combat.start()


# --- Ações -----------------------------------------------------------------------

func attack() -> Array[CombatEvent]:
	return combat.act(Combat.Action.ATTACK)


func use_skill(index: int) -> Array[CombatEvent]:
	if not can_use_skill(index):
		return []
	return combat.act(Combat.Action.SKILL, skills[index])


func defend() -> Array[CombatEvent]:
	return combat.act(Combat.Action.DEFEND)


func use_potion() -> Array[CombatEvent]:
	if not can_use_potion():
		return []
	if run == null:
		potions_left -= 1
	return combat.act(Combat.Action.ITEM, null, potion)


func flee() -> Array[CombatEvent]:
	return combat.act(Combat.Action.FLEE)


func can_act() -> bool:
	return combat.is_player_turn()


func can_use_skill(index: int) -> bool:
	return index >= 0 and index < skills.size() and combat.can_act(Combat.Action.SKILL, skills[index])


func can_use_potion() -> bool:
	return potions_count() > 0 and combat.can_act(Combat.Action.ITEM, null, potion)


func potions_count() -> int:
	return run.available_in_fight(POTION_ID) if run != null else potions_left


func use_ether() -> Array[CombatEvent]:
	if not can_use_ether():
		return []
	return combat.act(Combat.Action.ITEM, null, ether)


func can_use_ether() -> bool:
	return ethers_count() > 0 and combat.can_act(Combat.Action.ITEM, null, ether)


func ethers_count() -> int:
	return run.available_in_fight(ETHER_ID) if run != null else 0


func ether_label() -> String:
	return "%s (%d)" % [str(data.items[ETHER_ID]["name"]), ethers_count()]


## Previsão do ataque básico: "dano 12-16 · acerto 90% · crít 5% · +2 MP" (ADR-0029).
func attack_hint() -> String:
	return "%s · +%d MP" % [_damage_hint(combat.preview_player_strike(1.0)),
		roundi(combat.player.stats.max_mp * CombatFormulas.ATTACK_MP_RETURN)]


## Previsão de uma skill: faixa de dano para as de dano; para as outras, o efeito.
func skill_hint(index: int) -> String:
	var skill: CombatSkill = skills[index]
	match skill.effect:
		CombatSkill.Effect.SHIELD_BASH, CombatSkill.Effect.CHARGE, CombatSkill.Effect.POWER_STRIKE:
			var power: float = skill.power
			return _damage_hint(combat.preview_player_strike(power))
		CombatSkill.Effect.BULWARK:
			return "DEF +%d%% e reflete %d%%" % [roundi(CombatEffect.BULWARK_DEFENSE * 100.0), roundi(CombatEffect.BULWARK_REFLECT * 100.0)]
		CombatSkill.Effect.WAR_CRY:
			return "FOR e MEN +%d%% por %d turnos" % [roundi(CombatEffect.EMPOWER_ATTACK * 100.0), CombatEffect.EMPOWER_TURNS]
		CombatSkill.Effect.MEND:
			return "cura %d de HP" % roundi(combat.player.stats.max_hp * CombatEffect.MEND_PERCENT / 100.0)
	return ""


## Descrição completa da skill, para a dica do botão.
func skill_tip(index: int) -> String:
	var skill: CombatSkill = skills[index]
	var extra: String = ""
	match skill.effect:
		CombatSkill.Effect.SHIELD_BASH:
			extra = " Moeda: acertar o lado atordoa o inimigo por 1 turno (em chefe, Lentidão)."
		CombatSkill.Effect.CHARGE:
			extra = " Deixa a guarda aberta: DEF -20% por 1 turno."
	return "%s (%d MP): %s.%s" % [skill.display_name, skill.cost, skill_hint(index), extra]


func _damage_hint(preview: Dictionary) -> String:
	return "dano %d-%d · acerto %d%% · crít %d%%" % [int(preview["min"]), int(preview["max"]), int(preview["hit"]), int(preview["crit"])]


func can_flee() -> bool:
	return combat.can_act(Combat.Action.FLEE)


func is_over() -> bool:
	return combat.outcome != Combat.Outcome.ONGOING


# --- Consultas para a tela -------------------------------------------------------

func player_name() -> String:
	return combat.player.display_name


func enemy_name() -> String:
	return combat.enemy.display_name


func is_boss() -> bool:
	return combat.enemy.is_boss


func timeline(count: int) -> Array[int]:
	return combat.preview_turn_order(count)


## Moedas da Sorte que ainda dá para usar na luta, e se estão armadas (ADR-0026).
func lucky_coins() -> int:
	return combat.lucky_coins_left()


func is_lucky_armed() -> bool:
	return combat.is_reroll_armed()


func toggle_lucky_coin() -> bool:
	return combat.arm_reroll(not combat.is_reroll_armed())


func move_kind(move_id: String) -> EnemyMove.Kind:
	return _move_kinds.get(move_id, EnemyMove.Kind.ATTACK)


## Ícone de intenção do golpe (GDD §6): texto do ícone, se é perigoso, se é de moeda e
## o detalhe. No golpe de moeda, o detalhe traz a chance real de Cara (GDD §7).
func intent_view(move_id: String, reason: int = 0) -> Dictionary:
	var kind: EnemyMove.Kind = move_kind(move_id)
	var move: EnemyMove = _moves.get(move_id, EnemyMove.make(move_id, kind))
	var view: Dictionary = {
		"icon": CombatTexts.intent_icon(move.intent()),
		"name": CombatTexts.move_name(kind, move_id),
		"dangerous": move.is_dangerous(),
		"coin": move.is_coin(),
		"debuff": kind == EnemyMove.Kind.DEBUFF,
		"detail": "",
	}
	if move.is_coin():
		view["detail"] = "Escolha Cara ou Coroa. %s%s." % [CombatTexts.coin_stakes(kind), CombatTexts.fail_text(move)]
	elif kind == EnemyMove.Kind.DEBUFF:
		view["detail"] = "Se acertar: %s com %d%% de chance (%d%% se você Defender)." % [
			CombatTexts.effect_label(move.effect), move.effect_chance,
			roundi(move.effect_chance * CombatEffect.DEFEND_CHANCE_FACTOR)]
	elif kind == EnemyMove.Kind.STRONG:
		view["detail"] = "Defender reduz o dano."
	if reason > 0 and CombatTexts.REACTION_TEXTS.has(reason):
		view["reason"] = str(CombatTexts.REACTION_TEXTS[reason])
		view["detail"] = "%s. %s" % [view["reason"], view["detail"]]
	return view


func skill_label(index: int) -> String:
	var skill: CombatSkill = skills[index]
	return "%s (%d MP)" % [skill.display_name, skill.cost]


func potion_label() -> String:
	return "%s (%d)" % [str(data.items[POTION_ID]["name"]), potions_count()]


func outcome_text() -> String:
	return CombatTexts.outcome(combat.outcome)


## Linha do registro da luta. Devolve "" para eventos que a tela não escreve.
func describe(event: CombatEvent) -> String:
	var who: String = _side_name(event.side)
	match event.type:
		CombatEvent.Type.STARTED:
			return "A luta começa: %s, nível %d. Semente %d." % [enemy_name(), level, run_seed]
		CombatEvent.Type.INTENT:
			return "%s prepara: %s." % [enemy_name(), CombatTexts.move_name(move_kind(event.label), event.label)] + _reason_suffix(event.extra)
		CombatEvent.Type.ACTION:
			return "%s usa %s." % [who, _action_name(event)]
		CombatEvent.Type.MISS:
			return "%s erra." % who
		CombatEvent.Type.DAMAGE:
			var line: String = "%s sofre %d de dano" % [who, event.value]
			if event.label == "reflect":
				line += " (reflexo da Muralha)"
			elif event.label == "poison":
				line += " (veneno)"
			if event.flag:
				return line + ", crítico!"
			return line + "."
		CombatEvent.Type.HEAL:
			if event.value == 0 and event.extra == 0:
				return ""
			var parts: PackedStringArray = PackedStringArray()
			if event.value > 0:
				parts.append("%d de HP" % event.value)
			if event.extra > 0:
				parts.append("%d de MP" % event.extra)
			return "%s recupera %s." % [who, " e ".join(parts)]
		CombatEvent.Type.COIN:
			var coin_line: String = "Moeda: você escolheu %s. %s" % [
				CombatTexts.side_name(coin_call), CombatTexts.coin_result(coin_call, event.flag)]
			if event.extra == 1:
				coin_line += " A Moeda da Sorte rejogou o lance."
			return coin_line
		CombatEvent.Type.EFFECT_ON:
			return "%s: %s." % [who, CombatTexts.effect_name(event.label)]
		CombatEvent.Type.EFFECT_OFF:
			return "%s: %s acabou." % [who, CombatTexts.effect_name(event.label)]
		CombatEvent.Type.STUN_SKIP:
			return "%s está atordoado e perde o turno." % who
		CombatEvent.Type.PHASE:
			return "%s muda de fase!" % who
		CombatEvent.Type.FLEE_FAILED:
			return "A fuga falhou."
		CombatEvent.Type.DISEASE:
			return "%s pegou %s." % [who, Diseases.display_name(event.label)]
		CombatEvent.Type.ENDED:
			return CombatTexts.outcome(event.value)
	return ""


func _reason_suffix(code: int) -> String:
	return " (%s.)" % str(CombatTexts.REACTION_TEXTS[code]) if CombatTexts.REACTION_TEXTS.has(code) else ""


func _side_name(side: int) -> String:
	return player_name() if side == Combatant.PLAYER else enemy_name()


func _action_name(event: CombatEvent) -> String:
	if event.side == Combatant.ENEMY:
		return CombatTexts.move_name(move_kind(event.label), event.label)
	if CombatTexts.PLAYER_ACTIONS.has(event.label):
		return str(CombatTexts.PLAYER_ACTIONS[event.label])
	for skill: CombatSkill in skills:
		if skill.id == event.label:
			return skill.display_name
	if data.items.has(event.label):
		return str(data.items[event.label]["name"])
	return event.label
