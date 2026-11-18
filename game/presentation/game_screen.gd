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
## Atalhos de depuração (TASK-013, ADR-0018): só em build de desenvolvimento.
var debug_enabled: bool = OS.is_debug_build()
## Log local de eventos (TASK-013).
var telemetry_enabled: bool = true
var telemetry_dir: String = "user://"

var _thread: Thread
var _content: Control
var _map: MapScreen
var _combat: CombatScreen
var _panel: Control
var _reward_pending: bool = false
var _seed_counter: int = 0
var _seed_edit: LineEdit
var _debug_label: Label
## -1 moeda normal, 1 força sucesso, 0 força falha (depuração).
var _forced_coin: int = -1
var _logged_events: int = 0
var _telemetry: Telemetry


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
	_telemetry = Telemetry.new(telemetry_dir)
	_telemetry.enabled = telemetry_enabled
	if debug_enabled:
		_debug_label = Label.new()
		_debug_label.add_theme_font_size_override("font_size", 12)
		_debug_label.add_theme_color_override("font_color", Color(1.0, 0.6, 0.3))
		_debug_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_debug_label.z_index = 100
		add_child(_debug_label)
		_refresh_debug_label()
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
	if debug_enabled:
		_seed_edit = LineEdit.new()
		_seed_edit.placeholder_text = "Semente (depuração; vazio = aleatória)"
		box.add_child(_seed_edit)
	box.add_child(_button("Nova Descida", _new_run_from_menu))
	box.add_child(_button("Luta de teste (depuração)", _show_test_fight))


## Escolha de classe do MVP: só o Guerreiro (roteiro da TASK-011).
func _class_text() -> String:
	var stats: Stats = data.class_stats(CLASS_ID)
	return "Classe: %s (%s). HP %d, MP %d, FOR %d, DEF %d." % [
		str(data.classes[CLASS_ID]["name"]), RunState.PLAYER_NAME, stats.max_hp, stats.max_mp, stats.strength,
		stats.defense]


## Nova Descida do menu: em depuração, usa a semente digitada, se houver.
func _new_run_from_menu() -> void:
	if debug_enabled and _seed_edit != null and _seed_edit.text.strip_edges().is_valid_int():
		new_run(_seed_edit.text.strip_edges().to_int())
	else:
		new_run()


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
	_logged_events = 0
	_page("Gerando o mapa...", "Semente %d. Conferindo se há caminho vencível (GDD §5)." % run_seed)
	if use_thread:
		_thread = Thread.new()
		_thread.start(_create_run.bind(run_seed))
	else:
		run = _create_run(run_seed)
		_after_action()


func _create_run(run_seed: int) -> RunState:
	return RunState.new(data, run_seed, CLASS_ID, [], map_check_runs, null, runs_played == 0)


## Mostra a tela certa para a fase atual da Descida.
func _after_action() -> void:
	_flush_telemetry()
	match run.phase:
		RunState.Phase.CHOOSING:
			# Auto-save a cada nó resolvido, com a Bibiana no mapa (ADR-0017).
			if save_enabled:
				_store().save_run(run)
			_show_map()
			if not run.last_chest.is_empty():
				_show_chest()
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
	run.combat.forced_coin = _forced_coin
	_combat.start_run_fight(run)


func _on_fight_done() -> void:
	if run.combat != null:
		var node: MapNode = run.current_node()
		_telemetry.write(Telemetry.fight_lines(run.combat, node.enemy_id, node.level))
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


func _show_chest() -> void:
	var screen: RunPanelScreen = _open_panel()
	screen.show_chest()
	screen.closed.connect(func() -> void:
		screen.panels.close_chest()
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


## Tela de fim (GDD §26, "morte que ensina", ADR-0031): o que aconteceu, quem derrotou a
## Bibiana (e com quanto de HP ficou), dica tática, o que foi conquistado, os Ecos
## creditados (em dobro na 1ª Descida) e "Outra Descida".
func _show_result() -> void:
	var victory: bool = run.phase == RunState.Phase.VICTORY
	var earned: int = run.echoes_earned()
	echoes += earned
	runs_played += 1
	if save_enabled:
		_store().clear_run()
		_store().save_meta(echoes, runs_played)
	var summary: Dictionary = run.end_summary(echoes)
	var title: String = "Vitória! O chefe caiu." if victory else "A Bibiana caiu."
	var box: VBoxContainer = _page(title, "Semente %d." % run.streams.run_seed)
	if not victory:
		box.add_child(_label(str(summary["killer_line"])))
	box.add_child(_label(str(summary["tip_line"])))
	box.add_child(_label(str(summary["accomplished_line"])))
	box.add_child(_label(str(summary["next_line"])))
	box.add_child(_button("Outra Descida", func() -> void: new_run()))
	box.add_child(_button("Início", show_home))
	run_ended.emit(victory)


func _show_test_fight() -> void:
	_clear()
	var screen: CombatScreen = CombatScreen.new()
	screen.data = data
	screen.time_scale = time_scale
	_set_content(screen)


func _flush_telemetry() -> void:
	if run == null:
		return
	_telemetry.write(Telemetry.run_lines(run, _logged_events))
	_logged_events = run.history.size()


# --- Depuração (TASK-013) ----------------------------------------------------------

func _unhandled_input(event: InputEvent) -> void:
	if not debug_enabled or not event is InputEventKey or not event.is_pressed() or run == null:
		return
	match (event as InputEventKey).keycode:
		KEY_F1:
			debug_give_gold()
		KEY_F2:
			debug_skip_node()
		KEY_F3:
			debug_kill_enemy()
		KEY_F4:
			debug_cycle_coin()
		_:
			return
	get_viewport().set_input_as_handled()


func debug_give_gold(amount: int = 100) -> void:
	if debug_enabled and run != null and not run.is_over():
		run.gold += amount


## Pula o nó: escolhe o primeiro destino e, se for luta, vence na hora.
func debug_skip_node() -> void:
	if not debug_enabled or run == null or run.phase != RunState.Phase.CHOOSING:
		return
	choose_node(run.options()[0].id)
	if run.phase == RunState.Phase.FIGHT:
		debug_kill_enemy()


func debug_kill_enemy() -> void:
	if debug_enabled and run != null and run.phase == RunState.Phase.FIGHT and _combat != null:
		_combat.debug_kill()


## Alterna a moeda: normal, sempre sucesso, sempre falha.
func debug_cycle_coin() -> void:
	if not debug_enabled:
		return
	_forced_coin = {-1: 1, 1: 0, 0: -1}[_forced_coin]
	if run != null and run.combat != null:
		run.combat.forced_coin = _forced_coin
	_refresh_debug_label()


func _refresh_debug_label() -> void:
	if _debug_label == null:
		return
	var coin: String = {-1: "normal", 1: "sempre acerta", 0: "sempre erra"}[_forced_coin]
	_debug_label.text = "DEBUG  F1 +100 ouro  F2 pular nó  F3 matar inimigo  F4 moeda: %s" % coin


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
