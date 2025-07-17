extends Control

var game = "res://Scenes/game.tscn"

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file(game)


func _on_tutorial_pressed() -> void:
	pass # Replace with function body.


func _on_options_pressed() -> void:
	pass # Replace with function body.


func _on_quit_pressed() -> void:
	get_tree().quit()
