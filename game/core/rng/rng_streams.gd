class_name RngStreams
extends RefCounted
## Os quatro fluxos de sorteio do jogo (GDD §20): mapa, combate, loot e moeda.
##
## Cada fluxo tem semente própria, derivada da semente da Descida, e é independente dos
## outros: gastar sorteios de combate não muda a sequência da moeda. A mesma semente e as
## mesmas escolhas reproduzem a mesma Descida. A trapaça da moeda (GDD §7) só altera a
## chance antes do sorteio; o fluxo da moeda nunca é refeito depois dele.

enum Stream { MAP, COMBAT, LOOT, COIN }

const _GOLDEN: int = -7046029254386353131
const _MIX_A: int = -4658895280553007687
const _MIX_B: int = -7723592293110705685

var run_seed: int = 0
var _streams: Array[Pcg32] = []


func _init(run_seed_value: int = 0) -> void:
	run_seed = run_seed_value
	for index: int in Stream.size():
		_streams.append(Pcg32.new(derive_seed(run_seed_value, index), index))


func map() -> Pcg32:
	return _streams[Stream.MAP]


func combat() -> Pcg32:
	return _streams[Stream.COMBAT]


func loot() -> Pcg32:
	return _streams[Stream.LOOT]


func coin() -> Pcg32:
	return _streams[Stream.COIN]


func get_stream(which: Stream) -> Pcg32:
	return _streams[which]


## Semente nova e determinística a partir de [param seed_value] e de um rótulo
## ([param salt]). Serve para criar a semente de cada fluxo e a "próxima semente" do
## gerador de mapa quando ele descarta um cenário (GDD §5). É o SplitMix64.
static func derive_seed(seed_value: int, salt: int) -> int:
	return _split_mix(seed_value ^ _split_mix(salt))


## Estado dos quatro fluxos, para o save (texto, não números de 64 bits em JSON).
func snapshot() -> Dictionary:
	var streams: Array[Dictionary] = []
	for stream: Pcg32 in _streams:
		streams.append(stream.snapshot())
	return {"run_seed": str(run_seed), "streams": streams}


## Restaura de um [method snapshot]. Devolve falso, sem mudar nada, se o formato for
## inválido.
func restore(data: Dictionary) -> bool:
	if not (data.get("run_seed") is String and data.get("streams") is Array):
		return false
	var seed_text: String = data["run_seed"]
	var saved: Array = data["streams"]
	if not seed_text.is_valid_int() or saved.size() != _streams.size():
		return false
	var staged: Array[Pcg32] = []
	for entry: Variant in saved:
		if not entry is Dictionary:
			return false
		var generator: Pcg32 = Pcg32.new()
		if not generator.restore(entry):
			return false
		staged.append(generator)
	run_seed = seed_text.to_int()
	_streams = staged
	return true


static func _shift_right_logical(value: int, bits: int) -> int:
	return (value >> bits) & ((1 << (64 - bits)) - 1)


static func _split_mix(value: int) -> int:
	var z: int = value + _GOLDEN
	z = (z ^ _shift_right_logical(z, 30)) * _MIX_A
	z = (z ^ _shift_right_logical(z, 27)) * _MIX_B
	return z ^ _shift_right_logical(z, 31)
