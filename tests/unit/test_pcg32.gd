extends GutTest
## GDD §20 (aleatoriedade determinística) e ADR-0006: o PCG32 do núcleo.
## Os números fixos abaixo vêm da implementação de referência do PCG32 (semente 42,
## sequência 54) e de uma réplica em Python do mesmo algoritmo; se algum mudar, a
## sequência das Descidas gravadas mudou.


func _reference() -> Pcg32:
	return Pcg32.new(42, 54)


func test_matches_pcg32_reference_vectors() -> void:
	var rng: Pcg32 = _reference()
	var expected: Array[int] = [0xa15c02b7, 0x7b47f409, 0xba1d3330, 0x83d2f293, 0xbfa4784b, 0xcbed606e]
	for want: int in expected:
		assert_eq(rng.next_u32(), want)


func test_same_seed_gives_same_sequence() -> void:
	var a: Pcg32 = Pcg32.new(987654321, 3)
	var b: Pcg32 = Pcg32.new(987654321, 3)
	for i: int in 1000:
		assert_eq(a.next_u32(), b.next_u32(), "divergiu no sorteio %d" % i)


func test_different_seeds_and_sequences_differ() -> void:
	var base: Pcg32 = Pcg32.new(1, 0)
	var other_seed: Pcg32 = Pcg32.new(2, 0)
	var other_sequence: Pcg32 = Pcg32.new(1, 1)
	var same_seed: int = 0
	var same_sequence: int = 0
	for i: int in 100:
		var value: int = base.next_u32()
		if value == other_seed.next_u32():
			same_seed += 1
		if value == other_sequence.next_u32():
			same_sequence += 1
	assert_lt(same_seed, 3, "sementes diferentes quase não podem coincidir")
	assert_lt(same_sequence, 3, "sequências diferentes quase não podem coincidir")


func test_seed_with_resets_the_generator() -> void:
	var rng: Pcg32 = _reference()
	rng.next_u32()
	rng.next_u32()
	rng.seed_with(42, 54)
	assert_eq(rng.next_u32(), 0xa15c02b7)


func test_draw_int_golden_values() -> void:
	var rng: Pcg32 = _reference()
	var got: Array[int] = []
	for i: int in 10:
		got.append(rng.draw_int(1, 6))
	assert_eq(got, [4, 4, 3, 2, 2, 5, 6, 4, 1, 3] as Array[int])


func test_draw_int_stays_in_range_and_covers_it() -> void:
	var rng: Pcg32 = Pcg32.new(7, 0)
	var sum: int = 0
	var seen: Dictionary = {}
	for i: int in 10000:
		var value: int = rng.draw_int(-3, 3)
		assert_between(value, -3, 3)
		seen[value] = true
		sum += value
	assert_eq(seen.size(), 7, "todos os 7 valores devem aparecer")
	assert_eq(sum, 74, "soma fixa da sequência de referência")


func test_draw_int_is_roughly_uniform() -> void:
	var rng: Pcg32 = _reference()
	var counts: Array[int] = [0, 0, 0, 0, 0, 0, 0]
	for i: int in 10000:
		counts[rng.draw_int(1, 6)] += 1
	assert_eq(counts.slice(1), [1669, 1648, 1701, 1620, 1730, 1632] as Array[int])
	for face: int in range(1, 7):
		assert_between(counts[face], 1500, 1830, "face %d fora do esperado" % face)


func test_draw_int_degenerate_ranges() -> void:
	var rng: Pcg32 = _reference()
	assert_eq(rng.draw_int(5, 5), 5)
	assert_eq(rng.draw_int(9, 2), 9, "high menor que low devolve low")
	assert_eq(rng.draw_index(0), -1)
	assert_eq(rng.draw_index(1), 0)


func test_draw_float_is_in_unit_interval_with_expected_mean() -> void:
	var rng: Pcg32 = _reference()
	var total: float = 0.0
	for i: int in 10000:
		var value: float = rng.draw_float()
		assert_between(value, 0.0, 0.9999999999)
		total += value
	assert_almost_eq(total / 10000.0, 0.50202, 0.0001)


func test_draw_float_range_bounds() -> void:
	var rng: Pcg32 = Pcg32.new(11, 0)
	for i: int in 1000:
		var value: float = rng.draw_float_range(0.9, 1.1)
		assert_between(value, 0.9, 1.1)


func test_draw_percent_extremes() -> void:
	var rng: Pcg32 = _reference()
	for i: int in 200:
		assert_true(rng.draw_percent(100), "100% sempre acontece")
		assert_false(rng.draw_percent(0), "0% nunca acontece")


func test_draw_percent_matches_chance() -> void:
	var rng: Pcg32 = Pcg32.new(2024, 9)
	var hits: int = 0
	for i: int in 10000:
		if rng.draw_percent(30):
			hits += 1
	assert_between(hits, 2800, 3200, "30% em 10 mil lances")


func test_shuffled_copy_keeps_items_and_original() -> void:
	var rng: Pcg32 = _reference()
	var original: Array = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
	var shuffled: Array = rng.shuffled_copy(original)
	assert_eq(original, [0, 1, 2, 3, 4, 5, 6, 7, 8, 9], "a lista original não pode mudar")
	assert_eq(shuffled, [8, 2, 6, 4, 5, 1, 7, 0, 9, 3], "ordem fixa da sequência de referência")
	var sorted_back: Array = shuffled.duplicate()
	sorted_back.sort()
	assert_eq(sorted_back, original)


func test_shuffled_copy_of_tiny_lists() -> void:
	var rng: Pcg32 = _reference()
	assert_eq(rng.shuffled_copy([]), [])
	assert_eq(rng.shuffled_copy(["a"]), ["a"])


func test_snapshot_restores_the_same_future() -> void:
	var rng: Pcg32 = _reference()
	for i: int in 5:
		rng.next_u32()
	var saved: Dictionary = rng.snapshot()
	assert_eq(saved, {"state": "-9006259585714961295", "inc": "109"})
	var expected: Array[int] = []
	for i: int in 20:
		expected.append(rng.next_u32())
	var clone: Pcg32 = Pcg32.new()
	assert_true(clone.restore(saved))
	for want: int in expected:
		assert_eq(clone.next_u32(), want)


func test_snapshot_survives_json_without_losing_bits() -> void:
	var rng: Pcg32 = Pcg32.new(-1234567890123456789, 12345)
	for i: int in 17:
		rng.next_u32()
	var json_text: String = JSON.stringify(rng.snapshot())
	var parsed: Variant = JSON.parse_string(json_text)
	assert_true(parsed is Dictionary)
	var clone: Pcg32 = Pcg32.new()
	assert_true(clone.restore(parsed))
	for i: int in 50:
		assert_eq(clone.next_u32(), rng.next_u32())


func test_restore_rejects_bad_data_without_changing_state() -> void:
	var rng: Pcg32 = _reference()
	var bad_inputs: Array[Dictionary] = [
		{},
		{"state": 5, "inc": 7},
		{"state": "abc", "inc": "7"},
		{"state": "5", "inc": "8"},
	]
	for bad: Dictionary in bad_inputs:
		assert_false(rng.restore(bad), "deveria rejeitar %s" % str(bad))
	assert_eq(rng.next_u32(), 0xa15c02b7, "estado intacto depois das rejeições")
