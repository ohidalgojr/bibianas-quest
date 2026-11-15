extends GutTest
## Regra de arquitetura (GDD §20, ADR-0002): o núcleo não depende de nós, da árvore
## de cena, do relógio nem da aleatoriedade global do motor.
##
## O teste lê os scripts de res://game/core como texto. Comentários são ignorados.

const CORE_DIR: String = "res://game/core"

## Expressão regular -> motivo da proibição.
const FORBIDDEN: Dictionary = {
	"(?<![\\w.])(randi|randf|randfn|randi_range|randf_range|randomize|seed)\\s*\\(":
		"aleatoriedade global; use os fluxos de RNG do núcleo (GDD §20)",
	"\\.(shuffle|pick_random)\\s*\\(":
		"usa a aleatoriedade global por baixo; sorteie pelos fluxos de RNG do núcleo",
	"\\b(get_tree|get_node|get_viewport|add_child)\\s*\\(":
		"API de nó ou de árvore de cena",
	"\\bEngine\\.get_main_loop\\b":
		"acesso à árvore de cena",
	"\\b(Time|OS)\\.":
		"relógio e sistema quebram o determinismo; receba esses valores de fora",
}

var _regexes: Array[RegEx] = []
var _reasons: PackedStringArray = PackedStringArray()
var _scripts: PackedStringArray = PackedStringArray()


func before_all() -> void:
	for pattern: String in FORBIDDEN:
		var regex: RegEx = RegEx.create_from_string(pattern)
		_regexes.append(regex)
		_reasons.append(str(FORBIDDEN[pattern]))
	_scripts = _collect_scripts(CORE_DIR)


func _collect_scripts(dir_path: String) -> PackedStringArray:
	var found: PackedStringArray = PackedStringArray()
	var dir: DirAccess = DirAccess.open(dir_path)
	if dir == null:
		return found
	for sub: String in dir.get_directories():
		found.append_array(_collect_scripts(dir_path.path_join(sub)))
	for file: String in dir.get_files():
		if file.get_extension() == "gd":
			found.append(dir_path.path_join(file))
	return found


## Devolve o motivo da primeira regra violada pela linha, ou "" se a linha é permitida.
func _first_violation(line: String) -> String:
	var code: String = line.get_slice("#", 0)
	for i: int in _regexes.size():
		if _regexes[i].search(code) != null:
			return _reasons[i]
	return ""


func test_all_rules_compile() -> void:
	assert_eq(_regexes.size(), FORBIDDEN.size())
	for regex: RegEx in _regexes:
		assert_true(regex.is_valid(), "expressão inválida: %s" % regex.get_pattern())


func test_rules_flag_known_offenders() -> void:
	var offenders: PackedStringArray = PackedStringArray([
		"var roll: int = randi() % 100",
		"\tif randf() < 0.5:",
		"\tseed(42)",
		"options.shuffle()",
		"var pick: int = options.pick_random()",
		"get_tree().quit()",
		"var loop: MainLoop = Engine.get_main_loop()",
		"var now: int = Time.get_ticks_msec()",
	])
	for line: String in offenders:
		assert_ne(_first_violation(line), "", "deveria ser barrado: %s" % line)


func test_rules_allow_core_rng_calls_and_comments() -> void:
	var allowed: PackedStringArray = PackedStringArray([
		"var roll: int = stream.randi_range(1, 100)",
		"# nunca chame randi() direto no núcleo",
		"var elapsed_time: float = 0.0",
		"func reseed(value: int) -> void:",
		"var map_seed: int = seeds.map",
	])
	for line: String in allowed:
		assert_eq(_first_violation(line), "", "não deveria ser barrado: %s" % line)


func test_core_has_scripts_to_check() -> void:
	assert_gt(
		_scripts.size(), 0,
		"nenhum script em %s; os testes de pureza passariam vazios" % CORE_DIR
	)


func test_core_scripts_do_not_extend_node() -> void:
	for path: String in _scripts:
		var script: GDScript = load(path) as GDScript
		assert_not_null(script, "%s precisa carregar" % path)
		if script == null:
			continue
		var base: StringName = script.get_instance_base_type()
		assert_false(
			ClassDB.is_parent_class(base, &"Node"),
			"%s estende %s, que é um nó" % [path, base]
		)


func test_core_scripts_avoid_forbidden_apis() -> void:
	var violations: PackedStringArray = PackedStringArray()
	for path: String in _scripts:
		var lines: PackedStringArray = FileAccess.get_file_as_string(path).split("\n")
		for i: int in lines.size():
			var reason: String = _first_violation(lines[i])
			if reason != "":
				violations.append("%s:%d: %s" % [path, i + 1, reason])
	assert_eq(violations.size(), 0, "\n".join(violations))
