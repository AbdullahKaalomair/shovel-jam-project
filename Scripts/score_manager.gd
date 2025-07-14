extends Node

var money = 0

func _on_enemy_give_point(point: Variant) -> void:
	print("points: " + str(money))
	money += point
