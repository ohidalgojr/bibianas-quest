class_name CombatScreen
extends Control
## Tela de combate do protótipo cinza (TASK-006, ADR-0010): 2D, formas simples, em
## retrato. Desenha o que o [CombatSession] entrega e anima os eventos do núcleo em
## fila. Nenhuma regra é calculada aqui.

signal coin_focus(on: bool)
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
const DRAWER_ORDER: Array[String] = ["skills", "items", "tactical"]
const DRAWER_TITLES: Dictionary = {"skills": "Habilidades", "items": "Itens", "tactical": "Tático"}

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

## Palco 3D da luta (ADR-0036). Em headless (testes) a tela 2D de depuração continua valendo.
var use_stage: bool = DisplayServer.get_name() != "headless"
var _stage: Combat3DStage
var _timeline_col: VBoxContainer
var _status_enemy: HBoxContainer
var _status_player: HBoxContainer
var _forecast: Label
## Tipo de nó do palco quando a luta não vem de uma Descida (teste e depuração); -1 é a praça comum.
var stage_kind: int = -1
var _timeline: HBoxContainer
var _enemy_shape: VisualTheme.PortraitCanvas
var _player_shape: VisualTheme.PortraitCanvas
var _enemy_name: Label
var _enemy_hp_bar: ProgressBar
var _enemy_hp_label: Label
var _intent_panel: PanelContainer
var _intent_style: StyleBoxFlat
var _ticker: Label
var _ticker_tween: Tween
var _intent_icon: Label
var _intent_detail: Label
var _log_label: Label
var _player_hp_bar: ProgressBar
var _player_mp_bar: ProgressBar
var _player_stats: Label
var _player_effects: Label
var _buttons: Dictionary = {}
var _drawers: Dictionary = {}
var _drawer_tabs: Dictionary = {}
var _open_drawer: String = ""
var _sheet: PanelContainer
var _sheet_holder: VBoxContainer
## Folha das gavetas: altura e distância do rodapé (acima da fileira de abas).
const SHEET_HEIGHT: float = 270.0
const SHEET_BOTTOM: float = 78.0
var _selected_action: String = ""
## Skill, item e Fugir pedem um segundo toque (D-UI-1); desligado nos testes e na depuração 2D.
var confirm_taps: bool = DisplayServer.get_name() != "headless"
var _coin_overlay: PanelContainer
var _coin_medallion: VisualTheme.CoinMedallion
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
	theme = DarkTheme.build()
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
	var mut: String = session.run.current_node().mutation if session.run != null and session.run.current_node() != null else ""
	_enemy_shape.configure_enemy(session.enemy_id, mut)
	_enemy_shape.modulate = Color.WHITE
	_enemy_shape.custom_minimum_size = Vector2(150, 150) if session.is_boss() else Vector2(110, 110)
	if _stage != null:
		_stage.time_scale = time_scale
		_stage.setup(session.enemy_id, session.run.current_node().kind if session.run != null and session.run.current_node() != null else stage_kind, mut)
	var current_power: float = session.run.power if session.run != null else _power
	_player_shape.configure_player(current_power)
	if session.enemy_id == "bell_warden" and time_scale > 0.0:
		SoundFx.play(self, "bell")
	_enemy_hp_bar.max_value = session.combat.enemy.stats.max_hp
	_player_hp_bar.max_value = session.combat.player.stats.max_hp
	_player_mp_bar.max_value = session.combat.player.stats.max_mp
	for index: int in RunRules.MAX_SKILLS:
		var skill_button: Button = _buttons["skill_%d" % index]
		skill_button.visible = index < session.skills.size()
		if index < session.skills.size():
			skill_button.text = session.skill_label(index)
			_style_icon_button(skill_button, IconRegistry.texture_for("skill", session.skills[index].id))
	_refresh_bars()
	for bar: ProgressBar in [_enemy_hp_bar, _player_hp_bar, _player_mp_bar]:
		(bar as TrailBar).snap()


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
		"ether":
			events = session.use_ether()
		"flee":
			events = session.flee()
		"skill_0", "skill_1", "skill_2", "skill_3", "skill_4":
			events = session.use_skill(int(action.substr(6)))
	if events.is_empty():
		return
	await _play(events)


