class_name CombatScreen
extends Control
## Tela de combate do protótipo cinza (TASK-006, ADR-0010): 2D, formas simples, em
## retrato. Desenha o que o [CombatSession] entrega e anima os eventos do núcleo em
## fila. Nenhuma regra é calculada aqui.

signal fight_finished(outcome: int)
## Na luta da Descida, o jogador apertou "Continuar" depois do resultado (ADR-0013).
signal run_fight_done
## O jogador apertou Cara ou Coroa no lance da moeda (ADR-0014).
signal coin_called(side: int)

## Pausa por evento, em segundos, na velocidade 1x.
const EVENT_DELAY: float = 0.35
## GDD §7: animação do lance com cerca de 1,2 s.
const COIN_DELAY: float = 1.2
const TIMELINE_SIZE: int = 6
const LOG_LINES: int = 7
const LEVELS: Array[int] = [1, 2, 3, 4, 5, 6]

const COLOR_BG: Color = Color(0.07, 0.08, 0.1)
const COLOR_PANEL: Color = Color(0.13, 0.14, 0.17)
const COLOR_PLAYER: Color = Color(0.35, 0.5, 0.75)
const COLOR_ENEMY: Color = Color(0.6, 0.3, 0.28)
const COLOR_BOSS: Color = Color(0.45, 0.15, 0.2)
const COLOR_DANGER: Color = Color(0.85, 0.35, 0.2)
const COLOR_COIN: Color = Color(0.9, 0.75, 0.25)
const COLOR_DEBUFF: Color = Color(0.6, 0.4, 0.8)
const COLOR_CALM: Color = Color(0.4, 0.42, 0.46)

## Multiplicador das pausas: 1 normal, 0,5 na velocidade 2x, 0 nos testes.
var time_scale: float = 1.0
var data: GameData
var session: CombatSession
## Lado usado quando não há como esperar o botão (testes, [member time_scale] = 0).
var auto_call: int = CoinRules.HEADS

var _busy: bool = false
var _player_hp: int = 0
var _player_mp: int = 0
var _enemy_hp: int = 0
var _effects: Array[Dictionary] = [{}, {}]
var _log: PackedStringArray = PackedStringArray()
var _enemy_id: String = ""
var _level: int = 1
var _power: float = 1.0
var _seed_counter: int = 0

var _timeline: HBoxContainer
var _enemy_shape: ColorRect
var _player_shape: ColorRect
var _enemy_name: Label
var _enemy_hp_bar: ProgressBar
var _enemy_hp_label: Label
var _intent_panel: PanelContainer
var _intent_icon: Label
var _intent_detail: Label
var _log_label: Label
var _player_hp_bar: ProgressBar
var _player_mp_bar: ProgressBar
var _player_stats: Label
var _player_effects: Label
var _buttons: Dictionary = {}
var _coin_overlay: PanelContainer
var _coin_label: Label
var _call_row: HBoxContainer
var _call_buttons: Array[Button] = []
var _menu: PanelContainer
var _menu_title: Label
var _menu_enemies: VBoxContainer
var _menu_level: OptionButton
var _menu_power: SpinBox
var _menu_debug: Array[Control] = []
var _continue: Button


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	theme = Theme.new()
	theme.default_font_size = 20
	if data == null:
		data = DataLoader.load_all()
	_build()
	if not data.is_valid():
		_menu_title.text = "Dados inválidos. Veja o console."
		return
	var scenario: Dictionary = data.scenario("abandoned_city")
	_enemy_id = str(scenario["common_enemies"][0])
	_open_menu("Escolha a luta")


# --- Fluxo da luta ----------------------------------------------------------------

## Começa uma luta. Sem semente, usa um contador; a semente aparece no registro.
func start_fight(enemy_id: String, level: int, power: float, fight_seed: int = -1) -> void:
	_enemy_id = enemy_id
	_level = level
	_power = power
	if fight_seed < 0:
		_seed_counter += 1
		fight_seed = int(Time.get_unix_time_from_system()) * 1000 + _seed_counter
	session = CombatSession.new(data, enemy_id, level, power, fight_seed)
	_begin(session.combat.player.hp, session.combat.player.mp, session.combat.enemy.hp)
	await _play(session.start())


