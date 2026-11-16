class_name GameScreen
extends Control
## Raiz do fluxo provisório da Descida (TASK-009, ADR-0013): início, espera pela
## geração do mapa, mapa, combate, loja e fogueira provisórias e resultado. A TASK-011
## troca o início pelo menu de verdade. Só chama as ações públicas do [RunState].

signal run_ended(victory: bool)

const COLOR_BG: Color = Color(0.07, 0.08, 0.1)

var data: GameData
## Simulações da checagem de vencibilidade (GDD §5; ADR-0012). Os testes usam 0.
var map_check_runs: int = Winnability.DEFAULT_RUNS
## Cria a Descida numa thread (ADR-0013). Os testes criam na hora.
var use_thread: bool = true
## Repassado à tela de combate: 0 deixa a animação instantânea.
var time_scale: float = 1.0
var run: RunState

var _thread: Thread
var _content: Control
var _map: MapScreen
var _combat: CombatScreen
var _panel: PanelContainer
var _seed_counter: int = 0


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	theme = Theme.new()
	theme.default_font_size = 20
	if data == null:
		data = DataLoader.load_all()
	show_home()


func _exit_tree() -> void:
	if _thread != null and _thread.is_started():
		_thread.wait_to_finish()


func _process(_delta: float) -> void:
	if _thread != null and _thread.is_started() and not _thread.is_alive():
		run = _thread.wait_to_finish()
		_thread = null
		_after_action()


# --- Telas -------------------------------------------------------------------------

func show_home() -> void:
	var box: VBoxContainer = _page("Bibiana's Quest", "Protótipo cinza, regras v%d" % CoreVersion.RULES_VERSION)
	if not data.is_valid():
		box.add_child(_label("Dados inválidos. Veja o console."))
		return
	box.add_child(_button("Nova Descida", func() -> void: new_run()))
	box.add_child(_button("Luta de teste (depuração)", _show_test_fight))


## Começa uma Descida. Sem semente, usa o relógio; a semente aparece na espera e no fim.
func new_run(run_seed: int = -1) -> void:
	if run_seed < 0:
		_seed_counter += 1
		run_seed = int(Time.get_unix_time_from_system()) * 1000 + _seed_counter
	_page("Gerando o mapa...", "Semente %d. Conferindo se há caminho vencível (GDD §5)." % run_seed)
	if use_thread:
		_thread = Thread.new()
		_thread.start(_create_run.bind(run_seed))
	else:
		run = _create_run(run_seed)
		_after_action()


func _create_run(run_seed: int) -> RunState:
	return RunState.new(data, run_seed, "warrior", [], map_check_runs)


## Mostra a tela certa para a fase atual da Descida.
func _after_action() -> void:
	match run.phase:
		RunState.Phase.CHOOSING:
			_show_map()
		RunState.Phase.FIGHT:
			_show_fight()
		RunState.Phase.SHOP:
			_show_map()
			_show_shop()
		RunState.Phase.CAMPFIRE:
			_show_map()
			_show_campfire()
		RunState.Phase.VICTORY, RunState.Phase.DEFEAT:
			_show_result()


func _show_map() -> void:
	_clear()
	_map = MapScreen.new()
	_map.view = MapView.new(run)
	_map.node_chosen.connect(choose_node)
	_set_content(_map)


func choose_node(node_id: int) -> void:
	if run.choose_node(node_id):
		_after_action()


func _show_fight() -> void:
	_clear()
	_combat = CombatScreen.new()
	_combat.data = data
	_combat.time_scale = time_scale
	_combat.run_fight_done.connect(_on_fight_done)
	_set_content(_combat)
	_combat.start_run_fight(run)


func _on_fight_done() -> void:
	run.finish_fight()
	_after_action()


## Loja provisória (ADR-0013): a de verdade chega na TASK-010.
func _show_shop() -> void:
	var box: VBoxContainer = _open_panel("Loja", "Ouro: %d. A loja de verdade chega na TASK-010." % run.gold)
	box.add_child(_button("Seguir", func() -> void:
		run.leave_shop()
		_after_action()))


## Fogueira provisória (ADR-0013): Descansar e Seguir.
func _show_campfire() -> void:
	var stats: Stats = run.player_stats()
	var box: VBoxContainer = _open_panel("Fogueira", "Brasas: %d. HP %d/%d, MP %d/%d." % [
		run.embers, run.hp, stats.max_hp, run.mp, stats.max_mp])
	var rest: Button = _button("Descansar (%d Brasas)" % RunRules.REST_COST, func() -> void:
		run.rest()
		_after_action())
	rest.disabled = run.embers < RunRules.REST_COST
	box.add_child(rest)
	box.add_child(_button("Seguir", func() -> void:
		run.leave_campfire()
		_after_action()))


func _show_result() -> void:
	var victory: bool = run.phase == RunState.Phase.VICTORY
	var title: String = "Vitória! O chefe caiu." if victory else "A Bibiana caiu."
	var summary: String = "Semente %d. Poder %.2f, ouro %d, %d nós." % [
		run.streams.run_seed, run.power, run.gold, run.nodes_cleared]
	var box: VBoxContainer = _page(title, summary)
	box.add_child(_button("Nova Descida", func() -> void: new_run()))
	box.add_child(_button("Início", show_home))
	run_ended.emit(victory)


func _show_test_fight() -> void:
	_clear()
	var screen: CombatScreen = CombatScreen.new()
	screen.data = data
	screen.time_scale = time_scale
	_set_content(screen)


# --- Montagem ------------------------------------------------------------------------

func _clear() -> void:
	_panel = null
	if _content != null:
		# queue_free: o botão que pediu a troca de tela ainda está emitindo o sinal.
		remove_child(_content)
		_content.queue_free()
		_content = null


func _set_content(control: Control) -> void:
	_content = control
	add_child(control)


## Página simples centralizada com título e texto; devolve a caixa para os botões.
func _page(title: String, text: String) -> VBoxContainer:
	_clear()
	var page: Control = Control.new()
	page.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var background: ColorRect = ColorRect.new()
	background.color = COLOR_BG
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	page.add_child(background)
	var center: CenterContainer = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	page.add_child(center)
	var box: VBoxContainer = _titled_box(title, text)
	center.add_child(box)
	_set_content(page)
	return box


func _open_panel(title: String, text: String) -> VBoxContainer:
	_panel = PanelContainer.new()
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.03, 0.03, 0.05, 0.94)
	style.set_corner_radius_all(8)
	style.set_content_margin_all(16)
	_panel.add_theme_stylebox_override("panel", style)
	_panel.anchor_left = 0.05
	_panel.anchor_right = 0.95
	_panel.anchor_top = 0.3
	_panel.anchor_bottom = 0.7
	var box: VBoxContainer = _titled_box(title, text)
	_panel.add_child(box)
	_content.add_child(_panel)
	return box


func _titled_box(title: String, text: String) -> VBoxContainer:
	var box: VBoxContainer = VBoxContainer.new()
	box.custom_minimum_size = Vector2(440, 0)
	box.add_theme_constant_override("separation", 12)
	var heading: Label = _label(title)
	heading.add_theme_font_size_override("font_size", 30)
	box.add_child(heading)
	box.add_child(_label(text))
	return box


func _label(text: String) -> Label:
	var label: Label = Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return label


func _button(text: String, action: Callable) -> Button:
	var button: Button = Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(0, 64)
	button.pressed.connect(action)
	return button