func _play(events: Array[CombatEvent]) -> void:
	_busy = true
	_refresh_buttons()
	for event: CombatEvent in events:
		# Golpe da Bibiana: caminha até o inimigo e só aplica o dano no instante do impacto (TASK-071).
		if _stage != null and _is_player_swing(event):
			await _stage.hero_strike(event.type == CombatEvent.Type.DAMAGE and event.flag)
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
		if time_scale > 0.0:
			SoundFx.play(self, "victory" if result == Combat.Outcome.VICTORY else "defeat")
		if _stage != null and time_scale > 0.0 and result != Combat.Outcome.FLED:
			if result == Combat.Outcome.VICTORY:
				_stage.hero_victory()
			else:
				_stage.hero_defeat()
			await _wait(0.8)
		if session.run != null:
			_open_result(session.outcome_text())
		else:
			_open_menu(session.outcome_text())
		fight_finished.emit(result)


## Verdadeiro para o golpe da Bibiana no inimigo (acerto ou erro); não conta veneno, reflexo nem espinhos.
func _is_skill_id(label: String) -> bool:
	for skill: CombatSkill in session.skills:
		if skill.id == label:
			return true
	return false


func _is_player_swing(event: CombatEvent) -> bool:
	if event.side == Combatant.PLAYER:
		return false
	if event.type == CombatEvent.Type.MISS:
		return true
	return event.type == CombatEvent.Type.DAMAGE and not ["poison", "reflect", "thorny"].has(event.label)


## Atualiza o estado da tela a partir do evento, sem consultar regras.
func _apply(event: CombatEvent) -> void:
	match event.type:
		CombatEvent.Type.INTENT:
			_show_intent(event.label, event.extra)
		CombatEvent.Type.ACTION:
			if event.side == Combatant.PLAYER:
				_player_mp -= event.value
				if _stage != null:
					_stage.set_defending(event.label == "defend")
					if event.label != "defend" and event.label != "attack" and event.label != "flee" and not _is_skill_id(event.label):
						_stage.hero_use_item()
				if event.label == "defend" and time_scale > 0.0:
					SoundFx.play(self, "defend")
			else:
				_intent_icon.text = "..."
				_intent_detail.text = ""
				_set_intent_tone(COLOR_CALM)
		CombatEvent.Type.DAMAGE:
			var on_enemy: bool = event.side != Combatant.PLAYER
			if _stage != null:
				if not on_enemy and not ["poison", "reflect", "thorny"].has(event.label):
					_stage.play(true, "attack")
				_stage.play(on_enemy, "hit")
				if not on_enemy:
					_stage.hero_react(true)
				_stage.hit_stop(0.1 if event.flag else 0.07)
			if on_enemy:
				_enemy_hp = event.extra
			else:
				_player_hp = event.extra
			if time_scale > 0.0:
				SoundFx.play(self, "crit" if event.flag else "hit")
			_pop_text("-%d%s" % [event.value, " CRÍTICO!" if event.flag else ""], COLOR_COIN if event.flag else COLOR_DANGER, on_enemy, 44 if event.flag else 30)
			if on_enemy and event.extra <= 0:
				_play_defeat()
		CombatEvent.Type.MISS:
			_pop_text("Errou", COLOR_CALM, event.side != Combatant.PLAYER)
		CombatEvent.Type.DISEASE:
			_player_hp_bar.max_value = session.combat.player.stats.max_hp
			_player_hp = mini(_player_hp, int(_player_hp_bar.max_value))
			_pop_text(Diseases.display_name(event.label), COLOR_DEBUFF, false, 36)
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
func _pop_text(text: String, color: Color, on_enemy: bool, size: int = 30) -> void:
	if time_scale <= 0.0 or not is_inside_tree():
		return
	var target: Control = _enemy_shape if on_enemy else _player_shape
	var label: Label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 6)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.z_index = 50
	add_child(label)
	label.position = target.global_position - global_position + Vector2(target.size.x * 0.3, -10)
	if _stage != null:
		label.position = _stage.global_position - global_position + _stage.screen_pos(on_enemy) - Vector2(40, 30)
	var tween: Tween = create_tween().set_parallel(true)
	tween.tween_property(label, "position:y", label.position.y - 70.0, 0.9 * time_scale)
	tween.tween_property(label, "modulate:a", 0.0, 0.9 * time_scale).set_delay(0.3 * time_scale)
	tween.chain().tween_callback(label.queue_free)


