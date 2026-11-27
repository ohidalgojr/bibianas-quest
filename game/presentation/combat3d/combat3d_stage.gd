class_name Combat3DStage
extends Control
## Palco 3D da luta (TASK-037, ADR-0036, GDD §6 e §17, docs/ART-DIRECTION.md §4): o fundo vem do
## tipo do nó (praça, passagem de elite, sala do chefe), escurecido e com vinheta, com o inimigo
## grande e central, a Bibiana de costas embaixo à esquerda e luz quente no chão. Só
## apresentação: a tela de combate manda tocar as animações a partir dos eventos do núcleo.

const K_MINI: String = "res://assets/kenney/mini_dungeon/"
const K_GRAVE: String = "res://assets/kenney/graveyard/"
const SHRINK: int = 2
## Câmera de duelo (ADR-0050, IDENTIDADE-VISUAL §C.1): perto e baixa, o inimigo é o herói do quadro.
const CAM_SIZE: float = 4.3
const CAM_OFFSET: Vector3 = Vector3(1.0, 0.62, 1.0) * 16.0
const CAM_TARGET: Vector3 = Vector3(-0.5, 1.75, -0.4)
const ENEMY_POS: Vector3 = Vector3(-1.2, 0.9, -0.7)
const PLAYER_POS: Vector3 = Vector3(1.8, 0.9, 2.1)
## Alturas de pé em unidades (inimigo comum, elite, chefe e Bibiana).
const HEIGHT_COMMON: float = 2.3
const HEIGHT_ELITE: float = 3.0
const HEIGHT_BOSS: float = 3.6
## No palco pintado a moldura é menor: elite e chefe cabem inteiros com o aviso acima da cabeça.
const PAINTED_HEIGHT_ELITE: float = 2.5
const PAINTED_HEIGHT_BOSS: float = 2.7
const HEIGHT_PLAYER: float = 2.0
const ENEMY_YAW: float = 45.0
const PLAYER_YAW: float = 225.0
const ARENA_HALF: int = 5
## Arenas pintadas 9:16 (ADR-0053, F-024): luta comum no beco; elite, mini boss e chefe na praça
## (até existir `arena-cidade-chefe`).
## Altura de referência (px) dos recortes das poses: todas têm a mesma escala de pixel.
const HERO_REF_HEIGHT: float = 240.0
const WALK_FRAMES: int = 4
const FX_PATH: String = "res://assets/bibiana/fx/"
## Linha do tempo do golpe (s): caminhada até o inimigo, preparação com a espada no alto, volta.
const STRIKE_APPROACH: float = 0.38
const STRIKE_WINDUP: float = 0.16
const STRIKE_RECOVER: float = 0.2
const STRIKE_RETURN: float = 0.34
const WALK_FRAME_SECONDS: float = 0.09
const ARENA_COMMON: String = "res://assets/bibiana/arenas/arena-cidade-rua.jpg"
const ARENA_ELITE: String = "res://assets/bibiana/arenas/arena-cidade-praca.jpg"
## Cemitério e capela do Coveiro: só o chefe final (TASK-072).
const ARENA_BOSS: String = "res://assets/bibiana/arenas/arena-cidade-chefe.jpg"

var time_scale: float = 1.0
var camera: Camera3D
var player_node: Node3D
var enemy_node: Node3D

var _viewport: SubViewport
var _world: Node3D
var _scene_root: Node3D
var _enemy_id: String = ""
var _enemy_scale: float = 2.4
var _enemy_height: float = HEIGHT_COMMON
var _shake: float = 0.0
var _dim: ColorRect
var _portraits: Dictionary = {}
var _backdrop: TextureRect
## Poses de combate da Bibiana (TASK-071): troca a textura do sprite de costas.
var _hero_sprite: Sprite3D
var _defending: bool = false
var _hero_token: int = 0
var _painted: bool = false


