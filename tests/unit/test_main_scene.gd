extends GutTest
## TASK-001: a cena inicial está configurada, carrega e entra na árvore sem erro.


func test_main_scene_loads_and_enters_the_tree() -> void:
	var path: String = ProjectSettings.get_setting("application/run/main_scene", "")
	assert_ne(path, "", "application/run/main_scene precisa estar definido")

	var packed: PackedScene = load(path) as PackedScene
	assert_not_null(packed, "a cena principal precisa carregar")
	if packed == null:
		return

	var instance: Node = packed.instantiate()
	add_child_autofree(instance)
	assert_true(instance is Control, "a raiz da interface é um Control")
	assert_true(instance.is_inside_tree(), "a cena precisa entrar na árvore")
