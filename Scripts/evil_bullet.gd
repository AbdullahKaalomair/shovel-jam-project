extends RigidBody2D


const projectile_speed = 400
#const ENEMY = preload("res://Scenes/enemy.tscn")

func _ready() -> void:
	linear_velocity = Vector2(projectile_speed, 0).rotated(rotation)
 


func _on_life_time_timeout() -> void:
	queue_free()


func _on_body_entered(body: Node) -> void:
	pass


func _on_area_2d_body_entered(body: Node2D) -> void:
	queue_free()
	if body is Enemy or body is Tower_Enemy:
		body.take_damage(1)
	if body is Player:
		body.get_hit(position)
		
