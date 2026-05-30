extends Node

enum GameState { MAIN_MENU, PLAYING, PAUSED, GAME_OVER }

var current_state: GameState = GameState.MAIN_MENU
var player_nation: String = "Byzantium"
var player_name: String = "Spieler 1"

const NATIONS: Dictionary = {
	"Byzantium": {
		"display_name": "Byzantinisches Reich",
		"color": Color(0.6, 0.0, 0.8),
		"bonus": "Glaubensproduktion +25%",
		"units": ["Soldat", "Bogenschütze", "Kavallerist"],
		"starting_resources": {"gold": 500, "food": 300, "wood": 200, "faith": 100}
	},
	"Crusaders": {
		"display_name": "Kreuzfahrer",
		"color": Color(0.9, 0.9, 0.9),
		"bonus": "Kampfstärke +20%",
		"units": ["Ritter", "Armbrustschütze", "Sergeant"],
		"starting_resources": {"gold": 400, "food": 400, "wood": 300, "faith": 150}
	},
	"Saracens": {
		"display_name": "Sarazenen",
		"color": Color(0.9, 0.7, 0.0),
		"bonus": "Handelseinnahmen +30%",
		"units": ["Krieger", "Bogenschütze", "Kamelreiter"],
		"starting_resources": {"gold": 600, "food": 250, "wood": 150, "faith": 100}
	},
	"Mongols": {
		"display_name": "Mongolen",
		"color": Color(0.7, 0.4, 0.1),
		"bonus": "Bewegungsgeschwindigkeit +25%",
		"units": ["Reiter", "Bogenschütze z.Pf.", "Schamane"],
		"starting_resources": {"gold": 300, "food": 500, "wood": 100, "faith": 50}
	},
	"Mali": {
		"display_name": "Mali-Reich",
		"color": Color(0.9, 0.8, 0.0),
		"bonus": "Goldproduktion +40%",
		"units": ["Speerträger", "Bogenschütze", "Elefant"],
		"starting_resources": {"gold": 700, "food": 200, "wood": 200, "faith": 100}
	}
}

signal game_state_changed(state: GameState)

func get_nation(name: String) -> Dictionary:
	return NATIONS.get(name, {})

func get_all_nations() -> Array:
	return NATIONS.keys()

func set_player_nation(nation_name: String) -> void:
	if nation_name in NATIONS:
		player_nation = nation_name

func start_singleplayer() -> void:
	current_state = GameState.PLAYING
	get_tree().change_scene_to_file("res://scenes/main/game_scene.tscn")

func return_to_menu() -> void:
	current_state = GameState.MAIN_MENU
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main/main_menu.tscn")

func toggle_pause() -> void:
	if current_state == GameState.PLAYING:
		current_state = GameState.PAUSED
		get_tree().paused = true
	elif current_state == GameState.PAUSED:
		current_state = GameState.PLAYING
		get_tree().paused = false
	game_state_changed.emit(current_state)
