extends Control

var game_scene = "res://Scenes/game.tscn"
var tutorial_scene = ""
var options_scene = ""

var is_game_started = false

@onready var menu_container = $MenuMarginContainer
@onready var start_container = $StartMarginContainer
@onready var audio_player = $AudioStreamPlayer

var menu_music = preload("res://Assets/Sounds/Menu/Christmas synths.ogg")

func _ready() -> void:
	is_game_started = false
	menu_container.visible = false
	start_container.visible = true

func _input(event: InputEvent) -> void:
	if not is_game_started and event.is_pressed():
		is_game_started = true
		menu_container.visible = true
		start_container.visible = false
		audio_player.stream = menu_music
		audio_player.play()

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file(game_scene)


func _on_tutorial_pressed() -> void:
	get_tree().change_scene_to_file(tutorial_scene)


func _on_options_pressed() -> void:
	get_tree().change_scene_to_file(options_scene)


func _on_quit_pressed() -> void:
	get_tree().quit()
