extends Node

var money = 0
@onready var player: Player = $"../Player"
@onready var ammo_number_label: Label = $"../CanvasLayer/PanelContainer/MarginContainer/GridContainer/AmmoNumberLabel"
@onready var point_number_label: Label = $"../CanvasLayer/PanelContainer/MarginContainer/GridContainer/PointNumberLabel"

func _on_enemy_give_point(point: Variant) -> void:
	print("points: " + str(money))
	money += point
	
	
func _process(delta: float) -> void:
	ammo_number_label.text = str(player.ammo)
	point_number_label.text = str(money)
