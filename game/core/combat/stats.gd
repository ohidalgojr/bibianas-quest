class_name Stats
extends RefCounted
## Atributos de uma unidade de combate (GDD §6 "Atributos básicos", §8 e §9).
##
## [member precision] guarda o PRE como aparece nas tabelas do GDD, em que 90 é a
## base de todas as classes; a fórmula de acerto usa o bônus acima de 90 (ADR-0008).

const BASE_PRECISION: int = 90
## Crescimento por ponto de Poder acima de 1 (GDD §9).
const GROWTH_HP: float = 0.10
const GROWTH_ATTACK: float = 0.08
const GROWTH_GUARD: float = 0.06
const GROWTH_SPEED: float = 0.02

var max_hp: int = 1
var max_mp: int = 0
## FOR
var strength: int = 0
## MEN
var mind: int = 0
## DEF
var defense: int = 0
## RES
var resistance: int = 0
## VEL (Ritmo)
var speed: int = 1
## PRE, valor da tabela (90 é a base)
var precision: int = BASE_PRECISION
## ESQ
var evasion: int = 0
## CRIT, em pontos percentuais
var crit: int = 5
## SORTE
var luck: int = 0


## Cria a partir de um dicionário com as chaves hp, mp, strength, mind, defense,
## resistance, speed, precision, evasion, crit e luck. Chave ausente usa o padrão.
static func make(values: Dictionary) -> Stats:
	var stats: Stats = Stats.new()
	stats.max_hp = maxi(1, int(values.get("hp", 1)))
	stats.max_mp = maxi(0, int(values.get("mp", 0)))
	stats.strength = int(values.get("strength", 0))
	stats.mind = int(values.get("mind", 0))
	stats.defense = int(values.get("defense", 0))
	stats.resistance = int(values.get("resistance", 0))
	stats.speed = maxi(1, int(values.get("speed", 1)))
	stats.precision = int(values.get("precision", BASE_PRECISION))
	stats.evasion = int(values.get("evasion", 0))
	stats.crit = int(values.get("crit", 5))
	stats.luck = int(values.get("luck", 0))
	return stats


func copy() -> Stats:
	var other: Stats = Stats.new()
	other.max_hp = max_hp
	other.max_mp = max_mp
	other.strength = strength
	other.mind = mind
	other.defense = defense
	other.resistance = resistance
	other.speed = speed
	other.precision = precision
	other.evasion = evasion
	other.crit = crit
	other.luck = luck
	return other


## Atributos depois do crescimento por Poder (GDD §9): HP +10% por ponto acima de 1;
## FOR e MEN +8%; DEF e RES +6%; VEL +2%. MP, PRE, ESQ, CRIT e SORTE não crescem com o
## Poder. Arredonda para o inteiro mais próximo; Poder abaixo de 1 conta como 1.
func scaled_for_power(power: float) -> Stats:
	var extra: float = maxf(power - 1.0, 0.0)
	var other: Stats = copy()
	other.max_hp = roundi(max_hp * (1.0 + GROWTH_HP * extra))
	other.strength = roundi(strength * (1.0 + GROWTH_ATTACK * extra))
	other.mind = roundi(mind * (1.0 + GROWTH_ATTACK * extra))
	other.defense = roundi(defense * (1.0 + GROWTH_GUARD * extra))
	other.resistance = roundi(resistance * (1.0 + GROWTH_GUARD * extra))
	other.speed = maxi(1, roundi(speed * (1.0 + GROWTH_SPEED * extra)))
	return other


func precision_bonus() -> int:
	return precision - BASE_PRECISION