## Abate do inimigo (ADR-0021): clareia, some e mostra "Derrotado!". Sem tempo, só some.
func _play_defeat() -> void:
	if _stage != null:
		_stage.play(true, "death")
	if time_scale <= 0.0 or not is_inside_tree():
		_enemy_shape.modulate = Color(1, 1, 1, 0.25)
		return
	_pop_text("Derrotado!", COLOR_COIN, true)
	var tween: Tween = create_tween()
	tween.tween_property(_enemy_shape, "modulate", Color(3, 3, 3, 1), 0.12 * time_scale)
	tween.tween_property(_enemy_shape, "modulate", Color(1, 1, 1, 0.0), 0.5 * time_scale)


## Cor de ameaça do aviso do inimigo: na borda do cartão do palco (ou no painel inteiro, sem palco).
func _set_intent_tone(color: Color) -> void:
	if _intent_style != null:
		_intent_style.border_color = color
	elif _intent_panel != null:
		_intent_panel.self_modulate = color


func _show_intent(move_id: String, reason: int = 0) -> void:
	var view: Dictionary = session.intent_view(move_id, reason)
	var icon_text: String = str(view["icon"])
	var name_text: String = str(view["name"])
	# "ATAQUE  Ataque" era texto duplicado (IDENTIDADE-VISUAL §A.1): só repete se o nome diz algo novo.
	_intent_icon.text = icon_text if icon_text.to_lower() == name_text.to_lower() else "%s  %s" % [icon_text, name_text]
	_intent_detail.text = str(view["detail"])
	_intent_detail.visible = not _intent_detail.text.is_empty()
	if bool(view["coin"]):
		_set_intent_tone(COLOR_COIN)
	elif bool(view["debuff"]):
		_set_intent_tone(COLOR_DEBUFF)
	elif bool(view["dangerous"]):
		_set_intent_tone(COLOR_DANGER)
	else:
		_set_intent_tone(COLOR_CALM)


## Lance da moeda (GDD §7, ADR-0014): o jogador escolhe o lado vendo a chance, a moeda
## gira por 1,2 s e o resultado mostra o lado em que caiu.
func _show_coin(event: CombatEvent) -> void:
	_coin_overlay.visible = true
	if _stage != null:
		_stage.set_focus(true)
	coin_focus.emit(true)
	if _coin_medallion != null:
		_coin_medallion.show_call_prompt()
	var odds: String = "Moeda da Sorte: se errar, rejoga!" if session.is_lucky_armed() else ""
	var called: int = await _ask_call(event.value, odds)
	session.coin_call = called
	if _coin_medallion != null:
		_coin_medallion.set_side(called)
		_coin_medallion.spinning = true
	if time_scale > 0.0:
		SoundFx.play(self, "coin_tick")
	_coin_label.text = "Você escolheu %s\nA moeda gira...\n%s" % [CombatTexts.side_name(called), odds]
	await _wait(COIN_DELAY)
	var landed_side: int = called if event.flag else (CoinRules.TAILS if called == CoinRules.HEADS else CoinRules.HEADS)
	if _coin_medallion != null:
		_coin_medallion.set_side(landed_side)
	if time_scale > 0.0:
		SoundFx.play(self, "coin_heads" if event.flag else "coin_tails")
	var again: String = "\nA Moeda da Sorte rejogou o lance!" if event.extra == 1 else ""
	_coin_label.text = "Você escolheu %s\n%s%s" % [CombatTexts.side_name(called),
		CombatTexts.coin_result(called, event.flag), again]
	await _wait(EVENT_DELAY * 2.0)
	_coin_overlay.visible = false
	if _stage != null:
		_stage.set_focus(false)
	coin_focus.emit(false)


