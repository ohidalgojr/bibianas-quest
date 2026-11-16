class_name EnemyPhase
extends RefCounted
## Fase de um inimigo: o ciclo de movimentos vale enquanto a vida estiver em
## [member below_hp_percent] ou menos (GDD §6, chefes com 2 a 3 fases).

var below_hp_percent: int = 100
var moves: Array[EnemyMove] = []


static func make(threshold_percent: int, phase_moves: Array[EnemyMove]) -> EnemyPhase:
	var phase: EnemyPhase = EnemyPhase.new()
	phase.below_hp_percent = threshold_percent
	phase.moves = phase_moves
	return phase
