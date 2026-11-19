class_name SoundFx
extends RefCounted
## Sintetizador procedural de efeitos sonoros em código (GDD §7, §13, §19, TASK-031, ADR-0035):
## gera buffers AudioStreamWAV (PCM 16-bit mono, 22050 Hz) sob demanda e mantém cache em memória,
## sem depender de arquivos .wav/.ogg externos.

const SAMPLE_RATE: int = 22050
const CUES: Array[String] = [
	"coin_tick",
	"coin_heads",
	"coin_tails",
	"hit",
	"crit",
	"defend",
	"bell",
	"campfire",
	"step",
	"victory",
	"defeat",
	"rain_loop",
	"fire_loop",
	"thunder",
]

## Sons em laço (ambiente de fundo).
const LOOPS: Array[String] = ["rain_loop", "fire_loop"]

static var muted: bool = false
static var _cache: Dictionary = {}


static func stream_for(cue: String) -> AudioStreamWAV:
	if _cache.has(cue):
		return _cache[cue]
	var wav: AudioStreamWAV = _synthesize(cue)
	if wav != null and LOOPS.has(cue):
		wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
		wav.loop_begin = 0
		wav.loop_end = wav.data.size() / 2
	_cache[cue] = wav
	return wav


static func play(host: Node, cue: String, volume_db: float = -6.0) -> bool:
	if muted or host == null or not host.is_inside_tree():
		return false
	if DisplayServer.get_name() == "headless":
		return false
	var stream: AudioStreamWAV = stream_for(cue)
	if stream == null:
		return false
	var player: AudioStreamPlayer = host.get_node_or_null("_SoundFxPlayer") as AudioStreamPlayer
	if player == null:
		player = AudioStreamPlayer.new()
		player.name = "_SoundFxPlayer"
		host.add_child(player)
	player.stream = stream
	player.volume_db = volume_db
	player.play()
	return true


