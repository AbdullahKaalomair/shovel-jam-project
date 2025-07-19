extends Node

@onready var player: Player = $Player
@onready var gumball_machine: Tower = %GumballMachine
@onready var machine_label: Label = $TutorialText/ComeToMeSonContainer2/MarginContainer/CenterContainer/MachineLabel

var menu_scene = "res://Scenes/menu.tscn"


func _ready() -> void:
	gumball_machine.take_damage(3)
	
	

func _process(delta):
	if gumball_machine.health > gumball_machine.max_health - 3:
		machine_label.text = "Very good Gumbo...\nProtect me at all costs..."


func _on_area_2d_body_entered(body: Node2D) -> void:
	get_tree().change_scene_to_file(menu_scene)
