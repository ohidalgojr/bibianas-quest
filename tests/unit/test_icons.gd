extends GutTest
## TASK-043: todo id do jogo tem ícone e todo arquivo citado existe.


func test_every_file_in_the_tables_exists() -> void:
	for file_name: String in IconRegistry.all_files():
		assert_true(ResourceLoader.exists(IconRegistry.DIR + file_name + ".png"), "ícone %s existe" % file_name)


func test_every_item_skill_effect_and_node_has_an_icon() -> void:
	var data: GameData = DataLoader.load_all()
	for id: String in data.items:
		assert_not_null(IconRegistry.texture_for("item", id), "item %s sem ícone" % id)
	for id: String in data.combat_skills:
		assert_not_null(IconRegistry.texture_for("skill", id), "skill %s sem ícone" % id)
	for id: String in data.campfire_skills:
		assert_not_null(IconRegistry.texture_for("skill", id), "skill %s sem ícone" % id)
	for kind: String in CombatEffect.Kind.keys():
		assert_not_null(IconRegistry.texture_for("effect", kind.to_lower()), "efeito %s sem ícone" % kind)
	for index: int in MapNode.Kind.size():
		assert_not_null(IconRegistry.texture_for("node", str(index)), "nó %d sem ícone" % index)
	assert_not_null(IconRegistry.texture_for("disease", Diseases.LEPTOSPIROSIS))
