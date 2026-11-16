extends GutTest
## GDD §20: quatro fluxos de sorteio (mapa, combate, loot e moeda) com sementes
## separadas, reproduzíveis e independentes entre si.

const RUN_SEED: int = 12345


func _first_three(rng: Pcg32) -> Array[int]:
	return [rng.next_u32(), rng.next_u32(), rng.next_u32()]


func test_derive_seed_golden_values() -> void:
	assert_eq(RngStreams.derive_seed(12345, 0), 8814202233882078983)
	assert_eq(RngStreams.derive_seed(12345, 1), 1440032734657043752)
	assert_eq(RngStreams.derive_seed(12345, 2), 3124195775511229679)
	assert_eq(RngStreams.derive_seed(12345, 3), -5842047360511692015)
	assert_eq(RngStreams.derive_seed(0, 0), -6411193824288604561)


func test_each_stream_has_its_golden_sequence() -> void:
	var streams: RngStreams = RngStreams.new(RUN_SEED)
	assert_eq(_first_three(streams.map()), [3406537499, 322885192, 939649962] as Array[int])
	assert_eq(_first_three(streams.combat()), [114637183, 3800152976, 535534301] as Array[int])
	assert_eq(_first_three(streams.loot()), [3372100318, 2049155295, 564240483] as Array[int])
	assert_eq(_first_three(streams.coin()), [4241210005, 2441748249, 3186912171] as Array[int])


func test_same_seed_reproduces_every_stream() -> void:
	var a: RngStreams = RngStreams.new(RUN_SEED)
	var b: RngStreams = RngStreams.new(RUN_SEED)
	for which: int in RngStreams.Stream.size():
		var sa: Pcg32 = a.get_stream(which as RngStreams.Stream)
		var sb: Pcg32 = b.get_stream(which as RngStreams.Stream)
		for i: int in 500:
			assert_eq(sa.next_u32(), sb.next_u32(), "fluxo %d, sorteio %d" % [which, i])


func test_streams_are_different_from_each_other() -> void:
	var streams: RngStreams = RngStreams.new(RUN_SEED)
	var firsts: Dictionary = {}
	for which: int in RngStreams.Stream.size():
		firsts[streams.get_stream(which as RngStreams.Stream).next_u32()] = true
	assert_eq(firsts.size(), 4, "quatro fluxos, quatro primeiros sorteios distintos")


func test_spending_one_stream_does_not_move_the_others() -> void:
	var quiet: RngStreams = RngStreams.new(RUN_SEED)
	var busy: RngStreams = RngStreams.new(RUN_SEED)
	for i: int in 1000:
		busy.combat().next_u32()
		busy.loot().draw_int(1, 100)
	for i: int in 200:
		assert_eq(busy.coin().next_u32(), quiet.coin().next_u32(), "moeda mudou no sorteio %d" % i)
		assert_eq(busy.map().next_u32(), quiet.map().next_u32(), "mapa mudou no sorteio %d" % i)


func test_different_run_seeds_give_different_streams() -> void:
	var a: RngStreams = RngStreams.new(1)
	var b: RngStreams = RngStreams.new(2)
	assert_ne(a.coin().next_u32(), b.coin().next_u32())
	assert_ne(a.map().next_u32(), b.map().next_u32())


func test_derive_seed_is_deterministic_and_spreads() -> void:
	var seen: Dictionary = {}
	for salt: int in 1000:
		var value: int = RngStreams.derive_seed(RUN_SEED, salt)
		assert_eq(value, RngStreams.derive_seed(RUN_SEED, salt))
		seen[value] = true
	assert_eq(seen.size(), 1000, "mil rótulos, mil sementes distintas")


func test_snapshot_restores_all_streams_even_through_json() -> void:
	var original: RngStreams = RngStreams.new(RUN_SEED)
	for i: int in 37:
		original.map().next_u32()
		original.combat().draw_int(1, 20)
		original.loot().draw_float()
		original.coin().draw_percent(50)
	var parsed: Variant = JSON.parse_string(JSON.stringify(original.snapshot()))
	assert_true(parsed is Dictionary)
	var restored: RngStreams = RngStreams.new(0)
	assert_true(restored.restore(parsed))
	assert_eq(restored.run_seed, RUN_SEED)
	for i: int in 100:
		assert_eq(restored.map().next_u32(), original.map().next_u32())
		assert_eq(restored.combat().next_u32(), original.combat().next_u32())
		assert_eq(restored.loot().next_u32(), original.loot().next_u32())
		assert_eq(restored.coin().next_u32(), original.coin().next_u32())


func test_restore_rejects_bad_data_and_keeps_state() -> void:
	var streams: RngStreams = RngStreams.new(RUN_SEED)
	var good: Dictionary = streams.snapshot()
	var wrong_count: Dictionary = {"run_seed": "1", "streams": [good["streams"][0]]}
	var not_a_stream: Dictionary = {"run_seed": "1", "streams": [1, 2, 3, 4]}
	var bad_streams: Array[Dictionary] = [{}, wrong_count, not_a_stream, {"run_seed": 5, "streams": []}]
	for bad: Dictionary in bad_streams:
		assert_false(streams.restore(bad))
	assert_eq(streams.run_seed, RUN_SEED)
	assert_eq(_first_three(streams.map()), [3406537499, 322885192, 939649962] as Array[int])