static func _synthesize(cue: String) -> AudioStreamWAV:
	match cue:
		"coin_tick":
			return _make_wav(0.09, func(t: float) -> float:
				var env: float = exp(-t * 42.0)
				return (sin(TAU * 2400.0 * t) * 0.65 + sin(TAU * 3650.0 * t) * 0.35) * env)
		"coin_heads":
			return _make_wav(0.32, func(t: float) -> float:
				var env: float = exp(-t * 9.0)
				var f1: float = 880.0 if t < 0.11 else 1320.0
				return (sin(TAU * f1 * t) * 0.6 + sin(TAU * f1 * 2.0 * t) * 0.3) * env)
		"coin_tails":
			return _make_wav(0.38, func(t: float) -> float:
				var env: float = exp(-t * 7.5)
				var freq: float = lerpf(240.0, 125.0, t / 0.38)
				return (sin(TAU * freq * t) * 0.7 + sin(TAU * (freq * 1.41) * t) * 0.3) * env)
		"hit":
			return _make_wav(0.14, func(t: float) -> float:
				var env: float = exp(-t * 24.0)
				var drop: float = lerpf(190.0, 65.0, t / 0.14)
				var noise: float = sin(t * 14321.0) * cos(t * 7919.0)
				return (sin(TAU * drop * t) * 0.6 + noise * 0.4) * env)
		"crit":
			return _make_wav(0.24, func(t: float) -> float:
				var env: float = exp(-t * 14.0)
				var drop: float = lerpf(320.0, 80.0, t / 0.24)
				var ring: float = sin(TAU * 1480.0 * t) * exp(-t * 18.0)
				return (sin(TAU * drop * t) * 0.65 + ring * 0.35) * env)
		"defend":
			return _make_wav(0.18, func(t: float) -> float:
				var env: float = exp(-t * 18.0)
				return (sin(TAU * 420.0 * t) * 0.55 + sin(TAU * 790.0 * t) * 0.45) * env)
		"bell":
			return _make_wav(0.65, func(t: float) -> float:
				var env: float = exp(-t * 4.5)
				return (
					sin(TAU * 220.0 * t) * 0.50
					+ sin(TAU * 440.0 * t) * 0.25
					+ sin(TAU * 654.0 * t) * 0.15
					+ sin(TAU * 912.0 * t) * 0.10
				) * env)
		"campfire":
			return _make_wav(0.28, func(t: float) -> float:
				var env: float = exp(-t * 10.0)
				var crackle: float = sin(t * 9871.0) * sin(t * 3571.0)
				return (sin(TAU * 280.0 * t) * 0.35 + crackle * 0.65) * env)
		"step":
			return _make_wav(0.08, func(t: float) -> float:
				var env: float = exp(-t * 36.0)
				return (sin(TAU * 140.0 * t) * 0.7 + sin(t * 6151.0) * 0.3) * env)
		"rain_loop":
			var rain_state: Array[float] = [0.0]
			return _make_wav(4.0, func(t: float) -> float:
				var n: float = _noise(int(t * SAMPLE_RATE))
				rain_state[0] += (n - rain_state[0]) * 0.32
				var swell: float = 0.78 + 0.22 * sin(TAU * t / 4.0 * 2.0)
				return rain_state[0] * 0.55 * swell)
		"fire_loop":
			var fire_state: Array[float] = [0.0]
			return _make_wav(5.0, func(t: float) -> float:
				var index: int = int(t * SAMPLE_RATE)
				var n: float = _noise(index)
				fire_state[0] += (n - fire_state[0]) * 0.06
				var pop_slot: int = index / 2200
				var pop_age: float = float(index % 2200) / float(SAMPLE_RATE)
				var pop: float = 0.0
				if _noise(pop_slot * 7 + 3) > 0.82:
					pop = _noise(index * 3) * exp(-pop_age * 90.0) * 0.9
				return fire_state[0] * 0.9 + pop * 0.7)
		"thunder":
			var thunder_state: Array[float] = [0.0]
			return _make_wav(3.6, func(t: float) -> float:
				var n: float = _noise(int(t * SAMPLE_RATE))
				thunder_state[0] += (n - thunder_state[0]) * 0.025
				var env: float = minf(t / 0.12, 1.0) * exp(-t * 0.9) * (0.65 + 0.35 * sin(t * 9.0))
				return thunder_state[0] * 5.0 * env)
		"victory":
			return _make_wav(0.48, func(t: float) -> float:
				var env: float = exp(-t * 5.0)
				var note: float = 440.0 if t < 0.15 else (554.37 if t < 0.30 else 659.25)
				return (sin(TAU * note * t) * 0.65 + sin(TAU * note * 1.5 * t) * 0.25) * env)
		"defeat":
			return _make_wav(0.55, func(t: float) -> float:
				var env: float = exp(-t * 4.2)
				var note: float = 220.0 if t < 0.25 else 164.81
				return (sin(TAU * note * t) * 0.7 + sin(TAU * (note * 0.5) * t) * 0.3) * env)
		_:
			return _make_wav(0.08, func(t: float) -> float:
				return sin(TAU * 440.0 * t) * exp(-t * 30.0))


static func _make_wav(duration: float, generator: Callable) -> AudioStreamWAV:
	var sample_count: int = maxi(1, roundi(duration * SAMPLE_RATE))
	var bytes: PackedByteArray = PackedByteArray()
	bytes.resize(sample_count * 2)
	for i: int in sample_count:
		var t: float = float(i) / float(SAMPLE_RATE)
		var sample: float = clampf(float(generator.call(t)), -1.0, 1.0)
		var pcm: int = clampi(roundi(sample * 32767.0), -32768, 32767)
		if pcm < 0:
			pcm += 65536
		bytes[i * 2] = pcm & 0xFF
		bytes[i * 2 + 1] = (pcm >> 8) & 0xFF
	var wav: AudioStreamWAV = AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = SAMPLE_RATE
	wav.stereo = false
	wav.data = bytes
	return wav


## Ruído branco determinístico em [-1, 1] a partir do índice da amostra (sem aleatoriedade global).
static func _noise(index: int) -> float:
	var h: int = (index * 374761393 + 668265263) & 0x7fffffff
	h = ((h ^ (h >> 13)) * 1274126177) & 0x7fffffff
	return float(h % 20001) / 10000.0 - 1.0