func _ready() -> void:
	_painted = ResourceLoader.exists(ARENA_COMMON)
	clip_contents = true
	if _painted:
		_backdrop = TextureRect.new()
		_backdrop.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		_backdrop.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		_backdrop.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		_backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		_backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(_backdrop)
	var container: SubViewportContainer = SubViewportContainer.new()
	container.stretch = true
	container.stretch_shrink = 1 if _painted else SHRINK
	container.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR if _painted else CanvasItem.TEXTURE_FILTER_NEAREST
	container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(container)
	if not _painted:
		PostFx.apply(container, PostFx.COMBAT_BLUR)
	_viewport = SubViewport.new()
	_viewport.transparent_bg = _painted
	_viewport.size = Vector2i(270, 300)
	_viewport.msaa_3d = Viewport.MSAA_DISABLED
	container.add_child(_viewport)
	_world = Node3D.new()
	_viewport.add_child(_world)
	_build_environment()
	camera = Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = CAM_SIZE
	camera.near = 0.1
	camera.far = 80.0
	_world.add_child(camera)
	_aim_camera(Vector3.ZERO)
	_scene_root = Node3D.new()
	_world.add_child(_scene_root)
	_add_vignette()
	add_child(WeatherLayer.new())
	_dim = ColorRect.new()
	_dim.color = Color(0, 0, 0.02, 0.0)
	_dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_dim)


## Fator entre pixels do viewport e pixels da tela (1 no palco pintado, SHRINK no diorama 3D).
func _px() -> float:
	return 1.0 if _painted else float(SHRINK)


func _aim_camera(shake: Vector3) -> void:
	camera.position = CAM_TARGET + CAM_OFFSET + shake
	camera.look_at(CAM_TARGET + shake)


func _build_environment() -> void:
	var env: Environment = Environment.new()
	env.background_mode = Environment.BG_CLEAR_COLOR if _painted else Environment.BG_COLOR
	env.background_color = Color(0.02, 0.024, 0.038)
	Atmosphere.apply(env, not _painted)
	# O duelo precisa de mais ambiente que as outras cenas: o palco é fechado e as peças vêm tingidas.
	env.ambient_light_energy = 0.62
	env.fog_density = 0.002
	env.adjustment_enabled = not _painted
	env.adjustment_saturation = 0.56
	env.adjustment_contrast = 1.2
	env.adjustment_brightness = 0.9
	env.glow_enabled = not _painted
	env.glow_intensity = 0.58
	env.glow_bloom = 0.08
	var holder: WorldEnvironment = WorldEnvironment.new()
	holder.environment = env
	_world.add_child(holder)
	var moon: DirectionalLight3D = DirectionalLight3D.new()
	# Luar de aço rasante vindo de trás do inimigo: recorta a silhueta (IDENTIDADE-VISUAL §B.2).
	moon.light_color = Color("7E8FA8")
	moon.light_energy = 0.7
	moon.rotation_degrees = Vector3(-35, 225, 0)
	moon.shadow_enabled = true
	moon.directional_shadow_mode = DirectionalLight3D.SHADOW_ORTHOGONAL
	moon.directional_shadow_max_distance = 35.0
	_world.add_child(moon)
	# Preenchimento frio vindo da câmera, sem sombra: as paredes do fundo ainda se leem.
	var fill: DirectionalLight3D = DirectionalLight3D.new()
	fill.light_color = Color("7E8FA8")
	fill.light_energy = 0.55
	fill.rotation_degrees = Vector3(-30, 45, 0)
	_world.add_child(fill)
	if not _painted:
		_world.add_child(Atmosphere.make_focus_spot(ENEMY_POS + Vector3(0.0, 1.6, 0.0), 7.0))


## Monta o palco de uma luta. `kind` é o [enum MapNode.Kind] do nó (usa -1 para a luta de teste).
func setup(enemy_id: String, kind: int, mutation: String = "") -> void:
	_enemy_id = enemy_id
	for child: Node in _scene_root.get_children():
		child.queue_free()
	player_node = null
	enemy_node = null
	_hero_sprite = null
	_defending = false
	_hero_token += 1
	_build_arena(kind)
	_spawn_actors(kind)
	_apply_mutation(mutation)
	_portraits.clear()


