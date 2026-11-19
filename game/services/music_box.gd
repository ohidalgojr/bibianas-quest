class_name MusicBox
extends Node
## Música de fundo em laço com troca suave entre faixas e "silêncio" antes do lance da moeda
## (GDD §19, TASK-039). As faixas são CC0 do OpenGameArt (`assets/LICENSES.md`). Em headless não
## cria tocadores: só guarda a faixa atual, para os testes.

const BASE: String = "res://assets/opengameart/ambient_music/"
const TRACKS: Dictionary = {
	"map": BASE + "map.ogg",
	"combat": BASE + "combat.ogg",
	"boss": BASE + "boss.ogg",
	"camp": BASE + "camp.ogg",
}
const VOLUME_DB: float = -14.0
const SILENT_DB: float = -60.0
const FADE_SECONDS: float = 1.2

var current: String = ""
var ducked: bool = false
var enabled: bool = DisplayServer.get_name() != "headless"

var _player: AudioStreamPlayer
var _tween: Tween


func play_track(track: String) -> void:
	if track == current:
		return
	current = track
	if not enabled:
		return
	if not TRACKS.has(track):
		_fade_to(SILENT_DB, true)
		return
	var stream: AudioStream = load(TRACKS[track] as String) as AudioStream
	if stream is AudioStreamOggVorbis:
		(stream as AudioStreamOggVorbis).loop = true
	if _player == null:
		_player = AudioStreamPlayer.new()
		_player.volume_db = SILENT_DB
		add_child(_player)
	var fresh: bool = _player.stream == null or not _player.playing
	if _tween != null:
		_tween.kill()
	_tween = create_tween()
	if not fresh:
		_tween.tween_property(_player, "volume_db", SILENT_DB, FADE_SECONDS * 0.5)
	_tween.tween_callback(func() -> void:
		_player.stream = stream
		_player.play())
	_tween.tween_property(_player, "volume_db", SILENT_DB if ducked else VOLUME_DB, FADE_SECONDS)


## Silêncio proposital antes de golpes de moeda: a música some e volta depois.
func duck(on: bool) -> void:
	ducked = on
	if enabled and _player != null:
		_fade_to(SILENT_DB if on else VOLUME_DB, false)


func _fade_to(db: float, stop_after: bool) -> void:
	if _player == null:
		return
	if _tween != null:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(_player, "volume_db", db, FADE_SECONDS * 0.6)
	if stop_after:
		_tween.tween_callback(_player.stop)
