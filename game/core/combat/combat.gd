class_name Combat
extends RefCounted
## Motor do combate 1 contra 1 (GDD §6, §7 e §8), sem nós e sem tela.
##
## Uso: [method start], depois [method act] a cada turno do jogador, até [member outcome]
## deixar de ser ONGOING. Cada chamada devolve os eventos novos; [member history] guarda
## todos. Sorteios de acerto, crítico, variação e IA usam o fluxo de combate; o cara ou
## coroa usa o fluxo da moeda (GDD §20). Leituras do GDD no ADR-0008.

enum Action { ATTACK, SKILL, DEFEND, ITEM, FLEE }
enum Outcome { ONGOING, VICTORY, DEFEAT, FLED }

const CHARGE_TO_ACT: int = 100
## Chance de o inimigo pular um movimento do ciclo: o padrão se aprende, mas não se
## decora (GDD §6; valor no ADR-0008).
const VARIATION_PERCENT: int = 25
const MAX_STEPS: int = 10000
## GDD §7 (ADR-0020): golpes de moeda do inimigo precisam de ao menos este número de
## golpes de outro tipo entre eles. Vale para todos, chefes inclusive.
const COIN_GAP: int = 2

var player: Combatant
var enemy: Combatant
var outcome: Outcome = Outcome.ONGOING
var history: Array[CombatEvent] = []

## Depuração (TASK-013): -1 sorteia normal, 1 força sucesso, 0 força falha na moeda. O
## sorteio continua acontecendo (os fluxos andam igual); só o resultado muda.
var forced_coin: int = -1
## Moedas da Sorte disponíveis (a Descida passa o que a Bibiana carrega) e se estão armadas
## para o próximo lance errado (ADR-0026).
var lucky_coins: int = 0
var _reroll_armed: bool = false

var _rng: Pcg32
var _coin_rng: Pcg32
var _coin: CoinState
var _awaiting_player: bool = false
## Golpes do inimigo desde o último golpe de moeda; começa liberado.
var _since_coin: int = COIN_GAP
## Defesas seguidas do jogador, para as reações do inimigo (ADR-0030).
var _defend_streak: int = 0
var _started: bool = false


func _init(player_unit: Combatant, enemy_unit: Combatant, streams: RngStreams, coin_state: CoinState) -> void:
	player = player_unit
	enemy = enemy_unit
	_rng = streams.combat()
	_coin_rng = streams.coin()
	_coin = coin_state


## Começa a luta e avança até o primeiro turno do jogador (ou até o fim).
func start() -> Array[CombatEvent]:
	var first: int = history.size()
	if _started:
		return _since(first)
	_started = true
	player.charge = 0
	enemy.charge = 0
	_emit(CombatEvent.Type.STARTED, Combatant.PLAYER)
	_choose_intent()
	_advance()
	return _since(first)


func is_player_turn() -> bool:
	return _awaiting_player and outcome == Outcome.ONGOING


func can_act(action: Action, skill: CombatSkill = null, item: CombatItem = null) -> bool:
	if not is_player_turn():
		return false
	match action:
		Action.SKILL:
			return skill != null and player.mp >= skill.cost
		Action.ITEM:
			return item != null
		Action.FLEE:
			return enemy.can_flee
	return true