func _build_arena(kind: int) -> void:
	var boss: bool = kind == MapNode.Kind.BOSS or kind == MapNode.Kind.MINI_BOSS
	var focal_kind: String = "combat_boss" if boss else ("combat_elite" if kind == MapNode.Kind.ELITE else "combat_common")
	if _painted:
		# Fundo pintado HD-2D (ADR-0053): beco para luta comum, praça para elite, mini boss e chefe.
		var path: String = ARENA_ELITE if (boss or kind == MapNode.Kind.ELITE) else ARENA_COMMON
		if kind == MapNode.Kind.BOSS and ResourceLoader.exists(ARENA_BOSS):
			path = ARENA_BOSS
		_backdrop.texture = load(path) as Texture2D
		return
	# Reserva sem textura: arena de duelo composta (ADR-0050), canto de nave gótica.
	DuelArena.build(_scene_root, focal_kind)


func _spawn_actors(kind: int) -> void:
	player_node = ModelRegistry.spawn(ModelRegistry.hero_id())
	player_node.position = PLAYER_POS
	player_node.rotation_degrees.y = PLAYER_YAW
	_scene_root.add_child(player_node)
	player_node.scale = Vector3.ONE * _scale_to_height(player_node, HEIGHT_PLAYER, 1.0)
	_add_contact_shadow(player_node, 0.9)
	ModelRegistry.play(player_node, ModelRegistry.hero_id(), "idle")
	for found: Node in player_node.find_children("*", "Sprite3D", true, false):
		if found.name != "ContactShadow":
			_hero_sprite = found as Sprite3D
			break
	if not ModelRegistry.has_model(_enemy_id):
		return
	enemy_node = ModelRegistry.spawn(_enemy_id)
	enemy_node.position = ENEMY_POS
	enemy_node.rotation_degrees.y = ENEMY_YAW + ModelRegistry.yaw_offset(_enemy_id)
	var boss: bool = kind == MapNode.Kind.BOSS or kind == MapNode.Kind.MINI_BOSS
	# Escala pela altura de pé (a criatura alta lê alta), com teto para as largas (cão, rato).
	var target: float = HEIGHT_BOSS if boss else (HEIGHT_ELITE if kind == MapNode.Kind.ELITE else HEIGHT_COMMON)
	if _painted:
		target = PAINTED_HEIGHT_BOSS if boss else (PAINTED_HEIGHT_ELITE if kind == MapNode.Kind.ELITE else HEIGHT_COMMON)
	_scene_root.add_child(enemy_node)
	# Criatura larga (cão, ratos) não pode passar da moldura do quadro pintado.
	_enemy_scale = _scale_to_height(enemy_node, target, 1.0 if _painted else 1.7)
	enemy_node.scale = Vector3.ONE * _enemy_scale
	_enemy_height = target
	_add_contact_shadow(enemy_node, 1.1)
	ModelRegistry.play(enemy_node, _enemy_id, "idle")


## Sombra de contato: elipse escura e achatada sob os pés, para o sprite não flutuar sobre o quadro
## pintado (só no palco pintado). `width` é a largura em unidades locais do ator (pés em y = 0).
func _add_contact_shadow(actor: Node3D, width: float) -> void:
	if not _painted:
		return
	var gradient: Gradient = Gradient.new()
	gradient.colors = PackedColorArray([Color(0, 0, 0, 0.72), Color(0, 0, 0, 0.0)])
	gradient.offsets = PackedFloat32Array([0.0, 1.0])
	var tex: GradientTexture2D = GradientTexture2D.new()
	tex.gradient = gradient
	tex.fill = GradientTexture2D.FILL_RADIAL
	tex.fill_from = Vector2(0.5, 0.5)
	tex.fill_to = Vector2(1.0, 0.5)
	tex.width = 128
	tex.height = 128
	var shadow: Sprite3D = Sprite3D.new()
	shadow.name = "ContactShadow"
	shadow.texture = tex
	shadow.axis = Vector3.AXIS_Y
	shadow.pixel_size = width / 128.0
	shadow.shaded = false
	shadow.transparent = true
	shadow.position = Vector3(0.0, 0.02, 0.0)
	actor.add_child(shadow)


