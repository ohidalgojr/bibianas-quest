class_name CoinState
extends RefCounted
## Memória da moeda ao longo da Descida: a Maré de azar (GDD §7, ADR-0026) conta lances
## perdidos seguidos, inclusive entre combates. Quem guarda o objeto entre combates é
## o estado da Descida (TASK-007).

var losses_in_row: int = 0
var flips: int = 0
var heads: int = 0


## Maré de azar (GDD §7, ADR-0026): 3 ou mais lances perdidos seguidos. Ela melhora o
## próximo drop de equipamento; zera ao ganhar um lance ou ao ser usada.
func bad_luck() -> bool:
	return losses_in_row >= CoinRules.STREAK_LOSSES


func record(success: bool) -> void:
	flips += 1
	if success:
		heads += 1
		losses_in_row = 0
	else:
		losses_in_row += 1
