class_name CoinRules
extends RefCounted
## Chance do cara ou coroa (GDD §7, ADR-0014). O jogador escolhe um lado antes do lance;
## acertar o lado é o sucesso. A escolha é ritual e não muda a chance nem o sorteio, então
## o núcleo só sorteia sucesso ou falha e a apresentação decide em que face a moeda cai.

## Lados para a apresentação (glossário: heads, tails).
const HEADS: int = 0
const TAILS: int = 1

const BASE: int = 50
const MIN_CHANCE: int = 15
const MAX_CHANCE: int = 85
const LUCK_CAP: int = 15
const STREAK_LOSSES: int = 3
const STREAK_BONUS: int = 10
const CHEAT_MAX: int = 90


## Chance de acerto (%) = clamp(50 + SORTE + mods, 15, 85). A SORTE conta até +15; a
## Maré de azar entra como mod. A trapaça soma depois do clamp, com teto de 90.
static func chance(luck: int, mods: int, streak_bonus: int = 0, cheat: int = 0) -> int:
	var value: int = clampi(BASE + mini(luck, LUCK_CAP) + mods + streak_bonus, MIN_CHANCE, MAX_CHANCE)
	if cheat > 0:
		value = mini(value + cheat, CHEAT_MAX)
	return value