## Fator de escala que leva a altura do modelo a [param height], sem deixar a maior dimensão passar de
## [param max_ratio] vezes essa altura.
func _scale_to_height(node: Node3D, height: float, max_ratio: float) -> float:
	var box: AABB = _aabb(node)
	var longest: float = maxf(box.size.x, maxf(box.size.y, box.size.z))
	if box.size.y < 0.05 or longest < 0.05:
		return 2.0
	return minf(height / box.size.y, height * max_ratio / longest)


## Topo da cabeça do inimigo em coordenadas deste `Control` (o aviso de intenção fica sobre ele).
func head_screen_pos() -> Vector2:
	if enemy_node == null or camera == null or not camera.is_inside_tree():
		return Vector2(size.x * 0.5, size.y * 0.3)
	return camera.unproject_position(enemy_node.position + Vector3(0, _enemy_height, 0)) * _px()


## Posição de tela (coordenadas deste `Control`) do alvo, para números de dano e ícones.
func screen_pos(on_enemy: bool) -> Vector2:
	var node: Node3D = enemy_node if on_enemy else player_node
	if node == null or camera == null or not camera.is_inside_tree():
		return size * 0.5
	var head: float = 1.6 if on_enemy else 1.2
	return camera.unproject_position(node.position + Vector3(0, head, 0)) * _px()


## Textura da pose da Bibiana (`attack`, `defend`, `hurt`, `item`, `victory`, `defeat`, `walk_0`..`walk_3`
## ou `back` para a guarda de costas). Mantém a escala de pixel dos recortes.
func hero_pose(pose: String) -> void:
	if _hero_sprite == null:
		return
	var id: String = ModelRegistry.hero_id() if pose == "back" else "bibiana_warrior_%s" % pose
	if not ModelRegistry.has_sprite(id):
		return
	var tex: Texture2D = ModelRegistry.sprite_texture(id)
	_hero_sprite.texture = tex
	_hero_sprite.pixel_size = 1.0 / HERO_REF_HEIGHT
	_hero_sprite.offset = Vector2(0.0, float(tex.get_height()) * 0.5)


func _idle_pose() -> String:
	return "defend" if _defending else "back"


## Escolhe a guarda: ao agir, a Bibiana sai da defesa; ao defender, fica com o escudo à frente.
func set_defending(on: bool) -> void:
	_defending = on
	hero_pose(_idle_pose())


## Golpe da Bibiana: caminha até o inimigo, ergue a espada e devolve o controle no instante do impacto
## (a tela aplica dano e números nessa hora). A volta corre sozinha em seguida. Sem tempo, não anima.
func hero_strike(crit: bool = false) -> void:
	if _hero_sprite == null or enemy_node == null or time_scale <= 0.0 or not is_inside_tree():
		return
	_defending = false
	_hero_token += 1
	var token: int = _hero_token
	var toward: Vector3 = (PLAYER_POS - ENEMY_POS).normalized()
	var spot: Vector3 = ENEMY_POS + toward * 1.55
	var tween: Tween = create_tween().set_parallel(true)
	tween.tween_property(player_node, "position", spot, STRIKE_APPROACH * time_scale).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_method(func(t: float) -> void:
		if token == _hero_token:
			hero_pose("walk_%d" % (int(t / WALK_FRAME_SECONDS) % WALK_FRAMES)), 0.0, STRIKE_APPROACH * time_scale, STRIKE_APPROACH * time_scale)
	await tween.finished
	if token != _hero_token:
		return
	hero_pose("attack")
	await get_tree().create_timer(STRIKE_WINDUP * time_scale).timeout
	if token != _hero_token:
		return
	_spawn_fx("slash", enemy_node.position + Vector3(0.0, _enemy_height * 0.55, 0.0), 6, 3.2 if not crit else 4.0, 0.3)
	if crit:
		_spawn_fx("crit", enemy_node.position + Vector3(0.0, _enemy_height * 0.55, 0.0), 1, 2.8, 0.35)
	_hero_return(token)


func _hero_return(token: int) -> void:
	await get_tree().create_timer(STRIKE_RECOVER * time_scale).timeout
	if token != _hero_token or player_node == null:
		return
	var tween: Tween = create_tween().set_parallel(true)
	tween.tween_property(player_node, "position", PLAYER_POS, STRIKE_RETURN * time_scale).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_method(func(t: float) -> void:
		if token == _hero_token:
			hero_pose("walk_%d" % (int(t / WALK_FRAME_SECONDS) % WALK_FRAMES)), 0.0, STRIKE_RETURN * time_scale, STRIKE_RETURN * time_scale)
	await tween.finished
	if token == _hero_token:
		hero_pose(_idle_pose())