## Pede o lado ao jogador e devolve o escolhido. Sem tempo (testes) ou fora da árvore,
## usa [member auto_call] em vez de esperar o botão.
func _ask_call(chance: int, odds: String = "") -> int:
	if time_scale <= 0.0 or not is_inside_tree():
		return auto_call
	_coin_label.text = "Escolha o lado da moeda\n%s" % odds
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
	_set_bar_text(_enemy_hp_bar, "%d / %d" % [_enemy_hp, int(_enemy_hp_bar.max_value)])
	_enemy_hp_label.text = "HP %d / %d" % [_enemy_hp, int(_enemy_hp_bar.max_value)]
	_player_hp_bar.value = _player_hp
	_set_bar_text(_player_hp_bar, "HP %d / %d" % [_player_hp, int(_player_hp_bar.max_value)])
	_player_mp_bar.value = _player_mp
	_set_bar_text(_player_mp_bar, "MP %d / %d" % [_player_mp, int(_player_mp_bar.max_value)])
	_fill_status_icons()
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
	if _timeline_col != null:
		_fill_timeline_column()
		return
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
	if session != null:
		(_buttons["attack"] as Button).text = "Atacar" if _stage != null else "Atacar\n" + session.attack_hint()
	(_buttons["defend"] as Button).disabled = not can_go
	for index: int in RunRules.MAX_SKILLS:
		var skill_ready: bool = can_go and session.can_use_skill(index)
		var skill_button: Button = _buttons["skill_%d" % index]
		skill_button.disabled = not skill_ready
		if session != null and index < session.skills.size():
			skill_button.text = session.skill_label(index) if _stage != null else "%s\n%s" % [session.skill_label(index), session.skill_hint(index)]
			skill_button.tooltip_text = session.skill_tip(index)
	var potion: Button = _buttons["potion"]
	potion.disabled = not (can_go and session.can_use_potion())
	if session != null:
		potion.text = session.potion_label()
	var ether: Button = _buttons["ether"]
	ether.disabled = not (can_go and session != null and session.can_use_ether())
	if session != null:
		ether.text = session.ether_label()
	var flee: Button = _buttons["flee"]
	flee.disabled = not (can_go and session.can_flee())
	flee.tooltip_text = "Moeda: acertar o lado foge"
	var luck: Button = _buttons["luck"]
	var coins: int = session.lucky_coins() if session != null else 0
	luck.disabled = not (can_go and coins > 0)
	luck.text = "Moeda da Sorte (%d)%s" % [coins, "  ARMADA" if session != null and session.is_lucky_armed() else ""]
	if _forecast != null and session != null and _forecast.text.is_empty():
		_set_forecast(_forecast_for("attack"))


## Última linha do registro como letreiro sobre o palco por 2,2 s (Estudo 3.2.1, UI-C4): sem painel fixo.
func _show_ticker(line: String) -> void:
	if _ticker == null:
		return
	_ticker.text = line
	_ticker.modulate.a = 1.0
	if time_scale <= 0.0 or not is_inside_tree():
		return
	if _ticker_tween != null:
		_ticker_tween.kill()
	_ticker_tween = create_tween()
	_ticker_tween.tween_interval(2.2 * time_scale)
	_ticker_tween.tween_property(_ticker, "modulate:a", 0.0, 0.4)


