class_name CombatItem
extends RefCounted
## Consumível usado no combate. Os valores de cura vêm dos dados dos itens (TASK-005).

var id: String = ""
var heal_hp_percent: int = 0
var heal_mp_percent: int = 0


static func make(item_id: String, hp_percent: int, mp_percent: int = 0) -> CombatItem:
	var item: CombatItem = CombatItem.new()
	item.id = item_id
	item.heal_hp_percent = hp_percent
	item.heal_mp_percent = mp_percent
	return item
