class_name RunBot
extends RefCounted
## Bots de referência do simulador (GDD §23): "mediano" e "cuidadoso". Ferramenta de
## simulação, não regra do jogo (ADR-0011 e ADR-0012). Decisões que variam usam um
## gerador próprio, separado dos fluxos do jogo, para não mudar a Descida.
##
## - Mediano: defende golpes perigosos 60% das vezes, usa skills ao acaso, bebe poção
##   abaixo de 35% de vida, aceita elite com mais de 70% de vida.
## - Cuidadoso: lê a intenção (sempre defende golpe de moeda e forte), guarda poções
##   para o chefe, descansa cedo e foge de elite com menos de 85% de vida.

enum Profile { MEDIAN, CAREFUL }

const PROFILE_NAMES: Array[String] = ["mediano", "cuidadoso"]
const POTION_ID: String = "murky_potion"
const MAX_STEPS: int = 5000
const MAX_ACTIONS: int = 400


static func play(data: GameData, run_seed: int, profile: Profile = Profile.MEDIAN, run: RunState = null) -> RunState:
	if run == null:
		run = RunState.new(data, run_seed)
	var bot: Pcg32 = Pcg32.new(run_seed, 7)
	var steps: int = 0
	while not run.is_over() and steps < MAX_STEPS:
		steps += 1
		match run.phase:
			RunState.Phase.CHOOSING:
				run.choose_node(pick_node(run, profile))
			RunState.Phase.FIGHT:
				fight(run, bot, profile)
				run.finish_fight()
			RunState.Phase.SHOP:
				shop(run, profile)
			RunState.Phase.CAMPFIRE:
				campfire(run, profile)
	return run


## Joga seguindo uma rota fixa (checagem de vencibilidade, GDD §5). Fora a escolha do
## nó, decide como em [method play].
static func play_route(run: RunState, route: PackedInt32Array, run_seed: int, profile: Profile = Profile.MEDIAN) -> RunState:
	var bot: Pcg32 = Pcg32.new(run_seed, 7)
	var steps: int = 0
	while not run.is_over() and steps < MAX_STEPS:
		steps += 1
		match run.phase:
			RunState.Phase.CHOOSING:
				var next_id: int = -1
				for option: MapNode in run.options():
					if route.has(option.id):
						next_id = option.id
				if next_id == -1 or not run.choose_node(next_id):
					return run
			RunState.Phase.FIGHT:
				fight(run, bot, profile)
				run.finish_fight()
			RunState.Phase.SHOP:
				shop(run, profile)
			RunState.Phase.CAMPFIRE:
				campfire(run, profile)
	return run


static func hp_percent(run: RunState) -> int:
	return roundi(100.0 * run.hp / run.player_stats().max_hp)


## Fogueira se ferido, baú, depois a luta de menor nível; elite só com vida alta.
static func pick_node(run: RunState, profile: Profile) -> int:
	var careful: bool = profile == Profile.CAREFUL
	var rest_below: int = 75 if careful else 60
	var elite_above: int = 85 if careful else 70
	var best_id: int = -1
	var best_score: int = 0
	var health: int = hp_percent(run)
	for option: MapNode in run.options():
		var score: int = 10 + option.level
		match option.kind:
			MapNode.Kind.BONFIRE:
				score = 0 if health < rest_below else 12
			MapNode.Kind.CHEST:
				score = 1
			MapNode.Kind.ELITE:
				score = 13 + option.level if health > elite_above else 40
		if best_id == -1 or score < best_score:
			best_id = option.id
			best_score = score
	return best_id


## Joga a luta em andamento até o fim.
static func fight(run: RunState, bot: Pcg32, profile: Profile) -> void:
	var combat: Combat = run.combat
	var actions: int = 0
	while combat.is_player_turn() and actions < MAX_ACTIONS:
		actions += 1
		if profile == Profile.CAREFUL:
			_careful_turn(run, combat)
		else:
			_median_turn(run, combat, bot)


