extends GutTest
## Atmosfera comum das cenas 3D (TASK-055, ADR-0043).


func test_ambient_is_dark_and_cold() -> void:
	assert_lte(Atmosphere.AMBIENT_ENERGY, 0.52, "estudo D-ART-1: ambiente entre 0,40 e 0,52")
	assert_gte(Atmosphere.AMBIENT_ENERGY, 0.40)
	assert_gt(Atmosphere.AMBIENT_COLOR.b, Atmosphere.AMBIENT_COLOR.r, "tom azul-ardósia")


func test_apply_turns_fog_on_and_off() -> void:
	var env: Environment = Environment.new()
	Atmosphere.apply(env)
	assert_true(env.fog_enabled)
	assert_almost_eq(env.ambient_light_energy, Atmosphere.AMBIENT_ENERGY, 0.0001)
	Atmosphere.apply(env, false)
	assert_false(env.fog_enabled)


func test_focus_spot_is_warm_and_above_the_target() -> void:
	var spot: SpotLight3D = Atmosphere.make_focus_spot(Vector3(0, 1.9, 0))
	assert_gt(spot.light_color.r, spot.light_color.b, "luz de tocha, quente")
	assert_gt(spot.position.y, 1.9)
	spot.free()


func test_post_fx_has_bayer_dither_and_combat_blur() -> void:
	assert_true(PostFx.SHADER_CODE.contains("bayer4"))
	assert_lt(PostFx.COMBAT_BLUR, 1.3, "D-ART-2: menos desfoque no combate")
	var was: bool = GfxSettings.post_fx
	GfxSettings.post_fx = true
	var mat: ShaderMaterial = PostFx.material(PostFx.COMBAT_BLUR)
	assert_almost_eq(float(mat.get_shader_parameter("blur_amount")), PostFx.COMBAT_BLUR, 0.0001)
	GfxSettings.post_fx = was


func test_campfire_backdrop_lights_and_puts_out_the_fire() -> void:
	var backdrop: Scene3DBackdrop = Scene3DBackdrop.new()
	backdrop.kind = "campfire"
	backdrop.time_scale = 0.0
	backdrop.fire_lit = false
	add_child_autofree(backdrop)
	await get_tree().process_frame
	assert_false(backdrop.fire_lit)
	for part: Node3D in backdrop._fire_parts:
		assert_false(part.visible, "apagada: sem chama nem faísca")
	backdrop.set_fire_lit(true)
	for part: Node3D in backdrop._fire_parts:
		assert_true(part.visible)
	assert_gt(backdrop._fire_parts.size(), 0)


func test_no_game_scene_uses_green_pines() -> void:
	for path: String in ["res://game/presentation/map3d", "res://game/presentation/combat3d", "res://game/presentation/camp3d", "res://game/presentation/scenario"]:
		for file: String in DirAccess.get_files_at(path):
			if file.ends_with(".gd"):
				var text: String = FileAccess.get_file_as_string(path + "/" + file)
				assert_false(text.contains("pine-crooked") or text.contains("pine-fall"), "%s usa pinheiro verde" % file)
