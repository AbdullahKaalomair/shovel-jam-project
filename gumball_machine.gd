extends StaticBody2D
class_name Tower
var health = 5
var damage_sources := {}
var damage_timer := 0.0
const DAMAGE_INTERVAL := 1.0  # damage every 1 second


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if damage_sources.size() > 0:
		damage_timer += delta
		if damage_timer >= DAMAGE_INTERVAL:
			for damage in damage_sources:
				take_damage(damage_sources[damage])
			damage_timer = 0.0
	else:
		damage_timer = 0.0  # reset when not overlapping


func take_damage(damage: int):
	print(damage)
	print(health)
	health -= damage
	if health <= 0:
		queue_free()
	
#func enemy_attacking(enemy: String, damage: int):
	#print("first function")
	#damage_sources[enemy] = damage
#
#func enemy_stop_attacking(enemy: String):
	#damage_sources.erase(enemy)

func _on_area_2d_body_entered(body: Node2D) -> void:
	print(body.name)
	if body is Enemy:
		print(body)
		damage_sources[body] = body.damage


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is Enemy:
		damage_sources.erase(body)
