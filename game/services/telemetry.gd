class_name Telemetry
extends RefCounted
## Log local de eventos (TASK-013, ADR-0018): uma linha JSON por evento em
## `telemetry.log`, com nós, lutas, lances de moeda e mortes. Fica só no aparelho. Montar
## as linhas é função pura ([method fight_lines], [method run_lines]); gravar acrescenta o
## horário e escreve no arquivo.

const FILE: String = "telemetry.log"

var dir: String
var enabled: bool = true


func _init(log_dir: String = "user://") -> void:
	dir = log_dir
	if not dir.ends_with("/"):
		dir += "/"
	DirAccess.make_dir_recursive_absolute(dir)


func write(lines: Array[Dictionary]) -> void:
	if not enabled or lines.is_empty():
		return
	var file: FileAccess = FileAccess.open(dir + FILE, FileAccess.READ_WRITE) if FileAccess.file_exists(dir + FILE) \
		else FileAccess.open(dir + FILE, FileAccess.WRITE)
	if file == null:
		return
	file.seek_end()
	var now: int = int(Time.get_unix_time_from_system())
	for line: Dictionary in lines:
		var stamped: Dictionary = line.duplicate()
		stamped["t"] = now
		file.store_line(JSON.stringify(stamped))
	file.close()


func clear() -> void:
	if FileAccess.file_exists(dir + FILE):
		DirAccess.remove_absolute(dir + FILE)


## Linhas dos eventos da Descida desde [param from] (nós, luta, ouro, loja, fogueira, fim).
static func run_lines(run: RunState, from: int) -> Array[Dictionary]:
	var lines: Array[Dictionary] = []
	for index: int in range(from, run.history.size()):
		var event: RunEvent = run.history[index]
		match event.type:
			RunEvent.Type.NODE:
				lines.append({"type": "node", "kind": event.label, "id": event.value})
			RunEvent.Type.GOLD:
				lines.append({"type": "gold", "source": event.label, "amount": event.value})
			RunEvent.Type.SPENT:
				lines.append({"type": "spent", "what": event.label, "amount": event.value})
			RunEvent.Type.CAMPFIRE:
				lines.append({"type": "campfire", "action": event.label, "embers": event.value})
			RunEvent.Type.DROP:
				lines.append({"type": "drop", "item": event.label})
			RunEvent.Type.SOLD:
				lines.append({"type": "sold", "item": event.label, "gold": event.value})
			RunEvent.Type.SCENARIO:
				lines.append({"type": "scenario", "id": event.label, "index": event.value})
			RunEvent.Type.EVENT:
				lines.append({"type": "event", "id": event.label, "node": event.value})
			RunEvent.Type.EVENT_CHOICE:
				lines.append({"type": "event_choice", "choice": event.label, "index": event.value})
			RunEvent.Type.EVENT_COIN:
				lines.append({"type": "event_coin", "choice": event.label, "success": event.value == 1})
			RunEvent.Type.ENDED:
				lines.append({"type": "run_end", "victory": event.value == 1})
	return lines


## Linhas de uma luta terminada: cada lance de moeda, o resumo da luta e, na derrota, a
## morte com a marca de "morte por moeda" (GDD §7 e §23): o golpe fatal foi um lance de
## moeda perdido.
static func fight_lines(combat: Combat, enemy_id: String, level: int) -> Array[Dictionary]:
	var lines: Array[Dictionary] = []
	var turns: int = 0
	var last_coin_index: int = -1
	var last_coin_failed: bool = false
	var last_coin_reason: String = ""
	var fatal_label: String = ""
	var fatal_after_coin: bool = false
	for index: int in combat.history.size():
		var event: CombatEvent = combat.history[index]
		match event.type:
			CombatEvent.Type.TURN:
				if event.side == Combatant.PLAYER:
					turns += 1
			CombatEvent.Type.COIN:
				last_coin_index = index
				last_coin_failed = not event.flag
				last_coin_reason = event.label
				lines.append({"type": "coin", "reason": event.label, "chance": event.value, "success": event.flag,
					"rerolled": event.extra == 1, "enemy": enemy_id})
			CombatEvent.Type.DAMAGE:
				if event.side == Combatant.PLAYER and event.extra <= 0:
					fatal_label = event.label
					# A moeda vem logo antes do golpe que ela decide (só o golpe do inimigo conta).
					fatal_after_coin = last_coin_failed and last_coin_reason == event.label and index - last_coin_index <= 2
	lines.append({"type": "fight", "enemy": enemy_id, "level": level, "turns": turns, "outcome": combat.outcome})
	if combat.outcome == Combat.Outcome.DEFEAT:
		lines.append({"type": "death", "enemy": enemy_id, "level": level, "by": fatal_label, "by_coin": fatal_after_coin})
	return lines
