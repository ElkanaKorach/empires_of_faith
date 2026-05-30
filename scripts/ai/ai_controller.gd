extends Node
class_name AIController

@export var difficulty: int = 1
@export var ai_team: Entity.Team = Entity.Team.ENEMY

var resource_manager: ResourceManager = null
var player_base_pos: Vector2 = Vector2(400, 400)
var _think_timer: float = 0.0
var _attack_cooldown: float = 0.0

const THINK_INTERVAL: float = 4.0
const ATTACK_INTERVAL: float = 20.0

func _ready() -> void:
	resource_manager = ResourceManager.new()
	add_child(resource_manager)
	var nations := GameManager.get_all_nations()
	if nations.size() > 1:
		var ai_nation := GameManager.get_nation(nations[1])
		resource_manager.initialize(ai_nation.get("starting_resources", {}))

func _process(delta: float) -> void:
	_think_timer += delta
	_attack_cooldown -= delta
	if _think_timer >= THINK_INTERVAL:
		_think_timer = 0.0
		_think()

func _think() -> void:
	var units := _get_ai_units()
	if units.is_empty():
		return
	match difficulty:
		1: _easy(units)
		2: _medium(units)
		_: _hard(units)

func _easy(units: Array) -> void:
	if _attack_cooldown > 0.0 or randf() > 0.3:
		return
	_attack_cooldown = ATTACK_INTERVAL
	for u in units:
		var target := player_base_pos + Vector2(randf_range(-120, 120), randf_range(-120, 120))
		(u as Unit).move_to(target)

func _medium(units: Array) -> void:
	if _attack_cooldown > 0.0:
		return
	_attack_cooldown = ATTACK_INTERVAL * 0.7
	for u in units:
		(u as Unit).move_to(player_base_pos + Vector2(randf_range(-80, 80), randf_range(-80, 80)))

func _hard(units: Array) -> void:
	_attack_cooldown = ATTACK_INTERVAL * 0.4
	var player_units: Array = []
	for node in get_tree().get_nodes_in_group("units"):
		if node is Unit and (node as Unit).team == Entity.Team.PLAYER:
			player_units.append(node)
	for u in units:
		if not player_units.is_empty():
			var target := player_units[randi() % player_units.size()] as Entity
			(u as Unit).attack_entity(target)
		else:
			(u as Unit).move_to(player_base_pos)

func _get_ai_units() -> Array:
	var result: Array = []
	for node in get_tree().get_nodes_in_group("units"):
		if node is Unit and (node as Unit).team == ai_team:
			result.append(node)
	return result

func set_player_base(pos: Vector2) -> void:
	player_base_pos = pos