## Executa a ação do jogador e avança até o próximo turno dele (ou até o fim). Ação
## inválida não muda nada e devolve lista vazia.
func act(action: Action, skill: CombatSkill = null, item: CombatItem = null) -> Array[CombatEvent]:
	var first: int = history.size()
	if not can_act(action, skill, item):
		return _since(first)
	_awaiting_player = false
	_defend_streak = _defend_streak + 1 if action == Action.DEFEND else 0
	match action:
		Action.ATTACK:
			_emit(CombatEvent.Type.ACTION, Combatant.PLAYER, "attack")
			_strike(player, enemy, 1.0, CombatFormulas.Element.PHYSICAL, 1.0, "attack")
			_restore(player, 0, roundi(player.stats.max_mp * CombatFormulas.ATTACK_MP_RETURN))
		Action.SKILL:
			_use_skill(skill)
		Action.DEFEND:
			_emit(CombatEvent.Type.ACTION, Combatant.PLAYER, "defend")
			_apply_effect(player, CombatEffect.Kind.DEFENDING, 1)
			_restore(player, 0, roundi(player.stats.max_mp * CombatFormulas.DEFEND_MP_RETURN))
		Action.ITEM:
			_emit(CombatEvent.Type.ACTION, Combatant.PLAYER, item.id)
			_restore(player, roundi(player.stats.max_hp * item.heal_hp_percent / 100.0),
				roundi(player.stats.max_mp * item.heal_mp_percent / 100.0))
		Action.FLEE:
			_emit(CombatEvent.Type.ACTION, Combatant.PLAYER, "flee")
			if _flip_coin("flee"):
				_finish(Outcome.FLED)
			else:
				_emit(CombatEvent.Type.FLEE_FAILED, Combatant.PLAYER)
	_check_end()
	_advance()
	return _since(first)


## Depuração (TASK-013): derrota o inimigo na hora, pela via normal de vitória.
func debug_kill_enemy() -> Array[CombatEvent]:
	var first: int = history.size()
	if outcome == Outcome.ONGOING:
		enemy.hp = 0
		_check_end()
	return _since(first)


## Previsão de um golpe do jogador no inimigo (ADR-0029), sem sortear nada: dano mínimo e
## máximo sem crítico, dano máximo com crítico, chance de acerto e chance de crítico (%).
func preview_player_strike(power: float) -> Dictionary:
	var attack: float = player.effective_strength()
	var guard: float = enemy.effective_defense()
	var element: float = enemy.element_multiplier(CombatFormulas.Element.PHYSICAL)
	var low: int = CombatFormulas.final_damage(CombatFormulas.raw_damage(attack, power, guard, CombatFormulas.VARIANCE_LOW, 1.0, element, 1.0))
	var high: int = CombatFormulas.final_damage(CombatFormulas.raw_damage(attack, power, guard, CombatFormulas.VARIANCE_HIGH, 1.0, element, 1.0))
	var crit_high: int = CombatFormulas.final_damage(CombatFormulas.raw_damage(attack, power, guard, CombatFormulas.VARIANCE_HIGH, CombatFormulas.CRIT_MULTIPLIER, element, 1.0))
	return {
		"min": low,
		"max": high,
		"crit_max": crit_high,
		"hit": CombatFormulas.hit_chance(player.effective_precision_bonus(), enemy.stats.evasion),
		"crit": clampi(player.stats.crit, 0, 100),
	}


## Moedas da Sorte que ainda podem ser usadas nesta luta (ADR-0026).
func lucky_coins_left() -> int:
	return lucky_coins


## Arma a Moeda da Sorte: no próximo lance que cair errado, ele é rejogado uma vez.
func arm_reroll(on: bool) -> bool:
	if on and lucky_coins <= 0:
		return false
	_reroll_armed = on
	return true


func is_reroll_armed() -> bool:
	return _reroll_armed


## Próximos [param count] turnos, como [constant Combatant.PLAYER] ou [constant Combatant.ENEMY]: a linha do
## tempo do topo da tela (GDD §6). Usa as velocidades atuais.
func preview_turn_order(count: int) -> Array[int]:
	var order: Array[int] = []
	var player_charge: int = player.charge
	var enemy_charge: int = enemy.charge
	var player_speed: int = player.effective_speed()
	var enemy_speed: int = enemy.effective_speed()
	while order.size() < count:
		if player_charge < CHARGE_TO_ACT and enemy_charge < CHARGE_TO_ACT:
			var ticks: int = mini(_ticks_to_act(player_charge, player_speed), _ticks_to_act(enemy_charge, enemy_speed))
			player_charge += player_speed * ticks
			enemy_charge += enemy_speed * ticks
		if _player_goes_first(player_charge, enemy_charge):
			order.append(Combatant.PLAYER)
			player_charge -= CHARGE_TO_ACT
		else:
			order.append(Combatant.ENEMY)
			enemy_charge -= CHARGE_TO_ACT
	return order


