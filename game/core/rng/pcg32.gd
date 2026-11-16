class_name Pcg32
extends RefCounted
## Gerador pseudoaleatório PCG32 (variante XSH-RR), próprio do projeto (ADR-0006).
##
## Escolhido no lugar de RandomNumberGenerator porque a sequência não depende da
## versão do Godot e o estado inteiro cabe em dois números, fáceis de salvar. A mesma
## semente e a mesma sequência de chamadas dão sempre os mesmos resultados, em qualquer
## máquina. Trocar o algoritmo ou o modo de reduzir intervalos muda todas as Descidas já
## gravadas: exige ADR e subir [constant CoreVersion.RULES_VERSION].
##
## Os nomes dos métodos evitam de propósito os do motor ([code]randi[/code], [code]shuffle[/code],
## [code]pick_random[/code]), que o teste de pureza do núcleo proíbe.

const _MULTIPLIER: int = 6364136223846793005
const _MASK_32: int = 0xFFFFFFFF
const _TWO_POW_32: int = 4294967296

var _state: int = 0
var _inc: int = 1


## Cria um gerador. [param seed_value] escolhe o ponto de partida; [param sequence]
## escolhe uma de 2^63 sequências independentes. O padrão de PCG32 usa 42 e 54 nos
## vetores de referência (testados em [code]tests/unit/test_pcg32.gd[/code]).
func _init(seed_value: int = 0, sequence: int = 0) -> void:
	seed_with(seed_value, sequence)


## Reinicia o gerador como se tivesse acabado de ser criado.
func seed_with(seed_value: int, sequence: int) -> void:
	_state = 0
	_inc = (sequence << 1) | 1
	next_u32()
	_state += seed_value
	next_u32()


## Próximo inteiro de 32 bits sem sinal (0 a 4294967295).
func next_u32() -> int:
	var old: int = _state
	_state = old * _MULTIPLIER + _inc
	var xorshifted: int = (((old >> 18) & ((1 << 46) - 1)) ^ old) >> 27 & _MASK_32
	var rot: int = (old >> 59) & 31
	return ((xorshifted >> rot) | (xorshifted << ((-rot) & 31))) & _MASK_32


## Inteiro uniforme em [code][low, high][/code], extremos incluídos, sem viés.
## O intervalo precisa ter no máximo 2^32 valores. Se [param high] for menor que
## [param low], devolve [param low].
func draw_int(low: int, high: int) -> int:
	if high <= low:
		return low
	var span: int = high - low + 1
	assert(span <= _TWO_POW_32, "intervalo grande demais para draw_int")
	var threshold: int = (_TWO_POW_32 - span) % span
	var value: int = next_u32()
	while value < threshold:
		value = next_u32()
	return low + value % span


## Decimal uniforme em [code][0, 1)[/code], com resolução de 32 bits.
func draw_float() -> float:
	return float(next_u32()) / float(_TWO_POW_32)


## Decimal uniforme em [code][low, high)[/code].
func draw_float_range(low: float, high: float) -> float:
	return low + (high - low) * draw_float()


## Verdadeiro com a chance dada em pontos percentuais (0 a 100). Usa um sorteio
## inteiro de 1 a 100, então 50 significa exatamente 50 em 100.
func draw_percent(chance_percent: int) -> bool:
	return draw_int(1, 100) <= chance_percent


## Índice sorteado de 0 a [param size] - 1. Devolve -1 se [param size] for menor que 1.
func draw_index(size: int) -> int:
	if size < 1:
		return -1
	return draw_int(0, size - 1)


## Cópia embaralhada (Fisher-Yates, do fim para o começo). A lista original não muda.
func shuffled_copy(items: Array) -> Array:
	var result: Array = items.duplicate()
	for i: int in range(result.size() - 1, 0, -1):
		var j: int = draw_int(0, i)
		var held: Variant = result[i]
		result[i] = result[j]
		result[j] = held
	return result


## Estado para salvar. Os números vão como texto porque JSON guarda números em ponto
## flutuante e perderia os bits baixos de um inteiro de 64 bits.
func snapshot() -> Dictionary:
	return {"state": str(_state), "inc": str(_inc)}


## Restaura um estado gravado por [method snapshot]. Devolve falso, sem mudar nada,
## se o dicionário não tiver o formato esperado.
func restore(data: Dictionary) -> bool:
	if not (data.get("state") is String and data.get("inc") is String):
		return false
	var state_text: String = data["state"]
	var inc_text: String = data["inc"]
	if not (state_text.is_valid_int() and inc_text.is_valid_int()):
		return false
	var inc_value: int = inc_text.to_int()
	if (inc_value & 1) == 0:
		return false
	_state = state_text.to_int()
	_inc = inc_value
	return true
