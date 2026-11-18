class_name CombatFormulas
extends RefCounted
## Fórmulas de combate do GDD §6 e multiplicadores da moeda do §7. Leituras e
## arredondamentos no ADR-0008. Mudar qualquer número daqui exige ADR e subir
## [constant CoreVersion.RULES_VERSION].

enum Element { PHYSICAL, FIRE, LIGHTNING, HOLY, SHADOW }

const HIT_BASE: int = 90
const HIT_MIN: int = 10
const HIT_MAX: int = 98
const CRIT_MULTIPLIER: float = 1.5
const VARIANCE_LOW: float = 0.9
const VARIANCE_HIGH: float = 1.1
const WEAKNESS: float = 1.5
const RESISTANT: float = 0.5
## Defender: reduz o dano em 50% até o próximo turno (GDD §6).
const DEFEND_REDUCTION: float = 0.5
## Veterano (Guerreiro): Defender protege 30% a mais, 50% x 1,3 (ADR-0008).
const VETERAN_DEFEND_REDUCTION: float = 0.65
## Defender devolve 10% do MP máximo (GDD §6).
const DEFEND_MP_RETURN: float = 0.10
## Atacar devolve 10% do MP máximo, arredondado (ADR-0029).
const ATTACK_MP_RETURN: float = 0.10
## Nunca há morte imediata com a vida acima de 60% (GDD §7).
const LETHAL_GUARD_PERCENT: int = 60
## Multiplicador de dano em caso de falha (Coroa) por golpe de moeda (GDD §7).
const HEAVY_FAIL: float = 1.5
const CRUEL_SUCCESS: float = 0.5
const CRUEL_FAIL: float = 2.0
const MORTAL_FAIL: float = 2.5


## Dano = ATK x mult_skill x 100 / (100 + DEF) x U(0,9; 1,1) x crit x elemento x clima.
static func raw_damage(attack: float, skill_mult: float, target_defense: float, variance: float,
		crit_mult: float, element_mult: float, weather_mult: float) -> float:
	return attack * skill_mult * 100.0 / (100.0 + maxf(target_defense, 0.0)) * variance \
		* crit_mult * element_mult * weather_mult


## Arredonda para o inteiro mais próximo, com mínimo de 1 (um acerto sempre fere).
static func final_damage(raw: float) -> int:
	return maxi(1, roundi(raw))


## Acerto (%) = clamp(90 + PRE - ESQ, 10, 98), com PRE como bônus sobre a base 90.
static func hit_chance(precision_bonus: int, evasion: int) -> int:
	return clampi(HIT_BASE + precision_bonus - evasion, HIT_MIN, HIT_MAX)


static func defend_reduction(veteran: bool) -> float:
	return VETERAN_DEFEND_REDUCTION if veteran else DEFEND_REDUCTION


## Multiplicador de dano de um golpe de moeda do inimigo. Defender corta pela metade a
## penalidade de falha; Defender com Veterano a anula. O bônus de Cara do Golpe Cruel
## (dano -50%) não muda com Defender.
static func coin_damage_multiplier(kind: EnemyMove.Kind, success: bool, defending: bool, veteran: bool) -> float:
	var fail_mult: float = 1.0
	match kind:
		EnemyMove.Kind.HEAVY:
			fail_mult = HEAVY_FAIL
		EnemyMove.Kind.CRUEL:
			if success:
				return CRUEL_SUCCESS
			fail_mult = CRUEL_FAIL
		EnemyMove.Kind.MORTAL:
			fail_mult = MORTAL_FAIL
		_:
			return 1.0
	if success:
		return 1.0
	var penalty: float = fail_mult - 1.0
	if defending:
		penalty = 0.0 if veteran else penalty * 0.5
	return 1.0 + penalty


## Limita o dano para não matar quem está com a vida acima de 60% do máximo.
static func cap_lethal(damage: int, hp: int, max_hp: int) -> int:
	if damage >= hp and hp * 100 > max_hp * LETHAL_GUARD_PERCENT:
		return maxi(hp - 1, 0)
	return damage
