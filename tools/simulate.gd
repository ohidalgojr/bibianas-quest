extends SceneTree
## Simulador headless de balanceamento (GDD §23, TASK-008). Joga Descidas com os bots
## "mediano" e "cuidadoso", confere a vencibilidade de muitos mapas (GDD §5) e grava o
## relatório em reports/simulation.md.
##
## Uso (pela raiz do projeto):
##   godot --headless --path . -s tools/simulate.gd -- [--runs 400] [--check 40] [--maps 1000] [--map-check 20] [--seed 1000]
## --runs: Descidas por bot; --check: simulações da checagem de mapa durante as Descidas
## (0 desliga); --maps: mapas na prova de vencibilidade; --map-check: simulações por mapa
## nessa prova; --seed: primeira semente.

const OUT_PATH: String = "res://reports/simulation.md"


func _initialize() -> void:
	var args: Dictionary = _parse(OS.get_cmdline_user_args())
	var runs: int = int(args.get("runs", 400))
	var check: int = int(args.get("check", 40))
	var maps: int = int(args.get("maps", 1000))
	var map_check: int = int(args.get("map-check", 20))
	var first_seed: int = int(args.get("seed", 1000))
	var data: GameData = DataLoader.load_all()
	if not data.is_valid():
		quit(2)
		return
	var lines: PackedStringArray = PackedStringArray()
	lines.append("# Relatório do simulador")
	lines.append("")
	lines.append("Gerado em %s por `tools/simulate.gd` (runs %d, check %d, maps %d, map-check %d, seed %d)." % [
		Time.get_datetime_string_from_system(), runs, check, maps, map_check, first_seed])
	for profile: int in [RunBot.Profile.MEDIAN, RunBot.Profile.CAREFUL]:
		var start: int = Time.get_ticks_msec()
		var sim: Simulator = Simulator.new(data, profile, check)
		sim.run_many(first_seed, runs)
		lines.append("")
		lines.append(sim.report("Bot %s" % RunBot.PROFILE_NAMES[profile]))
		lines.append("")
		lines.append("Tempo: %.1f s." % ((Time.get_ticks_msec() - start) / 1000.0))
		print("bot %s pronto" % RunBot.PROFILE_NAMES[profile])
	var first_start: int = Time.get_ticks_msec()
	var first_sim: Simulator = Simulator.new(data, RunBot.Profile.MEDIAN, check, true)
	first_sim.run_many(first_seed, runs)
	lines.append("")
	lines.append(first_sim.report("Primeira Descida (bot mediano)"))
	lines.append("")
	lines.append("Tempo: %.1f s." % ((Time.get_ticks_msec() - first_start) / 1000.0))
	print("primeira Descida pronta")
	if maps > 0:
		lines.append("")
		lines.append(_winnability(data, first_seed, maps, map_check))
	var text: String = "\n".join(lines) + "\n"
	DirAccess.make_dir_recursive_absolute(OUT_PATH.get_base_dir())
	var file: FileAccess = FileAccess.open(OUT_PATH, FileAccess.WRITE)
	file.store_string(text)
	file.close()
	print(text)
	quit(0)


## Prova de vencibilidade (GDD §5): todo mapa gerado tem caminho vencível, ou é
## descartado e trocado. Conta quantos ficaram sem passar depois de todas as tentativas.
func _winnability(data: GameData, first_seed: int, maps: int, runs: int) -> String:
	var start: int = Time.get_ticks_msec()
	var failed: PackedStringArray = PackedStringArray()
	var smoothing: int = 0
	var discarded: int = 0
	var rate_total: float = 0.0
	for offset: int in maps:
		var run: RunState = RunState.new(data, first_seed + offset, "warrior", [], runs)
		smoothing += run.map_check.smoothing_steps
		discarded += run.map_check.maps_discarded
		rate_total += run.map_check.win_rate
		if not run.map_check.passed:
			failed.append(str(first_seed + offset))
		if (offset + 1) % 100 == 0:
			print("mapas: %d de %d" % [offset + 1, maps])
	var lines: PackedStringArray = PackedStringArray()
	lines.append("## Vencibilidade do mapa (GDD §5)")
	lines.append("")
	lines.append("| Métrica | Valor |")
	lines.append("| --- | --- |")
	lines.append("| Mapas (sementes) | %d |" % maps)
	lines.append("| Simulações por checagem | %d |" % runs)
	lines.append("| Sem caminho vencível no fim | %d |" % failed.size())
	lines.append("| Suavizações por mapa | %.2f |" % (float(smoothing) / maps))
	lines.append("| Mapas descartados por semente | %.2f |" % (float(discarded) / maps))
	lines.append("| Vitória na rota segura (última checagem) | %.1f%% |" % (rate_total / maps))
	lines.append("| Tempo por Descida criada | %d ms |" % ((Time.get_ticks_msec() - start) / maps))
	if not failed.is_empty():
		lines.append("")
		lines.append("Sementes sem caminho vencível: %s" % ", ".join(failed.slice(0, 50)))
	return "\n".join(lines)


func _parse(raw: PackedStringArray) -> Dictionary:
	var found: Dictionary = {}
	var index: int = 0
	while index < raw.size():
		var key: String = raw[index]
		if key.begins_with("--") and index + 1 < raw.size():
			found[key.substr(2)] = raw[index + 1]
			index += 2
		else:
			index += 1
	return found
