class_name RunBot
extends RefCounted
## Bot de regras que joga uma Descida inteira (ADR-0011). Ferramenta de teste e de
## simulação, não regra do jogo. Usa um gerador próprio, separado dos fluxos do jogo,
## para as decisões que variam.

const POTION_ID: String = "murky_potion"
const MAX_STEPS: int = 5000


static func play(data: GameData, run_seed: int) -> RunState:
	var run: RunState = RunState.new(data, run_seed)
	var bot: Pcg32 = Pcg32.new(run_seed, 7)
	var steps: int = 0
	while not run.is_over() and steps < MAX_STEPS:
		steps += 1
		match run.phase:
			RunState.Phase.CHOOSING:
				run.choose_node(pick_node(run))
			RunState.Phase.FIGHT:
				fight(run, bot)
				run.finish_fight()
			RunState.Phase.SHOP:
				shop(run)
			RunState.Phase.CAMPFIRE:
				campfire(run)
	return run


static func hp_percent(run: RunState) -> int:
	return roundi(100.0 * run.hp / run.player_stats().max_hp)


## Fogueira se ferido, baú, depois a luta de menor nível; elite só com vida alta.
static func pick_node(run: RunState) -> int:
	var best_id: int = -1
	var best_score: int = 0
	var health: int = hp_percent(run)
	for option: MapNode in run.options():
		var score: int = 10 + option.level
		match option.kind:
			MapNode.Kind.BONFIRE:
				score = 0 if health < 60 else 12
			MapNode.Kind.CHEST:
				score = 1
			MapNode.Kind.ELITE:
				score = 13 + option.level if health > 70 else 40
		if best_id == -1 or score < best_score:
			best_id = option.id
			best_score = score
	return best_id


static func fight(run: RunState, bot: Pcg32) -> void:
	var combat: Combat = run.combat
	var potion: CombatItem = run.data.combat_item(POTION_ID)
	var skills: Array[CombatSkill] = run.data.class_skills(run.class_id)
	var actions: int = 0
	while combat.is_player_turn() and actions < 400:
		actions += 1
		var danger: bool = combat.enemy.intent != null and combat.enemy.intent.is_dangerous()
		if combat.player.hp * 100 < combat.player.stats.max_hp * 35 and run.available_in_fight(POTION_ID) > 0:
			combat.act(Combat.Action.ITEM, null, potion)
		elif danger and bot.draw_percent(60):
			combat.act(Combat.Action.DEFEND)
		else:
			var chosen: CombatSkill = skills[bot.draw_index(skills.size())]
			if bot.draw_percent(40) and combat.can_act(Combat.Action.SKILL, chosen):
				combat.act(Combat.Action.SKILL, chosen)
			else:
				combat.act(Combat.Action.ATTACK)


## Garante 3 poções, depois o equipamento que couber deixando uma reserva de 30.
static func shop(run: RunState) -> void:
	for item_id: String in run.shop_offer.duplicate():
		var slot: String = str(run.data.items[item_id]["slot"])
		if item_id == POTION_ID and run.consumable_count(POTION_ID) < 3:
			run.buy(item_id)
		elif slot != "consumable" and run.gold - run.item_price(item_id) >= 30:
			run.buy(item_id)
	run.leave_shop()


static func campfire(run: RunState) -> void:
	if hp_percent(run) < 70:
		run.rest()
	for skill_id: String in run.campfire_skills():
		run.use_campfire_skill(skill_id)
	run.leave_campfire()


## Resumo comparável de uma Descida, para conferir reprodução por semente.
static func summary(run: RunState) -> String:
	return "%s p%.3f g%d hp%d mp%d n%d e%d" % [RunState.Phase.keys()[run.phase], run.power, run.gold,
		run.hp, run.mp, run.nodes_cleared, run.history.size()]
