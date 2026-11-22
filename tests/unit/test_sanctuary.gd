extends GutTest
## TASK-030 (ADR-0034): Santuário e meta-progresso (Biblioteca, Arsenal e Códice/Bestiário),
## compra de desbloqueios com Ecos, teto de +10% em bônus numéricos permanentes (GDD §9)
## e persistência em SaveStore.

const DIR: String = "user://test_sanctuary_saves/"

var _data: GameData
var _store: SaveStore


func before_all() -> void:
	_data = DataLoader.load_all()


func before_each() -> void:
	_store = SaveStore.new(DIR)
	_store.clear_run()
	DirAccess.remove_absolute(DIR + SaveStore.META_FILE)


func after_all() -> void:
	DirAccess.remove_absolute(DIR + SaveStore.META_FILE)
	DirAccess.remove_absolute(DIR + SaveStore.RUN_FILE)


func test_catalog_respects_permanent_numeric_bonus_cap() -> void:
	assert_eq(SanctuaryRules.catalog().size(), 4)
	assert_eq(SanctuaryRules.wing_catalog("library").size(), 2)
	assert_eq(SanctuaryRules.wing_catalog("arsenal").size(), 2)
	assert_lte(SanctuaryRules.IRON_SKIN_HP_PERCENT, SanctuaryRules.MAX_PERMANENT_BONUS_PERCENT,
		"bônus permanente de HP respeita o teto de +10% do GDD §9")
	assert_lte(SanctuaryRules.IRON_SKIN_DEF_PERCENT, SanctuaryRules.MAX_PERMANENT_BONUS_PERCENT,
		"bônus permanente de DEF respeita o teto de +10% do GDD §9")


func test_buy_upgrades_spends_echoes_and_rejects_duplicates_or_insufficient() -> void:
	var unlocked: Array[String] = []
	assert_false(SanctuaryRules.can_buy("tome_of_fury", 10, unlocked), "saldo insuficiente")
	assert_false(SanctuaryRules.can_buy("unknown_id", 100, unlocked), "id inexistente")
	assert_true(SanctuaryRules.can_buy("tome_of_fury", 20, unlocked))

	var res: Dictionary = SanctuaryRules.buy("tome_of_fury", 20, unlocked)
	assert_true(bool(res["ok"]))
	assert_eq(int(res["echoes"]), 8)
	unlocked.assign(res["unlocks"])
	assert_true(unlocked.has("tome_of_fury"))

	var dup: Dictionary = SanctuaryRules.buy("tome_of_fury", 50, unlocked)
	assert_false(bool(dup["ok"]), "não compra duas vezes o mesmo desbloqueio")


func test_meta_unlocks_apply_to_run_state_and_survive_run_save() -> void:
	var base_run: RunState = RunState.new(_data, 21)
	var unlocked: Array[String] = ["tome_of_fury", "tome_of_edge", "blessing_iron_skin", "pack_of_provisions"]
	var meta_run: RunState = RunState.new(_data, 21, "warrior", [], 0, null, false, unlocked)

	assert_true(meta_run.learned_skills.has("war_cry"), "tome_of_fury ensina Grito de Guerra no início")
	assert_eq(meta_run.gold, base_run.gold + SanctuaryRules.PROVISIONS_STARTING_GOLD, "pack_of_provisions dá ouro inicial")
	assert_eq(meta_run.consumable_count("dirty_ether"), base_run.consumable_count("dirty_ether") + 1, "pack_of_provisions dá 1 Éter Sujo")
	assert_gt(meta_run.player_stats().max_hp, base_run.player_stats().max_hp, "blessing_iron_skin sobe HP máx.")
	assert_gt(meta_run.player_stats().defense, base_run.player_stats().defense, "blessing_iron_skin sobe DEF")

	# Fogueira acesa com tome_of_edge ativa sharpen_edge por 2 combates.
	var node: MapNode = meta_run.options()[0]
	node.kind = MapNode.Kind.BONFIRE
	node.enemy_id = ""
	assert_true(meta_run.choose_node(node.id))
	assert_true(meta_run.light_campfire())
	assert_eq(int(meta_run.buffs.get("sharpen_edge", 0)), SanctuaryRules.EDGE_CAMPFIRE_COMBATS)
	assert_true(meta_run.leave_campfire())

	var saved: Dictionary = RunSave.to_dict(meta_run)
	var loaded: RunState = RunSave.from_dict(_data, saved)
	assert_not_null(loaded)
	assert_eq(loaded.meta_unlocks, meta_run.meta_unlocks)


func test_bestiary_records_kills_and_deaths_for_all_enemies() -> void:
	var bestiary: Dictionary = {}
	var defeated: Array[String] = ["infected_citizen", "giant_rat", "infected_citizen", "bell_warden"]
	bestiary = SanctuaryRules.record_run_in_bestiary(bestiary, defeated, "gravedigger")
	var entries: Array[Dictionary] = SanctuaryRules.bestiary_entries(_data, bestiary)
	assert_eq(entries.size(), 15, "todos os 15 inimigos aparecem no Códice")

	var by_id: Dictionary = {}
	for entry: Dictionary in entries:
		by_id[str(entry["id"])] = entry
	assert_eq(int(by_id["infected_citizen"]["kills"]), 2)
	assert_eq(int(by_id["bell_warden"]["kills"]), 1)
	assert_eq(int(by_id["gravedigger"]["deaths"]), 1)
	assert_true(str(by_id["bell_warden"]["coin_move"]).contains("Badalo"))


func test_game_screen_and_save_store_persist_sanctuary_and_bestiary() -> void:
	assert_true(_store.save_meta(30, 1, [], {"giant_rat": {"kills": 3, "deaths": 0}}))
	var game: GameScreen = GameScreen.new()
	game.map_check_runs = 0
	game.use_thread = false
	game.time_scale = 0.0
	game.save_dir = DIR
	game.telemetry_enabled = false
	game.debug_enabled = false
	add_child_autofree(game)

	var screen: SanctuaryScreen = game.show_sanctuary("library")
	assert_not_null(screen)
	assert_true(screen.buy_upgrade("tome_of_fury"))
	assert_eq(game.echoes, 18)
	assert_true(game.meta_unlocks.has("tome_of_fury"))

	screen.show_tab("arsenal")
	assert_true(screen.buy_upgrade("blessing_iron_skin"))
	assert_eq(game.echoes, 3)

	screen.show_tab("codex")
	var meta: Dictionary = _store.load_meta()
	assert_eq(int(meta["echoes"]), 3)
	assert_eq((meta["unlocks"] as Array).size(), 2)
	assert_eq(int(meta["bestiary"]["giant_rat"]["kills"]), 3)

	game.new_run(19)
	assert_true(game.run.learned_skills.has("war_cry"))
	assert_true(game.run.meta_unlocks.has("blessing_iron_skin"))
