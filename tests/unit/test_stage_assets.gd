extends GutTest
## TASK-035: contratos dos assets 3D. Todo pacote de `assets/` tem licença registrada, todo inimigo
## do jogo tem modelo que carrega e a cena de prova monta sem erro. A estética é julgada no print.

const ASSETS_DIR: String = "res://assets/"


func test_every_asset_package_is_listed_in_licenses() -> void:
	var licenses: String = FileAccess.get_file_as_string(ASSETS_DIR + "LICENSES.md")
	assert_ne(licenses, "", "assets/LICENSES.md existe")
	for vendor: String in DirAccess.get_directories_at(ASSETS_DIR):
		for package: String in DirAccess.get_directories_at(ASSETS_DIR + vendor):
			var folder: String = "assets/%s/%s/" % [vendor, package]
			assert_true(licenses.contains(folder), "pacote %s sem linha em assets/LICENSES.md" % folder)
			var has_license_text: bool = FileAccess.file_exists(ASSETS_DIR + vendor + "/" + package + "/License.txt") or FileAccess.file_exists(ASSETS_DIR + vendor + "/" + package + "/LICENSE.txt")
			assert_true(has_license_text, "pacote %s sem o texto de licença do autor" % folder)


func test_every_enemy_and_the_hero_have_a_model_that_loads() -> void:
	var data: GameData = DataLoader.load_all()
	var ids: Array[String] = ["bibiana"]
	for enemy_id: String in data.enemies:
		ids.append(enemy_id)
	for id: String in ids:
		assert_true(ModelRegistry.has_model(id), "%s sem modelo no ModelRegistry" % id)
		if not ModelRegistry.has_model(id):
			continue
		var node: Node3D = ModelRegistry.spawn(id)
		assert_not_null(node, id)
		assert_gt(node.get_child_count(), 0, "%s: modelo vazio" % id)
		node.free()


func test_proof_scene_builds_without_error() -> void:
	var scene: PackedScene = load("res://game/presentation/stage/proof_scene.tscn") as PackedScene
	assert_not_null(scene)
	var instance: Node = scene.instantiate()
	add_child_autofree(instance)
	assert_true(instance is ProofScene)
	assert_gt(instance.find_children("*", "MeshInstance3D", true, false).size(), 20, "cenário tem peças 3D")


func test_every_registered_sprite_file_loads() -> void:
	for id: String in ModelRegistry.MODELS:
		if not ModelRegistry.has_sprite(id):
			continue
		var tex: Texture2D = ModelRegistry.sprite_texture(id)
		assert_not_null(tex, "%s: sprite não carrega (rode --import depois de gerar com tools/make_sprite.py)" % id)


func test_hero_and_every_game_enemy_use_a_sprite() -> void:
	var data: GameData = DataLoader.load_all()
	assert_true(ModelRegistry.has_sprite("bibiana"))
	for enemy_id: String in data.enemies:
		assert_true(ModelRegistry.has_sprite(enemy_id), "%s sem sprite HD-2D (TASK-066)" % enemy_id)