func _push_log(line: String) -> void:
	_log.append(line)
	while _log.size() > LOG_LINES:
		_log.remove_at(0)
	_log_label.text = "\n".join(_log)
	_show_ticker(line)


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
	_enemy_shape = VisualTheme.PortraitCanvas.new()
	_enemy_shape.color = COLOR_ENEMY
	_enemy_shape.custom_minimum_size = Vector2(110, 110)
	_enemy_shape.configure_enemy("infected_citizen")
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

	if use_stage:
		_stage = Combat3DStage.new()
		_stage.custom_minimum_size = Vector2(0, 330)
		_stage.size_flags_vertical = Control.SIZE_EXPAND_FILL
		_stage.size_flags_stretch_ratio = 1.0
		column.add_child(_stage)
		_enemy_shape.visible = false
	_intent_panel = PanelContainer.new()
	_intent_panel.add_theme_stylebox_override("panel", _box(Color.WHITE))
	_set_intent_tone(COLOR_CALM)
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
	_player_shape = VisualTheme.PortraitCanvas.new()
	_player_shape.color = COLOR_PLAYER
	_player_shape.custom_minimum_size = Vector2(80, 80)
	_player_shape.configure_player(1.0)
	_player_shape.visible = not use_stage
	player_row.add_child(_player_shape)
	var player_info: VBoxContainer = VBoxContainer.new()
	player_info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	player_row.add_child(player_info)
	_player_stats = Label.new()
	player_info.add_child(_player_stats)
	var bars_row: HBoxContainer = HBoxContainer.new()
	bars_row.add_theme_constant_override("separation", 8)
	player_info.add_child(bars_row)
	_player_hp_bar = _bar(Color(0.3, 0.7, 0.35))
	_player_hp_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bars_row.add_child(_player_hp_bar)
	_player_mp_bar = _bar(Color(0.3, 0.45, 0.85))
	_player_mp_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bars_row.add_child(_player_mp_bar)
	_player_effects = Label.new()
	_player_effects.add_theme_font_size_override("font_size", 16)
	player_info.add_child(_player_effects)

	# Ações na zona do polegar (ADR-0044, D-UI-1 e D-UI-2): Atacar e Defender sempre à vista, em
	# um toque; Habilidades, Itens e Tático ficam em gavetas de abas, e o que gasta recurso pede
	# um segundo toque para confirmar (celular não tem hover).
	var grid: GridContainer = GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	column.add_child(grid)
	var tab_row: HBoxContainer = HBoxContainer.new()
	tab_row.add_theme_constant_override("separation", 6)
	column.add_child(tab_row)
	# Gavetas como folha sobreposta (TASK-067, crítica do diretor): sobem sobre o log e as ações sem
	# redimensionar o palco, que fica fixo.
	_sheet = PanelContainer.new()
	var sheet_style: StyleBoxFlat = StyleBoxFlat.new()
	sheet_style.bg_color = Color(0.082, 0.09, 0.11, 1.0)
	sheet_style.border_color = Color(0.54, 0.42, 0.23)
	sheet_style.set_border_width_all(2)
	sheet_style.set_corner_radius_all(10)
	sheet_style.set_content_margin_all(10)
	_sheet.add_theme_stylebox_override("panel", sheet_style)
	_sheet.anchor_left = 0.0
	_sheet.anchor_right = 1.0
	_sheet.anchor_top = 1.0
	_sheet.anchor_bottom = 1.0
	_sheet.offset_left = 10.0
	_sheet.offset_right = -10.0
	_sheet.offset_bottom = -SHEET_BOTTOM
	_sheet.offset_top = -SHEET_BOTTOM - SHEET_HEIGHT
	_sheet.visible = false
	var sheet_box: VBoxContainer = VBoxContainer.new()
	sheet_box.add_theme_constant_override("separation", 8)
	_sheet.add_child(sheet_box)
	_sheet_holder = sheet_box
	add_child(_sheet)
	for tab: String in DRAWER_ORDER:
		var tab_button: Button = Button.new()
		tab_button.text = str(DRAWER_TITLES[tab])
		tab_button.toggle_mode = true
		tab_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		tab_button.custom_minimum_size = Vector2(0, 52)
		tab_button.add_theme_font_size_override("font_size", 15)
		tab_button.pressed.connect(_select_drawer.bind(tab))
		tab_row.add_child(tab_button)
		_drawer_tabs[tab] = tab_button
		var drawer: GridContainer = GridContainer.new()
		drawer.columns = 1 if tab == "skills" else 2
		drawer.add_theme_constant_override("h_separation", 8)
		drawer.add_theme_constant_override("v_separation", 8)
		drawer.visible = false
		_sheet_holder.add_child(drawer)
		_drawers[tab] = drawer
	for entry: Array in [["attack", "Atacar"], ["defend", "Defender"], ["skill_0", "Skill"], ["skill_1", "Skill"],
			["skill_2", "Skill"], ["skill_3", "Skill"], ["skill_4", "Skill"], ["potion", "Poção"], ["ether", "Éter Sujo"],
			["luck", "Moeda da Sorte (0)"], ["flee", "Fugir"], ["speed", "Velocidade 1x"]]:
		var action: String = str(entry[0])
		var main_action: bool = action == "attack" or action == "defend"
		var button: Button = Button.new()
		button.text = str(entry[1])
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.custom_minimum_size = Vector2(0, (62 if use_stage else 76) if main_action else (64 if action.begins_with("skill_") else 56))
		button.add_theme_font_size_override("font_size", 16)
		var ui_icon: Texture2D = IconRegistry.texture_for("ui", action if action != "luck" else "luck")
		if action == "potion":
			ui_icon = IconRegistry.texture_for("ui", "potion")
		if ui_icon != null:
			_style_icon_button(button, ui_icon)
		if action == "speed":
			button.pressed.connect(_toggle_speed)
		elif action == "luck":
			button.pressed.connect(_toggle_lucky)
		else:
			button.pressed.connect(_on_action_pressed.bind(action))
		(grid if main_action else _drawers[_drawer_of(action)]).add_child(button)
		_buttons[action] = button

	_coin_overlay = _overlay()
	var coin_box: VBoxContainer = VBoxContainer.new()
	coin_box.add_theme_constant_override("separation", 16)
	coin_box.alignment = BoxContainer.ALIGNMENT_CENTER
	_coin_overlay.add_child(coin_box)
	var coin_center: CenterContainer = CenterContainer.new()
	coin_box.add_child(coin_center)
	_coin_medallion = VisualTheme.CoinMedallion.new()
	coin_center.add_child(_coin_medallion)
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
	if _stage != null:
		_stage.set_focus(false)
	coin_focus.emit(false)

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
	if _stage != null:
		var forecast_panel: PanelContainer = _move_hud_into_stage(log_panel)
		column.move_child(forecast_panel, player_row.get_index() + 1)
	_refresh_buttons()