## Luta da Descida (ADR-0013): a luta já começou no [RunState]; a tela repete os eventos
## desde o início, a partir da vida e do MP de antes da luta.
func start_run_fight(run: RunState) -> void:
	session = CombatSession.for_run(run)
	_begin(run.hp, run.mp, session.combat.enemy.stats.max_hp)
	await _play(session.start())


## Depuração (TASK-013): vence a luta em andamento na hora.
func debug_kill() -> void:
	if _busy or session == null or session.is_over():
		return
	await _play(session.combat.debug_kill_enemy())


func _begin(player_hp: int, player_mp: int, enemy_hp: int) -> void:
	_menu.visible = false
	_log.clear()
	_effects = [{}, {}]
	_player_hp = player_hp
	_player_mp = player_mp
	_enemy_hp = enemy_hp
	var level: int = session.level
	_enemy_name.text = "%s  (nível %d)" % [session.enemy_name(), level]
	_enemy_shape.color = COLOR_BOSS if session.is_boss() else COLOR_ENEMY
	_enemy_shape.modulate = Color.WHITE
	_enemy_shape.custom_minimum_size = Vector2(150, 150) if session.is_boss() else Vector2(110, 110)
	_enemy_hp_bar.max_value = session.combat.enemy.stats.max_hp
	_player_hp_bar.max_value = session.combat.player.stats.max_hp
	_player_mp_bar.max_value = session.combat.player.stats.max_mp
	for index: int in session.skills.size():
		(_buttons["skill_%d" % index] as Button).text = session.skill_label(index)
	_refresh_bars()


func perform(action: String) -> void:
	if _busy or session == null or not session.can_act():
		return
	var events: Array[CombatEvent] = []
	match action:
		"attack":
			events = session.attack()
		"defend":
			events = session.defend()
		"potion":
			events = session.use_potion()
		"flee":
			events = session.flee()
		"skill_0", "skill_1", "skill_2":
			events = session.use_skill(int(action.substr(6)))
	if events.is_empty():
		return
	await _play(events)


func _play(events: Array[CombatEvent]) -> void:
	_busy = true
	_refresh_buttons()
	for event: CombatEvent in events:
		_apply(event)
		if event.type == CombatEvent.Type.COIN:
			# O registro cita o lado escolhido, então só escreve depois da escolha.
			await _show_coin(event)
			_push_log(session.describe(event))
			continue
		var line: String = session.describe(event)
		if not line.is_empty():
			_push_log(line)
			await _wait(EVENT_DELAY)
	_busy = false
	_refresh_timeline()
	_refresh_buttons()
	if session.is_over():
		var result: int = session.combat.outcome
		if session.run != null:
			_open_result(session.outcome_text())
		else:
			_open_menu(session.outcome_text())
		fight_finished.emit(result)


## Atualiza o estado da tela a partir do evento, sem consultar regras.
func _apply(event: CombatEvent) -> void:
	match event.type:
		CombatEvent.Type.INTENT:
			_show_intent(event.label)
		CombatEvent.Type.ACTION:
			if event.side == Combatant.PLAYER:
				_player_mp -= event.value
			else:
				_intent_icon.text = "..."
				_intent_detail.text = ""
				_intent_panel.self_modulate = COLOR_CALM
		CombatEvent.Type.DAMAGE:
			var on_enemy: bool = event.side != Combatant.PLAYER
			if on_enemy:
				_enemy_hp = event.extra
			else:
				_player_hp = event.extra
			_pop_text("-%d%s" % [event.value, "!" if event.flag else ""], COLOR_COIN if event.flag else COLOR_DANGER, on_enemy)
			if on_enemy and event.extra <= 0:
				_play_defeat()
		CombatEvent.Type.MISS:
			_pop_text("Errou", COLOR_CALM, event.side != Combatant.PLAYER)
		CombatEvent.Type.HEAL:
			if event.side == Combatant.PLAYER:
				_player_hp += event.value
				_player_mp += event.extra
			else:
				_enemy_hp += event.value
		CombatEvent.Type.EFFECT_ON:
			_effects[event.side][event.label] = event.value
		CombatEvent.Type.EFFECT_OFF:
			_effects[event.side].erase(event.label)
		CombatEvent.Type.STUN_SKIP:
			_effects[event.side].erase("stunned")
	_refresh_bars()


