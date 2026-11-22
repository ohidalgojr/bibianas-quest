class_name Atmosphere
extends RefCounted
## Atmosfera comum às cenas 3D (TASK-055, ADR-0043, D-ART-1): luz ambiente baixa em azul-ardósia
## frio, neblina exponencial e a regra de que só a luz dirigida (lua, fogueira, lampião) revela
## a cena. Só apresentação.

## Energia da luz ambiente (o estudo pedia 0,40 a 0,52; era 0,72 a 0,85).
const AMBIENT_ENERGY: float = 0.38
## Azul-ardósia frio `#1B2029` clareado o bastante para a luz ambiente.
const AMBIENT_COLOR: Color = Color(0.14, 0.17, 0.23)
const FOG_COLOR: Color = Color(0.06, 0.075, 0.1)
const FOG_DENSITY: float = 0.014


## Aplica ambiente frio e neblina a um `Environment`.
static func apply(env: Environment, fog: bool = true) -> void:
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = AMBIENT_COLOR
	env.ambient_light_energy = AMBIENT_ENERGY
	env.fog_enabled = fog
	if fog:
		env.fog_light_color = FOG_COLOR
		env.fog_density = FOG_DENSITY
		env.fog_sky_affect = 0.0


## Foco quente dramático sobre o assunto (D-ART-1): um `SpotLight3D` vindo de cima, de luz de
## tocha, que separa o inimigo do fundo escuro.
static func make_focus_spot(target: Vector3, energy: float = 5.5) -> SpotLight3D:
	var spot: SpotLight3D = SpotLight3D.new()
	spot.light_color = Color(1.0, 0.72, 0.42)
	spot.light_energy = energy
	spot.spot_range = 14.0
	spot.spot_angle = 32.0
	spot.spot_attenuation = 0.8
	spot.position = target + Vector3(-1.5, 7.0, 3.0)
	spot.shadow_enabled = true
	spot.look_at_from_position(spot.position, target, Vector3.UP)
	return spot