## Resultado da luta da Descida: só o título e "Continuar".
func _open_result(title: String) -> void:
	_menu_title.text = title
	for control: Control in _menu_debug:
		control.visible = false
	_continue.visible = true
	_menu.visible = true


## Gaveta (aba) de cada ação que não é Atacar nem Defender.
func _drawer_of(action: String) -> String:
	if action.begins_with("skill_"):
		return "skills"
	if action == "potion" or action == "ether" or action == "luck":
		return "items"
	return "tactical"


## Abre uma aba da gaveta; tocar na aberta de novo a recolhe (devolve altura ao palco).
func _select_drawer(tab: String) -> void:
	var was_open: bool = _open_drawer == tab
	_open_drawer = "" if was_open else tab
	for tab_name: String in DRAWER_ORDER:
		(_drawers[tab_name] as GridContainer).visible = tab_name == _open_drawer
		(_drawer_tabs[tab_name] as Button).button_pressed = tab_name == _open_drawer
	_sheet.visible = not _open_drawer.is_empty()
	_clear_selection()


## Toque numa ação. Atacar e Defender executam direto; skill, item e Fugir pedem confirmação
## (primeiro toque seleciona e mostra a previsão, o segundo executa) quando [member confirm_taps].
func _on_action_pressed(action: String) -> void:
	if not confirm_taps or action == "attack" or action == "defend":
		perform(action)
		return
	if _selected_action == action:
		_clear_selection()
		perform(action)
		return
	_clear_selection()
	_selected_action = action
	(_buttons[action] as Button).modulate = Color(1.35, 1.2, 0.85)
	_set_forecast(_forecast_for(action) + "   (toque de novo para confirmar)")


func _clear_selection() -> void:
	if not _selected_action.is_empty() and _buttons.has(_selected_action):
		(_buttons[_selected_action] as Button).modulate = Color.WHITE
		if _forecast != null and session != null:
			_set_forecast(_forecast_for("attack"))
	_selected_action = ""


## Arma ou desarma a Moeda da Sorte para o próximo lance errado (ADR-0026).
func _toggle_lucky() -> void:
	if session != null and not _busy and session.can_act():
		session.toggle_lucky_coin()
		_refresh_buttons()


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


## Barra com moldura de bronze e o número dentro (TASK-043).
func _bar(color: Color) -> ProgressBar:
	var bar: ProgressBar = TrailBar.new()
	bar.custom_minimum_size = Vector2(0, 22)
	bar.show_percentage = false
	var fill: StyleBoxFlat = StyleBoxFlat.new()
	fill.bg_color = color
	fill.set_corner_radius_all(3)
	fill.border_color = color.lightened(0.35)
	fill.border_width_top = 2
	var back: StyleBoxFlat = StyleBoxFlat.new()
	back.bg_color = Color(0.04, 0.04, 0.06)
	back.border_color = Color(0.42, 0.35, 0.24)
	back.set_border_width_all(1)
	back.set_corner_radius_all(3)
	bar.add_theme_stylebox_override("fill", fill)
	bar.add_theme_stylebox_override("background", back)
	var text: Label = Label.new()
	text.name = "BarText"
	text.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	text.add_theme_font_size_override("font_size", 13)
	text.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	text.add_theme_constant_override("outline_size", 4)
	text.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bar.add_child(text)
	return bar


