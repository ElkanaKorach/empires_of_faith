extends CanvasLayer

var _res_labels: Dictionary = {}
var _info_panel: Control
var _info_label: Label
var _prod_container: HBoxContainer
var _prod_buttons: Array = []

const PANEL_COLOR := Color(0.05, 0.05, 0.12, 0.88)
const ACCENT := Color(0.7, 0.55, 0.1)

var resource_manager: ResourceManager = null

signal unit_production_requested(unit_type: String)

func _ready() -> void:
	layer = 15
	_build_resource_bar()
	_build_info_panel()
	_build_minimap_placeholder()

func setup(res_mgr: ResourceManager) -> void:
	resource_manager = res_mgr
	res_mgr.changed.connect(_on_resource_changed)
	_refresh_all_resources()

func _build_resource_bar() -> void:
	var bar := PanelContainer.new()
	bar.set_anchors_preset(Control.PRESET_TOP_WIDE)
	bar.custom_minimum_size = Vector2(0, 36)
	var style := StyleBoxFlat.new()
	style.bg_color = PANEL_COLOR
	style.border_color = ACCENT
	style.border_width_bottom = 1
	bar.add_theme_stylebox_override("panel", style)
	add_child(bar)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 24)
	bar.add_child(hbox)

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(8, 0)
	hbox.add_child(spacer)

	for res_type in ["gold", "food", "wood", "faith"]:
		var icons := {"gold": "🪙", "food": "🌾", "wood": "🪵", "faith": "✝"}
		var lbl := Label.new()
		lbl.text = icons.get(res_type, res_type) + " 0"
		lbl.add_theme_color_override("font_color", Color.WHITE)
		lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		hbox.add_child(lbl)
		_res_labels[res_type] = lbl

	# Pause / menu button on right
	var right_spacer := Control.new()
	right_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(right_spacer)

	var esc_lbl := Label.new()
	esc_lbl.text = "[Esc] Menü  [WASD] Kamera  [Scroll] Zoom"
	esc_lbl.add_theme_color_override("font_color", Color(0.55, 0.55, 0.6))
	esc_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hbox.add_child(esc_lbl)

	var right_pad := Control.new()
	right_pad.custom_minimum_size = Vector2(8, 0)
	hbox.add_child(right_pad)

func _build_info_panel() -> void:
	_info_panel = PanelContainer.new()
	_info_panel.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	_info_panel.position = Vector2(0, -160)
	_info_panel.custom_minimum_size = Vector2(300, 160)
	_info_panel.visible = false

	var style := StyleBoxFlat.new()
	style.bg_color = PANEL_COLOR
	style.border_color = ACCENT
	style.set_border_width_all(1)
	_info_panel.add_theme_stylebox_override("panel", style)
	add_child(_info_panel)

	var vbox := VBoxContainer.new()
	_info_panel.add_child(vbox)

	_info_label = Label.new()
	_info_label.add_theme_color_override("font_color", Color.WHITE)
	_info_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(_info_label)

	_prod_container = HBoxContainer.new()
	_prod_container.add_theme_constant_override("separation", 6)
	vbox.add_child(_prod_container)

func _build_minimap_placeholder() -> void:
	var mm := PanelContainer.new()
	mm.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	mm.position = Vector2(-170, -170)
	mm.custom_minimum_size = Vector2(160, 160)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.05, 0.12, 0.05, 0.85)
	style.border_color = ACCENT
	style.set_border_width_all(1)
	mm.add_theme_stylebox_override("panel", style)
	add_child(mm)

	var lbl := Label.new()
	lbl.text = "Minimapa\n(coming soon)"
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	lbl.add_theme_color_override("font_color", Color(0.35, 0.5, 0.35))
	mm.add_child(lbl)

func _on_resource_changed(type: String, amount: int) -> void:
	if type in _res_labels:
		var icons := {"gold": "🪙", "food": "🌾", "wood": "🪵", "faith": "✝"}
		(_res_labels[type] as Label).text = icons.get(type, type) + " " + str(amount)

func _refresh_all_resources() -> void:
	if resource_manager == null:
		return
	for t in _res_labels:
		_on_resource_changed(t, resource_manager.get_amount(t))

func show_selection(entities: Array) -> void:
	if entities.is_empty():
		_info_panel.visible = false
		return

	_info_panel.visible = true
	_clear_prod_buttons()

	if entities.size() == 1:
		var e := entities[0] as Entity
		_info_label.text = "%s\nHP: %d / %d" % [
			e.entity_name, int(e.current_health), int(e.max_health)
		]
		if e is Building:
			_show_building_ui(e as Building)
	else:
		_info_label.text = "%d Einheiten ausgewählt" % entities.size()

func _show_building_ui(building: Building) -> void:
	var nation := GameManager.get_nation(GameManager.player_nation)
	var units: Array = nation.get("units", [])
	for unit_type in units:
		var btn := Button.new()
		btn.text = unit_type
		btn.custom_minimum_size = Vector2(80, 32)
		btn.pressed.connect(func(): unit_production_requested.emit(unit_type))
		_prod_container.add_child(btn)
		_prod_buttons.append(btn)

func _clear_prod_buttons() -> void:
	for btn in _prod_buttons:
		btn.queue_free()
	_prod_buttons.clear()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		GameManager.toggle_pause()
