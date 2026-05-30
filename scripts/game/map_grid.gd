extends Node2D

const GRID_SIZE := 128
const MAP_W := 3200
const MAP_H := 3200
const LINE_COLOR := Color(0.22, 0.35, 0.16, 0.35)

func _draw() -> void:
	var x := 0
	while x <= MAP_W:
		draw_line(Vector2(x, 0), Vector2(x, MAP_H), LINE_COLOR, 1.0)
		x += GRID_SIZE
	var y := 0
	while y <= MAP_H:
		draw_line(Vector2(0, y), Vector2(MAP_W, y), LINE_COLOR, 1.0)
		y += GRID_SIZE