## Número que sobe do alvo e some (ADR-0021). Sem tempo (testes), não desenha.
func _pop_text(text: String, color: Color, on_enemy: bool) -> void:
	if time_scale <= 0.0 or not is_inside_tree():
		return
	var target: Control = _enemy_shape if on_enemy else _player_shape
	var label: Label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 30)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 6)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.z_index = 50
	add_child(label)
	label.position = target.global_position - global_position + Vector2(target.size.x * 0.3, -10)
	var tween: Tween = create_tween().set_parallel(true)
	tween.tween_property(label, "position:y", label.position.y - 70.0, 0.9 * time_scale)
	tween.tween_property(label, "modulate:a", 0.0, 0.9 * time_scale).set_delay(0.3 * time_scale)
	tween.chain().tween_callback(label.queue_free)


## Abate do inimigo (ADR-0021): clareia, some e mostra "Derrotado!". Sem tempo, só some.
func _play_defeat() -> void:
	if time_scale <= 0.0 or not is_inside_tree():
		_enemy_shape.modulate = Color(1, 1, 1, 0.25)
		return
	_pop_text("Derrotado!", COLOR_COIN, true)
	var tween: Tween = create_tween()
	tween.tween_property(_enemy_shape, "modulate", Color(3, 3, 3, 1), 0.12 * time_scale)
	tween.tween_property(_enemy_shape, "modulate", Color(1, 1, 1, 0.0), 0.5 * time_scale)


func _show_intent(move_id: String) -> void:
	var view: Dictionary = session.intent_view(move_id)
	_intent_icon.text = "%s  %s" % [view["icon"], view["name"]]
	_intent_detail.text = str(view["detail"])
	if bool(view["coin"]):
		_intent_panel.self_modulate = COLOR_COIN
	elif bool(view["debuff"]):
		_intent_panel.self_modulate = COLOR_DEBUFF
	elif bool(view["dangerous"]):
		_intent_panel.self_modulate = COLOR_DANGER
	else:
		_intent_panel.self_modulate = COLOR_CALM


## Lance da moeda (GDD §7, ADR-0014): o jogador escolhe o lado vendo a chance, a moeda
## gira por 1,2 s e o resultado mostra o lado em que caiu.
func _show_coin(event: CombatEvent) -> void:
	_coin_overlay.visible = true
	var streak: String = "\nMaré de azar: +%d" % event.extra if event.extra > 0 else ""
	var odds: String = "Chance de acertar: %d%%%s" % [event.value, streak]
	var called: int = await _ask_call(event.value, odds)
	session.coin_call = called
	_coin_label.text = "Você escolheu %s\nA moeda gira...\n%s" % [CombatTexts.side_name(called), odds]
	await _wait(COIN_DELAY)
	_coin_label.text = "Você escolheu %s\n%s\n%s" % [CombatTexts.side_name(called),
		CombatTexts.coin_result(called, event.flag), odds]
	await _wait(EVENT_DELAY * 2.0)
	_coin_overlay.visible = false


## Pede o lado ao jogador e devolve o escolhido. Sem tempo (testes) ou fora da árvore,
## usa [member auto_call] em vez de esperar o botão.
func _ask_call(chance: int, odds: String = "") -> int:
	if time_scale <= 0.0 or not is_inside_tree():
		return auto_call
	_coin_label.text = "Escolha o lado da moeda\n%s" % (odds if not odds.is_empty() else "Chance de acertar: %d%%" % chance)
	_call_row.visible = true
	var side: int = await coin_called
	_call_row.visible = false
	return side


func _wait(seconds: float) -> void:
	if time_scale <= 0.0 or not is_inside_tree():
		return
	await get_tree().create_timer(seconds * time_scale).timeout


# --- Atualização da tela -----------------------------------------------------------

func _refresh_bars() -> void:
	_enemy_hp_bar.value = _enemy_hp
	_enemy_hp_label.text = "HP %d / %d" % [_enemy_hp, int(_enemy_hp_bar.max_value)]
	_player_hp_bar.value = _player_hp
	_player_mp_bar.value = _player_mp
	_player_stats.text = "HP %d / %d    MP %d / %d" % [_player_hp, int(_player_hp_bar.max_value),
		_player_mp, int(_player_mp_bar.max_value)]
	_player_effects.text = _effects_text(Combatant.PLAYER)
	var enemy_effects: String = _effects_text(Combatant.ENEMY)
	_enemy_hp_label.text += ("    " + enemy_effects) if not enemy_effects.is_empty() else ""


