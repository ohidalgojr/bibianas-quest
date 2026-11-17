class_name RunRules
extends RefCounted
## Fórmulas e números da Descida (GDD §9, §12 e §15). Leituras no ADR-0011. Mudar
## qualquer número daqui exige ADR e subir [constant CoreVersion.RULES_VERSION].

## GDD §9: delta de Poder = 0,4 × N × m_tipo (era 0,15; ADR-0023).
const POWER_PER_LEVEL: float = 0.4
const STARTING_POWER: float = 1.0
## GDD §15: moedas por inimigo = round(6 × N × U(0,8; 1,2) × m_tipo).
const GOLD_PER_LEVEL: float = 6.0
const GOLD_VARIANCE_LOW: float = 0.8
const GOLD_VARIANCE_HIGH: float = 1.2
## GDD §9 e §15: m_tipo por tipo de inimigo.
const TYPE_MULTIPLIERS: Dictionary = {
	"common": 1.0,
	"elite": 1.5,
	"mini_boss": 2.5,
	"roaming_boss": 3.0,
	"boss": 4.0,
}
## GDD §15: baús dão de 1 a 3 vezes o ouro de uma batalha comum.
const CHEST_MIN_TIMES: int = 1
const CHEST_MAX_TIMES: int = 3

## GDD §12: 6 Brasas por fogueira; Descansar custa 3 e recupera 40% de HP e MP.
const EMBERS: int = 6
const REST_COST: int = 3
const REST_PERCENT: int = 40
## GDD §12 diz "1 a 2 Brasas"; o protótipo usa 2 (ADR-0011).
const CAMPFIRE_SKILL_COST: int = 2

## GDD §15: 2 equipamentos e 2 consumíveis (o especial fica fora, ADR-0011).
const SHOP_EQUIPMENT: int = 2
const SHOP_CONSUMABLES: int = 2
## GDD §15: atualizar custa 15 na primeira vez e mais 10 a cada nova vez no mesmo nó.
const REROLL_FIRST: int = 15
const REROLL_STEP: int = 10
## GDD §10: até 8 consumíveis.
const MAX_CONSUMABLES: int = 8
## ADR-0011: a Descida começa com 2 Poções Turvas.
const STARTING_ITEMS: Dictionary = {"murky_potion": 2}

## GDD §4 e §26: Ecos creditados pela profundidade e pelos chefes (ADR-0016). O GDD não
## dá os números; estes são do protótipo.
const ECHOES_PER_NODE: int = 1
const ECHOES_PER_BOSS: int = 5

## GDD §10: chance de equipamento por inimigo, valores iniciais (ADR-0022).
const DROP_EQUIPMENT_PERCENT: Dictionary = {"common": 12, "elite": 35}
## Consumível que cura HP: não está no GDD, proposta do ADR-0022.
const DROP_CONSUMABLE_PERCENT: Dictionary = {"common": 30, "elite": 50}
## GDD §10: o raro vem de elites; pesos por raridade (ADR-0022).
const DROP_RARITY_WEIGHTS: Dictionary = {
	"common": {"worn": 30, "common": 55, "uncommon": 15},
	"elite": {"common": 30, "uncommon": 45, "rare": 25},
}
## GDD §15: venda de itens paga 40% do valor.
const SELL_PERCENT: int = 40

## ADR-0011: elite um nível acima da camada; eventos fora do protótipo.
const ELITE_LEVEL_BONUS: int = 1
const PROTOTYPE_EVENT_WEIGHT: int = 0


## Ecos de uma Descida terminada: sempre creditados, mesmo na morte (GDD §26).
static func echoes(nodes_cleared: int, bosses_defeated: int) -> int:
	return ECHOES_PER_NODE * nodes_cleared + ECHOES_PER_BOSS * bosses_defeated


## Equipamento cai? Só inimigos comuns e elites (chefes dão Alma, fora do protótipo).
static func equipment_drops(enemy_type: String, loot: Pcg32) -> bool:
	return DROP_EQUIPMENT_PERCENT.has(enemy_type) and loot.draw_percent(int(DROP_EQUIPMENT_PERCENT[enemy_type]))


static func consumable_drops(enemy_type: String, loot: Pcg32) -> bool:
	return DROP_CONSUMABLE_PERCENT.has(enemy_type) and loot.draw_percent(int(DROP_CONSUMABLE_PERCENT[enemy_type]))


## Raridade sorteada pelos pesos do tipo de inimigo.
static func drop_rarity(enemy_type: String, loot: Pcg32) -> String:
	var weights: Dictionary = DROP_RARITY_WEIGHTS[enemy_type]
	var total: int = 0
	for rarity: String in weights:
		total += int(weights[rarity])
	var roll: int = loot.draw_int(1, total)
	for rarity: String in weights:
		roll -= int(weights[rarity])
		if roll <= 0:
			return rarity
	return "common"


static func sell_value(price: int) -> int:
	return roundi(price * SELL_PERCENT / 100.0)


static func type_multiplier(enemy_type: String) -> float:
	return float(TYPE_MULTIPLIERS.get(enemy_type, 1.0))


## Nível da Bibiana: parte inteira do Poder (ADR-0023). Só rótulo; os atributos seguem o Poder.
static func level_of(power: float) -> int:
	return floori(power)


static func power_gain(level: int, enemy_type: String) -> float:
	return POWER_PER_LEVEL * level * type_multiplier(enemy_type)


## Sorteia o U(0,8; 1,2) no fluxo de loot.
static func gold_drop(level: int, enemy_type: String, loot: Pcg32) -> int:
	var variance: float = loot.draw_float_range(GOLD_VARIANCE_LOW, GOLD_VARIANCE_HIGH)
	return gold_for(level, enemy_type, variance)


static func gold_for(level: int, enemy_type: String, variance: float) -> int:
	return roundi(GOLD_PER_LEVEL * level * variance * type_multiplier(enemy_type))


## Ouro de baú: o de uma batalha comum do nível, vezes 1 a 3 (ADR-0011).
static func chest_gold(level: int, loot: Pcg32) -> int:
	var base: int = gold_drop(level, "common", loot)
	return base * loot.draw_int(CHEST_MIN_TIMES, CHEST_MAX_TIMES)


## Nível dos inimigos de uma camada (1 a N), interpolado entre o mínimo e o máximo do
## cenário (ADR-0011). O chefe fica no máximo.
static func layer_level(layer: int, layers: int, min_level: int, max_level: int) -> int:
	if layer > layers:
		return max_level
	return min_level + roundi(float(max_level - min_level) * float(layer - 1) / float(layers))


static func reroll_cost(rerolls_done: int) -> int:
	return REROLL_FIRST + REROLL_STEP * rerolls_done


## Tipo de inimigo de um nó de luta, para m_tipo e para o grupo de inimigos.
static func enemy_type_for(kind: MapNode.Kind) -> String:
	match kind:
		MapNode.Kind.ELITE:
			return "elite"
		MapNode.Kind.MINI_BOSS:
			return "mini_boss"
		MapNode.Kind.BOSS:
			return "boss"
	return "common"
