class_name LightningFlash
extends ColorRect
## Clarão de relâmpago por cima de tudo (TASK-042): dois lampejos curtos. Não bloqueia toque e
## respeita `GfxSettings.flashes` (acessibilidade, GDD §19).


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	color = Color(0.82, 0.88, 1.0, 0.0)


func strike() -> void:
	if not GfxSettings.flashes or not is_inside_tree():
		return
	var tween: Tween = create_tween()
	tween.tween_property(self, "color:a", 0.42, 0.04)
	tween.tween_property(self, "color:a", 0.05, 0.08)
	tween.tween_property(self, "color:a", 0.3, 0.05)
	tween.tween_property(self, "color:a", 0.0, 0.35)
