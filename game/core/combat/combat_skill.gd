class_name CombatSkill
extends RefCounted
## Skill de combate. Os números vêm do GDD §8; quando os dados das classes existirem
## (TASK-005), eles saem deste arquivo.

enum Effect { SHIELD_BASH, CHARGE, BULWARK, POWER_STRIKE, WAR_CRY, MEND }

var id: String = ""
var display_name: String = ""
var cost: int = 0
var effect: Effect = Effect.SHIELD_BASH
var power: float = 1.0


static func make(skill_id: String, skill_name: String, mp_cost: int, skill_effect: Effect, skill_power: float) -> CombatSkill:
	var skill: CombatSkill = CombatSkill.new()
	skill.id = skill_id
	skill.display_name = skill_name
	skill.cost = mp_cost
	skill.effect = skill_effect
	skill.power = skill_power
	return skill


## Golpe de Escudo (6 MP, 0,8 x FOR, moeda: Cara atordoa); Investida (8 MP, 1,5 x FOR,
## DEF -20% por 1 turno); Muralha (6 MP, 2 turnos de DEF +50% e reflexo de 20%).
static func warrior_set() -> Array[CombatSkill]:
	var skills: Array[CombatSkill] = [
		make("shield_bash", "Golpe de Escudo", 6, Effect.SHIELD_BASH, 0.8),
		make("charge", "Investida", 8, Effect.CHARGE, 1.5),
		make("bulwark", "Muralha", 6, Effect.BULWARK, 0.0),
	]
	return skills
