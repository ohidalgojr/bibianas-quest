class_name CombatSession
extends RefCounted
## Controlador da tela de combate (ADR-0010). Monta a luta a partir dos dados, repassa
## as ações ao núcleo e traduz os eventos em textos e ícones. Não tem nós: a cena só
## desenha o que ele entrega, e os testes rodam sem tela.

## Poções Turvas por luta no protótipo (ADR-0010); o inventário real é da TASK-007.
const POTIONS_PER_FIGHT: int = 2
const POTION_ID: String = "murky_potion"
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

## Id do golpe -> tipo, para nomear golpes a partir dos eventos.
var _move_kinds: Dictionary = {}


func _init(game_data: GameData, fight_enemy: String, fight_level: int, fight_power: float, fight_seed: int,
		coin_state: CoinState = null) -> void:
	data = game_data
	enemy_id = fight_enemy
	level = fight_level
	power = fight_power
	run_seed = fight_seed
	skills = data.class_skills(CLASS_ID)
	potion = data.combat_item(POTION_ID)
	var enemy: Combatant = data.make_enemy(enemy_id, level)
	for phase: EnemyPhase in enemy.phases:
		for move: EnemyMove in phase.moves:
			_move_kinds[move.id] = move.kind
	combat = Combat.new(data.make_player(CLASS_ID, power), enemy, RngStreams.new(run_seed),
		coin_state if coin_state != null else CoinState.new())


func start() -> Array[CombatEvent]:
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
	potions_left -= 1
	return combat.act(Combat.Action.ITEM, null, potion)


func flee() -> Array[CombatEvent]:
	return combat.act(Combat.Action.FLEE)


func can_act() -> bool:
	return combat.is_player_turn()


func can_use_skill(index: int) -> bool:
	return index >= 0 and index < skills.size() and combat.can_act(Combat.Action.SKILL, skills[index])


func can_use_potion() -> bool:
	return potions_left > 0 and combat.can_act(Combat.Action.ITEM, null, potion)


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


func coin_chance() -> int:
	return combat.coin_chance()


func move_kind(move_id: String) -> EnemyMove.Kind:
	return _move_kinds.get(move_id, EnemyMove.Kind.ATTACK)


## Ícone de intenção do golpe (GDD §6): texto do ícone, se é perigoso, se é de moeda e
## o detalhe. No golpe de moeda, o detalhe traz a chance real de Cara (GDD §7).
func intent_view(move_id: String) -> Dictionary:
	var kind: EnemyMove.Kind = move_kind(move_id)
	var move: EnemyMove = EnemyMove.make(move_id, kind)
	var view: Dictionary = {
		"icon": CombatTexts.intent_icon(move.intent()),
		"name": CombatTexts.move_name(kind),
		"dangerous": move.is_dangerous(),
		"coin": move.is_coin(),
		"detail": "",
	}
	if move.is_coin():
		view["detail"] = "Chance de Cara: %d%%. %s" % [coin_chance(), CombatTexts.coin_stakes(kind)]
	elif kind == EnemyMove.Kind.STRONG:
		view["detail"] = "Defender reduz o dano."
	return view


func skill_label(index: int) -> String:
	var skill: CombatSkill = skills[index]
	return "%s (%d MP)" % [skill.display_name, skill.cost]


func potion_label() -> String:
	return "%s (%d)" % [str(data.items[POTION_ID]["name"]), potions_left]


func outcome_text() -> String:
	return CombatTexts.outcome(combat.outcome)


## Linha do registro da luta. Devolve "" para eventos que a tela não escreve.
func describe(event: CombatEvent) -> String:
	var who: String = _side_name(event.side)
	match event.type:
		CombatEvent.Type.STARTED:
			return "A luta começa: %s, nível %d. Semente %d." % [enemy_name(), level, run_seed]
		CombatEvent.Type.INTENT:
			return "%s prepara: %s." % [enemy_name(), CombatTexts.move_name(move_kind(event.label))]
		CombatEvent.Type.ACTION:
			return "%s usa %s." % [who, _action_name(event)]
		CombatEvent.Type.MISS:
			return "%s erra." % who
		CombatEvent.Type.DAMAGE:
			var line: String = "%s sofre %d de dano" % [who, event.value]
			if event.label == "reflect":
				line += " (reflexo da Muralha)"
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
			var coin_line: String = "Moeda (chance de Cara %d%%): %s." % [event.value, CombatTexts.coin_result(event.flag)]
			if event.extra > 0:
				coin_line += " Maré de azar: +%d." % event.extra
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
		CombatEvent.Type.ENDED:
			return CombatTexts.outcome(event.value)
	return ""


func _side_name(side: int) -> String:
	return player_name() if side == Combatant.PLAYER else enemy_name()


func _action_name(event: CombatEvent) -> String:
	if event.side == Combatant.ENEMY:
		return CombatTexts.move_name(move_kind(event.label))
	if CombatTexts.PLAYER_ACTIONS.has(event.label):
		return str(CombatTexts.PLAYER_ACTIONS[event.label])
	for skill: CombatSkill in skills:
		if skill.id == event.label:
			return skill.display_name
	if data.items.has(event.label):
		return str(data.items[event.label]["name"])
	return event.label
