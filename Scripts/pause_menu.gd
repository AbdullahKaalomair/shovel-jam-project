extends Control


const MENU = "res://Scenes/menu.tscn"
@onready var game_manager: Node = %GameManager

func _on_resume_button_pressed() -> void:
	game_manager.pause()


func _on_quit_button_pressed() -> void:
	game_manager.pause()
	get_tree().change_scene_to_file(MENU)
	Engine.time_scale = 1
