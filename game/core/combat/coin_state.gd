class_name CoinState
extends RefCounted
## Memória da moeda ao longo da Descida: a Maré de azar (GDD §7) conta lances
## perdidos seguidos, inclusive entre combates. Quem guarda o objeto entre combates é
## o estado da Descida (TASK-007).

var losses_in_row: int = 0
var flips: int = 0
var heads: int = 0


## +10 pontos enquanto houver 3 ou mais lances perdidos seguidos; zera ao ganhar.
func streak_bonus() -> int:
	return CoinRules.STREAK_BONUS if losses_in_row >= CoinRules.STREAK_LOSSES else 0


func record(success: bool) -> void:
	flips += 1
	if success:
		heads += 1
		losses_in_row = 0
	else:
		losses_in_row += 1