static func _median_turn(run: RunState, combat: Combat, bot: Pcg32) -> void:
	var skills: Array[CombatSkill] = run.skills()
	var danger: bool = combat.enemy.intent != null and combat.enemy.intent.is_dangerous()
	if combat.player.hp * 100 < combat.player.stats.max_hp * 35 and run.available_in_fight(POTION_ID) > 0:
		combat.act(Combat.Action.ITEM, null, run.data.combat_item(POTION_ID))
	elif danger and bot.draw_percent(60):
		combat.act(Combat.Action.DEFEND)
	else:
		var chosen: CombatSkill = skills[bot.draw_index(skills.size())]
		if bot.draw_percent(40) and combat.can_act(Combat.Action.SKILL, chosen):
			combat.act(Combat.Action.SKILL, chosen)
		else:
			combat.act(Combat.Action.ATTACK)


## Defende todo golpe de moeda (o Veterano anula a penalidade) e o golpe forte quando
## a vida está baixa; poção abaixo de 40% (fora do chefe, só se sobrar uma para ele);
## Golpe de Escudo no chefe para a Lentidão; senão ataca.
static func _careful_turn(run: RunState, combat: Combat) -> void:
	var intent: EnemyMove = combat.enemy.intent
	var potions: int = run.available_in_fight(POTION_ID)
	var reserve: int = 0 if combat.enemy.is_boss else 1
	var percent: int = roundi(100.0 * combat.player.hp / combat.player.stats.max_hp)
	if percent < 40 and potions > reserve:
		combat.act(Combat.Action.ITEM, null, run.data.combat_item(POTION_ID))
		return
	if intent != null and (intent.is_coin() or (intent.kind == EnemyMove.Kind.STRONG and percent < 60)):
		combat.act(Combat.Action.DEFEND)
		return
	var bash: CombatSkill = run.data.combat_skill("shield_bash")
	if combat.enemy.is_boss and not combat.enemy.has_effect(CombatEffect.Kind.SLOWED) \
			and combat.can_act(Combat.Action.SKILL, bash):
		combat.act(Combat.Action.SKILL, bash)
	else:
		combat.act(Combat.Action.ATTACK)


## Poções primeiro (2 no mediano, 4 no cuidadoso), depois equipamento que couber
## deixando uma reserva de 30.
static func shop(run: RunState, profile: Profile) -> void:
	_handle_drop(run)
	var want_potions: int = 4 if profile == Profile.CAREFUL else 2
	for item_id: String in run.shop_offer.duplicate():
		var slot: String = str(run.data.items[item_id]["slot"])
		if item_id == POTION_ID and run.consumable_count(POTION_ID) < want_potions:
			run.buy(item_id)
		elif slot != "consumable" and run.gold - run.item_price(item_id) >= 30:
			run.buy(item_id)
	if not run.skill_offer.is_empty() and run.gold - run.data.skill_price(run.skill_offer) >= 30:
		run.buy_skill()
	run.leave_shop()


const RARITY_RANK: Dictionary = {"worn": 0, "common": 1, "uncommon": 2, "rare": 3}


## Equipa o drop se for de raridade maior que o item do espaço; senão vende (ADR-0022).
static func _handle_drop(run: RunState) -> void:
	if run.pending_drop.is_empty():
		return
	var slot: String = str(run.data.items[run.pending_drop]["slot"])
	var old_id: String = str(run.equipment.get(slot, ""))
	var new_rank: int = int(RARITY_RANK.get(str(run.data.items[run.pending_drop]["rarity"]), 0))
	var old_rank: int = -1 if old_id.is_empty() else int(RARITY_RANK.get(str(run.data.items[old_id]["rarity"]), 0))
	if new_rank > old_rank:
		run.take_drop()
	else:
		run.sell_drop()


static func campfire(run: RunState, profile: Profile) -> void:
	var rest_below: int = 85 if profile == Profile.CAREFUL else 70
	if hp_percent(run) < rest_below:
		run.rest()
	for skill_id: String in run.campfire_skills():
		run.use_campfire_skill(skill_id)
	run.leave_campfire()


## Resumo comparável de uma Descida, para conferir reprodução por semente.
static func summary(run: RunState) -> String:
	return "%s p%.3f g%d hp%d mp%d n%d e%d" % [RunState.Phase.keys()[run.phase], run.power, run.gold,
		run.hp, run.mp, run.nodes_cleared, run.history.size()]
