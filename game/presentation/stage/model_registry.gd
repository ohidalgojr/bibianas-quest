class_name ModelRegistry
extends RefCounted
## Liga o id de uma entidade do jogo ao modelo 3D (campo "modelo", GDD §20; TASK-035).
## Trocar a arte é trocar uma linha aqui, sem tocar nas regras. Todo caminho de `assets/`
## precisa estar em `assets/LICENSES.md`. Os inimigos sem kit próprio usam um substituto
## (`placeholder: true`) até o Blender (ver "Pendências de modelo" em LICENSES.md).

const K_GRAVE: String = "res://assets/kenney/graveyard/"
const KAYKIT: String = "res://assets/kaykit/adventurers/"
const QUAT: String = "res://assets/quaternius/monsters/"
const OWN: String = "res://assets/bibiana/enemies/"

## id -> {path, scale, idle, walk, attack, hit, death, placeholder}
const MODELS: Dictionary = {
	"bibiana": {"path": KAYKIT + "Knight.glb", "scale": 0.3, "idle": "Idle", "walk": "Running_A", "attack": "1H_Melee_Attack_Slice_Diagonal", "hit": "Hit_A", "death": "Death_A", "placeholder": false},
	"infected_citizen": {"path": K_GRAVE + "character-zombie.glb", "scale": 1.0, "idle": "idle", "walk": "walk", "attack": "attack-melee-right", "hit": "idle", "death": "die", "placeholder": false},
	"giant_rat": {"path": OWN + "giant_rat.glb", "scale": 0.8, "yaw_offset": 55.0, "idle": "", "walk": "", "attack": "", "hit": "", "death": "", "placeholder": false},
	"carrion_crow": {"path": OWN + "carrion_crow.glb", "scale": 0.9, "idle": "", "walk": "", "attack": "", "hit": "", "death": "", "placeholder": false},
	"plague_hound": {"path": OWN + "plague_hound.glb", "scale": 0.7, "yaw_offset": 55.0, "idle": "", "walk": "", "attack": "", "hit": "", "death": "", "placeholder": false},
	"rotten_executioner": {"path": OWN + "rotten_executioner.glb", "scale": 0.85, "idle": "", "walk": "", "attack": "", "hit": "", "death": "", "placeholder": false},
	"bell_ghost": {"path": K_GRAVE + "character-ghost.glb", "scale": 1.0, "idle": "idle", "walk": "walk", "attack": "attack-melee-right", "hit": "idle", "death": "die", "placeholder": false},
	"wandering_bones": {"path": K_GRAVE + "character-skeleton.glb", "scale": 1.0, "idle": "idle", "walk": "walk", "attack": "attack-melee-left", "hit": "idle", "death": "die", "placeholder": false},
	"sewer_slime": {"path": QUAT + "Slime.fbx", "scale": 30.0, "idle": "Armature|Slime_Idle", "walk": "Armature|Slime_Walk", "attack": "Armature|Slime_Attack", "hit": "Armature|Slime_Idle", "death": "Armature|Slime_Death", "placeholder": false},
	"alley_leech": {"path": K_GRAVE + "character-vampire.glb", "scale": 1.0, "idle": "idle", "walk": "walk", "attack": "attack-melee-right", "hit": "idle", "death": "die", "placeholder": false},
	"bell_warden": {"path": K_GRAVE + "character-keeper.glb", "scale": 1.25, "idle": "idle", "walk": "walk", "attack": "attack-melee-left", "hit": "idle", "death": "die", "placeholder": true},
	"gravedigger": {"path": K_GRAVE + "character-keeper.glb", "scale": 1.6, "idle": "idle", "walk": "walk", "attack": "attack-melee-right", "hit": "idle", "death": "die", "placeholder": false},
}


## Giro extra (graus) para mostrar o bicho de perfil no palco; 0 quando não define.
static func yaw_offset(id: String) -> float:
	return float((MODELS[id] as Dictionary).get("yaw_offset", 0.0))


static func has_model(id: String) -> bool:
	return MODELS.has(id)


## Cria o modelo com a escala aplicada, dentro de um `Node3D` com o nome do id.
static func spawn(id: String) -> Node3D:
	var entry: Dictionary = MODELS[id]
	var packed: PackedScene = load(entry["path"] as String) as PackedScene
	var root: Node3D = Node3D.new()
	root.name = id
	var inst: Node3D = packed.instantiate() as Node3D
	inst.scale = Vector3.ONE * float(entry["scale"])
	root.add_child(inst)
	return root


## Toca a animação `key` ("idle", "walk", "attack", "hit" ou "death") do modelo criado por [method spawn].
## Modelo sem `AnimationPlayer` (os feitos no Blender do projeto) ganha uma respiração procedural no idle.
static func play(root: Node, id: String, key: String) -> void:
	var entry: Dictionary = MODELS[id]
	var wanted: String = str(entry.get(key, ""))
	for n: Node in root.find_children("*", "AnimationPlayer", true, false):
		var player: AnimationPlayer = n as AnimationPlayer
		if player.has_animation(wanted):
			if key == "idle" or key == "walk":
				player.get_animation(wanted).loop_mode = Animation.LOOP_LINEAR
			player.play(wanted)
		return
	if key == "idle" and root.is_inside_tree() and root.get_child_count() > 0 and not root.has_meta("breathing"):
		root.set_meta("breathing", true)
		var body: Node3D = root.get_child(0) as Node3D
		var base: Vector3 = body.scale
		var tween: Tween = root.create_tween().set_loops()
		tween.tween_property(body, "scale", base * Vector3(1.0, 1.05, 1.0), 0.9).set_trans(Tween.TRANS_SINE)
		tween.tween_property(body, "scale", base, 0.9).set_trans(Tween.TRANS_SINE)
