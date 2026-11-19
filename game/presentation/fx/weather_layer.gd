class_name WeatherLayer
extends Control
## Clima em partículas por cima do cenário (GDD §14 e §18, TASK-039): chuva fina e névoa que
## deriva. Cenário 1 tem Chuva e Névoa. Não bloqueia toque. `GfxSettings.weather` desliga.

var rain: bool = true
var mist: bool = true
var ash: bool = true
var embers: bool = false

var _rain_particles: CPUParticles2D
var _specks: Array[Dictionary] = []


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	clip_contents = true
	if not GfxSettings.weather or DisplayServer.get_name() == "headless":
		return
	if mist:
		_add_mist()
	if rain:
		_add_rain()
	if ash:
		_add_specks(false)
	if embers:
		_add_specks(true)
	resized.connect(_fit_rain)
	_fit_rain()


func _add_mist() -> void:
	var rect: ColorRect = ColorRect.new()
	rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var shader: Shader = Shader.new()
	shader.code = "shader_type canvas_item;\nfloat hash(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }\nfloat noise(vec2 p) {\n\tvec2 i = floor(p);\n\tvec2 f = fract(p);\n\tf = f * f * (3.0 - 2.0 * f);\n\treturn mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), f.x), mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), f.x), f.y);\n}\nvoid fragment() {\n\tvec2 p = UV * vec2(3.0, 5.0) + vec2(TIME * 0.05, TIME * 0.02);\n\tfloat n = noise(p) * 0.6 + noise(p * 2.3 + 7.0) * 0.4;\n\tfloat band = smoothstep(0.1, 0.8, UV.y);\n\tCOLOR = vec4(0.55, 0.62, 0.78, n * 0.16 * (0.4 + band));\n}\n"
	var mat: ShaderMaterial = ShaderMaterial.new()
	mat.shader = shader
	rect.material = mat
	add_child(rect)


func _add_rain() -> void:
	var image: Image = Image.create(2, 16, false, Image.FORMAT_RGBA8)
	for y: int in 16:
		var alpha: float = float(y) / 15.0
		for x: int in 2:
			image.set_pixel(x, y, Color(0.75, 0.85, 1.0, alpha))
	_rain_particles = CPUParticles2D.new()
	_rain_particles.texture = ImageTexture.create_from_image(image)
	_rain_particles.amount = 140
	_rain_particles.lifetime = 0.8
	_rain_particles.preprocess = 1.0
	_rain_particles.local_coords = false
	_rain_particles.direction = Vector2(-0.25, 1.0)
	_rain_particles.spread = 3.0
	_rain_particles.gravity = Vector2.ZERO
	_rain_particles.initial_velocity_min = 800.0
	_rain_particles.initial_velocity_max = 1050.0
	_rain_particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	_rain_particles.color = Color(1, 1, 1, 0.38)
	add_child(_rain_particles)


func _fit_rain() -> void:
	if _rain_particles != null:
		_rain_particles.position = Vector2(size.x * 0.5 + 60.0, -20.0)
		_rain_particles.emission_rect_extents = Vector2(size.x * 0.5 + 120.0, 2.0)
	for entry: Dictionary in _specks:
		var node: CPUParticles2D = entry["node"]
		var rising: bool = bool(entry["rising"])
		node.position = Vector2(size.x * 0.5, size.y + 10.0 if rising else -10.0)
		node.emission_rect_extents = Vector2(size.x * 0.5, 2.0)


## Cinzas que descem devagar ou brasas que sobem (TASK-042): pontos pequenos à deriva.
func _add_specks(rising: bool) -> void:
	var image: Image = Image.create(3, 3, false, Image.FORMAT_RGBA8)
	image.fill(Color.WHITE)
	var specks: CPUParticles2D = CPUParticles2D.new()
	specks.texture = ImageTexture.create_from_image(image)
	specks.amount = 36 if rising else 44
	specks.lifetime = 5.0 if rising else 7.0
	specks.preprocess = 6.0
	specks.local_coords = false
	specks.direction = Vector2(0.15, -1.0) if rising else Vector2(0.3, 1.0)
	specks.spread = 25.0
	specks.gravity = Vector2.ZERO
	specks.initial_velocity_min = 25.0
	specks.initial_velocity_max = 70.0 if rising else 40.0
	specks.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	specks.color = Color(1.0, 0.55, 0.15, 0.85) if rising else Color(0.7, 0.7, 0.75, 0.45)
	specks.scale_amount_min = 0.7
	specks.scale_amount_max = 1.6
	add_child(specks)
	_specks.append({"node": specks, "rising": rising})
