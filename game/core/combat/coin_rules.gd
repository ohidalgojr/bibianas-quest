class_name CoinRules
extends RefCounted
## Chance do cara ou coroa (GDD §7). Cara é sucesso; o lado escolhido pelo jogador é
## só ritual e não muda a chance.

const BASE: int = 50
const MIN_CHANCE: int = 15
const MAX_CHANCE: int = 85
const LUCK_CAP: int = 15
const STREAK_LOSSES: int = 3
const STREAK_BONUS: int = 10
const CHEAT_MAX: int = 90


## Chance de Cara (%) = clamp(50 + SORTE + mods, 15, 85). A SORTE conta até +15; a
## Maré de azar entra como mod. A trapaça soma depois do clamp, com teto de 90.
static func chance(luck: int, mods: int, streak_bonus: int = 0, cheat: int = 0) -> int:
	var value: int = clampi(BASE + mini(luck, LUCK_CAP) + mods + streak_bonus, MIN_CHANCE, MAX_CHANCE)
	if cheat > 0:
		value = mini(value + cheat, CHEAT_MAX)
	return value