func _advance() -> void:
	var steps: int = 0
	while outcome == Outcome.ONGOING:
		steps += 1
		assert(steps < MAX_STEPS, "combate sem fim")
		if steps >= MAX_STEPS:
			return
		if player.charge < CHARGE_TO_ACT and enemy.charge < CHARGE_TO_ACT:
			var ticks: int = mini(_ticks_to_act(player.charge, player.effective_speed()),
				_ticks_to_act(enemy.charge, enemy.effective_speed()))
			player.charge += player.effective_speed() * ticks
			enemy.charge += enemy.effective_speed() * ticks
		if _player_goes_first(player.charge, enemy.charge):
			player.charge -= CHARGE_TO_ACT
			_tick_effects(player)
			_check_end()
			if outcome != Outcome.ONGOING:
				return
			_awaiting_player = true
			_emit(CombatEvent.Type.TURN, Combatant.PLAYER)
			return
		enemy.charge -= CHARGE_TO_ACT
		_tick_effects(enemy)
		_check_end()
		if outcome != Outcome.ONGOING:
			return
		_enemy_turn()


## Empate: o jogador age primeiro (ADR-0008).
func _player_goes_first(player_charge: int, enemy_charge: int) -> bool:
	if player_charge >= CHARGE_TO_ACT and (enemy_charge < CHARGE_TO_ACT or player_charge >= enemy_charge):
		return true
	return false


@warning_ignore("integer_division")
func _ticks_to_act(charge: int, speed: int) -> int:
	if charge >= CHARGE_TO_ACT:
		return 0
	return (CHARGE_TO_ACT - charge + speed - 1) / speed


func _tick_effects(unit: Combatant) -> void:
	var kept: Array[CombatEffect] = []
	for effect: CombatEffect in unit.effects:
		if effect.kind == CombatEffect.Kind.POISON:
			_poison_damage(unit)
		effect.turns_left -= 1
		if effect.turns_left > 0:
			kept.append(effect)
		else:
			_emit(CombatEvent.Type.EFFECT_OFF, unit.side, effect.label())
	unit.effects = kept


## Veneno: 5% do HP máximo por turno, sem passar pela defesa; a regra de nunca matar de
## uma vez com mais de 60% de vida vale para a Bibiana (GDD §7 e §11).
func _poison_damage(unit: Combatant) -> void:
	var damage: int = maxi(1, roundi(unit.stats.max_hp * CombatEffect.POISON_PERCENT / 100.0))
	if unit.side == Combatant.PLAYER:
		damage = CombatFormulas.cap_lethal(damage, unit.hp, unit.stats.max_hp)
	damage = mini(damage, unit.hp)
	unit.hp -= damage
	_emit(CombatEvent.Type.DAMAGE, unit.side, "poison", damage, false, unit.hp)


func _enemy_turn() -> void:
	_emit(CombatEvent.Type.TURN, Combatant.ENEMY)
	var move: EnemyMove = enemy.intent
	if enemy.stunned:
		enemy.stunned = false
		_emit(CombatEvent.Type.STUN_SKIP, Combatant.ENEMY, move.id)
		_choose_intent()
		return
	_emit(CombatEvent.Type.ACTION, Combatant.ENEMY, move.id, move.intent())
	if move.kind == EnemyMove.Kind.HEAL:
		_restore(enemy, roundi(enemy.stats.max_hp * move.heal_percent / 100.0), 0)
	else:
		var mult: float = 1.0
		var coin_failed: bool = false
		if move.is_coin():
			var success: bool = _flip_coin(move.id)
			coin_failed = not success
			mult = CombatFormulas.coin_damage_multiplier(move.kind, success,
				player.has_effect(CombatEffect.Kind.DEFENDING), player.veteran)
		var dealt: int = _strike(enemy, player, move.power, CombatFormulas.Element.PHYSICAL, mult, move.id)
		if move.kind == EnemyMove.Kind.DEBUFF and dealt > 0 and player.is_alive():
			_try_debuff(move)
		if coin_failed and dealt > 0 and player.is_alive():
			_apply_fail_penalty(move)
	_since_coin = 0 if move.is_coin() else _since_coin + 1
	enemy.last_move = move
	_check_end()
	if outcome == Outcome.ONGOING:
		_choose_intent()


