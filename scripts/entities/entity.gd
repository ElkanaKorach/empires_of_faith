extends Node2D
class_name Entity

enum Team { PLAYER, ENEMY, NEUTRAL }
enum EntityType { UNIT, BUILDING }

@export var entity_name: String = "Entity"
@export var max_health: float = 100.0
@export var team: Team = Team.PLAYER
@export var entity_type: EntityType = EntityType.UNIT

var selection_radius: float = 20.0
var current_health: float = 0.0
var is_selected: bool = false
var is_alive: bool = true

signal health_changed(current: float, maximum: float)
signal died
signal selection_changed(value: bool)

func _ready() -> void:
	current_health = max_health
	add_to_group("entities")

func take_damage(amount: float) -> void:
	if not is_alive:
		return
	current_health = maxf(0.0, current_health - amount)
	health_changed.emit(current_health, max_health)
	queue_redraw()
	if current_health <= 0.0:
		_die()

func heal(amount: float) -> void:
	if not is_alive:
		return
	current_health = minf(max_health, current_health + amount)
	health_changed.emit(current_health, max_health)
	queue_redraw()

func _die() -> void:
	is_alive = false
	died.emit()
	queue_free()

func set_selected(value: bool) -> void:
	if is_selected == value:
		return
	is_selected = value
	selection_changed.emit(value)
	queue_redraw()

func get_health_ratio() -> float:
	if max_health <= 0.0:
		return 1.0
	return current_health / max_health

func _draw_health_bar() -> void:
	var bar_w := 36.0
	var bar_h := 4.0
	var bar_y := -selection_radius - 10.0
	draw_rect(Rect2(Vector2(-bar_w * 0.5, bar_y), Vector2(bar_w, bar_h)), Color(0.2, 0.0, 0.0))
	draw_rect(Rect2(Vector2(-bar_w * 0.5, bar_y), Vector2(bar_w * get_health_ratio(), bar_h)), Color(0.1, 0.9, 0.1))

func _draw_selection_ring() -> void:
	if is_selected:
		draw_arc(Vector2.ZERO, selection_radius + 3.0, 0.0, TAU, 48, Color(0.1, 1.0, 0.1), 2.0)