func _set_bar_text(bar: ProgressBar, label: String) -> void:
	var text: Label = bar.get_node_or_null("BarText") as Label
	if text != null:
		text.text = label


func _box(color: Color) -> StyleBoxFlat:
	var box: StyleBoxFlat = StyleBoxFlat.new()
	box.bg_color = color
	box.set_corner_radius_all(6)
	box.set_content_margin_all(10)
	return box


## No palco 3D, a intenção do inimigo fica numa faixa no topo da cena e o registro da luta numa
## faixa embaixo (como o painel de Fear & Hunger), liberando altura para os personagens.
func _move_hud_into_stage(log_panel: PanelContainer) -> PanelContainer:
	var column: Control = _stage.get_parent() as Control
	_intent_panel.get_parent().remove_child(_intent_panel)
	_stage.add_child(_intent_panel)
	# O registro fixo some: a última linha vira um letreiro de 2,2 s no pé do palco.
	log_panel.visible = false
	_ticker = Label.new()
	_ticker.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	_ticker.offset_top = -44.0
	_ticker.offset_bottom = -8.0
	_ticker.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_ticker.add_theme_font_size_override("font_size", 17)
	_ticker.add_theme_color_override("font_color", Color(0.9, 0.86, 0.76))
	_ticker.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.95))
	_ticker.add_theme_constant_override("outline_size", 5)
	_ticker.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ticker.modulate.a = 0.0
	_stage.add_child(_ticker)
	_timeline.visible = false
	_status_enemy = HBoxContainer.new()
	_status_enemy.position = Vector2(300, 68)
	_stage.add_child(_status_enemy)
	_status_player = HBoxContainer.new()
	_status_player.position = Vector2(8, 252)
	_stage.add_child(_status_player)
	_timeline_col = VBoxContainer.new()
	_timeline_col.add_theme_constant_override("separation", 3)
	_timeline_col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_timeline_col.position = Vector2(4, 56)
	_stage.add_child(_timeline_col)
	var forecast_panel: PanelContainer = PanelContainer.new()
	forecast_panel.add_theme_stylebox_override("panel", _box(Color(0.082, 0.09, 0.11, 0.92)))
	_forecast = Label.new()
	_forecast.add_theme_font_size_override("font_size", 16)
	_forecast.add_theme_color_override("font_color", Color(0.93, 0.84, 0.58))
	_forecast.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	forecast_panel.add_child(_forecast)
	column.add_child(forecast_panel)
	for action: String in _buttons.keys():
		var hover_button: Button = _buttons[action]
		hover_button.mouse_entered.connect(func() -> void: _set_forecast(_forecast_for(action)))
		hover_button.focus_entered.connect(func() -> void: _set_forecast(_forecast_for(action)))
	_intent_icon.add_theme_font_size_override("font_size", 20)
	_intent_detail.add_theme_font_size_override("font_size", 13)
	# Aviso do inimigo como cartão escuro com borda de ameaça (vermelho, ouro, roxo), não faixa cinza.
	_intent_style = StyleBoxFlat.new()
	_intent_style.bg_color = Color(0.027, 0.03, 0.043, 0.82)
	_intent_style.set_border_width_all(3)
	_intent_style.set_corner_radius_all(6)
	_intent_style.set_content_margin_all(8)
	_intent_style.border_color = COLOR_CALM
	_intent_panel.add_theme_stylebox_override("panel", _intent_style)
	_intent_panel.self_modulate = Color.WHITE
	_intent_icon.add_theme_color_override("font_color", Color(0.92, 0.9, 0.84))
	_intent_detail.add_theme_color_override("font_color", Color(0.72, 0.74, 0.8))
	# As barras já trazem os números e os ícones de status ficam no palco: sem texto duplicado.
	_player_stats.visible = false
	_enemy_hp_label.visible = false
	_player_effects.visible = false
	return forecast_panel