func _effects_text(side: int) -> String:
	var names: PackedStringArray = PackedStringArray()
	for label: String in _effects[side]:
		names.append(CombatTexts.effect_name(label))
	return ", ".join(names)


func _refresh_timeline() -> void:
	for child: Node in _timeline.get_children():
		child.queue_free()
	var title: Label = Label.new()
	title.text = "Próximos:"
	_timeline.add_child(title)
	if session == null or session.is_over():
		return
	for side: int in session.timeline(TIMELINE_SIZE):
		var chip: Label = Label.new()
		chip.text = " B " if side == Combatant.PLAYER else " I "
		chip.add_theme_color_override("font_color", COLOR_PLAYER.lightened(0.3) if side == Combatant.PLAYER else COLOR_DANGER)
		_timeline.add_child(chip)


func _refresh_buttons() -> void:
	var can_go: bool = session != null and not _busy and session.can_act()
	(_buttons["attack"] as Button).disabled = not can_go
	(_buttons["defend"] as Button).disabled = not can_go
	for index: int in 3:
		var skill_ready: bool = can_go and session.can_use_skill(index)
		(_buttons["skill_%d" % index] as Button).disabled = not skill_ready
	var potion: Button = _buttons["potion"]
	potion.disabled = not (can_go and session.can_use_potion())
	if session != null:
		potion.text = session.potion_label()
	var flee: Button = _buttons["flee"]
	flee.disabled = not (can_go and session.can_flee())
	flee.tooltip_text = "Moeda: acertar o lado foge (chance de %d%%)" % session.coin_chance() if session != null else ""
	(_buttons["skill_0"] as Button).tooltip_text = "Moeda: acertar o lado atordoa (chance de %d%%)" % session.coin_chance() \
		if session != null else ""


func _push_log(line: String) -> void:
	_log.append(line)
	while _log.size() > LOG_LINES:
		_log.remove_at(0)
	_log_label.text = "\n".join(_log)


# --- Menu de depuração ---------------------------------------------------------------

func _open_menu(title: String) -> void:
	_menu_title.text = title
	_continue.visible = false
	for control: Control in _menu_debug:
		control.visible = true
	for child: Node in _menu_enemies.get_children():
		child.queue_free()
	var scenario: Dictionary = data.scenario("abandoned_city")
	for index: int in _scenario_enemies().size():
		var enemy_id: String = _scenario_enemies()[index]
		var button: Button = Button.new()
		var kind: String = data.enemy_type(enemy_id)
		var tag: String = "" if kind == "common" else (" (chefe)" if kind == "boss" else " (elite)")
		button.text = "%d. %s%s" % [index + 1, str(data.enemies[enemy_id]["name"]), tag]
		button.custom_minimum_size = Vector2(0, 52)
		button.pressed.connect(_on_enemy_chosen.bind(enemy_id))
		_menu_enemies.add_child(button)
	if session == null:
		_menu_level.select(LEVELS.find(int(scenario["min_level"])))
	_menu.visible = true


func _scenario_enemies() -> Array[String]:
	var scenario: Dictionary = data.scenario("abandoned_city")
	var found: Array[String] = []
	for enemy_id: Variant in scenario["common_enemies"]:
		found.append(str(enemy_id))
	for enemy_id: Variant in scenario["elite_enemies"]:
		found.append(str(enemy_id))
	found.append(str(scenario["boss"]))
	return found


func _on_enemy_chosen(enemy_id: String) -> void:
	var level: int = LEVELS[maxi(_menu_level.selected, 0)]
	if data.enemy_type(enemy_id) == "boss":
		level = maxi(level, int(data.enemies[enemy_id]["base_level"]))
	start_fight(enemy_id, level, _menu_power.value)


func _unhandled_input(event: InputEvent) -> void:
	if not _menu.visible or not event is InputEventKey or not event.is_pressed():
		return
	var key: int = (event as InputEventKey).keycode
	var index: int = key - KEY_1
	if index >= 0 and index < _scenario_enemies().size():
		_on_enemy_chosen(_scenario_enemies()[index])
		get_viewport().set_input_as_handled()


# --- Montagem da tela ------------------------------------------------------------------