## Consequência temática de errar o lado (ADR-0030): efeito de combate e/ou doença. O Veterano
## que Defende anula a penalidade da coroa, inclusive esta (GDD §7 e §8).
func _apply_fail_penalty(move: EnemyMove) -> void:
	if player.veteran and player.has_effect(CombatEffect.Kind.DEFENDING):
		return
	if move.fail_effect_kind >= 0:
		var kind: CombatEffect.Kind = move.fail_effect_kind as CombatEffect.Kind
		_apply_effect(player, kind, CombatEffect.debuff_turns(kind))
	if not move.fail_disease.is_empty():
		_contract(move.fail_disease)


## A Bibiana pega uma doença: o HP máximo cai já nesta luta e a doença segue com ela (ADR-0030).
func _contract(disease_id: String) -> void:
	if player.diseases.has(disease_id) or not Diseases.is_known(disease_id):
		return
	player.diseases.append(disease_id)
	var factor: float = Diseases.max_hp_factor([disease_id])
	player.stats.max_hp = maxi(roundi(player.stats.max_hp * factor), 1)
	player.hp = mini(player.hp, player.stats.max_hp)
	_emit(CombatEvent.Type.DISEASE, Combatant.PLAYER, disease_id)


## Debuff do golpe (ADR-0020): a chance do golpe sorteia no fluxo de combate, não no da
## moeda; Defender corta a chance pela metade.
func _try_debuff(move: EnemyMove) -> void:
	var chance: int = move.effect_chance
	if player.has_effect(CombatEffect.Kind.DEFENDING):
		chance = roundi(chance * CombatEffect.DEFEND_CHANCE_FACTOR)
	if _rng.draw_percent(chance):
		_apply_effect(player, move.effect, CombatEffect.debuff_turns(move.effect))


## Códigos do motivo da reação, para o aviso na tela (ADR-0030).
const REACTION_CODES: Dictionary = {"player_hp_below": 1, "self_hp_below": 2, "player_defended_twice": 3, "player_buffed": 4}


## Reação do inimigo (GDD §6, ADR-0030): a primeira regra cuja condição vale e cujo golpe existe
## na fase atual, é permitido pelas regras de justiça e não foi o último golpe. Devolve
## {move, code} ou vazio.
func _reaction(moves: Array[EnemyMove]) -> Dictionary:
	for rule: Dictionary in enemy.reactions:
		var move: EnemyMove = null
		for candidate: EnemyMove in moves:
			if candidate.id == str(rule["move"]):
				move = candidate
		if move == null or not _reaction_holds(rule):
			continue
		if not _move_allowed(move) or (enemy.last_move != null and enemy.last_move.id == move.id):
			continue
		return {"move": move, "code": int(REACTION_CODES[str(rule["when"])])}
	return {}


func _reaction_holds(rule: Dictionary) -> bool:
	var value: int = int(rule.get("value", 0))
	match str(rule["when"]):
		"player_hp_below":
			return player.hp_percent() < value
		"self_hp_below":
			return enemy.hp_percent() < value
		"player_defended_twice":
			return _defend_streak >= 2
		"player_buffed":
			return player.has_effect(CombatEffect.Kind.EMPOWERED) or player.has_effect(CombatEffect.Kind.BULWARK)
	return false


func _choose_intent() -> void:
	_update_phase()
	var moves: Array[EnemyMove] = enemy.phases[enemy.phase_index].moves
	var reaction: Dictionary = _reaction(moves)
	if not reaction.is_empty():
		var reacted: EnemyMove = reaction["move"]
		enemy.intent = reacted
		_emit(CombatEvent.Type.INTENT, Combatant.ENEMY, reacted.id, reacted.intent(), false, int(reaction["code"]))
		return
	var index: int = enemy.cycle_index % moves.size()
	if moves.size() > 1 and _rng.draw_percent(VARIATION_PERCENT):
		index = (index + 1) % moves.size()
	enemy.cycle_index = index + 1
	var move: EnemyMove = moves[index]
	if not _move_allowed(move):
		move = _fallback(moves)
	enemy.intent = move
	_emit(CombatEvent.Type.INTENT, Combatant.ENEMY, move.id, move.intent())