## Reação da Bibiana a um golpe do inimigo: de escudo erguido (defendendo) solta faíscas, senão recua ferida.
func hero_react(damage_taken: bool = true) -> void:
	if _hero_sprite == null or time_scale <= 0.0 or not is_inside_tree():
		return
	_hero_token += 1
	var token: int = _hero_token
	var at: Vector3 = PLAYER_POS + Vector3(0.0, 1.1, 0.0)
	if _defending:
		hero_pose("defend")
		_spawn_fx("block", at, 5, 2.4, 0.3)
	elif damage_taken:
		hero_pose("hurt")
		_spawn_fx("slash", at, 6, 2.2, 0.26)
	await get_tree().create_timer(0.38 * time_scale).timeout
	if token == _hero_token:
		hero_pose(_idle_pose())


## Poção, éter e outros consumíveis: bebe e volta à guarda.
func hero_use_item() -> void:
	if _hero_sprite == null or time_scale <= 0.0 or not is_inside_tree():
		return
	_defending = false
	_hero_token += 1
	var token: int = _hero_token
	hero_pose("item")
	await get_tree().create_timer(0.7 * time_scale).timeout
	if token == _hero_token:
		hero_pose("back")


func hero_victory() -> void:
	_hero_token += 1
	hero_pose("victory")


func hero_defeat() -> void:
	_hero_token += 1
	hero_pose("defeat")


## Animação de FX por quadros (folha em `assets/bibiana/fx/`), em pé na cena, sempre à frente.
func _spawn_fx(fx_name: String, at: Vector3, frames: int, size: float, seconds: float) -> void:
	var path: String = FX_PATH + fx_name + ".png"
	if time_scale <= 0.0 or not is_inside_tree() or not ResourceLoader.exists(path):
		return
	var tex: Texture2D = load(path) as Texture2D
	var fx: Sprite3D = Sprite3D.new()
	fx.texture = tex
	fx.hframes = frames
	fx.frame = 0
	fx.pixel_size = size / float(tex.get_width() / frames)
	fx.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	fx.shaded = false
	fx.no_depth_test = true
	fx.render_priority = 5
	fx.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR
	fx.position = at
	_scene_root.add_child(fx)
	var tween: Tween = create_tween()
	tween.tween_method(func(t: float) -> void:
		if is_instance_valid(fx):
			fx.frame = mini(int(t * float(frames)), frames - 1), 0.0, 0.999, seconds * time_scale)
	tween.tween_callback(func() -> void:
		if is_instance_valid(fx):
			fx.queue_free())


## Toca uma animação do modelo: "attack", "hit", "death" ou "idle". `on_enemy` escolhe o lado.
func play(on_enemy: bool, key: String) -> void:
	var node: Node3D = enemy_node if on_enemy else player_node
	if node == null:
		return
	var id: String = _enemy_id if on_enemy else ModelRegistry.hero_id()
	ModelRegistry.play(node, id, key)
	if time_scale <= 0.0 or not is_inside_tree():
		return
	if not on_enemy and _hero_sprite != null:
		# A Bibiana tem poses próprias (hero_strike, hero_react): aqui só a tremida da câmera.
		if key == "hit":
			_shake = 0.18
		return
	var home: Vector3 = ENEMY_POS if on_enemy else PLAYER_POS
	var toward: Vector3 = (PLAYER_POS - ENEMY_POS).normalized() * (1.0 if on_enemy else -1.0)
	var tween: Tween = create_tween()
	match key:
		"attack":
			tween.tween_property(node, "position", home + toward * 0.9, 0.12 * time_scale)
			tween.tween_property(node, "position", home, 0.22 * time_scale)
		"hit":
			_shake = 0.18
			tween.tween_property(node, "position", home - toward * 0.35, 0.07 * time_scale)
			tween.tween_property(node, "position", home, 0.2 * time_scale)
		"death":
			tween.tween_property(node, "scale", node.scale * 0.01, 0.7 * time_scale).set_delay(0.3 * time_scale)
	tween.finished.connect(func() -> void:
		if key != "death":
			ModelRegistry.play(node, id, "idle"))


