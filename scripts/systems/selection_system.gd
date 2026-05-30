extends Node
class_name SelectionSystem

var selected: Array = []
var _camera: Camera2D = null
var _box_selecting: bool = false
var _box_start: Vector2 = Vector2.ZERO
var _box_current: Vector2 = Vector2.ZERO
var _sel_box: ColorRect = null

signal selection_changed(entities: Array)
signal move_ordered(units: Array, destination: Vector2)
signal attack_ordered(units: Array, target: Entity)

func _ready() -> void:
	var canvas := CanvasLayer.new()
	canvas.layer = 20
	add_child(canvas)
	_sel_box = ColorRect.new()
	_sel_box.color = Color(0.15, 0.9, 0.15, 0.18)
	_sel_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_sel_box.visible = false
	canvas.add_child(_sel_box)

	# Border overlay
	var border := Panel.new()
	border.name = "Border"
	border.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_sel_box.add_child(border)
	var style := StyleBoxFlat.new()
	style.bg_color = Color.TRANSPARENT
	style.border_color = Color(0.15, 0.9, 0.15, 0.9)
	style.set_border_width_all(1)
	border.add_theme_stylebox_override("panel", style)
	border.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

func setup(camera: Camera2D) -> void:
	_camera = camera

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		_on_mouse_button(event as InputEventMouseButton)
	elif event is InputEventMouseMotion and _box_selecting:
		_box_current = (event as InputEventMouseMotion).position
		_update_sel_box()

func _on_mouse_button(event: InputEventMouseButton) -> void:
	var world := _screen_to_world(event.position)

	if event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_box_start = event.position
			_box_current = event.position
			_box_selecting = true
			_sel_box.visible = true
		else:
			_box_selecting = false
			_sel_box.visible = false
			_finalize(event.position, event.shift_pressed)

	elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		_right_click(world)

func _update_sel_box() -> void:
	var r := _screen_rect(_box_start, _box_current)
	_sel_box.position = r.position
	_sel_box.size = r.size

func _finalize(end_screen: Vector2, additive: bool) -> void:
	var box := _screen_rect(_box_start, end_screen)
	var is_drag := box.size.length() > 8.0

	if not additive:
		_deselect_all()

	if is_drag:
		_box_select(box)
	else:
		_click_select(_screen_to_world(end_screen), additive)

	selection_changed.emit(selected.duplicate())

func _click_select(world_pos: Vector2, additive: bool) -> void:
	var hit := _entity_at(world_pos)
	if hit == null:
		if not additive:
			_deselect_all()
		return
	if hit.team != Entity.Team.PLAYER:
		return
	if hit in selected:
		if additive:
			_remove(hit)
	else:
		_add(hit)

func _box_select(screen_box: Rect2) -> void:
	for node in get_tree().get_nodes_in_group("units"):
		if node is Entity and (node as Entity).team == Entity.Team.PLAYER:
			var sp := _world_to_screen(node.global_position)
			if screen_box.has_point(sp):
				_add(node)

func _right_click(world_pos: Vector2) -> void:
	var units: Array = selected.filter(func(e): return e is Unit and (e as Unit).team == Entity.Team.PLAYER)
	if units.is_empty():
		return

	var target := _entity_at(world_pos)
	if target != null and target.team == Entity.Team.ENEMY:
		for u in units:
			(u as Unit).attack_entity(target)
		attack_ordered.emit(units, target)
		return

	# Formation move
	var count := units.size()
	var cols := ceili(sqrt(float(count)))
	var spacing := 44.0
	for i in range(units.size()):
		var row := i / cols
		var col := i % cols
		var offset := Vector2((col - cols * 0.5) * spacing, row * spacing)
		(units[i] as Unit).move_to(world_pos + offset)
	move_ordered.emit(units, world_pos)

func _entity_at(world_pos: Vector2) -> Entity:
	var best: Entity = null
	var best_d := INF
	for node in get_tree().get_nodes_in_group("entities"):
		if node is Entity:
			var e := node as Entity
			if not e.is_alive:
				continue
			var d := world_pos.distance_to(e.global_position)
			if d <= e.selection_radius and d < best_d:
				best = e
				best_d = d
	return best

func _add(e: Entity) -> void:
	if e not in selected:
		selected.append(e)
		e.set_selected(true)

func _remove(e: Entity) -> void:
	selected.erase(e)
	e.set_selected(false)

func _deselect_all() -> void:
	for e in selected:
		if is_instance_valid(e):
			(e as Entity).set_selected(false)
	selected.clear()

func _screen_to_world(sp: Vector2) -> Vector2:
	if _camera:
		var vp := get_viewport().get_visible_rect().size
		return _camera.global_position + (sp - vp * 0.5) / _camera.zoom
	return sp

func _world_to_screen(wp: Vector2) -> Vector2:
	if _camera:
		var vp := get_viewport().get_visible_rect().size
		return (wp - _camera.global_position) * _camera.zoom + vp * 0.5
	return wp

func _screen_rect(a: Vector2, b: Vector2) -> Rect2:
	return Rect2(
		Vector2(minf(a.x, b.x), minf(a.y, b.y)),
		Vector2(absf(b.x - a.x), absf(b.y - a.y))
	)
