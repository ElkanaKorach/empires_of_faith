extends Entity
class_name Building

@export var building_type: String = "townhall"
@export var production_time: float = 12.0
@export var max_queue: int = 5

var _queue: Array[String] = []
var _prod_timer: float = 0.0
var _is_producing: bool = false
var _rally: Vector2 = Vector2.ZERO
var _color: Color = Color(0.15, 0.35, 0.75)
var _size: Vector2 = Vector2(48, 48)

signal production_done(unit_type: String, rally_pos: Vector2)
signal queue_changed(progress: float, queue_copy: Array)

func _ready() -> void:
	super._ready()
	add_to_group("buildings")
	entity_type = EntityType.BUILDING
	selection_radius = 30.0
	max_health = 600.0
	current_health = max_health
	_rally = global_position + Vector2(70, 0)
	_refresh_color()

func _refresh_color() -> void:
	match team:
		Team.PLAYER: _color = Color(0.15, 0.35, 0.75)
		Team.ENEMY:  _color = Color(0.75, 0.1, 0.1)
		_:           _color = Color(0.4, 0.4, 0.4)

func _process(delta: float) -> void:
	if not is_alive:
		return
	_handle_production(delta)

func _handle_production(delta: float) -> void:
	if _queue.is_empty():
		if _is_producing:
			_is_producing = false
			queue_changed.emit(0.0, [])
		return
	_is_producing = true
	_prod_timer += delta
	queue_changed.emit(_prod_timer / production_time, _queue.duplicate())
	if _prod_timer >= production_time:
		_finish()

func _finish() -> void:
	var unit_type: String = _queue.pop_front()
	_prod_timer = 0.0
	production_done.emit(unit_type, _rally)
	if _queue.is_empty():
		_is_producing = false
	queue_changed.emit(0.0, _queue.duplicate())

func enqueue(unit_type: String) -> bool:
	if _queue.size() >= max_queue:
		return false
	_queue.append(unit_type)
	return true

func cancel(index: int = 0) -> void:
	if index < _queue.size():
		_queue.remove_at(index)
	if index == 0:
		_prod_timer = 0.0
	queue_changed.emit(get_progress(), _queue.duplicate())

func get_progress() -> float:
	if not _is_producing:
		return 0.0
	return _prod_timer / production_time

func get_queue_copy() -> Array:
	return _queue.duplicate()

func set_rally(point: Vector2) -> void:
	_rally = point

func _draw() -> void:
	if not is_alive:
		return
	var half := _size * 0.5
	draw_rect(Rect2(-half, _size), _color)
	draw_rect(Rect2(-half, _size), _color.darkened(0.3), false, 2.0)

	# Production progress bar
	if _is_producing:
		var prog := get_progress()
		var bw := _size.x
		var by := half.y + 6.0
		draw_rect(Rect2(Vector2(-bw * 0.5, by), Vector2(bw, 5)), Color(0.1, 0.1, 0.1))
		draw_rect(Rect2(Vector2(-bw * 0.5, by), Vector2(bw * prog, 5)), Color(1.0, 0.85, 0.0))

	_draw_health_bar()
	_draw_selection_ring()
