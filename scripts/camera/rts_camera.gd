extends Camera2D
class_name RTSCamera

@export var pan_speed: float = 380.0
@export var edge_margin: float = 18.0
@export var edge_pan: bool = true
@export var zoom_step: float = 0.08
@export var zoom_min: float = 0.4
@export var zoom_max: float = 2.2
@export var map_rect: Rect2 = Rect2(Vector2.ZERO, Vector2(3200, 3200))

var _target_zoom: float = 1.0
var _mid_drag: bool = false

func _ready() -> void:
	_target_zoom = zoom.x
	make_current()

func _process(delta: float) -> void:
	_kbd_pan(delta)
	_edge_pan(delta)
	_lerp_zoom(delta)
	_clamp_pos()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_WHEEL_UP and mb.pressed:
			_target_zoom = clampf(_target_zoom - zoom_step, zoom_min, zoom_max)
		elif mb.button_index == MOUSE_BUTTON_WHEEL_DOWN and mb.pressed:
			_target_zoom = clampf(_target_zoom + zoom_step, zoom_min, zoom_max)
		elif mb.button_index == MOUSE_BUTTON_MIDDLE:
			_mid_drag = mb.pressed
	elif event is InputEventMouseMotion and _mid_drag:
		position -= (event as InputEventMouseMotion).relative / zoom.x

func _kbd_pan(delta: float) -> void:
	var dir := Vector2.ZERO
	if Input.is_action_pressed("move_up"):    dir.y -= 1.0
	if Input.is_action_pressed("move_down"):  dir.y += 1.0
	if Input.is_action_pressed("move_left"):  dir.x -= 1.0
	if Input.is_action_pressed("move_right"): dir.x += 1.0
	if dir != Vector2.ZERO:
		position += dir.normalized() * pan_speed * delta / zoom.x

func _edge_pan(delta: float) -> void:
	if not edge_pan:
		return
	var mp := get_viewport().get_mouse_position()
	var vs := get_viewport().get_visible_rect().size
	var dir := Vector2.ZERO
	if mp.x < edge_margin:           dir.x -= 1.0
	elif mp.x > vs.x - edge_margin:  dir.x += 1.0
	if mp.y < edge_margin:           dir.y -= 1.0
	elif mp.y > vs.y - edge_margin:  dir.y += 1.0
	if dir != Vector2.ZERO:
		position += dir * pan_speed * delta / zoom.x

func _lerp_zoom(delta: float) -> void:
	var z := lerpf(zoom.x, _target_zoom, delta * 12.0)
	zoom = Vector2(z, z)

func _clamp_pos() -> void:
	position.x = clampf(position.x, map_rect.position.x, map_rect.end.x)
	position.y = clampf(position.y, map_rect.position.y, map_rect.end.y)
