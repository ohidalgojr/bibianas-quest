class_name AudioSettings
extends RefCounted
## Preferência de som do jogador (TASK-050): mudo ou não, lembrada em `user://settings.cfg`.
## Mudo silencia o bus Master (música, ambiente e efeitos) e liga `SoundFx.muted`.

const FILE_NAME: String = "settings.cfg"
const SECTION: String = "audio"

static var muted: bool = false


## Lê a preferência salva (em `dir`) e aplica; sem arquivo, o som fica ligado.
static func load_and_apply(dir: String = "user://") -> void:
	var config: ConfigFile = ConfigFile.new()
	if config.load(dir + FILE_NAME) == OK:
		muted = bool(config.get_value(SECTION, "muted", false))
	apply()


## Liga ou desliga o mudo, aplica e salva.
static func set_muted(value: bool, dir: String = "user://") -> void:
	muted = value
	apply()
	var config: ConfigFile = ConfigFile.new()
	config.load(dir + FILE_NAME)
	config.set_value(SECTION, "muted", muted)
	config.save(dir + FILE_NAME)


static func apply() -> void:
	SoundFx.muted = muted
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), muted)