## Prende o aviso do inimigo sobre a cabeça dele (Estudo 3.2.1, UI-C3), sem sair do palco.
func _anchor_intent() -> void:
	if _stage == null or _intent_panel == null or _intent_panel.get_parent() != _stage:
		return
	var head: Vector2 = _stage.head_screen_pos()
	var panel_size: Vector2 = _intent_panel.get_combined_minimum_size()
	_intent_panel.size = panel_size
	var x: float = clampf(head.x - panel_size.x * 0.5, 8.0, maxf(_stage.size.x - panel_size.x - 8.0, 8.0))
	var y: float = clampf(head.y - panel_size.y - 10.0, 8.0, maxf(_stage.size.y - panel_size.y - 8.0, 8.0))
	_intent_panel.position = Vector2(x, y)


func _process(_delta: float) -> void:
	_anchor_intent()


## Coluna de retratos numerados com a ordem dos próximos turnos, à esquerda do palco (FFT):
## moldura azul para a Bibiana e vermelha para o inimigo.
func _fill_timeline_column() -> void:
	for child: Node in _timeline_col.get_children():
		child.queue_free()
	if session == null or session.is_over():
		return
	var order: Array[int] = session.timeline(5)
	for index: int in order.size():
		var side: int = order[index]
		var chip: PanelContainer = PanelContainer.new()
		var box: StyleBoxFlat = StyleBoxFlat.new()
		box.bg_color = Color(0.05, 0.06, 0.09, 0.85)
		box.set_border_width_all(3 if index == 0 else 2)
		box.border_color = (Color(0.35, 0.55, 0.95) if side == Combatant.PLAYER else VisualTheme.COLOR_DANGER)
		if index == 0:
			box.border_color = box.border_color.lightened(0.35)
		box.set_content_margin_all(2)
		chip.add_theme_stylebox_override("panel", box)
		var row: HBoxContainer = HBoxContainer.new()
		row.add_theme_constant_override("separation", 2)
		chip.add_child(row)
		var number: Label = Label.new()
		number.text = str(index + 1)
		number.add_theme_font_size_override("font_size", 14)
		number.add_theme_color_override("font_color", Color(0.9, 0.9, 0.95))
		row.add_child(number)
		var portrait: TextureRect = TextureRect.new()
		portrait.texture = _stage.portrait(side != Combatant.PLAYER) if _stage != null else null
		portrait.custom_minimum_size = Vector2(46, 46)
		portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		portrait.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		row.add_child(portrait)
		_timeline_col.add_child(chip)


## Painel de previsão (FFT): dano, acerto e crítico da ação sob o dedo, entre os dois lados.
func _set_forecast(text: String) -> void:
	if _forecast != null:
		_forecast.text = text


func _forecast_for(action: String) -> String:
	if session == null:
		return ""
	if action == "attack":
		return "Atacar   " + session.attack_hint()
	if action.begins_with("skill_"):
		var index: int = int(action.trim_prefix("skill_"))
		if index < session.skills.size():
			return "%s   %s" % [session.skill_label(index), session.skill_hint(index)]
	return str((_buttons[action] as Button).text).replace("\n", "   ")


## Botão de ação com ícone pequeno à esquerda do texto (TASK-043).
func _style_icon_button(button: Button, icon: Texture2D) -> void:
	button.icon = icon
	button.expand_icon = true
	button.icon_alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.add_theme_constant_override("icon_max_width", 30)
	button.add_theme_constant_override("h_separation", 10)
	button.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST


## Ícones dos efeitos ativos sobre os personagens (TASK-043): o do inimigo no alto do palco, o da
## Bibiana embaixo à esquerda. Sem palco 3D os efeitos ficam só em texto.
func _fill_status_icons() -> void:
	if _status_enemy == null or _status_player == null:
		return
	for entry: Array in [[_status_enemy, Combatant.ENEMY], [_status_player, Combatant.PLAYER]]:
		var row: HBoxContainer = entry[0]
		for child: Node in row.get_children():
			child.queue_free()
		for label: String in _effects[int(entry[1])]:
			var tex: Texture2D = IconRegistry.texture_for("effect", label)
			if tex == null:
				continue
			var icon: TextureRect = TextureRect.new()
			icon.texture = tex
			icon.custom_minimum_size = Vector2(30, 30)
			icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			icon.tooltip_text = CombatTexts.effect_name(label)
			row.add_child(icon)
