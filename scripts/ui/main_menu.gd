extends Control

var _nation_panel: Control
var _selected_nation: String = "Byzantium"
var _nation_buttons: Dictionary = {}

const BG_COLOR := Color(0.04, 0.04, 0.09, 1.0)
const BTN_COLOR := Color(0.12, 0.12, 0.22, 1.0)
const BTN_HOVER := Color(0.22, 0.22, 0.38, 1.0)
const ACCENT := Color(0.7, 0.55, 0.1, 1.0)

func _ready() -> void:
	_build_ui()
	GameManager.set_player_nation(_selected_nation)

func _build_ui() -> void:
	# Full background
	var bg := ColorRect.new()
	bg.color = BG_COLOR
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	# Decorative top bar
	var bar := ColorRect.new()
	bar.color = ACCENT
	bar.set_anchors_preset(Control.PRESET_TOP_WIDE)
	bar.custom_minimum_size = Vector2(0, 4)
	add_child(bar)

	# Title
	var title := Label.new()
	title.text = "EMPIRES OF FAITH"
	title.set_anchors_preset(Control.PRESET_CENTER_TOP)
	title.position = Vector2(-200, 60)
	title.custom_minimum_size = Vector2(400, 60)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 36)
	title.add_theme_color_override("font_color", ACCENT)
	add_child(title)

	var subtitle := Label.new()
	subtitle.text = "Ein Echtzeit-Strategiespiel"
	subtitle.set_anchors_preset(Control.PRESET_CENTER_TOP)
	subtitle.position = Vector2(-180, 110)
	subtitle.custom_minimum_size = Vector2(360, 30)
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_color_override("font_color", Color(0.6, 0.6, 0.7))
	add_child(subtitle)

	# Main menu buttons (centered column)
	var menu_vbox := VBoxContainer.new()
	menu_vbox.set_anchors_preset(Control.PRESET_CENTER)
	menu_vbox.position = Vector2(-120, -60)
	menu_vbox.custom_minimum_size = Vector2(240, 240)
	menu_vbox.add_theme_constant_override("separation", 12)
	add_child(menu_vbox)

	var btn_play := _make_button("Einzelspieler starten")
	var btn_nations := _make_button("Fraktion wählen")
	var btn_quit := _make_button("Beenden")

	menu_vbox.add_child(btn_play)
	menu_vbox.add_child(btn_nations)
	menu_vbox.add_child(btn_quit)

	btn_play.pressed.connect(_on_play)
	btn_nations.pressed.connect(_toggle_nations)
	btn_quit.pressed.connect(get_tree().quit)

	# Nation selection panel (hidden by default)
	_nation_panel = _build_nation_panel()
	_nation_panel.visible = false
	add_child(_nation_panel)

	# Selected nation label
	var nation_label := Label.new()
	nation_label.name = "NationLabel"
	nation_label.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	nation_label.position = Vector2(-200, -50)
	nation_label.custom_minimum_size = Vector2(400, 30)
	nation_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	nation_label.add_theme_color_override("font_color", ACCENT)
	nation_label.text = "Fraktion: " + GameManager.get_nation(_selected_nation).get("display_name", _selected_nation)
	add_child(nation_label)

func _build_nation_panel() -> Control:
	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.position = Vector2(-280, -180)
	panel.custom_minimum_size = Vector2(560, 360)

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.08, 0.16)
	style.border_color = ACCENT
	style.set_border_width_all(2)
	style.set_corner_radius_all(6)
	panel.add_theme_stylebox_override("panel", style)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	panel.add_child(vbox)

	var heading := Label.new()
	heading.text = "Wähle deine Fraktion"
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	heading.add_theme_font_size_override("font_size", 18)
	heading.add_theme_color_override("font_color", ACCENT)
	vbox.add_child(heading)

	var grid := GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	vbox.add_child(grid)

	for nation_key in GameManager.get_all_nations():
		var nation := GameManager.get_nation(nation_key)
		var btn := _make_nation_button(nation_key, nation)
		_nation_buttons[nation_key] = btn
		grid.add_child(btn)

	var close_btn := _make_button("Schließen")
	close_btn.pressed.connect(_toggle_nations)
	vbox.add_child(close_btn)

	return panel

func _make_nation_button(key: String, nation: Dictionary) -> Button:
	var btn := Button.new()
	btn.custom_minimum_size = Vector2(160, 80)
	btn.text = nation.get("display_name", key) + "\n" + nation.get("bonus", "")
	btn.autowrap_mode = TextServer.AUTOWRAP_WORD

	var style := StyleBoxFlat.new()
	style.bg_color = Color(nation.get("color", Color.GRAY), 0.2)
	style.border_color = nation.get("color", Color.GRAY)
	style.set_border_width_all(2)
	style.set_corner_radius_all(4)
	btn.add_theme_stylebox_override("normal", style)

	var style_hover := style.duplicate() as StyleBoxFlat
	style_hover.bg_color = Color(nation.get("color", Color.GRAY), 0.45)
	btn.add_theme_stylebox_override("hover", style_hover)

	btn.pressed.connect(func(): _on_nation_selected(key))
	return btn

func _make_button(label: String) -> Button:
	var btn := Button.new()
	btn.text = label
	btn.custom_minimum_size = Vector2(240, 48)
	var style := StyleBoxFlat.new()
	style.bg_color = BTN_COLOR
	style.border_color = ACCENT
	style.set_border_width_all(1)
	style.set_corner_radius_all(4)
	btn.add_theme_stylebox_override("normal", style)
	var style_h := style.duplicate() as StyleBoxFlat
	style_h.bg_color = BTN_HOVER
	btn.add_theme_stylebox_override("hover", style_h)
	btn.add_theme_color_override("font_color", Color.WHITE)
	return btn

func _on_play() -> void:
	GameManager.start_singleplayer()

func _toggle_nations() -> void:
	_nation_panel.visible = not _nation_panel.visible

func _on_nation_selected(key: String) -> void:
	_selected_nation = key
	GameManager.set_player_nation(key)
	var label := find_child("NationLabel") as Label
	if label:
		label.text = "Fraktion: " + GameManager.get_nation(key).get("display_name", key)
	_nation_panel.visible = false
