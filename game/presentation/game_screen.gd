class_name GameScreen
extends Control
## Raiz do fluxo provisório da Descida (TASK-009, ADR-0013): início, espera pela
## geração do mapa, mapa, combate, recompensa, loja, fogueira e resultado. A TASK-011
## troca o início pelo menu de verdade. Só chama as ações públicas do [RunState].

signal run_ended(victory: bool)

const CLASS_ID: String = "warrior"
const COLOR_BG: Color = Color(0.07, 0.08, 0.1)

var data: GameData
## Simulações da checagem de vencibilidade (GDD §5; ADR-0012). Os testes usam 0.
var map_check_runs: int = Winnability.DEFAULT_RUNS
## Cria a Descida numa thread (ADR-0013). Os testes criam na hora.
var use_thread: bool = true
## Repassado à tela de combate: 0 deixa a animação instantânea.
var time_scale: float = 1.0
var run: RunState
## Ecos acumulados e Descidas jogadas desde que o jogo abriu. O save é da TASK-012.
var echoes: int = 0
var runs_played: int = 0
## Save em disco (TASK-012, ADR-0017). Os testes desligam ou apontam para uma pasta de teste.
var save_enabled: bool = true
var save_dir: String = "user://"

var _thread: Thread
var _content: Control
var _map: MapScreen
var _combat: CombatScreen
var _panel: Control
var _reward_pending: bool = false
var _seed_counter: int = 0


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	theme = Theme.new()
	theme.default_font_size = 20
	if data == null:
		data = DataLoader.load_all()
	if save_enabled:
		var meta: Dictionary = _store().load_meta()
		echoes = int(meta["echoes"])
		runs_played = int(meta["runs_played"])
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
	box.add_child(_label("Ecos: %d    Descidas: %d" % [echoes, runs_played]))
	box.add_child(_label(_class_text()))
	if save_enabled and _store().has_run():
		box.add_child(_button("Continuar Descida", resume_run))
	box.add_child(_button("Nova Descida", func() -> void: new_run()))
	box.add_child(_button("Luta de teste (depuração)", _show_test_fight))


## Escolha de classe do MVP: só o Guerreiro (roteiro da TASK-011).
func _class_text() -> String:
	var stats: Stats = data.class_stats(CLASS_ID)
	return "Classe: %s (%s). HP %d, MP %d, FOR %d, DEF %d." % [
		str(data.classes[CLASS_ID]["name"]), RunState.PLAYER_NAME, stats.max_hp, stats.max_mp, stats.strength,
		stats.defense]


func _store() -> SaveStore:
	return SaveStore.new(save_dir)


## Retoma a Descida salva; se o save não serve mais, apaga e volta ao menu.
func resume_run() -> void:
	var loaded: RunState = _store().load_run(data)
	if loaded == null:
		_store().clear_run()
		show_home()
		return
	run = loaded
	_after_action()


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
	return RunState.new(data, run_seed, CLASS_ID, [], map_check_runs)


## Mostra a tela certa para a fase atual da Descida.
func _after_action() -> void:
	match run.phase:
		RunState.Phase.CHOOSING:
			# Auto-save a cada nó resolvido, com a Bibiana no mapa (ADR-0017).
			if save_enabled:
				_store().save_run(run)
			_show_map()
		RunState.Phase.FIGHT:
			_show_fight()
		RunState.Phase.SHOP:
			_show_map()
			if _reward_pending:
				_show_reward()
			else:
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
	# Depois de uma vitória com loja, a recompensa vem antes dela (TASK-010).
	_reward_pending = run.phase == RunState.Phase.SHOP
	_after_action()


## Recompensa, loja e fogueira (TASK-010, ADR-0015): painéis por cima do mapa.
func _show_reward() -> void:
	var screen: RunPanelScreen = _open_panel()
	screen.show_reward()
	screen.closed.connect(func() -> void:
		_reward_pending = false
		_after_action())


func _show_shop() -> void:
	var screen: RunPanelScreen = _open_panel()
	screen.show_shop()
	screen.closed.connect(func() -> void:
		run.leave_shop()
		_after_action())


func _show_campfire() -> void:
	var screen: RunPanelScreen = _open_panel()
	screen.show_campfire()
	screen.closed.connect(func() -> void:
		run.leave_campfire()
		_after_action())


func _open_panel() -> RunPanelScreen:
	var screen: RunPanelScreen = RunPanelScreen.new()
	screen.panels = RunPanels.new(run)
	_panel = screen
	_content.add_child(screen)
	return screen


## Tela de fim (GDD §26, "morte que ensina"): o que aconteceu, quem derrotou a Bibiana,
## os Ecos creditados e "Outra Descida".
func _show_result() -> void:
	var victory: bool = run.phase == RunState.Phase.VICTORY
	var earned: int = run.echoes_earned()
	echoes += earned
	runs_played += 1
	if save_enabled:
		_store().clear_run()
		_store().save_meta(echoes, runs_played)
	var title: String = "Vitória! O chefe caiu." if victory else "A Bibiana caiu."
	var box: VBoxContainer = _page(title, "Semente %d." % run.streams.run_seed)
	if not victory:
		var killer: String = str(data.enemies[run.defeated_by_id]["name"]) if data.enemies.has(run.defeated_by_id) else "?"
		box.add_child(_label("Derrotada por %s, nível %d." % [killer, run.defeated_by_level]))
	box.add_child(_label("Poder %.2f, ouro %d, %d nós, %d chefe(s)." % [
		run.power, run.gold, run.nodes_cleared, run.bosses_defeated()]))
	box.add_child(_label("Ecos ganhos: +%d (total %d). Nenhuma Descida se perde." % [earned, echoes]))
	box.add_child(_button("Outra Descida", func() -> void: new_run()))
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
