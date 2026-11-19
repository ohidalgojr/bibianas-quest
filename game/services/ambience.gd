class_name Ambience
extends Node
## Som ambiente por cima da música (TASK-042, GDD §19): chuva em laço, crepitar do fogo em laço e
## trovão ocasional. Tudo sintetizado por [SoundFx]. Em headless não cria tocadores. Quando o
## trovão cai, emite [signal lightning] para a tela dar o clarão (desligável em `GfxSettings`).

signal lightning

const RAIN_DB: float = -22.0
const FIRE_DB: float = -18.0
const THUNDER_DB: float = -10.0
const SILENT_DB: float = -70.0
const THUNDER_MIN_SECONDS: float = 22.0
const THUNDER_MAX_SECONDS: float = 48.0
const THUNDER_DELAY: float = 0.9

var mood: String = ""
var enabled: bool = DisplayServer.get_name() != "headless"

var _rain: AudioStreamPlayer
var _fire: AudioStreamPlayer
var _thunder: AudioStreamPlayer
var _timer: Timer


func _ready() -> void:
	if not enabled:
		return
	_rain = _loop_player("rain_loop")
	_fire = _loop_player("fire_loop")
	_thunder = AudioStreamPlayer.new()
	_thunder.stream = SoundFx.stream_for("thunder")
	_thunder.volume_db = THUNDER_DB
	add_child(_thunder)
	_timer = Timer.new()
	_timer.one_shot = true
	_timer.timeout.connect(_on_thunder_due)
	add_child(_timer)


func _loop_player(cue: String) -> AudioStreamPlayer:
	var player: AudioStreamPlayer = AudioStreamPlayer.new()
	player.stream = SoundFx.stream_for(cue)
	player.volume_db = SILENT_DB
	add_child(player)
	player.play()
	return player


## Clima sonoro de cada situação: "map", "combat" e "home" têm chuva e trovão; "camp" tem fogo; "" é silêncio.
func set_mood(new_mood: String) -> void:
	if new_mood == mood:
		return
	mood = new_mood
	if not enabled or _rain == null:
		return
	var rainy: bool = mood == "map" or mood == "combat" or mood == "home"
	_fade(_rain, RAIN_DB if rainy else SILENT_DB)
	_fade(_fire, FIRE_DB if mood == "camp" else SILENT_DB)
	if rainy:
		if _timer.is_stopped():
			_schedule_thunder()
	else:
		_timer.stop()


func _fade(player: AudioStreamPlayer, db: float) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(player, "volume_db", db, 1.5)


func _schedule_thunder() -> void:
	_timer.start(randf_range(THUNDER_MIN_SECONDS, THUNDER_MAX_SECONDS))


func _on_thunder_due() -> void:
	strike()
	if mood == "map" or mood == "combat" or mood == "home":
		_schedule_thunder()


## Relâmpago agora e trovão logo depois (o clarão vem antes do som, como na vida).
func strike() -> void:
	lightning.emit()
	if _thunder == null:
		return
	await get_tree().create_timer(THUNDER_DELAY).timeout
	_thunder.play()