## Regras de justiça da IA (GDD §6 e §7): nunca o mesmo ataque forte duas vezes
## seguidas; ao menos [constant COIN_GAP] golpes entre dois golpes de moeda, em todos os
## inimigos; Golpe
## Mortal só em chefes; golpe perigoso só se o jogador tiver um turno para ver o aviso.
func _move_allowed(move: EnemyMove) -> bool:
	var last: EnemyMove = enemy.last_move
	if move.kind == EnemyMove.Kind.MORTAL and not enemy.is_boss:
		return false
	if last != null and move.is_dangerous() and last.id == move.id:
		return false
	if move.is_coin() and _since_coin < COIN_GAP:
		return false
	if move.is_dangerous() and preview_turn_order(1)[0] == Combatant.ENEMY:
		return false
	return true


func _fallback(moves: Array[EnemyMove]) -> EnemyMove:
	for move: EnemyMove in moves:
		if move.kind == EnemyMove.Kind.ATTACK:
			return move
	return EnemyMove.basic_attack()


func _update_phase() -> void:
	var percent: int = enemy.hp_percent()
	var target: int = enemy.phase_index
	for index: int in range(enemy.phase_index + 1, enemy.phases.size()):
		if percent <= enemy.phases[index].below_hp_percent:
			target = index
	if target != enemy.phase_index:
		enemy.phase_index = target
		enemy.cycle_index = 0
		_emit(CombatEvent.Type.PHASE, Combatant.ENEMY, "", target)


func _use_skill(skill: CombatSkill) -> void:
	player.mp -= skill.cost
	_emit(CombatEvent.Type.ACTION, Combatant.PLAYER, skill.id, skill.cost)
	match skill.effect:
		CombatSkill.Effect.SHIELD_BASH:
			var dealt: int = _strike(player, enemy, skill.power, CombatFormulas.Element.PHYSICAL, 1.0, skill.id)
			if dealt > 0 and enemy.is_alive() and _flip_coin(skill.id):
				if enemy.is_boss:
					_apply_effect(enemy, CombatEffect.Kind.SLOWED, CombatEffect.SLOW_TURNS)
				else:
					enemy.stunned = true
					_emit(CombatEvent.Type.EFFECT_ON, Combatant.ENEMY, "stunned", 1)
		CombatSkill.Effect.CHARGE:
			_strike(player, enemy, skill.power, CombatFormulas.Element.PHYSICAL, 1.0, skill.id)
			_apply_effect(player, CombatEffect.Kind.ARMOR_DOWN, 1)
		CombatSkill.Effect.BULWARK:
			_apply_effect(player, CombatEffect.Kind.BULWARK, 2)
		CombatSkill.Effect.POWER_STRIKE:
			_strike(player, enemy, skill.power, CombatFormulas.Element.PHYSICAL, 1.0, skill.id)
		CombatSkill.Effect.WAR_CRY:
			_apply_effect(player, CombatEffect.Kind.EMPOWERED, CombatEffect.EMPOWER_TURNS)
		CombatSkill.Effect.MEND:
			_restore(player, roundi(player.stats.max_hp * CombatEffect.MEND_PERCENT / 100.0), 0)