func _build() -> void:
	var background: ColorRect = ColorRect.new()
	background.color = COLOR_BG
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var margin: MarginContainer = MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side: String in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 16)
	add_child(margin)
	var column: VBoxContainer = VBoxContainer.new()
	column.add_theme_constant_override("separation", 10)
	margin.add_child(column)

	_timeline = HBoxContainer.new()
	column.add_child(_timeline)
	_refresh_timeline()

	# Inimigo
	var enemy_row: HBoxContainer = HBoxContainer.new()
	enemy_row.add_theme_constant_override("separation", 12)
	column.add_child(enemy_row)
	_enemy_shape = ColorRect.new()
	_enemy_shape.color = COLOR_ENEMY
	_enemy_shape.custom_minimum_size = Vector2(110, 110)
	enemy_row.add_child(_enemy_shape)
	var enemy_info: VBoxContainer = VBoxContainer.new()
	enemy_info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	enemy_row.add_child(enemy_info)
	_enemy_name = Label.new()
	enemy_info.add_child(_enemy_name)
	_enemy_hp_bar = _bar(Color(0.75, 0.25, 0.25))
	enemy_info.add_child(_enemy_hp_bar)
	_enemy_hp_label = Label.new()
	_enemy_hp_label.add_theme_font_size_override("font_size", 16)
	enemy_info.add_child(_enemy_hp_label)

	_intent_panel = PanelContainer.new()
	_intent_panel.add_theme_stylebox_override("panel", _box(Color.WHITE))
	_intent_panel.self_modulate = COLOR_CALM
	column.add_child(_intent_panel)
	var intent_box: VBoxContainer = VBoxContainer.new()
	_intent_panel.add_child(intent_box)
	_intent_icon = Label.new()
	_intent_icon.add_theme_font_size_override("font_size", 26)
	_intent_icon.add_theme_color_override("font_color", Color.BLACK)
	intent_box.add_child(_intent_icon)
	_intent_detail = Label.new()
	_intent_detail.add_theme_font_size_override("font_size", 16)
	_intent_detail.add_theme_color_override("font_color", Color.BLACK)
	_intent_detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	intent_box.add_child(_intent_detail)

	# Registro
	var log_panel: PanelContainer = PanelContainer.new()
	log_panel.add_theme_stylebox_override("panel", _box(COLOR_PANEL))
	log_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(log_panel)
	_log_label = Label.new()
	_log_label.add_theme_font_size_override("font_size", 16)
	_log_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_log_label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	_log_label.clip_text = true
	_log_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	log_panel.add_child(_log_label)

	# Bibiana
	var player_row: HBoxContainer = HBoxContainer.new()
	player_row.add_theme_constant_override("separation", 12)
	column.add_child(player_row)
	_player_shape = ColorRect.new()
	_player_shape.color = COLOR_PLAYER
	_player_shape.custom_minimum_size = Vector2(80, 80)
	player_row.add_child(_player_shape)
	var player_info: VBoxContainer = VBoxContainer.new()
	player_info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	player_row.add_child(player_info)
	_player_stats = Label.new()
	player_info.add_child(_player_stats)
	_player_hp_bar = _bar(Color(0.3, 0.7, 0.35))
	player_info.add_child(_player_hp_bar)
	_player_mp_bar = _bar(Color(0.3, 0.45, 0.85))
	player_info.add_child(_player_mp_bar)
	_player_effects = Label.new()
	_player_effects.add_theme_font_size_override("font_size", 16)
	player_info.add_child(_player_effects)

	# Ações na zona do polegar
	var grid: GridContainer = GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	column.add_child(grid)
	for entry: Array in [["attack", "Atacar"], ["defend", "Defender"], ["skill_0", "Skill"], ["skill_1", "Skill"],
			["skill_2", "Skill"], ["potion", "Poção"], ["flee", "Fugir"], ["speed", "Velocidade 1x"]]:
		var button: Button = Button.new()
		button.text = str(entry[1])
		button.custom_minimum_size = Vector2(0, 64)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var action: String = str(entry[0])
		if action == "speed":
			button.pressed.connect(_toggle_speed)
		else:
			button.pressed.connect(perform.bind(action))
		grid.add_child(button)
		_buttons[action] = button

	_coin_overlay = _overlay()
	var coin_box: VBoxContainer = VBoxContainer.new()
	coin_box.add_theme_constant_override("separation", 16)
	coin_box.alignment = BoxContainer.ALIGNMENT_CENTER
	_coin_overlay.add_child(coin_box)
	_coin_label = Label.new()
	_coin_label.add_theme_font_size_override("font_size", 30)
	_coin_label.add_theme_color_override("font_color", COLOR_COIN)
	_coin_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_coin_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	coin_box.add_child(_coin_label)
	_call_row = HBoxContainer.new()
	_call_row.add_theme_constant_override("separation", 12)
	_call_row.visible = false
	coin_box.add_child(_call_row)
	for side: int in [CoinRules.HEADS, CoinRules.TAILS]:
		var call_button: Button = Button.new()
		call_button.text = CombatTexts.side_name(side)
		call_button.custom_minimum_size = Vector2(0, 80)
		call_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		call_button.pressed.connect(func() -> void: coin_called.emit(side))
		_call_row.add_child(call_button)
		_call_buttons.append(call_button)
	_coin_overlay.visible = false

	_menu = _overlay()
	var menu_box: VBoxContainer = VBoxContainer.new()
	menu_box.add_theme_constant_override("separation", 10)
	_menu.add_child(menu_box)
	_menu_title = Label.new()
	_menu_title.add_theme_font_size_override("font_size", 30)
	_menu_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	menu_box.add_child(_menu_title)
	var hint: Label = Label.new()
	hint.text = "Depuração: inimigo (teclas 1 a 6), nível e Poder"
	hint.add_theme_font_size_override("font_size", 16)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	menu_box.add_child(hint)
	var options: HBoxContainer = HBoxContainer.new()
	menu_box.add_child(options)
	var level_label: Label = Label.new()
	level_label.text = "Nível"
	options.add_child(level_label)
	_menu_level = OptionButton.new()
	for level: int in LEVELS:
		_menu_level.add_item(str(level))
	options.add_child(_menu_level)
	var power_label: Label = Label.new()
	power_label.text = "  Poder"
	options.add_child(power_label)
	_menu_power = SpinBox.new()
	_menu_power.min_value = 1.0
	_menu_power.max_value = 10.0
	_menu_power.step = 0.5
	_menu_power.value = 1.0
	options.add_child(_menu_power)
	_menu_enemies = VBoxContainer.new()
	menu_box.add_child(_menu_enemies)
	_menu_debug = [hint, options, _menu_enemies]
	_continue = Button.new()
	_continue.text = "Continuar"
	_continue.custom_minimum_size = Vector2(0, 64)
	_continue.visible = false
	_continue.pressed.connect(func() -> void: run_fight_done.emit())
	menu_box.add_child(_continue)
	_refresh_buttons()