func _process(delta: float) -> void:
	if camera == null:
		return
	if _shake > 0.0:
		_shake = maxf(_shake - delta, 0.0)
		_aim_camera(Vector3(sin(_shake * 90.0), 0.0, cos(_shake * 70.0)) * _shake)
	else:
		_aim_camera(Vector3.ZERO)


func _add_vignette() -> void:
	var rect: ColorRect = ColorRect.new()
	rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var shader: Shader = Shader.new()
	shader.code = "shader_type canvas_item;\nvoid fragment() {\n\tvec2 uv = UV - vec2(0.5);\n\tfloat d = dot(uv, uv) * 2.6;\n\tCOLOR = vec4(0.0, 0.0, 0.02, clamp(d * d * 1.6, 0.0, 0.92));\n}\n"
	var mat: ShaderMaterial = ShaderMaterial.new()
	mat.shader = shader
	rect.material = mat
	add_child(rect)


## Mutação visível no modelo (GDD §11, ADR-0032): tamanho, transparência ou luz própria.
func _apply_mutation(mutation: String) -> void:
	if enemy_node == null or mutation.is_empty():
		return
	match mutation:
		"bloated":
			enemy_node.scale *= Vector3(1.3, 1.0, 1.3)
		"voracious":
			var red: OmniLight3D = OmniLight3D.new()
			red.light_color = Color(1.0, 0.18, 0.12)
			red.light_energy = 3.0
			red.omni_range = 4.0
			red.position = Vector3(0, 1.4, 0)
			enemy_node.add_child(red)
		"phantom":
			for mesh: Node in enemy_node.find_children("*", "GeometryInstance3D", true, false):
				if mesh is Sprite3D and mesh.name != "ContactShadow":
					(mesh as Sprite3D).modulate.a = 0.5
				elif not mesh is Sprite3D:
					(mesh as GeometryInstance3D).transparency = 0.5
		"thorny":
			enemy_node.scale *= 1.15
			var thorn: OmniLight3D = OmniLight3D.new()
			thorn.light_color = Color(0.7, 0.2, 0.5)
			thorn.light_energy = 2.0
			thorn.omni_range = 3.0
			thorn.position = Vector3(0, 1.0, 0)
			enemy_node.add_child(thorn)


## Retrato do personagem (cabeça e ombros) para a linha do tempo. Cada um tem a própria
## `SubViewport` com o modelo e uma câmera de frente, desenhada uma vez por luta.
func portrait(on_enemy: bool) -> Texture2D:
	var key: String = "enemy" if on_enemy else "player"
	if _portraits.has(key):
		return _portraits[key]
	var id: String = _enemy_id if on_enemy else ModelRegistry.hero_id()
	if not ModelRegistry.has_model(id):
		return null
	if ModelRegistry.has_sprite(id):
		# Busto de sprite (TASK-071): recorte quadrado da cabeça, reduzido com Lanczos (sem borrão).
		# A Bibiana usa a prancha de frente (rosto), não a de costas do palco.
		_portraits[key] = _bust_texture("bibiana" if not on_enemy else id)
		return _portraits[key]
	var port: SubViewport = SubViewport.new()
	port.size = Vector2i(64, 64)
	port.own_world_3d = true
	port.transparent_bg = true
	port.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(port)
	var model: Node3D = ModelRegistry.spawn(id)
	port.add_child(model)
	ModelRegistry.play(model, id, "idle")
	var height: float = 1.0
	var top: float = 1.0
	var box: AABB = _aabb(model)
	if box.size.y > 0.01:
		height = box.size.y
		top = box.position.y + box.size.y
	var cam: Camera3D = Camera3D.new()
	cam.projection = Camera3D.PROJECTION_ORTHOGONAL
	cam.size = height * 0.5
	port.add_child(cam)
	cam.position = Vector3(0, top - height * 0.2, 4.0)
	var light: DirectionalLight3D = DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-25, 20, 0)
	light.light_energy = 1.4
	port.add_child(light)
	var env: Environment = Environment.new()
	env.background_mode = Environment.BG_CLEAR_COLOR
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.6, 0.62, 0.7)
	var holder: WorldEnvironment = WorldEnvironment.new()
	holder.environment = env
	port.add_child(holder)
	var tex: Texture2D = port.get_texture()
	_portraits[key] = tex
	return tex