## Resolve um golpe. Devolve o dano causado, ou -1 se errou. Ordem fixa dos sorteios:
## acerto, crítico, variação.
func _strike(attacker: Combatant, defender: Combatant, power: float, element: CombatFormulas.Element,
		coin_mult: float, label: String) -> int:
	var hit: int = CombatFormulas.hit_chance(attacker.effective_precision_bonus(), defender.stats.evasion)
	if not _rng.draw_percent(hit):
		_emit(CombatEvent.Type.MISS, attacker.side, label)
		return -1
	var critical: bool = _rng.draw_percent(attacker.stats.crit)
	var variance: float = _rng.draw_float_range(CombatFormulas.VARIANCE_LOW, CombatFormulas.VARIANCE_HIGH)
	var physical: bool = element == CombatFormulas.Element.PHYSICAL
	var attack: float = attacker.effective_strength() if physical else attacker.effective_mind()
	var guard: float = defender.effective_defense() if physical else defender.effective_resistance()
	var raw: float = CombatFormulas.raw_damage(attack, power, guard, variance,
		CombatFormulas.CRIT_MULTIPLIER if critical else 1.0, defender.element_multiplier(element), 1.0)
	raw *= coin_mult
	if defender.has_effect(CombatEffect.Kind.CURSED):
		raw *= 1.0 + CombatEffect.CURSE_DAMAGE
	if defender.has_effect(CombatEffect.Kind.DEFENDING):
		raw *= 1.0 - CombatFormulas.defend_reduction(defender.veteran)
	var damage: int = CombatFormulas.final_damage(raw)
	if defender.side == Combatant.PLAYER:
		damage = CombatFormulas.cap_lethal(damage, defender.hp, defender.stats.max_hp)
	damage = mini(damage, defender.hp)
	defender.hp -= damage
	_emit(CombatEvent.Type.DAMAGE, defender.side, label, damage, critical, defender.hp)
	if physical and damage > 0 and defender.has_effect(CombatEffect.Kind.BULWARK) and attacker.is_alive():
		var reflected: int = mini(roundi(damage * CombatEffect.BULWARK_REFLECT), attacker.hp)
		if reflected > 0:
			attacker.hp -= reflected
			_emit(CombatEvent.Type.DAMAGE, attacker.side, "reflect", reflected, false, attacker.hp)
	return damage


func _flip_coin(reason: String) -> bool:
	var success: bool = _coin_rng.draw_percent(CoinRules.chance())
	var rerolled: int = 0
	if not success and _reroll_armed and lucky_coins > 0:
		lucky_coins -= 1
		_reroll_armed = false
		rerolled = 1
		success = _coin_rng.draw_percent(CoinRules.chance())
	if forced_coin >= 0:
		success = forced_coin == 1
	_coin.record(success)
	_emit(CombatEvent.Type.COIN, Combatant.PLAYER, reason, CoinRules.chance(), success, rerolled)
	return success


func _apply_effect(unit: Combatant, kind: CombatEffect.Kind, turns: int) -> void:
	var existing: CombatEffect = unit.effect_of(kind)
	if existing != null:
		existing.turns_left = maxi(existing.turns_left, turns)
	else:
		unit.effects.append(CombatEffect.make(kind, turns))
	_emit(CombatEvent.Type.EFFECT_ON, unit.side, CombatEffect.LABELS[kind], turns)


func _restore(unit: Combatant, hp_amount: int, mp_amount: int) -> void:
	var hp_gain: int = clampi(hp_amount, 0, unit.stats.max_hp - unit.hp)
	var mp_gain: int = clampi(mp_amount, 0, unit.stats.max_mp - unit.mp)
	unit.hp += hp_gain
	unit.mp += mp_gain
	_emit(CombatEvent.Type.HEAL, unit.side, "", hp_gain, false, mp_gain)


## Se os dois caírem no mesmo golpe (reflexo da Muralha), vale a derrota.
func _check_end() -> void:
	if outcome != Outcome.ONGOING:
		return
	if not player.is_alive():
		_finish(Outcome.DEFEAT)
	elif not enemy.is_alive():
		_finish(Outcome.VICTORY)


func _finish(result: Outcome) -> void:
	outcome = result
	_awaiting_player = false
	_emit(CombatEvent.Type.ENDED, Combatant.PLAYER, "", result)


func _emit(type: CombatEvent.Type, side: int, label: String = "", value: int = 0,
		flag: bool = false, extra: int = 0) -> void:
	history.append(CombatEvent.make(type, side, label, value, flag, extra))


func _since(first: int) -> Array[CombatEvent]:
	var events: Array[CombatEvent] = []
	for index: int in range(first, history.size()):
		events.append(history[index])
	return events
