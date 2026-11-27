class_name ModelRegistry
extends RefCounted
## Liga o id de uma entidade do jogo ao modelo 3D ou, desde a TASK-066, ao sprite 2D HD-2D (ADR-0053) (campo "modelo", GDD §20; TASK-035).
## Trocar a arte é trocar uma linha aqui, sem tocar nas regras. Todo caminho de `assets/`
## precisa estar em `assets/LICENSES.md`. Os inimigos sem kit próprio usam um substituto
## (`placeholder: true`) até o Blender (ver "Pendências de modelo" em LICENSES.md).

const K_GRAVE: String = "res://assets/kenney/graveyard/"
const KAYKIT: String = "res://assets/kaykit/adventurers/"
const QUAT: String = "res://assets/quaternius/monsters/"
const OWN: String = "res://assets/bibiana/enemies/"
## Sprites 2D HD-2D (ADR-0052): recortes das pranchas de conceito, em pé no diorama 3D.
const SPR: String = "res://assets/bibiana/sprites/"

## id -> {path, scale, idle, walk, attack, hit, death, placeholder}
const MODELS: Dictionary = {
	"bibiana": {"sprite": SPR + "bibiana_warrior.png", "flip": false, "path": KAYKIT + "Knight.glb", "scale": 0.3, "idle": "Idle", "walk": "Running_A", "attack": "1H_Melee_Attack_Slice_Diagonal", "hit": "Hit_A", "death": "Death_A", "placeholder": false},
	"infected_citizen": {"sprite": SPR + "infected_citizen.png", "flip": false, "path": K_GRAVE + "character-zombie.glb", "scale": 1.0, "idle": "idle", "walk": "walk", "attack": "attack-melee-right", "hit": "idle", "death": "die", "placeholder": false},
	"giant_rat": {"sprite": SPR + "giant_rat.png", "flip": false, "path": OWN + "giant_rat.glb", "scale": 0.8, "idle": "", "walk": "", "attack": "", "hit": "", "death": "", "placeholder": false},
	"carrion_crow": {"sprite": SPR + "carrion_crow.png", "flip": false, "path": OWN + "carrion_crow.glb", "scale": 0.9, "idle": "", "walk": "", "attack": "", "hit": "", "death": "", "placeholder": false},
	"plague_hound": {"sprite": SPR + "plague_hound.png", "flip": false, "path": OWN + "plague_hound.glb", "scale": 0.7, "idle": "", "walk": "", "attack": "", "hit": "", "death": "", "placeholder": false},
	"rotten_executioner": {"sprite": SPR + "rotten_executioner.png", "flip": false, "path": OWN + "rotten_executioner.glb", "scale": 0.85, "idle": "", "walk": "", "attack": "", "hit": "", "death": "", "placeholder": false},
	"bell_ghost": {"sprite": SPR + "bell_ghost.png", "flip": false, "path": OWN + "bell_ghost.glb", "scale": 1.0, "idle": "", "walk": "", "attack": "", "hit": "", "death": "", "placeholder": false},
	"wandering_bones": {"sprite": SPR + "wandering_bones.png", "flip": false, "path": OWN + "wandering_bones.glb", "scale": 1.0, "idle": "", "walk": "", "attack": "", "hit": "", "death": "", "placeholder": false},
	"hanged_man": {"sprite": SPR + "hanged_man.png", "flip": false, "path": OWN + "hanged_man.glb", "scale": 1.0, "idle": "", "walk": "", "attack": "", "hit": "", "death": "", "placeholder": false},
	"stitched_horror": {"sprite": SPR + "stitched_horror.png", "flip": false, "path": OWN + "stitched_horror.glb", "scale": 1.0, "idle": "", "walk": "", "attack": "", "hit": "", "death": "", "placeholder": false},
	"rat_mother": {"sprite": SPR + "rat_mother.png", "flip": false, "path": OWN + "rat_mother.glb", "scale": 1.0, "idle": "", "walk": "", "attack": "", "hit": "", "death": "", "placeholder": false},
	"sewer_slime": {"sprite": SPR + "sewer_slime.png", "flip": false, "path": QUAT + "Slime.fbx", "scale": 30.0, "idle": "Armature|Slime_Idle", "walk": "Armature|Slime_Walk", "attack": "Armature|Slime_Attack", "hit": "Armature|Slime_Idle", "death": "Armature|Slime_Death", "placeholder": false},
	"alley_leech": {"sprite": SPR + "alley_leech.png", "flip": false, "path": OWN + "alley_leech.glb", "scale": 1.0, "idle": "", "walk": "", "attack": "", "hit": "", "death": "", "placeholder": false},
	"blind_censer_bearer": {"sprite": SPR + "blind_censer_bearer.png", "flip": false, "path": OWN + "blind_censer_bearer.glb", "scale": 1.0, "idle": "", "walk": "", "attack": "", "hit": "", "death": "", "placeholder": false},
	"wax_physician": {"sprite": SPR + "wax_physician.png", "flip": false, "path": OWN + "wax_physician.glb", "scale": 1.0, "idle": "", "walk": "", "attack": "", "hit": "", "death": "", "placeholder": false},
	"trench_crawler": {"sprite": SPR + "trench_crawler.png", "flip": true, "path": OWN + "trench_crawler.glb", "scale": 1.0, "idle": "", "walk": "", "attack": "", "hit": "", "death": "", "placeholder": false},
	"bell_warden": {"sprite": SPR + "bell_warden.png", "flip": false, "path": OWN + "bell_warden.glb", "scale": 1.0, "idle": "", "walk": "", "attack": "", "hit": "", "death": "", "placeholder": false},
	"gravedigger": {"sprite": SPR + "gravedigger.png", "flip": false, "path": OWN + "gravedigger.glb", "scale": 1.0, "idle": "", "walk": "", "attack": "", "hit": "", "death": "", "placeholder": false},
	# Inimigos do estudo sem código ainda (TASK-051) e NPCs/props das pranchas HD-2D (F-024). Sem `path`:
	# só existem como sprite; a cena que os usar chama `spawn` normalmente.
	# Bibiana por classe em 4 poses (costas de combate, esquerda, direita, sentada na fogueira), TASK-069.
	"bibiana_warrior_back": {"sprite": SPR + "bibiana_warrior_back.png", "flip": false, "scale": 1.0, "idle": "", "walk": "", "attack": "", "hit": "", "death": "", "placeholder": false},
	"bibiana_warrior_left": {"sprite": SPR + "bibiana_warrior_left.png", "flip": false, "scale": 1.0, "idle": "", "walk": "", "attack": "", "hit": "", "death": "", "placeholder": false},
	"bibiana_warrior_right": {"sprite": SPR + "bibiana_warrior_right.png", "flip": false, "scale": 1.0, "idle": "", "walk": "", "attack": "", "hit": "", "death": "", "placeholder": false},
	"bibiana_warrior_camp": {"sprite": SPR + "bibiana_warrior_camp.png", "flip": false, "scale": 1.0, "idle": "", "walk": "", "attack": "", "hit": "", "death": "", "placeholder": false},
	"bibiana_cleric_back": {"sprite": SPR + "bibiana_cleric_back.png", "flip": false, "scale": 1.0, "idle": "", "walk": "", "attack": "", "hit": "", "death": "", "placeholder": false},
	"bibiana_cleric_left": {"sprite": SPR + "bibiana_cleric_left.png", "flip": false, "scale": 1.0, "idle": "", "walk": "", "attack": "", "hit": "", "death": "", "placeholder": false},
	"bibiana_cleric_right": {"sprite": SPR + "bibiana_cleric_right.png", "flip": false, "scale": 1.0, "idle": "", "walk": "", "attack": "", "hit": "", "death": "", "placeholder": false},
	"bibiana_cleric_camp": {"sprite": SPR + "bibiana_cleric_camp.png", "flip": false, "scale": 1.0, "idle": "", "walk": "", "attack": "", "hit": "", "death": "", "placeholder": false},
	"bibiana_rogue_back": {"sprite": SPR + "bibiana_rogue_back.png", "flip": false, "scale": 1.0, "idle": "", "walk": "", "attack": "", "hit": "", "death": "", "placeholder": false},
	"bibiana_rogue_left": {"sprite": SPR + "bibiana_rogue_left.png", "flip": false, "scale": 1.0, "idle": "", "walk": "", "attack": "", "hit": "", "death": "", "placeholder": false},
	"bibiana_rogue_right": {"sprite": SPR + "bibiana_rogue_right.png", "flip": false, "scale": 1.0, "idle": "", "walk": "", "attack": "", "hit": "", "death": "", "placeholder": false},
	"bibiana_rogue_camp": {"sprite": SPR + "bibiana_rogue_camp.png", "flip": false, "scale": 1.0, "idle": "", "walk": "", "attack": "", "hit": "", "death": "", "placeholder": false},
	"bibiana_mage_back": {"sprite": SPR + "bibiana_mage_back.png", "flip": false, "scale": 1.0, "idle": "", "walk": "", "attack": "", "hit": "", "death": "", "placeholder": false},
	"bibiana_mage_left": {"sprite": SPR + "bibiana_mage_left.png", "flip": false, "scale": 1.0, "idle": "", "walk": "", "attack": "", "hit": "", "death": "", "placeholder": false},
	"bibiana_mage_right": {"sprite": SPR + "bibiana_mage_right.png", "flip": false, "scale": 1.0, "idle": "", "walk": "", "attack": "", "hit": "", "death": "", "placeholder": false},
	"bibiana_mage_camp": {"sprite": SPR + "bibiana_mage_camp.png", "flip": false, "scale": 1.0, "idle": "", "walk": "", "attack": "", "hit": "", "death": "", "placeholder": false},
	"reliquary_lady": {"sprite": SPR + "reliquary_lady.png", "flip": false, "scale": 1.0, "idle": "", "walk": "", "attack": "", "hit": "", "death": "", "placeholder": false},
	"wheel_pilgrim": {"sprite": SPR + "wheel_pilgrim.png", "flip": false, "scale": 1.0, "idle": "", "walk": "", "attack": "", "hit": "", "death": "", "placeholder": false},
	"bog_washerwoman": {"sprite": SPR + "bog_washerwoman.png", "flip": false, "scale": 1.0, "idle": "", "walk": "", "attack": "", "hit": "", "death": "", "placeholder": false},
	"shop_keeper": {"sprite": SPR + "shop_keeper.png", "flip": false, "scale": 1.0, "idle": "", "walk": "", "attack": "", "hit": "", "death": "", "placeholder": false},
	"grave_scavenger": {"sprite": SPR + "grave_scavenger.png", "flip": false, "scale": 1.0, "idle": "", "walk": "", "attack": "", "hit": "", "death": "", "placeholder": false},
	# Poses de combate, estados e caminhada da Guerreira de costas (TASK-071).
	"bibiana_warrior_attack": {"sprite": SPR + "bibiana_warrior_attack.png", "flip": false, "scale": 1.0, "idle": "", "walk": "", "attack": "", "hit": "", "death": "", "placeholder": false},
	"bibiana_warrior_defend": {"sprite": SPR + "bibiana_warrior_defend.png", "flip": false, "scale": 1.0, "idle": "", "walk": "", "attack": "", "hit": "", "death": "", "placeholder": false},
	"bibiana_warrior_hurt": {"sprite": SPR + "bibiana_warrior_hurt.png", "flip": false, "scale": 1.0, "idle": "", "walk": "", "attack": "", "hit": "", "death": "", "placeholder": false},
	"bibiana_warrior_item": {"sprite": SPR + "bibiana_warrior_item.png", "flip": false, "scale": 1.0, "idle": "", "walk": "", "attack": "", "hit": "", "death": "", "placeholder": false},
	"bibiana_warrior_victory": {"sprite": SPR + "bibiana_warrior_victory.png", "flip": false, "scale": 1.0, "idle": "", "walk": "", "attack": "", "hit": "", "death": "", "placeholder": false},
	"bibiana_warrior_defeat": {"sprite": SPR + "bibiana_warrior_defeat.png", "flip": false, "scale": 1.0, "idle": "", "walk": "", "attack": "", "hit": "", "death": "", "placeholder": false},
	"bibiana_warrior_idle_guard": {"sprite": SPR + "bibiana_warrior_idle_guard.png", "flip": false, "scale": 1.0, "idle": "", "walk": "", "attack": "", "hit": "", "death": "", "placeholder": false},
	"bibiana_warrior_sit_fire": {"sprite": SPR + "bibiana_warrior_sit_fire.png", "flip": false, "scale": 1.0, "idle": "", "walk": "", "attack": "", "hit": "", "death": "", "placeholder": false},
	"bibiana_warrior_walk_0": {"sprite": SPR + "bibiana_warrior_walk_0.png", "flip": false, "scale": 1.0, "idle": "", "walk": "", "attack": "", "hit": "", "death": "", "placeholder": false},
	"bibiana_warrior_walk_1": {"sprite": SPR + "bibiana_warrior_walk_1.png", "flip": false, "scale": 1.0, "idle": "", "walk": "", "attack": "", "hit": "", "death": "", "placeholder": false},
	"bibiana_warrior_walk_2": {"sprite": SPR + "bibiana_warrior_walk_2.png", "flip": false, "scale": 1.0, "idle": "", "walk": "", "attack": "", "hit": "", "death": "", "placeholder": false},
	"bibiana_warrior_walk_3": {"sprite": SPR + "bibiana_warrior_walk_3.png", "flip": false, "scale": 1.0, "idle": "", "walk": "", "attack": "", "hit": "", "death": "", "placeholder": false},
	"campfire": {"sprite": SPR + "campfire.png", "flip": false, "scale": 1.0, "idle": "", "walk": "", "attack": "", "hit": "", "death": "", "placeholder": false},
	"iron_chest": {"sprite": SPR + "iron_chest.png", "flip": false, "scale": 1.0, "idle": "", "walk": "", "attack": "", "hit": "", "death": "", "placeholder": false},
	"plague_lamppost": {"sprite": SPR + "plague_lamppost.png", "flip": false, "scale": 1.0, "idle": "", "walk": "", "attack": "", "hit": "", "death": "", "placeholder": false},
	"gothic_tombstone": {"sprite": SPR + "gothic_tombstone.png", "flip": false, "scale": 1.0, "idle": "", "walk": "", "attack": "", "hit": "", "death": "", "placeholder": false},
	"gallows_post": {"sprite": SPR + "gallows_post.png", "flip": false, "scale": 1.0, "idle": "", "walk": "", "attack": "", "hit": "", "death": "", "placeholder": false},
}


