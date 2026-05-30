extends Entity
class_name Unit

@export var move_speed: float = 110.0
@export var attack_damage: float = 12.0
@export var attack_range: float = 55.0
@export var attack_cooldown: float = 1.4

var _target_pos: Vector2 = Vector2.ZERO
var _attack_target: Entity = null
var _attack_timer: float = 0.0
var _is_moving: bool = false
var _unit_color: Color = Color.CORNFLOWER_BLUE

signal arrived
signal attacked(target: Entity)

func _ready() -> void:
	super._ready()
	add_to_group("units")
	entity_type = EntityType.UNIT
	selection_radius = 16.0
	_target_pos = global_position
	_refresh_color()

func _refresh_color() -> void:
	if team == Team.PLAYER:
		var nation := GameManager.get_nation(GameManager.player_nation)
		_unit_color = nation.get("color", Color.CORNFLOWER_BLUE)
	elif team == Team.ENEMY:
		_unit_color = Color(0.9, 0.15, 0.15)
	else:
		_unit_color = Color.GRAY

func _process(delta: float) -> void:
	if not is_alive:
		return
	_handle_combat(delta)
	_handle_movement(delta)

func _handle_movement(delta: float) -> void:
	if not _is_moving:
		return
	var diff := _target_pos - global_position
	var dist := diff.length()
	if dist < 4.0:
		global_position = _target_pos
		_is_moving = false
		arrived.emit()
		queue_redraw()
		return
	global_position += diff.normalized() * move_speed * delta
	queue_redraw()

func _handle_combat(delta: float) -> void:
	if _attack_target == null or not is_instance_valid(_attack_target) or not _attack_target.is_alive:
		_attack_target = null
		return
	var dist := global_position.distance_to(_attack_target.global_position)
	if dist > attack_range:
		_move_internal(_attack_target.global_position)
		return
	_is_moving = false
	_attack_timer -= delta
	if _attack_timer <= 0.0:
		_do_attack()
		_attack_timer = attack_cooldown

func _do_attack() -> void:
	if is_instance_valid(_attack_target) and _attack_target.is_alive:
		_attack_target.take_damage(attack_damage)
		attacked.emit(_attack_target)

func _move_internal(destination: Vector2) -> void:
	_target_pos = destination
	_is_moving = true

func move_to(destination: Vector2) -> void:
	_target_pos = destination
	_is_moving = true
	_attack_target = null

func attack_entity(target: Entity) -> void:
	_attack_target = target
	_attack_timer = 0.0

func stop() -> void:
	_is_moving = false
	_attack_target = null
	_target_pos = global_position

func _draw() -> void:
	if not is_alive:
		return
	draw_circle(Vector2.ZERO, 13.0, _unit_color)
	draw_arc(Vector2.ZERO, 13.0, 0.0, TAU, 32, _unit_color.darkened(0.4), 1.5)
	if _is_moving:
		var dir := (_target_pos - global_position).normalized()
		draw_line(Vector2.ZERO, dir * 15.0, Color.WHITE, 1.5)
	_draw_health_bar()
	_draw_selection_ring()