## Resultado da luta da Descida: só o título e "Continuar".
func _open_result(title: String) -> void:
	_menu_title.text = title
	for control: Control in _menu_debug:
		control.visible = false
	_continue.visible = true
	_menu.visible = true


func _toggle_speed() -> void:
	time_scale = 0.5 if time_scale >= 1.0 else 1.0
	(_buttons["speed"] as Button).text = "Velocidade %s" % ("2x" if time_scale < 1.0 else "1x")


func _overlay() -> PanelContainer:
	var overlay: PanelContainer = PanelContainer.new()
	overlay.add_theme_stylebox_override("panel", _box(Color(0.03, 0.03, 0.05, 0.92)))
	overlay.anchor_left = 0.05
	overlay.anchor_right = 0.95
	overlay.anchor_top = 0.25
	overlay.anchor_bottom = 0.75
	overlay.offset_left = 0
	overlay.offset_right = 0
	overlay.offset_top = 0
	overlay.offset_bottom = 0
	add_child(overlay)
	return overlay


func _bar(color: Color) -> ProgressBar:
	var bar: ProgressBar = ProgressBar.new()
	bar.custom_minimum_size = Vector2(0, 18)
	bar.show_percentage = false
	bar.add_theme_stylebox_override("fill", _box(color))
	bar.add_theme_stylebox_override("background", _box(Color(0.2, 0.2, 0.22)))
	return bar


func _box(color: Color) -> StyleBoxFlat:
	var box: StyleBoxFlat = StyleBoxFlat.new()
	box.bg_color = color
	box.set_corner_radius_all(6)
	box.set_content_margin_all(10)
	return box
