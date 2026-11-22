class_name TrailBar
extends ProgressBar
## Barra de HP/MP com rastro de dano (Estudo §3.3, UI-T15): quando o valor cai, uma faixa clara
## fica para trás e some depois de um instante, mostrando o tamanho do golpe. Subir não deixa
## rastro. Só apresentação.

const TRAIL_COLOR: Color = Color(0.86, 0.78, 0.62, 0.85)
const HOLD_SECONDS: float = 0.35
const DRAIN_SECONDS: float = 0.45

var _trail: ColorRect
var _trail_value: float = 0.0
var _tween: Tween


func _ready() -> void:
	_trail = ColorRect.new()
	_trail.color = TRAIL_COLOR
	_trail.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_trail.show_behind_parent = true
	add_child(_trail)
	move_child(_trail, 0)
	_trail_value = value
	value_changed.connect(_on_value_changed)
	resized.connect(_layout_trail)
	_layout_trail()


## Para a barra sem animar (início de luta): rastro igual ao valor.
func snap() -> void:
	if _tween != null:
		_tween.kill()
	_trail_value = value
	_layout_trail()


## Valor do rastro (para testes).
func trail_value() -> float:
	return _trail_value


func _on_value_changed(new_value: float) -> void:
	if new_value >= _trail_value or not is_inside_tree() or max_value <= 0.0:
		snap()
		return
	if _tween != null:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_interval(HOLD_SECONDS)
	_tween.tween_method(_set_trail, _trail_value, new_value, DRAIN_SECONDS)
	_layout_trail()


func _set_trail(v: float) -> void:
	_trail_value = v
	_layout_trail()


func _layout_trail() -> void:
	if _trail == null or max_value <= 0.0:
		return
	var ratio_now: float = clampf(value / max_value, 0.0, 1.0)
	var ratio_trail: float = clampf(_trail_value / max_value, 0.0, 1.0)
	_trail.position = Vector2(size.x * ratio_now, 1.0)
	_trail.size = Vector2(maxf(size.x * (ratio_trail - ratio_now), 0.0), maxf(size.y - 2.0, 0.0))
