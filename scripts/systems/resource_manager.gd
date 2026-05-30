extends Node
class_name ResourceManager

var resources: Dictionary = {
	"gold": 0, "food": 0, "wood": 0, "faith": 0
}
var income: Dictionary = {
	"gold": 5, "food": 3, "wood": 2, "faith": 1
}

var _timer: float = 0.0
const INTERVAL: float = 5.0

signal changed(type: String, amount: int)

func _process(delta: float) -> void:
	_timer += delta
	if _timer >= INTERVAL:
		_timer = 0.0
		for t in income:
			add(t, income[t])

func initialize(starting: Dictionary) -> void:
	for t in starting:
		if t in resources:
			resources[t] = starting[t]
			changed.emit(t, resources[t])

func add(type: String, amount: int) -> void:
	if type in resources:
		resources[type] += amount
		changed.emit(type, resources[type])

func spend(type: String, amount: int) -> bool:
	if resources.get(type, 0) < amount:
		return false
	resources[type] -= amount
	changed.emit(type, resources[type])
	return true

func can_afford(cost: Dictionary) -> bool:
	for t in cost:
		if resources.get(t, 0) < cost[t]:
			return false
	return true

func spend_cost(cost: Dictionary) -> bool:
	if not can_afford(cost):
		return false
	for t in cost:
		spend(t, cost[t])
	return true

func get_amount(type: String) -> int:
	return resources.get(type, 0)
