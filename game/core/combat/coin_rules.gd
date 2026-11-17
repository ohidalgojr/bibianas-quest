class_name CoinRules
extends RefCounted
## Cara ou coroa (GDD §7, ADR-0025 D1 e ADR-0026). A moeda é só dois resultados: a
## chance é sempre 50% e não é exibida. O jogador escolhe um lado antes do lance e acertar
## é o sucesso (ADR-0014); a escolha é ritual, o núcleo só sorteia sucesso ou falha. SORTE e
## Maré de azar influenciam drops e baús, não a moeda.

## Lados para a apresentação (glossário: heads, tails).
const HEADS: int = 0
const TAILS: int = 1
## GDD §7: a chance do lance, sempre.
const CHANCE: int = 50
## GDD §7: lances perdidos seguidos que ligam a Maré de azar.
const STREAK_LOSSES: int = 3


static func chance() -> int:
	return CHANCE
