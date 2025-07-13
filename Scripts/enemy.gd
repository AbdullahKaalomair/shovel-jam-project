extends CharacterBody2D
class_name Enemy

var health = 3
var damage = 1
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func take_damage():
	health -= 1
	print(health)
	if health <= 0:
		queue_free()


#func _on_area_2d_body_entered(body: Node2D) -> void:
	#if body is Tower:
		#body.enemy_attacking("enemy", 1)
