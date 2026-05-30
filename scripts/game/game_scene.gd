extends Node2D

const UnitScene := preload("res://scenes/entities/unit.tscn")
const BuildingScene := preload("res://scenes/entities/building.tscn")

var resource_manager: ResourceManager
var selection_system: SelectionSystem
var combat_manager: CombatManager
var ai_controller: AIController
var camera: RTSCamera
var hud: Node

var _units_layer: Node2D
var _buildings_layer: Node2D
var _player_base_pos: Vector2 = Vector2(600, 600)
var _enemy_base_pos: Vector2 = Vector2(2400, 2400)

func _ready() -> void:
	_build_world()
	_init_systems()
	_spawn_player_start()
	_spawn_enemy_start()
	_connect_signals()

func _build_world() -> void:
	# Background map
	var bg := ColorRect.new()
	bg.color = Color(0.18, 0.28, 0.12)
	bg.position = Vector2.ZERO
	bg.size = Vector2(3200, 3200)
	bg.z_index = -10
	add_child(bg)

	# Grid lines for visual reference
	var grid := Node2D.new()
	grid.name = "Grid"
	grid.z_index = -9
	grid.set_script(load("res://scripts/game/map_grid.gd"))
	add_child(grid)

	_units_layer = Node2D.new()
	_units_layer.name = "Units"
	add_child(_units_layer)

	_buildings_layer = Node2D.new()
	_buildings_layer.name = "Buildings"
	add_child(_buildings_layer)

func _init_systems() -> void:
	# Camera
	camera = RTSCamera.new()
	camera.position = _player_base_pos
	camera.map_rect = Rect2(Vector2.ZERO, Vector2(3200, 3200))
	add_child(camera)

	# Resources
	resource_manager = ResourceManager.new()
	add_child(resource_manager)
	var nation := GameManager.get_nation(GameManager.player_nation)
	resource_manager.initialize(nation.get("starting_resources", {}))

	# Selection
	selection_system = SelectionSystem.new()
	add_child(selection_system)
	selection_system.setup(camera)

	# Combat
	combat_manager = CombatManager.new()
	add_child(combat_manager)

	# AI
	ai_controller = AIController.new()
	ai_controller.set_player_base(_player_base_pos)
	add_child(ai_controller)

	# HUD
	var hud_scene := load("res://scenes/main/hud.tscn") as PackedScene
	hud = hud_scene.instantiate() if hud_scene else _build_hud_fallback()
	add_child(hud)
	if hud.has_method("setup"):
		hud.setup(resource_manager)

func _build_hud_fallback() -> Node:
	var script := load("res://scripts/ui/hud.gd")
	var h := CanvasLayer.new()
	h.set_script(script)
	return h

func _spawn_player_start() -> void:
	# Town hall
	var th := _spawn_building(_player_base_pos, Entity.Team.PLAYER, "townhall")
	th.entity_name = "Rathaus"
	th.max_health = 1000.0
	th.current_health = 1000.0
	th.production_time = 10.0

	# 3 starting units
	var offsets := [Vector2(-80, 80), Vector2(0, 100), Vector2(80, 80)]
	for off in offsets:
		var u := _spawn_unit(_player_base_pos + off, Entity.Team.PLAYER)
		u.entity_name = "Krieger"

func _spawn_enemy_start() -> void:
	var th := _spawn_building(_enemy_base_pos, Entity.Team.ENEMY, "townhall")
	th.entity_name = "Feind-Rathaus"
	th.max_health = 800.0
	th.current_health = 800.0

	for i in range(4):
		var angle := TAU * i / 4.0
		var pos := _enemy_base_pos + Vector2(cos(angle), sin(angle)) * 90.0
		var u := _spawn_unit(pos, Entity.Team.ENEMY)
		u.entity_name = "Feind"
		u.move_speed = 90.0

func _spawn_unit(pos: Vector2, team: Entity.Team) -> Unit:
	var unit := UnitScene.instantiate() as Unit
	unit.team = team
	unit.global_position = pos
	_units_layer.add_child(unit)
	return unit

func _spawn_building(pos: Vector2, team: Entity.Team, type: String) -> Building:
	var b := BuildingScene.instantiate() as Building
	b.team = team
	b.building_type = type
	b.global_position = pos
	_buildings_layer.add_child(b)
	return b

func _connect_signals() -> void:
	if selection_system:
		selection_system.selection_changed.connect(_on_selection_changed)

	if combat_manager:
		combat_manager.entity_killed.connect(_on_entity_killed)

	if hud and hud.has_signal("unit_production_requested"):
		hud.unit_production_requested.connect(_on_production_requested)

func _on_selection_changed(entities: Array) -> void:
	if hud and hud.has_method("show_selection"):
		hud.show_selection(entities)

func _on_entity_killed(_killer: Entity, victim: Entity) -> void:
	if victim is Building and (victim as Building).building_type == "townhall":
		if victim.team == Entity.Team.ENEMY:
			_game_over(true)
		elif victim.team == Entity.Team.PLAYER:
			_game_over(false)

func _on_production_requested(unit_type: String) -> void:
	if selection_system == null:
		return
	for e in selection_system.selected:
		if e is Building and (e as Building).team == Entity.Team.PLAYER:
			var b := e as Building
			if resource_manager.spend_cost({"gold": 50, "food": 30}):
				if b.enqueue(unit_type):
					b.production_done.connect(func(type, rally): _spawn_unit(rally, Entity.Team.PLAYER), CONNECT_ONE_SHOT)
				else:
					resource_manager.add("gold", 50)
					resource_manager.add("food", 30)
			break

func _game_over(player_won: bool) -> void:
	var overlay := ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.65)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var lbl := Label.new()
	lbl.text = "SIEG!" if player_won else "NIEDERLAGE"
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	lbl.add_theme_font_size_override("font_size", 64)
	lbl.add_theme_color_override("font_color", Color.GOLD if player_won else Color.RED)
	overlay.add_child(lbl)

	var back_btn := Button.new()
	back_btn.text = "Zurück zum Menü"
	back_btn.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	back_btn.position = Vector2(-100, -80)
	back_btn.custom_minimum_size = Vector2(200, 44)
	back_btn.pressed.connect(GameManager.return_to_menu)
	overlay.add_child(back_btn)

	var canvas := CanvasLayer.new()
	canvas.layer = 50
	canvas.add_child(overlay)
	add_child(canvas)

	get_tree().paused = false