## Giro extra (graus) para mostrar o bicho de perfil no palco; 0 quando não define.
static func yaw_offset(id: String) -> float:
	return float((MODELS[id] as Dictionary).get("yaw_offset", 0.0))


## Verdadeiro quando o inimigo é um sprite 2D (ADR-0052).
static func has_sprite(id: String) -> bool:
	return MODELS.has(id) and (MODELS[id] as Dictionary).has("sprite") \
		and ResourceLoader.exists((MODELS[id] as Dictionary)["sprite"] as String)


## Id da Bibiana em combate e no mapa: de costas (visão do duelo) se a arte existir, senão a de frente.
## Só a Guerreira existe em jogo; as outras classes já têm as 4 poses registradas.
static func hero_id(class_id: String = "warrior", pose: String = "back") -> String:
	var id: String = "bibiana_%s_%s" % [class_id, pose]
	return id if has_sprite(id) else "bibiana"


static func sprite_texture(id: String) -> Texture2D:
	return load((MODELS[id] as Dictionary)["sprite"] as String) as Texture2D


static func has_model(id: String) -> bool:
	return MODELS.has(id)


## Cria o modelo com a escala aplicada, dentro de um `Node3D` com o nome do id.
static func spawn(id: String) -> Node3D:
	var entry: Dictionary = MODELS[id]
	if entry.has("sprite"):
		return _spawn_sprite(id, entry)
	var packed: PackedScene = load(entry["path"] as String) as PackedScene
	var root: Node3D = Node3D.new()
	root.name = id
	var inst: Node3D = packed.instantiate() as Node3D
	inst.scale = Vector3.ONE * float(entry["scale"])
	root.add_child(inst)
	return root


## Sprite 2D em pé (billboard preso ao eixo Y, filtro nearest, recebe a luz da cena), com 1 unidade
## de altura e os pés na origem, como os modelos 3D. `flip` vira a figura para o lado da Bibiana.
static func _spawn_sprite(id: String, entry: Dictionary) -> Node3D:
	var root: Node3D = Node3D.new()
	root.name = id
	var tex: Texture2D = load(entry["sprite"] as String) as Texture2D
	var sprite: Sprite3D = Sprite3D.new()
	sprite.texture = tex
	sprite.pixel_size = 1.0 / float(maxi(tex.get_height(), 1))
	sprite.offset = Vector2(0.0, float(tex.get_height()) * 0.5)
	sprite.flip_h = bool(entry.get("flip", false))
	sprite.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
	sprite.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR
	sprite.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
	sprite.shaded = false
	sprite.modulate = Color(1.0, 1.0, 1.0)
	sprite.double_sided = true
	root.add_child(sprite)
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
