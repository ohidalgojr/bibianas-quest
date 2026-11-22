class_name MapConfig
extends RefCounted
## Parâmetros de geração do mapa de um cenário (GDD §5 e §12). Os valores padrão são
## os "pontos de partida" do GDD; mudar um deles no código exige ADR.

const MIN_LAYERS: int = 3
const MAX_LAYERS: int = 12
const MIN_WIDTH: int = 3
const MAX_WIDTH: int = 5

var layer_count: int = 5
var width: int = 4
## Frequências iniciais dos tipos sorteados (GDD §5, "Tipos de nó"), em pontos.
var weight_battle: int = 49
var weight_elite: int = 10
var weight_chest: int = 14
var weight_event: int = 9
var weight_ambush: int = 18
## Elite não aparece nos primeiros 30% das camadas (arredondado para cima, ADR-0007).
var elite_free_percent: int = 30
## "Nunca três elites em uma mesma camada" (GDD §5).
var max_elites_per_layer: int = 2


## Configuração para um número de camadas, com a largura do GDD: 4 até 6 camadas,
## 5 de 7 em diante.
static func for_layers(layers: int) -> MapConfig:
	var config: MapConfig = MapConfig.new()
	config.layer_count = layers
	config.width = 4 if layers <= 6 else 5
	return config


## GDD §5, ADR-0049: o cenário 1 é curto (4 camadas, tutorial-gancho) e os seguintes crescem
## gradualmente até 10 no cenário 5.
const SCENARIO_LAYERS: Array[int] = [4, 6, 7, 8, 10]


static func for_scenario(scenario: int) -> MapConfig:
	return for_layers(SCENARIO_LAYERS[clampi(scenario, 1, 5) - 1])


## Quantas camadas iniciais não podem ter elite.
func elite_free_layers() -> int:
	@warning_ignore("integer_division")
	return (elite_free_percent * layer_count + 99) / 100


## Fogueiras por mapa (GDD §12, ADR-0028): 1 até 5 camadas; de 6 em diante, uma a cada 3
## camadas, com ao menos 2 (6 e 7 camadas: 2; 8 a 10: 3; 11 e 12: 4).
func bonfire_count() -> int:
	if layer_count < 6:
		return 1
	return maxi(2, roundi(layer_count / 3.0))


## Lista de problemas da configuração; vazia quando ela pode ser usada.
func problems() -> PackedStringArray:
	var found: PackedStringArray = PackedStringArray()
	if layer_count < MIN_LAYERS or layer_count > MAX_LAYERS:
		found.append("layer_count fora de %d a %d" % [MIN_LAYERS, MAX_LAYERS])
	if width < MIN_WIDTH or width > MAX_WIDTH:
		found.append("width fora de %d a %d" % [MIN_WIDTH, MAX_WIDTH])
	if mini(mini(weight_battle, weight_elite), mini(weight_chest, mini(weight_event, weight_ambush))) < 0:
		found.append("peso negativo")
	if weight_battle + weight_event + weight_ambush <= 0:
		found.append("batalha, evento e emboscada somam zero: faltaria tipo para sortear")
	if max_elites_per_layer < 0 or max_elites_per_layer > 2:
		found.append("max_elites_per_layer fora de 0 a 2")
	if elite_free_percent < 0 or elite_free_percent > 100:
		found.append("elite_free_percent fora de 0 a 100")
	return found
