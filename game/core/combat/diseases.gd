class_name Diseases
extends RefCounted
## Doenças da Descida (GDD §11, ADR-0030): persistem entre combates e se tratam na fogueira.
## Cada uma muda um atributo em percentual; hoje só a Leptospirose existe.

const LEPTOSPIROSIS: String = "leptospirosis"
## GDD §11: Leptospirose, -15% do HP máximo até tratar (Rato Grande).
const DEFS: Dictionary = {
	LEPTOSPIROSIS: {"name": "Leptospirose", "max_hp_percent": -15},
}


static func is_known(disease_id: String) -> bool:
	return DEFS.has(disease_id)


static func display_name(disease_id: String) -> String:
	return str(DEFS[disease_id]["name"]) if DEFS.has(disease_id) else disease_id


## Fator do HP máximo com as doenças dadas (1,0 sem doença).
static func max_hp_factor(disease_ids: Array) -> float:
	var factor: float = 1.0
	for disease_id: Variant in disease_ids:
		if DEFS.has(str(disease_id)):
			factor *= 1.0 + int(DEFS[str(disease_id)]["max_hp_percent"]) / 100.0
	return factor