## Recorte quadrado da cabeça de um sprite, centrado no centro de massa da região da cabeça (topo da
## figura em pé; lado esquerdo em bichos largos, que olham para a esquerda) e reduzido com Lanczos.
func _bust_texture(id: String) -> Texture2D:
	var source: Texture2D = ModelRegistry.sprite_texture(id)
	var image: Image = source.get_image()
	if image.is_compressed():
		image.decompress()
	var w: int = image.get_width()
	var h: int = image.get_height()
	var wide: bool = float(w) > float(h) * 1.1
	var region: Rect2i = Rect2i(0, 0, int(float(w) * 0.32), h) if wide else Rect2i(0, 0, w, int(float(h) * 0.28))
	var sum_x: float = 0.0
	var sum_y: float = 0.0
	var count: float = 0.0
	for y: int in range(region.position.y, region.end.y):
		for x: int in range(region.position.x, region.end.x):
			if image.get_pixel(x, y).a > 0.5:
				sum_x += float(x)
				sum_y += float(y)
				count += 1.0
	var cx: float = sum_x / count if count > 0.0 else float(w) * 0.5
	var cy: float = sum_y / count if count > 0.0 else float(h) * 0.15
	var side: int = int(float(h) * (0.8 if wide else 0.4))
	side = mini(side, mini(w, h))
	var x0: int = clampi(int(cx - float(side) * 0.5), 0, w - side)
	var y0: int = clampi(int(cy - float(side) * (0.5 if wide else 0.42)), 0, h - side)
	var crop: Image = image.get_region(Rect2i(x0, y0, side, side))
	crop.resize(96, 96, Image.INTERPOLATE_LANCZOS)
	return ImageTexture.create_from_image(crop)


## Caixa do modelo no espaço do próprio `node` (acumula as transformações da malha até ele).
func _aabb(node: Node3D) -> AABB:
	var out: AABB = AABB()
	var first: bool = true
	for found: Node in node.find_children("*", "GeometryInstance3D", true, false):
		var mesh: GeometryInstance3D = found as GeometryInstance3D
		var chain: Transform3D = mesh.transform
		var parent: Node = mesh.get_parent()
		while parent != null and parent != node:
			if parent is Node3D:
				chain = (parent as Node3D).transform * chain
			parent = parent.get_parent()
		var box: AABB = chain * mesh.get_aabb()
		out = box if first else out.merge(box)
		first = false
	return out


## Foco da moeda (GDD §7, §19): a cena escurece, a câmera se aproxima do centro e tudo fica
## em silêncio; `false` devolve a cena ao normal.
func set_focus(on: bool) -> void:
	if time_scale <= 0.0 or not is_inside_tree():
		return
	var tween: Tween = create_tween().set_parallel(true)
	tween.tween_property(_dim, "color:a", 0.6 if on else 0.0, 0.35 * time_scale)
	tween.tween_property(camera, "size", CAM_SIZE * (0.8 if on else 1.0), 0.35 * time_scale)


## Hit-stop (GDD §19): congela as animações por um instante no acerto, para dar peso.
func hit_stop(seconds: float = 0.08) -> void:
	if time_scale <= 0.0 or not is_inside_tree():
		return
	var players: Array[AnimationPlayer] = []
	for node: Node3D in [player_node, enemy_node]:
		if node == null:
			continue
		for found: Node in node.find_children("*", "AnimationPlayer", true, false):
			var player: AnimationPlayer = found as AnimationPlayer
			players.append(player)
			player.speed_scale = 0.0
	await get_tree().create_timer(seconds, true, false, true).timeout
	for player: AnimationPlayer in players:
		if is_instance_valid(player):
			player.speed_scale = 1.0
